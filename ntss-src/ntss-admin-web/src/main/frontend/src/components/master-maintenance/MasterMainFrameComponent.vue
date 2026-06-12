
<template>
  <router-view></router-view>
</template>

<script>
/**
 * マスターメンテナンスメインフレーム
 */
//import { mapGetters, mapActions } from "@/compat/vue/vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";

export default {
  mixins: [NextTransitionMixin],


};
</script>
