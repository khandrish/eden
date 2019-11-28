<template>
  <q-layout view="hHh lpR fFf">

    <q-header
      bordered
      class="bg-primary text-white"
    >
      <app-toolbar />
    </q-header>

    <q-page-container>
      <router-view />
    </q-page-container>

  </q-layout>
</template>

<script>
import { openURL } from 'quasar'
import AppToolbar from '../components/AppToolbar'

export default {
  components: { AppToolbar },
  data() {
    return {
      left: false
    }
  },
  methods: {
    openURL
  }
}
</script>
