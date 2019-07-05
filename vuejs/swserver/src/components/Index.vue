<template>
<div class="container">
  <Nav />

  <section class="hero">
    <div class="hero-body">
      <div class="container">
        <h1 class="title">{{ title }}</h1>
        <h2 class="subtitle">files and tools</h2>
      </div>
    </div>
  </section>

  <b-tabs type="is-boxed" position="is-centered" size="is-small" class="block" @click="alert('a')">
    <b-tab-item label="datetime2time" icon="clock"><Datetime2Time /></b-tab-item>
    <b-tab-item label="time2datetime" icon="clock"><Time2Datetime /></b-tab-item>
    <b-tab-item label="uri escape" icon="apple-alt"><URIEscape /></b-tab-item>
    <b-tab-item label="html entity" icon="apple-alt"><Entity /></b-tab-item>
  </b-tabs>

  <Footer />
</div>
</template>

<script>
import Nav from './Nav'
import Datetime2Time from './Tools/Datetime2Time'
import Time2Datetime from './Tools/Time2Datetime'
import URIEscape from './Tools/URIEscape'
import Entity from './Tools/Entity'
import Footer from './Footer'

export default {
  name: 'Index',
  methods: {
  },
  data () {
    return {
      title: 'OpenAPI Server Index'
    }
  },
  mounted: function () {
    document.title = this.title
  },
  components: {
    Nav, Datetime2Time, Time2Datetime, URIEscape, Entity, Footer
  }
}
</script>

<style scoped>
</style>

