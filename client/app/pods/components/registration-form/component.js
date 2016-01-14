import Ember from 'ember';

export default Ember.Component.extend({
  // Services
  session: Ember.inject.service('session'),

  // Hooks
  onFormValidityChange: function() {},

  // Form State
  isFormValid: Ember.computed.and('isLoginValueValid', 'isPasswordValueValid', 'isPasswordConfirmationValueValid'),
  formValidityChanged: Ember.observer('isFormValid', function(sender, key, value, rev) {
    this.get('onFormValidityChange')(value);
  }),

  // Form Values
  loginValue: '',
  isLoginValueValid: Ember.computed.match('loginValue', /^[\x20-\x7F]{7,255}$/),
  passwordValue: '',
  isPasswordValueValid: Ember.computed.match('passwordValue', /^[\x20-\x7F]{7,50}$/),
  passwordConfirmationValue: '',
  isPasswordConfirmationValueValid: Ember.computed.equal('passwordConfirmationValue', 'passwordValue'),
  actions: {
    processRegistrationForm : function() {
      console.log('processing registration');
      var $inputs = $('#register_form :input');

        var values = {};
        $inputs.each(function() {
          if(this.name === "") {
          } else if(this.type && this.type === 'checkbox') {
            values[this.name] = this.checked;
          } else {
            values[this.name] = $(this).val();
          }
        });
        
        console.log(values);

        this.get('session').authenticate('authenticator:eden', values);
        $('#register_modal').foundation('reveal', 'close');

      return false;
    },
    logout : function() {
      this.get('session').invalidate();
    },
    validateLogin: function() {
      console.log('validateLogin');
    },
    printValue: function() {
      console.log(this.get('isLoginValueValid'));
    }
  },
});
