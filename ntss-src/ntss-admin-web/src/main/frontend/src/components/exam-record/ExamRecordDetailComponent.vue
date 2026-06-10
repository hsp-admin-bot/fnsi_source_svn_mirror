/**
 * 検査結果一覧用メイン
 */
<template>
  <div class='main-content-area kendo-grid-style-page' style = "overflow-y: hidden;overflow-x:hidden;">
    <div class='exam-record-detail-head-content' id='examrecorddetailhead' style="position:relative;">
      <div style="width: 100%; height: 4.7em; font-size: 0.667em;">
        <common-searcharea :lineHeight="'3.8em'" :conditionList="conditionList" @show-popover='showPopover($event)'/>
      </div>
      <!--劉全航 start-->
      <!-- mod #10359 編集権限の動作不正 dengshen start -->
      <!-- <v-ons-button -->
      <!-- class="examRecord-style-select-button btn3-normal" -->
      <!-- style="min-width: 5em; margin-left: 0.5em;" -->
      <!-- v-bind:disabled="isDisabled" -->
      <!-- @click="createExamRecord"> -->
      <v-ons-button
        class="examRecord-style-select-button btn3-normal"
        style="min-width: 5em; margin-left: 0.5em;"
        v-bind:disabled="!isDisabled && !getItemAuthorized('ExamRecord', 'default_authority')"
        @click="createExamRecord">
      <!-- mod #10359 編集権限の動作不正 dengshen end -->
      新規登録
      </v-ons-button>
      <!-- del delete button 関 start -->
      <!-- <v-ons-button class="examRecord-style-select-button" style="margin-right: 1em; float:right;" v-bind:disabled="isSelectedPatId == null" @click="createExamRecord">新規作成</v-ons-button> -->
      <!-- del delete button 関 end -->
      <!--劉全航 end-->
      <v-ons-button class="examRecord-style-select-button btn3-normal" style="min-width: 4em; margin-left: 0.5em;" @click="createGraph">グラフ</v-ons-button>
    </div>
    <div class='exam-record-detail-main-content' style = "overflow-y:auto; overflow-x:auto; position:relative; top:5px;">
      <!-- チェックリスト一覧のグリッド -->
      <div id='examrecorddetailgrid'>
        <kendo-grid class = 'exam-detail-list'
          ref='examrecorddetailgrid'
          :data-source='examDetailDataSource'
          :editable='false'
          :reorderable='false'
          :resizable='true'
          :selectable='"cell"'
          :height='kendoGridHeight'
          :scrollable='true'
          :data-bound="setFontColor"
          :data-binding="dataBound"
          :change="onClickChange"
        >
        <kendo-grid-column v-for='category in examRecordDetailGridColumns' :key="category.length"
          :headerTemplate='category.headerTemplate'
          :title='category.title'
          :width='category.width'
          :field='category.field'
          :columns='category.columns'
          :hidden='category.hidden'
          :locked='category.locked'
          :lockable='category.lockable'
        >
        </kendo-grid-column>
        </kendo-grid>
      </div>
    </div>

    <v-ons-popover
      cancelable
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      :direction="popoverDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'exam-record-detail-popover']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="handlePopoverPosthide"
    >
      <div style="margin:10px;">
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">検査日開始</label>
          </v-ons-col>
          <v-ons-col vertical-align='center' style="white-space: nowrap;">
            <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
            <!-- <input
              input-id='treatDateSt'
              name='treatDateSt'
              type='date'
              float
              model-event="change"
              class="ntss-input-date"
              style="padding-right: unset"
              v-model='localCondition.examDateSt'
              v-validate="'date_format:yyyy-MM-dd'" /> -->
            <date-input
              input-id="treatDateSt"
              name="treatDateSt"
              type="date"
              model-event="change"
              class="ntss-input-date"
              style="padding-right: unset"
              v-model="localCondition.examDateSt"
              v-validate="'date_format:yyyy-MM-dd'"
              @handleClearInput="localCondition.examDateSt = ''"
            />
            <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
            <common-calendar v-model="localCondition.examDateSt" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">検査日終了</label>
          </v-ons-col>
          <v-ons-col vertical-align='center' style="white-space: nowrap;">
            <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
            <!-- <input
              input-id='treatDateEd'
              name='treatDateEd'
              type='date'
              float
              model-event="change"
              class="ntss-input-date"
              style="padding-right: unset"
              v-model='localCondition.examDateEd'
              v-validate="'date_format:yyyy-MM-dd'" /> -->
            <date-input
              input-id="treatDateEd"
              name="treatDateEd"
              type="date"
              model-event="change"
              class="ntss-input-date"
              style="padding-right: unset"
              v-model="localCondition.examDateEd"
              v-validate="'date_format:yyyy-MM-dd'"
              @handleClearInput="localCondition.examDateEd = ''"
            />
            <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
            <common-calendar v-model="localCondition.examDateEd" />
          </v-ons-col>
        </v-ons-row>
        <v-ons-row v-show="errors.has('treatDateSt')">
          <td>
            <p v-show="errors.has('treatDateSt')" class="error-message">
              {{ errors.first('treatDateSt') }}
            </p>
          </td>
        </v-ons-row>
        <v-ons-row v-show="errors.has('treatDateEd')">
          <td>
            <p v-show="errors.has('treatDateEd')" class="error-message">
              {{ errors.first('treatDateEd') }}
            </p>
          </td>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">異常値のみ表示</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <v-ons-switch input-id="switchTreatDate" v-model="localCondition.outRange"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">正常範囲列表示</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <v-ons-switch input-id="switchNormalRange" v-model="localCondition.normalRange"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">単位列表示</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <v-ons-switch input-id="switchUnit" v-model="localCondition.unitDisplay"></v-ons-switch>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">検査セット</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <v-ons-select input-id='examSetCd' v-model="localCondition.examSetCd">
              <option :value="defaultSelect"></option>
              <option v-for="(option, index) in getExamSetNameList" :key="index" :value="option.examSetCd">
                {{ option.examSetName }}
              </option>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class='condition-row'>
          <v-ons-col width='45%' vertical-align='center'>
            <label style="font-size:1.5em;">グラフセット</label>
          </v-ons-col>
          <v-ons-col vertical-align='center'>
            <v-ons-select input-id='examSetCd' v-model="localCondition.examGraphCd">
              <option :value="defaultSelect"></option>
              <template v-for='(option, index) in getExamSetNameList'>
                 <option v-if="option.graphSet == 1" :key="index" :value="option.examSetCd">
                  {{ option.examSetName }}
                </option>
              </template>
            </v-ons-select>
          </v-ons-col>
        </v-ons-row>
        <div class='condition-row' style="height:30px;margin-bottom:5px;">
          <div style="float:left;">
            <v-ons-button class='clear btn2-cancel' @click='dialogClear'>クリア</v-ons-button>
          </div>
          <div style="float:right;">
            <v-ons-button class='ok btn3-normal' :disabled="!canSave" @click='dialogOk'>OK</v-ons-button>
          </div>
        </div>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
  // add #10359 編集権限の動作不正 dengshen start
  import { getAuthorized } from "@/functions/common/CommonFunctions.js";
  // add #10359 編集権限の動作不正 dengshen end
  import Kendo from "@progress/kendo-ui";
  import {mapActions, mapGetters, mapMutations} from "vuex";
  import {EventBus} from "@/eventBus.js";
  import NextTransitionMixin from "@/components/NextTransitionMixin";
  import {deepCopy} from "@/functions/common/CommonFunctions";
  import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
  import commonSearchArea from "@/components/common/CommonSearchArea";
  import PopoverMixin from "@/components/PopoverMixin";
  import { EXAM_RECORD } from "@/constants/defaultSettingConstants";
  import {calcTargetDate, DATE_FORMAT} from "@/functions/modals/default-setting/defaultSettingUtils";
  import {popoverPosthide, popoverPostShow, popoverPreShow} from "@/functions/common/CommonPopoverFunctions";
  import { makeDefaultCondition, findExamSet } from "@/functions/exam-record/ExamRecordFunctions";

  import moment from "moment";
  import $$ from "jquery";
  // del #10359 編集権限の動作不正 dengshen start
  // //mod 編集権限の適用 劉全航 start
  // import {AUTHORITY_CODES} from "@/constants/userAuthority.js";
  // //mod 編集権限の適用 劉全航 end
  // del #10359 編集権限の動作不正 dengshen end
  import { getCurrentFunctionCd } from "@/router/routing-helper";
  import {DISP_ORDER_LEFT_PAST} from "@/constants/examRecordConstants";
  // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
  import DateInput from "@/components/common/DateInput.vue";
  // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
  // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
  import {messageFormat} from "@/functions/common/MessageFormat";
  import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
  // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng end
  // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
  import store from "@/stores";
  // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
  import PrintMixin from "@/components/PrintMixin";

