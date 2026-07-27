---
aliases:
  - /documentation/migrate/migrate_mcr2026_12/
doc_type: how-to
product: mycore
title: "Migration MyCoRe LTS 2026.06 nach 2026.12"
linkTitle: "2026.12.x"
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

### Schritt 1 ({{<mcr-ticket "MCR-XXXX" >}})

Beschreibung

### Schritt 2 ({{<mcr-ticket "MCR-XXXX" >}})

Beschreibung
