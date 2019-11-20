<template>
  <div class="relative-position">
    <form-wrapper :validator="$v.form">
      <q-form
        @submit="onSubmit"
        class="q-gutter-md"
        ref="form"
      >
        <q-input
          filled
          type="email"
          v-model="form.email"
          label="Email address *"
          hint="Used for logging in. Will not be shown."
        >
          <template v-slot:prepend>
            <q-icon name="mail" />
          </template>
        </q-input>

        <div>
          <q-btn
            label="Submit"
            type="submit"
            color="primary"
            :disabled="formIsDisabled"
          />
        </div>
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
  name: 'auth-form',
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
    onSubmit(event) {
      this.$v.$touch()
      if (this.$v.$invalid) {
        this.submitStatus = 'ERROR'
      } else {
        // do your submit logic here
        this.submitStatus = 'PENDING'
        const self = this

        this.$axios.post('/authenticate/email', {
          email: this.form.email
        }, {
          headers: {
            'x-csrf-token': this.$store.getters['csrf/getCsrfToken']
          }
        })
          .then(function(response) {
            self.$router.push({ path: '/authenticate' })
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
