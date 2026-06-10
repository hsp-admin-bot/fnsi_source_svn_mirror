/**
 * ModalPageレイアウト
 */
<template>
  <transition name="sub-modal">
    <div class="sub-modal-mask">
      <div class="sub-modal-wrapper">
        <div class="sub-modal-container">
          <div class="sub-modal-header">
            <ons-toolbar>
              <div class="left toolbar__title">
                <span>{{ modalTitle }}</span>
              </div>
              <div class="right">
                <ons-toolbar-button class="close-btn print-none" @click="$emit('onClose')">
                  <ons-icon icon="fa-times"></ons-icon>
                </ons-toolbar-button>
              </div>
            </ons-toolbar>
          </div>
          <div class="sub-modal-search">
            <slot name="search-area"></slot>
          </div>
          <div :class="changeBodyClass()">
            <slot name="body"></slot>
          </div>

          <div v-if="this.showFooter" class="sub-modal-footer">
            <v-ons-bottom-toolbar>
              <slot name="footer"></slot>
            </v-ons-bottom-toolbar>
          </div>
        </div>
      </div>
    </div>
  </transition>
</template>

<script>
import { mapState, mapGetters, mapActions } from "vuex";
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";

export default {
  mixins: [UserAuthorityMixin],
  props: {
    showFooter: {
      type: Boolean,
      default: true
    }
  },
  computed: {
    ...mapState("multi-sub-modal", ["modalTitle"]),
    ...mapGetters("multi-modal", ["getModalName"]),
  },
  methods: {
    ...mapGetters("multi-sub-modal", ["getAuthorityCds"]),
    ...mapActions("multi-sub-modal", ["hideModal"]),
    // 検索があるモーダルかどうかでbody部のスタイルクラスを変更する.
    changeBodyClass() {
      if (!this.showFooter) {
        // フッターなしの場合(検索エリアはない前提)
        return "sub-modal-body-no-footer";
      }
      return !this.$slots["search-area"] ? "sub-modal-body" : "sub-modal-body-search";
    }
  },
  mounted() {
    // 利用権限がない場合入力部品を操作不可にする
    this.authorityCds = this.getAuthorityCds();
    this.disableElement(this.$el);
    // ハンドラをインスタンスに保持（remove用）
    // window.onbeforeprint、window.onafterprintはModalBaseの処理を上書きしてしまうので使用しない
    this._handleBeforePrintSubModal = () => {
      // 印刷不要な要素を非表示にする
      document.getElementsByClassName("content-container")[0].style.display = "none";
      const parentModal = document.getElementsByClassName("modal-mask")[0];
      if (parentModal) parentModal.style.display = "none";
    };
    this._handleAfterPrintSubModal = () => {
      // 元に戻す
      document.getElementsByClassName("content-container")[0].style.display = "";
      const parentModal = document.getElementsByClassName("modal-mask")[0];
      if (parentModal) parentModal.style.display = "";
    };
    window.addEventListener("beforeprint", this._handleBeforePrintSubModal);
    window.addEventListener("afterprint", this._handleAfterPrintSubModal);
  },
  beforeDestroy () {
    window.removeEventListener("beforeprint", this._handleBeforePrintSubModal);
    window.removeEventListener("afterprint", this._handleAfterPrintSubModal);
  },
  watch: {
    // 親モーダルが変更されたら閉じる
    getModalName() {
      this.hideModal();
    }
  }
};
</script>

<style scoped>
/* 印刷時スタイル */
@media print {
  .print-none {
    display: none;
  }
}
/*
 * TODO 以下のように、cssのパスをエイリアスで設定できるようにしたい。
 * @import "@/assets/styles/modal.css";
 *
 * webpackでエイリアスを設定すればできそう。
 * https://vue-loader-v14.vuejs.org/ja/configurations/asset-url.html
 */

@import "../../assets/styles/subModal.css";
</style>