export default {
props: {
  // NOTE: コンソールエラー対策
  historyKey: null
},
  components: {
    "common-calendar": commonCalender,
    "common-searcharea": commonSearchArea,
	// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
    "date-input": DateInput,
	// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
  },
  mixins: [NextTransitionMixin, PopoverMixin, PrintMixin],
  // #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
  // beforeRouteLeave(to, from, next) {
  async beforeRouteLeave(to, from, next) {
  // #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng end
    if(to.fullPath.indexOf("exam-record") > -1){
      // 遷移先が検査結果系画面：初期化しない
    }else{
      // 遷移先が検査結果系画面以外：listを初期化
      this.storeReset();
    }
    // #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
    // next();
    try {
      if (to.name != "signin" && !!this.isPatInfoChaned) {
        await this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: answer => {
            if (answer === 1) {
              this.setIsPatInfoChaned(false);
              next();
            }
          }
        });
      } else {
        next();
      }
    } catch (error) {
      getErrorMessage('ExamRecordDetailComponent.vue', 'beforeRouteLeave', error);
      next();
    }
    // #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng end
  },
  data() {
    return {
      popoverVisible: false,
      popoverTarget: null,
      popoverDirection: "down",
      // 抽出条件
      localCondition: {
        examDateSt: "",
        examDateEd: "",
        outRange: false,
        normalRange: false,
        unitDisplay: false,
        examSetCd: -1,
        examGraphCd: -1,
	      examPatId: "",
        examPatSex: "",
      },
      sendOrdNo: null,
      debugmode: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      selectItems:[],
      androidFlg: false,
      iosFlg: false,
      firstRender: true,
      scrollPosition: {
        top: 0,
        left: 0
      },
      //mod 編集権限の適用 劉全航 end
      // 共通検索エリア部品に表示するデータのリスト
      conditionList: [],
      selfScreenName: "",
      setScrollPosition: null,
      scrollQuerySelector: ".k-grid-content", // スクロールコンテナ
      addClassTargetQuerySelector: [".k-grid-header-wrap table, .k-grid-content table"], // scroll-rightmostクラスを付与する対象のクエリセレクタ,
      isLoadingTriggered: false
    };
  },
  computed: {
    // add #11285 機能帳票の印刷情報対応② 高 start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #11285 機能帳票の印刷情報対応② 高 end
    ...mapGetters("account-edit", {
      getDefaultSetting: "getDefaultSetting"
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      sidebarWidth: "getSidebarWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
      //20260316 liyanze-z add 自施設(1) or 他施設(0)
      getPatientShareMode:"getPatientShareMode"
    }),
    //liyanze-z 20260324 add start
    ...mapGetters("pat-info", ["getIsOtherFacility", "getOtherFacilityCd"]),
    //liyanze-z 20260324 add end
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("exam-record/list", [
      "getCondition",
      "getDetailCondition",
      "getExamRecordDetailColumn",
      "getExamDetailDataSource",
      "getExamSetNameList",
      "getExamDefaultSex",
      "getExamResultDispOrder",
    ]),
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 start
    ...mapGetters("exam-record/modal", [
      "getIsOpenFlag"
    ]),
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 end
    ...mapGetters("pat-info", ["selectedPatId","selectedPatSex"]),
    ...mapGetters("split-graph", ["getExamRecordDate"]),
    ...mapGetters("loading-screen", ["getLoadingScreenVisible"]),
    ...mapGetters("account-edit", ["getDefaultSetting"]),
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
    ...mapGetters("pat-info", ["isPatInfoChaned"]),
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng end
    examDetailDataSource() {
      // mod #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 start
      let dataObj = this.getExamDetailDataSource
      if (dataObj != null) {
        dataObj = this.replaceObjData(dataObj, "NaN", "")
      }
      // storeからデータを取得
      return new Kendo.data.DataSource({
        // data: this.getExamDetailDataSource
        data: dataObj
      });
      // mod #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 end
    },
    examRecordDetailGridColumns() {
      return this.getExamRecordDetailColumn;
    },
    defaultSelect: () => -1,
    treatDate() {
      return this.getDetailCondition.treatDate.replace(/-/g, "/");
    },
    isSelectedPatId(){
      return this.selectedPatId;
    },
    /**
     * OKボタンがクリックできるかどうか.
     */
    canSave() {
      return this.$validator.errors.items.length === 0 && !!this.selectedPatId;
    },

    isDisabled(){
      // mod #10359 編集権限の動作不正 dengshen start
      // if(this.isAuthorized === true & this.isSelectedPatId !== null){
      if(this.isSelectedPatId !== null){
      // mod #10359 編集権限の動作不正 dengshen end
        return false;
      }else{
        return true;
      }
    },
  },
  methods: {
    ...mapActions("multi-modal", [
      "showExamRecordModal",
      "showExamRecordGraphModal"
    ]),
    ...mapActions("exam-record/list", [
      "storeReset",
      "setDetailCondition",
      "resetStatusDetailGridColumn",
      "setExamRecordDetailColumn",
      "sendDetailCondition",
      "resetExamDetailDataSource",
      "setExamDetailSelectData",
      "setDetailSelectItems",
      "examSelectDefaultSex",
      "examSetNameList",
      "setSortNameList",
      "resultDispOrderSetting",
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
    ]),
    ...mapActions("exam-record/modal", ["setExamModalDataSource"]),
    ...mapActions("split-graph", ["setExamRecordDate"]),
    // mod 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 start
    ...mapMutations("exam-record/modal", ["setModalState", "setIsOpenFlag"]),
    // mod 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 end
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng start
    ...mapMutations("pat-info", ["setIsPatInfoChaned"]),
    // add #10619 患者選択状態で検査結果に遷移した際にパンくずリストの配列が不正となる。 linjunfeng end
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays"
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end
    handlePopoverPosthide(event) {
      if (this.popoverVisible) {
        // 背景クリックで閉じられる場合
        this.setStoredCondition();
      }
      this.popoverPosthide(event);
    },
    // add #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 start
    replaceObjData(obj, val, replace) {
      if (typeof obj === "object") {
        if (Array.isArray(obj)) {
          for (let i = 0; i < obj.length; i++) {
            obj[i] = this.replaceObjData(obj[i], val, replace);
          }
        } else {
          for (let key in obj) {
            obj[key] = this.replaceObjData(obj[key], val, replace);
          }
        }
        return obj
      } else {
        return obj = obj === val ? replace :obj;
      }
    },
    // add #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 end
    // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe start
    getselectedExamSetName(examSetCd){
      var name = "";
      if (examSetCd != -1) {
        this.getExamSetNameList.forEach(everySet => {
          if (everySet.examSetCd == examSetCd) {
            name = everySet.examSetName;
          }
        });
      }
      return name;
    },
    // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe end
    requestrReportParams(param) {
      // 機能コード判定
      // mod 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 start
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3) && !this.getIsOpenFlag) {
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
        // add #11285 機能帳票の印刷情報対応② 高 end
        // mod 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 end
        // 機能一致
        var patFalg;
        if (this.selectedPatId === null) {
          patFalg = this.searchedPatList.map(({ pat_id }) => pat_id);
        } else {
          patFalg = null;
        }
        // 印刷パラメータを応答
        const params = {
          patId: this.selectedPatId,
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //patIds: patFalg,
          facilityCd: this.getFacilityCd,
          //add #9558 機能帳票でパラメータが正しく渡されていない 房 start
          //date: moment(this.localCondition.examDateSt).format("YYYY/MM/DD"),
          //add #9558 機能帳票でパラメータが正しく渡されていない 房 end
          //fromDate: moment(this.localCondition.examDateSt).format("YYYY/MM/DD"),
          //toDate: moment(this.localCondition.examDateEd).format("YYYY/MM/DD"),
          date: this.localCondition.examDateSt != null ? moment(this.localCondition.examDateSt).format("YYYYMMDD") : (this.localCondition.examDateEd != null ? moment(this.localCondition.examDateEd).format("YYYYMMDD") : moment(new Date()).format("YYYYMMDD")),
          fromDate: this.localCondition.examDateSt != null ? moment(this.localCondition.examDateSt).format("YYYYMMDD") : (this.localCondition.examDateEd != null ? moment(this.localCondition.examDateEd).format("YYYYMMDD") : moment(new Date()).format("YYYYMMDD")),
          toDate: this.localCondition.examDateEd != null ? moment(this.localCondition.examDateEd).format("YYYYMMDD") : (this.localCondition.examDateSt != null ? moment(this.localCondition.examDateSt).format("YYYYMMDD") : moment(new Date()).format("YYYYMMDD")),
          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 20250527 limingzhe start
          //dialysisDate: moment(new Date()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: this.localCondition.examDateSt != null ? moment(this.localCondition.examDateSt).format("YYYYMMDD") : (this.localCondition.examDateEd != null ? moment(this.localCondition.examDateEd).format("YYYYMMDD") : moment(new Date()).format("YYYYMMDD")),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 20250527 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          functionCd:"01801",
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe start
          selectExamSetCd: this.localCondition.examSetCd,
          selectedExamSetName: this.getselectedExamSetName(this.localCondition.examSetCd),
          selectExamGraphCd: this.localCondition.examGraphCd,
          selectedExamGraphName: this.getselectedExamSetName(this.localCondition.examGraphCd),
          // add ##11152 検査結果(個別)で機能帳票のパラメータに「検査セット」を追加 limingzhe end
          // add #11285 機能帳票の印刷情報対応② 高 start
          treatDate:this.getStorSimlpSearchQurey.treatDate,
          bedCdListString:this.getStorSimlpSearchQurey.selectedBedGName,
          freeWord:this.getStorSimlpSearchQurey.freeWord,
          expressCondCdStr:expressCondCd,
          kurNames:kurNames,
          patGroups:patGroups,
          // add #11285 機能帳票の印刷情報対応② 高 end
        };
        EventBus.$emit("sendReportParams", params);
      }
    },
    // -----------------------------------------
    // グリッドヘッダ押下イベント
    // -----------------------------------------
    dataBound() {
      // データ形式(data_type)が1:数値のもののみクリック時イベントを発火
      let self = this;
      // モーダル表示
      $$("th[role='columnheader']").off("click").on("click", function (e) {
        const field = $$(this).data("field");
        if (!field) return;

        const column = self.examRecordDetailGridColumns
          .flatMap(c => c.columns || [c])
          .find(c => c.field === field);

        if (column?.isOtherFacility) {
          e.preventDefault();
          e.stopPropagation();
          return false;
        }

        self.onClick(e);
      });
      // ポップアップ表示
      $$("th[data-field=examItemName]").off("click");
      $$("th[data-field=normalValue]").off("click");
    },
    // グリッドクリック時
    onClickChange(event) {
      const grid = event.sender;
      if (!grid) return;

      const selectedCell = grid.select();

      const isBodyCell = selectedCell.is("td") &&
        selectedCell.closest("tbody").length > 0;

      if (!isBodyCell) {
        event.preventDefault();
        return;
      }

      const colIndex = grid.cellIndex(selectedCell);
      const field = grid.columns[colIndex]?.field;

      const column = this.examRecordDetailGridColumns.find(c => {
        if (c.columns) {
          return c.columns.some(sub => sub.field === field);
        }
        return c.field === field;
      });

      if (column?.isOtherFacility) {
        grid.clearSelection();
        event.preventDefault();
        return;
      }
      if (event.sender) {
          this.setFontColor(event);
          const selRow = this.$refs.examrecorddetailgrid.kendoWidget().select().closest("tr");
          let selRowData = this.$refs.examrecorddetailgrid.kendoWidget().dataItem(selRow);
          let selRowIndex = "";
          const selcolIndex = event.sender.cellIndex(event.sender.select().closest("td"));

          if (event.sender.select().closest(event.sender.lockedContent).length) {
            //固定行押下のケース：グラフ選択と背景色付け
            let selectFlg = "noselect";
            selRowIndex = $$("tr", event.sender.lockedContent).index(event.sender.select().closest("tr"));
            if (selRowIndex == -1) {
              //ヘッダーは無効化
              return;
            }
            //選択済5件未満かつ選択対象外コード：追加
            //選択済データの押下：削除
            if(this.selectItems.length < 5 && !this.selectItems.some(str => String(selRowData.examItemCd) === str)){
              this.selectItems.push(String(selRowData.examItemCd));
              selectFlg = "selected";
            }else if(this.selectItems.some(str => String(selRowData.examItemCd) === str)){
              this.selectItems.splice(this.selectItems.indexOf(String(selRowData.examItemCd)), 1);
            }
            //画面再表示
            const tbodyc = this.$refs.examrecorddetailgrid.$el.children[1].lastChild.tBodies[0].children;
            const tbodyc2 = this.$refs.examrecorddetailgrid.$el.children[2].lastChild.tBodies[0].children;
            if(selectFlg ==="selected"){
              for(let columnNo = 0;columnNo < tbodyc[selRowIndex].children.length; columnNo++){
              tbodyc[selRowIndex].children[columnNo]?.classList?.add("kendo-grid-style-selected");
              }
              for(let columnNo2 = 0;columnNo2 < tbodyc2[selRowIndex].children.length; columnNo2++){
              tbodyc2[selRowIndex].children[columnNo2]?.classList?.add("kendo-grid-style-selected");
              }
            }else{
              for(let columnNo = 0;columnNo < tbodyc[selRowIndex].children.length; columnNo++){
                tbodyc[selRowIndex].children[columnNo].classList.remove("kendo-grid-style-selected");
              }
              for(let columnNo2 = 0;columnNo2 < tbodyc2[selRowIndex].children.length; columnNo2++){
                tbodyc2[selRowIndex].children[columnNo2].classList.remove("kendo-grid-style-selected");
              }
            }
            //storeにデータセット
            this.setDetailSelectItems(deepCopy(this.selectItems));

          } else {
            //可変行押下のケース：
            const headarData = $$("th[role='columnheader']");
            selRowIndex = $$("tr", event.sender.content).index(event.sender.select().closest("tr"));
            if(selRowIndex == -1){
              return;
            }
            if ($$(headarData[selcolIndex]).data("field")) {
              this.setModalState(1);
              const field = $$(headarData[selcolIndex]).data("field")
              this.setExamModalDataSource({field:field,facilityCd:this.getFacilityCd,patId:this.selectedPatId,patSex:this.selectedPatSex,defaultSex:this.getExamDefaultSex}).then(() => {
                // 表示
                this.showExamRecordModal();
                // 選択解除
                this.$refs.examrecorddetailgrid.kendoWidget().clearSelection();
              });
            }
          }
      }
    },

    //画面リサイズ時再処理
    resizeSelectRows(){
      // #8368対応時のメモ：
      // this.$refs.examrecorddetailgrid.$el.lastChild.lastChild
      // （＝this.$refs.examrecorddetailgrid.$el.children[2].lastChild）は
      // 検索結果が1件以上ある場合はtable要素になるが、
      // 検索結果が0件の場合はdiv要素になるため、
      // その要素のプロパティにtBodiesが存在する
      // （＝table要素である≒検索結果が1件以上ある）場合のみ
      // tBodies内の要素に選択行の見た目にするCSSクラスを設定する処理を行っている
      if(this.$refs.examrecorddetailgrid.$el.lastChild.lastChild.tBodies){
        const tbodyc = this.$refs.examrecorddetailgrid.$el.children[1].lastChild.tBodies[0].children;
        const tbodyc2 = this.$refs.examrecorddetailgrid.$el.children[2].lastChild.tBodies[0].children;

        const gridData = this.$refs.examrecorddetailgrid.dataSource.options.data;
        if(gridData){
          gridData.forEach((dataRow, index) => {
            if(this.selectItems.indexOf(String(dataRow.examItemCd)) >= 0){
              for(let columnNo = 0;columnNo < tbodyc[index].children.length; columnNo++){
                tbodyc[index].children[columnNo]?.classList?.add("kendo-grid-style-selected");
              }
              for(let columnNo2 = 0;columnNo2 < tbodyc2[index].children.length; columnNo2++){
                tbodyc2[index].children[columnNo2]?.classList?.add("kendo-grid-style-selected");
              }
            }
          });
        }
      }
    },

    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.popoverTarget = event;

      // 検索条件にstoreの情報をセット
      this.setStoredCondition();
      // 表示
      this.popoverVisible = true;
    },
    setStoredCondition() {
      const condition = this.getDetailCondition;
      this.localCondition.examDateSt = condition.examDateSt;
      this.localCondition.examDateEd = condition.examDateEd;
      this.localCondition.normalRange = condition.normalRange;
      this.localCondition.outRange = condition.outRange;
      this.localCondition.unitDisplay = condition.unitDisplay;
      this.localCondition.examSetCd = condition.examSetCd;
      // add #9465 #8368のソース巻き戻り 関 start
      this.localCondition.examGraphCd = condition.examGraphCd;
      // add #9465 #8368のソース巻き戻り 関 end
    },
    // -----------------------------------------
    // 抽出条件クリアボタンクリックイベント
    // -----------------------------------------
    dialogClear() {
      // 検索条件クリアして画面を更新
      this.setDefaultCondition();
      this.dialogOk();
    },
    // -----------------------------------------
    // 抽出条件OKボタンクリックイベント
    // -----------------------------------------
    dialogOk() {
      // 画面を閉じる
      this.popoverVisible = false;
      this.search();
    },
    // ------------------------------------------------------------------
    // 処理：抽出条件を元にした検索イベント
    // ------------------------------------------------------------------
    search() {
      // 検査日が変更された場合
      const chgFlg = (
        (this.localCondition.examDateSt != this.getDetailCondition.examDateSt)
        || (this.localCondition.examDateEd != this.getDetailCondition.examDateEd)
        || (this.localCondition.examSetCd != this.getDetailCondition.examSetCd)
        || (this.localCondition.outRange != this.getDetailCondition.outRange)
      );

      // 抽出条件登録
      this.setDetailCondition(this.localCondition);
      this.setConditionList();

      // 検索条件の内容で画面を更新
      this.setFilterCondition(chgFlg);
      let allItem = [];
      if (this.localCondition.examGraphCd != -1) {
        this.getExamSetNameList.forEach(everySet => {
          if (everySet.examSetCd == this.localCondition.examGraphCd) {
            this.selectItems = [];
            allItem = JSON.parse(everySet.examItemInfo);
            allItem.forEach(everyItem => {
              this.selectItems.push((String)(everyItem.exam_item_cd));
            });
          }
        });
        // #8368対応時のメモ：
        // setFilterCondition の呼び出しによる検索後の状態にDOMの更新が行われた後に
        // update から resizeSelectRows が呼ばれて
        // 選択行の見た目にするCSSクラスをtBodies内の要素に設定する処理が行われるので、
        // ここではその処理は不要
        this.setDetailSelectItems(deepCopy(this.selectItems));
      }
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      const wh = this.windowHeight;
      const hh = Array.prototype.slice
        .call(document.getElementsByClassName("header"))
        .shift().clientHeight;
      const fmh =
        (this.isDispMenu === 1
          ? document.getElementById("footer-menu").clientHeight
          : 0) + 5;
      const buttonArea = document.getElementById("examrecorddetailhead").clientHeight;
      this.kendoGridToolbarHeight = wh - hh - fmh - 10;
      this.kendoGridToolbarHeight =
      this.kendoGridToolbarHeight < 340 ? 340 : this.kendoGridToolbarHeight;

      this.kendoGridHeight = this.kendoGridToolbarHeight - buttonArea;
    },
    setHeaderStyle() {
      // ヘッダーにスタイル適用
      this.$refs.examrecorddetailgrid.$el.firstElementChild?.classList?.add(
        "master-grid-header"
      );
    },
    // 抽出条件変更イベント
    setFilterCondition(chgflg) {
      // 抽出条件が変更された場合
      if (chgflg) {
        // スケジュール取得
        this.dataLoad();
      } else {
        this.filteredExamRecord();
      }
      // 選択項目のリセット
      this.selectItems = [];
      this.setDetailSelectItems(deepCopy(this.selectItems));
    },

    // 検索条件が変更されたら表示内容を更新
    filteredExamRecord() {
      // 治療日列の表示/非表示
      let colsetting = deepCopy(this.getExamRecordDetailColumn);
      colsetting[4].hidden = !this.localCondition.normalRange;
      colsetting[5].hidden = !this.localCondition.unitDisplay;
      this.setExamRecordDetailColumn(colsetting);
    },

    // データ更新
    setExamRecord() {
      if (this.selfScreenName === this.$router.currentRoute.name) {
        this.dataLoad();
      }
    },
    async dataLoad() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      const examDateOrder = this.getExamResultDispOrder === DISP_ORDER_LEFT_PAST ? "asc" : "desc";
      // 表示データ設定
      await this.setExamDetailSelectData(
        {
          facilityCd: this.getFacilityCd, 
          examDateOrder: examDateOrder,
          patientShareMode: (this.getIsOtherFacility === false || (this.getOtherFacilityCd !== null && this.getOtherFacilityCd !== this.getFacilityCd)) ? 1 : this.getPatientShareMode

        }
      );
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
      // レコード列表示制御
      this.filteredExamRecord();
      if (this.firstRender) {
        this.$nextTick(() => {
          this.scrollFromRight();
        });
        this.firstRender = false;
      }

      this.$nextTick(() => {
        const gridContent = document.querySelector(".k-grid-content");
        this.setScrollPosition = () => {
          this.scrollPosition = {
            top: gridContent.scrollTop,
            left: gridContent.scrollLeft
          };
        }
        gridContent.addEventListener("scroll", this.setScrollPosition);
      });
    },
    // 検査データの文字色を設定
    scrollFromRight() {
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 start
      if(this.getCondition.examDate != "" && this.getCondition.examDate != null && this.getCondition.examDate != undefined){
        var scrollleftWidth = 0;
        for(let colIndex = 0; colIndex < document.querySelector(".k-grid-header-wrap").getElementsByTagName("th").length; colIndex++){
          if(document.querySelector(".k-grid-header-wrap").getElementsByTagName("th")[colIndex].outerText.indexOf(this.getCondition.examDate) != -1){
            scrollleftWidth = document.querySelector(".k-grid-header-wrap").getElementsByTagName("th")[colIndex].offsetLeft;
            break;
          }
        }
        this.scrollPosition.left = scrollleftWidth;
        this.$refs.examrecorddetailgrid.$el.children[2].scrollLeft = scrollleftWidth;
      }
      //add FNSI-患者カレンダに表示する予定の不足情報を追加する 江 end
      // スクロール位置を最新データに合わせる
      let lastColumnId;
      if(this.getExamResultDispOrder === DISP_ORDER_LEFT_PAST){
        const numberOfColumns = this.$refs.examrecorddetailgrid.kendoWidget().columns.length;
        lastColumnId = this.$refs.examrecorddetailgrid.kendoWidget().columns[numberOfColumns - 1].headerAttributes.id;
      } else {
        lastColumnId = this.$refs.examrecorddetailgrid.kendoWidget().columns[6].headerAttributes.id;
      }
      const lastColumnElement = document.getElementById(lastColumnId);
      if (lastColumnElement) lastColumnElement.scrollIntoView();
    },
    setFontColor(e){
      const lockrows = e.sender.content.find("tr");
      lockrows.each(function(index, row) {
        const dataItem = e.sender.dataItem(row);
        const dataColumns = e.sender.columns;
        // mod FNSI-Fix Bug 関 start
        // for (let i = 5; i < dataColumns.length; i++) {
        for (let i = 6; i < dataColumns.length; i++) {
        // mod FNSI-Fix Bug 関 end
          const value = dataColumns[i];
          if (dataItem[value.field+"Class"] == "H") {
            // mod FNSI-Fix Bug 関 start
            // row.children[i-2].style.color = "red";
            row.children[i-3].style.color = "var(--kendo-grid-style-high-class-color)";
            // mod FNSI-Fix Bug 関 end
          } else if (dataItem[value.field+"Class"] == "L") {
            // mod FNSI-Fix Bug 関 start
            // row.children[i-2].style.color = "blue";
            row.children[i-3].style.color = "var(--kendo-grid-style-low-class-color)";
            // mod FNSI-Fix Bug 関 end
          }
        }
      });
      // 高さの調整処理もdata-boundに連動して実施(kendo-gridのlockedオプション使用時に高さがずれる件の対応)
      this.$nextTick(() => {
        const headerHeight = document.getElementsByClassName("k-grid-header")[0].offsetHeight + 2;
        const scrolObj = document.getElementsByClassName("k-grid-content k-auto-scrollable")[0];
        let lockRowHeight = this.kendoGridHeight - headerHeight;
        // PCでの表示時のみ、スクロールバー分の不要な高さが発生する為、高さの調整を行う
        if (!this.androidFlg && !this.iosFlg && (scrolObj.scrollWidth > scrolObj.clientWidth)) {
          lockRowHeight -= 17;
        }
        document.getElementsByClassName("k-grid-content-locked")[0].style.height = lockRowHeight + "px";
      });
      const lockedContent = document.querySelector('.k-grid-content-locked');
      const scrollableContent = document.querySelector('.k-grid-content');
      if (lockedContent) {
        let startY = 0;
        // タッチ開始位置を記録（iOS/Android対応）
        lockedContent.addEventListener('touchstart', (e) => {
          startY = e.touches[0].clientY;
        }, { passive: false });

        lockedContent.addEventListener('touchmove', (e) => {
          // タッチ移動に応じてスクロール（iOS/Android対応）
          const deltaY = startY - e.touches[0].clientY;
          lockedContent.scrollTop += deltaY;
          startY = e.touches[0].clientY;
          e.preventDefault(); // 慣性スクロールを有効にするために必要
        }, { passive: false });
      }

      if (lockedContent && scrollableContent) {
        // 固定列のスクロールに応じて可動列を同期（縦スクロールの一体化）
        lockedContent.addEventListener('scroll', () => {
          scrollableContent.scrollTop = lockedContent.scrollTop;
        });

        // 可動列のスクロールに応じて固定列を同期（双方向同期）
        scrollableContent.addEventListener('scroll', () => {
          lockedContent.scrollTop = scrollableContent.scrollTop;
        });
      }
    },
    // グリッドクリック時
    onClick(event) {
      if ($$(event.currentTarget).data("field")) {
        this.setModalState(1);
        const field = $$(event.currentTarget).data("field")

        this.setExamModalDataSource({field:field,facilityCd:this.getFacilityCd,patId:this.selectedPatId,patSex:this.selectedPatSex,defaultSex:this.getExamDefaultSex}).then(() => {
          // 表示
          this.showExamRecordModal();
          // 選択解除
          this.$refs.examrecorddetailgrid.kendoWidget().clearSelection();
        });
      }
    },
    // 新規作成
    createExamRecord() {
      this.setModalState(0);
      this.setExamModalDataSource({field:null,facilityCd:this.getFacilityCd,patId:this.selectedPatId,patSex:this.selectedPatSex,defaultSex:this.getExamDefaultSex}).then(() => {
        // 表示
        this.showExamRecordModal();
      });
      this.search()
    },
    // グラフ作成
    createGraph() {
      // selectItemsが空の場合はグラフ表示しない
      if (this.selectItems.length >= 0) {
        this.showExamRecordGraphModal();
      }
    },
    restoreScrollPosition() {
      const gridContent = document.querySelector(".k-grid-content");
      gridContent.scrollTop = this.scrollPosition.top;
      gridContent.scrollLeft = this.scrollPosition.left;
    },
    // -----------------------------------------
    // 共通検索エリア部品に表示するデータのリストを作成
    // -----------------------------------------
    setConditionList() {
      const condObj = this.localCondition;
      const examSet = findExamSet(condObj.examSetCd, this.getExamSetNameList);
      const makeInfo = (visible, text, name) => ({ visible, listItem: { name, text } });
      const isValidDate = value => value !== "" && value != null;
      const cnvDateFmt = (value) => {
        if (isValidDate(value)) {
          return value.replace(/-/g, "/");
        } else {
          return value;
        }
      };
      this.conditionList = [
        makeInfo(isValidDate(condObj.examDateSt), cnvDateFmt(condObj.examDateSt), "検査日開始"),
        makeInfo(isValidDate(condObj.examDateEd), cnvDateFmt(condObj.examDateEd), "検査日終了"),
        makeInfo(condObj.outRange, "異常値のみ表示"),
        makeInfo(condObj.normalRange, "正常範囲列表示"),
        makeInfo(condObj.unitDisplay, "単位列表示"),
        makeInfo(examSet, examSet && examSet.examSetName, "検査セット"),
      ].reduce((condList, info) => {
        if (info.visible) {
          condList.push(info.listItem);
        }
        return condList;
      }, []);
    },
    // -----------------------------------------
    // 個人設定で登録した初期値をStoreに登録する
    // -----------------------------------------
    setDefaultCondition() {
      // 画面側初期値の登録
      const initialDefault = makeDefaultCondition();
      this.localCondition.examDateSt = initialDefault.examDateSt;
      this.localCondition.examDateEd = initialDefault.examDateEd;
      this.localCondition.outRange = initialDefault.outRange;
      this.localCondition.normalRange = initialDefault.normalRange;
      if (this.androidFlg || this.iosFlg) {
        this.localCondition.normalRange = false;
      }
      this.localCondition.unitDisplay = initialDefault.unitDisplay;
      this.localCondition.examSetCd = initialDefault.examSetCd;
      this.localCondition.examGraphCd = initialDefault.examGraphCd;
      // デフォルト設定の反映
      const defaultCondition = this.getDefaultSetting[EXAM_RECORD.KEY_NAME];
      if (defaultCondition) {
        // デフォルト設定が存在する場合は適用
        if (defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_START_DATE] != null) {
          this.localCondition.examDateSt = calcTargetDate(defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_START_DATE]);
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_END_DATE] != null) {
          this.localCondition.examDateEd = calcTargetDate(defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_END_DATE]);
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_OUT_RANGE] != null) {
          this.localCondition.outRange = defaultCondition[EXAM_RECORD.KEY_NAME_OUT_RANGE];
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_NORMAL_RANGE] != null) {
          // 正常範囲列表示はデフォルト設定があれば端末にかかわらず反映
          this.localCondition.normalRange = defaultCondition[EXAM_RECORD.KEY_NAME_NORMAL_RANGE];
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_UNIT_DISPLAY] != null) {
          this.localCondition.unitDisplay = defaultCondition[EXAM_RECORD.KEY_NAME_UNIT_DISPLAY];
        }
        if (defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_SET_CD] != null) {
          this.localCondition.examSetCd = defaultCondition[EXAM_RECORD.KEY_NAME_EXAM_SET_CD];
        }
      }
    },
    initCondition() {
      // デフォルト設定の反映
      this.setDefaultCondition();
      // 以前に保存した検索条件が存在する場合は反映する
      if (this.getDetailCondition.examDateSt != null) {
        this.localCondition.examDateSt = this.getDetailCondition.examDateSt;
      }
      if (this.getDetailCondition.examDateEd != null) {
        this.localCondition.examDateEd = this.getDetailCondition.examDateEd;
      }
      if (this.getDetailCondition.outRange != null) {
        this.localCondition.outRange = this.getDetailCondition.outRange;
      }
      if (this.getDetailCondition.normalRange != null) {
        this.localCondition.normalRange = this.getDetailCondition.normalRange;
      }
      if (this.getDetailCondition.unitDisplay != null) {
        this.localCondition.unitDisplay = this.getDetailCondition.unitDisplay;
      }
      if (this.getDetailCondition.examSetCd != null) {
        this.localCondition.examSetCd = this.getDetailCondition.examSetCd;
      }
      // 選択中の患者に関する項目を設定する
      this.localCondition.examPatId = this.selectedPatId;
      this.localCondition.examPatSex = this.selectedPatSex;

      if (this.getExamRecordDate) {
        // 9分割グラフから検査結果に遷移した場合
        this.localCondition.examDateSt = moment(this.getExamRecordDate).subtract(1, "months").format("YYYY-MM-DD");
        this.localCondition.examDateEd = moment(this.getExamRecordDate).add(1, "months").format("YYYY-MM-DD");
        this.setExamRecordDate(null);
      }

      if (this.hasParamsInResult()) {
        // 予実リストによる遷移時
        this.setConditionWithParams();
      }

      // 検索条件を保存しなおして表示に反映する
      this.setDetailCondition(this.localCondition);
      this.setConditionList();
    },
    hasParamsInResult() {
      return this.$route.params.condition && this.$route.params.condition.type === "in_result";
    },
    setConditionWithParams() {
      // 予実リストから渡された情報を表示条件に反映
      // #9329対応時の仕様メモ：
      // 選択したデータの検査日を表示条件の開始日終了日に設定する。検査セットは未指定状態にする。異常値のみ表示もOFFとする。
      this.localCondition.examDateSt
        = this.localCondition.examDateEd
        = moment(this.$route.params.condition.treatDate, "YYYY/MM/DD").format(DATE_FORMAT);
      this.localCondition.examSetCd = -1;
      this.localCondition.outRange = false;
    },
    triggerLoad(){
      if (this.isLoadingTriggered) return
      this.isLoadingTriggered = true

      // 共通ローダー:表示名設定
      this.setLoadingScreenMessage("処理中・・・")
      this.dataLoad()

      this.$nextTick(() => {
        this.isLoadingTriggered = false
      })
        
    }
  },
  watch: {
    // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 start
    'localCondition.examPatId':{
      handler(newValue) {
        if(newValue == null){
          store.dispatch("report/getMstReport", {funcCd: "01802",printFlag: null});
        }else {
          store.dispatch("report/getMstReport", {funcCd: "01802",printFlag: 1});
        }
      }
  },
    // add #10697 機能帳票マスタで画面に必要な帳票種別が設定できない＆画面の機能帳票リストに出てこない 杜天成 end
    windowHeight() {
      // iosPWA時の画面幅変更時:
      // app.vueのhandleResizeWindow実行後にcalculateGridHeightを実行するため、200ミリ秒待つ
      if(this.iosFlg && window.matchMedia('(display-mode: standalone)').matches){
        setTimeout(() => {
          this.calculateGridHeight();
        }, 200);
      }else{
        this.calculateGridHeight();
      }
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      // 印刷中はスキップ
      if (this.isPrint) return;      
      
      // 各項目の幅を自動調整する機能を呼び出すためにcolumnサイズを変更する（変更前と同じ値で呼び出す）
      let setWidth = parseInt(this.$refs.examrecorddetailgrid.kendoWidget().columns[0].width);
      this.$refs.examrecorddetailgrid.kendoWidget().resizeColumn(this.$refs.examrecorddetailgrid.kendoWidget().columns[0], setWidth);
      this.calculateGridHeight();
      setTimeout(() => {
        this.restoreScrollPosition();
      }, 50);
    },
    sidebarWidth(){
      $$(window).trigger('resize');
    },
    async selectedPatId() {
      // 再表示条件：選択したpatIdがnullではなく、また今表示しているidでもない場合
      if (this.selectedPatId !== null && this.selectedPatId !== this.localCondition.examPatId) {
        this.localCondition.examPatId = this.selectedPatId;
        this.localCondition.examPatSex = this.selectedPatSex;
        // 抽出条件セット
        this.setDetailCondition(this.localCondition);
        // ここは表示対象ではない項目のみの変更のため setConditionList は不要

        // データ取得
        await this.dataLoad();
        this.$nextTick(() => {
          this.calculateGridHeight();
          // ヘッダーにスタイル適用
          this.setHeaderStyle();
        });
      }
    },
    async "$route.params.condition"() {
      if (this.hasParamsInResult()) {
        // 予実リストでの画面遷移を伴わない検査予定選択時
        this.setConditionWithParams();
        // 抽出条件セット
        this.setDetailCondition(deepCopy(this.localCondition));

        if (this.selectedPatId) {
          // データ取得
          await this.dataLoad();
          this.$nextTick(() => {
            this.calculateGridHeight();
            // ヘッダーにスタイル適用
            this.setHeaderStyle();
          });
        }
        this.setConditionList();
      }
    },
    getLoadingScreenVisible() {
      if (!this.getLoadingScreenVisible && !this.firstRender) {
        this.$nextTick(() => {
          this.restoreScrollPosition();
        });
      }
    },
    //liyanze-z 20260316 add start
    getPatientShareMode(newVal, oldVal){
      this.triggerLoad();
    },
    getOtherFacilityCd(){
      this.triggerLoad();
    },
    //liyanze-z 20260316 add end
  },
  created() {
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 start
    this.setIsOpenFlag(false);
    // add 11372 【たくしん会】機能帳票からの印刷で同一帳票が2枚プリントされる　V1.0B 房 end
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("filterList", this.setFilterCondition);
    EventBus.$on("detailUpdate", this.setExamRecord);
    /*add FNSI-改修内容6326 任 start*/
    EventBus.$on("flashData",this.filteredExamRecord);
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    EventBus.$on("requestReportParams", this.requestrReportParams);
    /*add FNSI-改修内容6326 任 end*/
    // 一覧ヘッダ名をリセット
    this.resetStatusDetailGridColumn();
    this.resetExamDetailDataSource();
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // del #10359 編集権限の動作不正 dengshen start
    // //mod 編集権限の適用 劉全航 start
    // this.isAuthorized = this.getStateUserAccountInfo
    // .userSettings
    // .authorized_authorities
    // .includes(AUTHORITY_CODES.RST_EXAM_EDIT);
    // //mod 編集権限の適用 劉全航 end
    // del #10359 編集権限の動作不正 dengshen end
  },
  async mounted() {
    // パンくずリストのrefreshイベントをcreatedでリッスンすると検知しない
    EventBus.$on("refresh", this.setExamRecord);
   
    this.setLoadingScreenVisible(true);

    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }

    // 初期性別未設定判定フラグセット
    if (this.getExamDefaultSex == null) {
      await this.examSelectDefaultSex(this.getFacilityCd);
    }
    if (this.getExamSetNameList == null) {
      // 検査セットデータ生成処理：
      await this.examSetNameList(this.getFacilityCd);
      // 検査セットソート順データセット処理
      await this.setSortNameList(this.getFacilityCd);
    }
    // 検査結果画面表示順設定セット
    if (this.getExamResultDispOrder == null) {
      await this.resultDispOrderSetting(this.getFacilityCd);
    }

    // 検索条件の初期設定
    this.initCondition();

    // 選択条件リセット
    this.selectItems = [];
    this.setDetailSelectItems(deepCopy(this.selectItems));
    
    // 休日マスタの休日を取得
    this.fetchHolidays(this.getFacilityCd);

    if (this.selectedPatId) {
      // データ取得:patidがある場合のみ
      this.dataLoad();
      this.$nextTick(() => {
        this.calculateGridHeight();
        // ヘッダーにスタイル適用
        this.setHeaderStyle();
      });
    }

    this.setLoadingScreenVisible(false);
  },
  updated() {
    this.$nextTick(() => {
      // ヘッダーにスタイル適用
      this.setHeaderStyle();
      this.resizeSelectRows();
    });
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    this.clearHolidays(); // storeの休日マスタをクリア
    EventBus.$off("filterList");
    EventBus.$off("detailUpdate");
    /*add FNSI-改修内容6807 劉智博 start*/
    EventBus.$off("flashData");
    /*add FNSI-改修内容6807 劉智博 end*/
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    // EventBus.$off("requestReportParams");
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng start
    // EventBus.$off("refresh");
    EventBus.$off("refresh", this.setExamRecord);
    // #9271 他の画面への切り替え時のパンくずクリックは有効になりません。 linjunfeng end
    const gridContent = document.querySelector(".k-grid-content");
    gridContent && gridContent.removeEventListener("scroll", this.setScrollPosition);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  // add 性能改善メモリ不足 shan end
};

