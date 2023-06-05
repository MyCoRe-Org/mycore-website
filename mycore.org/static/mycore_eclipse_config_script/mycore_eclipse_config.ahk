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
; Getestet für die Eclipse Versionen 2022-06 bis 2023-03
;
; Change History:
;   v.0.91:  - Git Basis-Verzeichnis aktualisieren
;            - Javascript Formatter Konfiguration herunterladen und installieren
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

Gui, Font, S12 CDefault Bold, Verdana
Gui, Add, GroupBox, x20 y110 w290 h350, Download und Installation
Gui, Font, S8 norm, Verdana
Gui, Add, Text, x40 y140 w260 r6 , Die Eclipse IDE for Enterprise Java and Web Developers (jee) wird heruntergeladen und nach %EclipseInstallationDir% entpackt. Wird keine Eclipse Version angegeben, wird die aktuelle Version automatisch ermittelt.
Gui, Add, Text, x40 y240 w120 r1 vTextEclipseVersion, Eclipse Version
Gui, Add, Edit, x150 y240 w140 r1 vEclipseVersion
Gui, Font, S7, Verdana
Gui, Add, Text, x40 y268 w270 r1 vInfoEclipseVersion, (z.B. 2020-09, 2022-06, ...)
Gui, Font, S10 bold, Verdana
Gui, Add, Button, x50 y300 w230 r1 gDownloadEclipse vDownloadEclipse, Downloaden und Installieren

Gui, Font, S12 CDefault Bold, Verdana
Gui, Add, GroupBox, x330 y110 w290 h350, Konfiguration (Codestyle)
Gui, Font, S8 norm, Verdana
Gui, Add, Text, x350 y140 w260 r3 , Die Eclipse-Anwendung wird eingerichtet. Starten Sie Eclipse und öffnen Sie den zu konfigurierenden Eclipse-Workspace.
Gui, Font, S8 bold, Verdana
Gui, Add, Text, x350 y180 w260 r2 , Achten Sie darauf, dass zur Zeit nur EINE Eclipse-Anwendung geöffnet ist.
Gui, Font, S8 norm, Verdana
Gui, Add, CheckBox, x350 y240 w260 vOptEncoding Checked, Text file encoding (UTF-8)
Gui, Add, CheckBox, x350 y260 w260 r2 vOptMyCoReJavaCodeStyle Checked, Java Code Style Formatter für MyCoRe
Gui, Font, S7 norm, Verdana
Gui, Add, Text, x365 y285 w260 r1 vTextMyCoReJavaCodeStyle, (Download von der Homepage)
Gui, Font, S8 norm, Verdana
Gui, Add, CheckBox, x350 y315 w260 r1 vOptXMLCode Checked, XML File Formatting
Gui, Add, CheckBox, x350 y335 w260 r1 vOptHTMLCode Checked, HTML File Formatting
Gui, Add, CheckBox, x350 y355 w260 r1 vOptGitCode Checked, Git Repository Configuration
Gui, Add, CheckBox, x350 y375 w260 r1 vOptJavascriptCode Checked, Javascript Configuration
Gui, Font, S10 bold, Verdana
Gui, Add, Button, x410 y395 w120 r1 gConfigure, Konfigurieren

if(!A_isAdmin) {
	GuiControl, Disable, TextEclipseVersion
	GuiControl, Disable, EclipseVersion
	GuiControl, Disable, InfoEclipseVersion
	GuiControl, Disable, DownloadEclipse
	GuiControl, Disable, OptMyCoReJavaCodeStyle
	;Uncheck MyCoReJavaCodeStyle Checkbox
	GuiControl, , OptMyCoReJavaCodeStyle,0
	GuiControl, Disable, TextMyCoReJavaCodeStyle
}

