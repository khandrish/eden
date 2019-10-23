<template>
  <q-page class="flex flex-center">
    <div class="row landing-page-row">
      <div class="col">
        <div class="col landing-page-content-column">
          <h1>
            Players
          </h1>
        </div>
        <div class="col landing-page-content-column">
          <q-btn-group rounded>
            <q-btn
              @click="openURL('http://github.com/mononym/exmud')"
              color="amber"
              rounded
              glossy
              icon="fas fa-question"
              label="What's this?"
            >
              <q-tooltip>New to MUD's? Think RP has something to do with engines rotating? Come figure it all out here.</q-tooltip>
            </q-btn>
            <q-btn
              @click="openURL('https://github.com/mononym/exmud/wiki')"
              color="amber"
              rounded
              glossy
              icon="fas fa-list"
              label="MUD list"
            >
              <q-tooltip>Check out the hosted MUD's and their live stats.</q-tooltip>
            </q-btn>
            <q-btn
              color="amber"
              rounded
              glossy
              icon="fas fa-comments"
              label="Forums"
              :to="{ name: 'registry' }"
            >
              <q-tooltip>Join the conversation, and please be polite.</q-tooltip>
            </q-btn>
          </q-btn-group>
        </div>
      </div>
      <div class="col">
        <div class="col landing-page-content-column">
          <h1>
            Developers, GM's, and Admins
          </h1>
        </div>
        <div class="col landing-page-content-column">
          <q-btn-group rounded>
            <q-btn
              @click="openURL('http://github.com/mononym/exmud')"
              color="amber"
              rounded
              glossy
              icon="fab fa-github"
              label="Github"
            >
              <q-tooltip>View the Open Source code on GitHub</q-tooltip>
            </q-btn>
            <q-btn
              @click="openURL('https://github.com/mononym/exmud/wiki')"
              color="amber"
              rounded
              glossy
              icon="fas fa-book"
              label="Guides"
            >
              <q-tooltip>Learn about the development and administration of MUDS in ExMUD</q-tooltip>
            </q-btn>
            <q-btn
              color="amber"
              rounded
              glossy
              icon="fas fa-user-shield"
              label="Authenticate"
              :to="{ name: 'registry' }"
            >
              <q-tooltip>Get started by creating or logging into a development account</q-tooltip>
            </q-btn>
          </q-btn-group>
        </div>
      </div>
    </div>
  </q-page>
</template>

<style>
</style>

<script>
import { openURL } from 'quasar'

export default {
  name: 'LandingPage',
  methods: {
    openURL
  }
}
</script>
