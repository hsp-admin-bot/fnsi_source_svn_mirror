<template>
  <router-view></router-view>
</template>

<script>
import NextTransitionMixin from "@/components/NextTransitionMixin";

export default {
  mixins: [NextTransitionMixin],
  data() {
    return {};
  },
  computed: {},
  methods: {},
  mounted() {},
  destroyed() { },
  watch: {}
};
</script>
