---
title: "HowTo: Includes aus dem MCRURIResolver anzeigen lassen"  
slug: debug-mcruriresolver
date: 2019-02-20

draft: false

blog/authors: ["Paul Rochowski"]
blog/periods: 2019-02
blog/categories: 
- HowTo

---

Mithilfe dieser Einstellung ist es möglich zusätzliche Logs über die MCRURIResolver Includes anzeigen zu lassen

Hierzu sind die folgenden Konfigurationsschritte notwendig:

**1. Default log4j Konfiguration überschreiben**  
Hierzu sollte zunächst die Anwendungs-log4j Original Datei (In MIR ist dies z.B. die <code>log4j2.xml</code> aus MIR Module)
ins MyCoRe-Home-Verzeichnis kopieren.  
(Bei einer Default MIR Installation wird die Datei nach <code>C:\Users...\AppData\Local\MyCoRe\mir\resources</code> verschoben.)


**2. Überschriebene Log4j Konfiguration anpassen**  
Als zusätzlicher Logger wird innerhalb der überschriebenen <code>log4j2.xml</code> folgender Eintrag vorgenommen:

{{< highlight xml "linenos=table" >}}
  <logger name="org.mycore.common.xml.MCRURIResolver" level="debug" />
{{< / highlight >}}
<br />

**3.MyCoRe Anwendung neustarten**  
An dieser Stelle muss die MyCoRe Anwendung neu gestartet werden um die überschriebene log4j Konfiguration verwenden zu können


**4.It's done**  
Zusätzliche MCRURIResolver-Logs können nun innerhalb des DOM-Baums angezeigt werden.
Diese sind in einem Kommentarblock mit Überschrift *"The following includes where resolved by MCRURIResolver:"* eingebettet.