Gui, Show, w640 h480, MyCoRe: Eclipse Download und Konfiguration (%AppVersion%)
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
	if(OptXMLCode = 1) {
		XMLCode()
	}
	if(OptHTMLCode = 1) {
		HTMLCode()
	}
	if(OptGitCode = 1) {
		GitCode()
	}
	if(OptJavascriptCode = 1) {
		JavascriptCode()
	}
	MsgBox, 0, Eclipse Konfiguration abgeschlossen ..., Die Eclipse Konfiguration ist abgeschlossen!
	WinActivate, ahk_class AutoHotkeyGUI
	return

; Subroutine für das Runterladen und Entpacken von Eclipse
DownloadEclipse:
	DownloadEclipseAndUnzip()
	Sleep 200
	WinActivate, ahk_class AutoHotkeyGUI
	return

; Setzt für den Workspace die generelle Kodierung auf UTF-8
Encoding() {
	; Window -> Preferences -> General -> Workspace
	Send, ^3
	Send, General Workspace
	Loop 4 {
		Send, {down}
	}
	Send, {Enter}
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
	; Window -> Preferences -> XML -> XML Files -> Editor
	Send, ^3
	Send, Editor XML XML Files
	Send, {Enter}
	; Standardeinstellungen setzen
	Send, !a
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
	;Apply Button klicken
	Send, !a
	Send, {Space}
	; Fenster schließen
	Send, {Esc}
}

; HTML-Code Formatierung
HTMLCode() {
	global ConfigEclipseVersion
	if (ConfigEclipseVersion != "2022-12") {
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
	SendRaw, ${workspace_loc}\git
	; Apply Button klicken
	Loop, 14 {
		Send, {Tab}
	}
	Send, !a
	Send, {Space}
	; Fenster schlie�en
	Send, {Esc}
}

; Javascript Style-Regeln von der MyCoRe Homepage runterladen und installieren
JavascriptCode() {
	URLDownloadToFile, https://www.mycore.de/downloads/mycore-javascriptstyle.xml, %A_Desktop%\..\Downloads\mycore-javascriptstyle.xml
	Sleep 500
	; Eclipse Fenster wird in den Vordergrung geholt und aktiviert
	WinActivate, ahk_class SWT_Window0
	; Window -> Preferences -> Web -> Client-side JavaScript -> Formatter
	Send, ^3
	Send, Web Client-side JavaScript Formatter
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
	; Fenster schlie�en
	Send, {Esc}
}

; Eclipse runterladen und entpacken
DownloadEclipseAndUnzip() {
	global EclipseDownloadServerURL
	global EclipseInstallationDir
	; Wenn keine Eclipse-Version eingegeben wurde, wird die aktuelle Version ermittelt
	if(vEclipseVersion == "")
	{
		URLDownloadToFile, %EclipseDownloadServerURL%/release/release.xml, %A_Desktop%\..\Downloads\eclipse-release.xml
		FileRead, xmldata, %A_Desktop%\..\Downloads\eclipse-release.xml
		xmlDoc := ComObjCreate("MSXML2.DOMDocument.6.0")
		xmlDoc.async := false
		xmlDoc.loadXML(xmldata)
		vEclipseVersion := SubStr(xmlDoc.selectSingleNode("//present").text, 1, 7)
	}
	EclipseDir = %EclipseInstallationDir%\eclipse-jee-%vEclipseVersion%-R-win32-x86_64
	; Ist der Eclipse Ordner nicht vorhanden, dann erfolgt die Installation
	if !FileExist(EclipseDir)
	{
		EclipseDownloadURL = %EclipseDownloadServerURL%/release/%vEclipseVersion%/R/eclipse-jee-%vEclipseVersion%-R-win32-x86_64.zip
		EclipseDownloadFile = %A_Desktop%\..\Downloads\eclipse-jee-%vEclipseVersion%-R-win32-x86_64.zip
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
		RunWait, PowerShell -Command Expand-Archive -LiteralPath $HOME\Downloads\eclipse-jee-%vEclipseVersion%-R-win32-x86_64.zip -DestinationPath $HOME\Downloads
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
