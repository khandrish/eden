export function setDeveloperFeatureOn(context, featureOn) {
  context.commit('setDeveloperFeatureOn', featureOn)
}

export function loadSettings(context, playerId) {
  this._vm.$axios.get(`/player/settings`)
    .then(function(response) {
      context.commit('playerSettings/setPlayerSettings', response.data)
    })
}

export function saveSettings(context) {
  this._vm.$axios.post('/player/settings', context.state)
    .then(function(_) {
      this.$q.notify({
        message: 'Successfully saved Player Settings',
        color: getComputedStyle(document.documentElement).getPropertyValue('--positive')
      })
    })
    .catch(function(_) {
      this.$q.notify({
        message: 'Failed to save Player Settings',
        color: getComputedStyle(document.documentElement).getPropertyValue('--negative')
      })
    })
}
