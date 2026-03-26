---
title: "Migration MyCoRe LTS 2025.12 nach 2026.06"
mcr_version: ['2026.06']
author: []
description: "
Diese Seite fasst Systemanforderungen für die Nutzung des MyCoRe LTS 2026.06 und die Migration von Version
2025.12 zu 2026.06 zusammen."
date: "2000-01-01"
---
{{< mcr-comment >}} Publish this page by setting the date and removing icon and property 'pre' from menus.de.yaml {{< /mcr-comment >}}

<div class="alert alert-warning">
    Diese Seite ist <strong>Work in Progress</strong>. <br />
    Sie wird im Rahmen der Fertigstellung des aktuellen MyCoRe-Releases weiter ergänzt!
</div>

## Systemanforderungen MyCoRe LTS 2026.06 [TODO: UPDATE]

Für den Betrieb einer MyCoRe-Anwendung unter LTS 2026.06 sind folgende Voraussetzungen zu erfüllen:


### Betriebssystem

MyCoRe LTS 2026.06 ist auf diesen Betriebssystemen im Einsatz. Höhere Versionen sollten kein Problem darstellen.
- Open SuSE Leap 15.6 oder höher
- SuSE SLES 15.6 oder höher
- Ubuntu 24.04 LTS
- CentOS 8
- RHEL 8
- Windows 11 für Test- und Entwicklungssysteme

### Standardsoftware

Zur Arbeit mit MyCoRe LTS 2026.06 sind folgende Softwarekomponenten erforderlich bzw. empfohlen.
Diese sind alle von Drittanbietern und im Normalfall in den Distributionen enthalten.

- Java 21 (OpenJDK) (muss ggf. extern nachinstalliert werden)
- Tomcat 10.1.x bzw. Jetty 11.x (alternativ ein System mit Unterstützung von Servlet-6.0 und JakartaEE)
- SOLR 9.8.1 oder höher
- eine <a href="https://docs.jboss.org/hibernate/orm/6.5/javadocs/org/hibernate/dialect/package-summary.html">hibernate-fähige</a>
  relationale Datenbank wie PostgreSQL 16 oder höher, MySQL/Maria-DB 10 oder höher, DB2; für Testzwecke genügt auch die integrierte Datenbank H2
- Git 2.26 oder höher
- Apache Maven 3.6.3 oder höher

## Neuerungen, die eine Migration erforderlich machen
### Überarbeitung der Solr-Integration (MCR-3645)

Die Solr-Integration wurde grundlegend refaktoriert. Das bisherige Konzept mit
`MCRSolrCore` und `MCRSolrCoreManager` wurde durch ein neues,
klassenbasiertes **Index-Registry**-Konzept ersetzt.
Dabei wurden sowohl die Property-Namen als auch die Java-API geändert.
Die bisherigen Properties werden als deprecated erkannt und führen zu einer Warnung im Log,
bleiben aber zunächst noch funktionsfähig.

- Die Konfiguration der Solr-Kerne erfolgt nun über `MCR.Solr.IndexRegistry.Index.{id}.*` statt `MCR.Solr.Core.{id}.*`.
- Der Verbindungstyp (Standalone / SolrCloud) wird über eine `Class`-Property explizit festgelegt.
- Client-Timeouts und Parallelisierungs-Properties wurden unter `MCR.Solr.Default.*` zusammengefasst.
- Die Java-Klassen `MCRSolrClientFactory` und `MCRSolrCoreManager` sind deprecated und werden mit dem nächsten Release entfernt.

### Verhaltensänderung von `MCRCronjob`

Bisher wurden in MyCoRe konfigurierte Cronjobs bei einer Exception im Job nicht mehr gemäß des CRON-Zeitplans neu geplant.
Ab dieser Version führt ein Fehler im Job nicht mehr zum vollständigen Abbruch des Zeitplans.
Ein Retry-Mechanismus für die erneute Ausführung des aktuellen Joblaufs ist weiterhin nicht vorgesehen.

### `MCRAccessKeyServiceFactory` ist deprecated

Mit <a href="https://mycore.atlassian.net/browse/MCR-3581">MCR-3581</a> wurde die gesamte Factory-Klasse
`MCRAccessKeyServiceFactory` als `@Deprecated(forRemoval = true)` markiert.

Alle bisherigen Factory-Methoden sollten ersetzt werden:

