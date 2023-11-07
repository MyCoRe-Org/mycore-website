---
title:  "Tomcat 10.1 Installation und Konfiguration"
slug:   tomcat10_installation_konfiguration
date:   2023-11-07
publishDate: 2023-11-07

draft:  false

blog/authors:  ["Robert Stephan"]
blog/periods:  2023-11
blog/categories:
 - HowTos
blog/tags:
 - Tomcat 10.1
 - Release 2023.06

---
MyCoRe-Anwendungen basierend auf dem Release *2023.06* benötigen für den Betrieb einen Tomcat-Server der Version 10.1.x. Alerdings werden im aktuellen Ubuntu 22.04.LTS nur die Pakete für Tomcat 9 bereitgetellt. 

Deshalb soll hier beschrieben werden, wie man den Tomcat-Server *von Hand* installieren und konfigurieren kann.
Anschließend wird erläutert, wie das Logging des Tomcat-Servers funktioniert und wie sich dessen Konfiguration weiter optimieren lässt.
<!--more-->
Tomcat Installation
-------------------
Allgemeine Informationen zur Installation und Betrieb des Tomcat-Servers findet man in der *Tomcat-Dokumentation* [^1].
Die Installation erfolgt mit folgenden Schritten:

### Installation von Java (OpenJDK 17) mit dem Paketmanager
  ```
  $ sudo apt install openjdk-17-jdk
  ```
### Tomcat-Gruppe und Tomcat-Nutzer erstellen
  Für mich hat es sich als sinnvoll erwiesen, die User ID (UID) und Group ID (GID) explizit festzulegen. Dadurch lassen sich beispielsweise Dateien auf Netzlaufwerken von mehreren Tomcat-Instanzen auf unterschiedlichen Servern parallel verwenden (sinnvoll bei Migration und Neuinstallation).
  ```
  $ sudo groupadd -g 901 tomcat
  $ sudo useradd -u 901 -g 901 -m -d /opt/tomcat -s /bin/false tomcat
  ```
  Es wird je eine Gruppe und ein Nutzer `tomcat` angelegt. Es werden die vordefinierten Group ID und User ID (`-g`, `-u`) verwendet. Das Homeverzeichnis wird konfiguriert (`-d`) und erstellt (`-m`). Der Shell-Zugriff wird deaktiviert (`-s`).

