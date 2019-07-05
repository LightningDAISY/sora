<template>
  <section>
    <div class="columns">
      <div class="column">
        <b-field>
          <b-input placeholder="12345678"
            v-model="epochTime"
            size="is-medium"
            icon="stopwatch">
          </b-input>
        </b-field>
        <b-notification type="is-danger" style="margin-top:30px" :active.sync="isError" has-icon>
          {{ errorMessage }}
        </b-notification>
        <b-notification type="is-success" style="margin-top:30px" :active.sync="isActive" has-icon>
          {{ dt }}<br />
          UTC +{{ tzOffset * -1 }}h
        </b-notification>
      </div>
      <div class="column">
        <button class="button is-medium is-success is-outlined is-rounded" @click="clicked">get datetime</button>
      </div>
    </div>
  </section>
</template>

<script>
export default {
  name: 'Time2Datetime',
  data () {
    return {
      env: process.env,
      epochTime: '',
      dt: '',
      tzOffset: '',
      isActive: false,
      isError: false,
      errorMessage: '',
    }
  },
  methods: {
    clicked: function () {
      if(!this.epochTime.match(/\d/) || this.epochTime.match(/\D/)) {
        this.errorMessage = "invalid epochtime"
        this.isError = true
        return 
      }
      let newDate = new Date()
      newDate.setTime(this.epochTime * 1000)
      let year = newDate.getYear()
      if(year < 1900) { year += 1900 }
      let month = newDate.getMonth() + 1
      let date = newDate.getDate()
      let hour = newDate.getHours()
      let minute = newDate.getMinutes()
      let second = newDate.getSeconds()
      this.dt = year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second
      this.tzOffset = newDate.getTimezoneOffset() / 60
      this.isActive = true
    }
  }
}
</script>

<style scoped>

</style>
