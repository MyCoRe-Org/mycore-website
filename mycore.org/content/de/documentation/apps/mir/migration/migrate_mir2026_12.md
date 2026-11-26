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

### Entfernung des Layouts CosmoL ({{<mcr-ticket "MIR-1709" >}})

Das nicht mehr gepflegte Layout CosmoL wurde entfernt. Anwendungen, die in ihrer `mycore.properties` noch

```properties
MIR.Layout.Theme=cosmol
```

gesetzt haben, müssen auf das Layout `flatmir` umgestellt werden, da sonst keine Seite mehr gerendert werden kann:

```properties
MIR.Layout.Theme=flatmir
```

### Modulare Metadaten- und Admin-Box ({{<mcr-ticket "MIR-1661" >}})

Mit diesem Ticket wurde das Stylesheet `modsmetadata.xsl`, das
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
{.note}

### Verbesserte Personensuche ({{<mcr-ticket "MIR-1718" >}})

Die Personensuche wurde ein Stück weit verbessert, sodass Namen, deren erster Buchstabe Diakritika/Akzente hat,
nun besser unterstützt werden (sofern der Buchstabe aus dem Bereich A-Z stammt, für andere Buchstaben, z.B.
Griechische oder Kyrillische, wurde ein weiterer Button mit Beschriftung `…` hinzugefügt).

Hierfür muss das Solr-Schema aktualisiert und die Metadaten neu indexiert werden.
Dies kann mit den folgenden Kommandos erledigt werden:

- `reload solr configuration main in core main`
- `rebuild solr metadata index in core main`
- `optimize solr index in core main`
- `repair metadata search of type mods`

Das zur Suche verwendete Muster wird nun nicht mehr über den Parameter `terms.regex`,
sondern über den Parameter `regex` an das Servlet zur Personensuche übergeben.
Entsprechende Eintragungen, z.B. in der Datei `actionmappings.xml` oder anderen Verlinkungen,
müssen angepasst werden. 

In den Mustern kann auf die spezielle Behandlung von Umlauten verzichtet werden.
Insbesondere in der Datei `actionmappings.xml` kann also z.B. `terms.regex=%5Ba%7C%C3%A4%7C%C3%84%5D.*`
durch `regex=a.*` ersetzt werden.

Mit dem neuen Konfigurationswert `MIR.Search.PersonIndex.HideButtonRegex` kann eingestellt werden, 
ob das zur Suche verwendete Muster angezeigt werden soll, wenn einer der Buttons verwendet wurde.

### Integration und Umbenennung des Navigation-Plugins in MIR ({{<mcr-ticket "MIR-1684" >}}, {{<mcr-ticket "MIR-1730" >}})

