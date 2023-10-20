---
title:  "Das Dilemma des 'Gecrawlt – zurzeit nicht indexiert': Warum landen Repository-Inhalte nicht im Google-Index?"
slug:   google_gecrawlt_nicht_indexiert
date:   2023-10-18
publishDate: 2023-10-18

draft:  false

blog/authors:  ["Kathleen Neumann"]
blog/periods:  2023-10
blog/categories:
 - Störungen
blog/tags:
 - Google

news/frontpage: true
news/title_de: "Das Dilemma des 'Gecrawlt – zurzeit nicht indexiert'"
news/teaser_de: "Warum landen Repository-Inhalte nicht im Google-Index?"


---
Die Sichtbarkeit einer Website im Google-Suchindex ist von entscheidender Bedeutung, wenn es darum geht, im digitalen Zeitalter online präsent zu sein. Viele Website-Betreiber sehnen sich danach, dass ihre Seiten in den Weiten des Internets gefunden werden. Doch immer wieder taucht ein Problem auf, das Frust und Verwirrung auslöst: "Gecrawlt – zurzeit nicht indexiert." Was bedeutet diese Meldung, und warum landen manche Seiten nicht im Google-Index?

## Crawling und Indexierung: Der Schlüssel zur Sichtbarkeit

Bevor wir uns mit dem Problem der nicht indexierten Seiten befassen, ist es wichtig zu verstehen, wie der Google-Algorithmus funktioniert. Google verwendet einen automatisierten Prozess, der als Crawling und Indexierung bezeichnet wird. So funktioniert es:

1. **Crawling:** Google verwendet sogenannte Bots oder Spiders, um das Internet nach neuen Inhalten zu durchsuchen. Diese Bots folgen Links von einer Seite zur nächsten und sammeln Informationen über Webseiten. Dieser Prozess wird als Crawling bezeichnet.

2. **Indexierung:** Die gesammelten Informationen werden dann in einem riesigen Datenbank-Index gespeichert. Dieser Index enthält Details über Milliarden von Webseiten, darunter Text, Bilder und andere Medien. Die Informationen im Index werden verwendet, um Suchanfragen zu beantworten.

Wenn Ihre Seite "gecrawlt – zurzeit nicht indexiert" ist, bedeutet dies, dass Google Ihre Website besucht und die Informationen gesammelt hat, aber aus irgendeinem Grund entschieden hat, sie nicht in seinen Suchindex aufzunehmen. Lassen Sie uns nun die häufigsten Gründe für dieses Problem genauer betrachten:


### 1. Qualität und Relevanz des Inhalts

Google bevorzugt qualitativ hochwertigen und relevanten Inhalt. Wenn Ihre Seite nicht ausreichend informierend, einzigartig oder nützlich ist, besteht die Möglichkeit, dass sie nicht indexiert wird. Stellen Sie sicher, dass Ihre Inhalte den Bedürfnissen der Benutzer entsprechen und sich von anderen ähnlichen Seiten abheben.

### 2. Technische Probleme

Technische Probleme auf Ihrer Website können dazu führen, dass Google Ihre Seite nicht indexiert. Dazu gehören Fehler in der Seitenstruktur, langsame Ladezeiten, unzureichende XML-Sitemaps oder unvollständige Robots.txt-Dateien. Überprüfen Sie regelmäßig Ihre Website auf technische Probleme und beheben Sie sie, um die Indexierung zu erleichtern.

### 3. Doppelte Inhalte

Google straft Seiten mit doppelten Inhalten ab. Wenn Ihre Seite den gleichen Inhalt wie andere Seiten im Web enthält oder wenn Sie Inhalte von anderen Websites kopieren, wird dies die Wahrscheinlichkeit einer Indexierung drastisch verringern. Erstellen Sie einzigartigen und originellen Inhalt, um dieses Problem zu vermeiden.

### 4. Spam-Techniken

Google hat strenge Richtlinien gegen Spam und Manipulation des Suchindexes. Wenn Ihre Seite verdächtige oder spammy Techniken verwendet, um Suchergebnisse zu manipulieren, kann dies dazu führen, dass sie nicht indexiert wird.


### 5. Neue Website oder geänderte Inhalte

Manchmal dauert es eine Weile, bis Google neu erstellte oder geänderte Inhalte indexiert. Wenn Ihre Seite relativ neu ist oder Sie kürzlich Änderungen vorgenommen haben, kann es einige Zeit dauern, bis sie im Index erscheint.


## Fazit

Die Meldung "Gecrawlt – zurzeit nicht indexiert" kann für Website-Betreiber frustrierend sein. Um dieses Problem zu beheben, ist es wichtig, hochwertige Inhalte zu erstellen, technische Probleme zu beseitigen und sich an die Richtlinien von Google zu halten. Geduld ist ebenfalls eine Tugend, da die Indexierung manchmal Zeit in Anspruch nehmen kann. Wie nun kann man diese Richtlinien befolgen, um bessere Chancen, zu haben, dass die Repository-Inhalte im Google-Suchindex erscheinen und von Nutzern gefunden werden?


## Ein MyCoRe-Beispiel
Als Beispiel haben wir uns das [disziplinäre Open Access-Repositorium SlavDok](https://slavdok.slavistik-portal.de/) einmal genauer angeschaut. Das Fachrepositorium ist seit 2022 online und im Google-Index zu finden, aber von den aktuell 121 in der Sitemap eingetragenen Seiten sind nur 8 indexiert. Die restlichen 103 werden als "Gecrawlt – zurzeit nicht indexiert" aufgelistet. Augenscheinlich besteht zwischen den Seiten kein Unterschied. Im Index befindet sich beispielsweise [slavdok_mods_00000044](https://slavdok.slavistik-portal.de/receive/slavdok_mods_00000044) hingegen nicht im Index steht [slavdok_mods_00000086](https://slavdok.slavistik-portal.de/receive/slavdok_mods_00000086).

Folgende Maßnahmen haben wir ergriffen um die Findbarkeit des Repositories zu verbessern:
### 1. robots.txt
Einige Anpassungen in der robots.txt haben dazu geführt, dass der Link zum PDF nicht angezeigt wurde für die Bots. Durch den expliziten Eintrag "Allow: /rsc/jwt?*" ist nun der Link zum Volltext für die Bots sichtbar, was hoffentlich die Qualität und Relevanz des Inhalts verbessert.
https://slavdok.slavistik-portal.de/robots.txt

### 2. Metatags
Mit einem MIR-Update kam nun auch die Ergänzung, dass das Meta-Tag description aus dem Abstract gefüllt wird, wenn es entsprechend in der Sprache vorhanden ist.
```
    <meta name="title" content="One People, One Languague, One Literature?">
    <meta name="description" content="Histories of literatures mirror views and experiences of their own age and thus are constantly being rewritten. This is true also for the history&hellip;">
```

### 3. Kanonische URL
Durch die Konfiguration der kanonischen URL wird ein entsprechender Eintrag im HTML ergänzt, um auch den fehler "Doppelte Inhalte" zu umgehen.
```
     MIR.CanonicalBaseURL=https://slavdok.slavistik-portal.de/  # in den mycore.properties des Projektes

    <!-- erzeugt auf den Metadatenseiten diesen Eintrag im HTML-Code -->
    <link rel="canonical" href="https://slavdok.slavistik-portal.de/receive/slavdok_mods_00000086">
```

Nun bleibt nur, sich in Geduld zu üben.

