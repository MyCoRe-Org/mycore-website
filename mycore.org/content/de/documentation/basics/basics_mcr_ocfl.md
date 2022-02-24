
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

Derzeit ist es nur möglich, Objekte und Derivate-Metadaten zu speichern. Ziel ist es, das man zukünftig auch Derivate-Inhalte (Dateien) und alle Utility-Objekte, wie etwa Klassifikationen, Benutzer, ACLs, etc. im OCFL-Repository speichern kann.

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

# Definitionen für das Repository "Main"
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

Es sollte sichergestellt werden, dass während des Migrationsprozesses durch die Nutzer keine Daten bearbeitet werden.

Zunächst wird der Metadaten-Manager bei dem Nativen belassen und es soll sichergestellt werden,
dass das Repository `Main` oder das eigene Repository korrekt eingerichtet sind.

Mit dem Kommando `migrate metadata to repository {Repository}` können die Daten in die angegebene Repository überspielt werden.
Das Kommando gibt eine Statistik aus, ob alle Metadaten migriert werden konnten.

Auch wenn keine Fehler zu sehen sind, sollte man trotzdem anhand der Anzahl überprüfen, ob alle Objekte erfolgreich übertragen wurden.

Wenn alles geklappt hat, dann kann man den MetadatenManager wie folgt umstellen.
```shell {linenos=table}
 MCR.Metadata.Manager=org.mycore.ocfl.MCROCFLXMLMetadataManager
```

## Migration zwischen Layouts

Die Migration zwischen den OCFL Layouts funktioniert genauso wie zu OCFL,
der einzige Unterschied ist das hierbei der Metadaten-Manager des OCFL zu nutzen ist.

Um eine Repository zu Migrieren, ist die Quell-Repository mit
`MCR.Metadata.Manager.Repository={Quell-Repository}`
zu setzen.

