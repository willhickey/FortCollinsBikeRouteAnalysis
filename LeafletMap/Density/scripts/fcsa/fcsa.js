$('document').ready(function(){
	var mapObject = L.map('fscaMap').setView([40.585258, -105.084419], 13);	
	
	// uncomment additional layers from standardLayers
	// variable to display them.
	var streets = new L.esri.basemapLayer('Streets');
	streets.addTo(mapObject);

	L.geoJson(blockData).addTo(mapObject);

	console.log(bike_route_options);
	// iterates over routes from routes.js bike_routes and 
	// adds them to map.
	_.forEach(bike_routes, function(route){
		//var routeLine = L.polyline(route, bike_route_options);
		var routeLine = L.polyline(route[1], route[0]);
		routeLine.addTo(mapObject);
	})

	// auto-zooms map to a level where all routes show simultaneously
	mapObject.fitBounds(bike_routes);
});
