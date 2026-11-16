<script>

	import { untrack } from 'svelte';
	import { tick } from 'svelte';
	import { onMount } from "svelte";
	import { assets } from '$app/paths';
	let { url, index, stepIndex, progress , slide, focus=null, contain=null, background=null } = $props();
	let mounted;
	let isIntersecting = false;
	let myElement;

	onMount(() => {
	   mounted = true;
	   
	});



</script>
	
	{#if focus}
		<div class="outer">
			<div class="focus-container"
					 style="height: {focus.height}vw;
					 				max-width: {100/focus.height*100}vh;"
						>
			  <img
			  		bind:this={myElement}
			      class="background {stepIndex}"
			      src="{assets}/{url}"
			      style="width: {focus['background-width']}%;
			      			 left: {focus['background-left']}%;
			      			 top: {focus['background-top']}%;"
			    >
			  </div>
		 </div>
	{:else}
		<img
				bind:this={myElement}
		    class="{contain ? "contain": "backdrop"} {stepIndex}"
		    src="{assets}/{url}"
		  >

	 {/if}



  <style>

  	div.outer {
  		width: 100%;
  		height: 100svh;
  		display: flex;
  		align-items: center;
  		justify-content: center;
  		overflow: hidden; 
  	}

  	div.focus-container {
  		/* 1. Base width scales with the viewport width */
   		width: 100vw; 
   		/* 3. Caps height to prevent bottom overflow on tall screens */
   		max-height: 100vh; 
			position: relative;

  	}

  	div.focus-container img.background {
  		position: absolute;
  		height: auto;
  	}

  	img.backdrop {
  		object-fit: cover;
  		object-position: center center;
  	  overflow: hidden;
  	  top: 0px;
  	  left: 0px;
  	  position: absolute;
  	  width: 100vw;
  	  height: 100svh;
  	}


  	img.contain {
  		object-fit: contain;
  		overflow: hidden;
  	  top: 0;
  	  left: 0;
  	  position: absolute;
  	  width: 100vw;
  	  height: auto;
  	  top: 50%;
  	  left: 50%;
  	  transform: translate(-50%, -50%);
  	  max-height: 100%;

  	}

  </style>