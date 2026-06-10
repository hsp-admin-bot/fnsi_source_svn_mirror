/**
 * 体重計測定記録画面
 */
<template>
<div>
  <!-- mod FNSI-redmine3971 徐 start -->
  <!--#10567:体重測定記録画面の表示不正 Start -->
  <div id="scrollArea" class="main-content-area" style="overflow:scroll;" :class="{ 'weight-mode-measure-history-scroll-area': isWeightMode }" ref="ntssList">
  <!--#10567:体重測定記録画面の表示不正 End -->
  <!-- mod FNSI-redmine3971 徐 end -->
    <!-- 体重計測定記録一覧のグリッド -->
    <!-- mod FNSI-バグ 体重測定記録462 徐 start -->
    <!-- mod FNSI-redmine5437 張岩 start -->
    <!-- mod FNSI-redmine5373 張岩 start -->
    <!-- mod FNSI-redmine3971 徐 start -->
    <div :style="{ height: !isWeightMode ? '110%' : null }">
      <table class="ntss-list" id="table" :style="getWidthValue()">
      <!-- mod FNSI-redmine3971 徐 end -->
      <!-- mod FNSI-バグ 体重測定記録462 徐 end -->
      <!-- mod FNSI-redmine5373 張岩 end -->
        <thead>
          <tr>
            <th
              v-for="column in columns"
              :key="column.key"
              class="ntss-list-header-th-sticky"
              :style="{ 'min-width':column.minWidth + 'em' }"
            >{{ column.colName }}</th>
          </tr>
        </thead>
        <tr
          v-for="(measureHistory, idx) in measureHistoryList"
          :key="idx"
          :class="'ntss-list-body-tr'"
          @click="onClickRow(measureHistory)"
          style="height: 1.1rem;"
        >
          <td
            v-if="measureHistory.isHeader"
            :colspan="columns.length"
            :class="[
              'ntss-list-body-td-header',
              'ntss-list-body-td',
              getStyle(measureHistory.label)
            ]"
          >{{ measureHistory.label }}</td>
          <td
            v-else
            v-for="column in columns"
            class="ntss-list-body-td"
            :key="column.className"
            style="text-align: left;"
            :style="{ 'min-width':column.minWidth + 'em' }"
          >{{ column.text(measureHistory) }}</td>
        </tr>
        <!-- mod FNSI-redmine3971 徐 start -->
        <tr></tr>
        <!-- mod FNSI-redmine3971 徐 end -->
      </table>
    </div>
  </div>
  <!-- mod FNSI-redmine5437 張岩 end -->

  <!-- 体重モード時、キャンセルボタンと体重計情報を表示 -->
  <div v-if="isWeightMode" id="weight-mode-measure-history-footer">
    <div class="weight-mode-measure-history-btn-area">
      <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
    </div>
    <div class="weight-mode-measure-history-time-content">
      <span style="margin-left: 1em;">{{weightName}}</span>
      <span style="margin-left: 1em;">{{ymdTime}}</span>
    </div>
  </div>

</div>
</template>

