<!-- 
 患者情報・患者情報カード一覧
-->
<template>
  <main-content class="main-content">
    <div
      v-if="selectedPat !== null && startRenderPatInfoContent"
      id="card"
      class="card-list"
      :style="cardListStyle"
      ref="cardListDiv"
      @scroll="scrollHandler"
    >
    <!-- #9271 パンくずを押しても内容の最新データの表示がされない。 linjunfeng start -->
      <card-list
        ref="cardList"
        :pat-record="selectedPat"
        :history-key="historyKey"
        @card-list-mounted="cardListMountedHandler"
        @card-list-refresh="cardListRefreshHandler"
      />
      <!-- #9271 パンくずを押しても内容の最新データの表示がされない。 linjunfeng end -->
    </div>
    <div v-if="selectedPat !== null" class="type-right">
      <img class="menu-btn" id="menu-btn" :src="imgUrl" ref="menuBtn" @click="menuDisplay()" />
    </div>
  </main-content>
</template>

<script>
import { mapState, mapGetters, mapMutations } from "@/compat/vue/vuex";
import cardList from "@/components/pat-info/PatInfoCardList.vue";
import PatInfoContentMixin from "@/components/pat-info/PatInfoContentMixin.js"
import { EventBus } from "@/compat/vue/event-bus.js";

export default {
  inject: {
    getNtssLayoutRootElement: { default: null },
    getNtssFooterMenuElement: { default: null }
  },
  data() {
    return {
      // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 start
      cardListName: "patInfo"
      // 11729 患者情報・新規患者登録画面のカード展開/折畳状態の保持不正 end
    };
  },
  props: {
    historyKey: null
  },
  components: {
    "card-list": cardList,
  },
  mixins: [PatInfoContentMixin],
  mounted() {
    EventBus.$off("switchSidebar", this.handleSwitchSidebar);
    EventBus.$on("switchSidebar", this.handleSwitchSidebar);
    this.calculateContentHeight();
  },
  computed: {
    ...mapState("pat-info", ["startRenderPatInfoContent"]),
    ...mapGetters("pat-info", ["selectedPat", "getCardListScrollPos"]),
    ...mapGetters("account-edit", ["getTheme", "isDispMenu"]),
    ...mapGetters("account-edit", { getFontSize: "getFontSize" }),
    ...mapGetters("window-size", { windowWidth: "getSplittedWidth", windowHeight: "getWindowHeight" }),
    /**
     * カード一覧領域のインラインスタイルを返す
     * 
     * メニューバーの表示状態に応じて、カード一覧領域<div id="card" class="card-list"...>のwidth／margin-leftを切替える。
     * メニューバーopen時は左側にメニューバー幅(143px)を確保し、close時は確保しない。
     */
    cardListStyle() {
      if (this.isMenuBarShowing) {
        return {
          width: this.windowWidth - 143 + "px",
          marginLeft: "143px"
        };
      }
      return {
        width: this.windowWidth + "px",
        marginLeft: "0px"
      };
    },
  },
  watch: {
    isMenuBarShowing() {
      this.$nextTick(() => {
        this.$refs.cardList?.updateMasonry?.();
      });
    },
    windowHeight(val) {
      // mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start
      const btn = this.getPatInfoFirstByClassName("right-exe-btn");
      if (!btn) {
        return;
      }
      const headerHeight = this.getPatInfoFirstByClassName("header")?.offsetHeight || 0;
      const footHeight = (typeof this.getNtssFooterMenuElement === "function"
        ? this.getNtssFooterMenuElement()
        : this.getPatInfoElementById("footer-menu"))?.clientHeight || 0;
      const cardListDOM = this.$refs.cardListDiv || this.getPatInfoFirstByClassName("card-list");
      const btnHeight = btn.clientHeight;
      const cardListNewHeight = val - headerHeight - footHeight - btnHeight - 4;
      // mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end
      if (cardListDOM) {
        cardListDOM.style.height = cardListNewHeight + "px";
      }
    },
    getFontSize() {
      // mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start
      const btn = this.getPatInfoFirstByClassName("right-exe-btn");
      if (!btn) {
        return;
      }
      const headerHeight = this.getPatInfoFirstByClassName("header")?.offsetHeight || 0;
      const footHeight = (typeof this.getNtssFooterMenuElement === "function"
        ? this.getNtssFooterMenuElement()
        : this.getPatInfoElementById("footer-menu"))?.clientHeight || 0;
      const cardListDOM = this.$refs.cardListDiv || this.getPatInfoFirstByClassName("card-list");
      const btnHeight = btn.clientHeight;
      const cardListNewHeight = this.windowHeight - headerHeight - footHeight - btnHeight - 4;
      // mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end
      if (cardListDOM) {
        cardListDOM.style.height = cardListNewHeight + "px";
      }
    },
    isDispMenu() {
      this.calculateContentHeight();
    }
  },
  // 患者情報画面ページ表示中は患者情報ヘッダからカード一覧を表示させなくする
  created() {
    /* modify by shiyinwang 2022-08-26 [6119] Here, set true is more readable than toggle--start */
    this.setIsPatInfoPageShowing(true);
    /* modify by shiyinwang 2022-08-26 [6119]  Here, set true is more readable than toggle--end */
  },
  // 患者情報画面ページ表示中フラグを折る

  methods: {
    /* modify by shiyinwang 2022-08-26 [6119] Here, set true is more readable than toggle--start */
    ...mapMutations("pat-info", ["setIsPatInfoPageShowing", "setCardListScrollPos"]),
    /* modify by shiyinwang 2022-08-26 [6119] Here, set true is more readable than toggle--end */
    handleSwitchSidebar() {
      this.$nextTick(() => {
        this.$refs.cardList?.updateMasonry?.();
      });
    },
    calculateContentHeight() {
      // mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start
      const btn = this.getPatInfoFirstByClassName("right-exe-btn");
      if (!btn) {
        return;
      }
      const headerHeight = this.getPatInfoFirstByClassName("header")?.offsetHeight || 0;
      const windowHeight = this.windowHeight;
      const footHeight = (typeof this.getNtssFooterMenuElement === "function"
        ? this.getNtssFooterMenuElement()
        : this.getPatInfoElementById("footer-menu"))?.clientHeight || 0;
      const cardListDOM = this.$refs.cardListDiv || this.getPatInfoFirstByClassName("card-list");
      const btnHeight = btn.clientHeight;
      // 6512 何も編集していないが、保存ボタンが押せてしまう。 周
      if (!cardListDOM) {
        return;
      }
      let cardListNewHeight = windowHeight - headerHeight - footHeight - btnHeight - 4;
      cardListDOM.style.height = cardListNewHeight + "px";
      // mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end
    }
  },
  beforeUnmount() {
    this.setIsPatInfoPageShowing(false); // add by shiyinwang 2022-08-26 [6119] When leaving the patient information page, set the variable IsPatInfoPageShowing to false
    EventBus.$off("switchSidebar", this.handleSwitchSidebar);
  }

};
</script>

<style scoped>
@media print {
  .main-content :deep(div){
    height: auto !important;
  }
  /** 見出し開閉ボタン非表示 */
  .type-right {
    display: none;
  }
}
.card-list {
  overflow-y: scroll;
  position: absolute;
  top: 0;
  bottom: 34px;
}
.block {
  display: block;
}
.none {
  display: none;
}
.type-right {
  margin-left: 143px;
}
</style>
