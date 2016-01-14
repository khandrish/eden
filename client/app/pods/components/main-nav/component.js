import Ember from 'ember';

export default Ember.Component.extend({
  session: Ember.inject.service('session'),
  actions: {
    closeLoginModal: function() {
      Ember.$('#login_modal').foundation('close');
    },
    showLoginModal: function() {
      Ember.$('#login_modal').foundation('open');
    },
    closeRegistrationModal: function() {
      Ember.$('#registration_modal').foundation('close');
    },
    showRegistrationModal: function() {
      Ember.$('#registration_modal').foundation('open');
    },
    closeTosModal: function() {
      console.log('close tos modal');
      Ember.$('#tos_modal').foundation('close');
    },
    showTosModal: function() {
      Ember.$('#tos_modal').foundation('open');
    },
    invalidateSession: function() {
      this.get('session').invalidate();
    }
  },

  didInsertElement: function() {
    Ember.run.scheduleOnce("afterRender", function() {
      Ember.$(document).foundation();
    });
  }
});