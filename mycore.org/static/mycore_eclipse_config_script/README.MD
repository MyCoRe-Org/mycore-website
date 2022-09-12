MyCoRe: Eclipse Download und Konfigurations-Tool
================================================

Tool zum automatischen Download, Entpacken und Konfigurieren der Entwicklungsumgebung Eclipse.

## Allgemeine Hinweise
Das Eclipse Download und Konfigurations-Tool wurde als AutoHotKey-Script (Version 1.1.33.02) erstellt.
AutoHotKey kann [hier](https://www.autohotkey.com/download/) heruntergeladen werden.
Für die Bearbeitung kann der Script-Editor SciTe4 (Version 3.0.06.01) verwendete werden.
SciTe4 kann [hier](https://www.autohotkey.com/scite4ahk/) heruntergeladen werden.
Die Konfiguration wurde getestet für die Eclipse Version 2022-06.

## Kompilieren des Skripts (optional)
Durch das Kompilieren wird eine ausführbare Exe-Datei erzeugt.
Dazu kann mit Rechtsklick auf das Skript der Menüpunkt "Compile Script" ausgewählt werden. Die Exe-Datei wird 
im selben Ordner erstellt in dem sich das Script befindet.
Alternativ kann der Script-Editor verwendet werden. Dort befindet sich Im Menü "Extras" der Punkt "Kompilieren".

## Ausführen

Das Tool sollte als Administrator ausgeführt werden, da sonst seine Funktionsfähigkeit eingeschränkt ist.

## Funktionen

### Download und Installation

Die Eclipse IDE for Enterprise Java and Web Developers (JEE) wird heruntergeladen und nach C:\Programme\Eclipse 
entpackt. Wird keine Eclipse Version angegeben, wird die aktuelle Version automatisch ermittelt.

### Konfiguration (Codestyle)

Das Eclipse Download und Konfigurations-Tool bietet die Auswahl mehrerer Optionen zum Konfigurieren von Eclipse:
- Text file encoding (UTF-8)
- Java Code Style Formatter für MyCoRe (Download von der Homepage)
- XML File Formatting
- HTML File Formatting

Beim Ausführen der automatischen Konfiguration sollte darauf geachtet werden,
dass nur eine Eclipse-Anwendung, in welcher die Einstellungen vorgenommen werden, geöffnet ist.
