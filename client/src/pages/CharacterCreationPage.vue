<template>
  <q-page class="flex flex-center">
    <character-creation-wizard />
  </q-page>
</template>

<style>
</style>

<script>
import CharacterCreationWizard from '../components/CharacterCreationWizard.vue'

export default {
  name: 'CharacterCreationPage',
  components: { CharacterCreationWizard }
}
</script>
