
---

title: "Integration von S3 Storage"
mcr_version: ['2022.06']
author: ['Jens Kupferschmidt', 'Robert Stephan']
description: "
      Diese Seite fasst Informationen für die Nutzung von S3 Speichern unter MyCoRe LTS 2022-06 zusammen.
    "
date: "2022-11-09"

---

## Erstellen eines S3 Test-Storage Minio-Testserver

### Allgemeines

Als Testbeispiel soll die Integration eines Minio-S3-Servers an dieser Stelle dokumentiert werden. Für Produktivsysteme kann
dieser dann durch einen im RZ verfügbaren S3 Storage erstetzt werden.

Eine Anleitung zur Installation ist unter [Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-object-storage-server-using-minio-on-ubuntu-18-04-de)
für Ubuntu 22.04 beschieben.

Die folgende Konfiguration steht in <code>/etc/default/minio</code>.
{{< highlight shell "linenos=table">}}
MINIO_VOLUMES="/data/minio/" 
MINIO_OPTS="-C /etc/minio --address {my_host}:9000 --console-address {my_host}:9090" 
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=***
{{< /highlight >}}

Somit ist die S3-Schnittstelle unter Port 9000 und die Web-Schnittstelle unter Port 9090 zugreifbar.

Für das MyCoRe-Repository muss noch der Port 9000 frei geschaltet werden.

Nun müssen noch über die Web-Schnittstelle der Nutzer und Service Account angelegt, entsprechende Buckets angelegt und Daten hochgeladen werden.

## Das Plugin

### Features
 * S3-Viewer: Front-end für einen “externen” S3-Speicher
 * Browsing durch Dateien / Ordner / Archive (ZIP, TAR)
 * GUI (Erfassungsmaske) für die S3-Konfiguration

Das Ganze ist entwickelt als selbständiges MyCoRe-Plugin: https://github.com/MyCoRe-Org/s3-mcr-plugin

### Funktionsweise / Features:
 * Speicherung einer symetrisch verschlüssselten XML-basierten Konfigurationsdatei in einem MyCoRe-Derivate
 * Javascript-basierter Datei-Viewer
 * Erweiterung der REST-API für die Datei-Viewer-Komponente
 * Monitoring von Veränderungen an den S3-Dateien nach Einbindung in das Repository (Checksummen)

## Integration in MyCoRe

 * Auschecken: git checkout https://github.com/MyCoRe-Org/s3-mcr-plugin
 * Compilieren: mvn clean install
 * Installieren: Kopieren der JAR-Datei in das Lib-Verzeichnis im MyCoRe-Home
 * Ergänzung:  Ergänzen ‘extension’ als Eintrag in der Derivate-Types-Klassifikation
 
### Ergänzung der MyCoRe-Properties

MCR.FS.Impl.S3=org.mycore.filesystem.s3.XMLS3BucketProvider
MCR.FS.Impl.S3.Key=bucket-crypt 
MCR.Crypt.Cipher.bucket-crypt.class=org.mycore.crypt.MCRAESCipher 
MCR.Crypt.Cipher.bucket-crypt.KeyFile=%MCR.datadir%/bucket.key 
MCR.Crypt.Cipher.bucket-crypt.EnableACL=false

### Verschlüsselung erstellen

Symetrische Verschlüsselung von Metadaten wird bereits an anderen Stellen verwendet (Verschlüsselung von Bearbeiterkennungen, Impact Factor, …).

Mittels der MyCoRe-CLI kann ein schlüssel generiert werden: `generate keyfile for cipher bucket-crypt`.

## Einbindung der Daten

Die Daten im S3 können nun über ein MyCore-Derivate refernziert werden. Hierfür eis ein Derivate mit einer XML-Datei der folgenden Form erstellt und
hochgeladen werden.
```xml {linenos=table}
<folder-extension-bind encrypted="false"
     class="org.mycore.filesystem.s3.XMLS3BucketProvider">
  <XMLS3Bucket>
    <protocol>http</protocol>
    <endpoint>ub1vm108.ub.uni-rostock.de:9000</endpoint>
    <bucket>mycore-aw-kiel-2022</bucket>
    <accessKey>CxXncF8Dyk6m18gZ</accessKey> 
    <secretKey>xxxxxxxxxxxxxxxxxxxxxxxxxx</secretKey>
    <directory>resarch-data-03</directory
   </XMLS3Bucket> 
</folder-extension-bind>
```

Daraus wird eine verschlüsselte Datei generiert:
```xml {linenos=table}
<extension encrypted="true" key="bucket-crypt"
      class="org.mycore.filesystem.s3.XMLS3BucketProvider">
   QakmDRGARMYe+PXuFkq7SX/Zo9GLOGELKdYE9a66aFmsVCQOuJ+SrNgY
   Vi3HQ6L/mHuMHkcak1TTwy4+fF8aMg6hCuct7zfbGGq9xEO6PeBwnD …
   +UTKXgIs9QZkjamqs4apezzKXL/MHdFNihQDMXcFpWt7OF1DVasAMQX0
</extension>
```

