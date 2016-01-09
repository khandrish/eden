import Ember from 'ember';
import $ from 'jquery'

export default Ember.Component.extend({
	session: Ember.inject.service('session'),
	didInsertElement: function() {
    Ember.run.scheduleOnce("afterRender", function() {
     	Ember.$(document).foundation();
    });
  }
});
