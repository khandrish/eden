const player = JSON.parse(localStorage.getItem('player'))
const state = player
  ? { isAuthenticated: true, player: player }
  : { isAuthenticated: false, player: undefined }

export default state
