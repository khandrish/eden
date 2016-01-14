import Ember from 'ember';

export default Ember.Component.extend({
  // Services
  session: Ember.inject.service('session'),

  // Form Values
  loginValue: '',
  isLoginValueValid: function() {
    console.log('isLoginValueValid');
    console.log(this.get('loginValue'));
    return /^[\x20-\x7F]{7,255}$/.test(this.get('loginValue'));
  }.property('loginValue'),
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
      console.log(this.get('loginValue'));
    }
  },
});