<script>
import { mapGetters, mapActions } from "vuex";
import { EventBus } from "@/eventBus.js";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import {
  weightScaleStateMsg,
  weightScaleClassMsg,
  weightScaleModeMsg
} from "@/functions/common/WeightFunctions";
import { weightScaleState } from "@/constants/weightDefine";
import { dateFormat } from "@/functions/common/DateTimeUtils";
// jQureyを宣言（'$'はvue.jsで使用されているため、'$$'で宣言）
const $$ = require("jquery");
import moment from "moment";
import { getCurrentFunctionCd } from "@/router/routing-helper";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
import { getHolidayStyle } from "@/functions/common/CommonFunctions";
import PrintMixin from "@/components/PrintMixin";
export default {
  props: {
    // NOTE: コンソールエラー対策
    historyKey: null,
  },
  components: {},
  mixins: [NextTransitionMixin, PrintMixin],
  data() {
    return {
      firstCondition: {
        startDate: "",
        endDate: ""
      },
      condition: {
        measureDate: "",
        kurCd: -1,
        bedGroupCd: -1,
        freeWord: "",
        weightScaleStatus: -1
      },
      /**
       * 検索条件
       */
      fetchCondition: {
        startDate: "",
        endDate: ""
      },
      /**
       * ソート条件
       */
      sort: {
        key: "sortKey",
        isAsc: false
      },
      isRedrawing: false,
      // add FNSI-redmine3969 徐 start
      refreshCheck: true,
      // add FNSI-redmine3969 徐 end
      // add FNSI-redmine3971 徐 start
      updateCheck: true,
      // add FNSI-redmine3971 徐 end
      //自画面の名称
      selfScreenName: "",
      // 体重計モード用 画面表示用の年月日時分
      ymdTime: "",
      // 体重計モード用 画面表示用の年月日時分更新インターバル
      ymdUpdateProc: null,
      // 体重計モード用 画面表示用の年月日時分更新インターバル開始までの待機時間
      _minuteAlignTimeout: null,
      scrollQuerySelector: "#scrollArea", // スクロールコンテナ
      addClassTargetQuerySelector: ["table.ntss-list"], // scroll-rightmostクラスを付与する対象のクエリセレクタ
    };
  },
  computed: {
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("measure-history/list", [
      "getMstKurSelector",
      "getMstBedGroupList",
      "getWeightScaleStatusList",
      "getMeasureHistoryList",
      "getCondition",
      "getFilterSignal"
    ]),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),

    // add 画面印刷プレビューと印刷の実現 黄 start
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    // add 画面印刷プレビューと印刷の実現 黄 end

    ...mapGetters("send-condition/weight", [
      "getWeightMode"
    ]),
    ...mapGetters("send-condition/scale/setting", [
      "getWeightConfigInfo"
    ]),

    columns() {
      return [
        {
          key: "measureDate",
          colName: "測定日時",
          className: "measureDateBody",
          minWidth: 3,
          text: src => src.measureDateView
        },
        {
          key: "weightScaleStatus",
          // mod FNSI-バグ 体重測定記録460 徐 start
          colName: "測定状況",
          // mod FNSI-バグ 体重測定記録460 徐 end
          className: "weightScaleStatusBody",
          minWidth: 3,
          text: src => weightScaleStateMsg(src.weightScaleStatus)
        },
        // add FNSI-バグ 体重測定記録462 徐 start
        {
          key: "hospPatId",
          colName: "患者ID",
          className: "patIdBody",
          minWidth: 3,
          text: src => src.hospPatId
        },
        {
          key: "patName",
          colName: "患者名",
          className: "patNameBody",
          minWidth: 3,
          // mod 9485 nullを空文字列判定に変換します 張博 start
          text: src => (src.patLastName === null ? "" : src.patLastName) + " " + (src.patFirstName === null ? "" : src.patFirstName)
          // mod 9485 nullを空文字列判定に変換します 張博 end
        },
        {
          key: "scaleValue",
          colName: "測定値(kg)",
          className: "scaleValueBody",
          minWidth: 3,
          text: src => src.scaleValue
        },
        {
          key: "weightValue",
          colName: "体重値(kg)",
          className: "weightValueBody",
          minWidth: 3,
          text: src => src.weightValue
        },
        // add FNSI-バグ 体重測定記録462 徐 end
        {
          key: "message",
          colName: "メッセージ",
          className: "messageBody",
          minWidth: 3,
          text: src => src.message
        },
        {
          key: "kurName",
          colName: "クール",
          className: "kurNameBody",
          minWidth: 3,
          text: src => src.kurName
        },
        {
          key: "bedName",
          colName: "ベッド名",
          className: "bedNameBody",
          minWidth: 3,
          text: src => src.bedName
        },
        // add FNSI-バグ 体重測定記録462 徐 start
        {
          key: "weightName",
          colName: "体重計名称",
          className: "weightNameBody",
          minWidth: 3,
          text: src => src.weightName
        },
        // add FNSI-バグ 体重測定記録462 徐 end
        {
          key: "scaleClass",
          // mod FNSI-バグ 体重測定記録460 徐 start
          colName: "区分",
          // mod FNSI-バグ 体重測定記録460 徐 end
          className: "scaleClassBody",
          minWidth: 3,
          text: src => weightScaleClassMsg(src.scaleClass)
        },
        {
          key: "scaleMode",
          // mod FNSI-バグ 体重測定記録460 徐 start
          colName: "測定種別",
          // mod FNSI-バグ 体重測定記録460 徐 end
          className: "scaleModeBody",
          minWidth: 3,
          text: src => weightScaleModeMsg(src.scaleMode)
        },
        {
          key: "rstTare",
          colName: "風袋合計値(kg)",
          className: "rstTareBody",
          minWidth: 3,
          text: src => src.rstTare
        },
        {
          key: "rstOffWater",
          colName: "除水補正合計値(kg)",
          className: "rstOffWaterBody",
          minWidth: 3,
          text: src => src.rstOffWater
        },
        {
          key: "targetWeightValue",
          colName: "目標体重(kg)",
          className: "targetWeightValueBody",
          minWidth: 3,
          text: src => src.targetWeightValue
        },
        {
          key: "offWaterLimit",
          colName: "除水制限値(kg)",
          className: "offWaterLimitBody",
          minWidth: 3,
          text: src => src.offWaterLimit
        },
        {
          key: "wheelChairName",
          colName: "車いす名",
          className: "wheelChairNameBody",
          minWidth: 3,
          text: src => src.wheelChairName
        },
        {
          key: "wheelChairWeight",
          colName: "車いす重量(kg)",
          className: "wheelChairWeightBody",
          minWidth: 3,
          text: src => src.wheelChairWeight
        },
        {
          key: "staffName",
          // mod FNSI-バグ 体重測定記録460 徐 start
          colName: "実施者",
          // mod FNSI-バグ 体重測定記録460 徐 end
          className: "staffNameBody",
          minWidth: 3,
          text: src => src.staffName
        }
      ];
    },
    measureHistoryList() {
      let returnList = [];
      let lastDate = null;
      for (let element of this.filteredMeasureHistoryList(
        this.getMeasureHistoryList
      )) {
        const currentDateTime = new Date(element.measureDate);
        const currentDate = dateFormat.format(currentDateTime, "yyyy/MM/dd");
        const currentTime = dateFormat.format(currentDateTime, "hh:mm:ss");
        // mod bug 6258 修正 chen start
        element.measureDateView = currentTime;
        element.isHeader = false;
        element.currentDate = currentDate;
        // mod bug 6258 修正 chen end
        // add FNSI-バグ 体重測定記録461 徐 start
        if (element.scaleValue != null && element.scaleValue != 0) {
          element.scaleValue = parseFloat(element.scaleValue).toFixed(2);
        }
        if (element.rstTare != null && element.rstTare != 0) {
          element.rstTare = parseFloat(element.rstTare).toFixed(2);
        }
        if (element.rstOffWater != null && element.rstOffWater != 0) {
          element.rstOffWater = parseFloat(element.rstOffWater).toFixed(2);
        }
        if (element.weightValue != null && element.weightValue != 0) {
          element.weightValue = parseFloat(element.weightValue).toFixed(2);
        }
        if (element.targetWeightValue != null && element.targetWeightValue != 0) {
          element.targetWeightValue = parseFloat(element.targetWeightValue).toFixed(2);
        }
        if (element.offWaterLimit != null && element.offWaterLimit != 0) {
          element.offWaterLimit = parseFloat(element.offWaterLimit).toFixed(2);
        }
        if (element.wheelChairWeight != null && element.wheelChairWeight != 0) {
          element.wheelChairWeight = parseFloat(element.wheelChairWeight).toFixed(2);
        }
        // add FNSI-バグ 体重測定記録461 徐 end
        returnList.push(element);
      }
      // add bug 6258 修正 chen start
      let returnListAll = [];
      let dateList = [];
      const startDateTmp = this.firstCondition.startDate;
      let endDateTmp = this.firstCondition.endDate;
      if (startDateTmp !== "") {
        const startDate = moment(startDateTmp);
        let endDate = moment(endDateTmp);
        let days = (endDate - startDate)/(1*24*60*60*1000);
        let date = moment(endDate);
        for (let i = 0; i < days; i++) {
          date.date(date.date() - 1);
          const dateTmp = date.format("YYYY/MM/DD");
          const dateDisp = date.format("YYYY/MM/DD(dd)");
          if (dateList.findIndex(item => item === dateTmp) === -1) {
            dateList.push(dateTmp);
            returnListAll.push({
              isHeader: true,
              label: dateDisp
            });
          }
          returnList.forEach(item => {
            if (item.currentDate === dateTmp) {
              returnListAll.push(item);
            }
          });
        }
      }
      // add bug 6258 修正 chen end
      return returnListAll;
    },
    fontSizeInPx() {
      switch (this.getFontSize) {
        case 0: return 0.8 * 15;
        case 1: return 1.0 * 15;
        case 2: return 1.1 * 15;
        case 3: return 1.3 * 15;
        default: return 15; // NOTE: fontSize=1が初期値と設定されており、到達することはないが、安全性を考慮し設定しています
      }
    },
    /**
     * 体重計モードかどうかを返却します
     * getWeightModeが存在し、かつisWeightModeがtrueならtrueを返却
     * (!!によって結果を厳密なboolean型に変換して返却)
     */
    isWeightMode() {
      return !!(this.getWeightMode && this.getWeightMode.isWeightMode);
    },
    /**
     * 体重計の表示名を返却します
     */
    weightName() {
      return this.getWeightConfigInfo?.weightName ?? '体重計接続なし';
    },
  },
  methods: {
    ...mapActions("measure-history/list", [
      "setFilterSignal",
      "getOrderMeasureHistoryList"
    ]),
    ...mapActions("send-condition/scale", {
      sendConditionSetSelectOrdNo: "setSelectOrdNo"
    }),
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),
    onClickRow(measureHistory) {
      if (
        measureHistory.isHeader === false &&
        (measureHistory.weightScaleStatus === weightScaleState.wait ||
          measureHistory.weightScaleStatus === weightScaleState.sendFailure)
      ) {
        this.sendConditionSetSelectOrdNo({
          ordNo: measureHistory.ordNo,
          ordNo2: null
        }).then(() => {
          if (this.isWeightMode) {
            // 体重計モード時、体重計モード用体重測定画面へ遷移
            this.goSpecifiedView("weight-send-condition");
          } else {
            // 体重計モード以外の時、通常体重測定画面へ遷移
            this.goSpecifiedView("send-condition");
          }
        });
      }
    },
    setFilterCondition(condition) {
      this.condition = condition;
    },
    /**
     * 初期表示：体重計測定記録情報取得
     */
    OrderMeasureHistoryListFirst() {
      //#10567:体重測定記録画面の表示不正 Start
      let measureDate = this.getCondition.measureDate  ? new Date(this.getCondition.measureDate) : new Date();
      this.firstCondition.startDate = new Date(measureDate);
      this.firstCondition.endDate = new Date(measureDate);
      // 開始日と終了日設定
      this.firstCondition.startDate.setDate(this.firstCondition.startDate.getDate() - 6);
      this.firstCondition.endDate.setDate(this.firstCondition.endDate.getDate() + 1);
      // 再描画フラグ設定
      this.isRedrawing = this.getCondition.measureDate != "";
      //#10567:体重測定記録画面の表示不正 End
      const info = [];
      info.push({
        FacilityCd: this.getFacilityCd,
        isClear: true,
        startDate: this.getSeirekiDateString(this.firstCondition.startDate, ""),
        endDate: this.getSeirekiDateString(this.firstCondition.endDate, "")
      });
      this.getOrderMeasureHistoryList(info)
        .then(() => {
          $$("#scrollArea").scrollTop(1);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MeasureHistoryComponent.vue', 'OrderMeasureHistoryListFirst', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
    },
    updateObserveRecords(isRecordClear) {
      // add FNSI-redmine3971 徐 start
      if (this.updateCheck) {
      // add FNSI-redmine3971 徐 end
      const info = [];
      info.push({
        FacilityCd: this.getFacilityCd,
        isClear: isRecordClear,
        startDate: this.getSeirekiDateString(this.fetchCondition.startDate, ""),
        endDate: this.getSeirekiDateString(this.fetchCondition.endDate, "")
      });
      this.getOrderMeasureHistoryList(info)
        .then(() => {
          this.isRedrawing = false;
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MeasureHistoryComponent.vue', 'updateObserveRecords', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
      // add FNSI-redmine3971 徐 start
      } else {
        this.updateCheck = true;
      }
      // add FNSI-redmine3971 徐 end
    },
    /**
     * 検索条件の日付文字列(yyyyMMdd)を作る
     * @param dt 元の日付(Date型)
     */
    getSeirekiDateString(dt, delimiter) {
      return `${dt.getFullYear()}${delimiter}${`0${dt.getMonth() + 1}`.slice(
        -2
      )}${delimiter}${`0${dt.getDate()}`.slice(-2)}`;
    },
    filterFunction() {
      this.OrderMeasureHistoryListFirst();
    },
    /**
     * フィルタリング処理
     */
    filteredMeasureHistoryList(measureHistory) {
      if (measureHistory.length === 0) {
        return [];
      }
      return measureHistory
        .filter(dat => {
          // クールフィルター作成
          let isFilteringKur = true;
          if (`${this.condition.kurCd}` !== "-1") {
            isFilteringKur =
              dat.kurCd !== null &&
              `${dat.kurCd}` === `${this.condition.kurCd}`;
          }

          // ベッドグループフィルター作成
          let isFilteringBed = true;
          if (this.condition.bedGroupCd > 0) {
            isFilteringBed = false;
            let bedGroup = this.getMstBedGroupList.find(bg => bg.roomBedGroupCd ===  this.condition.bedGroupCd);
            if (bedGroup !== null && bedGroup.bedList)
            {
              for (const bedCd of bedGroup.bedList) {
                if (dat.bedCd === bedCd) {
                  isFilteringBed = true;
                  break;
                }
              }
            }
          }

          // フリーワードフィルター作成
          let isFilteringFreeWord = true;
          if (this.condition.freeWord !== "") {
            isFilteringFreeWord =
              (dat.bedName !== null &&
                dat.bedName.includes(this.condition.freeWord)) || // ベッド名
              (dat.patLastName !== null &&
                dat.patLastName.includes(this.condition.freeWord)) || // 患者名
              (dat.patFirstName !== null &&
                dat.patFirstName.includes(this.condition.freeWord)) ||
              (dat.wheelChairName !== null &&
                dat.wheelChairName.includes(this.condition.freeWord)); // 車いす名
          }

          // 条件送信結果フィルター作成
          let isFilteringFreeStatus = true;
          if (this.condition.weightScaleStatus > -1) {
            isFilteringFreeStatus =
              dat.weightScaleStatus ===
              this.getWeightScaleStatusList[this.condition.weightScaleStatus]
                .no;
          }
          return (
            isFilteringKur &&
            isFilteringBed &&
            isFilteringFreeWord &&
            isFilteringFreeStatus
          );
        })
        .slice();
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (
        // add FNSI-redmine3969 徐 start
        this.refreshCheck &&
        // add FNSI-redmine3969 徐 end
        this.selfScreenName === this.$router.currentRoute.name &&
        document.getElementsByTagName("ons-alert-dialog").length === 0
      ) {
        // フィルタークリア
        if (this.getFilterSignal === true) {
          this.setFilterSignal(false);
        }
        // 体重計測定記録情報取得
        this.OrderMeasureHistoryListFirst();
        // add FNSI-redmine3969 徐 start
        this.refreshCheck = false;
        setTimeout(() => {
          this.refreshCheck = true;
          this.isRedrawing = false;
        }, 1000);
        // add FNSI-redmine3969 徐 end
        // add FNSI-redmine3971 徐 start
        this.updateCheck = false;
        setTimeout(() => {
          this.updateCheck = true;
        }, 500);
        // add FNSI-redmine3971 徐 end
      }
    },
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // 機能一致
        // add #9558 機能帳票でパラメータが正しく渡されていない limingzhe start
        var patArr = this.measureHistoryList.filter(item => item.patId != null && item.ordNo != null);
        // add #9558 機能帳票でパラメータが正しく渡されていない limingzhe end
        // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
        this.bedCdListString = JSON.parse(sessionStorage.getItem('roomBedGroupNameStatusList')) || '';
        this.kurGroupName = JSON.parse(sessionStorage.getItem('kurGroupNameStatusList')) || '';
        let patGroups = null;
        if(this.getStorSimlpSearchQurey.selectedPatGroupNames) {
          patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames;
        } else {
          patGroups = "すべて";
        }
        // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
        // 印刷パラメータを応答
        const param = {
          // add 画面印刷プレビューと印刷の実現 黄 start
          patId: this.selectedPatId,
          // mod #9558 機能帳票でパラメータが正しく渡されていない limingzhe start
          patIds: patArr.map(({ patId }) => patId),
          ordNos: patArr.map(({ ordNo }) => ordNo),
          // mod #9558 機能帳票でパラメータが正しく渡されていない limingzhe end
          // add 画面印刷プレビューと印刷の実現 黄 end
          // mod #5984 測定履歴 コンテンツを追加する 孟堅 start　
          facilityCd: this.getFacilityCd,
          date:moment((this.firstCondition.endDate)).add(-1, 'd').format("YYYY/MM/DD"),     // 検索条件の測定日　空白ならば今日
          fromDate:moment((this.firstCondition.endDate)).add(-1, 'd').format("YYYY/MM/DD"), // 検索条件の測定日から検索条件の測定日　空白ならば今日から今日
          toDate: moment(this.firstCondition.endDate).add(-1, 'd').format("YYYYMMDD"),
          functionCd:"01401",
          // mod #5984 測定履歴 コンテンツを追加する 孟堅 end　
          // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
          bedCdListString:this.bedCdListString,
          kurNames:this.kurGroupName,
          patGroups:patGroups,
          // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    //#10567:体重測定記録画面の表示不正 Start
    //追加読み込み廃止　async scrollHandle　削除
    //#10567:体重測定記録画面の表示不正 End
    /**
     * 休日のスタイル取得
     */
    getStyle(date) {
      return getHolidayStyle(date, true);
    },
    /**
     * 一覧の全体の幅をpxで返却します.
     */
    getWidthValue() {
      // NOTE: 各項目幅の和 : 137em、各項目の間 (10px * 18) : 180px
      return `width:${137 * this.fontSizeInPx + 180}px;`;
    },
    /**
     * 前画面へ遷移
     */
    cancel() {
      this.$router.go(-1);
    },
    /**
     * 現在時刻を"YYYY/MM/DD(曜) HH:mm"形式で取得し、ymdTimeへセットします。
     */
    updateYmdTime() {
      const weekday = ['日', '月', '火', '水', '木', '金', '土'];
      const now = moment();
      this.ymdTime = `${now.format('YYYY/MM/DD')}(${weekday[now.day()]}) ${now.format('HH:mm')}`;
    },
    /**
     * 体重計モード時に画面表示する年月日時分をリアルタイム更新するインターバルを開始します。
     * (次の分の開始から実行し、その後は60秒間隔で更新する)
     * (分までの表示で秒を表示していない為、負荷を考慮し1分毎インターバルにする）
     */
    startMinuteClock() {
      // 二重起動を防止
      if (this.ymdUpdateProc || this._minuteAlignTimeout) return;

      // 初期表示
      this.updateYmdTime();

      // 次の分の開始までの待機時間（ミリ秒）を計算
      const delay = 60000 - (Date.now() % 60000);

      // 次の分が始まったら更新開始
      this._minuteAlignTimeout = setTimeout(() => {
        this.updateYmdTime();
        // 以降は60秒間隔で年月日時分を更新
        this.ymdUpdateProc = setInterval(this.updateYmdTime, 60000);
        this._minuteAlignTimeout = null;
      }, delay);
    },
  },
  watch: {
    getFilterSignal(value, oldValue) {
      if (value === true && oldValue === false) {
        this.filterFunction();
        this.setFilterSignal(false);
      }
    },
    getFontSize(newVal, oldVal) {
      if (newVal !== oldVal) {
        // テーブルの各列幅をフォントサイズに応じて更新
        this.$nextTick(() => {
          const table = document.getElementById("table");
          if (!table) return;
          const widthMultipliers = [5, 8, 8, 8, 5, 5, 12, 3, 9, 9, 5, 4, 7, 9, 6, 7, 10, 7, 10];
          for (let row of table.rows) {
            for (let i = 0; i < row.cells.length && i < widthMultipliers.length; i++) {
              row.cells[i].style.width = `${this.fontSizeInPx * widthMultipliers[i]}px`;
            }
          }
        });
      }
    }
  },
  created() {
    // 休日マスタの休日を取得
    this.fetchHolidays(this.getFacilityCd);

    this.selfScreenName = this.$router.currentRoute.name;
    // add 性能改善メモリ不足 shan start
    EventBus.$off("filterMeasureHistoryList", this.setFilterCondition);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("filterMeasureHistoryList", this.setFilterCondition);
    EventBus.$on("refresh", this.refresh);

    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // フィルタークリア
    if (this.getFilterSignal === true) {
      this.setFilterSignal(false);
    }

    // add FNSI-バグ 体重測定記録459 徐 start
    setTimeout(() => {
      var tTD;
      var table = document.getElementById("table");
      if (table != null) {
        const fsPx = this.fontSizeInPx;
        for (var j = 0; j < table.rows.length; j++) {
          if (table.rows[j].cells.length > 0) {
            // NOTE: 初期表示幅をフォントサイズに応じてpxで指定します(各数値は、em単位).
            table.rows[j].cells[0].width = `${fsPx * 5}px`; // 測定日時
            // add bug 7185 修正 chen start
            if (table.rows[j].cells[1]) {
              // add bug 7185 修正 chen end
              table.rows[j].cells[1].width = `${fsPx * 8}px`; // 測定状況
              table.rows[j].cells[2].width = `${fsPx * 8}px`; // 患者ID
              table.rows[j].cells[3].width = `${fsPx * 8}px`; // 患者名
              table.rows[j].cells[4].width = `${fsPx * 5}px`; // 測定値(kg)
              table.rows[j].cells[5].width = `${fsPx * 5}px`; // 体重値(kg)
              table.rows[j].cells[6].width = `${fsPx * 12}px`; // メッセージ
              table.rows[j].cells[7].width = `${fsPx * 3}px`; // クール
              table.rows[j].cells[8].width = `${fsPx * 9}px`; // ベッド名
              table.rows[j].cells[9].width = `${fsPx * 9}px`; // 体重計名称
              table.rows[j].cells[10].width = `${fsPx * 5}px`; // 区分
              table.rows[j].cells[11].width = `${fsPx * 4}px`; // 測定種別
              table.rows[j].cells[12].width = `${fsPx * 7}px`; // 風袋合計値(kg)
              table.rows[j].cells[13].width = `${fsPx * 9}px`; // 除水補正合計値(kg)
              table.rows[j].cells[14].width = `${fsPx * 6}px`; // 目標体重(kg)
              table.rows[j].cells[15].width = `${fsPx * 7}px`; // 除水制限値(kg)
              table.rows[j].cells[16].width = `${fsPx * 10}px`; // 車いす名
              table.rows[j].cells[17].width = `${fsPx * 7}px`; // 車いす重量(kg)
              table.rows[j].cells[18].width = `${fsPx * 10}px`; // 実施者
            }
          }
        }
        for (var i = 0; i < table.rows[0].cells.length; i++) {
          table.rows[0].cells[i].onmousedown = function() {
            tTD = this;
            if (event.offsetX > tTD.offsetWidth - 10) {
              tTD.mouseDown = true;
              tTD.oldX = event.x;
              tTD.oldWidth = tTD.scrollWidth;
            }
          };
          table.rows[0].cells[i].onmouseup = function() {
            if (tTD != undefined) {
              tTD.mouseDown = false;
              tTD.style.cursor = 'default';
            }
          };
          table.rows[0].cells[i].onmousemove = function(event) {
            if (event.offsetX > this.offsetWidth - 10) {
              this.style.cursor = 'col-resize';
            } else {
              this.style.cursor = 'default';
            }
            if (tTD == undefined) {
              tTD = this;
            }

            if (tTD.mouseDown != null && tTD.mouseDown == true) {
              tTD.style.cursor = 'default';

              // min-width を取得
              const computedStyle = getComputedStyle(tTD);
              const minWidthPx = parseFloat(computedStyle.minWidth);
              const newWidth = tTD.oldWidth + (event.clientX - tTD.oldX);
              if (newWidth >= minWidthPx) {
                tTD.width = newWidth;
                tTD.style.width = `${newWidth}px`;

                tTD.style.cursor = 'col-resize';
                table = document.getElementById("table");
                while (table.tagName != 'TABLE') {
                  table = table.parentElement;
                }
                for (let j = 0; j < table.rows.length; j++) {
                  if (table.rows[j].cells.length > 1) {
                    table.rows[j].cells[tTD.cellIndex].style.width = `${newWidth}px`;
                  }
                }
              }
            }
          };
        }
      }
    }, 300);
    // add FNSI-バグ 体重測定記録459 徐 end
  },
  mounted() {
    // 体重計測定記録情報取得
    this.OrderMeasureHistoryListFirst();

    if (this.isWeightMode) {
      // 体重計モード時、年月日時分表示用のインターバルを開始
      this.startMinuteClock();
    }
  },
  beforeDestroy() {
    this.clearHolidays(); // storeの休日マスタをクリア
    EventBus.$off("filterMeasureHistoryList", this.setFilterCondition);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());

    // setInterval停止 (体重計モード用インターバル)
    if (this.ymdUpdateProc) {
      clearInterval(this.ymdUpdateProc);
      this.ymdUpdateProc = null;
    }
    // setTimeout停止 (体重計モード用タイムアウト)
    if (this._minuteAlignTimeout) {
      clearTimeout(this._minuteAlignTimeout);
      this._minuteAlignTimeout = null;
    }
  }
};
</script>
<style scoped>
.table-wrapper {
  overflow: auto;
}
table {
  table-layout: fixed;
  /* mod FNSI-バグ 体重測定記録459 徐 start */
  /* width: auto; */
  overflow:scroll;
  /* mod FNSI-バグ 体重測定記録459 徐 end */
}
td {
  word-wrap: break-word;
}
@media print {
  /* スクロールコンテナ */
  #scrollArea {
    overflow: hidden !important;
    position: static;
  }
  table.ntss-list {
    position: relative;
  }
  /* 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  table.scroll-rightmost {
    position: relative !important;
    float: right !important;
  }
}
</style>
