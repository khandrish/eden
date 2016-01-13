import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['input-group'],
  tooltipText: '',
  inputId: null,
  name: '',
  type: 'text',
  placeholder: '',
  required: false,
  pattern: null,
  hasId: Ember.computed('id', function() {
    return this.get('inputId') != null;
  }),
  isValid: true,
  actions: {
    input() {
      var pattern = this.get('pattern');
      if(pattern != null) {
        var isValid = this.get('isValid');
        var onValidityChange = this.get('onValidityChange');

        if(typeof pattern == 'object') {
          if(pattern.hasOwnProperty('match')) {
            var target = pattern.match;
            var thisValue = this.$(':input').val();
            var thatValue = $('#' + target).val();

            if(thisValue != thatValue && isValid == true) {
              this.set('isValid', false);
            }
          }
        } else {

        }
      }
      var value = this.$(':input').val();
      var valid = RegExp(pattern).test(value);
      
      
      if(isValid != valid) {
        this.set('isValid', valid);
        if(onValidityChange != undefined) {
          onValidityChange();
        }
      }
    }
  }
});