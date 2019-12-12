---
title: "Relaunch der Digitalen Bibliothek der Hochschule Neubrandenburg"
slug: anwendung-digibib-hsnb
date: 2019-11-15

draft: false

blog/authors: ["Robert Stephan", "Hochschulbibliothek Neubrandenburg"]
blog/periods: 2019-11
blog/categories:
 - "Anwendungen"

---

Im November 2019 wurde die Digitale Bibliothek der Hochschule Neubrandenburg auf MyCoRe LTS 2019.06 aktualisiert.
Der Publikationsserver dient vor allem der Veröffentlichung von studentischen Abschlussarbeiten der Hochschule
und umfasst derzeit mehr als 1.800 Dokumente.
<!--more-->

https://www.digibib.hs-nb.de

Im Rahmen der Umstellung wurden u.a. die Metadaten von Dublin Core nach MODS migriert, das Layout 
an das Corporate Design der Hochschule angepasst und der Zugriff via HTTPS ermöglicht. 
Facetten erlauben einen differenzierten Zugang über Dokumenttypen, Fachbereiche oder Sachgruppen.

{{< mcr-figure src="/images/blog/applications/2019_dbhsnb.png" 
         class="text-center border border-secondary p-3" width="90%" 
         label="Screenshot" caption="Digitale Bibliothek der Hochschule Neubrandenburg" 
         attr="Hochschulbibliothek Neubrandenburg" />}}
         
Die Studierenden laden die PDF-Datei ihrer Abschlussarbeit hoch und erfassen die bibliographischen Metadaten per Webformular.
Daraus wird zuerst die Aufnahme für den Katalog der Hochschulbibliothek generiert.
Das Repository ruft die Daten über die SRU-Schnittstelle des Katalogs ab und transformiert sie mittels XSLT in das intern
verwendedete MODS-Format. Dadurch wird die Konsistenz der Daten in beiden Systemen sichergestellt.

