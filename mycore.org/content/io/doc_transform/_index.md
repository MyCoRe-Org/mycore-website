
---

title: "Webseiten-Migration"
author: ['Robert Stephan', 'Steffen Kasten']
mcr_version: ['2025.01']
date: "2019-03-07"

---
## "Spielwiese"
Zum Testen wurde ein Bereich mit der Sprache `io` geschaffen.
Seiten in diesem Bereich bleiben erhalten und können zum Ausprobieren und ggf. "Probeschreiben" von neuen Texten genutzt werden. 

**Der automatisch Transformationsprozess _löscht_** (noch) alle Seiten unterhalb von `de` und `en`, das Menü `menus.de.yaml` sowie die Image-Dateien im Ordner `images/generated`.

## Installation

* Hugo **extended** herunterladen und gemäß Anleitung installieren. 
* Testanwendung auschecken (mit GitURL)
	* [https://github.com/rsteph-de/mycore-website-hugo.git](https://github.com/rsteph-de/mycore-website-hugo.git)
* Maven: mvn clean:compile (oder: mvn clean:install)
	* CSS- und Javascript-Frameworks (Bootstrap, Fontawesome, JQuery) werden aus Webjars (aus Maven-Repositories) extrahiert
	

### Hugo starten

{{< highlight text >}}
cd …\git\mycore-website-hugo\mycore.org
…\git\mycore-website-hugo\mycore.org> hugo server
{{< / highlight >}}
**oder:**

{{< highlight cmd >}}
…\git\mycore-website-hugo\mycore.org> hugo server –D –disableFastRender
{{< / highlight >}}

* -D … Draft-Modus = baut auch alle Seiten mit draft = true)
* -disableFastRender = komplettes Rebuild bei Änderungen

bei Git PULL „verschluckt sich der Server manchmal“ &#8594; Server neustarten

