
<script>
  import { assets } from '$app/paths';
  // import components here
  import Lorem from '$lib/components/Lorem.svelte';
  // scrolling ai2html components
  import MapScroller from '$lib/components/MapScroller/Scroller.svelte';
  // import InteractiveMap from '$lib/components/InteractiveMap/InteractiveMap.svelte';
  import SlidesBackground from '$lib/components/Scroller/SlidesBackground.svelte';


  const steps = [];

  // // get content from google doc
  import doc from "../data/chiricahua-slides.json";

  // format slides for map scroller
  doc.slides.forEach(function(slide){

    steps.push({
      background: SlidesBackground,
      backgroundProps: {"slide": slide["slide"],
                        "type": slide.type,
                        "url": slide.url,
                        "sound": slide.sound,
                        "subtitles": slide.subtitles,
                        "focus": slide.focus,
                        "contain": slide.contain,
                        "background": slide.background,
                        "max-width": slide["max-width"],
                        "height": slide["height"]
                      },
      foreground: slide.copy,
      foregroundProps: {"multiple": slide["multiple-foreground"]},
      altText: slide.altText
    });

  });

</script>

<!-- This sets the page title in the browser tab -->
<svelte:head>
</svelte:head>



<!-- Your page content goes here -->
<div class="embedded-content"> 

<!-- <h1>Chiricahua scrolling map</h1> -->

<Lorem count=1 />

<!-- first develop MapLibre component -->
<!-- <InteractiveMap /> -->

<MapScroller {steps} foregroundPosition="middle" backgroundWidth="fluid" threshold="0.9" stackBackground={true}/>

<Lorem count=2 />


</div>


<style>
 h1,h2 {
  text-align: center;
 }

 :global(svelte-scroller-foreground) {
  pointer-events: none;
 }

</style>