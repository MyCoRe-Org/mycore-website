---
title: Wie XEditor Formulare verarbeitet
description: Abbildung zwischen HTML-Eingaben und XML-Dokumenten verstehen.
author: ['Frank Lützenkirchen', 'Kathleen Neumann']
doc_type: explanation
product: mycore
weight: 30
---

XEditor verbindet HTML-Formulare mit XML-Dokumenten. Eine Formulardefinition enthält gewöhnliches HTML und Elemente aus dem Namespace `http://www.mycore.de/xeditor`.

## Bindung an XML

`xed:source` lädt das zu bearbeitende XML. `xed:bind` wählt mit XPath den Knoten, auf den untergeordnete Eingabefelder abgebildet werden.

## Verarbeitung

Beim Absenden überträgt XEditor Formularwerte in die gebundenen XML-Knoten. Validierung, Bereinigung und Nachbearbeitung laufen vor dem endgültigen Ziel des Formulars.

## Dynamische Formulare

Wiederholungen, Bedingungen und mehrsprachige Bereiche verändern die dargestellten Eingaben, ohne das zugrunde liegende Bindungsmodell aufzugeben.

Die Elemente und Attribute sind in der [XEditor-Referenz]({{< ref "/documentation/reference/mycore/frontend/xeditor" >}}) beschrieben.
