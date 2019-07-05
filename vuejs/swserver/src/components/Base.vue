<template>
</template>

<script>
export default {
  name: 'Base',
  data () {
    return {
    }
  },
  methods: {
    requestURI: function() {
      let afterSplit = location.href.split(/\//, 5)
      return '/' + afterSplit[4]
    },
    basicRequest: function (method, uri, data, callback) {
      const form = new FormData()
      if (data) {
        for (let key in data) {
          form.append(key, data[key])
        }
      }
      let param = {
        method: method,
        headers: { 'User-Agent': 'Mozilla/5.0' }
      }
      if (method != "GET" && method != "HEAD") {
        param.body = form
      }
      fetch(
        uri,
        param
      ).then(
        function (res) {
          return (res.json())
		}
      ).then(
        function (json) {
          if (json.result && callback) {
            callback(json)
          }
        },
        function (res) {
          alert('error ' + res)
        }
      )
    }
  }
}
</script>

