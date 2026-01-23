---
title:  "Dynamische Maven-SNAPSHOT-Links mit JavaScript"
slug:   maven-snapshot-links
date:   2026-01-23
publishDate: 2026-01-23
draft:  false

blog/authors:  ["Robert Stephan"]
blog/periods:  2026-01
blog/categories:
 - HowTos
blog/tags:
 - 'XML mit JavaScript'
 - Maven

---

In diesem Artikel wird gezeigt, wie die aktuelle Maven SNAPSHOT-Version für ein Maven-Artifact automatisch aus den Maven-XML-Metadaten ausgelesen und daraus dynamisch ein Download-Link generiert werden kann. Dies ist besonders nützlich für Dokumentationsseiten, die immer auf die aktuellsten Entwicklerversionen verweisen sollen. 
<!--more-->
Die Lösung ist auch deshalb relevant, weil das Sonatype-Snapshot-Repository derzeit keine Möglichkeit bietet, die aktuellsten SNAPSHOT-Versionen über eine Weboberfläche anzuzeigen.

Auch Änderungen an Minor-Versionen wie `2025.12.0-SNAPSHOT`, `2025.12.1-SNAPSHOT` etc. werden dabei berücksichtigt.

## Die Lösung: HTML + JavaScript

Gesucht wurde eine Lösung, die ohne externe JavaScript-Abhängigkeiten in jedem modernen Browser lauffähig ist.

### Integration in die Webseite

Zunächst werden Links mit speziellen Data-Attributen für das Maven-Artifact eingefügt:

```html
<a class="maven-snapshot-link" 
   data-maven-groupid="org.mycore" 
   data-maven-artifactid="mycore-base" 
   data-maven-version="2025.12" 
   data-maven-extension="jar">
   mycore-base $VERSION ($SNAPSHOT)
</a>
```

Der Versions-String wird rechtstrunkiert verarbeitet, sodass auch Minor-Releases automatisch berücksichtigt werden. Mit dem Wert `20` würde man auch jahresübergreifend die aktuellste Version ermitteln. Die Platzhalter `$VERSION` und `$SNAPSHOT` werden später durch die tatsächlichen Versionsnummern ersetzt.

Beim Laden der Seite werden alle Links mit dem entsprechenden `class`-Attribut verarbeitet:

```javascript
document.addEventListener("DOMContentLoaded", async function(event) { 
  for (let e of document.querySelectorAll("a.maven-snapshot-link")) {
    const mavenData = await retrieveMavenData(e);
    if(mavenData != null) {
      e.setAttribute("href", mavenData.url);
      e.setAttribute("data-maven-metadata-url", mavenData.metadataURL);
      e.textContent = e.textContent
        .replace("$VERSION", mavenData.version)
        .replace("$SNAPSHOT", mavenData.snapshotVersion);
    }
  }
});
```

### Die Funktionen

#### 1. Maven-Daten abrufen: `retrieveMavenData(e)`

Die Funktion liefert ein JSON-Objekt mit den relevanten Informationen und Links zu einem Maven-Artifact zurück. Als Parameter wird das HTML-Link-Element übergeben, in dessen `data-*`-Attributen die notwendigen Parameter enthalten sind. Im ersten Schritt wird mit der Funktion `retrieveMavenMetadataURL(e)` die `maven-metadata.xml` für die aktuellste verfügbare SNAPSHOT-Version ermittelt.

```javascript
async function retrieveMavenData(e) {
  const metadataURL = await retrieveMavenMetadataURL(e);
  if(metadataURL != null) {
    // Metadaten-XML über CORS-Proxy laden
    const text = await fetch("https://corsproxy.io/?url=" + metadataURL)
      .then((response) => response.text());

    // XML parsen
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(text, "text/xml");

    // Versionsinformationen extrahieren
    const ext = e.dataset.mavenExtension;
    const snapshotVersion = xmlDoc.evaluate(
      "//snapshotVersion[extension='" + ext + "']/value",
      xmlDoc, null, XPathResult.STRING_TYPE, null
    ).stringValue;
    
    const version = xmlDoc.evaluate(
      "/metadata/version",
      xmlDoc, null, XPathResult.STRING_TYPE, null
    ).stringValue;

    // Download-URL konstruieren
    const downloadURL = "https://central.sonatype.com/repository/maven-snapshots/"
      + e.dataset.mavenGroupid.replaceAll(".", "/")
      + "/" + e.dataset.mavenArtifactid + "/" + version
      + "/" + e.dataset.mavenArtifactid + "-" + snapshotVersion
      + "." + e.dataset.mavenExtension;

    return {
      version: version, 
      snapshotVersion: snapshotVersion, 
      url: downloadURL, 
      metadataURL: metadataURL
    };
  }
  return null;
}
```

##### Verwendete Techniken

