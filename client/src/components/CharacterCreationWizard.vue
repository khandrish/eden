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
      title="Select a MUD"
      icon="fas fa-dice-d20"
      :done="step > 1"
      :header-nav="step > 1"
    >
      The available options for creating a character depend on the active
      features and configuration of the selected MUD.

      <q-select
        v-model="selectedMud"
        :options="muds"
        label="MUD:"
      />
    </q-step>

    <q-step
      :name="2"
      title="Choose a Name"
      icon="create_new_folder"
      :done="step > 2"
      :header-nav="step > 2"
    >
      A Character name is only unique within a MUD instance.
    </q-step>

    <template v-slot:navigation>
      <q-stepper-navigation>
        <q-btn
          @click="$refs.stepper.next()"
          color="primary"
          :label="step === 2 ? 'Finish' : 'Continue'"
        />
        <q-btn
          v-if="step > 1"
          flat
          color="primary"
          @click="$refs.stepper.previous()"
          label="Back"
          class="q-ml-sm"
        />
      </q-stepper-navigation>
    </template>
  </q-stepper>
</template>

<script>
// import { validationMixin } from 'vuelidate'
// import { helpers, required } from 'vuelidate/lib/validators'

export default {
  name: 'CharacterCreationWizard',
  // mixins: [validationMixin],
  components: {
  },
  data() {
    return {
      step: 1,
      muds: [
        {
          label: 'Dragon Realms',
          value: 'dragon-realms',
          description: 'A place with adventure, and all that.',
          category: '1'
        }
      ],
      selectedMud: null
    }
  },
  computed: {
  },
  validations: {
  },
  methods: {
  }
}
</script>

<style>
#authFormWrapper {
  display: flex;
}
</style>
