---

title: "Ressourcen"
mcr_version: ['2023.08']
author: ['Torsten Krause']
description: "*Ressourcen* sind referenzierbare, statische Inhalte (z.B. Bilder, XML-Dateien, etc.).
Dies sind typischerweise Dateien, die der MyCoRe-Anwendung zur Laufzeit zur Verfügung stehen und geladen und verarbeitet werden können;
z.B. in Java-Code, während der Interpretation von XML-Stylesheets oder als Antwort auf einen HTTP-Request.
Dynamisch generierte Inhalte gelten in diesem Kontext nicht als Ressourcen."
date: '2023-07-28'
---
Eine Ressource wird durch einen `/`-separierten Pfad identifiziert, z.B. `/path/to/resource.txt`.
Dieser Pfad wird im Folgenden als *der Pfad* der Ressource bezeichnet.
Für den Pfad einer Ressource gilt:

- Er wird immer als absolut angenommen. Ein führender `/` ist optional.
- Er muss immer eine „Datei“ referenzieren und darf daher nicht mit einem `/` enden.
- Er darf keine „Java-Klasse“ referenzieren und darf daher nicht mit `.class` enden.
- Er muss diese Datei immer direkt referenzieren und darf daher nicht die Segmente `.` oder `..` beinhalten.
- Er darf keine leeren Segmente beinhalten.

Die Pfade `/path/to/resource.txt` und `path/to/resource.txt` sind äquivalent.
Der Pfad `/path//to/./some/../resources/` ist in vielerlei Hinsicht ungültig.

## Web-Ressourcen

*Web-Ressourcen* sind Ressourcen, deren Pfad mit `/META-INF/resources` beginnt.
Dies entspricht einer Konvention aus der Javas Servlet-Welt.
Der Teil des Pfandes nach diesem Prefix wird im Folgenden als *der Web-Pfad* der Web-Ressource bezeichnet.
Für den Web-Pfad einer Web-Ressource gilt:

- Er darf nicht mit `/META-INF` oder `/WEB-INF` beginnen.

Der Pfad `/META-INF/resources/META-INF/meta-resource.txt` ist entsprechend ungültig.

Web-Ressourcen werden von einer MyCoRe-Anwendung als Antwort auf einen HTTP-Request ausgeliefert,
sofern kein Servlet oder Servlet-Filter konfiguriert ist, der den HTTP-Request beantwortet.
Hierbei wird der Pfad des HTTP-Requests als Web-Pfad verwendet, um eine Web-Ressource zu finden
und, falls vorhanden, auszuliefern.

Ist z.B. `https://my.mycore.de` die Basis-URL der MyCoRe-Anwendung,
so wird bei einer Anfrage von `https://my.mycore.de/path/to/web-resource.txt`
die Web-Ressource mit dem Web-Pfad `/path/to/web-resource.txt` gesucht.
Dies entspricht der Ressource mit dem Ressourcen-Pfad `/META-INF/ressource/path/to/web-resource.txt`.

## Fundstellen von Ressourcen

In einer typischen MyCoRe-Anwendung können Ressourcen an verschiedenen Stellen gefunden werden.
Dies werden im folgenden als *Fundstellen* bezeichnet.

### Arten von Fundstellen

Es gibt zwei Arten von Fundstellen:

- Fundstellen, deren Inhalt als Ressourcen verwendet wird
  (in den folgenden Beispielen anhand der Datei `resource.txt` verdeutlicht).
  Beinhaltet eine solche Fundstelle etwa die Datei `/path/to/resource.txt`,
  so wird diese mit dem Pfad `/path/to/resource.txt` gefunden.
- Fundstellen, deren Inhalt als Web-Ressourcen verwendet wird
  (in den folgenden Beispielen anhand der Datei `web-resource.txt` verdeutlicht).
  Beinhaltet eine solche Fundstelle etwa die Datei `/path/to/web-resource.txt`,
  so wird diese mit dem Pfad `/META-INF/ressource/path/to/web-resource.txt` gefunden.

Fundstellen, deren Inhalt als Ressourcen verwendet wird, können dementsprechend auch Web-Ressourcen beinhalten. 
Hierzu müssen diese an dieser Fundstelle explizit unterhalb von `/META-INF/ressource` abgelegt werden.
Fundstellen, deren Inhalt als Web-Ressourcen verwendet wird, können keine Ressourcen beinhalten,
die nicht Web-Ressourcen sind.

### Relevante Verzeichnisse

Für einige Fundstellen dienen die folgenden Verzeichnisse als Basis-Verzeichnisse:

- Das Konfigurationsverzeichnis der MyCoRe-Anwendung (im Folgenden als `/path/to/configDir` angenommen).
- Das Basis-Verzeichnis der Web-Anwendung, also das Verzeichnis in das der Web-Container (z.B. *Tomcat* oder *Jetty*)
  bei Laden der Web-Anwendung den Inhalt WAR-Datei extrahiert (im Folgenden als `/path/to/webappDir` angenommen).