### Tomcat Version ermitteln
Die aktuelle Tomcat-Version kann auf der Tomcat-Downloadseite[^4] ermittelt werden.
Mit folgendem Befehl kann die Version als Variable gespeichert werden, um sie in Skripten, etc. verwenden zu können (Quelle: Stackoverflow[^7])
```
$ TOMCAT_VER=`curl --silent https://dlcdn.apache.org/tomcat/tomcat-10/ | grep v10 | grep -v M | awk '{split($5,c,">v") ; split(c[2],d,"/") ; print d[1]}'`
```

### Tomcat herunterladen, entpacken, symbolischen Link erstellen
  ```
  $ sudo -u tomcat mkdir -p /opt/tomcat
  $ cd /opt/tomcat
  $ sudo -u tomcat wget https://dlcdn.apache.org/tomcat/tomcat-10/v$TOMCAT_VER/bin/apache-tomcat-$TOMCAT_VER.tar.gz
  $ sudo -u tomcat tar -xf tomcat-$TOMCAT_VER.tar.gz
  $ sudo ln -s /opt/tomcat/apache-tomcat-$TOMCAT_VER /opt/tomcat/tomcat10
  ```
  Durch den symbolischen Link erhält man einen stabilen Pfad für Skript-Dateien, etc., wenn später mal die Tomcat-Version aktualisieren muss.

### Erstellen einer Tomcat-Instanz
  Es empfiehlt sich, für jede MyCoRe-Anwendung eine eigene Instanz anzulegen. Das ermöglicht es, die Anwendungen unterschiedlich zu konfigurieren, separat neuzustarten und jeweils im ROOT-Kontext (ohne Anwendungspfad in der URL) laufen zu lassen.
  ```
  $ cd /opt/tomat
  $ sudo mkdir -p /opt/mycore/rosdok_2023/tomcat_base
  $ sudo -u tomcat ./bin/makebase.sh /opt/mycore/rosdok_2023/tomcat_base
  ```
### Konfigurations-Datei server.xml
  Die Verwendung von Platzhaltern in der Datei `server.xml` ermöglicht es, einige Parameter erst beim Start der Anwendung festzulegen. Diese Datei kann deshalb für jede beliebige Tomcat-Instanz unverändert verwendet werden:
  
  ``` xml
  <?xml version="1.0" encoding="UTF-8"?>
  <!-- Note:  A "Server" is not itself a "Container", so you may not
       define subcomponents such as "Valves" at this level.
       Documentation at /docs/config/server.html
   -->
  <Server port="${tomcat.shutdown_port}" shutdown="SHUTDOWN">
    <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
    <!-- Security listener. Documentation at /docs/config/listeners.html
      <Listener className="org.apache.catalina.security.SecurityListener" />
    -->
    <!-- APR library loader. Documentation at /docs/apr.html -->
    <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
    <!-- Prevent memory leaks due to use of particular java/javax APIs-->
    <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
    <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
    <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />
    <!-- A "Service" is a collection of one or more "Connectors" that share 
           a single "Container" ... 
    -->
    <Service name="Catalina">
      <!-- A "Connector" represents an endpoint by which requests are received
           and responses are returned. Documentation at :
      -->
      <!-- alternative: HTTP connector -->
      <!--
      <Connector port="${tomcat.http_port}" protocol="HTTP/1.1"
                 connectionTimeout="20000" encodedSolidusHandling="passthrough"
                 proxyName="${tomcat.proxy_name}" proxyPort="443" scheme="https" />
      -->                                                                                 
      <Connector port="${tomcat.ajp_port}" protocol="AJP/1.3"
                 packetSize="65536" secretRequired="false" 
                 encodedSolidusHandling="passthrough"
                 proxyName="${tomcat.proxy_name}" proxyPort="443" scheme="https" />

      <!-- An Engine represents the entry point (within Catalina) that processes
           every request.  ...
           You should set jvmRoute to support load-balancing via AJP ie :
           <Engine name="Catalina" defaultHost="localhost" jvmRoute="jvm1">
      -->
      <Engine name="Catalina" defaultHost="localhost">
        <Host name="localhost"  appBase="webapps"
              unpackWARs="true" autoDeploy="true">
        </Host>
      </Engine>
    </Service>
  </Server>
  ```
Die explitze Angabe von `scheme, proxyName, proxyPort` im `<Connector>` vermeidet Probleme bei der Übernahme dieser Werte vom vorgeschalteten Apache/NGINX Proxy-Server. Die Übergabe erfolgt mittels HTTP-Header (`X-FORWARDED-HOST`, `X-FORWARDED-PROTO`), kann aber gelegentlich nicht richtig funktionieren.

### Systemd konfigurieren
- **Systemd-Konfigurations-Datei (`/etc/systemd/system/tomcat10_rosdok_2023.service`)**  
  Der Start/Registrierung von Anwendungen erfolgt in Ubuntu über *systemd*.  
  Verschiedene Anleitungen empfehlen, die Tomcat-eigenen Startup und Shutdown-Skripte (`bin/startup.sh` und `bin/shutdown.sh`) auch in der systemd-Konfiguration zu verwenden. Diese sind allerdings sehr überfrachtet, da sie für verschiedenste, teilweise auch sehr alte, Linux-Distributionen funktionieren sollen.
  Außerdem wird unnötigerweise der Tomcat-Start in mehreren Layern gekapselt. Letzendlich soll aber nur eine *einfache Java-Anwendung* gestartet werden. Die Sache wird in *Wrapping Apache Tomcat in many pointless extra layers*[^5] ausführlicher beschrieben. 
  Basierend auf diesen Ausführungen und den Informationen aus *Tomcat systemd service*[^6] enstand folgende Systemd-Datei:
  ```
  #
  # Systemd unit file for Apache Tomcat
  # based on: https://www.tech-island.com/kb/tomcat-systemd-service
  #
  [Unit]
  Description=Tomcat 10.1 for RosDok - Rostocker Dokumentenserver
  
  After=network.target postgresql.service
  After=network.target

  [Service]

  # Configuration
  Environment="CATALINA_HOME=/opt/tomcat/tomcat10"
  Environment="CATALINA_BASE=/opt/mycore/rosdok_2023/tomcat_base"
  Environment="CATALINA_TMPDIR=/tmp"
  Environment="CATALINA_OPTS=-Djava.awt.headless=true -Dcom.sun.management.jmxremote -Xmx4G"
  Environment="JAVA_OPTS=-Dtomcat.shutdown_port=8105 -Dtomcat.http_port=8180 -Dtomcat.ajp_port=8109 -Dtomcat.proxy_name=rosdok.uni-rostock.de"
  Environment="JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
  Environment="CLASSPATH=/opt/tomcat/tomcat10/bin/bootstrap.jar:/opt/tomcat/tomcat10/bin/tomcat-juli.jar"
  # alternativ können Umgebungsvariablen auch in einer externen Datei angegeben werden:
  # EnvironmentFile=-/etc/default/tomcat

  # Lifecycle
  Type=simple
  ExecStart=/usr/bin/env ${JAVA_HOME}/bin/java \
    $JAVA_OPTS $CATALINA_OPTS \
    -classpath ${CLASSPATH} \
    -Dcatalina.base=${CATALINA_BASE} \
    -Dcatalina.home=${CATALINA_HOME} \
    -Djava.io.tmpdir=${CATALINA_TMPDIR} \
    -Djava.util.logging.config.file=${CATALINA_BASE}/conf/logging.properties \
    -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager \
    org.apache.catalina.startup.Bootstrap \
    start

  ExecStop=/usr/bin/env ${JAVA_HOME}/bin/java \
    $JAVA_OPTS \
    -classpath ${CLASSPATH} \
    -Dcatalina.base=${CATALINA_BASE} \
    -Dcatalina.home=${CATALINA_HOME} \
    -Djava.io.tmpdir=${CATALINA_TMPDIR} \
    -Djava.util.logging.config.file=${CATALINA_BASE}/conf/logging.properties \
    -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager \
    org.apache.catalina.startup.Bootstrap \
    stop

  # Logging
  SyslogIdentifier=tomcat10_rosdok_2023
  #per default wird das System-Journal verwendet
  #Bei den 'geschwätzigen' MyCoRe-Anwendungen sollen klassische Logdateien verwendet werden.
  #Logrote-Konfiguration nicht vergessen!
  StandardOutput=append:/opt/mycore/rosdok_2023/tomcat_base/logs/catalina.out
  StandardError=append:/opt/mycore/rosdok_2023/tomcat_base/logs/catalina.err

  # Security
  User=tomcat
  Group=tomcat

  NoNewPrivileges=true
  CacheDirectory=tomcat10_rosdok_2023
  CacheDirectoryMode=750

  ProtectSystem=strict
  ReadWritePaths=/opt/mycore/rosdok_2023/tomcat_base/
  ReadWritePaths=-/home/tomcat/.mycore/rosdok_2023
  ReadWritePaths=-/data/mycore/rosdok_2023/
  ReadWritePaths=-/tmp/
  #more Rostock specific folders
  #ReadWritePaths=-/storage/digibib_web/cache/iiif/rosdok/
  #ReadWritePaths=-/storage/digibib_web/cache/pdf/rosdok/
  #ReadOnlyPaths=-/var/backups/

  [Install]
  WantedBy=multi-user.target
  ```
  Interessant sind die Einstellungen im Abschnitt *Logging*, wo die Logs statt standardmäßig im Systemd-Journal wieder in *klassische* Log-Dateien gelegt  werden, die dann später mit LogRotate rotiert werden können.
  Im Abschnitt *Security* werden explizit die Pfade freigegeben, auf die der Tomcat-Service lesenden und schreibenden Zugriff erhalten soll.

- **Systemd-Service starten und aktivieren**
  ```
  $ sudo systemctl start tomcat10_rosdok_2023
  $ sudo systemctl enable tomcat10_rosdok_2023
  ```
  Mit *enable* wird der Service in die Autostart-Konfiguration des Servers eingetragen und damit automatisch bei jedem Server-Reboot gestartet.

[^1]: Tomcat 10.1 Documentation, https://tomcat.apache.org/tomcat-10.1-doc
[^2]: Digital Ocean: How to Install Apache Tomcat10 on Ubuntu, https://www.digitalocean.com/community/tutorials/how-to-install-apache-tomcat-10-on-ubuntu-20-04
[^3]: Tomcat 10.1 Dokumentation: 'Logging in Tomcat', https://tomcat.apache.org/tomcat-10.1-doc/logging.html
[^4]: Tomcat 10.1 Download-Seite, https://dlcdn.apache.org/tomcat/tomcat-10/ 
[^5]: Wrapping Apache Tomcat in many pointless extra layers, https://jdebp.uk/FGA/systemd-house-of-horror/tomcat.html
[^6]: Tomcat systemd service, https://www.tech-island.com/kb/tomcat-systemd-service
[^7]: Stackoverflow: 'How to get always latest link to download Tomcat server', https://stackoverflow.com/questions/51258801/how-to-get-always-latest-link-to-download-tomcat-server-using-shell

Logging Konfiguration
---------------------
In diesem Abschnitt werden die verschiedenen Logs einer Tomcat-Anwendung und deren Konfigurationsmöglichkeiten untersucht. 
Weitere Hinweise findet man im Abschnitt 'Logging' der Tomcat-Dokumentation[^3].

### Überblick

- internes Tomcat-Logging basiert auf *JULI*
  - Fork von Apache Commons Logging
  - Grund: unabhängiges Logging vom Server und den Webanwendungen  
    (keine Überschneidung mit anderen Logging-Frameworks)
- Möglichkeiten für das Logging in Webanwendungen
  - beliebiges Logging-Framework
  - System Logging API (java.util.logging) 
  - Logging API der Servlet Spezifikation (`jakarta.servlet.ServletContext.log(...)`)

### Arten von Logs
#### Servlet-Logging
- Aufrufe von `jakarta.servlet.ServletContext.log(...)` / `GenericServlet.log(...)` werden geloggt als:
```
org.apache.catalina.core.ContainerBase.[${engine}].[${host}].[${context}]
```
- nur rudimentäre Loglevel (`INFO` für Nachrichten, `SEVERE` für Exceptions)

#### Anwendungs-Logging
- wird über Logging-Frameworks wie Log4j oder SLF4J realisiert
- ist sehr umfangreich konfigurierbar

#### Konsole
- Konsolen-Output wird standardmäßig nach `catalina.out` geloggt, das sind vorallem:
  - Aufrufe von `System.out` / `System.err` 
  - Stacktraces von Exceptions (`e.printStacktrace()`)
- Der Context-Parameter `swallowOutput` ermöglicht es, diese Nachrichten an das Servlet-Logging umzuleiten.
- Diese Aufrufe sollte in Webanwendungen *eigentlich* nicht vorkommen.

#### Access-Logging
- unabhängiges Feature, wird via `Valve` konfiguriert (siehe *'Tomcat Access-Logging'* [^11])
- kann deaktiviert werden, in der Regel wird man für diesen Zweck das Logging des vorgeschalteten WebProxies (Apache2, NginX) nutzen.
 
### java.util.logging - Konfiguration
- siehe *Tomcat-Documentation: 'Using java.util.logging'* [^12]
- Konfiguration auf verschiedenen Ebenen:
  - global via  `${catalina.base}/conf/logging.properties` 
    (Datei-Pfad konfigurierbar per System-Property in Startup-Skripten)
  - in der Webanwendung via ` WEB-INF/classes/logging.properties`
- Klasse `Filehandler` für gebuffertes Logging
- Klasse `AsyncFilehander` für zusätzlich asynchrones Logging
- Klasse `ConsoleHandler` für Logging zur Console (und damit zu `catalina.out`)

- Standardmäßig sind mehre Handler definiert.

### Empfehlungen für Produktivbetrieb
- `ConsoleHandler` entfernen, um redundantes Logging nach `catalina.out` zu unterbinden
- `FileHandler`  für nicht genutzte Anwendungen entfernen (z.B. Tomcat Host Manager)
- ggf. Encoding setzen (Standard: System-default Encoding)
- Access Log konfigurieren

### Eine mögliche Logging-Konfiguration
- Rotation der Logdateien in der Tomcat-Logging-Konfiguration ausschalten
  (`*.rotatable = false`, `*.maxDays` deaktivieren)
- stattdessen *Logrotate*[^13]  konfigurieren

#### logging.properties
in: `/opt/mycore/rosdok_2023/tomcat_base/conf/logging.properties`:
```
handlers = 1catalina.org.apache.juli.AsyncFileHandler, 2localhost.org.apache.juli.AsyncFileHandler, 3manager.org.apache.juli.AsyncFileHandler, 4host-manager.org.apache.juli.AsyncFileHandler, java.util.logging.ConsoleHandler

