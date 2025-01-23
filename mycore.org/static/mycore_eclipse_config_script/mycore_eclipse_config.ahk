; MyCoRe: Eclipse Download und Konfiguration
;
; Tool zum automatischen download/entpacken und konfigurieren von Eclipse.
;
; AutoHotKey Version 1.1.33.02
; https://www.autohotkey.com/download/
;
; SciTe4 AutoHotKey Version 3.0.06.01
; Script-Editor für AutoHotKey
; https://www.autohotkey.com/scite4ahk/
;
; MyCoRe-Code-Style
; https://www.mycore.de/documentation/developer/codestyle/
;
; Getestet für die Eclipse Versionen 2022-06 bis 2024-12
;
; Change History:
;   v.0.91:  - Git Basis-Verzeichnis aktualisieren
;            - Javascript Formatter Konfiguration herunterladen und installieren
;   v.0.92:  - CSS-Code Formatierung hinzugefügt
;   v.0.93:  - Text Editor Formatierung hinzugefügt
;
;----------------------------------------------------------------------------------------------------------------------

; GLOBALE VARIABLEN
; Programm Version
AppVersion = v0.9
; Verzögerung der Tastaturanschläge in Millisekunden bei der Programmausführung
KeyDelay = 250
; Basisadresse des Eclipse-Download-Servers
EclipseDownloadServerURL = https://ftp.halifax.rwth-aachen.de/eclipse/technology/epp/downloads
; alternativ
; EclipseDownloadServerURL = https://rhlx01.hs-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads
; Order in dem die Eclipse Zip-Datei entpackt wird
EclipseInstallationDir = %A_ProgramFiles%\Eclipse

;----------------------------------------------------------------------------------------------------------------------

; GUI
; Erzeugung der Benutzeroberfläche
Gui, Font, S14 CDefault Bold, Verdana
Gui, Add, Text, x20 y10 w500 h30 , MyCoRe: Eclipse Download und Konfiguration
if(!A_IsAdmin) {
	Gui, Font, S8  norm, Verdana
	Gui, Add, GroupBox, x20 y40 w600 r1
	Gui, Add, Text, c800000 x40 y60 r1, Einige Funktionen wurden deaktiviert. Starten Sie das Programm / Skript als Administrator!
}

Gui, Font, S8 norm, Verdana
Gui, Add, Text, x20 y100 r1, Ihre Eclipse Version (z.B. 2024-09)
Gui, Add, Edit, x250 y100 w60 vEclipseVersion

Gui, Font, S12 CDefault Bold, Verdana
Gui, Add, GroupBox, x20 y130 w290 h350, Download und Installation
Gui, Font, S8 norm, Verdana
Gui, Add, Text, x40 y160 w260 r6 , Die Eclipse IDE for Enterprise Java and Web Developers (jee) wird heruntergeladen und nach %EclipseInstallationDir% entpackt. Wird keine Eclipse Version angegeben, wird die aktuelle Version automatisch ermittelt.
Gui, Font, S10 bold, Verdana
Gui, Add, Button, x50 y260 w230 r1 gDownloadEclipse vDownloadEclipse, Downloaden und Installieren

Gui, Font, S12 CDefault Bold, Verdana
Gui, Add, GroupBox, x330 y130 w290 h350, Konfiguration (Codestyle)
Gui, Font, S8 norm, Verdana
Gui, Add, Text, x350 y160 w260 r3 , Die Eclipse-Anwendung wird eingerichtet. Starten Sie Eclipse und öffnen Sie den zu konfigurierenden Eclipse-Workspace.
Gui, Font, S8 bold, Verdana
Gui, Add, Text, x350 y200 w260 r2 , Achten Sie darauf, dass zur Zeit nur EINE Eclipse-Anwendung geöffnet ist.
Gui, Font, S8 norm, Verdana
Gui, Add, CheckBox, x350 y260 w260 vOptEncoding Checked, Text file encoding (UTF-8)
Gui, Add, CheckBox, x350 y280 w260 r2 vOptMyCoReJavaCodeStyle Checked, Java Code Style Formatter für MyCoRe
Gui, Font, S7 norm, Verdana
Gui, Add, Text, x365 y305 w260 r1 vTextMyCoReJavaCodeStyle, (Download von der Homepage)
Gui, Font, S8 norm, Verdana
Gui, Add, CheckBox, x350 y325 w260 r1 vOptJavascriptCodeStyle Checked, Javascript Code Style Formatter
Gui, Add, CheckBox, x350 y350 w260 r1 vOptXMLCode Checked, XML File Formatting
Gui, Add, CheckBox, x350 y370 w260 r1 vOptTextEditoren Checked, Text Editors Formatting
Gui, Add, CheckBox, x350 y390 w260 r1 vOptGitCode Checked, Git Repository Configuration

