---
title: "HowTo: Ein multifunktionaler Download-Button"  
slug: howto-donwload-button
date: 2021-03-27

draft: true

blog/authors: ["Robert Stephan"]
blog/periods: 2021-03
blog/categories: 
- HowTos

---

In diesem Tutorial möchte ich anhand eines *Download-Buttons* einige Features demonstrieren, die in diesem oder den letzten
Jahren in MyCoRe integriert wurden. Dazu zählen die Anreicherung weiterer Informationen aus den Derivaten im ```<structure>```-Header des MyCoRe-Objektes, Data-URLs und verschiedene XSLT-Funktionen.
<!--more-->

Schauen wir uns zunächst das *Endergebnis* und den dazugehörigen HTML-Quellcode an an:

{{< mcr-figure src="/images/blog/howtos/download_button.png" 
         class="text-center" 
         label="Abbildung" caption="der fertige Download-Button" />}}

Der Buttonn zeigt ein Dateityp-abhängiges Symbol, den Derivate-Typ als Label, die Dateigröße und den Dateinamen. Weiterhin besteht die Möglichkeit eine
Datei mit der MD5-Summe dieser Datei herunterzuladen.

{{< mcr-figure label="Quellcode" caption="HTML-Code für den Download-Button" >}}
{{< highlight html "linenos=table" >}}
<div class="w-100 position-relative" style="padding-right:3em">
  <a class="badge border border-primary text-secondary position-absolute px-1 py-1" 
      style="right:0;bottom:0;height:3.0em" download="Mustermann_Dissertation_2020.pdf.md5"
      href="data:text/plain;charset=US-ASCII,77cfc859cb00158cf1d12e657b882eae%20%20Mustermann_Dissertation_2020.pdf">
      <i class="fas fa-download pb-1"></i><br>MD5
  </a>
  <a class="btn btn-primary ir-button-download d-inline-block"target="_blank" 
     href="http://localhost:8880/rosdok/file/rosdok_disshab_00001234/rosdok_derivate_00005678/Mustermann_Dissertation_2020.pdf">
     <img src="http://localhost:8880/rosdok/images/download_pdf.png" title="PDF Download" align="left" />
     <span class="float-right"><small>(20.2 MB)</small></span>
     <strong>Volltext</strong><br />
     <small>Mustermann_Dissertation_2020.pdf</small>
  </a>
</div>
{{< /highlight >}}
{{< /mcr-figure>}}

## Erweiterung des Derivate-Headers (MCRMetaEnrichedLinkID)

Über die URL <tt>/receive/{mcr-object-id}?XSL.Style=xml</tt> bekommen wir einen Einblick in das interne XML
eines MyCoRe-Objektes. Zur Generierung von Detail-ansichten (Frontpages) werden im Kopf des Objektes
seit Version ??? weitere Informationen zu den Derivaten (Name der Hauptdatei und Derivate-Typ-Klassifikation)
angezeigt.

{{< highlight xml "linenos=table" >}}
<mycoreobject ID="rosdok_disshab_00001234" version="2020.06">
  <structure>
    <derobjects class="MCRMetaEnrichedLinkID">
      <derobject inherited="0" xlink:type="locator" xlink:href="rosdok_derivate_0005678">
        <order>1</order>
        <maindoc>Mustermann_Dissertation_2020.pdf</maindoc>
        <classification classid="derivate_types" categid="fulltext"/>
      </derobject>
    </derobjects>
  </structure>
  ...
{{< / highlight >}}

Wir wollen diese Informationen ausbauen und zusätzlich auch noch die *Dateigröße* und die *MD5-Summe* der Hauptdatei integrieren.

