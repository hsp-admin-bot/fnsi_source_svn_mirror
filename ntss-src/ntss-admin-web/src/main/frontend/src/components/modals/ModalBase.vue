/**
 * ModalPageレイアウト
 */
<template>
  <div class="modal-mask">
    <div class="modal-wrapper">
      <div class="modal-container">
        <div class="modal-header">
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
        <div v-if="$slots['search-area']" class="modal-search">
          <slot name="search-area"></slot>
        </div>
        <div v-if="$slots['body']" :class="changeBodyClass()" id="scrollbody">
          <slot name="body"></slot>
        </div>
        <!-- mod #6449 アカウント情報で、2要素認証未登録の状態で秘密鍵作成ボタンを押下した際、画面最下部へとスクロールさせる 付 end -->
        <div v-if="this.showFooter && $slots['footer']" class="modal-footer">
          <v-ons-bottom-toolbar>
            <slot name="footer"></slot>
          </v-ons-bottom-toolbar>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState, mapGetters } from "@/compat/vue/vuex";
import UserAuthorityMixin from "@/components/common/UserAuthorityMixin";
import { getContentContainerElement, getScopedElementById, getScopedWindow } from "@/functions/common/LayoutMeasureHelper";

export default {
  mixins: [UserAuthorityMixin],
  props: {
    showFooter: {
      type: Boolean,
      default: true
    }
  },
  computed: {
    ...mapState("multi-modal", ["modalTitle"])
  },
  methods: {
    ...mapGetters("multi-modal", ["getAuthorityCds"]),
    // 検索があるモーダルかどうかでbody部のスタイルクラスを変更する.
    changeBodyClass() {
      if (!this.showFooter) {
        // フッターなしの場合(検索エリアはない前提)
        return "modal-body-no-footer";
      }
      return !this.$slots["search-area"] ? "modal-body" : "modal-body-search";
    },
    //  add #6449 アカウント情報で、2要素認証未登録の状態で秘密鍵作成ボタンを押下した際、画面最下部へとスクロールさせる 付 start
    scrollToBottom () {
      const div = getScopedElementById('scrollbody', this.$el || null);
      if (div) {
        div.scrollTo(0, div.scrollHeight - div.clientHeight);
      }
    },
    getPrintContentContainer() {
      return getContentContainerElement(this.$el || null);
    },
    //  add #6449 アカウント情報で、2要素認証未登録の状態で秘密鍵作成ボタンを押下した際、画面最下部へとスクロールさせる 付 end
  },
  mounted() {
    // 利用権限がない場合入力部品を操作不可にする
    this.authorityCds = this.getAuthorityCds();
    this.disableElement(this.$el);
    const ownerWindow = getScopedWindow(this.$el || null);
    this._printOwnerWindow = ownerWindow;
    if (!ownerWindow) {
      return;
    }
    this._handleBeforePrintModal = () => {
      //印刷不要な要素を非表示にする
      const contentContainer = this.getPrintContentContainer();
      if (contentContainer) {
        contentContainer.style.display = 'none';
      }
    };
    this._handleAfterPrintModal = () => {
      //隠し要素を放す
      const contentContainer = this.getPrintContentContainer();
      if (contentContainer) {
        contentContainer.style.display = '';
      }
    };
    ownerWindow.addEventListener("beforeprint", this._handleBeforePrintModal);
    ownerWindow.addEventListener("afterprint", this._handleAfterPrintModal);
  },
  beforeUnmount () {
    const ownerWindow = this._printOwnerWindow || getScopedWindow(this.$el || null);
    if (ownerWindow) {
      ownerWindow.removeEventListener("beforeprint", this._handleBeforePrintModal);
      ownerWindow.removeEventListener("afterprint", this._handleAfterPrintModal);
    }
    this._printOwnerWindow = null;
    this._handleBeforePrintModal = null;
    this._handleAfterPrintModal = null;
  }
};
</script>

<style scoped>
@import "../../assets/styles/modal.css";
/*
 * TODO 以下のように、cssのパスをエイリアスで設定できるようにしたい。
 * @import "@/assets/styles/modal.css";
 *
 * webpackでエイリアスを設定すればできそう。
 * https://vue-loader-v14.vuejs.org/ja/configurations/asset-url.html
 */
</style>
