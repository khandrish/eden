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
          type="token"
          v-model="form.token"
          label="Auth Token *"
          hint="One time use token sent to your email address."
        >
          <template v-slot:prepend>
            <q-icon name="fas fa-key" />
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
import { helpers, required } from 'vuelidate/lib/validators'
import { templates } from 'vuelidate-error-extractor'

const tokenRegex = helpers.regex('token', /^[0-9a-f]{12}4[0-9a-f]{3}[89ab][0-9a-f]{15}$/)

export default {
  name: 'token-form',
  mixins: [validationMixin],
  components: {
    FormWrapper: templates.FormWrapper
  },
  data() {
    return {
      form: {
        token: ''
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
      token: {
        required,
        tokenRegex
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

        this.$axios.post('/authenticate/token', {
          token: this.form.token
        })
          .then(function(response) {
            this.submitStatus = 'OK'
          })
          .catch(function(_error) {
            this.submitStatus = 'ERROR'
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
