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

- Kleinere Neuerung 1
- Kleinere Neuerung 2
- Kleinere Neuerung 3

### Größere Neuerung 1 ({{<mcr-ticket "MCR-XXXX" >}})

Beschreibung

### Größere Neuerung 2 ({{<mcr-ticket "MCR-XXXX" >}})

Beschreibung

## Migrationsschritte

### Geänderte Funktionen in `property.xsl` ({{<mcr-ticket "MCR-3719" >}})

Durch `property.xsl` wurden ursprünglich zwei Funktionen bereitgestellt;
eine, `one`, die den Wert zu einem Property-Namen zurückliefert und
eine, `all`, die alle Sub-Properties zu einem Präfix zurückliefert.
Letztere Funktion gibt eine geschachtelte XML-Elementstruktur zurück.

Im Rahmen der XSLT3-Umstellung wurde eine weitere Funktion, `map`, hinzugefügt,
die dasselbe tut wie `all`, dabei aber eine XSL-Map zurückliefert.

Mit MCR-3719 wurden die bereitgestellten Funktionen überarbeitet:

- Die Methode `one` wurde in `get` umbenannt.  
  Aufrufe von `mcrproperty:one` müssen durch `mcrproperty:get` ersetzt werden.
- Die Methode `map` wurde in `get-sub-properties` umbenannt.  
  Aufrufe von `mcrproperty:map` müssen durch `mcrproperty:get-sub-properties` ersetzt werden.
- Die Methode `all` wurde entfernt.  
  Aufrufe der Form `mcrproperty:all('MCR.Foo.Bars')/entry[@key='baz']` müssen durch
  - `map:get(mcrproperty:get-sub-properties('MCR.Foo.Bars'), 'baz')` (Hilfsmethode),
  - `mcrproperty:get-sub-properties('MCR.Foo.Bars')('baz')` (Funktionsaufruf) oder
  - `mcrproperty:get-sub-properties('MCR.Foo.Bars')?'baz'` (Lookup-Operator) ersetzt werden.

> Die Verwendung von `<xsl:param name=​'MCR.Foo.Bar'>` auf oberster Ebene eines Stylesheets sollte durch
> `<xsl:variable name=​"Bar" select=​"mcrproperty:get('MCR.Foo.Bar')" />` auf oberster Ebene des Stylesheets oder, besser,
> `<xsl:variable name=​"bar" select=​"mcrproperty:get('MCR.Foo.Bar')" />` am Verwendungsort ersetzt werden,
> um Probleme mit undefinierten oder doppelt definierten Parametern im Zusammenhang mir `xsl:include` / `xsl:import` zu vermeiden.
{.note}

### Überarbeitung der Generatoren für persistente Identifikatoren ({{<mcr-ticket "MCR-3723" >}})

Die Generatoren für persistente Identifikatoren wurden stark überarbeitet.
Dies erfordert kleiner Anpassungen in eigenen Implementierungen und an der Konfiguration.

Die folgenden Klassen wurden umbenannt:
 
- `MCRDNBURNGenerator` ⮕ `MCRDNBURNGeneratorBase`
- `MCRCountingDNBURNGenerator` ⮕ `MCRCountingDNBURNGeneratorBase`
- `MCRFLURNGenerator` ⮕ `MCRCurrentDateDNBURNGenerator`
- `MCRUUIDURNGenerator` ⮕ `MCRUUIDDNBURNGenerator`

Zudem gibt es einige neue Implementierungen von `MCRPIGenerator`; z.B. `MCROtherPIDOIGenerator`, die
eine DOI basierend auf dem Werte eines bereits vergebenen Identifikators, z.B. einer URN, erstellen kann.

