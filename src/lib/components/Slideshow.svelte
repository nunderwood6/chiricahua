<script>
  import ScrollerBase from '$lib/components/ScrollerBase.svelte';

  // Optional: Bind your own variables to use them in your code.
  let count = $state(1);
  let index = $state(0);
  let offset = $state(0);
  let progress = $state(0);
  let top = $state(0.1);
  let threshold = $state(0.5);
  let bottom = $state(0.9);
</script>

<ScrollerBase
  {top}
  {threshold}
  {bottom}
  bind:count
  bind:index
  bind:offset
  bind:progress
  query="div.step-foreground-container"
>

{#snippet backgroundSnippet()}


    <!-- Add media item for each slide (photo, video, ai2html) -->
    <div class="background-container">
      <!-- for each slide include component based on type -->
      
      
    </div>


    <!-- For reference, examples of how to use binded variables -->
   <!-- <p class="mb-0">
      Current step: <strong>{index + 1}/{count}</strong>
    </p>
    <progress class="mb-4" value={(index + 1) / count}></progress>

    <p class="mb-0">Offset in current step</p>
    <progress class="mb-4" value={offset}></progress>

    <p class="mb-0">Total progress</p>
    <progress class="mb-4" value={progress}></progress>  -->


  {/snippet}
  {#snippet foregroundSnippet()}

    <!-- Add foreground text for each slide -->

    <!-- Add custom foreground HTML or component -->
    <div class="step-foreground-container">Step 1</div>
    <div class="step-foreground-container">Step 2</div>
    <div class="step-foreground-container">Step 3</div>
    <div class="step-foreground-container">Step 4</div>
    <div class="step-foreground-container">Step 5</div>
  {/snippet}
</ScrollerBase>


<style>

  .custom-background {
    width: 100%;
    height: 100svh;
    text-align: center;
  }

  .step-foreground-container {
    width: 50%;
    background-color: rgba(0, 0, 0, 0.2);
    padding: 1em;
    margin: 0 0 70svh 0;
    position: relative;
    left: 50%;
  }
</style>

