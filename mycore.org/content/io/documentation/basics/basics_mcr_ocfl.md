
---

title: "Die Speicherung der MyCoRe-Objekte mit OCFL"
mcr_version: ['2021.06']
author: ['Kathleen Neumann', 'Jens Kupferschmidt', 'Robert Stephan','Tobias Lenhardt']
date: "2021-10-19"

---
## Allgemeines
      
[OCFL](https://ocfl.io/), das Oxford Common File Layout, ist ein Konzept zur Speicherung von
Daten in einer versionierten Form mit Ablage der Daten auf einem nativen Plattenbereich. Somit kann der Vorteil einer einfachen
Speicherung im Dateisystem mit dem einer Dateiversionierung optimal verbunden werden. Die MyCoRe-Entwickler arbeiten seit 2020
an der Integration diese Form der Datenablage in MyCoRe. Mit Version 2021 ist nun eine prototypische Implementierung unter
Zuhilfenahme der OCFL-Library im MyCoRe-Kern verfügbar.


Hier die Referenz zum [OCFL-Java Github](https://github.com/UW-Madison-Library/ocfl-java)

## Konfiguration
Um OCFL zu nutzen, muss zuerst das entsprechende MyCoRe-Modul in der *pom.xml* integriert werden.


```
 <dependency>
    <groupId>org.mycore</groupId>
    <artifactId>mycore-ocfl</artifactId>
    <version>${mycore.version}</version>
 </dependency>
```

Die folgenden Properties werden in dieser Form im Code mitgeliefert.


```
 MCR.CLI.Classes.Internal=%MCR.CLI.Classes.Internal%,org.mycore.ocfl.commands.MCROCFLCommands

 MCR.OCFL.Repository.Main=org.mycore.ocfl.MCRSimpleOcflRepositoryProvider
 MCR.OCFL.Repository.Main.RepositoryRoot=%MCR.datadir%/ocfl-root
 MCR.OCFL.Repository.Main.WorkDir=%MCR.datadir%/ocfl-temp
```

Diese Properties sind benötigt um den Metadatenmanager für XML zu ersetzen durch den für OCFL:

```
 MCR.Metadata.Manager=org.mycore.ocfl.MCROCFLXMLMetadataManager
 MCR.Metadata.Manager.Repository=Main
```