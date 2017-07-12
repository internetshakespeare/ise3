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
            <xd:p><xd:b>Created on:</xd:b> July 12, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> jtakeda</xd:p>
            <xd:p>This is a temporary transformation so that we can have documentation rendered on the site.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:param name="dataDir"/>
    <xsl:param name="outDir"/>
   
   <xsl:variable name="docsToBuild" select="collection(concat($dataDir,'/documentation?select=*.xml'))"/>
    
    <xsl:template match="/">
        <xsl:for-each select="$docsToBuild">
            <xsl:variable name="docName" select="//TEI/@xml:id"/>
            <xsl:result-document href="{concat($outDir,'/',$docName,'.xml')}">
                <xsl:apply-templates/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="TEI">
        <xsl:processing-instruction name="xml-stylesheet">type="text/xsl" href="../teibp/dist/content/teibp.xsl"</xsl:processing-instruction>
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="processing-instruction()"/>
    
    <xsl:template match="@*|node()" priority="-1">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>