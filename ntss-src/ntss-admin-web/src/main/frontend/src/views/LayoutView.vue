/**
 * ページレイアウト（RootViewの子コンポーネント）
 * `slot`にて、ヘッダ・パンくずリスト・メインコンポーネントを差し込む
 */
<template id='base-page-template'>
  <div class='content-container' @click="onClick">
    <div class='header' ref="header">
      <div>
        <slot name='header-content' />
      </div>
      <div class='bread-crumbs'>
        <slot name='bread-crumbs-content' />
      </div>
    </div>
    <div id="main-id" class='main main-font' :style='heightStyles'>
      <slot name='main-content' ref='mainComponent' />
    </div>
  </div>
</template>

<script>
import { EventBus } from "@/eventBus.js";
import LayoutMixin from "@/views/LayoutMixin";
export default {
  mixins: [LayoutMixin],
  methods: {
    onClick() {
      // ユーザーメニューを閉じる
      EventBus.$emit("closeUserMenu");
      // フッターのリストを閉じる
      EventBus.$emit("closeFooterList");
    }
  }
};
</script>

<style scoped>
.content-container {
  width: 100%;
  height: 100%;
  position: relative;
  overflow: hidden;
}

.header {
  z-index: 5;
}

.header > div:first-child {
  position: relative;
  z-index: 1;
}
</style>
