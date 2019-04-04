---

title: "MyCoRe Dokumentation: Umgebung einrichten"
description: "An dieser Stelle wird beschrieben, wie die Entwicklungsumgebung und Tools für die Dokumentation eingerichtet werden."
author: 		['Jens Kupferschmidt', 'Kathleen Neumann', 'Robert Stephan']
date: 			"2019-04-04"
---

## Installation von Hugo
Der Static Site Generator **Hugo** ([https://gohugo.io/](https://gohugo.io)) bildet seit April 2019 die technische Basis für die MyCoRe-Dokumentation.
Die Software ist in Go programmiert und steht für die gängigen Betriebssysteme als Download bereit.

Wir verwenden Hugo in der Extended Edition, vor allem da diese das CSS-Framework [Sass](https://sass-lang.com/) unterstützt. 

Der Download erfolgt direkt von der [Hugo-GitHub-Seite](https://github.com/gohugoio/hugo/releases).  
Windows-Nutzer verwenden **[hugo_extended_0.54.0_Windows-64bit.zip](https://github.com/gohugoio/hugo/releases/download/v0.54.0/hugo_extended_0.54.0_Windows-64bit.zip)**.

Die Zip-Datei enthält das komplette Hugo-Programm, welches aus nur einer Datei besteht. Diese kann an einem beliebigen Ort auf dem PC abgelegt werden (z.B. ```C:\Programme```). 
Anschließend muss der Ordner noch in der Umgebungsvariable ```Path``` bekannt gemacht werden.
Eine detailierte Installationsanleitung findet man in der Hugo Dokumentation [Install Hugo](https://gohugo.io/getting-started/installing/#windows).

## Git Checkout
Die Dokumentation wird in dem MyCoRe-Git-Repository **[MyCoRe-Org/mycore-website](https://github.com/MyCoRe-Org/mycore-website)** gepflegt.  
Commits dürfen ohne Pull-Requests direkt in den ```master```-Branch erfolgen.

<span class="badge badge-info">TODO</span> 
**Git-Einrichtung und Check-Out-Kommando ergänzen.**

## Initialisierung (Maven)
Wir haben uns dafür entschieden, externe CSS- und Javascript-Frameworks (wie Bootstrap) nicht über das Git-Repository auszuliefern. Diese werden via [Maven](https://maven.apache.org) als **[Webjars](https://www.webjars.org/)** heruntergeladen und in den Dokumentations-Source-Code integriert. Deshalb muss zuvor Maven gemäß der Anleitung "[Installing Apache Maven ](https://maven.apache.org/install.html)" eingerichtet werden. 

Werden die Hugo-Dokumentations-Umgebung neu eingerichtet oder die betreffenden Bibliotheken aktualisiert, muss einmalig in dem Ordner, in den das MyCoRe-Dokumentations-Projekt ausgecheckt wurde, das folgende Maven-Kommando aufgerufen werden:

{{< highlight system>}}
cd \workspaces\mycore-website
$ mvn clean compile
{{< / highlight >}}

## Hugo starten und öffnen
Hugo unterstützt die Webseiten-Entwicklung mit einem lokalen Server mit Live-Reload. Das bedeutet, das Änderungen am Quellcode direkt im Browser betrachtet werden können

{{< highlight system>}}
cd \workspaces\mycore-website\mycore.org
$ hugo server
{{< / highlight >}}

Die MyCoRe-Dokumentation kann nun lokal unter folgender Adresse betrachtet werden:   
**http://localhost:1313/**
