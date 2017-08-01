<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:math="http://www.w3.org/2005/xpath-functions/math"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  version="2.0"
  exclude-result-prefixes="#all"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:hcmc="http://hcmc.uvic.ca/ns"
  xmlns:svg="http://www.w3.org/2000/svg"
  xmlns:saxon="http://saxon.sf.net/">
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> August 1, 2017</xd:p>
      <xd:p><xd:b>Author:</xd:b> jtakeda</xd:p>
      <xd:p>This creates a webpage for a TEI encoded ISE play. Note that this is just for PROOFING PURPOSES
      and is not the final look and feel of the ISE plays.</xd:p>
    </xd:desc>
  </xd:doc>
  
  <xsl:include href="globals.xsl"/>
    <xsl:variable name="thisId" select="//TEI/@xml:id"/>
    
  <xsl:output method="xhtml" encoding="UTF-8" omit-xml-declaration="yes" exclude-result-prefixes="#all"/>
  
  
    <xsl:key name="anchor-to-notes" match="note" use="substring-after(span/@to,'#')"/>
    <xsl:key name="anchor-to-coll" match="app" use="substring-after(@to,'#')"/>
    <xsl:key name="tln-to-notes" match="note" use="substring-after(span/@to,'tln:')"/>
    <xsl:key name="tln-to-colls" match="app" use="substring-after(@to,'tln:')"/>
  <xsl:variable name="docsToBuild" select="$standaloneDocs[//catRef[starts-with(@target,'idt:idtPrimary')]]"/>
   <xsl:variable name="taxonomies" select="$standaloneDocs[//TEI/@xml:id='taxonomies']"/>
    
 <xsl:template match="/">
     <xsl:for-each select="$docsToBuild">
     
         <xsl:variable name="thisId" select="TEI/@xml:id"/>
         <xsl:message>Processing <xsl:value-of select="$thisId"/></xsl:message>
         <xsl:variable name="apps" select="$standaloneDocs[//relatedItem[ends-with(@target,$thisId)]]"/>
         <xsl:variable name="notes">
             <xsl:for-each select="$apps//div[@type='annotations']/note">
                 <xsl:copy>
                     <xsl:attribute name="xml:id" select="generate-id()"/>
                     <xsl:copy-of select="@*|node()"/>
                 </xsl:copy>
             </xsl:for-each>
         </xsl:variable>
         <xsl:variable name="colls">
             <xsl:for-each select="$apps//app">
                 <xsl:copy>
                     <xsl:attribute name="xml:id" select="generate-id()"/>
                     <xsl:copy-of select="@*|node()"/>
                 </xsl:copy>
             </xsl:for-each>
         </xsl:variable>
         
         <xsl:result-document href="{$basedir}/site/{$thisId}.html">
             <xsl:apply-templates>
                 <xsl:with-param name="thisId" tunnel="yes" select="$thisId"/>
                 <xsl:with-param name="notes" tunnel="yes" select="$notes"/>
                 <xsl:with-param name="colls" tunnel="yes" select="$colls"/>
             </xsl:apply-templates>
         </xsl:result-document>
     </xsl:for-each>
 </xsl:template>   

    
  <xsl:template match="TEI">
      <xsl:param name="notes" tunnel="yes"/>
      <xsl:param name="colls" tunnel="yes"/>
    <xsl:variable name="docRoot" select="."/>
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html>
    </xsl:text>
    <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
      <head>
        <meta charset="UTF-8"/>
        <title><xsl:value-of select="TEI/teiHeader/fileDesc/titleStmt/title"/> (PROOFING)</title>
        <style type="text/css">
          
          html, body{
            margin: 0;
            padding: 0;
            font-family: georgia, serif;
          }
          
          div.appendix{
            display:none;
          }
          
          div.meta{
            float: left;
            width: 20em;
            padding: 1em;
            background-color: #d0d0ff;
            margin: 0;
            position: fixed;
          }
          
          table.stats, table.stats td{
            border: solid 1pt black;
            border-collapse: collapse;
          }
          
          table.stats td{
            padding: 0.2em;
            text-align: right;
          }
          
          table.stats thead td{
            font-weight: bold;
            text-align: center;
          }
          
          div.play{
            margin: 0 0 0 22em;
            padding: 1em;
            border: solid 1px black;
          }

          /* Elements in text. */
          
          div.front, div.body, div.back, div.div, div.sp, div.l, div.stage{
            display: block;
          }
          
          div.front, div.body, div.back {
          margin-right:4em;
          }
          
          span.tln{
            display: none;
            font-size: 80%;
            margin-left: -3em;
            float: left;
          }
          
        
          
          div.p {
          display:block;
          max-width:75%;
          }
          
          div.p span.tln.showing{
            display: inline;
            color: grey;
            margin: 0;
            float: none;
          }
          
          
          div.p span.tln.showing::before{
          content: ' [';
          color: grey;
          
          }
          div.p span.tln.showing::after{
          content: '] ';
          color: grey;
          
          }
          div#refPopup{
             border: 1px solid rgb(102, 102, 102);
             box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.4);
             display: none;
             margin-right: 0;
             max-height: 50%;
            overflow: auto;
             padding: 1.25em;
             position: fixed;
            right: 2%;
            top: 41.2%;
            width: 22%;
             background-color: #ffffff;
            word-wrap: break-word;
             opacity: .95
          }
          div.popupCloser{
          
          font-size: 1.375em;
          line-height: 1;
          position: fixed;
          right: 3%;
          top: 47%;
          padding-bottom: .3em;
          position: absolute;
          top: 0.5em;
          right: 0.6875em;
          font-weight: bold;
          cursor: pointer;
          padding: .25em .5em;
          }
          
          span.tln.showing{
          display: block;
          }
