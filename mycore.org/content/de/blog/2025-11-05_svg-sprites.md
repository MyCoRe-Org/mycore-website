---
title:  "SVG-Sprites statt Web-Icon-Fonts"
slug:   svg-sprites
date:   2025-11-10
publishDate: 2025-11-10
draft:  false

blog/authors:  ["Robert Stephan"]
blog/periods:  2025-11
blog/categories:
 - HowTos
blog/tags:
 - XSLT
 - SVG

---
In diesem Tutorial soll gezeigt werden, wie in einer Webanwendung Icon-Fonts durch SVG-Sprites abgelöst werden können.
<!--more-->

### Was sind SVG-Sprites?
Als SVG-Sprites werden SVG-Dateien bezeichnet, die mehrere nebeneinander angeordnete Symbole enthalten.
Diese Symbole können dann einzeln auf Webseiten verwendet werden.

Bislang wurden in unseren Webanwendungen Symbole aus Web-Icon-Fonts, wie 
[Fontawesome](https://fontawesome.com/icons) oder [Bootstrap-Icons](https://icons.getbootstrap.com/) verwendet. Demgegenüber bieten SVG-Sprites
mehrere **Vorteile**:
- Anstelle großer Font-Dateien wird nur *eine* SVG-Datei verwendet.
- Diese Datei kann gut von Browsern gecacht werden.
- Die Datei ist lokal. Sie muss nicht aus einer externen Quelle (Content Delivery Network, CDN) oder aus einem Web-JAR (Maven-Dependency) geladen werden.
- Eine Mischung von Symbolen aus mehreren Icon-Fonts ist möglich.
- Die SVG-Symbole sind ebenso per CSS in Farbe, Größe, ... anpassbar.

### XSLT-Stylesheet zur Erstellung eines SVG-Sprites
Das XSLT1.0-Stylesheet **[svg-sprites.xsl](/downloads/snippets/blog/svg-sprite-icons/svg-sprite-icons.xsl)** kann für die Erstellung eines SVG-Sprites mit Symbolen aus verschiedenen Web-Icon-Fonts verwendet werden.
Als **Eingabe** dient eine einfache XML-Datei, in der die benötigten Icons aufgelistet sind. Als Syntax werden `<i>`-Elemente mit `class`-Attributen verwendet, wie sie aus dem Einsatz von Web-Fonts bekannt sind (siehe [Beispiel-XML-Datei]({{<relURL "/downloads/snippets/blog/svg-sprite-icons/sample_svg-sprite-icons.xml">}})):
``` xml
<?xml-stylesheet type="text/xsl" href="svg-sprite-icons.xsl"?>
<icons>
  <i class="fa-solid fa-bug"></i>
  <i class="bi bi-cookie"></i>
  ...
</icons> 
```
Das `class`-Attribute enthält immer zwei Werte. Der *erste Wert* ist ein Kürzel für die Icon-Bibliothek.
Wenn Icons in verschiedenen Varianten vorliegen, wird hier zusätzlich der Stil codiert. Dieser entspricht häufig dem Ordnernamen im GitHub-Repository. Der *zweite Wert* entspricht der ID des Icons. Die ID kann in
der Regel von der Recherche-Seite kopiert werden oder sie entspricht dem Dateinamen im GitHub-Repository.

Das *XSLT-Stylesheet* führt mit dieser Datei folgende **Transformation** durch:
- Ausgehend von den IDs der einzelnen Icons werden die zugehörigen SVGs aus den GitHub-Repositorien der verschiedenen Webfonts heruntergeladen.
- Bei Symbolen einiger Webfonts werden geringfügige Optimierungen vorgenommen.
  So wird beispielsweise die Farbe Schwarz durch `currentColor` ersetzt. Dadurch wird es später möglich, das Icon per CSS umzufärben.

### Ausführen der Transformation
Das Stylesheet ist XSLT 1.0 konform, so lässt sich die Transformation mit einem gängigen Browser durchführen. Allerdings benötigt man inzwischen einen Webserver (z.B [Apache HTTPD](https://httpd.apache.org/), [Tomcat](https://tomcat.apache.org/) oder [jwebserver](https://dev.java/learn/jvm/tool/jwebserver/)), da aktuelle Browser es lokalen HTML-Dateien nicht mehr gestatten, zusätzliche Daten von externen Quellen nachzuladen.  
Man startet beispielsweise *jwebserver* in dem Ordner, in dem sich die Beispiel-XML-Datei und die XSLT-Datei befinden, öffnet im Firefox-Browser die Seite [http://127.0.0.1:8000/sample_svg-sprite-icons.xml](http://127.0.0.1:8000/sample_svg-sprite-icons.xml) und speichert diese als SVG-Datei ab (z.B. als [sample_svg-sprite-icons.svg]({{<relURL "/downloads/snippets/blog/svg-sprite-icons/sample_svg-sprite-icons.svg">}})). Alternativ lässt sich die Transformation auch an der Kommandozeile mit einem Tool wie [xsltproc](https://manpages.ubuntu.com/manpages/noble/en/man1/xsltproc.1.html) durchführen.

### Benutzung der SVG-Datei
Als **Ergebnis** wird folgende SVG-Datei erzeugt:
<img src="{{<relURL "/downloads/snippets/blog/svg-sprite-icons/sample_svg-sprite-icons.svg">}}" alt="SVG-Datei mit allen Symbolen" style="display:block;width:400px" class="border border-secondary" />  

Die **Verwendung** im HTML-Code einer Webseite erfolgt beispielhaft auf folgende Weise:

<button style="float:right;margin-left:3em;" type="button" class="btn btn-outline-danger">
  <svg class="icon" style="width: 1em; height:1em; vertical:align:-0.125em;">
    <use xlink:href="{{<relURL "/downloads/snippets/blog/svg-sprite-icons/sample_svg-sprite-icons.svg">}}#fa-solid_fa-bug" />
  </svg>  Käfer</button>
  
``` html
<button type="button" class="btn btn-outline-danger">
  <svg class="icon">
    <use xlink:href="sprite-icons.svg#fa-solid_fa-bug" />
  </svg>  Käfer</button> 
```
Zusätzlich muss per *CSS* die Größe des Symbols an die Umgebung angepasst werden:
``` css
.icon {
    width: 1em; height:1em; vertical:align:-0.125em; 
}
```
Es können auch noch weitere Eigenschaften, wie z.B. die Farbe, verändert werden.

### Unterstützte Web-Icon-Fonts
Symbole aus folgenden Web-Icon-Fonts werden mit dem XSLT-Stylesheet geladen und in einer SVG-Datei gespeichert:

#### Bootstrap Icons
*"Free, high quality, open source icon library"* (über 2.000 Symbole)  
* Ressourcen: [Homepage](https://icons.getbootstrap.com/), 
[GitHub](https://github.com/twbs/icons), 
[Recherche](https://icons.getbootstrap.com/), 
vollständiges SVG-Sprite: [bootstrap-icons.svg](https://icons.getbootstrap.com/bootstrap-icons.svg)
* Beispiel-XML: `<i class="bi bi-cookie"></i>`

#### Fontawesome Icons
*"The internet's favorite icon library just expanded the menu. New designs. New packs. Millions of possible icons."* (ca. 2.000 freie Symbole)  
* Ressourcen: [Homepage](https://fontawesome.com/),
[GitHub](https://github.com/FortAwesome/Font-Awesome), 
[Recherche](https://fontawesome.com/search),
SVG Sprite: [Download-Hinweise](https://docs.fontawesome.com/web/add-icons/svg-sprites)
* Beispiel-XML: `<i class="fa-brands fa-linux"></i>`

#### Teenyicons
*"Designed on a 15x15 grid, Teenyicons easily fit in very small spaces and maintain a crisp look"* (ca. 1.200 Symbole)  
* Ressourcen: [GitHub](https://github.com/teenyicons/teenyicons),
[Recherche](https://icon-sets.iconify.design/teenyicons/)
* Beispiel-XML: `<i class="teenyicons teenyicons-pdf-solid"></i>`

#### Material Design Icons
*"Material Design Icons is the official icon set from Google. The icons are designed under the material design guidelines."* (ca. 11.000 Symbole)  
* Ressourcen: [GitHub](https://github.com/material-icons/material-icons),
Recherche via [iconify](https://icon-sets.iconify.design/ic/)
* Beispiel-XML: `<i class="ic ic-twotone-assignment-ind"></i>`

#### Octicons
*"A scalable set of icons handcrafted by GitHub."*  (ca. 600 Symbole)  
* Ressourcen: [Homepage](https://primer.style/octicons/),
[GitHub](https://github.com/primer/octicons/), 
Recherche via [primer.style](https://primer.style/octicons)
* Beispiel-XML: `<i class="oct oct-people-24"></i>`

#### Lucide
*"Lucide is an open-source icon library that provides 1000+ vector (svg) files for displaying icons and symbols in digital and non-digital projects. 
The library aims to make it easier for designers and developers to incorporate icons into their projects..."* (über 1.000 Symbole)  
* Ressourcen: [Homepage](https://lucide.dev/),
[GitHub](https://github.com/lucide-icons/lucide), 
[Recherche](https://lucide.dev/icons/)
* Beispiel-XML: `<i class="lucide lucide-rabbit"></i>`

#### Hero Icons
*"Beautiful hand-crafted SVG icons, by the makers of Tailwind CSS.
Available as basic SVG icons and via first-party React and Vue libraries."* (über 300 Symbole)   
* Ressourcen: [Homepage](https://heroicons.com/),
[GitHub](https://github.com/tailwindlabs/heroicons/)
* Beispiel-XML: `<i class="hero-24-outline hero-truck"></i>`

#### Tabler
*"A set of over 5800 free MIT-licensed high-quality SVG icons for you to use in your web projects."*   
* Ressourcen: [Homepage](https://tabler.io/icons),
[GitHub](https://github.com/tabler/tabler-icons/),
[Recherche](https://tabler.io/icons)
* Beispiel-XML: `<i class="tabler-outline tabler-plant"></i>`

#### Phosphor Icons
*"Phosphor is a flexible icon family for interfaces, diagrams, presentations — whatever, really. - 1,248 icons and counting - 6 weights: Thin, Light, Regular, Bold, Fill, and Duotone Designed at 16 x 16px to read well small and scale up big*"  
* Ressourcen: [Homepage](https://phosphoricons.com/),
[GitHub](https://github.com/phosphor-icons/homepage),
[Recherche](https://phosphoricons.com/#toolbar)
* Beispiel-XML: `<i class="phosphor-duotone phosphor-bathtub"></i>`

#### Radix Icons
*"A crisp set of 15×15 icons designed by the WorkOS team."* (über 300 Symbole)   
* Ressourcen: [Homepage](https://www.radix-ui.com/icons),
[GitHub](https://github.com/radix-ui/icons/)
* Beispiel-XML: `<i class="radix radix-rocket"></i>`

#### Clarity
Clarity icons provides pixel-perfect, scalable SVG-based icons. The icon system gives you complete control over icon color, orientation, and size. Additionally, 
you can access and customize any SVG graphic elements inside the icon through standard CSS.  
* Ressourcen: [Homepage](https://clarity.design/),
[GitHub](https://github.com/vmware-archive/clarity-assets/), 
[Recherche](https://clarity.design/documentation/icons/shapes)
* Beispiel-XML: `<i class="clr-essential clr-objects-solid"></i>`

#### Simple Icons
*"Over 3300 SVG icons for popular brands."*  
* Ressourcen: [Homepage](https://simpleicons.org/),
[GitHub](https://github.com/simple-icons/simple-icons/)
* Beispiel-XML: `<i class="simple simple-buymeacoffee"></i>`

#### Iconoir
*"An open source icons library with 1600+ icons, supporting React, React Native, Flutter, Vue, Figma, and Framer."*  
* Ressourcen: [Homeage](https://iconoir.com/),
[GitHub](https://github.com/iconoir-icons/iconoir/)
* Beispiel-XML: `<i class="iconoir-regular iconoir-jellyfish"></i>`

#### Flag-Icons
*"A curated collection of all country flags in SVG"*  (ca. 270 Symbole)  
* Ressourcen: [Homepage](https://flagicons.lipis.dev/),
[GitHub](https://github.com/lipis/flag-icons/)
* Beispiel-XML: `<i class="flagicons flagicons-ki"></i>`

#### Academicons
*"Academicons is a specialist icon font for academics. It contains icons for websites and organisations related to academia that are often missing from mainstream font packages. It can be used by itself, but its primary purpose is to be used as a supplementary package alongside a larger icon set."*  (ca. 150 Symbole)  
* Ressourcen: [Homepage](https://jpswalsh.github.io/academicons/),
[GitHub](https://github.com/jpswalsh/academicons/)
Recherche via [icones.js.org](https://icones.js.org/collection/academicons)
* Beispiel-XML: `<i class="ai ai-springer-square"></i>`


## Fazit
Gerade wenn in einer Webanwendung nur wenige Icons verwendet werden, die gegebenenfalls auch noch aus verschiedenen Web-Icon-Fonts stammen, bietet eine einzelne SVG-Sprite-Datei Vorteile. Mit dem hier vorgestellten XSLT-Stylesheet kann diese unter Verwendung mehrere bekannter Icon-Bibliotheken hergestellt werden. Bei Bedarf lässt sich das Stylesheet für weitere Icon-Bibliotheken anpassen.  
**Viel Spaß beim Ausprobieren!**
