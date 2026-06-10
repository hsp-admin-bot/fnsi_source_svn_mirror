/**
 * 検査依頼一覧（一日）ページ用ヘッダ
 */
<template>
  <v-card>
    <!-- 共通検索エリア -->
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
    <!-- ポップアップ -->
    <v-ons-popover
      cancelable
      :visible.sync='popoverVisible'
      :target='popoverTarget'
      :direction='popoverDirection'
      :cover-target=false
      :class="fontSizeSet"
    >
      <div style='margin:10px;'>
        <v-ons-row class='condition-row'>
          <v-ons-col width='40%' vertical-align='center'>
            <label>検査予定日</label>
          </v-ons-col>
          <v-ons-col width='60%' vertical-align='center'>
            <date-input
              v-model="condition.inProgress.scheduledDate"
              :classes="'input-area ntss-input-date ntss-custom-input start-date'"
              style="width:75%"
              isRequired
              />
            <common-calendar v-model="condition.inProgress.scheduledDate" class="calender start-date-comment"/>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='100%' vertical-align='center'>
            <label>検査区分</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='10%' vertical-align='center'></v-ons-col>
          <v-ons-col width='10%' vertical-align='center'>
            <v-ons-checkbox
              input-id="orderClassBeforeDialysis"
              float
              value="1"
              v-model="condition.inProgress.examType"
            />
          </v-ons-col>
          <v-ons-col width='20%' vertical-align='center'>
            <label for="orderClassBeforeDialysis">透析前</label>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center'>
            <v-ons-checkbox
              input-id="orderClassAfterDialysis"
              float
              value="2"
              v-model="condition.inProgress.examType"
            />
          </v-ons-col>
          <v-ons-col width='20%' vertical-align='center'>
            <label for="orderClassAfterDialysis">透析後</label>
          </v-ons-col>
          <v-ons-col width='10%' vertical-align='center'>
            <v-ons-checkbox
              input-id="orderClassOther"
              float
              value="0"
              v-model="condition.inProgress.examType"
            />
          </v-ons-col>
          <v-ons-col width='20%' vertical-align='center'>
            <label for="orderClassOther">その他</label>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='70%' vertical-align='center'>
            <label>予定あり患者のみ表示</label>
          </v-ons-col>
          <v-ons-col width='30%' vertical-align='center'>
            <v-ons-switch input-id="switchPatId" v-model="condition.inProgress.showScheduledOnly"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <div style="height:30px;margin-bottom:5px;" class="condition-row condition-button-area">
          <div style="float:left;" class="clear-button">
            <v-ons-button class="btn2-cancel common-style-cancel-button" @click="dialogClear">クリア</v-ons-button>
          </div>
          <div style="float:right;" class="ok-button">
            <v-ons-button class="btn3-normal common-style-ok-button" @click="dialogOk">OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<script>
import _ from 'lodash';
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import commonSearchArea from "@/components/common/CommonSearchArea";
import DateInput from "@/components/common/DateInput.vue";
import PopoverMixin from "@/components/PopoverMixin";
import { RegOrderClassTextSet } from "@/constants/examRequestConstants";
import { EXAM_REQUEST } from "@/constants/defaultSettingConstants";
import { calcTargetDate } from "@/functions/modals/default-setting/defaultSettingUtils";
import { toCalDate, toSlashDate, toKeyDate } from "@/functions/exam-request/ExamRequestFunctions";
// add #12500 「検査依頼一覧(一日)」画面の機能帳票対応 高 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
import store from "@/stores";
// add #12500 「検査依頼一覧(一日)」画面の機能帳票対応 高 end

