---

description: beschreibung der wichtigsten MyCoRe Funktionen.
title: Standardisierte Schnittstellen

---

## „Open Archives Initiative“ OAI-PMH 2.0

MyCoRe bietet eine Data-Provider-Schnittstelle entsprechend dem „Metadata Harvesting Protocol“ der
[Open Archives Initiative](http://www.openarchives.org"OAI - Open Archives Initiative")
in der aktuellen Protokoll-Version 2.0. 
Als OAI-Data-Provider macht eine MyCoRe-Anwendung die Metadaten ihrer Inhalte in verschiedenen Formaten zugänglich.
Externe OAI-Service-Provider können diese Daten über die Schnittstelle sammeln und weiterverarbeiten.

Die OAI-Schnittstelle ist frei konfigurierbar, unterstützt Sets, Resumption-Tokens und beliebige Metadatenformate. 
MyCoRe-Klassifikationen können dabei direkt zur Bildung einer Set-Struktur verwendet werden.
Über XSL-Stylesheets können beliebige Ausgabeformate implementiert werden. Bereits implementiert sind die folgenden Formate:

* [Dublin Core:](http://www.openarchives.org/OAI/openarchivesprotocol.html#dublincore)
Dieses Format muss jede OAI-Data-Provider-Implementierung bereitstellen. 
Es ist der kleinste gemeinsame Nenner für die Interoperabilität von Metadaten.
* [XMetaDissPlus:](http://www.dnb.de/DE/Standardisierung/Metadaten/xMetadissPlus.html)
In diesem Format sammelt die Deutsche Nationalbibliothek die Metadaten von Online-Hochschulschriften und E-Dissertationen.
MyCoRe-basierte Publikationsserver können so neu eingestellte E-Publikationen automatisiert an die DNB melden.
* [Epicur:](http://www.d-nb.de/wir/projekte/epicur.htm"EPICUR (Enhancement of Persistent Identifier Services - Comprehensive Method for unequivocal Resource Identification)
Über dieses Ausgabeformat werden persistente Identifikatoren (URNs) zu E-Publikationen und Digitalisaten an die Deutsche Nationalbibliothek zur Registrierung gemeldet. 

## Zugang für Suchmaschinen-Robots

MyCoRe bietet eine spezielle Schnittstelle ("IndexBrowser"), über die ein vollständiger Index aller enthaltenen Objekte
für die Indizierung durch Suchmaschinen-Robots generiert wird. Suchmaschinen wie z. B. Google können so
Metadaten und Volltexte frei zugänglicher, MyCoRe-basierter Repositorien indizieren und weltweit
auffindbar machen.

MyCoRe implementiert weiterhin das von Google, Yahoo, Microsoft und anderen forcierte 
„[Sitemap Protocol](http://www.google.com/schemas/sitemap/0.84/)“.
Über eine generierte XML-Datei erhält eine Suchmaschine dabei direkte Links zu indizierbaren Seiten, 
Informationen zu Änderungshäufigkeiten etc. 

Viele Suchmaschinen werten in den Webseiten enthaltene Metadaten aus (HTML META Elemente). Für das MODS-Datenmodell bietet 
MyCoRe eine direkte Ausgabe der MODS-Metadaten in den Formaten **Dublin Core** und **Highwire Press Tags**.
Suchmaschinen wie **Google Scholar** können dadurch in MyCoRe veröffentlichte E-Publikationen mit ihren wichtigsten 
beschreibenden Daten qualifiziert indizieren. 

## Webservices via SOAP

MyCoRe bietet eine Webservices-Schnittstelle nach dem 
[SOAP](http://de.wikipedia.org/wiki/SOAP"Wikipedia-Beitrag zu SOAP")
Protokoll. Über diese Schnittstelle können dritte Systeme in einer MyCoRe Anwendung suchen und Metadaten der Treffer erhalten.
MyCoRe verwendet die SOAP-Schnittstelle intern, um verteilte Anwendungen zu realisieren, bei denen mehrere MyCoRe
Instanzen parallel durchsucht werden.    

## SWORD-Schnittstelle

Das [Simple Web-service Offering Repository Deposit](http://swordapp.org/) Protokoll definiert eine
Schnittstelle, über die dritte Systeme automatisiert digitale Dokumente mit ihren Metadaten in ein Repository 
einbringen könne. Einige Verlage stellen so z. B. Open-Access-E-Publikationen von Autoren einer Hoschule automatisch 
in den Publikationsserver der Hochschule ein. 

In MyCoRe sind Rahmenfunktionen zur Implementierung der SWORD v1 Spezifikation enthalten. 
Für eine MyCoRe-Anwendung wurde SWORD v1 bereits vollständig implementiert. Derzeit ist eine Implementierung für
SWORD v2 in der Umsetzung.  

## XML via HTTP

XML spielt eine zentrale Rolle in MyCoRe. Alle Metadaten-Objekte sind intern als XML-Dokumente persistent abgelegt.
Metadaten und Klassifikationen lassen sich über die Kommandozeile als XML-Dokumente importieren und exportieren.
Dritte Systeme können diese Schnittstelle für den Batch Import von Metadaten verwenden.

Die Weboberfläche einer MyCoRe-Anwendung wird über Java-Servlets generiert, die XML-Dokumente ausgeben. Dadurch
ergibt sich eine weitere natürliche XML-Schnittstelle, da Seiten wie z. B. Trefferlisten einer Suche auch als XML-Dokument 
über eine HTTP Anfrage ausgegeben werden können. 

## REST-Schnittstelle

Eine REST-Schnittstelle ("Representational State Transfer") ist zur Zeit in Entwicklung.