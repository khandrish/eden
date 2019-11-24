<template>
  <div id="q-app">
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'app',
  preFetch({ store }) {
    store.dispatch('csrf/fetchCsrfToken')
    store.dispatch('player/loadPlayer')
  }
}
</script>

<style>
</style>
