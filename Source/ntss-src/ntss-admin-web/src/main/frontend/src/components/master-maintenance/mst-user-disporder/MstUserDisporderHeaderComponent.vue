/**
 * 利用者マスタメンテナンスレコードページ用ヘッダ
 */
<template>
  <v-card>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header'>
        <v-ons-col class='condition-search-col'>
        </v-ons-col>
        <v-ons-col>
        </v-ons-col>
      </v-ons-row>
    </div>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { EventBus } from "@/compat/vue/event-bus.js";

export default {
  data() {
    return {
      condition: {
        recordName: ""
      },
    };
  },

  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
</style>
