---
title: "Google Fonts lokal einbinden"
slug: google-fonts
date: 2022-02-11

draft: true

blog/authors: ["Wiebke Oeltjen"]
blog/periods: 2022-02
blog/categories:
 - News
blog/tags:
 - "google fonts"

news/frontpage: false
news/title_de: "Google Fonts einbinden"
news/teaser_de: "Google Fonts einbinden"
news/title_en: "Using Google Fonts"
news/teaser_en: "Using Google Fonts"

---
## Hintergrund
Am 20. Januar 2022 hat das Landgericht München I entschieden ([3 O 17493/20](https://rewis.io/urteile/urteil/lhm-20-01-2022-3-o-1749320/)), dass das dynamische Einbinden von Google Fonts einen abmahnfähigen Verstoß gegen die DSGVO darstellt. Die Begründung: „Die unerlaubte Weitergabe der dynamischen IP-Adresse des Klägers durch die Beklagte an Google stellt eine Verletzung des allgemeinen Persönlichkeitsrechtes in Form des informationellen Selbstbestimmungsrechts nach § 823 Abs. 1 BGB dar“ ([https://rewis.io/s/u/zH2/#rd_3](https://rewis.io/s/u/zH2/#rd_3)). Das Urteil ist noch nicht rechtskräftig. 

## Problem
Wer MIR verwendet, sollte beachten, dass Flatly bzw. Bootstrap Google-Fonts einbindet, wenn nichts anderes eingerichtet ist. 

## Lösung
Um das Problem zu vermeiden, bietet sich das *Self-Hosting* der Fonts an. Die Fonts können heruntergeladen und lokal eingebunden werden (siehe dazu [google-webfonts-helper](https://google-webfonts-helper.herokuapp.com/fonts)). Dort können die Google-Fonts in verschiedenen Versionen (und Dateiformaten) zusammengestellt und im ZIP-Verzeichnis heruntergeladen werdem. Auch werden Hinweise gegeben, wie sie in die eigene Webseite (CSS-Dateien) integriert werden können.

Für MIR-Templates, die auf Bootswatch basieren, kann das Laden der von Google gehosteten Version durch das Setzen der Sass-Variable <code>$web-font-path</code> auf <code>false</code> unterbunden werden. Alternativ kann eine URL eingetragen werden:  
<code> $web-font-path: \"https://webfonts.mydomain.de/css?family=Lato:400,700,400italic";</code>

Die Variable muss in einer Sass-Datei ergänzt werden. In MIR gibt es 16 Templates und 2 Layouts. Beides wird in einer Sass-Datei zusammengeführt und je nachdem welches Template und Layout verwendet wird, ergibt sich ein anderer Name, z.B. <code>Layout flatmir + Template flatly = flatmir-flatly.scss</code>.

Der Inhalt sieht immer folgendermaßen aus:

{{< highlight java >}}
 @import "%layout%/lib/variables";  
 @import "common/variables";  
 @import  "../assets/bootswatch/%template%/variables";  
 @import  "../assets/bootstrap/bootstrap";  
 @import  "../assets/bootswatch/%template%/bootswatch";  
 @import "%layout%/layout";  
{{< /highlight >}}

Wobei <code>%layout%</code> durch <code>flatmir</code> und <code>%template%</code> durch <code>flatly</code> zu ersetzen sind. Am Anfang der Datei können Variablen ergänzt werden, wie z.B. <code>$web-font-path</code> oder <code>$font-family-sans-serif</code>:
{{< highlight java >}}
 $web-font-path: "https://webfonts.mydomain.de/css?family=Roboto:400,700,400italic";  
 $font-family-sans-serif: 'Roboto', Helvetica, Arial, sans-serif;  
 @import "flatmir/lib/variables";  
 @import "common/variables";  
 @import  "../assets/bootswatch/flatly/variables";  
 @import  "../assets/bootstrap/bootstrap";  
 @import  "../assets/bootswatch/flatly/bootswatch";  
 @import "flatmir/layout“;  
{{< /highlight >}}
Die Datei muss anschließend im webpages-Verzeichnis abgelegt werden, z.B. hier:
{{< highlight java >}}
 ~/.mycore/mir/data/webpages/META-INF/resources/mir-layout/scss/flatmir-flatly.scss</code>
{{< /highlight >}}

## Hinweis
Im Standard Boostrap werden keine Google-Fonts eingebunden.  

### Quellen
Siehe Meldungen z.B. bei 
* _golem.de_ [„Einbindung von Google Fonts ist rechtswidrig“](https://www.golem.de/news/landgericht-muenchen-einbindung-von-google-fonts-ist-rechtswidrig-2202-162826.html)  
* _Kanzlei Putte_ [„LG München: Einbindung von Google Fonts ohne Einwilligung“](https://www.ra-plutte.de/lg-muenchen-dynamische-einbindung-google-web-fonts-ist-dsgvo/)  

