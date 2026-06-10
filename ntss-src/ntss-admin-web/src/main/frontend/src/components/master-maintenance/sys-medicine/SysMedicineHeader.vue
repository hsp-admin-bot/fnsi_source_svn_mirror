/**
 * マスタメンテナンスレコードページ用ヘッダ
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
                   :visible.sync='popoverVisible'
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
            <v-ons-input input-id='recordName' type='text' float  v-model='condition.inProgress.recordName' @keydown.enter='onSearchEnter'></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class='btn2-cancel clear' @click='dialogClear'>クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class='btn3-normal ok' @click='dialogOk'>OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapActions } from "vuex";
import { EventBus } from "@/eventBus";
import PopoverMixin from "@/components/PopoverMixin";
import { mapGetters } from "vuex";
import commonSearchArea from "@/components/common/CommonSearchArea";
import {ApiHelper} from "@/apis/AxiosHelper";
import {deepCopy} from "@/functions/common/CommonFunctions";

export default {
  components: {
    "common-searcharea": commonSearchArea
  },
  mixins: [PopoverMixin],
  data() {
    const defaultCondition = {
      recordName: "",
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
        }
      },
      isSortMode: false,
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      masterPhysicalName: "getMasterName",
      getMasterRecordList: "getMasterRecordList"
    }),
  },
  methods: {
    ...mapActions("master-maintenance", [
      "setMasterRecordList",
      "setCondition",
      "edit",
      // add 5515 標準医薬品マスタ検索で検索できない 周安寧 start
      "findRecordListByFacilityCd",
      // mod 5515 標準医薬品マスタ検索で検索できない 周安寧 end
    ]),
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      // add 5515 標準医薬品マスタ検索で検索できない 周安寧 start
      setLoadingScreenMessage: "setLoadingScreenMessage"
      // add 5515 標準医薬品マスタ検索で検索できない 周安寧 end
    }),

    // 抽出UI表示イベント
    showPopover(event) {
      // ソートモード時は表示しない
      if (this.isSortMode) {
        return;
      }
      this.copyConditionInUsedToInProgress();
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // 抽出条件クリアボタンクリックイベント
    dialogClear() {
      this.setLoadingScreenVisible(true);
      // 検索条件クリアして画面を更新
      this.condition.inProgress.recordName = this.defaultCondition.recordName;
      this.condition.inProgress.includeDeleted = this.defaultCondition.includeDeleted;
      this.condition.inUsed.recordName = this.defaultCondition.recordName;
      this.condition.inUsed.includeDeleted = this.defaultCondition.includeDeleted;
      // 共通検索エリア部品に表示するデータのリストを初期化
      this.conditionList = [];
      // 画面を閉じる
      this.popoverVisible = false;
      this.search();
      this.setLoadingScreenVisible(false);
    },

    // 抽出条件Enter押下時イベント
    onSearchEnter : function(){
        this.dialogOk();
    },

    // 抽出条件OKボタンクリックイベント
    dialogOk() {
      this.popoverVisible = false;
      this.search();
    },

    // 処理：抽出条件を元にした検索イベント
    async search() {
      // add 5515 標準医薬品マスタ検索で検索できない 周安寧 start
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);
      // add 5515 標準医薬品マスタ検索で検索できない 周安寧 end
      if (this.condition.inProgress.recordName !== "") {
        const offset = 0;
        await ApiHelper.get("/sys_medicine/getSysMedicineByLimitAndOffset/" + offset + "/" + this.condition.inProgress.recordName).then(response => {
          let temp = deepCopy(this.getMasterRecordList);
          response.data.forEach(e => {
            e.name = e.salesName;
            e.code = e.standardNo;
            e.receiptCd1 = e.receiptCd_1;
            e.receiptCd2 = e.receiptCd_2;
          });
          temp.data = response.data;
          this.setMasterRecordList(temp);
        });
      } else {
        // mod 5515 標準医薬品マスタ検索で検索できない 周安寧 start
        await this.findRecordListByFacilityCd(this.getFacilitySwitch)
        // await ApiHelper.get("/sys_medicine/getSysMedicineByLimitAndOffset/100").then(response => {
        //   // ソート関数
        //   const compare = (a, b) => {
        //     if (a.standardNo < b.standardNo) {
        //       return -1;
        //     }
        //     if (a.standardNo > b.standardNo) {
        //       return 1;
        //     }
        //     return 0;
        //   };
        //   let temp = deepCopy(this.getMasterRecordList);
        //   response.data.forEach(e => {
        //     e.name = e.salesName;
        //   });
        //   temp.data = response.data;
        //   temp.data.sort(compare)
          //this.setMasterRecordList(this.getFilteredMasterRecordList);
        //})
        // mod 5515 標準医薬品マスタ検索で検索できない 周安寧 end
      }
      this.copyConditionInProgressToInUsed();
      // 検索条件の内容で画面を更新
      this.setCondition(JSON.parse(JSON.stringify(this.condition.inUsed)));
      EventBus.$emit("onSearchForMstVirtualScrollable");
      // add 5515 標準医薬品マスタ検索で検索できない 周安寧 start
      this.setLoadingScreenVisible(false);
      // add 5515 標準医薬品マスタ検索で検索できない 周安寧 end
    },
    setSortMode(isSortMode) {
      // 検索条件の内容で画面を更新
      this.isSortMode = isSortMode;
      if (this.isSortMode) {
        // ソートモード時は条件クリア
        this.dialogClear();
      }
    },
    copyConditionInProgressToInUsed() {
      this.condition.inUsed.recordName = this.condition.inProgress.recordName;
      this.condition.inUsed.includeDeleted = this.condition.inProgress.includeDeleted;
      this.setConditionList();
    },
    copyConditionInUsedToInProgress() {
      this.condition.inProgress.recordName = this.condition.inUsed.recordName;
      this.condition.inProgress.includeDeleted = this.condition.inUsed.includeDeleted;
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      const condObj = this.condition.inUsed;
      // 名称
      if (condObj.recordName != "") {
        condList.push({ name:"名称", text:condObj.recordName });
      }
      // 削除を表示
      if (condObj.includeDeleted) {
        condList.push({ text:"削除を表示" });
      }
      this.conditionList = condList;
    },
    // add マスタ障害対応 No43 孔 start
    clearHeaderSearch(){
      this.condition.inProgress.recordName = this.defaultCondition.recordName;
      this.condition.inProgress.includeDeleted = this.defaultCondition.includeDeleted;
      this.condition.inUsed.recordName = this.defaultCondition.recordName;
      this.condition.inUsed.includeDeleted = this.defaultCondition.includeDeleted;
      // 共通検索エリア部品に表示するデータのリストを初期化
      this.conditionList = [];
    }
    // add マスタ障害対応 No43 孔 end
  },
  created() {
    EventBus.$on("setSortMode", this.setSortMode);
    // add マスタ障害対応 No43 孔 start
    EventBus.$on("clearHeaderSearch", this.clearHeaderSearch);
    // add マスタ障害対応 No43 孔 end
    // add #9590 start
    EventBus.$on("handleSearch", this.search);
    // add #9590 end
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("setSortMode", this.setSortMode);
    EventBus.$off("clearHeaderSearch", this.clearHeaderSearch);
    // add #9590 start
    EventBus.$off("handleSearch", this.search);
    // add #9590 end
  }
  // add 性能改善メモリ不足 shan end
};
</script>
