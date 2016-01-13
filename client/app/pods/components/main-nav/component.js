import Ember from 'ember';

export default Ember.Component.extend({
  session: Ember.inject.service('session'),
  actions: {
    closeRegistrationModal: function() {
      Ember.$('#registration_modal').foundation('close');
    },
    showRegistrationModal: function() {
      Ember.$('#registration_modal').foundation('open');
    },
    logout : function() {
      this.get('session').invalidate();
    }
  },

  didInsertElement: function() {
    Ember.run.scheduleOnce("afterRender", function() {
      Ember.$(document).foundation();
    });
  }
});