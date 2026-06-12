/* 水質調査 */
<template>
  <div class="main-content-area" style="overflow: hidden;" @mousedown="onMouseDown($event)" @mouseup="onMouseUp($event)" @mouseleave="onInitialize($event)">
    <!-- 全体エリア -->
    <div class="scroll-table" style="position: sticky;" id="allArea">
      <!-- 固定エリア -->
      <div class="fixed-area" id="fixedArea" @mousewheel="onWheel($event, 'fixedArea')" @touchstart="onTouchStart" @touchmove="onTouchMove">
        <table class="grid-record-list" style="border-left: solid 1px var(--ntss-list-border-color);" id="fixedTable">
          <thead>
            <tr>
              <th class="ntss-list-header-th-sticky sticky-col-checkbox">
                <v-ons-checkbox v-model="selectedAllList" :disabled="!hasTreatmentRecordAuthority" :input-id="'checkbox-all'" :value="-1" @click="setChecked()"></v-ons-checkbox>
              </th>
              <th v-if="isDisplayMachineName" class="ntss-list-header-th-sticky sticky-col-equipment word-break-th manual-width" id="machineName" draggable="true" @dragstart="onDragStart(false)" @drag="onDragOver($event, false)" @dragend="onDragEnd(false)">
                <span @click="sortBy('machineOrderIndex')" :class="sortedClass('machineOrderIndex')" class="clickable-header-label">装置名</span>
              </th>
              <th v-if="isDisplaySurveyType" class="ntss-list-header-th-sticky sticky-col-type word-break-th manual-width" id="surveyTypeName" draggable="true" @dragstart="onDragStart(false)" @drag="onDragOver($event, false)" @dragend="onDragEnd(false)">
                <span @click="sortBy('waterSurveyTypeOrderIndex')" :class="sortedClass('waterSurveyTypeOrderIndex')" class="clickable-header-label">種別</span>
              </th>
              <th class="ntss-list-header-th-sticky sticky-col-point word-break-th manual-width" id="pointName" draggable="true" @dragstart="onDragStart(false)" @drag="onDragOver($event, false)" @dragend="onDragEnd(false)">
                <span @click="sortBy('waterSurveyPointOrderIndex')" :class="sortedClass('waterSurveyPointOrderIndex')" class="clickable-header-label">検査箇所名</span>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(rec, index) in sortMntWaterSurvey" :key="rec.pointCd">
              <td class="check-box sticky-col-checkbox">
                <v-ons-checkbox v-model="selectedList" :disabled="!hasTreatmentRecordAuthority" :input-id="'checkbox-' + index" :value="index + 1"></v-ons-checkbox>
              </td>
              <td v-if="isDisplayMachineName && rec.show" :rowspan="rec.count" class="sticky-col-equipment word-break-td" @click="showChartModal(rec.machineNo, 1)">
                {{ rec.machineName }}
              </td>
              <td v-if="isDisplaySurveyType" class="sticky-col-type word-break-td" @click="showChartModal(rec.surveyTypeCd, 2)">
                {{ rec.surveyTypeName }}
              </td>
              <td class="sticky-col-point word-break-td" @click="showChartModal(rec.pointCd, 3)">
                {{ rec.pointName }}
              </td>
            </tr>
          </tbody>
        </table>
        <!-- スクロール調整エリア -->
        <div id="scrollAdjustArea" />
      </div>
      <!-- スクロールエリア -->
      <div class="scroll-area" id="scrollArea" @mousewheel="onWheel($event, 'scrollArea')" @scroll="onScroll($event)">
        <table class="scroll-table-data" id="scrollTable">
          <thead>
            <tr @mouseover="onMouseOver()" @mouseleave="onMouseLeave()">
              <th
                v-for="(date, index) in getRangeDate"
                class="ntss-list-header-th-sticky word-break-th manual-width"
                style="max-width: 400px; min-width: 160px; width: 160px; --base-width: 160px;"
                :key="date.code + index"
                :id="index+1"
                draggable="true"
                @mousedown="onGetID($event)"
                @dragstart="onDragStart(true)"
                @drag="onDragOver($event, true)"
                @dragend="onDragEnd(true)"
              >
                <span :class="sortedClass('value_' + date.code)" class="clickable-header-label" @click="clickHeader($event, date)">
                  <span :class="calendarDate(date)" style="background-color: transparent;">{{ date.text + '(' + date.name + ')' }}</span>
                </span>
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(rec, index) in sortMntWaterSurvey" :key="rec.pointCd">
              <!-- mod #11047 数値IF修正【最優先】 張玲 start -->
              <!-- <td
                v-for="(date, i) in getRangeDate"
                v-html="showCellData(index, date, rec.surveyTypeCd)"
                class="word-break-td"
                style="max-width: 400px; min-width: 150px; width: 150px;"
                :key="date.code + '|' + rec.pointCd + index + i"
                @click="editSchedule($event, index, date)"
              ></td> -->
              <!-- #10977 インジェクション対応 linjunfeng start -->
              <!-- <td
                v-for="(date, i) in getRangeDate"
                v-html="showCellData(index, date, rec.surveyTypeCd)"
                class="word-break-td"
                style="max-width: 400px; min-width: 150px; width: 150px;"
                :key="date.code + '|' + rec.pointCd + index + i"
                @click="editSchedule($event, index, rec, date)"
              ></td> -->
              <td
                v-for="(date, i) in getRangeDate"
                class="word-break-td"
                style="max-width: 400px; min-width: 150px; width: 150px;"
                :key="date.code + '|' + rec.pointCd + index + i"
                @click="editSchedule($event, index, rec, date)"
              >{{showCellData(index, date, rec.surveyTypeCd)}}</td>
              <!-- #10977 インジェクション対応 linjunfeng end -->
              <!-- mod #11047 数値IF修正【最優先】 張玲 end -->
            </tr>
          </tbody>
        </table>
      </div>
      <v-ons-popover
        :class="[fontSizeSet, 'popover-content popover-content-plan']"
        cancelable
        v-model:visible="popoverPlan.popoverVisible"
        :target="popoverPlan.popoverTarget"
        :direction="popoverPlan.popoverDirection"
      >
        <div class="popover-content-div">
          <v-ons-row class="popover-content-row" v-if="isCreatePlan">
            <v-ons-col class="popover-content-col">
              <v-ons-button class="btn1-execute button" :disabled="!hasTreatmentRecordAuthority" @click="createPlan">予定作成</v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="popover-content-row" v-if="!isCreatePlan">
            <v-ons-col class="popover-content-col">
              <v-ons-button class="btn4-alert button" :disabled="!hasTreatmentRecordAuthority" @click="stopPlan">予定中止</v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="popover-content-row">
            <v-ons-col class="popover-content-col">
              <v-ons-button class="btn3-normal button" :disabled="!hasTreatmentRecordAuthority" @click="addResult">結果登録</v-ons-button>
            </v-ons-col>
          </v-ons-row>
        </div>
      </v-ons-popover>
      <v-ons-popover
        :class="[fontSizeSet, 'popover-content popover-content-header']"
        cancelable
        v-model:visible="popoverHeader.popoverVisible"
        :target="popoverHeader.popoverTarget"
        :direction="popoverHeader.popoverDirection"
      >
        <div class="popover-content-div">
          <v-ons-row class="popover-content-row">
            <v-ons-col class="popover-content-col">
              <v-ons-button class="btn4-alert button" :disabled="!hasTreatmentRecordAuthority"  @click="stopBulkPlan">一括中止</v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="popover-content-row">
            <v-ons-col class="popover-content-col">
              <v-ons-button class="btn3-normal button" :disabled="!hasTreatmentRecordAuthority" @click="createResult">結果登録</v-ons-button>
            </v-ons-col>
          </v-ons-row>
          <v-ons-row class="popover-content-row">
            <v-ons-col class="popover-content-col">
              <v-ons-button class="btn3-normal button" @click="sortBy('value_' + selectedItem.selectedDate.code)">ソート</v-ons-button>
            </v-ons-col>
          </v-ons-row>
        </div>
      </v-ons-popover>
    </div>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper";

import { getCurrentFunctionCd } from "@/router/routing-helper";
import PopoverMixin from "@/components/PopoverMixin";
// add  FNSI-権限 姜 start
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
// add  FNSI-権限 姜 end
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
import store from "@/stores";
// add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
import { deepCopy } from "@/functions/common/CommonFunctions";
//add #11047 数値IF修正【最優先】 張玲 start
import BigNumber from "@/compat/number/bignumber";
//add #11047 数値IF修正【最優先】 張玲 end
import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";
import { getLatestHeaderElement, getHeaderHeight, getFooterMenuClientHeight, getScopedElementById, getScopedElementsByClassName, queryScopedSelector, queryScopedSelectorAll, getScopedSessionStorage } from "@/functions/common/LayoutMeasureHelper";
import PrintMixin from "@/components/PrintMixin";

const PLANED = 1,
  INSPECTION = 2,
  HAVE_RESULT = 3;
const ScrollStartPostionState = Object.freeze({
  Initial: 0,
  AfterInitGrid: 1,
  AfterSetPositon: 2,
});

