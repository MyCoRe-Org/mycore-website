<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
>

<xsl:output method="xml" encoding="UTF-8"/>

<xsl:variable name="newline">
<xsl:text>
</xsl:text>
</xsl:variable>

  <xsl:variable name="newID">
    <xsl:value-of select="substring-before(/mycorederivate/@ID,'_derivate_')"/>
    <xsl:value-of select="'_derivate_'"/>
    <xsl:value-of select="substring-after(/mycorederivate/@ID,'_derivate_')"/>
  </xsl:variable>

<xsl:attribute-set name="tag">
  <xsl:attribute name="class">
    <xsl:value-of select="./@class" />
  </xsl:attribute>
  <xsl:attribute name="heritable">
    <xsl:value-of select="./@heritable" />
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="subtag">
  <xsl:attribute name="sourcepath">
    <xsl:value-of select="$newID"/>
   </xsl:attribute>
   <xsl:attribute name="maindoc">
     <xsl:value-of select="@maindoc"/>
   </xsl:attribute>
   <xsl:attribute name="ifsid">
     <xsl:value-of select="@ifsid"/>
   </xsl:attribute>
</xsl:attribute-set>

<xsl:template match="/">
  <mycorederivate>
    <xsl:copy-of select="mycorederivate/@label"/>
    <xsl:copy-of select="mycoreobject/@version"/>
    <xsl:copy-of select="mycorederivate/@xsi:noNamespaceSchemaLocation"/>
    <xsl:attribute name="ID">
      <xsl:value-of select="$newID"/>
    </xsl:attribute>
    <derivate>
      <xsl:if test="mycorederivate/derivate/linkmetas">
        <linkmetas class="MCRMetaLinkID" heritable="false">
          <linkmeta inherited="0" xlink:type="locator" >
            <xsl:attribute name="xlink:href">
              <xsl:value-of select="substring-before(mycoreobject/@ID,'_document_')"/>
              <xsl:value-of select="'_mods_'"/>
              <xsl:value-of select="substring-after(mycorederivate/derivate/linkmetas/linkmeta/@xlink:href,'_document_')"/>
            </xsl:attribute>
          </linkmeta>
        </linkmetas>
    </xsl:if>
      <xsl:if test="mycorederivate/derivate/titles">
        <xsl:copy-of select="mycorederivate/derivate/titles"/>
    </xsl:if>
      <xsl:if test="mycorederivate/derivate/externals">
        <xsl:copy-of select="mycorederivate/derivate/externals"/>
    </xsl:if>
      <xsl:for-each select="mycorederivate/derivate/internals">
        <xsl:copy use-attribute-sets="tag">
          <xsl:for-each select="internal">
            <xsl:copy use-attribute-sets="subtag" />
          </xsl:for-each>
        </xsl:copy>
      </xsl:for-each>
    </derivate>
    <service>
      <xsl:apply-templates select="mycoreobject/service/servdates" />
      <xsl:copy-of select="mycoreobject/service/servflags" />
      <xsl:copy-of select="mycoreobject/service/servstate" />

      <!-- include acl if available -->
      <!-- xsl:variable name="acl" select="document(concat('access:action=all&amp;object=',mycoreobject/@ID))"/>
        <xsl:if test="$acl/*/*">
            <xsl:copy-of select="$acl"/>
        </xsl:if -->
    </service>
  </mycorederivate>
</xsl:template>

  <xsl:template match="servdates">
    <servdates class="MCRMetaISO8601Date">
      <servdate type="createdate" inherited="0">
        <xsl:choose>
          <xsl:when test="not(contains(servdate[@type='createdate'], 'T'))">
            <xsl:value-of select="concat(servdate[@type='createdate'],'T00:00:00.000Z')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="servdate[@type='createdate']"/>
          </xsl:otherwise>
        </xsl:choose>
      </servdate>
      <servdate type="modifydate" inherited="0">
        <xsl:choose>
          <xsl:when test="not(contains(servdate[@type='modifydate'], 'T'))">
            <xsl:value-of select="concat(servdate[@type='modifydate'],'T00:00:00.000Z')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="servdate[@type='modifydate']" />
          </xsl:otherwise>
        </xsl:choose>
      </servdate>
    </servdates>
  </xsl:template>

</xsl:stylesheet>