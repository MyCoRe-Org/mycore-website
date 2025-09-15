---
title: "SVG Sprites - eine Alternative zu Webfonts"
slug:  webfonts_svgsprites
date:  2025-09-15
publishDate: 2025-09-15

draft: 	false

blog/authors: 	["Robert Stephan"]
blog/periods: 	2025-09
blog/categories:
 - HowTos


news/frontpage: 	false

---
<p>
  Icons und Symbole im SVG-Format sind, skalierbare, XML-basierte Vektorgrafiken, die sich einfach in Webseiten einbetten lassen. <em>SVG-Sprites</em> ist eine Technik, die die Verwendung von SVG-Icons und -Grafiken optimiert, indem mehrere dieser Dateien in einer einzigen SVG-Datei zusammengefasst werden. Bei der Anzeige eines einzelnen Icons wird dann nur der entsprechende Teil dieser Bilddatei angezeigt. Vorteile sind eine komfortablen Verwaltung, kürzere Ladezeit und die Möglichkeit Icons bzw. Grafiken umzufärben.

Wir stellen hier ein XSLT-Skript bereit, welches SVG-Dateien aus verschiedenen, frei zugänglichen Icon-Bibliotheken (wie z.B. <a href="https://fontawesome.com/">Fontawesome</a> oder <a href="https://icons.getbootstrap.com/">Bootstrap Icons</a>) herunterlädt und sie gemeinsam als SVG-Sprite-Datei speichert.
</p>

<!--more--> 
<div>
<h3>Vor- und Nachteile von SVG Sprites und Icon-Fonts</h3>
Die bisherige Praxis waren Icon-Fonts. Dabei handelt es sich um Schriftarten für das Internet, die keine Buchstaben, sondern Piktogramme enthalten Auf einer Webseite werden sie mittels CSS in den Quelltext integriert und wie jede andere Schriftart eingelesen.

<table>
  <tr>
    <td></td>
    <th>Vorteile</th>
    <th>Nachteile</th>
  </tr>
  <tr class="align-top">
    <th class="text-nowrap">SVG-Sprites</th>
    <td>
      <ul>
        <li><em>Reduzierte HTTP-Anfragen:</em> Alle Icons werden in einer einzigen Datei gebündelt, was die Ladezeit der Website verbessert.</li>
        <li><em>Bessere Performance:</em> Weniger Serveranfragen führen zu schnelleren Ladezeiten.</li>
        <li><em>Skalierbarkeit:</em> SVGs sind vektorbasiert und können ohne Qualitätsverlust skaliert werden.</li>
        <li><em>Wartbarkeit:</em>Alle Icons sind an einem Ort, was die Verwaltung und Aktualisierung erleichtert.</li>
        <li><em>CSS-Format</em>: SVG-Sprites können einfach über CSS gesteuert und gestaltet werden.</li>
        <li><em>Caching:</em>Die eine Sprite-Datei kann vom Browser gecached werden.</li>
      </ul>
    </td>
    <td>
      <ul>
        <li><em>Browser Support:</em> Ältere Browser (z.B. Internet Explorer 8 oder Android 2.3) werden nicht unterstützt.</li>
      </ul>
    </td>
  </tr>
  <tr class="align-top">
    <th class="text-nowrap">Icon-Fonts</th>
    <td>
      <ul>
        <li><em>Browser Support:</em> auch ältere Browser stellen die Zeichen dar.</li>
        <li><em>Anpassbarkeit:</em> Eigenschaften, wie Größe, Farbe, Schatten oder Rotation sind via CSS gut änderbar.</li>
      </ul>
    </td>
    <td>
      <ul>
        <li><em>Ladezeit:</em> Es muss immer der komplette Zeichensatz eingelesen werden.</li>
        <li><em>Positionierung:</em> Symbole müssen immer als einzelnes Textzeichen verarbeitet werden.</li>
        <li><em>Semantik:</em> Bearbeitung nur im HTML-Code möglich</li>
        <li><em>Integration:</em> Die Einbindung von Webfonts in CSS ist komlex. Bei Fehlern erscheint häufig nur kryptische Zeichen.</li>
      </ul>
    </td>
</tr>
</table>

<h3>Aufbau einer SVG-Sprites Datei</h3>
Schauen wir uns zunächst ein Beispiel für eine SVG-Sprites-Datei an: <br />
<img src="/images/blog/2025-09-15_svg-sprites/sample_sprites.svg" /><br />
<p>
Im <a href="view-source:https:{{< absURL "/images/blog/2025-09-15_svg-sprites/sample_sprites.svg">}}">Quelltext</a>
sieht man, wie die Icons im <tt>&lt;defs&gt;</tt>-Bereich als <tt>&lt;symbol&gt;</tt>-Element mit den Atttributen  <tt>id</tt>, <tt>viewBox</tt> oder <tt>fill</tt>
definiert wurden. In Kommentaren werden Hinweise zur Lizenz des Icons und seiner Quelle angegeben. Durch die Angabe von <tt>fill="currentColor"</tt> lässt sich die Farbe des Icons später beim Einbinden per CSS überschreiben.
</p>
<p>
Im 2. Abschnitt wird mit <tt>&lt;g&gt;</tt> und <tt>&lt;use&gt;</tt> die Icons mit ihrer ID und ihrer Position in der SVG-Sprites-Datei dargestellt.
Diese Angaben sind optional, vereinfachen aber später die Benutzung.
</p>

