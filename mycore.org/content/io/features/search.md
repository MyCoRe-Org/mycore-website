---

description: beschreibung der wichtigsten MyCoRe Funktionen.
title: Suche in Metadaten und Volltext

---

## Suchfunktionen

MyCoRe unterstützt die kombinierte Suche in den Metadaten von Objekten (Titel, Autor etc.),
in den Metadaten von Dateien (Änderungsdatum, Dateigröße etc.) und in den Volltexten von Dateien.
Eine MyCoRe-Anwendung sucht dabei nicht direkt in den Daten von Objekten und Dateien, sondern in daraus abgeleiteten
Suchfeldern. Die Abbildung von Metadaten auf Suchfelder erfolgt über eine Konfigurationsdatei. So wird z. B.
das XML-Element <code>/metadata/titles/title</code> auf ein Suchfeld <code>title</code> abgebildet.

{{< mcr-figure src="/images/io/features/searchfield.png"  title="Auszug aus der Datei searchfields.xml" width="100%" />}}

Dabei können auch komplexe Suchanfragen mit booleschen Ausdrücken (und/oder/nicht), Platzhaltern und Suchoperatoren
gestellt werden. Der Datentyp eines Suchfeldes (ID, Name, Text, Zahl, Datum etc.) bestimmt die bei der Suche
einsetzbaren Operatoren (z.B. Phrasensuche, Trunkierung, &lt;, &gt;, ...).

{{< mcr-figure src="/images/io/features/searchfield.png"  title="Auszug aus der Datei searchfields.xml" width="100%" />}}
{{< mcr-figure src="/images/io/features/mcrql.png"  title="Expertensuche mit der MyCoRe-Anfragesprache" width="100%" />}}
Die Suche in MyCoRe ist auf Basis von
[Apache Lucene](http://lucene.apache.org"Apache Lucene Home")
realisiert. Obwohl auch andere Implementierungen denkbar sind, ist dies
die zur Zeit einzige Implementierung der MyCoRe Suche, die für den Produktionseinsatz sinnvoll ist.
Über Lucene durchlaufen indizierte Texte ggf. verschiedene Normalisierungsschritte wie Stammwortreduktion (Stemming) und
Umlautnormalisierung.

## Suchmasken und Trefferlisten

MyCoRe-Suchmasken sind frei konfigurierbar, von einfachen Ein-Feld-Suchformularen über komplexere, qualifiziertere
Suchmasken bis hin zu frei formulierbaren Experten-Abfragen in der MyCoRe-Query-Language (MCRQL). Suchmasken können
selbst erstellt oder aus einer Konfiguration von Suchfeldern automatisch generiert werden.

{{< mcr-figure src="/images/io/features/searchmask.png"  title="Beispiel einer Suchmaske" width="100%" />}}

Trefferlisten sind auf- oder absteigend nach mehreren Feldern beliebig sortierbar. Die ursprüngliche Suche kann angezeigt
("Sie haben gesucht nach: ...") oder noch einmal verfeinert werden (Rückkehr zum Suchformular mit Anpassung der
Suchparameter).

Auch eine verteilte Suche über mehrere Server ist möglich und intern über Webservices-Schnittstellen
realisiert. Auf diesem Wege können auch Legacy-Systeme mittels einer eigenen Implementierung dieser Schnittstellen auf
Java-Basis integriert werden.

## Datei-Inhalte durchsuchen

Für die Volltextsuche wird der Inhalt von Textdateien über konfigurierbare Filter extrahiert. Derzeit sind Implementierungen
für HTML, XML, TXT, OpenOffice Formate und PDF-Dateien enthalten.

MyCoRe kann aus bestimmten Dateitypen zusätzliche Metadaten extrahieren und diese ebenfalls durchsuchbar machen. Derzeit
sind Implementierungen für die Extraktion bzw. Suche in EXIF-Metadaten von JPEG-Grafiken (Aufnahmedatum etc.),
in ID3-Metadaten von MP3-Audiodateien (Titel, Interpret, Länge etc.)
und in Metadaten von PDF-Dokumenten (Seitenzahl, Autor etc.) verfügbar.

MyCoRe kann als Content gespeicherte XML-Dateien qualifiziert durchsuchen. Bei entsprechender Konfiguration könnten z. B.
die XML-Strukturen einer <code>manifest.xml</code>-Datei eines SCORM-Lernpaketes, oder METS-Metadaten eines Digitalisates durchsucht werden.