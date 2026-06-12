/**
 * 画面分割用ページレイアウト（RootViewの子コンポーネント）
 * `slot`にて、ヘッダ・パンくずリスト・メインコンポーネントを差し込む
 * `router-view`にて、子画面として次の画面を差し込む
 */
<template>
  <div class='content-container' @click="onClick">
    <div class='content-box' :style='widthStyles'>
      <div class='header' ref="header">
        <div>
          <slot name='header-content' />
        </div>
        <div class='bread-crumbs' >
          <slot name='bread-crumbs-content' />
        </div>
      </div>
      <div class='main main-font' :style='heightStyles'>
        <slot name='main-content' ref='mainComponent' />
      </div>
    </div>
    <router-view />
  </div>
</template>

<script>
import { EventBus } from "@/compat/vue/event-bus.js";
import {
  queryScopedSelector,
  queryScopedSelectorAll
} from "@/functions/common/LayoutMeasureHelper";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import LayoutMixin from "@/views/LayoutMixin";

export default {
  mixins: [LayoutMixin],
  data() {
    return {
      // content-box クラスに設定されている min-width
      contentBoxWidth: 0
    };
  },
  computed: {
    ...mapGetters("window-size", {
      // 分割された画面の幅取得
      splittedWidth: "getSplittedWidth"
    }),
    ...mapGetters("account-edit", {
      isSplitFrame: "getSplitFrame"
    }),
    widthStyles() {
      // 分割された画面の幅をCSS変数を利用して書き換え
      return { "--width": `${this.splittedWidth - 1}px` };
    }
  },
  watch: {
    splittedWidth() {
      // 最低表示幅を下回ったら付けるスタイル
      const scopedDocument = this.$el?.ownerDocument || document;
      const objList = queryScopedSelectorAll(".content-box", scopedDocument);
      const target = objList[objList.length - 1];
      if (!target) {
        return;
      }

      if (this.splittedWidth < this.contentBoxWidth) {
        target.style.transform = `translate3d(calc(${this.contentBoxWidth}px - var(--width)), 0px, 0px)`;
      } else {
        target.style.transform = "";
      }
    },
    /**
     * 画面フレーム分割設定が更新された
     */
    isSplitFrame() {
      if (this.isSplitFrame) {
        // 画面分割数を設定
        this.setSplittableFrames();
      } else {
        // 画面分割数をクリア
        this.resetSplittableFrames();
      }
    }
  },
  methods: {
    ...mapActions("window-size", [
      "setSplittableFrames",
      "resetSplittableFrames"
    ]),
    onClick() {
      // ユーザーメニューを閉じる
      EventBus.$emit("closeUserMenu");
      // フッターのリストを閉じる
      EventBus.$emit("closeFooterList");
    }
  },
  mounted() {
    const scopedDocument = this.$el?.ownerDocument || document;
    const contentBox = queryScopedSelector(".content-box", scopedDocument);
    if (contentBox) {
      this.contentBoxWidth = Number(
        (contentBox.ownerDocument?.defaultView || this.$el?.ownerDocument?.defaultView || window).getComputedStyle(contentBox).minWidth.replace("px", "")
      );
    }
  }
};
</script>

<style scoped>
.content-container {
  display: flex;
  margin: 0;
  padding: 0;
  flex-direction: row;
  flex-wrap: nowrap;
  justify-content: flex-end;
}
.content-box {
  --width: 200px;
  width: var(--width);
  min-width: 200px;
  height: inherit;
  position: relative;
}
</style>