<!--          div.speaker{
            font-style: italic;
            padding: 0 2em;
          }
          
          /*The first l in a speech will follow the 
          speaker element, so it shouldn't be 
          block. */
          div.speaker{
            display: inline;
            padding-bottom:.5em;
          }
          
          
          div.l{
          margin:-.2em;
          }-->
          
          div.act, div.prologue, div.epilogue, div.scene{
            border-top: solid 1pt gray;
            border-bottom: solid 1pt gray;
            border-collapse: collapse;
            margin: 0;
            padding: 1em;
          }
          
          div.act, div.prologue, div.epilogue{
            padding-left: 4em;
          }
          
          div.scene:first-of-type, div.scene:last-of-type{
            border-width: 0;
          }
          
          div.docTitle{
            text-align: center;
            font-size: 300%;
          }
          
          h2, h3, h4, h5, h6{
            text-align: center;
          }
          
          div.sp{
          margin:.75em 0;
          }
          
          div.speaker{
          margin-bottom:.35em;
          font-weight:bold;
          }
          
          span.anchor {
            vertical-align:super;
            font-size:smaller;
            text-decoration:underline;
            color: blue;
            cursor: pointer;
          }
          
          span.anchor.error {
          color: red;
          cursor: pointer;
          }
          
          div.stage{
            font-style: italic;
            margin: 1em 0;
          }
          
          div.l{
            padding-left:20px;
            line-height:26px;
          }
          
          div.l > span.tln {
            padding-left:-20px;
          }
         
          /* Breaks. */
          
          cb[n="2"], pb{
          display: block;
          border-bottom: solid 1px black;
          }
          
          cb[n="2"]{
          width: 50%;
          margin-left: 25%;
          }
          
          /* Inline textual features. */
          span.gOld{
            display: none;
            background-color: #ffff00;
          }
          span.ligature{
            letter-spacing: -0.1em;
          }
          span.gModern{
          }
          
          *[class~="simple:allcaps"]{
            text-transform: capitalize;
          }
          
          *[class~="simple:blackletter"]{
            font-weight: bold;
            font-family: monospace;
          }
          
          *[class~="simple:bold"]{
            font-weight: bold;
          }
          
          *[class~="simple:bottombraced"]{
            text-decoration: underline;
          }
          
          *[class~="simple:boxed"]{
            border: solid 1pt black;
            padding: 0.2em;
          }
          
          *[class~="simple:centre"]{
            display: block;
            text-align: center;
          }
          
          *[class~="simple:cursive"]{
            font-family: cursive;
          }
          
          *[class~="simple:display"]{
            display: block;
          }
          
          *[class~="simple:doublestrikethrough"]{
            text-decoration: line-through;
          }
          
          *[class~="simple:doubleunderline"]{
            text-decoration: underline;
            border-bottom: double 1pt black;
          }
          
          *[class~="simple:dropcap"]{
            display: inline-block;
            float: left;
            font-size: 200%;
            vertical-align: top;
            padding: 0.25em;
            margin-right: 0.1em;
            border: solid 1pt black;
          }
          
          *[class~="simple:float"]{
            display: block;
            float: left;
          }
          
          *[class~="simple:hyphen"]{
            content: "-";
          }
          
          *[class~="simple:italic"]{
            font-style: italic;
          }
          
          *[class~="simple:larger"]{
            font-size: 120%;
          }
          
          *[class~="simple:leftbraced"]{
            border-left: solid 1pt black;
          }
          
          *[class~="simple:letterspace"]{
          letter-spacing: 1ex;
          }
          
          *[class~="simple:normalstyle"]{
            font-style: normal;
            font-weight: normal;
          }
          
          *[class~="simple:normalweight"]{
            font-weight: normal;
          }
          
          *[class~="simple:right"]{
            text-align: right;
          }
          
          *[class~="simple:rotateleft"]{
            background-color: #ffff00;
          }
          
          *[class~="simple:rotateright"]{
            background-color: #00ffff;
          }
          
          *[class~="simple:smallcaps"]{
            font-variant: small-caps;
          }
          
          [rendition~="simple:smaller"]{
            font-size: 80%;
          }
          
          *[class~="simple:strikethrough"]{
            text-decoration: line-through;
          }
          
          *[class~="simple:subscript"]{
            font-size: 70%;
            vertical-align: sub;
          }
          
          *[class~="simple:superscript"]{
            font-size: 70%;
            vertical-align: super;
          }
          
          *[class~="simple:topbraced"]{
            border-top: solid 1pt black;
          }
          
          *[class~="simple:typewriter"]{
            font-family: monospace;
          }
          
          *[class~="simple:underline"]{
            text-decoration: underline;
          }
          
          *[class~="simple:wavyunderline"]{
            text-decoration: underline;
          }
        </style>
        
        <script type="text/javascript">
