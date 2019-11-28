<template>
  <q-tabs
    v-model="tab"
    vertical
    class="text-teal"
  >
    <q-tab
      name="quickActions"
      icon="fas fa-stopwatch"
      label="Quick Actions"
    />
  </q-tabs>
</template>

<script>

export default {
  name: 'app-left-drawer-nav',
  mixins: [],
  components: {
  },
  data() {
    return {
      tab: 'quickActions'
    }
  }
}
</script>

<style>
</style>
