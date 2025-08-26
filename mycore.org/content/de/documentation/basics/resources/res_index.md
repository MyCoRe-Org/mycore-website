---

title: "Ressourcen"
mcr_version: ['2025.06']
author: ['Torsten Krause']
date: '2025-09-01'

---

*Ressourcen* sind referenzierbare, statische Inhalte (z.B. Bilder, XML-Dateien, etc.).

Sie stehen der MyCoRe-Anwendung zur Laufzeit zur Verfügung und können von dieser verwendet und verarbeitet werden,
z.B. in Java-Code, während der Interpretation von XML-Stylesheets oder als Antwort auf einen HTTP-Request.

Dynamisch generierte Inhalte gelten in diesem Kontext nicht als Ressourcen.

In einer klassischen Java-Anwendung können Ressourcen mit Methoden wie `Class#getResource(String)` oder `ClassLoader#getResource(String)` gefunden werden.
Diese Methoden nehmen einen Pfad als `String` und liefern, sofern eine entsprechende Ressource vorhanden ist, eine zugehörige URL als `URL` zurück.
Über diese URL kann mit der eigentlichen Ressource interagiert werden.

## Der Resource-Resolver

MyCoRe bringt mit dem *Resource-Resolver* (`MCRResourceResolver`) einen ähnlichen Mechanismus. Dieser sollte präferiert verwendet werden.
Er berücksichtigt im Gegensatz zu Standard-Java-Mechanismen verschiedene MyCoRe-spezifische Aspekte, z.B. die Priorität von MyCoRe-Modulen.

Auf den global zur Verfügung stehenden ResourceResolver kann mittels `MCRResourceResolver.obtainInstance()` zugegriffen werden.
Er stellt Methoden bereit, mit denen nach Ressourcen gesucht werden kann, z.B. `MCRResourceResolver#resolveResource(String)`.
Diese Methoden nehmen einen Pfad z.B. als `String` und liefern, sofern eine entsprechende Ressource vorhanden ist,
eine zugehörige URL als `Optional<URL>` zurück.

Zusätzlich bietet MyCoRe mit `MCRResourceHelper` eine Hilfsklasse an, um mit statischen Methoden direkt auf Ressourcen zuzugreifen
(diese bieten nicht alle Möglichkeiten des Resource-Resolvers, sind typischerweise aber ausreichend), z.B.:
- `MCRResourceHelper#getResourceUrl(String)`: liefert die URL zu einem Pfad als `URL` zurück
- `MCRResourceHelper#getResourceAsStream(String)`: liefert direkt den Inhalt der zu einem Pfad als `InputStream` zurück

## Ressourcen-Pfade

Wie im Standard-Java-Mechanismen wird nach Ressourcen mit einem `/`-separierten Pfad gesucht, z.B. `/path/to/resource.txt`.
Zu jedem Pfad gibt es höchstens eine Ressource. MyCoRe bietet jedoch umfangreiche Möglichkeiten, diese zu überschreiben; z.B. basierend auf der Modul-Priorität.

Für Ressourcen-Pfade gelten in MyCoRe die folgenden Regeln:

- Sie werden immer als absolut angenommen. Ein führender `/` ist optional.
- Sie müssen immer eine „Datei“ referenzieren. Sie dürfen daher nicht mit einem `/` enden.
- Sie dürfen keine „Java-Klasse“ referenzieren. Sie dürfen daher nicht mit `.class` enden.
- Sie müssen diese Datei immer direkt referenzieren. Sie dürfen daher nicht die Segmente `.` oder `..` beinhalten.
- Sie dürfen keine leeren Segmente beinhalten.

Die Pfade `/path/to/resource.txt` und `path/to/resource.txt` sind äquivalent. Der Pfad `/path//to/./some/../resources/` ist ungültig,
weil er ein leeres Segment beinhaltet, die Segmente `.` und `..` beinhaltet und mit einem `/` endet.

MyCoRe stellt die Klasse `MCRResourcePath` bereit, um Ressourcen-Pfade zu repräsentieren. Instanzen können z.B.
mit den Methoden `MCRResourcePath#ofPath(String)` oder `MCRResourcePath#ofPathOrThrow(String)` erzeugt
und anschließend z.B. mit `MCRresourceResolver#resolve(MCRResourcePath)` verwendet werden.

