export function setDeveloperFeatureOn(state, featureOn) {
  state.developerFeatureOn = featureOn
}

export function setPlayerSettings(state, settings) {
  state.playerId = settings.playerId
  state.developerFeatureOn = settings.developerFeatureOn
}
