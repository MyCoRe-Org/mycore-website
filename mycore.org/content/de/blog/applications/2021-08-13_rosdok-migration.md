---
title:   "RosDok Migration 2021"
slug: anwendung-rosdok-migration
date: 2021-08-13

draft: false

blog/authors: ["Robert Stephan"]
blog/periods: 2021-08
blog/categories:
 - "Anwendungen"

#blog/tags:
 
---

Im August 2021 wurde an der [Universitätsbibliothek Rostock](https://www.ub.uni-rostock.de/) eine neue Version 
des Rostocker Dokumentenservers (**RosDok**) in Betrieb genommen.
<!--more-->

&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; <img src="/images/blog/applications/2021_rosdok_logo_left_blue.png" width="250" alt="RosDok-Logo"><br />
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; https://rosdok.uni-rostock.de

Auf **RosDok** werden Historische Bestände (Digitalisate von Büchern, Handschriften und anderen Materialien aus den Sammlungen der Universitätsbibliothek Rostock und weiterer Einrichtungen in Mecklenburg-Vorpommern) sowie aktuelle Elektronische Publikationen (wie Dissertationen, Schriftenreihen, Wissenschaftliche Publikationen oder Forschungsdaten aus der Universität Rostock) gemeinsam präsentiert.

Die Migration erfolgte ausgehend von MyCoRe Version 2017.06 LTS auf das aktuelle Release 2021.06 LTS.  
Während der Schwerpunkt bei der letzten [Aktualisierung]({{< ref "/blog/applications/2018-07-04_rosdok-relaunch" >}}) im Jahr 2018 vor allem auf der Anpassung des Weblayouts an das neue Corporate Design und Optimierung der Publikationsprozesse (z.B. durch Upload-Formulare und automatische Metadatenübernahme aus dem UB-Katalog) lag, wurde dieses Mal vor allem interne Technologien ausgetauscht oder erneuert.
  
So wurden unter anderem

#### • die Workflowengine gewechselt:
Anstelle von [Activiti](https://www.activiti.org/) wird jetzt die Open-Source BPM-Platform von [Camunda](https://camunda.com/de/) eingesetzt.
Die Workflow-Beschreibung im Format [BPMN 2.0](https://www.bpmn.de/lexikon/bpmn/) wurde vereinfacht und die Benutzeroberfläche für die Bearbeitung der Dokumente im Repository überarbeitet.

#### • das MVC-Framework ersetzt:
Für die Umsetzung des MVC-Prinzips (Model-View-Controller) wurde bislang das [Stripes-Framework](https://stripesframework.atlassian.net) eingesetzt. In der neuen Version werden die HTML-Seiten mittels JavaServer Pages und [MVC-Templates](https://eclipse-ee4j.github.io/jersey.github.io/documentation/latest/mvc.html) aus dem [Jersey](https://eclipse-ee4j.github.io/jersey/)-Framework generiert. Jersey wird in MyCoRe bereits für die Implementierung der REST-API verwendet. Feste Bestandteile der Webseite wie Header oder Footer werden als JSP-Fragmente eingebunden.

#### • die XSLT-Stylesheets für die Generierung von MODS aus PicaXML ausgelagert:
RosDok (MyCoRe) speichert die Metadaten der Dokumente intern als XML im [MODS](https://www.loc.gov/standards/mods/)-Format. Grundlage für die MODS-Metadaten auf RosDok sind die dazugehörigen Aufnahmen im Katalog der Universitätsbibliothek im [Pica](https://format.gbv.de/pica)-Format. Die für die Konvertierung der Katalogaufnahmen nach MODS verwendeten XSLT-Stylesheets wurden grundlegend überarbeitet und anschließend in das [GitHub-Projekt PicaMods](https://github.com/MyCoRe-Org/pica2mods) überführt. So können sie gemeinsam mit der MyCoRe-Community weiterentwickelt und als Open-Source durch Dritte nachgenutzt werden.


#### • XSLT3 für die Erzeugung der Metadatenseite eingeführt:
Das HTML für die Anzeige der Metadaten wurde in der alten RosDok-Version hauptsächlich mittels der [JSP XML Tag Library](https://docs.oracle.com/javaee/5/tutorial/doc/bnakq.html) erzeugt.
In der aktuellen Version wird als Technologie [XSLT3](https://www.w3.org/TR/xslt-30/) verwendet. In MyCoRe wurden neue [XSLT3-Funktionen]({{< ref "/documentation/frontend/xsl/xsl_xslt3#mycore-xslt3-funktionen" >}}) implementiert, die die Generierung der Metadatenseite unterstützen.

{{< mcr-figure src="/images/blog/applications/2021_rosdok_metadata_krey.png" 
         class="border border-primary text-center" width="100%" 
         label="Screenshot" caption="RosDok - Beispiel für Metadatenseite" attr="UB Rostock" />}}

Mit der Umstellung auf die aktuelle MyCoRe Version konnten verschiedene neue Features, wie die bereits erwähnten [XSLT-3 Funktionen]({{< ref "/documentation/frontend/xsl/xsl_xslt3#mycore-xslt3-funktionen" >}}), das [Factbased Access System]({{< ref "/documentation/permissions/acl_factbased" >}}) oder die [IIIF-Image-API für Thumbnails]({{< ref "/documentation/interfaces/interface_iiif_support#implementierung-fr-thumbnails-von-bilder-und-pdfdateien" >}}) direkt in RosDok integriert und eingesetzt werden.

<br>
