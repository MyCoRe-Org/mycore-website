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

### Zentrale Vue-/Vite-Infrastruktur im neuen Modul `mycore-vue` ({{<mcr-ticket "MCR-3810" >}})

Alle Vue-Anwendungen von MyCoRe nutzen jetzt eine gemeinsame Vue-/Vite-/TypeScript-Toolchain im neuen Maven-Modul
`mycore-vue`: eine `package.json`, eine `yarn.lock` und ein `node_modules` für alle Apps. Dependency- und
Security-Updates für Vue erfolgen damit an genau einer Stelle. Die Vue-Apps selbst bleiben in ihren fachlichen
Modulen (`mycore-webtools`, `mycore-webcli`, `mycore-jobqueue`, `mycore-acl`); ihre Ausgabeverzeichnisse und URLs
ändern sich nicht. Ebenfalls in das neue Modul gewandert sind das `MCRVueRootServlet` und seine i18n-Schlüssel.
Die Alt-Frontends auf Basis von AngularJS und Grunt (METS-Editor, WCMS2, Classeditor, ACL-Editor2, Upload und
Viewer) sind nicht betroffen und behalten ihren eigenen Build.

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




### `MCRVueRootServlet` in ein neues Modul und Paket verschoben ({{<mcr-ticket "MCR-3811" >}})

Das `MCRVueRootServlet` liegt nicht mehr in `mycore-webtools`, sondern im neuen Modul `mycore-vue`.
Damit ändert sich auch sein Paket:

| bisher | neu |
| --- | --- |
| `org.mycore.webtools.vue.MCRVueRootServlet` | `org.mycore.frontend.vue.MCRVueRootServlet` |

Eine als `deprecated` markierte Kompatibilitätsklasse unter dem alten Namen gibt es nicht. Anzupassen sind daher:

- jede eigene `web.xml` bzw. `web-fragment.xml`, die das Servlet über `<servlet-class>` einbindet,
- jede eigene Ableitung des Servlets sowie alle `import`-Anweisungen im eigenen Java-Code,
- die `pom.xml` von Anwendungen, die ihre MyCoRe-Module einzeln auflisten, statt `mycore-meta` oder die
  MyCoRe-BOM zu verwenden. Sie benötigen zusätzlich eine Abhängigkeit auf `org.mycore:mycore-vue`.

Die URL-Muster (`url-pattern`) und die Namen der `init-param` (`heading`, `properties`, `permission`,
`wrapWebPage`) bleiben unverändert. Ein Neubau der eigenen Vue-Apps ist wegen des Umzugs nicht nötig.

### i18n-Schlüssel des Vue-Servlets umbenannt ({{<mcr-ticket "MCR-3811" >}})

Mit dem Servlet sind auch dessen Übersetzungen in die neue Komponente `vue` gewandert und haben dabei
ihr Präfix gewechselt:

| bisher | neu |
| --- | --- |
| `component.webtools.error.MCRVueRootServlet.*` | `component.vue.error.MCRVueRootServlet.*` |
| `component.webtools.vue.error.*` | `component.vue.error.*` |

Betroffen sind der Schlüssel `accessDenied` des Servlets sowie die Texte der Fehlerseiten unterhalb von
`general`, `401`, `403` und `404`. In der englischen Fassung hießen die beiden allgemeinen Schlüssel bisher
fälschlich `component.webtools.vue.error.genral.message` und `component.webtools.vue.error.genral.description`.
Dieser Tippfehler wurde beim Umzug korrigiert.

Wer einen dieser Texte in den eigenen `messages_de.properties` bzw. `messages_en.properties` überschrieben hat,
muss die Schlüssel dort entsprechend umbenennen. Andernfalls greifen wieder die Standardtexte von MyCoRe.

### Property `MCR.Vue.Properties` in die Komponente `vue` verschoben ({{<mcr-ticket "MCR-3811" >}})

