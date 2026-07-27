---
title: Eine erste MyCoRe-Anwendung erstellen
description: Erzeugen, initialisieren und starten Sie eine lokale Beispielanwendung.
author: ['Robert Stephan', 'Kathleen Neumann']
doc_type: tutorial
product: mycore
weight: 10
---

In diesem Tutorial erzeugen Sie mit dem Maven-Archetype eine Anwendung namens `skeleton`. Sie bauen die Anwendung, initialisieren ihre Daten und starten sie lokal.

## Lernziel

Am Ende erreichen Sie die Anwendung unter `http://localhost:8080/skeleton`. Dabei lernen Sie das Zusammenspiel von Maven-Projekt, CLI, Konfiguration, Datenbank, Solr und Webanwendung kennen.

## Voraussetzungen

Richten Sie zuerst die [Systemanforderungen]({{< ref "/documentation/reference/mycore/system-requirements" >}}) ein. Verwenden Sie für dieses Tutorial H2, den Solr-Runner und Jetty.

Legen Sie ein leeres Arbeitsverzeichnis für die Anwendung an und öffnen Sie dort ein Terminal.

## 1. Archetype bereitstellen

Laden Sie den vorhandenen Skeleton-Archetype in Ihr lokales Maven-Repository und aktualisieren Sie den lokalen Archetype-Katalog.

```shell
mvn dependency:get -Dartifact="org.mycore.skeleton:mycore-skeleton-archetype:2022.06-SNAPSHOT" -DremoteRepositories=https://oss.sonatype.org/content/repositories/snapshots
mvn archetype:crawl
```

## 2. Anwendung erzeugen

Starten Sie den Generator.

```shell
mvn archetype:generate -Dfilter=mycore-skeleton-archetype
```

Wählen Sie den MyCoRe-Skeleton-Archetype. Verwenden Sie `skeleton` als `artifactId`, `skeleton_main` als Hauptindex und `skeleton_class` als Klassifikationsindex.

Bestätigen Sie die übrigen Beispielwerte oder passen Sie Organisation und Projekttitel an Ihre Lernumgebung an.

## 3. Projekt bauen

Wechseln Sie in das erzeugte Projekt und bauen Sie alle Module.

```shell
mvn clean install
```

Der Build erzeugt unter anderem die CLI und das Webarchiv. Die drei Module trennen Kommandozeile und Konfiguration, Anwendungslogik sowie Webanwendung.

## 4. Konfiguration erzeugen

Starten Sie im CLI-Modul den passenden Befehl für Ihr Betriebssystem.

```text
bin/skeleton.sh create configuration directory
```

Unter Windows verwenden Sie:

```text
bin\skeleton.bat create configuration directory
```

Die Konfiguration liegt danach unter `~/.mycore/skeleton` oder im entsprechenden lokalen MyCoRe-Verzeichnis unter Windows.

## 5. Solr für die Lernumgebung starten

Wechseln Sie in das Webapp-Modul. Installieren Sie die beiden ConfigSets mit dem Solr-Runner und starten Sie Solr.

```shell
mvn solr-runner:copyHome
mvn solr-runner:installConfigSet@cs_main
mvn solr-runner:installConfigSet@cs_classification
mvn solr-runner:start
```

Solr ist anschließend unter `http://localhost:8983/solr/` erreichbar.

## 6. Datenbank und Ausgangsdaten initialisieren

H2 benötigt für diese Lernumgebung keine zusätzliche Datenbankkonfiguration. Laden Sie zuerst die JPA-Mappings neu.

```text
bin/skeleton.sh reload mappings in jpa configuration file
```

Unter Windows verwenden Sie wieder die Datei `bin\skeleton.bat`.

Laden Sie danach die vorbereiteten Klassifikationen, Benutzer und Rechte.

```text
bin/skeleton.sh process config/setup-commands.txt
```

## 7. Anwendung starten

Starten Sie im Webapp-Modul den eingebetteten Jetty-Server.

```shell
mvn jetty:run
```

Öffnen Sie `http://localhost:8080/skeleton`. Sie haben nun eine lokale MyCoRe-Anwendung erzeugt, konfiguriert und initialisiert.

## Was Sie gelernt haben

Der Archetype erzeugt die Projektstruktur. Die CLI verwaltet Konfiguration und Daten. Solr übernimmt die Suche, während das Webapp-Modul die Anwendung für einen Servlet-Container bereitstellt.

## Nächste Schritte

Nutzen Sie die [Anleitungen zur Einrichtung]({{< ref "/documentation/how-to-guides/mycore/setup" >}}), wenn Sie Datenbank, Solr oder Deployment für eine eigene Umgebung anpassen möchten.
