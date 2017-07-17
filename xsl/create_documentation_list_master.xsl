<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:include href="globals.xsl"/>
    <xsl:param name="outDoc"/>
    
    <xsl:output encoding="UTF-8" indent="no" method="text"/>
    
    <!--Apparatus docs-->
    <xsl:variable name="documentationDocTargets" select="$originalDocs//TEI[descendant::catRef[starts-with(@target,'idt:idtDocumentation')]]/@xml:id" as="xs:string+"/>
    <xsl:variable name="distinctTargs" select="distinct-values($documentationDocTargets)"/>
    
    
    <xsl:template match="/">
        <xsl:result-document href="{$outDoc}">
            <!--<xsl:for-each select="$docsToList">
                <xsl:value-of select="substring-after(.,'doc:')"/><xsl:if test="not(position()=last())"><xsl:text>&#x0a;</xsl:text></xsl:if>
            </xsl:for-each>-->
            <xsl:for-each select="$distinctTargs">
                <xsl:value-of select="."/><xsl:if test="not(position()=last())"><xsl:text>&#x0a;</xsl:text></xsl:if>
            </xsl:for-each>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>