### Typische Fundstellen

In einer typischen MyCoRe-Anwendung gibt es die folgenden Fundstellen:

#### Developer-Override

Ist ein [Developer-Override]({{< ref dev_devmode >}}) konfiguriert
(z.B. mit `MCR.Developer.Resource.Override=/path/to/overrideDir`),
so wird der Inhalt der dort genannten Verzeichnisse als Ressourcen verwendet.

```
/path/to/overrideDir/resource.txt
/path/to/overrideDir/META-INF/resources/web-resource.txt
```

#### WCMS2

Ist das [WCMS2]({{< ref frontend_wcms >}})-Modul vorhanden, so wird der Inhalt des Speicherverzeichnisses
(typischerweise `/data/save/webpages` im Konfigurationsverzeichnis der MyCoRe-Anwendung)
als Web-Ressourcen verwendet.

```
/path/to/configDir/data/save/webpages/web-resource.txt
```

#### Ressourcen im Konfigurationsverzeichnis

Der Inhalt von `/resources` im Konfigurationsverzeichnis der MyCoRe-Anwendung wird als Ressourcen verwendet.

```
/path/to/configDir/resources/resource.txt
/path/to/configDir/resources/META-INF/resources/web-resource.txt
```

#### Web-Ressourcen in der Web-Anwendung

Der Inhalt des Basis-Verzeichnisses der Web-Anwendung wird als Web-Ressourcen verwendet.

```
/path/to/webappDir/web-resource.txt
```

Beim Laden der Web-Anwendung extrahiert der Web-Container (z.B. *Tomcat* oder *Jetty*) den Inhalt der WAR-Datei in dieses Verzeichnis.
Abgesehen von den Inhalten der Unterordner `/META-INF` und `/WEB-INF`
wird der Inhalt dieses Ordners von dem Web-Container als Antwort auf einen HTTP-Request ausgeliefert,
sofern kein Servlet oder Servlet-Filter konfiguriert ist, der den HTTP-Request beantwortet.
Dies gilt auch für Inhalte, die nach dem Extrahieren hinzukommen.

Aus diesem Grund dürfen Web-Pfade nicht mit `/META-INF` und `/WEB-INF` beginnen.

In einem Maven-Projekt zum Erzeugen einer WAR-Datei (z.B. `mir-webapp`)
befinden sich die so extrahierten Inhalte im Verzeichnis `/src/main/webapp`.

```
/path/to/mavenWarProject/src/main/webapp/web-resource.txt
```

#### Ressourcen in der Web-Anwendung

Der Inhalt von `/WEB-INF/classes` im Basis-Verzeichnisses der Web-Anwendung wird als Ressourcen verwendet.

```
/path/to/webappDir/WEB-INF/classes/resource.txt
/path/to/webappDir/WEB-INF/classes/META-INF/resources/web-resource.txt
```

In einem Maven-Projekt zum Erzeugen einer WAR-Datei (z.B. `mir-webapp`)
befinden sich diese Inhalte im Verzeichnis `/src/main/resources`.

```
/path/to/mavenWarProject/src/main/resource/resource.txt
/path/to/mavenWarProject/src/main/resource/META-INF/resources/web-resource.txt
```

#### Bibliotheken im Konfigurationsverzeichnis

Der Inhalt von JAR-Dateien im Verzeichnis `/lib` im Konfigurationsverzeichnis der MyCoRe-Anwendung wird als Ressourcen verwendet, 
sofern diese Bibliotheken zum Startzeitpunkt der MyCoRe-Anwendung dort vorhanden sind. 
Nachträglich hinzugefügte JAR-Dateien werden nicht geladen.

```
/path/to/configDir/lib/library-1.0.jar
 ├─ /resource.txt
 └─ /META-INF/resources/web-resource.txt
```

Hierbei kann es sich um MyCoRe-Anwendungsmodule oder normale Programmbibliotheken (z.B. WebJars) handeln.

#### Bibliotheken in der Web-Anwendung

Der Inhalt von JAR-Dateien im Verzeichnis `/WEB-INF/lib` im Basis-Verzeichnisses der Web-Anwendung wird als Ressourcen verwendet,
sofern diese Bibliotheken zum Startzeitpunkt der MyCoRe-Anwendung dort vorhanden sind.
Nachträglich hinzugefügte JAR-Dateien werden nicht geladen.

```
/path/to/webappDir/WEB-INF/lib/mycore-xxx-2023.08.jar
 ├─ /resource.txt
 └─ /META-INF/resources/web-resource.txt
```

Diese JAR-Dateien stammen aus der extrahierten WAR-Datei.
Sie sind die (transitiv) eingebundenen Dependencies mit Scope `compile` oder `runtime` (z.B. `org.mycore:mycore-xxx`)
in einem Maven-Projekt zum Erzeugen einer WAR-Datei (z.B. `mir-webapp`).

Hierbei kann es sich um MyCoRe-Anwendungsmodule oder normale Programmbibliotheken (z.B. WebJars) handeln.

