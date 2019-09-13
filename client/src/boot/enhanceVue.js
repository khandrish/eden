import Vue from 'vue'

Vue.prototype.$watchAll = function(props, callback) {
  props.forEach(prop => {
    this.$watch(prop, callback)
  })
}
