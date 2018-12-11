<template>
  <div class="front">
    <TopMenu/>
    <div>
      <table class="table is-bordered is-striped is-narrow">
        <tr>
          <th>Nickname</th><td id="nickname"></td>
        </tr>
        <tr>
          <th>Login ID</th><td id="loginId"></td>
        </tr>
        <tr>
          <th>Mail address</th><td id="mailAddress"></td>
        </tr>
        <tr>
          <th>Role</th><td id="role"></td>
        </tr>
        <tr>
          <th>Personality</th><td id="personality"></td>
        </tr>
        <tr>
          <th>Joined</th><td id="at"></td>
        </tr>
      </table>
    </div>
    <div style="text-align:center">
      <blockquotes>
        <router-link class="button is-info" :to="'/modify'">modify</router-link>
      </blockquotes>
    </div>
  </div>
</template>

<script>
import TopMenu from './TopMenu'
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
        document.querySelector("#nickname").innerHTML = json.nickname
        document.querySelector("#loginId").innerHTML = json.userName
        document.querySelector("#mailAddress").innerHTML = json.mailAddress
        document.querySelector("#role").innerHTML = json.role
        document.querySelector("#personality").innerHTML = json.personality
        document.querySelector("#at").innerHTML = Date(json.createdAt + "000")
      }
    )
  }
}
</script>