export default {
    // add  FNSI-権限 姜 start
  mixins: [PopoverMixin ,ComponentGuardMixin, PrintMixin],
    // add  FNSI-権限 姜 end
  data() {
    return {
      selectedList: [],
      selectedAllList: [],
      // add FNSI-水質管理_青田の対応 徐 start
      interval: null,
      resultTextMap: new Map,
      // add FNSI-水質管理_青田の対応 徐 end
      popoverPlan: {
        popoverVisible: false,
        popoverTarget: null,
        popoverDirection: "down"
      },
      popoverHeader: {
        popoverVisible: false,
        popoverTarget: null,
        popoverDirection: "down"
      },
      selectedItem: {
        selectedIndex: null,
        selectedDate: null
      },
      target: null,
      // del FNSI-バグ 水質管理779 徐 start
      /* resultTextList: [
        {
          cd: 1,
          text: "未満"
        },
        {
          cd: 2,
          text: "以下"
        },
        {
          cd: 3,
          text: "検出感度以下"
        }
      ], */
      // del FNSI-バグ 水質管理779 徐 del
      isAddResult: false,
      isCreatePlan: false,
      listMstBed: [],
      listMachineNo: [],
      sort: {
        key: "",
        isAsc: true
      },
      isInitGrid: false,
      machineSortList: [],
      // add  FNSI-権限 姜 start
      // 権限を有無する
      hasTreatmentRecordAuthority: false,
      // add  FNSI-権限 姜 end
      selfScreenName: "",
      isClicked: false,
      isOvered: false,
      targetID: null,
      intervalIDList: [],
      buffer: 0,
      maxWidth: 400,
      minWidth: 150,
      beforeUpdateScrollTopPosition: 0,
      scrollTopPosition: 0,
      scrollLeftPosition: 0,
      scrollState: false,
      isScrollY: false,
      // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
      isCheckResult: false,
      // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
      // add #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe start
      isToggleShowobject: true,
      // add #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe end
      //add #9558 水質管理一覧のヘッダ部から個別画面に遷移すると、機能帳票の制御が「一覧」のままになる 杜 start
      maList: [],
      inspectionDay: null,
      waterMaList: [],
      // add #11285 機能帳票の印刷情報対応② 高 start
      bedCdListString: "",
      // add #11285 機能帳票の印刷情報対応② 高 end
      //add #9558 水質管理一覧のヘッダ部から個別画面に遷移すると、機能帳票の制御が「一覧」のままになる 杜 end
      touchStartY: 0,
      iosFlg: false,
      androidFlg: false,
      setScrollStartPostionState: ScrollStartPostionState.Initial,
      scrollQuerySelector: ".scroll-area",
      addClassTargetQuerySelector: ["#scrollTable"],
    };
  },
  computed: {
    // add #11285 機能帳票の印刷情報対応② 高 start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #11285 機能帳票の印刷情報対応② 高 end
    ...mapGetters("window-size", {
       windowHeight: "getWindowHeight",
       windowWidth: "getWindowWidth",
       mainWindowWidth: "getMainWindowWidth",
       sidebarWidth: "getSidebarWidth"
     }),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("account-edit", ["getUserId", "getUserName"]),
    ...mapGetters("multi-calendar", ["getSelectedDateList"]),
    ...mapGetters("water-quality-survey/list", [
      "mstSurveyPoint",
      "mstSurveyType",
      "mstMachine",
      "mntWaterSurvey",
      "getCondition",
      "getResultText",
      "getListBedGroup",
      "getSelectedList"
    ]),
    ...mapGetters("water-quality-survey/result", ["surveyRecordDb",
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      "getSurveyResultList",
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
    ]),

    // add 機能帳票パラメータ確認 陳 start
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    // ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-info", ["searchedPatList","selectedPatId"]),
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    // add 機能帳票パラメータ確認 陳 end
    ...mapGetters("mst-holiday", ["getHolidays"]),
    getRangeDate() {
      let rangeDate = [];
      if (this.surveyRecordDb && this.surveyRecordDb.length !== 0) {
        const currentDate = dayjs();
        const listDate = [];
        // データベースで検査日を取得
        this.surveyRecordDb.forEach(r => {
          let isCurrDate = false;

          // check exist current date in database base on inspection date
          if (
            this.formatDate(currentDate, "YYYYMMDD") ===
            this.formatDate(r.inspectionDate, "YYYYMMDD")
          ) {
            isCurrDate = true;
          }
          const dateObj = {
            text: this.formatDate(r.inspectionDate, "YYYY/MM/DD"),
            code: this.formatDate(r.inspectionDate, "YYYYMMDD"),
            name: dayjs(r.inspectionDate)
              .format("dddd")
              .replace("曜日", ""),
            isCurrDate
          };
          // add EOL dou start
          if (!listDate.some(x => x.text == dateObj.text)) {
            // add EOL dou end
            listDate.push(dateObj);
          }
        });
        // リストの日付を並べ替え
        listDate.sort((a, b) => {
          return new Date(a.text) - new Date(b.text);
        });
        rangeDate = listDate;
      }
      return rangeDate;
    },
    isDisplayMachineName() {
      let condition = this.getCondition;
      if (condition.isDispMachineName === false) {
        return false;
      }
      return true;
    },
    isDisplaySurveyType() {
      let condition = this.getCondition;
      if (condition.isDispSurveyType === false) {
        return false;
      }
      return true;
    },
    sortMntWaterSurvey() {
      if (!this.mntWaterSurvey.length) return [];
    
      const list = JSON.parse(JSON.stringify(this.mntWaterSurvey));
      
      // 直前のソート実施済の列が画面表示されていない場合はソート状態クリア
      if (this.sort.key) {
        let existsSortDate = true;
        if (this.sort.key.startsWith("value_")) {
          const sortDate = this.sort.key.split("_")[1];
          existsSortDate = list.some(i =>
            i.surveyData.some(r =>
              this.formatDate(r.inspectionDate, "YYYYMMDD") === sortDate));
        }
        const invalidKey =
          (this.sort.key === "machineOrderIndex" && !this.isDisplayMachineName) ||        // 装置名
          (this.sort.key === "waterSurveyTypeOrderIndex" && !this.isDisplaySurveyType) || // 種別
          !existsSortDate;  // 日付
        if (invalidKey) {
          this.sort = {key: "", isAsc: true};
        }
      }
      
      // ソート実行
      let { key, isAsc } = this.sort || {};
      if (key) {
        if (key.startsWith("value_")) {
          // 日付列ソート
          let data = this.sortResultValue(list, isAsc, key);
          this.setMntWaterSurvey(data);
        } else {
          // 装置名、種別、検査箇所名は共通関数でソート
          list.sort((a, b) => {
            return sortableCompare(a, b, key, isAsc);
          });
          const newList = this.groupAfterSort(list);
          this.setMntWaterSurvey(newList);
        }
      } else {
        // ソートなしはデフォルトソート順でソート
        // 水質検査箇所マスタ並び順昇順
        list.sort((a, b) => {
          return sortableCompare(a, b, "waterSurveyPointOrderIndex", true);
        });
        const newList = this.groupAfterSort(list);
        this.setMntWaterSurvey(newList);
      }

      return this.mntWaterSurvey;
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  methods: {
    getScopedElementById(id) {
      return getScopedElementById(id, this);
    },
    getScopedElementsByClassName(className) {
      return getScopedElementsByClassName(className, this);
    },
    getScopedQuery(selector) {
      return queryScopedSelector(selector, this);
    },
    getScopedQueryAll(selector) {
      return queryScopedSelectorAll(selector, this);
    },
    getScopedOwnerWindow(element) {
      return element?.ownerDocument?.defaultView || this.$el?.ownerDocument?.defaultView || window;
    },
    getScopedComputedStyle(element) {
      if (!element) {
        return null;
      }
      return this.getScopedOwnerWindow(element).getComputedStyle(element);
    },

    registerWaterQualityEventHandlers() {
      this.unregisterWaterQualityEventHandlers();
      EventBus.$on("filter", this.filterData);
      EventBus.$on("refresh", this.filterData);
      EventBus.$on("isCheckResultFunc", this.isCheckResultFunc);
      EventBus.$on("isCheckResultSon", this.isCheckResultSon);
      EventBus.$on("getMaList", this.getMaList);
      EventBus.$on("inspectionDay", this.getInspectionDay);
      EventBus.$on("setToggleShowobject", this.setToggleShowobject);
      EventBus.$on("addBulkResult", this.addBulkResult);
      EventBus.$on("createBulkPlan", this.createBulkPlan);
      EventBus.$on("requestReportParams", this.requestrReportParams);
    },
    unregisterWaterQualityEventHandlers() {
      EventBus.$off("filter", this.filterData);
      EventBus.$off("refresh", this.filterData);
      EventBus.$off("isCheckResultFunc", this.isCheckResultFunc);
      EventBus.$off("isCheckResultSon", this.isCheckResultSon);
      EventBus.$off("getMaList", this.getMaList);
      EventBus.$off("inspectionDay", this.getInspectionDay);
      EventBus.$off("setToggleShowobject", this.setToggleShowobject);
      EventBus.$off("addBulkResult", this.addBulkResult);
      EventBus.$off("createBulkPlan", this.createBulkPlan);
      EventBus.$off("requestReportParams", this.requestrReportParams);
    },

    // じょはく add メモリにて利用者マスタ一覧取得 Start
    ...mapGetters("user", {
      getMstPersonalUser: "getMstPersonalUser"
    }),
    // じょはく add メモリにて利用者マスタ一覧取得 End
    // 共通ローダー設定
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage"
    ]),
    ...mapActions("water-quality-survey/list", [
      "setSelectedSurveyList",
      "setMstSurveyPoint",
      "setMstSurveyType",
      "setMstMachine",
      "setMntWaterSurvey",
      "setMstUser",
      "setSelectedList",
      "setChartData",
      "setChartTitle",
      "setResultText"
    ]),
    ...mapActions("water-quality-survey/result", [
      "setSelectTabId",
      "setControlDisp",
      "setInspectionDate",
      "setSurveyRecord",
      "setSurveyRecordDb"
    ]),
    ...mapActions("water-quality-survey/chart", ["setRangeDate"]),
    ...mapActions("multi-modal", [
      "showWaterResultModal",
      "showWaterChartModal"
    ]),

    ...mapActions("multi-calendar", ["setSelectedDateList"]),
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),

    // add FNSI-水質管理_青田の対応 徐 start
    calendarDate(cDate) {
      let date = dayjs(new Date(cDate.text));
      const className = "calendar-date";
      const today = dayjs();
      var checkHoliday = this.getHolidays;
      let ret = [];

      if (checkHoliday[date.format("YYYY-MM-DD")] != null) {
        if (today.format("YYYY/MM/DD") == date.format("YYYY/MM/DD")) {
          ret.push(className + "-Today-Holiday");
        } else {
          ret.push(className + "-Holiday");
        }
      } else if(cDate.name == "土"){
        if (today.format("YYYY/MM/DD") == date.format("YYYY/MM/DD")) {
          ret.push(className + "-Today-Saturday");
        } else {
          ret.push(className + "-Saturday");
        }
      } else if(cDate.name == "日"){
        if (today.format("YYYY/MM/DD") == date.format("YYYY/MM/DD")) {
          ret.push(className + "-Today-Sunday");
        } else {
          ret.push(className + "-Sunday");
        }
      } else {
        if (today.format("YYYY/MM/DD") == date.format("YYYY/MM/DD")) {
          ret.push(className + "-Today-OtherMonth");
        } else {
          ret.push(className + "-OtherMonth");
        }
      }
      return ret;
    },
    // add FNSI-水質管理_青田の対応 徐 end
    //add FNSI-全選択チェックボックスの動作不具合の修正 江 start
    setChecked() {
      // ケースチェックボックスすべて選択が選択されています
      if (this.selectedAllList.length > 0) {
        // ケースチェックボックスは選択されていないすべてを選択します
        this.selectedList = [];
      } else {
        this.selectedList = Object.keys(this.sortMntWaterSurvey).map(k =>
          (+k + 1).toString()
        );
      }
    },
    //add FNSI-全選択チェックボックスの動作不具合の修正 江 end
    getMachineNameByMachineCd(cd) {
      const findItem = this.machineSortList.find(r => r.machineNo === cd);
      return findItem ? findItem.machineName : "";
    },
    // add  FNSI-権限 姜 start
    getTreatmentRecordAuthority() {
     return this.hasAuthorityByCd(AUTHORITY_CODES.DEV_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.DEV_EDIT);
    },
    // add  FNSI-権限 姜 end
    // mod FNSI-バグ 水質管理779 徐 start
    // getResultTextByCd(cd) {
    //  const findItem = this.getResultText.find(r => {
    //    return r.cd == cd;
    //  });
    //  const findItem = resultText.find(r => {
    //    return r.cd == cd;
    //  });
    //  return findItem ? findItem.text : "";
    getResultTextByCd(cd, surveyTypeCd, selectedDate, point_cd) {
      if (this.getResultText.get(surveyTypeCd)) {
        const resultText = JSON.parse(this.getResultText.get(surveyTypeCd));
        const findItem = resultText.find(r => {
          return r.cd == cd;
        });
        //mod #11945 水質管理 結果文字列に関する複数のバグ zrx start
        // return findItem ? findItem.text : "";
        if(findItem) {
          return findItem.text;
        } else {
          //マスタの文字列 delete
          let copyList = JSON.parse(JSON.stringify(this.mntWaterSurvey));
          const filtered = copyList.flatMap(item =>
            item.surveyData.filter(d => {
              const date = dayjs(d.inspectionDate).format("YYYYMMDD");
              return date == selectedDate;
            })
          );
          if (filtered.length > 0) {
            for (const d of filtered) {
              if (!d) continue;
              const t = d.text;
              if (t === null || t === undefined) continue;
              const s = String(t).trim();
              if (s !== "" && s !== "0" && point_cd === d.point_cd) {
                const exists = resultText.some(entry => String(entry.text).trim() === s);
                if (!exists) {
                  return s;
                }
              }
            }
          }
          return "";
        }
        //mod #11945 水質管理 結果文字列に関する複数のバグ zrx end
      } else {
        return "";
      }
      // mod FNSI-バグ 水質管理779 徐 end
    },

    getUnitByPointCd(cd) {
      let unit = "";
      const surveyType = this.mstSurveyPoint.find(r => {
        return r.surveyPointCd === cd;
      });
      if (surveyType) {
        const findItem = this.mstSurveyType.find(t => {
          return t.surveyTypeCd == surveyType.surveyTypeCd;
        });
        if (findItem && findItem.unit) {
          unit = findItem.unit;
        }
      }
      return unit;
    },

    stopBulkPlan() {
      this.popoverHeader.popoverVisible = false;
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "水質検査予定一括中止確認",
        title: DIALOG_MESSAGES[13000153].title,
        // message: "結果が登録されていない水質検査予定を全て中止します。よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000153].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: async answer => {
          if (answer === 1) {
            const setDate = this.selectedItem.selectedDate;

            let listInspectionDateDb = await this.getSurveyRecordDB(
              setDate.code,
              setDate.code
            );

            if (listInspectionDateDb && listInspectionDateDb.length) {
              const existRecord = listInspectionDateDb.find(r => {
                const date = this.formatDate(r.inspectionDate, "YYYYMMDD");
                return date == setDate.code;
              });
              if (existRecord) {
                const surveyRecordNo = existRecord.surveyRecordNo;
                const listPointCd = [];
                const surveyData = JSON.parse(existRecord.surveyData);
                surveyData.forEach(d => {
                  if (
                    d.text === "" &&
                    d.time == "" &&
                    // mod FNSI-水質管理_青田の対応 徐 start
                    // d.value == 0 &&
                    (d.value == null || d.value == "") &&
                    // mod FNSI-水質管理_青田の対応 徐 end
                    d.picker == 0 &&
                    d.inspector == 0
                  ) {
                    listPointCd.push(d.point_cd);
                  }
                });
                this.deleteMulti(surveyRecordNo, listPointCd);
              }
            }
          }
        }
      });
    },
    // 日付列ヘッダー > 結果登録
    async createResult() {
      // add #9558 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
      store.dispatch("report/getMstReport", {funcCd: "03201",printFlag: 1});
      this.isCheckResult = true;
      // add #9558 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
      // 結果登録(一覧：-2)
      this.addBulkResult(-2);
    },
    async addBulkResult(chkFlg) {
      this.popoverHeader.popoverVisible = false;
      // 選択あり(1/-1)は一括、選択なし(2/-2)は一覧
      this.setSelectTabId((chkFlg === 1 || chkFlg === -1) ? 0 : 1);
      this.setControlDisp({
        isDispPlan: true,
        isDispResult: true,
        isDispDel: true,
        isDisableDate: true,
        isToggleShowObject: (chkFlg === 1) || (chkFlg === -1) ? true : false,
        toggleShowResult: false,
        toggleShowPlan: false
      });
      let selectedDate;
      if (this.selectedItem.selectedDate !== null) {
        selectedDate = this.selectedItem.selectedDate.code;
      }
      // add #9558 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
      if(chkFlg === -1){
        this.isToggleShowobject=true;
      }else{
        this.isToggleShowobject=false;
      }
      // add #9558 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
      if (chkFlg === 1) {
        /**
         * ヘッダーの「結果登録」ボタンをクリックしてケース更新結果
         */
        this.setControlDisp({
          isDispPlan: false,
          isDispResult: false,
          isDisableDate: false,
          isToggleShowObject: true,
          toggleShowResult: false,
          toggleShowPlan: false
        });
        const date = new Date();
        selectedDate = this.formatDate(date, "YYYYMMDD");
        // add #9558 機能帳票で正しく変数が引き渡されていない 杜 start
        this.isToggleShowObject = true;
        // add #9558 機能帳票で正しく変数が引き渡されていない 杜 end
      } else if (chkFlg === 2) {
        this.setSelectTabId(1);
        this.setControlDisp({
          isDispPlan: false,
          isDispResult: false,
          isDisableDate: false,
          isToggleShowObject: false,
          toggleShowResult: false,
          toggleShowPlan: false
        });
        const date = new Date();
        selectedDate = this.formatDate(date, "YYYYMMDD");
        // add #9558 機能帳票で正しく変数が引き渡されていない 杜 start
        this.isToggleShowObject = false;
        // add #9558 機能帳票で正しく変数が引き渡されていない 杜 end
      }

      this.setInspectionDate(this.selectedItem.selectedDate);

      let surveyRecordNo = null;

      let listInspectionDateDb = await this.getSurveyRecordDB(
        selectedDate,
        selectedDate
      );
      if (listInspectionDateDb && listInspectionDateDb.length) {
        const existRecord = listInspectionDateDb.find(r => {
          const date = this.formatDate(r.inspectionDate, "YYYYMMDD");
          return date == selectedDate;
        });
        if (existRecord) {
          surveyRecordNo = existRecord.surveyRecordNo;
        }
      }

      let copyList = JSON.parse(JSON.stringify(this.mntWaterSurvey));
      copyList.forEach(rec => {
        rec.surveyRecordNo = surveyRecordNo;
        /**
         * 選択した日付に基づいて調査データをフィルタリングする
         */
        const filtered = rec.surveyData.filter(d => {
          const date = this.formatDate(d.inspectionDate, "YYYYMMDD");
          return date == selectedDate;
        });
        if (filtered && filtered.length) {
          rec.surveyData = filtered[0];
        } else {
          rec.surveyData = {};
          rec.surveyData.plan = 0;
          rec.surveyData.text = "";
          rec.surveyData.time = "";
          rec.surveyData.unit = this.getUnitByPointCd(rec.pointCd);
          // mod FNSI-水質管理_青田の対応 徐 start
          // rec.surveyData.value = 0;
          rec.surveyData.value = "";
          // mod FNSI-水質管理_青田の対応 徐 end
          rec.surveyData.picker = 0;
          rec.surveyData.point_cd = rec.pointCd;
          rec.surveyData.inspector = 0;
          // add FNSI-水質検査結果登録で備考欄を追加する 周 start
          rec.surveyData.memo = "";
          // add FNSI-水質検査結果登録で備考欄を追加する 周 end
        }
        /**
         * レコードの調査データにデフォルト値がない場合
         * 調査タイプ情報を取得し、調査タイプに基づいてデフォルト値を割り当てます
         */
        // del FNSI-水質管理_青田の対応 徐 start
        /* const surveyTypeInfo = this.mstSurveyType.find(
          t => t.surveyTypeCd == rec.surveyTypeCd
        );
        if (rec.surveyData.text == 0) {
          rec.surveyData.text = +surveyTypeInfo.initialString;
        }
        if (rec.surveyData.value == 0) {
          rec.surveyData.value = +surveyTypeInfo.initialValue;
        } */
        // del FNSI-水質管理_青田の対応 徐 end
      });
      // add FNSI-水質管理_青田の対応 徐 start
      for (var i = 0; i < copyList.length; i++) {
        var selectindex = 0;
        if (this.selectedList != null && this.selectedList.indexOf(i + 1 + "") != -1) {
          selectindex = 1;
        }
        const surveyItemNew =
          {
            point_cd: copyList[i].surveyData.point_cd,
            plan: copyList[i].surveyData.plan,
            time: copyList[i].surveyData.time,
            picker: copyList[i].surveyData.picker,
            inspector: copyList[i].surveyData.inspector,
            value: copyList[i].surveyData.value,
            text: copyList[i].surveyData.text,
            memo: copyList[i].surveyData.memo,
            unit: copyList[i].surveyData.unit,
            index: selectindex
          };
        copyList[i].surveyData = surveyItemNew;
      }
      // add FNSI-水質管理_青田の対応 徐 end
      /**
       * ヘッダーの「結果登録」ボタンをクリックして結果を更新する場合
       * フィルターレコードがチェックされます
       */
      // del FNSI-redmine4000、4002 徐 start
      /* if (chkFlg === 1) {
        if (this.getSelectedList && this.getSelectedList.length) {
          const arrIndex = this.getSelectedList.map(value => {
            return +value - 1;
          });
          copyList = copyList.filter((v, i) => {
            return arrIndex.includes(i);
          });
        }
      } */
      // del FNSI-redmine4000、4002 徐 end
      this.setSurveyRecord(copyList);
      // add FNSI-水質管理_青田の対応 徐 start
      this.interval = setInterval(() => {
        var breakCheck = JSON.parse(getScopedSessionStorage(this.$el || this).getItem("breakCheck"));
        if (breakCheck == "1") {
          const dataList = JSON.parse(getScopedSessionStorage(this.$el || this).getItem("selectedList"));
          const select = JSON.parse(getScopedSessionStorage(this.$el || this).getItem("select"));
          const reSelectedList = [];
          if (dataList != null) {
            if (select === "") {
              for (var i = 0; i < dataList.length; i++) {
                reSelectedList.push(dataList[i] + "");
              }
            } else {
              for (var io = 0; io < dataList.length; io++) {
                reSelectedList.push(select[Number(dataList[io]) - 1] + "");
              }
            }
          }
          this.selectedList = reSelectedList;
          getScopedSessionStorage(this.$el || this).removeItem("selectedList");
          getScopedSessionStorage(this.$el || this).removeItem("breakCheck");
          getScopedSessionStorage(this.$el || this).removeItem("select");
          clearInterval(this.interval);
        }
      }, 300);
      // mod FNSI-redmine4000、4002 徐 start
      /* if (chkFlg === 1) {
        this.selectedList.sort((old,New)=>{
          return old - New
        })
        getScopedSessionStorage(this.$el || this).setItem('select', JSON.stringify(this.selectedList));
      } else {
        getScopedSessionStorage(this.$el || this).setItem('select', JSON.stringify(""));
      } */
      getScopedSessionStorage(this.$el || this).setItem('select', JSON.stringify(""));
      // mod FNSI-redmine4000、4002 徐 end
      // add FNSI-水質管理_青田の対応 徐 end
      this.showWaterResultModal();
    },

    clickHeader(event, setDate) {
      this.selectedItem.selectedDate = JSON.parse(JSON.stringify(setDate));
      this.popoverHeader.popoverTarget = event;
      this.popoverHeader.popoverVisible = true;
    },

    // 水質管理画面の描画
    showCellData(surveyIndex, setDate, surveyTypeCd) {
      let rtn = "";
      const surveyRecord = this.mntWaterSurvey[surveyIndex];

      if (!surveyRecord) return rtn;
      // 水質管理:予定されている場合、一度登録したページが表示されません。 林峻峰 start
      // surveyData(水質データ)のフィルター
      let surveyItem = surveyRecord.surveyData.filter(item => {
        const inspectionDate = this.formatDate(item.inspectionDate, "YYYYMMDD");
        return inspectionDate == setDate.code;
      });

      if (surveyItem) {
        surveyItem = surveyItem[surveyItem.length - 1]
      }
      // 水質管理:予定されている場合、一度登録したページが表示されません。 林峻峰 end
      if (surveyItem) {

        const surveyType = this.mstSurveyType.find(
          i => i.surveyTypeCd == surveyTypeCd
        );
        // mod FNSI-改修内容6324修正 xuty start
        // if (
        //mod #11945 水質管理 結果文字列に関する複数のバグ zrx start
        // if ((surveyItem.value === null || surveyItem.value === "") && surveyItem.text === 3) {
        //   surveyItem.status = HAVE_RESULT;
        //   var text = this.getResultTextByCd(surveyItem.text, surveyTypeCd);
        //   const resultVal = `${text}`;
        //   rtn = `${resultVal}`;
        // } else if (
        if (
        //mod #11945 水質管理 結果文字列に関する複数のバグ zrx end
        // mod FNSI-改修内容6324修正 xuty end
          // mod FNSI-水質管理_青田の対応 徐 start
          // surveyItem.value === 0 &&
          // surveyItem.text === 0 &&
          // (surveyItem.time !== "" || surveyItem.picker !== 0)
          (surveyItem.value === "" || surveyItem.value === null) &&
          (surveyItem.memo !== "" || surveyItem.time !== ""
          || surveyItem.picker !== 0 || surveyItem.inspector !== 0)
          // mod FNSI-水質管理_青田の対応 徐 end
        ) {
          surveyItem.status = INSPECTION;
          rtn = "検査中";
        // mod FNSI-水質管理_青田の対応 徐 start
        // } else if (surveyItem.value && surveyItem.value !== 0) {
        } else if (surveyItem.value !== null && surveyItem.value !== "") {
        // mod FNSI-水質管理_青田の対応 徐 end
          if (typeof surveyType !== "object") {
            return rtn;
          }

          surveyItem.status = HAVE_RESULT;

          // mod FNSI-バグ 水質管理779 徐 start
          // let text = this.getResultTextByCd(surveyItem.text);
          var text = this.getResultTextByCd(surveyItem.text, surveyTypeCd, surveyItem.inspectionDate, surveyItem.point_cd);
          // mod FNSI-バグ 水質管理779 徐 end
          const resultVal = this.formatResultValue(
            surveyType.decimalDigits,
            surveyItem.unit,
            text,
            surveyItem.value
          );

          rtn = `${resultVal}`;
        // mod FNSI-水質管理_青田の対応 徐 start
        // } else if (surveyItem.value === 0 && surveyItem.text !== 0) {
        //mod #11945 水質管理 結果文字列に関する複数のバグ zrx start
        // } else if ((surveyItem.value === null || surveyItem.value === "") && surveyItem.text !== 0) {
        } else if ((surveyItem.value === null || surveyItem.value === "") && surveyItem.text !== "") {
        //mod #11945 水質管理 結果文字列に関する複数のバグ zrx end
        // mod FNSI-水質管理_青田の対応 徐 end
          surveyItem.status = HAVE_RESULT;
          // mod FNSI-バグ 水質管理779 徐 start
          // let text = this.getResultTextByCd(surveyItem.text);

          /* const resultVal = this.formatResultValue(
            surveyType.decimalDigits,
            surveyItem.unit,
            text,
            surveyItem.value);*/
          const resultText = this.getResultTextByCd(surveyItem.text, surveyTypeCd, surveyItem.inspectionDate, surveyItem.point_cd);
          const resultVal = `${resultText}`;
          // mod FNSI-バグ 水質管理779 徐 end

          rtn = `${resultVal}`;
        } else if (surveyItem.plan == 1) {
          surveyItem.status = PLANED;
          rtn = "〇";
        }
      }
      return rtn;
    },
    //add #11047 数値IF修正【最優先】 張玲 start
    isNumber(numVal) {
      // チェック条件パターン
      var pattern = /^[-]?([1-9]\d*|0)(\.\d+)?$/;
      // 数値チェック
      return pattern.test(numVal);
    },
    //add #11047 数値IF修正【最優先】 張玲 end

    // Vue3では空文字をBigNumberに渡すと例外になるため、Vue2の非数値はそのまま表示する語義を保つ
    formatSurveyValue(value, decimalDigits) {
      if (!this.isNumber(value)) {
        return value;
      }
      const numberValue = BigNumber(value);
      if (decimalDigits !== undefined && decimalDigits !== null && decimalDigits !== "") {
        const formattedValue = numberValue.toFormat(decimalDigits);
        return numberValue.isEqualTo(formattedValue) ? formattedValue : numberValue.toString();
      }
      return numberValue.toString();
    },

    formatResultValue(decNumber, unit, resultText, resultValue) {
      // mod #11047 数値IF修正【最優先】 張玲 start
      // let value = resultValue.toFixed(decNumber);
      resultValue = this.formatSurveyValue(resultValue, decNumber);
      // mod #11047 数値IF修正【最優先】 張玲 end
      if (!unit) {
        unit = "";
      }

      if (resultText) {
        // mod #11047 数値IF修正【最優先】 張玲 start
        // return `${value} ${unit} ${resultText}`;
        return `${resultValue} ${unit} ${resultText}`;
        // mod #11047 数値IF修正【最優先】 張玲 end
      }
      // mod #11047 数値IF修正【最優先】 張玲 start
      // return `${value} ${unit}`;
      return `${resultValue} ${unit}`;
      // mod #11047 数値IF修正【最優先】 張玲 end
    },

    showPopOver(event) {
      // add 2020-11-09 FNSI-バグ 水質管理765 徐 start
      var innerHeight = event.view.innerHeight;
      var clientY = event.clientY;
      if (innerHeight - clientY < 115) {
        this.popoverPlan.popoverDirection= "up";
        this.popoverHeader.popoverDirection= "up";
      } else {
        this.popoverPlan.popoverDirection= "down";
        this.popoverHeader.popoverDirection= "down";
      }
      // add 2020-11-09 FNSI-バグ 水質管理765 徐 end

      this.popoverPlan.popoverTarget = event;
      this.popoverPlan.popoverVisible = true;
    },

    async stopPlan() {
      this.popoverPlan.popoverVisible = false;
      const setDate = this.selectedItem.selectedDate;
      const surveyRecord = this.mntWaterSurvey[this.selectedItem.selectedIndex];
      const surveyItem = surveyRecord.surveyData.find(item => {
        const inspectionDate = this.formatDate(item.inspectionDate, "YYYYMMDD");
        return inspectionDate == setDate.code;
      });
      let listInspectionDateDb = await this.getSurveyRecordDB(
        setDate.code,
        setDate.code
      );
      if (listInspectionDateDb && listInspectionDateDb.length) {
        const existRecord = listInspectionDateDb.find(r => {
          const date = this.formatDate(r.inspectionDate, "YYYYMMDD");
          return date == setDate.code;
        });
        if (existRecord) {
          const surveyRecordNo = existRecord.surveyRecordNo;
          this.deleteOne(surveyRecordNo, surveyItem.point_cd);
        }
      }
    },

    async createPlan() {
      this.popoverPlan.popoverVisible = false;
      const index = this.selectedItem.selectedIndex;
      const surveyRecord = this.mntWaterSurvey[index];
      const setDate = this.selectedItem.selectedDate;
      let surveyRecordNo = null;
      let surveyData = [];

      let listInspectionDateDb = await this.getSurveyRecordDB(
        setDate.code,
        setDate.code
      );

      if (listInspectionDateDb && listInspectionDateDb.length) {
        const existRecord = listInspectionDateDb.find(
          r => this.formatDate(r.inspectionDate, "YYYYMMDD") == setDate.code
        );
        if (existRecord) {
          surveyData = JSON.parse(existRecord.surveyData);
          surveyRecordNo = existRecord.surveyRecordNo;
        }
      }

      /**
       * 新しい検査日で新しい計画を作成する場合
       */
      const dataInsert = [
        {
          surveyRecordNo: surveyRecordNo,
          facilityCd: this.getFacilityCd,
          inspectionDate: dayjs(setDate.code).format(),
          surveyData: [
            ...surveyData,
            {
              point_cd: surveyRecord.pointCd,
              plan: 1,
              time: "",
              picker: 0,
              inspector: 0,
              // mod FNSI-水質管理_青田の対応 徐 start
              // value: 0,
              value: "",
              // mod FNSI-水質管理_青田の対応 徐 end
              text: "",
              // add FNSI-水質検査結果登録で備考欄を追加する 周 start
              memo: "",
              // add FNSI-水質検査結果登録で備考欄を追加する 周 end
              unit: this.getUnitByPointCd(surveyRecord.pointCd)
            }
          ],
          isDisp: "1",
          isDel: "0"
        }
      ];
      this.insertMultiWaterSurvey(dataInsert);
    },

    async createBulkPlan() {
      const rowId = this.selectedList;
      const copyList = JSON.parse(JSON.stringify(this.mntWaterSurvey));
      const checkedList = copyList.filter((val, index) => {
        return rowId.includes((index + 1).toString());
      });
      let dataInsert = [];

      if (this.getSelectedDateList.length === 0) {
        /**
         * ユーザーが検査日を選択せずに保存ボタンをクリックした場合
         * ポップアップエラーメッセージを表示
         */
        this.$ons.notification.alert({
          // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
          // title: "",
          // message: "予定を作成する日付を選択してください",
          title: DIALOG_MESSAGES[12000275].title,
          message: messageFormat(DIALOG_MESSAGES[12000275].message),
          // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
        });
        return;
      }

      const startDate = this.formatDate(
        this.getSelectedDateList[0],
        "YYYYMMDD"
      );
      const endDate = this.formatDate(
        this.getSelectedDateList[this.getSelectedDateList.length - 1],
        "YYYYMMDD"
      );

      let listInspectionDateDb = await this.getSurveyRecordDB(
        startDate,
        endDate
      );

      this.getSelectedDateList.forEach(date => {
        let surveyRecordNo = null;
        let surveyData = [];
        /**
         * データベースで選択された日付を確認する
         * 存在する場合は、このレコードを取得し、新しいポイントコードで新しい計画をプッシュしてデータを調査します
         * それ以外の場合は、データベースに新しいレコードを作成します
         */
        if (listInspectionDateDb && listInspectionDateDb.length) {
          const existRecord = listInspectionDateDb.find(r => {
            return (
              this.formatDate(r.inspectionDate, "YYYYMMDD") ==
              this.formatDate(date, "YYYYMMDD")
            );
          });
          if (existRecord) {
            surveyRecordNo = existRecord.surveyRecordNo;
            surveyData = JSON.parse(existRecord.surveyData);
          }
        }
        checkedList.forEach(rc => {
          /**
           * 調査データに存在するポイントコードを確認する
           */
          const check = surveyData.find(d => d.point_cd == rc.pointCd);
          if (check) {
            // 予定なし・結果ありのデータが存在する場合、予定あり・結果ありに変更
            surveyData.find(d => {
              if (d.point_cd == check.point_cd && d.plan !== "1") {
                d.plan = "1";
              }
            });
            return;
          }
          surveyData = [
            ...surveyData,
            {
              point_cd: rc.pointCd,
              plan: 1,
              time: "",
              picker: 0,
              inspector: 0,
              // mod FNSI-水質管理_青田の対応 徐 start
              // value: 0,
              value: "",
              // mod FNSI-水質管理_青田の対応 徐 end
              text: "",
              // add FNSI-水質検査結果登録で備考欄を追加する 周 start
              memo: "",
              // add FNSI-水質検査結果登録で備考欄を追加する 周 end
              unit: this.getUnitByPointCd(rc.pointCd)
            }
          ];
        });
        dataInsert.push({
          surveyRecordNo: surveyRecordNo,
          facilityCd: this.getFacilityCd,
          inspectionDate: dayjs(date).format(),
          surveyData: surveyData,
          isDisp: "1",
          isDel: "0"
        });
      });
      this.insertMultiWaterSurvey(dataInsert);
      this.setSelectedDateList([]);
    },
    // mod #11047 数値IF修正【最優先】 張玲 start
    // async addResult() {
    async addResult(surveyType) {
    // mod #11047 数値IF修正【最優先】 張玲 end
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
      store.dispatch("report/getMstReport", {funcCd: "03201",printFlag: 1});
      // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      this.isCheckResult = true;
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      //  mod FNSI-redmine4000、4002 徐 start
      /*this.popoverPlan.popoverVisible = false;
      this.setSelectTabId(1);
      this.setControlDisp({
        isDispPlan: true,
        isDispResult: true,
        isDispDel: true,
        isDisableDate: true,
        isToggleShowObject: true,
        toggleShowResult: !this.isAddResult,
        toggleShowPlan: false
      });

      let surveyRecordNo = null;

      this.setInspectionDate(this.selectedItem.selectedDate);

      let selectedDate = this.selectedItem.selectedDate.code;
      let listInspectionDateDb = await this.getSurveyRecordDB(
        selectedDate,
        selectedDate
      );
      if (listInspectionDateDb && listInspectionDateDb.length) {
        const existRecord = listInspectionDateDb.find(r => {
          const date = this.formatDate(r.inspectionDate, "YYYYMMDD");
          return date == this.selectedItem.selectedDate.code;
        });
        if (existRecord) {
          surveyRecordNo = existRecord.surveyRecordNo;
        }

        const copyList = JSON.parse(JSON.stringify(this.mntWaterSurvey));
        const surveyRecord = copyList[this.selectedItem.selectedIndex];
        const surveyItem = surveyRecord.surveyData.find(item => {
          return (
            this.formatDate(item.inspectionDate, "YYYYMMDD") ==
            this.selectedItem.selectedDate.code
          );
        });
        surveyRecord.surveyRecordNo = surveyRecordNo;
        // add FNSI-水質管理_青田の対応 徐 start
        var selectindex = 0;
        if (this.selectedList != null && this.selectedList.indexOf(this.selectedItem.selectedIndex + 1 + "") != -1) {
          selectindex = 1;
        }
        // add FNSI-水質管理_青田の対応 徐 end
        // mod FNSI-バグ 水質管理771 徐 start
        // surveyRecord.surveyData = surveyItem;
        if (typeof(surveyItem) == "undefined") {
          const surveyItemNew =
          {
            point_cd: surveyRecord.pointCd,
            plan: 0,
            time: "",
            picker: 0,
            inspector: 0,
            // mod FNSI-水質管理_青田の対応 徐 start
            // value: 0,
            value: "",
            // mod FNSI-水質管理_青田の対応 徐 end
            text: 0,
            memo: "",
            unit: this.getUnitByPointCd(surveyRecord.pointCd),
            index: selectindex
          };
          surveyRecord.surveyData = surveyItemNew;
        } else {
          // add FNSI-水質管理_青田の対応 徐 start
          // surveyRecord.surveyData = surveyItem;
          const surveyItemNew =
            {
              point_cd: surveyItem.point_cd,
              plan: surveyItem.plan,
              time: surveyItem.time,
              picker: surveyItem.picker,
              inspector: surveyItem.inspector,
              value: surveyItem.value,
              text: surveyItem.text,
              memo: surveyItem.memo,
              unit: surveyItem.unit,
              index: selectindex
            };
          surveyRecord.surveyData = surveyItemNew;
          // add FNSI-水質管理_青田の対応 徐 end
        }
        this.setSurveyRecord([surveyRecord]);
        // add FNSI-水質管理_青田の対応 徐 start
        this.interval = setInterval(() => {
          var breakCheck = JSON.parse(getScopedSessionStorage(this.$el || this).getItem("breakCheck"));
          if (breakCheck == "1") {
            const dataList = JSON.parse(getScopedSessionStorage(this.$el || this).getItem("selectedList"));
            const select = JSON.parse(getScopedSessionStorage(this.$el || this).getItem("select"));
            const reSelectedList = [];
            if (dataList != null) {
              for (var i = 0; i < dataList.length; i++) {
                reSelectedList.push(select[Number(dataList[i]) - 1] + "");
              }
            }
            this.selectedList = reSelectedList;
            getScopedSessionStorage(this.$el || this).removeItem("selectedList");
            getScopedSessionStorage(this.$el || this).removeItem("breakCheck");
            getScopedSessionStorage(this.$el || this).removeItem("select");
            clearInterval(this.interval);
          }
        }, 300);
        const newSelectList = [];
        newSelectList.push(this.selectedItem.selectedIndex + 1);
        getScopedSessionStorage(this.$el || this).setItem('select', JSON.stringify(newSelectList));
        // add FNSI-水質管理_青田の対応 徐 end
        this.showWaterResultModal();
      }*/
      let surveyRecordNo = null;
      this.popoverPlan.popoverVisible = false;
      this.selectedList = [];
      this.selectedList.push(this.selectedItem.selectedIndex + 1 + "");
      this.setSelectTabId(1);
      this.setControlDisp({
        isDispPlan: true,
        isDispResult: true,
        isDispDel: true,
        isToggleShowObject: true,
        isDisableDate: true,
        toggleShowResult: false,
        toggleShowPlan: false
      });
      this.setInspectionDate(this.selectedItem.selectedDate);
      let selectedDate = this.selectedItem.selectedDate.code;
      let listInspectionDateDb = await this.getSurveyRecordDB(
        selectedDate,
        selectedDate
      );
      if (listInspectionDateDb && listInspectionDateDb.length) {
        const existRecord = listInspectionDateDb.find(r => {
          const date = this.formatDate(r.inspectionDate, "YYYYMMDD");
          return date == selectedDate;
        });
        if (existRecord) {
          surveyRecordNo = existRecord.surveyRecordNo;
        }
      }
	    // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
      if(this.isCheckResult) this.mntWaterSurvey[this.selectedItem.selectedIndex].surveyRecordNo = surveyRecordNo;
	    // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
      let copyList = JSON.parse(JSON.stringify(this.mntWaterSurvey));
      copyList.forEach(rec => {
        rec.surveyRecordNo = surveyRecordNo;
        /**
         * 選択した日付に基づいて調査データをフィルタリングする
         */
        const filtered = rec.surveyData.filter(d => {
          const date = this.formatDate(d.inspectionDate, "YYYYMMDD");
          return date == selectedDate;
        });
        if (filtered && filtered.length) {
          rec.surveyData = filtered[0];
        } else {
          rec.surveyData = {};
          rec.surveyData.plan = 0;
          rec.surveyData.text = "";
          rec.surveyData.time = "";
          rec.surveyData.unit = this.getUnitByPointCd(rec.pointCd);
          rec.surveyData.value = "";
          rec.surveyData.picker = 0;
          rec.surveyData.point_cd = rec.pointCd;
          rec.surveyData.inspector = 0;
          rec.surveyData.memo = "";
        }
      });
      for (var i = 0; i < copyList.length; i++) {
        var selectindex = 0;
        if (this.selectedList != null && this.selectedList.indexOf(i + 1 + "") != -1) {
          selectindex = 1;
        }
        //add #11047 数値IF修正【最優先】 張玲 start
        const targetSurveyType =
          surveyType && surveyType.decimalDigits !== undefined
            ? surveyType
            : this.mstSurveyType.find(
              type => type.surveyTypeCd == copyList[i].surveyTypeCd
            );
        copyList[i].surveyData.value = this.formatSurveyValue(
          copyList[i].surveyData.value,
          targetSurveyType ? targetSurveyType.decimalDigits : undefined
        );
        //add #11047 数値IF修正【最優先】 張玲 end
        const surveyItemNew =
          {
            point_cd: copyList[i].surveyData.point_cd,
            plan: copyList[i].surveyData.plan,
            time: copyList[i].surveyData.time,
            picker: copyList[i].surveyData.picker,
            inspector: copyList[i].surveyData.inspector,
            value: copyList[i].surveyData.value,
            text: copyList[i].surveyData.text,
            memo: copyList[i].surveyData.memo,
            unit: copyList[i].surveyData.unit,
            index: selectindex
          };
        copyList[i].surveyData = surveyItemNew;
      }
      this.setSurveyRecord(copyList);
      this.interval = setInterval(() => {
        var breakCheck = JSON.parse(getScopedSessionStorage(this.$el || this).getItem("breakCheck"));
        if (breakCheck == "1") {
          const dataList = JSON.parse(getScopedSessionStorage(this.$el || this).getItem("selectedList"));
          const reSelectedList = [];
          for (var i = 0; i < dataList.length; i++) {
            reSelectedList.push(dataList[i] + "");
          }
          this.selectedList = reSelectedList;
          getScopedSessionStorage(this.$el || this).removeItem("selectedList");
          getScopedSessionStorage(this.$el || this).removeItem("breakCheck");
          getScopedSessionStorage(this.$el || this).removeItem("select");
          clearInterval(this.interval);
        }
      }, 300);

      this.showWaterResultModal();
      // mod FNSI-redmine4000、4002 徐 end
    },
    // mod #11047 数値IF修正【最優先】 張玲 start
    // editSchedule(e, surveyIndex, setDate) {
    editSchedule(e, surveyIndex, rec, setDate) {
    // mod #11047 数値IF修正【最優先】 張玲 end
      this.selectedItem.selectedIndex = surveyIndex;
      this.selectedItem.selectedDate = setDate;
      const surveyRecord = this.mntWaterSurvey[surveyIndex];
      const surveyItem = surveyRecord.surveyData.find(item => {
        const inspectionDate = this.formatDate(item.inspectionDate, "YYYYMMDD");
        return inspectionDate == setDate.code;
      });
      //add #11047 数値IF修正【最優先】 張玲 start
      const surveyType = this.mstSurveyType.find(
          i => i.surveyTypeCd == rec.surveyTypeCd
        );
      //add #11047 数値IF修正【最優先】 張玲 end

      let status = "";
      if (surveyItem) {
        status = surveyItem.status;
      }
      switch (status) {
        case PLANED: // 予定中止
          this.isAddResult = true;
          this.isCreatePlan = false;
          this.showPopOver(e);
          break;
        case INSPECTION: // 結果登録
          this.isAddResult = false;
          this.isCreatePlan = false;
          //mod #11047 数値IF修正【最優先】 張玲 start
          // this.addResult();
          this.addResult(surveyType);
          //mod #11047 数値IF修正【最優先】 張玲 end
          break;
        case HAVE_RESULT: // 結果登録
          this.isAddResult = false;
          this.isCreatePlan = false;
          // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
          this.isCheckResult = true;
          // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
          //mod #11047 数値IF修正【最優先】 張玲 start
          // this.addResult();
          this.addResult(surveyType);
          //mod #11047 数値IF修正【最優先】 張玲 end
          break;
        default:
          this.isCreatePlan = true;
          this.showPopOver(e);
          break;
      }
    },

    initGrid(surveyPoint) {
      let arrMappingRc = [];
      if (surveyPoint && surveyPoint.length) {
        surveyPoint.forEach(item => {
          const rc = {
            surveyRecordNo: null,
            facilityCd: this.getFacilityCd,
            pointCd: item.surveyPointCd,
            pointName: item.pointName,
            surveyTypeCd: item.surveyTypeCd,
            surveyTypeName: item.surveyTypeName,
            machineNo: !item.machineNo ? -1 : item.machineNo,
            machineName: this.getMachineNameByMachineCd(item.machineNo),
            machineOrderIndex: item.machineOrderIndex,
            waterSurveyTypeOrderIndex: item.waterSurveyTypeOrderIndex,
            waterSurveyPointOrderIndex: item.waterSurveyPointOrderIndex,
            surveyData: []
          };
          arrMappingRc.push(rc);
        });
      }
      arrMappingRc = this.groupMachinePoint(arrMappingRc);
      this.setMntWaterSurvey(arrMappingRc);
      if (!this.isInitGrid) {
        // 画面開始時のスクロール位置設定処理状態を進める
        this.setScrollStartPostionState = ScrollStartPostionState.AfterInitGrid;
      }
      this.isInitGrid = true;
    },
    // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
    isCheckResultFunc(){
      this.isCheckResult = false;
    },
    // add #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
    // add #9558 機能帳票で正しく変数が引き渡されていない 杜 start
    isCheckResultSon(){
      this.isCheckResult = true;
    },
    getMaList(list){
      this.maList = list;
    },
    getInspectionDay(date){
      this.inspectionDay = date;
    },
    // add #9558 機能帳票で正しく変数が引き渡されていない 杜 end
    // add #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe start
    setToggleShowobject(isShow){
      this.isToggleShowobject = isShow;
    },
    // add #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe end
    async filterData(isSearch) {
      if (this.selfScreenName !== this.$route.name) {
        return;
      }
      isSearch = isSearch || false;
      // 店から状態を取得する
      let condition = this.getCondition;
      // フラグチェックデータは調査タイプ別にフィルタリングされます
      let listSurveyTypeCd = [];
      // フラグチェックデータはベッドグループによってフィルタリングされます
      let bedGroupCd = null;

      let startDate = dayjs(condition.fromDate).format("YYYYMMDD");
      let endDate = dayjs(condition.toDate).format("YYYYMMDD");

      // add FNSI-水質管理_青田の対応 徐 start
      if (condition.fromDate == "") {
        startDate = null;
      }
      if (condition.toDate == "") {
        endDate = null;
      }
      // add FNSI-水質管理_青田の対応 徐 end

      let url = `waterSurvey/filter`;
      let postParams = {
        startDate,
        endDate,
        listSurveytypeCd: [],
        bedGroupCd: null
      };
      if (condition.surveyTypeCd !== -1) {
        // フラグチェックデータは調査タイプ別にフィルタリングされます
        listSurveyTypeCd = condition.surveyTypeCd;
        postParams.listSurveytypeCd = listSurveyTypeCd;
      }

      this.listMachineNo = [];
      if (condition.bedGroupCd !== null) {
        // フラグチェックデータはベッドグループによってフィルタリングされます
        bedGroupCd = condition.bedGroupCd;
        postParams.bedGroupCd = bedGroupCd;
      }
      try {
        this.setLoadingScreenVisible(true);
        const response = await ApiHelper.post(url, postParams);
        this.setSurveyRecordDb(response.data);
        if (!this.isInitGrid || isSearch) {
          this.initGrid(this.mstSurveyPoint);
          this.selectedAllList = [];
        }

        let dataFilter = this.mapSurveyDataWithSurveyPoint(response.data);
        if (listSurveyTypeCd.length > 0) {
          dataFilter = this.filterByTypeCd(dataFilter, listSurveyTypeCd);
        }

        if (bedGroupCd !== null) {
          dataFilter = this.filterByBedGroupCd(dataFilter, bedGroupCd);
        }

        this.selectedList = [...this.selectedList];
        dataFilter = this.groupAfterSort(dataFilter);
        this.setMntWaterSurvey(dataFilter);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('WaterQualitySurveyComponent.vue','filterData',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        this.setLoadingScreenVisible(false);
        this.internalServerError(error);
      }
    },

    filterByTypeCd(data, typeCd) {
      // ヘッダーから選択された調査タイプコードでデータをフィルタリングする
      if (typeCd.length > 0) {
        data = data.filter(item => typeCd.includes(item.surveyTypeCd));
      }
      return data;
    },

    filterByBedGroupCd(data, bedGroupCd) {
      let listMachineNo = [];
      // ヘッダーから選択されたベッドグループコードでデータをフィルタリング
      if (bedGroupCd !== null) {
        // 店舗からリストベッドグループを取得する
        const listBedGroup = this.getListBedGroup;
        const bedGroup = listBedGroup.find(item =>
          item.roomBedGroupCd === bedGroupCd
        );
        if(bedGroup) {
          // ベッドグループのリストベッドを取得する
          let listBedCd = JSON.parse(bedGroup.bedList);
          // ベッドコードで機械番号を取得
          if (listBedCd !== null && listBedCd.length > 0) {
            this.listMstBed.forEach(bed => {
              if (listBedCd.flat().includes(bed.bedCd)) {
                listMachineNo.push(bed.machineNo);
              }
            });
          }
        }
      }
      // mod 7974 水質検査箇所マスタの対象装置が未選択の対象が、水質管理の一覧が表示されない　周安寧  start
      // if (listMachineNo.length > 0) {
      //   data = data.filter(item => listMachineNo.includes(item.machineNo));
      // }
      if (listMachineNo.length > 0) {
        data = data.filter(item => listMachineNo.includes(item.machineNo));
      } else {
        data = [];
      }
      // mod 7974 水質検査箇所マスタの対象装置が未選択の対象が、水質管理の一覧が表示されない　周安寧  end
      return data;
    },

    mapSurveyDataWithSurveyPoint(data) {
      this.mntWaterSurvey.forEach(d => {
        d.surveyData = [];
      });
      if (data && data.length) {
        data.forEach(rc => {
          const inspectionDate = this.formatDate(rc.inspectionDate, "YYYYMMDD");
          const surveyData = JSON.parse(rc.surveyData);
          surveyData.forEach(data => {
            const index = this.mntWaterSurvey.findIndex(
              d => d.pointCd == data.point_cd
            );
            if (index !== -1) {
              // mod FNSI-水質管理_青田の対応 徐 start
              /* const dataItem = {
                  plan: +data.plan,
                  text: +data.text,
                  time: data.time,
                  unit: data.unit,
                  value: +data.value,
                  picker: data.picker,
                  point_cd: data.point_cd,
                  inspector: data.inspector,
                  // add FNSI-水質検査結果登録で備考欄を追加する 周 start
                  memo: data.memo,
                  // add FNSI-水質検査結果登録で備考欄を追加する 周 end
                  inspectionDate: inspectionDate
                };
              this.mntWaterSurvey[index].surveyData.push(dataItem);*/
              if (data.value === null || data.value === "") {
                const dataItem = {
                  plan: +data.plan,
                  //mod #11945 水質管理 結果文字列に関する複数のバグ zrx start
                  // text: +data.text,
                  text: data.text,
                  //mod #11945 水質管理 結果文字列に関する複数のバグ zrx end
                  time: data.time,
                  unit: data.unit,
                  value: "",
                  picker: data.picker,
                  point_cd: data.point_cd,
                  inspector: data.inspector,
                  memo: data.memo,
                  inspectionDate: inspectionDate
                };
                this.mntWaterSurvey[index].surveyData.push(dataItem);
              } else {
                const dataItem = {
                  plan: +data.plan,
                  //mod #11945 水質管理 結果文字列に関する複数のバグ zrx start
                  // text: +data.text,
                  text: data.text,
                  //mod #11945 水質管理 結果文字列に関する複数のバグ zrx end
                  time: data.time,
                  unit: data.unit,
                  //mod #11047 数値IF修正【最優先】 張玲 start
                  // value: +data.value,
                  value: data.value,
                  //mod #11047 数値IF修正【最優先】 張玲 end
                  picker: data.picker,
                  point_cd: data.point_cd,
                  inspector: data.inspector,
                  memo: data.memo,
                  inspectionDate: inspectionDate
                };
                this.mntWaterSurvey[index].surveyData.push(dataItem);
              }
              // mod FNSI-水質管理_青田の対応 徐 end
            }
          });
        });
      }
      return this.mntWaterSurvey;
    },

    groupMachinePoint(data) {
      data.forEach(d1 => {
        d1.show = false;
        delete d1.count;
      });
      let a = 1;
      data.reduce((prev, curr) => {
        if (prev.length && curr.machineNo === prev[prev.length - 1].machineNo) {
          prev[prev.length - 1].count = a++;
        } else {
          a = 1;
          prev.push(curr);
          curr.show = true;
          curr.count = a++;
        }

        return prev;
      }, []);
      return data;
    },

    async insertMultiWaterSurvey(data) {
      data.forEach(d => {
        d.surveyData.forEach(i => {
          delete i.status;
        });
        delete d.machineNo;
        delete d.machineName;
        delete d.show;
        delete d.count;
      });
      try {
        this.setLoadingScreenVisible(true);
        await ApiHelper.post("/waterSurvey/saveMulti", data);
        this.filterData();
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('WaterQualitySurveyComponent.vue','insertMultiWaterSurvey',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        this.internalServerError(error);
      }
      this.setLoadingScreenVisible(false);
    },

    async deleteOne(surveyRecordNo, pointCd) {
      try {
        this.setLoadingScreenVisible(true);
        await ApiHelper.post(
          `/waterSurvey/removeSurveyData?surveyRecordNo=${surveyRecordNo}&pointCd=${pointCd}`
        );
        this.filterData();
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('WaterQualitySurveyComponent.vue','deleteOne',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        this.internalServerError(error);
      }
      this.setLoadingScreenVisible(false);
    },

    async deleteMulti(surveyRecordNo, listPointCd) {
      try {
        const params = {
          listPointCd: JSON.stringify(listPointCd)
        };
        this.setLoadingScreenVisible(true);
        await ApiHelper.post(
          `/waterSurvey/${surveyRecordNo}/removeListSurveyData`,
          params
        );
        this.filterData();
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('WaterQualitySurveyComponent.vue','deleteMulti',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        this.internalServerError(error);
      }
      this.setLoadingScreenVisible(false);
    },

    filterDataSelected(selectedList) {
      const normalizedSelectedList = (Array.isArray(selectedList) ? selectedList : []).map(value => String(value));
      const filtered = this.mntWaterSurvey.filter((e, i) => {
        return normalizedSelectedList.indexOf(String(i + 1)) >= 0;
      });
      this.setSelectedSurveyList(filtered);
    },
    // 昇順/降順のclassを作成
    sortedClass(key) {
      return getSortedClass(key, this.sort);
    },
    // ソートするキーを設定する
    sortBy(key) {
      updateSort(key, this.sort);
    },

    // ソート後にマシン名でデータをグループ化する
    groupAfterSort(data) {
      data.forEach(d1 => {
        d1.show = false;
        delete d1.count;
      });
      let a = 1;
      data.reduce((prev, curr) => {
        if (prev.length && curr.machineNo === prev[prev.length - 1].machineNo) {
          prev[prev.length - 1].count = a++;
        } else {
          a = 1;
          prev.push(curr);
          curr.show = true;
          curr.count = a++;
        }

        return prev;
      }, []);
      return data;
    },
    sortResultValue(list, isAsc, key) {
      // ソートキーの日付を取得
      const selectedDate = key.split("_")[1];
      let listRecordHaveValueAndText = [];
      let listRecordText = [];
      let listInvestigating = [];
      let listRecordPlan = [];
      let listRecordNoPlan = [];
      list.forEach(i => {
        let data = i.surveyData.find(r => {
          return this.formatDate(r.inspectionDate, "YYYYMMDD") === selectedDate;
        });
        // 予定なし ※jsonに行が存在しない
        if (!data) {
          listRecordNoPlan.push(i);
          return;
        }
        // 結果値あり
        if (data.value !== "" && data.value !== null) {
          listRecordHaveValueAndText.push(i);
          return;
        }
        // 結果文字列あり
        if ((data.value === null || data.value === "") && data.text !== "") {
          listRecordText.push(i);
          return;
        }
        // 検査中
        if (
          (data.value === "" || data.value === null) &&
          data.text === "" &&
          (data.time !== "" || data.picker !== 0 || data.inspector !== 0 || data.memo !== "")
        ) {
          listInvestigating.push(i);
          return;
        }
        // 予定あり
        if (data.plan === 1) {
          listRecordPlan.push(i);
          return;
        }
        // 予定なし ※予定未登録で結果削除した場合はjsonに行が存在する
        listRecordNoPlan.push(i);
        return;
      });
      listRecordHaveValueAndText.sort((a, b) => {
        let sortItem2;
        if (isAsc) {
          sortItem2 = 1;
        } else {
          sortItem2 = -1;
        }
        const r1 = a.surveyData.find(r1 => {
          return (
            this.formatDate(r1.inspectionDate, "YYYYMMDD") === selectedDate
          );
        });
        const r2 = b.surveyData.find(r2 => {
          return (
            this.formatDate(r2.inspectionDate, "YYYYMMDD") === selectedDate
          );
        });
        const v1 = r1 ? r1.value : 0;
        const v2 = r2 ? r2.value : 0;

        if (v1 > v2) return 1 * sortItem2;
        if (v1 < v2) return -1 * sortItem2;
      });
      let merged = [].concat(
        listRecordHaveValueAndText,
        listRecordText,
        listInvestigating,
        listRecordPlan,
        listRecordNoPlan
      );
      if (!isAsc) {
        merged = [].concat(
          listRecordPlan,
          listInvestigating,
          listRecordText,
          listRecordHaveValueAndText,
          listRecordNoPlan
        );
      }
      return this.groupAfterSort(merged);
    },
    // 水位図を描く
    showChartModal(code, type) {
      if (this.surveyRecordDb && this.surveyRecordDb.length) {
        this.surveyRecordDb.sort((a, b) => {
          const dateA = this.formatDate(a.inspectionDate, "YYYY/MM/DD");
          const dateB = this.formatDate(b.inspectionDate, "YYYY/MM/DD");
          return new Date(dateA) - new Date(dateB);
        });
        // format value for chart
        const minX = dayjs(this.surveyRecordDb[0].inspectionDate).format(
          "YYYY/MM/DD");
        const maxX = dayjs(
          this.surveyRecordDb[this.surveyRecordDb.length - 1].inspectionDate).format("YYYY/MM/DD");
        this.setRangeDate([minX, maxX]);
      }

      /**
       * タイプ = 1：マシン名に基づいてチャートを表示
       * タイプ = 2: 調査タイプに基づいてチャートを表示
       * タイプ = 3：調査ポイントに基づいてグラフを表示
       */
      let filterData;
      switch (type) {
        case 1:
          filterData = this.sortMntWaterSurvey.filter(
            item => item.machineNo === code
          );
          break;
        case 2:
          filterData = this.sortMntWaterSurvey.filter(
            item => item.surveyTypeCd === code
          );
          break;
        case 3:
          filterData = this.sortMntWaterSurvey.filter(
            item => item.pointCd === code
          );
          break;
        default:
          filterData = [];
          break;
      }
      // クローン(フィルタデータ)の作成
      const chartData = deepCopy(filterData);
      this.setChartData(chartData);
      this.showWaterChartModal();
    },

    formatDate(date, type) {
      return dayjs(date).format(type);
    },

    internalServerError(error) {
      console.log(error);
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
      // this.$ons.notification.alert("システムエラーが発生しました。", {
      //   title: "エラー"
      // });
      this.$ons.notification.alert(messageFormat(DIALOG_MESSAGES['00200002'].message), {
        title: DIALOG_MESSAGES['00200002'].title
      });
      // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
    },
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {

        // add #11285 機能帳票の印刷情報対応② 高 start
        var expressCondCd="";
        if (null != this.getStorSimlpSearchQurey.rstDialysisState && this.getStorSimlpSearchQurey.rstDialysisState.length > 0) {
          if (this.getStorSimlpSearchQurey.rstDialysisState.length == 2) {
            expressCondCd = "予定・実績";
          } else {
            if (this.getStorSimlpSearchQurey.rstDialysisState[0] == 1) {
              expressCondCd = "予定";
            } else {
              expressCondCd = "実績";
            }
          }
        }
        let kurNames = null;
        if(this.getStorSimlpSearchQurey.kurNames && this.getStorSimlpSearchQurey.kurNames.length > 0) {
          kurNames = this.getStorSimlpSearchQurey.kurNames.join("・");
        } else {
          kurNames = "すべて";
        }
        let patGroups = null;
        if(this.getStorSimlpSearchQurey.selectedPatGroupNames) {
          patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames;
        } else {
          patGroups = "すべて";
        }
        this.bedCdListString = JSON.parse(getScopedSessionStorage(this.$el || this).getItem('roomBedGroupNameWater')) || [];
        // add #11285 機能帳票の印刷情報対応② 高 end
        // 機能一致

        // 印刷パラメータを応答
        const condition = this.getCondition;
        // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
        // const param = {
        //   // add 機能帳票パラメータ確認 陳 start
        //   patId: this.selectedPatId,
        //   // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
        //   patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
        //   // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
        //   machineNos: this.mntWaterSurvey.map(({machineNo}) => machineNo),
        //   //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
        //   selectNos:this.selectedList,
        //   functionCd:"03201",
        //   //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
        //   // add 機能帳票パラメータ確認 陳 end
        //   facilityCd: this.getFacilityCd,
        //   date: dayjs(Date.now()).format("YYYY/MM/DD"),
        // };
        // EventBus.$emit("sendReportParams", param);
        if(this.isCheckResult) {
          //水質検査結果登録画面
 // mod #9558 機能帳票で正しく変数が引き渡されていない 杜 start
 //          var arr = [this.mntWaterSurvey[this.selectedItem.selectedIndex].machineNo];
 //          const param1 = {
 //            functionCd: "03201",
 //            facilityCd: this.getFacilityCd,
 //            date: this.selectedItem.selectedDate.text,
 //            fromDate: this.selectedItem.selectedDate.text,
 //            toDate: this.selectedItem.selectedDate.text,
 //            // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe start
 //            //machineNos: arr,
 //            machineNos: this.isToggleShowobject ? arr : this.mntWaterSurvey.map(({machineNo}) => machineNo),
 //            // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe end
 //            mainte_no: this.mntWaterSurvey[this.selectedItem.selectedIndex].surveyRecordNo,
 //            patId: this.selectedPatId,
 //            patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
 //          };

          // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
          // var arr = this.maList.length != 0 ? this.maList.map(({machineNo}) => machineNo) : (this.waterMaList.length != 0 ? this.waterMaList.map(({machineNo}) => machineNo) :(this.selectedItem.selectedIndex != undefined ?[this.mntWaterSurvey[this.selectedItem.selectedIndex].machineNo]:null));
          // var arrSurveyRecordNo = this.maList.length != 0 ? this.maList.map(({surveyRecordNo}) => surveyRecordNo) : (this.waterMaList.length != 0 ? this.waterMaList.map(({surveyRecordNo}) => surveyRecordNo) : (this.selectedItem.selectedIndex != undefined ?[this.mntWaterSurvey[this.selectedItem.selectedIndex].surveyRecordNo]:null));
          let machineNos = [];
          let surveyRecordNos = [];
          if(this.getSurveyResultList != null && this.getSurveyResultList.length != 0) {
            // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
            //machineNos = this.getSurveyResultList.filter(item => item.show === true).map(({machineNo}) => machineNo);
            machineNos = this.getSurveyResultList.filter(item => item.show === true && item.machineName != null && item.machineName != "").map(({machineNo}) => machineNo);
            if(this.getSurveyResultList.filter(item => item.show === true && (item.machineName == null || item.machineName == "")).map(({machineNo}) => machineNo).length > 0) machineNos.push(-1);
            // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
            surveyRecordNos = Array.from(new Set(this.getSurveyResultList.filter(item => item.show === true && item.surveyRecordNo != null).map(({surveyRecordNo}) => surveyRecordNo)));
          }
          else {
            // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
            //machineNos = this.mntWaterSurvey.map(({machineNo}) => machineNo);
            machineNos = this.mntWaterSurvey.filter(item => item.machineName != null && item.machineName != "").map(({machineNo}) => machineNo);
            if(this.mntWaterSurvey.filter(item => item.machineName != null && item.machineName != "").map(({machineNo}) => machineNo).length > 0) machineNos.push(-1);
            // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
            surveyRecordNos = Array.from(new Set(this.mntWaterSurvey.filter(item => item.surveyRecordNo != null).map(({surveyRecordNo}) => surveyRecordNo)));
          }
          // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
         const param1 = {
            functionCd: "03201",
            facilityCd: this.getFacilityCd,
            date: this.inspectionDay,
            fromDate: this.inspectionDay,
            toDate: this.inspectionDay,
            // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
            // // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe start
            // // machineNos: arr,
            // machineNos: this.isToggleShowobject ? arr : this.mntWaterSurvey.map(({machineNo}) => machineNo),
            // // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe end
            // mainte_no: arrSurveyRecordNo,
            machineNos: machineNos,
            mainte_no: surveyRecordNos != null && surveyRecordNos.length != 0 ? surveyRecordNos[0] : -1,
            // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
            patId: this.selectedPatId,
            patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          };
 // mod #9558 機能帳票で正しく変数が引き渡されていない 杜 end
          EventBus.$emit("sendReportParams", param1);
        }
        else{
          //水質管理画面
          const selected = this.mntWaterSurvey.filter((e, i) => {
            return this.selectedList.indexOf(String(i + 1)) >= 0;
          });
          const param = {
            functionCd:"03201",
            facilityCd: this.getFacilityCd,
            fromDate: dayjs(condition.fromDate).format("YYYY/MM/DD"),
            toDate: dayjs(condition.toDate).format("YYYY/MM/DD"),
            date: dayjs(condition.fromDate).format("YYYY/MM/DD"),
            // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe start
            //machineNos: selected.map(({machineNo}) => machineNo),
            machineNos: this.mntWaterSurvey.map(({machineNo}) => machineNo),
            // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/08/27 limingzhe end
            selectNos:this.selectedList,
            patId: this.selectedPatId,
            patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
            // add #11285 機能帳票の印刷情報対応② 高 start
            treatDate:this.getStorSimlpSearchQurey.treatDate,
            bedCdListString:this.bedCdListString,
            freeWord:this.getStorSimlpSearchQurey.freeWord,
            expressCondCdStr:expressCondCd,
            kurNames:kurNames,
            patGroups:patGroups,
            // add #11285 機能帳票の印刷情報対応② 高 end
          };
          EventBus.$emit("sendReportParams", param);
        }
        // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
      }
    },

    async getSurveyRecordDB(startDate, endDate) {
      let response;

      const url = `waterSurvey/filter`;
      const postParams = {
        startDate,
        endDate,
        listSurveytypeCd: [],
        listBedGroupCd: []
      };
      try {
        this.setLoadingScreenVisible(true);
        response = await ApiHelper.post(url, postParams);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('WaterQualitySurveyComponent.vue','getSurveyRecordDB',error);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        this.setLoadingScreenVisible(false);
        this.internalServerError(error);
      }

      if (response && response.data) {
        return response.data;
      }
      return [];
    },
    // マウスダウンイベント
    onMouseDown(event) {
      // マウス左ボタン押下の場合
      if (event.button == 0) {
        // マウス左ボタン押下状態
        this.isClicked = true;
      }
    },
    // マウスアップイベント
    onMouseUp(event) {
      // マウス左ボタン押下の場合
      if (event.button == 0) {
        // マウス左ボタン未押下状態
        this.isClicked = false;
      }
    },
    // 初期化イベント
    onInitialize(event) {
      // マウス左ボタン押下の場合
      if (event.button == 0) {
        // 初期化処理
        this.isClicked = false;
        this.isOvered = false;
      }
    },
    // マウスオーバーイベント
    onMouseOver() {
      // マウスオーバー状態
      this.isOvered = true;
    },
    // マウスリーブイベント
    onMouseLeave() {
      // マウス未オーバー状態
      this.isOvered = false;
    },
    // ID取得イベント
    onGetID(event) {
      // マウス左ボタン押下の場合
      if (event.button == 0) {
        // 対象IDの登録
        this.targetID = event.target.id;
      }
    },
    // ドラッグ開始イベント
    onDragStart(isScrollTableHeader) {
      // スクロールテーブルヘッダー かつ、対象ID ≠ "NULL"の場合
      if (isScrollTableHeader && this.targetID != "" && this.targetID != null && this.targetID != undefined) {
        // スクロールテーブル幅の設定
        this.setScrollTableWidth();
      }
      // テーブル高の同期
      this.syncTableHeight();
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
      // 固定テーブル列最小幅の補正
      this.resetFixedTableColumnMinWidth();
    },
    // ドラッグオーバーイベント
    onDragOver(event, isScrollTableHeader) {
      // ドラッグオーバーイベントの解除
      event.preventDefault();
      // 再帰処理
      this.intervalIDList.push(setInterval(function() {
        // スクロールテーブルヘッダー かつ、対象ID ≠ "NULL"の場合
        if (isScrollTableHeader && this.targetID != "" && this.targetID != null && this.targetID != undefined) {
          // スクロールテーブル幅の設定
          this.setScrollTableWidth();
        }
        // テーブル高の同期
        this.syncTableHeight();
        // 表示エリアサイズの設定
        this.setDisplayAreaSize();
        // 固定テーブル列最小幅の補正
        this.resetFixedTableColumnMinWidth();
        // 再帰処理の停止
        if (!this.isClicked && !this.isOvered) {
          // インターバルの削除
          this.disposeInterval();
          // 対象IDの削除
          this.targetID = null;
        }
      }.bind(this), 200));
    },
    // ドラッグ終了イベント
    onDragEnd(isScrollTableHeader) {
      // スクロールテーブルヘッダー かつ、対象ID ≠ "NULL"の場合
      if (isScrollTableHeader && this.targetID != "" && this.targetID != null && this.targetID != undefined) {
        // スクロールテーブル幅の設定
        this.setScrollTableWidth();
      }
      // テーブル高の同期
      this.syncTableHeight();
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
      // 固定テーブル列最小幅の補正
      this.resetFixedTableColumnMinWidth();
      // インターバルの削除
      this.disposeInterval();
      // 対象IDの削除
      this.targetID = null;
    },
    // マウスホイールイベント
    onWheel(event, name) {
      // 全体エリアスクロール状態の場合
      if (this.scrollState) {
        // スクロール(Y：横スクロール無し)状態の場合
        if (this.isScrollY) {
          // イベント発生元 = 固定エリアの場合
          if (name === 'fixedArea') {
             // 日付数の取得
             const cols = this.getScrollTableHeaderCells().length;
             // 日付数 = "0"の場合
             if (cols === 0) {
               // スクロールトップの取得
               const scrollPosition = this.getScopedElementById("fixedArea").scrollTop;
               // (固定エリア)スクロールの同期
               this.getScopedElementById("fixedArea").scrollTop = scrollPosition + event.deltaY;
               // 終了
               return false;
             }
          } else if (name === 'scrollArea') {
            // シフトキー押下の場合
            if (event.shiftKey) {
               // 終了：シフトキー押下時は反応させないため、後続処理(縦軸移動)は実施しない
               return false;
            }
          }
        } else {
          // シフトキー押下の場合
          if (event.shiftKey) {
            // 終了：スクロールは横軸移動だけのため、後続処理(縦軸移動)は実施しない
            return false;
          }
        }
      } else {
        // イベント発生元 = 変動エリアの場合
        if (name === 'scrollArea') {
          // シフトキー押下の場合
          if (event.shiftKey) {
            // 終了：スクロールは横軸移動だけのため、後続処理(縦軸移動)は実施しない
            return false;
          }
        }
      }
      // 全体エリアスクロール状態 かつ スクロール(Y)状態以外の場合
      if (this.scrollState && !this.isScrollY) {
        // スクロールトップの取得
        const scrollPosition = this.getScopedElementById("allArea").scrollTop;
        // (全体エリア)スクロールの同期
        this.getScopedElementById("allArea").scrollTop = scrollPosition + event.deltaY;
      } else {
        // スクロールトップの取得
        const scrollPosition = this.getScopedElementById("scrollArea").scrollTop;
        // (スクロールエリア)スクロールの同期
        this.getScopedElementById("scrollArea").scrollTop = scrollPosition + event.deltaY;
      }
    },
    // マウススクロールイベント
    onScroll(event) {
      // 処理実行タイミングの最適化
      (this.$el?.ownerDocument?.defaultView || window).requestAnimationFrame(async () => {
        // 縦スクロール(現在のスクロールトップ ≠ 前回のスクロールトップ)の場合
        if (event.target.scrollTop != this.scrollTopPosition) {
          // スクロール位置の設定
          await this.setScrollPosition(event);
        }
        if (event.target.scrollWidth != 0) {
          // スクロールトップの保持
          const scrollArea = this.getScopedElementById("scrollArea");
          const maxScrollTop = scrollArea.scrollHeight - scrollArea.clientHeight;
          const currentScrollTop = Math.min(Math.floor(event.target.scrollTop), maxScrollTop);
          if (maxScrollTop >= this.scrollTopPosition) {
            this.scrollTopPosition = currentScrollTop;
          }
          // 横スクロール位置の保持
          this.scrollLeftPosition = event.target.scrollLeft;
        }
      });
    },
    // インターバルの削除
    disposeInterval() {
      // 再帰処理IDs > "0"の場合
      if (this.intervalIDList.length > 0) {
        // 再帰処理の終了
        clearInterval(this.intervalIDList.shift());
      }
    },
    getWaterScopedElements(selector) {
      return Array.from(queryScopedSelectorAll(selector, this.$el || null));
    },
    getScrollTableHeaderCells() {
      return this.getWaterScopedElements("#scrollTable th");
    },
    getFixedTableRows() {
      return this.getWaterScopedElements("#fixedTable tr");
    },
    getScrollTableRows() {
      return this.getWaterScopedElements("#scrollTable tr");
    },
    // バッファーの取得
    getBufferSize() {
      // 日付数の取得
      const cols = this.getScrollTableHeaderCells().length;
      // バッファーの算出
      this.buffer = cols * 30;
    },
    // テーブル高の同期
    syncTableHeight() {
      // テーブル行高の初期化
      this.initTableHeight();
      // テーブル行高の設定
      this.setTableHeight();
    },
    // テーブル行高の初期化
    initTableHeight() {
      // 行件数の取得
      const fixedRows = this.getFixedTableRows();
      const scrollRows = this.getScrollTableRows();
      const rows = fixedRows.length;
      // 行件数処理
      for (let i=0; i < rows; i++) {
        // 固定テーブル行高の初期化
        fixedRows[i].style.height = "";
        // スクロールテーブル行高の初期化
        if (scrollRows[i]) scrollRows[i].style.height = "";
      }
    },
    // テーブル行高の設定
    setTableHeight() {
      // 行件数の取得
      const fixedRows = this.getFixedTableRows();
      const scrollRows = this.getScrollTableRows();
      const rows = fixedRows.length;
      // 行件数処理
      for (let i=0; i < rows; i++) {
        const fixedRow = fixedRows[i];
        const scrollRow = scrollRows[i];
        if (!fixedRow || !scrollRow) continue;
        // 固定テーブル行の取得
        const fixedTableRow = fixedRow.getBoundingClientRect();
        // スクロールテーブル行の取得
        const scrollTableRow = scrollRow.getBoundingClientRect();
        // 固定テーブル行高の取得
        const fixedTableRowHeight = fixedTableRow.height;
        // スクロールテーブル行高の取得
        const scrollTableRowHeight = scrollTableRow.height;
        // 固定テーブル行高 > スクロールテーブル行高の場合
        if(fixedTableRowHeight > scrollTableRowHeight){
          // 固定テーブル行高の設定
          fixedRow.style.height = fixedTableRowHeight + "px";
          // スクロールテーブル行高の設定
          scrollRow.style.height = fixedTableRowHeight + "px";
        } else {
          // 固定テーブル行高の設定
          fixedRow.style.height = scrollTableRowHeight + "px";
          // スクロールテーブル行高の設定
          scrollRow.style.height = scrollTableRowHeight + "px";
        }
      }
    },
    // 表示エリアサイズの設定
    setDisplayAreaSize() {
      // 固定エリアサイズの設定
      this.setFixedAreaSize();
      // スクロールエリアサイズの設定
      this.setScrollAreaSize();
      // スクロールバーの設定
      this.setScrollBar();
      // スクロール位置の設定
      this.setScrollPosition();
    },
    // 固定エリアサイズの設定
    setFixedAreaSize() {
      // -----height-----
      // ヘッダー高の取得
      const headerHeight = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
      // フッター高の取得
      const footerHeight = getFooterMenuClientHeight(this.$el || null);
      // 画面表示幅 - ヘッダー高 - フッター高 - 調整高
      const fixedAreaHeight = this.windowHeight - headerHeight - footerHeight - 20;
      // 固定テーブル高の取得
      const fixedTableHeight = this.getScopedElementById("fixedTable").clientHeight;
      // 固定エリア高 > 固定テーブル高
      if (fixedAreaHeight > fixedTableHeight) {
        // 横スクロールバーの高さ
        const scrollArea = this.getScopedElementById("scrollArea");
        const scrollBarHeight = scrollArea.offsetHeight - scrollArea.clientHeight;
        // 固定テーブル高 + 調整高
        const val = fixedTableHeight + scrollBarHeight;
        // 固定エリア高の設定
        this.getScopedElementById("fixedArea").style.height = val + "px";
        // スクロール調整エリアマージンの初期化
        this.getScopedElementById("scrollAdjustArea").style.marginTop = "0px";
      } else {
        // 固定エリア高 - 調整高
        const val = fixedAreaHeight + (20 - 8);
        // 固定エリア高の設定
        this.getScopedElementById("fixedArea").style.height = val + "px";
        // スクロール調整エリアマージンの固定化
        if (!this.isMobileDevice) {
          this.getScopedElementById("scrollAdjustArea").style.marginTop = "18px";
        }
      }
    },
    // スクロールエリアサイズの設定
    setScrollAreaSize() {
      // -----height-----
      // ヘッダー高の取得
      const headerHeight = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
      // フッター高の取得
      const footerHeight = getFooterMenuClientHeight(this.$el || null);
      // スクロールエリア高の計算
      const scrollAreaHeight = this.windowHeight - headerHeight - footerHeight - 20;
      // スクロールテーブル高の取得
      const scrollTableHeight = this.getScopedElementById("scrollTable").clientHeight;
      // スクロールエリア高 > スクロールテーブル高
      if (scrollAreaHeight > scrollTableHeight) {
        // 横スクロールバーの高さ
        const scrollArea = this.getScopedElementById("scrollArea");
        const scrollBarHeight = scrollArea.offsetHeight - scrollArea.clientHeight;
        // 固定テーブル高 + 調整高
        const val = scrollTableHeight + scrollBarHeight;
        // スクロールエリア高の設定
        this.getScopedElementById("scrollArea").style.height = val + "px";
      } else {
        // スクロールエリア高 - 調整高
        const val = scrollAreaHeight + (20 - 8);
        // スクロールエリア高の設定
        this.getScopedElementById("scrollArea").style.height = val + "px";
      }
      // -----width-----
      // サイドバー開閉有無の取得
      const sideBarIsOpen = this.getScopedElementById("patientSearchSidebarArea").style.cssText.toString().indexOf("transform:") === -1;
      // 固定エリア幅の取得
      const fixedAreaWidth = this.getScopedElementById("fixedArea").clientWidth;
      // サイドバー閉の場合
      if (!sideBarIsOpen) {
        // 画面表示幅 - 固定エリア幅 - 調整幅
        const val = this.windowWidth - fixedAreaWidth - 10;
        // スクロールエリア幅の設定
        this.getScopedElementById("scrollArea").style.width = val + "px";
      } else {
        // 画面表示幅(サイドバー含む) - 固定エリア幅 - 調整幅
        const val = this.mainWindowWidth - fixedAreaWidth - 11;
        // スクロールエリア幅の設定
        this.getScopedElementById("scrollArea").style.width = val + "px";
      }
    },
    // スクロールテーブル幅の初期化
    initScrollTableWidth() {
      // 日付数の取得
      const cols = this.getScrollTableHeaderCells().length;
      // 最小幅 * 日付数 + バッファー
      const val = this.minWidth * cols + this.buffer;
      // スクロールテーブル幅の設定
      this.getScopedElementById("scrollTable").style.width = val + "px";
    },
    // スクロールテーブル幅の取得
    getScrollTableWidth() {
      // スクロールテーブル幅の初期値
      let val = 0;
      // 日付数の取得
      const scrollThList = this.getScrollTableHeaderCells();
      const cols = scrollThList.length;
      // 列件数処理
      for (let i=0; i < cols; i++) {
        // ヘッダーの取得
        const th = scrollThList[i];
        // 日付列幅の取得
        const dateWidth = Number(th.style.width.replace("px", ""));
        // 日付列幅の加算
        val += dateWidth;
      }
      return val;
    },
    // スクロールテーブル幅の設定
    setScrollTableWidth() {
      // ヘッダーの取得
      let th = this.getScopedElementById(this.targetID);
      // ヘッダー幅の取得
      const thWidth = Number(th.style.width.replace("px", ""));
      // 現在列幅の評価
      const currentWidth = this.evaluateCurrentWidth(thWidth, this.maxWidth, this.minWidth);
      // 基準(前回)列幅の取得
      const baseWidth = Number(th.style.getPropertyValue("--base-width").replace("px", ""));
      // スクロールテーブル幅の取得
      const scrollTableWidth = this.getScrollTableWidth();
      // スクロールテーブル幅の計算
      const val = this.calculateScrollTableWidth(scrollTableWidth, currentWidth, baseWidth);
      // スクロールテーブル幅の設定
      this.getScopedElementById("scrollTable").style.width = val + this.buffer + "px";
      // 現在列幅の記録
      th.style.width = currentWidth + "px";
      // 基準(前回)列幅の記録
      th.style.setProperty("--base-width", currentWidth + "px");
    },
    // 現在列幅の評価
    evaluateCurrentWidth(targetWidth, maxWidth, minWidth) {
      // 評価
      if (targetWidth > maxWidth) {
        // 最大値：400px
        return maxWidth;
      } else if (targetWidth < minWidth) {
        // 最小値：150px
        return minWidth;
      } else {
        // 許容値：150px ～ 400px
        return targetWidth;
      }
    },
    // スクロールテーブル幅の計算
    calculateScrollTableWidth(scrollTableWidth, currentWidth, baseWidth) {
      // 現在幅 > 基準幅 もしくは、現在幅 < 基準幅
      if (currentWidth > baseWidth || currentWidth < baseWidth) {
        // スクロールテーブル幅 + 変化値
        return scrollTableWidth + (currentWidth - baseWidth);
      } else {
        // 同値
        return scrollTableWidth;
      }
    },
    // スクロールバーの設定
    setScrollBar() {
      // サイドバー開閉有無の取得
      const sideBarIsOpen = this.getScopedElementById("patientSearchSidebarArea").style.cssText.toString().indexOf("transform:") === -1;
      // 固定エリア幅の取得
      const fixedAreaWidth = this.getScopedElementById("fixedArea").clientWidth;
      // スクロールテーブル幅の取得
      const scrollTableWidth = this.getScrollTableWidth();
      // 日付数の取得
      const scrollThList = this.getScrollTableHeaderCells();
      const cols = scrollThList.length;
      // スクロールテーブル一列目幅の取得
      const scrollTableColumnWidth = cols > 0 ? scrollThList[0].clientWidth : 0;
      // 固定エリア幅 + スクロールテーブル一列目幅
      const val_1 = fixedAreaWidth + scrollTableColumnWidth;
      // 固定エリア幅 + スクロールテーブル幅 + バッファー
      const val_2 = fixedAreaWidth + scrollTableWidth + this.buffer;
      // サイドバー閉の場合
      if (!sideBarIsOpen) {
        // 画面表示幅 > 固定エリア幅 + スクロールテーブル一列目幅の場合
        if (this.windowWidth > val_1) {
          // 画面表示幅 > 固定エリア幅 + スクロールテーブル幅の場合
          if (this.windowWidth > val_2) {
            // 日付数 = "0"の場合
            if (cols == 0) {
              // 固定エリアオーバーフローの有効化
              this.enableFixedAreaOverflow("Y");
            } else {
              // スクロールエリアオーバーフローの有効化
              this.enableScrollAreaOverflow("Y");
            }
            // スクロールテーブル幅 + バッファー
            const val = scrollTableWidth + this.buffer;
            // 全体エリアサイズの最適化
            this.optimizeAllAreaSize(true);
            // スクロールエリア幅の再設定
            this.getScopedElementById("scrollArea").style.width = "auto";
            // スクロールテーブル幅の再設定
            this.getScopedElementById("scrollTable").style.width = val + "px";
            // 全体エリアスクロール状態
            this.scrollState = true;
            // スクロール(Y)状態
            this.isScrollY = true;
          } else {
            // スクロールテーブル幅 + バッファー
            const val = scrollTableWidth + this.buffer;
            // スクロールエリアオーバーフローの有効化
            this.enableScrollAreaOverflow("XY");
            // 全体エリアサイズの最適化
            this.optimizeAllAreaSize(true);
            // スクロールテーブル幅の再設定
            this.getScopedElementById("scrollTable").style.width = val + "px";
            // スクロールエリアスクロール状態
            this.scrollState = false;
            // スクロール(XY)状態
            this.isScrollY = false;
          }
        } else {
          // 全体エリアオーバーフローの有効化
          this.enableAllAreaOverflow("XY");
          // 全体エリアサイズの最適化
          this.optimizeAllAreaSize(false);
          // 全体エリアスクロール状態
          this.scrollState = true;
          // スクロール(XY)状態
          this.isScrollY = false;
        }
      } else {
        // 画面表示幅(サイドバー含む) > 固定エリア幅 + スクロールテーブル一列目幅の場合
        if (this.mainWindowWidth > val_1) {
          // 画面表示幅(サイドバー含む) > 固定エリア幅 + スクロールテーブル幅の場合
          if (this.mainWindowWidth > val_2) {
            // 日付数 = "0"の場合
            if (cols == 0) {
              // 固定エリアオーバーフローの有効化
              this.enableFixedAreaOverflow("Y");
            } else {
              // スクロールエリアオーバーフローの有効化
              this.enableScrollAreaOverflow("Y");
            }
            // スクロールテーブル幅 + バッファー
            const val = scrollTableWidth + this.buffer;
            // 全体エリアサイズの最適化
            this.optimizeAllAreaSize(true);
            // スクロールエリア幅の再設定
            this.getScopedElementById("scrollArea").style.width = "auto";
            // スクロールテーブル幅の再設定
            this.getScopedElementById("scrollTable").style.width = val + "px";
            // 全体エリアスクロール状態
            this.scrollState = true;
            // スクロール(Y)状態
            this.isScrollY = true;
          } else {
            // スクロールテーブル幅 + バッファー
            const val = scrollTableWidth + this.buffer;
            // スクロールエリアオーバーフローの有効化
            this.enableScrollAreaOverflow("XY");
            // 全体エリアサイズの最適化
            this.optimizeAllAreaSize(true);
            // スクロールテーブル幅の再設定
            this.getScopedElementById("scrollTable").style.width = val + "px";
            // スクロールエリアスクロール状態
            this.scrollState = false;
            // スクロール(XY)状態
            this.isScrollY = false;
          }
        } else {
          // 全体エリアオーバーフローの有効化
          this.enableAllAreaOverflow("XY");
          // 全体エリアサイズの最適化
          this.optimizeAllAreaSize(false);
          // 全体エリアスクロール状態
          this.scrollState = true;
          // スクロール(XY)状態
          this.isScrollY = false;
        }
      }
    },
    // 全体エリアオーバーフローの有効化
    enableAllAreaOverflow() {
      // オーバーフロー
      this.getScopedElementById("allArea").style.overflow = "auto";
      this.getScopedElementById("fixedArea").style.overflow = "initial";
      this.getScopedElementById("scrollArea").style.overflow = "initial";
      // 位置
      this.getScopedElementById("fixedArea").style.left = "auto";
      // 調整(1)
      this.getScopedElementById("fixedArea").style.height = "max-content";
      this.getScopedElementById("scrollAdjustArea").style.marginTop = "0px";
      // 調整(2)
      this.getScopedElementById("scrollArea").style.height = "max-content";
    },
    // 固定エリアオーバーフローの有効化
    enableFixedAreaOverflow(type) {
      // オーバーフロー
      this.getScopedElementById("allArea").style.overflow = "hidden";
      this.getScopedElementById("fixedArea").style.overflowX = "hidden";
      this.getScopedElementById("fixedArea").style.overflowY = "auto";
      this.getScopedElementById("scrollArea").style.overflow = "hidden";
      // 位置
      this.getScopedElementById("fixedArea").style.left = "auto";
      // 調整
      this.getScopedElementById("scrollAdjustArea").style.marginTop = "0px";
    },
    // スクロールエリアオーバーフローの有効化
    enableScrollAreaOverflow(type) {
      // オーバーフロー
      this.getScopedElementById("allArea").style.overflow = "hidden";
      this.getScopedElementById("fixedArea").style.overflow = "hidden";
      if (type == "XY") {
        this.getScopedElementById("scrollArea").style.overflow = "auto";
        this.getScopedElementById("fixedArea").style.overflowX = "scroll";
      } else {
        this.getScopedElementById("scrollArea").style.overflowX = "hidden";
        this.getScopedElementById("scrollArea").style.overflowY = "auto";
      }
      // 位置
      this.getScopedElementById("fixedArea").style.left = "0";
    },
    // 全体エリアサイズの最適化
    optimizeAllAreaSize(isScrollAreaOverflow) {
      // スクロールエリアオーバーフローの場合
      if (isScrollAreaOverflow) {
        // 全体エリアの最大化
        this.getScopedElementById("allArea").style.width = "max-content";
        this.getScopedElementById("allArea").style.height = "max-content";
      } else {
        // 全体エリアの初期化
        this.getScopedElementById("allArea").style.width = "auto";
        this.getScopedElementById("allArea").style.height = "auto";
      }
    },
    // スクロール位置の設定
    setScrollPosition(event = null) {
      // イベント = "NULL"の場合
      if (event == null) {
        // スクロールトップの取得
        const scrollTop = this.getScopedElementById("scrollArea").scrollTop;
        // (固定エリア)スクロール位置の同期
        this.getScopedElementById("fixedArea").scrollTop = scrollTop;
      } else {
        // スクロールトップの取得
        const scrollTop = event.target.scrollTop;
        // (固定エリア)スクロール位置の同期
        this.getScopedElementById("fixedArea").scrollTop = scrollTop;
      }
    },
    // 固定テーブル列最小幅の補正
    resetFixedTableColumnMinWidth() {
      // 全体エリアスクロール状態の場合
      if (this.scrollState) {
        // -----装置名-----
        if (this.isDisplayMachineName) {
          // 列幅の取得
          const machineNameWidth = this.getScopedElementById("machineName").style.width != "" ? Number(this.getScopedElementById("machineName").style.width.replace("px", "")) : this.minWidth;
          // 現在列幅の評価
          const currentMachineNameWidth = this.evaluateCurrentWidth(machineNameWidth, this.maxWidth, this.minWidth);
          // 最小列幅の設定
          this.getScopedElementById("machineName").style.minWidth = currentMachineNameWidth + "px";
        }
        // -----種別-----
        if (this.isDisplaySurveyType) {
          // 列幅の取得
          const surveyTypeNameWidth = this.getScopedElementById("surveyTypeName").style.width != "" ? Number(this.getScopedElementById("surveyTypeName").style.width.replace("px", "")) : this.minWidth;
          // 現在列幅の評価
          const currentSurveyTypeNameWidth = this.evaluateCurrentWidth(surveyTypeNameWidth, this.maxWidth, this.minWidth);
          // 最小列幅の設定
          this.getScopedElementById("surveyTypeName").style.minWidth = currentSurveyTypeNameWidth + "px";
        }
        // -----検査箇所名-----
        // 列幅の取得
        const pointNameWidth = this.getScopedElementById("pointName").style.width != "" ? Number(this.getScopedElementById("pointName").style.width.replace("px", "")) : this.minWidth;
        // 現在列幅の評価
        const currentPointNameWidth = this.evaluateCurrentWidth(pointNameWidth, this.maxWidth, this.minWidth);
        // 最小列幅の設定
        this.getScopedElementById("pointName").style.minWidth = currentPointNameWidth + "px";
      } else {
        // -----装置名-----
        // 最小列幅の初期化
        if (this.isDisplayMachineName) this.getScopedElementById("machineName").style.minWidth = "";
        // -----種別-----
        // 最小列幅の初期化
        if (this.isDisplaySurveyType) this.getScopedElementById("surveyTypeName").style.minWidth = "";
        // -----検査箇所名-----
        // 最小列幅の初期化
        this.getScopedElementById("pointName").style.minWidth = "";
      }
    },
    // 横スクロールを最右端へ移動（最新日付列を表示）
    applyHorizontalScrollEnd(scrollElement) {
      if (!scrollElement) return 0;
      const maxScrollLeft = scrollElement.scrollWidth - scrollElement.clientWidth;
      const scrollLeft = maxScrollLeft > 0 ? maxScrollLeft : 0;
      scrollElement.scrollLeft = scrollLeft;
      return scrollLeft;
    },
    // スクロール開始位置（初期表示は横スクロール最右）
    setScrollStartPostion(retryCount = 0) {
      const scrollArea = this.getScopedElementById("scrollArea");
      if (!scrollArea) return;

      const cols = scrollArea.querySelector("thead tr")?.children;
      if (!cols || !cols.length) {
        if (retryCount < 30) {
          setTimeout(() => {
            this.setScrollStartPostion(retryCount + 1);
          }, 100);
        }
        return;
      }
      // セル幅が有効な状態になっていなければ再実行する
      if (!cols[0].scrollWidth) {
        if (retryCount < 30) {
          setTimeout(() => {
            this.setScrollStartPostion(retryCount + 1);
          }, 100);
        }
        return;
      }

      this.scrollLeftPosition = this.applyHorizontalScrollEnd(scrollArea);
      // 全体エリア横スクロール時は allArea も最右へ
      if (this.scrollState && !this.isScrollY) {
        const allArea = this.getScopedElementById("allArea");
        this.applyHorizontalScrollEnd(allArea);
      }
    },
    // レイアウトの再調整
    modifyLayout() {
      // テーブル高の同期
      this.syncTableHeight();
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
      // 固定テーブル列最小幅の補正
      this.resetFixedTableColumnMinWidth();
      setTimeout(() => {
        // ここまでのレイアウト計算処理結果によって
        // スクロールバーの表示状態が変化してからレイアウトを再計算する
        // （nextTickではDOMのレンダリング結果の変化を待てないようなのでsetTimeoutを使用する）
        // 表示エリアサイズの設定
        this.setDisplayAreaSize();
        // 固定テーブル列最小幅の補正
        this.resetFixedTableColumnMinWidth();
      });
    },
    onTouchStart(event) {
      if (event.touches.length === 1) {
        this.touchStartY = event.touches[0].clientY;
      }
    },
    onTouchMove(event) {
      if (event.touches.length === 1) {
        const currentY = event.touches[0].clientY;
        const deltaY = this.touchStartY - currentY;
        const fixedArea = this.getScopedElementById("fixedArea");
        const scrollArea = this.getScopedElementById("scrollArea");
        fixedArea.scrollTop += deltaY;
        scrollArea.scrollTop = fixedArea.scrollTop;
        this.touchStartY = currentY;
      }
    },
  },
  watch: {
    // WindowHeightの監視
    windowHeight() {
      // レイアウトの再調整
      this.modifyLayout();
    },
    // WindowWidthの監視
    windowWidth() {
      // add start 馬 #10362
      const element = this.getScopedElementById('app');
      const computedStyle = this.getScopedComputedStyle(element);
      if (computedStyle?.display === 'none') {
        return;
      }
      // add start 馬 #10362
      // レイアウトの再調整
      this.modifyLayout();
    },
    // SideBarWidthの監視
    sidebarWidth() {
      // add start 馬 #10362
      const element = this.getScopedElementById('app');
      const computedStyle = this.getScopedComputedStyle(element);
      if (computedStyle?.display === 'none') {
        return;
      }
      // add start 馬 #10362
      // レイアウトの再調整
      this.modifyLayout();
    },
    // FontSizeの監視
    getFontSize() {
      // 印刷中はスキップ
      if (this.isPrint) return;

      // レイアウトの再調整
      this.modifyLayout();
    },
    // 登録データの監視
    sortMntWaterSurvey() {
      this.$nextTick(() => {
        // DOM更新前スクロールトップの保持
        this.beforeUpdateScrollTopPosition = this.scrollTopPosition;
        // DOMの更新時
        setTimeout(() => {
          // バッファーの取得
          this.getBufferSize();
          // スクロールテーブル幅の初期化
          this.initScrollTableWidth();
          // テーブル高の同期
          this.syncTableHeight();
          // 表示エリアサイズの設定
          this.setDisplayAreaSize();
          // 固定テーブル列最小幅の補正
          this.resetFixedTableColumnMinWidth();
          // 画面操作時のスクロール位置の設定
          const scrollArea = this.getScopedElementById("scrollArea");
          scrollArea.scrollTop = this.beforeUpdateScrollTopPosition;
          // 初回グリッド描画時は setScrollStartPostion で最右へスクロールする
          if (this.setScrollStartPostionState !== ScrollStartPostionState.AfterInitGrid) {
            scrollArea.scrollLeft = this.scrollLeftPosition;
          }
          // 固定エリアのスクロール位置を設定
          this.setScrollPosition();
          setTimeout(() => {
            // ここまでのレイアウト計算処理結果によって
            // スクロールバーの表示状態が変化してからレイアウトを再計算する
            // （nextTickではDOMのレンダリング結果の変化を待てないようなのでsetTimeoutを使用する）
            // 表示エリアサイズの設定
            this.setDisplayAreaSize();
            // 固定テーブル列最小幅の補正
            this.resetFixedTableColumnMinWidth();
            if (this.setScrollStartPostionState === ScrollStartPostionState.AfterInitGrid) {
              // 画面開始時のスクロール位置設定処理状態を進める
              this.setScrollStartPostionState = ScrollStartPostionState.AfterSetPositon;
              // スクロール開始位置
              this.setScrollStartPostion();
            }
          });
        });
      });
    },
    selectedList(value) {
      value = (Array.isArray(value) ? value : []).map(v => String(v));
      if (value.join("|") !== this.selectedList.map(v => String(v)).join("|")) {
        this.selectedList = value;
        return;
      }
      // add FNSI-全選択チェックボックスの動作不具合の修正 江 start
      if(value.length===this.sortMntWaterSurvey.length)
      {
        this.selectedAllList = ["-1"];
      }else{
        this.selectedAllList = [];
      }
      //add #9558 水質管理一覧のヘッダ部から個別画面に遷移すると、機能帳票の制御が「一覧」のままになる 杜 start
      if (this.selectedAllList.length == 0) {
        let maListNew = [];
        for (var index = 0 ;index < value.length;index++) {
          maListNew[index] = this.sortMntWaterSurvey[parseInt(value[index]) - 1];
        }
        this.waterMaList = maListNew;
      }
      //add #9558 水質管理一覧のヘッダ部から個別画面に遷移すると、機能帳票の制御が「一覧」のままになる 杜 end
      // add FNSI-全選択チェックボックスの動作不具合の修正 江 end
      this.filterDataSelected(value);
      this.setSelectedList(value);
    },
    // del FNSI-全選択チェックボックスの動作不具合の修正 江 start
    // selectedAllList(value) {
    //   // ケースチェックボックスすべて選択が選択されています
    //   if (value.length > 0) {
    //     this.selectedList = Object.keys(this.sortMntWaterSurvey).map(k =>
    //       (+k + 1).toString()
    //     );
    //   } else {
    //     // ケースチェックボックスは選択されていないすべてを選択します
    //     this.selectedList = [];
    //   }
    // }
    // del FNSI-全選択チェックボックスの動作不具合の修正 江 end
  },
  async created() {
    // 画面名称取得
    this.selfScreenName = this.$route.name;
    // 端末判別
    const ua = ((this?.$el?.ownerDocument?.defaultView?.navigator?.userAgent) || globalThis?.navigator?.userAgent || "").toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    // 非同期処理を行う前にレンダリング中に使用されうるMapを持つStore項目を初期化しておく
    this.setResultText(this.resultTextMap);
    // #9451対応時のメモ：
    // 本来はStoreの永続化処理では復元できないMapオブジェクトを
    // Storeのstateに入れること自体を避けるべきと思われる。
    // #9451で setResultText のタイミングを修正して回避した
    // 不具合についてはredmineを参照してください。

    // ヘッダーからのイベントは非同期初期化前に受け付けられるようにする
    this.registerWaterQualityEventHandlers();

    // 休日マスタの休日を取得
    await this.fetchHolidays(this.getFacilityCd);
    // add  FNSI-権限 姜 start
    this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    // add  FNSI-権限 姜 end
    // add 性能改善メモリ不足 shan start
    this.registerWaterQualityEventHandlers();
    // add 性能改善メモリ不足 shan end

    try {
      this.setLoadingScreenVisible(true);
      // じょはく mod メモリにて利用者マスタ一覧取得 Start
      const [
        responseMstSurveyType,
        responseMstSurveyPoint,
        // responseMstUser,
        responseMstBed,
        responseMstMachine
      ] = await Promise.all([
        ApiHelper.get("mstInfo/mstWaterSurveyType"),
        ApiHelper.get("mstInfo/mstWaterSurveyPoint"),
        // ApiHelper.get(`/mstInfo/mstPersonalUser`, {
        //   facility_cd: this.getFacilityCd
        // }),
        ApiHelper.get(`/mstInfo/mstBed`, {
          facility_cd: this.getFacilityCd,
          is_disp: 1,
          is_del: 0
        }),
        ApiHelper.get(`mstInfo/mstMachine`, {
          facility_cd: this.getFacilityCd
        })
      ]);
      // じょはく mod メモリにて利用者マスタ一覧取得 end

      const mstSurveyType = responseMstSurveyType.data;
      // add FNSI-バグ 水質管理779 徐 start
      for (var i = 0; i < mstSurveyType.length; i++) {
        const initialString = mstSurveyType[i].initialString;
        if (initialString && initialString != "") {
          const initialStringJson = JSON.parse(initialString);
          if (typeof initialStringJson == "object" && initialStringJson.length > 0) {
            var resultText = "[";
            for (var j = 0; j <initialStringJson.length; j++) {
              //mod #11945 水質管理 結果文字列に関する複数のバグ zrx start
              // resultText = resultText + "{\"cd\": " + (j + 1) + ", \"text\": \"" + initialStringJson[j].text + "\"},";
              resultText = resultText + "{\"cd\": \"" + initialStringJson[j].text + "\", \"text\": \"" + initialStringJson[j].text + "\"},";
              //mod #11945 水質管理 結果文字列に関する複数のバグ zrx end
            }
            resultText = resultText.substring(0, resultText.length - 1);
            resultText = resultText + "]";
            this.resultTextMap.set(mstSurveyType[i].surveyTypeCd, resultText);
          }
          //add #11945 水質管理 結果文字列に関する複数のバグ zrx start
          if(initialStringJson.length == 0) {
            let resultText = JSON.stringify([{ cd: "", text: "" }]);
            this.resultTextMap.set(mstSurveyType[i].surveyTypeCd, resultText);
          }
          //add #11945 水質管理 結果文字列に関する複数のバグ zrx end
        }
      }
      // add FNSI-バグ 水質管理779 徐 end
      const mstSurveyPoint = responseMstSurveyPoint.data;

      this.machineSortList = responseMstMachine.data;

      this.listMstBed = responseMstBed.data;
      this.setMstSurveyType(mstSurveyType);
      this.setMstSurveyPoint(mstSurveyPoint);
      // じょはく add メモリにて利用者マスタ一覧取得 Start
      let mstPersonalUser = this.getMstPersonalUser();
      // メモリにて利用者マスタ一覧情報がない場合、APIを呼出する
      if (!mstPersonalUser) {
        await ApiHelper.get(`/mstInfo/mstPersonalUser`, {
          facility_cd: this.getFacilityCd
        }).then(
          response => {
            mstPersonalUser = response.data;
          }
        );
      }
      this.setMstUser(mstPersonalUser);
      // じょはく add メモリにて利用者マスタ一覧取得 End
      this.filterData(true);
      this.setLoadingScreenVisible(false);
    } catch (error) {
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
      getErrorMessage('WaterQualitySurveyComponent.vue','created',error);
      //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
      this.setLoadingScreenVisible(false);
      this.internalServerError(error);
    }
  },
  beforeUnmount() {
    this.clearHolidays(); // storeの休日マスタをクリア
    this.unregisterWaterQualityEventHandlers();
    // インターバルの削除
    this.disposeInterval();
    // 対象IDの削除
    this.targetID = null;
  }
};
</script>

<style scoped>
tr {
  /* 設定しなくても表示に問題がない高さは自動で確保される */
  height: 2.2em;
}
td {
  border: solid var(--ntss-list-border-color);
  border-width: 0px 1px 1px 0px;
  text-align: center;
  padding: 4px;
  height: 30px;
  white-space: nowrap;
  color: var(--ntss-base-color);
}
.check-box {
  width: 1rem;
  white-space: normal;
  text-align: center;
}
.ntss-list-header-th-sticky {
  z-index: 9;
  white-space: unset;
  text-align: center;
}
/* ボタングループのスタイル定義 */
.ntss-button-group {
  width: 15em;
  display: flex;
}
.col-sticky-check {
  left: 0;
  position: -webkit-sticky;
  position: sticky;
  z-index: 0;
}
.sticky-col-checkbox {
  max-width: 2em;
  min-width: 2em;
  width: 2em;
}
.sticky-col-checkbox {
  text-align: center;
}
.sticky-col-equipment {
  max-width: 400px;
  min-width: 150px;
  width: 150px;
}
.sticky-col-type {
  max-width: 400px;
  min-width: 150px;
  width: 150px;
}
.sticky-col-point {
  max-width: 400px;
  min-width: 150px;
  width: 150px;
}
.sticky-col-equipment,
.sticky-col-type,
.sticky-col-point {
  text-align: left;
}
.scroll-table {
  display: flex;
  max-height: -webkit-fill-available;
  width: max-content;
}
.fixed-area {
  left: 0;
  position: sticky;
  white-space: nowrap;
  width: auto;
  will-change: transform;
  z-index: 999;
}
.scroll-area {
  margin-left: -1px;
  overflow-y: visible;
  will-change: transform;
  width: auto;
}
.grid-record-list {
  border-collapse: collapse;
  background-color: var(--ntss-list-background-color);
}
.grid-record-list :deep(tr:nth-child(even)) {
  background-color: var(--ntss-list-content-2nd-background-color);
}
.scroll-table-data {
  border-collapse: collapse;
  background-color: var(--ntss-list-background-color);
}
.scroll-table-data :deep(tr:nth-child(even)) {
  background-color: var(--ntss-list-content-2nd-background-color);
}
.popover-content-row {
  margin-bottom: 10px;
}
.popover-content :deep(.popover--top),
.popover-content :deep(.popover--right),
.popover-content :deep(.popover--left),
.popover-content :deep(.popover--bottom) {
  min-width: initial;
}
.popover-content-plan :deep(.popover__content) {
  width: 200px;
  min-height: auto;
}
.popover-content-header :deep(.popover__content) {
  width: 200px;
  min-height: auto;
}
.popover-content-div {
  margin: 5px;
}
</style>
<style lang="scss" scoped>
.calendar-date {
  background-color: var(--ntss-list-header-background-color);
  text-align: center;
  &-Today-Holiday {
    background-color: #2ca06f;
    color: var(--ntss-holiday-color);
  }
  &-Today-Saturday {
    background-color: #2ca06f;
    color: var(--ntss-saturday-color);
  }
  &-Today-Sunday {
    background-color: #2ca06f;
    color: var(--ntss-sunday-color);
  }
  &-Today-OtherMonth {
    background-color: #2ca06f;
    color: #e4e4e4;
  }
  &-Holiday {
    background-color: var(--ntss-list-header-background-color);
    color: var(--ntss-holiday-color);
  }
  &-Saturday {
    background-color: var(--ntss-list-header-background-color);
    color: var(--ntss-saturday-color);
  }
  &-Sunday {
    background-color: var(--ntss-list-header-background-color);
    color: var(--ntss-sunday-color);
  }
  &-OtherMonth {
    background-color: var(--ntss-list-header-background-color);
    color: #e4e4e4;
  }
}
.manual-width {
  resize: horizontal;
  overflow: hidden;
}
.clickable-header-label {
  display: block;
  height: 100%;
  width: 100%;
  align-content: center;
  padding: 0 4px;
  box-sizing: border-box;
  overflow: hidden;
}
.word-break-th {
  word-wrap: break-word;
}
.word-break-td {
  white-space: pre-wrap;
  word-break: break-all;
}
/* 固定列・横スクロールバーの表示調整 */
.fixed-area {
  /* スクロールバーのつまみ部分とトラック部分の色 */
  scrollbar-color: var(--ntss-list-background-color) var(--ntss-list-background-color);
}
.fixed-area::-webkit-scrollbar-thumb {
  /* スクロールバーのつまみ部分の色 */
  background-color: var(--ntss-list-background-color);
}
.fixed-area::-webkit-scrollbar-track {
  /* スクロールバーのトラック部分の色 */
  background-color: var(--ntss-list-background-color);
}
.fixed-area::-webkit-scrollbar-button {
  /* スクロールバーの矢印を非表示にする */
  display: none;
}

@media print {
  #allArea {
    width: 100% !important;
  }

  /** 固定列、スクロールコンテナ */
  #fixedArea {
    overflow: visible !important;
    height: auto !important;
  }
  #scrollArea {
    overflow: hidden !important;
    height: auto !important;
  }

  /** テーブル */
  #fixedTable {
    table-layout: fixed !important;
    width: auto !important;
  }
  #scrollTable {
    table-layout: fixed !important;
  }
  #fixedTable tr,
  #scrollTable tr {
    page-break-inside: avoid;
    break-inside: avoid;
  }

  /* 右端スクロール時はテーブルを右寄せ */
  #scrollArea:has(table.scroll-rightmost) {
    display: flex;
    justify-content: flex-end;
  }
}
</style>
