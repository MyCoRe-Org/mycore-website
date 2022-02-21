
---

title: "Versionierung mit OCFL in MyCoRe"
description: ""
mcr_version: ['2021.11']
author: ['Kathleen Neumann', 'Jens Kupferschmidt', 'Robert Stephan', 'Tobias Lenhardt']
date: "2022-02-21"

---

## Allgemeines

[OCFL <sup><i class="fas fa-external-link-alt"></i></sup>](https://ocfl.io/), das Oxford Common File Layout, ist ein Konzept zur Speicherung von Daten in einer versionierten Form auf einem nativen Plattenbereich. Somit kann der Vorteil einer einfachen
Speicherung im Dateisystem mit dem einer Dateiversionierung optimal verbunden werden. Dies wurde mithilfe der [Java OCFL Libary der UW-Madison <sup><i class="fas fa-external-link-alt"></i></sup>](https://github.com/UW-Madison-Library/ocfl-java) realisiert. Die MyCoRe-Entwickler arbeiten seit 2020 an der Integration dieser Form der Datenablage in MyCoRe und in dem Snapshot der 2021.06 Version wurde es prototypisch Implementiert. Mit dem Release {{<mcr-version "2021.11">}} ist dies nun auch für Produktivanwendungen als Beta verfügbar und kann genutzt werden um Objekte in OCFL zu speichern. Geplant ist, dass mit dem Release in 2022 die OCFL Implementierung fertiggestellt wird und somit die Beta-Phase verlässt.

Die "OCFL-Beta" bedeutet, das bisher noch nicht alles im OCFL gespeichert werden kann, aber es nicht mehr zu schwerwiegenden Änderungen kommen wird. Die zukünftigen Änderungen bauen auf diese Implementierung auf, ohne das Konflikte für den Nutzer entstehen.

## Zukünftige Pläne

Derzeit ist es nur möglich, Objekte und Derivate zu speichern. Es ist geplant, dass man viele weiteren Dateitypen von MyCoRe mit im OCFL speichern kann. Beispielsweise soll man Zukünftig Benutzer, Klassifikationen und mehr mit im OCFL speichern können.

# Die Speicherung der MyCoRe-Objekte mit OCFL

## Konfiguration

Um OCFL zu nutzen, muss zuerst das entsprechende MyCoRe-Modul in der *pom.xml* integriert werden.

{{<mcr-comment>}}
<!-- folgendes ist auch ein Hugo Shortcode, funktioniert fast genauso wie die HTML Variante 
     für mehr Info, siehe: https://gohugo.io/content-management/syntax-highlighting/ -->
{{</mcr-comment>}}
```xml {linenos=table}
 <dependency>
    <groupId>org.mycore</groupId>
    <artifactId>mycore-ocfl</artifactId>
    <version>${mycore.version}</version>
 </dependency>
```

{{<mcr-comment>}}
<!-- {{< highlight xml "linenos=false">}}
 <dependency>
    <groupId>org.mycore</groupId>
    <artifactId>mycore-ocfl</artifactId>
    <version>${mycore.version}</version>
 </dependency>
{{< /highlight >}} -->
{{</mcr-comment>}}

Die folgenden Properties werden in dieser Form im Code als Standardwerte mitgeliefert.

```shell {linenos=table}
MCR.CLI.Classes.Internal=%MCR.CLI.Classes.Internal%,org.mycore.ocfl.commands.MCROCFLCommands

# Setzt die Standard Repository auf "Main"
MCR.Metadata.Manager.Repository=Main

# Definitionen für die Repository "Main"
MCR.OCFL.Repository.Main=org.mycore.ocfl.MCROCFLHashRepositoryProvider
MCR.OCFL.Repository.Main.RepositoryRoot=%MCR.datadir%/ocfl-root
MCR.OCFL.Repository.Main.WorkDir=%MCR.datadir%/ocfl-temp
```

Diese können, sofern erwünscht, überschrieben werden. Es ist darauf zu achten,
dass der Repository Provider von dem `MCROCFLRepositoryProvider` vererbt ist.

Mit dem folgendem Property kann der Metadaten Manager von XML zu OCFL umgestellt werden:

```shell {linenos=table}
 MCR.Metadata.Manager=org.mycore.ocfl.MCROCFLXMLMetadataManager
```

Will man seine eigene Repository anlegen, geht das wie folgt:

```shell {linenos=table}
#Repository Provider für verschiedene Layouts
MCR.OCFL.Repository.{Repository_Name}=org.mycore.ocfl.{Repository_Provider}
#Pfad zum Unterverzeichnis für Dateispeicherung
MCR.OCFL.Repository.{Repository_Name}.RepositoryRoot=%MCR.datadir%/foo
#Pfad zum Unterverzeichnis für Zwischenspeicher
MCR.OCFL.Repository.{Repository_Name}.WorkDir=%MCR.datadir%/bar
```

### Liste der Repository Provider in MyCoRe

{{<mcr-table id="repository-provider-list" class="table" style="" col-styles="">}}
   | Repository Provider | Layout |
   | :------------------ | :----- |
   | MCROCFLHashRepositoryProvider | [0003 Hashed Truncated N-tuple Trees with Object ID Encapsulating Directory](#ocfl-community-extension-0003-hashed-truncated-n-tuple-trees-with-object-id-encapsulating-directory-for-ocfl-storage-hierarchies) |
   | MCROCFLMCRRepositoryProvider | [MyCoRe Storage Layout](#mycore-storage-layout) |
{{</mcr-table>}}

Mehr Erklärung zu den Repository Providern kann im Abschnitt [Layout Liste](#verfügbare-repository-layouts) gefunden werden.

{{<mcr-comment>}}
<!-- ## Infos zu der Migration zu OCFL

*<u>Notiz:</u> Migration von XML sowie SVN möglich, zwischen OCFL, also nicht final und auch zurück zu nativ XML via export, falls SVN benutzt wird, sollte man bis man sich sicher ist das einem das neue System besser gefällt, keine wichtigen Änderungen vornehmen, da eine Migration zurück zu SVN <u>NICHT</u> möglich ist.* -->
{{</mcr-comment>}}

## Migration zu OCFL

Für die Prozedur sollte sichergestellt werden, dass die Daten nicht von Nutzern bearbeitet werden.

Zunächst wird der Metadaten-Manager bei dem Nativen belassen und es soll sichergestellt werden,
dass die Repository `Main` oder die eigene Repository korrekt eingerichtet sind.

Mit dem Kommando `migrate metadata to repository {Repository}` können die Daten in die angegebene Repository überspielt werden.
Das Kommando gibt eine Statistik aus, ob alle Metadaten migriert werden konnten.

Auch wenn keine Fehler zu sehen sind, sollte man trotzdem die Anzahl überprüfen, ob alle Objekte erfolgreich übertragen wurden.

Wenn alles geklappt hat, dann kann man den MetadatenManager umstellen.

## Migration zwischen Layouts

Die Migration zwischen den OCFL Layouts funktioniert genauso wie zu OCFL,
der einzige Unterschied ist das hierbei der Metadaten-Manager des OCFL zu nutzen ist.

Um eine Repository zu Migrieren, ist die Quell-Repository mit
`MCR.Metadata.Manager.Repository={Quell-Repository}`
zu setzen.

Die Ziel Repository muss manuell gesetzt werden (siehe [Konfiguration](#konfiguration)), diese Repository darf nicht den gleichen Typ (Repository Provider) haben wie die Quelle. Wird dies trotzdem benötigt, ist es abzuwägen, ob es nicht besser ist, die Repository einfach zu kopieren.

Hierbei kann es manchmal vorkommen, dass ein `MCRUsageException` ausgelöst wird. Dies tritt dann auf,
wenn Objekte vor der Migration zu OCFL gelöscht wurden und es versucht wird, ein Property zu lesen, da MyCoRe diese ID noch immer bekannt ist. Die Datei existiert aber nicht mehr.\
Dies wird in zukünftigen Versionen behoben werden, <u>hat aber keinen Impakt in die Funktionsweise von OCFL</u>.

## Verfügbare Repository Layouts
### OCFL Community Extension 0003: Hashed Truncated N-tuple Trees with Object ID Encapsulating Directory for OCFL Storage Hierarchies

Das *0003-hash-and-id-n-tuple-storage-layout* ist das Standard Layout in MyCoRe. Es ist ein Layout aus den offiziellen Community Extensions für OCFL. Dadurch lässt sich ein Repository mit dem *0003-hash-and-id-n-tuple-storage-layout* durch externe Programme einfach einsehen und verändern. Aus den Dateinamen wird ein Hashwert gebildet, mit dem danach die Ordnerstruktur gebildet wird.

Der Vorteil ist wie erwähnt, das es kompatibel ist mit externen Tools für OCFL Repositories. Mit diesen kann man auch ohne MyCoRe Änderungen vornehmen, Dateien suchen oder ersetzen. Jedoch sollte man es vermeiden, Dateien zu löschen, da dies zu Problemen mit MyCoRe führen kann.

Der Nachteil ist, dass durch die Bildung des Hashwertes ein Dateizugriff länger dauert. Durch die Nutzung des Hashwertes ist es ohne externe Tools nicht möglich, herauszufinden, in welchem Ordner sich welches Objekt befindet, sondern nur durch den root Ordner des Objektes und der `inventory.json` .

Link zur Spezifikation: [0003-hash-and-id-n-tuple-storage-layout.md <sup><i class="fas fa-external-link-alt"></i></sup>](https://github.com/OCFL/extensions/blob/main/docs/0003-hash-and-id-n-tuple-storage-layout.md)

#### Hash Generation

Die Hashes im Implementierten *0003-hash-and-id-n-tuple-storage-layout* werden mit Sha-256 Generiert, 3 Tuple aus jeweils 3 Stellen generieren dann den Pfad zum Objekt.\
Die Bildung des Hashes wird mit dem Ursprünglichen Dateinamen gemacht, welcher dann vor dem Speichern sicher für die Ordnerstruktur dank Escape-Sequenzen gemacht wird.

{{<mcr-table id="repository-provider-list" class="table" style="" col-styles="">}}
| Dateiname                          | Tuple 1 | Tuple 2 | Tuple 3 | Rest des Hashes                                         |
| :--------------------------------- | :-----: | :-----: | :-----: | :------------------------------------------------------ |
| derivate:Project_derivate_00000101 | a32     | 302     | e6c     | f89914a40e3656dac10c66586f0a8db3da22220030b7ba73da47350 | 
| derivate:Project_derivate_00000109 | 484     | 67d     | d9f     | e493cdd42659c08844a487f1b9b21d8a229404b247e1cabba4f51c2 | 
| derivate:Project_derivate_00000110 | f10     | 8d6     | 503     | 58f00e0affef633b0f618328a214b96fbf29f87f29ff7387e23a247 | 
| derivate:Project_derivate_12345678 | 71d     | 94b     | ed9     | 219276d96aa6f0a6af1c31dfc203b3a8100f57b6a677feb222edc4b | 
| doctype:Project_doctype_00000101   | 700     | 702     | 393     | 015ec5378a4008acbfa4239b89d3279f75cd7bf0d65227cedf4fdaa | 
| doctype:Project_doctype_00000109   | 281     | dfd     | ee7     | 83f19825711d3a2f1544023f445539b6d666eccc1ac4271e657de73 | 
| doctype:Project_doctype_00000110   | cf3     | 8d8     | 0a3     | c278bc2a78d094dc592052af2333d97f949872f3ff21ad51de7761a | 
| doctype:Project_doctype_12345678   | 9d4     | 759     | 752     | 65d474fe6bcd7cfa9756cd06c690ae102f1ba5bfaf51294d96f418c | 
| mcrclass:rfc5646                   | d32     | 4be     | d1c     | a6a89d0ed26bddcaaca66e50f57dd77b908c90ada7c21ba4489a26d | 
| mcruser:editor1A@local             | 1a5     | ec9     | a72     | 9b5220c75033f21e46b594e22ec52d1f89b238072bf7488b6f32a07 | 
| mcracl:rules                       | e64     | 6f0     | 669     | a8ae91be6c36beb30ba8d596f52682ecc2bc5a124b3d21d54967077 | 
| mcrweb:pages                       | 5cd     | 8a6     | 495     | 343a81793d771c3e083674872d2763d7a3a112c251781e1052d5bba | 
{{</mcr-table>}}

#### Ordnerstruktur

```text {linenos=table}
[storage_root]
├── 0=ocfl_1.0
├── ocfl_layout.json
├── extensions
│   └── 0003-hash-and-id-n-tuple-storage-layout
│       └── config.json
├── a32
│   └── 302
│       └── e6c
│           └── derivate%3aProject_derivate_00000101
│               └── ... [object root]
├── 484
│   └── 67d
│       └── d9f
│           └── derivate%3aProject_derivate_00000109
│               └── ... [object root]
├── f10
│   └── 8d6
│       └── 503
│           └── derivate%3aProject_derivate_00000110
│               └── ... [object root]
├── 71d
│   └── 94b
│       └── ed9
│           └── derivate%3aProject_derivate_12345678
│               └── ... [object root]
├── 700
│   └── 702
│       └── 393
│           └── doctype%3aProject_doctype_00000101
│               └── ... [object root]
├── 281
│   └── dfd
│       └── ee7
│           └── doctype%3aProject_doctype_00000109
│               └── ... [object root]
├── cf3
│   └── 8d8
│       └── 0a3
│           └── doctype%3aProject_doctype_00000110
│               └── ... [object root]
├── 9d4
│   └── 759
│       └── 752
│           └── doctype%3aProject_doctype_12345678
│               └── ... [object root]
├── d32
│   └── 4be
│       └── d1c
│           └── mcrclass%3arfc5646
│               └── ... [object root]
├── 1a5
│   └── ec9
│       └── a72
│           └── mcruser%3aeditor1A@local
│               └── ... [object root]
├── e64
│   └── 6f0
│       └── 669
│           └── mcracl%3arules
│               └── ... [object root]
└── 5cd
    └── 8a6
        └── 495
            └── mcrweb%3apages
                └── ... [object root]
```

### MyCoRe Storage Layout

Das MyCoRe Storage Layout ist ein eigens entwickeltes OCFL Layout, welches ähnlich des Nativen XML Store arbeitet. Die Pfadberechnung von `mcrobject` und `mcrderivate` erfolgt durch ihre ID und dem konfigurierten SlotLayout bzw. des eingestellten NumberPatterns (siehe [Metadataspeicher]({{< relref "basics_mcr_store">}})), wobei bei den restlichen Objekten durch Typ und Name der Pfad erstellt wird.

<b class="text-warning">Es ist zu beachten, dass das MyCoRe Storage Layout keinem Standard entspricht und daher womöglich von keinen externen Tools nativ unterstützt wird.</b>

Im Vergleich zu dem *0003-hash-and-id-n-tuple-storage-layout* ist das *mycore-storage-layout* besser ohne externe Tools zu navigieren. Es ist zu beachten, dass trotzdem keine Daten direkt verändert werden dürfen, da es sonst zu Fehlern bei der Validierung kommen kann.

In der Performance in MyCoRe ist das *mycore-storage-layout* schneller als das *0003-hash-and-id-n-tuple-storage-layout*, da nicht erst bei jedem Dateizugriff die Hashwerte des Dateinamens generiert werden müssen.

Link zur Spezifikation: [mycore-storage-layout.md <sup><i class="fas fa-external-link-alt"></i></sup>](https://github.com/MyCoRe-Org/mycore/blob/2021.06.x/mycore-ocfl/src/main/resources/ocfl-specs/mycore-storage-layout.md)

#### Ordnerstruktur

```shell {linenos=table}
[storage root]
├── 0=ocfl_1.0
├── extensions
│   └── mycore-storage-layout
│       └── config.json
├── mycore-storage-layout.md
├── ocfl_1.0.txt
├── ocfl_extensions_1.0.md
├── ocfl_layout.json
├── mcrderivate
│   └── Project
│       └── derivate
│           ├── 0000
│           │   └── 01
│           │       ├── Project_derivate_00000101
│           │       │   └── ... [object root]
│           │       ├── Project_derivate_00000109
│           │       │   └── ... [object root]
│           │       └── Project_derivate_00000110
│           │           └── ... [object root]
│           └── 1234
│               └── 56
│                   └── Project_derivate_12345678
│                       └── ... [object root]
├── mcrobject
│   └── Project
│       └── doctype
│           ├── 0000
│           │   └── 01
│           │       ├── Project_doctype_00000101
│           │       │   └── ... [object root]
│           │       ├── Project_doctype_00000109
│           │       │   └── ... [object root]
│           │       └── Project_doctype_00000110
│           │           └── ... [object root]
│           └── 1234
│               └── 56
│                   └── Project_doctype_12345678
│                       └── ... [object root]
├── mcrclass
│   └── rfc5646
│       └── ... [object root]
├── mcruser
│   └── editor1A@local
│       └── ... [object root]
├── mcracl
│   └── rules
│       └── ... [object root]
└── mcrweb
    └── pages
        └── ... [object root]
```

## Offene Probleme

  - Ein Objekt muss hart löschbar sein bisher ist nur 'soft'-löschen möglich.
  - Nach löschen können alte Versionen immer noch aufgerufen werden
  - Die Version muss bei `/receive/{ID}` als Attribut `?r=v{n}` mitgegeben werden, da sonst XSLT nichts von den Versionen weiß.

## Fazit

  - Fixes und Konkretisierungen sind noch erforderlich?
  - Mit Release 2022 sollte OCFL produktiv einsetzbar sein.
