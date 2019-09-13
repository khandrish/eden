<template>
  <q-layout view="hHh lpR fFf">

    <q-page-container>
      <router-view />
    </q-page-container>

  </q-layout>
</template>

<script>
import { openURL } from 'quasar'

export default {
  name: 'EmptyLayout',
  components: {
  },
  data() {
    return {
    }
  },
  methods: {
    openURL
  }
}
</script>

<style>
</style>