> Die Repräsentation von Ressourcen-Pfaden ist bewusst simpel implementiert.
> Sie hat kein Konzept davon, was es für Pfade in (verschiedenen Kontexten) bedeutet, „relativ zueinander zu sein“.
> Code, der mit dem Resource-Resolver interagiert, ist dafür verantwortlich, absolute Pfade zu bilden.
> Diese Einschränkung soll verhindern, dass Dateien ungewollt als Ressourcen zur Verfügung stehen.
{.note}

Außerhalb von Java-Code, z.B. in einem XSL-Stylesheet, können Ressourcen mit dem URI-Resolver ermittelt werden.
Der URI-Resolver nutzt beim Auflösen der URI `resource:path/to/resource.txt` den Resource-Resolver mit dem Ressourcen-Pfad `/path/to/resource.txt`.

## Web-Ressourcen

*Web-Ressourcen* sind Ressourcen, deren Pfad mit `/META-INF/resources` beginnt.
Dies entspricht der Konvention von Java-Servlet-Containern.

Der Teil des Pfades einer Web-Ressource direkt inter dem Präfix `/META-INF/resources` ist der *Web-Pfad* dieser Web-Ressource.

Die Ressource mit dem Pfad `/META-INF/resources/path/to/web-resource.txt` ist identisch mit der Web-Resource mit dem Web-Pfad `/path/to/web-resource.txt`.

In einer klassischen Java-Web-Anwendung werden Web-Ressourcen mit Methoden wie `ServletContext#getResource(String)` genutzt.
Diese Methoden nehmen einen Web-Pfad als `String` und liefern, sofern eine entsprechende Web-Ressource vorhanden ist, eine zugehörige URL als `URL` zurück.
Über diese URL kann mit der eigentlichen Web-Ressource interagiert werden.

Für Web-Pfade gelten in MyCoRe die folgenden Regeln:

- Sie werden immer als absolut angenommen. Ein führender `/` ist optional.
- Sie dürfen nicht mit `/META-INF` oder `/WEB-INF` beginnen.

Der Ressourcen-Pfad `/META-INF/resources/META-INF/meta-resource.txt` ist ungültig, weil er den ungültigen Web-Pfad `/META-INF/meta-resource.txt` beinhaltet.

Alle Methoden der Klassen `MCRResourceResolver`, `MCRResourceHelper` und `MCRResourcePath` haben jeweils eine alternative Variante,
die direkt einen Web-Pfad entgegennimmt, z.B. `MCRResourceResolver#resolveWebResource(String)`, `MCRResourceHelper#getWebResourceUrl(String)` oder `MCRResourcePath#ofWebPath(String)`.
Im Java-Code einer MyCoRe-Anwendung sollte es keinen Bedarf geben, den Präfix `/META-INF/resources` direkt zu verwenden.

Außerhalb von Java-Code, z.B. in einem XSL-Stylesheet, können Web-Ressourcen mit dem URI-Resolver ermittelt werden.
Der URI-Resolver nutzt beim Auflösen der URI `webapp:path/to/web-resource.txt` den Resource-Resolver mit dem Web-Pfad `/path/to/web-resource.txt`.

### Auslieferung von Web-Ressourcen

Web-Ressourcen werden von MyCoRe direkt bereitgestellt, so wie dies auch in klassischen Java-Web-Anwendungen üblich ist.

Sofern kein Servlet oder Servlet-Filter konfiguriert ist, der einen eingehenden HTTP-Request beantwortet,
wird der Pfad des HTTP-Requests als Web-Pfad verwendet, eine entsprechende Web-Ressource mit dem Resource-Resolver gesucht und, falls vorhanden, ausgeliefert.

> Ist z.B. `https://my.mycore.de/repo` die Basis-URL der MyCoRe-Anwendung,
> so wird bei einer Anfrage von `https://my.mycore.de/repo/path/to/web-resource.txt`
> die Web-Ressource mit dem Web-Pfad `/path/to/web-resource.txt` verwendet.
> Dies entspricht der Ressource mit dem Ressourcen-Pfad `/META-INF/resources/path/to/web-resource.txt`.
{.note}

## Fundstellen von Ressourcen

Im Gegensatz zu den Standard-Java-Mechanismen sucht der Resource-Resolver nicht nur über den Classpath der Java-Anwendung nach Ressourcen.
Er sucht z.B. an verschiedenen Stellen im Dateisystem oder innerhalb von Programmbibliotheken (`*.jar`-Dateien),
die von der MyCoRe-Anwendung verwendet werden.