#### Sonstige Bibliotheken

Der Inhalt von sonstigen JAR-Dateien wird als Ressourcen verwendet, sofern diese Bibliotheken geladen werden.
Welche Mechanismen hierzu zur Verfügung stehen, hängt u.A. von verwendeten Web-Container und der verwendeten JVM ab. 

Bei _Tomcat_ beispielsweise können herzu JAR-Dateien im Verzeichnis `/lib` im Installationsverzeichnis abgelegt werden
oder mit der Umgebungsvariablen `CLASSPATH` beim Start weitere Bibliotheken eingebunden werden.

Hierbei kann es sich um MyCoRe-Anwendungsmodule oder normale Programmbibliotheken (z.B. WebJars) handeln.

## API zum Verwenden von Ressourcen (MCRResourceResolver)

Das Verfahren zum Arbeiten mit Ressourcen wurde in {{<mcr-version "2023.08">}} neu gestaltet.

Ressourcen werden in MyCoRe als URL repräsentiert, wobei der URL einer Ressource geeignet sein muss,
den Inhalt der Ressource zu laden und zu verarbeiten.
Dies muss beliebig oft möglich sei und jedes Mal denselben Inhalt liefern. 
Im Folgenden werden Ressourcen und ihre Repräsentation in Java-Code als `URL` synonym verwendet.

Ressourcen-Pfade werden im Java-Code als `MCRResourcePath` repräsentiert.
Diese Klasse setzt die oben beschriebenen Einschränkungen durch.
Mit den statischen Methoden `Optional<MCRResourcePath> ofPath(String path)` und `Optional<MCRResourcePath> ofWebPath(String path)`
können Instanzen für Ressourcen-Pfade anhand von ausgeschriebenen Pfaden oder Web-Pfaden erstellt werden.

Zum Verwenden von Ressourcen in Java-Code stellt MyCoRe die zentrale Zugangsstelle `MCRResourceResolver` bereit.
Diese stellt diverse Methoden zum Auffinden einer Ressource bereit.
Die wesentliche Methode ist hierbei `Optional<URL> resolve(MCRResourcePath, MCRHints hints)`.
Sie nimmt einen Ressourcen-Pfad und sucht eine passende Ressource. Diese wird, falls vorhanden, zurückgegeben.
Die meisten anderen Methoden des Resolvers sind hilfreiche Abkürzungen für typische Anwendungsfälle.

Die Hilfsklasse `MCRResourceHelper` stellt zudem einen alternativen Zugang zum Resolver bereit.
Hier wird die Abwesenheit einer Ressource nicht durch `Optional`-, sondern durch `null`-Werte signalisiert. 
Diese Hilfsklasse erleichtert insbesondere die Anpassung von bestehendem Java-Code an das neue Verfahren.

Die konkret zum Auffinden von Ressourcen verwendete Strategie ist bei dem neuen Verfahren nicht mehr fest vorgegeben.
Sie wird anhand der Angaben in der Konfiguration der MyCoRe-Anwendung instanziiert. 
Typischerweise wird die Strategie dabei aus mehreren Komponenten zusammengestellt.
Eine Übersicht über die verwendete Zusammenstellung wird beim Start der MyCoRe-Anwendung in den Log-Daten ausgegeben. 

Für einige Komponenten müssen neben dem Pfad weitere Parameter verarbeitet werden.
Diese werden als `MCRHints` übergeben.
Die Hilfsklasse `MCRResourceHintKeys` definiert Schlüssel für standardmäßig bereitgestellte Parameter.
Die folgenden Werte werden hierbei bereitgestellt:

- `CONFIG_DIR`: Das von `MCRConfigurationDir#getConfigurationDirectory()` bereitgestellte Konfigurationsverzeichnis.
- `CLASS_LOADER`: Der von `MCRClassTools#getClassLoader()` gelieferte `ClassLoader`
- `SERVLET_CONTEXT`: Der `ServletContext` der Web-Anwendung, falls vorhanden.
- `WEBAPP_DIR`: Das Basis-Verzeichnis der Web-Anwendung, falls vorhanden.

## Strategien zum Auffinden von Ressourcen (MCRResourceProvider)

In MyCoRe werden verschiedene Strategien zum Auffinden von Ressourcen mit dem Interface `MCRResourceProvider` implementiert.
Die wesentliche Methode in diesem Interface ist `Optional<URL> provide(MCRResourcePath path, MCRHints hints)`.
Sie nimmt einen Pfad und liefert, falls vorhanden, eine passende Ressource.

MyCoRe stellt diverse Implementierungen von `MCRResourceProvider` bereit.
Einige *allgemeine Strategien* bilden grundsätzliche Verfahren ab.
Diese dienen als Grundlage für *spezielle Strategien* für die oben genannten typischen Fundstellen oder für eigene Strategien.
Zudem gibt es *komponierenden Strategien* die aus bestehenden Strategien neuen Strategien zusammenstellen.

Für die allgemeinen Strategien gibt es im Wesentlichen zwei Ansätze:

- Einige Strategien suchen anhand des gegebenen Pfades nach einer passenden Ressource, z.B. indem Sie den Pfad im Dateisystem nachschlagen.
- Andere Strategien wählen aus einer Menge von Kandidaten, z.B. die vom Web-Container verwendbaren Ressourcen, die passendste Ressource aus.

Jeder Strategie wird im Konstruktor mit dem Parameter `coverage` eine kurze Beschreibung ihres Einsatzzwecks übergeben.
Dies dient introspektiven Zwecken.
Typischerweise werden Instanzen von `MCRResourceProvider` jedoch nicht direkt erstellt,
sondern aus der Konfiguration der MyCoRe-Anwendung als [konfigurierte Klasseninstanzen]({{< ref basics_configurable_instance >}}) abgeleitet.
Für den eben genannten Parameter `coverage` gibt es für alle Implementierungen den Konfigurationsschlüssel `Coverage`.

### Allgemeine Strategien

MyCoRe stellt die folgenden allgemeinen Strategien bereit.

#### MCRClassLoaderResourceProvider

Die Strategie `MCRClassLoaderResourceProvider` verwendet die Methode `ClassLoader#getResource(String)` zum Auffinden einer Ressource.

#### MCRFileSystemResourceProvider

Die Strategie `MCRFileSystemResourceProvider` sucht anhand eines gegebenen Pfades im Dateisystem nach einer passenden Ressource.

Hierzu wird dem Konstruktor eine Liste von Basisverzeichnissen übergeben.
Diese Liste wird beim Suchen von Ressourcen der Reihe nach abgearbeitet.
Der erste Treffer wird verwendet.
Dem Konstruktor muss zudem ein `MCRResourceProviderMode` (entweder `RESOURCES` oder `WEB_RESOURCES`) übergeben werden.
Dieser Parameter bestimmt, ob die im Dateisystem vorhandenen Dateien als Ressourcen oder Web-Ressourcen verwendet werden sollen.

Zusätzliche Konfigurationsschlüssel:
- `Mode`: Der Modus, entweder `RESOURCES` oder `WEB_RESOURCES`.
- `BaseDirs`: Eine kommaseparierte Liste von Basisverzeichnissen.

#### MCRLFSResourceProvider

Die Strategie `MCRLFSResourceProvider` unterteilt die Strategie in drei Phasen: **L**ocate, **F**ilter, **S**elect.
Diese drei Phasen dienen insbesondere der Umsetzung von Strategien, die eine Ressource aus einer Menge von Kandidaten auswählen.
Jeder Phase wird von einer eigenen Komponente umgesetzt.

In der Locate-Phase wird von einem `MCRResourceLocator` die Menge der Kandidaten bereitgestellt.
In der Filter-Phase werden ungeeignete Kandidaten von einem `MCRResourceFilter` entfernt.
In der Select-Phase wird aus der Menge der geeigneten Kandidaten mit einem `MCRResourceSelector`
die Menge der präferierten Ressourcen ausgewählt und ihrer Priorität nach sortiert.
Im Gegensatz zur Filter-Phase werden Ressourcen in der Select-Phase nicht nur für sich betrachtet,
sondern können in Bezug auf alle geeigneten Kandidaten bewertet werden.
Sollten nach den drei Phasen noch mehrere Kandidaten zur verfügung stehen, wird der erste Kandidat verwendet.

Zusätzliche Konfigurationsschlüssel::
- `Locator`: Die Strategie für die Locate-Phase (`MCRResourcelocator`).
- `Filter`: Der Filter für die Filter-Phase (`MCRResourceFilter`).
- `Selector`: Der Strategie für die Select-Phase (`MCRResourceSelector`).

##### Locate-Phase

Die wesentliche Methode im Interface `MCRResourceLocator` ist `Stream<URL> locate(MCRResourcePath path, MCRHints hints)`.
Sie nimmt einen `MCRResourcePath` und stellt eine Menge von Kandidaten bereit.
MyCoRe stellt mehrere Implementierungen von `MCRResourceLocator` bereit.

###### MCRClassLoaderResourceLocator

Die Strategie `MCRClassLoaderResourceLocator` verwendet die Methode `ClassLoader#getResources(String)` zum Auffinden von Ressourcen.

###### MCRServletContextResourceLocator

Die Strategie `MCRServletContextResourceLocator` verwendet die Methode `ServleteContext#getResource(String)` zum Auffinden einer Web-Ressource.

###### MCRCombinedResourceLocator

Die Strategie `MCRCombinedResourceLocator` kombiniert mehrere andere Strategien.
Hierbei werden die Ergebnisse aller Strategien nacheinander bereitgestellt.

Zusätzliche Konfigurationsschlüssel:
- `Locators.`_`nnn`_, wobei _`nnn`_ numerische Werte sind: Eine Liste von Strategien (`MCRResourceLocator`).

##### Filter-Phase