# RS: remove ConsoleHandler from ROOT logger (avoid duplicated logging to localhost.log and catalina.out
#.handlers = 1catalina.org.apache.juli.AsyncFileHandler, java.util.logging.ConsoleHandler
.handlers = 1catalina.org.apache.juli.AsyncFileHandler

############################################################
# Handler specific properties.
# Describes specific configuration info for Handlers.
############################################################

1catalina.org.apache.juli.AsyncFileHandler.level = FINE
1catalina.org.apache.juli.AsyncFileHandler.directory = ${catalina.base}/logs
1catalina.org.apache.juli.AsyncFileHandler.prefix = catalina.
# 1catalina.org.apache.juli.AsyncFileHandler.maxDays = 30
1catalina.org.apache.juli.AsyncFileHandler.rotatable = false
1catalina.org.apache.juli.AsyncFileHandler.encoding = UTF-8

2localhost.org.apache.juli.AsyncFileHandler.level = FINE
2localhost.org.apache.juli.AsyncFileHandler.directory = ${catalina.base}/logs
2localhost.org.apache.juli.AsyncFileHandler.prefix = localhost.
# 2localhost.org.apache.juli.AsyncFileHandler.maxDays = 30
2localhost.org.apache.juli.AsyncFileHandler.rotatable = false
2localhost.org.apache.juli.AsyncFileHandler.encoding = UTF-8