<h3>XSLT-Datei</h3>
<p>
Für die Erstellung der im vorherigen Abschnitt vorgestellten Datei kann das XSLT-Skript <strong><a href="{{< relURL "/images/blog/2025-09-15_svg-sprites/svg-sprite_icons.xsl">}}">svg-sprite_icons.xsl</a></strong> verwendet werden.
Es sucht das entsprechende Icon Github-Repositorium der jeweiligen Icon-Bibliothek heraus und kopiert den SVG-Code in die Sprites-Datei.</p>
<p>Weiterhin werden Lizenzinformationen und Github-Repository-URL des Images als XML-Kommentar hinzugefügt.
</p>
<p>In einigen Fällen werden minimale Anpassungen an den SVG-Dateien vorgenommen, damit später eine einheitliche Verwendung gewährleistet werden kann. So wird ggf. ein fehlendes Attribut <code>viewBox</code> ergänzt, wenn es nicht vorhanden ist und um die Icons später per cSS Umfärben zu können, werden die Farb-Werte in den Attributen <code>fill</code> und <code>stroke</code> mit dem Schlüsselwort code>currentColor</code> als Wert ersetzt.</p>

## Bedienungsanleitung

### Icons XML-Datei
Als Eingabe für das XSLT-Skript wirde eine einfache XML-Datei erstellt.
``` xml
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="svg-sprite_icons.xsl"?>
<icons>
  <i class="fa-solid fa-bug"></i>
  <i class="bi bi-cookie"></i>
  <i class="bi bi-cookie"></i>
  <i class="teenyicons teenyicons-pdf-solid"></i>
</icons>
```

Das XSLT 1.0 Stylesheet muss im Header der Datei eingebunden werden: `<?xml-stylesheet type="text/xsl" href="svg-sprite_icons.xsl"?>` 

Die gewünschten Icons werden unterhalb des Element `<icons>` als `<i>`-Elemente angegeben. Dabei orientiert sich die Syntax an Icon-Font-Integration von Font-Awesome und Bootstrap Icons.

Um einen einheitlichen Zugriff auf die verschiedenen Icon-Bibliotheken zu ermöglichen, wurde eine einheitliche `class`-ID definiert. So setzt sich die Beispiel-ID <code>fa-solid_fa-bug</code> aus dem Kürzel der jeweiligen Icon Bibliothek (z.B. <code>fa</code> für Fontawesome), einen möglichen Prefix (z.B. <code>solid</code>) und einem Unterstrich, gefolgt vom Icon Namen in der Icon-Bibliothek (z.B. <code>fa-bug</code>) zusammen.</p>

### Konvertierung XML zu SVG
Aus dieser Datei wird im nächsten Schritt die SVG-Sprites-Datei durch Anwendung des XSLT-Skripts erzeugt.  
Dazu gibt es 2 Möglichkeiten:

#### Option 1: Browser (Firefox) und jwebserver

Der Browser Firefox kann XSLT 1.0 Code ausführen und die Datei konvertieren.
Aus Sicherheitsgründen lädt der Browser aber weiteren Dateien von der Festplatte nach. Deshalb muss die Transformation in einem Webserver gestartet werden. Java-Entwickler können dafür das Tool `jwebserver` benutzen.

Um den Webserver zu starten geht man in der Kommandozeile in den Projektordner und gibt einfach den Befehl `jwebserver` ein.
Nun kann die XML-Datei über die URL `http://127.0.0.1:8000/svg-sprite_icons.xml` geöffnet werden.  
Nach dem öffnen muss die Seite im Browser (Firefox) als ***.svg** gespeichert werden. Beim Speichern muss als Dateityp **"Webseite, komplett (*.htm; *.html)"** ausgewählt sein.

#### Option 2: Xalan
Eine Alternative ist [Xalan](https://xalan.apache.org/). Xalan ist ein Open-Source Projekt der Apache Software Foundation. Xalan wird verwendet, um XML-Daten mithilfe von XSLT-Stylesheets in andere Formate (z.B. HTML, Text oder andere XML-Strukturen) umzuwandeln. Für die Konvertierung werden 2 `jar`-Dateien benötigt [xalan.jar](https://repo1.maven.org/maven2/xalan/xalan/2.7.3/xalan-2.7.3.jar) und [serializer.jar](https://repo1.maven.org/maven2/xalan/serializer/2.7.3/serializer-2.7.3.jar). Diese lädt man herunter und kopiert sie in den Projektordner. Anschließend wechselt man auf der Kommandozeile in der  Projektordner und führt folgenden Befehl aus:

```
java -cp "xalan.jar" org.apache.xalan.xslt.Process -in svg-sprite_icons.xml -xsl svg-sprite_icons.xsl -out ausgabe.svg
```

### Einbindung in die Webseite via ID

Um die soeben erzeugte SVG-Sprites-Datei auf einer Webseite nutzen zu können, kann sie mit `<svg><use /></svg>`eingebunden werden. Sie wird `xlink:href` Attribut verlinkt und die Icon-ID als Referenz (nach **"#"**) angehängt.

```
<button type="button" class="btn btn-outline-danger">
  <svg class="icon"><use xlink:href="sample_sprites.svg#fa-solid_fa-bug" /></svg>
  Käfer
</button>
```

### CSS: Skalierung

Damit die Grafik sich gut in den benachbarten Text einfügt, wird wird folgende Style-Regel benötigt.

```
<style>
.icon {
  width: 1em;
  height: 1em;
  vertical-align: -0.125em;
</style>
}
```
Je nach Bedarf können weitere CSS-Eigenschaften oder weitere Klassen ergänzt werden.


<h3>Quellen und weitere Informationen</h3>
<ul>
  <li>Icon Fonts oder SVG-Sprites? (<a href="https://www.sandstein.de/blog/icon-fonts-oder-svg-sprites">sandstein.de</a></li>
  <li>Vorteile von SVG-GRafiken im Webdesign (<a href="https://www.t3premium.de/blog/vorteile-svg-grafiken-im-webdesign/">t3premium.de</a>)</li>
</ul>
</div>
