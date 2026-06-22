<template>
  <v-ons-modal :visible="isVisible">
    <p class="loading-modal">
      {{ value }}
      <v-ons-icon icon="fa-spinner" spin />
    </p>
  </v-ons-modal>
</template>

<script>
/**
 * @description 共通ロード中モーダル
 */

import { mapGetters } from "vuex";

export default {
  props: {},
  computed: {
    ...mapGetters("loading-screen", {
      getLoadingScreenVisible: "getLoadingScreenVisible",
      getLoadingScreenMessage: "getLoadingScreenMessage"
    }),
    isVisible() {
      // storeからデータを取得
      return this.getLoadingScreenVisible;
    },
    value() {
      // storeからデータを取得
      return this.getLoadingScreenMessage;
    }
  },
  methods: {}
};
</script>

<style scoped>
.loading-modal {
  text-align: center;
  font-size: 30px;
}
</style>
