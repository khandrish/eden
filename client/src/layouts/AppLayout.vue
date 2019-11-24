<template>
  <q-layout view="hHh LpR fFf">

    <q-header
      bordered
      class="bg-primary text-white"
    >
      <app-toolbar />
    </q-header>

    <q-drawer
      show-if-above
      v-model="left"
      side="left"
      behavior="desktop"
      bordered
    >
      <!-- drawer content -->
      <app-left-drawer-nav />
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>

  </q-layout>
</template>

<script>
import { openURL } from 'quasar'
import AppLeftDrawerNav from '../components/AppLeftDrawerNav'
import AppToolbar from '../components/AppToolbar'

export default {
  components: { AppLeftDrawerNav, AppToolbar },
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
