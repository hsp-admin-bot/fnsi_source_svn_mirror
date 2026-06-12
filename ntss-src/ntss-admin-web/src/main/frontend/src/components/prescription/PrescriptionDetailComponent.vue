<!-- 処方画面 -->
<template>
  <div class='main-content-area'>
    <label style="font-size: 5em;">{{ msg }}</label>
  </div>
</template>

<script>

export default {
  data() {
    return {
      msg: "処方画面です。"
    };
  },

};
</script>

<style scoped>
.main-content-area {
  min-width: 200px;
}
</style>
