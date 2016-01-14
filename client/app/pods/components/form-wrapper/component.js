import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'form',
  form: undefined,
  isValid: false,
  isInvalid: Ember.computed('isValid', function() {return !this.get('isValid');}),
  actions: {
    cancel: function() {
      this.get('onCancel')();
    },
    formValidityChanged: function(newValue) {
      this.set('isValid', newValue);
    },
    submit: function() {
      var inputs = this.$(':input[name]');
      var values = {};

      inputs.each(function() {
        switch(this.type) {
          case 'checkbox':
            values[this.name] = this.checked;
            break;
          case 'text':
          case 'password':
          case 'select':
            values[this.name] = this.value;
            break;
          case 'radio':
            if(this.checked) {
              values[this.name] = this.value;
            }
            break;
        }
      });

      this.get('onSubmit')(values);
    }
  }
});
