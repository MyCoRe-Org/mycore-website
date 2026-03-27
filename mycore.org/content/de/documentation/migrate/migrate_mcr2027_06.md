---
title: "Migration MyCoRe LTS 2026.12 nach 2027.06"
mcr_version: ['2027.06']
author: []
description: "
Diese Seite fasst Systemanforderungen für die Nutzung des MyCoRe LTS 2027.06 und die Migration von Version
2026.12 zu 2027.06 zusammen."
date: "2000-01-01"
---

{{< mcr-comment >}} Publish this page by setting the date and removing icon and property 'pre' from menus.de.yaml {{< /mcr-comment >}}
<div class="alert alert-warning">
    Diese Seite ist <strong>Work in Progress</strong>. <br />
    Sie wird im Rahmen der Fertigstellung des aktuellen MyCoRe-Releases weiter ergänzt!
</div>

## Systemanforderungen MyCoRe LTS 2027.06 [TODO: UPDATE]

Für den Betrieb einer MyCoRe-Anwendung unter LTS 2027.06 sind folgende Voraussetzungen zu erfüllen:

### Betriebssystem

MyCoRe LTS 2027.06 ist auf diesen Betriebssystemen im Einsatz. Höhere Versionen sollten kein Problem darstellen.

- Open SuSE Leap 15.6 oder höher
- SuSE SLES 15.6 oder höher
- Ubuntu 24.04 LTS
- CentOS 8
- RHEL 8
- Windows 11 für Test- und Entwicklungssysteme

### Standardsoftware

Zur Arbeit mit MyCoRe LTS 2027.06 sind folgende Softwarekomponenten erforderlich bzw. empfohlen.
Diese sind alle von Drittanbietern und im Normalfall in den Distributionen enthalten.

- Java 25 (OpenJDK) (muss ggf. extern nachinstalliert werden)
- Tomcat 10.1.x bzw. Jetty 11.x (alternativ ein System mit Unterstützung von Servlet-6.0 und JakartaEE)
- SOLR 9.8.1 oder höher
- eine <a href="https://docs.jboss.org/hibernate/orm/6.5/javadocs/org/hibernate/dialect/package-summary.html">hibernate-fähige</a>
  relationale Datenbank wie PostgreSQL 16 oder höher, MySQL/Maria-DB 10 oder höher, DB2; für Testzwecke genügt auch die integrierte Datenbank H2
- Git 2.26 oder höher
- Apache Maven 3.6.3 oder höher

## Neuerungen, die eine Migration erforderlich machen

### Neuerung 1

Beschreibung

### Neuerung 2

Beschreibung

## Migrationsschritte

### Schritt 1

Beschreibung

### Schritt 2

Beschreibung

