const routes = [
  {
    path: '/home',
    component: () => import('layouts/EmptyLayout.vue'),
    children: [{ path: '', name: 'home', component: () => import('pages/HomePage.vue') }]
  },
  {
    path: '/registry',
    component: () => import('layouts/EmptyLayout.vue'),
    children: [{ path: '', name: 'registry', component: () => import('pages/VentureForthLandingPage.vue') }]
  },
  {
    path: '/',
    component: () => import('layouts/EmptyLayout.vue'),
    children: [{ path: '', component: () => import('pages/LandingPage.vue') }]
  }
]

// Always leave this as last one
if (process.env.MODE !== 'ssr') {
  routes.push({
    path: '*',
    component: () => import('pages/Error404.vue')
  })
}

export default routes