Die wesentliche Methode im Interface `MCRResourceFilter` ist `Stream<URL> filter(Stream<URL> resourceUrls, MCRHints hints)`.
Sie nimmt einen die Menge von Kandidaten aus der Locate-Phase und entfernt ungeeignete Kandidaten.
MyCoRe stellt mehrere Implementierungen von `MCRResourceFilter` bereit.

###### MCRLibraryResourceFilter

Der Filter `MCRLibraryResourceFilter` prüft, ob ein Kandidat Inhalt einer JAR-Datei ist.

Dem Konstruktor muss ein `MCRResourceFilterMode` (entweder `MUST_MACTH` oder `MUST_NOT_MACTH`) übergeben werden.
Dieser Parameter bestimmt, ob die Kandidaten die genannte Bedingung erfüllen müssen oder nicht erfüllen dürfen.

Zusätzliche Konfigurationsschlüssel:
- `Mode`: Der Modus, entweder `MUST_MACTH` oder `MUST_NOT_MACTH`.

###### MCRConfigDirLibraryResourceFilter

Der Filter `MCRConfigDirLibraryResourceFilter` prüft, ob ein Kandidat Inhalt einer JAR-Datei
im Verzeichnis `/lib` im Konfigurationsverzeichnis der MyCoRe-Anwendung ist.

Dem Konstruktor muss ein `MCRResourceFilterMode` (entweder `MUST_MACTH` oder `MUST_NOT_MACTH`) übergeben werden.
Dieser Parameter bestimmt, ob die Kandidaten die genannte Bedingung erfüllen müssen oder nicht erfüllen dürfen.

Zusätzliche Konfigurationsschlüssel:
- `Mode`: Der Modus, entweder `MUST_MACTH` oder `MUST_NOT_MACTH`.

###### MCRWebappLibraryResourceFilter

Der Filter `MCRConfigDirLibraryResourceFilter` prüft, ob ein Kandidat Inhalt einer JAR-Datei
im Verzeichnis `/WEB-INF/lib` im Basis-Verzeichnisses der Web-Anwendung ist.

Dem Konstruktor muss ein `MCRResourceFilterMode` (entweder `MUST_MACTH` oder `MUST_NOT_MACTH`) übergeben werden.
Dieser Parameter bestimmt, ob die Kandidaten die genannte Bedingung erfüllen müssen oder nicht erfüllen dürfen.

Zusätzliche Konfigurationsschlüssel:
- `Mode`: Der Modus, entweder `MUST_MACTH` oder `MUST_NOT_MACTH`.

###### MCRWebappClassesDirResourceFilter

Der Filter `MCRWebappClassesDirResourceFilter` prüft, ob ein Kandidat
aus dem Verzeichnis `/WEB-INF/classes` im Basis-Verzeichnisses der Web-Anwendung stammt.

Dem Konstruktor muss ein `MCRResourceFilterMode` (entweder `MUST_MACTH` oder `MUST_NOT_MACTH`) übergeben werden.
Dieser Parameter bestimmt, ob die Kandidaten die genannte Bedingung erfüllen müssen oder nicht erfüllen dürfen.

Zusätzliche Konfigurationsschlüssel:
- `Mode`: Der Modus, entweder `MUST_MACTH` oder `MUST_NOT_MACTH`.

###### MCRCombinedResourceFilter

Der Filter `MCRCombinedResourceLocator` kombiniert mehrere andere Filter.
Hierbei werden alle Filter nacheinander angewendet.
Kandidaten müssen die Bedingungen aller Filter erfüllen werden, um die Bedingung des kombinierten Filters zu erfüllen.

Zusätzliche Konfigurationsschlüssel:
- `Filters.`_`nnn`_, wobei _`nnn`_ numerische Werte sind: Eine Liste von Filtern (`MCRResourceFilter`).

##### Select-Phase

Die wesentliche Methode im Interface `MCRResourceSelector` ist `List<URL> select(List<URL> resourceUrls, MCRHints hints)`.
Sie reduziert und sortiert die Menge von geeigneten Kandidaten aus der Filter-Phase.
MyCoRe stellt mehrere Implementierungen von `MCRResourceSelector` bereit.

###### MCRHighestComponentPriorityResourceSelector

Die Strategie `MCRHighestComponentPriorityResourceSelector` wählt aus den geeigneten Kandidaten denjenigen Kandidaten aus,
die aus den MyCoRe-Komponenten stammen, die unter allen MyCore-Komponenten, die Kandidaten bereitstellen, 
die höchste Priorität haben.  

Hierzu wird für eine effiziente Umsetzung die von `MCRRuntimeComponentDetector#getAllComponents(ComponentOrder)` 
absteigend nach Priorität sortierte Liste der MyCoRe-Komponenten abgearbeitet.
Dies wird so lange gemacht, bis eine Komponente gefunden wurde, die einen der Kandidaten beinhaltet.
Dieser Kandidat wird ausgewählt.
Anschließend werden nur noch MyCoRe-Komponenten betrachtet, und ggf. weitere Kandidaten ausgewählt, die dieselbe Priorität haben,
wie die erste so verwendete MyCoRe-Komponente.

