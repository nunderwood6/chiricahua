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
      <!-- if single/default -->
      {#if !step.foregroundProps.multiple}
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
      <!-- if multiple foregrounds -->
      {:else}
        <!-- foreground container step for each block in copy-->
        {#each step.foreground as copy, j}
        <!-- make first one the same (trigger changes) -->
          {#if j === 0}
         <div
           class="step-foreground-container step-{i +
             1} mb-20 h-screen flex items-center justify-center"
         >
             <div class="step-foreground w-full">
               <Markdown source={copy} />
             </div>
         </div>
          {:else}
          <div
            class="step-foreground-container-empty step-{i +
              1 + `_${j}`} mb-20 h-screen flex items-center justify-center"
          >
              <div class="step-foreground w-full">
                <p>
                {@html copy}
                </p>
              </div>
          </div>
          {/if}
        {/each}
      {/if}

  {/each}
</div>

<style lang="scss">

div.foreground {
  pointer-events: none;
}

 div.foreground-wrapper {
  padding-top: 80vh;
  padding-bottom: 40vh;
  margin: 0 5px;
  display: flex;
    flex-direction: column;
 }

  div.step-foreground-container,div.step-foreground-container-empty {
    margin: 0 20px;
  }

  :global(input[type="checkbox"].sound) {
    accent-color: #555 !important;
    width: 20px;
    height: 20px;
    vertical-align: middle;
    cursor: pointer;
    margin-left: 5px !important;
  }


  div.step-foreground {
    pointer-events: auto;
    font-size: 18px;
    color: #fff;
    border-radius: 0.25rem;
    margin: 5vh auto 70vh;
    padding: 5px 15px;
    background: rgba(0,0,0, 0.9);
    max-width: 550px;
    box-shadow: 0 5px 5px rgba(0,0,0,0.3);

  }


/* 
  @media (min-width: 850px) {
       div.step-foreground {
          max-width: 37vw;
          margin: 5vh 20px 80vh;
          float: right;
          font-size: 20px;
        } 
    }

*/

  

  .visually-hidden {
    display: none;
  }



</style>
