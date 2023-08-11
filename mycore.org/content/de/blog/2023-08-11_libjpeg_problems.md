---
title:  "Probleme bei der JPEG-Verarbeitung in Java17"
slug: 	libjpeg-java17-problem
date:   2023-08-11
publishDate: 2023-08-11

draft: 	false

blog/authors: 	["Robert Stephan"]
blog/periods: 	2023-08
blog/categories:
 - Störungen
blog/tags:
 - libjpeg
 - Java17

---
Bei der Verwendung von **Java17** kommt es auf verschiedenen aktuellen Linux-Systemen zu Problemem mit der Anzeige und Verarbeitung von JPEG-Dateien. Der Fehler liegt in der Systembibliothek **libjpeg-turbo** und kann mit einer Aktualisierung derselben behoben werden.

In MyCoRe-Repositorien sind unter anderem die IIIF-Image API oder die Thumbnail- Generierung davon betroffen.<!--more-->
Einige Bilder lassen sich dann z.B. per IIIF-API nicht ausliefern. Machmal funktioniert auch nur die Ausgabe von Bildern einer bestimmten Größe nicht. In der Tomcat-Logdatei (`catalina.out`) findet man dazu beispielsweise folgende Fehlermeldung:

```
ERROR  MCRIIIFImageResource: Error while getting Image {image-id} from  with region: 1024,5120,1024,543, size: 256,, rotation: 0, quality: default, format: jpg
org.mycore.iiif.image.impl.MCRIIIFImageProvidingException: Error while reading tiles!
        at org.mycore.iview2.iiif.MCRIVIEWIIIFImageImpl.provide(MCRIVIEWIIIFImageImpl.java:220)
        at org.mycore.iiif.image.resources.MCRIIIFImageResource.getImage(MCRIIIFImageResource.java:171)
        at jdk.internal.reflect.GeneratedMethodAccessor213.invoke(Unknown Source)
        at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.base/java.lang.reflect.Method.invoke(Method.java:568)
        at ...
        
Caused by: javax.imageio.IIOException: Bogus virtual array access
        at java.desktop/com.sun.imageio.plugins.jpeg.JPEGImageReader.readImage(Native Method)
        at java.desktop/com.sun.imageio.plugins.jpeg.JPEGImageReader.readInternal(JPEGImageReader.java:1382)
        at java.desktop/com.sun.imageio.plugins.jpeg.JPEGImageReader.read(JPEGImageReader.java:1162)
        at java.desktop/javax.imageio.ImageReader.read(ImageReader.java:938)
        at org.mycore.iview2.services.MCRIView2Tools.readTile(MCRIView2Tools.java:284)
        at org.mycore.iview2.iiif.MCRIVIEWIIIFImageImpl.provide(MCRIVIEWIIIFImageImpl.java:214)
```

Das Problem wird durch die Systembibliothek **libjpeg-turbo** verursacht (siehe [GitHub-Issue](https://github.com/libjpeg-turbo/libjpeg-turbo/issues/613)) und wurde mit der Version **2.1.4** behoben.
Viele Linux-Distributionen verwenden ältere Versionen dieser Bibliothek und müssen deshalb aktualisiert werden.


### Update unter Ubuntu 2022.04 LTS

Die derzeit installierte Version kann mit dem Befehl `apt-cache policy libjpeg-turbo8` abgefragt werden.
In der Regel sollte Version **2.1.2** installiert sein, welche aktualisiert werden muss.

Auf einem Ubuntu-Server befinden sich die libjpeg-Dateien im Verzeichnis `/usr/lib/x86_64-linux-gnu`
```
lrwxrwxrwx  1 root root        16 Feb 21  2022 libjpeg.so.8 -> libjpeg.so.8.2.2
-rw-r--r--  1 root root    522960 Feb 21  2022 libjpeg.so.8.2.2
```

Zur Aktualisierung kann das Installationspaket für **libjpeg-turbo8** aus dem folgenden Ubuntu-Release (2023.04, Lunar) verwendet werden, welches eine reparierte Version der Bibliothek enthält.

Die Downloadseite lautet: https://packages.ubuntu.com/lunar/libjpeg-turbo8.

Das Paket muss lediglich herunterladen und über den Paket-Manager installiert werden.

```
$ cd /tmp
$ wget http://de.archive.ubuntu.com/ubuntu/pool/main/libj/libjpeg-turbo/libjpeg-turbo8_2.1.5-2ubuntu1_amd64.deb
$ sudo apt install -f /tmp/libjpeg-turbo8_2.1.5-2ubuntu1_amd64.deb
```

Im Verzeichnis `/usr/lib/x86_64-linux-gnu` befinden sich nun die aktualisierten Dateien:
```
lrwxrwxrwx  1 root root        16 Feb  8  2023 libjpeg.so.8 -> libjpeg.so.8.2.2
-rw-r--r--  1 root root    534592 Feb  8  2023 libjpeg.so.8.2.2
```
Es schadet sicher nicht, jetzt den Server einmal neu zu booten.

### Update unter Suse SLES 14.3
Von unseren Suse-Nutzern kam folgende Anleitung, wie man die **libjpeg-turbo** Bibliothek lokal bauen 
und in sein System einbinden kann:

```
$ zypper install cmake nasm gcc

$ git clone https://github.com/libjpeg-turbo/libjpeg-turbo.git
$ cd libjpeg-turbo

$ cmake -G"Unix Makefiles" -DWITH_JAVA=1 -DWITH_JPEG8=1
$ export CFLAGS=-fPIC
$ make

$ cp libjpeg.so.8.2.2 /usr/lib64/
```
Das funktioniert für andere Linux-Distributionen ähnlich. 
Lediglich der Pfad, an den die Datei am Ende kopiert wird, kann abweichen.

Wichtig ist es mit der Option `-DWITH_JPEG8=1` zu bauen, da die aktuelle Version der Library schon JPEG9 verwendet, Java17 aber JPEG8 benötigt.
