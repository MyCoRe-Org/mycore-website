---

title: "Migration MIR LTS 2026.06 nach 2026.12"
mcr_version: ['2026.12']
author: ['']
description: "Listet die einzelnen Schritte zur Migration von MIR LTS 2026.06 nach 2026.12 auf."
date: "2000-01-01"

---
{{< mcr-comment >}} Publish this page by setting the date and removing icon and property 'pre' from menus.de.yaml {{< /mcr-comment >}}
<div class="alert alert-warning">
  Diese Seite ist <strong>Work in Progress</strong>. <br />
  Sie wird im Rahmen der Fertigstellung des aktuellen MIR-Releases weiter ergänzt!
</div>

## Migrationsanleitung MIR

Hier sind weitere Schritte zur MIR-Migration gelistet, die neben der
[Migrationsanleitung für MyCoRe]({{< ref migrate_mcr2026_12 >}}) noch relevant sind.

### Modulare Metadaten- und Admin-Box

Mit <a href="https://mycore.atlassian.net/browse/MIR-1661">MIR-1661</a> wurde das Stylesheet `modsmetadata.xsl`, das
bisher die Metadaten-Box und die Admin-Box der Detailseite erzeugt hat, in einzelne Felder aufgeteilt. Jedes Feld (z.
B. `title`, `dates.issued`, `identifier`) ist nun ein eigenes Template in einem eigenen Modul. Welche Felder in 
welcher Reihenfolge angezeigt werden, wird über Properties gesteuert, auf Wunsch auch abhängig vom Genre.
Die Ausgabe entspricht der bisherigen Darstellung.

Die Stylesheets `modsmetadata.xsl` und `modsmetadata-legacy.xsl` sind entfallen. Eigene Anpassungen, die diese
Stylesheets überschrieben haben, müssen auf Feld-Module umgestellt werden (siehe Beispiel unten).

Folgende Properties sind neu:

```properties
# Module mit den Feld-Templates der Metadaten-Box bzw. Admin-Box
MCR.URIResolver.xslIncludes.metadatabox=metadata/metadata-box/mods/title.xsl,...
MCR.URIResolver.xslIncludes.admindatabox=metadata/admindata-box/state.xsl,...

# Angezeigte Felder und deren Reihenfolge
MIR.MetadataBox.Fields=title,conference,name,parent,related-item,...
MIR.AdmindataBox.Fields=state,created,created.by,note,modified,modified.by,object-id,identifier.intern,version
```

Zusätzlich kann die Feldliste der Metadaten-Box pro Genre angepasst werden. Ist für ein Genre keine eigene Liste
gesetzt, wird die Liste des übergeordneten Genres verwendet (z.B. `thesis` für `dissertation`), sonst die
Standardliste. Mit `none` wird die Metadaten-Box für ein Genre ausgeblendet:

```properties
MIR.MetadataBox.Fields.thesis=title,dates.accepted,dates.issued,name,corporate,identifier,language,subject,classification,note
MIR.MetadataBox.Fields.article=none
```

Das Property `MIR.Metadata.Admindata.ShowRealUserName` wurde in `MIR.AdmindataBox.ShowRealUserName` umbenannt und ist
nun deprecated. Wer die Anzeige von Klarnamen in der Admin-Box aktiviert hat, muss das Property umbenennen:

```properties
MIR.AdmindataBox.ShowRealUserName=true
```

#### Beispiel: Feld für ein Genre überschreiben

Soll für Abschlussarbeiten statt der Titelzeile nur der übersetzte Titel angezeigt werden, genügt ein eigenes Modul
mit einem Template für das Feld `title` und einer höheren `priority`. Das Attribut `genres` enthält das Genre des
Dokuments samt übergeordneten Genres, das Template greift also z.B. auch für `dissertation` und `master_thesis`.
Das ursprüngliche Template muss dafür nicht angepasst werden:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mirobject="http://www.mycore.de/xslt/mirobject"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:template match="field[@name='title'][contains-token(@genres, 'thesis')]" mode="metadata-box-field" priority="1">
    <xsl:param name="object" as="element(mycoreobject)" />

    <xsl:call-template name="meta-row-from-nodes">
      <xsl:with-param name="nodes" select="mirobject:mods($object)/mods:titleInfo[@type='translated']/mods:title" />
      <xsl:with-param name="label-key" select="'mir.title.type.translated'" />
    </xsl:call-template>
  </xsl:template>

</xsl:stylesheet>
```

Das Modul (z.B. `xslt/metadata/custom/thesis-title.xsl`) wird anschließend an die Liste der Module angehängt:

```properties
MCR.URIResolver.xslIncludes.metadatabox=%MCR.URIResolver.xslIncludes.metadatabox%,metadata/custom/thesis-title.xsl
```

> Neue Felder werden auf die gleiche Weise ergänzt: Template mit einem neuen Feldnamen (z.B.
> `match="field[@name='access-condition']"`) anlegen, Modul an `MCR.URIResolver.xslIncludes.metadatabox` anhängen
> und den Feldnamen in `MIR.MetadataBox.Fields` an der gewünschten Stelle eintragen. Existieren für ein Feld zwei
> Templates mit gleicher `priority`, bricht die Transformation mit einem Fehler ab.
