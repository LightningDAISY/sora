<template>
  <div class="front">
    <TopMenu/>
    <div>
      <table class="table is-bordered is-striped is-narrow">
        <tr>
          <th>Nickname</th><td><input id="nickname" class="input" type="text" value="" /></td>
        </tr>
        <tr>
          <th>Login ID</th><td><input id="loginId" class="input" type="text" value="" /></td>
        </tr>
        <tr>
          <th>Password</th><td><input id="password" class="input" type="password" value="" /></td>
        </tr>
        <tr>
          <th>Mail address</th><td><input id="mailAddress" class="input" type="text" value="" /></td>
        </tr>
        <tr>
          <th>Personality</th><td><textarea id="personality" class="textarea" value=""></textarea></td>
        </tr>
      </table>
    </div>
    <div style="text-align:center">
      <a class="button is-info" @click="modify()">modify</a>
    </div>
  </div>
</template>

<script>
import TopMenu from './TopMenu'
import config from '../../config'
import FetchBase from './Modules/FetchBase'

export default {
  components: { TopMenu },
  name: 'MyPage',
  mixins: [FetchBase],
  data () {
    return {
      nickname: '',
      uri: {
        mypage: process.env.URI_MYPAGE,
        modify: process.env.URI_MODIFY
      },
      bind: {}
    }
  },
  mounted: function () {
    this.basicRequest(
      'GET',
      this.uri.mypage,
      null,
      function(json) {
        if(json.result === 'NG') {
			location.href = process.env.URI_LOGIN
		}
        document.querySelector('#nickname').value    = json.nickname
        document.querySelector('#loginId').value     = json.userName
        document.querySelector('#mailAddress').value = json.mailAddress
        document.querySelector('#personality').value = json.personality
      }
    )
  },
  methods: {
    modify: function () {
      this.basicRequest(
        'POST',
        this.uri.modify,
        {
          'nickname'    : document.querySelector('#nickname').value,
          'loginId'     : document.querySelector('#loginId').value,
          'mailAddress' : document.querySelector('#mailAddress').value,
          'personality' : document.querySelector('#personality').value,
        },
        function(json) {
          if(json.result === 'OK') {
			alert('modified')
          } else{
			alert('error')
		  }
        }
      )
    }
  }
}
</script>
