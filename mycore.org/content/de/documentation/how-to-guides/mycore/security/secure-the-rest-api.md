---
title: Zugriff auf die REST-API absichern
description: Lesende und schreibende REST-Aufrufe mit ACLs schützen.
author: ['Robert Stephan', 'Lennard Golsch']
doc_type: how-to
product: mycore
weight: 70
---

MyCoRe schützt REST-Pfade mit ACLs. Definieren Sie zuerst eine Regel für `restapi:/` mit dem Recht `read`.

## Zugriff eingrenzen

Beschränken Sie einzelne Pfade mit genaueren Regeln, etwa für `/objects`, `/search` oder `/classifications`.

Eine Regel kann Zugriff allgemein erlauben, auf Benutzer oder Rollen begrenzen oder von IP-Adressen abhängig machen.

## Schreibzugriffe prüfen

REST v2 unterstützt schreibende Operationen. Prüfen Sie für jeden aktivierten Endpunkt die benötigten Rechte und testen Sie erlaubte sowie abgelehnte Aufrufe.

Endpunkte und Formate stehen in der [REST-v1-Referenz]({{< ref "/documentation/reference/mycore/interfaces/rest-api-v1" >}}) und der [REST-v2-Referenz]({{< ref "/documentation/reference/mycore/interfaces/rest-api-v2" >}}).
