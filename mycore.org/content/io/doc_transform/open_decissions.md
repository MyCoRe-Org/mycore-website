---

title: 	'Webseiten-Migration: Offene Entscheidungen'
author: ['Robert Stephan', 'Kathleen Neumann']
date: 	'2019-03-12'

---

## Hosting
### MyCoRe-Server *oder* Github-Pages
 - siehe [Hugo: Host on Github](https://gohugo.io/hosting-and-deployment/hosting-on-github/)
 - aber: Auch für das Github-Hosting müssen die Seiten erst gebaut und die generierten Seiten hochgeladen werden.
 - deshalb: Kann auch wie bisher die Seite auf dem MyCoRe-Server mit *Bamboo* gebaut und lokal (per Apache) bereitgestellt werden <br />   (Auschecken / `hugo`-Kommando ausführen / in `www`-Ordner kopieren)

## Mehrsprachigkeit
### Alles übersetzen vs. Fallback vs. kleiner englischer Auftritt
 - wir haben uns in kleiner Runde dafür entschieden einen kleinen eigenen rein englischen Auftritt anzubieten
 - es ist zu überlegen, was das vor allem für die Startseite und deren Aktualität bedeutet
 - genauso Download etc ...
 - vielleicht können wir hier nochmal recherchieren was Hugo da anbietet

## Blog
### Hugo vs. Ghost
 - Wollen wir die jetzige Blog-Plattform behalten, oder Hugo auch für das Blog verwenden?
 - **Vorteil Hugo**:  
    - alles aus "einem 'Guss" / nur ein System
    - Kombination von News / Blog möglich
 - **Vorteil Ghost**: 
    - Online-Editor

## News
### Data *oder* Blog
   - News-Informationen zur Zeit als **JSON** in `/data/news.json`<br /> 
     (entspricht aktuellem Stand (News als XML))
   {{<highlight json>}}
{ "title":    "Neue Anwendung",
  "message": "Die Publikationsplattform der Max Weber Stiftung „perspectivia.net“ basiert nun auf MyCoRe.",
  "url":     "https://www.perspectivia.net/",
  "date":    "06. Dez 2018",
  "author":  "Wiebke Oeltjen",
   "image":  "sf" }
   {{</highlight>}}   
    
   - **Alternative:** Blogeinträge, getaggt mit "frontpage"
    - dadurch automatisch mehr Blogeinträge
    - alte Daten bleiben erhalten (News-Verlauf)
    - allerdings "Mehrarbeit" - zusätzlicher Text für kurzen Blogeintrag
    
### statisch (Hugo) oder dynamisch (Javascript)
   - zur Zeit beim Compilieren mit Hugo erzeugt
   - **Alternative:** Javascript ((Blog-Einträge oder Daten stellt Hugo per REST-API zur Verfügung)
      - Vorteil: Einträge können per Datumsparameter automatisch ein- und ausgeblendet werden <br />
        Solche "Spielereien" gingen auch statisch (Filter, ...). Dann müsste wir aber wengisten **nachts** die Seiten einmal neubauen
       