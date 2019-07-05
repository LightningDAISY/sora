<template>
  <nav class="level">
    <p  class="level-item has-text-centered">
      <b-dropdown hoverable>
        <button class="button" slot="trigger">
          <i class="fas fa-bars"></i>&#160;
          <span>OpenAPI</span>
        </button>

        <b-dropdown-item>
          <a :href="swagger.specifications" class="link is-info">API Specifications</a>
        </b-dropdown-item>
        <b-dropdown-item>
          <a :href="swagger.viewer" class="link is-info">OpenAPI Viewer</a>
        </b-dropdown-item>
        <b-dropdown-item>
          <a :href="swagger.editor" class="link is-info">Swagger Editor</a>
        </b-dropdown-item>
        <b-dropdown-item>
          <a :href="swagger.ui" class="link is-info">Swagger UI</a>
        </b-dropdown-item>
      </b-dropdown>
    </p>

    <p v-if="currentUri == '/'" class="level-item has-text-centered">
        <u><b-icon icon="home" size="is-small"></b-icon>&#160;Home</u>
    </p>
    <p v-else class="level-item has-text-centered">
      <router-link class="link is-info" :to="'/'">
        <b-icon icon="home" size="is-small"></b-icon>&#160;Home
      </router-link>
    </p>

    <p v-if="$store.state.userData.userId && $store.state.userData.userId > 0 && currentUri == '/wiki'" class="level-item has-text-centered">
      <u><i class="fab fa-dochub"></i>ocs</u>
    </p>
    <p v-if="$store.state.userData.userId && $store.state.userData.userId > 0 && currentUri != '/wiki'" class="level-item has-text-centered">
      <router-link class="link is-info" :to="'/wiki'">
        <i class="fab fa-dochub"></i>ocs
      </router-link>
    </p>

    <p v-if="currentUri == '/file'" class="level-item has-text-centered">
        <u><i class="fas fa-file-alt"></i>&#160;Files</u>
    </p>
    <p v-if="currentUri != '/file'" class="level-item has-text-centered">
        <router-link class="link is-info" :to="'/file'">
          <i class="far fa-file-alt"></i>&#160;Files
        </router-link>
	</p>

    <p v-if="currentUri == '/login'" class="level-item has-text-centered">
        <u><i class="fas fa-user"></i>&#160;{{ loginStr }}</u>
    </p>
    <p v-else class="level-item has-text-centered">
      <router-link class="link is-info" :to="'/login'">
        <i class="fas fa-user"></i>&#160;{{ loginStr }}
      </router-link>
    </p>

    <p v-if="currentUri == '/contact'" class="level-item has-text-centered">
        <u><i class="far fa-comment"></i>&#160;Contact</u>
    </p>
    <p v-else class="level-item has-text-centered">
      <router-link class="link is-info" :to="'/contact'">
        <i class="far fa-comment"></i>&#160;Contact
      </router-link>
    </p>
  </nav>
</template>

<script>
import Base from './Base'

export default {
  name: 'Nav',
  mixins: [Base],
  data () {
    return {
      env: process.env,
      apiUri: process.env.API_SCHEME + '://' + process.env.API_ADDRESS + ':' + process.env.API_PORT + '/api/user/info.json',
      swagger: {
        specifications: process.env.STATIC_HOST + process.env.PATH_DOCS,
        ui: process.env.STATIC_HOST + process.env.PATH_SWAGGER_UI,
        editor: process.env.STATIC_HOST + process.env.PATH_SWAGGER_EDITOR,
        viewer: process.env.STATIC_HOST + process.env.PATH_SWAGGER_VIEWER,
      },
      currentUri: '',
      loginStr: 'Login',
    }
  },
  mounted: function() {
    const that = this
    this.currentUri = this.requestURI()
    if(this.$store.state.userData.userId) {
        that.loginStr   = 'Logout'
        return
    }
    else if(document.cookie.length < 1)
    {
        return
    }

    this.basicRequest(
      'GET',
      this.apiUri,
      null,
      function(json) {
        if(json.result === 'OK') {
          that.loginStr   = 'Logout'
          that.$store.commit('saveUserData', json)
        } else {
          that.loginStr   = 'Login'
          that.$store.commit('saveUserData', {})
        }
      }
    )
  },
}
</script>

<style scoped>
h1, h2 {
  font-weight: normal;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #333;
}
a:hover {
  color:#66c;
}
</style>

