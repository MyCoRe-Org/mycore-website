---
title: "Datei Upload mit dem 2018.06 Release"  
slug: datei-upload
date: 2018-06-13

draft: false

blog/authors: ["Sebastian Hofmann"]
blog/periods: 2018-06
blog/categories: 
- HowTo

---

Für das 2018.06 Release habe ich einen neuen Datei Upload entwickelt. Dieser basiert auf der 
[WebkitEntry](https://developer.mozilla.org/en-US/docs/Web/API/HTMLInputElement/webkitEntries#Browser_compatibility) API und wird von Firefox, Chrome und Edge unterstützt. Für alle anderen Browser gibt es einen Fallback.

{{< mcr-figure src="/images/io/blog/mir_receive_mir_mods_00000002.png" title="Uploadbereich"width="100%" />}}

Um den neuen Upload zu benutzen muss man die MyCoRe-Webtools einbinden.
In die Seite mit dem Upload muss man folgende Skripte einbinden

{{< highlight html "linenos=table" >}}
<script src="{$WebApplicationBaseURL}modules/webtools/upload/js/upload-api.js"></script>
<script src="{$WebApplicationBaseURL}modules/webtools/upload/js/upload-gui.js"></script>
<link rel="stylesheet" type="text/css" href="{$WebApplicationBaseURL}modules/webtools/upload/css/upload-gui.css" />
{{< / highlight >}}

Außerdem versucht das Skript aus der globalen Javascript-Variable die Eigenschaft **mycoreUploadSettings** auszulesen, also definiert man diese folgendermaßen:

{{< highlight html "linenos=table" >}}
<script>
  window["mycoreUploadSettings"] = {
    webAppBaseURL:"<xsl:value-of select='$WebApplicationBaseURL' />"
  }
</script> 
{{< / highlight >}}

Das Script ist jetzt fertig eingebunden und konfiguriert. Jetzt muss ein Bereich (z.B. div-Element) bestimmt werden in dem die Datei abgelegt werden muss.

{{< highlight html "linenos=table" >}}
<div class="file-upload-box well" data-upload-object="{$objID}" data-upload-target="/">
  <i class="fa fa-upload"></i>
  <xsl:value-of disable-output-escaping="yes" select="concat(' ', i18n:translate('upload.drop.derivate'))"/>
</div>
<script>
  mycore.upload.enable(document.querySelector(".file-upload-box").parentElement);
</script>  
{{< / highlight >}}

Das Attribut **data-upload-object** bestimmt in welches MyCoRe-Objekt die Dateien geladen werden sollen, entweder ein Derivat oder ein Objekt zu dem automatisch ein Derivat erstellt wird. Das Attribut **data-upload-target** bestimmt in welchen Ordner die Dateien hochgeladen werden. Die Script-Zeile am Ende aktiviert dann den Fileupload für das Div-Element.

Die Übersetzung für den Text in der Box ist wie folgt definiert:

{{< highlight system "linenos=table" >}}
 mir.upload.drop.derivate=Dateien/Verzeichnisse zum Anhängen ablegen oder <a class="mcr-upload-show">durchsuchen</a>.
{{< / highlight >}}

In der Übersetzung steckt ein Link für den Fallback für Browser die WebKitEntry nicht unterstützen. Wichtig ist das dieser die Klasse **mcr-upload-show** hat.

Damit der Benutzer weiß das er die Dateien fallen lassen kann (Drag&Drop) kann man die Box beim Dragover noch färben. Dafür kann man folgendes CSS nutzen:

{{< highlight css "linenos=table" >}}
.dragover {
  background-color:LightBlue ;
  color:white;  
}
{{< / highlight >}}