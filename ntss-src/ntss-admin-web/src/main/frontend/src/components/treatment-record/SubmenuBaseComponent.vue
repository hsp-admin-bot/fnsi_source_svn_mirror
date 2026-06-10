/**
 * 単一レイアウトを持つ子機能のページレイアウト
 */
<template id='submenu-base-page'>
  <div class="submenu-container">
    <div>
      <slot name="header" />
    </div>
    <div class="submenu-main">
      <slot name="main" />
    </div>
    <div v-show="showSubmenuFooter" class="submenu-footer">
      <slot name="footer" />
    </div>
  </div>
</template>

<script>
export default {
  data() {
    return {
      /**
       * フッターメニュー表示有無
       * true:表示する(デフォルト)
       * false:表示しない
       */
      showSubmenuFooter : true,
    };
  },
  /**
   * インスタンスが生成された後の処理
   */
  created() {
    // footerメニューの表示変数を初期化
    this.showSubmenuFooter = true;
    // 装置設定の場合、footerメニューを非表示にする.
    if (this.$router.currentRoute.name === "treatment-record-setting" || 
        this.$router.currentRoute.name === "treatment-record-complaint") {
      this.showSubmenuFooter = false;
    }
  }
};
</script>

<style scoped>
.submenu-container {
  height: 100%;
  display: flex;
  flex-direction: column;
}

.submenu-main {
  overflow: auto;
  z-index: 1;
  width: 100%;
  height: 100%;
}
.submenu-main
  > div:not(#weight-component):not(#result-component):not(#condition-component):not(#setting-component):not(#round-component):not(#vital-component):not(#monitor-component) {
  min-width: 400px;
}

.submenu-footer {
  z-index: 2;
  width: 100%;
}
</style>
