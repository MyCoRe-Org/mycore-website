---
title:  "Maven-Versionen für Releases und Snapshots via shields.io ermitteln"
slug:   maven-badges
date:   2026-10-19
publishDate: 2026-10-19
draft:  false

blog/authors:  ["Robert Stephan"]
blog/periods:  2026-10
blog/categories:
 - HowTos
blog/tags:
 - 'XPath-WebProxy'
 - Maven

---

Auf den Download-Seiten von mycore.de sollen die aktuellen Snapshot-Versionen von MyCoRe und MIR samt direktem Download-Link erscheinen, ohne dass jemand die Seite nach jedem Build anpassen muss. Die notwendigen Informationen befinden sich in den `maven-metadata.xml`-Dateien des Snapshot-Repositorys auf `central.sonatype.com`.
<!--more-->

Der Browser kann diese Dateien per JavaScript aber nicht einfach abrufen. Sonatype liefert keine passenden CORS-Header aus, daher wird der Zugriff von einer fremden Domain blockiert. Seit Anfang des Jahres lief der Abruf deshalb über den Dienst corsproxy.io. Weil dieser inzwischen einen API-Key benötigt, musste eine Alternative gefunden werden.

## Der Dienst shields.io

Der Hauptzweck von [shields.io](https://shields.io/) ist die Erstellung kleiner Status-Grafiken, sogenannte Badges, wie man sie aus vielen GitHub-READMEs kennt. Ein Badge besteht aus einem Label links und einem Wert rechts.

**Beispiel-Badge im SVG-Format:**  
<img id="badge-preview" src="data:image/svg+xml;utf8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22164%22%20height%3D%2220%22%20role%3D%22img%22%20aria-label%3D%22maven-central%3A%20v2026.06.0%22%3E%3Ctitle%3Emaven-central%3A%20v2026.06.0%3C%2Ftitle%3E%3Cfilter%20id%3D%22blur%22%3E%3CfeGaussianBlur%20stdDeviation%3D%2216%22%2F%3E%3C%2Ffilter%3E%3ClinearGradient%20id%3D%22s%22%20x2%3D%220%22%20y2%3D%22100%25%22%3E%3Cstop%20offset%3D%220%22%20stop-color%3D%22%23bbb%22%20stop-opacity%3D%22.1%22%2F%3E%3Cstop%20offset%3D%221%22%20stop-opacity%3D%22.1%22%2F%3E%3C%2FlinearGradient%3E%3CclipPath%20id%3D%22r%22%3E%3Crect%20width%3D%22164%22%20height%3D%2220%22%20rx%3D%223%22%2F%3E%3C%2FclipPath%3E%3Cg%20clip-path%3D%22url(%23r)%22%3E%3Crect%20width%3D%2291%22%20height%3D%2220%22%20fill%3D%22%23555%22%2F%3E%3Crect%20x%3D%2291%22%20width%3D%2273%22%20height%3D%2220%22%20fill%3D%22%23007ec6%22%2F%3E%3Crect%20width%3D%22164%22%20height%3D%2220%22%20fill%3D%22url(%23s)%22%2F%3E%3C%2Fg%3E%3Cg%20fill%3D%22%23fff%22%20text-anchor%3D%22middle%22%20font-family%3D%22Verdana%2CGeneva%2CDejaVu%20Sans%2Csans-serif%22%20text-rendering%3D%22geometricPrecision%22%20font-size%3D%22110%22%3E%3Cg%20transform%3D%22scale(.1)%22%3E%3Cg%20aria-hidden%3D%22true%22%20fill%3D%22%23010101%22%3E%3Ctext%20x%3D%22465%22%20y%3D%22150%22%20fill-opacity%3D%22.8%22%20filter%3D%22url(%23blur)%22%20textLength%3D%22810%22%3Emaven-central%3C%2Ftext%3E%3Ctext%20x%3D%22465%22%20y%3D%22150%22%20fill-opacity%3D%22.3%22%20textLength%3D%22810%22%3Emaven-central%3C%2Ftext%3E%3C%2Fg%3E%3Ctext%20x%3D%22465%22%20y%3D%22140%22%20textLength%3D%22810%22%3Emaven-central%3C%2Ftext%3E%3C%2Fg%3E%3Cg%20transform%3D%22scale(.1)%22%3E%3Cg%20aria-hidden%3D%22true%22%20fill%3D%22%23010101%22%3E%3Ctext%20x%3D%221265%22%20y%3D%22150%22%20fill-opacity%3D%22.8%22%20filter%3D%22url(%23blur)%22%20textLength%3D%22630%22%3Ev2026.06.0%3C%2Ftext%3E%3Ctext%20x%3D%221265%22%20y%3D%22150%22%20fill-opacity%3D%22.3%22%20textLength%3D%22630%22%3Ev2026.06.0%3C%2Ftext%3E%3C%2Fg%3E%3Ctext%20x%3D%221265%22%20y%3D%22140%22%20textLength%3D%22630%22%3Ev2026.06.0%3C%2Ftext%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E">
```json
// https://img.shields.io/maven-central/v/org.mycore/mycore-base
```


Für viele Dienste gibt es fertige Badges, außerdem lassen sich frei konfigurierbare Badges erstellen:

- **Static Badge:** Label und Wert werden direkt als Parameter übergeben.
- **Dynamic Badge:** Der Wert wird zur Laufzeit aus einer JSON-, XML- oder YAML-Datei gelesen.

Aussehen und Verhalten steuern Parameter wie `style`, `label`, `labelColor`, `color`, `logo` und `cacheSeconds`.

shields.io liefert die Daten für jedes Badge auf Wunsch auch im [JSON-Format](https://contributing.shields.io/tutorial-json-format.html) und erlaubt Abrufe von beliebigen Domains ohne CORS-Beschränkungen. So lässt sich der Dienst als öffentlicher Proxy mit eingebauter XPath-Auswertung direkt im Browser per `fetch()` nutzen.

**Beispiel einer JSON-Antwort:**
```json
{"label":"maven-central","message":"v2026.06.0","color":"blue","link":[]}
// https://img.shields.io/maven-central/v/org.mycore/mycore-base.json
```

## Verwendete shields.io-Badges auf der MyCoRe-Webseite

Für Maven bringt shields.io zwei fertige Versions-Badges mit. Außerdem lassen sich Badges statisch oder dynamisch aus einer XML-Datei erzeugen.

| Badge | Einsatz | URL-Schema |
| --- | --- | --- |
| [Maven Central Version](https://shields.io/badges/maven-central-version) | liest Releases auf Maven Central | `https://img.shields.io/maven-central/v/`<br>`<groupId>/<artifactId>` |
| [Maven metadata URL](https://shields.io/badges/maven-metadata-url) | liest beliebige Versionen (z. B. Snapshots) aus beliebigen Repositories | `https://img.shields.io/maven-metadata`<br>`?metadataUrl=<URL>` |
| [Static Badge](https://shields.io/badges/static-badge) | erzeugt ein Badge aus den angegebenen Parametern | `https://img.shields.io/static/v1`<br>`?label=<Label>&message=<Text>` |
| [Dynamic XML Badge](https://shields.io/badges/dynamic-xml-badge) | extrahiert einen Wert aus einer XML-Datei | `https://img.shields.io/badge/dynamic/xml`<br>`?url=<URL>&query=<XPath>` |

Die beiden Maven-Badges kennen weitere versionsbezogenen Parameter:

- `strategy` bestimmt, welche Version angezeigt wird: `highestVersion` (Standard, sortiert nach Maven-Semantik), `latestProperty` oder `releaseProperty` (Werte aus den Metadaten).
- `filter` schränkt die Versionen vorab ein: `*` ist ein Platzhalter, ein vorangestelltes `!` negiert das Muster, z. B. `filter=2026.06*`.

Beim Maven-Metadata-Badge muss `metadataUrl` auf die artefaktweite `maven-metadata.xml` zeigen,  
also `…/<groupId-als-Pfad>/<artifactId>/maven-metadata.xml`, und URL-encodiert sein.   

Für mycore-base im Snapshot-Repository von Maven Central sieht das so aus:

```
https://img.shields.io/maven-metadata/v?metadataUrl=https%3A%2F%2Fcentral.sonatype.com
%2Frepository%2Fmaven-snapshots%2Forg%2Fmycore%2Fmycore-base%2Fmaven-metadata.xml
```

Wird das Badge als `<img>` in ein `<a>`-Element eingebunden, ist es auch klickbar. Einen Haken hat das Badge allerdings: Es liefert nur die Snapshot-Version wie `2026.12.0-SNAPSHOT`. Für einen Download-Link braucht man aber den Dateinamen mit Zeitstempel und Build-Nummer, etwa `mir-webapp-2026.06.1-20261016.132145-35.war`. Dieser steht in einer zweiten `maven-metadata.xml` im Versionsordner des Maven-Artefakts.  
Hier kommt ein anderes Badge ins Spiel.

## Das Dynamic XML Badge als „XPath-Service“

Das [Dynamic XML Badge](https://shields.io/badges/dynamic-xml-badge) liest per XPath einen beliebigen Wert aus einem XML-Dokument. Die Pflichtparameter sind `url` (das XML-Dokument) und `query` (der XPath-Ausdruck). Mit der Endung `.json` wird daraus ein einfacher XPath-Service ohne CORS-Beschränkungen:

```
https://img.shields.io/badge/dynamic/xml.json?url=<XML-URL>&query=<XPath>
```

Das Ergebnis steht im Feld `message`.  
Für XML-Elemente mit Namespace müsste man im XPath-Ausdruck auf die Funktion `local-name()` zurückgreifen.

Beispiel:

```json
// https://img.shields.io/badge/dynamic/xml.json
// ?url=https%3A%2F%2Fcentral.sonatype.com%2Frepository%2Fmaven-snapshots
//      %2Forg%2Fmycore%2Fmir%2Fmir-webapp%2F2026.06.1-SNAPSHOT%2Fmaven-metadata.xml
// &query=%2F%2FsnapshotVersion%5Bextension%3D%27war%27%5D%5Blast%28%29%5D%2Fvalue
// &label=war
{"label":"war","message":"2026.06.1-20261016.132145-35","color":"blue","link":[]}
```

Für die notwendige URL-Kodierung der Parameter kann die JavaScript-Funktion `encodeURIComponent()` verwendet werden, zum Beispiel:

```javascript
encodeURIComponent("//snapshotVersion[extension='war'][last()]/value")
```

## Umsetzung auf mycore.de

Die Grundlage bildet ein `<a>`-Element, das über `data`-Attribute alle nötigen Angaben zum Maven-Artefakt erhält.

```html
<a class="maven-snapshot-link"
   data-maven-groupid="org.mycore" data-maven-artifactid="mycore-base"
   data-maven-version="2026.06" data-maven-extension="jar">mycore-base</a>
```
Die weitere Verarbeitung erfolgt in zwei Schritten:

### 1. maven-metadata.xml für das aktuelle Punkt-Release der SNAPSHOT-Version finden

```javascript
async function retrieveMavenMetadataURL(e){
  const snapshotsMetadataUrl = "https://central.sonatype.com/repository/maven-snapshots/"
    + e.dataset.mavenGroupid.replaceAll(".","/") + "/" + e.dataset.mavenArtifactid
    + "/maven-metadata.xml";

  const query = e.dataset.mavenVersion 
    ? ('//version[starts-with(., "'+ e.dataset.mavenVersion +'")][last()]') 
    : ('//version[last()');
  const jsonUrl = 'https://img.shields.io/badge/dynamic/xml.json'
    + '?url=' + encodeURIComponent(snapshotsMetadataUrl)
    + '&query=' + encodeURIComponent(query);
  const json = await fetch(jsonUrl)
    .then((response) => response.json());
  const snapshotVersion = json.message; 

  let metadataXmlURL = "https://central.sonatype.com/repository/maven-snapshots/"
    + e.dataset.mavenGroupid.replaceAll(".","/") + "/" + e.dataset.mavenArtifactid
    + "/" + snapshotVersion + "/maven-metadata.xml";
  return metadataXmlURL;
}
```

### 2. Download-URL mit Zeitstempel ermitteln

```javascript
async function retrieveMavenDataViaShieldsIo(e){
  const metadataURL = await retrieveMavenMetadataURL(e);
  if(metadataURL != null){
    const ext = e.dataset.mavenExtension;
    const jsonSnapshotVersionUrl = 'https://img.shields.io/badge/dynamic/xml.json'
      + '?url=' + encodeURIComponent(metadataURL)
      + '&query=' + encodeURIComponent("//snapshotVersion[extension='" + ext + "'][last()]/value")
      + '&label=war';

    const jsonSnapshotVersion = await fetch(jsonSnapshotVersionUrl)
      .then((response) => response.json());
    const snapshotVersion = jsonSnapshotVersion.message;

    const jsonVersionUrl = 'https://img.shields.io/badge/dynamic/xml.json'
      + '?url=' + encodeURIComponent(metadataURL)
      + '&query=' + encodeURIComponent("//version");
        
    const jsonVersion = await fetch(jsonVersionUrl)
      .then((response) => response.json());
    const version = jsonVersion.message;

    const downloadURL = "https://central.sonatype.com/repository/maven-snapshots/"
      + e.dataset.mavenGroupid.replaceAll(".", "/")
      + "/" + e.dataset.mavenArtifactid+ "/" +version
      + "/" +e.dataset.mavenArtifactid + "-" + snapshotVersion
      + "." +e.dataset.mavenExtension;
      return downloadURL;
  }
  else { return null; }
}
```

Die zurückgegebene Download-URL kann als `href`-Attribut des obigen `<a>`-Elements gesetzt werden. Für dessen Inhalt kann ein weiteres
shields.io-Badge genutzt werden.

## Fazit

[shields.io](https://shields.io/) ist mehr als ein Badge-Generator. Über die `.json`-Endung und das *Dynamic XML Badge* kann es als XPath-Dienst für öffentliche XML-Dateien eingesetzt werden und umgeht so die fehlenden CORS-Header der Quelle.