Hierbei kann über die Konfiguration der MyCoRe-Anwendung genau festgelegt werden,
welchen Fundstellen durchsucht werden sollen und in welcher Reihenfolge dies geschehen soll.
Zudem kann z.B. festgelegt werden, dass die Suchergebnisse gecacht werden sollen,
um nachfolgende Suchen nach bereits gesuchten Ressourcen zu beschleunigen.

In den meisten Fällen werden die in einer Fundstelle vorhandenen Dateien direkt als Ressourcen verwendet.

> Ist z.B. `/my/repo/resources` der Pfad zu einem als Fundstelle für Ressourcen verwendeten Verzeichnis im Dateisystem,
> so wird beim Suchen nach einer Ressource mit Pfad `/path/to/resource.txt` nach einer Datei
> mit Pfad `/my/repo/resources/path/to/resource.txt` gesucht.
{.note}

In manchen Fällen werden die in einer Fundstelle vorhandenen Dateien jedoch als Web-Ressourcen verwendet.

> Ist z.B. `/my/repo/web-resources` der Pfad zu einem als Fundstelle für Web-Ressourcen verwendeten Verzeichnisses im Dateisystem,
> so wird beim Suchen nach einer Ressource mit Pfad `/META-INF/ressources/path/to/web-resource.txt` nach einer Datei
> mit Pfad `/my/repo/web-resources/path/to/web-resource.txt` gesucht.
> Ressourcen ohne Präfix `/META-INF/ressources` in ihrem Pfad können in einer solchen Fundstelle nicht gefunden werden.
{.note}

MyCoRe stellt das Interface `MCRResourceProvider` bereit, um Fundstellen zu repräsentieren.
MyCoRe liefert zudem eine Reihe von Implementierungen für verschiedene Fundstellen
und weitere Implementierungen zum Kombinieren oder Modifizieren anderer Implementierungen.
Der Resource-Resolver verwendet genau einen Resource-Provider, um seine Aufgaben zu erfüllen.

## Konfiguration des Resource-Resolvers

Der Resource-Resolver ist Teil des Basis-Moduls von MyCoRe.
Dieses Modul beinhaltet eine Standardkonfiguration für den Resource-Resolver.
Diese Konfiguration ist für die meisten Fälle ausreichend.

**Typischerweise besteht keine Notwendigkeit, die Standardkonfiguration anzupassen oder auszutauschen.**

Dies muss nur dann gemach werden, wenn eine eigene MyCoRe-Anwendung besondere Bedarfe hat oder
auf einzelne Fundstellen der Standardkonfiguration verzichtet werden soll.
Letzteres kann für einen effizienteren Betrieb durchaus sinnvoll sein.

## Standardkonfiguration des Resource-Resolvers

<div class="w-75">{{< mcr-figure src="/images/documentation/basics/resources/res_default.png" class="border border-secondary" label="Abbildung 1" caption="Schematische Darstellung der Standardkonfiguration" width="100%" height="" />}}</div>

Die Standardkonfiguration kombiniert sieben tatsächliche Fundstellen. Die letzten vier dieser Fundstellen sind dabei in einem Cache,
da sich der Inhalt dieser Fundstellen zur Laufzeit einer MyCoRe-Anwendung typischerweise nicht ändern sollte und
die meisten Ressourcen typischerweise hier gefunden werden.

**Ist für einen Ressource-Pfad in mehreren Fundstellen eine Datei vorhanden, so wird die Datei aus der ersten solchen Fundstelle verwendet.**

Im einzelnen Umfasst die Standardkonfiguration die folgenden Fundstellen:

### Developer-Override

Ist ein [Developer-Override]({{< ref dev_devmode >}}) konfiguriert
(z.B. mit `MCR.Developer.Resource.Override=/path/to/overrideDir`),
so wird der Inhalt der dort genannten Verzeichnisse als Ressourcen verwendet.

```
/path/to/overrideDir/resource.txt
/path/to/overrideDir/META-INF/resources/web-resource.txt
```

Ist für einen Ressource-Pfad in mehreren dieser Verzeichnisse eine Datei vorhanden, so wird die Datei aus dem ersten solchen Verzeichnis verwendet.

### WCMS2

Ist das [WCMS2]({{< ref frontend_wcms >}})-Modul vorhanden, so wird der Inhalt des Speicherverzeichnisses
(typischerweise `/data/save/webpages` im [Konfigurationsverzeichnis]({{< ref basics_mcr_configdir >}}) der MyCoRe-Anwendung)
als Web-Ressourcen verwendet.

```
/path/to/configDir/data/save/webpages/web-resource.txt
```

