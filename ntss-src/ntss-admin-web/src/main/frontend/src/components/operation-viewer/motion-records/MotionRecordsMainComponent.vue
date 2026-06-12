/**
 * 装置記録 MainContent
 */
<template>
  <div>
    <div id="scrollArea" ref="scrollArea" class='main-content-area' style="-webkit-overflow-scrolling:touch;">
      <table class='ntss-list'>
        <thead>
          <tr>
            <th v-for='column in columns'
                :key='column.key'
                :class="[sortedClass(column.key), column.centerAlign ? 'list-header-th-center' : '']"
                class="ntss-list-header-th-sticky"
                :style="{ width:column.width + '%' }"
                @click='clickHeader(column.key, $event)'>{{ column.colName }}</th>
          </tr>
        </thead>
        <tbody ref="tbody">
          <tr v-for='(motionRecord, motionRecordKey) in convertList(sortedItems)'
              :key='motionRecordKey'
               class="ntss-list-body-tr"
              :class="getDataTypeClass(motionRecord)"
              @click='goNext(motionRecord.headerFlag, motionRecord.maxRecodeFlag, motionRecord)'>
            <td
              v-if="motionRecord.headerFlag"
              colspan="3"
              :class="[
                'ntss-list-body-td-header',
                motionRecord.className,
                'ntss-list-body-td',
                getStyle(motionRecord.eventRegDate)
              ]"
              >{{ formattedEventRegDate(motionRecord.eventRegDate) }}</td>
            <td v-if="!motionRecord.headerFlag && !motionRecord.maxRecodeFlag" class='ntss-list-body-td' style="text-align:right;">{{ motionRecord.eventRegTime }}</td>
            <td v-if="!motionRecord.headerFlag && !motionRecord.maxRecodeFlag" class='ntss-list-body-td'>{{ motionRecord.machineRecordMessage }}</td>
            <td v-if="!motionRecord.headerFlag && !motionRecord.maxRecodeFlag" class='ntss-list-body-td' style="text-align:center;">{{ convertDataType(motionRecord.dataType) }}</td>
            <td
              v-if="motionRecord.maxRecodeFlag"
              colspan="3"
              :class="'ntss-list-body-td-header ntss-list-body-td'">1万件を超えたため表示していないデータがあります。</td>
          </tr>
        </tbody>
      </table>
    </div>
    <v-ons-popover cancelable
                   v-model:visible='popoverVisible'
                   :target='popoverTarget'
                   :direction='popoverDirection'
                   :cover-target="false"
                   :class="fontSizeSet"
                   @preshow="popoverPreShow"
                   @postshow="popoverPostShow"
                   @posthide="popoverPosthide"
                   >
      <div style='margin:5px;'>
        <v-ons-row class='condition-row'>
          <v-ons-col width='30%' vertical-align='center'>
            <label style="font-size:1.6em;">発生日</label>
          </v-ons-col>
          <v-ons-col width='70%' vertical-align='center'>
<!--            mod bug #7299 修正 chen start-->
            <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
<!--            <v-ons-input class="motionRecordPopover" float type='date' min='1880-01-01' max='2099-12-31' v-model='condition.startDate'></v-ons-input>-->
           <date-input :classes="'motionRecordPopover input ntss-input-date start-date'" float v-model='condition.startDate' @handleClearInput="condition.startDate = null"  @keyup="showStartMsg"/>
            <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
            <common-calendar v-model="condition.startDate" class="start-date-comment"/>
            <div class="error-message" v-if="showErrorStartDate">{{
                this.msgDiaLog
              }}</div>
<!--            mod bug #7299 修正 chen end-->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='30%' vertical-align='center'>
            <label style="font-size:1.6em;float:right;">～</label>
          </v-ons-col>
          <v-ons-col width='70%' vertical-align='center'>
            <!--            mod bug #7299 修正 chen start-->
            <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 start -->
