<script>

  import { assets } from '$app/paths';

  let { graphic, fullHeight = false, focus=null, background=null, contain=null, maxWidth=null} = $props();

  let myElement;
	  
  let graphicHtml = $state('');
  
  // Dynamically load the HTML file as a raw string using Vite
  async function loadHtml(graphic) {
    try {
      const module = await import(`../graphics/${graphic}.html?raw`);
      graphicHtml = module.default.replaceAll("assetsPath", assets);
    } catch (e) {
      graphicHtml = '<p>File not found</p>';
    }
  }

  loadHtml(graphic);

</script>


	{#if focus}
			<div class="outer">
				<div class="focus-container"
						 style="height: {focus.height}vw;
						 				max-width: {100/focus.height*100}vh;">
						<!-- add background image if there is one -->
						<!-- {#if background}
						<img
									  		bind:this={myElement}
									      class="background"
									      src="{assets}/{background}"
									      style="width: {focus['background-width']}%;
									      			 left: {focus['background-left']}%;
									      			 top: {focus['background-top']}%;"
									    >
						{/if} -->
				  	<!-- Inject the raw HTML string into the DOM -->
				  	{@html graphicHtml}
				  </div>
			 </div>
		{:else}
			<div class="graphic-wrapper" class:fullHeight={fullHeight} class:contain={contain}>
			  	<div class="inner" class:fullHeight={fullHeight}
			  		style={maxWidth ? "max-width: "+ maxWidth +";" : ""}>
				<!-- Inject the raw HTML string into the DOM -->
				{@html graphicHtml}
				</div>
			</div>

		 {/if}


<style>

			div.graphic-wrapper.contain {
				width: 100vw;
				height: 100svh;
				justify-content: center;
				align-items: center;
				display: flex;
				background: #000;
			}

			div.graphic-wrapper.contain .inner {
				width: 100%;
				margin: 0 auto;

			}

/*			div.graphic-wrapper.contain .inner {
				flex-shrink: 0;
				min-width: 100%;
				min-height: 100%;
			}*/

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

	.graphic-wrapper.fullHeight {
		display: flex;
		justify-content: center;
		align-items: center;
		overflow: hidden;


		width: 100vw;
/*		max-width: 1300px;*/
		height: 100svh;
		max-height: 900px;

	}

	@media screen and (min-width: 750px) {
			.graphic-wrapper.fullHeight {
				max-height: 800px;

			}

	}

	@media screen and (min-width: 850px) {
			.graphic-wrapper.fullHeight {
				max-height: 1000px;

			}

	}

	@media screen and (min-width: 900px) {
			.graphic-wrapper.fullHeight {
				max-height: 1200px;

			}

	}

	.inner.fullHeight {
		flex-shrink: 0;
		min-width: 100%;
		min-height: 100%;
		

	}

</style>