Beispiel:

Angenommen es wird nach einer Resource in den folgenden Komponenten gesucht:

- Komponente `A`, Priorität 90, kein Kandidat
- Komponente `B`, Priorität 80, Kandidat
- Komponente `C`, Priorität 80, Kandidat
- Komponente `D`, Priorität 70, Kandidat
- Komponente `E`, Priorität 60, Kandidat
- Komponente `F`, Priorität 60, kein Kandidat

In diesem Fall werden die Kandidaten der Komponenten `B` und `C` ausgewählt.
Beim Betrachten von Komponente `C` wird die Suche abgebrochen,
da diese Komponente eine niedrigere Priorität hat,
als eine der Komponenten, die einen Kandidaten beinhaltet.
Die Komponenten `E` und `F` werden nicht betrachtet.

###### MCRFirstLibraryJarResourceSelector

Die Strategie `MCRFirstLibraryJarResourceSelector` wählt aus den verbleibenden Kandidaten denjenigen aus,
die aus der Bibliothek stammt, die unter allen Bibliotheken als erste in der Liste der Bibliotheken auftaucht.

Hierzu wird die von `ServletContext#getAttribute(String)` für den Schlüssel `ServletContext#ORDERED_LIBS` gelieferte Liste der Bibliotheken abgearbeitet.
Dies wird so lange gemacht, bis eine Bibliothek gefunden wurde, die einen der Kandidaten beinhaltet.
Dieser Kandidat wird ausgewählt.
Anschließend werden keine weiteren Bibliotheken betrachtet.

###### MCRCombinedResourceSelector

Die Strategie `MCRCombinedResourceSelector` kombiniert mehrere andere Strategien.
Hierbei werden alle Strategien nacheinander angewendet.
Kandidaten müssen von allen Strategien ausgewählt werden, um von der kombinierten Strategie übernommen zu werden.
Es wird die Priorisierung zuletzt angewandten Strategie übernommen.

Zusätzliche Konfigurationsschlüssel:
- `Selectors.`_`nnn`_, wobei _`nnn`_ numerische Werte sind: Eine Liste von Strategien (`MCRResourceSelector`).

### Spezielle Strategien

MyCoRe stellt die folgenden speziellen Strategien bereit.

#### MCRDeveloperOverrideResourceProvider

Die Strategie `MCRDeveloperOverrideResourceProvider` deckt die Fundstelle _„Developer-Override“_ ab.

#### MCRWCMSWebResourceProvider

Die Strategie `MCRWCMSWebResourceProvider` deckt die Fundstelle _„WCMS2“_ ab.

#### MCRConfigDirResourceProvider

Die Strategie `MCRConfigDirResourceProvider` deckt die Fundstelle _„Ressourcen im Konfigurationsverzeichnis“_ ab.

#### MCRWebappDirWebResourceProvider

Die Strategie `MCRWebappDirWebResourceProvider` deckt die Fundstelle _„Web-Ressourcen der Web-Anwendung“_ ab.

#### MCRWebappClassesDirResourceProvider

Die Strategie `MCRWebappClassesDirResourceProvider` deckt die Fundstelle _„Ressourcen der Web-Anwendung“_ ab.

Diese Strategie ist ein `MCRLFSResourceProvider` mit einem `MCRClassLoaderResourceLocator`
und einem `MCRWebappClassesDirResourceFilter`.

#### MCRLibraryResourceProvider

Die Strategie `MCRLibraryResourceProvider` verwendet den Inhalt von beliebigen JAR-Dateien als Ressourcen,
unabhängig davon an welcher Stelle sich diese befinden.

Diese Strategie ist ein `MCRLFSResourceProvider` mit einem `MCRClassLoaderResourceLocator`,
einem `MCRLibraryResourceFilter` und einer Kombination aus `MCRHighestComponentPriorityResourceSelector`
und `MCRFirstLibraryJarResourceSelector`.

#### MCRConfigDirLibraryResourceProvider

Die Strategie `MCRConfigDirLibraryResourceProvider` deckt die Fundstelle _„Bibliotheken im Konfigurationsverzeichnis“_ ab.

Diese Strategie ist ein `MCRLFSResourceProvider` mit einem `MCRClassLoaderResourceLocator`,
einem `MCRConfigDirLibraryResourceFilter` und einer Kombination aus `MCRHighestComponentPriorityResourceSelector`
und `MCRFirstLibraryJarResourceSelector`.

Dem Konstruktor muss ein `MCRResourceFilterMode` (entweder `MUST_MACTH` oder `MUST_NOT_MACTH`) übergeben werden.
Dieser Parameter bestimmt, ob die ausgewählten Ressourcen aus einer Bibliothek im Konfigurationsverzeichnis oder
aus einer anderen Bibliothek stammen müssen. In jedem Fall müssen die Ressourcen aus einer Bibliothek stammen.  

