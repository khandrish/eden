export function put(state, players) {
  players.forEach(player => {
    state.set(player.id, player)
  })
}
