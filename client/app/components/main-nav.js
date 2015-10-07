import Ember from 'ember';

export default Ember.Component.extend({
	actions: {
		processLoginForm : function() {
			console.log('processing login');
			var $inputs = $('#login_form :input');

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
    		$('#login_modal').foundation('reveal', 'close');

			return false;
		},
		processRegisterForm : function() {
			console.log('processing register');
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
	},
	afterRenderEvent : function() {
		$(document).foundation();
	},
});
