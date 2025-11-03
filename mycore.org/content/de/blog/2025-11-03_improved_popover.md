---
title:  "Popover mit erweiterter Funktionalität (Bootstrap 5)"
slug:   bootstrap5-improved-popover
date:   2025-11-03
publishDate: 2025-11-03

draft:  false

blog/authors:  ["Robert Stephan"]
blog/periods:  2025-11
blog/categories:
 - HowTos
blog/tags:
 - Bootstrap5
 - Javascript

---
In diesem Tutorial erstellen wir ein Bootstrap5-Popover, welches durch zwei verschiedene Javascript-Events ausgelöst wird.
Beim Auslösen über das *Hover-Event (Mouse-Over)* soll das Popover nach 3 Sekunden automatisch geschlossen werden. 
Beim *Click-Event* soll das Popover so lange geöffnet bleiben, bis es manuell geschlossen wird.
<!--more-->

Titelzeile und Inhalt des Popovers sollen aus [*HTML-Template-Elementen*](https://developer.mozilla.org/de/docs/Web/HTML/Reference/Elements/template) 
übernommen werden. Dadurch lassen sich serverseitig dynamische Inhalte und komplexere Darstellungen generieren, 
als es beispielsweise mit dem Standard-Mechanismus *data-Attribut* oder per JSON-Konfiguration möglich wäre.
In der Titelzeile soll außerdem automatisch ein *Schließen-Button* erzeugt werden.

Als Ausgangsbasis dient die [Bootstrap 5 Dokumentation für Popovers](https://getbootstrap.com/docs/5.3/components/popovers/#options).

**Beispiel-Screenshot:**

<img src="{{<relURL "/images/blog/howtos/improvedPopover.png">}}" alt="Screenshot des geöffneten Popovers" style="width:350px;display:block"/>  

Der zugehörige Quelltext befindet sich in den beiden Dateien 
[improvedPopover.html](/images/blog/howtos/improvedPopover.html) 
 und [improvedPopover.js](/images/blog/howtos/improvedPopover.js).


### Initialisierung des Popovers im HTML

Das Popover wird mit einem Info-Button verknüpft. Dafür muss dieser Button, wie durch Bootstrap 5 vorgegeben, 
das Data-Attribut `data-bs-toggle=popover` besitzen. 
Der Info-Button enthält zusätzlich in den Data-Attributen `data-ir-popover-title-template` und `data-ir-popover-body-template` 
die IDs der HTML-Templates, die für die Generierung des Popovers verwendet werden.

``` html
<button id="btn_ir_popover_1234" type="button" class="btn"
        data-bs-toggle="popover" data-bs-placement="bottom"
        data-ir-popover-title-template="#tmpl_ir_popover_title_1234"
        data-ir-popover-body-template="#tmpl_ir_popover_body_1234">
        
  <i class="fa-solid fa-circle-info"></i>
</button>

<template id="tmpl_ir_popover_title_1234">
...        
</template>
<template id="tmpl_ir_popover_body_1234">
...        
</template>
```

### JavaScript-Implementierung und Konfiguration

Zuerst selektieren wir alle Elemente, die eine ID haben, die mit `btn_ir_popover_` anfängt. 
Diese Elemente sollen nach unserer Konvention ein Popover erhalten.
Anschließend initialisieren wir die Popover für diese Elemente mit dem Trigger-Event *Hover* und setzt das Delay 
für das automatische Schließen (z.B. auf 3 Sekunden). 

Der Inhalt des generierten Popovers wird um einen Schließen-Button ergänzt. Damit dies möglich ist, 
müssen wir den [*Sanitizer*](https://getbootstrap.com/docs/5.3/getting-started/javascript/#sanitizer)
deaktivieren: `sanitize: false`. Dieser prüft normalerweise, dass nur sicherer HTML-Code für das Erstellen
des Popovers verwendet wird. Durch das Ausschalten muss HTML-Code der aus nicht vertrauenswürdigen Quellen
(z.B. Benutzereingaben, URL-Parametern) übernommen wird, gesondert auf unsicheren Code (Javascript, ...) 
geprüft und eventuell bereinigt werden.

Der generierte Schließen-Button erhält ein Data-Attribut `data-ir-popover-trigger`, welches auf das Trigger-Element verweist.
Die Titelzeile und der Inhalt des Popovers werden durch Javascript-Funktionen aus den HTML-Template-Elementen 
ausgelesen, deren IDs in den Data-Attributen `data-ir-popover-title-template` `data-ir-popover-body-template`,
angegeben wurden. 

Damit die CSS-Formatierung des Popovers nicht durch das HTML-Element beinflusst wird, in das es eingebettet wurde, 
wird ein [*Custom container*](https://getbootstrap.com/docs/5.3/components/popovers/#custom-container) 
konfiguriert. Mit `container: 'body'` wird hier das Popover explizit im `<body>`-Tag platziert.

``` javascript
document.querySelectorAll('[id^="btn_ir_popover_"]').forEach(function(popoverTriggerEl) {
  let popover = new bootstrap.Popover(popoverTriggerEl, {
    trigger: 'hover',
    delay: {
      "show": 0,
      "hide": 3000
    },
    html: true,
    title: function() {
      ...
    }
    content: function() {
      ...
    },
    container: 'body',
    sanitize: false
  });
```

### Click-Event

Beim Öffnen des Popovers über das Click-Event soll das Popover geöffnet bleiben 
und nicht wie beim Hover-Event automatisch geschlossen werden.
Dazu wird der Zustand des Popovers in einem Data-Attribut verwaltet. Bei jedem Auslösen des Click-Events 
wird geprüft, ob das Data-Attribut `data-ir-popover-clicked` am auslösenden HTML-Element vorhanden ist. 
Wenn ja, gehen wir davon aus, dass das Popover bereits angezeigt wird. Dann wird dieses Data-Attribut 
gelöscht und die CSS-Klasse `active` entfernt.
Andernfalls wird am Trigger-Element das Data-Attribut `data-ir-popover-clicked` auf `true` gesetzt,
die CSS-Klasse `active` hinzugefügt und das Popover durch die Methode `getOrCreateInstance()` initialisiert.

``` javascript
popoverTriggerEl.addEventListener('click', (event) => {
  const popover = bootstrap.Popover.getOrCreateInstance(event.target)
  if (popoverTriggerEl.dataset.irPopoverClicked == "true") {
    delete popoverTriggerEl.dataset.irPopoverClicked;
    popoverTriggerEl.classList.remove("active");
    popover.hide();
  } else {
    popoverTriggerEl.dataset.irPopoverClicked = "true";
    popoverTriggerEl.classList.add("active");
    popover.show();
  }
});
```

Damit das Popover nicht automatisch geschlossen wird, nutzen wir das Bootstrap Event `hide.bs.popover`.
Wir prüfen darin, ob das auslösende Trigger-Element das Data-Attribut `data-ir-popover-clicked` besitzt 
und deshalb dass Popover geöffnet bleiben soll. 
Durch Aufruf von [`preventDefault()`](https://developer.mozilla.org/en-US/docs/Web/API/Event/preventDefault)
wird dann die Ausführung des Hide-Events unterbrochen.

``` javascript
popoverTriggerEl.addEventListener('hide.bs.popover', (event) => {
  if (popoverTriggerEl.dataset.irPopoverClicked == "true") {
    event.preventDefault();
  }
});
```

### Aktivierung des Schließen-Button

Da der Schließen-Button dynamisch erzeugt wird, lässt er sich so nicht einfach in das Eventsystem des Browsers einbinden. 
Deshalb registrieren wir uns am globalen Click-Event und prüfen über 
die [`classList`](https://developer.mozilla.org/en-US/docs/Web/API/Element/classList), 
ob es sich bei dem geklickten Element um einen Schließen-Button mit der Klasse `btn-close` handelt. 
Wenn ja ermitteln wir aus dessen Data-Attribut die ID des Trigger-Elementes, welches das Popup ursprünglich geöffnet hat.
Mit dem [Optional Chaining Operator (?.)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Operators/Optional_chaining) 
wird sichergestellt, dass der Code fehlerfrei läuft und `undefined` zurückliefert, falls das Data-Attribut nicht vorhanden ist.
Wenn eine ID ermittelt wurde, holen wir uns das Trigger-Element mit der Funktion `document.getElementById()` 
und löschen dessen Data-Attribut `ir-popover-clicked` sowie die CSS-Klasse `active`. 
Dann holen wir uns mit `getOrCreateInstance()` das zugehörige Popover-Objekt und schließen es mit `hide()`.

``` javascript
  document.addEventListener('click', (eventClick) => {
    const targetEl = eventClick.target;
    const idTriggerEl = targetEl.dataset.irPopoverTrigger?.replace("#", "");
    if (targetEl.classList.contains("btn-close") && idTriggerEl) {
      const triggerEl = document.getElementById(idTriggerEl);
      delete triggerEl.dataset.irPopoverClicked;
      triggerEl.classList.remove("active");
      const popover = bootstrap.Popover.getOrCreateInstance(triggerEl);
      popover.hide();
    }
  });
```

### Fazit
Damit ist da Popover vollständig konfiguriert und funktionsbereit.
Ich hoffe, dass mit diesem Tutorial verschiedene Aspekte aus der Arbeit mit Bootstrap und Javascript vermittelt werden konnten
und nun **Viel Spaß beim Ausprobieren!**.
