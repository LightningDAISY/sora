import Vue from 'vue'
import Router from 'vue-router'
import FileManager from '@/components/FileManager'
import FrontPage from '@/components/FrontPage'
import Login from '@/components/Login'
import MyPage from '@/components/MyPage'
import Modify from '@/components/Modify'

Vue.use(Router)

export default new Router({
  // mode: 'history',
  routes: [
	{
      path: '/file',
      name: 'filemanager',
      default: true,
      component: FileManager
    },
	{
      path: '/login',
      name: 'login',
      component: Login
    },
    {
      path: '/mypage',
      name: 'mypage',
      component: MyPage
    },
    {
      path: '/modify',
      name: 'modify',
      component: Modify
    },
    {
      path: '/',
      name: 'FrontPage',
      component: FrontPage
    },
    {
	  path: '*',
	  name: 'default',
	  component: FileManager,
    }
  ]
})
