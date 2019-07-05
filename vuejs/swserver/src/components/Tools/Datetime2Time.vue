<template>
  <section>
    <div class="columns">
      <div class="column">
        <b-datepicker v-model="date" inline>
        </b-datepicker>
      </div>
      <div class="column">
        <b-timepicker v-model="date" inline></b-timepicker>
        <b-notification type="is-success" style="margin-top:30px" :active.sync="isActive" has-icon>
          {{ dt }}<br />
          UTC +{{ tzOffset * -1 }}h<br />
          {{ epochtime }}
        </b-notification>
      </div>
      <div class="column">
        <button class="button is-medium is-success is-outlined is-rounded" @click="clicked">get unixtime</button>
      </div>
    </div>
  </section>

</template>

<script>
export default {
  name: 'Datetime2Time',
  data () {
    return {
      env: process.env,
      date: new Date(),
      isActive: false,
      tzOffset: '',
      dt: '',
      epochtime: 0,
    }
  },
  methods: {
    clicked: function () {
      let year = this.date.getYear()
      if(year < 1900) { year += 1900 }
      let month = this.date.getMonth() + 1
      let date = this.date.getDate()
      let hour = this.date.getHours()
      let minute = this.date.getMinutes()
      this.dt = year + "-" + month + "-" + date + " " + hour + ":" + minute + ":0"
      let newDate = new Date(year, month - 1, date, hour, minute, 0)
      this.tzOffset = newDate.getTimezoneOffset() / 60
      this.epochtime = (newDate.getTime() / 1000) | 0
      this.isActive = true
    }
  }
}
</script>

<style scoped>
</style>

