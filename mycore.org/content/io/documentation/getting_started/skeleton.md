---

date: "2015-11-10"
description: beschreibung der wichtigsten MyCoRe Funktionen.
title: Mit dem 'Skeleton' zur eigenen Anwendung
author: ['Kathleen Neumann', 'Wiebke Oeltjen', 'Robert Stephan']
mcr_version: [2017.07]
---

Zur Entwicklung einer eigenen MyCoRe-Anwendung stellen wir ein Anwendungsgerüst
zur Verfügung, das als Einstieg dienen soll.

## Installation von "Skeleton"

Das „Skeleton“ ist quasi ein Gerüst zum Erstellen einer eigenen MyCoRe-Anwendung. Diese minimale Webanwendung kann je nach eigenem Bedarf schrittweise um weitere Komponenten und Funktionen erweitert werden. Eigene Anforderungen an das Layout können ebenso einfach realisiert werden, wie Erweiterungen am Datenmodell oder an Klassifikationen. Auch das Rollenmodell lässt sich erweitern und anpassen. Als Vorlage kann die sehr viel umfangreichere Webanwendung „MIR“ verwendet werden. Im Folgenden wird kurz beschrieben, wie das „Skeleton“ verwendet werden kann.

### Embedded Shortcode figure/highlight
Es folgt ein Versuch, den <code>{{</* highlight */>}}</code> shortcode in <code>{{</* mcr-figure */>}}</code>  zu kapseln

{{< mcr-figure label="Code 1" caption="{{<mcr-figure />}} shortcode with embedded {{<highlight />}} shortcode" width="75%" >}}
{{< highlight xml "linenos=table" >}}
<realm id="registerUser" setable="false">
  <label xml:lang="de">Registrierung</label>
  <label xml:lang="en">Register</label>
  <login url="../authorization/new-author.xed" redirectParameter="url">
    <label xml:lang="de">Neue Benutzerkennung anlegen</label>
    <label xml:lang="en">Create new User ID</label>
    <info>
      <label xml:lang="de">
        Neuen Benutzer für die Anwendung registrieren.
      </label>
      <label xml:lang="en">
        Register new user for application.
      </label>
    </info>
  </login>
</realm>
{{< / highlight >}}
{{< / mcr-figure >}}

### Voraussetzungen

Für die Anwendungsentwicklung mit Skeleton benötigen Sie die unter <a href="site:requirements">Systemanforderungen</a>
beschriebene Software.

### 1. Quellen herunterladen

Zuerst sollte ein Arbeitsverzeichnis angelegt werden.
(z.B. <code>C:\skeleton\workspace</code> oder <code>~/skeleton/workspace</code>).</p>

