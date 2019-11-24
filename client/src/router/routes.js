const routes = [
  {
    path: '/',
    component: () => import('layouts/EmptyLayout.vue'),
    children: [{ path: '', component: () => import('pages/LandingPage.vue') }]
  },
  {
    path: '/authenticate',
    component: () => import('layouts/EmptyLayout.vue'),
    children: [{ path: '', component: () => import('pages/AuthenticatePage.vue') }]
  },
  {
    path: '/dashboard',
    component: () => import('layouts/AppLayout.vue'),
    children: [{ path: '', component: () => import('pages/DashboardPage.vue') }]
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
