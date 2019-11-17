<template>
  <q-page class="flex flex-center">
    <div class="row landing-page-row">
      <div class="col">
        <div class="col landing-page-content-column">
          <h1>
            Either follow the link in the email or enter the token here to log in.
          </h1>
        </div>
        <div class="col landing-page-content-column">
          <token-form></token-form>
        </div>
      </div>
    </div>
  </q-page>
</template>

<style>
</style>

<script>
import TokenForm from '../components/TokenForm.vue'

export default {
  name: 'LandingPage',
  components: { 'token-form': TokenForm }
}
</script>
