import Vue from 'vue'
import Vuex from 'vuex'

import csrf from './csrf'
import player from './player'
import players from './players'
import settings from './settings'

Vue.use(Vuex)

/*
 * If not building with SSR mode, you can
 * directly export the Store instantiation
 */

export default function(/* { ssrContext } */) {
  const Store = new Vuex.Store({
    modules: {
      csrf,
      player,
      players,
      settings
    },

    // enable strict mode (adds overhead!)
    // for dev mode only
    strict: process.env.DEV
  })

  return Store
}