Dazu muss die abstrakte Klasse [org.mycore.datamodel.metadata.MCRMetaEnrichedLinkIDFactory](https://github.com/MyCoRe-Org/mycore/blob/2020.06.x/mycore-base/src/main/java/org/mycore/datamodel/metadata/MCREditableMetaEnrichedLinkID.java) implementiert bzw. erweitert und als Property registriert werden.

{{< mcr-figure label="Konfiguration" caption="mycore.properties" >}}
{{< highlight html "linenos=table" >}}
MCR.Metadata.EnrichedDerivateLinkIDFactory.Class=org.mycore.jspdocportal.common.controller.datamodel.metadata.MCRExtendedDerivateLinkIDFactory
{{< /highlight >}}
{{< /mcr-figure>}}

Mit ein wenig Aufwand könnte die XML-Struktur innerhalb von ``<derobject>`` angepasst werden.
Für unsere Zwecke nutzen wir aber das bereits vorhandene &lt;title&gt; Element nach.
Das Element hat den Datentyp [MCRMetaLangText](https://www.mycore.de/documentation/basics/mcrobject/mcrobj_datatypes#freier-text-mcrmetalangtext)
Ursprünglich ist es dazu gedacht, den optional vorhandenen Titel des Derivates anzuzeigen. 
Mit individuellen ``type`` Attributen sind unsere neuen Metadaten eindeutig referenzierbar.

{{< mcr-figure label="Quellcode" caption="MCRExtendedDerivateLinkIDFactory.java" >}}
{{< highlight java "linenos=table" >}}
public class MCRExtendedDerivateLinkIDFactory extends MCRDefaultEnrichedDerivateLinkIDFactory {
  private static final Logger LOGGER = LogManager.getLogger();
  
  @Override
  public MCREditableMetaEnrichedLinkID getDerivateLink(MCRDerivate der) {
    MCREditableMetaEnrichedLinkID derivateLinkID = super.getDerivateLink(der);
    final String mainDoc = derivateLinkID.getMainDoc();
    if (!StringUtils.isEmpty(mainDoc)) {
      MCRPath mcrPath = MCRPath.getPath(der.getId().toString(), mainDoc);
      if (Files.exists(mcrPath)) {
        try {
          @SuppressWarnings("rawtypes")
          MCRFileAttributes attrs = Files.readAttributes(mcrPath, MCRFileAttributes.class);
          List<MCRMetaLangText> titles = derivateLinkID.getTitle();
          titles.add(new MCRMetaLangText("title", "zxx", "maindoc_size", 0, "", Long.toString(attrs.size())));
          titles.add(new MCRMetaLangText("title", "zxx", "maindoc_md5", 0, "", attrs.md5sum()));
          derivateLinkID.setTitles(titles);
        } catch (IOException e) {
          LOGGER.error(e);
        }
      } else {
        LOGGER.error("Error - maindoc '" + mainDoc + "' does not exist for " + der.getId().toString());
      }
    }
    return derivateLinkID;
  }
}
{{< /highlight >}}
{{< /mcr-figure>}}

Im Ergebnis haben wir nun Dateigröße und MD5-Summe im XML-Code des MyCoRe-Objektes:

{{< highlight xml "linenos=table" >}}
<mycoreobject ID="rosdok_disshab_00001234" version="2020.06">
  <structure>
    <derobjects class="MCRMetaEnrichedLinkID">
      <derobject inherited="0" xlink:type="locator" xlink:href="rosdok_derivate_0005678">
        <order>1</order>
        <maindoc>Mustermann_Dissertation_2020.pdf</maindoc>
        <title xml:lang="zxx" type="maindoc_size" inherited="0" form="plain">21175865</title>
        <title xml:lang="zxx" type="maindoc_md5" inherited="0" form="plain">77cfc859cb00158cf1d12e657b882eae</title>
        <classification classid="derivate_types" categid="fulltext"/>
      </derobject>
    </derobjects>
  </structure>
  ...
{{< / highlight >}}

## Erzeugen des HTML-Codes mit XSLT3
Zur Erzeugung der Detailsansicht (Frontpage) können wir ab Version {{< mcr-version 2020.06 >}} XSLT-3 verwenden.
Ein neues Feature sind XSLT-Funktionen. Die MyCoRe-Community stellt [XSLT-Funktionen](http://www.mycore.de/documentation/frontend/xsl/xsl_xslt3#mycore-xslt3-funktionen) für wichtige Features, wie
Übersetzungen (I18N) oder Klassifikationen bereit.

Um die Funktionen nutzen zu können muss im ``<stylesheet>>`` Element der Namespace deklariert werden
und die Funktionen via ```<xsl:import>```eingebunden werden.

{{< mcr-figure label="XSLT" caption="Einbinden von Funktionen" >}}
{{< highlight xml "linenos=table" >}}
<?xml version="1.0"?>
<xsl:stylesheet version="3.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrclass="http://www.mycore.de/xslt/classification">
  ...
  <xsl:import href="resource:xsl/functions/i18n.xsl" />
  <xsl:import href="resource:xsl/functions/classification.xsl" />
  ...
{{< /highlight >}}
{{< /mcr-figure>}}

Anschließend können die Funktionen beim Erzeugen des HTML-Codes genutzt werden, z.B:

{{< highlight xml "linenos=table" >}}
<img align="left" src="{$WebApplicationBaseURL}images/download_zip.png" title="{mcri18n:translate('Webpage.docdetails.zipdownload')}" />
<strong>{mcrclass:current-label-text(./classification[@classid='derivate_types'])}</strong>
{{< /highlight >}}

An dieser Stelle noch einmal das vollständige XSLT-Skript:

{{< mcr-figure label="Quellcode" caption="docdetails.xsl" >}}
{{< highlight xml "linenos=table" >}}
<?xml version="1.0"?>
<xsl:stylesheet version="3.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:mods="http://www.loc.gov/mods/v3" 
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrclass="http://www.mycore.de/xslt/classification"
  xmlns:mcrstring="http://www.mycore.de/xslt/stringutils"
  exclude-result-prefixes="mods xlink"
  expand-text="yes">

  <xsl:param name="WebApplicationBaseURL" select="'http://rosdok.uni-rostock.de/'"/>
  <xsl:param name="WebApplicationTitle" select="'RosDok'"/>
  <xsl:param name="CurrentLang" />
  <xsl:param name="DefaultLang" />
  
  <xsl:output method="html" indent="yes" standalone="no" />
  
  <xsl:import href="resource:xsl/functions/i18n.xsl" />
  <xsl:import href="resource:xsl/functions/classification.xsl" />
  <xsl:import href="resource:xsl/functions/stringutils.xsl" />
  
  <xsl:template match="/">
    <!--  Download Area -->
    <div style="margin-bottom:30px;">
      <xsl:for-each select="/mycoreobject/structure/derobjects/derobject[classification[@classid='derivate_types'][@categid='fulltext']]">
        <xsl:call-template name="download-button" />
      </xsl:for-each>
    </div>
  </xsl:template>
  
  <xsl:template name="download-button">
    <xsl:variable name="mcrid" select="/mycoreobject/@ID" />
    <xsl:variable name="derid" select="./@xlink:href" />
    <xsl:variable name="fulltext_url">{$WebApplicationBaseURL}file/{$mcrid}/{$derid}/{./maindoc/text()}</xsl:variable>
     <div class="w-100 position-relative" style="padding-right:3em">
      <a class="badge border border-primary text-secondary position-absolute px-1 py-1" 
         style="right:0;bottom:0;height:3.0em"  download="{./maindoc}.md5" 
         href="data:text/plain;charset=US-ASCII,{encode-for-uri(concat(./title[@type='maindoc_md5'],'  ', ./maindoc))}">
         <i class="fas fa-download pb-1"></i><br />MD5
      </a>
      <a class="btn btn-primary ir-button-download d-inline-block"
         href="{$fulltext_url}" target="_blank">
         <xsl:choose>
           <xsl:when test="ends-with(./maindoc, '.zip')">
             <img align="left" src="{$WebApplicationBaseURL}images/download_zip.png" title="{mcri18n:translate('Webpage.docdetails.zipdownload')}" />
           </xsl:when>
           <xsl:when test="ends-with(./maindoc, '.pdf')">
             <img align="left" src="{$WebApplicationBaseURL}images/download_pdf.png" title="{mcri18n:translate('Webpage.docdetails.pdfdownload')}" />
           </xsl:when>
           <xsl:otherwise>
             <img align="left" src="{$WebApplicationBaseURL}images/download_other.png" title="{mcri18n:translate('Webpage.docdetails.otherdownload')}" />
           </xsl:otherwise>
         </xsl:choose>
         <span class="float-right"><small>({mcrstring:pretty-filesize(./title[@type='maindoc_size'])})</small></span>
         <strong>{mcrclass:current-label-text(./classification[@classid='derivate_types'])}</strong>
         <br /><small>{mcrstring:abbreviate-center(./maindoc, 40)}</small>
      </a>
    </div>
  </xsl:template>

</xsl:stylesheet>
{{< /highlight >}}
{{< /mcr-figure>}}

## Data-URLs
Zum Schluss möchte ich noch auf ein weiteres Feature hinweisen - *Data-URLs*.

Mit [Data-URLs](https://de.wikipedia.org/wiki/Data-URL) lassen sich Dateien (z.B. Bilder oder Downloads) simulieren.
Sie werden als <tt>ASCII</tt> oder <tt>Base64</tt> codiert und direkt in den HTML-Quellcode eingebettet.

Diese Möglichkeit erspart uns die Implementation eines zusätzlichen Servlets oder einer anderen serverseitigen Komponente, die die MD5-Checksummen-Datei erzeugt. Diese besteht in unserem Fall nur aus einer Zeile:
{{< highlight text "linenos=table" >}}
{MD5}  {Dateiname}
{{< /highlight >}}

Folgendes XSLT-Skript kann für die Generierung verwendet werden. Auch hier nutzen wir wieder Informationen aus dem 
angereicherten ``<structure>``-Element.
{{< mcr-figure caption="XSLT-Quellcode">}}
{{< highlight xml "linenos=table" >}}
  <a href="data:text/plain;charset=US-ASCII,{encode-for-uri(concat(./title[@type='maindoc_md5'],'  ', ./maindoc))}"
     download="{./maindoc}.md5">MD5</a>
{{< /highlight >}}
{{< /mcr-figure>}}

Das Ergebnis als HTML:
{{< mcr-figure caption="HTML-Quellcode">}}
{{< highlight xml "linenos=table" >}}
<a href="data:text/plain;charset=US-ASCII,77cfc859cb00158cf1d12e657b882eae%20%20Mustermann_Dissertation_2020.pdf"
   download="Mustermann_Dissertation_2020.pdf.md5">MD5</a>
{{< /highlight >}}
{{< /mcr-figure>}}

Im ``href``-Attribut wird eingeleitet mit <tt>data:</tt> und anschließendem Mime-Type der Inhalt der zukünftigen Datei spezifziert.  Das ``download``-Atttribut gibt den Dateinamen vor, den unsere MD5-Datei beim Download erhalten soll.

Und so sieht dann die heruntergeladene MD5-Datei aus:
{{< mcr-figure label="MD5-Datei" caption="Mustermann_Dissertation_2020.pdf.md5" >}}
{{< highlight xml "linenos=none" >}}
77cfc859cb00158cf1d12e657b882eae  Mustermann_Dissertation_2020.pdf
{{< /highlight >}}
{{< /mcr-figure>}}