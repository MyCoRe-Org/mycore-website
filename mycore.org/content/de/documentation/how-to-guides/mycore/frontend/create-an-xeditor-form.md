---
title: Ein erstes XEditor-Formular erstellen
description: Ein HTML-Formular an ein XML-Dokument binden.
author: ['Frank Lützenkirchen', 'Kathleen Neumann']
doc_type: how-to
product: mycore
weight: 10
---

Erstellen Sie eine MyCoRe-Webseite mit der Endung `.xed`. Definieren Sie dort genau ein `xed:form` und deklarieren Sie den XEditor-Namespace.

## XML-Quelle festlegen

Laden Sie mit `xed:source` das Dokument, das das Formular bearbeiten oder erzeugen soll.

## Eingabefeld binden

Wählen Sie mit `xed:bind` einen XML-Knoten per XPath. Platzieren Sie das zugehörige HTML-Eingabefeld innerhalb dieser Bindung.

## Formular absenden

Fügen Sie ein Submit-Ziel und einen Submit-Button hinzu. Ergänzen Sie bei Bedarf einen Abbruchpfad und Validierungsregeln.

## Ergebnis prüfen

Senden Sie das Formular im Debug-Modus ab und prüfen Sie das erzeugte XML. Verwenden Sie danach die [XEditor-Referenz]({{< ref "/documentation/reference/mycore/frontend/xeditor" >}}) für weitere Elemente.
