import { createApp } from 'vue'
import { createRouter, createWebHistory } from 'vue-router'
import App from './App.vue'
import StartPage from './pages/StartPage.vue'
import MainPage from './pages/MainPage.vue'
import './assets/app.css'

const routes = [
    { path: '/', component: StartPage },
    { path: '/app', component: MainPage, meta: { requiresAuth: true } }
]

const router = createRouter({
    history: createWebHistory(),
    routes
})

router.beforeEach(async (to, from, next) => {
    if (to.meta.requiresAuth) {
        try {
            const response = await fetch('/api/auth/check')
            if (response.ok) {
                next()
            } else {
                next('/')
            }
        } catch {
            next('/')
        }
    } else {
        next()
    }
})

const app = createApp(App)
app.use(router)
app.mount('#app')

export default router
