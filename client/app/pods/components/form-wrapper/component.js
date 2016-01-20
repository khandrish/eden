import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['columns', 'row'],

  // Form state
  inputs: {},
  isValid: false,
  isInvalid: Ember.computed.not('isValid'),

  // Application Logic
  actions: {
    registerInput: function(name, getter) {
      this.set('inputs.'+name, getter);
    },
    cancel: function() {
      this.get('onCancel')();
    },
    submit: function(values) {
      var inputs = this.get('inputs');
      var values = {};
      for (var key in inputs) {
        values[key] = inputs[key]();
      }
      this.get('onSubmit')(values);
    }
  }
});
