/**
* 機能帳票マスタメンテナンスデータページ  MainContent
*/
<template>
  <div class='main-content-area master-maintenance-page'>
    <div class='ntss-list' :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <div class='header-btn-area right' :style="isMobileDevice ? { minHeight: '30px' } : {}">
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord" @click="addRow()">追加</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 2em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="!isSortMode && isAllowSort" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="isSortMode && isAllowSort" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <kendo-grid ref="grid" :class="fontSizeSet"
                    :data-source="masterRecords"
                    :editable="true"
                    :selectable="true"
                    :reorderable="false"
                    :height=kendoGridHeight
                    :scrollable="true"
                    :beforeEdit=modifyEditStart
                    :edit=addInputAssist
                    :cellClose=editEnd
                    @save="onSave"
                    @databound="onDataBoundKendoGrid">
          <template v-for="(column, index) in columns" >
            <!-- mod 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start -->
            <!-- <kendo-grid-column v-if="column.field == 'functionCd'"
                               :key="index"
                               :title="column.title"
                               :field="column.field"
                               :hidden="column.hidden"
                               :locked="column.locked"
                               :editable="column.editable"
                               :width="column.width"
                               :format="column.format"
                               :values="getReportSetting">
            </kendo-grid-column>
            <kendo-grid-column v-else-if="column.field == 'reportCd'"
                               :key="index"
                               :title="column.title"
                               :field="column.field"
                               :hidden="column.hidden"
                               :locked="column.locked"
                               :editable="column.editable"
                               :width="column.width"
                               :format="column.format"
                               :values="getReport">
            </kendo-grid-column> -->
            <kendo-grid-column v-if="column.field == 'functionCd'"
                               :key="index"
                               :title="column.title"
                               :field="column.field"
                               :hidden="column.hidden"
                               :locked="column.locked"
                               :editable="column.editable"
                               :width="column.width"
                               :format="column.format"
                               :values="getReportSetting"
                               :editor=filterChangefunctionCd>
            </kendo-grid-column>
            <kendo-grid-column v-else-if="column.field == 'reportCd'"
                               :key="index"
                               :title="column.title"
                               :field="column.field"
                               :hidden="column.hidden"
                               :locked="column.locked"
                               :editable="column.editable"
                               :width="column.width"
                               :format="column.format"
                               :values="getReport"
                               :editor=filterChangeReportCD>
            </kendo-grid-column>
            <!-- mod 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end -->
            <kendo-grid-column v-else
                               :key="index"
                               :title="column.title"
                               :field="column.field"
                               :hidden="column.hidden"
                               :locked="column.locked"
                               :editable="column.editable"
                               :width="column.width"
                               :format="column.format"
                               :values="column.values">
            </kendo-grid-column>
          </template>
        </kendo-grid>
      </kendo-grid-toolbar>
      <div id="grid-footer">
        <v-ons-row width="100%" v-show="!isSortMode" >
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
  </div>
</template>

