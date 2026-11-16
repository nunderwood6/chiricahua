<script lang="ts">
  import type { ScrollerStep } from '../@types/global';

  import { Markdown } from '@reuters-graphics/svelte-markdown';

  interface Props {
    steps: ScrollerStep[];
  }

  let { steps }: Props = $props();
</script>
<div class="foreground-wrapper">
  {#each steps as step, i}
      <div
        class="step-foreground-container step-{i +
          1} mb-20 h-screen flex items-center justify-center"
      >
        {#if step.foreground === '' || !step.foreground}
          <!-- Empty foreground -->
          <div class="empty-step-foreground"></div>
          {#if typeof step.altText === 'string'}
            <div class="background-alt-text visually-hidden">
              <Markdown source={step.altText} />
            </div>
          {/if}
        {:else}
          <div class="step-foreground w-full">
            {#if typeof step.foreground === 'string'}
              <Markdown source={step.foreground} />
            {:else}
              <step.foreground {...step.foregroundProps || {}}></step.foreground>
            {/if}
          </div>
          {#if typeof step.altText === 'string'}
            <div class="background-alt-text visually-hidden">
              <Markdown source={step.altText} />
            </div>
          {/if}
        {/if}
      </div>
  {/each}
</div>

<style lang="scss">
  @use './../../scss/mixins' as mixins;


 div.foreground-wrapper {
  padding-top: 40vh;
  padding-bottom: 40vh;
 }

  div.step-foreground-container {
    margin: 0 20px;
  }

  div.step-foreground {
    border-radius: 0.25rem;
    margin: 5vh auto 80vh;
    padding: 18px;
    background: rgba(255, 255, 255, 0.7);
    max-width: 650px;

  }



  .visually-hidden {
    display: none;
  }



</style>
