<template>
  <div class="container">
    <Nav />
<!-- Modal Begin -->
  <div id="modal-template">
    <transition name="modal" v-if="modal.show">
      <div class="modal-mask">
        <div class="modal-wrapper">
          <div class="modal-container">
            <div class="modal-header">
              <slot name="header">
                {{ modal.header }}
                <button class="modal-default-button" @click="modal.show = false">
                  Close
                </button>
              </slot>
            </div>

            <div class="modal-body">
              <slot name="body">
                <table class="history" v-if="histories.length">
                  <tr v-for="history in histories">
                    <td v-html="history.nickname"></td>
                    <td>
                      <div class="diff" v-html="history.body"></div>
                    </td>
                    <td>
                      <div v-html="time2datetime(history.time)"></div>
                      <button class="modal-default-button" @click="rollbackTo(history.id)">この版に戻す</button>
                    </td>
                  </tr>
                </table>
                <p v-else>not modified</p>
                {{ modal.body }}
              </slot>
            </div>

            <div class="modal-footer">
              <slot name="footer">
                {{ modal.footer }}
                <button class="modal-default-button" @click="modal.show = false">
                  Close
                </button>
              </slot>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </div>
<!-- Model End-->

    <div>
      <div v-if="$store.state.userData.userId && $store.state.userData.userId > 0" id="filemanager-panel">
        <button class="button is-primary" @click="newDirectory">create a new directory</button>
        <input type="file" name="file" @change="uploadFile($event)" />
      </div>
      <table class="table" id="filemanager-List">
        <tr>
          <td>
            <a @click="linkto('#' + fmuri + parentUri)">..</a>
          </td>
          <td>&#160;</td>
          <td>&#160;</td>
        </tr>
        <tr v-for="name in fileNames">
          <td v-if="files[name].isDirectory">
            <a @click="linkto('#' + fmuri + getPathByHref() + '/' + name)">{{ name }}</a><br />
          </td>
          <td v-else>
            <a :href="staticHost + files[name].uri">{{ name }}</a>
          </td>
          <td class="permission">{{ files[name].permissionString }}</td>
          <td>
            <a v-if="name.match(/\.ya?ml$/)" :href="viewerPath + '?' + staticHost + files[name].uri" class="button is-primary">Viewer</a>
            <a v-else-if="name.match(/\.json$/)" :href="viewerPath + '?' + staticHost + files[name].uri" class="button is-primary">Viewer</a>
            <a v-if="name.match(/\.ya?ml$/)" :href="uiPath + '/?' + encodeURI(staticHost + files[name].uri)" class="button is-primary">UI</a>
            <a v-if="name.match(/\.ya?ml$/)" :href="getStubUri(files[name].uri)" class="button is-primary">Stub</a>
          </td>
        </tr>
      </table>
    </div>
    <Footer />
  </div>
</template>

<script>
import Nav from './Nav'
import Footer from './Footer'
import Base from './Base'

