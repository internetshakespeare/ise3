<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:param name="basedir"/>

    
    <xsl:variable name="siteXmlDir" select="concat($basedir,'/site/xml')"/>
    <xsl:variable name="originalDocs" select="collection(concat($siteXmlDir,'/original?select=*.xml'))"/>
    <xsl:variable name="standardDocs" select="collection(concat($siteXmlDir,'/standard?select=*.xml'))"/>
    <xsl:variable name="standaloneDocs" select="collection(concat($siteXmlDir,'/standalone?select=*.xml'))"/>
    
       
</xsl:stylesheet>