Gui, Font, S10 bold, Verdana
Gui, Add, Button, x410 y435 w120 r1 gConfigure, Konfigurieren

if(!A_isAdmin) {
	GuiControl, Disable, TextEclipseVersion
	GuiControl, Disable, DownloadEclipse
	GuiControl, Disable, OptMyCoReJavaCodeStyle
	GuiControl, Disable, OptJavascriptCodeStyle
	;Uncheck MyCoReJavaCodeStyle Checkbox
	GuiControl, Disable, OptTexytEditoren
	GuiControl, , OptMyCoReJavaCodeStyle,0
	GuiControl, , OptJavascriptCodeStyle,0
	GuiControl, Disable, TextMyCoReJavaCodeStyle
}

Gui, Show, w640 h500, MyCoRe: Eclipse Download und Konfiguration (%AppVersion%)
return

; Subroutine für die Eclipse Konfiguration
; Ausgeführt vom Button 'Konfigurieren'
Configure:
	; Benutzereingaben werden gespeichert
	Gui, Submit, NoHide
	SetKeyDelay, %KeyDelay%
	; Eclipse Fenster wird in den Vordergrung geholt und aktiviert
	WinActivate, ahk_class SWT_Window0

	if(OptEncoding = 1) {
		Encoding()
	}
	if(OptMyCoReJavaCodeStyle = 1) {
		MyCoReJavaCodeStyle()
	}
	if(OptJavascriptCodeStyle = 1) {
		JavascriptCode()
	}
	if(OptXMLCode = 1) {
		XMLCode()
	}
	if(OptTextEditoren = 1) {
		TextEditoren()
	}
	if(OptGitCode = 1) {
		GitCode()
	}

	MsgBox, 0, Eclipse Konfiguration abgeschlossen ..., Die Eclipse Konfiguration ist abgeschlossen!
	Sleep 1000
	WinActivate, ahk_class AutoHotkeyGUI
	return

; Subroutine für das Runterladen und Entpacken von Eclipse
DownloadEclipse:
    ; Formularfelder werden in Variablen gespeichert
	Gui, Submit, NoHide
	DownloadEclipseAndUnzip()
	Sleep 200
	WinActivate, ahk_class AutoHotkeyGUI
	return

; Setzt für den Workspace die generelle Kodierung auf UTF-8
Encoding() {
	global EclipseVersion
	if (EclipseVersion >= "2024-12") {
		Send, ^3
		Send, hook
		Send, {Enter}
	} else {
		; Window -> Preferences -> General -> Workspace
		Send, ^3
		Send, General Workspace
		Loop 4 {
			Send, {down}
		}
		Send, {Enter}
	}

	; Standardeinstellungen setzen
	Send, !d
	; Text File encoding -> Other -> UTF-8
	Send, !u
	Send, {down}
	Send, {TAB down}
	Send, UTF-8
	; Apply Button klicken
	Send, {TAB down}
	Send, {TAB down}
	Send, {TAB down}
	Send, {Space}
	; Fenster schließen
	Send, {Esc}
}

; Java-Code-Style-Regeln von der MyCoRe Homepage runterladen und installieren
MyCoReJavaCodeStyle() {
	URLDownloadToFile, https://www.mycore.de/downloads/mycore-javastyle.xml, %A_Desktop%\..\Downloads\mycore-javastyle.xml
	Sleep 500
	; Eclipse Fenster wird in den Vordergrung geholt und aktiviert
	WinActivate, ahk_class SWT_Window0
	; Window -> Preferences -> Java -> Code Style -> Formatter
	Send, ^3
	Send, Code Style Formatter
	Send, {Enter}
	; Import
	Send, !m
	Send, %A_Desktop%\..\Downloads\mycore-javastyle.xml
	Send, {Enter}
	; Check
	if WinActive("Importing Profile") {
		Send, {Enter}
	}
	; Load Profil Check
	If WinActive("Load Profile")
	{
			Send, !o
			Send, {Enter}
	}
	; Apply Button klicken
	Send, !a
	Send, {Space}
	; Fenster schließen
	Send, {Esc}
}

