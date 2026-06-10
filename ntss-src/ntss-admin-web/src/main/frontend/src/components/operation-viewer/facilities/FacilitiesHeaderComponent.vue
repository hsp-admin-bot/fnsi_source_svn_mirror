/**
 * 稼働ビューア施設一覧ページ用ヘッダ
 */
<template>
  <div>
    <div class='header-item'>
      <v-ons-row class='mark-leftmost-header'>
        <v-ons-col class='condition-search-col'>
          <common-searcharea :conditionList="conditionList" @show-popover='showPopover($event)'/>
        </v-ons-col>
        <v-ons-col style="margin-top: 0.4em;">
          <div class="filter-area" id="facilityFilter">
            <div class="filter-button">
              <input type="checkbox" class="emergency" id="facilityEmergency" @click='facilityCheckedCheckbox($event);' v-bind:checked='condition.facilityEmergency'>
              <label for="facilityEmergency" class="filterLabel">{{ emergencyCount }}</label>
            </div>
            <!-- 予防保全対応不完全のため非表示とする -->
            <div class="filter-button" v-if=false>
              <input type="checkbox" class="prophylaxis" id="facilityProphylaxis" @click='facilityCheckedCheckbox($event);' v-bind:checked='condition.facilityProphylaxis'>
              <label for="facilityProphylaxis" class="filterLabel">{{ prophylaxisCount }}</label>
            </div>
            <div class="filter-button">
              <input type="checkbox" class="defect" id="facilityDefect" @click='facilityCheckedCheckbox($event);' v-bind:checked='condition.facilityDefect'>
              <label for="facilityDefect" class="filterLabel">{{ defectCount }}</label>
            </div>
          </div>
          <div class="filter-area">
            <div class="filter-button">
              <input type="radio" class="all" id="facilityAll" @click='facilityCheckedRadio($event);' v-bind:checked='condition.facilityAll'>
              <label for="facilityAll" class="filterLabel filterLabelWidth">ALL</label>
            </div>
          </div>
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
      <div style='margin:10px;'>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>部署符号</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-select float v-model='inProgressCondition.departmentCd'>
              <!-- mod FNSI redmine #4243 修正 鄧シン start -->
              <!-- <option>-</option> -->
              <option></option>
              <option>すべて</option>
              <!-- mod FNSI redmine #4243 修正 鄧シン end -->
              <option v-for='(departmentCd, idxDepartmentCd) in departmentCds' :key='idxDepartmentCd'>{{ departmentCd }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>都道府県</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-select float v-model='inProgressCondition.prefName' style="display:">
              <!-- mod FNSI redmine #4243 修正 鄧シン start -->
              <!-- <option>-</option> -->
              <option></option>
              <option>すべて</option>
              <!-- mod FNSI redmine #4243 修正 鄧シン end -->
              <option v-for='prefecture in prefectures' :key='prefecture[0]'>{{ prefecture[1] }}</option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>施設名</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <v-ons-input input-id='facilityName' type='text' float  v-model='inProgressCondition.facilityName'></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <!-- 警報通知発生降順にソート -->
        <v-ons-row class="condition-row">
          <v-ons-col width='10%' vertical-align='center'>
            <v-ons-checkbox v-model="inProgressCondition.isAlarmSort" input-id="sort"></v-ons-checkbox>
          </v-ons-col>
          <label for="sort" class="popoverFilterLabel">{{ getIsAlarmDispText() }}</label>
        </v-ons-row>
        <!-- 検索IF内の各ボタン -->
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class='btn2-cancel clear' id="button-clear" @click='dialogClear'>クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class='btn3-normal ok' id="button-ok" @click='dialogOk'>OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </div>
</template>

<!-- スクリプト処理 -->
<script>
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
import PopoverMixin from "@/components/PopoverMixin";
import {
  IS_ALARM_TEXT
} from "@/constants/operationViewerCommon";
import commonSearchArea from "@/components/common/CommonSearchArea";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end

export default {
  components: {
    "common-searcharea": commonSearchArea
  },
  mixins: [PopoverMixin],
  data() {
    const defaultCondition = {
      /**
       * 部署符号
       */
      // mod FNSI redmine #4243 修正 鄧シン start
      // departmentCd: "-",
      departmentCd: "すべて",
      // mod FNSI redmine #4243 修正 鄧シン end
      /**
       * 都道府県名
       */
      // mod FNSI redmine #4243 修正 鄧シン start
      // prefName: "-",
      prefName: "すべて",
      // mod FNSI redmine #4243 修正 鄧シン end
      /**
       * 施設名
       */
      facilityName: "",
      /**
       * 警報通知発生降順にソート
       */
      isAlarmSort: true
    };
    return {
      /**
       * 検索IDの表示有無
       */
      popoverVisible: false,
      /**
       * 検索IF
       */
      popoverTarget: null,
      /**
       * 検索IFの表示位置
       */
      popoverDirection: "down",
      /**
       * 検索条件
       */
      defaultCondition: defaultCondition,
      /**
       * 選択中の検索条件
       */
      inProgressCondition: {
        ...defaultCondition
      },
      /**
       * 絞込条件
       */
      condition: {
        /**
         * 初期検索条件
         */
        ...defaultCondition,
        /**
         * 緊急発報のチェックボックス状態
         */
        facilityEmergency: false,
        /**
         * 予防保守のチェックボックス状態
         */
        facilityProphylaxis: false,
        /**
         * 通信不良のチェックボックス
         */
        facilityDefect: false,
        /**
         * 全選択
         */
        facilityAll: true
      },
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [{ text: IS_ALARM_TEXT }]
    };
  },
  computed: {
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo",
      "isNkkFacility"
    ]),
    ...mapGetters("operation-viewer/facility", [
      "getCandidates",
      "getEmergencyCount",
      "getProphylaxisCount",
      "getDefectCount",
      "getServiceSupportCount"
    ]),
    // -----------------------------------------
    // 部署符号の選択肢リスト取得
    // -----------------------------------------
    departmentCds() {
      return this.getCandidates.departmentCds;
    },
    // -----------------------------------------
    // 都道府県の選択肢リスト取得
    // -----------------------------------------
    prefectures() {
      return this.getCandidates.prefectures;
    },
    /**
     * 緊急発報件数若しくはサービス対応件数を取得する.
     * サインイン者が日機装施設に属している場合は、サービス対応件数を返却する.
     * それ以外の場合は、緊急発報件数を返却する.
     *
     * @returns 緊急発報件数 or サービス対応件数
     */
    emergencyCount() {
      // 日機装施設に属している場合
      if (this.isNkkFacility) {
        return this.getServiceSupportCount;
      }
      // それ以外
      return this.getEmergencyCount;
    },
    // -----------------------------------------
    // 予防保守件数取得
    // -----------------------------------------
    prophylaxisCount() {
      return this.getProphylaxisCount;
    },
    // -----------------------------------------
    // 通信不良件数取得
    // -----------------------------------------
    defectCount() {
      return this.getDefectCount;
    }
  },
  methods: {
    ...mapGetters("operation-viewer/facility", ["getCondition"]),
    ...mapActions("operation-viewer/facility", [
      "fetchFacilities",
      "setCondition",
      "findFacilities"
    ]),
    /**
     * 「警報通知発生降順にソート」の文字列を取得する.
     * ※operationViewerCommonに記載されている.
     *
     * @returns 表示文字列
     */
    getIsAlarmDispText() {
      return IS_ALARM_TEXT;
    },
    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      // del FNSI redmine #4243 修正 鄧シン start
      // this.copyConditionToInProgress();
      // del FNSI redmine #4243 修正 鄧シン end
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
      this.setCondition(this.condition);
      // 検索処理の実行
      this.fetchFacilities(this.getStateUserAccountInfo.userId).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('FacilitiesHeaderComponent.vue', 'dialogClear', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        // TODO Httpステータス 400時のエラー処理
      });
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      this.copyConditionFromInProgress();
      this.popoverVisible = false;
      this.search();
    },
    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    search() {
      this.findFacilities(this.condition);
    },
    // ------------------------------------------------------------------
    // 処理：各チェックボックスクリック時のイベント
    //       全選択のラジオボタンをOFFにし、施設一覧のstateのconditionを更新する
    // 引数：event : マウスクリックイベント
    // ------------------------------------------------------------------
    facilityCheckedCheckbox(event) {
      // 選択された要素の属性:idをイベントから取得
      const checkId = event.currentTarget.id;
      if (checkId === "facilityEmergency") {
        this.condition.facilityEmergency = event.currentTarget.checked;
      } else if (checkId === "facilityProphylaxis") {
        this.condition.facilityProphylaxis = event.currentTarget.checked;
      } else if (checkId === "facilityDefect") {
        this.condition.facilityDefect = event.currentTarget.checked;
      }
      // 全選択のラジオボタンを未選択に設定
      this.condition.facilityAll = false;
      // チェックボックスが全てOFFになった場合の対応
      if (
        !this.condition.facilityEmergency &&
        !this.condition.facilityProphylaxis &&
        !this.condition.facilityDefect
      ) {
        // 全選択のラジオボタンをONに設定
        this.condition.facilityAll = true;
      }
      // storeに条件を登録
      this.setCondition(this.condition);
      // フィルタリング
      this.search();
    },
    // ------------------------------------------------------------------
    // 処理：全選択のラジオボタンクリック時のイベント
    //       緊急発報、予防保守、通信異常のチェックボックスを全てOFFにし、
    //       施設一覧のstateのconditionを更新する
    // 引数：event : マウスクリックイベント
    // ------------------------------------------------------------------
    facilityCheckedRadio(event) {
      this.condition.facilityEmergency = false;
      this.condition.facilityProphylaxis = false;
      this.condition.facilityDefect = false;
      this.condition.facilityAll = event.currentTarget.checked;
      this.setCondition(this.condition);
      // フィルタリング
      this.search();
    },
    /**
     * stateから取得した検索条件を変数に設定する.
     */
    setStateCondition() {
      const stateCondition = this.getCondition();
      this.condition.departmentCd = stateCondition.departmentCd;
      this.condition.prefName = stateCondition.prefName;
      this.condition.facilityName = stateCondition.facilityName;
      this.condition.facilityEmergency = stateCondition.facilityEmergency;
      this.condition.facilityProphylaxis = stateCondition.facilityProphylaxis;
      this.condition.facilityDefect = stateCondition.facilityDefect;
      this.condition.facilityAll = stateCondition.facilityAll;
      this.condition.isAlarmSort = stateCondition.isAlarmSort;
      this.setConditionList();
    },
    /**
     * 絞り込み条件から検索条件にコピーする.
     */
    copyConditionToInProgress() {
      this.inProgressCondition.departmentCd = this.condition.departmentCd;
      this.inProgressCondition.prefName = this.condition.prefName;
      this.inProgressCondition.facilityName = this.condition.facilityName;
      this.inProgressCondition.isAlarmSort = this.condition.isAlarmSort;
    },
    /**
     * 選択されている検索条件を絞り込み条件にコピーする.
     */
    copyConditionFromInProgress() {
      this.condition.departmentCd = this.inProgressCondition.departmentCd;
      this.condition.prefName = this.inProgressCondition.prefName;
      this.condition.facilityName = this.inProgressCondition.facilityName;
      this.condition.isAlarmSort = this.inProgressCondition.isAlarmSort;
      this.setConditionList();
    },
    /**
     * 検索条件をクリアする.
     */
    clearCondition() {
      this.condition.departmentCd = this.defaultCondition.departmentCd;
      this.condition.prefName = this.defaultCondition.prefName;
      this.condition.facilityName = this.defaultCondition.facilityName;
      this.condition.isAlarmSort = this.defaultCondition.isAlarmSort;
      this.inProgressCondition.departmentCd = this.defaultCondition.departmentCd;
      this.inProgressCondition.prefName = this.defaultCondition.prefName;
      this.inProgressCondition.facilityName = this.defaultCondition.facilityName;
      this.inProgressCondition.isAlarmSort = this.defaultCondition.isAlarmSort;
      // 共通検索エリア部品に表示するデータのリストを初期化
      this.conditionList = [{ text: IS_ALARM_TEXT }];
    },
    /**
     * 共通検索エリア部品に表示するデータのリストを作成.
     */
    setConditionList() {
      let condList = [];
      const condObj = this.condition;
      // 部署符号
      // mod FNSI redmine #4243 修正 鄧シン start
      // if (condObj.departmentCd != "" && condObj.departmentCd != "-") {
      if (condObj.departmentCd != "" && condObj.departmentCd != "すべて") {
      // mod FNSI redmine #4243 修正 鄧シン end
        condList.push({ name:"部署符号", text:condObj.departmentCd });
      }
      // 都道府県
      // mod FNSI redmine #4243 修正 鄧シン start
      // if (condObj.prefName != "" && condObj.prefName != "-") {
      if (condObj.prefName != "" && condObj.prefName != "すべて") {
      // mod FNSI redmine #4243 修正 鄧シン end
        condList.push({ name:"都道府県", text:condObj.prefName });
      }
      // 施設名
      if (condObj.facilityName != "") {
        condList.push({ name:"施設名", text:condObj.facilityName });
      }
      // 警報通知発生降順にソート
      if (condObj.isAlarmSort) {
        condList.push({ text:this.getIsAlarmDispText() });
      }
      this.conditionList = condList;
    }
  },
  created() {
    this.setStateCondition();
  },
  mounted() {
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
input[type="radio"] {
  display: none; /* ラジオボタンを非表示にする */
}
input[type="checkbox"] {
  display: none; /* チェックボックスを非表示にする */
}
.filterLabelWidth {
  width: 4.6em;
}
.popoverFilterLabel {
  margin-right: 7px;
  font-size: 1.6em;
}
/* add FNSI-画面デザイン一覧画面対応 江 start */
#button-clear{
  background-color: #656a73!important;
  color:#ffffff!important;
}
#button-ok{
  background-color: #4291B9!important;
  color: #ffffff!important;
  border-bottom: solid 3px #4974a0!important;
}
/* add FNSI-画面デザイン一覧画面対応 江 end */
</style>
