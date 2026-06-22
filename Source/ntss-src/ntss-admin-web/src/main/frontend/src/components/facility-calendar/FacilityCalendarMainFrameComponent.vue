<template>
  <router-view></router-view>
</template>

<script>
/**
 * 観察記録メインフレーム
 */
import NextTransitionMixin from "@/components/NextTransitionMixin";

export default {
  mixins: [NextTransitionMixin]
};
</script>