Danach wechselt man in dieses Verzeichnis und lädt das aktuelle Release [Skeleton 2016.02](https://server.mycore.de/svn/maven/skeleton/tags/skeleton-2016.02)
mit dem Kommando <code>svn checkout https://server.mycore.de/svn/maven/skeleton/tags/skeleton-2016.02 skeleton</code> herunter (oder alternativ den aktuellen Entwicklungszweig
[Skeleton Trunk](https://server.mycore.de/svn/maven/skeleton/trunk) mit <code>svn checkout https://server.mycore.de/svn/maven/skeleton/trunk</code>).

### 2. CLI erstellen

Im Arbeitsverzeichnis wird mit dem Kommando <code>mvn clean install</code> die Skeleton Anwendung erstmals gebaut.
Nun steht in <code>skeleton-cli/target</code> ein <code>zip</code> bzw. <code>tar.gz</code> für die MyCoRe-Kommandozeile zur Verfügung.
Das <code>zip</code> bzw. <code>tar.gz</code>kann nun in einem beliebigen Projektverzeichnis auf dem Anwendungs-Server entpackt werden.

### 3. Konfigurieren

#### Konfigurationsverzeichnis generieren

Zuerst wechsel man in das gerade erstellte Verzeichnis der CLI, z.B.:
<code>cd c:\skeleton\skeleton-cli</code>

Anschließend wird das Konfigurationsverzeichnis generiert, indem je nach Betriebssystem
das folgende Kommando aufgerufen wird:
<dl>
  <dt>Linux:</dt><dd> <code>bin/skeleton.sh create configuration directory</code></dd>
  <dt>Windows:</dt><dd> <code>bin\skeleton.bat create configuration directory</code></dd>
</dl>

Im Nutzerverzeichnis wird dadurch ein MyCoRe-Konfigurationsverzeichnis generiert,
das unter Linux <code>~/.mycore/skeleton</code> heißt und bei Windows im Verzeichnis
<code>c:\Users\<userName>\AppData\Local\MyCoRe\skeleton\ </code> zu finden ist.

Es ist darauf zu achten, dass der Name des Konfigurationsverzeichnisses dem Namen der
Webanwendung entspricht, in diesem Beispiel also <code>skeleton</code>:

#### Datenbank konfigurieren

Zur Konfiguration der Datenbank muss die <code>hibernate.cfg.xml</code> im
[MyCoRe-Konfigurationsverzeichnis]({{< ref "/documentation/getting_started/mcr_properties.md" >}})
angepasst werden (siehe [Datenbank / Hibernate]({{< ref "/documentation/archiv/version2015/hibernate.md" >}})).

Seit {{<mcr-version "2016.03">}} wird die Datenbank in der
<code>persistence.xml</code> unter <code>resources/META-INF</code> konfiguriert.

#### Solr konfigurieren

Um in der Anwendung suchen und recherchieren wird ein Solr-Suchserver benötigt.

Dieser läuft als eigene Webanwendung, die in einem Servlet-Container (z.B. Tomcat) deployed
und konfiguiert werden muss (siehe [Solr-Integration]({{< ref "/documentation/archiv/version2017/solr_4.md" >}})).

Der Solr-Core <code>collection1</code> sollte in <code>skeleton</code> umbenannt werden.
Dazu  muss im Solr-Home-Verzeichnis das Verzeichnis für den Core umbenannt und darin
in der Datei <code>core.properties</code> der Name als Property<code>name=skeleton</code>
gesetzt werden.

Dann kopiert man die Solr-Konfiguration für Skeleton (3 Dateien) aus dem Verzeichnis
<code>/config/solr-home</code> der Skeleton-CLI Anwendung in den soeben erstellen Solr-Core

Abschließend wird im MyCoRe-Konfigurationsverzeichnis die URL des Solr-Cores
in der Datei <code>mycore.properties</code> gesetzt:

<code>MCR.Module-solr.ServerURL=http://localhost:8080/solr/skeleton</code>

### 4. Daten laden

Nun können die Klassifikationen und Nutzer in die DB geladen werden.
Dazu wird folgendes Kommando verwendet:

<dl>
  <dt>Linux:</dt><dd> <code>bin/skeleton.sh process config/setup-commands.txt</code></dd>
  <dt>Windows:</dt><dd> <code>bin\skeleton.bat process config\setup-commands.txt</code></dd>
</dl>

Später kann die Datei setup-commands.txt
um anwendungsspezifische Nutzer, Rechte und Klassifikationen ergänzt werden.

### 5. Anwendung deployen

Abschließend soll jetzt die Webanwendung online gestellt werden.

Wenn Änderungen am Source-Code oder Konfiguration vorgenommen worden sind,
dann muss die Anwendung nocheinmal
im Arbeitsverzeichnis mit dem Kommando <code>mvn clean install</code> neu gebaut werden.

Dadurch wird die Datei <code>skeleton-webapp\target\skeleton-2015.11.0.war</code>
erzeugt oder aktualisiert. Diese wird in <code>skeleton.war</code> umbenannt und
dann in das <code>\webapps</code>-Verzeichnis des Servlet-Containers (Tomcat) kopiert.
Der Servlet-Container entpackt und startet die Anwendung.

<p class="text-success">Herzlichen Glückwunsch! Ihre MyCoRe-Anwendung ist jetzt online:</p>

[**http://localhost:8080/skeleton**](http://localhost:8080/skeleton)
        
## Schritt-für-Schritt zur eigenen Anwendung

Nachdem das Anwendungsskelett eingerichtet und initial gebaut wurde, ist es an der Zeit einen
genaueren Blick auf die Verzeichnisse und Dateien zu werfen. Um nun ausgehend von diesem
Anwendungsskelett zur eigenen Anwendung zu kommen, ist es notwendig zu verstehen, wo was steht.

{{< mcr-figure src="/images/io/documentation/getting_started/dir-structure.png"  title="Verzeichnisstruktur des Skeleton-Moduls im Überblick" width="75%" />}}

In der nachfolgenden Schritt-für-Schritt-Anleitung wird genauer in die einzelnen Bereiche geschaut.
Grob kann man jedoch sagen:

<dl>
  <dt style="border:2px solid #9BBB5A;padding-left:5px;">skeleton-cli</dt>
  <dd>erstellt die CLI und enthält die Basis-Konfiguration inkl. ACL-Spezifikation, Solr-Konfiguration und den nötigen Klassifikationen</dd>

  <dt style="border:2px solid #A34AA4;margin-top:10px;padding-left:5px;">skeleton-module</dt>
  <dd>umfasst die gesamte Anwendungslogik</dd>

  <dt style="border:2px solid #4049CC;margin-top:10px;padding-left:5px;">skeleton-webapp</dt>
  <dd>erstellt das Webarchiv</dd>
</dl>

### 1. Datenmodell erstellen

Im ersten Schritt muss das eigene [Datenmodell]({{< ref "/documentation/basics/mcrobject/mcrobject_datadef.md" >}}) basierend auf den 
[MyCoRe-Datentypen]({{< ref "/documentation/basics/mcrobject/mcrobject_datatypes.md" >}})
spezifiziert werden. Diese Spezifikation erfolgt im <span style="border:2px solid #A34AA4;padding:0px 5px;">skeleton-module</span> unter <code>src/main/datamodel/def</code>.
Die dort hinterlegte <code>simpledoc.xml</code> soll als Vorlage für eigene MyCoRe-Objektdefinitionen dienen. Für jedes MyCoRe-Objekt ist eine eigene
Datei anzulegen.

Neue Datenmodelldefinitionen müssen in der Konfigurationsdatei <code>src/main/resources/config/skeleton/mycore.properties</code>
über das Property <code>MCR.Metadata.Type.{objecttype-name}=true</code> registriert werden. Dabei entspricht der <code>{objecttype-name}</code>
dem Dateinamen, der die MyCoRe-Objektdefinition enthält und dem im name-Attribut angegebenen String (wie hier am Beispiel der <code>simpledoc.xml</code>).

{{< highlight xml "linenos=table" >}}
<?xml version="1.0" encoding="UTF-8"?>
<objecttype ...
            name="simpledoc"
            ...>
  <metadata>
    [...]
  </metadata>
</objecttype>


# in mycore.properties
MCR.Metadata.Type.simpledoc=true]]>
{{< / highlight >}}

Abschließend muss die Anwendung inkl. der CLI mit <code>mvn clean install</code> neu gebaut werden.

### 2. Erfassungsmasken

Um eigene Erfasssungsmasken zu erstellen, muss als erstes das HTML-Formular nach eigenen Anforderungen erstellt werden.
Dies kann z.B. mit Bootstrap und unter Verwendung des <a href="http://bootsnipp.com/forms?version=3">FormBuilder für Bootstrap 3</a>
realisiert werden.

{{< mcr-figure src="/images/io/documentation/getting_started/formbuilder.png"  title="Schnell zum Bootstrap-Formular mit dem Formbuilder" width="75%" />}}

<span class="label label-warning">Achtung:</span> Der Formbuilder setzt <code>name</code>-Attribute für Buttons, Input-Felder, etc.
Diese kann der XEditor nicht verarbeiten und produziert Fehler. Diese Attribute also bitte unbedingt entfernen!

Nachdem das HTML-Formular fertig ist, muss dies mit den entsprechenden XEditor-Bestandteilen angereichert werden. Alle Details
dazu finden sich in der [XEditor-Dokumentation]({{< ref "/documentation/frontend/xeditor.md" >}}).

Die Definitionsdatei für die Erfassungsmaske für <code>simpledoc</code> befindet sich im <span style="border:2px solid #A34AA4;padding:0px 5px;">skeleton-module</span>
unter <code>src/main/resources/META-INF/resources/content/publish/simpledoc.xed</code></p>

### 3. Anzeige der Daten

Um die Daten auf der Webseite präsentieren, wird mittels XSLT das XML des MyCoRe-Objektes zu HTML transformiert.

Ein Beispiel für die Transformation eines <code>simpledoc</code>-MyCoRe-Objektes befindet sich im <span style="border:2px solid #A34AA4;padding:0px 5px;">skeleton-module</span> unter
<code>src/main/resources/xsl/simpledoc.xsl</code>

Eigene Transformationsdateien müssen in der Konfigurationsdatei des <span style="border:2px solid #A34AA4;padding:0px 5px;">skeleton-module</span>, den
<code>src/main/resources/config/skeleton/mycore.properties</code> durch Komma separiert ergänzt werden.

{{< highlight shell >}}
##############################################################################
# Datamodel                                                                  #
##############################################################################
MCR.Metadata.Type.simpledoc=true
MCR.Metadata.Type.{objecttype-name}=true
MCR.URIResolver.xslIncludes.objectTypes=%MCR.URIResolver.xslIncludes.objectTypes%,simpledoc.xsl,{objecttype-name}.xsl
{{< / highlight >}}

### 4. Konfiguration der Suche

An dieser Stelle können natürlich nicht die vielfältigen Möglichkeiten, die Solr bietet
vorgestellt und dokumentiert werden. Dazu verweisen wir auf die Literatur und die Solr Homepage.

Die Informationen hier sollen als Einstiegspunkt dienen und helfen, sich bei
der Konfiguration zurechtzufinden. Vor allem sollen die MyCoRe-spezifischen Besonderheiten dargestellt werden.

#### Suchfeld-Definition im Solr Core

Die Definition erfolgt in der Datei <code>schema.xml</code> im Solr Core Konfigurationsverzeichnis.
Wir empfehlen jedoch alle Änderungen im <em>Skeleton </em>Konfigurationsverzeichnis vorzunehmen und
die Dateien bei Änderungen in den Solr Core zu kopieren. Dadurch lassen sich auch die Solr Konfigurationsdateien
mit den anderen Dateien des eigenen Projektes unter Versionskontrolle verwalten.

Die Schema Datei befindet sich unter:
<code>skeleton-cli\src\main\config\solr-home\skeleton\conf\schema.xml</code>

Die Syntax der Suchfelddefinitionen entnehme man dem Solr Wiki oder
einem gutes Solr Buch.

##### Beispiel

{{< highlight xml >}}
<field name="ds.title" type="text_general" multiValued="true" stored="true" />
{{< / highlight >}}

Das Attribut <tt>type</tt> referenziert eine an anderer Stelle im Schema
definierte Typ-Definition. In dieser ist festgelegt, wie Solr die Daten
beim Import und die Terme von Suchanfragen verarbeiten sollen (z.B: Tokenisierung (Zerlegung in Worte), Normalisierung (Umlaute), Stammformreduktion, ...)

Mit dem Attribut <tt>multiValued</tt> wird angegeben, ob das Indexfeld wiederholbar ist.
ID-Werte und Felder nach denen sortiert werden soll, sollte nicht mehrfach vorkommen.

Mit dem Attribut <tt>stored</tt> wird angegeben, ob neben der Solr-internen Form
auch noch die Ausgangsform des Feldwertes gespeichert werden soll. Gespeicherte Felder können
z.B. dazu genutzt werden, Trefferlisten direkt aus der XML-Rückgabe einer Solr Anfrage
zu generieren, ohne nochmal auf das MyCoRe Datenobjekt zugreifen zu müssen.

#### Suchfeld-Mapping per XSLT

Die Werte der Suchfelder werden mittels XSLT generiert.

Um ein eigenes XSLT-Stylesheet in die Verabeitungskette zu integrieren,
muss in der Datei <code>jspdocportal-module\src\main\resources\config\jspdocportal\mycore.properties</code>
das entsprechende Property erweitert werden:

{{< highlight xml >}}
MCR.URIResolver.xslImports.solr-document
      =%MCR.URIResolver.xslImports.solr-document%,solr/skeleton-solr.xsl
{{< / highlight >}}

Die XSLT-Transformationen werden in der Datei <code>skeleton-module\src\main\resources\xsl\solr\skeleton-solr.xsl</code>
           vorgenommen. Diese Datei produziert XML nach folgendem Vorbild:

{{< highlight xml >}}
<field name="feldname">feldwert</field>
{{< / highlight >}}

Die Feldnamen beziehen sich auf die in der Solr Konfiguration (<code>schema.xml</code>)
definierten Felder.

##### Beispiel

{{< highlight xml >}}
<xsl:for-each select="mods:titleInfo/*">
    <field name="ds.title"><xsl:value-of select="text()" /></field>
</xsl:for-each>]]>
{{< / highlight >}}
       </section>

### 5. Anpassung der Suchmasken und Trefferanzeige

Suchmasken können ebenfalls mit dem  <a href="site:xeditor">XEditor</a>-Framework erstellt werden.

Ein Beispiel für die Definition einer einfachen Suchmasken befindet sich im <span style="border:2px solid #A34AA4;padding:0px 5px;">skeleton-module</span> unter:
<code>src/main/resources/META-INF/resources/content/search/simple.xed</code></p>

TODO: Trefferlisten per XSLT

## Tipps im Umgang

### Probleme beim Maven-Build im Eclipse

Checkt man das Skeleton-Mavenmodul im Eclipse aus (inkl. installierter svn und maven-Plugins), ist darauf
zu achten, dass man bei bei den „Run Configurations“ beim Reiter „Refresh“ den Haken setzt bei
„Refresh resources upon completion“. Ansonsten kann es zu einer NullPointerException im Build-Prozess
kommen.
