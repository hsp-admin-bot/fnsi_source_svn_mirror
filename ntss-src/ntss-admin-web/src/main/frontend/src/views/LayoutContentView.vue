/**
 * ページレイアウト（RootViewの子コンポーネント）
 * `slot`にて、メインコンポーネントを差し込む
 * 親Viewにheaderがあり、main-contentのみを表示するViewで使用する
 * 親Viewのheightを基準にレイアウトするので
 * LayoutMixinによるメインコンポーネントのheight設定も行わない
 */
<template>
  <div class='content-container' @click="onClick">
    <div class='main main-font' style='height: 100%;'>
      <slot name='main-content' ref='mainComponent' />
    </div>
  </div>
</template>

<script>
import { EventBus } from "@/compat/vue/event-bus.js";
export default {
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
.main {
  height: 100% !important;
}
</style>
