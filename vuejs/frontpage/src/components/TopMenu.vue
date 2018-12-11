<template>
    <nav class="navbar is-success" style="margin-bottom:50px;">
      <div class="navbar-brand">
        <router-link class="navbar-item" :to="'/'">Swagger Server</router-link>
      </div>
      <div class="navbar-menu">
        <div class="navbar-start">
          <router-link class="navbar-item" :to="'/'">Home</router-link>
          <a class="navbar-item" :href="this.editoruri">Editor</a>
          <a class="navbar-item" :href="this.uiuri">UI</a>
          <router-link class="navbar-item" :to="'/file'">FileManager</router-link>
        </div>
        <div class="navbar-end">
          <div class="navbar-item">
            <router-link class="button" :to="'/mypage'">
              <span>MyPage</span>
            </router-link>
            <a class="button is-primary" :href="this.loginuri">
              <span id="topmenu-login">{{ loginstr }}</span>
            </a>
          </div>
        </div>
      </div>
    </nav>
</template>

<script>
import config from '../../config'
import FetchBase from './Modules/FetchBase'

export default {
  name: 'TopMenu',
  mixins: [FetchBase],
  mounted: function () {
    let that = this
    this.basicRequest(
      'GET',
      this.useruri,
      null,
      function(json) {
        if(json.result == "OK") {
          that.loginstr = "Logout"
        } else {
          that.loginstr = "Login"
        }
      }
    )
  },
  data () {
    return {
      loginstr: '', 
      apiuri: process.env.ENDPOINT_FM,
      staticuri: process.env.STATIC_FM,
      useruri: process.env.URI_USER_INFO,
      loginuri: process.env.URI_LOGIN,
      editoruri: process.env.SWAGGER_EDITOR,
      uiuri: process.env.SWAGGER_UI,
      api: config.dev.api
    }
  }
}
</script>
