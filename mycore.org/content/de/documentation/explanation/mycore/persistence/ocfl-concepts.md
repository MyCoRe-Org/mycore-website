---
title: Wie OCFL in MyCoRe eingesetzt wird
description: Rolle von OCFL, Repository-Layouts und Versionierung verstehen.
author: ['Kathleen Neumann', 'Jens Kupferschmidt', 'Robert Stephan', 'Tobias Lenhardt', 'Matthias Eichner']
doc_type: explanation
product: mycore
weight: 50
---

OCFL organisiert Daten in einer transparenten, versionierten Ablage. MyCoRe kann damit Metadaten, Klassifikationen, Nutzerdaten und Derivat-Inhalte sichern.

## Rolle im Speichermodell

Für Objekte und Derivate kann OCFL der primäre Speicher sein. Klassifikationen und Nutzerdaten verbleiben primär in der Datenbank und werden zusätzlich in OCFL gesichert.

## Repository und Layout

Ein Repository bestimmt Speicherort und Zugriffstechnik. Das Layout bestimmt, wie eine MyCoRe-ID auf Verzeichnisse im Repository abgebildet wird.

Das standardisierte Hash-Layout verbessert die Interoperabilität. Das MyCoRe-Layout ist leichter manuell zu navigieren, entspricht aber keinem allgemeinen OCFL-Layout.

## Versionen statt Überschreiben

Änderungen erzeugen neue OCFL-Versionen. Dadurch bleiben frühere Zustände nachvollziehbar, solange eine Löschregel die Historie nicht ausdrücklich verwirft.

## Lokaler und entfernter Speicher

Repositories können auf einem lokalen Dateisystem oder in einem S3-kompatiblen Objektspeicher liegen. Entfernte Dateien können zusätzlich lokal zwischengespeichert werden.

Die vollständigen Provider, Properties, Layouts und Befehle stehen in der [OCFL-Referenz]({{< ref "/documentation/reference/mycore/storage/ocfl" >}}).
