---
title: Wie MyCoRe Solr integriert
description: Index-Registry, Indizes und Konfiguration im Zusammenhang verstehen.
author: ['Jens Kupferschmidt', 'Kathleen Neumann', 'Robert Stephan', 'Sebastian Hofmann']
doc_type: explanation
product: mycore
weight: 40
---

MyCoRe kapselt Solr-Indizes in einer Index-Registry. Eine Anwendung kann dadurch mehrere Indizes einheitlich konfigurieren und entweder Standalone Solr oder SolrCloud verwenden.

## Index-Registry

Die Registry liest MyCoRe-Properties und erzeugt daraus benannte Index-Instanzen. Jede Instanz kennt ihren Client, ihre Collection oder ihren Core und ihre Authentifizierung.

## Haupt- und Klassifikationsindex

Der Hauptindex enthält Dokumente für Metadaten und Volltext. Ein optionaler Klassifikationsindex unterstützt die Suche in Klassifikationen.

## Erweiterbare ConfigSets

Kernmodul und Anwendung liefern Konfigurationsfragmente. MyCoRe führt Schema und Solr-Konfiguration zu einem anwendungsspezifischen ConfigSet zusammen.

Einrichtungsschritte stehen unter [Solr konfigurieren]({{< ref "/documentation/how-to-guides/mycore/setup/configure-solr" >}}). Properties, Befehle und Java-API stehen in der [Solr-Referenz]({{< ref "/documentation/reference/mycore/search/solr-integration" >}}).
