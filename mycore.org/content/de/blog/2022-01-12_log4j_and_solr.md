---
title: "Log4j und Solr"
slug: log4j_and_solr
date: 2022-01-13

draft: false

blog/authors: ["Kathleen Neumann"]
blog/periods: 2022-01
blog/categories:
 - News
blog/tags:
 - "Security"
 - "log4j"
 - "Solr"

news/frontpage: true
news/title_de: "Log2J und Solr"
news/teaser_de: "Umgang mit Log4j-Sicherheitslücke und Informationen zum Update auf Solr 8.11.1"
news/title_en: "Log4J and Solr"
news/teaser_en: "Handling log4j security warnings and information for Solr 8.11.1 Update"

---

Wir haben für die MyCoRe- und MIR-Versionen 2018.06, 2019.06, 2020.06 und 2021.06 jeweils einen Snapshot mit der aktuellen log4j-Version 2.17.1 bereitgestellt. Die Snapshots stehen bei Sonatype zur Verfügung und können da heruntergeladen werden. Ein entsprechendes Release wird zeitnah nachgeliefert. Möchte man kein Update herunterladen kann in MyCoRe die poml.xml angepasst und die log4j-Version händisch aktualisiert werden. Möchte man die laufende MyCoRe-Anwendung nicht aktualisieren, kann ab Version 2017 die log4j-Version auch direkt im Tomcat-Lib-Verzeichnis ausgetauscht werden.

Bei älteren MyCoRe-Versionen die noch mit log4j 1 laufen müsste die betroffene Klasse aus den jar-Dateien gelöscht werden. Dafür stellen sowohl Apache
als auch die MyCoRe-Community keine Updates zur Verfügung.


Solr

'register solr core with name repper_main on server http://meine-Solr8.11-URL.de:8985 as core mainv8'

'show solr configuration'
MCR.Solr.ServerURL=http://meine-Solr-URL:8983
MCR.Solr.Core.mainv8.Name=repper_main
MCR.Solr.Core.mainv8.ServerURL=http://meine-Solr8.11-URL.de:8985/
MCR.Solr.Core.main.Name=repper_main
MCR.Solr.Core.main.ServerURL=http://meine-Solr-URL:8983/
MCR.Solr.Core.classification.Name=repper_class
MCR.Solr.Core.classification.ServerURL=http://meine-Solr-URL:8983/

'reload solr configuration main in core mainv8'

'rebuild solr metadata and content index in core mainv8'