<!--            <v-ons-input class="motionRecordPopover" float type='date' min='1880-01-01' max='2099-12-31' v-model='condition.endDate'></v-ons-input>-->
            <date-input :classes="'motionRecordPopover input ntss-input-date end-date'" float v-model='condition.endDate' @handleClearInput="condition.endDate = null"  @keyup="showEndMsg"/>
            <!-- #5590 2023/04/19 ×を常に表示するように修正 張博 end -->
            <common-calendar v-model="condition.endDate" class="start-date-comment"/>
            <div class="error-message" v-if="showErrorEndDate">{{
                this.msgDiaLog
              }}</div>
<!--            mod bug #7299 修正 chen start-->
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='10%' vertical-align='center'>
            <v-ons-checkbox v-model="condition.dataType[0]" input-id="kiroku"></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center'>
            <label for="kiroku" class="popoverFilterLabel" id='kirokutest'>{{ convertDataType(1) }}</label>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center'>
            <v-ons-checkbox v-model="condition.dataType[1]" input-id="kinkyu"></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center'>
            <label for="kinkyu" class="popoverFilterLabel">{{ convertDataType(2) }}</label>
          </v-ons-col>
          <!-- 予防保全対応不完全のため非表示とする -->
          <v-ons-checkbox v-if=false v-model="condition.dataType[2]" input-id="yobou"></v-ons-checkbox>
          <label v-if=false for="yobou" class="popoverFilterLabel">{{ convertDataType(3) }}</label>
          <v-ons-col width='10%' vertical-align='center'>
            <v-ons-checkbox v-model="condition.dataType[3]" input-id="ziko"></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center'>
            <label for="ziko" class="popoverFilterLabel">{{ convertDataType(4) }}</label>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center'>
            <v-ons-checkbox v-model="condition.dataType[4]" input-id="youkai"></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center'>
            <label for="youkai" class="popoverFilterLabel">{{ convertDataType(5) }}</label>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center' v-if="!isGeneralUser">
            <v-ons-checkbox v-model="condition.dataType[5]" input-id="data"></v-ons-checkbox>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center' v-if="!isGeneralUser">
            <label for="data" class="popoverFilterLabel">{{ convertDataType(6) }}</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='30%' vertical-align='center'>
            <label style="font-size:1.6em;">ﾌﾘｰﾜｰﾄﾞ</label>
          </v-ons-col>
          <v-ons-col width='70%' vertical-align='center'>
            <v-ons-input float type='text' v-model='condition.freeWord'></v-ons-input>
          </v-ons-col>
        </v-ons-row>
        <div class='condition-row' style="height:30px;">
          <div style="float:left;">
            <v-ons-button class='btn2-cancel clear' id="button-clear" @click='dialogClear'>初期化</v-ons-button>
          </div>
          <div style="float:right;">
<!--        mod bug #7299 修正 chen start-->
            <v-ons-button class='btn1-execute ok' :disabled="showErrorEndDate || showErrorStartDate" id="button-ok" @click='dialogOk'>OK</v-ons-button>
<!--        mod bug #7299 修正 chen end-->
          </div>
        </div>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import dayjs from "@/compat/date/dayjs";
