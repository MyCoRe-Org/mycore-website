---

description: beschreibung der wichtigsten MyCoRe Funktionen.
title: Weboberfläche und Autoren-Schnittstellen

---

## Anpassbare Weboberfläche

MyCoRe verwendet XML als internes Speicher- und Datenaustauschformat.
Die Weboberfläche einer MyCoRe Anwendung wird durch „Java Servlets“ implementiert,
die die Ergebnisse einer Anfrage als XML-Dokumente ausliefern. Diese XML-Dokumente werden
serverseitig über <strong>XSL-Stylesheets</strong> in eine HTML-Webseite transformiert.

Durch Änderungen an CSS-Dateien und den XSL-Stylesheets kann die Weboberfläche nahezu beliebig
angepasst werden, um andere Layouts und Darstellungen zu erzeugen. 
Die Verwendung von XSL ermöglicht dabei auch andere Ausgabeformate als HTML. 
Beispielsweise sind die Formate <strong>RSS, CSV oder PDF</strong> (mittels XSL-FO) leicht realisierbar. 
Unterstützung von XSL-FO ist in MyCoRe direkt integriert, so dass sich Inhalte via XSL direkt als PDF ausgeben lassen.

## Mehrsprachigkeit und UTF-8

MyCoRe unterstützt mehrsprachige Weboberflächen. Einzelne Abschnitte oder ganze Webseiten können in
verschiedenen Sprachen hinterlegt werden. Bezeichnungen von Such- oder Eingabefeldern werden in sprachabhängigen,
einfach anpassbaren Konfigurationsdateien verwaltet. Bei der Ein- und Ausgabe von Datums- und Zahlenwerten werden
verschiedene Formate unterstützt. Auch der Textfluss ist z. B. für das Arabische von rechts nach links umkehrbar.
MyCoRe ist vollständig UTF-8 fähig, sowohl in der Weboberfläche als auch in der Speicherung und Bearbeitung der Metadaten.

## Such- und Eingabemasken

Die freie Konfigurierbarkeit des Datenmodells erfordert eine flexible Möglichkeit, 
eigene Such- und Eingabemasken zu gestalten. Dies wird durch das MyCoRe-Editor-Framework realisiert. 
Metadaten und Suchanfragen werden in MyCoRe intern als XML-Dokumente dargestellt. 
Das Editor-Framework ordnet Eingabefeldern in Formularen bestimmten XML-Elementen zu.
So können auch sehr komplexe Formulare individuell realisiert werden. 
Das Editor-Framework unterstützt mehrsprachige Bezeichner, wiederholbare Felder und Bereiche, 
Online-Hilfetexte und umfangreiche Regeln zur Eingabevalidierung.

## Korbfunktion und Exportformate

MyCoRe bietet eine Korbfunktion. Objekte können aus der Trefferliste oder Einzelansicht heraus in 
den Korb gelegt werden, der in der Benutzer-Sitzung gehalten wird. Die im Korb gesammelten Objekte
können z. B. gemeinsam exportiert werden. 

Über konfigurierbare, mehrstufige <strong>Content-Transformer</strong> kann MyCoRe aus den ursprünglichen 
XML-Metadaten von Objekten nahezu beliebige andere Ausgabeformate erzeugen. So kann z. B. in einem ersten
Transformationsschritt die MODS-Darstellung einer Publikation via XSL um zusätzliche Daten angereichert werden,
in einem zweiten Schritt dieses MODS-Dokument dann über ein externes Programm auf dem Server (z. B. BibUtils)
als BibTeX-Datei ausgegeben werden.    

In Kombination mit der Korbfunktion kann eine MyCoRe-Anwendung so verschiedene Exportformate, z. B. für
Literaturverwaltungsprogramme, anbieten.

## Web-Content-Management-Modul

MyCoRe bietet ein einfaches Web-Content-Management-Modul, über das sich 
Navigationsmenü und die Inhalte statischer Webseiten online bearbeiten lassen.
Es gibt eine Übersetzungsfunktion zur Realisierung mehrsprachiger Webseiten. 
Das WCMS-Modul generiert automatisch eine Sitemap der Serverseiten und speichert die 
Änderungshistorie an den Seiten. Auch ein Upload von Bildern ist möglich.
Bestimmten Seiten oder Bereichen kann ein Layout-Template auf CSS-Basis
zugewiesen werden, so dass innerhalb eines Anwendungsservers verschiedene Bereiche mit 
unterschiedlichem Layout gepflegt werden können.

Hinweis: Dieses Modul wird zur Zeit nicht mehr weiterentwickelt.

## Autoren-Schnittstelle und Workflow

Neben dem Batch-Import über XML-Dokumente können berechtigte Anwender direkt ihre Inhalte über die Weboberfläche
einer MyCoRe Anwendung pflegen. Über das Editor-Framework können unterschiedliche, auch komplexe Eingabeformular
für Metadaten inkl. Eingabevalidierung gestaltet werden. Dateien werden direkt über ein HTML-Formular oder ein Java-Applet 
(für sehr große Dateien) hochgeladen.

Workflows zur weiteren Verarbeitung der so eingestellten Dokumente können in verschiedener Komplexität realisiert werden.
Das **SimpleWorkflow-Modul** bietet hier z. B. eine einfachste Variante eines Freigabeschritts, bei dem 
die zu bearbeitenden Metadaten und Dateien zunächst auf einem lokalen Plattenbereich zwischengespeichert werden.
Komplexere Workflows können unterschiedliche Formulare zur Bearbeitung durch verschiedene Benutzerrollen umsetzen.

Hinweis: Das SimpleWorkflow-Modul wird zur Zeit nicht mehr weiterentwickelt.

## Kommandozeilen-Befehle

Neben der Weboberfläche verfügt MyCoRe für administrative Zwecke über eine Benutzerschnittstelle auf
Kommandozeilenbasis. Über diese Schnittstelle können insbesondere große Datenmengen, z. B. Metadaten im
XML-Format, importiert und exportiert werden, oder z. B. Suchindizes nach geänderter Systemkonfiguration neu aufgebaut
werden. Die Schnittstelle unterstützt den Batchimport großer Datenmengen. Eine Vielzahl von Befehlen steht für
Batch-Verarbeitung und zu administrativen Zwecken zur Verfügung. Das **Command Line Interface (CLI)**
steht in zwei Varianten zur Verfügung:

* als separate, kommandozeilenbasierte Anwendung, die auf der Shell-Ebene des Betriebssystems gestartet wird
* als in eine MyCoRe-Webanwendung (WebCLI) integrierte Oberfläche, über die eingeloggte Administratoren direkt Kommandos ausführen können