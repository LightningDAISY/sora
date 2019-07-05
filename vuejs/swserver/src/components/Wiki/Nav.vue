<template>
<nav class="level">
  <p class="level-item has-text-centered">
    <router-link to="/wiki" class="link is-info">Home</router-link>
  </p>
  <p class="level-item has-text-centered">
    <router-link to="/wiki/list" class="link is-info">EntryList</router-link>
  </p>
  <p class="level-item has-text-centered">
    <router-link to="/wiki/post" class="link is-info">NewEntry</router-link>
  </p>

</nav>
</template>

<script>
export default {
  name: 'WikiNav',
  data () {
    return {
    }
  },
  mounted: function() {
  },
}
</script>

<style scoped>
a {
  color: #444;
}
a:hover {
  color:#66c;
}
</style>

