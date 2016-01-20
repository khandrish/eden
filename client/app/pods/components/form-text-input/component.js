import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['input-group'],
  hasTooltip: Ember.computed.notEmpty('tooltipText'),
  tooltipText: '',
  type: 'text',
  submit: true,
  name: null,
  didInitAttrs: function(){
    if(this.get('submit')) {
      var getter = (function(component) { 
        return function(){ 
         return component.get('fieldValue');
        };
      })(this);
      var name = this.get('name');
      this.attrs.register(name, getter);
    }
  }
});
