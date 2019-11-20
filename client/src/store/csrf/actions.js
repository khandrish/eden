export function fetchCsrfToken(context) {
  this._vm.$axios.get('/csrf-token')
    .then(function(response) {
      context.commit('setCsrfToken', response.data)
    })
}
