<template>
<div class="container">
  <Nav />

  <section style="margin-top:70px">
    <div class="columns">
      <div class="column is-one-quarter">
      </div>
      <div class="column is-half">

        <!-- success modal -->
        <section class="margined">
          <b-message title="received" type="is-success" :active.sync="successIsActive">
            {{ modalMessage }}
          </b-message>
        </section>

        <!-- error modal -->
        <section class="margined">
          <b-message title="Error" type="is-danger" :active.sync="errorIsActive">
            {{ modalMessage }}
          </b-message>
        </section>

        <h1 class="title">Contact</h1>
        <b-field label="name">
          <b-input id="name" type="text" v-model="values.name" tabindex="1"></b-input>
        </b-field>

        <b-field label="Email">
          <b-input id="email" type="email" v-model="values.email" tabindex="2"></b-input>
        </b-field>

        <b-field label="Message">
          <b-input id="message" type="textarea" rows="6" v-model="values.message" tabindex="3"></b-input>
        </b-field>

        <b-field>
          <button v-if="!sended" class="button is-light" type="submit" tabindex="4" @click="send($event)">
            <i class="far fa-envelope"></i>
            &#160;<span>Send</span>
          </button>
        </b-field>
      </div>
      <div class="column is-one-quarter">
      </div>
    </div>
  </section>

  <Footer />

</div>
</template>

<script>
import Nav from './Nav'
import Footer from './Footer'
import Base from './Base'

export default {
  name: 'Contact',
  mixins: [Base],
  data () {
    return {
      title: 'Contact',
      apiUri: process.env.API_SCHEME + '://' + process.env.API_ADDRESS + ':' + process.env.API_PORT + '/api/contact',
      values: {
        name   : '',
        email  : '',
        message: '',
      },
      sended: 0,
      modalMessage: '',
      errorIsActive: false,
      successIsActive: false,
    }
  },
  methods: {
    send: function (event) {
      const that = this
      this.basicRequest(
        'POST',
        this.apiUri,
        {
          name: this.values.name,
          email: this.values.email,
          message: this.values.message
        },
        function(json) {
          if(json.result === 'OK') {
            that.sended = 1
            that.modalMessage = 'メッセージを受け付けました。'
            that.successIsActive = true
            that.errorIsActive = false
          } else {
            that.modalMessage = json.message ? json.message : 'internal server error'
            that.successIsActive = false
            that.errorIsActive = true
          }
        }
      )
    }
  },
  mounted: function () {
    document.title = this.title
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

