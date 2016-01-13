import Ember from 'ember';

export default Ember.Component.extend({
	tagName: 'button',
	classNames: ['primary button'],
	classNameBindings: ['isEnabled::disabled'],
	isEnabled: true,
	text: '',
	click() {
		this.get('onClick')();
	}
});
