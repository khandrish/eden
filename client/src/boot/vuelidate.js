import Vue from 'vue'
import vuelidate from 'vuelidate'
import vuelidateErrorExtractor, { templates } from 'vuelidate-error-extractor'

Vue.use(vuelidate)
Vue.use(vuelidateErrorExtractor, {
  template: templates.singleErrorExtractor.foundation6,
  messages: { required: 'The {attribute} field is required' }, // error messages to use
  attributes: { // maps form keys to actual field names
    email: 'Email',
    nickname: 'Nickname'
  }
})
