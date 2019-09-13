<template>
  <q-page class="flex flex-center">
    <div class="row">
      <div class="col">
        <login-form></login-form>
      </div>
      <div class="col-1">
        <q-separator
          vertical
          inset
        />
      </div>
      <div class="col">
        <signup-form></signup-form>
      </div>
    </div>
  </q-page>
</template>

<style>
</style>

<script>
import LoginForm from '../components/LoginForm.vue'
import SignupForm from '../components/SignupForm.vue'

export default {
  // name: 'RegistryPage',
  components: { 'login-form': LoginForm, 'signup-form': SignupForm }
}
</script>
