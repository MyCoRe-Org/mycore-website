---
title: OCFL konfigurieren
description: OCFL-Modul, Repository und Metadatenspeicher aktivieren.
author: ['Kathleen Neumann', 'Jens Kupferschmidt', 'Robert Stephan', 'Tobias Lenhardt', 'Matthias Eichner']
doc_type: how-to
product: mycore
weight: 10
---

Diese Anleitung zeigt den Weg zu einer OCFL-Ablage. Die genauen Provider und Properties finden Sie in der [OCFL-Referenz]({{< ref "/documentation/reference/mycore/storage/ocfl" >}}).

## Modul einbinden

Fügen Sie Ihrer Anwendung das Modul `mycore-ocfl` hinzu. Für ein S3-kompatibles Backend benötigen Sie zusätzlich `mycore-ocfl-s3`.

## Repository wählen

Definieren Sie einen Repository-Namen, einen passenden Provider sowie Arbeits- und Zielverzeichnis. Verwenden Sie für S3 die in der Referenz aufgeführten S3-Properties.

## Datentyp aktivieren

Wählen Sie, ob OCFL XML-Metadaten, Klassifikationen, Nutzerdaten oder Derivat-Inhalte verwalten soll. Übernehmen Sie nur die Properties des benötigten Datentyps.

## Bestehende Daten migrieren

Führen Sie die passenden OCFL-Migrationsbefehle zunächst in einer gesicherten Testumgebung aus. Prüfen Sie danach Repository und Anwendung, bevor Sie die Änderung produktiv übernehmen.

## Ergebnis prüfen

Ändern Sie ein Testobjekt und kontrollieren Sie, ob eine neue OCFL-Version entsteht. Bearbeiten oder löschen Sie Dateien im Repository nicht direkt.
