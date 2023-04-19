# MyCoRe Website with Hugo

## Requirements:
 - Maven 3.5 or higher (https://maven.apache.org/download.cgi)
 - optional: Hugo extended 0.99.1 (https://github.com/gohugoio/hugo/releases)

## To start local:

### :sheep::sheep: Clone repository
### :jigsaw: Prepare build and load dependencies
 ```shell
 mvn clean compile
 ```
### :building_construction: Build with hugo wrapper
 ```shell
  cd mycore.org
  ./hugow server
 ```
### :point_right: Alternative: build with installed hugo version
 ```shell
  cd mycore.org
  hugo server
 ```
### :globe_with_meridians: Read local site in browser
 Open your browser and go to <http://localhost:1313/>.
 
### :facepalm: Troubleshooting
 We have seen some problems with Hugo's Fast-Render-Mode (e.g. duplicated entries in site search),
   so you might turn it of by starting hugo with
```
> hugow server --disableFastRender
```
 - To include drafts and planned content, use the corresponding build instructions, i.e.:
```
> hugow server --buildDrafts --buildFuture
```
 
