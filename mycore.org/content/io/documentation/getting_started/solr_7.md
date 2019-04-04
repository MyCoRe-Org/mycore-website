---

date: "2018-08-08"
description: Suche in MyCoRe mit Apache Solr
title: Suche in MyCoRe mit Apache Solr
author: ['Kathleen Neumann', 'Jens Kupferschmidt', 'Robert Stephan']

---

Die MyCoRe-Anwendungen benötigen eine leistungsstarke Suchmaschine für vielfältige Suchoperationen. Die Grundinstallation wird auf dieser Seite beschrieben. Hinsichtlich der konkreten MyCoRe-Anwendung gibt es weiterführenden Hinweise im Kapitel Suche. 

## Einrichtung eines Solr-Servers

Mit dem Release 2018.06 wurde in MyCoRe von Solr 4.10 (siehe [Archiv]({{< ref "/documentation/archiv/version2017/solr_4.md" >}})) auf Solr 7 umgestellt. Um Solr zu installieren, folge man der Anleitung ["Installing Solr"](https://lucene.apache.org/solr/guide/7_4/installing-solr.html) von der Solr Homepage.

Die richtige Solr Version kann [hier](http://archive.apache.org/dist/lucene/solr/7.4.0/) heruntergeladen werden.

Es ist sinnvoll, wenn man das Datenverzeichnis mit den eigenen Cores nicht innerhalb der Solr-Distribution anlegt. Das gilt auch für die Log-Dateien. 

Mit folgendem Kommando lässt sich der Solr-Server 'individualisiert' starten:

<code>cd .../solr-7.4.0/bin ; solr start -s {my_data_dir} -p {my_port} -m {my_ram} -Dsolr.log.dir={my_log_dir}</code>

Die Cores werden dabei nach <code>{my_data_dir}</code> gelegt, Log-Dateien nach <code>{my_log_dir}</code>. Beide Verzeichnisse müssen vorher angelegt werden. Eine detailierte Beschreibung der Startparameter und weitere Konfigurationsmöglichkeiten liefert die Seite ["Solr Control Script Reference"](https://lucene.apache.org/solr/guide/7_4/solr-control-script-reference.html).

 Für den produktiven Einsatz von Solr (Verzeichnisstruktur, <code>init.d</code> Skript für den automatischen Start, ...) liefert die Seite ["Taking Solr to Production"](https://lucene.apache.org/solr/guide/7_4/taking-solr-to-production.html). die notwendigen Informationen.
 
Hinweis: Die mit Version 7 mitgelieferten TIKA-Bibliotheken führen bei Volltextindizierung zu enormen Performanceproblemen und Instabilitäten. Um das zu vermeiden müssen die Bibliotheken unter <code>solr-7.*/contrib/extraction/lib/tika-*.jar</code> gegen die Bibliotheken der Version 1.16 ausgetauscht werden. Diese können hier heruntergeladen werden:

* [tika-core-1.16.jar](http://central.maven.org/maven2/org/apache/tika/tika-core/1.16/tika-core-1.16.jar)
* [tika-java7-1.16.jar](http://central.maven.org/maven2/org/apache/tika/tika-java7/1.16/tika-java7-1.16.jar)
* [tika-parsers-1.16.jar](http://central.maven.org/maven2/org/apache/tika/tika-parsers/1.16/tika-parsers-1.16.jar)
* [tika-xmp-1.16.jar](http://central.maven.org/maven2/org/apache/tika/tika-xmp/1.16/tika-xmp-1.16.jar)

## Konfiguration

Damit ist die Solr-Installation abgeschlossen. Für jede MyCoRe-Anwendung müssen jetzt eine oder mehrere Solr-Cores angelegt werden. Die Konfiguration der Cores wird im Abschnitt Solr-Nutzung beschrieben. 

## Migration von Solr 4

Einige Dinge haben sich zwischen Version 4 und 7 geändert. Diese sollen in loser Reihenfolge hier aufgelistet werden. 

* Die <code>solr.xml</code> hat sich völlig verändert und sollte von einem Solr 7-Beispiel übernommen werden.
* Die Schemadaten stehen nicht mehr in <code>schema.xml</code> sondern in der Datei <code>managed-schema</code>.
* Einige Typbezeichnungen und Filterklassen gibt es nicht mehr, hier muss einen händische anpassung entsprechend der Dokumentation erfolgen.
* Das Standardformat der Rückgabe einer Anfrage ist jetzt **json** und nicht mehr **xml**. 