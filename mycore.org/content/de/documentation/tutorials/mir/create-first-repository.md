---
title: Ein erstes MIR-Repository einrichten
description: Installieren und starten Sie ein lokales MIR-Repository.
author: ['Kathleen Neumann', 'Jens Kupferschmidt']
doc_type: tutorial
product: mir
weight: 10
---

In diesem Tutorial richten Sie eine einfache lokale MIR-Instanz ein. Der MIR-Wizard führt durch die Grundkonfiguration.

## Lernziel

Am Ende erreichen Sie MIR unter `http://localhost:8080/mir/` und können sich an der initialisierten Anwendung anmelden.

## Voraussetzungen

Prüfen Sie die [MyCoRe-Systemanforderungen]({{< ref "/documentation/reference/mycore/system-requirements" >}}). Für MIR benötigen Sie außerdem `bibutils`, einen Servlet-Container und Solr.

Die vollständigen Varianten und Produktionshinweise stehen in der [MIR-Installationsanleitung]({{< ref "/documentation/how-to-guides/mir/installation/install-mir" >}}).

## 1. MIR bereitstellen

Laden Sie das MIR-Webarchiv und speichern Sie es als `mir.war`. Legen Sie die Datei im `webapps`-Verzeichnis Ihres Servlet-Containers ab.

Starten Sie den Container. Er entpackt das Archiv und stellt MIR unter dem Kontext `/mir` bereit.

## 2. Wizard öffnen

Öffnen Sie `http://localhost:8080/mir/`. Beim ersten Aufruf zeigt MIR den Installations-Wizard.

Suchen Sie im Log des Servlet-Containers nach `Login token`. Kopieren Sie das vollständige Token in die Sicherheitsabfrage des Wizards.

## 3. Lernumgebung konfigurieren

Tragen Sie die Adressen der vorbereiteten Solr-Kerne ein. Wählen Sie für dieses Tutorial H2 oder HSQLDB als lokale Datenbank.

Die SMTP-Konfiguration ist für den ersten lokalen Start optional. Ohne SMTP stehen Funktionen wie die Bestätigung einer Selbstregistrierung nicht vollständig zur Verfügung.

Speichern Sie die Konfiguration. Der Wizard erzeugt Konfigurationsdateien und lädt die vorbereiteten Klassifikationen, Benutzer und Rechte.

## 4. MIR neu starten

Starten Sie MIR oder den Servlet-Container neu. Erst danach liest die Anwendung die erzeugte Konfiguration vollständig ein.

Öffnen Sie erneut `http://localhost:8080/mir/`. Melden Sie sich mit den in der Installationsausgabe genannten initialen Zugangsdaten an.

## Was Sie gelernt haben

MIR ist eine vorkonfigurierte MyCoRe-Anwendung. Das Webarchiv liefert die Anwendung, der Wizard erzeugt die lokale Konfiguration, und Solr sowie die Datenbank stellen Suche und Persistenz bereit.

## Nächste Schritte

Nutzen Sie die [MIR-Anleitungen]({{< ref "/documentation/how-to-guides/mir" >}}), um die Installation zu individualisieren oder für den produktiven Betrieb vorzubereiten.
