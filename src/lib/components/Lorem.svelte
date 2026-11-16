<script>
	let { count = 1 } = $props();
</script>


{#each { length: count } as _, i}


<p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
</p>

{/each}


<style>
	
	p {
		font-family: "Tiempos Text", "Georgia", "serif";
		font-size: 18px;
		max-width: 760px;
		margin: 2em auto;
		padding: 0 10px;

	}

	@media screen and (max-width: 500px) {
			p {
				padding: 0 10px;
			}

	}

</style>