<template>
  <div class="q-pa-md" style="max-width: 400px; height: 100%">
    <div class="column" style="height: 100%">
      <div class="col">
        <q-form
          @submit="onLogIn"
          class="q-gutter-md"
        >
          <p>Follow the provided link or manually enter the one-time-code to log in!</p>
          <q-input
            filled
            v-model="name"
            label="Your Email *"
            hint="The email address used when signing up for the account."
            lazy-rules
            :rules="[ val => val && val.length > 0 || 'Please type something']"
          />

          <div>
            <q-btn label="Log In" type="submit" color="primary"/>
          </div>
        </q-form>
      </div>
      <div class="col-1">
        <q-separator inset />
      </div>
      <div class="col">
        <p>Get started with passwordless authentication!</p>
        <q-form
          @submit="onSignUp"
          class="q-gutter-md"
        >
          <q-input
            filled
            v-model="nickname"
            label="Your nickname *"
            hint="How other players will know you. Can be changed later."
            lazy-rules
            :rules="[ val => val && val.length > 1 && val.length <= 30 || 'Must be 2 tp 30 characters in length.']"
          />

          <q-input
            filled
            type="number"
            v-model="email"
            label="Your email *"
            hint="Used for logging in and communication."
            lazy-rules
            :rules="[
            ]"
          />

          <q-toggle v-model="accept" label="I accept the license and terms" />

          <div>
            <q-btn label="Sign Up" type="submit" color="primary"/>
          </div>
        </q-form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'LoginOrSignupDrawer',
  data() {
    return {}
  }
}
</script>

<style>
</style>