<xsl:text disable-output-escaping="yes">
          function showHideGlyphs(sender){
            var olds = document.getElementsByClassName('gOld');
            var moderns = document.getElementsByClassName('gModern');
            var oldStyle = sender.checked? 'inline':'none';
            var modernStyle = sender.checked? 'none':'inline';
            for (var i=0; i&lt;olds.length; i++){
              olds[i].style.display = oldStyle;
            }
            for (var i=0; i&lt;moderns.length; i++){
              moderns[i].style.display = modernStyle;
            }
          }

          
            function showRef(ref, status){
            var infoDiv=document.getElementById('refPopup');
                 if (infoDiv){
                    infoDiv.remove();
                 }
            var headerElem = document.createElement('h2');
            if (status == 'error'){
                headerElem.innerHtml='UNMATCHED LEMMA';
             }
            var refId = ref.id;
            var thisRef = document.getElementById(refId);
            var tempElem = document.createElement('p');
            tempElem.setAttribute('class','popupContent');
            tempElem.innerHTML= thisRef.innerHTML;
            var header = document.createElement('h2');
            var popup = document.createElement('div');
            popup.setAttribute ('id', 'refPopup');
            popup.setAttribute('style','display:none;');
            popup.appendChild(headerElem);
            popup.appendChild(tempElem);
            var popupCloser = document.createElement('div');
            popupCloser.setAttribute('class','popupCloser');
            popupCloser.setAttribute('onclick','this.parentNode.remove()');
            popupCloser.innerHTML='x';
            popup.appendChild(popupCloser);
            document.body.appendChild(popup);
            popup.removeAttribute('style');
            popup.setAttribute('style','display:block;');
            }
          
