import Ember from 'ember';

export default Ember.Component.extend({
  session: Ember.inject.service('session'),
  actions: {
    cancel: function() {
      this.get('cancel')();
    },
    registerNewPlayer: function(params) {
      this.get('confirm')();
    }
  }
});
