<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:redirect="http://xml.apache.org/xalan/redirect" xmlns:xalan="http://xml.apache.org/xalan" xmlns:ehri="https://ehri-project.eu/functions" xmlns:func="http://exslt.org/functions" extension-element-prefixes="xalan redirect func ehri" exclude-result-prefixes="xhtml tei">
    <xsl:output indent="yes" omit-xml-declaration="yes" encoding="utf-8" method="xml" xalan:indent-amount="4"/>

    <xsl:param name="lang" select="'en'"/>

    <ehri:strings>
        <search xml:lang="en">Search in this edition</search>
        <search xml:lang="de">Suche in der Edition</search>
        <ehriPortal xml:lang="en">View in EHRI Portal</ehriPortal>
        <ehriPortal xml:lang="de">Im EHRI Portal anzeigen</ehriPortal>
        <geonames xml:lang="en">View in Geonames</geonames>
        <geonames xml:lang="de">In Geonames anzeigen</geonames>
        <wikipedia xml:lang="en">View in Wikipedia</wikipedia>
        <wikipedia xml:lang="de">In Wikipedia anzeigen</wikipedia>
        <holocaustCz xml:lang="en">View in Holocaust.cz</holocaustCz>
        <holocaustCz xml:lang="de">In Holocaust.cz anzeigen</holocaustCz>
        <person xml:lang="en">Person</person>
        <person xml:lang="de">Person</person>
        <place xml:lang="en">Place</place>
        <place xml:lang="de">Ort</place>
        <organisation xml:lang="en">Organisation</organisation>
        <organisation xml:lang="de">Organisation</organisation>
        <subject xml:lang="en">Subject</subject>
        <subject xml:lang="de">Thema</subject>
        <textFromPage xml:lang="en">Text from page </textFromPage>
        <textFromPage xml:lang="de">Text von Seite </textFromPage>
    </ehri:strings>

    <xsl:variable name="messages" select="document('')/*/ehri:strings"/>

    <func:function name="ehri:url-label">
        <xsl:param name="url"/>
        <xsl:param name="default"/>

        <func:result>
            <xsl:choose>
                <xsl:when test="contains($url, 'portal.ehri-project.eu')">
                    <xsl:value-of select="$messages/ehriPortal[lang($lang)]"/>
                </xsl:when>
                <xsl:when test="contains($url, 'geonames.org')">
                    <xsl:value-of select="$messages/geonames[lang($lang)]"/>
                </xsl:when>
                <xsl:when test="contains($url, 'holocaust.cz')">
                    <xsl:value-of select="$messages/holocaustCz[lang($lang)]"/>
                </xsl:when>
                <xsl:when test="contains($url, 'wikipedia.org')">
                    <xsl:value-of select="$messages/wikipedia[lang($lang)]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$default"/>
                </xsl:otherwise>
            </xsl:choose>
        </func:result>
    </func:function>

    <func:function name="ehri:slugify">
        <xsl:param name="elem"/>

        <xsl:variable name="url" select="$elem/attribute::ref"/>

        <xsl:variable name="ehri-auth" select="'https://portal.ehri-project.eu/authorities/'"/>
        <xsl:variable name="ehri-term" select="'https://portal.ehri-project.eu/keywords/'"/>
        <xsl:variable name="ehri-unit" select="'https://portal.ehri-project.eu/units/'"/>
        <xsl:variable name="ehri-inst" select="'https://portal.ehri-project.eu/institutions/'"/>
        <xsl:variable name="geonames1" select="'http://sws.geonames.org/'"/>
        <xsl:variable name="geonames2" select="'http://www.geonames.org/'"/>
        <xsl:variable name="holocaustcz" select="'https://www.holocaust.cz/databaze-obeti/obet/'"/>

        <func:result>
            <xsl:choose>
                <xsl:when test="starts-with($url, '#')">
                    <xsl:value-of select="substring-after($url, '#')"/>
                </xsl:when>
                <xsl:when test="starts-with($url, $ehri-auth)">
                    <xsl:value-of select="concat('ehri-authority-', substring-after($url, $ehri-auth))"/>
                </xsl:when>
                <xsl:when test="starts-with($url, $ehri-term)">
                    <xsl:value-of select="concat('ehri-term-', substring-after($url, $ehri-term))"/>
                </xsl:when>
                <xsl:when test="starts-with($url, $ehri-unit)">
                    <xsl:value-of select="concat('ehri-unit-', substring-after($url, $ehri-unit))"/>
                </xsl:when>
                <xsl:when test="starts-with($url, $ehri-inst)">
                    <xsl:value-of select="concat('ehri-institution-', substring-after($url, $ehri-inst))"/>
                </xsl:when>
                <xsl:when test="starts-with($url, $geonames1)">
                    <xsl:value-of select="concat('geonames-', substring-after($url, $geonames1))"/>
                </xsl:when>
                <xsl:when test="starts-with($url, $geonames2)">
                    <xsl:value-of select="concat('geonames-', substring-before(substring-after($url, $geonames2),'/'))"/>
                </xsl:when>
                <xsl:when test="starts-with($url, $holocaustcz)">
                    <xsl:value-of select="concat('holocaust-cz-', substring-after($url, $holocaustcz))"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </func:result>
    </func:function>

    <func:function name="ehri:get-id">
        <func:result>
            <xsl:choose>
                <xsl:when test="./tei:linkGrp/tei:link[@type='normal']">
                    <xsl:value-of select="./tei:linkGrp/tei:link[@type='normal']/@target"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat('#', @xml:id)"/>
                </xsl:otherwise>
            </xsl:choose>
        </func:result>
    </func:function>

    <xsl:template name="entity-header">
        <xsl:param name="type"/>
        <xsl:param name="name"/>
        <h5>
            <xsl:value-of select="normalize-space($type)"/>:
            <xsl:value-of select="normalize-space($name)"/>
        </h5>
    </xsl:template>

    <xsl:template name="entity-body">
        <xsl:param name="link"/>
        <xsl:param name="name"/>
        <xsl:param name="search-type"/>

        <xsl:variable name="note" select="./tei:note"/>

        <div class="content-info-entity-body">
            <xsl:if test="$note">
                <div class="content-info-entity-note">
                    <xsl:copy-of select="$note/node()"/>
                </div>
            </xsl:if>

            <xsl:variable name="desc">
                <xsl:value-of select="./tei:linkGrp/tei:link[@type='desc']/@target"/>
            </xsl:variable>
            <ul class="content-info-entity-footer">
                <li>
                    <a class="tei-entity-search" target="_parent">
                        <xsl:attribute name="href">
                            <xsl:value-of select="concat('/search?q=*&amp;f[]=', $search-type, ':', $name)"/>
                        </xsl:attribute>
                        <div class="material-icons">search</div>
                        <xsl:value-of select="$messages/search[lang($lang)]"/>
                    </a>
                </li>
                <xsl:if test="starts-with($link, 'http')">
                    <li>
                        <a target="_blank">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$link"/>
                            </xsl:attribute>
                            <div class="material-icons">launch</div>
                            <xsl:value-of select="ehri:url-label($link, 'View')"/>
                        </a>
                    </li>
                </xsl:if>
                <xsl:if test="$desc != ''">
                    <li>
                        <a class="tei-entity-description" target="_blank">
                            <xsl:attribute name="href">
                                <xsl:value-of select="$desc"/>
                            </xsl:attribute>
                            <div class="material-icons">info_outline</div>
                            <xsl:value-of select="ehri:url-label($desc, $messages/wikipedia[lang($lang)])"/>
                        </a>
                    </li>
                </xsl:if>
            </ul>
        </div>
    </xsl:template>

    <xsl:template name="place-entity">
        <xsl:variable name="link" select="ehri:get-id()"/>
        <div class="content-info-entity tei-entity tei-place">
            <xsl:attribute name="data-ref">
                <xsl:value-of select="$link"/>
            </xsl:attribute>
            <xsl:call-template name="entity-header">
                <xsl:with-param name="type" select="$messages/place[lang($lang)]"/>
                <xsl:with-param name="name" select="./tei:placeName"/>
            </xsl:call-template>
            <xsl:call-template name="entity-body">
                <xsl:with-param name="link" select="$link"/>
                <xsl:with-param name="name" select="normalize-space(./tei:placeName)"/>
                <xsl:with-param name="search-type">Place</xsl:with-param>
            </xsl:call-template>
        </div>
    </xsl:template>

    <xsl:template name="person-entity">
        <xsl:variable name="link" select="ehri:get-id()"/>
        <div class="content-info-entity tei-entity tei-person">
            <xsl:attribute name="data-ref">
                <xsl:value-of select="$link"/>
            </xsl:attribute>
            <xsl:call-template name="entity-header">
                <xsl:with-param name="type" select="$messages/person[lang($lang)]"/>
                <xsl:with-param name="name" select="./tei:persName"/>
            </xsl:call-template>
            <xsl:call-template name="entity-body">
                <xsl:with-param name="link" select="$link"/>
                <xsl:with-param name="name" select="normalize-space(./tei:persName)"/>
                <xsl:with-param name="search-type">Person</xsl:with-param>
            </xsl:call-template>
        </div>
    </xsl:template>

    <xsl:template name="org-entity">
        <xsl:variable name="link" select="ehri:get-id()"/>
        <div class="content-info-entity tei-entity tei-org">
            <xsl:attribute name="data-ref">
                <xsl:value-of select="$link"/>
            </xsl:attribute>
            <xsl:call-template name="entity-header">
                <xsl:with-param name="type" select="$messages/organisation[lang($lang)]"/>
                <xsl:with-param name="name" select="./tei:orgName"/>
            </xsl:call-template>
            <xsl:call-template name="entity-body">
                <xsl:with-param name="link" select="$link"/>
                <xsl:with-param name="name" select="normalize-space(./tei:orgName)"/>
                <xsl:with-param name="search-type">Organisation</xsl:with-param>
            </xsl:call-template>
        </div>
    </xsl:template>

    <xsl:template name="term-entity">
        <xsl:variable name="link" select="ehri:get-id()"/>
        <div class="content-info-entity tei-entity tei-term">
            <xsl:attribute name="data-ref">
                <xsl:value-of select="$link"/>
            </xsl:attribute>
            <xsl:call-template name="entity-header">
                <xsl:with-param name="type" select="$messages/subject[lang($lang)]"/>
                <xsl:with-param name="name" select="./tei:name"/>
            </xsl:call-template>
            <xsl:call-template name="entity-body">
                <xsl:with-param name="link" select="$link"/>
                <xsl:with-param name="name" select="normalize-space(./tei:name)"/>
                <xsl:with-param name="search-type">Subject</xsl:with-param>
            </xsl:call-template>
        </div>
    </xsl:template>

    <xsl:template match="tei:pb" name="page">
        <xsl:variable name="pageno" select="@n"/>

        <xsl:if test="$pageno">
            <div class="element-text-page">
                <div class="element-text-page-icon material-icons">insert_drive_file</div>
                <xsl:value-of select="$messages/textFromPage[lang($lang)]"/>
                <xsl:value-of select="$pageno"/>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:q" name="quote">
        <q>
            <xsl:apply-templates/>
        </q>
    </xsl:template>

    <xsl:template match="tei:list" name="list">
        <ol>
            <xsl:for-each select="./tei:item">
                <li>
                    <xsl:apply-templates/>
                </li>
            </xsl:for-each>
        </ol>
    </xsl:template>

    <xsl:template match="tei:table" name="table">
        <table>
            <xsl:apply-templates/>
        </table>
    </xsl:template>

    <xsl:template match="tei:row" name="table-row">
        <tr>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>

    <xsl:template match="tei:cell" name="table-cell">
        <xsl:choose>
            <xsl:when test="./parent::node()[@role='label']">
                <th>
                    <xsl:apply-templates/>
                </th>
            </xsl:when>
            <xsl:otherwise>
                <td>
                    <xsl:if test="./@role">
                        <xsl:attribute name="class">
                            <xsl:value-of select="./@role"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </td>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:del" name="deleted">
        <del>
            <xsl:apply-templates/>
        </del>
    </xsl:template>

    <xsl:template match="tei:p" name="identity">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="tei:note" name="notes">
        <xsl:variable name="num" select="count(../preceding-sibling::*/tei:note) + 1"/>
        <span class="tei-note-ref">
            <xsl:value-of select="$num"/>
        </span>
        <span class="tei-note">
            <span class="tei-note-num">Note <xsl:value-of select="$num"/>:
            </span>
            <xsl:value-of select="."/>
        </span>
    </xsl:template>

    <xsl:template match="tei:term|tei:placeName|tei:persName|tei:orgName">
        <span class="tei-entity-ref">
            <xsl:attribute name="data-ref">
                <xsl:value-of select="attribute::ref"/>
            </xsl:attribute>
            <xsl:attribute name="data-neatline-slug">
                <xsl:value-of select="ehri:slugify(.)"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="/">
        <div class="tei">
            <div class="tei-entities">
                <xsl:comment>TEI Entities</xsl:comment>
                <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listPlace/tei:place">
                    <xsl:call-template name="place-entity"/>
                </xsl:for-each>

                <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:list/tei:item">
                    <xsl:call-template name="term-entity"/>
                </xsl:for-each>

                <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listPerson/tei:person">
                    <xsl:call-template name="person-entity"/>
                </xsl:for-each>

                <xsl:for-each select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listOrg/tei:org">
                    <xsl:call-template name="org-entity"/>
                </xsl:for-each>
            </div>

            <div class="tei-text" dir="auto">
                <xsl:comment>TEI Text</xsl:comment>
                <xsl:apply-templates select="tei:TEI/tei:text/tei:body/*"/>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>