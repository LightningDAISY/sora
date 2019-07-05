import Vue from 'vue'
import Router from 'vue-router'
import Buefy from 'buefy'
import 'buefy/dist/buefy.css'
import Index   from '@/components/Index'
import About   from '@/components/About'
import Contact from '@/components/Contact'
import WikiIndex   from '@/components/Wiki/Index'
import WikiEntry   from '@/components/Wiki/Entry'
import WikiEdit    from '@/components/Wiki/Edit'
import WikiList    from '@/components/Wiki/List'
import WikiPost    from '@/components/Wiki/Post'
import WikiHistory from '@/components/Wiki/History'
import Login   from '@/components/Login'
import Signup  from '@/components/Signup'
import FileManager from '@/components/FileManager'
import Phrase  from '@/components/Phrase'

Vue.use(Router)
Vue.use(Buefy, { defaultIconPack: 'fa' })

window.Vue = Vue

export default new Router({
  routes: [
    {
      path: '/',
      name: 'Index',
      component: Index
    },
    {
      path: '/about/',
      name: 'About',
      component: About
    },
    {
      path: '/wiki/',
      name: 'WikiIndex',
      component: WikiIndex
    },
    {
		path: '/wiki/entry/:id',
      name: 'WikiEntry',
      component: WikiEntry
    },
    {
      path: '/wiki/edit/:id',
      name: 'WikiEdit',
      component: WikiEdit
    },
    {
      path: '/wiki/list/',
      name: 'WikiList',
      component: WikiList
    },
    {
      path: '/wiki/post',
      name: 'WikiPost',
      component: WikiPost
    },
    {
      path: '/wiki/history/:id',
      name: 'WikiHistory',
      component: WikiHistory
    },
    {
      path: '/contact/',
      name: 'Contact',
      component: Contact
    },
    {
      path: '/login/',
      name: 'Login',
      component: Login
    },
    {
      path: '/signup/:id',
      name: 'SignupParams',
      component: Signup
    },
    {
      path: '/signup/',
      name: 'Signup',
      component: Signup
    },
    {
      path: '/phrase/',
      name: 'Phrase',
      component: Phrase
    },
	{
      path: '/file/',
      name: 'FileManager',
      component: FileManager,
      children: [
        {
          path: '*',
          name: 'default',
          component: FileManager,
        }
	  ]
	},
  ]
})
