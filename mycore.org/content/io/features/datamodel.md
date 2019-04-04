---

description: beschreibung der wichtigsten MyCoRe Funktionen.
title: Das MyCoRe Datenmodell

---

## Objekte, Datentypen und Beziehungen
Statt ein fixes Datenmodell wie Dublin Core vorzugeben, lässt sich das Metadatenmodell einer
        MyCoRe Anwendung frei konfigurieren:

* **Datentypen** definieren Art und mögliche Werte der Felder eines Objektes. Vordefinierte Datentypen sind z. B. Text, Zahl, Boolean (Ja/Nein), Datum, Name, Verweis (Link), Kategorie, XML.
* **Objekttypen** definieren, welche Felder zur Beschreibung gleichartiger Objekte verwendet werden, welchen Datentyps diese sind, und ob sie verpflichtend oder wiederholbar sind.
* Objekte können untereinander in einer **_Beziehung_** stehen. Dies kann ein Verweis sein (z. B. "Publikation" verweist auf "Person"), oder eine Vater-Kind-Beziehung ("ist-Teil-von", "besteht aus") mit Existenzabhängigkeit (z. B. Objekt "Zeitschrift" enthält "Artikel").
* **Beispiel**
  * Objekttyp "Publikation" mit den Feldern "Titel" (Text, mehrsprachig, verpflichtend, wiederholbar), "Autor" (Verweis auf "Person", optional, wiederholbar)...
  * Objekttyp "Person" mit den Feldern "Name", "Geburtsdatum" (Datum, optional, nicht wiederholbar), ...

Für Vater-Kind-Beziehungen zwischen Objekten bietet MyCoRe einen **Vererbungsmechanismus** für Metadaten. Kindobjekte können dabei über mehrere Hierarchiestufen hinweg Werte bestimmter Felder von den übergeordneten Objkten erben. Ein Zeitschriftenartikel könnte z. B. das Veröffentlichungsdatum des Heftes erben, in dem der Artikel erschienen ist. Vererbung bezieht sich hier also auf die Werte der Metadaten, nicht auf die Datenmodelldefinition.

## Metadaten mit beliebigem XML Schema
Neben den vordefinierten Datentypen können **eigene Datentypen** als Java-Klassen implementiert werden.
Alternativ kann auch der XML-Datentyp für eigene Erweiterungen verwendet werden.
Felder dieses Typs können eine beliebige XML-Struktur enthalten,
die ggf. durch ein **XML Schema** spezifiziert wird.
So können beliebige XML-basierte Datenmodelle wie z. B. MODS direkt in MyCoRe
zur Beschreibung von Objekten verwendet werden.
        
