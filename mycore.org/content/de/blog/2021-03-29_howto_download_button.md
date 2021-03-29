---
title: "HowTo: Ein multifunktionaler Download-Button"  
slug: howto-download-button
date: 2021-03-29

draft: false

blog/authors: ["Robert Stephan"]
blog/periods: 2021-03
blog/categories: 
- HowTos

---

In diesem Tutorial werde ich am Beispiel eines *Download-Buttons* einige Features demonstrieren, 
die mit diesem oder dem letzten Release in MyCoRe integriert wurden. 
Im Speziellen geht es dabei um die Anreicherung zusätzlicher Informationen aus den Derivaten im ``<structure>``-Teil des MyCoRe-Objektes, XSLT-Funktionen und Data-URLs.
<!--more-->

Schauen wir uns zunächst das *Endergebnis* und den dazugehörigen HTML-Quellcode an:

{{< mcr-figure src="/images/blog/howtos/download_button.png" 
         class="text-center" 
         label="Abbildung" caption="der fertige Download-Button" />}}

Der Button zeigt ein Dateityp-abhängiges Symbol, den Derivate-Typ als Label, die Dateigröße und den Dateinamen. 
Weiterhin besteht die Möglichkeit eine Datei herunterzuladen, die eine MD5-Prüfsumme für die Validierung enthält.

{{< mcr-figure label="Quellcode" caption="HTML-Code für den Download-Button" >}}
{{< highlight html "linenos=table" >}}
<div class="w-100 position-relative" style="padding-right:3em">
  <a class="badge border border-primary text-secondary position-absolute px-1 py-1" 
      style="right:0;bottom:0;height:3.0em" download="Mustermann_Dissertation_2020.pdf.md5"
      href="data:text/plain;charset=US-ASCII,77cfc859cb00158cf1d12e657b882eae%20%20Mustermann_Dissertation_2020.pdf">
      <i class="fas fa-download pb-1"></i><br>MD5
  </a>
  <a class="btn btn-primary ir-button-download d-inline-block"target="_blank" 
     href="http://localhost:8080/rosdok/file/rosdok_disshab_00001234/rosdok_derivate_00005678/Mustermann_Dissertation_2020.pdf">
     <img src="http://localhost:8080/rosdok/images/download_pdf.png" title="PDF Download" align="left" />
     <span class="float-right"><small>(20.2 MB)</small></span>
     <strong>Volltext</strong><br />
     <small>Mustermann_Dissertation_2020.pdf</small>
  </a>
</div>
{{< /highlight >}}
{{< /mcr-figure>}}

## Anreicherung des &lt;structure&gt;-Headers mit Derivate-Informationen (MCRMetaEnrichedLinkID)

Über die URL <tt>/receive/{mcrobjectid}?XSL.Style=xml</tt> können wir uns das interne XML eines MyCoRe-Objektes
ansehen. Zur Generierung von Detailansichten (Frontpage) werden in den Kopfbereich des Objektes
seit Version {{< mcr-version "2019.06" >}} weitere Informationen zu den Derivaten 
(Name der Hauptdatei und Derivate-Typ-Klassifikation) eingebettet.

{{< highlight xml "linenos=table" >}}
<mycoreobject ID="rosdok_disshab_00001234" version="2020.06">
  <structure>
    <derobjects class="MCRMetaEnrichedLinkID">
      <derobject inherited="0" xlink:type="locator" xlink:href="rosdok_derivate_0005678">
        <order>1</order>
        <maindoc>Mustermann_Dissertation_2020.pdf</maindoc>
        <classification classid="derivate_types" categid="fulltext" />
      </derobject>
    </derobjects>
  </structure>
  ...
{{< / highlight >}}

Wir wollen diese Informationen erweitern und zusätzlich noch die Dateigröße und die MD5-Prüfsumme 
der Hauptdatei (<tt>maindoc</tt>) integrieren.