; XML-Code Formatierung
XMLCode() {
	global EclipseVersion
	if (EclipseVersion >= "2024-12") {
	; Window -> Preferences -> XML (Wild Web Developer) -> Formatting
		Send, ^3
		Send, XML Wild Formatting
		Send, {Enter}
		; Standardeinstellungen setzen
		Send, !a
		; Shift Tab. Ein Tab zurück
		Send, +{Tab}
		Send, {Enter}
		; Line width 120
		Send, !e
		Send, +{Tab}, +{Tab}
		Send, ^a
		Send, 120
	} else {
		; Window -> Preferences -> XML -> XML Files -> Editor
		Send, ^3
		Send, Editor XML XML Files
		Send, {Enter}
		; Standardeinstellungen setzen
		Send, !d
		Send, {Tab}
		; Line width 120
		Send, !w
		Send, ^a
		Send, 120
		; Indent using spaces
		Send, !n
		; Indentation size 2
		Send, !d
		Send, 2
		; Format Comments abschalten
		Send, !f
		Send, -
	}
	;Apply Button klicken
	Send, !a
	Send, {Space}
	; Fenster schließen
	Send, {Esc}
}

; Text-Editoren Formatierung
TextEditoren() {
	global EclipseVersion
		; Window -> Preferences -> Web -> HTML Files -> Editor
		Send, ^3
		Send, Editor Web HTML Files
		Send, {Enter}
		; Standardeinstellungen setzen
		Send, !d
		; Line width 120
		Send, !w
		Send, ^a
		Send, 120
		; Indent using spaces
		Send, !n
		; Indentation size 2
		Send, !t
		Send, 2
		; Apply Button klicken
		Send, !a
		Send, {Space}
		; Fenster schließen
		Send, {Esc}

		; CSS-Code Formatierung
		; Window -> Preferences -> Web -> CSS Files -> Editor
		Send, ^3
		Send, Editor Web CSS Files
		Send, {Enter}
		; Standardeinstellungen setzen
		Send, !e
		Send, {Tab}
		Send, {Enter}
		; Line width 120
		Send, !w
		Send, ^a
		Send, 120
		; Indent using spaces
		Send, !n
		; Indentation size 2
		Send, !d
		Send, 2
		; Apply Button klicken
		Send, !e
		Send, {Tab}
		Send, {Tab}
		Send, {Space}
		; Fenster schließen
		Send, {Esc}

	if (EclipseVersion >= "2024-12") {
		; Eclipse Version >= 2024-12 Text 	Editoren Formatierung
		; Window - Preferences -> General -> Editors -> Text Editors
		Send, ^3
		Send, General Editors Accessibility
		Send, {Enter}
		; Shift Tab. Ein Tab zurück
		Send, +{Tab}
		; Shift Tab. Ein Tab zurück
		Send, +{Tab}
		Send, {Left}
		; Standardeinstellungen setzen
		Send, !a
		; Shift Tab. Ein Tab zurück
		Send, +{Tab}
		Send, {Enter}
		; Insert spaces for tabs
		Send, !i
		; Displayed tab width 2
		Send, !t
		Send, ^a
		Send, 2
		; Apply Button klicken
		Send, !a
		Send, {Space}
		; Fenster schließen
		Send, {Esc}
	} else {
		; Text Editoren Formatierung
		; Window -> Preferencces -
		Send, ^3
		Send, Preferences Text Editor
		Loop 15 {
			Send, {down}
		}
		Send, {up}
		Send, {Enter}
		; Standardeinstellungen setzen
		Send, !d
		Send, {Enter}
		; Displayed tab width 2
		Send, !t
		Send, ^a
		Send, 2
		; Insert spaces for tabs
		Send, !i
		; Apply Button klicken
		Send, !a
		Send, {Space}
		; Fenster schließen
		Send, {Esc}
	}

}

; Git
GitCode() {
	; Window -> Preferences -> Version Control (Team) -> Git
    Send, ^3
	Send, Git Version Control
	Send, {Enter}
	; Set Default repository folder
	Send, !f
	Send, ^a
	SendRaw, ${workspace_loc}\..\git
	; Apply Button klicken
	Loop, 14 {
		Send, {Tab}
	}
	Send, !a
	Send, {Space}
	; Fenster schließen
	Send, {Esc}
}

