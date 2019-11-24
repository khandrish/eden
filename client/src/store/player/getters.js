export function getPlayer(state, _getters, _rootState, rootGetters) {
  console.log(rootGetters)
  return rootGetters['players/getById'](state.playerId)
}

export function getIsAuthenticated(state) {
  return state.isAuthenticated
}
