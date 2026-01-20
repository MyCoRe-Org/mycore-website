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
     // Beispiel: https://central.sonatype.com/repository/maven-snapshots/org/mycore/mir/mir-webapp/2023.06.5-SNAPSHOT/maven-metadata.xml
   let versionXmlURL = "https://central.sonatype.com/repository/maven-snapshots/"
     + e.dataset.mavenGroupid.replaceAll(".","/") + "/" + e.dataset.mavenArtifactid
     + "/maven-metadata.xml";
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