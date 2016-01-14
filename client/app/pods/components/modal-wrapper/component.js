import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['reveal tiny'],
  attributeBindings: ['reveal:data-reveal', 'aria:aria-hidden', 'role'],
  reveal: true,
  aria: 'true',
  role: 'dialog',
  onCancel: function(){},
  onConfirm: function(){},
  actions: {
    cancel: function() {
      this.get('onCancel')();
    },
    confirm: function() {
      this.get('onConfirm')();
    }
  }
});
