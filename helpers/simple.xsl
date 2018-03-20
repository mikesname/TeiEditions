<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:output indent="yes" omit-xml-declaration="yes" encoding="utf-8" method="xml"/>
    <xsl:strip-space elements="*"/>

    <xsl:template match="tei:p" name="identity">
        <xsl:apply-templates select="node()|@*"/>
    </xsl:template>

    <xsl:template match="tei:term|tei:placeName|tei:persName|tei:orgName">
        <span class="tei-entity">
            <xsl:attribute name="data-ref"><xsl:value-of select="attribute::ref"/></xsl:attribute>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="/">
        <div class="tei-text">
            <xsl:for-each select="/tei:TEI/tei:text/tei:body/tei:p">
                <p><xsl:call-template name="identity"/></p>
            </xsl:for-each>
        </div>
    </xsl:template>
</xsl:stylesheet>