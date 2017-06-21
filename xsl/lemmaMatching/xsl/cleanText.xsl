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
            <xd:p>A simple transform that cleans up a character tokenized text.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:param name="apparatusDocPath"/>
    <xsl:variable name="apparatusDoc" select="document($apparatusDocPath)"/>
    
    
    <xsl:variable name="fromMilestones" select="for $n in $apparatusDoc//@from return hcmc:cleanAppId($n)"/>
    <xsl:variable name="toMilestones" select="for $n in $apparatusDoc//@to return hcmc:cleanAppId($n)"/>
    <xsl:variable name="allMilestones" select="distinct-values(($fromMilestones,$toMilestones))"/>

    
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>

  <xsl:template match="c[@xml:id=$allMilestones]">
      <!--A character can be both a from and a to milestone, so we have to account for both-->
      <xsl:if test="@xml:id=$fromMilestones">
          <!--If this token is the start of a span, then put an anchor preceding it-->
          <anchor>
              <xsl:attribute name="xml:id" select="concat(@xml:id,'-from')"/>
          </anchor>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test="@xml:id=$toMilestones">
          <!--If this token is the end of a span, then put an anchor following it-->
          <anchor>
              <xsl:attribute name="xml:id" select="concat(@xml:id,'-to')"/>
          </anchor>
      </xsl:if>
  </xsl:template>
    
    <xsl:template match="c">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!--Functions-->
    
    
    <xsl:function name="hcmc:cleanAppId">
        <xsl:param name="string"/>
        <xsl:value-of select="substring-before(substring-after($string,'#'),'-')"/>
    </xsl:function>
    
    
    <!--Identity-->
    
    <xsl:template match="@*|node()" priority="-1" mode="#all">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>