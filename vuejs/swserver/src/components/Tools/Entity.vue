<template>
  <section>
    <div class="columns">
      <div class="column">
        <div class="field">
          <div class="control">
            <textarea class="textarea is-primary is-small" v-model="val" placeholder="abcde"></textarea>
          </div>
          <div class="control">
            <pre v-html="val"></pre>
          </div>
          <div class="control">
            <textarea class="textarea is-primary is-small" v-model="result" placeholder="&#64;&#65..."></textarea>
          </div>
          <div class="control">
            <pre v-html="result"></pre>
          </div>
        </div>
      </div>
      <div class="column">
        <button class="button is-medium is-success is-outlined is-rounded" @click="clicked">convert</button>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: 'Entity',
  data () {
    return {
      env: process.env,
      val: '',
      result: '',
      isActive: false,
      errorMessage: '',
    }
  },
  methods: {
    clicked: function () {
      this.result = ''
      for(let i=0 ; i<this.val.length; i++) {
        let chr = this.val.charAt(i);
        this.result += "&#" + chr.charCodeAt().toString() + ";"
      }
      this.isActive = true
    }
  }
}
</script>

<style scoped>

</style>
