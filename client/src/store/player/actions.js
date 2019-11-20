export function setPlayer(context, player) {
  context.commit('setPlayer', player)
  // If a Player is being set, it can be assumed that the user is authenticated
  context.commit('setIsAuthenticated', true)
}
