<?php
/**
 * TeiEditions
 *
 * @copyright Copyright 2017 King's College London Department of Digital Humanities
 * @license http://www.gnu.org/licenses/gpl-3.0.txt GNU GPLv3
 */

/**
 * Miscellaneous TEI functions.
 *
 * @package TeiEditions
 */

/**
 * Determine if an URL is an XML file.
 *
 * @param $file_url
 * @return bool
 */

function tei_editions_is_xml_file($file_or_path)
{
    $path = $file_or_path instanceof File
        ? $file_or_path->getWebPath()
        : $file_or_path;
    $url = strpos($path, "?")
        ? substr($path, 0, strpos($path, "?"))
        : $path;

    $suffix = ".xml";
    $length = strlen($suffix);

    return $length === 0 ? $length : (substr($url, -$length) === $suffix);
}

function full_path_to($file)
{
    return (isset($_SERVER['HTTPS']) ? "https" : "http") . "://$_SERVER[HTTP_HOST]" . web_path_to($file);
}

function tei_editions_prettify_tei($path, $img_map)
{

    $teipb = dirname(__FILE__) . '/simple.xsl';

    $xsldoc = new DOMDocument();
    $xsldoc->load($teipb);
    $xsldoc->documentURI = $teipb;

    $xmldoc = new DOMDocument();
    $xmldoc->loadXML(file_get_contents($path));
    $xmldoc->documentURI = $path;

    // NB: Suppress annoying warnings here...
    //$xmldoc = tei_editions_replace_urls_xml($xmldoc, $img_map);

    $proc = new XSLTProcessor;
    $proc->importStylesheet($xsldoc);
    return $proc->transformToXml($xmldoc);
}

function tei_editions_replace_urls_xml(DOMDocument $doc, $map)
{
    $filename = full_path_to('teibp/content/replace-urls.xsl');
    $xsldoc = new DOMDocument();
    $xsldoc->loadXML(file_get_contents($filename));

    foreach ($xsldoc->getElementsByTagName('url-lookup') as $elem) {
        foreach ($map as $name => $path) {
            $kv = $xsldoc->createElement('entry');
            $kv->setAttribute('key', $name);
            $kv->appendChild($xsldoc->createTextNode($path));
            $elem->appendChild($kv);
        }
    }

    $proc = new XSLTProcessor();
    $proc->registerPHPFunctions('basename');
    $proc->importStylesheet($xsldoc);
    return $proc->transformToDoc($doc);
}

function tei_editions_check_xpath_is_valid($path)
{
    $xpath = new DOMXPath(new DOMDocument);
    $xpath->registerNamespace("tei", "http://www.tei-c.org/ns/1.0");
    $check = $xpath->evaluate($path);
    return $check !== false;
}

/**
 * Render the first XML file associated with the item as TEI.
 *
 * @param Item $item an Omeka item
 * @return string
 */
function tei_editions_render_item(Item $item)
{
    $files = $item->getFiles();

    $file_url_map = array();
    foreach ($files as $file) {
        $file_url_map[basename($file->original_filename)] = $file->getWebPath();
    }

    $xml = "";
    foreach ($files as $file) {
        $path = $file->getWebPath();
        if (tei_editions_is_xml_file($path)) {
            $xml .= @tei_editions_prettify_tei($path, $file_url_map);
            break;
        }
    }
    return $xml;
}

function tei_editions_get_tei_path(Item $item)
{
    foreach ($item->getFiles() as $file) {
        $path = $file->getWebPath();
        if (tei_editions_is_xml_file($path)) {
            return $path;
        }
    }
    return null;
}

/**
 * Average an array of long/lat arrays.
 *
 * @param $points
 * @return array average long/lat values
 */
function tei_editions_centre_points($points)
{
    $num = count($points);
    $lons = array_map(function ($p) {return $p[0];}, $points);
    $lats = array_map(function ($p) {return $p[1];}, $points);
    return array(array_sum($lons) / $num, array_sum($lats) / $num);
}

/**
 * Hack to convert degrees to Neatline's metres:
 *
 * http://neatline.org/2012/09/10/geocoding-for-neatline-part-i/
 *
 * @param $coords array an array containing latitude and longitude keys
 * in degrees
 *
 * @return array an array containing latitude and longitude keys
 * in metres
 */
function tei_editions_degrees_to_metres($lon_lat)
{
    $half_circumference = 20037508.34;

    $x = $lon_lat[0] * $half_circumference / 180;
    $y = log(tan((90 + $lon_lat[1]) * pi() / 360)) / (pi() / 180);
    $y = $y * $half_circumference / 180;
    return array($x, $y);
}
