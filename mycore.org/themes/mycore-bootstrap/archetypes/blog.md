---
title: "{{ replace .Name "-" " " | title }}"
slug: anwendung
date: {{ .Date }}

draft: false

blog/authors: ["Max Mustermann", "Betty Beispiel"]
blog/periods: {{ dateFormat "2006-01" .Date }}
blog/categories:
 - "News"
blog/tags:
 - "Anwendungen"

#news/frontpage: true
#news/title_de: "{{ replace .Name "-" " " | title }}"
#news/teaser_de: 
#news/title_en: 
#news/teaser_en: 

---

## Erster Abschnitt

Text...