Zusätzliche Konfigurationsschlüssel:
- `Mode`: Der Modus, entweder `MUST_MACTH` oder `MUST_NOT_MACTH`.

#### MCRWebappLibraryResourceProvider

Die Strategie `MCRWebappLibraryResourceProvider` deckt die Fundstelle _„Bibliotheken der Web-Anwendung“_ ab.

Diese Strategie ist ein `MCRLFSResourceProvider` mit einem `MCRClassLoaderResourceLocator`,
einem `MCRWebappLibraryResourceFilter` und einer Kombination aus `MCRHighestComponentPriorityResourceSelector`
und `MCRFirstLibraryJarResourceSelector`.

Dem Konstruktor muss ein `MCRResourceFilterMode` (entweder `MUST_MACTH` oder `MUST_NOT_MACTH`) übergeben werden.
Dieser Parameter bestimmt, ob die ausgewählten Ressourcen aus einer Bibliothek der Web-Anwendung oder
aus einer anderen Bibliothek stammen müssen. In jedem Fall müssen die Ressourcen aus einer Bibliothek stammen.

Zusätzliche Konfigurationsschlüssel:
- `Mode`: Der Modus, entweder `MUST_MACTH` oder `MUST_NOT_MACTH`.

### Komponierende Strategien

MyCoRe stellt die folgenden komponierenden Strategien bereit.

#### MCRCachingResourceProvider

Die Strategie `MCRCachingResourceProvider` übernimmt die Ergebnisse einer anderen Strategie
und speichert diese in einem `MCRCache` zwischen.

Dem Konstruktor muss eine Cache-Größe und die zu verwendenden Strategie übergeben werden. 

Zusätzliche Konfigurationsschlüssel:
- `Capacity`: Die Cache-Größe.
- `Provider`: Die zugrundeliegende Strategie (`MCRResourceProvider`).

#### MCRCombinedResourceProvider

Die Strategie `MCRCombinedResourceProvider` kombiniert mehrere andere Strategien.
Hierbei wird das erste von einer der Strategien gelieferte Ergebnis bereitgestellt.

Zusätzliche Konfigurationsschlüssel:
- `Providers.`_`nnn`_, wobei _`nnn`_ numerische Werte sind: Eine Liste von Strategien (`MCRResourceProvider`).

### Konfigurationen

Es können mehrere Konfigurationen zum Auffinden von Ressourcen angegeben werden.
Für eine Konfiguration wird der Konfigurationsschlüssel `MCR.Resource.Resolver.`_`name`_ verwendet, 
wobei _`name`_ ein frei wählbarer Name ist.

Für jede solche Konfiguration muss mit dem Schlüssel `Provider`
eine Strategie zum Auffinden von Ressourcen angegeben werden (`MCRResourcelocator`).

Die tatsächlich zu verwendende Konfiguration wird mit dem Konfigurationsschlüssel `MCR.Resource.Resolver` ausgewählt,
wobei als Wert der frei gewählten Namen einer Konfiguration angegeben werden muss.
Nur diese Strategie wird instanziiert.

Dieser mechanismus erlaubt den schnellen Wechsel zwischen verschiedenen Konfigurationen.

#### Standardkonfiguration

In MyCoRe sind zwei Konfigurationen vorgegeben: `default` und `legacy`.

Die Konfiguration `legacy` bildet im wesentliche die Strategie nach, die vor {{<mcr-version "2023.08">}} fest implementiert war.
Die Konfiguration `default` ist eine vereinfachte und effizientere Strategie, die in den meisten Anwendungsfällen ausreichend sein sollte. 

##### Die default-Konfiguration

Die folgende Übersicht stellt die `defualt`-Konfiguration dar:

```
├─ Class: org.mycore.common.resource.provider.MCRCombinedResourceProvider
├─ Coverage: all resources
├─ Provider:
│  ├─ Class: org.mycore.common.resource.provider.MCRDeveloperOverrideResourceProvider
│  └─ Coverage: developer override resources
├─ Provider:
│  ├─ Class: org.mycore.wcms2.MCRWCMSWebResourceProvider
│  └─ Coverage: WCMS web resources
├─ Provider:
│  ├─ Class: org.mycore.common.resource.provider.MCRConfigDirResourceProvider
│  └─ Coverage: config dir resources
└─ Provider:
   ├─ Class: org.mycore.common.resource.provider.MCRCachingResourceProvider
   ├─ Coverage: cached app resources
   ├─ Capacity: 1000
   └─ Provider:
      ├─ Class: org.mycore.common.resource.provider.MCRCombinedResourceProvider
      ├─ Coverage: app resources
      ├─ Provider:
      │  ├─ Class: org.mycore.common.resource.provider.MCRWebappDirWebResourceProvider
      │  └─ Coverage: webapp dir web resources
      ├─ Provider:
      │  ├─ Class: org.mycore.common.resource.provider.MCRWebappClassesDirResourceProvider
      │  └─ Coverage: webapp classes dir resources
      ├─ Provider:
      │  ├─ Class: org.mycore.common.resource.provider.MCRLibraryResourceProvider
      │  └─ Coverage: library resources
      └─ Provider:
         ├─ Class: org.mycore.common.resource.provider.MCRClassLoaderResourceProvider
         └─ Coverage: fallback resource
```

