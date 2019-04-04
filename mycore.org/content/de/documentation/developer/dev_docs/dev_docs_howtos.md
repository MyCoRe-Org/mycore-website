---

title: "MyCoRe Dokumentation: Tipps und Tricks"
description: "
      An dieser Stelle sollen Lösungen für technische Fragen und Hilfestellungen für den Einstieg in Hugo gegeben werden."
author: 		['Jens Kupferschmidt', 'Kathleen Neumann', 'Robert Stephan']
date: 			"2019-04-04"
---

## Mehrsprachigkeit
## Navigation mit YAML
## Hugo Shortcode "Hightlight" für Code-Beispiele
- siehe Hugo-Dokumentation: [Syntax Highlighting](https://gohugo.io/content-management/syntax-highlighting).
- z.B. 
  {{< highlight system>}}
  {{</* highlight system */>}}
      cd \workspaces\mycore-website
      $ mvn clean compile
  {{</* /highlight */>}}                      {{< /highlight >}}

## Tipps und Tricks
### Hugo

### MarkDown
##### "Im Notfall: HTML"
- Wenn man nicht mehr weiter weiß, oder die Mächtigkeit von Markdown nicht ausreicht (z.B. bei Tabellen), lässt sich HTML direkt in den Markdown-Code einbetten.
- Wechsel zwischen Markdown und HTML sollten jedoch auf ein Minimum beschränkt werden.
 
##### Markdown CheatSheet
- Den Einstieg in Markdown kann das Cheatsheet (dt. Spickzettel) ***[Markdown](http://packetlife.net/media/library/16/Markdown.pdf)*** von packetlife.net erleichtern.

##### Zeilenumbrüche
- Einfache Zeilenumbrüche können durch einbetten von HTML (```<br />```) oder durch Einfügen 
  von zwei Leerzeichen (```␣␣```) am Zeilenende erstellt werden. 
- Eine Leerzeile zwischen den Textblöcken erzeugt einen neuen Absatz.