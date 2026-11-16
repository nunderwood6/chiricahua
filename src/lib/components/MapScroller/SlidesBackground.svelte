<script lang="ts">

  import { untrack } from 'svelte';
  import { tick } from 'svelte';
  import type { ScrollerStep } from '../@types/global';
  import Photo from "./Photo.svelte";
  import Ai2htmlGraphic from "./Ai2htmlGraphic.svelte";
  import Video from "./Video.svelte";
  import { assets } from '$app/paths';

  // scrolling video
  import ScrollerVideo from '$lib/reuters/ScrollerVideo/ScrollerVideo.svelte';

  let mounted;
  import { onMount } from "svelte";

  let stepElements;
  let hint;
  let muted = $state(true);
  let imgSrc = $state(`${assets}/volume_off_24dp_E3E3E3.svg`);
  let checkbox;

  let toggleMuted = function(fromCheckbox){
    muted = !muted;
    imgSrc = muted ? `${assets}/volume_off_24dp_E3E3E3.svg` : `${assets}/volume_up_24dp_E3E3E3.svg`;
    updateVideos();
    // and hide hint
    hint = document.querySelector("p.hint");
    if(hint){
      hint.style.display = "none";
    }
    // switch checkbox too
    if(fromCheckbox != "checkbox"){
      checkbox.checked = !checkbox.checked;
    }
  }

  onMount(() => {
     mounted = true;
     checkbox = document.querySelector("input.sound");
     if(checkbox){
      checkbox.addEventListener("click", () => {
        toggleMuted("checkbox");
      })
     }
  });

  interface Props {
    index: number;
    steps: ScrollerStep[];
    preload?: number;
    stackBackground?: boolean;
    progress?: number;
    imgSrc: string;
  }

  let { index, steps, preload = 1, stackBackground = true, progress, offset }: Props = $props();

  let sequenceActive = $derived(progress > 0 && progress < 1);

  function showStep(i: number) {
    if (preload === 0) return true;
    if (stackBackground) return i >= 0;
    return i >= index - preload && i <= index + preload;
  }

  function isVisible(i: number) {
    if (stackBackground) return i <= index;
    return i === index;
  }

  function isCurrent(i){
    return i === index;
  }

  let vidOffset = 0;

  function videoOffset(i,offset){
    if(i === index){
      vidOffset = offset;
      return offset;
    } else if (i > index){
      console.log("above");
      vidOffset = 0;
      return 0;
    } else {
      console.log("below");
      vidOffset = 1;
      return 1;
    }
  }


    function updateVideos(){
      stepElements = document.querySelectorAll(".step-background");


      if(!mounted) return;

      stepElements.forEach(function(stepElement){
        let video = stepElement.querySelector("video");

        if(!video){
          return;
        } else {
            if(stepElement.classList.contains("current") && sequenceActive){
              video.play();
              if(video.muted && !muted){
                video.muted = false;
              }  else {
                video.muted = true;
              }
            } else {
              video.pause();
               video.muted = true;
            }
        }
      });   
    }

  // use effect because it updates after DOM changes
  $effect(() => {
     untrack(() => {
      if(mounted && sequenceActive){
       updateVideos();
      }
     })
   });

  // turn sound off when sequence is not active
    $effect(() => {
        untrack(() => {
        // only do after page load
        if(mounted){
          updateVideos();
        }   
     })
   });

</script>

{#each steps as step, i}
   
  {#if showStep(i)}
    <!-- different background types based on type -->
    <div
      class={`step-background step-${i + 1} w-full absolute ${step.backgroundProps.slide}`}
      class:visible={isVisible(i)}
      class:invisible={!isVisible(i)}
      class:current={isCurrent(i)}
      style={step.backgroundProps.background ? "background: "+ step.backgroundProps.background +";" : ""}
    >

          <!-- various asset types -->
          {#if step.backgroundProps.type == "photo"}
          <Photo stepIndex={i}
                 url={step.backgroundProps.url}
                 {index}
                 {progress}
                 slide={step.backgroundProps.slide}
                 focus={step.backgroundProps.focus}
                 contain={step.backgroundProps.contain}
                 background={step.backgroundProps.background}
                 maxWidth={step.backgroundProps["max-width"]}
                  />
          {:else if step.backgroundProps.type == "ai2html"}
           <Ai2htmlGraphic graphic={step.backgroundProps.url}
                           focus={step.backgroundProps.focus}
                           background={step.backgroundProps.background}
                           contain={step.backgroundProps.contain}
                           maxWidth={step.backgroundProps["max-width"]}
                           />
          {:else if step.backgroundProps.type == "scroll-video"}
          <div class="scroll-video-wrapper">
          <!-- Pass bindable prop `progress` as `videoPercentage` and set `trackScroll` to `false` -->
              <ScrollerVideo
                src={step.backgroundProps.url}
                videoPercentage={videoOffset(i,offset)}
                height="100lvh"
                trackScroll={false}
                debug={false}
                objectFit="contain"
                autoplay={false}
                class="sequence-scroller-container"
                id="impervious-sequence"
              />
            </div>
          {:else if step.backgroundProps.type == "video"}
            <Video stepIndex={i} url={step.backgroundProps.url} {index} {progress} {muted} {imgSrc} {toggleMuted} sound={step.backgroundProps.sound} slide={step.backgroundProps.slide} subtitles={step.backgroundProps.subtitles}/>
          {:else if step.backgroundProps.type == "blank"}
            <div class="empty"></div>
          {/if}

    </div>
  {/if}
{/each}

<style lang="scss">


  .step-background {

    pointer-events: auto;
    width: 100%;
    height: 100svh;
    position: absolute;
    overflow: clip;


/*
    @media (min-width: 850px) {
      width: 55vw;
      max-width: 1000px;
      margin-left: 50px;
    }
*/


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

  .scroll-video-wrapper {
    background-color: #222;
    width: 100vw;
  }

/*
  :global(.step-background.police video) {
    max-width: 800px;
  }


  */



</style>
