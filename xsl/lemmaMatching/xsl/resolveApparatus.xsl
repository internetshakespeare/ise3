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
    
    <xsl:output indent="yes" encoding="UTF-8"/>
    
    <xsl:param name="sourceText" select="document('../xml/iseH5_FM.xml')"/>
    <xsl:param name="apparatus" select="document('../xml/iseH5_FM_annotations.xml')"/>
    <xsl:variable name="docOutPath" select="'../results/iseH5_FM_withMilestones.xml'"/>
    <xsl:variable name="appOutPath" select="'../results/iseH5_FM_annotations_withMilestones.xml'"/>
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
    
    
    <!--This has to be figured out a bit better-->
    <xsl:variable name="apps" select="$apparatus//app"/>
    <xsl:variable name="notes" select="$apparatus//note"/>
    
    <xsl:template match="/">
        <xsl:message>Matching apparatus...</xsl:message>
        <xsl:result-document href="{$docOutPath}">
            <xsl:copy-of select="$finalText"/>    
        </xsl:result-document>
        <xsl:result-document href="{$appOutPath}">
           <xsl:copy-of select="$appsWithPointers"/>
        </xsl:result-document>
    </xsl:template>
    
    
    <xsl:template name="addMilestonesToApparatus">
        <xsl:apply-templates select="$apparatus" mode="modifyApparatus"/>
    </xsl:template>
    
    
  
    <xsl:template match="note/span" mode="modifyApparatus">
        <xsl:variable name="term" select="following-sibling::term"/>
        <xsl:message>Checking <xsl:value-of select="$term"/></xsl:message>
        <xsl:copy>
            <xsl:attribute name="from" select="concat('iseH5_FM_withMilestones.xml#',hcmc:getCharId(parent::note,'start'))"/>
            <xsl:attribute name="to" select="concat('iseH5_FM_withMilestones.xml#',hcmc:getCharId(parent::note,'end'))"/>
        </xsl:copy>
    </xsl:template>
    
    
    <xsl:function name="hcmc:getCharId">
        <xsl:param name="note" as="element()"/>
        <xsl:param name="place" as="xs:string"/>
        
        <xsl:variable name="term" select="$note/term"/>
        
        <!--Froms are necessary, tos are not-->
        <xsl:variable name="from" select="$note/span/@from" as="attribute(from)"/>
        
        <!--We have to be more cautious if the phrase is across a line-->
        
        <xsl:variable name="to" select="if ($note/span/@to) then $note/span/@to else $from" as="attribute()"/>
        
        <!--Tokenize the term based on elipses-->
        <xsl:variable name="termTokens" select="tokenize(normalize-space($term),'\s*\.\s*\.\s*\.\s*')" as="xs:string+"/>
        
        <!--Depending on if we're at the start or the end-->
        <xsl:variable name="termToCheck" select="$termTokens[if ($place='start') then 1 else last()]"/>
        
        <!--So we know how far to check-->
        <xsl:variable name="termCharCount" select="string-length($termToCheck)"/>
        
        <!--We check up one if its the 'end' test, since many end lemmas will cross across lines-->
        
        <xsl:variable name="tlnToCheck" select="if ($place='start') then substring-after($from,'tln:') else number(substring-after($to,'tln:'))"/>
        
        
        
        
        <!--TLN to check-->
        <xsl:variable name="thisTln" select="$sourceTextWithCharIds//lb[@type='tln'][@n=$tlnToCheck]" as="element(lb)"/>
        <xsl:variable name="nextTln" select="$thisTln/following::lb[@type='tln'][1]" as="element(lb)"/>
        
        <xsl:variable name="followingChars" as="element(c)+">
            <xsl:choose>
                <xsl:when test="$place='end'">
                    <xsl:sequence select="$thisTln/preceding::c[position() lt $termCharCount],$thisTln/following::c[generate-id(preceding::lb[@type='tln'][1])=generate-id($thisTln)]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$thisTln/following::c[generate-id(preceding::lb[@type='tln'][1])=generate-id($thisTln)]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="idToReturn" as="xs:string*">
            <xsl:for-each select="$followingChars[starts-with($termToCheck,@n)]">
                <xsl:variable name="thisChar" select="."/>
                <xsl:variable name="charSeq" select="($thisChar, following::c[position() lt $termCharCount])"/>
                <xsl:variable name="concattedChars" select="string-join($charSeq,'')"/>
                <xsl:message><xsl:value-of select="$concattedChars"/>: <xsl:value-of select="string-length($concattedChars)"/></xsl:message>
                <xsl:if test="$concattedChars = $termToCheck">
                    <xsl:value-of select="if ($place='start') then $thisChar/@xml:id else $charSeq[last()]/@xml:id"/>
                </xsl:if>             
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="count($idToReturn) = 1">
                <xsl:message>Found match.</xsl:message>
            </xsl:when>
            <xsl:when test="count($idToReturn) gt 1">
                <xsl:message>Found too many matches!</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>No match found.</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$idToReturn"/>
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
    <xsl:template match="text()[ancestor::body]" name="tokenizeText" mode="firstPass">
        <xsl:analyze-string select="." regex="." flags="s">
            <xsl:matching-substring>
                <c n="{.}"><xsl:value-of select="."/></c>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!--Third pass cleaning transform, which just gets rid of the temporary stuff made in pass 1-->
    
    <xsl:template match="c" mode="clean">
        
        <xsl:choose>
            <xsl:when test="concat('iseH5_FM_withMilestones.xml#',@xml:id) = $appsWithPointers//@from">
                <anchor>
                    <xsl:attribute name="xml:id" select="@xml:id"/>
                </anchor>
                <xsl:apply-templates mode="#current"/>
            </xsl:when>
            <xsl:when test="concat('iseH5_FM_withMilestones.xml#',@xml:id)=$appsWithPointers//@to">
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