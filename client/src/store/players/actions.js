export function getById(context, playerId) {
  context.commit('get', playerId)
}

export function listAll(context) {
  context.commit('list')
}

export function put(context, players) {
  if (Array.isArray(players)) {
    context.commit('put', players)
  } else {
    context.commit('put', [players])
  }
}
