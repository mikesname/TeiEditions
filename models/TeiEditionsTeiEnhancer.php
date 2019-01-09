<?php
/**
 * TeiEditions
 *
 * @copyright Copyright 2018 King's College London Department of Digital Humanities
 * @license http://www.gnu.org/licenses/gpl-3.0.txt GNU GPLv3
 */

include_once dirname(__FILE__) . '/TeiEditionsDataFetcher.php';

/**
Extracts URIs of annotated/linked terms, people, organisations, places, ghettos and camps from TEI document,
fetches metadata from EHRI, Geonames and possibly other services
and adds normalised records to TEI Header.

TEI elements and services handled:
------------------------------

<placeName>
- Geonames: DONE
- EHRI camps and ghettos: TBD
- EHRI countries: TBD
- Wikidata: manually?
- Wikipedia: is used at all?

<personName>
- EHRI personalities: DONE
- Holocaust.cz: manually (no API yet)
- Yad Vashem victims database: manually (is there an API?)

<orgName>
- EHRI corporate bodies: DONE

<term>
- EHRI terms: DONE

*/
class TeiEditionsTeiEnhancer
{
    private $tei;
    private $dataSrc;
    private $doc;

    // Describes the XML paths in which to add entities,
    // the source tag from which to extract references,
    // and a function which fetches data about the references.
    private static $TYPES = [
        // dest-list-tag, dest-item-tag, dest-name-tag, src-tag, fetch-function
        ["list", "item", "name", "term", "fetchConcepts"],
        ["listOrg", "org", "orgName", "orgName", "fetchHistoricalAgents"],
        ["listPerson", "person", "persName", "persName", "fetchHistoricalAgents"],
        ["listPlace", "place", "placeName", "placeName", "fetchPlaces"],
    ];

    function __construct(SimpleXMLElement &$tei, TeiEditionsDataFetcher $src)
    {
        $this->tei = $tei;
        $this->tei->registerXPathNamespace('t', 'http://www.tei-c.org/ns/1.0');
        $this->doc = TeiEditionsDocumentProxy::fromSimpleXMLElement($tei);
        $this->dataSrc = $src;
    }

    /**
     * Extract references for a given entity tag name from a TEI
     * body text and return the data as a [$name => $url] array.
     *
     * NB: If an entity is found without a ref attribute a
     * numeric ref will be generated (and added to the document.)
     *
     * @param SimpleXMLElement $tei a TEI document
     * @param string $nameTag the tag name to locate
     * @return array an array of [name => urls]
     */
    function getReferences($nameTag, &$idx = 0)
    {
        $names = [];
        $urls = [];
        if (!($docid = (string)@$this->tei->xpath("/t:TEI/t:teiHeader/t:profileDesc/t:creation/t:idno/text()")[0])) {
            $docid = (string)$this->tei->xpath("/t:TEI/@xml:id")[0];
        }
        $paths = [
            "/t:TEI/t:teiHeader/t:profileDesc/t:creation//t:$nameTag",
            "/t:TEI/t:text/t:body/*//t:$nameTag"
        ];
        foreach ($paths as $path) {
            $nodes = $this->tei->xpath($path);
            foreach ($nodes as $node) {
                $ref = $node->xpath("./@ref");
                $text = $node->xpath("./descendant-or-self::text()");
                if ($ref) {
                    $urls[(string)($ref[0])] = (string)$text[0];
                } else {
                    $idx++;
                    $locUrl = "#" . $docid . "_" . $idx;
                    $node->addAttribute("ref", $locUrl);
                    $names[(string)($text[0])] = $locUrl;
                }
            }
        }

        return array_merge($names, array_flip($urls));
    }

    /**
     * Add an entity to the header with the given list/item/name.
     *
     * @param SimpleXMLElement $tei the TEI document
     * @param string $listTag the list tag name
     * @param string $itemTag the item tag name
     * @param string $nameTag the place tag name
     * @param TeiEditionsEntity $entity the entity
     */
    private function addEntity($listTag, $itemTag, $nameTag, TeiEditionsEntity $entity)
    {
        $source = $this->tei->teiHeader->fileDesc->sourceDesc;
        $list = $source->$listTag ? $source->$listTag : $source->addChild($listTag);

        $item = $list->addChild($itemTag);
        $item->addChild($nameTag, htmlspecialchars($entity->name));

        if ($entity->hasGeo()) {
            $location = $item->addChild('location');
            $location->addChild('geo', $entity->latitude . " " . $entity->longitude);
        }
        // Special case - if we have a local URL anchor, it refers to an xml:id
        // otherwise, add a link group.
        if ($entity->ref()[0] == '#') {
            $item->addAttribute("xml:id", substr($entity->ref(), 1),
                "http://www.w3.org/XML/1998/namespace");
        }
        if (!empty($entity->urls)) {
            $link_grp = $item->addChild('linkGrp');
            foreach ($entity->urls as $type => $url) {
                $link = $link_grp->addChild("link");
                $link->addAttribute("type", $type);
                $link->addAttribute("target", $url);
            }
        }
        if (!empty($entity->notes)) {
            $desc = $item->addChild("note");
            foreach ($entity->notes as $p) {
                $desc->addChild("p", htmlspecialchars($p));
            }
        }
    }

    /**
     * Adds references to the TEI header for the following items:
     *  - orgName
     *  - persName
     *  - placeName
     *  - term
     *
     * @return integer the number of items added.
     */
    public function addReferences()
    {
        // Index for generated entity IDs
        $idx = 0;
        $added = 0;

        foreach ($this::$TYPES as $typeSpec) {
            list($listTag, $itemTag, $nameTag, $srcTag, $fetcherFunc) = $typeSpec;

            $existing = $this->doc->entities($listTag, $itemTag, $nameTag);
            $refs = $this->getReferences($srcTag, $idx);
            foreach ($this->dataSrc->{$fetcherFunc}($refs) as $ref) {
                if (!in_array($ref, $existing)) {
                    error_log("Found $srcTag " . $ref->name);
                    $this->addEntity($listTag, $itemTag, $nameTag, $ref);
                    $added++;
                } else {
                    error_log("Not updating existing $srcTag " . $ref->name);
                }
            }
        }
        return $added;
    }
}