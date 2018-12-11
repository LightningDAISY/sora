<template>
  <div>
    <TopMenu/>
    <div id="fileManager">
      <div id="filePanel">
        <button class="button is-primary" @click="newDirectory">create a new directory</button>
        <input type="file" name="file" @change="uploadFile($event)" />
      </div>
      <table class="table" id="fileList">
        <tr>
          <td>
            <a @click="linkto('#' + fmuri + parentUri)">..</a>
          </td>
          <td>&#160;</td>
          <td>&#160;</td>
        </tr>
        <tr v-for="file in files">
          <td v-if="file.isDirectory">
            <a @click="linkto('#' + fmuri + getPathByHref() + '/' + file.name)">{{ file.name }}</a><br />
          </td>
          <td v-else>
            <a :href="staticHost + file.uri">{{ file.name }}</a>
          </td>
          <td class="permission">{{ file.permissionString }}</td>
          <td>
            <div v-if="file.lockedBy">
              <a class="button is-info" @click="freezeNode(file)">unlock (locked by {{ file.userNickname }}</a>
              <a v-if="file.name.match(/\.yaml$/)" :href="uiPath + '?' + file.uri" class="button is-primary">SwaggerUI</a>
              <a v-if="file.name.match(/\.json$/)" :href="uiPath + '?' + file.uri" class="button is-primary">SwaggerUI</a>
            </div>
            <div v-else>
              <a class="button is-info" @click="freezeNode(file)">lock</a>
              <a class="button is-info" @click="renameNode(file)">Rename</a>
              <a class="button is-info" @click="deleteNode(file)">Delete</a>
              <a v-if="file.name.match(/\.yaml$/)" :href="uiPath + '?' + file.uri" class="button is-primary">SwaggerUI</a>
              <a v-else-if="file.name.match(/\.json$/)" :href="uiPath + '?' + file.uri" class="button is-primary">SwaggerUI</a>
            </div>
          </td>
        </tr>
      </table>
    </div>
  </div>
</template>

<script>
import TopMenu from './TopMenu'
import config from '../../config'
import FetchBase from './Modules/FetchBase'

export default {
  components: { TopMenu },
  name: 'FileManager',
  mixins: [FetchBase],
  mounted: function () {
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
      files: [],
      parentUri: '',
      linkUri: '',
      fmuri: process.env.PATH_FM,
      apiuri: process.env.ENDPOINT_FM,
      staticHost: process.env.STATIC_HOST,
      uiPath: process.env.PATH_UI
    }
  },
  methods: {
    linkto: function (uri) {
      this.linkUri = uri
      window.location = process.env.URI_BASE + '/' + this.linkUri
    },
    //
    // location.hrefから基底PATH(http〜/file)を消した値
    //
    getPathByHref: function () {
      let sep = new RegExp('://[^/]+' + process.env.PATH_FM)
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
        "POST",
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
		"PUT",
		this.apiuri + this.getPathByHref(),
		{
			newFile : files[0]
		},
        function () { that.showCurrent() }
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
        "PUT",
        this.apiuri + file.path,
        { "newName" : input },
        function () { that.showCurrent() }
      )
    },

    deleteNode: function(file) {
	  const parts = file.path.split(/\//)
	  if(!confirm("remove " + parts[parts.length - 1] + "?")) { return }
      const that = this
	  this.basicRequest(
        "DELETE",
        this.apiuri + file.path,
        null,
        function () { that.showCurrent() }
      )
    },

    // 
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
        },
        function(res) { alert("error " + res) }
      )
    }
  }
}
</script>
