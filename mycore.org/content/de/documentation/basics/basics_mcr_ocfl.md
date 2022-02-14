
---

title: "Die Speicherung der MyCoRe-Objekte mit OCFL"
description: ""
mcr_version: ['2021.06']
author: ['Kathleen Neumann', 'Jens Kupferschmidt', 'Robert Stephan','Tobias Lenhardt']
date: "2022-02-14"

---

## Allgemeines
 
[OCFL](https://ocfl.io/), das Oxford Common File Layout, ist ein Konzept zur Speicherung von
Daten in einer versionierten Form mit Ablage der Daten auf einem nativen Plattenbereich. Somit kann der Vorteil einer einfachen
Speicherung im Dateisystem mit dem einer Dateiversionierung optimal verbunden werden. Die MyCoRe-Entwickler arbeiten seit 2020
an der Integration dieser Form der Datenablage in MyCoRe. Mit Version 2021 ist nun eine prototypische Implementierung unter
Zuhilfenahme der OCFL-Library im MyCoRe-Kern verfügbar. Mit dem Release \<2021|2022> soll OCFL nun auch produktiv verwendbar sein.


Hier die Referenz zum [OCFL-Java Github](https://github.com/UW-Madison-Library/ocfl-java)</p>

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
MCR.OCFL.Repository.{Repository_Name}={Repository_Provider}
#Pfad zum Unterverzeichnis für Dateispeicherung
MCR.OCFL.Repository.{Repository_Name}.RepositoryRoot=%MCR.datadir%/foo
#Pfad zum Unterverzeichnis für Zwischenspeicher
MCR.OCFL.Repository.{Repository_Name}.WorkDir=%MCR.datadir%/bar
```

### Liste der Repository Provider in MyCoRe

{{<mcr-table id="repository-provider-list" class="table" style="" col-styles="">}}
   | Repository Provider | Layout |
   | :------------------ | :----- |
   | MCROCFLHashRepositoryProvider | [0003 Hashed Truncated N-tuple Trees with Object ID Encapsulating Directory](https://ocfl.github.io/extensions/0003-hash-and-id-n-tuple-storage-layout.html) |
   | MCROCFLMCRRepositoryProvider | [MyCoRe Storage Layout](#mycore-storage-layout) |
{{</mcr-table>}}

Mehr Erklärung zu den Repository Providern kann im Abschnitt [Provider Liste](#verfügbare-repository-provider) gefunden werden.


## Migration zu OCFL
<!-- <b class="text-warning">Achtung: Die Migration befindet sich aktuell noch im Experimentellen Beta-Entwicklungsstadium und ist nicht für den produktiven Einsatz vorgesehen</b> -->

Für die Prozedur sollte sichergestellt werden, dass die Daten nicht von Nutzern bearbeitet werden.

Zunächst wird der Metadaten-Manager bei dem Nativen belassen und es soll sichergestellt werden,
dass die Repository `Main` oder die eigene Repository korrekt eingerichtet sind.

Mit dem Kommando `migrate metadata to repository {Repository}` können die Daten in die angegebene Repository überspielt werden.
Das Kommando gibt eine Statistik aus, ob alle Metadaten migriert werden konnten.

Auch wenn keine Fehler zu sehen sind, sollte man trotzdem die Anzahl überprüfen, ob alle Objekte erfolgreich übertragen wurden.

Wenn alles geklappt hat, dann kann man den MetadatenManager umstellen.

## Migration zwischen Layouts

Die Migration zwischen den OCFL Layouts funktioniert genauso wie zu OCFL,
der einzige unterschied ist das hierbei der Metadaten-Manager des OCFL zu nutzen ist.

Um eine Repository zu Migrieren, ist die Quell-Repository mit
`MCR.Metadata.Manager.Repository={Quell-Repository}`
zu setzen.

Die Ziel Repository muss manuell gesetzt werden (siehe [Konfiguration](#konfiguration)), diese Repository darf nicht den gleichen Typ (Repository Provider) haben wie die Quelle. Wird dies trotzdem benötigt, ist es abzuwägen, ob es nicht besser ist, die Repository einfach zu kopieren.

Hierbei kann es manchmal vorkommen, dass die OCFL Library eine `ObjectNotFound` Exception wirft, dies tritt dann auf,
wenn Objekte gelöscht wurden und es versucht wird, ein Property zu lesen.\
<b class="text-danger">Überprüfen warum das so ist, ist es möglich erst ein "exist" check zu machen vor dem abfragen?</b>

## Verfügbare Repository Provider
### OCFL Community Extension 0003: Hashed Truncated N-tuple Trees with Object ID Encapsulating Directory for OCFL Storage Hierarchies

Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.

`Notiz:` *Hash hat den Vorteil das es externe tools gibt, welche es erlauben, Veränderungen an der Repository schnell selber tätigen zu können. Sein größter Nachteil ist, das es ohne externe Tools unmöglich ist, zu wissen, in welchem Ordner was steckt, außerdem ist die Performance (um rund 40%\*) schlechter, da erst pro Datei die Hashwerte generiert werden müssen.*

*\*bei einem Test mit 100k Objekten dauerte die Migration 5 bis 6 Minuten mit dem MCRLayout, 8 bis 10 Minuten mit dem Hash Layout*

Link zur Spezifikation: [0003-hash-and-id-n-tuple-storage-layout.md](https://github.com/OCFL/extensions/blob/main/docs/0003-hash-and-id-n-tuple-storage-layout.md)

#### (Ordnerstruktur)

```text {linenos=table}
[storage_root]/
├── 0=ocfl_1.0
├── ocfl_layout.json
├── extensions/0003-hash-and-id-n-tuple-storage-layout/config.json
├── 3c0/
│   └── ff4/
│       └── 240/
│           └── object-01/
│               ├── 0=ocfl_object_1.0
│               ├── inventory.json
│               ├── inventory.json.sha512
│               └── v1 [...]
└── 487/
    └── 326/
        └── d8c/
            └── %2e%2ehor%2frib%3ale-%24id/
                ├── 0=ocfl_object_1.0
                ├── inventory.json
                ├── inventory.json.sha512
                └── v1 [...]
```

### MyCoRe Storage Layout

Das MyCoRe Storage Layout ist ein eigens entwickeltes OCFL Layout, welches ähnlich des Nativen XML Store arbeitet. Die Pfadberechnung von `mcrobject` und `mcrderivate` erfolgt durch ihre ID und dem konfigurierten SlotLayout bzw. des eingestellten NumberPatterns (siehe [Metadataspeicher]({{< relref "basics_mcr_store">}})), wobei bei den restlichen Objekten durch Typ und Name der Pfad erstellt wird.

<b class="text-warning">Es ist zu beachten, das das MyCoRe Storage Layout keinem Standard entspricht und daher womöglich von keinen externen tools nativ unterstützt wird.</b>

`Notiz:` *Wie sich in tests herausgestellt hat, läuft das \<mycore-storage-layout> schneller als das \<hash-n-turple-id-encapsulation> layout mit mycore, es ist außerdem besser zu navigieren ohne externe programme. Dennoch sollte an den Daten nichts direkt verändert werden.*

#### (Ordnerstruktur)

```text {linenos=table}
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

  - <b class="text-warning">Derzeit kommt noch eine Warnung, dass die `ocfl-specs` nicht gefunden werden können für das MCR Storage Layout, dies wird demnächst behoben.</b>
  - Ein Objekt muss hart löschbar sein bisher ist nur 'soft'-löschen möglich.
  - Die Version muss bei `/receive/{ID}` als Attribut `?r=v{n}` mitgegeben werden, da sonst XSLT nichts von den Versionen weiß.
  - Tests sind noch nicht alle komplett durch, weitere folgen.

## Fazit

  - OCFL ist nicht für Produktivanwendungen komplett genug?
  - Fixes und Konkretisierungen sind noch erforderlich.
  - Mit Release <b class="text-danger">~~2022~~ der Sternzeit 2253</b> sollte OCFL produktiv einsetzbar sein.
