export function setDeveloperFeatureOn(context, featureOn) {
  context.commit('setDeveloperFeatureOn', featureOn)
  save(context, this)
}

export function loadSettings(context) {
  this._vm.$axios.get(`/player/settings`)
    .then(function(response) {
      context.commit('setPlayerSettings', response.data.data)
    })
}

export function saveSettings(context) {
  save(context, this)
}

import { Notify } from 'quasar'

function save(context, self) {
  self._vm.$axios.post('/player/settings', context.state)
    .then(function(_) {
      Notify.create({
        message: 'Successfully saved Player Settings'
      })
    })
    .catch(function(_) {
      Notify.create({
        message: 'Failed to save Player Settings'
      })
    })
}
