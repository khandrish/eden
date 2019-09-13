<template>
  <q-form
    @submit="onSubmit"
    class="q-gutter-md"
    ref="form"
  >
    <p>Start adventuring today!</p>
    <q-input
      filled
      v-model="nickname"
      label="Nickname *"
      hint="What everyone else sees. Can be changed later."
      :rules="[ val => val && val.length > 1 && val.length <= 30 || 'Must be 2 to 30 characters in length.']"
    />

    <q-input
      filled
      type="email"
      v-model="email"
      label="Email address *"
      hint="Used for logging in and communication."
      :rules="[ validate_email ]"
    />

    <q-toggle
      v-model="tos"
      label="I accept the TOS"
      color="green"
    />

    <div>
      <q-btn
        label="Sign Up"
        type="submit"
        color="primary"
        :disabled="formIsDisabled"
      />
    </div>
  </q-form>
</template>

<script>
export default {
  name: 'signup-form',
  data() {
    return {
      formIsDisabled: true,
      email: '',
      nickname: '',
      tos: false
    }
  },
  created: function() {
    this.$watchAll(['email', 'nickname', 'tos'], this.onStateChange)
  },
  computed: {
    isFormInvalid: function() {
      console.log('isFormInvalid')
      console.log(this)
      return true // this.errors.count() > 0 || !(Object.keys(this.fields).some(key => this.fields[key].dirty))
    }
  },
  methods: {
    onStateChange(event) {
      console.log('onStateChange')
      console.log(this)
      console.log(this.$refs.form)
      console.log(event)
      const self = this
      this.$refs.form.validate().then(success => {
        if (success) {
          // yay, models are correct
          console.log('validation passed')
          console.log(self)
        } else {
          console.log('validation failed')
          console.log(self)
          // oh no, user has filled in
          // at least an invalid value
        }
      })
    },
    onSubmit(event) {
      console.log('attempting signup')
      console.log(this.signup.email)
      console.log(this.signup.nickname)
      console.log(this.signup.tos)
      console.log(this)
      this.$validator.validate().then(valid => {
        if (valid) {
          console.log('valid')
        } else {
          console.log('invalid')
        }
      })
    },
    validate_email(email) {
      console.log('validate_email')
      console.log(email)
      return (/^.+@.+$/.test(email) && email.length > 2 && email.length < 256) || 'Email addresses are between 3 and 254 characters and contain an @ symbol.'
    }
  }
}
</script>

<style>
#seperator-container {
  display: flex;
  justify-content: center;
}
</style>
