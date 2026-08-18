---

title: "Erkennung und Behandlung von Dubletten"
mcr_version: ['2026.12']
date: '2026-08-18'

---

Die Komponente `mycore-dedup` erkennt mögliche Dubletten anhand konfigurierbarer Kriterien. Sie ist nicht auf
MODS-Dokumente beschränkt: Eine Anwendung kann für jeden MyCoRe-Objekttyp eigene Kriterien und einen eigenen
Anzeigetitel bereitstellen. `mycore-mods` bringt lediglich eine fertige Konfiguration für MODS mit.

Die Erkennung liefert bewusst nur **mögliche** Dubletten. Zwei Objekte gelten als mögliche Dubletten, sobald sie
mindestens ein Kriterium mit gleichem Typ und gleichem, normalisiertem Wert besitzen. Ein fachlicher Prozess oder ein
Benutzer muss anschließend entscheiden, ob es sich tatsächlich um Dubletten handelt.

## Funktionsweise

Die Komponente speichert drei Arten von Daten in der MyCoRe-Datenbank:

- Deduplication Keys aus Kriterientyp, normalisiertem Wert und Objekt-ID,
- einen optionalen Anzeigetitel je Objekt und
- Paare, die ein Benutzer ausdrücklich als **keine Dubletten** markiert hat.

Beim Anlegen, Ändern und Reparieren eines `MCRObject` führt der `MCRDeDupEventHandler` alle für dessen Objekttyp
konfigurierten `MCRDeDupCriterionBuilder` aus. Er ersetzt die bisher gespeicherten Keys und aktualisiert den
Anzeigetitel. Beim Löschen eines Objekts entfernt er dessen Keys, Titel und alle zugehörigen
Keine-Dublette-Markierungen. Objekttypen ohne konfigurierte Builder erzeugen keine Keys.

Eine Suche vergleicht also nicht bei jeder Anfrage erneut die vollständigen Metadaten, sondern nur die vorberechneten
Keys. Das macht die Abfrage schnell und erlaubt es, unterschiedliche Metadatenmodelle über dieselbe API anzusprechen.
Eine mögliche Dublette wird durch jeden gemeinsamen Key einzeln ausgegeben. Teilen zwei Objekte beispielsweise sowohl
einen Identifier als auch ein Titel-Autor-Kriterium, enthält die REST-Antwort zwei Einträge für dieses Paar.

> Nach dem erstmaligen Aktivieren der Komponente besitzen bereits vorhandene Objekte noch keine Keys. Sie müssen
> einmal repariert oder erneut gespeichert werden, damit der Event Handler die Keys und Titel aufbaut.

## Abhängigkeit und Grundkonfiguration

Eine Anwendung nimmt zunächst die Komponente auf. Die Versionsverwaltung erfolgt üblicherweise über die MyCoRe-BOM.

```xml
<dependency>
  <groupId>org.mycore</groupId>
  <artifactId>mycore-dedup</artifactId>
</dependency>
```

Damit werden unter anderem das JPA-Mapping, die Event Handler, der URI-Resolver und die REST-Anwendung konfiguriert.
Die dafür mitgelieferten Standard-Properties lauten:

```properties
MCR.DeDup.CriteriaProvider.Class=org.mycore.dedup.MCRDeDupCriteriaProvider
MCR.DeDup.KeyManager.Class=org.mycore.dedup.MCRDeDupKeyManager
MCR.DeDup.TitleProvider.Class=org.mycore.dedup.MCRDeDupTitleProvider

MCR.JPA.MappingFileNames=%MCR.JPA.MappingFileNames%,META-INF/mycore-dedup-mappings.xml
MCR.EventHandler.MCRObject.015D.Class=org.mycore.dedup.MCRDeDupNoDuplicateFlagEventHandler
MCR.EventHandler.MCRObject.085.Class=org.mycore.dedup.MCRDeDupEventHandler

MCR.DeDup.NoDuplicateFlagType=dedupNoDuplicate
MCR.URIResolver.ModuleResolver.dedup.Class=org.mycore.dedup.MCRDeDupURIResolver
MCR.URIResolver.ModuleResolver.dedup.SessionKeyPrefixes=editor_
MCR.DeDup.API.Resource.Packages=org.mycore.dedup.resources
```

