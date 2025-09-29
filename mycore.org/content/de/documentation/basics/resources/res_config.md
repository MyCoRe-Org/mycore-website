---

title: "Konfiguration des Resource-Resolvers"
mcr_version: ['2025.06']
author: ['Torsten Krause']
date: '2025-09-01'

---

Die wichtigste Konfiguration des Resource-Resolvers ist der verwendete Resource-Provider.
Typischerweise wird dabei eine Kombination aus mehreren Resource-Providern zusammengestellt, die eine baumartige Struktur hat.

Für eine Kombination wird der Konfigurationsschlüssel der Form `MCR.Resource.Resolver.Providers.`_`name`_`.Class` verwendet,
wobei _`name`_ ein frei wählbarer Name für die jeweilige Kombination ist.
Die referenzierte Klasse muss das Interface `MCRResourceProvider` implementieren.

Die tatsächlich verwendete Kombination wird mit dem Konfigurationsschlüssel `MCR.Resource.Resolver` gewählt.
Dieser Mechanismus erlaubt den schnellen Wechsel zwischen verschiedenen Konfigurationen.

> Sollen Ressourcen z.B. wie in einer Standard-Java-Anwendung ausschließlich über den ClassLoader gesucht werden,
> kann dies mit einem `MCRClassLoaderResourceProvider` folgendermaßen erreicht werden:
> 
> ```
> MCR.Resource.Resolver.Providers.example.Class=org.mycore.resource.provider.MCRClassLoaderResourceProvider
> MCR.Resource.Resolver=example
> ```
{.note}

Im Basis-Modul von MyCoRe sind zwei derartige Kombinationen vorbereitet.
Eine Kombination mit Namen `default` für die [Standardkonfiguration]({{< ref "res_index#standardkonfiguration-des-resource-resolvers" >}}) und
eine Kombination mit Namen `legacy`, die eher das Verhalten von MyCoRe vor {{<mcr-version "2023.08">}} weitestgehend nachbildet
(siehe [Migrationsanleitung]({{< ref "migrate_mcr2024_06#migrationsschritte" >}})).
Die Kombination mit Namen `default` ist dabei als die tatsächlich verwendete Kombination gesetzt.

Im Falle einer Kombination aus mehreren Resource-Providern kann der „Sinn und Zweck“ der einzelnen Resource-Provider
jeweils mit dem Konfigurationsparameter `Coverage` festgelegt werden. Diese Angabe dient lediglich der Dokumentation
und wird in verschiedene Ausgaben integriert. Zudem kann jeder Resource-Provider
mit dem Konfigurationsparameter `Enabled` einzeln aus der Konfiguration ausgeschlossen werden.
Wird ein solcher Parameter auf `false` gesetzt, hat dies denselben Effekt,
als hätte man den zugehörigen Resource-Provider komplett aus der Konfiguration entfernt.
Dieser Mechanismus erlaubt das schnelle Hinzufügen und Entfernen einzelner Resource-Provider.

Resource-Provider-Implementierungen können zudem individuelle Konfigurationsparameter haben.

> Sollen Ressourcen z.B. wie in einer Standard-Java-Anwendung ausschließlich über den ClassLoader gesucht werden,
> aber gelegentlich für Debug-Zwecke auch ein Developer-Override verwendet werden, kann dies
> mit einem `MCRClassLoaderResourceProvider` und einem `MCRDeveloperOverrideResourceProvider`, die durch einen
> `MCRCombinedResourceProvider` kombiniert sind, folgendermaßen erreicht werden:
>
> ```
> MCR.Resource.Resolver.Providers.example.Class=org.mycore.resource.provider.MCRCombinedResourceProvider
> MCR.Resource.Resolver.Providers.example.Providers.10.Class=org.mycore.resource.provider.MCRDeveloperOverrideResourceProvider
> MCR.Resource.Resolver.Providers.example.Providers.10.Coverage=debug resource override
> MCR.Resource.Resolver.Providers.example.Providers.10.Enabled=false
> MCR.Resource.Resolver.Providers.example.Providers.20.Class=org.mycore.resource.provider.MCRClassLoaderResourceProvider
> MCR.Resource.Resolver=example
> ```
> Für den `MCRClassLoaderResourceProvider` wird der individuelle Konfigurationsparameter `Providers` verwendet,
> über den eine Liste von Resource-Providern konfiguriert werden kann.
{.note}

