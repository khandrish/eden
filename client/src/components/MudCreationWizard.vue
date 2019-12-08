<template>
  <q-stepper
    v-model="step"
    alternative-labels
    header-nav
    ref="stepper"
    color="primary"
    animated
    vertical
  >
    <q-step
      :name="1"
      title="Name It"
      icon="fas fa-signature"
      :done="step > 1"
      :header-nav="step > 1"
    >
      <p>
        The slug is generated automatically from the name chosen for the MUD. The slug is used in urls when accessing
        resources and information linked to the MUD. For example, to view the live statistics for your MUD the url
        would be '/muds/{{ mudSlugUrlExample }}/stats'.
      </p>

      <q-input
        v-model="mudName"
        label="Name"
      />
      <q-input
        v-model="mudSlug"
        label="Slug"
        readonly
      />

      <q-inner-loading :showing="createMudRequestInProgress">
        <q-spinner-gears
          size="50px"
          color="primary"
        />
      </q-inner-loading>

      <q-stepper-navigation>
        <q-btn
          @click="createMud"
          color="primary"
          label="Create MUD"
          :disabled="createMudButtonDisabled"
        />
      </q-stepper-navigation>
    </q-step>

    <q-step
      :name="2"
      title="Describe It"
      icon="fas fa-book-open"
      :done="step > 2"
      :header-nav="step > 2"
    >
      <p>
        The description is the first place where you have the opportunity to set your MUD apart from the rest. Make it
        unique and meaningful to draw in players.
      </p>
      <q-editor
        v-model="mudDescription"
        min-height="5rem"
      />

      <q-stepper-navigation>
        <q-btn
          @click="addDescription"
          color="primary"
          label="Add Description"
          :disabled="addDescriptionButtonDisabled"
        />
      </q-stepper-navigation>
    </q-step>

    <q-step
      :name="3"
      title="Configure It"
      icon="fas fa-toggle-on"
      :done="step > 3"
      :header-nav="step > 3"
    >
      <div class="text-h6 q-mb-md">Settings</div>
      <div class="text-h7 q-mb-md">Features</div>
      <q-toggle
        v-model="mudMultiplayFeatureOn"
        label="Multiplaying Allowed"
      >
        <q-tooltip content-style="font-size: 12px">
          Allow a Player with multiple Characters to log into more than one Character at a time.
        </q-tooltip>
      </q-toggle>
      <q-item v-if="mudMultiplayFeatureOn">
        <q-item-section avatar>
          <q-icon name="fas fa-users" />
        </q-item-section>
        <q-item-section>
          <q-slider
            v-model="mudMultiplayMaxAllowedCharacters"
            :min="2"
            :max="5"
            :step="1"
            snap
            label
            label-always
          />
        </q-item-section>
        <q-tooltip content-style="font-size: 12px">
          The maximum number of Characters that can be logged into at one time.
        </q-tooltip>
      </q-item>
    </q-step>
  </q-stepper>
</template>

<script>
import _ from 'lodash'
import { Notify } from 'quasar'
import saveState from 'vue-save-state'

export default {
  mixins: [saveState],
  name: 'MudCreationWizard',
  components: {
  },
  data() {
    return {
      mud: null,

      // MUD creation/wizard related stuff
      addDescriptionButtonDisabled: false,
      createMudButtonDisabled: true,
      createMudRequestInProgress: false,
      mudDescription: '',
      mudName: '',
      mudSlug: '',
      mudSlugUrlExample: 'placeholder-slug',
      step: 1,

      // Feature related stuff
      mudMultiplayFeatureOn: false,
      mudMultiplayMaxAllowedCharacters: 2
    }
  },
  computed: {
  },
  validations: {
  },
  methods: {
    getSaveStateConfig() {
      return {
        'cacheKey': 'MudCreationWizard'
      }
    },
    checkNameAndGetSlug: _.debounce(function() {
      if (this.mudName === '' || this.mudName.length < 2) {
        this.mudSlug = ''
        this.mudSlugUrlExample = 'placeholder-slug'
        this.createMudButtonDisabled = true
      } else {
        const nameToSubmit = this.mudName
        const self = this

        this.$axios.post('/muds/checkNameAndGetSlug', {
          name: nameToSubmit
        })
          .then(function(response) {
            self.mudSlug = self.mudSlugUrlExample = response.data.data.slug
            self.createMudButtonDisabled = false
          })
          .catch(function(error) {
            if (error.response.status === 409) {
              self.createMudButtonDisabled = true

              Notify.create({
                message: 'Name/Slug already taken for: ' + nameToSubmit
              })
            }
          })
      }
    }, 500),
    addDescription: function() {
      const self = this
      this.addDescriptionRequestInProgress = true

      this.$axios.post('/muds/update', {
        id: this.mud.id,
        attributes: {
          description: this.mudDescription
        }
      })
        .then(function(response) {
          Notify.create({
            message: 'Description has been added to your mud: ' + self.mud.name
          })

          self.step = 3
        })
        .catch(function(_error) {
          Notify.create({
            message: 'Unexpected error encountered when creating MUD. If error persists please contact support.'
          })
        })
        .finally(function() {
          self.addDescriptionRequestInProgress = false
        })
    },
    createMud: function() {
      const self = this
      this.createMudRequestInProgress = true

      this.$axios.post('/muds/create', {
        name: this.mudName
      })
        .then(function(response) {
          Notify.create({
            message: 'Your MUD has been successfully created!'
          })

          self.mud = response.data.data
          self.step = 2
        })
        .catch(function(error) {
          if (error.response && error.response.status === 409) {
            Notify.create({
              message: 'Name/Slug already taken for: ' + self.mudName
            })
          } else {
            Notify.create({
              message: 'Unexpected error encountered when creating MUD. If error persists please contact support.'
            })
          }
        })
        .finally(function() {
          self.createMudRequestInProgress = false
        })
    }
  },
  watch: {
    mudName: function(val) {
      this.checkNameAndGetSlug()
    }
  }
}
</script>

<style>
</style>
