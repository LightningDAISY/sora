<template>
  <footer class="footer custom-footer">
    <div class="has-text-centered skew-block skew-block-right">
      <p>
        {{ copyright }}
      </p>
    </div>
  </footer>
</template>

<script>
export default {
  name: 'Footer',
  data () {
    return {
      env: process.env,
      copyright: process.env.COPYRIGHT
    }
  },
}

</script>

<style scoped>
a {
  color: #333;
}
.custom-footer {
  margin:60px 0 100px 0;
  background-color:transparent;
}

.skew-block-left {
  position: absolute;
  left:10px;
  transform:skew(0deg,-2deg);
}

.skew-block-right {
  position: absolute;
  right:10px;
  transform:skew(0deg,-2deg);
}

.skew-block {
  font-family: serif;
  width:300px;
  padding:10px;

  // radius
  border-radius:10px;
  -moz-border-radius:10px;
  -webkit-border-radius:10px;

  // border-shadow
  -webkit-box-shadow:5px 5px 5px 5px #ccc;
  -moz-box-shadow:5px 5px 5px 5px #ccc;
  box-shadow:5px 5px 5px 5px #ccc;

  // text-shadow
  text-shadow:3px 3px 3px #999;

  color:#666;
  background-color:#f7f7f7;

  border:1px solid #ccc;
}
</style>

