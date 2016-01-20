import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['row', 'columns', 'collapse'],
  
  // Services
  session: Ember.inject.service('session'),

  // Form State
  isValid: Ember.computed.and('loginValueValid', 'passwordValueValid', 'passwordConfirmationValueValid'),

  // Form Values
  loginValue: '',
  loginValueValid: Ember.computed.match('loginValue', /^[\x20-\x7F]{7,255}$/),
  passwordValue: '',
  passwordValueValid: Ember.computed.match('passwordValue', /^[\x20-\x7F]{7,50}$/),
  passwordConfirmationValue: '',
  passwordConfirmationValueValid: Ember.observer('passwordConfirmationValue', 'passwordValue', function(sender, key, value, rev) {
    return true;
  }),
  tosAccepted: false,
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
      console.log(this.get('loginValueValid'));
      console.log(this.get('passwordValueValid'));
      console.log(this.get('passwordConfirmationValueValid'));
    }
  },
});
