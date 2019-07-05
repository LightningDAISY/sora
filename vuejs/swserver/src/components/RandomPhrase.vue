<template>
  <section>
    <div class="phrase">
        <div v-html="message.body"></div>
        <div v-if="message.author" class="author" v-html="message.author"></div>
        <div v-if="message.company || message.title" class="quote">
          <span v-if="message.company">{{ message.company }}</span>
          <span v-if="message.title">{{ message.title }}</span>
        </div>
    </div>
  </section>
</template>

<script>
import Base from './Base'

export default {
  name: 'RandomPhrase',
  mixins: [Base],
  data () {
    return {
      env: process.env,
      message: {
        body:    '',
        author:  '',
        title:   '',
        company: '',
      },
      apiUri: process.env.API_SCHEME + '://' + process.env.API_ADDRESS + ':' + process.env.API_PORT + '/api/phrase/random',
    }
  },
  mounted: function () {
    let that = this
    this.basicRequest(
      'GET',
      this.apiUri,
      null,
      function(json) {
        if(json && json.message) {
          that.message.body = json.message.replace(/\n/g, '<br />')
          that.message.author = json.author
          that.message.title = json.title
          that.message.company = json.company
        }
      }
    )
  },
}
</script>

<style scoped>
div.phrase
{
  font: 400 14px/1.2 serif;
  color: #333;
  background-color: #f7f7f7;
  text-align: left;
  margin: 30px 5px 60px 5px;
  border-radius: 10px 10px 10px 10px / 10px 10px 10px 10px;
  padding: 30px 20px 10px 30px;
  -webkit-box-shadow: inset 5px 5px 20px 5px rgba(153,153,153,1);
  -moz-box-shadow: inset 5px 5px 20px 5px rgba(153,153,153,1);
  box-shadow: inset 5px 5px 20px 5px rgba(153,153,153,1);
}
div.phrase .author
{
  margin:10px;
  text-align:right;
  font-size:14px;
}
div.phrase .quote
{
  margin:10px;
  text-align:right;
  font-size:13px;
}
</style>

