
---

title: "Versionierung mit OCFL in MyCoRe"
description: ""
mcr_version: ['2021.11']
author: ['Kathleen Neumann', 'Jens Kupferschmidt', 'Robert Stephan', 'Tobias Lenhardt']
date: "2022-05-24"

---

## Allgemeines

[OCFL](https://ocfl.io/), das Oxford Common File Layout, ist ein Konzept zur Speicherung von Daten in einer versionierten Form auf einem nativen Plattenbereich. Damit können die Vorteile einer einfachen
Speicherung im Dateisystem und einer Dateiversionierung optimal verbunden werden. 

Die Implementierung wurde mit Hilfe der [Java OCFL Libary](https://github.com/UW-Madison-Library/ocfl-java) der University of Wisconsin-Madison realisiert. Die MyCoRe-Entwickler arbeiten seit 2020 an der Integration dieser Form der Datenablage in MyCoRe und haben sie nun prototypisch implementiert. Mit dem Release {{<mcr-version "2021.11">}} ist sie auch für Produktivanwendungen als Beta verfügbar und kann genutzt werden um Objekte im OCFL-Storage-Layout zu speichern. Es ist geplant, dass mit dem Release in 2022 die OCFL Implementierung fertiggestellt wird und somit die Beta-Phase verlässt.

"OCFL-Beta" bedeutet, das bisher noch nicht alles im OCFL gespeichert werden kann, aber es nicht mehr zu grundlegenden Änderungen kommen wird. Zukünftige Änderungen bauen auf dieser Implementierung auf, ohne das Konflikte für den Nutzer entstehen.

## Zukünftige Pläne

Derzeit ist es nur möglich, Objekte und Derivate-Metadaten zu speichern. Ziel ist es, das man zukünftig auch Derivate-Inhalte (Dateien) und alle Utility-Objekte (wie etwa Klassifikationen, Benutzer, ACLs, etc.) im OCFL-Repository speichern kann.

# Die Speicherung der MyCoRe-Objekte mit OCFL

## Konfiguration

#### Alle Konfigurationen sind hier verfügbar: [ocfl-properties]

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

Die folgenden Properties werden im Code als Standardwerte mitgeliefert.

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
dass die Implementation des Repository Providers von der Klassse `MCROCFLRepositoryProvider` vererbt ist.

Mit dem folgenden Property kann der Metadaten Manager von XML (bisherige Implementierung) auf OCFL umgestellt werden:

```shell {linenos=table}
 MCR.Metadata.Manager=org.mycore.ocfl.MCROCFLXMLMetadataManager
```

Will man sein eigenes Repository anlegen, geht das wie folgt:

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

Weitere Erläuterungen zu den Repository Providern können im Abschnitt [Verfügbare Repository Layouts](#verfügbare-repository-layouts) gefunden werden.

{{<mcr-comment>}}
<!-- ## Infos zu der Migration zu OCFL

*<u>Notiz:</u> Migration von XML sowie SVN möglich, zwischen OCFL, also nicht final und auch zurück zu nativ XML via export, falls SVN benutzt wird, sollte man bis man sich sicher ist das einem das neue System besser gefällt, keine wichtigen Änderungen vornehmen, da eine Migration zurück zu SVN <u>NICHT</u> möglich ist.* -->
{{</mcr-comment>}}

## Migration zu OCFL

Es sollte sichergestellt werden, dass während des Migrationsprozesses durch die Nutzer keine Daten bearbeitet werden.

Zunächst wird der Metadaten-Manager bei dem Nativen belassen und es soll sichergestellt werden,
dass das Repository `Main` oder das eigene Repository korrekt eingerichtet sind.

Mit dem Kommando `migrate metadata to repository {Repository}` können die Daten in die angegebene Repository überspielt werden.
Das Kommando gibt in einer Statistik aus, ob alle Metadaten migriert werden konnten.

Auch wenn keine Fehler zu sehen sind, sollte man trotzdem anhand der Anzahl überprüfen, ob alle Objekte erfolgreich übertragen wurden.

Wenn alles geklappt hat, kann man den MetadatenManager wie folgt umstellen:
```shell {linenos=table}
 MCR.Metadata.Manager=org.mycore.ocfl.MCROCFLXMLMetadataManager
```

## Migration zwischen Layouts

Die Migration zwischen den OCFL Layouts funktioniert genauso wie zu OCFL,
der einzige Unterschied ist das hierbei der Metadaten-Manager für OCFL zu nutzen ist.

Um ein Repository zu migrieren, ist das Quell-Repository mit
`MCR.Metadata.Manager.Repository={Quell-Repository}`
zu setzen.

Das Ziel Repository muss manuell gesetzt werden (siehe [Konfiguration](#konfiguration)), dieses Repository darf nicht den gleichen Typ (Repository Provider) haben wie die Quelle. Haben Quell- und Zielrepository denselben Typ, ist es abzuwägen, ob es einfacher, das Repository zu kopieren.

{{<mcr-comment>}}
<!--
Der Nutzer ruft ja nicht wissentlich den Versionsverlauf auf, sondern das Migrationsscript, daher denke ich das es generell gehalten werden soll, da sich der Nutzer sonst fragt:
"Naja, ich rufe den nicht selber auf, aber bekomme das Exception, was soll ich tun?"
Um das zu vermeiden, wird nur darauf eingegangen, dass er kommt und danach warum der kommt.
 -->
{{</mcr-comment>}}
Hierbei kann es vorkommen, dass ein `MCRUsageException` ausgegeben wird. Dies tritt dann auf, wenn Objekte oder Derivate vor der Migration zu OCFL gelöscht wurden und daher nicht mit migriert wurden. Das Problem entsteht, wenn versucht wird, deren Versionsverlauf zu lesen, da MyCoRe diese IDs noch immer bekannt sind. Es tritt nicht auf wenn Objekte und Derivate NACH der Migration gelöscht werden, da nun der Versionsverlauf nicht mit gelöscht wird.\
Das Problem wird in einer zukünftigen Version behoben werden und hat <u>keinen Einfluss auf die Funktionsweise von OCFL</u>. Es kann daher ohne Bedenken ignoriert werden.

## Verfügbare Repository Layouts
### OCFL Community Extension 0003: Hashed Truncated N-tuple Trees <br />with Object ID Encapsulating Directory for OCFL Storage Hierarchies

Das *0003-hash-and-id-n-tuple-storage-layout* ist das Standard Layout in MyCoRe. Es ist ein Layout aus den offiziellen Community Extensions für OCFL. 
Ein Repository mit dem *0003-hash-and-id-n-tuple-storage-layout* lässt sich auch durch externe Programme einfach einsehen und verändern.\
Aus den Dateinamen wird ein Hashwert gebildet, mit dem danach die Ordnerstruktur gebildet wird.


Es sollte vermieden werden, Dateien zu löschen oder neu anzulegen, da MyCoRe seine eigene Liste für die IDs führt und es sonst zu Fehlern oder Datenverlust kommen kann.

Der Nachteil ist, dass durch die Bildung des Hashwertes ein Dateizugriff länger dauert. Durch die Nutzung des Hashwertes ist es ohne externe Tools nicht möglich, herauszufinden, in welchem Ordner sich welches Objekt befindet, sondern nur durch den root Ordner des Objektes und der `inventory.json` .

Link zur Spezifikation: [0003-hash-and-id-n-tuple-storage-layout.md](https://github.com/OCFL/extensions/blob/main/docs/0003-hash-and-id-n-tuple-storage-layout.md)

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

```text {linenos=false}
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

Das MyCoRe Storage Layout ist ein eigens entwickeltes OCFL Layout, welches ähnlich des Nativen XML Store arbeitet. Die Pfadberechnung von `mcrobject` und `mcrderivate` erfolgt durch aus ihrer ID und einem konfigurierbaren SlotLayout bzw. des eingestellten NumberPatterns (siehe [Metadataspeicher]({{< relref "basics_mcr_store">}})). Bei bei den Utility-Objekten (Klassifikationen, Nutzer, ...) wird der Pfad aus deren Typ und dem Namen erstellt.

<b class="text-warning">Es ist zu beachten, dass das MyCoRe Storage Layout keinem OCFL-Standard-Layout entspricht und daher nicht von externen Tools nativ unterstützt wird.</b>

Allerdings ist im Vergleich zu dem *0003-hash-and-id-n-tuple-storage-layout* die Ordnerstruktur des *mycore-storage-layout* besser ohne externe Tools zu navigieren. Es ist zu beachten, dass trotzdem keine Daten direkt verändert werden dürfen, da es sonst zu Fehlern bei der Validierung kommen kann.

In der Performance in MyCoRe ist das *mycore-storage-layout* schneller als das *0003-hash-and-id-n-tuple-storage-layout*, da nicht erst bei jedem Dateizugriff die Hashwerte des Dateinamens generiert werden müssen.

Link zur Spezifikation: [mycore-storage-layout.md](https://github.com/MyCoRe-Org/mycore/blob/2021.06.x/mycore-ocfl/src/main/resources/ocfl-specs/mycore-storage-layout.md)

#### Ordnerstruktur

```text {linenos=false}
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

## Versionierung von Klassifikationen

Es ist nun auch möglich, Klassifikationen neben der Datenbank im OCFL Store zu speichern, aber primär wird dann weiterhin die Datenbank genutzt.

### Konfiguration

#### Alle Konfigurationen sind hier verfügbar: [ocfl-properties]

Hierbei zusätzlich mitgeliefert sind die folgenden Properties:

```shell {linenos=table}
# Setzt die Standard Repository auf "Main"
MCR.Classification.Manager.Repository=Main
```

Um die OCFL Speicherung zu aktivieren, sind die folgenden Konfigurationen zu setzen:

```shell {linenos=table}
# Dies ersetzt die DAO Implementation mit einer die Events sendet
MCR.Category.DAO=org.mycore.datamodel.classifications2.impl.MCREventedCategoryDAOImpl

MCR.Classification.Manager=org.mycore.ocfl.MCROCFLXMLClassificationManager
# Hiermit wird dann die Repository "Main" auf Mutable gesetzt, dies ist für die Verwendung vom Klassifikations Store benötigt!
MCR.OCFL.Repository.Main.Mutable=true
# Und hier wird der EventHandler eingebunden
MCR.EventHandler.MCRClassification.020.Class=org.mycore.ocfl.MCROCFLEventHandler
```

Wenn man eine andere Repository anstatt "Main" nutzen will, kann man dies einfach ersetzen, wichtig hierbei ist das die Repository auch auf Mutable gesetzt ist.

### Benutzung

Für die Benutzung ist es nicht wichtig, eine "Migration" zu machen, bei einer Änderung wird die neue Version im OCFL Store abgelegt,\
auch wenn dieser noch leer ist.

Falls es dennoch erwünscht ist, das die Repository und die Datenbank auf gleichem Stand sind, kann auch den OCFL Store neu bauen lassen.\
Hierzu müssen als erstes die OCFL Entwicklerbefehle mit eingebunden werden:

```shell {linenos=table}
 MCR.CLI.Classes.Internal=%MCR.CLI.Classes.Internal%,org.mycore.ocfl.commands.MCROCFLDevCommands
```
<b class="text-danger">Es ist zu beachten, das dies alle Klassifikationsdaten die bisher im OCFL Store sind ohne Sicherung löschen wird!</b>

Folgend kann dann das Kommando `rebuild ocfl class store` genutzt werden um den den OCFL Store zu dem gleichen Stand wie die Datenbank zu bringen.

Ist dies ohne Fehler erfolgt, kann man die Entwicklerbefehle auch wieder entfernen.

### Zusätzliche Konfiguration

Wenn Klassifikationen gespeichert werden, kann man auch optional das `counter` Property mit aktivieren.\
Dieses speichert, wie viele Objekte zu einer jeweiligen Kategorie verlinkt sind, kann aber auch etwas länger dauern, und diese müssen beim Importieren entfernt werden.

Diese können hiermit aktiviert werden:
```shell {linenos=table}
 MCR.OCFL.Classification.Counter=true
```

## Offene Probleme
#### Hartes Löschen
Unter bestimmten Umständen muss ein Objekt auch hart löschbar sein - bisher ist nur 'soft'-löschen möglich.
Das bedeutet, nach dem Löschen können alte Versionen immer noch angezeigt werden.
Dazu kann beispielsweise für eine ältere Version in der URL `/receive/{ID}` das Attribut `?r=v{n}` mitgegeben werden, um die entsprechende Version anzuzeigen.

{{<mcr-comment>}}<!-- Markdown Links: -->{{</mcr-comment>}}

[ocfl-properties]: https://raw.githubusercontent.com/MyCoRe-Org/mycore/issues/MCR-2604-ocfl-classification-storage/mycore-ocfl/src/main/resources/components/ocfl/config/mycore.properties "MyCoRe OCFL-Module Properties"
