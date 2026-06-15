---
title: "Migration MyCoRe LTS 2026.06 nach 2026.12"
mcr_version: ['2026.12']
author: []
description: "Diese Seite fasst Systemanforderungen für die Nutzung des MyCoRe LTS 2026.12 und die Migration von Version
2026.06 zu 2026.12 zusammen."
date: "2000-01-01"
---

{{< mcr-comment >}} Publish this page by setting the date and removing icon and property 'pre' from menus.de.yaml {{< /mcr-comment >}}
<div class="alert alert-warning">
    Diese Seite ist <strong>Work in Progress</strong>. <br />
    Sie wird im Rahmen der Fertigstellung des aktuellen MyCoRe-Releases weiter ergänzt!
</div>

## Systemanforderungen MyCoRe LTS 2026.12 [TODO: UPDATE]

Für den Betrieb einer MyCoRe-Anwendung unter LTS 2026.12 sind folgende Voraussetzungen zu erfüllen:

### Betriebssystem

MyCoRe LTS 2026.12 ist auf diesen Betriebssystemen im Einsatz. Höhere Versionen sollten kein Problem darstellen.

- Open SuSE Leap 15.6 oder höher
- SuSE SLES 15.6 oder höher
- Ubuntu 24.04 LTS
- CentOS 8
- RHEL 8
- Windows 11 für Test- und Entwicklungssysteme

### Standardsoftware

Zur Arbeit mit MyCoRe LTS 2026.12 sind folgende Softwarekomponenten erforderlich bzw. empfohlen.
Diese sind alle von Drittanbietern und im Normalfall in den Distributionen enthalten.

- Java 25 (OpenJDK) (muss ggf. extern nachinstalliert werden)
- Tomcat 10.1.x bzw. Jetty 11.x (alternativ ein System mit Unterstützung von Servlet-6.0 und JakartaEE)
- SOLR 9.8.1 oder höher
- eine <a href="https://docs.jboss.org/hibernate/orm/6.5/javadocs/org/hibernate/dialect/package-summary.html">hibernate-fähige</a>
  relationale Datenbank wie PostgreSQL 16 oder höher, MySQL/Maria-DB 10 oder höher, DB2; für Testzwecke genügt auch die integrierte Datenbank H2
- Git 2.26 oder höher
- Apache Maven 3.6.3 oder höher

## Neuerungen

- Die Generatoren für persistente Identifikatoren wurden stark überarbeitet (MCR-3723).
- Kleinere Neuerung 2
- Kleinere Neuerung 3

### Größere Neuerung 1 (MCR-XXXX)

Beschreibung

### Größere Neuerung 2 (MCR-XXXX)

Beschreibung

## Migrationsschritte

### Überarbeitung der Generatoren für persistente Identifikatoren (MCR-3723)

Ebenfalls mit [MCR-3723](https://mycore.atlassian.net/browse/MCR-3723) wurden die Generatoren für persistente Identifikatoren
stark überarbeitet. Dies erfordert kleiner Anpassungen in eigenen Implementierungen und an der Konfiguration.
### Schritt 1 (MCR-XXXX)

Die folgenden Klassen wurden umbenannt:
 
- `MCRDNBURNGenerator` ⮕ `MCRDNBURNGeneratorBase`
- `MCRCountingDNBURNGenerator` ⮕ `MCRCountingDNBURNGeneratorBase`
- `MCRFLURNGenerator` ⮕ `MCRCurrentDateDNBURNGenerator`
- `MCRUUIDURNGenerator` ⮕ `MCRUUIDDNBURNGenerator`

Zudem gibt es einige neue Implementierungen von `MCRPIGenerator`; z.B. `MCROtherPIDOIGenerator`, die 
eine DOI basierend auf dem Werte eines bereits vergebenen Identifikators, z.B. einer URN, erstellen kann. 

Alle Implementierungen von `MCRPIGenerator` wurden auf den aktuellen annotationsbasierten konfigurationMechanismus
umgestellt. Hierbei wurden für alle Klassen Konfigurationsproxies angelegt. Die ehemals zu Konfiguration eingesetzten 
Methoden `setProperties(Map)` und `init(String)` wurden entfernt. Alle Klassen nun über Konstruktoren, die
die von der jeweiligen Implementierung benötigten Werte aufnehmen. Eigener Java-Code muss ggf. angepasst werden.
Eigene Implementierungen müssen ggf. ebenfalls umgestellt werden. 

Generatoren, die Datumsangaben formatieren, haben bisher jeweils unterschiedliche Strategien hierzu direkt
implementiert. Es wurde ein neues Interface `MCRDateFormatter` und Implementierungen für alle diese Strategien erstellt.
Alle Generatoren arbeite nun mit `MCRDateFormatter`. Entsprechend kann die Strategie zum Formatieren von Datumsangaben nun
jeweils über die Konfiguration angepasst oder ausgetauscht werden.

Dies macht folgende eine Migration aller konfigurierten Instanzen von `MCRGenericPIGenerator` (z.B. `TypeYearCountURN` bei MIR)
notwendig:

```properties
# Alt
MCR.PI.Generator.TypeYearCountURN.Class=org.mycore.pi.MCRGenericPIGenerator
...
MCR.PI.Generator.TypeYearCountURN.DateFormat=yyyyMMdd
...
```

```properties
# Neu
MCR.PI.Generator.TypeYearCountURN.Class=org.mycore.pi.MCRGenericPIGenerator
...
MCR.PI.Generator.TypeYearCountURN.DateFormatter.Class=org.mycore.common.date.MCRSimpleDateFormatter
MCR.PI.Generator.TypeYearCountURN.DateFormatter.Format=yyyyMMdd
...
```

Statt `MCRSimpleDateFormatter` kann alternativ auch z.B. `MCRISO8601DateFormatter` oder `MCRFLDateScrambler` verwendet werden. 

### Schritt 2 (MCR-XXXX)

Beschreibung

### Schritt 3 (MCR-XXXX)

Beschreibung
