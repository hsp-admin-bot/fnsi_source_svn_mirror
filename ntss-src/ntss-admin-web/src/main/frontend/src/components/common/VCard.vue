<template>
  <div class="v-card"><slot /></div>
</template>

<script>
export default {
  name: "VCard"
};
</script>

<style scoped>
.v-card {
  display: block;
  width: 100%;
  box-sizing: border-box;
}
</style>
