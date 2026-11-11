 async function retrieveMavenData(e){
   //Beispiel-Result { url: 'https://central.sonatype.com/repository/maven-snapshots/org/mycore/mycore-base/2025.12.0-SNAPSHOT/mycore-base-2025.12.0-20251204.160950-64.pom',
   //                  version: '2023.06.5-SNAPSHOT',
   //                  snapshotVersion: '2023.06.5-20251216.150037-2'
   //                  metadataURL: https://central.sonatype.com/repository/maven-snapshots/org/mycore/mir/mir-webapp/2023.06.5-SNAPSHOT/maven-metadata.xml'
   //                }
   const metadataURL = await retrieveMavenMetadataURL(e);
   if(metadataURL != null){
     const text = await fetch("https://corsproxy.io/?url="+metadataURL)
         .then((response) => response.text());

     const parser = new DOMParser();
     const xmlDoc = parser.parseFromString(text, "text/xml");

     const ext = e.dataset.mavenExtension;
     const snapshotVersion = xmlDoc.evaluate(
           "//snapshotVersion[extension='" + ext + "']/value",
           xmlDoc, null, XPathResult.STRING_TYPE, null
         ).stringValue;
     const version = xmlDoc.evaluate(
           "/metadata/version",
           xmlDoc, null, XPathResult.STRING_TYPE, null
         ).stringValue;
     const downloadURL = "https://central.sonatype.com/repository/maven-snapshots/"
           + e.dataset.mavenGroupid.replaceAll(".", "/")
           + "/" + e.dataset.mavenArtifactid+ "/" +version
           + "/" +e.dataset.mavenArtifactid + "-" + snapshotVersion
           + "." +e.dataset.mavenExtension;
     return {version: version, snapshotVersion:snapshotVersion, url: downloadURL, metadataURL: metadataURL};
   }
   else {
     return null;
   }
 }
 
async function retrieveMavenMetadataURL(e){
   // Beispiel: https://central.sonatype.com/repository/maven-snapshots/org/mycore/mycore-base/2026.06.1-SNAPSHOT/maven-metadata.xml
   let versionXmlURL = retrieveMavenSnapshotsURL(e);
   const text = await fetch("https://corsproxy.io/?url="+versionXmlURL)
     .then((response) => response.text());
   const parser = new DOMParser();
   const xmlDoc = parser.parseFromString(text, "text/xml");
   const version=e.dataset.mavenVersion;

  const snapshotVersion = xmlDoc.evaluate(
    "(//versions/version[starts-with(., '" + version + "')])[last()]",
       xmlDoc, null, XPathResult.STRING_TYPE, null).stringValue;

  let metadataXmlURL = "https://central.sonatype.com/repository/maven-snapshots/"
    + e.dataset.mavenGroupid.replaceAll(".","/") + "/" + e.dataset.mavenArtifactid
    + "/" + snapshotVersion + "/maven-metadata.xml";
  return metadataXmlURL;
}

async function extractMyCoReParentVersionFromPom(url){
  const text = await fetch("https://corsproxy.io/?url="+url)
    .then((response) => response.text());
  const parser = new DOMParser();
  const xmlDoc = parser.parseFromString(text, "text/xml");
  const nsResolver = function(prefix){
    const ns = {
      mvn: "http://maven.apache.org/POM/4.0.0"
    };
    return ns[prefix] || null;
  };
  const mcrParentVersion = xmlDoc.evaluate(
    "/mvn:project/mvn:parent/mvn:version",
    xmlDoc, nsResolver, XPathResult.STRING_TYPE, null).stringValue;
  return mcrParentVersion;
}

/** *********************************************************
 *  re-implementation via shields.io API
 *  *********************************************************/