- **ALT:** `MCRAccessKeyService aks = MCRAccessKeyServiceFactory.getAccessKeyService();`
- **NEU:** `MCRAccessKeyService aks = MCRAccessKeyService.obtainInstance();

Weitere Factory-Methoden wurden analog verschoben:

- **ALT:** `MCRAccessKeyServiceFactory.getAccessKeySessionService()`
- **NEU:** `MCRAccessKeySessionService.obtainInstance()`

<!-- separate adjacent lists -->

- **ALT:** `MCRAccessKeyServiceFactory.getAccessKeyPermissionService()`
- **NEU:** `MCRAccessKeyPermissionService.obtainInstance()`

### `MCRCategoryID`: Umbenennung der Methode `isRootID()` zu `isRoot()`

Wegen eines Konfliktes bei der Benennung der beiden Methoden `isRootID()` und `getRootID()` im Zusammenhang mit der
Verwendung der Klasse als JavaBean wurde die Methode `isRootID()` zu **`isRoot()`** umbenannt
(siehe <a href="https://mycore.atlassian.net/browse/MCR-3637">Ticket MCR-3637</a>).
    
## Migrationsschritte

### Solr-Konfiguration migrieren (MCR-3645)

#### Property-Umbenennung

Die folgende Tabelle zeigt die alten Properties und ihre neuen Entsprechungen.
Ob `CoreName` oder `CollectionName` zu verwenden ist, hängt vom
Betriebsmodus ab (Standalone vs. SolrCloud). Ebenso ob `SolrUrl` (Standalone),
`SolrUrls` (SolrCloud URL-Modus) oder `ZkUrls` (SolrCloud ZooKeeper-Modus)
gesetzt werden muss.

<div class="table-responsive">
    <table class="table table-sm table-bordered">
        <thead class="thead-light">
        <tr>
            <th>Altes Property (bis 2025.12)</th>
            <th>Neues Property (ab 2026.06)</th>
        </tr>
        </thead>
        <tbody>
        <tr>
            <td><code>MCR.Solr.ServerURL</code></td>
            <td><code>MCR.Solr.IndexRegistry.Index.main.SolrUrl</code> (Standalone)<br>
                <code>MCR.Solr.IndexRegistry.Index.main.SolrUrls</code> (Cloud URL)<br>
                <em>und analog für <code>classification</code></em></td>
        </tr>
        <tr>
            <td><code>MCR.Solr.Core.main.Name</code></td>
            <td><code>MCR.Solr.IndexRegistry.Index.main.CoreName</code> (Standalone)<br>
                <code>MCR.Solr.IndexRegistry.Index.main.CollectionName</code> (SolrCloud)</td>
        </tr>
        <tr>
            <td><code>MCR.Solr.Core.main.ServerURL</code></td>
            <td><code>MCR.Solr.IndexRegistry.Index.main.SolrUrl</code> oder <code>.SolrUrls</code></td>
        </tr>
        <tr>
            <td><code>MCR.Solr.Core.main.ConfigSetTemplate</code></td>
            <td><code>MCR.Solr.IndexRegistry.Index.main.ConfigSetTemplate</code></td>
        </tr>
        <tr>
            <td><code>MCR.Solr.Core.main.Type</code></td>
            <td><code>MCR.Solr.IndexRegistry.Index.main.IndexTypes</code></td>
        </tr>
        <tr>
            <td><code>MCR.Solr.Core.classification.*</code></td>
            <td><code>MCR.Solr.IndexRegistry.Index.classification.*</code> (analog zu <code>main</code>)</td>
        </tr>
        <tr>
            <td><code>MCR.Solr.SolrClient.ConnectionTimeout</code></td>
            <td><code>MCR.Solr.Default.Client.ConnectionTimeout</code></td>
        </tr>
        <tr>
            <td><code>MCR.Solr.SolrClient.SocketTimeout</code></td>
            <td><code>MCR.Solr.Default.Client.RequestTimeout</code> und <code>MCR.Solr.Default.Client.IdleTimeout</code></td>
        </tr>
        <tr>
            <td><code>MCR.Solr.SolrClient.JettyHttpClient.Enabled</code></td>
            <td><code>MCR.Solr.Default.UseJettyHttpClient</code></td>
        </tr>
        <tr>
            <td><code>MCR.Solr.ConcurrentUpdateSolrClient.Enabled</code></td>
            <td><code>MCR.Solr.Default.ConcurrentClient.Enabled</code></td>
        </tr>
        <tr>
            <td><code>MCR.Solr.ConcurrentUpdateSolrClient.QueueSize</code></td>
            <td><code>MCR.Solr.Default.ConcurrentClient.QueueSize</code></td>
        </tr>
        <tr>
            <td><code>MCR.Solr.ConcurrentUpdateSolrClient.ThreadCount</code></td>
            <td><code>MCR.Solr.Default.ConcurrentClient.ThreadCount</code></td>
        </tr>
        </tbody>
    </table>
</div>

#### Pflicht-Property: `Class`

Neu ist das Property `MCR.Solr.IndexRegistry.Index.{id}.Class`, das den
Verbindungstyp explizit festlegt. Es muss für jeden konfigurierten Index gesetzt werden:

```properties
# Standalone Solr
MCR.Solr.IndexRegistry.Index.main.Class=org.mycore.solr.standalone.core.MCRConfigurableSolrCore

