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
  }
}
</script>

<style>
</style>