<script>
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import {ApiHelper} from "@/apis/AxiosHelper";
import {mapActions, mapGetters, mapMutations} from "vuex";
import {EventBus} from "@/eventBus";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
import $ from "jquery";
// add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
export default {
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
  components: {},
  data() {
    return {
      mstFunctionReportList: [],
      sysReportSettingList: [],
      sysReportList: [],
      reportCategory: [],
      dataGrouping: [],
      isSortMode: false,
      columns: [
        {
          field: "code",
          title: "code",
          hidden: false,
          locked: false,
          editable: () => true,
          values: null,
        },
      ],
      kendoValidatorSetup: {
        rules: {},
        messages: {},
      },
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      condition: {
        recordName: "",
        includeDeleted: false
      },
      scrollPosition: {
        top: 0,
        left: 0
      },
      //自画面の名称
      selfScreenName: "",
      lastScrollTop: 0,
      lastScrollLeft: 0,
      // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
      functionCdGrouping: [],
      // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
      androidFlg: false,
      iosFlg: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
    }
  },
  async created() {
    this.setLoadingScreenVisible(true);
    // add マスタ一覧 1･施設切替を可能とする 王 start
    await ApiHelper.get(
      `/master_maintenance/${'mst_function_report'}/data/${this.getFacilitySwitch}`
    ).then(response => {
      this.mstFunctionReportList = response.data.localDataSource.data
    });
    // add マスタ一覧 1･施設切替を可能とする 王 end
    this.setCondition(this.condition);
    // mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 start
    // await ApiHelper.get("/sys_report_setting/getSysRepotrSettingAll").then(response => {
    //   this.sysReportSettingList = response.data
    // });
    await ApiHelper.get("/sys_report_setting/getSysRepotrSettingAll", {
      facilityCd: this.getFacilitySwitch
    }).then(response => {
      this.sysReportSettingList = response.data
    });
    // mod 7323 機能帳票マスタの機能名リストに初回リリースに含まれない機能が表示されている 周安寧 end
    // add マスタ一覧 1･施設切替を可能とする 王 start
    //add 6502 6498 5984 定期・日常が分離されていない 吉 start
    await ApiHelper.get(
      `/master_report/data/${this.getFacilitySwitch}/"1"`
    ).then(response => {
      this.sysReportList = response.data
    });
    //add 6502 6498 5984 定期・日常が分離されていない 吉 end
    // add マスタ一覧 1･施設切替を可能とする 王 end
    this.dataCategory();
    // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
    this.functionGrouping();
    // add start #9590
    this.loadGridData();
    // add end #9590
    // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
  },
  watch:{
    windowHeight() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    windowWidth() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    isDispMenu() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    getFontSize() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    columns:function(val){
      this.$nextTick(function(){
        if (val.length > 1)
        this.setLoadingScreenVisible(false);
      });
    }
  },
  computed:{
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      isRecordModified: "isRecordModified",
      getFacilitySwitch: "getFacilitySwitch"
    }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return "font-size-set-" + names[this.getFontSize];
    },
    masterRecords() {
      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    getReportSetting(){
      let temp = [];
      for (const item of this.sysReportSettingList) {
        temp.push({
          "text":item.functionName,
          "value":item.functionCd
        })
      }
      // const columns = this.columnDefinition;
      // if (columns.find(e => e.field === "functionCd") !== undefined) {
      //   columns.find(e => e.field === "functionCd").values = temp;
      //   this.setColumns(columns);
      // }
      return temp
    },
    getReport(){
      let temp = [];
      for (const item of this.sysReportList) {
        temp.push({
          "text":item.reportName,
          "value":item.reportCd
        })
      }
      // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      // // add bug 6410 修正 吉 start
      // temp.push({
      //   "text": "治療経過表（自動選択）",
      //   "value": '-3'
      // })
      // temp.push({
      //   "text": "治療経過表（手書き：自動選択）",
      //   "value": '-4'
      // })
      // // add bug 6410 修正 吉 end
      // //add 6498 装置帳票：点検結果が機能帳票で出力できない 吉 start
      // temp.push({
      //   "text": "日常点検記録簿",
      //   "value": '-5'
      // })
      // temp.push({
      //   "text": "定期点検・交換部品記録簿",
      //   "value": '-6'
      // })
      // //add 6498 装置帳票：点検結果が機能帳票で出力できない 吉 end
      // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      // const columns = this.columnDefinition;
      // if (columns.find(e => e.field === "reportCd") !== undefined) {
      //   columns.find(e => e.field === "reportCd").values = temp;
      //   this.setColumns(columns);
      // }
      return temp
    },
    isChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        this.kendoValidator !== undefined &&
        data !== undefined &&
        (this.isRecordModified || !this.kendoValidator.validate())
      );
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  methods: {
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "findColumnInfo",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      "setComparisonRecordModel",
      "findRecordListByFacilityCdWithSql",
      "updateIndCondInfo",
      // "setColumns"
    ]),
    // add start #9590
    ...mapMutations("master-maintenance", ["setColumns"]),
    // add end #9590
    ...mapActions("master-maintenance", {
      facilityList: "facilityList"
    }),
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible"
    }),
    onSave(ev){
      this.editingFlg = false;
      //所有患者なしの場合
      if (ev.values.isPersonal && ev.values.isPersonal=="0") {
        ev.model.patId=""
      }
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      ev.sender.refresh();
      if (ev.model.operation === 1) {
        ev.model.edited = true;
      }
      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
    },
    modifyEditStart(e){
      // del 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
      // let temp = [];

      // for (const argument of this.dataGrouping) {
      //   if (argument.cd === e.model.functionCd){
      //     // add bug 6410 修正 chen start
      //     if (e.model.functionCd === "01501" || e.model.functionCd === "00401" ||
      //       e.model.functionCd === "00701" || e.model.functionCd === "00601"){
      //       let obj = {
      //         "text": "治療経過表（自動選択）",
      //         "value": '-3'
      //       }
      //       temp.push(obj);

      //       obj = {
      //         "text": "治療経過表（手書き：自動選択）",
      //         "value": '-4'
      //       }
      //       temp.push(obj)
      //     }
      //     //add 6498 装置帳票：点検結果が機能帳票で出力できない 吉 start
      //     if (e.model.functionCd === "03301"){
      //       let obj = {
      //         "text": "定期点検（記録簿・交換部品記録簿）",
      //         "value": '-6'
      //       }
      //       temp.push(obj);
      //     }
      //     if (e.model.functionCd === "03401"){
      //       let obj = {
      //         "text": "日常点検記録簿",
      //         "value": '-5'
      //       }
      //       temp.push(obj);
      //     }
      //     //add 6498 装置帳票：点検結果が機能帳票で出力できない 吉 end
      //     // add bug 6410 修正 chen end
      //     for (let i = 0; i < argument.list.length; i++) {
      //       for (let j = 0; j < this.sysReportList.length; j++) {
      //         if (argument.list[i] === this.sysReportList[j].reportCd){
      //           let obj = {
      //             "text": this.sysReportList[j].reportName,
      //             "value": argument.list[i]
      //           }
      //           temp.push(obj)
      //         }
      //       }
      //     }
      //   }
      // }
      // e.sender.columns[5].values = temp;
      // del 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      this.editStart(e);
    },
    // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
    filterChangefunctionCd(container, data) {
      let dataSource = [];
      let selectedReport=null;
      if(data.model.functionCd){
        selectedReport=data.values.find(el=> el.value==data.model.functionCd);
      }
      dataSource = this.modifyEditFunctionCD((data.model.reportCd), selectedReport);
      let index = dataSource.findIndex(el => el.value == data.model.functionCd);
      const that = this;
      // #11327 機能帳票マスタで間違った選択をすると目的の設定が不可能となる linjunfeng start
      // $(`<input name="${data.field}" required  class="k-input k-textbox k-valid" validationMessage="機能名は必須入力です。" />`)
      $(`<input name="${data.field}" class="k-input k-textbox k-valid" />`)
      // #11327 機能帳票マスタで間違った選択をすると目的の設定が不可能となる linjunfeng end
          .appendTo(container)
          .kendoDropDownList({
            dataSource: dataSource,
            dataTextField: "text",
            dataValueField: "value",
            valuePrimitive: true,
            index: index,
            select(e) {
              // マスタ名称を取得
              let mstName = e.dataItem["value"];
              // マスタ名称fieldを強制変更 ※セルの変更と見做されkendo-gridのsaveが発火するので注意
              data.model.set(data.field, mstName);
              that.edit({ editRecord: data.model, isSortMode: that.isSortMode });
              e.sender.refresh();
              // 状態に合わせて背景色を変更
              that.editBackgroundColor();
            }
          })
          // #8745 は必須入力です。追加 林峻峰 start
          // del #11327 機能帳票マスタで間違った選択をすると目的の設定が不可能となる linjunfeng start
          // }).blur((event)=>{
          //   if (!event.target.value) {
          //     const width = document.getElementsByClassName('k-textbox')[0].clientWidth;
          //     $('.k-textbox').after(`<div class="k-widget k-tooltip k-tooltip-validation k-invalid-msg" style="width: ${width}px" ><span class="k-icon k-i-warning"> </span>機能名は必須入力です。<div class="k-callout k-callout-n"></div></div>`)
          //     document.getElementsByClassName('k-textbox')[0].style.border = '1px solid red';
          //   } 
          // });
          // del #11327 機能帳票マスタで間違った選択をすると目的の設定が不可能となる linjunfeng end
          // #8745 は必須入力です。追加 林峻峰 end
    },
    filterChangeReportCD(container, data) {
      let dataSource = [];
      //mod #6927 修正：本行で選択されている帳票を表示することはできません yumingyang start
      // dataSource = this.modifyEditReportCD(data.model.functionCd);
      // //add #6927 修正：本行で選択されている帳票を表示することはできません yumingyang start
      // dataSource.unshift(data.values.find(el=> el.value==data.model.reportCd));
      // //add #6927 修正：本行で選択されている帳票を表示することはできません yumingyang end
      let selectedReport=null;
      if(data.model.reportCd){
        selectedReport=data.values.find(el=> el.value==data.model.reportCd);
      }
      dataSource = this.modifyEditReportCD(data.model.functionCd,selectedReport);
      //mod #6927 修正：本行で選択されている帳票を表示することはできません yumingyang end
      let index = dataSource.findIndex(el => el.value == data.model.reportCd);
      const that = this;
      // #11327 機能帳票マスタで間違った選択をすると目的の設定が不可能となる linjunfeng start
      // $(`<input name="${data.field}" required  class="k-input k-textbox k-valid" validationMessage="帳票名は必須入力です。" />`)
      $(`<input name="${data.field}" class="k-input k-textbox k-valid" />`)
      // #11327 機能帳票マスタで間違った選択をすると目的の設定が不可能となる linjunfeng end
        .appendTo(container)
        .kendoDropDownList({
          dataSource: dataSource,
          dataTextField: "text",
          dataValueField: "value",
          valuePrimitive: true,
          index: index,
          filter: "contains",
          select(e) {
            // マスタ名称を取得
            let mstName = e.dataItem["value"];
            // マスタ名称fieldを強制変更 ※セルの変更と見做されkendo-gridのsaveが発火するので注意
            data.model.set(data.field, mstName);
            that.edit({ editRecord: data.model, isSortMode: that.isSortMode });
            e.sender.refresh();
            // 状態に合わせて背景色を変更
            that.editBackgroundColor();
          }
        })  
        // #8745 は必須入力です。追加 林峻峰 start  
        // del #11327 機能帳票マスタで間違った選択をすると目的の設定が不可能となる linjunfeng start
        // }).blur((event)=>{
        //   if (!event.target.value) {
        //     const width = document.getElementsByClassName('k-textbox')[0].clientWidth;
        //     $('.k-textbox').after(`<div class="k-widget k-tooltip k-tooltip-validation k-invalid-msg" style="width: ${width}px" ><span class="k-icon k-i-warning"> </span>帳票名は必須入力です。<div class="k-callout k-callout-n"></div></div>`)
        //     document.getElementsByClassName('k-textbox')[0].style.border = '1px solid red';
        //   } 
        // })
        // del #11327 機能帳票マスタで間違った選択をすると目的の設定が不可能となる linjunfeng end
        // #8745 は必須入力です。追加 林峻峰 end
    },
    modifyEditReportCD(functionCd,selectedReport){
      let temp = [];
      let list = []
      // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      // if (functionCd === "01501" || functionCd === "00401" ||
      //    functionCd === "00701" || functionCd === "00601"){
      //   let obj = {
      //     "text": "治療経過表（自動選択）",
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen start
      //     // "value": '-3'
      //     "value": -3
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen end
      //   }
      //   temp.push(obj);
      //
      //   obj = {
      //     "text": "治療経過表（手書き：自動選択）",
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen start
      //     // "value": '-4'
      //     "value": -4
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen end
      //   }
      //   temp.push(obj)
      // }
      // if (functionCd === "03301"){
      //   let obj = {
      //     "text": "定期点検（記録簿・交換部品記録簿）",
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen start
      //     // "value": '-6'
      //     "value": -6
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen end
      //   }
      //   temp.push(obj);
      // }
      // if (functionCd === "03401"){
      //   let obj = {
      //     "text": "日常点検記録簿",
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen start
      //     // "value": '-5'
      //     "value": -5
      //     // mod #6927「重複チェックがされていない」について、対応する。 dengshen end
      //   }
      //   temp.push(obj);
      // }
      // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      if (functionCd === null || functionCd === ""){
          for (const item of this.sysReportList) {
          temp.push({
            "text":item.reportName,
            "value":item.reportCd
          })
        }
        return temp
      }
      list = this.dataGrouping.filter(item => item.cd === functionCd)
      if (list !== undefined && list.length > 0) {
        for (let i = 0; i < list[0].list.length; i++) {
          for (let j = 0; j < this.sysReportList.length; j++) {
            if (list[0].list[i] === this.sysReportList[j].reportCd){
              let obj = {
                "text": this.sysReportList[j].reportName,
                "value": list[0].list[i]
              }
            temp.push(obj)
          }
        }
        //mod #6927 修正：本行で選択されている帳票を表示することはできません yumingyang start
        if(selectedReport&&list[0].list[i] === selectedReport.value){
          temp.push(selectedReport)
        }
        //mod #6927 修正：本行で選択されている帳票を表示することはできません yumingyang end
		    // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        for (let indexTemp = 0; indexTemp < temp.length; indexTemp++){
          if(temp[indexTemp].value === -3){
            if (functionCd != '00401' && functionCd != '00601' && functionCd != '00701'){
              temp.splice(indexTemp, 1);
            }
          }
          else if(temp[indexTemp].value === -4){
            if (functionCd != '00401' && functionCd != '00601' && functionCd != '00701'){
              temp.splice(indexTemp, 1);
            }
          }
          else if(temp[indexTemp].value === -5){
            if (functionCd != '03401'){
              temp.splice(indexTemp, 1);
            }
          }
          else if(temp[indexTemp].value === -6){
            if (functionCd != '03301'){
              temp.splice(indexTemp, 1);
            }
          }
            // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
            else if (temp[indexTemp].value === -7) {
              if (functionCd != '03201') {
                temp.splice(indexTemp, 1);
              }
            }
            // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
        }
		    // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      }
      }
      // add #6927「重複チェックがされていない」について、対応する。 dengshen start
      for (let indexRecord = 0; indexRecord < this.getFilteredMasterRecordList.data.length; indexRecord++){
        if (this.getFilteredMasterRecordList.data[indexRecord].functionCd === functionCd) {
          for (let indexTemp = 0; indexTemp < temp.length; indexTemp++){
            if (temp[indexTemp].value === this.getFilteredMasterRecordList.data[indexRecord].reportCd){
              temp.splice(indexTemp, 1);
            }
          }
        }
      }
      // add #6927「重複チェックがされていない」について、対応する。 dengshen end
      return temp;
    },
    modifyEditFunctionCD(reportCd, selectedReport){
      let temp = [];
      let list = []
      // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      // if (reportCd === -3 || reportCd === -4) {
      //   let obj1 = {
      //     "text": "チェックリスト",
      //     "value": '01501'
      //   }
      //   temp.push(obj1);
      //   let obj2 = {
      //     "text": "患者経過総合ビューア",
      //     "value": '00401'
      //   }
      //   temp.push(obj2);
      //   let obj3 = {
      //     "text": "患者情報",
      //     "value": '00701'
      //   }
      //   temp.push(obj3);
      //   let obj4 = {
      //     "text": "治療記録",
      //     "value": '00601'
      //   }
      //   temp.push(obj4);
      //
      // }
      // if (reportCd === -6 ) {
      //   let obj = {
      //     "text": "定期点検",
      //     "value": '03301'
      //   }
      //   temp.push(obj);
      // }
      // if (reportCd === -5 ) {
      //   let obj = {
      //     "text": "日常点検",
      //     "value": '03401'
      //   }
      //   temp.push(obj);
      // }
      // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      if (reportCd === null || reportCd === 0) {
        for (const item of this.sysReportSettingList) {
          temp.push({
            "text":item.functionName,
            "value":item.functionCd
          })
        }
        return temp;
      }
      list = this.functionCdGrouping.filter(item => item.cd === reportCd)
      if (list !== undefined && list.length > 0) {
        for (let i = 0; i < list[0].list.length; i++) {
          for (let j = 0; j < this.sysReportSettingList.length; j++) {
            if (list[0].list[i] === this.sysReportSettingList[j].functionCd){
              let obj = {
                "text": this.sysReportSettingList[j].functionName,
                "value": list[0].list[i]
              }
              temp.push(obj)
            }
          }
          if(selectedReport&&list[0].list[i] === selectedReport.value){
          temp.push(selectedReport)
        }
        }
        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        let temp1 = [];
        temp.forEach (t => {
          if(reportCd === -3){
            if (t.value === '00401' || t.value === '00601' || t.value === '00701'){
              temp1.push(t);
            }
          }
          else if(reportCd === -4){
            if (t.value === '00401' || t.value === '00601' || t.value === '00701'){
              temp1.push(t);
            }
          }
          else if(reportCd === -5){
            if (t.value === '03401'){
              temp1.push(t);
            }
          }
          else if(reportCd === -6){
            if (t.value === '03301'){
              temp1.push(t);
            }
          }
          // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
          else if (reportCd === -7) {
            if (t.value === '03201') {
              temp1.push(t);
            }
          }
          // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
          else {
            temp1.push(t);
          }
        });
        temp = temp1;
        // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      }
      // add #6927「重複チェックがされていない」について、対応する。 dengshen start
      for (let indexRecord = 0; indexRecord < this.getFilteredMasterRecordList.data.length; indexRecord++){
        if (this.getFilteredMasterRecordList.data[indexRecord].reportCd === reportCd) {
          for (let indexTemp = 0; indexTemp < temp.length; indexTemp++){
            if (temp[indexTemp].value === this.getFilteredMasterRecordList.data[indexRecord].functionCd){
              temp.splice(indexTemp, 1);
            }
          }
        }
      }
      // add #6927「重複チェックがされていない」について、対応する。 dengshen end
      return temp;
    },
    // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
    loadGridData() {
      // delete start #9590
      // this.setCondition(this.condition);
      // delete end #9590
      this.findList();
    },
    dataCategory(){
      for (const item of this.sysReportSettingList) {
        let printReportClass = JSON.parse(item.printReportClass);
        let temp = [];
        // mod 8569 【IES起票】【機能帳票マスタ】機能名が検査結果の時、帳票種別が紹介状の設定問題 zhou start
        //let classList = null;
        let classList = [];
        // mod 8569 【IES起票】【機能帳票マスタ】機能名が検査結果の時、帳票種別が紹介状の設定問題 zhou start
        // if (printReportClass.length > 1){
        //   classList = printReportClass[0].report_class.split(',').concat(printReportClass[1].report_class.split(','))
        // } else {
        //   classList = printReportClass[0].report_class.split(',')
        // }
        for(let i = 0; i < printReportClass.length; i ++){
          classList = classList.concat(printReportClass[i].report_class.split(','));
        }
        // mod 8569 【IES起票】【機能帳票マスタ】機能名が検査結果の時、帳票種別が紹介状の設定問題 zhou end
        for (let i = 0; i < classList.length; i++) {
          classList[i] = parseInt(classList[i])
        }
        classList = classList.sort(function(a, b){return a - b});
        let finClassList = [classList[0]];
        for (let i = 1, len = classList.length; i < len; i++) {
          if (classList[i] !== classList[i - 1]) {
            finClassList.push(classList[i]);
          }
        }
        for (let i = 0; i < finClassList.length; i++) {
          for (let j = 0; j < this.sysReportList.length; j++) {
            if (finClassList[i] === this.sysReportList[j].reportClass){
              temp.push(this.sysReportList[j].reportCd)
            }
          }
        }
        let obj = {
          cd: item.functionCd,
          list: temp
        }
        this.dataGrouping.push(obj)
      }
    },
    // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 start
    functionGrouping(){
      for (let i = 0; i < this.sysReportList.length; i++) {
        let temp = [];
        for (const item of this.sysReportSettingList) {
          let printReportClass = JSON.parse(item.printReportClass);
          let classList = null;
          if (printReportClass.length > 1){
            classList = printReportClass[0].report_class.split(',').concat(printReportClass[1].report_class.split(','))
          } else {
            classList = printReportClass[0].report_class.split(',')
          }
          if (classList.includes(this.sysReportList[i].reportClass.toString())) {
            temp.push(item.functionCd)
          }
        }
        let obj = {
          cd: this.sysReportList[i].reportCd,
          list: temp
        }
        this.functionCdGrouping.push(obj)
      }
    },
    // add 6379 【機能帳票マスタ】プルダウンメニューの選択肢、動作の不正 周安寧 end
    findList() {
      // apiをコールして値を取得
      // add マスタ一覧 1･施設切替を可能とする 王
      // this.findRecordListByFacilityCdWithSql(this.facilityCd)
      this.findRecordListByFacilityCdWithSql(this.getFacilitySwitch)
        .then(response => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          if (response.data.columns.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000001].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message:
                // add 全マスタメッセージ調整 王 start
                // "マスタ定義にカラム情報が登録されていません。<BR>カラム情報を登録してください。",
                DIALOG_MESSAGES[12000001].message,
                // add 全マスタメッセージ調整 王 end
              callback: () => {
                this.cancel();
              }
            });
          }
          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach(column => {
            // 初期表示時の編集可否を退避
            column.originalEditable = column.editable;
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
          });
          this.columns = toFunction;
          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            column.width = this.columnWidth + "em";
            if (column.field === "machineRecordMessage")column.width = "20em";
            if (column.field === "dispFlg")column.width = "20em";
            // add 削除の欄が広い 王 start
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // if (column.field === "isDisp")column.width = "8em";
            if (column.field === "isDisp")column.width = "9em";
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // add 削除の欄が広い 王 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && column.dataType === "string" && column.field === "name") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width * 15
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
          });
          // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          this.columns.unshift({
            title: " ",
            field: "dummy",
            hidden: false,
            locked: true,
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });
          // add #9590 start
          let repArr = [];
          for (const item of this.sysReportSettingList) {
            repArr.push({
              "text": item.functionName,
              "value": item.functionCd
            })
          }
          let temp = [];
          for (const item of this.sysReportList) {
            temp.push({
              "text": item.reportName,
              "value": item.reportCd
            })
          }
          // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
          // temp.push({
          //   "text": "治療経過表（自動選択）",
          //   "value": '-3'
          // }, {
          //   "text": "治療経過表（手書き：自動選択）",
          //   "value": '-4'
          // }
          // , {
          //   "text": "日常点検記録簿",
          //   "value": '-5'
          // }, {
          //   "text": "定期点検・交換部品記録簿",
          //   "value": '-6'
          // }
          // );
          // del #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
          this.columns.forEach((column) => {
            if (column.field === "functionCd") {
              column.values = repArr;
            } else if (column.field === "reportCd") {
              column.values = temp;
            }
          });
          this.setColumns(this.columns);
          // add #9590 end
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            /* add スクロールの位置を維持 楊 start */
            document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop = this.lastScrollTop;
            document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft = this.lastScrollLeft;
            setTimeout(() => {
                this.lastScrollTop = 0;
                this.lastScrollLeft = 0;
              }, 1000);
            /* add スクロールの位置を維持 楊 end */
          });
          // 初期データ内容を保存
          this.setComparisonRecordModel();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstFunctionReportMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000003].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message:
                // add 全マスタメッセージ調整 王 start
                // message: "指定されたマスタが見つかりません。"
                DIALOG_MESSAGES[12000003].message
                // add 全マスタメッセージ調整 王 end
            });
          }
        })
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }
      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
      Object.keys(fields).forEach(k => {
        // バリデーションで必須が定義されているかどうか
        const validation = fields[k].validation;
        const isRequired =
          typeof validation !== "undefined" && validation.required;
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          d[k] = "";
        } else if (fields[k].type === "number") {
          if (isRequired) {
            d[k] = 0;
          } else {
            d[k] = null;
          }
        } else if (fields[k].type === "date") {
          if (isRequired) {
            d[k] = new Date();
          } else {
            d[k] = null;
          }
        } else {
          d[k] = null;
        }
        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
      });
      this.lastScrollTop = this.$refs.grid.$el.lastChild.scrollHeight;
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      this.editBackgroundColor();
    },
    async saveRecord() {
      this.setLoadingScreenVisible(true);
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        this.setLoadingScreenVisible(false);
        // 共通ローダー：表示終了
        return;
      }
      /* add スクロール位置を保存 楊  start */
      this.lastScrollTop = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop;
      this.lastScrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft;
      /* add スクロール位置を保存 楊 end */
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        (r) => !(r.operation === 1 && !r.edited)
      );
      this.setMasterRecordList(records);
      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();
      let message = "";
      // add 全マスタメッセージ調整 王 start
      if (validateMessage.length !== 0) {
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = DIALOG_MESSAGES[12000005].message + validateMessage;
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message + DIALOG_MESSAGES[12000006].message + validateComboMessage;
      }
      // add 全マスタメッセージ調整 王 end
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000005].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        // add redmine 10_障害一覧.No42 帳票名未入力メッセージ 宋qy start
        this.setLoadingScreenVisible(false);
        // add redmine 10_障害一覧.No42 帳票名未入力メッセージ 宋qy end
        return;
      }
      // apiをコールして値を保存
      // add マスタ一覧 1･施設切替を可能とする 王
      // await this.updateRecordList(this.getUpdateRecordList)
      await this.updateRecordListByFacilityCd({facilityCd: this.getFacilitySwitch, request: this.getUpdateRecordList})
        .then(response => {
          //共通ローダー：表示終了
          this.updateResponse = response.data;
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            title: DIALOG_MESSAGES[12000004].title,
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            message:
              // add 全マスタメッセージ調整 王 start
              // "マスタ更新が完了しました。"
              DIALOG_MESSAGES[12000004].message
              // add 全マスタメッセージ調整 王 end

          });
          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstFunctionReportMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            //共通ローダー：表示終了
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        });
      this.setLoadingScreenVisible(false);
    },
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
  },
  // add 性能改善メモリ不足 shan end
}
</script>

<style scoped>
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
#grid-footer {
  margin: 0;
  padding: 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.k-grid-toolbar {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style >>> .k-grid-header-locked > table {
  border-right-width: 0px;
}
.kendo-grid-toolbar-style >>> .k-grid-header-locked {
  border-right: 1px solid var(--ntss-list-border-color) !important;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  z-index: 1;
  box-shadow: 1px 0px 0px 0px var(--ntss-border-color) !important;
}
/* #8745 は必須入力です。追加 林峻峰 start */
.kendo-grid-toolbar-style >>> .k-edit-cell{
  position: relative;
  overflow: inherit;
}
.kendo-grid-toolbar-style
  >>> .k-grid
  tr:nth-last-child(1)
  .k-tooltip.k-tooltip-validation {
  bottom: 38px;
}
.kendo-grid-toolbar-style
  >>> .k-grid
  tr:nth-last-child(1)
  .k-tooltip.k-tooltip-validation
  .k-callout {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}
.kendo-grid-toolbar-style >>> .k-dropdown > .k-tooltip-validation{
  display: none !important;
}
/* #8745 は必須入力です。追加 林峻峰 end */
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
</style>