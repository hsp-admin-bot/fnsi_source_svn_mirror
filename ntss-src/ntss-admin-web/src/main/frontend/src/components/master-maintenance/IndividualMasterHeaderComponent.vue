/**
 * 個別マスタメンテナンスページ用ヘッダ
 */
<template>
  <v-card>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header'>
      </v-ons-row>
    </div>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { EventBus } from "@/eventBus.js";
export default {
  data() {
    return {};
  },
  computed: {},
  methods: {},
  created() {},
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>