Die Property `MCR.Vue.Properties` wird nicht mehr von `mycore-webtools` vorbelegt, sondern von `mycore-vue`.
Name und Standardwert (`MCR.NameOfProject`) bleiben gleich, die Datei wechselt von
`components/webtools/config/mycore.properties` nach `components/vue/config/mycore.properties`.

Überschreibungen in der `mycore.properties` der Anwendung wirken unverändert. Zu beachten ist lediglich die
geänderte Komponenten-Priorität: `mycore-vue` hat Priorität 78, `mycore-webtools` hat 85. Wer den Wert in einer
eigenen Komponente mit einer Priorität zwischen 78 und 85 setzt, überschreibt die Vorbelegung jetzt wie erwartet;
zuvor gewann in diesem Fall die Vorbelegung aus `mycore-webtools`.

### Geänderte Modul-Abhängigkeiten ({{<mcr-ticket "MCR-3811" >}})

Mit dem Umzug haben sich zwei transitive Abhängigkeiten verschoben:

- `mycore-webcli` hängt nicht mehr von `mycore-webtools` ab, sondern von `mycore-vue`. Anwendungen, die
  `mycore-webtools` bisher nur transitiv über `mycore-webcli` bezogen haben, müssen es explizit in ihre
  `pom.xml` aufnehmen.
- `org.jsoup:jsoup` ist zusammen mit dem Servlet nach `mycore-vue` gewandert und ist in `mycore-webtools` keine
  direkte Abhängigkeit mehr. Wer jsoup im eigenen Java-Code verwendet und es bisher transitiv über
  `mycore-webtools` erhalten hat, muss es selbst deklarieren.

Die Module `mycore-webtools`, `mycore-webcli`, `mycore-jobqueue` und `mycore-acl` ziehen `mycore-vue` jeweils
im Scope `runtime` nach, das Servlet steht zur Laufzeit also weiterhin überall dort zur Verfügung, wo es bisher
schon verfügbar war.

### Zentraler Frontend-Build für Vue-Apps im MyCoRe-Reactor ({{<mcr-ticket "MCR-3810" >}})

Dieser Schritt betrifft nur Module und Overlays, die eine eigene Vue-App innerhalb des MyCoRe-Reactors bauen.
Anwendungen mit einem eigenständigen Frontend-Build außerhalb des Reactors sind nicht betroffen.

- Die einzelnen `package.json`- und `yarn.lock`-Dateien der Apps sind entfallen. Abhängigkeiten und Build-Skripte
  stehen zentral in `mycore-vue/package.json`, pro App gibt es ein Skript `build:<app>`.
- `yarn install` läuft nur noch einmal, nämlich in `mycore-vue`. Der Build einer App bleibt eine Ausführung des
  `frontend-maven-plugin` im besitzenden Modul, allerdings mit
  `<workingDirectory>${basedir}/../mycore-vue</workingDirectory>` und dem App-Skript als `<arguments>`.
- Der isolierte Bau eines einzelnen Moduls (`mvn -pl <modul> install`) setzt jetzt ein vorhandenes
  `mycore-vue/node_modules` voraus. Andernfalls ist `-am` nötig, damit `mycore-vue` zuvor gebaut wird.
- Die alten `node_modules`-Verzeichnisse in den Modulen werden bei `mvn clean` einmalig mit entfernt.
- Die Toolchain wurde dabei vereinheitlicht und angehoben, unter anderem auf vite 8, `@vitejs/plugin-vue` 6,
  vue-tsc 3, eslint 10 und vitest 4. Da vite 8 mit rolldown bündelt, gehören Bundler-Einstellungen jetzt unter
  `build.rolldownOptions` statt unter das veraltete `build.rollupOptions`. `vite-plugin-eslint` und
  `rollup-plugin-external-globals` sind entfallen.

Wie eine eigene App an die gemeinsame Toolchain angeschlossen wird, beschreibt `mycore-vue/README.md`.

### Schritt 1 ({{<mcr-ticket "MCR-XXXX" >}})

Beschreibung

### Schritt 2 ({{<mcr-ticket "MCR-XXXX" >}})

Beschreibung