Die Reihenfolge der Event Handler ist relevant: `015D` wertet temporäre Keine-Dublette-Flags aus, bevor der reguläre
Handler `020` das Objekt schreibt. `085` baut anschließend die Such-Keys auf.

Für eine optionale Administrationsoberfläche kann zusätzlich `org.mycore:mycore-dedup-gui` eingebunden werden. Sie ist
unter `{Webanwendung}/dedup/` erreichbar und zeigt mögliche Dubletten sowie Keine-Dublette-Markierungen an.

## Eigene Objekttypen unterstützen

Für einen eigenen Objekttyp sind mindestens ein `MCRDeDupCriterionBuilder` und dessen Konfiguration notwendig. Ein
`MCRDeDupTitleResolver` ist optional, aber für verständliche REST- und GUI-Ausgaben empfehlenswert.

Angenommen, die Anwendung verwendet den Objekttyp `book` und speichert ISBNs in Elementen namens `isbn`. Ein einfacher
Builder kann so aussehen:

```java
package org.example.book.dedup;

import java.util.LinkedHashSet;
import java.util.Set;

import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathFactory;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.dedup.MCRDeDupCriterion;
import org.mycore.dedup.MCRDeDupCriterionBuilder;

public class BookISBNCriterionBuilder implements MCRDeDupCriterionBuilder {

    @Override
    public Set<MCRDeDupCriterion> build(MCRObject object) {
        if (!"book".equals(object.getId().getTypeId())) {
            return Set.of();
        }

        Set<MCRDeDupCriterion> result = new LinkedHashSet<>();
        Element metadata = object.getMetadata().createXML();
        var isbnElements = XPathFactory.instance()
            .compile(".//isbn", Filters.element())
            .evaluate(metadata);
        for (Element isbnElement : isbnElements) {
            String isbn = isbnElement.getTextTrim().replaceAll("[-\\s]", "");
            if (!isbn.isEmpty()) {
                result.add(MCRDeDupCriterion.of("identifier", "isbn:" + isbn));
            }
        }
        return result;
    }
}
```

Der Builder wird unter der tatsächlichen Typ-ID aus der `MCRObjectID` registriert:

```properties
MCR.DeDup.CriterionBuilder.book.isbn.Class=org.example.book.dedup.BookISBNCriterionBuilder
```

Das Segment `isbn` ist nur ein frei wählbarer, innerhalb des Objekttyps eindeutiger Name. Mehrere Builder lassen sich
parallel konfigurieren:

```properties
MCR.DeDup.CriterionBuilder.book.isbn.Class=org.example.book.dedup.BookISBNCriterionBuilder
MCR.DeDup.CriterionBuilder.book.titleAuthor.Class=org.example.book.dedup.BookTitleAuthorCriterionBuilder
MCR.DeDup.CriterionBuilder.book.shelfmark.Class=org.example.book.dedup.BookShelfmarkCriterionBuilder
```

Alle zurückgegebenen Mengen werden vereinigt. Ein einzelner gemeinsamer Wert genügt für einen Treffer; die verschiedenen
Builder bilden also standardmäßig eine ODER-Verknüpfung. Anwendungen, die nur eine bestimmte Kombination vergleichen
wollen, können diese Felder in **einem** normalisierten Kriterium zusammenfassen, beispielsweise
`MCRDeDupCriterion.of("title-author", normalizedTitle + ':' + normalizedAuthor)`.

Bei eigenen Kriterien sollte Folgendes beachtet werden:

- Semantisch gleiche Werte müssen identisch normalisiert werden, etwa durch Kleinschreibung, vereinheitlichte
  Leerzeichen oder das Entfernen von Trennzeichen.
- Der Kriterientyp gehört zum Vergleich. Derselbe Wert in den Typen `identifier` und `shelfmark` erzeugt keinen Treffer.
- Builder müssen bei nicht unterstützten oder unvollständigen Objekten eine leere Menge liefern statt eine Exception
  auszulösen.
- Kriteriumswerte werden beim Speichern auf 255 Zeichen gekürzt. Sehr lange zusammengesetzte Werte sollten deshalb
  besser stabil gehasht werden, um unbeabsichtigte Gleichheiten nach der Kürzung zu vermeiden.