[http://localhost:1313](http://localhost:1313)

## Transformer
Zur automatischen Konvertierung der Forrest-Webseite wurde ein Java-Programm erstellt.
Es befindet sich als eigenständiges Maven-Projekt im Unterordner <code>forrest_hugo_transformer</code>

### Transformer compilieren und starten
{{< highlight shell "linenos=table" >}}
cd ...\mycore-website-hugo\forrest_hugo_transformer
mvn clean install
java -jar target\mycore-forrest2hugo.jar c:\workspaces\mycore_website\git\mycore-documentation c:\workspaces\mycore_website\git\mycore-website-hugo

{{</ highlight>}}

* löscht im <code>content</code>-Verzeichnis die Ornder <code>de</code> und <code>en</code>, den Ordner 
  <code>/static/images/_generated</code> und die Datei <code>/config/_default/menus.de.yaml</code>.
* startet **MenueTransformer** und **PageTransformer**

### MenueTransformer

* erstellt aus der *"site.xml"* die *"menus.de.yaml"*

**alt:** *"site.xml"*
{{< highlight xml "linenos=table, linenostart=23" >}}
<site label="MyCoRe Website" href="" xmlns="http://apache.org/forrest/linkmap/1.0">

  <welcome         label="Start" href="index.html" tab="welcome" />

  <features     label="Funktionen"       href="features/" tab="features">
    <index      label="Übersicht"        href="index.html" />
    <datamodel  label="Datenmodell"      href="datamodel.html" />
    <search     label="Suche"            href="search.html" />
    <frontend   label="Präsentation"     href="frontend.html" />
    <interfaces label="Schnittstellen"   href="interfaces.html" />
    <derivates  label="Dateiverwaltung"  href="derivates.html" />
    <acl        label="Rechteverwaltung" href="acl.html" />
  </features>

  <applications    label="Beispiele"              href="applications/" tab="applications">
    <index         label="Demo"                   href="index.html" />
    <map           label="Karte"                  href="map.html" />
    <list          label="Anwendungen von A-Z"        href="list.html" />
  </applications>

  <download      label="Download"           href="download/" tab="download">
    <howtoget    label="Übersicht"          href="index.html" />
    <dl_mycore   label="MyCoRe"             href="mycore/">
      <release     label="LTS-Release 2018.06"    href="release.html" />
      <changelog   label="Changelog"              href="changelog.html" />
    </dl_mycore>
    <dl_mir            label="MIR"                    href="mir/">
      <mir_release_2018     label="Release 2018.06"        href="release_2018.html" />
      <mir_release_2017     label="Release 2017.06"        href="release_2017.html" />
      <mir_changelog   label="Changelog"              href="changelog.html" />
    </dl_mir>
...
{{< / highlight >}}

**neu:** *"menus.de.yaml"*
{{< highlight yaml "linenos=table">}}
main:
- {identifier: welcome, name: Start, weight: -99, url: /}
- {identifier: features, name: Funktionen, weight: -98, url: /site/features}
- {identifier: index, parent: features, name: Übersicht, weight: -99, url: /site/features/index}
- {identifier: datamodel, parent: features, name: Datenmodell, weight: -98, url: /site/features/datamodel}
- {identifier: search, parent: features, name: Suche, weight: -97, url: /site/features/search}
- {identifier: frontend, parent: features, name: Präsentation, weight: -96, url: /site/features/frontend}
- {identifier: interfaces, parent: features, name: Schnittstellen, weight: -95, url: /site/features/interfaces}
- {identifier: derivates, parent: features, name: Dateiverwaltung, weight: -94, url: /site/features/derivates}
- {identifier: acl, parent: features, name: Rechteverwaltung, weight: -93, url: /site/features/acl}
- {identifier: applications, name: Beispiele, weight: -97, url: /site/applications}
- {identifier: index, parent: applications, name: Demo, weight: -99, url: /site/applications/index}
- {identifier: map, parent: applications, name: Karte, weight: -98, url: /site/applications/map}
- {identifier: list, parent: applications, name: Anwendungen von A-Z, weight: -97,
  url: /site/applications/list}
- {identifier: download, name: Download, weight: -96, url: /site/download}
- {identifier: howtoget, parent: download, name: Übersicht, weight: -99, url: /site/download/howtoget}
- {identifier: dl_mycore, parent: download, name: MyCoRe, weight: -98, url: /site/download/dl_mycore}
- {identifier: release, parent: dl_mycore, name: LTS-Release 2018.06, weight: -99,
  url: /site/download/mycore/release}
- {identifier: changelog, parent: dl_mycore, name: Changelog, weight: -98, url: /site/download/mycore/changelog}
- {identifier: dl_mir, parent: download, name: MIR, weight: -97, url: /site/download/dl_mir}
...
{{< / highlight >}}

### PageTransformer

#### Pfade

* ließt alle XML Dateien im <code>P_INPUT</code> Pfad
* neuer Pfad wird erstellt
	* alte Pfade außerhalb des *"documentation"* Ordners kommen in den Ordner *"site"*
		* alt: .../features/datamodel.html
		* neu: .../site/features/datamodel/
* *".xml"* wird zu *".html"*
* Einsortierung in ".../content/de/..." oder ".../content/en/..." anhand Dateien mit *".de."* oder *".en."*
	* *".de."* und *".en."* wird entfernt

#### Header

* Der Header der Datei wird eingelesen und migriert

**alt:** *"requirements.xml"*
{{< highlight xml "linenos=table">}}
<header>
  <title>Systemanforderungen</title>
  <release>2017.06</release>
  <release>2018.06</release>
  <authors>
    <person email="[EMAIL PROTECTED]" name="Jens Kupferschmidt" />
    <person email="[EMAIL PROTECTED]" name="Kathleen Neumann" />
  </authors>
  <version>2018-03-17</version>
  <abstract>
    MyCoRe ist eine betriebssystemunabhängige Java-Anwendung und bringt bereits viele Komponenten mit. Einige
    Voraussetzungen sind jedoch zu schaffen, bevor Sie eine MyCoRe-Anwendung installieren oder an MyCoRe
    mitentwickeln
    können.
  </abstract>
</header>
{{< / highlight >}}

**neu:** *"requirements.html"*
{{< highlight html "linenos=table">}}
---

title: "Systemanforderungen"
mcr_version: ['2017.06','2018.06']
author: ['Jens Kupferschmidt'], ['Kathleen Neumann']
description: "
      MyCoRe ist eine betriebssystemunabhängige Java-Anwendung und bringt bereits viele Komponenten mit. Einige
      Voraussetzungen sind jedoch zu schaffen, bevor Sie eine MyCoRe-Anwendung installieren oder an MyCoRe
      mitentwickeln
      können.
    "
date: "2018-03-17"

---
{{< / highlight >}}

#### Body

Der Body der Datei wird eingelesen und migriert
	
* Abschnitte: <code>\<section\></code> &#8594; <code>\<div\></code>
* Überschriften: <code>\<section\></code>/<code>\<title\></code> &#8594; <code>\<h2\></code>, <code>\<h3\></code>, <code>\<h4\></code> je nach Schachtelungstiefe
* Codezeilen: <code>\<pre\></code> &#8594; <code>{{&lt; highlight html "linenos=table"&gt;}}</code>
* Bilder:
	* Kopieren der Bilder in den Pfaden *"src/documentation/content/xdocs"* und *"src/documentation/resources"*
	* Neuer Pfad *"/static/images/_generated"*
		* *alt:* <code>\<img src="images/mir/wizard_token.png"\></code> 
		* *neu:* <code>\<img src='{{&lt; relURL "/images/_generated/documentation/getting_started/wizard_token.png" &gt;}}'</code>
* Links: <code>\<a href="site:hibernate"\></code> &#8594; <code>\<a href="{{&lt; ref hibernate &gt;}}"\></code>



## Hugo compilieren
 - ggf <code>baseURL</code> in <code>config.yaml</code> anpassen 
 
{{< highlight cmd >}}
cd …\git\mycore-website-hugo\mycore.org
…\git\mycore-website-hugo\mycore.org> hugo
{{< / highlight >}}

  - Hugo ohne <code>server</code>-Parameter ausführen
  - Hugo erstellt einen Ordner <code>public</code>
  - Das Ergebnis ist **plain-HTML**, dass einfach auf den Webserver kopiert wird.