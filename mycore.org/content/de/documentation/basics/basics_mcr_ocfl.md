---
title: "Versionierung mit OCFL in MyCoRe"
description: "Nutzung des Oxford Common File Layout (OCFL) zur Versionierung von Metadaten, Klassifikationen, Nutzerdaten und Derivat-Inhalten in MyCoRe."
mcr_version: ['2025.02']
author: ['Kathleen Neumann', 'Jens Kupferschmidt', 'Robert Stephan', 'Tobias Lenhardt', 'Matthias Eichner']
date: "2025-04-01"

---

## Allgemeines

[OCFL](https://ocfl.io/), das Oxford Common File Layout, ist ein Konzept zur Speicherung von Daten in einer versionierten Form auf einem Speichersystem (z.B. lokales Dateisystem, S3-kompatibler Objektspeicher). Damit können die Vorteile einer standardisierten, transparenten Speicherung mit einer robusten Dateiversionierung optimal verbunden werden.

Die MyCoRe-Entwickler arbeiten seit 2020 an der Integration dieser Form der Datenablage in MyCoRe.
Die Implementierung wurde mit Hilfe der [Java OCFL Libary](https://github.com/OCFL/ocfl-java) umgesetzt. Diese wurde ursprünglich an der University of Wisconsin-Madison realisiert wurde und wird jetzt durch die OCFL-Community weiter betreut.

*   **Seit {{< mcr-version "2021.11" >}}:** Speicherung von **Objekt- und Klassifikations-Metadaten** im OCFL-Storage-Layout.
*   **Seit {{< mcr-version "2022.06" >}}:** Erweiterung um **Nutzerdaten**-Speicherung.
*   **Seit {{< mcr-version "2025.12" >}}:** Integration eines **NIO.2 FileSystem Providers** (`ocfl://`), welcher es ermöglicht, **Derivat-Inhalte (Dateien und Verzeichnisse)** direkt im OCFL-Repository über Standard-Java-IO/NIO-Operationen transaktional zu verwalten. Unterstützung für **S3-kompatiblen Objektspeicher** als Backend wurde hinzugefügt.

### Zukünftige Pläne

OCFL kann nun als primärer Speicher für MyCoRe-Objekte und Derivate (Metadaten **und** Inhalte) dienen. Für Utility-Objekte wie Klassifikationen und Nutzerdaten fungiert die OCFL-Ablage weiterhin als sekundärer Sicherheitsspeicher bzw. Backup, da die primäre Speicherung in der Datenbank verbleibt. Zukünftige Ergänzungen könnten dies für ACLs und Webseiten erweitern.

## Konfiguration

### Integration von OCFL

Um OCFL zu nutzen, muss zuerst das entsprechende MyCoRe-Modul in der *pom.xml* integriert werden.

```xml {linenos=table}
 <dependency>
    <groupId>org.mycore</groupId>
    <artifactId>mycore-ocfl</artifactId>
    <version>${mycore.version}</version>
</dependency>
```
Für die S3 Anbindung wird zusätzlich das **mycore-ocfl-s3** Modul benötigt:
```xml {linenos=table}
 <dependency>
    <groupId>org.mycore</groupId>
    <artifactId>mycore-ocfl-s3</artifactId>
    <version>${mycore.version}</version>
</dependency>
```

### Allgemeine Konfiguration

Die folgenden Properties werden im Code als Standardwerte mitgeliefert. Alle Konfigurationen sind hier verfügbar: [ocfl-properties]

```properties {linenos=table}
# Integration der CLI-Kommandos
MCR.CLI.Classes.Internal=%MCR.CLI.Classes.Internal%,org.mycore.ocfl.commands.MCROCFLCommands
MCR.CLI.Classes.Internal=%MCR.CLI.Classes.Internal%,org.mycore.ocfl.commands.MCROCFLRegexCommands

# Standard-Repository "Main" (Lokales Dateisystem, Hash-Layout)
MCR.OCFL.Repository.Main=org.mycore.ocfl.repository.MCROCFLHashRepositoryProvider
MCR.OCFL.Repository.Main.RepositoryRoot=%MCR.datadir%/ocfl-root
MCR.OCFL.Repository.Main.WorkDir=%MCR.datadir%/ocfl-temp
```

Diese können, sofern erwünscht, überschrieben werden. Es ist darauf zu achten,
dass die Implementation des Repository Providers das Interface `org.mycore.ocfl.repository.MCROCFLRepositoryProvider` implementiert.

Will man sein eigenes Repository anlegen bzw. ein anderes Layout oder Backend verwenden, geht das wie folgt über die jeweiligen Properties:

```properties {linenos=table}
# Repository Provider für verschiedene Layouts/Backends
MCR.OCFL.Repository.{Repository_Name}=org.mycore.ocfl.repository.{Repository_Provider}

# Konfiguration für lokale Dateisystem-Provider
MCR.OCFL.Repository.{Repository_Name}.RepositoryRoot=%MCR.datadir%/foo
MCR.OCFL.Repository.{Repository_Name}.WorkDir=%MCR.datadir%/bar

# Beispielhafte Konfiguration für S3-Provider (siehe unten)
# MCR.OCFL.Repository.{Repository_Name}.S3...
```

#### Liste der Repository Provider in MyCoRe

{{<mcr-table id="repository-provider-list" class="table" style="" col-styles="">}}
| Repository Provider                | Backend              | Layout                                                              | Beschreibung                                                                                                |
| :--------------------------------- | :------------------- | :------------------------------------------------------------------ | :---------------------------------------------------------------------------------------------------------- |
| `MCROCFLHashRepositoryProvider`    | Lokales Dateisystem  | 0003 Hashed Truncated N-tuple Trees with Object ID Encapsulation    | Standard OCFL Community Extension Layout, gut für Interoperabilität, aber "unlesbare" Verzeichnisstruktur.      |
| `MCROCFLMCRRepositoryProvider`     | Lokales Dateisystem  | MyCoRe Storage Layout                                               | MyCoRe-spezifisches Layout, ähnelt IFS2, besser navigierbar, aber kein OCFL-Standard.                      |
| `MCROCFLS3RepositoryProvider`      | S3-kompatibel        | 0003 Hashed Truncated N-tuple Trees with Object ID Encapsulation    | Ermöglicht die Speicherung im S3-Objektspeicher. Verwendet standardmäßig das Hash-Layout für S3-Kompatibilität. |
{{</mcr-table>}}

### Verfügbare Repository Layouts

#### OCFL Community Extension 0003: Hashed Truncated N-tuple Trees <br />with Object ID Encapsulating Directory for OCFL Storage Hierarchies

Das *0003-hash-and-id-n-tuple-storage-layout* ist das Standardlayout in MyCoRe für lokale Dateisysteme und S3. Es ist ein Layout aus den offiziellen Community-Extensions für OCFL.
Ein Repository mit diesem Layout lässt sich auch durch externe Programme einfach einsehen und verändern.\
Aus den OCFL Objekt IDs wird ein Hashwert gebildet, mit dem danach die Ordnerstruktur erzeugt wird.

Es sollte vermieden werden, Dateien direkt im Storage zu löschen oder neu anzulegen, da MyCoRe ggf. eigene Indizes führt und es dadurch zu Fehlern oder Datenverlust kommen kann.

Der Nachteil ist, dass durch die Bildung des Hashwertes ein direkter Dateizugriff erschwert wird. Ohne externe Tools ist es nicht leicht möglich, herauszufinden, in welchem Ordner sich welches Objekt befindet. Der Zugriff ist nur über den Root-Ordner des Objektes und die `inventory.json` möglich.

Link zur Spezifikation: [0003-hash-and-id-n-tuple-storage-layout.md](https://ocfl.io/extensions/0003-hash-and-id-n-tuple-storage-layout.html)

##### Hash Generation

Der Hashwert im *0003-hash-and-id-n-tuple-storage-layout* wird mit dem Algorithmus SHA-256 generiert. 3 Tupel mit jeweils 3 Stellen vom Beginn des Hashwertes bilden dann den Pfad zum Objekt.

Der Hashwert wird aus der OCFL Objekt ID gebildet (z.B. `mcrderivate:Project_derivate_00000101`). Anschließend wird ein sicherer Verzeichnisname erzeugt, indem Sonderzeichen wie `:` durch ihre Escape-Sequenzen codiert werden (`%3a`).

{{<mcr-table id="hash-examples" class="table" style="" col-styles="">}}
| OCFL Objekt ID                        | Tuple 1 | Tuple 2 | Tuple 3 | Verzeichnisname (kodiert)                      |
| :------------------------------------ | :-----: | :-----: | :-----: | :--------------------------------------------- |
| mcrderivate:Project_derivate_00000101 | 37c     | 205     | dbd     | mcrderivate%3aProject_derivate_00000101        |
| mcrderivate:Project_derivate_00000109 | d36     | 065     | d61     | mcrderivate%3aProject_derivate_00000109        |
| mcrderivate:Project_derivate_12345678 | 475     | 5ce     | 80d     | mcrderivate%3aProject_derivate_12345678        |
| mcrobject:Project_doctype_00000101    | cb8     | 8d8     | 068     | mcrobject%3aProject_doctype_00000101           |
| mcrobject:Project_doctype_12345678    | 482     | f56     | 5db     | mcrobject%3aProject_doctype_12345678           |
| mcrclass:rfc5646                      | d32     | 4be     | d1c     | mcrclass%3arfc5646                             |
| mcruser:editor1A@local                | 1a5     | ec9     | a72     | mcruser%3aeditor1A@local                       |
| mcracl:rules                          | e64     | 6f0     | 669     | mcracl%3arules                                 |
| mcrweb:pages                          | 5cd     | 8a6     | 495     | mcrweb%3apages                                 |
{{</mcr-table>}}

##### Ordnerstruktur (Beispiel)

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
 │               └── ... [object root: inventory.json, v1/, ...]
 ├── cb8
 │   └── 8d8
 │       └── 068
 │           └── mcrobject%3aProject_doctype_00000101
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
 ... (weitere Objekte analog)
```

#### MyCoRe Storage Layout

Das MyCoRe Storage Layout ist ein eigens entwickeltes OCFL Layout für **lokale Dateisysteme**, welches ähnlich dem nativen XML Store (IFS2) arbeitet. Die Pfadberechnung von `mcrobject` und `mcrderivate` erfolgt aus der ID und einem konfigurierbaren `SlotLayout` bzw. des eingestellten `NumberPatterns` (siehe [Metadataspeicher]({{< relref "basics_mcr_store">}})). Bei den Utility-Objekten (Klassifikationen, Nutzer, …) wird der Pfad aus deren Typ und dem Namen erstellt.

> **Achtung!**  
> Das MyCoRe Storage Layout entspricht keinem OCFL-Standard-Layout und wird daher von externen Tools nicht nativ unterstützt.
{.warning}

Allerdings ist im Vergleich zum Hash-Layout die Ordnerstruktur des MyCoRe-Layouts besser ohne externe Tools zu navigieren. Es ist zu beachten, dass trotzdem keine Daten direkt verändert werden dürfen, da es sonst zu Fehlern bei der Validierung kommen kann.

Performance-Vorteil: Im MyCoRe-Kontext ist dieses Layout oft schneller als das Hash-Layout, da der Pfad direkt aus der ID berechnet wird und kein Hash generiert werden muss.

Link zur Spezifikation: [mycore-storage-layout.md](https://github.com/MyCoRe-Org/mycore/blob/main/mycore-ocfl/src/main/java/org/mycore/ocfl/layout/mycore-storage-layout.md) <!-- Link prüfen/anpassen -->

##### Ordnerstruktur (Beispiel mit SlotLayout 4-2)

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
 ... (weitere Objekte analog)
 ├── mcrclass
 │   └── rfc5646 # Name/ID der Klassifikation
 │       └── ... [object root]
 ├── mcruser
 │   └── editor1A@local # UserID
 │       └── ... [object root]
 ... (weitere Utility-Typen)
```

### Konfiguration für S3-Speicher

Um einen S3-kompatiblen Speicher zu nutzen, muss das **mycore-ocfl-s3** Modul in der Anwendung eingebunden werden.
Zusätzlich muss man den S3 Repository Provider setzen, den Endpoint, den Access- und den Secret-Key. 

Hier ein Minimal Beispiel für eine MinIO-Instanz.
```properties {linenos=table}
MCR.OCFL.Repository.Main=org.mycore.ocfl.repository.MCROCFLS3RepositoryProvider
MCR.OCFL.Repository.Main.S3.Endpoint=http://host.docker.internal:9010
MCR.OCFL.Repository.Main.S3.Credentials.AccessKeyId={access key}
MCR.OCFL.Repository.Main.S3.Credentials.SecretAccessKey={secret key}
```

Eine vollständige Liste aller Properties findet sich
[hier](https://github.com/MyCoRe-Org/mycore/blob/main/mycore-ocfl-s3/src/main/resources/components/ocfl-s3/config/mycore.properties).

### Versionierung von XML-Metadaten (Objekte & Derivate)

Die folgenden Properties werden im Code als Standardwerte mitgeliefert:

```properties {linenos=table}
# Setzt das Standard Repository für Metadaten auf "Main"
MCR.Metadata.Manager.Repository=Main
```

Mit dem folgenden Property kann der Metadaten Manager von der bisherigen Implementierung (nativer XML Store) auf OCFL umgestellt werden. **Dies darf erst NACH der Migration der Metadaten erfolgen!**

```properties {linenos=table}
# Standard OCFL Metadaten Manager
MCR.Metadata.Manager=org.mycore.ocfl.metadata.MCROCFLXMLMetadataManager

# Optional: GZIP-komprimierte Speicherung
# MCR.Metadata.Manager=org.mycore.ocfl.metadata.MCRGZIPOCFLXMLMetadataManager
```

> **Wichtig für Remote-Speicher (S3):**  
> Bei Verwendung von Remote-Speichern ist es **zwingend erforderlich**, den `MCRFileBaseCacheObjectIDGenerator` zu konfigurieren, da das Ermitteln der höchsten ID durch Scannen des Repositories nicht effizient möglich ist:
{.warning}

```properties {linenos=table}
MCR.Metadata.ObjectID.Generator.Class=org.mycore.datamodel.common.MCRFileBaseCacheObjectIDGenerator
```

### Versionierung von Klassifikationen

Es ist auch möglich, Klassifikationen neben der Datenbank im OCFL Store zu speichern, aber primär wird dann weiterhin die Datenbank genutzt (OCFL als Backup/Historie).

> **Achtung!**  
> Aktuell ist die gleichzeitige Nutzung von OCFL und SOLR für Klassifikationen noch nicht möglich! Wir arbeiten daran.
{.warning}

Die folgenden Properties werden im Code als Standardwerte mitgeliefert:

```properties {linenos=table}
# Setzt das Standard Repository für Klassifikationen auf "Main"
MCR.Classification.Manager.Repository=Main
```

Um die OCFL Speicherung zu aktivieren, sind die folgenden Konfigurationen zu setzen:

```properties {linenos=table}
# Dies ersetzt die Standard DAO Implementation mit einer, die Events sendet
MCR.Category.DAO=org.mycore.datamodel.classifications2.impl.MCREventedCategoryDAOImpl

# Aktiviert den OCFL Classification Manager (zuständig für Lesen aus OCFL bei Bedarf)
MCR.Classification.Manager=org.mycore.ocfl.classification.MCROCFLXMLClassificationManager

# Und hier wird der EventHandler eingebunden (kümmert sich um das Schreiben nach OCFL bei Änderungen)
MCR.EventHandler.MCRClassification.020.Class=org.mycore.ocfl.classification.MCROCFLClassificationEventHandler
```

Wenn man ein anderes Repository anstatt "Main" nutzen will, funktioniert dies exakt so wie oben für die Metadaten beschrieben ist.

### Versionierung von Nutzerdaten

Es ist auch möglich, Nutzerdaten neben der Datenbank im OCFL Store zu speichern, primär wird jedoch weiterhin die Datenbank genutzt (OCFL dient als Backup/Historie). Die Daten werden dabei in der vergleichbaren Form wie bei einem `save user`-Kommando abgelegt.

Um die OCFL Speicherung zu aktivieren, sind die folgenden Konfigurationen zu setzen:

```properties {linenos=table}
# Setzt das Standard Repository für Nutzerdaten auf "Main"
MCR.Users.Manager.Repository=Main

# Und hier wird der EventHandler eingebunden (schreibt Änderungen nach OCFL)
MCR.EventHandler.MCRUser.020.Class=org.mycore.ocfl.user.MCROCFLUserEventHandler
```

### Versionierung von Derivat-Inhalten (NIO.2 FileSystem)

Mit der Einführung des NIO.2 FileSystem Providers (`ocfl://`) können nun auch die Inhalte von Derivaten (Dateien und Verzeichnisse) direkt im OCFL-Repository versioniert werden. Dies bietet eine moderne, transaktionssichere und versionierte Alternative zu älteren Speichermechanismen wie IFS2.

#### Konfiguration

Die Verwaltung der Derivat-Inhalte über OCFL wird aktiviert, indem das Standard-Dateisystem von MyCoRe auf `ocfl` gesetzt und das zugehörige Repository konfiguriert wird:

```properties {linenos=table}
# Setzt OCFL als Standard-Dateisystem für Derivat-Inhalte
MCR.NIO.DefaultScheme=ocfl

# Definiert, welches OCFL Repository für Inhalte genutzt wird (z.B. "Main").
# Dieses Repository muss unter MCR.OCFL.Repository.Main konfiguriert sein.
MCR.Content.Manager.Repository=Main
```

Für den Betrieb sind temporäre Speicherbereiche notwendig, deren Konfiguration sich je nach Repository-Typ (lokal vs. remote) unterscheidet.

##### Transaktionaler Speicher (für alle Repository-Typen)

Unabhängig vom Repository-Typ wird ein **transaktionaler Speicher** benötigt. Alle schreibenden Dateioperationen (Erstellen, Ändern, Löschen) werden zunächst in diesem lokalen Verzeichnis zwischengespeichert. Erst beim erfolgreichen Commit der MyCoRe-Transaktion werden die Änderungen atomar in das OCFL-Repository übernommen.

```properties {linenos=table}
# Konfiguration des transaktionalen Speichers
MCR.Content.TransactionalStorage=org.mycore.ocfl.niofs.storage.MCROCFLDefaultTransactionalStorage
MCR.Content.TransactionalStorage.Path=%MCR.datadir%/ocfl-storage/transactional
```

##### Zusätzlicher Cache für Remote-Repositories

Bei der Verwendung eines Remote-Repositories (z.B. S3) wird *zusätzlich* ein temporärer Cache für Lesezugriffe empfohlen. Dieser "Remote-Cache" speichert heruntergeladene Dateien lokal, um wiederholte, langsame Netzwerkzugriffe zu vermeiden.

```properties {linenos=table}
# Konfiguration des Caches für Remote-Repositories
MCR.Content.RemoteStorage=org.mycore.ocfl.niofs.storage.MCROCFLDefaultRemoteTemporaryStorage
MCR.Content.RemoteStorage.Path=%MCR.datadir%/ocfl-storage/remote
```

Die Basisimplementierung `MCROCFLDefaultRemoteTemporaryStorage` ist ein intelligenter lokaler Cache, der als **Content-Addressable Storage (CAS)** arbeitet. Dateien werden nicht unter ihrem Pfad, sondern unter ihrem SHA-512-Digest gespeichert. Dies sorgt für eine automatische Deduplizierung: Eine Datei mit identischem Inhalt wird nur einmal lokal vorgehalten, selbst wenn sie in verschiedenen Derivaten vorkommt.

**Eviction-Strategien:**

Da der lokale Speicherplatz begrenzt ist, muss eine Strategie festgelegt werden, wann und wie alte Dateien aus dem Cache entfernt werden (`eviction`).

*   **`MCROCFLNeverEvictStrategy` (Standard):** Der Cache wird niemals automatisch bereinigt. Dies ist sicher, kann aber dazu führen, dass der Speicherplatz vollläuft.
*   **`MCROCFLMaxSizeEvictionStrategy`:** Der Cache wird bereinigt, sobald er eine konfigurierte Maximalgröße überschreitet. Dabei werden die am längsten nicht mehr genutzten Dateien (LRU-Prinzip) zuerst entfernt.

**Beispielkonfiguration:**
```properties
# Aktiviert den Cache für Remote-Dateien
MCR.Content.RemoteStorage=org.mycore.ocfl.niofs.storage.MCROCFLDefaultRemoteTemporaryStorage
MCR.Content.RemoteStorage.Path=%MCR.datadir%/ocfl-storage/remote

# Strategie: Bereinigung bei Überschreitung von 1000 MB
MCR.Content.RemoteStorage.EvictionStrategy=org.mycore.ocfl.niofs.storage.MCROCFLMaxSizeEvictionStrategy
MCR.Content.RemoteStorage.EvictionStrategy.MaxSize=1000
```

**Journaling und Wartung des Caches:**

Um nach einem Neustart der Anwendung den Zustand des Caches schnell wiederherstellen zu können, ohne alle Dateien neu prüfen zu müssen, wird ein **Journal** (`cache.journal`) geführt. Jede Aktion (Hinzufügen, Löschen, Lesezugriff) wird protokolliert.

Mit der Zeit kann dieses Journal sehr groß werden, was den Startvorgang verlangsamt. Daher sollte es regelmäßig komprimiert werden.

**Komprimierungs-Befehl:**

Der Befehl `compact ocfl remote storage journal` liest den aktuellen Zustand des Caches und schreibt ein neues, sauberes Journal.

**Automatisierung per Cronjob:**

Es wird empfohlen, die Komprimierung regelmäßig (z.B. nächtlich) per Cronjob auszuführen.

```properties
# Cronjob zur Komprimierung des Remote-Cache-Journals (Täglich um 2 Uhr morgens)
MCR.Cronjob.Jobs.CompactRemoteStorageJournal=org.mycore.mcr.cronjob.MCRCommandCronJob
MCR.Cronjob.Jobs.CompactRemoteStorageJournal.Command=compact ocfl remote storage journal
MCR.Cronjob.Jobs.CompactRemoteStorageJournal.Cron=0 2 * * *
MCR.Cronjob.Jobs.CompactRemoteStorageJournal.User=system:JANITOR
MCR.Cronjob.Jobs.CompactRemoteStorageJournal.Enabled=true
```

#### Nutzung

Nach der Konfiguration können Dateien und Verzeichnisse in Derivaten über die Standard-Java-NIO.2-API (`java.nio.file.*`) oder die MyCoRe-spezifische `MCRPath`-API zugegriffen und bearbeitet werden. Das `ocfl`-Schema wird hierfür verwendet:

```java {linenos=table}
import java.io.IOException;
import java.net.URI;
import java.nio.file.Files;
import java.nio.file.Path;
import org.mycore.datamodel.niofs.MCRPath;

public void manageFile() throws IOException {
    // Beispiel mit MCRPath (wenn MCR.NIO.DefaultScheme=ocfl)
    Path filePath = MCRPath.getPath("myDerivateID_00000001", "/path/to/myFile.txt");
    Files.createDirectories(filePath.getParent());
    Files.writeString(filePath, "Hello OCFL!");
    byte[] content = Files.readAllBytes(filePath);

    // Beispiel mit Standard NIO.2 Path und explizitem Schema
    URI fileUri = URI.create("ocfl:///myDerivateID_00000001/path/to/myFile.txt");
    Path filePathNIO = Path.of(fileUri);
    Files.writeString(filePathNIO, "Hello again!");
}
```

Alle Schreiboperationen (Erstellen, Schreiben, Löschen, Verschieben) innerhalb einer MyCoRe-Transaktion werden im **transaktionalen Speicher** gepuffert. Erst beim Commit der Transaktion (`MCRTransactionManager.commitTransactions()`) werden diese Änderungen in einer neuen OCFL-Version im Ziel-Repository festgeschrieben. Dies gewährleistet Konsistenz und atomare Operationen.
### Optionen für das Löschen

Werden Daten im OCFL gelöscht, so werden sie per default nur als gelöscht markiert (logisches Löschen). Ältere Versionen können erstmal per default noch eingesehen werden.

Das endgültige Löschen von Daten (Purge), inklusive der gesamten Historie des Objekts, kann über die folgenden Properties festgelegt werden. Die Konfiguration ist sehr granular möglich.

```properties {linenos=table}
# Globales Standardverhalten (default: false = kein Purge)
# MCR.OCFL.dropHistory=true

# Pro OCFL-Typ
# MCR.OCFL.dropHistory.mcruser=true
# MCR.OCFL.dropHistory.mcrobject=true
# MCR.OCFL.dropHistory.mcrderivate=true
# MCR.OCFL.dropHistory.mcrclass=true

# Pro MyCoRe-ID (Projekt, Typ, Base, volle ID) - spezifischer als Typ
# MCR.OCFL.dropHistory.projektA=true
# MCR.OCFL.dropHistory.projektA_typB=true
# MCR.OCFL.dropHistory.projektA_typB_00001234=true

# Auch pro OCFL-Typ + MyCoRe-ID
# MCR.OCFL.dropHistory.mcrobject.projektA_typB=true

# Reguläre Ausdrücke (werden vor/nach anderen Regeln geprüft)
# MCR.OCFL.dropHistory.preMatch=.*_temp_.*|true  # Beispiel: Alle mit _temp_ purgen
# MCR.OCFL.dropHistory.postMatch=.*_keep_.*|false # Beispiel: Alle mit _keep_ nie purgen

# Detaillierte Prioritäten siehe Konfigurationsdatei [ocfl-properties]
```

## Migration

### Migration von Metadaten zu OCFL

Es sollte sichergestellt werden, dass während des Migrationsprozesses durch die Nutzer keine Daten bearbeitet werden.

Zunächst wird der Metadaten-Manager bei dem nativen XML-Plattenspeicher belassen (`MCR.Metadata.Manager` **nicht** auf OCFL setzen) und es sollte geprüft werden, dass das Ziel-Repository (z. B. `Main`) korrekt eingerichtet ist.

Mit dem Kommando `migrate metadata to repository {RepositoryID}` können die Daten in das angegebene OCFL Repository überspielt werden. `{RepositoryID}` ist der Name des Repositories (z.B. `Main`). Das Kommando gibt in einer Statistik aus, ob alle Metadaten migriert werden konnten. Optional kann mit `migrate metadata to repository {RepositoryID} with pruners {PrunerIDs}` die Historie während der Migration reduziert werden (siehe `MCR.OCFL.Metadata.Migration.Pruners.*` Properties).

Auch wenn keine Fehler zu sehen sind, sollte man trotzdem anhand der Anzahl überprüfen, ob alle Objekte erfolgreich übertragen wurden.

Wenn alles erfolgreich übertragen wurde, kann man den MetadatenManager für den Produktivbetrieb umstellen:
```properties {linenos=table}
 MCR.Metadata.Manager=org.mycore.ocfl.metadata.MCROCFLXMLMetadataManager
```

### Migration von Derivat-Inhalten zu OCFL (Work in Progress!)

Um bestehende Derivat-Inhalte (z.B. aus IFS2) in das OCFL-Repository zu migrieren, nachdem `MCR.NIO.DefaultScheme=ocfl` konfiguriert wurde, stehen neue CLI-Kommandos zur Verfügung:

1.  **Migration starten:**
*   Führen Sie `migrate derivates to ocfl` aus. Dies generiert eine Liste von `migrate derivate ...`-Kommandos für alle bekannten Derivate.
*   Führen Sie die generierten `migrate derivate {derivateId} to ocfl`-Kommandos aus (z.B. über `sh < file` oder `mcr_cli ...`). Jedes Kommando kopiert Dateien und Verzeichnisse aus dem vorherigen Default-Dateisystem (z.B. `ifs2://{derivateId}/...`) nach `ocfl://{derivateId}/...`.
2.  **Validierung (Wichtig!):** Nach der Migration **muss** die Korrektheit überprüft werden:
*   Führen Sie `validate ocfl derivates` aus. Dies generiert `validate ocfl derivate ...`-Kommandos.
*   Führen Sie die generierten `validate ocfl derivate {derivateId}`-Kommandos aus. Diese vergleichen die Digests (Prüfsummen) der Dateien im alten Speicher mit denen im neuen OCFL-Speicher. Abweichungen werden in der Logdatei und in `conf/ocfl-derivate-migration-errors` protokolliert.

> **Achtung!**  
> Erst wenn die Validierung für alle Derivate fehlerfrei durchläuft (<code>ocfl-derivate-migration-errors</code> existiert nicht oder ist leer), kann der alte Speicher (z.B. IFS2-Verzeichnisse) sicher entfernt werden! 
{.warning}

### Migration von Klassifikationen und Nutzerdaten zu OCFL

Die Daten für User und Klassifikationen können initial mit `update ocfl classifications` und `update ocfl users` nach OCFL migriert werden. Da die Datenbank die Primärquelle bleibt, ist dies weniger kritisch als die Metadaten- oder Derivat-Migration. Die EventHandler sorgen dafür, dass zukünftige Änderungen automatisch ins OCFL geschrieben werden.

### Migration zwischen OCFL Layouts/Backends

Die Migration von **Metadaten** zwischen verschiedenen OCFL-Repositories (z.B. von lokal Hash zu S3, oder von MyCoRe-Layout zu Hash-Layout) funktioniert analog zur initialen Migration:
1.  Stellen Sie sicher, dass `MCR.Metadata.Manager` auf die **Quell**-OCFL-Implementierung zeigt (`MCROCFLXMLMetadataManager`).
2.  Konfigurieren Sie das Quell-Repository mit `MCR.Metadata.Manager.Repository={Quell-RepositoryID}`.
3.  Konfigurieren Sie das **Ziel**-Repository unter einem **anderen** Namen (z.B. `Target`) mit dem gewünschten Provider und Pfad/Endpoint.
4.  Führen Sie `migrate metadata to repository {Ziel-RepositoryID}` aus.
5.  Nach erfolgreicher Migration, ändern Sie `MCR.Metadata.Manager.Repository` auf das Ziel-Repository.

Hierbei kann es vorkommen, dass ein MCRUsageException ausgegeben wird. Dies tritt dann auf, wenn Objekte oder Derivate vor der Migration zu OCFL gelöscht wurden und daher nicht mit migriert wurden. Das Problem entsteht, wenn versucht wird, deren Versionsverlauf zu lesen, da MyCoRe diese IDs noch immer bekannt sind. Es tritt nicht auf wenn Objekte und Derivate NACH der Migration gelöscht werden, da nun der Versionsverlauf nicht mit gelöscht wird.

Das Problem wird in einer zukünftigen Version behoben werden und hat <ins>keinen Einfluss auf die Funktionsweise von OCFL</ins>. Es kann daher ohne Bedenken ignoriert werden.

Für **Derivat-Inhalte** gibt es derzeit keine dedizierten MyCoRe-Kommandos zur Migration zwischen OCFL-Repositories/Layouts. Dies müsste manuell (z.B. durch Kopieren der Repository-Verzeichnisse bei lokalen Stores) oder über externe OCFL-Tools erfolgen.

## Rücksetzen auf Speicher ohne OCFL

**Experimentell: Muss noch endgültig getestet werden.**

### XML-Metadaten
1.  Den `MCR.Metadata.Manager` zurück auf die vorherige Implementierung (z.B. `org.mycore.datamodel.common.MCRXMLMetadataManager`) setzen.
2.  Ggf. `MCR.Metadata.Manager.Repository` entfernen.
3.  Die Metadaten müssen aus dem OCFL-Repository (z.B. über `restore object`-Kommandos oder externe Tools) in das alte Format/den alten Speicher zurückmigriert werden. **Dieser Prozess ist komplex und erfordert sorgfältige Planung.**

### Derivat-Inhalte
1.  Den `MCR.NIO.DefaultScheme` zurück auf das vorherige Schema (z.B. `ifs2`) setzen.
2.  Ggf. `MCR.Content.Manager.Repository` und `MCR.Content.TempStorage` entfernen/anpassen.
3.  Die Inhalte müssen aus dem OCFL-Repository (z.B. über `Files.copy` oder externe Tools) in den alten Speicher zurückmigriert werden. **Dieser Prozess ist potenziell zeit- und speicheraufwendig.**

### Klassifikationen
Da die Klassifikationen primär in der Datenbank gespeichert sind, ist nur der Manager (`MCR.Classification.Manager`, `MCR.Category.DAO`) und der EventHandler (`MCR.EventHandler.MCRClassification...`) umzukonfigurieren bzw. zu entfernen. Der OCFL-Teilbaum kann gelöscht werden.

### Nutzerdaten
Da die Nutzer primär in der Datenbank gespeichert sind, ist nur der EventHandler (`MCR.EventHandler.MCRUser...`) zu entfernen. Der OCFL-Teilbaum kann gelöscht werden.

## Benutzung und Kommandos

Für die laufende Benutzung (nach initialer Konfiguration/Migration) ist es nicht zwingend notwendig, eine "Migration" durchzuführen. Bei einer Änderung eines Objekts, einer Klassifikation etc. wird automatisch eine neue Version im konfigurierten OCFL Store abgelegt, auch wenn dieser für das spezifische Objekt noch leer war. Bei Derivat-Inhalten wird der OCFL-Objekt-Root bei der ersten Schreiboperation angelegt.

### Globale Kommandos

*   `purge all marked from ocfl`: Löscht **endgültig** alle OCFL-Einträge (Objekte, Derivate, Klassen, User), die zuvor nur logisch gelöscht wurden (erfordert Bestätigung).
*   `purge all ocfl entries matching {RegEx}`: Löscht **endgültig** alle OCFL-Einträge, deren OCFL Objekt ID dem regulären Ausdruck entspricht (erfordert Bestätigung).
*   `purge all marked ocfl entries matching {RegEx}`: Löscht **endgültig** alle logisch gelöschten OCFL-Einträge, deren OCFL Objekt ID dem regulären Ausdruck entspricht (erfordert Bestätigung).

### Metadaten (Objekte/Derivate)

*   `migrate metadata to repository {RepositoryID} [with pruners {PrunerIDs}]`: Migriert alle Metadaten aus dem aktuellen `MCR.Metadata.Manager` in das angegebene OCFL Repository. Optional können Pruner zur Reduzierung der Historie angegeben werden.
*   `purge marked metadata from ocfl`: Löscht **endgültig** alle logisch gelöschten Metadaten-Objekte (erfordert Bestätigung).
*   `purge object {MCRID} from ocfl`: Löscht ein spezifisches Metadaten-Objekt **endgültig** aus OCFL (erfordert Bestätigung).
*   `purge marked ocfl objects matching {RegEx}`: Löscht **endgültig** logisch gelöschte Metadaten-Objekte, deren MCRID dem Regex entspricht (erfordert Bestätigung).
*   `restore object {MCRID} from ocfl`: Stellt die letzte Version des Objekts aus OCFL im aktuellen `MCR.Metadata.Manager` wieder her (überschreibt ggf. existierende Daten!).
*   `restore object {MCRID} from ocfl with version {version}`: Stellt eine spezifische Version des Objekts aus OCFL wieder her.
*   `restore ocfl objects matching {RegEx}`: Stellt die letzte Version von logisch gelöschten Objekten wieder her, deren MCRID dem Regex entspricht.

### Klassifikationen

*   `update ocfl classifications`: Schreibt den aktuellen Stand aller Klassifikationen aus der DB nach OCFL.
*   `update ocfl classification {ClassID}`: Schreibt den aktuellen Stand einer Klassifikation aus der DB nach OCFL.
*   `sync ocfl classifications`: Synchronisiert den OCFL Store mit der DB (aktualisiert vorhandene, markiert fehlende als gelöscht).
*   `delete ocfl classification {ClassID}`: Markiert eine Klassifikation in OCFL als gelöscht (oder purgt sie, je nach Konfiguration).
*   `purge marked classifications from ocfl`: Löscht **endgültig** alle logisch gelöschten Klassifikationen (erfordert Bestätigung).
*   `purge classification {ClassID} from ocfl`: Löscht eine Klassifikation **endgültig** (erfordert Bestätigung).
*   `purge ocfl classifications matching {RegEx}`: Löscht Klassifikationen **endgültig**, deren ID dem Regex entspricht (erfordert Bestätigung).
*   `purge marked ocfl classifications matching {RegEx}`: Löscht logisch gelöschte Klassifikationen **endgültig**, deren ID dem Regex entspricht (erfordert Bestätigung).
*   `restore classification {ClassID} from ocfl [with version {version}]`: Stellt eine Klassifikation aus OCFL in der Datenbank wieder her (überschreibt!).
*   `restore ocfl classifications matching {RegEx}`: Stellt die letzte Version von logisch gelöschten Klassifikationen wieder her, deren ID dem Regex entspricht.

### Nutzerdaten

*   `update ocfl users`: Schreibt den aktuellen Stand aller Nutzer aus der DB nach OCFL.
*   `update ocfl user {UserID}`: Schreibt den aktuellen Stand eines Nutzers aus der DB nach OCFL.
*   `sync ocfl users`: Synchronisiert den OCFL Store mit der DB.
*   `delete ocfl user {UserID}`: Markiert einen Nutzer in OCFL als gelöscht (oder purgt ihn).
*   `purge marked users from ocfl`: Löscht **endgültig** alle logisch gelöschten Nutzer (erfordert Bestätigung).
*   `purge user {UserID} from ocfl`: Löscht einen Nutzer **endgültig** (erfordert Bestätigung).
*   `purge ocfl users matching {RegEx}`: Löscht Nutzer **endgültig**, deren ID dem Regex entspricht (erfordert Bestätigung).
*   `purge marked ocfl users matching {RegEx}`: Löscht logisch gelöschte Nutzer **endgültig**, deren ID dem Regex entspricht (erfordert Bestätigung).
*   `restore user {UserID} from ocfl [with version {version}]`: Stellt einen Nutzer aus OCFL in der Datenbank wieder her (überschreibt!).
*   `restore ocfl users matching {RegEx}`: Stellt die letzte Version von logisch gelöschten Nutzern wieder her, deren ID dem Regex entspricht.

### Derivat-Inhalte (Neu)

*   `migrate derivates to ocfl`: Erzeugt eine Liste von Migrationskommandos für alle Derivate, um Inhalte ins OCFL zu kopieren.
*   `migrate derivate {derivateId} to ocfl`: Migriert den Inhalt eines spezifischen Derivats ins OCFL.
*   `validate ocfl derivates`: Erzeugt eine Liste von Validierungskommandos für alle Derivate.
*   `validate ocfl derivate {derivateId}`: Vergleicht Digests zwischen altem Speicher und OCFL für ein Derivat.

## Offene Probleme

*   **Zugriff auf Soft-gelöschte Daten regeln:** Es kann beispielsweise für Zugriff auf ältere Versionen in der URL `/receive/{ID}` das Attribut `?r=v{n}` angegeben werden. Der Zugriff darauf muss über ACLs (`view-history`, `read-history`) geregelt werden. Seit Release {{< mcr-version "2023.05" >}} ist der Zugriff ohne diese Rechte nicht mehr möglich.
*   **SOLR für Klassifikationen:** Die Integration von SOLR und dem OCFL EventHandler für Klassifikationen muss ggf. noch finalisiert werden, um Konflikte zu vermeiden.
*   **Performance Remote Storage:** Die Performance bei der Verwendung von Remote-Speichern (S3), insbesondere bei vielen kleinen Dateien oder häufigen NIO FS Zugriffen, sollte evaluiert und ggf. optimiert werden.
*   **Migration von Derivat-Inhalten zwischen OCFL-Repositories:** Derzeit fehlen dedizierte MyCoRe-Kommandos.

{{< mcr-comment >}}<!-- Markdown Links: -->{{< /mcr-comment >}}

[ocfl-properties]: https://github.com/MyCoRe-Org/mycore/blob/main/mycore-ocfl/src/main/resources/components/ocfl/config/mycore.properties "MyCoRe OCFL-Module Properties"
