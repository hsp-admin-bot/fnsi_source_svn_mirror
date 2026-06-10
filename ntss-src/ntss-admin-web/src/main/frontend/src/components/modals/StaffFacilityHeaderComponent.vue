/**
 * 担当施設一覧ページ用ヘッダ
 */
<template>
  <v-card>
    <div class='dialog-header-item'>
      <v-ons-row>
        <v-ons-col class='condition-search-col'>
          <common-searcharea :lineHeight="'3.8em'" :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
      </v-ons-row>
    </div>
    <v-ons-popover cancelable
                   :visible.sync='popoverVisible'
                   :target='popoverTarget'
                   :direction='popoverDirection'
                   :cover-target=false
                   :class="fontSizeSet"
                   >
      <!--mod FNSI-画面部品デザイン じょはく start-->
      <div class="fab-font-color" style='margin:10px;'>
        <!--mod FNSI-画面部品デザイン じょはく end-->
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label id="search-label-font">部署符号</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-select float v-model='searchCondition.inProgress.departmentCd'>
              <option>-</option>
              <option v-for='(departmentCd, idxDepartmentCd) in departmentCds' :key='idxDepartmentCd'>{{ departmentCd }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label id="search-label-font">都道府県</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-select float v-model='searchCondition.inProgress.prefName' style="display:">
              <option>-</option>
              <option v-for='prefectureName in prefectureNames' :key='prefectureName'>{{ prefectureName }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label id="search-label-font">施設名</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-input input-id='facilityName' type='text' float  v-model='searchCondition.inProgress.facilityName' modifier='AccountEditFacilityName'></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class='btn2-cancel clear' @click='dialogClear'>クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class='btn1-execute ok' @click='dialogOk'>OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<!-- スクリプト処理 -->
<script>
import { mapGetters, mapActions } from "vuex";
import PopoverMixin from "@/components/PopoverMixin";
import commonSearchArea from "@/components/common/CommonSearchArea";

export default {
  components: {
    "common-searcharea": commonSearchArea
  },
  mixins: [PopoverMixin],
  data() {
    const defaultCondition = {
      departmentCd: "-",
      prefName: "-",
      facilityName: ""
    };
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      defaultCondition: defaultCondition,
      searchCondition: {
        // 入力中の検索条件
        inProgress: {
          ...defaultCondition
        },
        // 実際に検索に使用される条件
        inUsed: {
          ...defaultCondition
        }
      },
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: []
    };
  },
  computed: {
    ...mapGetters("staff-facility", ["getCandidates"]),
    // -----------------------------------------
    // 部署符号の選択肢リスト取得
    // -----------------------------------------
    departmentCds() {
      return this.getCandidates.departmentCds;
    },
    // -----------------------------------------
    // 都道府県の選択肢リスト取得
    // -----------------------------------------
    prefectureNames() {
      return this.getCandidates.prefectureNames;
    }
  },
  methods: {
    ...mapGetters(`staff-facility`, ["getCondition"]),
    ...mapActions(`staff-facility`, ["setCondition"]),
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.copyConditionInUsedToInProgress();
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      this.clearCondition();
      // 画面を閉じる
      this.popoverVisible = false;
      // 検索条件クリア
      this.setCondition(this.searchCondition.inUsed);
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      this.copyConditionInProgressToInUsed();
      this.popoverVisible = false;
      this.search();
    },
    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    search() {
      this.setCondition(this.searchCondition.inUsed);
    },
    copyConditionInProgressToInUsed() {
      this.searchCondition.inUsed.departmentCd = this.searchCondition.inProgress.departmentCd;
      this.searchCondition.inUsed.prefName = this.searchCondition.inProgress.prefName;
      this.searchCondition.inUsed.facilityName = this.searchCondition.inProgress.facilityName;
      this.setConditionList();
    },
    copyConditionInUsedToInProgress() {
      this.searchCondition.inProgress.departmentCd = this.searchCondition.inUsed.departmentCd;
      this.searchCondition.inProgress.prefName = this.searchCondition.inUsed.prefName;
      this.searchCondition.inProgress.facilityName = this.searchCondition.inUsed.facilityName;
    },
    clearCondition() {
      this.searchCondition.inUsed.departmentCd = this.defaultCondition.departmentCd;
      this.searchCondition.inUsed.prefName = this.defaultCondition.prefName;
      this.searchCondition.inUsed.facilityName = this.defaultCondition.facilityName;
      this.searchCondition.inProgress.departmentCd = this.defaultCondition.departmentCd;
      this.searchCondition.inProgress.prefName = this.defaultCondition.prefName;
      this.searchCondition.inProgress.facilityName = this.defaultCondition.facilityName;
      // 共通検索エリア部品に表示するデータのリストを初期化
      this.conditionList = [];
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      let condList = [];
      const condObj = this.searchCondition.inUsed;
      // 部署符号
      if (condObj.departmentCd != "" && condObj.departmentCd != "-") {
        condList.push({ name:"部署符号", text:condObj.departmentCd });
      }
      // 都道府県
      if (condObj.prefName != "" && condObj.prefName != "-") {
        condList.push({ name:"都道府県", text:condObj.prefName });
      }
      // 施設名
      if (condObj.facilityName != "") {
        condList.push({ name:"施設名", text:condObj.facilityName });
      }
      this.conditionList = condList;
    }
  },
  created() {
    const storedCondition = this.getCondition();
    if (storedCondition) {
      this.searchCondition.inUsed.departmentCd = storedCondition.departmentCd;
      this.searchCondition.inUsed.prefName = storedCondition.prefName;
      this.searchCondition.inUsed.facilityName = storedCondition.facilityName;
      this.setConditionList();
    }
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
#search-label-font {
  font-size: 17px;
}

.dialog-header-item {
  /* 文字色：黒テーマ字に灰色になってしまう為、黒で上書きする */
  color:#333333;
  font-size: .667em;
  height: 4.7em;
}

.condition-row {
  margin-bottom: 15px;
  width: 100%;
}
</style>