Die in MyCore verfügbaren Resource-Provider können der [JavaDoc-Dokumentation](https://javadoc.io/doc/org.mycore/mycore-base/latest/org/mycore/resource/provider/package-summary.html)
entnommen werden. Hier werden auch die jeweils verfügbaren individuellen Konfigurationsparameter beschrieben.

## Standardkonfiguration des Resource-Resolvers

<div class="w-75">{{< mcr-figure src="/images/documentation/basics/resources/res_default.png" class="border border-secondary" label="Abbildung 1" caption="Schematische Darstellung der Standardkonfiguration" width="100%" height="" />}}</div>

Die Standardkonfiguration nutzt die bisher beschriebenen Mechanismen, um mehrere Resource-Provider zu kombinieren.
Dabei kommen neben den Resource-Providern für die eigentlichen Fundstellen zwei `MCRCombinedResourceProvider`
und ein `MCRCachingResourceProvider` zum Einsatz:

```
MCR.Resource.Resolver.Providers.default.Class=org.mycore.resource.provider.MCRCombinedResourceProvider
MCR.Resource.Resolver.Providers.default.Coverage=all resources
MCR.Resource.Resolver.Providers.default.Providers.10.Class=org.mycore.resource.provider.MCRDeveloperOverrideResourceProvider
MCR.Resource.Resolver.Providers.default.Providers.15.Class=org.mycore.wcms2.MCRWCMSWebResourceProvider
MCR.Resource.Resolver.Providers.default.Providers.20.Class=org.mycore.resource.provider.MCRConfigDirResourceProvider
MCR.Resource.Resolver.Providers.default.Providers.30.Class=org.mycore.resource.provider.MCRCachingResourceProvider
MCR.Resource.Resolver.Providers.default.Providers.30.Coverage=cached app resources
MCR.Resource.Resolver.Providers.default.Providers.30.Capacity=1000
MCR.Resource.Resolver.Providers.default.Providers.30.Provider.Class=org.mycore.resource.provider.MCRCombinedResourceProvider
MCR.Resource.Resolver.Providers.default.Providers.30.Provider.Coverage=app resources
MCR.Resource.Resolver.Providers.default.Providers.30.Provider.Providers.10.Class=org.mycore.resource.provider.MCRWebappDirWebResourceProvider
MCR.Resource.Resolver.Providers.default.Providers.30.Provider.Providers.20.Class=org.mycore.resource.provider.MCRWebappClassesDirResourceProvider
MCR.Resource.Resolver.Providers.default.Providers.30.Provider.Providers.30.Class=org.mycore.resource.provider.MCRLibraryResourceProvider
MCR.Resource.Resolver.Providers.default.Providers.30.Provider.Providers.40.Class=org.mycore.resource.provider.MCRClassLoaderResourceProvider
MCR.Resource.Resolver.Providers.default.Providers.30.Provider.Providers.40.Coverage=fallback resources
```

> Der `MCRWCMSWebResourceProvider` wird nur in die Standardkonfiguration integriert, wenn das [WCMS2]({{< ref frontend_wcms >}})-Modul vorhanden ist.
> Die numerischen Werte in den Listen von Resource-Providern sind so gewählt, dass auch eigene Module weitere Resource-Provider
> in die Standardkonfiguration integrieren können.
{.note}

Während der [Initialisierung]({{< ref basics_lifecycle >}}) der MyCoRe-Anwendung wird im Log die Struktur
der tatsächliche gewählten Kombination ausgegeben. Für die Standardkonfiguration sieht diese Ausgabe folgendermaßen aus:

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
         └─ Coverage: fallback resources
```

## Dynamische Parameter

> Die verschiedenen Resource-Provider-Implementierungen benötigen teilweise,
> neben dem Ressourcen-Pfad der gesuchten Ressource, weitere Parameter.
> Zugleich teilen sich alle Implementierungen dasselbe Interface.
> Die Methoden zum Suchen nach Ressourcen können daher keine individuellen Parameter haben. 
>
> Um Parameter in die Suche nach einer Ressource einfließen zu lassen,
> haben die Methoden von `MCRResourceResolver` jeweils eine alternative Variante.
> Diese hat neben dem Ressource-Pfad eine typsichere Hashmap in Form von `MCRHints` als weiteren Parameter.
>
> Die Klasse `MCRResourceHintKeys` definiert die von MyCoRe verwendeten Schlüssel für eine solche Hashmap.
> Zu jedem Schlüssel implementiert MyCoRe je einen passenden `MCRHint`.
> 
> Eigene Module können weitere Schlüssel definieren und zugehörige Hint-Implementierungen bereitstellen,
> um damit zusätzliche Parameter in die Ressourcen-Suche einfließen zu lassen,
> falls eigene Resource-Provider-Implementierungen diese benötigen.
{.note}

Der Resource-Resolver wird neben dem zu verwendenden Resource-Provider mit
einer typsicheren Hashmap von zusätzlichen Parametern initialisiert, den *Hints*.
Diese Hints werden standardmäßig bei jeder Suche nach einer Ressource verwendet.
Je nach Implementierung eines Hints können tatsächliche  Werte während der Initialisierung des Resource-Resolvers
oder dynamisch zur Laufzeit ermittelt werden.

Um eigene Parameter in diese Hints aufzunehmen, werden Konfigurationsschlüssel
der Form `MCR.Resource.Resolver.Hints.`_`name`_`.Class` verwendet,
wobei _`name`_ ein frei wählbarer Name für den jeweiligen Parameter ist.
Die referenzierte Klasse muss das Interface `MCRHint` implementieren.

Wie bei den Resource-Providern kann auch jeder Hint mit dem Konfigurationsparameter `Enabled`
einzeln aus der Konfiguration ausgeschlossen werden.

Die Standardkonfiguration stellt über diesen Mechanismus die folgenden Hints bereit:

| Hint-Schlüssel                   | Hint-Implementierung                   | Verwendeter Wert                                                                                                                 |
|----------------------------------|----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------|
| `CLASS_LOADER`                   | `MCRClassLoaderResourceHint`           | Der von `MCRClassTools`​`#getClassLoader()` gelieferte `ClassLoader`                                                             |
| `CLASSPATH_DIRS_PROVIDER`<span/> | `MCRClasspathDirsProviderResourceHint` | Der konfigurierte `MCRClasspathDirsProvider`                                                                                     |
| `COMPONENTS`                     | `MCRComponentsResourceHint`            | Die von `MCRRuntimeComponentDetector`​`#getAllComponents(HIGHEST_PRIORITY_FIRST)` bereitgestellte Liste von MyCoRe-Komponenten.  |
| `CONFIG_DIR`                     | `MCRConfigDirResourceHint`             | Das von `MCRConfigurationDir`​`#getConfigurationDirectory()` bereitgestellte Konfigurationsverzeichnis.                          |
| `SERVLET_CONTEXT`                | `MCRServletContextResourceHint`        | Der `ServletContext` der Web-Anwendung, falls vorhanden.                                                                         |
| `WEBAPP_DIR`                     | `MCRWebappDirResourceHint`             | Das Webapp-Verzeichnis der Web-Anwendung, falls vorhanden.                                                                       |
{.table}
<br/>

> Von besonderer Bedeutung ist hierbei die Klasse `MCRClasspathDirsProviderResourceHint`.
> Dieser Hint stellt optional eine mit dem individuellen Konfigurationsparameter `ClasspathDirsProvider`
> konfigurierte Implementierung von `MCRClasspathDirsProvider` bereit.
> Ein `MCRClasspathDirsProvider` wiederum liefert die Liste der Verzeichnisse im Dateisystem,
> die vom verwendeten `ClassLoader` genutzt werden, um u.A. nach Ressourcen zu suchen.
>
> Standardmäßig ist die Implementierung `MCRSystemPropertyClasspathDirsProvider` konfiguriert.
> Diese wertet das Java-System-Property `java.class.path` aus und entnimmt aus dieser Liste
> nur die Einträge für Verzeichnisse im Dateisystem.
>
> Wenn ein eigenes MyCoRe-Modul dem Classpath des verwendeten ClassLoaders zur Laufzeit
> weitere Verzeichnisse hinzufügt, finden sich diese Verzeichnisse jedoch nicht im genannte Java-System-Property wieder.
> In diesem Fall muss für eine korrekte Funktion die Klasse `MCRClassgraphClasspathDirsProvider`
> verwendet und zudem die Programmbibliothek
> [`io.github.classgraph:classgraph`](https://central.sonatype.com/artifact/io.github.classgraph/classgraph)
> bereitgestellt werden. Die Konfiguration muss in diesem Fall folgendermaßen angepasst werden:
>
> ```
> MCR.Resource.Resolver.Hints.classpathDirsProvider.Class=org.mycore.resource.hint.MCRClasspathDirsProviderResourceHint
> MCR.Resource.Resolver.Hints.classpathDirsProvider.ClasspathDirsProvider.Class=org.mycore.resource.common.MCRClassgraphClasspathDirsProvider
> ```
{.note}

## Globale Parameter

Für Resource-Provider, die im Dateisystem nach Ressourcen suchen,
kann die zu berücksichtigende Liste von `LinkOption`-Werten global konfiguriert werden.
Hierzu kann der Konfigurationsschlüssel `MCR.Resource.Common.LinkOptions` verwendet werden.
Standardmäßig ist hier der Wert `NOFOLLOW_LINKS` konfiguriert.

Wenn bei der Such nach Ressourcen im Dateisystem auch Soft-Links gefolgt werden soll,
muss die Konfiguration wie folgt angepasst werden:

```
MCR.Resource.Common.LinkOptions=
```