[MODS](http://www.loc.gov/standards/mods/ "zur MODS-Homepage") (Metadata Object Description Schema)
ist ein XML-basiertes Metadatenschema der Library of Congress, für das MyCoRe bereits eine
spezielle Unterstützung mit vordefinierter Funktionalität bietet.
Dazu gehören etwa der direkte Import von MODS-Metadaten als MyCoRe-Objekte und die Abbildung auf MyCoRe-Klassifikationen.
        
MODS ist das von MyCoRe empfohlene Metadatenformat für Publikationsserver,
dem wir besondere Aufmerksamkeit und Funktionalität widmen. So ist die MyCoRe-Beispielanwendung "MIR" eine auf MODS basierende Anwendung.

## Internes Speicherformat der Metadaten

Die Metadaten aller MyCoRe-Objekte werden intern als XML-Dokumente gespeichert.
Dies unterstützt Strategien der Langzeitarchivierung und stellt sicher,
dass Metadaten auch unabhängig von MyCoRe zu einem späteren Zeitpunkt
weiter verarbeitet werden können.

Intern ist jedes MyCoRe-Objekt dabei in drei Bereiche unterteilt:

<dl>
        <dt>
          <code>metadata</code>
        </dt>
        <dd>
          im metadata-Teil werden die Werte der Datenfelder gespeichert, die das Objekt beschreiben,
          die eigentlichen Metadaten.
        </dd>
        <dt>
          <code>structure</code>
        </dt>
        <dd>
          im structure-Teil werden die Vater-Kind-Beziehungen zwischen Objekten gespeichert,
          die Verweise auf übergeordnete Objekte.
        </dd>
        <dt>
          <code>service</code>
        </dt>
        <dd>
          im service-Teil werden administrative und teils automatisch generierte Metadaten gespeichert,
          z. B. das Änderungsdatum und (beim Import) Verweise auf Access Control Listen zur Zugriffssteuerung.
        </dd>
      </dl>

## Hierarchisches Klassifikationssystem

Klassifikationssysteme finden in vielen internationalen Metadaten-Standards Verwendung, um Datenbestände
sachlich zu erschließen und Inhalte zu strukturieren. Beispiele für solche Klassifikationen sind
die **Dewey-Dezimalklassifikation (DDC)**, oder das **"Gemeinsame Vokabular"**
von DINI und Deutscher Nationalbibliothek zur Einordnung von Publikationstypen.
Auch fach- oder anwendungsspezifische Klassifikationsysteme werden
verwendet, z. B. die Organisationsstruktur der eigenen Einrichtung.

MyCoRe kann beliebige solcher Klassifikationssysteme unterstützen. Eine Klassifikation besteht in MyCoRe aus
einer Liste oder Hierarchie von Kategorien. Jede Kategorie besitzt eine eindeutige ID, eine mehrsprachige Bezeichnung,
sowie optional ein Kommentarfeld und einen weiterführenden Link.

 Klassifikationen können über eine XML-Struktur über Kommandozeilen-Befehle **importiert und exportiert** werden.
Darüber hinaus gibt es auch einen **Online-Klassifikationseditor**, um Klassifikationen anzulegen und Kategorien zu bearbeiten.
Mehrere in Publikationsservern häufig verwendete Klassifikationen stehen vordefiniert zur Verfügung, z. B.
die ersten Ebenen der DDC, das Gemeinsame Vokabular, eine Liste der Sprachen nach RFC4646 und weitere.

MyCoRe-Objekte können beliebigen Klassifikationskategorien zugewiesen werden.
Bei der **Recherche** kann über Kategorien gesucht werden, wobei auch die Hierarchie von Kategorien berücksichtigt wird.
Über einen **Klassifikationsbrowser** kann der Bestand nach Kategorien strukturiert präsentiert werden.

## Persistente Identifikatoren (Persistent Identifier)

Persistent-Identifier-Systeme wie **URN, DOI und Handle** dienen in Online-Repositorien
der dauerhaften Referenzierung von Ressourcen. Elektronische Publikationen und Digitalisate
erhalten so eine dauerhafte, standardisierte und weltweit eindeutige Adresse, unter der sie erreichbar sind
und mit der sie zitiert werden können. Alle Formen von „Persistent Identifiern“ können in den MyCoRe-Metadaten
gespeichert werden.

MyCoRe unterstützt direkt die Generierung, Vergabe und Verwaltung von
[URNs](http://www.persistent-identifier.de/),
Persistent Identifiern im Namensraum urn:nbn:de,
wie sie die Deutsche Nationalbibliothek für E-Publikationen einsetzt. Für die Generierung
von URNs stehen verschieden Algorithmen zur Verfügung, etwa auf Basis von Zeitstempeln oder fortlaufenden
Zählern, die auch miteinander kombiniert werden können. MyCoRe speichert die URN, berechnet und testet
ggf. die zugehörige Prüfsumme und implementiert einen lokalen URN-Resolver.
Zugewiesene URNs können über die **OAI-Schnittstelle** im Datenformat **Epicur** an die
Deutsche Nationalbibliothek gemeldet werden.

Eine vergleichbare, direktere Unterstützung für das Handle-System ist in Entwicklung.