##### Die legacy-Konfiguration

Die folgende Übersicht stellt die `legacy`-Konfiguration dar:

```
├─ Class: org.mycore.common.resource.provider.MCRCombinedResourceProvider
├─ Coverage: all resources
├─ Provider:
│  ├─ Class: org.mycore.common.resource.provider.MCRDeveloperOverrideResourceProvider
│  └─ Coverage: developer override resources
├─ Provider:
│  ├─ Class: org.mycore.wcms2.MCRWCMSWebResourceProvider
│  └─ Coverage: WCMS web resources
├─ Provider:
│  ├─ Class: org.mycore.common.resource.provider.MCRWebappDirWebResourceProvider
│  └─ Coverage: webapp dir web resources
├─ Provider:
│  ├─ Class: org.mycore.common.resource.provider.MCRConfigDirResourceProvider
│  └─ Coverage: config dir resources
├─ Provider:
│  ├─ Class: org.mycore.common.resource.provider.MCRConfigDirLibraryResourceProvider
│  ├─ Coverage: config dir library resources
│  └─ Mode: MUST_MATCH
├─ Provider:
│  ├─ Class: org.mycore.common.resource.provider.MCRWebappClassesDirResourceProvider
│  └─ Coverage: webapp classes dir resources
├─ Provider:
│  ├─ Class: org.mycore.common.resource.provider.MCRConfigDirLibraryResourceProvider
│  ├─ Coverage: other library resources
│  └─ Mode: MUST_NOT_MATCH
└─ Provider:
   ├─ Class: org.mycore.common.resource.provider.MCRClassLoaderResourceProvider
   └─ Coverage: fallback resource
```
 
#### Eigene Konfiguration

Eigene konfigurationen können mit dem oben beschriebenen Mechanismus
und den bei den einzelnen Komponenten vorgestellten Konfigurationsschlüsseln erstellt werden.

Verwendet man keinen Developer-Override, kein WCMS und auch keine anderen Mechanismen,
die den Inhalt von Fundstellen zur Laufzeit verändern, kann z.B. die folgendermaßen zusammengestellte Konfiguration
mit dem Namen `simple` verwendet werden:

```
MCR.Resource.Resolver.simple.Provider.Class=org.mycore.common.resource.provider.MCRCachingResourceProvider
MCR.Resource.Resolver.simple.Provider.Coverage=cached app resources
MCR.Resource.Resolver.simple.Provider.Capacity=1000
MCR.Resource.Resolver.simple.Provider.Provider.Class=org.mycore.common.resource.provider.MCRCombinedResourceProvider
MCR.Resource.Resolver.simple.Provider.Provider.Coverage=app resources
MCR.Resource.Resolver.simple.Provider.Provider.Providers.10.Class=org.mycore.common.resource.provider.MCRConfigDirResourceProvider
MCR.Resource.Resolver.simple.Provider.Provider.Providers.20.Class=org.mycore.common.resource.provider.MCRWebappDirWebResourceProvider
MCR.Resource.Resolver.simple.Provider.Provider.Providers.30.Class=org.mycore.common.resource.provider.MCRWebappClassesDirResourceProvider
MCR.Resource.Resolver.simple.Provider.Provider.Providers.40.Class=org.mycore.common.resource.provider.MCRLibraryResourceProvider
MCR.Resource.Resolver.simple.Provider.Provider.Providers.50.Class=org.mycore.common.resource.provider.MCRClassLoaderResourceProvider
MCR.Resource.Resolver.simple.Provider.Provider.Providers.50.Coverage=fallback resource
```
Die folgende Übersicht stellt diese Konfiguration dar:

```
├─ Class: org.mycore.common.resource.provider.MCRCachingResourceProvider
├─ Coverage: cached app resources
├─ Capacity: 1000
└─ Provider:
   ├─ Class: org.mycore.common.resource.provider.MCRCombinedResourceProvider
   ├─ Coverage: app resources
   ├─ Provider:
   │  ├─ Class: org.mycore.common.resource.provider.MCRConfigDirResourceProvider
   │  └─ Coverage: config dir resources
   ├─ Provider:
   │  ├─ Class: org.mycore.common.resource.provider.MCRWebappDirWebResourceProvider
   │  └─ Coverage: webapp dir web resources
   ├─ Provider:
   │  ├─ Class: org.mycore.common.resource.provider.MCRWebappClassesDirResourceProvider
   │  └─ Coverage: webapp classes dir resources
   ├─ Provider:
   │  ├─ Class: org.mycore.common.resource.provider.MCRLibraryResourceProvider
   │  └─ Coverage: library resources
   └─ Provider:
      ├─ Class: org.mycore.common.resource.provider.MCRClassLoaderResourceProvider
      └─ Coverage: fallback resource
```