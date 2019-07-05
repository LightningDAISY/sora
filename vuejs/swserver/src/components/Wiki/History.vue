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
                <li><span class="clickable" @click="setAllCategory(); setAllEntry();">All</span></li>
                <li v-for="category in categories"><span class="clickable" @click="setAllCategory(category); setAllEntry(category)">{{ category }}</span></li>
              </ul>
            </div>
          </b-collapse>
        </section>
      </div>

      <div class="column is-two-quater">
        <div class="card" v-if="histories.length < 1">
          更新はありません。
        </div>
        <div class="card" v-for="history in histories">
          <div class="card-content">
            <div class="content wiki-format" v-html="generateHtml(history.preview)"></div>
          </div>
          <footer class="card-footer">
            <a class="card-footer-item" @click="rollbackTo(currentEntry.id, history.id)">Rollback to {{ epoch2date(history.createdAt) }}</a>
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
      histories: [],
      currentEntry: {},
    }
  },
  watch: {
    $route: function () {
      this.setCurrentEntry(this.$route.params.id)
    }
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
    setAllEntry: function(name) {
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
    setAllHistory: function (entryId) {
      const that = this
      this.basicRequest(
        'GET',
        this.apiUri + '/histories/' + entryId,
        {},
        function(json) {
          if(json.result == 'OK')
          {
            that.histories = json.histories
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
	rollbackTo: function(entryId, historyId) {
      if(!confirm('really?')) { return false }
	  const that = this
      this.basicRequest(
        'POST',
        this.apiUri + '/rollback/' + entryId + '/' + historyId,
        {},
        function(json) {
          if(json.result == 'OK') {
    		that.setAllEntry()
            that.modalMessage = 'rollback the entry.'
            that.successIsActive = true
            that.errorIsActive = false
            that.setCurrentEntry(that.$route.params.id)
            that.setAllHistory(that.$route.params.id)
          } else {
            that.modalMessage = json.message ? json.message : 'failed'
            that.successIsActive = false
            that.errorIsActive = true
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
  },
  mounted: function () {
    document.title = this.title
    this.setCurrentEntry(this.$route.params.id)
    this.setAllHistory(this.$route.params.id)
    this.setAllCategory()
    this.setAllEntry()
  },
  components: {
    Nav, WikiNav, Footer
  }
}
</script>

<style scoped>
</style>

