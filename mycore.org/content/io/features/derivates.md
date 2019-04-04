---

description: beschreibung der wichtigsten MyCoRe Funktionen.
title: Dateiverwaltung, Digitalisate und Video Streaming

---

## Dateibereiche

Einem MyCoRe-Metadaten-Objekt wie z. B. einer Publikation sind in der Regel auch Dateien zugeordnet,
z. B. der Volltext der Publikation. MyCoRe speichert diese Dateien in einer eigenen, internen Struktur, dem
internen Dateisystem (IFS).

Hierzu sind einem MyCoRe-Objekt ein oder mehrere Dateibereiche zugeordnet, intern "Derivate" genannt.
Derivate sind Bündel von zusammengehörigen Dateien, die auch eine interne Verzeichnisstruktur besitzen dürfen.
So können z.B. Varianten eines Dokumentes in PDF- und HTML-Form existieren, die jeweils ein Derivat mit
ein oder mehreren Dateien bilden.

## „Content Stores“

Neben den Datei-Inhalten werden auch weitere beschreibende Daten zu Dateien verwaltet,
insbesondere eine MD5 Prüfsumme zur Konsistenzprüfung. Als physisches Speichermedium dient ein separater Bereich
im lokalen Dateisystem, auf den der Browser des Anwenders nur indirekt über Java Servlets zugreift.
So kann die Anwendung sicherstellen, dass Zugriffsberechtigungen nicht umgangen werden. Neben dem **lokalen Dateisystem**
unterstützt MyCoRe über das [Apache Commons Virtual Fileystems](http://commons.apache.org/proper/commons-vfs/filesystems.html)
auch direkt die Speicherung auf entfernten Dateisystemen via <strong>FTP, SFTP oder CIFS</strong>.

MyCoRe kann mehrere solcher Speicherorte für Dateien (Content Stores) parallel verwenden.
Anhand von Regeln wird für die importierte Datei ein entsprechender Content Store gewählt.
So können etwa Audio-/Videodateien anhand ihrer Dateiendung automatisch beim Upload auf
einem Video-Streaming-Server abgelegt werden.

## Import und Export von Dateien

Import und Export von Dateien und Dateibereichen ist sowohl über die
MyCoRe-Kommandozeile (Command Line Interface) für Batch-Verarbeitung,
als auch über die Web-Schnittstelle möglich.
Einfache Dateien laden Autoren direkt über ein HTML-Formular hoch.
Für den Upload großer Dateien mit bis zu mehreren Gigabyte oder ganzer Verzeichnisbäume
steht ein Java Applet zur Verfügung. Die so importierte Verzeichnisstruktur bleibt im internen Derivat erhalten,
so dass auch umfangreiche HTML-Bäume archiviert und dargestellt werden können.

Über ein Servlet werden Dateien und Verzeichnisse im Browser angezeigt und ausgeliefert.
Dabei ist auch die dynamische Generierung einer ZIP-Datei möglich.

## Image Viewer

Das MyCoRe Image Viewer Modul realisiert einen Bildbetrachter für
hochauflösende Digitalisate oder große Grafikdateien (z. B. Landkarten).
Formate wie hochauflösende TIFF Dateien werden direkt in MyCoRe importiert und
serverseitig automatisch in verschiedenen Zoom-Stufen gekachelt.
Der in JavaScript implementierte, integrierte Image Viewer zeigt die Grafik dann in jedem aktuellen Browser an.
Der Image Viewer erlaubt das Skalieren von Bildern (Zoomen) und das Blättern durch die Bilder eines Dateibereichs.
Über ein Thumbnail kann in großen Bildern navigiert werden.

{{< mcr-figure src="/images/io/features/imageviewer.png"  title="Anzeige verschiedener Bildformate im Bildbetrachter" width="100%" />}}

## METS-Editor

MyCoRe unterstützt den **Metadata Encoding and Transmission Standard (METS)** zur Strukturierung
von Digitalisaten in Dateibereichen. Über den integrierten METS-Editor können die Dateien eines Digitalisats
in eine logische Struktur gebracht und paginiert werden. Die METS-Datei wird auch vom Image Viewer verwendet,
um durch ein Digitalisat zu blättern und ein Inhaltsverzeichnis anzuzeigen.

Das über MyCoRe erstellte METS Dokument ist auch kompatibel zum DFG-Viewer, über den Digitalisate
so alternativ dargestellt werden können.

## Audio-/Video-Streaming

MyCoRe kann transparent einen Audio-/Video-Streaming-Server als Ablageort für Dateien integrieren.
Der Nutzer importiert eine Datei bzw. lädt sie über den Webbrowser hoch.
Anhand der Dateiendung und hinterlegter Regeln wählt MyCoRe dann
automatisch den Streamingserver als Speicherort. Die Audio-/Videodatei kann dann über den
Streaming-Server wiedergegeben  werden, ohne dass ein Download erforderlich ist.
Der Nutzer kann frei im Videostrom navigieren oder direkt über die URL
bestimmte Stellen ansteuern. In der Weboberfläche können aus dem
Streaming-Server gewonnene technische Metadaten wie Bitrate, Framerate und Abspieldauer angezeigt werden.

{{< mcr-figure src="/images/io/features/videostreaming.png"  title="Anzeige multimedialer Daten" width="100%" />}}

Unterstützt wird zur Zeit der
[Helix Universal Server (Real)](https://helix-server.helixcommunity.org/"Helix Community")
zum Streaming von Real Audio/Video, Windows Media, Flash, MPEG 4, MP3, AVI, Quicktime und anderen Formaten.