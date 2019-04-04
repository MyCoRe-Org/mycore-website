---
title: "datamodel-plugin erweitern"  
slug: datamodel-plugin-erweitern
date: 2018-03-15

draft: false

blog/authors: ["Thomas Scheffler"]
blog/periods: 2018-03
blog/categories:
- HowTo
blog/tags:
- Datenmodell
- Maven

---

Wer das MyCoRe [Datamodel-Plugin](https://github.com/MyCoRe-Org/datamodel-plugin) verwendet, um ein eigenes [Datenmodell](http://www.mycore.de/documentation/basics/mcrobject/mcrobject_datadef.html) in ein XML-Schema zu übersetzen kommt vielleicht an den Punkt, dass er eigene Datentypen ergänzen möchte. Dabei stellt sich die Frage, wie man Erweiterungen diesen Plugin zur Verfügung stellt.<!--more--> 

Heute habe ich entdeckt, dass der Prozess des Übersetzens relativ leicht mittels [XML-Catalogs](http://www.oasis-open.org/committees/download.php/14809/xml-catalogs.html) zu erweitern ist.

Das [Haupt-Stylesheet](https://github.com/MyCoRe-Org/datamodel-plugin/blob/master/src/main/resources/datamodel2schema.xsl) inkludiert das leere Stylesheet [datamodel2ext.xsl](https://github.com/MyCoRe-Org/datamodel-plugin/blob/master/src/main/resources/datamodel2ext.xsl).

Das Plugin gibt im Debug-Modus von Maven ein paar Hinweise:

{{< highlight system "linenos=table" >}}
[DEBUG] -- end configuration --
Setting resolver verbosity to maximum.
Parse catalog: ./xcatalog
Loading catalog: ./xcatalog
Default BASE: file:////git/mycore/xcatalog
Catalog does not exist: file:////git/mycore/xcatalog
{{< / highlight >}}

Es sucht eine Datei *xcatalog* im aktuellen Verzeichnis. In diese schreiben wir folgende Zeilen:

{{< highlight xml "linenos=table" >}}
<?xml version="1.0" encoding="UTF-8"?>
<catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
  <uri name="datamodel2ext.xsl" uri="mydef.xsl" />
</catalog>
{{< / highlight >}}

Und schon wird statt *datamodel2ext.xsl* die Datei *mydef.xsl* im aktuellen Verzeichnis eingebunden. Der Inhalt in <code>@uri</code> wird relativ zu *xcatalog* aufgelöst. Der Verweis kann aber auch absolut sein und z.B. auf einem Web-Server (z.B. Git-Repository) zeigen.

Damit sollte es leicht möglich sein, Templates zur ergänzen oder zu überscheiben.