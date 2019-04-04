---

date: "2018-06-29"
description: beschreibung der wichtigsten MyCoRe Funktionen.
title: Konfiguration
author: ['Kathleen Neumann']

mcr_version: ['2017.06','2018.06']

---


## Konfigurationsverzeichnis

Die Konfiguration der MyCoRe-Anwendung befindet sich typischer Weise unter:

* Windows: <code>c:\Users\&lt;username>\AppData\Local\MyCoRe\&lt;appname></code>
* Linux: <code>/home/&lt;username>/.mycore/&lt;appname></code>

Wird eine Anwendung neu initialisiert, kann das Konfigurationsverzeichnis mit dem CLI-Befehl:
<code>create configuration directory</code> neu angelegt werden. Bestehende Konfigurationen
werden dabei nicht überschrieben!

Aufbau des neu erstellten Konfigurations-Verzeichnisses:

{{< highlight shell >}}
/data
/lib
/resources
  /META-INF
    persistence.xml
mycore.properties
{{< / highlight >}}

Weitere Informationen dazu siehe [MCRConfigurationDir](http://www.mycore.de/generated/mycore/apidocs/org/mycore/common/config/MCRConfigurationDir.html)

## MyCoRe-Properties

<table class="table table-striped">
        <caption>Übersicht der wichtigsten Properties:</caption>
        <thead>
          <tr>
            <th>Property</th>
            <th>Beschreibung</th>
            <th>Beispiel</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>MCR.NameOfProject</td>
            <td>Name des Projektes</td>
            <td>MIR</td>
          </tr>
          <tr>
            <td>MCR.datadir</td>
            <td>MyCoRe-Datenverzeichnis, enthält alle Daten</td>
            <td>%MCR.basedir%/data (default)</td>
          </tr>
          <tr>
            <td>MCR.Solr.ServerURL <span class="label label-warning">2018.06</span></td>
            <td>URL zum Server für die gegebene Anwendung</td>
            <td>http://localhost:8983/</td>
          </tr>
          <tr>
            <td>MCR.Solr.Core.main.Name <span class="label label-warning">2018.06</span></td>
            <td>Name des Solr-Kerns vom Typ <code>main</code></td>
            <td>mycore</td>
          </tr>
          <tr>
            <td>MCR.Module-solr.ServerURL <span class="label label-warning">2017.06</span></td>
            <td>URL zum Solr-Kern für die gegebene Anwendung</td>
            <td>http://localhost:8080/solr/mycore</td>
          </tr>
          <tr>
            <td>MCR.baseurl</td>
            <td>Basis-URL unter der die Anwendung läuft</td>
            <td>http://mycore.de/mir/</td>
          </tr>
        </tbody>
      </table>
<!-- https://www.jamestharpe.com/code-comments-markdown/ -->
[//]: # (TODO: Welche MyCoRe-Properties gibt es und wie sind sie anzupassen? Was macht <code>mycore.active.properties</code> und <code>mycore.resolved.properties</code>)


