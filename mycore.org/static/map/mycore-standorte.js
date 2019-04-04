     var map, select;
      $(document).ready(function() {
     var container = document.getElementById('popup');
    var content = document.getElementById('popup-content');
    var closer = document.getElementById('popup-closer');

    var overlay = new ol.Overlay(/** @type {olx.OverlayOptions} */ ({
        element: container,
        autoPan: true,
        autoPanAnimation: {
          duration: 250
        }
	}));

      /**
       * Add a click handler to hide the popup.
       * @return {boolean} Don't follow the href.
       */
	closer.onclick = function() {
    	overlay.setPosition(undefined);
        closer.blur();
        return false;
	};

    var kml = new ol.layer.Vector({
        source: new ol.source.Vector({
          url: '/map/mycore-standorte.kml',
          format: new ol.format.KML()
        })
	});
    
    var clusterSource = new ol.source.Cluster({
        distance: 15,
        source: kml.getSource()
	});
    
    var styleCache = {};
    var clusters = new ol.layer.Vector({
        source: clusterSource,
       
        style: function(feature) {
          var size = feature.get('features').length;
          var style = styleCache[size];
          if (!style) {
            style = new ol.style.Style({
              image: new ol.style.Circle({
                radius: 10,
                stroke: new ol.style.Stroke({
                  color: '#fff'
                }),
                fill: new ol.style.Fill({
                  color: '#265E78'
                })
              }),
              text: new ol.style.Text({
                text: size.toString(),
                fill: new ol.style.Fill({
                  color: '#fff'
                })
              })
            });
            styleCache[size] = style;
          }
          return style;
        }
    });
    
    /* 
    var osm =  new ol.layer.Tile({
            source: new ol.source.OSM()
    });
	
    var carto = new ol.layer.Tile({ 
    	source: new ol.source.XYZ({ 
        	url:'http://{1-4}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png'
    	})
	}); 
	
	 var natgeo = new ol.layer.Tile({ 
		    source: new ol.source.XYZ({ 
		        url:'https://server.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer/tile/{z}/{y}/{x}'
		    })
	 });
	 */
	var esri =  new ol.layer.Tile({
         source: new ol.source.XYZ({
            attributions: [new ol.Attribution({
	        	html: 'Tiles © <a href="https://services.arcgisonline.com/ArcGIS/' +
	            	  'rest/services/World_Topo_Map/MapServer">ArcGIS</a>'
	      	})],
             url: 'https://server.arcgisonline.com/ArcGIS/rest/services/' +
                 'World_Topo_Map/MapServer/tile/{z}/{y}/{x}'
           })
   	});
	
	var tiles = esri;
     
	var map = new ol.Map({
        	target: 'map',
        	layers: [tiles, clusters],
        	overlays: [overlay],
        	view: new ol.View({
				center: ol.proj.fromLonLat([10.5, 50.50]),
        		zoom: 6
    		})
	});

	function isCluster(feature) {
    	if (!feature || !feature.get('features')) { 
    		return false; 
  		}
    	return feature.get('features').length > 0;
   	}
      
    map.on('click', function(evt) {
    	var feature = map.forEachFeatureAtPixel(evt.pixel, 
    		                  function(feature) { return feature; });
    	
    	if (isCluster(feature)) {
    	    // is a cluster, so loop through all the underlying features
    		var features = feature.get('features');
    	    var output="";
    	    for(var i = 0; i < features.length; i++) {
    	      // here you'll have access to your normal attributes:
    	      console.log(features[i].get('name'));
    	      output += "<h2>" + features[i].get('name') + "</h2>" + features[i].get('description');
			}
    	  
			var coordinate = evt.coordinate;
        
			// Ausgabe der Koordinaten:
			// var hdms = ol.coordinate.toStringHDMS(ol.proj.transform(coordinate, 'EPSG:3857', 'EPSG:4326'));
        	// content.innerHTML = '<p>You clicked here:</p><code>' + hdms + '</code>'
          
      		content.innerHTML =  output;
        	overlay.setPosition(coordinate);
		}
    });
    
});