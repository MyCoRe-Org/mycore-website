---
title: "Was wäre ein Leben ohne Derivate?"  
slug: leben-ohne-derivate
date: 2018-02-23

draft: false

blog/authors: ["Thomas Scheffler"]
blog/periods: 2018-02
blog/categories: 
- HowTo
blog/tags:
- Derivate
- Entwicklung

---

## Was ist ein Derivat?

1. Derivate sind Dateibereiche, also Wurzelverzeichnisse, die über eine bestimmte ID zu erreichen sind.
2. Derivate sind Metadaten. Sie beschreiben die Dateien und verlinken die Dateien mit einem (Metadaten-)Objekt, die wiederum die Dateien beschreiben.

## Wo ist das Problem?

Der homonyme Gebrauch führt zu einem nicht gleich offensichtlichen Problem:

Was bedeutet das ACL-Mapping für „write“ auf ein „Derivat“? Nun ausdrücken möchten wir damit, dass das Ändern der Dateien verboten oder erlaubt ist. Wir implizieren also ein Derivat nach der 1. Definition. Auswirken tut sich das jedoch auch auf die Metadaten, die wir im 2. Punkt besprochen haben. Das führte unlängst zu der [Problematik](https://mycore.atlassian.net/browse/MCR-1813), dass eine Hauptdatei (oder auch Startdatei) nicht gesetzt (oder geändert) werden konnte, nachdem ein Persistenter Identifier (u.a.: URN, DOI) vergeben worden ist.

Die zusätzliche Indirektion zwischen Metadatenobject (beschreibt die Dateien), verlinktem Derivat (beschreibt die Dateien) und den zusammengefassten Dateien führt außerdem dazu, dass bei jeder Präsentation zusätzlich zum anzuzeigenden Metadaten-Objekt alle Derivat-Metadaten nachgeladen werden müssen, um an notwendige Informationen zu kommen. Das geschieht schon so seit 16 Jahren und wurde noch nie in Frage gestellt. Bis gestern.

## Metadata first, Bedenken second

Gestern traf ich mich mit Kathleen, René und Frank in Göttigen, um eigentlich über die zukünftige MIR-Strategie zu sprechen. Kathleen berichtet über das obige Problem. Frank hatte eine lange Liste von kleinen Kanten und größeren Wünschen. Als wir über Derivate und bestimmte Derivat-Typen sprachen (Thumbnails, Layout, Volltext, etc.) stellte er die ketzerische Frage, wer überhaupt die Derivat-Metadaten braucht und warum diese nicht in der Metadaten des Objekts mit aufgeführt werden.

Und wenn man einmal darüber nachdenkt und das berühmte „Haben wir schon immer so gemacht“ außen vor lässt, würden sich mit der Integration der bisherigen Derivat-Metadaten in die jeweiligen MyCoRe-Objekte eine Reihe von Problemen lösen. Dazu gehört auch, dass die Metadaten der Derivat dann zusammen mit den Metadaten der Objekte versioniert werden.

## Code here:

{{< highlight xml "linenos=table" >}}
<mycoreobject ID="mycore_doc_00000001">
  <structure>
    <derobjects>
      <derobject inherited="0" xlink:type="locator" xlink:label="fulltext" xink:href="mir_derivate_00000001">
        <internals class="MCRMetaIFS" heritable="false">
          <internal inherited="0" maindoc="index.html" />
        </internals>
      </derobject>
    </derobjects>
  </structure>
  [...]
{{< / highlight >}}

Der Code zeigt die Auswirkungen, die das Einbetten der Metadaten hätte. Es werden alle Metadaten des Derivates (bis auf die Links zum Objekt und den Service-Teil) in den Structure-Teil des Metadatenobjects übernommen.

## Abschließendes Urteil

Nun, ein abschließendes Urteil steht noch aus. Aber es ist ein interessanter Denkanstoß, den ich gestern aus Göttingen mitgenommen habe: *Brauchen wir Metadaten über Metadaten über Dateien eigentlich?*