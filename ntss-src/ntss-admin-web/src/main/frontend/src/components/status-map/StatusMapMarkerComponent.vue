/**
 * マーカー(治療状況マップ)
 */
<template>
  <div class="marker"
    :style='{ backgroundColor: color }'>
  </div>
</template>

<script>
export default {
  components: {},
  computed: {},
  props: ["color"],
  methods: {},
  watch: {},
  beforeCreate() {},
  created() {},
  beforeMount() {},
  mounted() {},
  beforeUpdate() {},
  updated() {},
  beforeDestroy() { },
  destroyed() { }
};
</script>
<style scoped>
div.marker {
  pointer-events: none;
  border-radius: 0.5em;
  width: 0.8em;
  min-width: 0.8em;
  height: 0.8em;
  border: 0.05em solid #222;
  margin: 0.4em 0;
}
</style>
