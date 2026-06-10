/**
 * Pageレイアウト
 * 他社がまだ使用しているため、残しておく
 * TODO 他社もvue-routerでの画面遷移に切り替え、使用しなくなった際に削除する
 */
<template id='base-page-template'>
  <div style="width:100%;height:100%;position:relative;overflow:hidden;" @click="onClick">
    <div class='header' id="headerContent">
      <div>
        <div>
          <header-content />
        </div>
        <div class='bread-crumbs'>
          <bread-crumbs-content :pageTitle = "component" />
        </div>
      </div>
    </div>
    <div class='main' id="mainContent">
      <main-content />
    </div>
  </div>
</template>

<script>
import { EventBus } from "@/eventBus.js";

export default {
  data() {
    return {
      component: ""
    };
  },
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
