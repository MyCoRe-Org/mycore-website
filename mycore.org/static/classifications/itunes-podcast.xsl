<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                exclude-result-prefixes="xs fn">

  <xsl:output method="xml"
              version="1.0"
              encoding="UTF-8"
              indent="yes"/>

  <xsl:strip-space elements="*"/>

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:template name="init">

    <mycoreclass xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                 xsi:noNamespaceSchemaLocation="MCRClassification.xsd" ID="itunes-podcast">
      <label xml:lang="en" text="Apple Podcasts categories"/>
      <label xml:lang="x-uri" text="http://www.mycore.org/classifications/itunes-podcast"/>
      <url xlink:href="https://help.apple.com/itc/podcasts_connect/#/itc9267a2f12" xlink:type="locator"/>
      <categories>
        <!-- https://raw.githubusercontent.com/mr-rigden/Podcast-Categories-List/d2a1e6a281f8c813601a7766e014fe8d107b540e/podcast_categories_list.json -->
        <xsl:apply-templates select="fn:json-to-xml(fn:unparsed-text('itunes-podcast.json'))"/>
      </categories>

    </mycoreclass>
  </xsl:template>

  <xsl:template match="fn:array">
    <xsl:apply-templates/>
  </xsl:template>
  <xsl:template match="fn:map">
    <category>
      <xsl:attribute name="ID">
        <xsl:apply-templates select="fn:string[@key='category']/text()" mode="id"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </category>
  </xsl:template>

  <xsl:template match="fn:string[@key]">
    <label xml:lang="en" text="{.}"/>
  </xsl:template>

  <xsl:template match="fn:string[not(@key)]">
    <category>
      <xsl:attribute name="ID">
        <xsl:apply-templates select="text()" mode="id"/>
      </xsl:attribute>
      <label xml:lang="en" text="{.}"/>
    </category>
  </xsl:template>
  
  <xsl:template match="text()" mode="id">
    <xsl:value-of select="replace(replace(replace(.,' ','_'),'&amp;',''),'__','_')" />
  </xsl:template>

</xsl:stylesheet>
