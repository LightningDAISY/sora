<template>
<div class="container">
  <Nav />
  <section class="margin-top-large">
    <h1 class="title">{{ currentCategory || title }}</h1>
    <WikiNav />

    <!-- success modal -->
    <section class="vertical-margin-large">
      <b-message title="received" type="is-success" :active.sync="successIsActive">
        {{ modalMessage }}
      </b-message>
    </section>

    <!-- error modal -->
    <section class="vertical-margin-large">
      <b-message title="Error" type="is-danger" :active.sync="errorIsActive">
        {{ modalMessage }}
      </b-message>
    </section>

    <!-- content -->
    <div class="columns">
      <!-- left -->
      <div class="column is-one-quarter">
        <section>
          <b-collapse class="panel">
            <div slot="trigger" class="panel-heading">
                <strong>Categories</strong>
            </div>
            <div class="panel-block has-text-left">
              <ul>
                <li><span class="clickable" @click="setAllCategory(); setAllEntries();">All</span></li>
                <li v-for="category in categories"><span class="clickable" @click="setAllCategory(category); setAllEntries(category)">{{ category }}</span></li>
              </ul>
            </div>
          </b-collapse>
        </section>
      </div>

      <div class="column is-two-quater">
        <div class="card" v-if="currentEntry.id">
          <header class="card-header">
            <p class="card-header-title">{{ currentEntry.categoryName }} : {{ currentEntry.subject }}</p>
          </header>
          <div class="card-content">
            <div class="content wiki-format" v-html="generateHtml(currentEntry.body)"></div>
          </div>
          <footer class="card-footer">
            <a :href="'#/wiki/history/' + currentEntry.id" class="card-footer-item">History</a>
            <a :href="'#/wiki/edit/' + currentEntry.id" class="card-footer-item">Edit</a>
            <a class="card-footer-item" @click="deleteEntry(currentEntry)">Delete</a>
          </footer>
        </div>
      </div>

      <div class="column is-one-quarter">
        <section>
          <b-collapse class="panel">
            <div slot="trigger" class="panel-heading">
                <strong>Recent Entries</strong>
            </div>
            <div class="panel-block has-text-left">
              <ul class="wikiEntryList">
                <li v-for="entry in entries">
                  <a class="clickable" :href="'#/wiki/entry/' + entry.id">{{ entry.subject }}</a><br />
                  <span class="datetime">{{ epoch2date(entry.updatedAt) }}</span>
                </li>
              </ul>
            </div>
          </b-collapse>
        </section>
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
  name: 'WikiEntry',
  mixins: [Base],
  data () {
    return {
      title: process.env.WIKI.TITLE,
      apiUri: process.env.API_SCHEME + '://' + process.env.API_ADDRESS + ':' + process.env.API_PORT + '/api/wiki',
      successIsActive: false,
      errorIsActive: false,
      modalMessage: '',
      currentCategory: '',
      categories: [],
      entries: [],
      currentEntry: {},
    }
  },
  watch: {
    $route: function () {
      this.setCurrentEntry(this.$route.params.id)
    }
  },
  computed: {
    frontEntries: function () {
      return Array.prototype.slice.call(this.entries,0,10)
    },
  },
  methods: {
    setAllCategory: function(name) {
      const that = this
      if(!name) { name = '' }
      this.currentCategory = name
      this.basicRequest(
        'GET',
        this.apiUri + '/categories/' + name,
        {},
        function(json) {
          if(json.result == 'OK')
          {
            that.categories = json.categories
          }
        }
      )
    },
    generateHtml: function (json) {
      if(!json) { return }
      let struct = JSON.parse(json)
      return WikiGenerator.generate(struct)
    },
    setAllEntries: function(name) {
      const that = this
      if(!name) { name = '' }
      this.basicRequest(
        'GET',
        this.apiUri + '/entries/' + name,
        {},
        function(json) {
          if(json.result == 'OK')
          {
            that.entries = json.entries
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
            document.title = that.currentEntry.categoryName + ':' + that.currentEntry.subject
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
	epoch2date: function(epochtime) {
      let date = new Date(epochtime * 1000)
      let year = date.getFullYear()
      let month = date.getMonth() + 1
      let day   = date.getDate()
      return year + '.' + month + '.' + day
    },
	deleteEntry: function(entry) {
      if(!confirm("really ?")) { return false }
      const that = this
      this.basicRequest(
        'DELETE',
        this.apiUri + '/set/' + entry.id,
        {},
        function(json) {
          if(json.result == 'OK') {
    		that.setAllEntries()
            that.modalMessage = 'removed'
            that.successIsActive = true
            that.errorIsActive = false
          } else {
            that.modalMessage = json.message ? json.message : 'failed'
            that.successIsActive = false
            that.errorIsActive = true
			that.currentEntry = {}
          }
        }
      )
    },
  },
  mounted: function () {
    document.title = this.title
    this.setCurrentEntry(this.$route.params.id)
    this.setAllCategory()
    this.setAllEntries()
  },
  components: {
    Nav, WikiNav, Footer
  }
}
</script>

<style scoped>
category
{
  font-size:0.9em
}
subject
{
  font-size:1.3em
}

</style>