- **CORS-Proxy**: Der Abruf der Maven-Metadaten-XML-Datei muss über einen öffentlichen CORS-Proxy (hier [corsproxy.io](https://corsproxy.io/)) erfolgen. Dieser ergänzt den fehlenden HTTP-Header `Access-Control-Allow-Origin: *`, damit die externe Datei auf der eigenen Webseite weiterverarbeitet werden kann.
- **dataset**: Über [HTMLElement.dataset](https://developer.mozilla.org/en-US/docs/Web/API/HTMLElement/dataset) lassen sich die Informationen aus den `data-*`-Attributen auslesen. Zu beachten ist, dass bei den Attribut-Namen eine Konvertierung von `dash-style` nach `camelCase` erfolgt.
- **DOMParser**: Der [DOMParser](https://developer.mozilla.org/en-US/docs/Web/API/DOMParser) konvertiert XML-Text in ein DOM-Dokument.
- **XPath-Verarbeitung**: Die Funktion [document.evaluate()](https://developer.mozilla.org/en-US/docs/Web/API/Document/evaluate) führt XPath-Abfragen auf XML-Dokumenten aus und liefert ein [XPathResult](https://developer.mozilla.org/en-US/docs/Web/API/XPathResult)-Objekt zurück. Dieses verfügt über Hilfsfunktionen, um abhängig von der Rückgabe der `evaluate()`-Funktion das Ergebnis (hier: ein String) weiterverarbeiten zu können.

#### 2. Metadata-URL ermitteln: `retrieveMavenMetadataURL(e)`

Diese Funktion ermittelt für das in den `data-*`-Attributen des übergebenen HTML-Elements spezifizierte Maven-Artifact den Link zur `maven-metadata.xml` für die aktuellste verfügbare SNAPSHOT-Version.

```javascript
async function retrieveMavenMetadataURL(e) {
  // Basis-Metadaten-URL konstruieren
  let versionXmlURL = "https://central.sonatype.com/repository/maven-snapshots/"
    + e.dataset.mavenGroupid.replaceAll(".", "/") 
    + "/" + e.dataset.mavenArtifactid
    + "/maven-metadata.xml";

  // XML laden
  const text = await fetch("https://corsproxy.io/?url=" + versionXmlURL)
    .then((response) => response.text());
  
  const parser = new DOMParser();
  const xmlDoc = parser.parseFromString(text, "text/xml");
  const version = e.dataset.mavenVersion;

  // Neueste Version mit dem angegebenen Präfix finden
  const snapshotVersion = xmlDoc.evaluate(
    "(//versions/version[starts-with(., '" + version + "')])[last()]",
    xmlDoc, null, XPathResult.STRING_TYPE, null
  ).stringValue;

  // URL zur versionsspezifischen Metadaten-Datei
  let metadataXmlURL = "https://central.sonatype.com/repository/maven-snapshots/"
    + e.dataset.mavenGroupid.replaceAll(".", "/") 
    + "/" + e.dataset.mavenArtifactid
    + "/" + snapshotVersion + "/maven-metadata.xml";
    
  return metadataXmlURL;
}
```

##### Verwendete Techniken

Hier werden dieselben Technologien wie in der ersten Funktion verwendet.

- **XPath-Ausdruck**: Über `(//versions/version[starts-with(., '2025.12')])[last()]` werden alle `<version>`-Elemente gefunden, die mit dem angegebenen Präfix beginnen. Anschließend wird das letzte (neueste) Element ausgewählt.

#### 3. Bonus: Parent-Version aus POM extrahieren

In unserem Szenario war es notwendig, auch Informationen direkt aus der `pom.xml`-Datei zu ermitteln. Konkret ging es um den Versions-String des verwendeten Parent-Artifacts. Dazu kann man mit den bereits vorgestellten Technologien die POM-Datei parsen.

Allerdings muss im XPath-Ausdruck jetzt mit Namespaces gearbeitet und ein entsprechender Resolver mitgeliefert werden. Dabei handelt es sich um eine einfache JavaScript-Funktion, die zu einem Präfix (hier: `mvn:`) die Namespace-URL (hier: `http://maven.apache.org/POM/4.0.0`) zurückliefert.

```javascript
async function extractMyCoReParentVersionFromPom(url) {
  const text = await fetch("https://corsproxy.io/?url=" + url)
    .then((response) => response.text());
    
  const parser = new DOMParser();
  const xmlDoc = parser.parseFromString(text, "text/xml");
  
  // Namespace-Resolver für Maven-POMs
  const nsResolver = function(prefix) {
    const ns = {
      mvn: "http://maven.apache.org/POM/4.0.0"
    };
    return ns[prefix] || null;
  };
  
  // Parent-Version extrahieren
  const mcrParentVersion = xmlDoc.evaluate(
    "/mvn:project/mvn:parent/mvn:version",
    xmlDoc, nsResolver, XPathResult.STRING_TYPE, null
  ).stringValue;
    
  return mcrParentVersion;
}
```

### Exkurs: Eigener CORS-Proxy
Die Verwendung eines externen CORS-Proxy-Servers sollte kritisch hinterfragt werden. Hierbei entsteht eine Abhängigkeit von der Verfügbarkeit eines externen Dienstes. Zudem existieren Limitierungen bei der Anzahl der Zugriffe, und letztendlich sollten auch datenschutzrechtliche Aspekte berücksichtigt werden.

Die benötigte Funktionalität lässt sich alternativ mit geringem Konfigurationsaufwand über einen selbstgehosteten Apache2-Webserver bereitstellen. Erste Hinweise dazu finden sich auf der Webseite [enable-cors.org](https://enable-cors.org/server_apache.html).

## Fazit

Mit dieser Lösung haben wir gezeigt, dass sich auch mit einfachen JavaScript-Bordmitteln komplexe Aufgaben lösen lassen. Die Kombination aus Data-Attributen, DOMParser und XPath ermöglicht es uns, dynamische Links auf die neuesten SNAPSHOT-Versionen eines Maven-Artifacts zu generieren – ganz ohne manuelle Pflege der Dokumentation.

Besonders praktisch finden wir, dass die Lösung ohne externe JavaScript-Bibliotheken auskommt und in jedem modernen Browser funktioniert. Auch die Verarbeitung von XML mit Namespaces, wie bei Maven-POMs, stellt kein Problem dar.