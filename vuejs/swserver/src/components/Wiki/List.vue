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

      <div class="column is-three-quater">
        <div class="columns">
          <div class="column is-half">
            <ul class="entryList">
              <li v-for="entry in leftUpEntries">
                <h2 v-if="isNewInitial(entry.subject.substr(0,1))" class="initial">{{ entry.subject.substr(0,1) }}</h2>
                <p><span class="clickable" @click="setAllCategory(entry.categoryName); setAllEntry(entry.categoryName)">{{ entry.categoryName }}</span> <router-link :to="'/wiki/entry/' + entry.id">{{ entry.subject }}</router-link></p>
              </li>
            </ul>
            <ul class="entryList">
              <li v-for="entry in leftDownEntries">
                <h2 v-if="isNewInitial(entry.subject.substr(0,1))" class="initial">{{ entry.subject.substr(0,1) }}</h2>
                <p><span class="clickable" @click="setAllCategory(entry.categoryName); setAllEntry(entry.categoryName)">{{ entry.categoryName }}</span> <router-link :to="'/wiki/entry/' + entry.id">{{ entry.subject }}</router-link></p>
              </li>
            </ul>
          </div>
        </div>
        <div class="columns">
          <div class="column is-half">
            <ul class="entryList">
              <li v-for="entry in rightUpEntries">
                <h2 v-if="isNewInitial(entry.subject.substr(0,1))" class="initial">{{ entry.subject.substr(0,1) }}</h2>
                <p><span class="clickable" @click="setAllCategory(entry.categoryName); setAllEntry(entry.categoryName)">{{ entry.categoryName }}</span> <router-link :to="'/wiki/entry/' + entry.id">{{ entry.subject }}</router-link></p>
              </li>
            </ul>
            <ul class="entryList">
              <li v-for="entry in rightDownEntries">
                <h2 v-if="isNewInitial(entry.subject.substr(0,1))" class="initial">{{ entry.subject.substr(0,1) }}</h2>
                <p><span class="clickable" @click="setAllCategory(entry.categoryName); setAllEntry(entry.categoryName)">{{ entry.categoryName }}</span> <router-link :to="'/wiki/entry/' + entry.id">{{ entry.subject }}</router-link></p>
              </li>
            </ul>
          </div>
        </div>
        <b-pagination
            :total="total"
            :current.sync="currentPage"
            :order="order"
            :size="size"
            :simple="isSimple"
            :rounded="isRounded"
            :per-page="perPage"
        >
        </b-pagination>
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
  name: 'WikiIndex',
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
      lastInitial: '',

      // paging
      total: 0,
      currentPage: 1,
      perPage: 100,
      order: '',
      size: '',
      isSimple: false,
      isRounded: false,
    }
  },
  watch: {
    currentPage: function() {
      this.setAllCategory(this.currentCategory)
      this.setAllEntry(this.currentCategory, this.perPage, this.perPage * (this.currentPage - 1))
    }
  },
  methods: {
    setAllCategory: function(name) {
      const that = this
      if(!name) { name = '' }
      this.currentCategory = name
      this.basicRequest(
        'GET',
        this.apiUri + '/categories/' + encodeURIComponent(name),
        {},
        function(json) {
          if(json.result == 'OK')
          {
            that.categories = json.categories
          }
        }
      )
    },
    setAllEntry: function(name, limit, offset) {
      const that = this
      if(!limit)  { limit  = this.perPage }
      if(!offset) { offset = 0 }
      if(!name) { name = '' }
      this.basicRequest(
        'GET',
        this.apiUri + '/subjects/' + encodeURIComponent(name) + '/' + limit + '/' + offset,
        {},
        function(json) {
          if(json.result == 'OK')
          {
            that.entries = json.subjects
            that.total   = json.count
          }
        }
      )
    },
    isNewInitial: function(initial) {
      return this.lastInitial != initial
    },
  },
  computed: {
    leftUpEntries: function () {
      return Array.prototype.slice.call(this.entries,0,25)
    },
    rightUpEntries: function () {
      return Array.prototype.slice.call(this.entries,25,25)
    },
    leftDownEntries: function () {
      return Array.prototype.slice.call(this.entries,50,25)
    },
    rightDownEntries: function () {
      return Array.prototype.slice.call(this.entries,75,25)
    },

  },
  mounted: function () {
    document.title = this.title
    this.setAllCategory()
    this.setAllEntry()
  },
  components: {
    Nav, WikiNav, Footer
  }
}
</script>

<style scoped>

.entryList li
{
	text-align: left;
}

.entryList a
{
	text-decoration: none;
	color: #333;
}

.entryList a:hover
{
	color: #999;
	text-decoration: underline;
}

.entryList .initial
{
	font-size: 26px;
	border-image: linear-gradient(to right, #aaa, #fff) 1/0 0 2px 0;
}
</style>

