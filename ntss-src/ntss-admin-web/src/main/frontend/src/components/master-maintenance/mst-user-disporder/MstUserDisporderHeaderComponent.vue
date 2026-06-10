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
import { EventBus } from "@/eventBus.js";

export default {
  components: {
  },
  data() {
    return {
      condition: {
        recordName: ""
      },
    };
  },
  computed: {
  },
  methods: {
  },
  created() {
  },
  destroyed() {
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
</style>