import { FUNC_DETAIL_MOTION_RECORD_DETAIL, FUNC_DETAIL_MOTION_RECORD_LIST } from "@/constants/function-code";
import commonjs from "@/constants/operationViewerCommon";
import { SERVICE_SUPPORT } from "@/constants/operationViewerCommon";
import PopoverMixin from "@/components/PopoverMixin";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
// add bug #6942 修正 chen start
import {sendRequestFetchMotionRecords, sendRequestFindMotionRecords, sendRequestFindMotionRecordsTotal} from "@/apis/operation-viewer";
// add bug #7299 修正 chen start
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
// add bug #7299 修正 chen end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
//#5590 2023/04/19 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/19 ×を常に表示するように修正 張博 end
import { getHolidayStyle } from "@/functions/common/CommonFunctions";
import { getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
/**
 * 最大表示件数.
 */
const MAX_RECORD = 30000;
// add bug #6942 修正 chen end
export default {
  mixins: [NextTransitionMixin, PopoverMixin],
  // add bug #7299 修正 chen start
  components: {
    "common-calendar": commonCalender,
    //#5590 2023/04/19 ×を常に表示するように修正 張博 start
    "date-input":DateInput,
    //#5590 2023/04/19 ×を常に表示するように修正 張博 end
  },
  // add bug #7299 修正 chen end
  data() {
    return {
      _isRefreshing: false,
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      isUpdating: false,
      // add bug #6942 修正 chen start
      // 装置記録一覧
      motionRecords: [],
      // 最大件数を超えたか
      isOverMaxRecode: false,
      // add bug #6942 修正 chen end
      // add bug #6997 修正 chen start
      // イベント発生日
      eventRegDate: "",
      // add bug #6997 修正 chen end
      // add bug #7299 修正 chen start
      showErrorStartDate: false,
      msgDiaLog: DIALOG_MESSAGES["99999995"].message,
      showErrorEndDate: false,
      // add bug #7299 修正 chen end
      columns: [
        {
          key: "sortKey",
          colName: "発生日時",
          width: 30,
          centerAlign: false
        },
        {
          key: "machineRecordMessage",
          colName: "内容",
          width: 100,
          centerAlign: false
        },
        {
          key: "dataType",
          colName: "類",
          width: 10,
          centerAlign: true
        }
      ],
      // 類表示名
      dataTypeName: {
        1: {
          shortName: "記",
          className: ""
        },
        2: {
          shortName: "警",
          className: "emergency-row"
        },
        3: {
          shortName: "予",
          className: "preventive-row"
        },
        4: {
          shortName: "自",
          className: ""
        },
        5: {
          shortName: "溶",
          className: ""
        },
        6: {
          shortName: "デ",
          className: ""
        }
      },
      // 検索条件
      condition: {
        startDate: "",
        endDate: "",
        dataType: [false, false, false, false, false, false],
        freeWord: ""
      },
      // ソート条件
      sort: {
        key: "",
        isAsc: true
      },
      selfScreenPath: "",
      offset: 0,
      total: null,
      isFilter: false,
      scrollTop: 0,
    };
  },
  computed: {
      // mod bug #6942 修正 chen start
    ...mapGetters("operation-viewer/motion-record", [
      // "getMotionRecords",
      "getHeaderInfo",
      "getMachineTypeCd",
      // "getEventRegDate",
      // "isOverMaxRecode"
      // mod bug #6942 修正 chen end
    ]),
    ...mapGetters("user", ["isGeneralUser"]),

    /**
     * ソートを行う.
     */
    sortedItems() {
      // mod bug #6942 修正 chen start
      const list = this.motionRecords.slice();
      // mod bug #6942 修正 chen end
      if (this.sort.key) {
        list.sort((a, b) => commonjs.compareKey(a, b, this.sort.key, this.sort.isAsc));
      }
      return list;
    }
  },
  methods: {
    ...mapGetters("user", ["getUserType", "getAdministrator"]),
    ...mapGetters("account-edit", [
      "getStateUserAccountInfo",
      "isNkkFacility"
    ]),
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapGetters("operation-viewer/machine", ["getSelectMachine"]),
    ...mapActions("operation-viewer/machine", ["getMachine"]),
      // mod bug #6942 修正 chen start
    ...mapActions("operation-viewer/motion-record", [
      // "fetchMotionRecords",
      // "setEventRegDate",
      // "findMotionRecords",
      // mod bug #6942 修正 chen end
      "setHeaderInfo"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("operation-viewer/motion-record-detail", ["setMotionRecord"]),
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    /**
     * 選択された装置記録情報の詳細画面に遷移する.
     *
     * @param {Boolean} headerFlag ヘッダー行フラグ
     * @param {Boolean} maxRecodeFlag 最大レコード行フラグ
     * @param {*} motionRecord 装置記録情報
     */
    goNext(headerFlag, maxRecodeFlag, motionRecord) {
      // ヘッダー行や最大レコードメッセージを表示している行の場合
      if (headerFlag || maxRecodeFlag) {
        return;
      }
      // 選択された装置設定をstoreに設定
      this.setMotionRecord(motionRecord);
      // Mixinで定義したメソッドで次画面へ遷移
      this.goNextView();
    },
    /**
     * stateに登録されたレコードを画面に表示用に変換する.
     *
     * @param {Array} MotionRecords 装置記録情報のリスト
     */
    convertList(MotionRecords) {
      const rtnList = [];
      let rtnEventRegDate = "";

      for (let i = 0; i < MotionRecords.length; i++) {
        let rtnEventRegTime = "";
        let rtnMachineRecordMessage = "";
        let rtnDataType = "";
        let rtnTestType = "";
        let rtnHeaderFlag = true;
        let rtnMotionRecordNo = "";
        let rtnIsCorrection = "";
        let rtnUserId = "";
        let rtnIsCorrectionUpDate = null;
        let rtnServiceSupportType = "";
        let rtnServiceSupportUserId = null;
        let rtnServiceSupportUpDate = null;

        if (rtnEventRegDate === MotionRecords[i].eventRegDate) {
          rtnEventRegTime = MotionRecords[i].eventRegTime;
          rtnMachineRecordMessage = MotionRecords[i].machineRecordMessage;
          rtnDataType = MotionRecords[i].dataType;
          rtnTestType = MotionRecords[i].testType;
          rtnHeaderFlag = false;
          rtnMotionRecordNo = MotionRecords[i].motionRecordNo;
          rtnIsCorrection = MotionRecords[i].isCorrection;
          rtnUserId = MotionRecords[i].userId;
          rtnIsCorrectionUpDate = MotionRecords[i].isCorrectionUpDate;
          rtnServiceSupportType = MotionRecords[i].serviceSupportType;
          rtnServiceSupportUserId = MotionRecords[i].serviceSupportUserId;
          rtnServiceSupportUpDate = MotionRecords[i].serviceSupportUpDate;
        } else {
          rtnEventRegDate = MotionRecords[i].eventRegDate;
          i--;
        }
        rtnList.push({
          eventRegDate: rtnEventRegDate,
          eventRegTime: rtnEventRegTime,
          machineRecordMessage: rtnMachineRecordMessage,
          dataType: rtnDataType,
          testType: rtnTestType,
          headerFlag: rtnHeaderFlag,
          motionRecordNo: rtnMotionRecordNo,
          isCorrection: rtnIsCorrection,
          userId: rtnUserId,
          maxRecodeFlag: false,
          isCorrectionUpDate: rtnIsCorrectionUpDate,
          serviceSupportType: rtnServiceSupportType,
          serviceSupportUserId: rtnServiceSupportUserId,
          serviceSupportUpDate: rtnServiceSupportUpDate
        });
        // 最後に追加したデータを取り出す.
        const last = rtnList[rtnList.length - 1];
        if (!rtnHeaderFlag && !this.isCorrection(last)) {
          rtnList.reverse().some(r => {
            if (!r.headerFlag) {
              return;
            }
            if (r.className !== "emergency-row") {
              r.className = this.getDataTypeClass(last);
            }
            return true;
          });
          rtnList.reverse();
        }
      }
      // 表示しきれない行があることを通知する行を追加
      if (this.isOverMaxRecode) {
        const dummyRecord = this.createDummyRecord();
        this.sort.isAsc && this.sort.key !== "" ? rtnList.unshift(dummyRecord) : rtnList.push(dummyRecord);
      }
      return rtnList;
    },
    /**
     * 一覧表示する際のダミー行を作成する.
     * ※この関数の想定では、表示しきれない行がある事を通知する行の作成
     *
     * @returns {*} ダミー行を表す情報
     */
    createDummyRecord() {
      return {
            eventRegDate: "",
            eventRegTime: "",
            machineRecordMessage: "",
            dataType: "",
            testType: "",
            headerFlag: false,
            motionRecordNo: "",
            isCorrection: "",
            userId: "",
            maxRecodeFlag: true,
            isCorrectionUpDate: null,
            serviceSupportType: "",
            serviceSupportUserId: null,
            serviceSupportUpDate: null
          };
    },
    // dataTypeをコードから文字列に成形
    convertDataType(dataType) {
      return this.dataTypeName[dataType].shortName;
    },
    /**
     * 与えられたmotionRecordに格納されているdataTypeが未対応時の付与するクラス名を取得する.
     *
     * サインイン者が日機装施設に属する場合、dataTypeが 「3:予防保守」 の場合、
     * 「2:警報通知」に登録されているクラス名を返却する.
     *
     * @param {*} motionRecord 装置動作記録
     * @return クラス名
     */
    getDataTypeClass(motionRecord) {
      if (this.isCorrection(motionRecord)) {
        return "";
      }
      return this.isNkkFacility()
              ? this.dataTypeName[2].className
              : this.dataTypeName[motionRecord.dataType].className;
    },
    /**
     * 対処が必要な「類」の項目に対して、対処済か否かを判定する.
     * サインイン者が日機装施設に属している場合には、サービス対応区分で判定する.
     *
     * @param {*} 1装置動作記録
     * @returns 戻り値：true（対処済）、false：未対処
     *          ※対処が不要な「類」の場合はtrueを返却する.
     */
    isCorrection(motionRecord) {
      // データ区分が未登録の場合
      if (!motionRecord.dataType) {
        return true;
      }
      // サインイン者が日機装施設に属する場合
      if (this.isNkkFacility()) {
        if ((motionRecord.dataType === 2 || motionRecord.dataType === 3) &&
            motionRecord.serviceSupportType !== SERVICE_SUPPORT.SERVICE_SUPPORTED.cd &&
            motionRecord.serviceSupportType !== SERVICE_SUPPORT.OUT_OF_SERVICE.cd) {
          return false;
        }
        return true;
      }
      // dataTypeが設定されていて且つ未対処(isCorrectionが'1'以外)
      if (motionRecord.isCorrection !== "1") {
        // dataTypeNameのclassNameを取得
        const className = this.dataTypeName[motionRecord.dataType].className;
        // classNameが空でなければ未対処
        if (className) {
          return false;
        }
        return true;
      }
      return true;
    },
    // 現在日～現在日より7日前までの情報を取得してstateに登録
    fetchMotionRecordsFirst() {
      this.offset = 0;
      this.scrollToTop();
      this.fetch(true)
    },
    fetch(isNeedCountTotal = false) {
      // 条件をフィルタに設定
      let nowDate = new Date();
      this.condition.endDate = dayjs(nowDate).format("YYYY-MM-DD");
      this.condition.startDate = dayjs(
        nowDate.setDate(nowDate.getDate() - 7)
      ).format("YYYY-MM-DD");
      const info = [];
      info.push({
        facilityCd: this.getHeaderInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: this.getHeaderInfo.machineSerial,
        userTypeCd: this.getStateUserAccountInfo().userType,
        administrator: this.getStateUserAccountInfo().administrator,
        startDate: (this.condition.startDate  ?? "").replace(/-/g, ""),
        endDate: (this.condition.endDate ?? "").replace(/-/g, ""),
      });
      this.setLoadingScreenVisible(true);
      this.fetchMotionRecords(info, isNeedCountTotal)
        .then(() => {
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MotionRecordsMainComponent.vue', 'fetchMotionRecordsFirst', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
    },
    updateMotionRecords() {
      const info = [];
      info.push({
        facilityCd: this.getHeaderInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: this.getHeaderInfo.machineSerial,
        userTypeCd: this.getStateUserAccountInfo().userType,
        administrator: this.getStateUserAccountInfo().administrator,
        // mod bug #6997 修正 chen start
        // baseDate: this.dateFormat(this.getEventRegDate),
        baseDate: this.dateFormat(this.eventRegDate),
        // mod bug #6997 修正 chen end
      });
      this.setLoadingScreenVisible(true);
      this.fetchMotionRecords(info)
        .then(() => {
          this.isUpdating = false;
          this.setLoadingScreenVisible(false);
        })
        .catch(error => {
          this.setLoadingScreenVisible(false);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MotionRecordsMainComponent.vue', 'updateMotionRecords', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
    },
    // ヘッダークリック時の処理
    clickHeader(key, event) {
      if (key !== this.columns[0].key) {
        this.showPopover(event);
      } else {
        this.sortBy(key);
      }
    },
    // 昇順/降順のclassを作成
    sortedClass(key) {
      return this.sort.key === key
        ? `sorted-${this.sort.isAsc ? "desc" : "asc"}`
        : "";
    },
    // ソートするキーを設定する
    sortBy(key) {
      if (key === this.sort.key && !this.sort.isAsc) {
        // ソートをクリア
        this.sort.key = "";
        this.sort.isAsc = true;
        return;
      }
      this.sort.isAsc = this.sort.key === key ? !this.sort.isAsc : true;
      this.sort.key = key;
    },
    // ポップアップメニューを表示
    showPopover(event) {
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // 検索ダイアログの初期化
    dialogClear() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // 初期化
      this.condition.startDate = "";
      this.condition.endDate = "";
      for (let i = 0; i < this.condition.dataType.length; i++) {
        this.condition.dataType[i] = false;
      }
      this.condition.freeWord = "";
      // 画面閉じる
      this.popoverVisible = false;
      // 検索処理の実行
      this.fetchMotionRecordsFirst();
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);

    },
    dialogOk() {
      this.popoverVisible = false;
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      this.offset = 0;
      this.scrollToTop();
      this.search(true);
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },
    // 検索条件に一致するレコードを取得してstateに登録
    search(isNeedCountTotal = false) {
      const filterDataType = [];
      for (let idx1 = 0; idx1 < this.condition.dataType.length; idx1++) {
        if (this.condition.dataType[idx1]) {
          filterDataType.push(idx1 + 1);
        }
      }
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      const info = [];
      info.push({
        facilityCd: this.getHeaderInfo.facilityCd,
        machineTypeCd: this.getMachineTypeCd,
        machineSerial: this.getHeaderInfo.machineSerial,
        userTypeCd: this.getUserType(),
        administrator: this.getAdministrator(),
        startDate: (this.condition.startDate ?? "").replace(/-/g, ""),
        endDate: (this.condition.endDate ?? "").replace(/-/g, ""),
        dataType: filterDataType,
        freeWord: this.condition.freeWord,
      });
      // 入力日付のチェック
      this.checkDateRange(info);
      this.findMotionRecords(info, isNeedCountTotal)
        .then(() => {
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MotionRecordsMainComponent.vue', 'search', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          // 共通ローダー:表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            // TODO 必要に応じて、適切な業務エラー処理を実装すること。
          }
        });
    },
    // 受け取った日付データをyyyyMMdd形式で返す
    dateFormat(date) {
      const year = date.getFullYear();
      const month = `${"00"}${date.getMonth() + 1}`.slice(-2);
      const day = `${"00"}${date.getDate()}`.slice(-2);
      return `${year.toString()}${month.toString()}${day.toString()}`;
    },
    // 入力日付のチェック
    checkDateRange(info){
      // 未入力チェック (パラメータの為、必ず何か値を入れるようにする)
      if (info[0].startDate === "") {
        info[0].startDate = "00000000";
      }
      if (info[0].endDate === "") {
        info[0].endDate = new Date(9999, 11, 31);
        info[0].endDate = this.dateFormat(info[0].endDate);
      }
      if (info[0].startDate !== "00000000" && info[0].endDate !== "99991231") {
        // 反転チェック
        const startDate = new Date(info[0].startDate.substring (0, 4) + "-" + info[0].startDate.substring(4, 6) + "-" + info[0].startDate.substring(6, 8));
        const endDate = new Date(info[0].endDate.substring (0, 4) + "-" + info[0].endDate.substring(4, 6) + "-" + info[0].endDate.substring(6, 8));
        if (startDate > endDate) {
          const tmpDate = info[0].startDate;
          info[0].startDate = info[0].endDate;
          info[0].endDate = tmpDate;
        }
      }
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    async refresh(isMainContent, autoRefreshFlag) {
      if (this._isRefreshing) {
        return;
      }
      this._isRefreshing = true;
      try {
        if (isMainContent === undefined) {
          const paths = this.$route.matched.map(item => item.path);
          if (!paths?.includes(this.selfScreenPath)) {
            return;
          }
        }
        // 共通ローダー:表示開始
        this.setLoadingScreenVisible(true);
        this.offset = 0;
        const filterDataType = [];
        for (let idx1 = 0; idx1 < this.condition.dataType.length; idx1++) {
          if (this.condition.dataType[idx1]) {
            filterDataType.push(idx1 + 1);
          }
        }
        const scrollAreaRef = this.$refs.scrollArea;
        if (scrollAreaRef) {
          // 現在のスクロール位置を保持
          this.scrollTop = scrollAreaRef.scrollTop;
        }
        const info = [];
        info.push({
          facilityCd: this.getHeaderInfo.facilityCd,
          machineTypeCd: this.getMachineTypeCd,
          machineSerial: this.getHeaderInfo.machineSerial,
          userTypeCd: this.getStateUserAccountInfo().userType,
          administrator: this.getStateUserAccountInfo().administrator,
          startDate: (this.condition.startDate ?? "").replace(/-/g, ""),
          endDate: (this.condition.endDate ?? "").replace(/-/g, ""),
          dataType: filterDataType,
          freeWord: this.condition.freeWord,
        });
        // 入力日付のチェック
        this.checkDateRange(info);
        
        await this.findMotionRecords(info, false, autoRefreshFlag);
        
        if (scrollAreaRef) {
          scrollAreaRef.scrollTop = this.scrollTop;
        }
        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);
        
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('MotionRecordsMainComponent.vue', 'refresh', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        // 共通ローダー:表示終了
        this.setLoadingScreenVisible(false);
        if (error.response?.status === 400) {
          // TODO 必要に応じて、適切な業務エラー処理を実装すること。
        }
      } finally {
        this._isRefreshing = false;
      }
    },
    // add bug #6997 修正 chen start
    setEventRegDate(baseDate) {
      baseDate = baseDate.replace(/\//g, "");
      const eventRegDateTmp = new Date(
        baseDate.slice(0, 4),
        baseDate.slice(4, 6) - 1,
        baseDate.slice(6)
      );
      eventRegDateTmp.setDate(eventRegDateTmp.getDate() - 1);
      this.eventRegDate = eventRegDateTmp;
    },
    // add bug #6997 修正 chen end
    // add bug #6942 修正 chen start
    // 装置記録一覧クリア
    clearMotionRecords() {
      this.motionRecords = [];
    },
    // フィルタリング時
    async findMotionRecords(info, isNeedCountTotal = false, autoRefreshFlag) {
      const params = info[0];
      this.isFilter = true;
      if (isNeedCountTotal) {
        const totalResponse = await sendRequestFindMotionRecordsTotal(params);
        this.total = totalResponse.data;
      }
      if (this.offset === 0) {
        this.clearMotionRecords();
      }
      if (this.total === 0) {
        return;
      }
      const motionRecordsResponse = await sendRequestFindMotionRecords({ ...params, ...{ offset: this.offset }, autoRefreshFlag});
      const motionRecords = motionRecordsResponse.data.motionRecords;
      // 日付でソートする用のカラムを追加
      for (const record of motionRecords) {
        record.sortKey = `${record.eventRegDate}_${record.eventRegTime}`;
      }
      motionRecordsResponse.data.motionRecords = motionRecords;
      this.motionRecords = this.motionRecords.concat(motionRecordsResponse.data.motionRecords);
      this.offset = this.motionRecords.length;
      return motionRecordsResponse;
    },
    // 初期表示時
    async fetchMotionRecords(info, isNeedCountTotal = false) {
      const params = info[0];
      this.isFilter = false;
      this.setLoadingScreenVisible(true);
      try {
          if (isNeedCountTotal) {
            const totalResponse = await sendRequestFindMotionRecordsTotal(params);
            this.total = totalResponse.data;
          }
          if (this.offset === 0) {
            this.clearMotionRecords();
          }
          if (this.total === 0) {
            return;
          }
          const motionRecordsResponse = await sendRequestFetchMotionRecords({ ...params, ...{ offset: this.offset }});
          const motionRecords = motionRecordsResponse.data.motionRecords;

          // 日付でソートする用のカラムを追加
          for (const record of motionRecords) {
            record.sortKey = `${record.eventRegDate}_${record.eventRegTime}`;
          }
          motionRecordsResponse.data.motionRecords = motionRecords;
          if (motionRecords.length > 0) {
            this.setEventRegDate(motionRecords.slice(-1)[0].eventRegDate);
          }
          this.motionRecords = this.motionRecords.concat(motionRecordsResponse.data.motionRecords);
          this.offset = this.motionRecords.length;
          this.setLoadingScreenVisible(false);
          return motionRecordsResponse;
      } catch(error) {
        this.setLoadingScreenVisible(false);
        throw error;
      }
    },
    // add bug #6942 修正 chen end
    // add bug #7299 修正 chen start
     showStartMsg(){
      const startDateInput = getScopedElementsByClassName("start-date", this.$el || this)[0];
      this.showErrorStartDate = this.condition.startDate ? startDateInput?.validationMessage !== "" : false;
    },
    showEndMsg(){
      const endDateInput = getScopedElementsByClassName("end-date", this.$el || this)[0];
      this.showErrorEndDate = this.condition.endDate ? endDateInput?.validationMessage !== "" : false;
    },
    scroll() {
      if (this.motionRecords.length >= this.total) {
        return;
      }
      const tbodyRef = this.$refs.tbody;
      const scrollAreaRef = this.$refs.scrollArea;
      if (tbodyRef && scrollAreaRef) {
        const lastRow = tbodyRef.lastElementChild || tbodyRef.lastChild;
        if (lastRow && typeof lastRow.getBoundingClientRect === "function") {
          const scrollAreaRect = scrollAreaRef.getBoundingClientRect();
          const lastRowRect = lastRow.getBoundingClientRect();
          if (lastRowRect.top >= scrollAreaRect.top &&
          lastRowRect.bottom <= scrollAreaRect.bottom) {
            if (this.motionRecords.length >= MAX_RECORD) {
              this.$ons.notification.alert({
                title: DIALOG_MESSAGES[12000170].title,
                messageHTML:  messageFormat(DIALOG_MESSAGES[12000170].message)
               });
               return;
            }
            if (this.isFilter) {
              this.search();
            } else {
              this.fetch();
            }
            return;
          }
        }
      }
    },
    scrollToTop() {
      const scrollAreaRef = this.$refs.scrollArea;
      if (scrollAreaRef) {
        scrollAreaRef.scrollTop = 0;
      }
    },
    formattedEventRegDate(regDate){
      const date = dayjs(regDate, "YYYY/MM/DD");
      return date.format("YYYY/MM/DD(dd)");   
    },
    /**
     * 休日のスタイル取得
     */
    getStyle(date) {
      return getHolidayStyle(date, true);
    }
  },
  // add bug #7299 修正 chen end
  async created() {
    // 画面名称取得
    this.selfScreenPath = this.$route.path;
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 共通ローダー:表示開始
    this.setLoadingScreenVisible(true);
    // add 性能改善メモリ不足 shan start
    EventBus.$off("refresh", this.refresh);
    // add 性能改善メモリ不足 shan end
    EventBus.$on("refresh", this.refresh);

    const queryParameters = this.getQueryParameters();
    if (this.getHeaderInfo.facilityCd === "" &&
        (queryParameters.FUNC === FUNC_DETAIL_MOTION_RECORD_LIST ||
         queryParameters.FUNC === FUNC_DETAIL_MOTION_RECORD_DETAIL)) {
      // URLダイレクトで装置記録画面に遷移した場合、ヘッダ情報を取得する
      const condition = {
        facilityCd: queryParameters.FACILITYCD,
        machineTypeCd: queryParameters.MACHINETYPECD,
        machineSerial: queryParameters.MACHINESERIAL
      }
      await this.getMachine(condition);
      await this.setHeaderInfo(this.getSelectMachine());
    }
    
    // 休日マスタの休日を取得
    await this.fetchHolidays(this.getHeaderInfo.facilityCd);

    this.fetchMotionRecordsFirst();
    // 共通ローダー:表示終了
    this.setLoadingScreenVisible(false);
    this.resetLoadingScreenVisibleCount();
    
  },
  mounted() {
    (this.$el?.ownerDocument?.defaultView || window).addEventListener("scroll", this.scroll,true);
  },
  beforeUnmount() {
    this.clearHolidays(); // storeの休日マスタをクリア
    (this.$el?.ownerDocument?.defaultView || window).removeEventListener("scroll", this.scroll,true);
    EventBus.$off("refresh", this.refresh);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.popoverFilterLabel {
  margin-left: -5px;
  margin-right: 7px;
  font-size: 1.6em;
}
.list-header-th-center {
  text-align: center;
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