async function retrieveMavenDataViaShieldsIo(e){
  //Beispiel-Result { url: 'https://central.sonatype.com/repository/maven-snapshots/org/mycore/mycore-base/2025.12.0-SNAPSHOT/mycore-base-2025.12.0-20251204.160950-64.pom',
  //                  version: '2023.06.5-SNAPSHOT',
  //                  snapshotVersion: '2023.06.5-20251216.150037-2'
  //                  metadataURL: https://central.sonatype.com/repository/maven-snapshots/org/mycore/mir/mir-webapp/2023.06.5-SNAPSHOT/maven-metadata.xml'
  //                }
  const metadataURL = await retrieveMavenMetadataURLViaShieldsIo(e);
    if(metadataURL != null){
      const ext = e.dataset.mavenExtension;

      const jsonSnapshotVersionUrl = 'https://img.shields.io/badge/dynamic/xml.json'
        + '?url=' + encodeURIComponent(metadataURL)
        + '&query=' + encodeURIComponent("//snapshotVersion[extension='" + ext + "'][last()]/value")
        + '&label=' + ext;
      const jsonSnapshotVersion = await fetch(jsonSnapshotVersionUrl)
        .then((response) => response.json());
      const snapshotVersion = jsonSnapshotVersion.message;

      const jsonVersionUrl = 'https://img.shields.io/badge/dynamic/xml.json'
        + '?url=' + encodeURIComponent(metadataURL)
        + '&query=' + encodeURIComponent("//version");
          
      const jsonVersion = await fetch(jsonVersionUrl)
        .then((response) => response.json());
      const version = jsonVersion.message;

      const downloadURL = "https://central.sonatype.com/repository/maven-snapshots/"
        + e.dataset.mavenGroupid.replaceAll(".", "/")
        + "/" + e.dataset.mavenArtifactid+ "/" +version
        + "/" +e.dataset.mavenArtifactid + "-" + snapshotVersion
        + "." +e.dataset.mavenExtension;
        return {version: version, snapshotVersion:snapshotVersion, url: downloadURL, metadataURL: metadataURL};
    }
    else {
      return null;
    }
}

async function retrieveMavenMetadataURLViaShieldsIo(e){
  // Beispiel: https://central.sonatype.com/repository/maven-snapshots/org/mycore/mycore-base/2026.06.1-SNAPSHOT/maven-metadata.xml
  const metadataUrl = retrieveMavenSnapshotsURL(e);

  const query = e.dataset.mavenVersion ? ('//version[starts-with(., "'+ e.dataset.mavenVersion +'")][last()]') : ('//version[last()');
  const jsonUrl = 'https://img.shields.io/badge/dynamic/xml.json'
    + '?url=' + encodeURIComponent(metadataUrl)
    + '&query=' + encodeURIComponent(query);

  const json = await fetch(jsonUrl)
    .then((response) => response.json());

  const version=e.dataset.mavenVersion;

  const snapshotVersion = json.message; 

  let metadataXmlURL = "https://central.sonatype.com/repository/maven-snapshots/"
    + e.dataset.mavenGroupid.replaceAll(".","/") + "/" + e.dataset.mavenArtifactid
    + "/" + snapshotVersion + "/maven-metadata.xml";
  return metadataXmlURL;
}

async function extractMyCoReParentVersionFromPomViaShieldsIo(url){
  const query = '/*[local-name()="project"]/*[local-name()="parent"]/*[local-name()="version"]';
  const jsonUrl = 'https://img.shields.io/badge/dynamic/xml.json'
     + '?url=' + encodeURIComponent(url)
     + '&query=' + encodeURIComponent(query);

  const json = await fetch(jsonUrl)
     .then((response) => response.json());
  return json.message;
}


function retrieveMavenSnapshotsURL(e){
  // Beispiel: https://central.sonatype.com/repository/maven-snapshots/org/mycore/mycore-base/2026.06.1-SNAPSHOT/maven-metadata.xml
  return "https://central.sonatype.com/repository/maven-snapshots/"
    + e.dataset.mavenGroupid.replaceAll(".","/") + "/" + e.dataset.mavenArtifactid
    + "/maven-metadata.xml";
}
