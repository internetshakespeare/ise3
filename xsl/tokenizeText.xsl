<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> June 21, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> jtakeda</xd:p>
            <xd:p>This transformation tokenizes a base text based on characters. It
            is a simple identity transform.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="no" method="xml" encoding="UTF-8"/>
    
    <xsl:template match="/">
        <xsl:variable name="firstPass">
            <xsl:apply-templates mode="tokenize"/>
        </xsl:variable>
        <xsl:apply-templates select="$firstPass" mode="generateIds"/>
    </xsl:template>
    
    <xsl:template match="c" mode="generateIds">
        <xsl:variable name="precedingTln" select="preceding::lb[@type = 'tln' or @subtype='tln'][1]"/>
        <xsl:copy>
            <xsl:attribute name="xml:id" select="concat(generate-id(.),'_',$precedingTln/@n)"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!--No point in tokenizing just plain whitespace that will never be a lemma anyway-->
    <xsl:template match="text()[ancestor::text][preceding::lb][not(parent::front|parent::back|parent::body|parent::div|parent::lg|parent::sp)]" name="tokenizeText" mode="tokenize">
       
        <xsl:analyze-string select="." regex="." flags="s">
            <xsl:matching-substring>
                <c n="{.}"><xsl:value-of select="."/></c>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    
    <!--Identity transform; applies to all modes-->
    
    <xsl:template match="@*|node()" priority="-1" mode="#all">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>