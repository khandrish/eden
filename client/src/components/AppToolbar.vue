<template>
  <q-toolbar>
    <q-toolbar-title>
      <q-avatar>
        <img src="https://cdn.quasar.dev/logo/svg/quasar-logo.svg">
      </q-avatar>
      ExMUD
    </q-toolbar-title>

    <q-separator
      dark
      vertical
    />
    <q-btn
      stretch
      flat
      label="Dashboard"
      to="/dashboard"
    />
    <q-separator
      dark
      vertical
    />
    <q-btn
      stretch
      flat
      label="MUDs"
      to="/muds"
    />
    <q-separator
      dark
      vertical
    />
    <q-btn
      stretch
      flat
      label="Characters"
      to="/characters"
    />
    <q-separator
      dark
      vertical
    />
    <q-btn
      stretch
      flat
      label="Wiki"
    />
    <q-separator
      dark
      vertical
    />
    <q-btn
      stretch
      flat
      label="Store"
    />
    <q-separator
      dark
      vertical
    />
    <q-btn
      stretch
      flat
      label="Forums"
    />
    <q-separator
      dark
      vertical
    />
    <q-space />

    <template v-if="authenticated">
      <q-btn-dropdown
        rounded
        icon="fas fa-user"
      >
        <q-list>
          <q-item
            clickable
            v-close-popup
          >
            <div class="row no-wrap q-pa-md">
              <div class="column">
                <div class="text-h6 q-mb-md">Settings</div>
                <div class="text-h7 q-mb-md">Features</div>
                <q-toggle
                  v-model="developerFeatureOn"
                  label="Developer"
                >
                  <q-tooltip content-style="font-size: 12px">
                    Features related to MUD development. See Wiki for more info.
                  </q-tooltip>
                </q-toggle>
              </div>

              <q-separator
                vertical
                inset
                class="q-mx-lg"
              />

              <div class="column items-center">
                <q-avatar size="72px">
                  <img src="https://cdn.quasar.dev/img/boy-avatar.png">
                </q-avatar>

                <div class="text-subtitle1 q-mt-md q-mb-xs">John Doe</div>

                <q-btn
                  color="primary"
                  label="Logout"
                  push
                  size="sm"
                  @click="logout"
                  v-close-popup
                />
              </div>
            </div>
          </q-item>
        </q-list>
      </q-btn-dropdown>
    </template>
    <template v-else>
      <email-form />
    </template>

  </q-toolbar>
</template>

<script>
import EmailForm from '../components/EmailForm.vue'

export default {
  name: 'app-toolbar',
  mixins: [],
  components: { EmailForm },
  data() {
    return {
    }
  },
  computed: {
    authenticated() {
      return this.$store.getters['player/getIsAuthenticated']
    },
    developerFeatureOn: {
      set: function(value) {
        this.$store.dispatch('settings/setDeveloperFeatureOn', value)
      },
      get: function() {
        return this.$store.getters['settings/getDeveloperFeatureOn']
      }
    }
  },
  methods: {
    logout: function() {
      this.$store.dispatch('player/logout')
    }
  }
}
</script>

<style>
</style>