Dazu muss die abstrakte Klasse [org.mycore.datamodel.metadata.MCRMetaEnrichedLinkIDFactory](https://github.com/MyCoRe-Org/mycore/blob/2020.06.x/mycore-base/src/main/java/org/mycore/datamodel/metadata/MCREditableMetaEnrichedLinkID.java) implementiert bzw. erweitert und als Property registriert werden.

{{< mcr-figure label="Konfiguration" caption="mycore.properties" >}}
{{< highlight html "linenos=table" >}}
MCR.Metadata.EnrichedDerivateLinkIDFactory.Class=org.mycore.jspdocportal.common.controller.datamodel.metadata.MCRExtendedDerivateLinkIDFactory
{{< /highlight >}}
{{< /mcr-figure>}}

In der überschriebenen Methode <code>getDerivateLink()</code> erweitern wir die Liste der XML-Elemente
um Einträge für Dateigröße und MD5-Prüfsumme der Hauptdatei (<tt>maindoc</tt>).  

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
          derivateLinkID.setOrCreateElement("maindoc_size", Long.toString(attrs.size()));
          derivateLinkID.getContentList().add(new Element("maindoc_md5").setText(attrs.md5sum()));
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

Mit der Methode ``setOrCreateElement()`` kann ein neues Element mit Textinhalt erzeugt werden.
Über die Methode ``getContentList()`` erhält man Zugriff auf die Liste der Kindelemente von <tt>&lt;derobject&gt;</tt> und kann diese
um weitere, bei Bedarf auch komplexere Elemente erweitern. Als XML-Bibliothek wird in MyCoRe [JDOM](http://www.jdom.org/) verwendet.

Im Ergebnis sehen wir nun die neuen XML-Elemente <tt>&lt;maindoc_size&gt;</tt> und <tt>&lt;maindoc_md5&gt;</tt>:

{{< mcr-figure label="Quellcode" caption="XML-Kopfbereich des MyCoRe-Objektes" >}}
{{< highlight xml "linenos=table" >}}
<mycoreobject ID="rosdok_disshab_00001234" version="2020.06">
  <structure>
    <derobjects class="MCRMetaEnrichedLinkID">
      <derobject inherited="0" xlink:type="locator" xlink:href="rosdok_derivate_0005678">
        <order>1</order>
        <maindoc>Mustermann_Dissertation_2020.pdf</maindoc>
        <classification classid="derivate_types" categid="fulltext"/>
        <maindoc_size>21175865</maindoc_size>
        <maindoc_md5>7a06ba98cd541566ffb94a1a6bb41bb3</maindoc_md5>
      </derobject>
    </derobjects>
  </structure>
  ...
{{< / highlight >}}
{{< /mcr-figure>}}

## Erzeugen des Detailansicht mit XSLT3
Zur Erzeugung des HTML-Codes der Detailansicht (Frontpage) können wir ab Version {{< mcr-version "2020.06" >}} XSLT3 verwenden.
Ein neues Feature sind XSLT-Funktionen. Die MyCoRe-Community stellt einige [XSLT-Funktionen](http://www.mycore.de/documentation/frontend/xsl/xsl_xslt3#mycore-xslt3-funktionen) zur Verfügung, die 
beispielsweise die Arbeit mit Übersetzungen (I18N) oder Anzeige von Klassifikationen erleichtern.

Um die Funktionen nutzen zu können muss im ``<stylesheet>``- Element deren  Namespace deklariert werden
und die Funktionen selbst noch einmal via ``<xsl:import>`` eingebunden werden. 
Wir nutzen den <tt>resource:</tt>-URI-Resolver
um die XSLT-Dateien mit den Funktionsdefinitionen aus dem Classpath laden zu können.

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

Anschließend können die Funktionen in den Stylesheets zum Erzeugen des HTML-Codes genutzt werden, z.B:

{{< mcr-figure label="Quellcode" caption="XSLT-Fragment" >}}
{{< highlight xml "linenos=table" >}}
<img align="left" src="{$WebApplicationBaseURL}images/download_zip.png" 
     title="{mcri18n:translate('Webpage.docdetails.zipdownload')}" />
<strong>{mcrclass:current-label-text(./classification[@classid='derivate_types'])}</strong>
{{< /highlight >}}
{{< /mcr-figure>}}

Am Ende dieses Abschnitts können wir noch einmal das vollständige XSLT-Skript zur Generierung des Download-Buttons betrachten:

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

  <xsl:param name="WebApplicationBaseURL" select="'http://localhost:8080/rosdok/'"/>
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
         href="data:text/plain;charset=US-ASCII,{encode-for-uri(concat(./maindoc_md5,'  ', ./maindoc))}">
         <i class="fas fa-download pb-1"></i><br />MD5
      </a>
      <a class="btn btn-primary ir-button-download d-inline-block" href="{$fulltext_url}" target="_blank">
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
         <span class="float-right"><small>({mcrstring:pretty-filesize(./maindoc_size)})</small></span>
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
Sie werden entweder als <tt>ASCII</tt> oder als <tt>Base64</tt> kodiert und direkt in den HTML-Quellcode eingebettet.

Diese Möglichkeit erspart uns die Implementation eines zusätzlichen Servlets oder einer anderen serverseitigen Komponente, 
die die MD5-Prüfsummen-Datei erzeugt. 

Die Datei besteht in unserem Fall aus nur einer Zeile:
{{< highlight xml "linenos=table" >}}
  {MD5}  {Dateiname}
{{< /highlight >}}

Folgendes XSLT-Skript kann für die Generierung verwendet werden. Auch hier nutzen wir wieder die Informationen aus dem 
angereicherten ``<structure>``-Element.
{{< mcr-figure caption="XSLT-Quellcode">}}
{{< highlight xml "linenos=table" >}}
  <a href="data:text/plain;charset=US-ASCII,{encode-for-uri(concat(./maindoc_md5, '  ', ./maindoc))}"
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

Im ``href``-Attribut wird eingeleitet mit <tt>data:</tt> und anschließendem Mime-Type der Inhalt der zukünftigen Datei codiert. 
Das ``download``-Atttribut gibt den Dateinamen vor, den unsere MD5-Datei beim Download erhalten soll.

Und so sieht dann die heruntergeladene MD5-Datei aus:
{{< mcr-figure label="MD5-Datei" caption="Mustermann_Dissertation_2020.pdf.md5" >}}
{{< highlight xml "linenos=none" >}}
77cfc859cb00158cf1d12e657b882eae  Mustermann_Dissertation_2020.pdf
{{< /highlight >}}
{{< /mcr-figure>}}

Und damit sind wir bereits am Ende meiner kurzen Vorstellung einiger neuer MyCoRe-Features 
und jetzt wünsche ich viel Spaß beim Ausprobieren.