### Anzeigetitel für einen eigenen Typ

Der Titel wird zusammen mit den Keys gespeichert und muss daher nicht für jede Zeile einer Trefferliste erneut aus den
Metadaten geladen werden. Eine Implementierung gibt `Optional.empty()` zurück, wenn sie keinen Titel ermitteln kann:

```java
package org.example.book.dedup;

import java.util.Optional;

import org.jdom2.Element;
import org.jdom2.filter.Filters;
import org.jdom2.xpath.XPathFactory;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.dedup.MCRDeDupTitleResolver;

public class BookTitleResolver implements MCRDeDupTitleResolver {

    @Override
    public Optional<String> resolveTitle(MCRObject object) {
        if (!"book".equals(object.getId().getTypeId())) {
            return Optional.empty();
        }
        Element metadata = object.getMetadata().createXML();
        Element title = XPathFactory.instance()
            .compile(".//title", Filters.element())
            .evaluateFirst(metadata);
        return title == null || title.getTextTrim().isEmpty()
            ? Optional.empty()
            : Optional.of(title.getTextTrim());
    }
}
```

```properties
MCR.DeDup.TitleResolver.book.Class=org.example.book.dedup.BookTitleResolver
```

Alternativ kann `org.mycore.dedup.MCRDeDupLabelTitleResolver` verwendet werden, wenn das Label des `MCRObject` als
Anzeige ausreicht. Titel werden auf 1024 Zeichen gekürzt. Änderungen am Resolver werden für vorhandene Objekte erst
nach einer Reparatur oder dem nächsten Speichern sichtbar.

### MODS als Referenzkonfiguration

`mycore-mods` registriert drei Builder für Identifier, die Kombination aus Titel und Autor sowie Signaturen:

```properties
MCR.DeDup.CriterionBuilder.mods.identifier.Class=org.mycore.mods.dedup.MCRMODSIdentifierDeDupCriterionBuilder
MCR.DeDup.CriterionBuilder.mods.titleAuthor.Class=org.mycore.mods.dedup.MCRMODSTitleAuthorDeDupCriterionBuilder
MCR.DeDup.CriterionBuilder.mods.shelfmark.Class=org.mycore.mods.dedup.MCRMODSShelfmarkDeDupCriterionBuilder
MCR.DeDup.TitleResolver.mods.Class=org.mycore.mods.dedup.MCRMODSDeDupTitleResolver
```

Einzelne Strategien können in der Anwendung durch Überschreiben oder Entfernen des jeweiligen Properties angepasst
werden.

## URI-Resolver

Der URI-Resolver stellt Treffer als XML für XSLT-Stylesheets bereit. Er unterstützt zwei Aktionen.

### Gespeichertes Objekt abfragen

`dedup:duplicates:{objectId}` sucht anhand der bereits gespeicherten Keys eines Objekts:

```xsl
<xsl:variable name="duplicates" select="document('dedup:duplicates:app_book_00000001')/duplicates"/>
```

Das Ergebnis gruppiert alle gemeinsamen Kriterien nach dem jeweils anderen Objekt:

```xml
<duplicates for="app_book_00000001">
  <duplicate id="app_book_00000002">
    <criterion type="identifier" value="isbn:9781566199094"/>
    <criterion type="title-author" value="beispieltitel:mustermann"/>
  </duplicate>
</duplicates>
```

Bereits als keine Dubletten markierte Paare werden nicht ausgegeben. Eine ungültige Objekt-ID oder eine unbekannte
Aktion führt zu einem `TransformerException`.

### Noch nicht gespeichertes Editorobjekt abfragen

`dedup:duplicates-for-session:{sessionKey}` ist für ein Objekt gedacht, das während der Bearbeitung noch nicht
gespeichert wurde. Der Resolver liest das JDOM-Metadatenelement aus der aktuellen MyCoRe-Session, erzeugt daraus ein
`MCRObject`, berechnet dessen Kriterien direkt und vergleicht diese mit den gespeicherten Keys:

```xsl
<xsl:variable name="duplicates"
              select="document('dedup:duplicates-for-session:editor_book')/duplicates"/>
```