Das [Navigations-Plugin](https://github.com/MyCoRe-Org/mir-navigation-plugin) ist ab 2026.12 Teil von MIR. 
Hierbei wurden einige Anpassungen und Erweiterungen integriert. Insbesondere wurde das Feature an sich und 
mit dem Feature in Verbindung stehende Dinge in "Guidance" umbenannt, um es besser von anderen Features,
die Teil von MIR sind, abgrenzen zu können.

Wer das Plugin bisher nicht verwendet hat, muss nichts tun. Wer das Plugin bisher verwendet hat,
muss es entfernen und ein paar kleinere Anpassungen vornehmen.

Die wichtigsten Unterschiede:

- Für die Konfiguration einer Navigation wurde bisher die Datei mit Namen `navigation.xml` im Derivat des Typs `navigation` verwendet.  
  Nun wird die Startdatei (per Konvention: `guidance.xml`) im Derivat des Typs `guidance` verwendet.
- Die XML-Struktur der Konfigurationsdatei wurde überarbeitet, z.B. heißt das Root-Element nun `guidance` und nicht mehr `item`.
- Das Feature wurde um einige Aspekte erweitert, die in der Konfigurationsdatei konfiguriert werden können; insbesondere:
  - Listenelemente konnten bereits eine sprachabhängige Beschriftung haben.  
    Nun kann auch die URL sprachabhängig konfiguriert werden.
  - Listenelement konnten bisher nur absolute oder relative URLs haben.  
    Nun kann alternativ eine XML-Datei aus demselben Derivat referenziert werden,
    die mit dem `MCRDerivateContentTransformerServlet` gerendert wird.
    Zudem kann nun ein URL-Pfad global konfiguriert werden,
    der optional bei relativen URLs integriert werden kann
    (erspart unnötige Dopplungen bei der Eingabe)
  - Bisher konnte für das Banner nur eine relative URL zu einer Bilddatei angegeben werden.  
    Nun können dieselben Möglichkeiten wie bei den Links von Listeneinträgen verwendet werden
    (wobei eine Bilddatei aus demselben Derivat mit dem `MCRFileNodeServlet` ausgeliefert wird).
    Zudem können sprachabhängig unterschiedliche Bilder und Links konfiguriert werden.
  - Bei Bannern kann zusätzlich "Kleingedrucktes" unterhalb des Banners ausgegeben werden
    ([Beispiel](https://macau.uni-kiel.de/receive/macau_mods_00006298)).
  - Zwischen Banner und der Verknüpfungsliste können nun prominente Buttons für zwei spezielle Funktionen angezeigt werden
    ([Beispiel](https://macau.uni-kiel.de/receive/macau_mods_00008326)):
    - Ein "Über diese Serie / Zeitschrift / ..."-Button (global konfiguriert in der Konfigurationsdatei)
    - Ein "Gedrucktes Exemplar kaufen"-Button (individuell konfiguriert für jedes Objekt, z.B. jeden Band einer Serie)

Die neue XML-Struktur ist im Ticket {{<mcr-ticket "MIR-1730" >}} beschrieben.

Es sind die foldenden Migrationsschritte vorzunehmen:

- Die JAR-Datei des Navigations-Plugins muss entfernt werden.
- In den Properties muss `MIR.GuidancePanel.Enabled=true` gesetzt werden.
- Im Property `MIR.Layout.End` muss ggf. `series-layout` durch `mir-guidance-panel` ersetzt werden.
- Aus dem Property `MCR.URIResolver.xslIncludes.MyCoReWebPage` müssen `series-panel-adapter.xsl` und  `series-panel-enricher.xsl` entfernt werden.
- Das Property `MIR.GuidancePanel.RSS.Enabled` muss in `MIR.Metadata.Navigation.SeriesPanel.RSS.Enabled` umbenannt werden.
- Das Property `MIR.Metadata.Navigation.SeriesPanel.RSS.Enabled` muss ggf. konfiguriert werden, da der Standardwert nun `true` ist.
- Das Solr-Feld `root` wurde in `mods.relatedItem.root` umbenannt. Links mit `q=root:...`  müssen ggf. zu `q=mods.relatedItem.root:....` angepasst werden. Die Solr-Konfiguration muss neu geladen und der Solr-Index muss neu gebaut werden, sofern dies nicht eh im Rahmen der Migration der verbesserten Personensuche bereits geschehen ist.

Zur Migration der Daten genügt das Kommando `migrate navigation`. Es führt die folgenden Kommandos aus,
die alternativ auch einzeln ausgeführt werden können:

1. `create guidance derivate type`  
   Legt den neuen Derivat-Typ `guidance` an.
1. `select navigation derivates`  
   Selektiert alle Derivate mit Derivat-Typ `navigation` (und ohne Hauptdatei `guidance.xml`).
1. `execute for selected verify navigation derivate {x}`  
   Fürt für alle selektierten Derivate eine Scheme-Validierung der alten XML-Struktur
   der alten Konfigurationsdatei `navigation.xml` aus und warnt, wenn eine Datei nicht valide ist
   (bricht die weitere Verarbeitung aber nicht ab). 
1. `execute for selected migrate navigation derivate {x}`  
   Ändert für alle selektierten Derivate den Derivat-Typ von `navigation` in `guidance`,
   benennt die Datei `navigation.xml` in `guidance.xml` um und trägt diese Datei als Hauptdatei des Derivats ein.
1. `select guidance derivates`
   Selektiert alle Derivate mit Derivat-Typ `guidance` (und mit Hauptdatei `guidance.xml`).
1. `execute for selected migrate guidance derivate {x} main document`  
    Transformiert den Inhalt der Hauptdatei `guidance.xml` in die neue XML-Struktur. 
1. `execute for selected verify guidance file guidance.xml in derivate {x}`  
   Fürt für alle selektierten Derivate eine Scheme-Validierung der neuen XML-Struktur
   der neuen Konfigurationsdatei `guidance.xml` aus und warnt, wenn eine Datei nicht valide ist
   (bricht die weitere Verarbeitung aber nicht ab).
1. `delete navigation derivate type`  
   Entfernt den alten Derivat-Typ `navigation` an.

> An sich genügt das Kommando `migrate navigation`. Die Transformation ignoriert unbekannte Inhalte
> (unbekannte Elemente oder Attribute) aus der alten XML-Struktur und übernimmt diese nicht in die
> neue XML-Struktur. Nur wer sicher sein will, dass hier keine Informationen versehentlich verloren gehen,
> sollte vorher `select navigation derivates` und `execute for selected verify navigation derivate {x}`
> manuell ausführen und die ausgegebenen Warnungen studieren.
{.note}

Die generierte HTML-Struktur ist sehr vergleichbar mit der HTML-Struktur, die zuvor von dem Navigation-Plugin
erzeugt wurde, ist aber nicht identisch. Insbesondere wurden einige `class`-Attribute umbenannt
(Banner: `banner-link` ⮕ `mir-guidance-banner`; Verknüpfungsliste: `series-card` ⮕ `mir-guidance-items`).
Wer das Styling der HTML-Ausgabe des Navigations-Plugins angepasst hat, muss diese Anpassungen überarbeiten.
