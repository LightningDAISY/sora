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

        <h1 class="title">Phrases</h1>
        <b-field label="発言者">
          <b-input id="author" type="text" v-model="values.author" tabindex="1"></b-input>
        </b-field>

        <b-field label="書籍名">
          <b-input id="title" type="text" v-model="values.title" tabindex="2"></b-input>
        </b-field>

        <b-field label="出版社">
          <b-input id="company" type="text" v-model="values.company" tabindex="3"></b-input>
        </b-field>

        <b-field label="本文">
          <b-input id="message" type="textarea" rows="6" v-model="values.message" tabindex="4"></b-input>
        </b-field>

        <b-field>
          <button v-if="!sended" class="button is-light" type="submit" tabindex="5" @click="send($event)">
            <i class="far fa-envelope"></i>
            &#160;<span>Save</span>
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
  name: 'Phrase',
  mixins: [Base],
  data () {
    return {
      title: 'Phrase',
      apiUri: process.env.API_SCHEME + '://' + process.env.API_ADDRESS + ':' + process.env.API_PORT + '/api/phrase',
      values: {
        author   : '',
        title : '',
        company  : '',
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
          author: this.values.author,
          email: this.values.email,
          title: this.values.title,
          message: this.values.message
        },
        function(json) {
          if(json.result === 'OK') {
            that.sended = 1
            that.modalMessage = '投稿を受け付けました。'
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