# SolrCloud (URL-basiert oder ZooKeeper)
MCR.Solr.IndexRegistry.Index.main.Class=org.mycore.solr.cloud.collection.MCRConfigurableSolrCloudCollection
```

#### Minimales Migrationsbeispiel

Eine typische Standalone-Konfiguration sah bisher so aus:

```properties
# ALT (bis 2025.12)
MCR.Solr.ServerURL=http://localhost:8983/
MCR.Solr.Core.main.Name=mycore
MCR.Solr.Core.classification.Name=mycore-classifications
```

Die neue Konfiguration lautet:

```properties
# NEU (ab 2026.06)
MCR.Solr.IndexRegistry.Index.main.Class=org.mycore.solr.standalone.core.MCRConfigurableSolrCore
MCR.Solr.IndexRegistry.Index.main.SolrUrl=http://localhost:8983/solr
MCR.Solr.IndexRegistry.Index.main.CoreName=mycore

MCR.Solr.IndexRegistry.Index.classification.Class=org.mycore.solr.standalone.core.MCRConfigurableSolrCore
MCR.Solr.IndexRegistry.Index.classification.SolrUrl=http://localhost:8983/solr
MCR.Solr.IndexRegistry.Index.classification.CoreName=mycore-classifications
```

Den Konfigurationsassistenten zum Erzeugen der Properties für alle Verbindungstypen findet
man in der [Solr-Dokumentation]({{< ref search_solr_use >}}).
    </p>

#### Java API: `MCRSolrClientFactory` und `MCRSolrCoreManager`

Die Klassen `MCRSolrClientFactory` und `MCRSolrCoreManager` sind
deprecated. Der Zugriff auf Solr-Clients erfolgt nun über die Index-Registry:

```java
// ALT (bis 2025.12)
SolrClient client = MCRSolrClientFactory.getMainSolrClient();
// oder:
SolrClient client = MCRSolrCoreManager.get("main").get().getClient();

// NEU (ab 2026.06)
SolrClient client = MCRSolrIndexRegistryManager.obtainRegistry()
    .getIndex("main")
    .orElseThrow()
    .getClient();
```

#### Java API: `MCRSolrAuthenticationManager`

Die Methode `MCRSolrAuthenticationManager.getInstance()` wurde in
`MCRSolrAuthenticationManager.obtainInstance()` umbenannt.

```java
// ALT
MCRSolrAuthenticationManager.getInstance().applyAuthentication(request, level);

// NEU
MCRSolrAuthenticationManager.obtainInstance().applyAuthentication(request, level);
```

### Umwandlung von `MCRXMLMetadataManager` in ein Interface


Bisher war `MCRXMLMetadataManager` eine finale Klasse. Die konkrete Implementierung konnte ausgetauscht werden,
indem per `MCR.Metadata.Manager` eine Instanz von `MCRXMLMetadataManagerAdapter` angegeben wurde.
Damit war `MCRXMLMetadataManager` die einzige Stelle in MyCoRe, die dieses Adapter-Pattern verwendet hat.
Zur Harmonisierung wurde daher `MCRXMLMetadataManager` in ein Interface umgewandelt.

Die bestehenden Implementierungen implementieren nun direkt `MCRXMLMetadataManager` und nicht mehr
`MCRXMLMetadataManagerAdapter`. Sie wurden daher wie folgt umbeannnt:

- `MCRDefaultXMLMetadataManagerAdapter` ⮕ `MCRDefaultXMLMetadataManager`
- `MCRGZIPOCFLXMLMetadataManagerAdapter` ⮕ `MCRGZIPOCFLXMLMetadataManager`
- `MCROCFLXMLMetadataManagerAdapter` ⮕ `MCROCFLXMLMetadataManager`

Es wurde jeweils eine weitere Klasse mit dem alten Namen hinzugefügt und als `@Deprecated` markiert.
Im Kommentar zur Klasse wird jeweils auf die nun zu verwendende Klasse hingewiesen. Eigener Code bleibt daher noch
funktionsfähig, muss aber vor der Verwendung des nächsten MyCoRe-Releases umgestellt werden.

Um den PMD-Regeln für Singeltons gerecht zu werden wurde zudem die Methode `MCRXMLMetadataManager#getInstance`
in `MCRXMLMetadataManager#obtainInstance` umbenannt und die alte Methode ebenfalls als `@Deprecated`
markiert. Auch sie wird mit dem nächsten Release entfernt.