Das Ziel Repository muss manuell gesetzt werden (siehe [Konfiguration](#konfiguration)), diese Repository darf nicht den gleichen Typ (Repository Provider) haben wie die Quelle. Wird dies trotzdem benötigt, ist es abzuwägen, ob es nicht besser ist, das Repository einfach zu kopieren.

Hierbei kann es manchmal vorkommen, dass ein `MCRUsageException` ausgegeben wird. Dies tritt dann auf, wenn Objekte oder Derivate vor der Migration zu OCFL gelöscht wurden und daher nicht mit Migriert wurden. Folgend wird versucht, deren Versionsverlauf zu lesen, da MyCoRe diese ID noch immer bekannt ist. Dies tritt nicht auf wenn Objekte und Derivate nach der Migration gelöscht werden, da der Versionsverlauf nicht mit gelöscht wird.\
Dies wird in zukünftigen Versionen behoben werden und hat <u>keinen Impakt in der Funktionsweise von OCFL</u>, und kann daher ohne Bedenken ignoriert werden.

## Verfügbare Repository Layouts
### OCFL Community Extension 0003: Hashed Truncated N-tuple Trees with Object ID Encapsulating Directory for OCFL Storage Hierarchies

Das *0003-hash-and-id-n-tuple-storage-layout* ist das Standard Layout in MyCoRe. Es ist ein Layout aus den offiziellen Community Extensions für OCFL. 
Ein Repository mit dem *0003-hash-and-id-n-tuple-storage-layout* lässt sich auch durch externe Programme einfach einsehen und verändern.\
Aus den Dateinamen wird ein Hashwert gebildet, mit dem danach die Ordnerstruktur gebildet wird.


Es ist zu beachten, das es vermieden werden soll, Dateien zu löschen oder neu anzulegen, da MyCoRe seine eigene Liste für die IDs führt und es daher zu Fehlern oder Datenverlust kommen kann.

Der Nachteil ist, dass durch die Bildung des Hashwertes ein Dateizugriff länger dauert. Durch die Nutzung des Hashwertes ist es ohne externe Tools nicht möglich, herauszufinden, in welchem Ordner sich welches Objekt befindet, sondern nur durch den root Ordner des Objektes und der `inventory.json` .

Link zur Spezifikation: [0003-hash-and-id-n-tuple-storage-layout.md <sup><i class="fas fa-external-link-alt"></i></sup>](https://github.com/OCFL/extensions/blob/main/docs/0003-hash-and-id-n-tuple-storage-layout.md)

#### Hash Generation

Der Hashwert im *0003-hash-and-id-n-tuple-storage-layout* wird mit mit dem Algorithmus SHA-256 generiert. 3 Tupel mit jeweils 3 Stellen vom Beginn des Hashwertes bilden dann den Pfad zum Objekt.

Der Hashwert wird aus dem ursprünglichen Dateinamen gebildet. Anschließend wird ein sicherer Dateiname erzeugt, indem Sonderzeichen durch ihre Escape-Sequenzen codiert werden. Dadurch wird eine problemlose Speicherung gewährleistet.

{{<mcr-table id="repository-provider-list" class="table" style="" col-styles="">}}
| Dateiname                             | Tuple 1 | Tuple 2 | Tuple 3 | Rest des Hashes                                         |
| :------------------------------------ | :-----: | :-----: | :-----: | :------------------------------------------------------ |
| mcrderivate:Project_derivate_00000101 | 37c     | 205     | dbd     | dbbe09979e5972de14595cab5a972a9826b93301effeab5f24ae884 | 
| mcrderivate:Project_derivate_00000109 | d36     | 065     | d61     | 20804aada912de4c0659dec694eb672ce53646a64b67373906de919 | 
| mcrderivate:Project_derivate_00000110 | 8a4     | 31f     | f27     | 2ae4106294efe2725676d0b60392b149f5e446b4f511e915262909a | 
| mcrderivate:Project_derivate_12345678 | 475     | 5ce     | 80d     | 9f6f3785d1f5febe66bd70f3bdbcae252347ceaeea704bcf113c7f6 | 
| mcrobject:Project_doctype_00000101    | cb8     | 8d8     | 068     | 8005b1c1407f0569b7c5bf1eeeb94fabb2ef6325c278d04a5b6483d | 
| mcrobject:Project_doctype_00000109    | 17b     | e8c     | 3a5     | a22984ed75fa484ad5d44c04a6ea364d5d62ff26c8d339206d3f63e | 
| mcrobject:Project_doctype_00000110    | d5f     | aa4     | 90d     | e8754eb1c3172398274d7e0ea540e6c785304952956dfe93c535ab8 | 
| mcrobject:Project_doctype_12345678    | 482     | f56     | 5db     | 9f0a7740d6eab30627f2e74473d206e35fccac0d0850c188dcf7db1 | 
| mcrclass:rfc5646                      | d32     | 4be     | d1c     | a6a89d0ed26bddcaaca66e50f57dd77b908c90ada7c21ba4489a26d | 
| mcruser:editor1A@local                | 1a5     | ec9     | a72     | 9b5220c75033f21e46b594e22ec52d1f89b238072bf7488b6f32a07 | 
| mcracl:rules                          | e64     | 6f0     | 669     | a8ae91be6c36beb30ba8d596f52682ecc2bc5a124b3d21d54967077 | 
| mcrweb:pages                          | 5cd     | 8a6     | 495     | 343a81793d771c3e083674872d2763d7a3a112c251781e1052d5bba | 
{{</mcr-table>}}

#### Ordnerstruktur

```text {linenos=table}
[storage_root]
├── 0=ocfl_1.0
├── ocfl_layout.json
├── extensions
│   └── 0003-hash-and-id-n-tuple-storage-layout
│       └── config.json
├── 37c
│   └── 205
│       └── dbd
│           └── mcrderivate%3aProject_derivate_00000101
│               └── ... [object root]
├── d36
│   └── 065
│       └── d61
│           └── mcrderivate%3aProject_derivate_00000109
│               └── ... [object root]
├── 8a4
│   └── 31f
│       └── f27
│           └── mcrderivate%3aProject_derivate_00000110
│               └── ... [object root]
├── 475
│   └── 5ce
│       └── 80d
│           └── mcrderivate%3aProject_derivate_12345678
│               └── ... [object root]
├── cb8
│   └── 8d8
│       └── 068
│           └── mcrobject%3aProject_doctype_00000101
│               └── ... [object root]
├── 17b
│   └── e8c
│       └── 3a5
│           └── mcrobject%3aProject_doctype_00000109
│               └── ... [object root]
├── d5f
│   └── aa4
│       └── 90d
│           └── mcrobject%3aProject_doctype_00000110
│               └── ... [object root]
├── 482
│   └── f56
│       └── 5db
│           └── mcrobject%3aProject_doctype_12345678
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

Das MyCoRe Storage Layout ist ein eigens entwickeltes OCFL Layout, welches ähnlich des Nativen XML Store arbeitet. Die Pfadberechnung von `mcrobject` und `mcrderivate` erfolgt durch ihre ID und dem konfigurierten SlotLayout bzw. des eingestellten NumberPatterns (siehe [Metadataspeicher]({{< relref "basics_mcr_store">}})), wobei bei den Utility-Objekten (Klassifikationen, Nutzer, ...) wird der Pfad aus deren Typ und dem Namen erstellt.

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
  - Nach dem Löschen können alte Versionen immer noch aufgerufen werden.
  - Bei einer alten Version muss bei `/receive/{ID}` als Attribut `?r=v{n}` mitgegeben werden, da sonst XSLT nichts von den Versionen weiß.