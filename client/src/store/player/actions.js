export function setPlayerId(context, playerId) {
  context.commit('setPlayerId', playerId)
  // If a valid playerId is being set, it can be assumed that the user is authenticated
  if (playerId !== null) {
    context.commit('setIsAuthenticated', true)
  } else {
    context.commit('setIsAuthenticated', false)
  }
}

// export function loadPlayer({ commit }) {
//   const self = this

//   return new Promise((resolve, reject) => {
//     self._vm.$axios.get('/player')
//       .then(function(response) {
//         self.dispatch('player/setPlayerId', response.data.id)
//         self.dispatch('players/putPlayer', response.data)
//         resolve()
//       })
//       .catch(function(_error) {
//         self.dispatch('player/setPlayerId', null)
//         reject()
//       })
//   })
// }

export function loadPlayer(context) {
  const self = this

  this._vm.$axios.get('/player')
    .then(function(response) {
      self.dispatch('player/setPlayerId', response.data.data.id)
      self.dispatch('players/put', response.data.data)
      self.dispatch('settings/loadSettings')
    })
    .catch(function(_error) {
      self.dispatch('player/setPlayerId', null)
    })
}

export function logout(context) {
  const self = this

  this._vm.$axios.post('/logout')
    .then(function(response) {
      self.dispatch('player/setPlayerId', null)
    })
}
