<template>
  <q-page class="flex flex-center">
    <div class="row landing-page-row">
      <div class="col">
        <q-btn
          label="Create MUD"
          to="/muds/new"
        />
        <q-card
          dark
          bordered
          class="bg-grey-9 my-card"
        >
          <q-card-section>
            <div class="text-h6">Shadowrun Uprising</div>
          </q-card-section>

          <q-separator
            dark
            inset
          />

          <q-card-section>
            {{ lorem }}
          </q-card-section>
        </q-card>
      </div>
    </div>
  </q-page>
</template>

<style lang="sass">
</style>

<script>

export default {
  name: 'MudsPage',
  components: {},
  data() {
    return {
      lorem: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.'
    }
  }
}
</script>
