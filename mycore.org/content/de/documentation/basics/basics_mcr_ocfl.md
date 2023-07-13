
---

title: "Versionierung mit OCFL in MyCoRe"
description: ""
mcr_version: ['2022.06']
author: ['Kathleen Neumann', 'Jens Kupferschmidt', 'Robert Stephan', 'Tobias Lenhardt']
date: "2023-07-13"

---

## Allgemeines

[OCFL](https://ocfl.io/), das Oxford Common File Layout, ist ein Konzept zur Speicherung von Daten in einer versionierten Form auf einem nativen Plattenbereich. Damit können die Vorteile einer einfachen
Speicherung im Dateisystem und einer Dateiversionierung optimal verbunden werden. 

Die Implementierung wurde mit Hilfe der [Java OCFL Libary](https://github.com/UW-Madison-Library/ocfl-java) der University of Wisconsin-Madison
realisiert. Die MyCoRe-Entwickler arbeiten seit 2020 an der Integration dieser Form der Datenablage in MyCoRe und haben sie nun in Teilen 
implementiert. Mit dem Release {{<mcr-version "2021.11">}} ist sie auch für Produktivanwendungen als Beta verfügbar und kann genutzt werden, 
um Objekte und Klassifikationen im OCFL-Storage-Layout zu speichern. Mit dem Release {{<mcr-version "2022.06">}} wird die OCFL Implementierung
um das User-System erweitert. Da hierfür auch 'unter der Haube' für den Endanwender funktionsneutrale Umbauten erforderlich sind, wird sich der OCFL-Teil auch
im aktuellen LTS kontinuierlich weiterentwickeln. Dies soll aber keine Auswirkungen auf die Benutzerebene haben. Zukünftige Änderungen bauen auf 
dieser Implementierung auf, ohne das Konflikte für den Nutzer entstehen. ACLs, Web-Seiten und die digitalen Objekte der Derivate können aktuell noch nicht versioniert werden.

## Zukünftige Pläne

Derzeit ist es nur möglich, Objekte und Derivate-Metadaten sowie Klassifikationen und Nutzer zu speichern. Ziel ist es, das man zukünftig auch 
Derivate-Inhalte (Dateien) und alle Utility-Objekte (wie etwa ACLs, etc.) im OCFL-Repository speichern kann. Für einzelne Datenbereiche wie XML
soll OCFL eine Form des Primärspeichers darstellen. Bei Daten wie Klassifikationen und Nutzer wird die OCFL-Ablage nur als sekundärer Sicherheitsspeicher genutzt.
Weitere Ergänzungen werden dies für ACLs und digitale Objekte schrittweise ergänzen.

# Integration von OCFL

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

# Konfiguration

## Allgemeine Konfiguration

Die folgenden Properties werden im Code als Standardwerte mitgeliefert. Alle Konfigurationen sind hier verfügbar: [ocfl-properties]

```shell {linenos=table}
# Integration der CLI-Kommandos
MCR.CLI.Classes.Internal=%MCR.CLI.Classes.Internal%,org.mycore.ocfl.commands.MCROCFLCommands

# Definitionen für das Repository "Main"
MCR.OCFL.Repository.Main=org.mycore.ocfl.repository.MCROCFLHashRepositoryProvider
MCR.OCFL.Repository.Main.RepositoryRoot=%MCR.datadir%/ocfl-root
MCR.OCFL.Repository.Main.WorkDir=%MCR.datadir%/ocfl-temp
```

Diese können, sofern erwünscht, überschrieben werden. Es ist darauf zu achten,
dass die Implementation des Repository Providers von der Klassse `MCROCFLRepositoryProvider` vererbt ist.

Will man sein eigenes Repository anlegen bzw. ein eigenes Layout verwenden, geht das wie folgt über die jeweiligen Properties:

```shell {linenos=table}
#Repository Provider für verschiedene Layouts
MCR.OCFL.Repository.{Repository_Name}=org.mycore.ocfl.repository.{Repository_Provider}
#Pfad zum Unterverzeichnis für Dateispeicherung
MCR.OCFL.Repository.{Repository_Name}.RepositoryRoot=%MCR.datadir%/foo
#Pfad zum Unterverzeichnis für Zwischenspeicher
MCR.OCFL.Repository.{Repository_Name}.WorkDir=%MCR.datadir%/bar
```

#### Liste der Repository Provider in MyCoRe

{{<mcr-table id="repository-provider-list" class="table" style="" col-styles="">}}
   | Repository Provider | Layout |
   | :------------------ | :----- |
   | MCROCFLHashRepositoryProvider | [0003 Hashed Truncated N-tuple Trees with Object ID Encapsulating Directory](#ocfl-community-extension-0003-hashed-truncated-n-tuple-trees-br-with-object-id-encapsulating-directory-for-ocfl-storage-hierarchies) |
   | MCROCFLMCRRepositoryProvider | [MyCoRe Storage Layout](#mycore-storage-layout) |
{{</mcr-table>}}

Weitere Erläuterungen zu den Repository Providern können im Abschnitt [Verfügbare Repository Layouts](#verfügbare-repository-layouts) gefunden werden.

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

Das MyCoRe Storage Layout ist ein eigens entwickeltes OCFL Layout, welches ähnlich des Nativen XML Store arbeitet. Die Pfadberechnung von `mcrobject` und `mcrderivate` erfolgt aus der ID und einem konfigurierbaren SlotLayout bzw. des eingestellten NumberPatterns (siehe [Metadataspeicher]({{< relref "basics_mcr_store">}})). Bei den Utility-Objekten (Klassifikationen, Nutzer, ...) wird der Pfad aus deren Typ und dem Namen erstellt.

<b class="text-warning">Es ist zu beachten, dass das MyCoRe Storage Layout keinem OCFL-Standard-Layout entspricht und daher nicht von externen Tools nativ unterstützt wird.</b>

Allerdings ist im Vergleich zu dem *0003-hash-and-id-n-tuple-storage-layout* die Ordnerstruktur des *mycore-storage-layout* besser ohne externe Tools zu navigieren. Es ist zu beachten, dass trotzdem keine Daten direkt verändert werden dürfen, da es sonst zu Fehlern bei der Validierung kommen kann.

In der Performance in MyCoRe ist das *mycore-storage-layout* schneller als das *0003-hash-and-id-n-tuple-storage-layout*, da nicht erst bei jedem Dateizugriff die Hashwerte des Dateinamens generiert werden müssen.

Link zur Spezifikation: [mycore-storage-layout.md](https://github.com/MyCoRe-Org/mycore/blob/main/mycore-ocfl/src/main/resources/ocfl-specs/mycore-storage-layout.md)

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


## Versionierung von XML-Metadaten

Die folgenden Properties werden im Code als Standardwerte mitgeliefert. Alle Konfigurationen sind hier verfügbar: [ocfl-properties]

```shell {linenos=table}
# Setzt die Standard Repository auf "Main"
MCR.Metadata.Manager.Repository=Main
```

Mit dem folgenden Property kann der Metadaten Manager von XML (bisherige Implementierung) auf OCFL umgestellt werden. **Dies darf erst 
NACH der Migartion erfolgen!**

```shell {linenos=table}
 MCR.Metadata.Manager=org.mycore.ocfl.metadata.MCROCFLXMLMetadataManager
```


## Versionierung von Klassifikationen

Es ist auch möglich, Klassifikationen neben der Datenbank im OCFL Store zu speichern, aber primär wird dann weiterhin die Datenbank genutzt.

<b class="text-warning">Achtung, aktuell ist die gleichzeitige Nutzung von OCFL und SOLR für Klassifikationen noch nicht möglich! Wir arbeiten daran.</b>

Die folgenden Properties werden im Code als Standardwerte mitgeliefert. Alle Konfigurationen sind hier verfügbar: [ocfl-properties]

```shell {linenos=table}
# Setzt die Standard Repository auf "Main"
MCR.Classification.Manager.Repository=Main
```

Um die OCFL Speicherung zu aktivieren, sind die folgenden Konfigurationen zu setzen:

```shell {linenos=table}
# Dies ersetzt die DAO Implementation mit einer die Events sendet
MCR.Category.DAO=org.mycore.datamodel.classifications2.impl.MCREventedCategoryDAOImpl

MCR.Classification.Manager=org.mycore.ocfl.classification.MCROCFLXMLClassificationManager

# Und hier wird der EventHandler eingebunden
MCR.EventHandler.MCRClassification.020.Class=org.mycore.ocfl.classification.MCROCFLClassificationEventHandler
```

Wenn man eine andere Repository anstatt "Main" nutzen will, funktioniert dies exakt so wie oben für die Objekte beschrieben ist.


## Versionierung von Nutzerdaten

Es ist auch möglich, Nutzerdaten neben der Datenbank im OCFL Store zu speichern, primär wird jedoch weiterhin die Datenbank genutzt.
Die Daten werden dabei in der vergleichbaren Form wie bei einem SAVE-Kommando abgelegt.

Um die OCFL Speicherung zu aktivieren, sind die folgenden Konfigurationen zu setzen:

```shell {linenos=table}
# Setzt die Standard Repository auf "Main"
MCR.Users.Manager.Repository=Main

# Setzt den Manager auf die Implementierung für OCFL
MCR.Users.Manager=org.mycore.ocfl.user.MCROCFLXMLUserManager

# Und hier wird der EventHandler eingebunden
MCR.EventHandler.MCRUser.020.Class=org.mycore.ocfl.user.MCROCFLUserEventHandler
```


## Optionen für das Löschen

Werden Daten im OCFL gelöscht, so werden Sie per default nur als gelöscht markiert. Ältere Versionen können erstmal per default noch eingesehen werden.

Zum endgültigen Löschen von Daten kann dies über das folgende Property festgelegt werden. Bei Metadaten ist dabei auch eine Gruppierung nach MCRBaseID oder MCRProjectID möglich.
```MCR.OCFL.dropHistory.mcrclass=true
MCR.OCFL.dropHistory.mcruser=true
MCR.OCFL.dropHistory.mcrobject=true
MCR.OCFL.dropHistory.mcrobject.ULBeeHealth=true
MCR.OCFL.dropHistory.mcrobject.ULBeeHealth_anihealth=true
```

# Migartion

## Migration zu OCFL

Es sollte sichergestellt werden, dass während des Migrationsprozesses durch die Nutzer keine Daten bearbeitet werden.

Zunächst wird der Metadaten-Manager bei dem nativen XML-Plattenspeicher belassen und es soll sichergestellt werden,
dass das Repository `Main` oder das eigene Repository (z. B. `MCR`) korrekt eingerichtet sind. **Der MCR.Metadata.Manager muss noch auf XML stehen!**

Mit dem Kommando `migrate metadata to repository {Repository}` können die Daten in die angegebene Repository überspielt werden.
Das Kommando gibt in einer Statistik aus, ob alle Metadaten migriert werden konnten.

Auch wenn keine Fehler zu sehen sind, sollte man trotzdem anhand der Anzahl überprüfen, ob alle Objekte erfolgreich übertragen wurden.

Wenn alles erfolgreich umgestellt ist, kann man den MetadatenManager wie folgt umstellen:
```shell {linenos=table}
 MCR.Metadata.Manager=org.mycore.ocfl.metadata.MCROCFLXMLMetadataManager
```

Die Daten für User und Klassifikationen können mit `update ocfl classifications` und `update ocfl users` nach OCFL migriert werden. Primärdaten bleiben hier aber die Datenbanktabellen!

## Migration zwischen Layouts

Die Migration zwischen den OCFL Layouts funktioniert genauso wie zu OCFL,
der einzige Unterschied ist das hierbei der Metadaten-Manager für OCFL zu nutzen ist.

Um ein Repository zu migrieren, ist das Quell-Repository mit
`MCR.Metadata.Manager.Repository={Quell-Repository}`
zu setzen.

Das Ziel Repository muss manuell gesetzt werden (siehe [Konfiguration](#konfiguration)), dieses Repository darf nicht den gleichen Typ (Repository Provider) haben wie die Quelle. Haben Quell- und Zielrepository denselben Typ, ist es abzuwägen, ob es einfacher, das Repository zu kopieren.

Hierbei kann es vorkommen, dass ein `MCRUsageException` ausgegeben wird. Dies tritt dann auf, wenn Objekte oder Derivate vor der Migration zu OCFL gelöscht wurden und daher nicht mit migriert wurden. Das Problem entsteht, wenn versucht wird, deren Versionsverlauf zu lesen, da MyCoRe diese IDs noch immer bekannt sind. Es tritt nicht auf wenn Objekte und Derivate NACH der Migration gelöscht werden, da nun der Versionsverlauf nicht mit gelöscht wird.

Das Problem wird in einer zukünftigen Version behoben werden und hat <u>keinen Einfluss auf die Funktionsweise von OCFL</u>. Es kann daher ohne Bedenken ignoriert werden.


## Rücksetzen auf den XML-Manager ohne OCFL

### XML-Metadaten

[To Do] - Die muss noch endgültig getestet werden.

### Klassifikationen

Da die Klassifikationen primär in der Datenbank gespeichert sind, ist nur der Manager umzukonfigurieren, die Properties zu entfernen und der OCFL-Teilbaum zu löschen.

### Nutzerdaten

Da die Nutzer primär in der Datenbank gespeichert sind, ist nur der Manager umzukonfigurieren, die Properties zu entfernen und der OCFL-Teilbaum zu löschen.


# Benutzung und Kommandos

Für die Benutzung ist es nicht wichtig, eine "Migration" zu machen, bei einer Änderung wird die neue Version im OCFL Store abgelegt, auch wenn dieser noch leer ist.

## Globale Kommandos

`purge all marked from ocfl` - Löscht alle markierten OCFL-Einträge.

`purge all ocfl entries matching {RegEx}` - Löscht alle OCFL-Einträge, bei welchen die MCRIDs dem regulären Ausdruck entsprechen.

`purge all marked ocfl entries matching {RegEx}` - Löscht alle markierten OCFL-Einträge, bei welchen die MCRIDs dem regulären Ausdruck entsprechen.

## Metadaten

`migrate metadata to repository {ReopsitoryID}` - Migriert alle Metadaten in das OCFL Repository mit der ReopsitoryID (z. B. Main oder MCR).

`purge marked metadata from ocfl` - Entfernt im Falle, dass bisher nur ein logisches Löschen im OCFL erfolgte, alle markierten Objekt aus dem System.

`purge object {MCRID} from ocfl` - Entfernt im Falle, dass bisher nur ein logisches Löschen im OCFL erfolgte, das angegebene Objekt aus dem System.

`purge marked ocfl objects matching {RegEx}` - Entfernt die Objekte vom OCFL, bei welchen die MCRIDs dem regulären Ausdruck entsprechen.

`restore ocfl object {MCRID}` - Stellt das Objekt mit der letzten Revision im OCFL wieder her.

`restore object {MCRID} from ocfl with version {version_before_delete}` - Stellt das Objekt mit der angegebenen Version im OCFL wieder her.

`restore ocfl object matching {RegEx}` - Stellt die Objekte im OCFL her, bei welchen die MCRIDs dem regulären Ausdruck entsprechen.

## Klassifikationen

`update ocfl classifications` - Sollen erstmalig alle Klassifikationen auf dem OCFL Store gespeichert werden, kann man mit diesem Befehl alle Klassifikationen von der Datenbank in den OCFL Store schreiben lassen.

`update ocfl classification {ClassID}` - Soll nur eine einzige Klassifikation aktualisiert werden, kann dies mit diesem Befehl getan werden.

`sync ocfl classifications` - Sollte der Fall auftreten, das der Stand des OCFL Stores und die der Datenbank nicht mehr gleich sind, kann man mit dem Befehl alle Klassifikationen im OCFL auf den aktuellen Stand bringen und in der Datenbank gelöschte Klassifikationen in OCFL als gelöscht markieren lassen. Je nach Property werden diese auch im OCFL direkt gelöscht.

`delete ocfl classification {ClassID}` - Löscht eine Klassifikation aus dem OCFL-System. Hierbei ist zu beachten, wie die Porperties zum Löschen in OCFL gesetzt sind. Ggf. sind ältere Versionen weiterhin vorhanden.

`purge marked classification from ocfl` - Entfernt im Falle, dass bisher nur ein logisches Löschen im OCFL erfolgte, alle so markierten Klassifikationen entgültig aus dem System.

`purge classification {ClassID} from ocfl` - Entfernt im Falle, dass bisher nur ein logisches Löschen im OCFL erfolgte, die angegebene Klassifikation aus dem System.

`purge classifications matching {RegEx}` - Entfernt die Klassifikationen aus dem OCFL, welche dem regulären Ausdruck entsprechen.

`purge marked classifications matching {RegEx}` - Entfernt die markierten Klassifikationen aus dem OCFL, welche dem regulären Ausdruck entsprechen.

`restore classification {ClassID} from ocfl` - Stellt die Klassifikation mit der letzten Version im OCFL wieder her.

`restore classification {ClassID} from ocfl with version {version_before_delete}` - Stellt die Klassifikation mit der angegebenen Version im OCFL wieder her.

`restore ocfl classifications matching {RegEx}` - Stellt die Klassifikationen im OCFL her, welche dem regulären Ausdruck entsprechen.

## Nutzerdaten

`update ocfl users` - Aktualisiert alle Nutzerdaten im OCFL-Speicher.

`update ocfl user {UserID}` - Aktualisiert den Nutzer mit der UserID im OCFL-Speicher.

`sync ocfl users` - Syncronisiert die Nutzerdaten im OCFL mit denen der Datenbank.

`delete ocfl user {UserID}` - Löscht den Nutzer mit der UserID aus dem OCFL-Speicher. Hierbei ist die Property-Konfiguration für das Löschen im OCFL zu beachten.

`purge marked user from ocfl` - Entfernt im Falle, dass bisher nur ein logisches Löschen im OCFL erfolgte, alle so markierten User entgültig aus dem System.

`purge user {UserID} from ocfl` - Entfernt im Falle, dass bisher nur ein logisches Löschen im OCFL erfolgte, den angegebenen User aus dem System.

`purge ocfl user matching {RegEx}` - Entfernt die Nutzer aus dem OCFL, welche dem regulären Ausdruck entsprechen.

`purge marked user matching {RegEx}` - Entfernt die markierten Nutzer aus dem OCFL, welche dem regulären Ausdruck entsprechen.

`restore user {UserID} from ocfl` - Stellt den Nutzer mit der letzten Version im OCFL wieder her.

`restore user {UserID} from ocfl with version {version_before_delete}` - Stellt den Nutzer mit der angegebenen Version im OCFL wieder her.

`restore ocfl user matching {RegEx}` - Stellt die Nutzer im OCFL her, welche dem regulären Ausdruck entsprechen.

# Offene Probleme

## Zugriff auf Soft-gelöschte Daten regeln

Es kann beispielsweise für Zugriff auf ältere Versionen in der URL `/receive/{ID}` das Attribut `?r=v{n}` angegeben werden. Dies muss über ACLs geregelt werden.\
Seit Release {{<mcr-version "2023.05">}} ist der Zugriff ohne diese Rechte nicht mehr möglich!\
Benötigt sind die Rechte `view-history` für die Versionsliste und `read-history` um alte Versionen aufrufen zu können. Diese werden seit Release {{<mcr-version "2022.06">}} mitgeliefert.

## Struktur der Manager

Die Konzeption der Manager, der Zugriff darauf und die Konfiguration über properties muss überarbeitet werden.

## SOLR für Klassifikationen

Der monolitische Manager für die Speicherung von Klassifikationen in der Datenbank und in SOLR muss in einen EventHandler überführt werden.

{{<mcr-comment>}}<!-- Markdown Links: -->{{</mcr-comment>}}

[ocfl-properties]: https://raw.githubusercontent.com/MyCoRe-Org/mycore/2022.06.x/mycore-ocfl/src/main/resources/components/ocfl/config/mycore.properties "MyCoRe OCFL-Module Properties"
