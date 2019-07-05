<template>
<div class="container">
  <Nav />
  <section class="margin-top-large">
    <h1 class="title">{{ title }}</h1>
    <WikiNav />

    <!-- success modal -->
    <section class="margin-top-large">
      <b-message title="received" type="is-success" :active.sync="successIsActive">
        {{ modalMessage }}
      </b-message>
    </section>

    <!-- error modal -->
    <section class="margin-top-large">
      <b-message title="Error" type="is-danger" :active.sync="errorIsActive">
        {{ modalMessage }}
      </b-message>
    </section>

    <div class="columns">
      <div class="column is-half wiki-form">

        <b-field label="Subject">
          <b-input rounded type="text" v-model="subject" tabindex="1"></b-input>
        </b-field>

        <b-field label="Category">
          <b-autocomplete
            rounded
            v-model="category"
            :data="filteredDataArray"
            placeholder="e.g. Perl"
            tabindex="2"
            @select="option => selected = option">
            <template slot="empty">No results found</template>
          </b-autocomplete>
        </b-field>

        <b-field label="Body">
          <b-input type="textarea" rows="6" v-model="body" tabindex="3"></b-input>
        </b-field>

        <b-field>
          <div class="is-center">
            <button class="button is-light" type="submit" tabindex="6" @click="send($event)">
              <i class="far fa-plus-square"></i>
              &#160;<span>Update</span>
            </button>
          </div>
        </b-field>
      </div>
      <div class="column is-half">
        <div class="preview-window wiki-format" v-html="previewBody"></div>
        <pre class="source-window" v-text="previewBody"></pre>
        <pre class="source-window" v-text="jsonBody"></pre>
      </div>
    </div>
  </section>

  <Footer />
</div>
</template>

<script>
import Nav from '../Nav'
import WikiNav from './Nav'
import Footer from '../Footer'
import Base from '../Base'
import WikiParser    from '../../libs/WikiParser'
import WikiGenerator from '../../libs/WikiGenerator'

export default {
  name: 'WikiPost',
  mixins: [Base],
  data () {
    return {
      title: process.env.WIKI.TITLE,
      apiUri: process.env.API_SCHEME + '://' + process.env.API_ADDRESS + ':' + process.env.API_PORT + '/api/wiki',
      body: '',
      subject: '',
      category: '',
      categories: [],
      selected: null,
      previewBody: '',
      jsonBody: '',
      modalMessage: '',
      errorIsActive: false,
      successIsActive: false,
      currentEntry: {},
    }
  },
  watch: {
    body: function() {
      this.bodyUpdated()
    },
  },
  methods: {
    bodyUpdated: function (event) {
      this.jsonBody = WikiParser.parse(this.body)
      this.previewBody = WikiGenerator.generate(this.jsonBody)
    },
    setAllCategory: function() {
      const that = this
      this.basicRequest(
        'GET',
        this.apiUri + '/categories',
        {},
        function(json) {
          if(json.result == 'OK')
          {
            that.categories = json.categories
          }
        }
      )
    },
    setCurrentEntry: function (entryId) {
      const that = this
      this.basicRequest(
        'GET',
        this.apiUri + '/entry/' + entryId,
        {},
        function(json) {
          if(json.result == 'OK')
          {
            that.currentEntry = json.entry
            that.subject  = that.currentEntry.subject
            that.category = that.currentEntry.categoryName
            that.body     = that.currentEntry.source
          }
          else
          {
            that.errorIsActive = true
            that.modalMessage  = 'invalid request'
            return
          }
        }
      )
    },
    send: function (event) {
      const that = this
      this.basicRequest(
        'POST',
        this.apiUri + '/set',
        {
          id: that.currentEntry.id,
          subject: this.subject,
          category: this.category,
          body: JSON.stringify(WikiParser.parse(this.body)),
          source: this.body,
        },
        function(json) {
          if(json.result === 'OK') {
            that.modalMessage = 'エントリを編集しました。'
            that.successIsActive = true
            that.errorIsActive = false
          } else {
            that.modalMessage = json.message ? json.message : 'エントリの編集に失敗しました。'
            that.successIsActive = false
            that.errorIsActive = true
          }
        }
      )
    },
  },
  computed: {
    filteredDataArray() {
      return this.categories.filter((option) => {
        return option
          .toString()
          .toLowerCase()
          .indexOf(this.category.toLowerCase()) >= 0
      })
    }
  },
  // フォーム入力のたびに実行
  //updated: function() {
  //  this.bodyUpdated()
  //},
  mounted: function () {
    document.title = this.title
    this.setCurrentEntry(this.$route.params.id)
    this.setAllCategory()
  },
  components: {
    Nav, WikiNav, Footer
  }
}
</script>

<style scoped>

</style>

