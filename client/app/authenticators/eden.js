import Ember from 'ember';
import Base from 'ember-simple-auth/authenticators/base';

export default Base.extend({
  restore(data) {
    console.log('authenticator restore');
    return Ember.RSVP.reject();
  },

  authenticate(options) {
    console.log('authenticator authenticate');
    return new Ember.RSVP.Promise(function(resolve, reject) {
      
      // on success
      resolve({id: 1});

      // on failure
      // reject();
    });
  },

  invalidate(data) {
    console.log('authenticator invalidate');
    return Ember.RSVP.resolve();
  }
});