Alle Implementierungen von `MCRPIGenerator` wurden auf den aktuellen annotationsbasierten Konfigurationsmechanismus
umgestellt. Hierbei wurden für alle Klassen Konfigurationsproxies angelegt. Die ehemals zu Konfiguration eingesetzten
Methoden `setProperties(Map)` und `init(String)` wurden entfernt. Alle Klassen verfügen nun über Konstruktoren, die
alle von der jeweiligen Implementierung benötigten Werte aufnehmen. Eigener Java-Code muss ggf. angepasst werden.
Eigene Implementierungen müssen ggf. ebenfalls umgestellt werden.

### Flexible Datumsformatierung für Generatoren für persistente Identifikatoren ({{<mcr-ticket "MCR-3760" >}})

Die Generatoren für persistente Identifikatoren, die formatierte Datumsangaben verwenden,
haben bisher jeweils unterschiedliche Strategien hierzu direkt implementiert.
Es wurde ein neues Interface `MCRDateFormatter` und Implementierungen für alle Strategien erstellt.
Alle Generatoren arbeiten jetzt mit `MCRDateFormatter`. Entsprechend kann die Strategie
zum Formatieren von Datumsangaben nun jeweils über die Konfiguration angepasst oder ausgetauscht werden. 

Dies macht eine Migration aller konfigurierten Instanzen von `MCRGenericPIGenerator` (z.B. `TypeYearCountURN` bei MIR)
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

Bei allen anderen Generatoren ist keine Migration zwingend notwendig, da die vormals direkt implementierte
Strategie zur Datumsformatierung weiterhin das Standardverhalten ist.

### Methoden in `MCRConfigurationBase` und `MCRConfiguration2` ({{<mcr-ticket "MCR-3785" >}})

MyCoRe stellt die Klassen `MCRConfigurationBase` und `MCRConfiguration2` bereit, wobei `MCRConfigurationBase`
im Wesentlichen die aus `mycore.properites`-Dateien eingelesenen Konfigurationseinträge bereitstellt und
`MCRConfiguration2` eine *nettere* API für die Verwendung dieser Konfigurationseinträge anbietet.

Ein wichtiger Unterschied ist hier, dass `MCRConfigurationBase` Einträge mit leeren Werten,
wie alle anderen Einträge auch, bereitstellt. `MCRConfiguration2` hingegen ignoriert Einträge mit leeren Werten
und behandelt diese wie nicht vorhandene Einträge.

Hiervon abweichend haben die Methoden `MCRConfiguration2#getPropertiesMap` und `MCRConfiguration2#getSubPropertiesMap`
jeweils alle Einträge berücksichtigt, inklusive Einträgen mit leeren Werten. Daher wurden diese Methoden
nach `MCRConfigurationBase` verschoben und in `MCRConfiguration2` äquivalente Methoden hinzugefügt,
die Einträge mit leeren Werten ignorieren. Zudem wurden die Namen der Methoden leicht angepasst.

Dementsprechend müssen in eigenem Java-Code
- Aufrufe von `MCRConfiguration2#getPropertiesMap` entweder durch `MCRConfigurationBase#getAllPropertiesMap`
  oder durch `MCRConfiguration2#getAllPropertiesMap` ersetzt werden und 
- Aufrufe von `MCRConfiguration2#getSubPropertiesMap` entweder durch `MCRConfigurationBase#getSubpropertiesMap`
  oder durch `MCRConfiguration2#getSubpropertiesMap` ersetzt werden,

je nachdem, ob man einen 1-zu-1-Ersatz für die alte Methode benötigt, oder ob man das Verhalten der neuen
Methode bevorzugt (z.B. weil man angenommen hatte, das sich die alte Methode bereits mit den sonstigen
Methoden aus `MCRConfiguration2` harmonisch verhalten hat).

Grundsätzlich ist es empfehlenswert, jeweils die neue Methode zu verwenden, es sei denn es gibt wichtige Gründe dafür,
Konfigurationseinträge mit leeren Werten zu verarbeiten.

### Schritt 1 ({{<mcr-ticket "MCR-XXXX" >}})

Beschreibung

### Schritt 2 ({{<mcr-ticket "MCR-XXXX" >}})

Beschreibung
