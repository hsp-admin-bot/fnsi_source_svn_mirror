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
import { mapState, mapGetters, mapMutations } from "vuex";
import cardList from "@/components/pat-info/PatInfoCardList.vue";
import PatInfoContentMixin from "@/components/pat-info/PatInfoContentMixin.js"
import { EventBus } from "@/eventBus.js";

export default {
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
    EventBus.$off("switchSidebar")
    EventBus.$on("switchSidebar", () => {
      let SideBarIsOpen = document.getElementById("patientSearchSidebarArea").style.cssText.toString().indexOf("transform:") === -1;
      // 6512 何も編集していないが、保存ボタンが押せてしまう。 周
      let BarIsOpen =
        (undefined !== document.getElementById("menu-bar-id") && null !== document.getElementById("menu-bar-id"))
          ? document.getElementById("menu-bar-id").classList.contains("block") : null;
      let ClientWidth = document.documentElement.clientWidth;
      let cardElem = document.getElementById("card");
      if (!cardElem) {
        return;
      }
      if (!SideBarIsOpen) {
        if (BarIsOpen) {
          document.getElementById("card").style.width = ClientWidth - 143 + "px";
        } else {
          document.getElementById("card").style.width = ClientWidth + "px";
        }
      } else {
        if (BarIsOpen) {
          document.getElementById("card").style.width = ClientWidth - 443 + "px";
        } else {
          document.getElementById("card").style.width = ClientWidth - 300 + "px";
        }
      }
    });
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
    windowHeight(val) {
      // mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start
      let btn = document.getElementsByClassName("right-exe-btn")[0];
      if (!btn) {
        return;
      }
      let headerHeight = document.getElementsByClassName("header")[0].offsetHeight;
      let footHeight = document.getElementById("footer-menu").clientHeight;
      let cardListDOM = document.getElementsByClassName("card-list")[0];
      let btnHeight = btn.clientHeight;
      let cardListNewHeight = val - headerHeight - footHeight - btnHeight - 4;
      // mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end
      if (undefined !== cardListDOM) {
        cardListDOM.style.height = cardListNewHeight + "px";
      }
    },
    getFontSize() {
      // mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start
      let btn = document.getElementsByClassName("right-exe-btn")[0];
      if (!btn) {
        return;
      }
      let headerHeight = document.getElementsByClassName("header")[0].offsetHeight;
      let footHeight = document.getElementById("footer-menu").clientHeight;
      let cardListDOM = document.getElementsByClassName("card-list")[0];
      let btnHeight = btn.clientHeight;
      let cardListNewHeight = this.windowHeight - headerHeight - footHeight - btnHeight - 4;
      // mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end
      cardListDOM.style.height = cardListNewHeight + "px";
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
  destroyed() {
  },
  methods: {
    /* modify by shiyinwang 2022-08-26 [6119] Here, set true is more readable than toggle--start */
    ...mapMutations("pat-info", ["setIsPatInfoPageShowing", "setCardListScrollPos"]),
    /* modify by shiyinwang 2022-08-26 [6119] Here, set true is more readable than toggle--end */
    calculateContentHeight() {
      // mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 start
      let btn = document.getElementsByClassName("right-exe-btn")[0];
      if (!btn) {
        return;
      }
      let headerHeight = document.getElementsByClassName("header")[0].offsetHeight;
      let windowHeight = this.windowHeight;
      const footHeight = document.getElementById("footer-menu").clientHeight;
      let cardListDOM = document.getElementsByClassName("card-list")[0];
      let btnHeight = btn.clientHeight;
      // 6512 何も編集していないが、保存ボタンが押せてしまう。 周
      if (undefined === cardListDOM || null === cardListDOM) {
        return;
      }
      let cardListNewHeight = windowHeight - headerHeight - footHeight - btnHeight - 4;
      cardListDOM.style.height = cardListNewHeight + "px";
      // mod #10260 文字サイズ特大にしたときに保存、キャンセルボタンの高さに白背景があっていない。不要な余白の排除 宮崎 end
    }
  },
  beforeDestroy() {
    this.setIsPatInfoPageShowing(false); // add by shiyinwang 2022-08-26 [6119] When leaving the patient information page, set the variable IsPatInfoPageShowing to false
    EventBus.$off("switchSidebar");
  }

};
</script>

<style scoped>
@media print {
  .main-content >>> div {
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
