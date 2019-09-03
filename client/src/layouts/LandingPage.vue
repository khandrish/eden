<template>
  <q-layout view="hHh lpR fFf">

    <q-header
      bordered
      class="bg-primary text-white"
    >
      <q-toolbar>
        <q-toolbar-title>
          <q-avatar>
            <img src="https://cdn.quasar.dev/logo/svg/quasar-logo.svg">
          </q-avatar>
          Title
        </q-toolbar-title>

        <q-btn
          dense
          flat
          round
          icon="menu"
          @click="right = !right"
        />
      </q-toolbar>
    </q-header>

    <q-drawer
      v-model="right"
      side="right"
      overlay
      bordered
    >
      <!-- drawer content -->
      <loginOrSignupDrawer></loginOrSignupDrawer>
    </q-drawer>

    <q-page-container>
      <router-view />
    </q-page-container>

  </q-layout>
</template>

<script>
import { openURL } from 'quasar'
import loginOrSignupDrawer from '../components/LoginOrSignupDrawer.vue'

export default {
  name: 'LandingPage',
  components: {
    loginOrSignupDrawer
  },
  data() {
    return {
      right: false
    }
  },
  methods: {
    openURL
  }
}
</script>

<style>
</style>
