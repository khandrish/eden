<template>
  <div>
    <form-wrapper :validator="$v.form">
      <q-form
        @submit="onSubmit"
        class="q-gutter-md"
        ref="form"
      >
        <p>Already have an account? Enter the email address used when signing up here!</p>
        <!-- <q-input
          filled
          v-model="form.email"
          label="Account email address *"
          hint="The email address used when signing up for the account."
          @input="checkValidationStatus"
        >
          <template v-slot:prepend>
            <q-icon name="mail" />
          </template>
        </q-input> -->

        <form-group name="email">
          <q-input
            filled
            type="email"
            v-model="form.email"
            label="Account email address *"
            hint="The email address used when signing up for the account."
            @input="checkValidationStatus"
          >
            <template v-slot:prepend>
              <q-icon name="mail" />
            </template>
          </q-input>
        </form-group>

        <div>
          <q-btn
            label="Log In"
            type="submit"
            color="primary"
            :disabled="formIsDisabled"
          />
        </div>
      </q-form>
    </form-wrapper>
  </div>
</template>

<script>
import { validationMixin } from 'vuelidate'
import { helpers, required, maxLength, minLength } from 'vuelidate/lib/validators'
import FormWrapper from 'vuelidate-error-extractor'

const emailRegex = helpers.regex('email', /^.+@.+$/)

export default {
  name: 'login-form',
  mixins: [validationMixin],
  components: {
    FormWrapper: FormWrapper
  },
  data() {
    return {
      form: {
        email: ''
      }
      // formIsDisabled: true
    }
  },
  validations: {
    form: {
      email: {
        required,
        minLength: minLength(3),
        maxLength: maxLength(254),
        emailRegex
      }
    }
  },
  computed: {
    formIsDisabled: function() {
      // `this` points to the vm instance
      console.log(this)
      return this.$v.$invalid
    }
  },
  methods: {
    checkValidationStatus(event) {
      console.log('checkValidationStatus')
      console.log(event)
      console.log(this.$v.$invalid)
      this.formIsDisabled = this.$v.$invalid
    },
    onSubmit(event) {
      console.log('attempting login')
      console.log(this)
      console.log(this.email)
      this.$refs.form.validate().then(success => {
        if (success) {
          // yay, models are correct
          console.log('validation passed')
        } else {
          console.log('validation failed')
          // oh no, user has filled in
          // at least an invalid value
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
