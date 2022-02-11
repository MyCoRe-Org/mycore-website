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
Am 20. Januar 2022 hat das Landgericht München I entschieden ([3 O 17493/20](https://rewis.io/urteile/urteil/lhm-20-01-2022-3-o-1749320/)), dass das dynamische Einbinden von Google Fonts einen abmahnfähigen Verstoß gegen die DSGVO darstellt. Die Begründung: „Die unerlaubte Weitergabe der dynamischen IP-Adresse des Klägers durch die Beklagte an Google stellt eine Verletzung des allgemeinen Persönlichkeitsrechtes in Form des informationellen Selbstbestimmungsrechts nach § 823 Abs. 1 BGB dar“ ([https://rewis.io/s/u/zH2/#rd_3](https://rewis.io/s/u/zH2/#rd_3)). 

## Lösung
Um das Problem zu vermeiden, bietet sich das *Self-Hosting* an. Die fonts können heruntergeladen und lokal eingebunden werden (siehe dazu [google-webfonts-helper](https://google-webfonts-helper.herokuapp.com/fonts)). Dort können die Google-Fonts in verschiedenen Versionen (und Dateiformaten) zusammengestellt und im ZIP-Verzeichnis heruntergeladen werdem. Auch werden Hinweise gegeben, wie sie in die eigene Webseite (CSS-Dateien) integriert werden können.

Das Laden der von Google gehosteten Version kann durch das Setzen der Sass-Variable <code>$web-font-path</code> auf <code>false</code> unterbunden werden. Alternativ kann eine URL eingetragen werden:  
<code> $web-font-path: \"https://webfonts.mydomain.de/css?family=Lato:400,700,400italic";</code>

Das Urteil ist noch nicht rechtskräftig. 

### Quellen
Siehe Meldungen z.B. bei 
* _golem.de_ [„Einbindung von Google Fonts ist rechtswidrig“](https://www.golem.de/news/landgericht-muenchen-einbindung-von-google-fonts-ist-rechtswidrig-2202-162826.html)  
* _Kanzlei Putte_ [„LG München: Einbindung von Google Fonts ohne Einwilligung“](https://www.ra-plutte.de/lg-muenchen-dynamische-einbindung-google-web-fonts-ist-dsgvo/)  

