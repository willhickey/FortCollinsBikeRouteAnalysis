$('document').ready(function(){
	var mapObject = L.map('fscaMap').setView([40.555258, -105.084419], 13);	

	var osm = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
	attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
	});
	var streets = new L.esri.basemapLayer('Streets');
    var imagery= new L.esri.basemapLayer('Imagery');
    var imagelabels = new L.esri.basemapLayer('ImageryLabels');
    var imagestreets = new L.esri.basemapLayer('ImageryTransportation');
    var fullimagery = new L.layerGroup([imagery, imagelabels, imagestreets])
    var topo = new L.esri.basemapLayer('Topographic');
          
	osm.addTo(mapObject);
	var baseMaps = {
		"Satellite": imagery,
		"OSM": osm
	};
	L.control.layers(baseMaps).addTo(mapObject);
	var schoolTypes = {
		"Middle": imagery,
		"Elementary": osm
	}
	

	// default polyline styles. additional options listed here:
	// http://leafletjs.com/reference.html#path-options
	var bike_route_options = {
		color: 'forestgreen',
		weight: 10,
		opacity: 0.1
	}
	console.log(bike_route_options);
	// iterates over routes from routes.js bike_routes and 
	// adds them to map.
	_.forEach(bike_routes, function(route){
		//var routeLine = L.polyline(route, bike_route_options);
		var routeLine = L.polyline(route[1], route[0]);
		routeLine.addTo(mapObject);
	})

	// auto-zooms map to a level where all routes show simultaneously
	//mapObject.fitBounds(bike_routes);
	
	
});
