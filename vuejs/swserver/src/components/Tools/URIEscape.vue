<template>
  <section>
    <div class="columns">
      <div class="column">
        <div class="field">
          <div class="control">
            <textarea class="textarea is-primary is-small" v-model="val" placeholder="%32%64..."></textarea>
          </div>
        </div>
        <textarea v-if="isActive" class="textarea is-primary is-small" style="margin-top:30px">{{ result }}</textarea>
      </div>
      <div class="column">
        <div class="control">
          <label class="radio">
            <input type="radio" name="mode" value="1" checked="checked" @click="change($event)">&#160;Escape
          </label><br />
          <label class="radio">
            <input type="radio" name="mode" value="2" @click="change($event)">&#160;Unescape
          </label><br />
          <label class="radio">
            <input type="radio" name="mode" value="3" checked="checked" @click="change($event)">&#160;Encode
          </label><br />
          <label class="radio">
            <input type="radio" name="mode" value="4" @click="change($event)">&#160;Decode
          </label>
        </div>
      </div>
      <div class="column">
        <button class="button is-medium is-success is-outlined is-rounded" @click="clicked">{{ buttonStr }}</button>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: 'URIEscape',
  data () {
    return {
      env: process.env,
      val: '',
      mode: 1,
      isActive: false,
      result: '',
      buttonStr: 'escape'
    }
  },
  methods: {
    change: function (event) {
      if (event.target.checked)
      {
        this.mode = event.target.value
        this.buttonStr = this.mode == 1 ? 'escape' :
                         this.mode == 2 ? 'unescape' :
                         this.mode == 3 ? 'encode' : 'decode'
      }
    },
    clicked: function () {
      if(this.val.length < 1) { return }
      this.result = this.mode == 1 ? encodeURIComponent(this.val) :
                    this.mode == 2 ? decodeURIComponent(this.val) :
                    this.mode == 3 ? encodeURI(this.val) : decodeURI(this.val)
      this.isActive = true
    }
  }
}
</script>

<style scoped>
.result {
	background-color: transparent;
	width: 50%;
	color: #fff;
    overflow: auto;
}
</style>
