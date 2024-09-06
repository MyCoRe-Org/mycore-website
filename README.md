# MyCoRe Website with Hugo
(online at: https://www.mycore.de)

## Requirements:
 - Maven 3.5 or higher (https://maven.apache.org/download.cgi)
 - Hugo extended 0.89 (https://github.com/gohugoio/hugo/releases)


## To start locally:

 - clone repository
   ```
   git clone https://github.com/MyCoRe-Org/mycore-website.git
   ```
 - build website
   ```
   > yarn build
   ```
   or
   ```
   > maven clean compile
   ```
- start Hugo
  ```
  > cd mycore.org
  > hugo server
  ```
- open your browser and goto <http://localhost:1313/>
 
 ### Troubleshooting
 - We have seen some problems with Hugo's Fast-Render-Mode (e.g. duplicated entries in site search),
   so you might turn it of by starting hugo with
```
> hugo server --disableFastRender
```
 - To include drafts and planned content, use the corresponding build instructions, i.e.:
```
> hugo server --buildDrafts --buildFuture
```
 
