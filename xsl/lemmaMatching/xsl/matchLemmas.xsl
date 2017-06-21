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
            <xd:p>A transformation that takes an ISE TEI file that has been tokenized into
                characters and matches apparatus to the document.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="no" encoding="UTF-8"/>
    
    <xsl:param name="tokenizedXml"/>
    <xsl:param name="docResultsPath"/>
   
    <xsl:variable name="sourceDoc" select="document($tokenizedXml)"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="note/span">
        <xsl:copy>
            <xsl:copy-of select="@n"/>
            <xsl:copy-of select="hcmc:getCharId2(.,following-sibling::term)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="app">
        <xsl:copy>
            <xsl:copy-of select="hcmc:getCharId2(.,lem)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="hcmc:getCharId2" as="attribute()*">
        <xsl:param name="elem" as="element()"/>
        <xsl:param name="lemma" as="element()"/>
        <xsl:variable name="term" select="normalize-space(string-join($lemma/text(),''))"/>
       <!-- <xsl:message><xsl:value-of select="$term"/></xsl:message>-->
        <xsl:variable name="from" select="$elem/@from"/>
        <xsl:variable name="to" select="if ($elem[@to]) then $elem/@to else $from"/>
        <xsl:variable name="termTokens" select="tokenize(normalize-space($term),'\s*\.\s*\.\s*\.\s*')" as="xs:string+"/>
        <xsl:variable name="termCount" select="count($termTokens)"/>
        <xsl:if test="$termCount gt 2">
            <xsl:message>ERROR: "<xsl:value-of select="$term"/>" (<xsl:value-of select="$from"/>-<xsl:value-of select="$to"/>) is incorrectly delimited (<xsl:value-of select="$termCount"/> tokens).</xsl:message>
            <xsl:message terminate="yes">Aborting.</xsl:message>
        </xsl:if>
       <!-- <xsl:message>Checking <xsl:value-of select="$term"/></xsl:message>-->
        <xsl:variable name="points" as="xs:string*">
            <xsl:for-each select="$termTokens">
                <xsl:variable name="thisPos" select="position()"/>
                <xsl:variable name="termToCheck" select="."/>
               <!-- <xsl:message><xsl:value-of select="$termToCheck"/></xsl:message>-->
                <xsl:variable name="termLength" select="string-length($termToCheck)"/>
                <xsl:variable name="tlnToCheck" select="substring-after(if ($thisPos=1) then $from else $to,'tln:')"/>
                <xsl:variable name="thisTln" select="$sourceDoc//lb[@type='tln'][@n=$tlnToCheck]"/>
               <!-- <xsl:message><xsl:value-of select="$tlnToCheck"/></xsl:message>-->
                <xsl:choose>
                    <xsl:when test="not(empty($thisTln))">
                        <xsl:variable name="followingChars" select="$thisTln/following::c[substring-after(@xml:id,'_')=$tlnToCheck]"/>
                        <xsl:variable name="charsToProcess" select="if ($thisPos=1) then ($thisTln/preceding::c[position() lt $termLength],$followingChars) else $followingChars" as="element(c)+"/>
                        
                        <!--Checking variable-->
                        <xsl:variable name="idToReturn" as="xs:string*">
                            <xsl:for-each select="$charsToProcess[starts-with($termToCheck,@n)]">
                                <xsl:variable name="thisChar" select="."/>
                                <xsl:variable name="charSeq" select="($thisChar, following::c[position() lt $termLength])"/>
                                <xsl:variable name="concattedChars" select="string-join($charSeq,'')"/>
                                <xsl:if test="$concattedChars = $termToCheck">
                                    <xsl:value-of select="concat($thisChar/@xml:id,'-from')"/>
                                    <xsl:value-of select="concat($charSeq[last()]/@xml:id,'-to')"/>
                                </xsl:if>             
                            </xsl:for-each>
                        </xsl:variable>
                        
                        <xsl:variable name="idCount" select="count($idToReturn)"/>
                        <xsl:if test="$idCount gt 1">
                            <xsl:if test="$idCount gt 2">
                                <xsl:message>WARNING: Found <xsl:value-of select="$idCount"/> matches for "<xsl:value-of select="$termToCheck"/>" (TLN <xsl:value-of select="$tlnToCheck"/>). Returning the first match.</xsl:message>
                            </xsl:if>
                            <xsl:value-of select="$idToReturn[1]"/>
                            <xsl:value-of select="$idToReturn[2]"/>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>           
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <!--There should be 2 anchors for each term-->
            <xsl:when test="count($points) = $termCount * 2">
                <xsl:attribute name="from" select="concat($docResultsPath,'#',$points[1])"/>
                <xsl:attribute name="to" select="concat($docResultsPath,'#',$points[last()])"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>ERROR: Unable to find "<xsl:value-of select="$term"/>" (TLN <xsl:value-of select="concat(substring-after($from,'tln:'),'-',substring-after($to,'tln:'))"/>)</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="hcmc:getCharId">
        <xsl:param name="app" as="element()"/>
        <xsl:param name="place" as="xs:string"/>
        <xsl:variable name="isAnnotation" select="if ($app/local-name()='note') then true() else false()"/>
        <xsl:variable name="term" select="if ($isAnnotation) then normalize-space(string-join($app/term/text(),'')) else normalize-space(string-join($app/lem/text(),''))" as="xs:string"/>
        
        <!--Froms are necessary, tos are not-->
        <xsl:variable name="from" select="if ($isAnnotation) then $app/span/@from else $app/@from" as="attribute(from)"/>
        
        <!--We have to be more cautious if the phrase is across a line-->
        
        <xsl:variable name="to" select="if ($isAnnotation) then if ($app/span/@to) then $app/span/@to else $from else if ($app/@to) then $app/@to else $from" as="attribute()"/>
        
        <!--Tokenize the term based on elipses-->
        <xsl:variable name="termTokens" select="tokenize(normalize-space($term),'\s*\.\s*\.\s*\.\s*')" as="xs:string+"/>
        
        <!--Depending on if we're at the start or the end-->
        <xsl:variable name="termToCheck" select="$termTokens[if ($place='from') then 1 else last()]"/>
        
        <!--So we know how far to check-->
        <xsl:variable name="termCharCount" select="string-length($termToCheck)"/>
        
        <!--We check up one if its the 'end' test, since many end lemmas will cross across lines-->
        
        <xsl:variable name="tlnToCheck" select="if ($place='from') then substring-after($from,'tln:') else substring-after($to,'tln:')"/>
        
        <!--TLN to check-->
        <xsl:variable name="thisTln" select="$sourceDoc//lb[@type='tln'][@n=$tlnToCheck]" as="element(lb)*"/>
        <xsl:choose>
            <xsl:when test="not(empty($thisTln))">
                <xsl:variable name="followingChars" select="$thisTln/following::c[substring-after(@xml:id,'_')=$tlnToCheck]"/>
                <xsl:variable name="charsToProcess" select="if ($place='to') then ($thisTln/preceding::c[position() lt $termCharCount],$followingChars) else $followingChars" as="element(c)+"/>
                
                <!-- <xsl:message>Checking <xsl:value-of select="$termToCheck"/> (TLN <xsl:value-of select="$tlnToCheck"/>)</xsl:message>-->
                <xsl:variable name="idToReturn" as="xs:string*">
                    <xsl:for-each select="$charsToProcess[starts-with($termToCheck,@n)]">
                        <xsl:variable name="thisChar" select="."/>
                        <xsl:variable name="charSeq" select="($thisChar, following::c[position() lt $termCharCount])"/>
                        <xsl:variable name="concattedChars" select="string-join($charSeq,'')"/>
                        <xsl:if test="$concattedChars = $termToCheck">
                            <xsl:value-of select="concat(if ($place='from') then $thisChar/@xml:id else $charSeq[last()]/@xml:id,'-',$place)"/>
                        </xsl:if>             
                    </xsl:for-each>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="count($idToReturn) = 1">
                        <xsl:value-of select="$idToReturn[1]"/>
                    </xsl:when>
                    <xsl:when test="count($idToReturn) gt 1">
                        <xsl:message>Found too many matches! Returning the first one by default. (<xsl:value-of select="$termToCheck"/> (TLN <xsl:value-of select="$tlnToCheck"/>))</xsl:message>
                        <xsl:value-of select="$idToReturn[1]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>No match found. (<xsl:value-of select="$termToCheck"/> (TLN <xsl:value-of select="$tlnToCheck"/>))</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
              
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>TLN <xsl:value-of select="$tlnToCheck"/> not found (<xsl:value-of select="$termToCheck"/>)</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
      
    </xsl:function>
    
    
    <!--Identity transform; applies to all modes-->
    
    <xsl:template match="@*|node()" priority="-1" mode="#all">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>