export default {
  mixins: [PopoverMixin],
  components: {
    "common-searcharea": commonSearchArea,
    "common-calendar": commonCalender,
    "date-input":DateInput,
  },
  data() {
    /* デフォルト設定 */
    const initCondition = {
      scheduledDate: "",
      examType: [
        RegOrderClassTextSet[0].value,
        RegOrderClassTextSet[1].value,
        RegOrderClassTextSet[2].value,
      ],
      showScheduledOnly: true,
    };
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      conditionList: [],   // 共通検索エリア部品に表示するデータのリスト
      condition: {
        // 入力中の検索条件
        inProgress: {
          ...initCondition
        },
        // 実際に検索に使用される条件
        inUsed: {
          ...initCondition
        }
      },
    };
  },
  /****************************************************************************/
  // computed
  /****************************************************************************/
  computed: {
    ...mapGetters("account-edit", ["getDefaultSetting"]),
    ...mapGetters("exam-request/list", ["getStartToEndDate"]),
    ...mapGetters("exam-request/daily", ["getCondition", "getDefaultCondition"]),
    // add #12500 「検査依頼一覧(一日)」画面の機能帳票対応 高 start
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #12500 「検査依頼一覧(一日)」画面の機能帳票対応 高 end
  },
  /****************************************************************************/
  // watch
  /****************************************************************************/
  watch: {
    /** 検査予定日（表示期間・開始日）の更新 */
    getStartToEndDate: {
      handler(newVal, oldVal) {
        if (newVal.showStartDate !== oldVal.showStartDate) {
          this.condition.inUsed.scheduledDate = toKeyDate(newVal.showStartDate);
          this.condition.inProgress.scheduledDate = toCalDate(newVal.showStartDate);
          this.setConditionList();
        }
      },
      deep: true
    },
  },
  /****************************************************************************/
  // methods
  /****************************************************************************/
  methods: {
    ...mapActions("exam-request/list", ["updateStartToEndDate"]),
    ...mapActions("exam-request/daily", ["setCondition", "setDefaultCondition"]),
    /** 前回条件を適用し、検査予定日を初期化 */
    applyPreviousCondition(initDate) {
      this.condition.inUsed = this.getCondition;
      this.condition.inUsed.scheduledDate = initDate;
    },
    /** 個人設定（デフォルト条件）を読み込み、初期化 */
    applyDefaultSetting(initDate) {
      const defaultExamRequest = this.getDefaultSetting[EXAM_REQUEST.KEY_NAME];

      if (defaultExamRequest) {
        const {
          [EXAM_REQUEST.KEY_NAME_SCHEDULED_DATE]: defaultScheduledDate,
          [EXAM_REQUEST.KEY_NAME_EXAM_TYPE_LIST]: defaultExamTypeList,
          [EXAM_REQUEST.KEY_NAME_SHOW_SCHEDULED_ONLY]: defaultShowScheduledOnly
        } = defaultExamRequest;
        // 検査予定日
        this.condition.inUsed.scheduledDate = toKeyDate(this.getStartToEndDate.showStartDate || calcTargetDate(defaultScheduledDate));
        // 検査区分リスト
        if (defaultExamTypeList != null) {
          this.condition.inUsed.examType = defaultExamTypeList;
        }
        // 予定あり患者のみ表示
        if (defaultShowScheduledOnly != null) {
          this.condition.inUsed.showScheduledOnly = defaultShowScheduledOnly;
        }
      } else {
        // デフォルト設定が存在しない場合、表示期間・開始日 or 本日を設定
        this.condition.inUsed.scheduledDate = initDate;
      }
    },
    /** 共通検索エリア部品に表示するデータのリストを作成 */
    setConditionList() {
      const { scheduledDate, examType, showScheduledOnly } = this.condition.inUsed;
      const formatDate = d => d ? toSlashDate(d) : "";
      const examTypeText = RegOrderClassTextSet.filter(e => examType.includes(e.value)).map(e => e.text).join("、");
      this.conditionList = [
        { name: "検査予定日", text: formatDate(scheduledDate) },
        examTypeText != "" && { name: "検査区分", text: examTypeText },
        showScheduledOnly && { text: "予定あり患者のみ表示" }
      ].filter(Boolean);
    },
    /** 抽出UI表示イベント */
    showPopover(event) {
      this.condition.inProgress = _.cloneDeep(this.condition.inUsed);
      this.condition.inProgress.scheduledDate = toCalDate(this.condition.inUsed.scheduledDate);
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    /** 抽出条件クリアボタンクリックイベント */
    dialogClear() {
      // 検索条件クリア
      this.condition.inProgress = _.cloneDeep(this.getDefaultCondition);
      this.dialogOk();
    },
    /** 抽出条件OKボタンクリックイベント */
    dialogOk() {
      this.popoverVisible = false;
      this.search();
    },
    /** 処理：抽出条件を元にした検索イベント */
    search() {
      // 編集中の条件を使用中に反映
      this.condition.inUsed.scheduledDate = toKeyDate(this.condition.inProgress.scheduledDate);
      this.condition.inUsed.examType = this.condition.inProgress.examType;
      this.condition.inUsed.showScheduledOnly = this.condition.inProgress.showScheduledOnly;
      // 検索条件の内容で画面を更新
      this.setCondition(_.cloneDeep(this.condition.inUsed));
      // 表示期間・開始日を更新
      this.updateStartToEndDate({
        showStartDate: this.condition.inUsed.scheduledDate, // NOTE: Storeへの設定は[YYYYMMDD]形式
        showEndDate: this.getStartToEndDate.showEndDate, // NOTE: 変更していないが部品側に合わせて設定する
      });
      this.setConditionList();
    },
    // add #12500 「検査依頼一覧(一日)」画面の機能帳票対応 高 start
    // 検査依頼（一覧／一日）機能帳票にて、画面タイトルの検索欄から検査区分を取得する
    getExamSelectNameNew() {
      var examDialysis = "";
      const examType = this.condition?.inUsed?.examType ?? [];

      const hasAll = ["1", "2", "0"].every(v => examType.includes(v));
      const hasBefore = examType.includes("1");
      const hasAfter  = examType.includes("2");
      const hasOther  = examType.includes("0");
      if (hasAll) {
        examDialysis = "すべて";
      } else {
        if (hasBefore) {
          examDialysis += "透析前" + "・"
        }
        if (hasAfter) {
          examDialysis += "透析後" + "・"
        }
        if (hasOther) {
          examDialysis += "その他" + "・"
        }
        examDialysis = examDialysis.slice(0,-1);
      }
      return examDialysis;
    },
    // 検査依頼(一覧／一日) 機能帳票
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) !== getCurrentFunctionCd().substring(0, 3)) return;

      // 透析状態（予定 / 実績）
      let expressCondCd = "";
      const dialysisState = this.getStorSimlpSearchQurey?.rstDialysisState ?? [];

      if (dialysisState.length > 0) {
        if (dialysisState.length === 2) {
          expressCondCd = "予定・実績";
        } else {
          expressCondCd = dialysisState[0] === 1 ? "予定" : "実績";
        }
      }

      // クール名
      const kurNames =
        this.getStorSimlpSearchQurey?.kurNames?.length > 0
          ? this.getStorSimlpSearchQurey.kurNames.join("・")
          : "すべて";

      // 患者グループ
      const patGroups =
        this.getStorSimlpSearchQurey?.selectedPatGroupNames
        ?? "すべて";

      const fromDate = this.getCondition.scheduledDate;
      const toDate = this.getCondition.scheduledDate;
      const reportParams = {
        // 機能コード
        functionCd: "02101",
        // 施設コード
        facilityCd: this.getFacilityCd,
        // 患者ID(複）
        patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
        // 対象日
        date: fromDate,
        // 対象期間開始日
        fromDate,
        // 対象期間終了日
        toDate,

        // 検査区分
        inspectionKbn:this.getExamSelectNameNew(),
        // 透析日
        treatDate:this.getStorSimlpSearchQurey.treatDate,
        // ベッド
        bedCdListString:this.getStorSimlpSearchQurey.selectedBedGName,
        // フリーワード
        freeWord:this.getStorSimlpSearchQurey.freeWord,
        // 治療状態
        expressCondCdStr:expressCondCd,
        // クール
        kurNames:kurNames,
        // 患者グループ
        patGroups:patGroups
      };
      EventBus.$emit("sendReportParams", reportParams);
    },
    // add #12500 「検査依頼一覧(一日)」画面の機能帳票対応 高 end
  },
  /****************************************************************************/
  // Lifecycle Hooks
  /****************************************************************************/
  async created() {
    const initDate = toKeyDate(this.getStartToEndDate.showStartDate);
    // add #12500 「検査依頼一覧(一日)」画面の機能帳票対応 高 start
    // 検査依頼(一覧／一日) {"disp_status":"2","report_class":"1,2,8,9,10"}
    store.dispatch("report/getMstReport", {funcCd: "02101",printFlag: 2});
    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add #12500 「検査依頼一覧(一日)」画面の機能帳票対応 高 end
    // 検索条件の初期表示設定
    this.getCondition ? this.applyPreviousCondition(initDate) : this.applyDefaultSetting(initDate);
    // 初期検索条件を設定
    if (!this.getDefaultCondition) {
      this.setDefaultCondition(_.cloneDeep(this.condition.inUsed));
    }
    this.setConditionList();
  },
  // add #12500 「検査依頼一覧(一日)」画面の機能帳票対応 高 start
  beforeDestroy() {
    EventBus.$off("requestReportParams", this.requestrReportParams);
  },
  // add #12500 「検査依頼一覧(一日)」画面の機能帳票対応 高 end
  mounted() {
    // 抽出条件登録
    this.setCondition(_.cloneDeep(this.condition.inUsed));
    EventBus.$emit("addLeftmostHeaderMargin");
  }
};
</script>
