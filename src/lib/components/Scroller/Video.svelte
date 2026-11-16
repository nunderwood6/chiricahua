<script>

	import { untrack } from 'svelte';
	import { tick } from 'svelte';
	import { onMount } from "svelte";
	import { assets } from '$app/paths';
	let { url, index, stepIndex, progress, isPlaying = $bindable(false), muted,imgSrc ,toggleMuted, sound, slide, subtitles } = $props();
	let mounted;
	let isIntersecting = false;
	let myElement;

	// let muted = true;
	// let imgSrc = "/volume_off_24dp_E3E3E3.svg";

	onMount(() => {
	   mounted = true;

	   // // // get video select

	   // // add observer to turn sound on/only once
	   // if(stepIndex == 0){
	   // 	soundOnWhenIntersecting();
	   // }
	   
	});


  function soundOnWhenIntersecting(){

  		const observerOptions = {
  		  root: null,         // Uses browser viewport as the checking container
  		  threshold: 0.8     // Triggers when 15% of the element is visible
  		};

  		const callback = (entries) => {
  	      entries.forEach(entry => {
  	        if (entry.isIntersecting) {
  	          let isIntersecting = true;
  	          soundToggle();
  	          // only fire once
  	          observer.unobserve(entry.target);
  	        } else {
  	        }
  	      });
  	    };

  	    const observer = new IntersectionObserver(callback,observerOptions);

  	    observer.observe(firstStep);

  }

</script>

  {#if !subtitles}
	<video
		bind:this={myElement}
	    src={url}
	    class="backdrop {stepIndex}"
	    muted
	    loop
	    playsinline
	  ></video>
  {:else}
	  <video
	  	bind:this={myElement}
	      class="backdrop {stepIndex}"
	      muted
	      loop
	      playsinline
	      crossorigin="anonymous"
	    >
	    	<source src={url} type="video/mp4" />
	    	<track src={`${assets}/${subtitles}`} label="English captions" default />

	    </video>
   {/if}

  {#if (slide == "facebook")}
  <p class="hint">Turn sound on/off <span class="arrow">→</span></p>
  {/if}

  <!-- add a mute/unmute control with each video if sound enabled-->
  {#if sound}
  <button class="sound" onclick={toggleMuted}>
  	<img src={imgSrc}>
  </button>
  {/if}

  <style>
  	video.backdrop {
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

  	video::cue {
  		font-size: 18px;
  		font-family: 'GT America', sans-serif;
  	}

  	@media (width <=500px){
  		video::cue {
  			font-size: 14px;
  		}
  	}

  	p.hint {
  		color: #eee;
  		background-color: rgba(0,0,0,0.5);
  		text-shadow: 0 2px rgba(0, 0, 0, 0.6);
  		font-size: 14px;
  		padding: 0px 10px 5px 5px;
  		border-radius: 5px;
  		position: absolute;
  		right: 105px;
  		top: 45px;

  		span.arrow {
  			display: inline-block;
  			font-size: 20px;
  			animation: moveBackAndForth 2s ease-in-out infinite alternate;
  		}
  	}

  	@keyframes moveBackAndForth {
  	  from {
  	    transform: translate(0,3px);
  	  }
  	  to {
  	    transform: translate(7px,3px);
  	  }
  	}

  	button.sound {
  		background-color: rgba(0,0,0,0.75);
  		cursor: pointer;
  		border: 0.5px solid rgba(255,255,255,0.5);
  		border: none;
  		position: absolute;
  		right: 50px;
  		top: 50px;
  		width: 50px;
  		height: 50px;
  		padding: 10px !important;
  		border-radius: 5px !important;

  		&:hover {
  			background-color: #111;
  			border: 0.5px solid rgba(255,255,255,0.5);
  		}

  		img {
  			width: 100%;
  		}

  	}





  </style>