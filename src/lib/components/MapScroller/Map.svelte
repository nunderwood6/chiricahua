<script>
	import { assets } from '$app/paths';
	import { onMount } from 'svelte';
	import { debounce } from 'lodash-es';
	import * as maplibregl from 'maplibre-gl';
	import maplibreWorkerUrl from 'maplibre-gl/dist/maplibre-gl-worker.mjs?worker&url';
	 // Set the worker URL before mounting the map
	 maplibregl.setWorkerUrl(maplibreWorkerUrl);
	import 'maplibre-gl/dist/maplibre-gl.css';

	import { Protocol } from 'pmtiles';
	let protocol = new Protocol();
	maplibregl.addProtocol('pmtiles', protocol.tile);

	let { index, steps, progress, offset } = $props();

	// resize logic for both inner/outer width so it fires web inspector opens/closes
	let innerWidth = $state(0);
	let outerWidth = $state(0);

	$effect(() => {
		console.log('inner width: ', innerWidth);
		console.log('outer width: ', outerWidth);
	    handleResize();
	  });

	function mapVisible(index) {
	  // check if current step is map
	  // console.log(steps[index]);
	  let isMap = steps[index].backgroundProps.type === "map";
	  return isMap;
	}

	let map;
	let mapBounds;

	////////////////////////////////////////////////////////////
	////// Set up for pmtiles //////////////////////////////////
	////////////////////////////////////////////////////////////

	let pmtilesUrl = `https://pub-b73f484c2fd14f749f91dbdd558a3bdf.r2.dev/chiricahua/chiricahua.pmtiles`;

	// 2. Calculate bounds in MapLibre's [-90, 90] identity space
	// Since the image was anchored at top-left (0,0) of a 4096x4096 canvas:
	const origWidth = 3750;
	const origHeight = 2250;
	const canvasSize = 4096; // padded so it's square
	const backgroundSize = [origWidth,origHeight];

	const maxLng = -90 + (origWidth / canvasSize) * 180;
	const minLat = 90 - (origHeight / canvasSize) * 180;

	const backgroundBounds = [-90, minLat, maxLng, 90];
	const backgroundFitBounds = [[backgroundBounds[0],backgroundBounds[1]],
								[backgroundBounds[2],backgroundBounds[3]]];

	// calculate detail bounds
	const detailLeft = 921
	const detailTop = 307;
	const detailWidth = 1008;
	const detailHeight = 973;

	const detailBounds = [detailLeft,detailTop,detailLeft+detailWidth,detailTop+detailHeight]; // xMin,yMin,xMax,YMax
	const detailFitBounds = pixelBoundsToMapBounds(detailBounds,backgroundSize,backgroundBounds);


	function pixelBoundsToMapBounds(pixelBounds,backgroundSize,backgroundBounds){
		const [xMin, yMin, xMax, yMax] = pixelBounds;
		const [W, H] = backgroundSize;
		const [west, south, east, north] = backgroundBounds;

		const lngMin = west + (xMin / W) * (east - west);
		const lngMax = west + (xMax / W) * (east - west);
		const latMax = north - (yMin / H) * (north - south);
		const latMin = north - (yMax / H) * (north - south);

		return [
		    [lngMin, latMin], // Southwest corner
		    [lngMax, latMax]  // Northeast corner
		  ];
	}

	function boundsToClockwiseCorners(bounds) {

			  const [west, south, east, north] = bounds;

			  return [
			    [west, north], // Top-Left (North-West)
			    [east, north], // Top-Right (North-East)
			    [east, south], // Bottom-Right (South-East)
			    [west, south], // Bottom-Left (South-West)
			  ];
	}

	////////////////////////////////////////////////////////////
	////// baked labels ////////////////////////////////////////
	////////////////////////////////////////////////////////////

	// const bakedLabelsBounds = boundsToClockwiseCorners(backgroundBounds);

	////////////////////////////////////////////////////////////
	////// maplibre labels ////////////////////////////////////////
	////////////////////////////////////////////////////////////
	function pointCoordsToMapCoords(pointCoords){
		const [x,y] = pointCoords;
		const [W, H] = backgroundSize;
		const [west, south, east, north] = backgroundBounds;

		const lng = west + (x / W) * (east - west);
		const lat = north - (y / H) * (north - south);

		return [lng,lat];

	}

	const labelsGeojson = {
		  type: 'geojson',
		  data: {
		    type: 'FeatureCollection',
		    name: 'map-labels',
		    features: [
		    	{
		    		type: 'Feature',
		    		properties: {
		    			'label-name': "Visitor Center"
		    		},
		    		geometry: {
		    			coordinates: pointCoordsToMapCoords([1167,1085]),
		    			type: 'Point'
		    		}
		    	}
		    ]
		  
		  }
	}

	////////////////////////////////////////////////////////////
	////// Set up for image layers and geojsons w/ bounds ///
	////////////////////////////////////////////////////////////

	// // Define your non-geographic image dimensions in pixels (must be <90 so I divided by 1000)
	// const backgroundWidth = 3.750;
	// const backgroundHeight = 2.250;

	// // Map top-left, top-right, bottom-right, bottom-left to pseudo-coordinates [lng, lat]
	// const backgroundBounds = [
	//     [0, backgroundHeight],        // top-left [x, y] -> treated as [lng, lat]
	//     [backgroundWidth, backgroundHeight], // top-right
	//     [backgroundWidth, 0],         // bottom-right
	//     [0, 0]                 // bottom-left
	// ];

	// const boundsGeojson = {
	// 	  type: 'geojson',
	// 	  data: {
	// 	    type: 'Feature',
	// 	    geometry: {
	// 	      type: 'Polygon',
	// 	      coordinates: [[
	// 	        backgroundBounds[3], // SW
	// 	        backgroundBounds[2],  // SE
	// 	        backgroundBounds[1],   // NE
	// 	        backgroundBounds[0],  // NW
	// 	        backgroundBounds[3]  // Close polygon
	// 	      ]]
	// 	    }
	// 	  }
	// }

	// ////// second area to zoom to ///////////////
	// const detailLeft = 0.921
	// const detailTop = .307;
	// const detailWidth = 1.008;
	// const detailHeight = 0.973;

	// // y values are from top/left, so need to use base image height to calculate y values here
	// const detailBounds = [
	//     [detailLeft, backgroundHeight-detailTop],        // top-left [x, y] -> treated as [lng, lat]
	//     [detailLeft+detailWidth, backgroundHeight-detailTop], // top-right
	//     [detailLeft+detailWidth, backgroundHeight-detailTop-detailHeight],     // bottom-right
	//     [detailLeft, backgroundHeight-detailTop-detailHeight]                 // bottom-left
	// ];

	// const detailGeojson = {
	// 	  type: 'geojson',
	// 	  data: {
	// 	    type: 'Feature',
	// 	    geometry: {
	// 	      type: 'Polygon',
	// 	      coordinates: [[
	// 	        detailBounds[3], // SW
	// 	        detailBounds[2],  // SE
	// 	        detailBounds[1],   // NE
	// 	        detailBounds[0],  // NW
	// 	        detailBounds[3]  // Close polygon
	// 	      ]]
	// 	    }
	// 	  }
	// }

	const handleResize = debounce(
		() => {
			if (map && mapVisible(index)) {
				updateBounds();
			}
		},
		100,
		{ leading: true }
	);

	////////////////////////////////////////////////////////////
	////// Handling index changes //////////////////////////////
	////////////////////////////////////////////////////////////

	// bounds for various steps
	let bounds = {
		"opener": backgroundFitBounds,
		"detail": detailFitBounds
	}

	function updateBounds(){
		if(!map) return;
		if(!mapVisible(index)) return;

		let slideId = steps[index].backgroundProps.slide;
		mapBounds = bounds[slideId];
		map.fitBounds(mapBounds,{"duration": 1000});

	}

	// update map bounds
	$effect(() => {

		console.log("index is now ", index);
		// console.log("resized");
		// only update map if it exists and is currently visible
		if(!map) return;
		if(!mapVisible(index)) return;

		updateBounds();

	});


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
			  // glyphs: "https://demotiles.maplibre.org/font/{fontstack}/{range}.pbf",
			  style,
			  bounds: backgroundBounds,
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
		    
		    ////////////////////////////////////////////////////////////
		    ////// Add pmtiles w/ fake mercator instead ////////////
		    ////////////////////////////////////////////////////////////

			  map.addSource("background", {
		            type: "raster",
		            url: `pmtiles://${pmtilesUrl}`,
		            tileSize: 512,
		            bounds: [-90, minLat, maxLng, 90]
			  });

		      map.addLayer({
		          id: 'background-layer',
		          type: 'raster',
		          source: 'background',
		          paint: {
		              'raster-fade-duration': 0
		          }
		      });

		      // add maplibre labels
		      map.addSource("map-labels", labelsGeojson);

		      map.addLayer({
		      	id: 'point-map-labels',
		      	type: 'circle',
		      	source: 'map-labels',
		      	paint: {
		      		'circle-radius': 3,
		      		'circle-color': '#ffffff',
		      		'circle-opacity': 1
		      	}
		      });

		      map.addLayer({
		      	id: "map-labels-text",
		      	type: "symbol",
		      	source: "map-labels",
		      	layout: {
		      		'text-field': ['get', 'label-name'], // Get the 'name' property from each feature
		      		'text-font': ["Tiempos Text", "Georgia Bold", "serif"],
		      		'text-size': 14,
		      		"text-anchor": "top",
  					"text-offset": [0, 0.2] 
		      	},
		      	paint: {
		      		'text-color': '#ffffff',
		      		'text-halo-color': '#333333',
					'text-halo-width': 0.25,
					'text-halo-blur': 1
		      	}
		      });

		      // // add baked labels
		      // map.addSource('baked-labels', {
		      //     type: 'image',
		      //     url: `${assets}/baked-labels.png`,
		      //     coordinates: bakedLabelsBounds
		      // });

		      // // Add a raster layer to display the image source
		      // map.addLayer({
		      //     id: 'baked-labels',
		      //     type: 'raster',
		      //     source: 'baked-labels',
		      //     paint: {
		      //         'raster-fade-duration': 0
		      //     }
		      // });

		      // zoom to image
		      map.fitBounds(backgroundFitBounds,{ duration: 0 });


			////////////////////////////////////////////////////////////
		    ////// Images ////////////
		    ////////////////////////////////////////////////////////////

		    // // Add the image source using the pseudo-geographic corner coordinates
		    // map.addSource('non-geo-image', {
		    //     type: 'image',
		    //     url: `${assets}/chiricahua.jpg`,
		    //     coordinates: backgroundBounds
		    // });

		    // // Add a raster layer to display the image source
		    // map.addLayer({
		    //     id: 'image-layer',
		    //     type: 'raster',
		    //     source: 'non-geo-image',
		    //     paint: {
		    //         'raster-fade-duration': 0
		    //     }
		    // });

		    // // zoom to image
		    // map.fitBounds([backgroundBounds[3],backgroundBounds[1]],{ duration: 0 });

		    ////////////////////////////////////////////////////////////
		    ////// bounding boxes ////////////
		    ////////////////////////////////////////////////////////////


		    // map.addSource("bbox", boundsGeojson);

		    // map.addLayer({
		    //   id: 'bbox-outline',
		    //   type: 'line',
		    //   source: 'bbox',
		    //   paint: {
		    //     'line-color': '#ff0000',
		    //     'line-width': 2
		    //   }
		    // });

		    // map.addSource("detail-bbox", detailGeojson);

		    // map.addLayer({
		    //   id: 'detail-bbox-outline',
		    //   type: 'line',
		    //   source: 'detail-bbox',
		    //   paint: {
		    //     'line-color': '#ff0000',
		    //     'line-width': 2
		    //   }
		    // });


		    // setTimeout(function(){
		    // 	 map.fitBounds([detailBounds[3],detailBounds[1]]);
		    // },1000)



		});

	});

</script>


<div class="map-container" 
	 class:visible={mapVisible(index)}
	 class:invisible={!mapVisible(index)}
	 >
	
	<div id="map"></div>

</div>

<svelte:window bind:innerWidth bind:outerWidth />


<style>
	
	div.map-container {

		position: absolute;
		display: block;
		width: 100%;
		height: 100%;
		background-color: #eee;


		opacity: 0;
		will-change: opacity;
		transition: 0.35s opacity ease;

		&.visible {
		  opacity: 1;
		}

		&.invisible {
		  opacity: 0;
		  pointer-events: none;
		}
	}

	div#map {
		width: 100%;
		height: 100svh;
	}


</style>