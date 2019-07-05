<template>
<div class="container">
  <Nav />
  <section style="margin:70px 30px 0 30px">

    <b-notification type="is-danger" style="margin-top:30px" :active.sync="isError" has-icon>
      {{ errorMessage }}
    </b-notification>
    <b-notification type="is-success" style="margin-top:30px" :active.sync="isSuccess" has-icon>
      {{ successMessage }}
    </b-notification>

    <b-collapse class="card">
      <div slot="trigger" slot-scope="props" class="card-header">
        <p class="card-header-title">Login</p>
        <b-icon :icon="props.open ? 'caret-up' : 'caret-down'"></b-icon>
      </div>
      <div class="card-content">
        <div class="content">
          <p style="text-align: left">
            Do you already have an account?
          </p>
          <b-field>
            <b-radio-button v-model="values.isLogin" native-value="0" type="is-primary" @change.native="change">
              <i v-if="values.isLogin < 1" class="fas fa-check"></i>
              <span>&#160;No, create this account now.</span>
            </b-radio-button>
            <b-radio-button v-model="values.isLogin" native-value="1" type="is-success" @change.native="change">
              <i v-if="values.isLogin > 0" class="fas fa-check"></i>
              <span>&#160;Yes, my account is:</span>
            </b-radio-button>
          </b-field>
        </div>
      </div>
      <footer class="card-footer">
         <input class="card-footer-item" type="text" v-model="values.loginId" placeholder="LoginID"/>
         <input class="card-footer-item" type="password" v-model="values.password" placeholder="Password"/>
         <button class="card-footer-item" style="cursor: pointer" @click="login($event)">{{ values.buttonStr }}</button>
      </footer>
    </b-collapse>
  </section>
  <Footer />
</div>
</template>

<script>
import Nav from './Nav'
import Footer from './Footer'
import Base from './Base'

export default {
  name: 'Login',
  mixins: [Base],
  data () {
    return {
      title: 'Login',
      apiUri: process.env.API_SCHEME + '://' + process.env.API_ADDRESS + ':' + process.env.API_PORT + '/api/auth/user/login.json',
      redirectUri: process.env.REDIRECT_URI,
      successMessage: '',
      errorMessage: '',
      isSuccess: false,
      isError: false,
      sessionName: process.env.SESSION_NAME,
      values: {
        loginId: '',
        password: '',
        buttonStr: 'Login',
        isLogin: 2
      },
    }
  },
  methods: {
    change: function() {
      this.values.buttonStr = this.values.isLogin == 1 ? 'Login' : 'Sign up'
    },
    login: function (event) {
      const that = this
      if(this.values.isLogin < 1) {
        location.href = '/#/signup/' + encodeURIComponent(this.values.loginId)
        return
      }
      this.basicRequest(
        'POST',
        this.apiUri,
        {
          username : this.values.loginId,
          projectid: 1,
          password : this.values.password
        },
        function(json) {
          if(json.result === 'OK') {
            that.successMessage = 'logged in'
            that.errorMessage = ''
            that.isSuccess = true
            that.isError   = false
            setTimeout(function () { window.location.href = that.redirectUri }, 3)
          } else {
            that.successMessage = ''
            that.errorMessage = json.message ? json.message : 'invalid LoginID or Password'
            that.isSuccess = false
            that.isError   = true
          }
        }
      )
    }
  },
  mounted: function () {
    document.title = this.title
    this.isLogin = 1
    this.$store.commit('saveUserData', {})
    document.cookie = this.sessionName + '=;expires=Thu, 01 Jan 1970 00:00:01 GMT'
  },
  components: {
    Nav, Footer
  }
}
</script>

<style scoped>
.margined {
  margin-top: 30px;
  margin-bottom:30px;
}
</style>

