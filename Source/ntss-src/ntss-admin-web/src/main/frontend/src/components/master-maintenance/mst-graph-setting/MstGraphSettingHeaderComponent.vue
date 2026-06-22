/**
 * P-Ca9分割グラフ設定マスタメンテナンスレコードページ用ヘッダ
 */
<template>
  <v-card>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header'>
        <v-ons-col class='condition-search-col'>
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <v-ons-col>
          <div class="filter-area"></div>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover cancelable
                   v-model:visible='popoverVisible'
                   :target='popoverTarget'
                   :direction='popoverDirection'
                   :cover-target="false"
                   :class="fontSizeSet">
      <div style='margin:10px;'>
        <div v-if="isSearchFlg">
          <v-ons-row class='condition-row'>
            <v-ons-col width='40%' vertical-align='center'>
              <label>名称</label>
            </v-ons-col>
            <v-ons-col width='60%' vertical-align='center'>
              <v-ons-input input-id='recordName' type='text' float  v-model='condition.recordName' @keydown.enter='onSearchEnter'></v-ons-input>
            </v-ons-col>
          </v-ons-row>
          <div class='condition-row' style="height:30px;margin-bottom:5px;">
            <div style="float:left;">
              <v-ons-button class='btn2-cancel clear button' @click='dialogClear'>クリア</v-ons-button>
            </div>
            <div style="float:right;">
              <v-ons-button class='btn3-normal ok button' @click='dialogOk'>OK</v-ons-button>
            </div>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import PopoverMixin from "@/components/PopoverMixin";
import commonSearchArea from "@/components/common/CommonSearchArea";

export default {
  components: {
    "common-searcharea": commonSearchArea
  },
  mixins: [PopoverMixin],
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      condition: {
        recordName: ""
      },
      targetEmailAddress: "",
      isSortMode: false,
      isSearchFlg: false,
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    };
  },
  computed: {
    ...mapGetters("account-edit", {
      getTheme: "getTheme",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    correctStyle(){
      let color = "";
      if (this.getTheme === 0) {
        color = "white";
      }
      return { "background-color": `${ color }` };
    }
  },
  methods: {
    ...mapActions("mst-graph-setting", [
      "setCondition"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      // ソートモード時は表示しない
      if (this.isSortMode) {
        return;
      }
      this.isSearchFlg = true;
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検索条件クリアして画面を更新
      this.condition.recordName = "";
      // 共通検索エリア部品に表示するデータのリストを初期化
      this.conditionList = [];
      // 画面を閉じる
      this.popoverVisible = false;
      this.search();
    },
    // -----------------------------------------
    // 抽出条件Enter押下時イベント
    // -----------------------------------------
    onSearchEnter : function(){
      this.dialogOk();
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      this.popoverVisible = false;
      this.setConditionList();
      this.search();
    },
    // -----------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // -----------------------------------------
    search() {
      // 検索条件の内容で画面を更新
      this.setCondition(JSON.parse(JSON.stringify(this.condition)));
    },
    setSortMode(isSortMode) {
      // 検索条件の内容で画面を更新
      this.isSortMode = isSortMode;
      if (this.isSortMode) {
        // ソートモード時は条件クリア
        this.dialogClear();
      }
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      const condObj = this.condition;
      // 名称
      if (condObj.recordName != "") {
        condList.push({ name:"名称", text:condObj.recordName });
      }
      this.conditionList = condList;
    }
  },
  created() {
    EventBus.$on("setSortMode", this.setSortMode);
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
  },
  beforeUnmount() {
    EventBus.$off("setSortMode", this.setSortMode);
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>

</style>