java.util.logging.ConsoleHandler.level = FINE
java.util.logging.ConsoleHandler.formatter = org.apache.juli.OneLineFormatter
java.util.logging.ConsoleHandler.encoding = UTF-8

############################################################
# Facility specific properties.
# Provides extra control for each logger.
############################################################

org.apache.catalina.core.ContainerBase.[Catalina].[localhost].level = INFO
org.apache.catalina.core.ContainerBase.[Catalina].[localhost].handlers = 2localhost.org.apache.juli.AsyncFileHandler
```

#### Logrotate-Konfiguration
- Im Netz findet man verschiedenste Tutorials und Anleitungen zu Logrotate, z.B.:
  - https://www.linux-magazin.de/ausgaben/2005/12/hier-geht-s-rund/ 
    (Zitat: "*Rotieren geht über Studieren*" ;-) )
  - https://wiki.triphahn.de/wiki/Logrotate#Logrotate_dateext_Option
  - https://manpages.ubuntu.com/manpages/jammy/man8/logrotate.8.html

Hier werden folgende Einstellungen verwendet
in: `/etc/logrotate.d/tomcat10_rosdok_2023`:
```
/opt/mycore/rosdok_2023/tomcat_base/logs/catalina.out
/opt/mycore/rosdok_2023/tomcat_base/logs/catalina.err
/opt/mycore/rosdok_2023/tomcat_base/logs/catalina.log
/opt/mycore/rosdok_2023/tomcat_base/logs/localhost.log {
    daily
    copytruncate
    dateext
    dateyesterday
    missingok
    notifempty
    compress
    delaycompress
    rotate 14
}
```

Das Ergebnis sieht dann Tomcat-Log-Verzeichnis so aus:
```
-rw-r--r-- 1 tomcat tomcat        0 Aug 12 20:13 catalina.err
-rw-r--r-- 1 tomcat tomcat    15489 Aug 19 21:14 catalina.log
-rw-r--r-- 1 tomcat tomcat    17935 Aug 19 00:10 catalina.log-20230818
-rw-r--r-- 1 tomcat tomcat     2343 Aug 18 00:10 catalina.log-20230817.gz
-rw-r--r-- 1 tomcat tomcat     3317 Aug 17 00:06 catalina.log-20230816.gz
-rw-r--r-- 1 tomcat tomcat  1321591 Aug 19 21:49 catalina.out
-rw-r--r-- 1 tomcat tomcat   766656 Aug 19 00:10 catalina.out-20230818
-rw-r--r-- 1 tomcat tomcat    66865 Aug 18 00:10 catalina.out-20230817.gz
-rw-r--r-- 1 tomcat tomcat   107547 Aug 17 00:06 catalina.out-20230816.gz
-rw-r--r-- 1 tomcat tomcat   372705 Aug 19 18:25 localhost.log
-rw-r--r-- 1 tomcat tomcat   200181 Aug 19 00:10 localhost.log-20230818
-rw-r--r-- 1 tomcat tomcat     5381 Aug 18 00:10 localhost.log-20230817.gz
-rw-r--r-- 1 tomcat tomcat     6108 Aug 17 00:06 localhost.log-20230816.gz
```
Für jede Art von Log-Datei sieht man jetzt die aktuelle Datei, eine unkomprimierte Datei vom Vortrag und ältere Dateien der letzten 14 Tage in komprimierter Form.

[^11]: Tomcat-Documentation: Access_Logging, https://tomcat.apache.org/tomcat-10.1-doc/config/valve.html#Access_Logging
[^12]: Tomcat-Documentation: Using java.util.logging, https://tomcat.apache.org/tomcat-10.1-doc/logging.html#Using_java.util.logging_(default)
[^13]: Ubuntu Manpages: Logrotate, https://manpages.ubuntu.com/manpages/jammy/man8/logrotate.8.html
