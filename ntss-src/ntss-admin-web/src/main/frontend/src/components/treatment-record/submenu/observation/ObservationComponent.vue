/**
 * 治療記録の子機能 観察記録ページ
 */
<template>
  <div id="observation-component">
    <main-component :history-key="historyKey" />
  </div>
</template>

<script>
import { mapGetters, mapActions } from "vuex"
import MainComponent from "@/components/observe-record/ObserveRecordMainComponent";
import { HISTORY_KEY_OBSERVE_RECORD_LIST } from "@/router/observe-record/HistoryKeyConstants";
import { EventBus } from "@/eventBus.js";

export default {
  components: {
    "main-component": MainComponent,
  },
  data() {
    return {
      historyKey: HISTORY_KEY_OBSERVE_RECORD_LIST,
      selfScreenName: ""
    };
  },
  watch: {
    getOrdNo() {
      this.refresh();
    }
  },
  methods: {
    ...mapGetters("treatment-record/common", ["getOrdNo"]),
    ...mapActions("observe-record/list", ["setOrdNo"]),
    /**
     * 再描画処理
     */
    refresh() {
      // 子機能ボタンエリアの更新
      this.$emit("update");
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      this.setOrdNo(this.getOrdNo());
    }
  },
  created() {
    // 観察記録へオーダ番号を引き渡す
    this.setOrdNo(this.getOrdNo());
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    // イベント登録
    EventBus.$on("refresh", this.refresh);

  },
  /**
   * コンポーネント破棄
   */
  beforeDestroy() {
    // イベント解除
    // del refresh方法処理不正について、対応する。 dengshen start
    // EventBus.$off("refresh");
    // del refresh方法処理不正について、対応する。 dengshen end
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    EventBus.$off("refresh", this.refresh);
    // add #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
  }
};
</script>

<style scoped>
#observation-component >>> div.main-content-area,
#observation-component >>> table.ntss-list {
  position: relative;
  top: 0 !important;
}
</style>
