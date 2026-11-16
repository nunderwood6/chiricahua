<script>
	import { assets } from '$app/paths';
	import { onMount } from 'svelte';
	import * as maplibregl from 'maplibre-gl';
	import maplibreWorkerUrl from 'maplibre-gl/dist/maplibre-gl-worker.mjs?worker&url';
	 // Set the worker URL before mounting the map
	 maplibregl.setWorkerUrl(maplibreWorkerUrl);
	import 'maplibre-gl/dist/maplibre-gl.css';

	let map;

	////////////////////////////////////////////////////////////
	////// Adding image layers and geojsons for their bounds ///
	////////////////////////////////////////////////////////////

	// Define your non-geographic image dimensions in pixels (must be <90 so I divided by 1000)
	const backgroundWidth = 3.750;
	const backgroundHeight = 2.250;

	// Map top-left, top-right, bottom-right, bottom-left to pseudo-coordinates [lng, lat]
	const backgroundBounds = [
	    [0, backgroundHeight],        // top-left [x, y] -> treated as [lng, lat]
	    [backgroundWidth, backgroundHeight], // top-right
	    [backgroundWidth, 0],         // bottom-right
	    [0, 0]                 // bottom-left
	];

	const boundsGeojson = {
		  type: 'geojson',
		  data: {
		    type: 'Feature',
		    geometry: {
		      type: 'Polygon',
		      coordinates: [[
		        backgroundBounds[3], // SW
		        backgroundBounds[2],  // SE
		        backgroundBounds[1],   // NE
		        backgroundBounds[0],  // NW
		        backgroundBounds[3]  // Close polygon
		      ]]
		    }
		  }
	}

	////// second area to zoom to ///////////////
	const detailLeft = 0.921
	const detailTop = .307;
	const detailWidth = 1.008;
	const detailHeight = 0.973;

	// y values are from top/left, so need to use base image height to calculate y values here
	const detailBounds = [
	    [detailLeft, backgroundHeight-detailTop],        // top-left [x, y] -> treated as [lng, lat]
	    [detailLeft+detailWidth, backgroundHeight-detailTop], // top-right
	    [detailLeft+detailWidth, backgroundHeight-detailTop-detailHeight],     // bottom-right
	    [detailLeft, backgroundHeight-detailTop-detailHeight]                 // bottom-left
	];

	const detailGeojson = {
		  type: 'geojson',
		  data: {
		    type: 'Feature',
		    geometry: {
		      type: 'Polygon',
		      coordinates: [[
		        detailBounds[3], // SW
		        detailBounds[2],  // SE
		        detailBounds[1],   // NE
		        detailBounds[0],  // NW
		        detailBounds[3]  // Close polygon
		      ]]
		    }
		  }
	}


	/////////// setup map
	const style = {
	            version: 8,
		         projection: {type: 'identity'},
	            sources: {
	              maplibre: {
	                url: "https://demotiles.maplibre.org/tiles/tiles.json",
	                type: "vector",
	              }
	            },
	            layers: [
	              {
	                id: "background",
	                type: "background",
	                paint: {
	                  "background-color": "#fff",
	                },
	              }]
	};

	onMount(() => {

		map = new maplibregl.Map({
			  container: 'map',
			  style,
			  bounds: [backgroundBounds[3],backgroundBounds[1]],
			  // maxBounds: [backgroundBounds[3],backgroundBounds[1]],
			  // maxZoom: 7,
			  interactive: false,
			  scrollZoom: false,
			  maplibreLogo: false,
			  attributionControl: false
			});

		// // Add zoom controls to the map.
		// map.addControl(new maplibregl.NavigationControl({
		//     showZoom: true,
		//     showCompass: false
		// }));

		map.on('load', () => {
		    // Add the image source using the pseudo-geographic corner coordinates
		    map.addSource('non-geo-image', {
		        type: 'image',
		        url: `${assets}/chiricahua.jpg`,
		        coordinates: backgroundBounds
		    });

		    // Add a raster layer to display the image source
		    map.addLayer({
		        id: 'image-layer',
		        type: 'raster',
		        source: 'non-geo-image',
		        paint: {
		            'raster-fade-duration': 0
		        }
		    });

		    map.addSource("bbox", boundsGeojson);

		    map.addLayer({
		      id: 'bbox-outline',
		      type: 'line',
		      source: 'bbox',
		      paint: {
		        'line-color': '#ff0000',
		        'line-width': 2
		      }
		    });

		    map.addSource("detail-bbox", detailGeojson);

		    map.addLayer({
		      id: 'detail-bbox-outline',
		      type: 'line',
		      source: 'detail-bbox',
		      paint: {
		        'line-color': '#ff0000',
		        'line-width': 2
		      }
		    });

		    // // zoom to image
		    map.fitBounds([backgroundBounds[3],backgroundBounds[1]],{ duration: 0 });

		    // setTimeout(function(){
		    // 	 map.fitBounds([detailBounds[3],detailBounds[1]]);
		    // },1000)



		});

	});

</script>


<div class="map-container">
	
	<div id="map"></div>


</div>


<style>
	
	div.map-container {
		width: 100%;
		height: 100%;
		background-color: #eee;
	}

	div#map {
		width: 100%;
		height: 100lvh;
	}


</style>