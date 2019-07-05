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
          <b-input rounded type="text" v-model="values.subject" tabindex="1"></b-input>
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
            <button class="button is-light" type="button" tabindex="4" @click="exists($event)">
              <i class="fas fa-search-location"></i>
              &#160;<span>is Exists</span>
            </button>

            <button class="button is-light" type="button" tabindex="5" @click="save($event)">
              <i class="fas fa-save"></i>
              &#160;<span>Save</span>
            </button>

            <button class="button is-light" type="submit" tabindex="6" @click="send($event)">
              <i class="far fa-plus-square"></i>
              &#160;<span>Post</span>
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
      values: {
        subject   : '',
        category  : '',
        body: '',
      },
      body: '',
      category: '',
      categories: [],
      selected: null,
      previewBody: '',
      jsonBody: '',
      modalMessage: '',
      errorIsActive: false,
      successIsActive: false,
    }
  },
  watch: {
    body: function() {
      this.bodyUpdated()
    },
  },
  methods: {
	save: function (event) {
      this.values.category = this.category
      this.values.body = this.body
      localStorage.setItem('formValues', JSON.stringify(this.values))
      alert('saved')
    },
    exists: function (event) {
      if(this.category.length < 1) { alert("input category"); return false }
      if(this.values.subject.length < 1) { alert("input subject"); return false }
      let that = this
      this.basicRequest(
        'GET',
        this.apiUri + '/exists/' + encodeURIComponent(this.category) + '/' + encodeURIComponent(this.values.subject),
        null,
        function(json) {
          if(json.result == 'OK')
          {
            alert(that.category + ':' + that.values.subject + 'は未登録です。続行すると新規登録します')
          }
          else
          {
            if(confirm("登録済です。続行すると既存のエントリを更新します。OKを押すとBodyを既存のエントリに差し替えます。")) {
              that.body = json.record.body
              that.bodyUpdated()
            }
          }
        }
      )

    },
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
    send: function (event) {
      const that = this
      this.basicRequest(
        'POST',
        this.apiUri + '/set',
        {
          subject: this.values.subject,
          category: this.category,
          body: JSON.stringify(WikiParser.parse(this.body)),
          source: this.body,
        },
        function(json) {
          if(json.result === 'OK') {
            that.modalMessage = 'エントリをポストしました。本文を何ぞ間違えた場合、subjectとcategoryを変えずに、このまま編集して再度Postすると修正できます。'
            that.successIsActive = true
            that.errorIsActive = false
          } else {
            that.modalMessage = json.message ? json.message : 'エントリのポストに失敗しました。'
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
    this.setAllCategory()

    if(this.$store.state.formValues.length > 0)
    {
	    this.values.subject  = $store.state.formValues.subject
	    this.values.category = $store.state.formValues.category
	    this.values.body     = $store.state.formValues.body
	    this.category        = $store.state.formValues.category
	    this.body            = $store.state.formValues.body
        return
    }
    if(localStorage.getItem('formValues'))
    {
      let vals = JSON.parse(localStorage.getItem('formValues'))
      for(let key in vals)
      {
        this.values[key] = vals[key]
      }
      this.category = this.values.category
      this.body = this.values.body
      return
    }
  },
  components: {
    Nav, WikiNav, Footer
  }
}
</script>

<style scoped>

</style>

