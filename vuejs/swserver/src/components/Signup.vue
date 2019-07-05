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
        <p class="card-header-title">Sign up</p>
        <b-icon :icon="props.open ? 'caret-up' : 'caret-down'"></b-icon>
      </div>
      <div class="card-content">
        <div class="content">
          <p style="text-align: left">
            Login ID<br />
            <b-field>
              <b-input placeholder="Login ID" v-model="values.loginId" type="text" icon="user"></b-input>
              <button @click="isExists($event)">is exists?</button>
            </b-field>
          </p>

          <p style="text-align: left">
            Nickname<br />
            <b-field>
              <b-input placeholder="Nickname" v-model="values.nickname" type="text" icon="user"></b-input>
              <button @click="isExists($event)">is exists?</button>
            </b-field>
          </p>

          <p style="text-align: left">
            E-Mail Address<br />
            <b-field>
              <b-input placeholder="EMail" v-model="values.email" type="mail" icon="envelope"></b-input>
            </b-field>
          </p>

          <p style="text-align: left">
            Login Password<br />
            <b-field>
              <b-input placeholder="******" v-model="values.password" type="password" icon="key"></b-input>
            </b-field>
          </p>

          <p style="text-align: left">
            Pass Phrase<br />
            <b-field>
              <b-input placeholder="PassPhrase" v-model="values.passphrase" type="text" icon="user-secret"></b-input>
            </b-field>
          </p>

        </div>
      </div>
      <footer class="card-footer">
         <button class="card-footer-item" style="cursor: pointer" @click="signup($event)">Sign up</button>
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
  name: 'Signup',
  mixins: [Base],
  data () {
    return {
      title: 'Signup',
      apiUri: process.env.API_SCHEME + '://' + process.env.API_ADDRESS + ':' + process.env.API_PORT + '/api/auth/user/signup.json',
      checkerUri: process.env.API_SCHEME + '://' + process.env.API_ADDRESS + ':' + process.env.API_PORT + '/api/auth/user/isexists.json',
      isError: false,
      isSuccess: false,
      errorMessage : '',
      successMessage : '',
      values: {
        loginId: '',
        password: '',
        nickname: '',
        passphrase: '',
        email: '',
      },
    }
  },
  methods: {
    isExists: function (event) {
	  const that = this
      this.basicRequest(
        'POST',
        this.checkerUri,
        {
          username: this.values.loginId,
          projectId: 1,
          nickname: this.values.nickname,
        },
        function(json) {
          if(json.result === 'OK') {
            that.successMessage = '登録できます。'
            that.isError   = false
            that.isSuccess = true
          } else {
            that.errorMessage = json.message ? json.message : 'invalid parameters'
            that.isSuccess = false
            that.isError   = true
          }
        }
      )
	
    },
    signup: function (event) {
      const that = this
      this.basicRequest(
        'POST',
        this.apiUri,
        {
          username: this.values.loginId,
          mailAddress: this.values.email,
          projectid: 1,
          password: this.values.password,
          nickname: this.values.nickname,
          passPhrase: this.values.passphrase,
        },
        function(json) {
          if(json.result === 'OK') {
            that.successMessage = '登録しました。'
            that.isError   = false
            that.isSuccess = true
          } else {
            that.errorMessage = json.message ? json.message : 'internal server error'
            that.isSuccess = false
            that.isError   = true
          }
        }
      )
    }
  },
  mounted: function () {
    document.title = this.title
    this.values.loginId = this.$route.params.id
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

