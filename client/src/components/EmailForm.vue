<template>
  <div class="relative-position">
    <form-wrapper :validator="$v.form">
      <q-form
        class="q-gutter-md"
        ref="form"
      >
        <q-input
          filled
          type="email"
          v-model="form.email"
          label="Email address *"
        >
          <q-tooltip content-style="font-size: 12px">
            The email is kept private.
          </q-tooltip>
          <template v-slot:prepend>
            <q-icon name="mail" />
          </template>
          <template v-slot:append>
            <q-btn
              label="Login or Signup"
              type="submit"
              color="primary"
              :disabled="formIsDisabled"
              @click="submit"
            />
          </template>
        </q-input>
      </q-form>
    </form-wrapper>
    <q-inner-loading :showing="requestInProgress">
      <q-spinner-gears
        size="50px"
        color="primary"
      />
    </q-inner-loading>
  </div>
</template>

<script>
import { validationMixin } from 'vuelidate'
import { helpers, required, maxLength, minLength } from 'vuelidate/lib/validators'
import { templates } from 'vuelidate-error-extractor'

const emailRegex = helpers.regex('email', /^.+@.+$/)

export default {
  name: 'email-form',
  mixins: [validationMixin],
  components: {
    FormWrapper: templates.FormWrapper
  },
  data() {
    return {
      form: {
        email: ''
      },
      submitStatus: 'WAITING'
    }
  },
  computed: {
    formIsDisabled() {
      return this.$v.$invalid
    },
    requestInProgress() {
      return this.submitStatus === 'PENDING'
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
  methods: {
    submit(event) {
      this.$v.$touch()
      if (this.$v.$invalid) {
        this.submitStatus = 'ERROR'
      } else {
        this.submitStatus = 'PENDING'
        const self = this

        this.$axios.post('/authenticate/email', {
          email: this.form.email
        })
          .then(function(response) {
            if (window.location.pathname === '/') {
              self.$router.push({ path: '/authenticate' })
            } else {
              self.$router.push({ path: '/authenticate', query: { referrer: window.location.pathname } })
            }
          })
          .catch(function(_error) {
            self.submitStatus = 'ERROR'
          })
      }
    }
  }
}
</script>

<style>
#authFormWrapper {
  display: flex;
}
</style>