</script>
<style>
@media print {
  /** 検査結果 tableレイアウト崩れ回避 */
  body:has(#examrecorddetailgrid) #main-id {
    display: inline-block;
  }
}
</style>
<style scoped>
.exam-record-detail-main-content >>> .master-grid-header {
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}
.exam-record-detail-main-content >>> th.k-first {
  background-color: #333333;
  background-image: none;
}
.exam-record-detail-main-content >>> th.k-first ~ th {
  background-color: #333333;
  background-image: none;
}
.exam-record-detail-head-content {
  overflow-y: hidden;
  margin-top: 5px;
  flex: 0;
  background-color: var(--ntss-base-background-color);
  display: flex;
  flex-wrap: nowrap;
  align-items: center;
}
.exam-record-detail-main-content {
  overflow-y: hidden;
  flex: 1;
  background-color: var(--ntss-base-background-color);
}
.exam-record-detail-footer-content {
  margin-top: 5px;
  margin-right: 5px;
  flex: 0;
  background-color: var(--ntss-base-background-color);
}
.exam-record-detail-popover >>> .popover {
  width: 31em;
}

/* スマホスタイル */
@media screen and (max-width: 480px) {
  .exam-detail-list {
    font-size : 10px;
    word-wrap: break-word;
    white-space: normal;
  }
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked::-webkit-scrollbar {
  display: none;
}
@media print {  
  /** スクロールコンテナ */
  .exam-record-detail-main-content >>> .k-grid-header-wrap,
  .exam-record-detail-main-content >>> .k-grid-content {
    overflow: hidden !important;
    height: auto !important;
  }
  
  /** 固定列調整 */
  .exam-record-detail-main-content >>> .k-grid-content-locked {
    height: auto !important;
  }
  /** 固定列枠線 */
  .exam-record-detail-main-content >>> .k-grid-header-locked::after {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-header-background-color);
    pointer-events: none;
  }
  .exam-record-detail-main-content >>> .k-grid-content-locked::after {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-border-color);
    pointer-events: none;
  }
  /** ヘッダのズレ原因を除去 */
  .exam-record-detail-main-content >>> .k-grid-header {
    padding-right: 0 !important;
  }
  /** gridの幅 */
  .exam-record-detail-main-content >>> .k-grid {
    width: 100vw;
    height: auto !important;
  }
  /** 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  /* 右端時固定列最前面表示*/
  .exam-record-detail-main-content:has(table.scroll-rightmost) >>> .k-grid-content-locked,
  .exam-record-detail-main-content:has(table.scroll-rightmost) >>> .k-grid-header-locked {
    z-index: 1;
  }
  .main-content-area:has(table.scroll-rightmost) {
    margin-left: -1px !important;
  }
  .exam-record-detail-main-content >>> .k-grid-header-wrap:has(table.scroll-rightmost),
  .exam-record-detail-main-content >>> .k-grid-content:has(table.scroll-rightmost) {
    position: static;
  }
}
.exam-detail-list >>> th.k-header:has(.other-facility-header) {
  pointer-events: none;
  color: #999;
}
.exam-detail-list >>> th.other-facility-header {
  pointer-events: none;
  color: #999;
}
.exam-detail-list >>> .k-grid-content td.other-facility-cell {
  pointer-events: none;
  background-color: #0000001a !important;
  color: #999 !important;
}
.exam-detail-list >>> .k-grid-content tr.k-alt td.other-facility-cell {
  background-color: #ccc !important;
}
</style>
