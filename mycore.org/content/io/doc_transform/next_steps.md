---

title: 	'Webseiten-Migration: Nächste Schritte'
author: ['Robert Stephan', 'Kathleen Neumann']
date: 	'2019-03-12'

---
## Migrations(-Zeit-)plan
 - Was ist **vor**, **während** und **nach** der Migration zu tun?

 
## Technisches
- Umzug des Codes in Git von `rsteph-de` zu `MyCoRe-Org` 
	- Branch unter <code>documentation</code> oder eigenes Projekt?
	- eigenes Projekt: `mycore-website` (wg. des "Systemwechsels")
	- [x] **eingerichtet:** https://github.com/MyCoRe-Org/mycore-website
- Automatisches Deployment nach mycore.de
	- Einrichtung einer Subdomain zum Testen: <code>wwwtest.mycore.de</code>
	- Bamboo-Konfiguration zum automatischen Deployment
	- alternativ kann GitHub Pages auch Hugo-Seiten hosten, siehe z.B. https://dev.to/dgavlock/creating-a-hugo-site-on-github-pages-3cjo

## Was ist nach der Migration noch zu tun?
Zu einem Zeitpunkt <code>X</code> kann das Migrations-Skript letztmalig gestartet werden.
Dann beginnt die *Handarbeit* und es gibt kein zurück mehr.

- URLs mit "#" (TODO) reparieren
- Überschriften-Hierarchie h1, h2, h3, h4 prüfen und ggf. korrigieren
- Webseiten bereinigen / umstrukturieren
  - z.B. veraltete Informationen im 'Archiv' entfernen

## Was ist zu beachten / Wo sind noch Probleme?

### Probleme mit doppelten Anführungszeichen in HTML-Attributen und Hugo Shortcodes.

{{< highlight text "linenos=table">}}
<img src="{{</* relURL "/images/_generated/ebers-pap.png" */>}}" title="Papyrus" />
{{< /highlight>}}
 
 - Problem: Hugo kann in Shortcodes nur doppelte Anführungszeichen verwenden. Das beißt sich mit den XML-Attributen.
 - Zur Dokumentation von Shortcodes siehe ([Hugo-Discourse](https://discourse.gohugo.io/t/how-is-the-hugo-doc-site-showing-shortcodes-in-code-blocks/9074/3))
 - Man könnte JDOM erweitern, dass es für die Attribute einfache Anführungszeichen verwendet.
([StackOverflow](https://stackoverflow.com/questions/18742412/save-xml-file-with-single-quotes-with-jdom))
Ob das sinnvoll ist, und ob wir das machen, muss ich mir erst nochmal gründlich überlegen. 
- Oder man verwendet den **[Hugo-Figure-Shortcode](https://gohugo.io/content-management/shortcodes/#figure)**
- [x] **gelöst:** Wir haben JETZT unsereren eigenen Shortcode <strong>&lt;mcr-figure&gt;</strong>


## Anzeige von Source-Code im XML-Format mit <code>&amp;lt;</code> und <code>&amp;gt;</code>
- Durch die JDOM-Ausgabe werden die XML-Tags encoded.
- [x] **gelöst:** Zeilen werden markiert und nach der JDOM-Ausgabe ein zweites Mal prozessiert.

## Javascript für TOC-Generierung ist buggy
- Alternative suchen oder selber neu schreiben
- mit JQuery lässt sich da einiges an Code bereinigen
- verschiedene Sonderfälle könnten ignoriert werden.
- [x] **gelöst:** `tocbot.js` Framework integriert
  - mit eigenem Javascript Code werden, wo notwendig, noch @id-Attribute an die &lt;h1&gt;...&lt;h6&gt; Elemente generiert

## CSS Fine-tuning
 - SCSS / Bootstrap Integration
 - Anpassen des Templates (Überschriften, Abstände, ...)
 
## Dokumentation der Dokumentation
 - Richtlinien zur Arbeit mit Hugo festlegen
 	- Sourcecode in HTML und/oder Markdown
 	- **Yaml** (kein Toml) für Konfigurationsdateien
 	- feste Page-Header-Variablen (Titel, Autor, Datum)
- verwendete und eigene **Shortcodes** für Images, Links, Codeblöcke beschreiben
- Inhaltsverzeichnisgenerierung ("no-TOC"-Klasse, ...)



