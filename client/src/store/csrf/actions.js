export async function fetchCsrfToken(context) {
  const axios = this._vm.$axios

  axios.get('/csrf-token')
    .then(function(response) {
      axios.defaults.headers.post['x-csrf-token'] = response.data
      context.commit('setCsrfToken', response.data)
    })
}

// export function fetchCsrfToken(_context) {
//   const self = this
//   const axios = this._vm.$axios

//   return new Promise((resolve, reject) => {
//     axios.get('/csrf-token')
//       .then(function(response) {
//         axios.defaults.headers.post['x-csrf-token'] = response.data
//         self.dispatch('csrf/setCsrfToken', response.data)
//         resolve()
//       })
//       .catch(function(_error) {
//         reject()
//       })
//   })
// }
