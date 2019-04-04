---

title: Funktionen
description: beschreibung der wichtigsten MyCoRe Funktionen.

---

## Was kann MyCoRe?

MyCoRe ist ein System zur Entwicklung von Dokumenten- und Publikationsservern, Archivanwendungen, Sammlungen von Digitalisaten oder vergleichbaren Repositorien. Auf MyCoRe basierende Anwendungen nutzen einen gemeinsamen Kern, der die typischerweise für solche Anwendungen erforderliche Funktionalität wie Metadatenverwaltung, Suchfunktionen, OAI-Schnittstelle, ein Bildbetrachtungsmodul etc. bereitstellt. Dieser Kern kann um eigene, spezielle lokale Funktionen erweitert und per Konfiguration angepasst werden. Das _„CoRe“_ in MyCoRe steht für „Content Repository“ oder wahlweise für „Core“ (Kern), das _„My“_ für die lokale Anpassung und Nutzung. Neben diesem Kern, der als eine in der Programmiersprache Java implementierte Klassenbibliothek (mycore.jar) realisiert ist, stellen wir eine Beispielanwendung mit dem Namen „MIR“ zur Verfügung, die als Demonstrations- und Testumgebung dient, aber auch als Basis für einen eigenen MyCoRe-basierter Dokumentenserver verwendet werden kann. Eine weitere Beispielanwendung mit dem Namen „Skeleton“ steht als Anwendungsgerüst für eigene MyCoRe-basierte Anwendungen zur Verfügung. 

{{< mcr-figure src="/images/io/features/mycore_architecture.png"  title="MyCoRe Architektur-Skizze" width="75%" />}}

 MyCoRe ist also keine vollständige, unmittelbar einsetzbare Repository-Software wie etwa OPUS oder EPrints, sondern stellt eine API zur Erstellung solcher und ähnlicher Anwendungen zur Verfügung. Dadurch liegen die Stärken von MyCoRe in der Bereitstellung mächtiger, umfangreicher Funktionen und in der Flexibilität. Beispielsweise sind das Metadatenmodell, die Weboberflächen, Such- und Eingabemasken frei konfigurierbar. Den Aufbau von MyCoRe skizziert das oben stehende Architekturbild. Daneben kann „MIR“ als Framework verstanden werden, welches gerade Einsteigern alles in die Hand gibt, um einen ersten eigenen Dokumentenserver auf Basis von MyCoRe aufzusetzen, während das „Skeleton“ ein Grundgerüst für eine eigene MyCoRe-Anwendung verstanden werden kann.

MyCoRe hat seinen Ursprung in der MILESS-Software, einem an der Universität Essen entwickelten Dokumentenserver. Aus der Gruppe der Nachnutzer von MILESS entstand der Wunsch nach einem System, das zusätzliche Anforderungen abdeckt und mehr Flexibilität bietet, und für ein breiteres Anwendungsspektrum einsetzbar ist. Daraus entstand die MyCoRe-Initiative als Zusammenschluss von Software- und Anwendungsentwicklern in Bibliotheken und Rechenzentren mehrerer deutscher Universitäten.

#### MyCoRe Datenblatt

Die wichtigsten Daten zu MyCoRe finden Sie auf unserem MyCoRe-Datenblatt:

<i class="far fa-file-pdf"></i>&nbsp;&nbsp;&nbsp;[MyCoRe-Datenblatt (deutsch)](/filecollection/MyCoRe_Datenblatt.pdf)

<i class="far fa-file-pdf"></i>&nbsp;&nbsp;&nbsp;[MyCoRe datasheet (englisch)](/filecollection/MyCoRe_datasheet.pdf)

