<script lang="ts">

  console.log("YUP")
  import type { ScrollerStep } from '../@types/global';

  interface Props {
    index: number;
    steps: ScrollerStep[];
    preload?: number;
    stackBackground?: boolean;
  }

  let { index, steps, preload = 1, stackBackground = true }: Props = $props();

  function showStep(i: number) {
    if (preload === 0) return true;
    if (stackBackground) return i >= 0;
    return i >= index - preload && i <= index + preload;
  }

  function isVisible(i: number) {
    if (stackBackground) return i <= index;
    return i === index;
  }
</script>

<div class="background-container">
{#each steps as step, i}
  {#if showStep(i)}
    <!-- different background types based on type -->
    <div
      class={`step-background step-${i + 1} w-full absolute`}
      class:visible={isVisible(i)}
      class:invisible={!isVisible(i)}
      style={`background: ${step.backgroundProps.colour};`}
    >
      
      <step.background {...step.backgroundProps || {}}>
      </step.background>
    </div>
  {/if}
{/each}
</div>

<style lang="scss">

  .background-container {
    width: 100%;
    height: 100svh;
    position: relative;
  }

  .step-background {

    width: 100%;
    height: 80svh;
    position: absolute;

    top: 50%;
    left: 50%;
    transform: translate(-50%, -50%);

    opacity: 0;
    will-change: opacity;
    transition: 0.35s opacity ease;

    &.visible {
      opacity: 1;
    }

    &.invisible {
      opacity: 0;
    }
  }



</style>
