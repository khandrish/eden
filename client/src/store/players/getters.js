export function getById(state) {
  return function(playerId) {
    return state.get(playerId)
  }
}

export function list(state) {
  return Array.from(state.values())
}