; Javascript Style-Regeln von der MyCoRe Homepage runterladen und installieren
JavascriptCode() {
	global EclipseVersion
	URLDownloadToFile, https://www.mycore.de/downloads/mycore-javascriptstyle.xml, %A_Desktop%\..\Downloads\mycore-javascriptstyle.xml
	Sleep 500
	; Eclipse Fenster wird in den Vordergrung geholt und aktiviert
	WinActivate, ahk_class SWT_Window0
	; Window -> Preferences -> Web -> Client-side JavaScript -> Formatter
	Send, ^3
	if (EclipseVersion >= "2024-12") {
		Send, Java Code Style Formatter
	} else {
		Send, Web Client-side JavaScript Formatter
	}
	Send, {Enter}
	; Import
	Send, !m
	Send, {Space}
	Send, %A_Desktop%\..\Downloads\mycore-javascriptstyle.xml
	Send, {Enter}
	; Check if Window is open
	if WinActive("Load Profile")
	{
		Send, !o
		Send, {Enter}
	}
	; Apply Button klicken
	Send, !a
	Send, {Space}
	; Fenster schließen
	Send, {Esc}
}

; Eclipse runterladen und entpacken
DownloadEclipseAndUnzip() {
	global EclipseDownloadServerURL
	global EclipseInstallationDir
	global EclipseVersion
	; Wenn keine Eclipse-Version eingegeben wurde, wird die aktuelle Version ermittelt
	if(EclipseVersion == "")
	{
		URLDownloadToFile, %EclipseDownloadServerURL%/release/release.xml, %A_Desktop%\..\Downloads\eclipse-release.xml
		FileRead, xmldata, %A_Desktop%\..\Downloads\eclipse-release.xml
		xmlDoc := ComObjCreate("MSXML2.DOMDocument.6.0")
		xmlDoc.async := false
		xmlDoc.loadXML(xmldata)
		EclipseVersion := SubStr(xmlDoc.selectSingleNode("//present").text, 1, 7)
	}
	EclipseDir = %EclipseInstallationDir%\eclipse-jee-%EclipseVersion%-R-win32-x86_64
	; Ist der Eclipse Ordner nicht vorhanden, dann erfolgt die Installation
	if !FileExist(EclipseDir)
	{
		EclipseDownloadURL = %EclipseDownloadServerURL%/release/%EclipseVersion%/R/eclipse-jee-%EclipseVersion%-R-win32-x86_64.zip
		EclipseDownloadFile = %A_Desktop%\..\Downloads\eclipse-jee-%EclipseVersion%-R-win32-x86_64.zip
		SplashImage , ,M W980 H140, Bitte warten..., `nEclipse wird gerade heruntergeladen. `n`n URL: %EclipseDownloadURL% `n Datei: %EclipseDownloadFile%
		URLDownloadToFile, %EclipseDownloadURL%, %EclipseDownloadFile%
		SplashImage, Off
		; Bei einer Falschen URL wird die Fehlerseite runtergeladen und ist ca 1Kb groß, dass wird hier abgefangen und die Datei gelöscht
		FileGetSize, FileSize, %EclipseDownloadFile%, K
		if(FileSize < 5)
		{
			MsgBox, ,Eclipse Installation abgebrochen, Fehler beim Download der URL:`n%EclipseDownloadURL%
			FileDelete, %EclipseDownloadFile%
			return
		}
		; Gibt es einen Ordner Eclipse schon? Wenn ja löschen
		if FileExist(A_Desktop "\..\Downloads\eclipse")
		{
			FileRemoveDir, %A_Desktop%\..\Downloads\eclipse, true
		}
		RunWait, PowerShell -Command Expand-Archive -LiteralPath $HOME\Downloads\eclipse-jee-%EclipseVersion%-R-win32-x86_64.zip -DestinationPath $HOME\Downloads
		FileMoveDir, %A_Desktop%\..\Downloads\eclipse, %EclipseDir%
		; Zip löschen
		FileDelete, %EclipseDownloadFile%
		MsgBox, 4, Eclipse Installation beendet., Sie finden ihr neues Eclipse unter`n%EclipseDir%.`n`nOrdner öffnen?
		IfMsgBox Yes
		{
			Run, %EclipseDir%
			return
		}
	} else
	{
		MsgBox, 4, Eclipse Installation abgebrochen., Der Ordner `n%EclipseDir%`nexistiert bereits.`n`nOrdner öffnen?
		IfMsgBox Yes
		{
			Run, %EclipseDir%
			return
		}
	}
}