### Konfigurationsverzeichnis

Der Inhalt von `/resources` im [Konfigurationsverzeichnis]({{< ref basics_mcr_configdir >}}) der MyCoRe-Anwendung wird als Ressourcen verwendet.

```
/path/to/configDir/resources/resource.txt
/path/to/configDir/resources/META-INF/resources/web-resource.txt
```

### Webapp-Verzeichnis

> Beim Laden einer Web-Anwendung extrahieren Servlet-Container (z.B. *Tomcat* oder *Jetty*) den Inhalt der `*.war`-Datei in das Webapp-Verzeichnis.
> Abgesehen von den Inhalten der Unterverzeichnisse `/META-INF` und `/WEB-INF` wird der Inhalt dieses Verzeichnisses in einer klassischen Standard-Java-Web-Anwendung
> vom Servlet-Container als Antwort auf HTTP-Requests ausgeliefert. Aus diesem Grund dürfen Web-Pfade auch in MyCoRe nicht mit `/META-INF` oder `/WEB-INF` beginnen.
{.note}

Der Inhalt des Webapp-Verzeichnisses wird als Web-Ressourcen verwendet.

```
/path/to/webappDir/web-resource.txt
```

> In einem typischen Maven-Projekt zum Erzeugen einer WAR-Datei müssen Dateien in das Verzeichnis `/src/main/webapp` gelegt werden,
> um vom Servlet-Container in das Webapp-Verzeichnis extrahiert zu werden.
{.note}

### Webapp-Klassenverzeichnis

Der Inhalt von `/WEB-INF/classes` im Webapp-Verzeichnis wird als Ressourcen verwendet.

```
/path/to/webappDir/WEB-INF/classes/resource.txt
/path/to/webappDir/WEB-INF/classes/META-INF/resources/web-resource.txt
```

> In einem typischen Maven-Projekt zum Erzeugen einer WAR-Datei müssen Dateien in das Verzeichnis `/src/main/resources` gelegt werden,
> um vom Servlet-Container in das Verzeichnis `/WEB-INF/classes` im Webapp-Verzeichnis extrahiert zu werden.
{.note}

### Programmbibliotheken

Der Inhalt der von der MyCoRe-Anwendung verwendeten Programmbibliotheken (`*.jar`-Dateien) wird als Ressourcen verwendet.
Hierbei kann es sich um MyCoRe-Anwendungsmodule oder normale Programmbibliotheken (z.B. WebJars) handeln.

Ist für einen Ressource-Pfad in mehreren Bibliotheken eine Datei vorhanden, so wird präferiert ein MyCoRe-Modul verwendet,
andernfalls wird, sofern möglich, die von `ServletContext#getAttribute(ServletContext.ORDERED_LIBS)` genannte Reihenfolge berücksichtigt. 

Ist für einen Ressource-Pfad in mehreren MyCoRe-Modulen eine Datei vorhanden, so wird die Datei aus dem MyCoRe-Modul mit der höchsten Modul-Priorität verwendet.

> Welche Mechanismen zum Auffinden von Programmbibliotheken zur Verfügung stehen,
> hängt u.A. vom verwendeten Servlet-Container und der verwendeten JVM ab.
> Bei _Tomcat_ können herzu Bibliotheken z.B. im Verzeichnis `/lib` im Installationsverzeichnis abgelegt werden.
> Zudem können weitere Bibliotheken mit der Umgebungsvariablen `CLASSPATH` eingebunden werden.
> Eine MyCoRe-Anwendung verwendet zusätzlich Programmbibliotheken im Verzeichnis `/lib` im Konfigurationsverzeichnis.
{.note}

### ClassLoader

Die mittels `ClassLoader#getResources(String)` gefundenen Ressourcen werden als solche verwendet.

Diese Fundstelle dient in der Standardkonfiguration nur als Fallback, um sicherzustellen,
dass alle von einer Standard-Java-Anwendung gefundenen Ressourcen auch von einer MyCoRe-Anwendung gefunden werden.
Alle in einer typischen MyCoRe-Anwendung verwendeten Ressourcen sollten jedoch bereits durch eine andere Fundstelle gefunden worden sein.

Sind für einen Ressource-Pfad in mehrere Ressourcen vorhanden, so wird die erstgenannte dieser Ressourcen verwendet.

> Diese Fundstelle wird zudem verwendet, wenn Tests aus einer IDE heraus ausgeführt werden, die hierzu einen Classpath dynamisch zusammenstellt.
{.note}
