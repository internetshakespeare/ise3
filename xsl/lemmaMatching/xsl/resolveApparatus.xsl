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
            <xd:p><xd:b>Created on:</xd:b> June 20, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> jtakeda</xd:p>
            <xd:p>This transformation attempts to match a string from
                a lemma within particular boundary points. It then adds milestone
                elements around it.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="no" encoding="UTF-8"/>
    
    
    <xsl:param name="sourceText" select="document('../../../../svn/data/texts/H5/iseH5_FM.xml')"/>
    <xsl:param name="apparatus" select="document('../../../../svn/data/texts/H5/iseH5_FM_annotations.xml')"/>
    <!--<xsl:param name="sourceText" select="document('../xml/iseH5_FM_test.xml')"/>
    <xsl:param name="apparatus" select="document('../xml/iseH5_FM_annotations_test.xml')"/>-->
    <xsl:param name="outPath" select="'../results/'"/>
    <xsl:variable name="sourceUri" select="document-uri($sourceText)"/>
    <xsl:variable name="sourceId" select="$sourceText//TEI/@xml:id"/>
    <xsl:variable name="appId" select="$apparatus//TEI/@xml:id"/>
    <xsl:variable name="docResultsUri" select="resolve-uri(concat($outPath,$sourceId,'.xml'))"/>
    <xsl:variable name="appResultsUri" select="resolve-uri(concat($outPath,$appId,'.xml'))"/>
  
    <xsl:variable name="excludedElements" select="'teiHeader'"/>
    <xsl:variable name="sourceTextWithChars">
        <xsl:apply-templates select="$sourceText" mode="firstPass"/>
    </xsl:variable>
    <xsl:variable name="sourceTextWithCharIds">
        <xsl:apply-templates select="$sourceTextWithChars" mode="secondPass"/>
    </xsl:variable>
    <xsl:variable name="finalText">
        <xsl:apply-templates select="$sourceTextWithCharIds" mode="clean"/>
    </xsl:variable>
    
    <xsl:variable name="appsWithPointers">
        <xsl:call-template name="addMilestonesToApparatus"/>
    </xsl:variable>
    
    <xsl:key name="c-to-appFrom" match="*" use="concat($docResultsUri,'#',@from)"/>
    <xsl:key name="c-to-appTo" match="*" use="concat($docResultsUri,'#',@to)"/>
    
    <xsl:template match="/">
      <xsl:message>Correlating apparatus and text...</xsl:message>
        <xsl:result-document href="{$docResultsUri}">
            <xsl:copy-of select="$finalText"/>    
        </xsl:result-document>
        <xsl:result-document href="{$appResultsUri}">
           <xsl:copy-of select="$appsWithPointers"/>
        </xsl:result-document>
    </xsl:template>
    
    
    <xsl:template name="addMilestonesToApparatus">
        <xsl:apply-templates select="$apparatus" mode="modifyApparatus"/>
    </xsl:template>
    
    
  
    <xsl:template match="note/span | app" mode="modifyApparatus">
        
        <!--<xsl:message>Checking <xsl:value-of select="if (self::span) then following-sibling::term else lem"/></xsl:message>-->
        <xsl:copy>
            <!--This function can likely be shorted so that it can output both the @to and @from
                attributes-->
            <xsl:attribute name="from" select="concat($docResultsUri,'#',hcmc:getCharId(if (self::span) then parent::note else self::app,'start'))"/>
            <xsl:attribute name="to" select="concat($docResultsUri,'#', hcmc:getCharId(if (self::span) then parent::note else self::app,'end'))"/>
            <xsl:apply-templates mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
        
    
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
        <xsl:variable name="termToCheck" select="$termTokens[if ($place='start') then 1 else last()]"/>
        
        <!--So we know how far to check-->
        <xsl:variable name="termCharCount" select="string-length($termToCheck)"/>
        
        <!--We check up one if its the 'end' test, since many end lemmas will cross across lines-->
        
        <xsl:variable name="tlnToCheck" select="if ($place='start') then substring-after($from,'tln:') else substring-after($to,'tln:')"/>
        
        <!--TLN to check-->
        <xsl:variable name="thisTln" select="$sourceTextWithCharIds//lb[@type='tln'][@n=$tlnToCheck]" as="element(lb)"/>
        <xsl:variable name="precedingTln" select="$thisTln/preceding::lb[@type='tln'][1]"/>
        <xsl:variable name="thisTlnId" select="generate-id($thisTln)"/>
        <xsl:variable name="precedingTlnId" select="generate-id($precedingTln)"/>
        <xsl:variable name="followingChars" select="$thisTln/following::c[generate-id(preceding::lb[@type='tln'][1])=$thisTlnId]"/>
        <xsl:variable name="charsToProcess" select="if ($place='end') then ($thisTln/preceding::c[position() lt $termCharCount],$followingChars) else $followingChars" as="element(c)+"/>
        
        <xsl:message>Checking <xsl:value-of select="$termToCheck"/> (TLN <xsl:value-of select="$tlnToCheck"/>)</xsl:message>
        <xsl:variable name="idToReturn" as="xs:string*">
            <xsl:for-each select="$charsToProcess[starts-with($termToCheck,@n)]">
                <xsl:variable name="thisChar" select="."/>
                <xsl:variable name="charSeq" select="($thisChar, following::c[position() lt $termCharCount])"/>
                <xsl:variable name="concattedChars" select="string-join($charSeq,'')"/>
                <xsl:if test="$concattedChars = $termToCheck">
                    <xsl:value-of select="if ($place='start') then $thisChar/@xml:id else $charSeq[last()]/@xml:id"/>
                </xsl:if>             
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="count($idToReturn) = 1">
              <!--  <xsl:message>Found match.</xsl:message>-->
            </xsl:when>
            <xsl:when test="count($idToReturn) gt 1">
                <xsl:message>Found too many matches! Returning the first one by default. (<xsl:value-of select="$termToCheck"/> (TLN <xsl:value-of select="$tlnToCheck"/>))</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>No match found. (<xsl:value-of select="$termToCheck"/> (TLN <xsl:value-of select="$tlnToCheck"/>))</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$idToReturn[1]"/>
    </xsl:function>
    
    
    
    <!--Second pass template-->
    
    <xsl:template match="c" mode="secondPass">
        <xsl:copy>
            <xsl:attribute name="xml:id" select="generate-id(.)"/>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!--First pass template-->
    
    <xd:doc>
        <xd:desc>
            <xd:ref name="tokenizeText" type="template"/>
            <xd:p>This template tokenizes the text.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="text()[ancestor::text]" name="tokenizeText" mode="firstPass">
        <xsl:analyze-string select="." regex="." flags="s">
            <xsl:matching-substring>
                <c n="{.}"><xsl:value-of select="."/></c>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!--Third pass cleaning transform, which just gets rid of the temporary stuff made in pass 1-->
    
 <!--   <xsl:template match="c" mode="clean">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    -->
    <xsl:template match="c" mode="clean">
        <xsl:variable name="thisId" select="concat($docResultsUri,'#',@xml:id)"/>
        <xsl:choose>
            <xsl:when test="$appsWithPointers//@from=$thisId">
                <anchor>
                    <xsl:attribute name="xml:id" select="@xml:id"/>
                </anchor>
                <xsl:apply-templates mode="#current"/>
            </xsl:when>
            <xsl:when test="$appsWithPointers//@to=$thisId">
                <xsl:apply-templates mode="#current"/>
                <anchor>
                    <xsl:attribute name="xml:id" select="@xml:id"/>
                </anchor>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="#current"/>
            </xsl:otherwise>
        </xsl:choose>
       
    </xsl:template>
    

    
    
    <!--Identity transform; applies to all modes-->
    
    <xsl:template match="@*|node()" priority="-1" mode="#all">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>