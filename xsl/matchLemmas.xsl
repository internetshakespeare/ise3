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
            <xd:p>Expected input: a valid ISE-TEI apparatus file (annotations or collations)
                that have @to and @from attributes that denote tln milestones</xd:p>
        </xd:desc>
        <xd:param name="tokenizedXml">
            <xd:p>A valid ISE TEI file with each character wrapped in a 
                &lt;c/&gt; element.</xd:p>
        </xd:param>
        <xd:param name="docResulsPath">
            <xd:p>A string path to the ISE TEI file.</xd:p>
        </xd:param>
        <xd:return>
            <xd:p>A valid ISE-TEI apparatus file with its @to and @from tln values 
            replaced with specific anchors in the ISE text. Note that this XSLT does not 
            add the markers, just creates a list of necessary anchors. See 
            <xd:a href="cleanText.xsl">this transform</xd:a>.</xd:p>
        </xd:return>
    </xd:doc>
    
    <!--Don't indent-->
    <xsl:output indent="no" encoding="UTF-8"/>
    
    <xsl:param name="tokenizedXml"/>
   
   <xd:doc scope="component">
       <xd:desc>
           <xd:ref name="sourceDoc" type="variable"/>
           <xd:p>The tokenized TEI-XML text onto which we map apparatus</xd:p>
       </xd:desc>
   </xd:doc>
    <xsl:variable name="sourceDoc" select="document($tokenizedXml)"/>
    <xsl:variable name="sourceDocId" select="$sourceDoc//TEI/@xml:id"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="matchSpan" type="template"/>
            <xd:ref name="matchApp" type="template"/>
            <xd:p>matchApp and matchSpan are two mutually exclusive cases, depending on
            what type of apparatus we are matching. If we are matching against annotations, 
            then matchSpan; if collations, then app.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="note/span" name="matchSpan">
        <xsl:copy>
            <xsl:copy-of select="@n"/>
            <xsl:copy-of select="hcmc:getCharId(.,following-sibling::term)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="app" name="matchApp">
        <xsl:copy>
            <xsl:copy-of select="hcmc:getCharId(.,lem)"/>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="hcmc:getCharId" type="function"/>
            <xd:p>This function takes in an element and a lemma and
            returns the @from and @to with pointers to the characters
            that begin and end (respectively) the lemma.</xd:p>
        </xd:desc>
        <xd:param name="elem">
            <xd:p>The element that we are processing (either app or span)</xd:p>
        </xd:param>
        <xd:param name="lemma">
            <xd:p>The term we are attempting to match (if app, &lt;lem&gt;;
                if note, &lt;span&gt;)</xd:p>
        </xd:param>
        <xd:return>
            <xd:p>Either a @to and an @from attribute or nothing at all.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:function name="hcmc:getCharId" as="attribute()*">
        <xsl:param name="elem" as="element()"/>
        <xsl:param name="lemma" as="element()"/>
        
        <!--Sometimes term contain descendent markup. We ignore it any text
        that is not a direct child of term.-->
        
        <xsl:variable name="lemmaText" select="normalize-space(string-join($lemma/text(),''))"/>
        
        <xsl:variable name="terms" as="xs:string+">
            <xsl:choose>
                <xsl:when test="$lemma[gap] or $lemma[lb]">
                    <xsl:value-of select="normalize-space($lemma/text()[1])"/>
                    <xsl:value-of select="normalize-space($lemma/text()[last()])"/>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(string-join($lemma/text(),''))"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
   
       
        <xsl:variable name="from" select="$elem/@from"/>
        
        <!--It is completely valid for apparatus not to have @to values, since
            a term might be on a single TLN. But since we are attempting to 
            give definitive start and end points to the term, we construct a
            @to-->
        <xsl:variable name="to" select="if ($elem[@to]) then $elem/@to else $from"/>
        
        <xsl:variable name="termCount" select="count($terms)"/>
        
        <!--The points variable will contain a sequence of 0 or more ids
            that correspond to the lemmas.-->
        <xsl:variable name="points" as="xs:string*">
            <!--We take each side of the term in turn-->
            <xsl:for-each select="$terms">
                
                <!--We need to know where we are in the term sequence-->
                <xsl:variable name="thisPos" select="position()"/>
                
                <!--This term, for context-->
                <xsl:variable name="termToCheck" select="."/>
                
                <!--The length of the term-->
                <xsl:variable name="termLength" select="string-length($termToCheck)"/>
                
                <!--This is the TLN value to check (TLN:###). If we are matching in 
                    the first term, then use $from else use $to (which might be the 
                    same as $from)-->
                <xsl:variable name="tlnToCheck" select="substring-after(if ($thisPos=1) then $from else $to,'tln:')"/>
                
                <!--The line break element that corresponds with this TLN element-->
                <xsl:variable name="thisTln" select="$sourceDoc//lb[@type = 'tln' or @subtype='tln'][@n=$tlnToCheck]"/>
                
                <!--When there is a lb element that corresponds with this
                    TLN, continue. Otherwise, report the error-->
                <xsl:choose>
                    <xsl:when test="not(empty($thisTln))">
                        
                        <!--All of the characters that appear after the chosen TLN. Note that
                            the characters have been preprocessed so that their xml:ids contain
                            the TLN.-->
                        <xsl:variable name="followingChars" select="$thisTln/following::c[substring-after(@xml:id,'_')=$tlnToCheck]"/>
                        
                        <!--These are the characters to check. If we are in the first term, 
                            then we check all the characters that follow the current TLN
                            and $termLength number of characters before. This is necessary 
                            as editors will sometimes make a lemma that spans across two lines
                            without denoting where the linebreak is-->
                        <xsl:variable name="charsToProcess" select="if ($thisPos=1) then ($thisTln/preceding::c[position() lt $termLength],$followingChars) else $followingChars" as="element(c)+"/>
                        
                        <!--Checking variable-->
                        <xsl:variable name="idToReturn" as="xs:string*">
                            <!--For each character to check that equals the first letter
                                of $termToCheck-->
                            <xsl:for-each select="$charsToProcess[starts-with($termToCheck,@n)]">
                                
                                <!--This character (for context)-->
                                <xsl:variable name="thisChar" select="."/>
                                
                                <!--Create a sequence of characters that starts with thisCharacter 
                                    (which is the first character of the term we are checking, 
                                    following by $termLength-1  of the characters that follow it-->
                                
                                <xsl:variable name="charSeq" select="($thisChar, following::c[position() lt $termLength])"/>
                                
                                <!--Create a string for the character sequence. We're attempting to
                                    create a string that looks like the term to check-->
                                <xsl:variable name="concattedChars" select="string-join($charSeq,'')"/>
                                
                                <!--If there's a match, return the beginning and end point
                                ids from the character sequence.-->
                                <xsl:if test="$concattedChars = $termToCheck">
                                    <xsl:value-of select="concat($thisChar/@xml:id,'-from')"/>
                                    <xsl:value-of select="concat($charSeq[last()]/@xml:id,'-to')"/>
                                </xsl:if>             
                            </xsl:for-each>
                        </xsl:variable>
                        
                        <!--How many ids did the above variable return?-->
                        <xsl:variable name="idCount" select="count($idToReturn)"/>
                        
                        <!--If the variable returned more than 1, then some end/start points have
                            been found-->
                        <xsl:if test="$idCount gt 1">
                            
                            <!--But if there's more than 2, that means there were multiple matches. 
                                This happens often with common, short words (eg: matching "he" to 
                                the line "He said they hurt Helen's heart" would have 4 sets of 
                                end points (and thus $idCount = 8). If that's the case, then 
                                warn about it-->
                            <xsl:if test="$idCount gt 2">
                                <xsl:message>Found <xsl:value-of select="$idCount"/> matches for "<xsl:value-of select="$termToCheck"/>" (TLN <xsl:value-of select="$tlnToCheck"/>). Returning the first match.</xsl:message>
                            </xsl:if>
                            
                            <!--Regardless of how many ids are returned by $idCount, return
                                the first set-->
                            
                            <xsl:value-of select="$idToReturn[1]"/>
                            <xsl:value-of select="$idToReturn[2]"/>
                        </xsl:if>
                    </xsl:when>
                </xsl:choose>           
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:choose>
          <!--Each term should have two points: an end and a beginning-->
            <xsl:when test="count($points) = $termCount * 2">
                <!--The first one is the outermost left limit-->
                <xsl:attribute name="from" select="concat('doc:',$sourceDocId,'#',$points[1])"/>
                
                <!--The second one is the outermost right limit-->
                <xsl:attribute name="to" select="concat('doc:',$sourceDocId,'#',$points[last()])"/>
            </xsl:when>
            <xsl:otherwise>
                <!--Otherwise, throw an error-->
                <xsl:message>Unable to find "<xsl:value-of select="$lemmaText"/>" (TLN <xsl:value-of select="concat(substring-after($from,'tln:'),'-',substring-after($to,'tln:'))"/>)</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    
    <!--Identity transform-->
    
    <xsl:template match="@*|node()" priority="-1" mode="#all">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>