Aus Sicherheitsgründen darf der Session-Key nur mit einem konfigurierten Präfix beginnen. Mehrere Präfixe werden durch
Kommas getrennt:

```properties
MCR.URIResolver.ModuleResolver.dedup.SessionKeyPrefixes=editor_,myBookEditor_
```

Der zugehörige Session-Wert muss ein `org.jdom2.Element` mit dem XML des `MCRObject` sein. Das Ergebnis hat dasselbe
Format wie oben; das `for`-Attribut enthält hierbei den Session-Key. Da das neue Objekt noch keine endgültige ID hat,
kann diese Abfrage keine bereits gespeicherte Keine-Dublette-Markierung für das neue Objekt berücksichtigen.

## REST-API

Die JSON-API liegt unter `{Webanwendung}/api/dedup`. Alle Endpunkte setzen das MyCoRe-Recht
`manage-deduplication` voraus; ohne dieses Recht antwortet die API mit HTTP 403. Leseantworten werden nicht gecacht.

| Methode | Pfad | Bedeutung |
| --- | --- | --- |
| `GET` | `/api/dedup/duplicates` | Alle möglichen Dublettenpaare auflisten |
| `GET` | `/api/dedup/duplicates/{id}` | Mögliche Dubletten eines Objekts auflisten |
| `GET` | `/api/dedup/no-duplicates` | Alle Keine-Dublette-Markierungen auflisten |
| `POST` | `/api/dedup/no-duplicates?id1={id1}&id2={id2}` | Ein Paar als keine Dubletten markieren |
| `DELETE` | `/api/dedup/no-duplicates/{markingId}` | Eine Markierung anhand ihrer Datenbank-ID entfernen |

Eine Trefferantwort enthält einen Eintrag je gemeinsamem Kriterium. Die Objekt-IDs eines Paars werden unabhängig von
der Abfragerichtung lexikographisch sortiert:

```json
[
  {
    "objectId1": "app_book_00000001",
    "title1": "Ein Beispieltitel",
    "objectId2": "app_book_00000002",
    "title2": "Ein Beispieltitel, zweite Ausgabe",
    "criterionType": "identifier",
    "criterionValue": "isbn:9781566199094"
  }
]
```

Fehlt ein gespeicherter Anzeigetitel, ist das entsprechende Feld `null`. Das Markieren eines Paars liefert HTTP 201;
wiederholtes Markieren desselben ungeordneten Paars ist wirkungsgleich. Identische oder ungültige Objekt-IDs führen zu
HTTP 400. Das Löschen liefert HTTP 204 und ist auch dann erfolgreich, wenn die angegebene Markierung nicht existiert.

Eine Keine-Dublette-Markierung unterdrückt das Paar vollständig, auch wenn es mehrere Kriterien gemeinsam hat. Die
Antwort von `GET /api/dedup/no-duplicates` enthält zusätzlich die ID der Markierung, den erzeugenden Benutzer und den
ISO-8601-Zeitpunkt:

```json
[
  {
    "id": 17,
    "objectId1": "app_book_00000001",
    "title1": "Ein Beispieltitel",
    "objectId2": "app_book_00000002",
    "title2": "Ein anderer Titel",
    "creator": "administrator",
    "created": "2026-08-18T09:30:00Z"
  }
]
```

## Keine-Dublette-Entscheidung beim Anlegen eines Objekts

Bei einem neuen Objekt steht die endgültige Objekt-ID während der Editorprüfung unter Umständen noch nicht fest. Die
Entscheidung kann deshalb vor dem Speichern als Service-Flag am neuen Objekt mitgegeben werden:

```java
object.getService().addFlag("dedupNoDuplicate", "app_book_00000002");
```

Der Flag-Typ ist mit `MCR.DeDup.NoDuplicateFlagType` konfigurierbar. Für jedes bestätigte Vergleichsobjekt wird ein
eigenes Flag gesetzt. Der frühe Event Handler wandelt gültige Flags beim Anlegen oder Ändern in dauerhafte
Keine-Dublette-Markierungen um und entfernt die Flags vor dem Speichern aus den Metadaten. Ungültige IDs,
Selbstreferenzen und doppelte Werte werden ignoriert.
