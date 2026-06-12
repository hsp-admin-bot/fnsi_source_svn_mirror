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
import { EventBus } from "@/compat/vue/event-bus.js";
export default {


  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>