export default {
  name: 'FileManager',
  mixins: [Base],
  mounted: function () {
    document.title = this.title
    this.showCurrent()
  },
  watch: {
    '$route' (to, from) {
	  let newPath = to.path.replace(/^\/file/, '')
      this.showCurrent(this.apiuri + '/list', newPath)
    }
  },
  data () {
    return {
      title: 'FileManager',
      files: [],
      fileNames: [],
      histories: [],
      parentUri: '',
      linkUri: '',
      fmuri: '/file',
      uribase: process.env.SCHEME + '://' + process.env.ADDRESS + ':' + process.env.PORT,
      apiuri: process.env.API_SCHEME + '://' + process.env.API_ADDRESS + ':' + process.env.API_PORT + '/api/file',
      staticHost: process.env.STATIC_HOST,
      stubHost: process.env.STUB_HOST,
      uiPath: process.env.PATH_SWAGGER_UI,
      viewerPath: process.env.PATH_SWAGGER_VIEWER,
      modal: {
        show: false,
        header: '',
        body:   '',
        footer: '',
      },
    }
  },
  methods: {
    getStubUri : function(uri) {
      return this.stubHost + uri + '/README'
    },
    linkto: function (uri) {
      this.linkUri = uri
      window.location = this.uribase + '/' + this.linkUri
    },
    //
    // location.hrefから基底PATH(http〜/file)を消した値
    //
    getPathByHref: function () {
      let sep = new RegExp('://[^/]+' + this.fmuri)
      // let arr = location.href.replace(/\/+$/, '').split(sep, 2)
      let arr = location.href.replace(/\/+$/, '').split(/#\/file/, 2)
      if(arr[1].length < 1 || arr[1] == '?') { return '' }
      let param = decodeURIComponent(arr[1]).replace(/^\?/, '')
      if(param == '/') { param = '' }
      return param
    },
    //
    // Current-URIに対応するListAPI-URI
    //
    getListApiUri: function () {
      let filePath = this.getPathByHref()
      return this.apiuri + '/list' + filePath
    },
    //
	newDirectory: function () {
      const input = prompt('directory name')
      if(!input) { return }
      const that = this
      this.basicRequest(
        'POST',
        this.apiuri + this.getPathByHref(),
        { "directoryName" : input },
        function () { that.showCurrent() }
      )
    },
	uploadFile: function (event) {
      let files = event.target.files || event.dataTransfer.files
      if(!files || !files.length) { alert("empty"); return }
      const that = this
      this.basicRequest(
		'PUT',
		this.apiuri + this.getPathByHref(),
		{
			newFile : files[0]
		},
        function () {
          alert("uploaded")
          that.showCurrent()
        }
	  )
      
    },

    //
    getAPath: function (json) {
      if (json && Object.keys(json)) {
        for (let key in json) {
          return json[key].path
        }
      }
    },

    // 
    renameNode: function (file) {
      const input = prompt("input a new name", file.path)
      if(!input) { return }
      const that = this
      this.basicRequest(
        'PUT',
        this.apiuri + file.path,
        { "newName" : input },
        function (json) {
          if(json.message) { alert(json.message) }
          that.showCurrent()
        }
      )
    },

    deleteNode: function(file) {
	  const parts = file.path.split(/\//)
	  if(!confirm("remove " + parts[parts.length - 1] + "?")) { return }
      const that = this
	  this.basicRequest(
        'DELETE',
        this.apiuri + file.path,
        null,
        function () { that.showCurrent() }
      )
    },

    time2datetime: function (epoch) {
      let newDate = new Date()
      newDate.setTime(epoch * 1000)
      let year = newDate.getYear()
      if(year < 1900) { year += 1900 }
      let month = newDate.getMonth() + 1
      let date = newDate.getDate()
      let hour = newDate.getHours()
      let minute = newDate.getMinutes()
      let second = newDate.getSeconds()
      return year + "-" + month + "-" + date + " " + hour + ":" + minute + ":" + second
    },

	showHistory: function (file) {
      const that = this
      this.basicRequest(
        'GET',
        this.apiuri + '/histories' + encodeURI(file.path),
        null,
        function (json) {
          if(json.result === 'OK') {
            that.histories = json.histories
            that.modal.show = true
          }
          else
          {
            alert("network error")
          }
        }
      )
    },

	rollbackTo: function (historyId) {
      if(!confirm("rollback?")) { return }
      const that = this
      this.basicRequest(
        "POST",
        this.apiuri + '/rollbackTo/' + historyId,
        null,
        function (json) {
          if(json.result === 'OK') {
            that.modal.show = false
			alert("rollback changes")
          } else {
            alert(json.message)
          }
        }
      )
    },

    freezeNode: function (file) {
      const that = this
      this.basicRequest(
        "OPTIONS",
        this.apiuri + file.path,
        null,
        function (json) {
          if(json.result === 'OK') {
			that.showCurrent()
          } else {
            alert("ログイン後に再実行してください")
          }
        }
      )
    },
    //
    // location.hrefの一つ上
    // 
    setParentUri: function (requestPath) {
      let uri = requestPath
      if(!uri) { uri = this.getPathByHref() }
      this.parentUri = uri.replace(/\/[^\/]+$/, '')
    },

    //
    showCurrent: function (baseUri, requestPath) {
      const that = this
      if(!requestPath) { requestPath = this.getPathByHref() }
      this.setParentUri(requestPath)
      const listApiUri = baseUri ? baseUri + requestPath : this.getListApiUri()
      fetch(
        listApiUri,
        {
          method: "GET",
          headers: {
            "User-Agent" : "Mozilla/5.0"
          }
        }
      )
      .then(
        function(res) {
          return(res.json())
        }
      )
      .then(
        function(json) {
          let path = that.getAPath(json)
          that.files = json
          that.fileNames = Object.keys(json)
          that.fileNames.sort().sort(function(a,b) {
            return parseInt(json[b].isDirectory) - parseInt(json[a].isDirectory)
          })
        },
        function(res) { alert("error " + res) }
      )
    }
  },
  components: { Nav, Footer },
}
</script>
