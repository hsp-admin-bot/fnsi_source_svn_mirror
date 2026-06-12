/**
 * マスタ編集（愁訴処置マスタ）ヘッダコンポーネント
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
                   :cover-target=false
                   :class="[fontSizeSet, 'master-search']"
                   >
      <div style='margin:10px;'>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>名称</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-input input-id='freeWord' type='text' float  v-model='condition.inProgress.freeWord' @keydown.enter='onSearchEnter'></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <v-ons-checkbox input-id='includeDeleted' float  v-model='condition.inProgress.includeDeleted'></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <label for="includeDeleted">削除を表示する</label>
          </v-ons-col>
        </v-ons-row>
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class='clear btn2-cancel' @click='dialogClear'>クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class='ok btn3-normal' @click='dialogOk'>OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<script>
import { mapActions } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import PopoverMixin from "@/components/PopoverMixin";
import commonSearchArea from "@/components/common/CommonSearchArea";

export default {
  components: {
    "common-searcharea": commonSearchArea
  },
  mixins: [PopoverMixin],
  data() {
    const defaultCondition = {
      freeWord: "",
      includeDeleted: false
    };
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      defaultCondition: defaultCondition,
      condition: {
        // 入力中の検索条件
        inProgress: {
          ...defaultCondition
        },
        // 実際に検索に使用される条件
        inUsed: {
          ...defaultCondition
        },
        isSortMode: false
      },
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    }
  },
  methods: {
    ...mapActions("mst-complaint", [
      "setCondition",
      "setChangeFlg",
    ]),
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      // ソートモード時は表示しない
      if (this.isSortMode) {
        return;
      }
      this.copyConditionInUsedToInProgress();
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検索条件クリアして画面を更新
      this.condition.inProgress.freeWord = this.defaultCondition.freeWord;
      this.condition.inProgress.includeDeleted = this.defaultCondition.includeDeleted;
      this.condition.inUsed.freeWord = this.defaultCondition.freeWord;
      this.condition.inUsed.includeDeleted = this.defaultCondition.includeDeleted;
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
      this.search();
    },
    // -----------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // -----------------------------------------
    search() {
      this.copyConditionInProgressToInUsed();
      // 検索条件の内容で画面を更新
      this.setCondition(JSON.parse(JSON.stringify(this.condition.inUsed)));
      // MstComplaintMainComponentのdataSource()プロパティが再評価されるようにするため
      // this.getFilteredDataSourceで使用しているchangeFlgを初期化する
      this.setChangeFlg(false);
    },
    setSortModeComplaint(isSortMode) {
      this.isSortMode = isSortMode;
      if (this.isSortMode) {
        // ソートモード時は条件クリア
        this.dialogClear();
      }
    },
    copyConditionInProgressToInUsed() {
      this.condition.inUsed.freeWord = this.condition.inProgress.freeWord;
      this.condition.inUsed.includeDeleted = this.condition.inProgress.includeDeleted;
      this.setConditionList();
    },
    copyConditionInUsedToInProgress() {
      this.condition.inProgress.freeWord = this.condition.inUsed.freeWord;
      this.condition.inProgress.includeDeleted = this.condition.inUsed.includeDeleted;
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      const condObj = this.condition.inUsed;
      // 名称
      if (condObj.freeWord != "") {
        condList.push({ name:"名称", text:condObj.freeWord });
      }
      // 削除を表示
      if (condObj.includeDeleted) {
        condList.push({ text:"削除を表示" });
      }
      this.conditionList = condList;
    }
  },
  created() {
    EventBus.$on("setSortModeComplaint", this.setSortModeComplaint);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("setSortModeComplaint", this.setSortModeComplaint);
  },
  // add 性能改善メモリ不足 shan start
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
}
</script>
