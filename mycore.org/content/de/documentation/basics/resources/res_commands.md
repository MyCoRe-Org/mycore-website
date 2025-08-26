---

title: "Kommandos für den Resource-Resolver"
mcr_version: ['2025']
author: ['Torsten Krause']
date: '2025-09-01'

---

Im Gegensatz zu den Standard-Java-Mechanismen sucht der Resource-Resolver nicht nur über den Classpath der Java-Anwendung
oder sen Servlet-Context der Java-Web-Anwendung nach Ressourcen.

Über die Konfiguration der MyCoRe-Anwendung können mehrere Fundstellen konfiguriert werden, die durchsucht werden sollen.
Die Reihenfolge wird dabei genau festgelegt.

Dementsprechend kann es für einen Ressourcen-Pfad in der MyCoRe-Anwendung durchaus mehrere Ressourcen geben.
Der Resource-Resolver liefert die erste Ressource, die gefunden wird.

Die [Developer-Kommandos](../../../developer/dev_devmode#kommandos) stellen die folgenden Kommandos,
die Fragestellungen hierzu beantworten können.

## Auflösen der URL zu einem Ressourcen-Pfad

Das Kommando `show resource url for {0}` nimmt einen Ressourcen-Pfad und liefert die dazu vom Resource-Resolver gefundene URL.

Das Kommando `show all resource urls for {0}` nimmt einen Ressourcen-Pfad und liefert alle dazu vom Resource-Resolver gefundene URLs.

Möchte man beispielsweise wissen, welche Version des Stylesheets `mods2dc.xsl` tatsächlich verwendet wird, 
so kann dies mit dem Kommando `show resource url for xsl/mods2dc.xsl` ermittelt werden.

```
INFO: Processing command: 'show resource url for xsl/mods2dc.xsl' (0 left)
...
INFO: Resolved resource /xsl/mods2dc.xsl as jar:file:/opt/tomcat/webapps/ROOT/WEB-INF/lib/mir-module-2025.06.jar!/xsl/mods2dc.xsl
INFO: Command processed (2 ms)
```

Möchte man beispielsweise wissen, welche Versionen des Stylesheets `mods2dc.xsl` zudem vorhanden sind
und in welcher Reihenfolge diese vom Resource-Resolver gefunden werden, 
so kann dies mit dem Kommando `show all resource urls for xsl/mods2dc.xsl` ermittelt werden.

```
INFO: Processing command: 'show all resource urls for xsl/mods2dc.xsl' (0 left)
...
INFO: Resolved resource /xsl/mods2dc.xsl as jar:file:/opt/tomcat/webapps/ROOT/WEB-INF/lib/mir-module-2025.06.jar!/xsl/mods2dc.xsl [all resources / app resources / library resources]
INFO: Resolved resource /xsl/mods2dc.xsl as jar:file:/opt/tomcat/webapps/ROOT/WEB-INF/lib/mycore-mods-2025.06.jar!/xsl/mods2dc.xsl [all resources / app resources / library resources]
INFO: Resolved resource /xsl/mods2dc.xsl as jar:file:/opt/tomcat/webapps/ROOT/WEB-INF/lib/mir-module-2025.06.jar!/xsl/mods2dc.xsl [all resources / app resources / fallback resources]
INFO: Resolved resource /xsl/mods2dc.xsl as jar:file:/opt/tomcat/webapps/ROOT/WEB-INF/lib/mycore-mods-2025.06.jar!/xsl/mods2dc.xsl [all resources / app resources / fallback resources]
INFO: Command processed (7 ms)
```

Hierbei wird für jede gefundene Ressource in eckigen Klammern angegeben, von welchem Resource-Provider die jeweilige Ressource gefunden wurde.
Dabei werden die `Coverage`-Konfigurationswerte aus der Konfiguration der Resource-Provider verwendet.

Im Beispiel werden zwei MyCoRe-Module gefunden, die die genannte Ressource beinhalten.
Beide Ressourcen werden sowohl über den als `library resources` konfigurierten `MCRLibraryResourceProvider` als auch 
über den als `fallback resources` konfigurierten `MCRClassLoaderResourceProvider` gefunden.

> Um noch mehr Details über den Auswahlprozess der Resource zu erfahren, kann das Log-Level für den Resource-Resolver
> mit dem Kommando `change log level of org.mycore.resource.MCRResourceResolver to TRACE` umgestellt werden.
> Führt man nun z.B. das Kommando `show resource url for xsl/mods2dc.xsl` aus, wird in der Log-Ausgabe folgendes ausgegeben:
> 
> ```text
> [INFO] 2025-06-01T12:00:00,000 TRACE administrator MCRResourceResolver: Tracing resource URL for path /xsl/mods2dc.xsl
> [INFO] ├─ MCRDeveloperOverrideResourceProvider [developer override resources]:
> [INFO] │  └─ Providing no resource URL
> [INFO] ├─ MCRWCMSWebResourceProvider [WCMS web resources]:
> [INFO] │  ├─ Looking for directory /home/mcr/.mycore/data/save/webpages
> [INFO] │  ├─ /home/mcr/.mycore/data/save/webpages doesn't exist
> [INFO] │  └─ Providing no resource URL
> [INFO] ├─ MCRConfigDirResourceProvider [config dir resources]:
> [INFO] │  ├─ Looking for directory /home/mcr/.mycore/resources
> [INFO] │  ├─ Looking for file /home/mcr/.mycore/resources/xsl/mods2dc.xsl
> [INFO] │  ├─ /home/mcr/.mycore/resources/xsl/mods2dc.xsl doesn't exist
> [INFO] │  └─ Providing no resource URL
> [INFO] ├─ MCRCachingResourceProvider [cached app resources]:
> [INFO] │  ├─ Cache hit for /xsl/mods2dc.xsl
> [INFO] │  └─ Providing resource URL jar:file:/opt/tomcat/webapps/ROOT/WEB-INF/lib/mir-module-2025.06.jar!/xsl/mods2dc.xsl
> [INFO] ├─ Got resource URL from MCRCachingResourceProvider, no need for further providers
> [INFO] └─ Providing resource URL jar:file:/opt/tomcat/webapps/ROOT/WEB-INF/lib/mir-module-2025.06.jar!/xsl/mods2dc.xsl
> ```
> 
> Die Ausgabe folgt strukturell den konfigurierten Resource-Providern. Es werden nacheinander die konfigurieren Instanzen von
> `MCRDeveloperOverrideResourceProvider`, `MCRWCMSWebResourceProvider`, `MCRConfigDirResourceProvider` und `MCRCachingResourceProvider`
> befragt. Letzterer hat in diesem Beispiel bereits ein gecachtes Ergebnis und gibt dieses zurück.
> Die verbliebenen Resource-Provider werden nicht befragt.
> 
> Das Kommando `show all resource urls for xsl/mods2dc.xsl` würde zu einer noch umfangreicheren Ausgabe führen,
> da bei diesem Kommando immer alle Resource-Provider befragt werden und ein ggf. gecachtes Ergebnis ignoriert wird.
{.note}

## Auflösen des Inhalts einer Ressource

Möchte man den Inhalt einer Ressource ermitteln, kann dies im Falle von XML-Dateien mit dem Kommando
`resolve uri resource:path/to/resource.xml` erledigt werden.

Ressourcen sind jedoch nicht zwangsweise XML-Dateien. Als Ressourcen können beliebige Dateien verwendet werden.
Dies müssen nicht einmal Textdateien sein. Daher gibt es für Ressourcen die folgenden zusätzlichen Kommandos.

Das Kommando `resolve textual resource {0}` zeigt den Inhalt einer Textdatei, die als Ressource mit dem gegebenem Ressourcen-Pfad gefunden wird.
Hierbei wird der Zeichensatz `UTF-8` verwendet.
Beim Kommando `resolve textual resource {0} with charset {1}` kann zudem der zu verwendende Zeichensatz vorgegeben werden.

Das Kommando `resolve binary resource {0}` zeigt den Inhalt einer beliebigen Datei, die als Ressource mit dem gegebenem Ressourcen-Pfad gefunden wird.
Hierbei wird der Inhalt Base-64-encoded ausgegeben.
Beim Kommando `resolve binary resource {0} with encoder {1}` kann zudem das zu verwendende Encoding angegeben werden.
MyCoRe unterstützt aktuell jedoch nur das standardmäßig verwendete Encoding `BASE_64`.

## Auflösen der URL zu einem Web-Pfad

Das Kommando `show web resource url for {0}` nimmt einen Web-Pfad und liefert die dazu vom Resource-Resolver gefundene URL.

Das Kommando `show all web resource urls for {0}` nimmt einen Web-Pfad und liefert alle dazu vom Resource-Resolver gefundene URLs.

Möchte man beispielsweise wissen, welche Version der Datei `navigation.xml` tatsächlich verwendet wird,
so kann dies mit dem Kommando `show web resource url for config/navigation.xml` ermittelt werden.

```
INFO: Processing command: 'show web resource url for config/navigation.xml' (0 left)
...
INFO: Resolved resource /META-INF/resources/config/navigation.xml as file:/home/mcr/.mycore/resources/META-INF/resources/config/navigation.xml
INFO: Command processed (2 ms)
```

Möchte man beispielsweise wissen, welche Versionen der Datei `navigation.xml` zudem vorhanden sind
und in welcher Reihenfolge diese vom Resource-Resolver gefunden werden,
so kann dies mit dem Kommando `show all web resource urls for config/navigation.xml` ermittelt werden.

```
INFO: Processing command: 'show all web resource urls for config/navigation.xml' (0 left)
...
INFO: Resolved resource /META-INF/resources/config/navigation.xml as file:/home/mcr/.mycore/resources/META-INF/resources/config/navigation.xml [all resources / config dir resources]
INFO: Resolved resource /META-INF/resources/config/navigation.xml as jar:file:/opt/tomcat/webapps/ROOT/WEB-INF/lib/mir-module-2025.06.jar!/META-INF/resources/config/navigation.xml [all resources / app resources / library resources]
INFO: Resolved resource /META-INF/resources/config/navigation.xml as jar:file:/opt/tomcat/webapps/ROOT/WEB-INF/lib/mir-module-2025.06.jar!/META-INF/resources/config/navigation.xml [all resources / app resources / fallback resources]
INFO: Command processed (7 ms)
```

Hierbei wird für jede gefundene Ressource in eckigen Klammern angegeben, von welchem Resource-Provider die jeweilige Ressource gefunden wurde.
Dabei werden die `Coverage`-Konfigurationswerte aus der Konfiguration der Resource-Provider verwendet.

Im Beispiel wird eine Datei im Konfigurationsverzeichnis über den als `config dir resources` konfigurierten
`MCRConfigDirResourceProvider` gefunden. Zudem wird ein MyCoRe-Modul gefunden, die die genannte Web-Ressource beinhalten.
Diese Ressource werd sowohl über den als `library resources` konfigurierten `MCRLibraryResourceProvider`
als auch über den als `fallback resources` konfigurierten `MCRClassLoaderResourceProvider` gefunden.

> Um noch mehr Details über den Auswahlprozess der Web-Resource zu erfahren, kann das Log-Level für den Resource-Resolver
> mit dem Kommando `change log level of org.mycore.resource.MCRResourceResolver to TRACE` umgestellt werden.
> Führt man nun z.B. das Kommando `show web resource url for config/navigation.xml` aus, wird in der Log-Ausgabe folgendes ausgegeben:
>
> ```text
> [INFO] 2025-06-01T12:00:00,000 TRACE administrator MCRResourceResolver: Tracing resource URL for path /META-INF/resources/config/navigation.xml
> [INFO] ├─ MCRDeveloperOverrideResourceProvider [developer override resources]:
> [INFO] │  └─ Providing no resource URL
> [INFO] ├─ MCRWCMSWebResourceProvider [WCMS web resources]:
> [INFO] │  ├─ Looking for directory /home/mcr/.mycore/data/save/webpages
> [INFO] │  ├─ /home/mcr/.mycore/data/save/webpages doesn't exist
> [INFO] │  └─ Providing no resource URL
> [INFO] ├─ MCRConfigDirResourceProvider [config dir resources]:
> [INFO] │  ├─ Looking for directory /home/mcr/.mycore/resources
> [INFO] │  ├─ Looking for file /home/mcr/.mycore/resources/META-INF/resources/config/navigation.xml
> [INFO] │  └─ Providing resource URL file:/home/mcr/.mycore/resources/META-INF/resources/config/navigation.xml
> [INFO] ├─ Got resource URL from MCRConfigDirResourceProvider, no need for further providers
> [INFO] └─ Providing resource URL file:/home/mcr/.mycore/resources/META-INF/resources/config/navigation.xml
> ```
>
> Die Ausgabe folgt strukturell den konfigurierten Resource-Providern. Es werden nacheinander die konfigurieren Instanzen von
> `MCRDeveloperOverrideResourceProvider`, `MCRWCMSWebResourceProvider` und `MCRConfigDirResourceProvider`
> befragt. Letzterer hat in diesem Beispiel bereits ein Ergebnis und gibt dieses zurück.
> Die verbliebenen Resource-Provider werden nicht befragt.
>
> Das Kommando `show all web resource urls for config/navigation.xml` würde zu einer noch umfangreicheren Ausgabe führen,
> da bei diesem Kommando immer alle Resource-Provider befragt werden und ein ggf. gecachtes Ergebnis ignoriert wird.
{.note}

## Auflösen des Inhalts einer Web-Ressource

Möchte man den Inhalt einer Ressource ermitteln, kann dies im Falle von XML-Dateien mit dem Kommando
`resolve uri webapp:path/to/web-resource.xml` erledigt werden.

Web-Ressourcen sind jedoch nicht zwangsweise XML-Dateien. Als Web-Ressourcen können beliebige Dateien verwendet werden.
Dies müssen nicht einmal Textdateien sein. Daher gibt es für Web-Ressourcen die folgenden zusätzlichen Kommandos.

Das Kommando `resolve textual web resource {0}` zeigt den Inhalt einer Textdatei, die als Web-Ressource mit dem gegebenem Web-Pfad gefunden wird.
Hierbei wird der Zeichensatz `UTF-8` verwendet.
Beim Kommando `resolve textual web resource {0} with charset {1}` kann zudem der zu verwendende Zeichensatz vorgegeben werden.

Das Kommando `resolve binary web resource {0}` zeigt den Inhalt einer beliebigen Datei, die als Web-Ressource mit dem gegebenem Web-Pfad gefunden wird.
Hierbei wird der Inhalt Base-64-encoded ausgegeben.
Beim Kommando `resolve binary web resource {0} with encoder {1}` kann zudem das zu verwendende Encoding angegeben werden.
MyCoRe unterstützt aktuell jedoch nur das standardmäßig verwendete Encoding `BASE_64`.
