<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:template match="/">
        <div class="document-text">
            <xsl:for-each select="/tei:TEI/tei:text/tei:body/tei:p">
                <p><xsl:value-of select="."/></p>
            </xsl:for-each>
        </div>
    </xsl:template>
</xsl:stylesheet>
