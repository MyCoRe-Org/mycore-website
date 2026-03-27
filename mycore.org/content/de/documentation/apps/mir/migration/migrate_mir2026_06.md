---
title: "Migration MIR LTS 2025.12 nach 2026.06"
mcr_version: [ '2026.06' ]
author: [ '' ]
description: "Listet die einzelnen Schritte zur Migration von MIR LTS 2025.12 nach 2026.06 auf."
date: "2000-01-01"

---

{{< mcr-comment >}} Publish this page by setting the date and removing icon and property 'pre' from menus.de.yaml {{< /mcr-comment >}}
<div class="alert alert-warning">
  Diese Seite ist <strong>Work in Progress</strong>. <br />
  Sie wird im Rahmen der Fertigstellung des aktuellen MIR-Releases weiter ergänzt!
</div>

## Migrationsanleitung MIR

Hier sind weitere Schritte zur MIR-Migration gelistet, die neben der
[Migrationsanleitung für MyCoRe]({{< ref migrate_mcr2026_06 >}}) noch relevant sind.

### Umstellung bestehender Stylesheets auf `xslt`

Mit <a href="https://mycore.atlassian.net/browse/MCR-3497">MCR-3497</a> wurde das Stylesheet `tems2options` aus `xsl`
entfernt. Daher wurden mit <a href="https://mycore.atlassian.net/browse/MIR-1514">MIR-1514</a> alle Stellen in MIR,
die `items2options` bisher genutzt haben, auf die neuere Variante aus `xslt` umgestellt.

Im Zuge der Umstellung wurden ebenfalls folgende Änderungen umgesetzt:

- `convertClassificationOptions` nach `fix-classification-options` umbenannt und nach `xslt` verschoben
- `license-filter` nach `xslt` verschoben

Eigene Anpassungen, die die genannten Stylesheets nutzen, müssen folglich auf `xslt` umgestellt werden.

> Generell können Stylesheets über den <a href="https://mycore.atlassian.net/browse/MCR-3087">Flavour</a>-Mechanismus
> gezielt und selektiv auf `xslt` umgestellt werden, siehe MIR-1514.
{.note}

### Wegfall von `MIR.Viewer.DisableDerivateType`

Im Rahmen von <a href="https://mycore.atlassian.net/browse/MCR-3551">MCR-3551</a> ist das Property
`MIR.Viewer.DisableDerivateType` weggefallen. Wer dieses Property z.B. mit

```properties
MIR.Viewer.DisableDerivateType=foo,bar
```

angepasst hat, muss für jeden genannten Publikationstypen ein neues Property anlegen:

```properties
MCR.Derivate.DisplayFilter.Filter.Filters.20.Mappings.show-file-viewer.foo=false
MCR.Derivate.DisplayFilter.Filter.Filters.20.Mappings.show-file-viewer.bar=false
```

> Die augenscheinliche Komplexität des Property-Names liegt daran, dass in MyCoRe/MIR mit
> <a href="https://mycore.atlassian.net/browse/MCR-3551">MCR-3551</a> ein flexibel
> konfigurierbarer Mechanismus geschaffen wurde, um Derivate in verschiedenen
> Situationen auszublenden. In MIR sind dies:
>
> - Das Anzeigen des Viewers (`show-file-viewer`)
> - Das Anzeigen der Dateiliste (`show-file-area`)
> - Das Berücksichtigen beim Export (ZIP-Download, OAI-Schnittstelle) (`export`)
>
> Standardmäßig wird dies in MIR über den Derivat-Typ gesteuert. Mit
>
> ```
> MIR.Editor.Derivate.EditableIntentServiceFlags=true
> ```
>
> kann ein zusätzlicher Mechanismus aktiviert werden, bei dem das Standardverhalten für jedes Derivat einzeln
> überschrieben werden kann. Hierzu werden im Derivat-Editor zusätzliche Konfigurationsmöglichkeiten eingeblendet.
> 
> <div class="w-75">
> <img src="/images/apps/mir/migration/derivate_editor_2026_06.webp" class="border border-secondary p-0 w-100" />
> </div>
>
> Über das Berechtigungssystem (für das jeweilige Derivat und die Rechte `manage-intent-show-file-viewer`,
> `manage-intent-show-file-area` bzw. `manage-intent-export`) kann gesteuert werden, wer diese Einstellungen vornehmen kann.
{.note}