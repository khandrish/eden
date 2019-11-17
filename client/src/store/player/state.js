const player = JSON.parse(localStorage.getItem('player'))
const state = player
  ? { status: { authenticated: true }, player: player }
  : { status: { authenticated: false }, player: undefined }

export default state