</xsl:text>
        </script>
      </head>
      <body>
        <div class="meta">
          
          <form>
            <p style="text-indent: -2em; margin-left: 2em;"><input type="checkbox" onclick="showHideGlyphs(this)"/> Show ligatures and other special glyphs</p>
          </form>
          <h3>Stats</h3>
          <table class="stats">
            <tr>
              <td>Major divisions encoded:</td>
              <td><xsl:value-of select="count(//div[@type=('act', 'epilogue', 'prologue')])"/></td>
            </tr>
            <tr>
              <td>Scenes encoded:</td>
              <td><xsl:value-of select="count(//div[@type=('scene')])"/></td>
            </tr>
            <tr>
              <td>Speeches encoded:</td>
              <td><xsl:value-of select="count(//sp)"/></td>
            </tr>
            <tr>
              <td>Lines encoded:</td>
              <td><xsl:value-of select="count(//l)"/></td>
            </tr>
            <tr>
              <td>Special chars encoded:</td>
              <td><xsl:value-of select="count(//g)"/></td>
            </tr>
          </table>
          
          <xsl:if test="//sp[@who]">
            <h3>Speakers, speeches and lines</h3>
            <table class="stats">
              <thead>
                <tr>
                  <td>Speaker (id)</td>
                  <td>Speeches</td>
                  <td>Lines</td>
                </tr>
              </thead>
              <tbody>
                <xsl:for-each select="//particDesc/listPerson/person">
                  <xsl:variable name="thisCastItem" select="."/>
                  <xsl:variable name="whoVal" select="$thisCastItem/@xml:id"/>
                  <xsl:if test="$docRoot//sp[@who=concat('#',$whoVal)]">
                    <tr>
                      <td><xsl:value-of select="$thisCastItem/@xml:id"/></td>
                      <td><xsl:value-of select="count($docRoot//sp[@who=$whoVal])"/></td>
                      <td><xsl:value-of select="count($docRoot//l[ancestor::sp[@who=$whoVal]])"/></td>
                    </tr>
                  </xsl:if>
                </xsl:for-each>
              </tbody>
            </table>
          </xsl:if>
        </div>
        
        <div class="play">
          <xsl:apply-templates select="text"/>
        </div>
        <div class="appendix">
           <xsl:apply-templates select="$notes" mode="app"/>
            <xsl:apply-templates select="$colls" mode="app"/>
        </div>
      </body>
    </html>
  </xsl:template>
    
 <xsl:template match="note[@xml:id] | app[@xml:id]" mode="app">
     <div class="{local-name()}" id="{@xml:id}">
         <xsl:apply-templates mode="#current"/>
     </div>
 </xsl:template>
   
   <xsl:template match="note[@xml:id]/*[not(self::span)] | app/*" mode="app">
       <div class="{local-name()}"><em><xsl:value-of select="local-name()"/></em> <xsl:if test="@resp or @source">(<xsl:apply-templates select="@resp,@source" mode="#current"/>)</xsl:if>: <xsl:apply-templates mode="#current"/></div>
   </xsl:template>
   
   <xsl:template match="@resp|@source">
       <xsl:value-of select="local-name()"/>: <xsl:value-of select="."/><xsl:text> </xsl:text>
   </xsl:template>
    
  
  <xsl:template match="front | body | back | docTitle | div | sp | l | stage">
    <div>
      <xsl:copy-of select="hcmc:processAtts(.)"/>
      <xsl:apply-templates select="@* | node()"/>
    </div>
  </xsl:template>
  
  <xsl:template match="p">
    <div>
      <xsl:copy-of select="hcmc:processAtts(.)"/>
      <xsl:apply-templates select="@*|node()"/>
    </div>
  </xsl:template>
  
  <xsl:template match="head">
    <xsl:element name="h{count(ancestor::div) + 1}">
      <xsl:copy-of select="hcmc:processAtts(.)"/>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="speaker">
    <div class="speaker">
      <xsl:copy-of select="hcmc:processAtts(.)"/>
      <xsl:apply-templates select="@* | node()"/>
    </div>
  </xsl:template>
  
  <xsl:template match="hi">
    <span>
      <xsl:copy-of select="hcmc:processAtts(.)"/>
      <xsl:apply-templates select="@* | node()"/>
    </span>
  </xsl:template>
  
  <xsl:template match="lb[not(@type)]">
    <span class="lb"><xsl:copy-of select="hcmc:processAtts(.)"/></span>
  </xsl:template>
  
  <xsl:template match="lb[@type='tln' or @subtype='tln']">
    <xsl:param name="notes" tunnel="yes"/>
    <xsl:param name="colls" tunnel="yes"/>
    <xsl:variable name="thisN" select="@n"/>
    <span class="tln showing"><xsl:value-of select="@n"/></span>
    <xsl:variable name="errorNotes" select="$notes//key('tln-to-notes',$thisN)"/>
    <xsl:variable name="errorColls" select="$colls//key('tln-to-colls',$thisN)"/>
      <xsl:variable name="errorCount" select="count($errorNotes) + count($errorColls)"/>
    <xsl:if test="$errorCount gt 0">
        <xsl:message>TLN <xsl:value-of select="$thisN"/> has <xsl:value-of select="$errorCount"/> error<xsl:if test="$errorCount gt 1">s</xsl:if>.</xsl:message>
        <xsl:for-each select="($errorNotes,$errorColls)">
            <span class="anchor error"><a onclick="javascript:showRef({@xml:id},'error')">X</a></span>
        </xsl:for-each>
        
    </xsl:if>
    
  </xsl:template>
  
  <xsl:template match="g[@ref]">
    <xsl:variable name="gId" select="substring-after(@ref, 'g:')"/>
    <xsl:variable name="glyph" select="$taxonomies//glyph[@xml:id=$gId]"/>
    <span class="g">
      <xsl:if test="$glyph">
        <xsl:attribute name="title">
          <xsl:value-of select="$glyph/glyphName"/>
          <xsl:if test="$glyph/mapping"> (<xsl:value-of select="$glyph/mapping[1]"/>)</xsl:if>
        </xsl:attribute>
        <xsl:if test="$glyph/mapping"><span class="gOld{if (contains($gId, 'igature')) then ' ligature' else ''}"><xsl:value-of select="$glyph/mapping[1]"/></span></xsl:if>
      </xsl:if>
      <span class="gModern"><xsl:apply-templates select="@* | node()"/></span>
    </span>
  </xsl:template>
    
    <!--Now anchors...-->
    
    <xsl:template match="anchor[ends-with(@xml:id,'-to')]">
        <xsl:param name="notes" tunnel="yes"/>
        <xsl:param name="colls" tunnel="yes"/>
        <xsl:variable name="thisId" select="@xml:id"/>
        <xsl:variable name="theseNotes" select="$notes//key('anchor-to-notes',$thisId)"/>
        <xsl:variable name="theseColls" select="$colls//key('anchor-to-coll',$thisId)"/>
        <xsl:for-each select="$theseNotes">
            <xsl:variable name="thisNote" select="."/>
            <xsl:variable name="thisNoteId" select="$thisNote/@xml:id"/>
            <xsl:variable name="thisNoteNum" select="position()"/>
            <span class="anchor"><a onclick="javascript:showRef({$thisNoteId}, 'found')">○</a></span>
        </xsl:for-each>
        
        <xsl:for-each select="$theseColls">
            <xsl:variable name="thisColl" select="."/>
            <xsl:variable name="thisCollId" select="$thisColl/@xml:id"/>
            <xsl:variable name="thisCollNum" select="position()"/>
            <span class="anchor"><a onclick="javascript:showRef({$thisCollId}, 'found')">†</a></span>
        </xsl:for-each>
        
    </xsl:template>
  
  <xsl:template match="@who">
    <xsl:attribute name="title" select="//particDesc/descendant::person[@xml:id = substring-after(., '#')]/reg"/>
  </xsl:template>
  
<!-- Atts handled by function. -->
  <xsl:template match="@rendition | @style | @type"/>
  
  <xsl:function name="hcmc:processAtts" as="attribute()*">
    <xsl:param name="el"/>
    <xsl:attribute name="class"><xsl:value-of select="string-join(($el/local-name(), $el/@type, $el/@rendition), ' ')"/></xsl:attribute>
    <xsl:if test="$el/@style"><xsl:attribute name="style" select="$el/@style"/></xsl:if>
    <!--<xsl:if test="$el/self::l"><xsl:attribute name="title" select="concat('Line number ', xs:string(count($el/preceding::l) + 1))"/></xsl:if>-->
  </xsl:function>
  
  <xsl:template match="@*" priority="-1"/>
  
</xsl:stylesheet>