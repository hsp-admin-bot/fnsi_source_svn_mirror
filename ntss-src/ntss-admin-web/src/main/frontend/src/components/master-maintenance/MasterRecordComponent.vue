/**
 * マスタメンテナンスデータページ  MainContent
 */
<template>
  <div class='main-content-area master-maintenance-page'>
    <div class='ntss-list' :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style print-grid-style" :style="heightStyles">
        <div id="grid-header" class='header-btn-area right'>
          <!-- mod 画面デザイン 對應 王 start-->
          <!-- <v-ons-button modifier="outline" class="toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord && isAddButton" @click="addRow()">追加</v-ons-button>-->
          <!-- <v-ons-button modifier="outline" v-show="isMstExamItem" class="toolbar-btn" style="float: left; margin-left: 1px;" @click="showRecalculationModal">再計算</v-ons-button>-->
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord && isAddButton" @click="addRow()">追加</v-ons-button>
          <v-ons-button modifier="outline" v-show="isMstExamItem" class="btn3-normal toolbar-btn" style="float: left; margin-left: 1px;" @click="showRecalculationModal">再計算</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <!-- mod 画面デザイン 對應 王 end-->
          <!-- del マスタ一覧 1･施設切替を可能とする 孔s start -->
          <!-- <kendo-dropdownlist ref="dropDownList" v-if="isMasterUser"
              v-model="facilitylistValue"
              :data-source="facilities"
              :data-text-field="'facilityName'"
              :data-value-field="'facilityCd'"
              :filter="'contains'"
              @open="onOpenFacility"
              @change="onChangeFacility"
              style="width: 13em;">
          </kendo-dropdownlist> -->
          <!-- del マスタ一覧 1･施設切替を可能とする 孔s end -->
          <!-- mod 画面デザイン 對應 王 start-->
          <!-- <v-ons-button modifier="outline" class="toolbar-btn csv-btn" style="margin-right: 10px;" v-show="!isSortMode && isAllowAddRecord" @click="importCsv()">CSV取込</v-ons-button>-->
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn csv-btn" style="margin-right: 10px;" v-show="!isSortMode && isAllowAddRecord && isCsvButton" @click="importCsv()">CSV取込</v-ons-button>
          <!-- mod 画面デザイン 對應 王 end-->
          <v-ons-button class="btn3-normal toolbar-btn" v-show="!isSortMode && isAllowSort && isToRankButton" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button class="btn3-normal toolbar-btn" v-show="isSortMode && isAllowSort" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <kendo-grid id="grid" ref="grid" :class="fontSizeSet"
            :data-source="dataSourceItems"
            :editable="true"
            :selectable="true"
            :reorderable="false"
            :height=kendoGridHeight
            :scrollable="true"
            :beforeEdit=modifyEditStart
            :edit=addInputAssist
            :cellClose=editEnd
            @save="onEditSave"
            @databound="onDataBoundKendoGrid">
            <template v-for="(column, index) in columns" >
              <kendo-grid-column v-if="column.field === '$modalType'"
                :key="index"
                :title="column.title == null || column.title == '' ? ' ' : column.title"
                :field="column.field"
                :hidden="column.hidden"
                :attributes="{ class: 'btn3-kendo-normal' }"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '詳細', click: showMasterEditModal }">
              </kendo-grid-column>
              <kendo-grid-column
                v-else-if="column.title === '在宅'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="! facilityHemoDialysis"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
              />
              <kendo-grid-column v-else-if="column.dataType === 'date'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="eachModelCalendar">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.field === 'leftDataIndex' || column.field === 'rightDataIndex'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="comboEditor">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.dataType === 'color'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :template="column.colorTemplate"
                :editor="colorEditor">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.dataType === 'textarea'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="textareaEditor">
              </kendo-grid-column>
              <!-- #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start -->
              <!-- <kendo-grid-column v-else-if="column.dataType === 'number'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :round="false"
                :restrictDecimals="true"
                @editor="numericEditor">
              </kendo-grid-column> -->
              <kendo-grid-column v-else-if="column.dataType === 'number'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :round="false"
                :restrictDecimals="true"
                @template="(dataItem) => formatValue(dataItem, column)"
                @editor="numericEditor">
              </kendo-grid-column>
              <!-- #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end -->
              <!-- redmine 5344 日常点検を選択した場合も内容3が登録できる 宋qy start -->
              <kendo-grid-column v-else-if="column.field === 'mainteContent3'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :template="column.textTemplate"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="stringEditor">
              </kendo-grid-column>
              <!-- redmine 5344 日常点検を選択した場合も内容3が登録できる 宋qy end -->
              <kendo-grid-column v-else
                :key="index"
                :title="column.title"
                :field="column.field"
                :template="column.textTemplate"
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
        <!-- add スクロールの位置を維持 楊 start -->
        <!-- <v-ons-row width="100%"  v-show="!isSortMode" > -->
        <!-- mod #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue start -->
        <!-- <v-ons-row width="100%" :style="{ visibility:this.isSortMode ?  'visible' : 'visible' }" > -->
        <v-ons-row width="100%" :style="{ visibility:this.isSortMode ?  'hidden' : 'visible' }" >
        <!-- mod #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue end -->
        <!-- add スクロールの位置を維持 楊 end -->
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
<!--            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord()">保存</v-ons-button>-->
            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecordPopUpModel()">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    <master-csv
      :popoverVisible="masterCsvVisible"
      :popoverTarget="masterCsvTarget"
      @popover-close="prehideCsvPopover"
    />
      <!-- 指示者設定モーダル -->
      <v-ons-modal v-if="isModalVisible" :visible="isModalVisible" :class="modalFontSize">
        <ind-user-setting @hide-modal="isModalVisible = false" :title="title"/>
      </v-ons-modal>

    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters, mapMutations } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus";
import moment from "moment";
import $ from "jquery";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import Vue from "vue";
import { ApiHelper } from "@/apis/AxiosHelper";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import { mstVitalGraphDefine } from "@/constants/mstVitalGraph";
import { mstPatViewerLayout } from "@/constants/mstPatViewerLayout";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import { MASTER_DELETE_DISPLAY } from "@/constants/TreatmentRecord";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {
  sendRequestFindRecordListByFacilityCd,
} from "@/apis/master-maintenance";
import {
  DEFAULT_PROCEDURE,
  DEFAULT_MEDICATE_TIMING,
} from "@/constants/facilitySetting";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { MST_DEFAULT_VALUE } from "@/constants/masterDefineDetail";
import { MainteClass } from "@/constants/mainteConstants";
import { SUB_CATEGORY_NO } from "@/constants/mstPatCalendarLayoutDefine";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { messageFormat } from "@/functions/common/MessageFormat";
import indUserSetting from "@/components/pat-info/ind-user-setting/IndUserSettingModal";
import BigNumber from "bignumber.js";
import { deleteDataProcessing } from "@/functions/mst/MasterMaintenanceFunctions";

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
  components: {
    "master-csv": MasterCsvComponent,
    "ind-user-setting": indUserSetting,
  },
  data() {
    return {
      // add 9664 by kangjie 20231208 start
      title:"治療方法を更新します",
      isModalVisible: false,
      // add 9664 by kangjie 20231208 end
      recordList: [],
      // 初期状態で1列がないとその後の表示が行われないため初期列を定義
      columns: [
        {
          field: "code",
          title: "code",
          hidden: false,
          locked: false,
          editable: () => true,
          values: null
        }
      ],
      condition: {
        recordName: "",
        includeDeleted: false
      },
      updateResponse: {
        isSuccess: false,
        errorMessage: ""
      },
      isSortMode: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      mstSynchroApiParams: {
        mstTable: "mst_m_notice",
        deviceEdgeNo: -1,
        deviceName: "すべて"
      },
      mstHolidayNkkData: [],
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      //自画面の名称
      selfScreenName: "",
      masterCsvVisible: false,
      masterCsvTarget: null,
      // 選択中の施設コード
      facilitylistValue: "",
      // 選択中施設の在宅機能有無
      facilityHemoDialysis: false,
      //変更前の施設
      prevFacilityCd: "",
      waterSurveyPointValueFalg: false,
      mstMonitorGraphItem: [],
      mstMonitorInitial: [],
      errorMessage: "",
      errorNameMstAlerm: [],
      oldLocalDataSource: [],

      resizeObserver: null,
      dataSourceItems: {},
      // add start #9301
      defaultMedicateTimingDataCd: null,
      defaultProcedureCd: null,
      // add end #9301
      // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
      sysMonitorItemList: [],
      // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
    };
  },
  computed: {
    // add 9664 by kangjie 20231211 start
    ...mapGetters("pat-info",
      ["isIndUserSetting",
      "indUserId"]),
    modalFontSize() {
      const names = ["small", "medium", "large", "x-large"];
      return "font-size-set-" + names[this.getFontSize];
    },
    // add 9664 by kangjie 20231211 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", {
      getAdvancedSettings :"getAdvancedSettings",
      systemUseSetting: "getSystemUseSetting"
    }),
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる start
    ...mapGetters("master-maintenance", {
      getScrollTopPosition: "getScrollTopPosition",
      getScrollLeftPosition: "getScrollLeftPosition"
    }),
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる end

    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    ...mapGetters("master-maintenance", {
      // add マスタ一覧 1･施設切替を可能とする 孔s start
      getFacilitySwitch: "getFacilitySwitch",
      // add マスタ一覧 1･施設切替を可能とする 孔s end
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      getLogicalMasterName: "getLogicalMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      isRecordModified: "isRecordModified",
      comparisonRecordModel: "getComparisonRecordModel",
      getFacilityList: "getFacilityList"
    }),
    // しばらくは使いませんでした
    // facilities() {
    //   // storeからデータを取得
    //   return this.getFacilityList;
    // },
    isMasterUser: {
      get() {
        return this.getStateUserAccountInfo.userType === 1 ? true : false;
      },
      set() {}
    },
    masterRecords() {
      // storeからデータを取得
      //add FNSI-改修内容テンプレートマスタ、カテゴリマスタにデータがない場合、サブカテゴリマスタのテンプレートとカテゴリ項目に表示されたCDを空白に修正必要 任 start
      this.columns.forEach(column => {
          if(column.field==='categoryCd'&&column.values!==null){
            if(column.values.length===0){
              this.getFilteredMasterRecordList.data.forEach(item => {
                item.categoryCd = null;
              });
            }
          }else if(column.field==='templateCd'&&column.values!==null){
            if(column.values.length===0){
              this.getFilteredMasterRecordList.data.forEach(item => {
                item.templateCd = null;
              });
            }
           }
          // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
          // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
          // if (column.locked && (column.dataType === "string" || column.dataType === "textarea") && column.field === "name") {
          //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width
          // }
          // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
          // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
      })
      if(this.masterPhysicalName == "mst_holiday") {
        if (!this.getFilteredMasterRecordList.data){
          return this.getFilteredMasterRecordList;
        }
        let mstHolidayNkks = this.mstHolidayNkkData.filter(e=>e.class == "0");
        let mstHolidays = this.getFilteredMasterRecordList.data.filter(e=>e.class == "0");
        if (mstHolidayNkks.length> 0 ){
          let strMstHoliday = mstHolidays.map(e=> String(e.year));
          let that = this;
          let strMasterRecord = this.getMasterRecordList.data.map(e=> String(e.year));
          mstHolidayNkks.filter(e=>e.class == "0").forEach( e => {
            if(!strMstHoliday.includes(String(e.year)) && !strMasterRecord.includes(String(e.year))) {
             that.addRow(e.year, e.code);
            }
          })
        }
        let mstHolidayLists =  this.getFilteredMasterRecordList;
        const compare = (a, b) => {
          if(a.year && b.year){
            return a.year - b.year;
          }else{
            return 1;
          }
        }
        mstHolidays.sort(compare);
        mstHolidayLists.data = mstHolidays.filter(e=>e.class == "0");
        return mstHolidayLists;
      } else {
        // add FNSI-改修内容テンプレートマスタ、カテゴリマスタにデータがない場合、サブカテゴリマスタのテンプレートとカテゴリ項目に表示されたCDを空白に修正必要 任 end
        return this.getFilteredMasterRecordList
      }
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isAddButton() {
      let addMasterName = ["sys_medicine","mst_take_medicine","mst_vital_graph"]
      return addMasterName.indexOf(this.masterPhysicalName) < 0 ;
    },
    isToRankButton() {
      let addMasterName = ["mst_holiday"]
      return addMasterName.indexOf(this.masterPhysicalName) < 0 ;
    },
    isCsvButton() {
      let addMasterName = ["mst_holiday", "mst_prescription_set"]
      return addMasterName.indexOf(this.masterPhysicalName) < 0 ;
    },
    isMstExamItem() {
      return this.masterPhysicalName == "mst_exam_item";
    },
    isChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (this.isRecordModified || (this.kendoValidator && !this.kendoValidator.validate()))
      );
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
  },
  watch: {
    // add 9664 by kangjie 20231211 start
    isIndUserSetting() {
      if (this.isIndUserSetting) {
        // execute save
        this.saveRecord();
      }
    },
    // add 9664 by kangjie 20231211 end
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
    },
    masterRecords () {
      this.dataSourceItems = this.generatedGridData();
    }
  },
  methods: {
    // add 9664 by kangjie 20231211 start
    ...mapMutations("pat-info", ["setSelectedPat", "setIsPatInfoVisible", "setIndUserList", "setIsIndUserSetting", "setIndUserId", "setIsPatInfoChaned"]),
    // add 9664 by kangjie 20231211 end
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる start
    ...mapMutations("master-maintenance", ["setScrollTopPosition", "setScrollLeftPosition"]),
    // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる end

    // #8519 【デグレ】編集した項目のバッググラウンドが黄緑にならない 訾浩 start
    editBackgroundColor() {
      this.$nextTick(() => {
        // グリッドが表示されていなかったら処理終了
        const gridHeader = this.$refs.grid.$el.firstChild;
        if (gridHeader.textContent === " ") {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");
        // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
        // 共通定型文マスタ：「保存」ボタン⇒非活性、編集場所のスタイル⇒未編集 林峻峰 start
        //const gridLock = this.$refs.grid.$el.children[1].children[0].children[1];
        // 共通定型文マスタ：「保存」ボタン⇒非活性、編集場所のスタイル⇒未編集 林峻峰 end
        // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
        // グリッドにレコードがなければ処理終了
        if (!this.$refs.grid.$el.lastChild.lastChild.tBodies) {
          return;
        }
        // 固定列、可変列、データソースの取得
        const tbodyc = this.$refs.grid.$el.lastChild.lastChild
          .tBodies[0].children;
        // del #8598 「検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない」について、対応する。 dengshen start
        // let lockTbodyc = this.$refs.grid.$el.children[1].lastChild
        //   .tBodies[0].children;
        // del #8598 「検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない」について、対応する。 dengshen end
        const gridData = this.$refs.grid.dataSource;
        if (this.$refs.grid.$el.children[1].lastChild.tBodies != undefined) {
          // mod #8598 「検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない」について、対応する。 dengshen start
          // lockTbodyc =
          let lockTbodyc =
            // mod #8598 「検査再計算ツールで対象患者と再計算項目の選択ができず計算ができない」について、対応する。 dengshen end
            this.$refs.grid.$el.children[1].lastChild.tBodies[0].children;

          // 列の行数は固定・可変で同一なため可変列の行数を使用
          for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
            const currentTrc = tbodyc[rwCount].children;
            const currentLockTrc = lockTbodyc[rwCount].children;

            // 並び順の色変更
            this.changeSortColor(currentLockTrc);
            // 編集項目の色を変更
            let edited = this.changeEditColor(currentTrc, currentLockTrc);
            // 削除対象を判定
            const deleted = this.isDeleteRow(currentTrc);
            // モーダルからの編集も色を変更する
            if (this.isEdited(gridData._view[rwCount].code)) {
              edited = true;
            }
            // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
            // 共通定型文マスタ：「保存」ボタン⇒非活性、編集場所のスタイル⇒未編集 林峻峰 start
            // if (this.getMasterRecordListOld && this.getMasterRecordListOld[rwCount] && this.getMasterRecordList.data && this.getMasterRecordList.data[rwCount].operation) {
            //   this.getMasterRecordListOld[rwCount].operation = this.getMasterRecordList.data[rwCount].operation
            // }
            // if (this.getMasterRecordListOld && this.getMasterRecordListOld[rwCount]&& this.getMasterRecordList.data &&this.getMasterRecordList.data[rwCount].upDate) {
            //   console.log('delete')
            //   delete this.getMasterRecordList.data[rwCount].upDate
            // }
            // if (this.getMasterRecordListOld && this.getMasterRecordListOld[rwCount]&& this.getMasterRecordList.data && this.getMasterRecordListOld[rwCount].upDate) {
            //   delete this.getMasterRecordListOld[rwCount].upDate
            // }
            // if (this.getMasterRecordListOld&& this.getMasterRecordList.data && this.getMasterRecordList.data[rwCount].$modalType === undefined) {
            //   delete this.getMasterRecordList.data[rwCount].$modalType
            // }
            // if (this.getMasterRecordListOld && this.getMasterRecordList.data && this.getMasterRecordList.data[rwCount] && this.getMasterRecordList.data[rwCount].occupations && this.getMasterRecordListOld[rwCount] && this.getMasterRecordListOld[rwCount].occupations) {
            //   this.getMasterRecordList.data[rwCount].occupations = JSON.stringify(JSON.parse(this.getMasterRecordList.data[rwCount].occupations).sort());
            //   this.getMasterRecordListOld[rwCount].occupations = JSON.stringify(JSON.parse(this.getMasterRecordListOld[rwCount].occupations).sort());
            // }
            // if (this.getMasterRecordListOld && this.getMasterRecordList.data && JSON.stringify(this.getMasterRecordListOld[rwCount]) === JSON.stringify(this.getMasterRecordList.data[rwCount])) {
            //   edited = false;
            //   if (gridLock && gridLock.children && gridLock.children[rwCount] && gridLock.children[rwCount].children && gridLock.children[rwCount].children[3] && gridLock.children[rwCount].children[3].children[0]) {
            //     gridLock.children[rwCount].children[3].children[0].remove();
            //     gridLock.children[rwCount].children[3].setAttribute('class', '');
            //   }
            // }
            // 共通定型文マスタ：「保存」ボタン⇒非活性、編集場所のスタイル⇒未編集 林峻峰 end
            // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc end
            // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
            this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
            // データ参照エラーコンボの背景色を変更
            if (this.masterPhysicalName !== "mst_medicine") {
              this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
            }
          }
        }
      });
    },
    // #8519 【デグレ】編集した項目のバッググラウンドが黄緑にならない 訾浩 end
    ...mapActions("multi-modal", ["showMasterEdit", "showMstExamItemRecManagementModal"]),
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
      "getDeviceEdgeNoList",
      "mstSyncDeviceEdge",
      "findRecordListByFacilityCd"
     ,"updateIndCondInfo",
      "findFacilitySettingInfo",
      "getMasterDeviceEdgeNoListByFacilityCd"
    ]),
    ...mapActions("treatment-record/common", ["sendNextPatInfo",]),
    ...mapActions("master-maintenance", {
      facilityList: "facilityList"
    }),
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    ...mapActions("pat-viewer", ["getMstMedicineIncludeDeleted", "getMstMedicineMixIncludeDeleted", "getMstProcedure", "getMstMedicateTiming"]),
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
    init() {
      if (this.dataSourceItems && typeof this.dataSourceItems.data === 'function') {
        this.dataSourceItems.data([...this.masterRecords.data])
      }
    },
    // add start #9301
    async getDefaultCd () {
      const defaultMedicateTimingData = await this.findFacilitySettingInfo({
        facilityCd: this.getFacilitySwitch,
        settingNo: DEFAULT_MEDICATE_TIMING
      });
      this.defaultMedicateTimingDataCd = defaultMedicateTimingData?.data || null;
      const defaultProcedureData = await this.findFacilitySettingInfo({
        facilityCd: this.getFacilitySwitch,
        settingNo: DEFAULT_PROCEDURE
      });
      this.defaultProcedureCd = defaultProcedureData?.data || null;
    },
    // add end #9301
    // グリッドのデータ再表示
    gridDataRefresh() {
      const grid = this.$refs.grid;
      grid.dataSource = this.generatedGridData();
    },
    generatedGridData() {
      let that = this;
      // eslint-disable-next-line no-undef
      return new kendo.data.DataSource({
        //6661:スクロールバー異常
        // pageSize: 30,
        transport: {
          read: function (e) {
            if (that.masterRecords.data != null)
              e.success(that.masterRecords.data);
          },
        },
        schema: that.masterRecords.schema,
      });
    },
    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
        // 選択した施設を元にベッド一覧の取得
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
          // 選択した施設を元にベッド一覧の取得
          this.findList();
        })
        .catch(error => {
          if (error.response.status === 400) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MasterRecordComponent.vue', 'facilityList', '指定されたマスタが見つかりません。');
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          else{
            getErrorMessage('MasterRecordComponent.vue', 'facilityList', error);
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        });
    },
    onOpenFacility(e) {
      // 変更前の値を取得
      this.prevFacilityCd = e.sender._old;
    },
    // 施設を選択時の動作
    onChangeFacility(e) {
      if(this.prevFacilityCd != e.sender._old) {
        // 選択施設の拡張設定を取得
        var newFacilityAdvancedSettings = {};
        let selectedIndex = e.sender.selectedIndex;
        try {
          if (e.sender.dataSource.options.data[selectedIndex].advancedSettings) {
            newFacilityAdvancedSettings = JSON.parse(e.sender.dataSource.options.data[selectedIndex].advancedSettings);
          }
        } catch(error) {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MasterRecordComponent.vue', 'onChangeFacility' , error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          newFacilityAdvancedSettings = {};
        }

        if (!newFacilityAdvancedSettings.func_advcds) {
          newFacilityAdvancedSettings.func_advcds = [];
        }

        const enableHomeDialysis = newFacilityAdvancedSettings.func_advcds.some(
          setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
        );

        if (this.isChanged){
          // 編集時は未保存確認メッセージを出力する
          const newFacilityCd = e.sender._old;
          e.preventDefault();
          this.$ons.notification.confirm({
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/22 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                // 選択した施設を元に装置一覧の取得
                this.facilitylistValue = newFacilityCd;
                // 選択施設の在宅機能有無を取得
                this.facilityHemoDialysis = enableHomeDialysis;
                this.findList();
              } else {
                // 変更前の施設を設定する
                this.facilitylistValue = this.prevFacilityCd;
              }
            }
          });
        } else {
          // 選択した施設を元に装置一覧の取得
          this.facilitylistValue = e.sender._old;
          // 選択施設の在宅機能有無を取得
          this.facilityHemoDialysis = enableHomeDialysis;
          this.findList();
        }
      }
    },
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-synchro", ["startMstSynchro"]),
    eachModelCalendar(container, data) {
      if (this.androidFlg === true) {
        // Androidの場合は、HTML5のカレンダーを表示
        $(`<input type="date" name="${data.field}" />`).appendTo(container);
      } else {
        let moveOutFlg = false;
        container.mouseenter(() => moveOutFlg = false);
        container.mouseleave(() => moveOutFlg = true);
        // デスクトップ、iOSの場合は、処理で補正したHTML5のカレンダーを表示
        let nowData;
        let hasInitValue = true;
        const editedData = data.model[data.field];
        let nowDtatString;
        if (editedData) {
          nowData = new Date(editedData);
        } else {
          nowData = new Date();
          hasInitValue = false;
        }
        nowDtatString = nowData.getFullYear() + "-" + ('0' + (nowData.getMonth() + 1)).slice(-2) + "-" + ('0' + nowData.getDate()).slice(-2);
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
        if (!editedData) {
          nowDtatString = "";
        }
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end
        $(
          `<span style="position:relative"><input type="date" style="width:8em" id="displayedDummyEditor" class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;"/><span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:absolute;left:75%;top:1px;color: #212529;z-index:9999999" ></span></span>`
        ).appendTo(container);
        // フォーカスアウトで編集データを反映するイベントを発火
        document.getElementById("displayedDummyEditor").addEventListener("blur", function(ev) {
          if (!moveOutFlg) {
            return;
          }

          let resultData;
          const dayData = new Date(ev.target.value);
          // 初期と編集後の値が空欄の場合、更新レコードとして判断しない
          if (ev.target.value === "" && !hasInitValue ) {
            resultData = "";
            nowDtatString = "";
            hasInitValue = true;
          } else {
            resultData = dayData.getFullYear() + "-" + ('0' + (dayData.getMonth() + 1)).slice(-2) + "-" + ('0' + dayData.getDate()).slice(-2);
          }
          // 変更前の値と比較し、同じ値の場合は処理しない。又は、初期値がない場合、必ず処理する。
          if (!hasInitValue || nowDtatString != resultData) {
            document.getElementById("hiddenDateInputEditor").value = resultData;
            // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
            $(document.getElementById("hiddenDateInputEditor")).trigger('change');
          }
        });

        let commonCalenderPicker = new (Vue.extend(commonCalender))();
        commonCalenderPicker.$on("input", value => {
          document.getElementById("hiddenDateInputEditor").value = value;
          // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
          $(document.getElementById("hiddenDateInputEditor")).trigger('change');
        });
        commonCalenderPicker.$mount();
        commonCalenderPicker.setSilently(nowDtatString);
        container.append(commonCalenderPicker.$el);
        //  #5590 2023/05/15 iPadでSafariを使うと、数字に×が被る。修正 張博 start
        const userAgent = window.navigator.userAgent;
        if (userAgent.indexOf("Intel Mac OS") > -1) {
           document.getElementById("displayedDummyEditor").addEventListener("change", (ev) => {
           document.getElementById("hiddenDateInputEditor").value = ev.target.value;
           $(document.getElementById("hiddenDateInputEditor")).trigger('change');
        });
        }else{
          document.getElementById("displayedDummyEditor").addEventListener("change", (ev) => {
              commonCalenderPicker.setSilently(ev.target.value);
        });
        }
        //  #5590 2023/05/15 iPadでSafariを使うと、数字に×が被る。修正 張博 end
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
        // let clear = `<span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:relative;right:65px;bottom:1px;color: #212529;z-index:9999999" ></span>`
        // container.append(clear);
        document.getElementById("clear").addEventListener("mousedown", function(ev) {
          document.getElementById("hiddenDateInputEditor").value = null;
          $(document.getElementById("hiddenDateInputEditor")).trigger('change');
        });
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end
        //  #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 start
        document.getElementById("clear").addEventListener("touchstart", function(ev) {
          document.getElementById("hiddenDateInputEditor").value = null;
          $(document.getElementById("hiddenDateInputEditor")).trigger('change');
        });
        //  #5590 2023/05/12 iPadでSafariを使うと、数字に×が被る。修正 張博 end
      }
    },
    comboEditor(container, data) {
      if(this.masterPhysicalName == "mst_monitor_graph") {
        data.values = this.mstMonitorGraphItem
        // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
        let that = this;
        // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
        $(`<input class="k-textbox" name="${data.field}"/>`)
          .appendTo(container)
          .kendoDropDownList({
            dataSource: data.values,
            dataTextField: "text",
            dataValueField: "value",
            change:function(e){
              const reg = e.sender.filterInput[0].value;
              if (reg === "" || reg === null) {
                data.model[data.field] = data.values[e.sender.selectedIndex].value;
              } else {
                let temp = [];
                data.values.forEach(e => {
                  if (e.text.toString().search(reg) !== -1) {
                    temp.push(e);
                  }
                });
                data.model[data.field] = temp[e.sender.selectedIndex].value;
              }
              // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
              const sysMonitorItemObj = that.sysMonitorItemList.find(item => item.moni_data_no == data.model[data.field]);
              const setData = (key, min ,max) => {
                if (data.model[key] > max) {
                    data.model[key] = max;
                  }
                  if (data.model[key] < min) {
                    data.model[key] = min;
                  }
              };
              if (sysMonitorItemObj) {
                const decimals = sysMonitorItemObj.decimal_figure;
                const min = sysMonitorItemObj.lower /  Math.pow(10, decimals);
                const max = sysMonitorItemObj.upper /  Math.pow(10, decimals);
                if (data.field == "leftDataIndex") {
                  setData('leftGraphLowerLimit', min, max);
                  setData('leftGraphUpperLimit', min, max);
                }
                if (data.field == "rightDataIndex") {
                  setData('rightGraphLowerLimit', min, max);
                  setData('rightGraphUpperLimit', min, max);
                }
              } else {
                const masterField = that.getMasterRecordList.schema.model.fields;
                if (data.field == "leftDataIndex") {
                  setData('leftGraphUpperLimit', masterField['leftGraphLowerLimit'].validation.min, masterField['leftGraphLowerLimit'].validation.max);
                  setData('leftGraphLowerLimit', masterField['leftGraphUpperLimit'].validation.min, masterField['leftGraphUpperLimit'].validation.max);
                }
                if (data.field == "rightDataIndex") {
                  setData('rightGraphLowerLimit', masterField['rightGraphLowerLimit'].validation.min, masterField['rightGraphLowerLimit'].validation.max);
                  setData('rightGraphLowerLimit', masterField['rightGraphLowerLimit'].validation.min, masterField['rightGraphLowerLimit'].validation.max);
                }
              }
              // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
            },
            filter: "contains",
          });
      }
    },
    colorEditor(container, data) {
      // const dummyField = $("<input/>")
      //   .attr("name", data.field)
      //   .css("display", "none")
      //   .appendTo(container);

      // const colorPicker = $("<input/>")
      //   .appendTo(container)
      //   .kendoColorPicker({
      //     value: data.model[data.field],
      //     palette: "basic",
      //     tileSize: {
      //       width: 32,
      //       height: 24
      //     },
      //     change: (e) => {
      //       // コンソールにエラーが出るためにnextTickで遅らせている
      //       this.$nextTick(() => {
      //         dummyField.val(e.value).trigger("change");
      //       });
      //     }
      //   });

      // // パレットを開く
      // colorPicker.data("kendoColorPicker").open();
      const dummyField = $(`<input type = "color" data-bind="value:${data.field}" width: 4em; />`).appendTo(container);
          this.$nextTick(() => {
            dummyField.click();
          });
    },
    /**
     * @description textarea(改行可能なテキストボックス)用のkendo editor
     */
    textareaEditor(container, data) {
      if (this.masterPhysicalName == "mst_mainte_detail" && (!data.model.isCmt || data.model.isCmt == "0")) {
        return;
      }
      $(
        `<textarea name="${data.field}" class="k-valid k-textarea resize-obs-target" style="font-size: 1.0em; width:100%; resize: vertical; max-height: 65vh;"/>`
      ).appendTo(container);
      this.resizeObserver = new ResizeObserver(entries => {
        // テキストエリアのリサイズに応じてkendo-gridをリサイズする
        this.calculateGridWidth();
      });
      this.resizeObserver.observe(document.querySelector('.resize-obs-target'));
    },
    numericEditor(container, options) {
      // ダイアライザマスタ変更  杜 start
      // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
      // const format = options.format.slice(3, options.format.length - 1);
      let format = options.format.slice(3, options.format.length - 1);
      // const decimals = format.slice(1);
      let decimals = format.slice(1);
      // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
      let parameter = { format, decimals, round: false };
      // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 start
      // let strinput= '<input data-bind="value:' + options.field + '"/> ';
      let strinput= '<input id="myInputNumber" style="text-align:right" data-bind="value:' + options.field + '"/> ';
      // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 end
      const masterField = this.getMasterRecordList.schema.model.fields[options.field];
      // 負担率の入力制限不正 (保険マスタ) start
      // mod 治療記録バイタルグラフマスタ 3、サイズ下上限「0-10」 start
      // if (this.masterPhysicalName == "mst_insurance" || this.masterPhysicalName == "mst_medicate_timing") {
      // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
      // if (this.masterPhysicalName == "mst_insurance" || this.masterPhysicalName == "mst_medicate_timing" || this.masterPhysicalName == "mst_vital_graph" || this.masterPhysicalName == "mst_monitor_graph") {
      if (this.masterPhysicalName == "mst_insurance" || this.masterPhysicalName == "mst_medicate_timing" || this.masterPhysicalName == "mst_vital_graph") {
      // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
      // mod 治療記録バイタルグラフマスタ 3、サイズ下上限「0-10」 end
        parameter = { format, decimals, round: false,  min: masterField.validation.min, max: masterField.validation.max};
      // 負担率の入力制限不正 (保険マスタ) end
      // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
      }else if (this.masterPhysicalName == "mst_monitor_graph") {
        const dataIndexObj = {
          leftGraphUpperLimit: {
            dataIndex: options.model.leftDataIndex
          },
          leftGraphLowerLimit: {
            dataIndex: options.model.leftDataIndex
          },
          rightGraphUpperLimit: {
            dataIndex: options.model.rightDataIndex
          },
          rightGraphLowerLimit: {
            dataIndex: options.model.rightDataIndex
          },
        };
        let min = masterField.validation.min;
        let max = masterField.validation.max;
        if (dataIndexObj[options.field]?.dataIndex) {
          const sysMonitorItemObj = this.sysMonitorItemList.find(item => item.moni_data_no == dataIndexObj[options.field].dataIndex);
          if (sysMonitorItemObj) {
            decimals = sysMonitorItemObj.decimal_figure;
            min = sysMonitorItemObj.lower /  Math.pow(10, decimals);
            max = sysMonitorItemObj.upper /  Math.pow(10, decimals);
            format = "n" + decimals;
          }
        }
        parameter = { format, decimals, round: false,  min, max, step: Math.pow(10,-decimals)};
      // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
      }else if (this.masterPhysicalName == "mst_dialyzer") {
        parameter = { format, decimals, round: false, min: masterField.validation.min, max: masterField.validation.max, step :Math.pow(10,-decimals),};
        if (masterField.validation.required ) {
          // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 start
          //strinput = '<input data-bind="value:' + options.field + '"required="true" validationMessage ="'+masterField.validation.validationMessage+'" /> ';
          strinput = '<input id="myInputNumber" style="text-align:right" data-bind="value:' + options.field + '"required="true" validationMessage ="'+masterField.validation.validationMessage+'" /> ';
          // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 end
        }
      }else if (this.masterPhysicalName == "sys_medicine" || this.masterPhysicalName == "mst_medicine_group"){
        if(masterField.validation.maxlength) {
            let maxlength = masterField.validation.maxlength;
            masterField.validation.max = Math.pow(10,maxlength-decimals) - Math.pow(10,-decimals);
            masterField.validation.min = (Math.pow(10,maxlength-decimals) - Math.pow(10,-decimals)) *-1;
        }
        parameter = { format, decimals, round: false, min: masterField.validation.min, max: masterField.validation.max, step :Math.pow(10,-decimals),};
      }
      // add 水質検査種別マスタ 閾値・グラフ上限、下限と結果初期値の小数桁数が小数部桁数を無視している 孔s start
      else if (this.masterPhysicalName == "mst_water_survey_type" ) {
        if( options.field=="decimalDigits" || options.field=="integerDigits" ) {
            // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Mod by Zt Start
            parameter = { format, decimals, round: false, min: masterField.validation.min, max: masterField.validation.max
              , change: (e)=>this.numericalCollation(e, options, masterField.validation.max, masterField.validation.min)};
            // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Mod by Zt End
        }
        if (options.field=="upperThreshold" || options.field=="lowerThreshold" ||
          options.field=="graphUpperLimit" || options.field=="graphLowerLimit" ||
          options.field=="initialValue"
        ) {
          let decimalDigits = options.model.decimalDigits && options.model.decimalDigits > 0 ? options.model.decimalDigits : 0;
          let integerDigits = options.model.integerDigits && options.model.integerDigits > 0 ? options.model.integerDigits : 0;
          let max = Math.pow(10, integerDigits)-Math.pow(10, -decimalDigits);
          // mod redmine 6316 水質検査値でマイナス値の入力が実施できる 宋qy start
          // #11047 数値IF修正 mod by Z.T. Start
          // let min = 0;
          let min = Math.pow(10,integerDigits) * -1 + Math.pow(10,-decimalDigits);
          // #11047 数値IF修正 mod by Z.T. end
          // mod redmine 6316 水質検査値でマイナス値の入力が実施できる 宋qy end
          let formatTemp ="n"+decimalDigits;
          parameter = { format: formatTemp, decimals: decimalDigits, round: false, step: Math.pow(10,-decimalDigits).toFixed(decimalDigits), min: min, max: max};
        }
      } else if (this.masterPhysicalName === "mst_medicine_support") {
        parameter = { format, decimals, round: false, step :Math.pow(10,-decimals)};
      }
      // add 水質検査種別マスタ 閾値・グラフ上限、下限と結果初期値の小数桁数が小数部桁数を無視している 孔s end

      // add #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 start
      let parameterDecimals = parameter.decimals ? Number(parameter.decimals) : 1
      let parameterStep = parameter.step ? BigNumber(parameter.step).toNumber() : 1
      let parameterFormat = parameter.format;
      let parameterRound = parameter.round;
      let parameterMin = parameter.min ? BigNumber(parameter.min).toNumber() : 0
      let parameterMax = parameter.max ? BigNumber(parameter.max).toNumber() : 999999

      // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Add by Zt Start
      let changeEvent = parameter.change
          ? parameter.change : (e) => {
            let value = e.sender._value;
            // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
            if (this.masterPhysicalName == "mst_monitor_graph") {
              options.model[options.field] = this.roundValue(value, parameter.decimals, BigNumber.ROUND_HALF_UP);
            }
            // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
            if (this.masterPhysicalName == "mst_water_survey_type") {
              options.model[options.field] = this.roundValue(value, parameter.decimals, BigNumber.ROUND_DOWN);
            }

            // add 11455 投与タイミングマスタ>治療開始後通知時間にNULLが設定出来る zkm start
            if ("mst_medicate_timing" == this.masterPhysicalName && "alertTime" == options.field) {
              options.model[options.field] = null === value ? 0 : value;
            }
            // add 11455 投与タイミングマスタ>治療開始後通知時間にNULLが設定出来る zkm end

            // 数値範囲内かどうかの確認
            if (value > parameterMax) {
              options.model[options.field] = parameterMax
            } else if (value <  parameterMin) {
              options.model[options.field] = parameterMin
            }
            document.getElementById("grid").onmousewheel = () => {
              return true
            }
          }
      // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Add by Zt End

      $(strinput).appendTo(container).kendoNumericTextBox({
        decimals: parameterDecimals,
        step: parameterStep,
        // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
        // format: "n0",
        format: parameterFormat,
        // #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
        round: parameterRound,
        spin: (e) => {
          const numericTextBox = $("#myInputNumber").data("kendoNumericTextBox");
          let value = numericTextBox.value();
          
          // 数値範囲内かどうかの確認
          if (value > parameterMax) {
            value = parameterMin;
          } else if (value < parameterMin) {
            value = parameterMax;
          }
          
          // 指数表記を通常表記に変換
          value = BigNumber(value).toFixed();
          // UIの表示を更新
          numericTextBox.value(value);
          numericTextBox.element.val(value);
          
          document.getElementById("grid").onmousewheel = () => {
            return true
          }
        },
        // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Mod by Zt
        change: changeEvent
      });
      this.$nextTick(() => {
        document.getElementById("grid").onmousewheel = () => {
          return false
        }
        $("#myInputNumber").prev().attr("type", "number")
        const numericTextBox = $("#myInputNumber").data("kendoNumericTextBox");
        numericTextBox.element.on("mousewheel", (event)=>{
          let delta = (event.originalEvent.wheelDelta && (event.originalEvent.wheelDelta > 0 ? 1 : -1)) ||
                      (event.originalEvent.detail && (event.originalEvent.wheelDelta > 0 ? -1 : 1))
          let value = event.target.value;
          value = value !== "" ? parseFloat(value) : 0;   

          if (delta > 0) {
            // 滑ります
            value += parameterStep
          } else {
            // 下がります
            value -= parameterStep
          }
          // 数値範囲内かどうかの確認
          if (value > parameterMax) {
            value = parameterMin
          } else if (value <  parameterMin) {
            value = parameterMax
          }
          event.target.value = value.toFixed(this.getDecimalPointLength(parameterStep));
        })
        numericTextBox.element.on("blur", () => {
          document.getElementById("grid").onmousewheel = () => {
            return true
          }
          numericTextBox?.trigger("change")
        })
        numericTextBox.element.on("focusin paste", (event) => {
          // kendoNumericTextBoxの仕様で極度に小さい値or大きい値のペーストは無効となり元の値がevent.target.valueに設定される
          // paste時、元の値が極度に小さい値or大きい値の場合、UIが指数表記となる
          // pasteのタイミングではまだ値がevent.target.valueに反映されていないため、setTimeoutを使って非同期的に値を取得することで指数表記になる事象を回避
          setTimeout(() => {
            const value = event.target.value;
            if (value !== "") {
              // 指数表記を通常表記に変換
              event.target.value = BigNumber(value).toFixed();
            }
          }, 0);
        })
      })
      // add #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 end
     // ダイアライザマスタ変更  杜 end
    },
    /**
     * 指定された小数点以下の桁数に丸めた値を返す
     * @param {*} value 数値
     * @param {*} decimals 小数部桁数
     * @param {*} roundingMode BigNumberの丸めモード
     */
    roundValue(value, decimals, roundingMode) {
      if (decimals == 0) {
        return value != null ? Math.floor(value) : null;
      } else {
        return value != null ? BigNumber(value).decimalPlaces(decimals, roundingMode).toNumber() : null;
      }
    },
    // mod #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 start
    getDecimalPointLength(number){
      var numbers = BigNumber(number).toFixed().split('.');
      return (numbers[1]) ? numbers[1].length : 0;
    },
    // add #5589 2023/04/07 数値IFのスタイル全不正 林峻峰 end
    // add 水質検査種別マスタ 閾値・グラフ上限、下限と結果初期値の小数桁数が小数部桁数を無視している 孔s start
    numericalCollation(e, options, parameterMax, parameterMin){
      // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Mod by Zt Start
      // if(!options.model[options.field]&&options.model[options.field]===null){
      //   return
      // }

      // 数値範囲内かどうかの確認
      let value = e.sender._value;
      if (!value) {
        options.model[options.field] = parameterMin
      } else if (value > parameterMax) {
        options.model[options.field] = parameterMax
      } else if (value <  parameterMin) {
        options.model[options.field] = parameterMin
      }
      // #11047 水質検査種別マスタ 閾値・グラフ上限、下限と整数部桁数の関係設定追加 Mod by Zt Start

      if (options.field=="decimalDigits" || options.field=="integerDigits") {
        let decimalDigits = options.model.decimalDigits&&options.model.decimalDigits>0?options.model.decimalDigits:0;
        let integerDigits = options.model.integerDigits&&options.model.integerDigits>0?options.model.integerDigits:0;
        let max = Math.pow(10,integerDigits)-Math.pow(10,-decimalDigits);
        // #11047 数値IF修正 mod by Z.T. Start
        let min = Math.pow(10,integerDigits) * -1 + Math.pow(10,-decimalDigits);
        // #11047 数値IF修正 mod by Z.T. end
        let updateList = [];
        updateList.push({name: "upperThreshold", value: options.model["upperThreshold"]});
        updateList.push({name: "lowerThreshold", value: options.model["lowerThreshold"]});
        updateList.push({name: "graphUpperLimit", value: options.model["graphUpperLimit"]});
        updateList.push({name: "graphLowerLimit", value: options.model["graphLowerLimit"]});
        updateList.push({name: "initialValue", value: options.model["initialValue"]});

        updateList.forEach(item=>{
          if (options.field=="decimalDigits") {
            // #11047 数値IF修正【最優先】 linjunfeng start
            // if(item.value.toString().split(".")[1] && item.value.toString().split(".")[1].length > decimalDigits){
            if(item.value != null && item.value.toString().split(".")[1] && item.value.toString().split(".")[1].length > decimalDigits){
              // #11047 数値IF修正【最優先】 linjunfeng end
              // #11047 数値IF修正 mod by Z.T. Start
              // item.value.toFixed(decimalDigits) > max ? options.model[item.name]=max : options.model[item.name]=item.value.toFixed(decimalDigits);
              item.value.toFixed(decimalDigits) > max
                ? options.model[item.name]=max : options.model[item.name] = item.value.toFixed(decimalDigits);
              item.value.toFixed(decimalDigits) < min
                ? options.model[item.name]=min : options.model[item.name] = item.value.toFixed(decimalDigits);
              // #11047 数値IF修正 mod by Z.T. end
            }
          }
          if (options.field=="integerDigits") {
            // #11047 数値IF修正 mod by Z.T. Start
            // if (item.value && item.value > max) {
            //   options.model[item.name]=max;
            // }
            if (item.value) {
              if (item.value > max)  options.model[item.name] = max;
              if (item.value < min) options.model[item.name] = min;
            }
            // #11047 数値IF修正 mod by Z.T. End
          }
        })
      }
    },
    // add 水質検査種別マスタ 閾値・グラフ上限、下限と結果初期値の小数桁数が小数部桁数を無視している 孔s end
    // マスタ一覧のデータを取得
    findList() {
      let isDeleteData = []
      let masterPhysicalName = this.masterPhysicalName;
      const facilitySwitch = {
        // facilityCd: this.getFacilityCd
        facilityCd: this.getFacilitySwitch
      };
      // apiをコールして値を取得
      this.findRecordListByFacilityCd(this.facilitylistValue)
        .then(response => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          if (response.data.columns.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message:
              //   "マスタ定義にカラム情報が登録されていません。<BR>カラム情報を登録してください。",
              title: DIALOG_MESSAGES[12000001].title,
              message: messageFormat(DIALOG_MESSAGES[12000001].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              callback: () => {
                this.cancel();
              }
            });
          }

          // add NO-7325 cuifc start
          if (this.masterPhysicalName === "mst_treatment") {
            this.createOldLocalDataSource(response.data.localDataSource.data);
          }
          // add NO-7325 cuifc end

          // add 治療記録モニタグラフマスタ 項目不正 start
          if (this.masterPhysicalName === "mst_monitor_graph") {
            for (let i = 0; i < response.data.columns.length; i++) {
              if (response.data.columns[i].field === "leftDataIndex" || response.data.columns[i].field === "rightDataIndex") {
                response.data.columns[i].values = this.mstMonitorGraphItem
              }
            }
            for (let i = 0; i < response.data.localDataSource.data.length; i++) {
              if (response.data.localDataSource.data[i].leftIsMstMonitor === 1) {
                response.data.localDataSource.data[i].leftDataIndex = "MST" + response.data.localDataSource.data[i].leftDataIndex;
              }
              if (response.data.localDataSource.data[i].rightIsMstMonitor === 1) {
                response.data.localDataSource.data[i].rightDataIndex = "MST" + response.data.localDataSource.data[i].rightDataIndex;
              }
            }
          }
          // add 治療記録モニタグラフマスタ 項目不正 end

          // add redmine 5702 溶解装置のトレンドグラフ 宋qy start
          if (this.masterPhysicalName === "mst_trend_graph_template" || this.masterPhysicalName === "mst_trend_graph_monitor_set") {
            for (let i = 0; i < response.data.localDataSource.data.length; i++) {
              if (response.data.localDataSource.data[i].model === "003" && response.data.localDataSource.data[i].comFormatCd === "I" ) {
                response.data.localDataSource.data[i].model = "006";
              } else if (response.data.localDataSource.data[i].model === "003" && response.data.localDataSource.data[i].comFormatCd === "J" ) {
                response.data.localDataSource.data[i].model = "007";
              }
            }
          }
          // add redmine 5702 溶解装置のトレンドグラフ 宋qy end

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
          // add FNSI-修正 マスタ削除の対応 Du start
          if(masterPhysicalName == "mst_medicine" || masterPhysicalName == "mst_equipment")
            toFunction.filter(column => column.field === "classCd")
            .forEach(column => {
             column.textTemplate = (dataItem) => {
                let columnValues = column.values.map(e=>String(e.value));
                let deleteData = []
                if (isDeleteData.length > 0) {
                  deleteData = isDeleteData.map(e=>String(e));
                }
                let value = dataItem[`${column.field}`];
                if (!value) value = "";
                if(value && !columnValues.includes(value) && !deleteData.includes(value)){
                  isDeleteData.push(value)
                }
                let isvalue = column.values.filter(e=>String(e.value) == value);
                value = isvalue.length > 0 ? this.$sanitize(isvalue[0].text) : "";
                return value;
              }
            });
          // add FNSI-修正 マスタ削除の対応 Du end
          this.columns = toFunction;
          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            column.width = column.field === "isDisp" ? "9em" : (this.columnWidth + "em");
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && (column.dataType === "string" || column.dataType === "textarea") && column.field === "name") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 16 : column.width * 16;
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
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
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            let columnsData = this.columns;
            this.calculateGridHeight();
            this.calculateGridWidth();
            // add FNSI-修正 マスタ削除の対応 Du start
            if(isDeleteData.length > 0) {
              ApiHelper.get(masterPhysicalName == "mst_medicine" ? `/mstInfo/mstMedicineClassIncludeDeleted` : `/mstInfo/mstEquipmentClassIncludeDeleted`, facilitySwitch)
              .then(responsesData=> {
                isDeleteData.forEach(e=>{
                  let data = responsesData.data.filter(item => String(item.classCd) == e);
                  // #9863 MasterRecordComponent.vue:1174 Uncaught (in promise) TypeError: Cannot read properties of undefined (reading 'classCd') 横展開2 linjunfeng start
                  // columnsData.filter(a=>a.field == "classCd")[0].values.push({value:parseInt(data[0].classCd),text:MASTER_DELETE_DISPLAY.DELETED + data[0].className,isDisp:true})
                  columnsData.filter(a=>a.field == "classCd")[0].values.push({value:parseInt(data[0]?.classCd),text:MASTER_DELETE_DISPLAY.DELETED + data[0]?.className,isDisp:true})
                  // #9863 MasterRecordComponent.vue:1174 Uncaught (in promise) TypeError: Cannot read properties of undefined (reading 'classCd') 横展開2 linjunfeng end
                })
              });
              this.columns = columnsData;
            }
            // add FNSI-修正 マスタ削除の対応 Du end
            /* add スクロールの位置を維持 楊 start */
            // document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop = this.lastScrollTop;
            // document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft = this.lastScrollLeft;
            /* add スクロールの位置を維持 楊 end */

            // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる start
            // ストアからスクロール位置を取得してデータ表示域に設定
            this.$refs.grid.$el.lastChild.scrollTop = this.getScrollTopPosition;
            this.$refs.grid.$el.lastChild.scrollLeft = this.getScrollLeftPosition;
            // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる end
          });
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          // 色カラムのテンプレート生成
          this.columns.filter(column => column.dataType === "color")
            .forEach(column => {
              column.colorTemplate = (dataItem) => {
                const value = dataItem[`${column.field}`];
                return `<div style='background-color: ${value}; width: 4em;'>&nbsp;</div>`;
              }
            });

          // add 水質検査種別マスタ 閾値・グラフ上限、下限と結果初期値の小数桁数が小数部桁数を無視している 孔s start
          if(this.masterPhysicalName === "mst_water_survey_type" ){
            this.columns.filter(column => (
              column.field=="upperThreshold" || column.field=="lowerThreshold" ||
              column.field=="graphUpperLimit" || column.field=="graphLowerLimit" ||
              column.field=="initialValue"
            ))
              .forEach(column => {
                column.format = "";
              });
          }
          // add 水質検査種別マスタ 閾値・グラフ上限、下限と結果初期値の小数桁数が小数部桁数を無視している 孔s end

          // add 治療記録バイタルグラフマスタ 1、6つの初期データを固定表示するようにしました。 と削除できません。 start
          if (this.masterPhysicalName == "mst_vital_graph") {
            if (response.data.localDataSource.data.length === 0) {
              mstVitalGraphDefine.map(item =>{
                return {
                  code: 0,
                  name: item.vvitalGraphName,
                  vitalLineColor: item.vitalLineColor,
                  vitalLineSize: item.vitalLineSize,
                  vitalLineTypeValue: item.vitalLineTypeValue,
                  vitalPointColor: item.vitalPointColor,
                  vitalPointSize: item.vitalPointSize,
                  vitalPointTypeValue: item.vitalPointTypeValue,
                  isDel: "",
                  isDisp: "1",
                  sortRank: item.sortRank,
                  sortInputTime: 0,
                  isAddRow: true,
                  edited: true
                };
              }).forEach(element => {
                this.edit({ editRecord: element, isSortMode: this.isSortMode });
              });
            }
            this.columns.filter(column => (column.field=="name" || column.field=="isDisp"))
            .forEach(column => {
              const temp = response.data.localDataSource.data.filter(item => item.isDisp == "1").sort((a,b) => a.code-b.code);
              const maxCode = temp.length>mstVitalGraphDefine.length ? temp[mstVitalGraphDefine.length-1].code : temp[temp.length-1].code;
              column.editable = (e)=>{return e.code > maxCode};
            });
          }
          // add 治療記録バイタルグラフマスタ 1、6つの初期データを固定表示するようにしました。 と削除できません。 end
          this.dataSourceItems = this.generatedGridData();
          // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
          // 共通定型文マスタ：「保存」ボタン⇒非活性、編集場所のスタイル⇒未編集 林峻峰 start
          // this.getMasterRecordListOld = deepCopy(this.getMasterRecordList.data.filter((item)=>{
          //   return item.isDisp === "1"
          // }))
          // this.getMasterRecordListOld.forEach((item)=>{
          //   if (item.occupations) {
          //     item.occupations = item.occupations.replace(/\s/g, '')
          //   }
          // })
          // 共通定型文マスタ：「保存」ボタン⇒非活性、編集場所のスタイル⇒未編集 林峻峰 end
          // del #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（データリストレイアウトマスタ画面）20231106 ztc start
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MasterRecordComponent.vue', 'findRecordListByFacilityCd' , error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
        });
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    setFilterCondition(condition) {
      this.condition.recordName = condition.recordName;
      this.condition.includeDeleted = condition.includeDeleted;
    },
    onEditSave(e) {
      let field = Object.keys(e.values)[0];
      if(this.masterPhysicalName == "mst_monitor_graph") {
        if (field === "leftDataIndex") {
          for (let i = 0; i < this.mstMonitorInitial.length; i++) {
            if (this.mstMonitorInitial[i].moniDataNo === e.values.leftDataIndex) {
              e.model.leftGraphLowerLimit = this.mstMonitorInitial[i].lower;
              e.model.leftGraphUpperLimit = this.mstMonitorInitial[i].upper;
            }
          }
        }
        if (field === "rightDataIndex") {
          for (let i = 0; i < this.mstMonitorInitial.length; i++) {
            if (this.mstMonitorInitial[i].moniDataNo === e.values.rightDataIndex) {
              e.model.rightGraphLowerLimit = this.mstMonitorInitial[i].lower;
              e.model.rightGraphUpperLimit = this.mstMonitorInitial[i].upper;
            }
          }
        }
      }
      if (this.masterPhysicalName == "mst_mainte_detail") {
        if (e.values.isCmt)  e.model.iniText = null;
        // redmine 5344 日常点検を選択した場合も内容3が登録できる 宋qy start
        if (e.values.mainteClass) e.model.mainteContent3 = null;
        // redmine 5344 日常点検を選択した場合も内容3が登録できる 宋qy end
        if (e.values.mainteClass == "1") e.model.ansPattern = "0";
        if (e.values.mainteClass == "2") e.model.ansPattern = "1" ;
      }
      if (this.masterPhysicalName == "mst_water_survey_type" && ["upperThreshold", "lowerThreshold", "graphUpperLimit", "graphLowerLimit", "initialValue"].includes(field)) {
        e.values[field] = this.roundValue(e.values[field], e.model.decimalDigits, BigNumber.ROUND_DOWN);
      }
      
      // 値変更時のみonSaveを実行
      // onSaveを無条件で実行すると値変更しなくても行色が編集状態となる
      const oldValue = e.model[field];
      const newValue = e.values[field];
      if (oldValue != newValue) {
        this.onSave(e)
      }
    },
    //日常・定期点検項目マスタ 列の関連
    modifyEditStart (e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      if (this.masterPhysicalName == "mst_mainte_detail") {
        if (e.model.mainteClass == "1")  e.sender.columns[9].values = this.columns[9].values.filter(e => e.value == "0");
         if (e.model.mainteClass == "2")  e.sender.columns[9].values = this.columns[9].values.filter(e => e.value != "0");
      }
      // add FNSI-修正 マスタ削除の対応 Du start
      if (this.masterPhysicalName == "mst_medicine" || this.masterPhysicalName == "mst_equipment") {
        e.sender.columns.filter(e=>e.field == "classCd")[0].values = this.columns.filter(e=>e.field == "classCd")[0].values.filter(e=>!e.isDisp);
      }
      // add FNSI-修正 マスタ削除の対応 Du end
      // add 医療材料セットマスタ 編集の時、スクロール位置を取得 start 鞠
      if (this.masterPhysicalName == "mst_equipment") {
        const grid = $("div.k-grid-content")[0];
        this.scrollPosition.left = grid.scrollLeft;
      }
      // add 医療材料セットマスタ 編集の時、スクロール位置を取得 end 鞠
      this.editStart(e)
    },
    /**
     * add NO-7325 cuifc
     * 外部連携インタフェースを要求するか否かを判断する
     * */
    sendSetUpdateFlag() {
      this.getUpdateRecordList.forEach((recordData) => {
        if (recordData.operation === 2) {
          for (const oldRecordData of this.oldLocalDataSource) {
            let tcsJson = recordData.treatmentConditionSetting;
            let code = recordData.code;
            let deviceMode = recordData.deviceMode;
            let oldtcsJson = oldRecordData.treatmentConditionSetting;
            let oldCode = oldRecordData.code;
            let oldDeviceMode = oldRecordData.deviceMode;
            //治療方法マスタの中の装置モードの項目を変更した場合,isSendJournalApiFlag値は1
            if (code === oldCode && (tcsJson !== oldtcsJson || deviceMode !== oldDeviceMode)) {
              recordData.isSendJournalApiFlag = 1;
              break;
            } else {
              recordData.isSendJournalApiFlag = 0;
            }
          }
        }
      });
    },
    /**
     * add NO-7325 cuifc
     * OldLocalDataSourceの作成
    */
    createOldLocalDataSource(dataSourceList) {
      this.oldLocalDataSource = [];
      dataSourceList.forEach((dataSource) => {
        const dataSourceJson = {
          code: dataSource.code,
          deviceMode: dataSource.deviceMode,
          name: dataSource.name,
          treatmentConditionSetting: dataSource.treatmentConditionSetting
        };
        this.oldLocalDataSource.push(dataSourceJson);
      });
    },
    // add 9664 by kangjie 20231208 start
    /**
     * @description 指示者設定確認
     */
    async checkIndUserSetting() {
      this.setIsIndUserSetting(false);
      this.setIndUserId(null);
      // 指示者情報を取得
      const response = await ApiHelper.get(
        `/facilities/${this.getStateUserAccountInfo.facilityCd}/personal-user/job/doctor`
      ).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('PatInfoCardList.vue', 'checkIndUserSetting', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        throw error;
      });
      if (0 !== response.data.length) {
        // 指示者リストを作成
        const indUserList = [];
        response.data.forEach(user => {
          indUserList.push({
            name: `${user.user_last_name} ${user.user_first_name}`,
            userId: user.user_id
          });
        });
        this.setIndUserList(indUserList);
        return true;
      } else {
        return false;
      }
    },
    async saveRecordPopUpModel(){
      // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる start
      // 保存ボタン押下時のスクロールバー位置をストアに保存
      this.setScrollTopPosition( this.$refs.grid.$el.lastChild.scrollTop );
      this.setScrollLeftPosition( this.$refs.grid.$el.lastChild.scrollLeft );
      // #9976 マスタ画面で保存を行うとスクロール位置が先頭になる end

      if (this.masterPhysicalName === 'mst_treatment') {
        const editRecord = this.getUpdateRecordList.filter(item => (item.operation === 2))
        const checkResult = await this.checkIndUserSetting().catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('MasterRecordComponent.vue', 'confirmSelectDoctorNo', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          throw error;
        });
        if (checkResult && editRecord.length >0) {
          this.isModalVisible = true;
        } else {
          this.saveRecord ();
        }
      } else {
        this.saveRecord ();
      }
    },
    // add 9664 by kangjie 20231208 end
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }
      /* add 内部#6279 by zhangruixue 2023-06-15 --start */
      if (this.masterPhysicalName === "mst_treatment_set"){
        const editRecord = this.getUpdateRecordList.filter(item => (item.operation === 1 && item.edited))
        let treatmentCdEmptyFlg = false;
        for(let item of editRecord) {
          if(!item.treatmentCd){
            treatmentCdEmptyFlg = true;
            break;
          }
        }
        if (treatmentCdEmptyFlg) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES['22010001'].title,
            message: messageFormat(DIALOG_MESSAGES['22010001'].message, '治療方法')
          });
          this.setLoadingScreenVisible(false);
          return;
        }
      }
      /* mod 内部#6279 by zhangruixue 2023-06-15 --start */
      // 患者経過総合ビューアレイアウトマスタ
      // バイタル・モニタグラフ　入室～退室の親子化の解除
      if (this.masterPhysicalName === "mst_pat_viewer_layout") {
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          //add 内部#6589 【試験T】【結合テスト】3日・7日・14日 checkon，disp_period_class 显示Null zhaoqi 20230626 start
          let dispPeriodClass = this.getMasterRecordList.data[i].dispPeriodClass;
          if(dispPeriodClass === ''){
            this.getMasterRecordList.data[i].dispPeriodClass = '0';
          }
          //add 内部#6589 【試験T】【結合テスト】3日・7日・14日 checkon，disp_period_class 显示Null zhaoqi 20230626 end
          let dispItemInfo = JSON.parse(this.getMasterRecordList.data[i].dispItemInfo);
          let convertDispItemInfo = [];
           // 6376【設計T】【結合試験仕様書作成】【患者経過総合ビューアレイアウトマスタ】 新规追加一条 点击保存 保存失败 start zhao
          if (dispItemInfo) {
           // 6376【設計T】【結合試験仕様書作成】【患者経過総合ビューアレイアウトマスタ】 新规追加一条 点击保存 保存失败 end zhao
            for (let j = 0; j < dispItemInfo.length; j++) {
              if (dispItemInfo[j].categoryNo === 1) {
                let treateCategoryItem = [];
                for (let k = 0; k < dispItemInfo[j].categoryItem.length; k++) {
                  if (dispItemInfo[j].categoryItem[k].subCategoryNo >= 58 && dispItemInfo[j].categoryItem[k].subCategoryNo <= 61 && dispItemInfo[j].categoryItem[k].vitalChild !== undefined) {
                    let vitalCategoryItem_1 = dispItemInfo[j].categoryItem[k];
                    let vitalCategoryItem_2 = dispItemInfo[j].categoryItem[k].vitalChild[0];
                    let vitalCategoryItem_3 = dispItemInfo[j].categoryItem[k].vitalChild[1];
                    if (vitalCategoryItem_1 !== undefined && vitalCategoryItem_1.isDisp) {
                      delete vitalCategoryItem_1.isDisp;
                      delete vitalCategoryItem_1.isDispflag;
                      vitalCategoryItem_1.subCategoryItem.forEach((subCategoryItem) => {
                        delete subCategoryItem.isDisp;
                        delete subCategoryItem.isDispflag;
                      });
                      delete vitalCategoryItem_1.vitalChild;
                      treateCategoryItem.push(vitalCategoryItem_1);
                    }
                    if (vitalCategoryItem_2 !== undefined && vitalCategoryItem_2.isDisp) {
                      delete vitalCategoryItem_2.isDisp;
                      delete vitalCategoryItem_2.isDispflag;
                      vitalCategoryItem_2.subCategoryItem.forEach((subCategoryItem) => {
                        delete subCategoryItem.isDisp;
                        delete subCategoryItem.isDispflag;
                      });
                      treateCategoryItem.push(vitalCategoryItem_2);
                    }
                    if (vitalCategoryItem_3 !== undefined && vitalCategoryItem_3.isDisp) {
                      delete vitalCategoryItem_3.isDisp;
                      delete vitalCategoryItem_3.isDispflag;
                      vitalCategoryItem_3.subCategoryItem.forEach((subCategoryItem) => {
                        delete subCategoryItem.isDisp;
                        delete subCategoryItem.isDispflag;
                      });
                      treateCategoryItem.push(vitalCategoryItem_3);
                    }
                  } else {
                    // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                    dispItemInfo[j].categoryItem[k].subCategoryItem.forEach((subCategoryItem) => {
                      delete subCategoryItem.isDispflag;
                    });
                    // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                    treateCategoryItem.push(dispItemInfo[j].categoryItem[k]);
                  }
                }
                let treateDispItemInfo = dispItemInfo[j];
                treateDispItemInfo.categoryItem = treateCategoryItem;
                convertDispItemInfo.push(treateDispItemInfo);
              } else {
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 start
                for (let k = 0; k < dispItemInfo[j].categoryItem.length; k++) {
                  dispItemInfo[j].categoryItem[k].subCategoryItem.forEach((subCategoryItem) => {
                    delete subCategoryItem.isDispflag;
                  });
                }
                // add #9574 患者経過総合ビューアレイアウトマスタの長期間表示で検査結果のグラフの選択肢が不正 吉 end
                convertDispItemInfo.push(dispItemInfo[j]);
              }
            }
           // 6376【設計T】【結合試験仕様書作成】【患者経過総合ビューアレイアウトマスタ】 新规追加一条 点击保存 保存失败 start zhao
          }
           // 6376【設計T】【結合試験仕様書作成】【患者経過総合ビューアレイアウトマスタ】 新规追加一条 点击保存 保存失败 end zhao
          this.getMasterRecordList.data[i].dispItemInfo = JSON.stringify(convertDispItemInfo);
        }
      }
      
      // 患者カレンダーレイアウトマスタ
      // バイタル・モニタグラフ　入室～退室の親子化の解除
      const vitalMonitorSubCategoryNo1 = [
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_1_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_2_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_3_1,
        SUB_CATEGORY_NO.VITAL_MONITOR_GRAPH_IN_OUT_4_1
      ];      
      if (this.masterPhysicalName === "mst_pat_calendar_layout") {
        this.getMasterRecordList.data.forEach(record => {
          // 表示区分
          record.dispClass = record.dispClass ? record.dispClass : "0";
          
          if (!record.dispItemInfo) return;
          const dispItemInfo = JSON.parse(record.dispItemInfo);
        
          const convertDispItemInfo = dispItemInfo.map(info => {
            // 治療情報以外はそのまま
            if (info.categoryNo !== 2) return info;
        
            const treateCategoryItem = [];
            
            info.categoryItem.forEach(categoryItem => {
              const isVitalTarget =
                vitalMonitorSubCategoryNo1.includes(categoryItem.subCategoryNo) &&
                categoryItem.vitalChild !== undefined;
        
              if (isVitalTarget) {
                const items = this.buildCategoryItemsVitalMonitor(categoryItem);
                if (items.length) {
                  treateCategoryItem.push(...items);
                  return; // 次の categoryItem
                }
              }
              // else 相当
              categoryItem.subCategoryItem.forEach(sub => {
                delete sub.isDispflag;
              });
              treateCategoryItem.push(categoryItem);
              
            });
        
            return {
              ...info,
              categoryItem: treateCategoryItem
            };
          });

          record.dispItemInfo = JSON.stringify(convertDispItemInfo);
        });
      }
      
      if (this.masterPhysicalName === "mst_dialyzer") {
        let flag = false;
        // add #7224 尿素クリアランスについて 付 start
        let flagureaClearance = false
        // add #7224 尿素クリアランスについて 付 end
        let message = "";
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          if (this.getMasterRecordList.data[i].ufrWarningMax < this.getMasterRecordList.data[i].ufrWarningMin) {
            flag = true;
            if (message === "") {
              message += this.getMasterRecordList.data[i].name;
            } else {
              message += "<br>" + this.getMasterRecordList.data[i].name;
            }
          }
          // add #7224 尿素クリアランスについて 付 start
          if (this.getMasterRecordList.data[i].ureaClearance > this.getMasterRecordList.data[i].bloodamt) {
            flagureaClearance = true;
            if (message === "") {
              // mod #7224 尿素クリアランスについて 徐博 start
              // message += '尿素クリアランス（' + (this.getMasterRecordList.data[i].ureaClearance).toFixed(1) + '）＞血流量（' + (this.getMasterRecordList.data[i].bloodamt).toFixed(1) + '）になっています。';
              message += '尿素クリアランス（' + (this.getMasterRecordList.data[i].ureaClearance).toFixed(0) + '）＞血流量（' + (this.getMasterRecordList.data[i].bloodamt).toFixed(0) + '）になっています。';
              // mod #7224 尿素クリアランスについて 徐博 end
            } else {
              // mod #7224 尿素クリアランスについて 徐博 start
              // message += "<br>" + '尿素クリアランス（' + (this.getMasterRecordList.data[i].ureaClearance).toFixed(1) + '）＞血流量（' + (this.getMasterRecordList.data[i].bloodamt).toFixed(1) + '）になっています。';
              message += "<br>" + '尿素クリアランス（' + (this.getMasterRecordList.data[i].ureaClearance).toFixed(0) + '）＞血流量（' + (this.getMasterRecordList.data[i].bloodamt).toFixed(0) + '）になっています。';
              // mod #7224 尿素クリアランスについて 徐博 end
            }
          }
          // add #7224 尿素クリアランスについて 付 end
        }
        // add #7224 尿素クリアランスについて 付 start
        if (flagureaClearance) {
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES["00300006"].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: message
          });
          return
        }
        // add #7224 尿素クリアランスについて 付 end
        if (flag) {
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES[12000081].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            message: message + DIALOG_MESSAGES[12000081].message
          });
          return;
        }
      }
      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      let isSysMedicine = false;
      if (this.masterPhysicalName == "sys_medicine") isSysMedicine = true;
      records.data = records.data.filter(
        r => !(r.operation === 1 && (!r.edited || !(r.isAddRow && (r.isDisp == '1'|| isSysMedicine))))
      );
      // データの削除特殊処理
      await deleteDataProcessing(this.getFacilitySwitch, this.masterPhysicalName, records.data);
      if (this.masterPhysicalName == "mst_holiday"){
        let deleteData =  records.data.filter(e=> e.isDisp == "0" && e.operation == 2 && e.class =="0").map(a=>a.code);
        let recoveryData =  records.data.filter(e=> e.isDisp == "1" && e.operation == 2 && e.class =="0").map(a=>a.code);
        if(deleteData)
        records.data.forEach(e=>{
          deleteData.forEach(item => {
            if (e.isDisp == "1" && e.code == item+1) {
              e.isDisp ="0";
              e.operation = 2;
            }
          });
          recoveryData.forEach(item => {
            if (e.isDisp == "0" && e.code == item+1) {
              e.isDisp ="1";
              e.operation = 2;
            }
          });
        })
      }
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();
      let message = "";
      if (validateMessage.length !== 0) {
        message = "以下の列に未入力項目が存在します。" + validateMessage  +"</br>";
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          message + "以下の列の選択を見直してください。" + validateComboMessage +"</br>";
      }

      // add 治療記録モニタグラフマスタ 項目不正 start
      // mod 9184 治療記録モニタグラフマスタにて1項目のグラフが生成できない 関 start
      // if (this.masterPhysicalName == "mst_monitor_graph") {
      if (this.masterPhysicalName == "mst_monitor_graph" && message === "") {
        // mod 9184 治療記録モニタグラフマスタにて1項目のグラフが生成できない 関 end
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          if (this.getMasterRecordList.data[i].leftDataIndex.slice(0, 3) === "MST") {
            this.getMasterRecordList.data[i].leftIsMstMonitor = 1;
            this.getMasterRecordList.data[i].leftDataIndex = this.getMasterRecordList.data[i].leftDataIndex.slice(3);
          } else {
            this.getMasterRecordList.data[i].leftIsMstMonitor = 0;
          }
          if (this.getMasterRecordList.data[i].rightDataIndex.slice(0, 3) === "MST") {
            this.getMasterRecordList.data[i].rightIsMstMonitor = 1;
            this.getMasterRecordList.data[i].rightDataIndex = this.getMasterRecordList.data[i].rightDataIndex.slice(3);
          } else {
            this.getMasterRecordList.data[i].rightIsMstMonitor = 0;
          }
        }
      }
      // add 治療記録モニタグラフマスタ 項目不正 end

      // 水質検査箇所マスタ 水質調査種別  変更不可
      if (this.masterPhysicalName == "mst_water_survey_point") {
        await this.validateWaterSurveyPointValue();
        if(this.waterSurveyPointValueFalg)
          // add 全マスタメッセージ調整 王 start
          // message = message + "結果が登録されている</br> 箇所の種別変更はできません。";
          message = message + DIALOG_MESSAGES[12000050].message;
          // add 全マスタメッセージ調整 王 end
      }

      // add #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng start
      const mstObj = {
        mst_pat_event_data_template: "inputParams", // 患者イベントテンプレートマスタ
        mst_medicine_mix: "mixInfo", // 調製薬剤マスタ
        mst_facility_calendar_layout: "dispItemInfo", // 施設カレンダーレイアウトマスタ
        mst_pat_list_layout: "dispItemInfo", // データリストレイアウトマスタ
        mst_trend_graph_monitor_set: "seriesInfo", // 治療状況透析液調製装置トレンドレイアウトマスタ
        mst_trend_graph_template: "seriesInfo", // 治療状況透析液調製装置グラフレイアウトマスタ
        mst_destination_group: "destinationTarget", // 送信先グループマスタ
        mst_exam_set: "iteminfo", // 検査セットマスタ
        mst_equipment_set: "setInfo", // 医療材料セットマスタ
        mst_medicine_set: "setInfo", // 薬剤セットマスタ
      };
      const mstName = Object.keys(mstObj);
      // add #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng end
      // #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng start
      // if(this.masterPhysicalName === 'mst_medicine_mix'){
      if(mstName.includes(this.masterPhysicalName)){
      // #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng emd
        this.getMasterRecordList.data.forEach(
          item => {
            // #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng start
            // if(item.mixInfo == null){
              // item.mixInfo = "[]";
            // }
            const key = mstObj[this.masterPhysicalName];
            if(item[key] == null || item[key] === ""){
              if (this.masterPhysicalName === 'mst_destination_group') {
                item[key] = "{\"users\":[]}";
              } else if (this.masterPhysicalName === 'mst_pat_list_layout') {
                item[key] = "[]";
                item.occupations = "[]";
              } else {
                item[key] = "[]";
              }
            }
            // #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng end
          }
        )
      }

      // 検査項目マスタ
      if (this.masterPhysicalName == "mst_exam_item") {
        let examItemFalg = true;
        this.getMasterRecordList.data.forEach(item1 => {
          if(item1.isDisp === "1"){
            this.getMasterRecordList.data.forEach(item2 => {
              if (item1.defaultCalcExamItemCd != "0" &&
                  item1.code != item2.code &&
                  item1.defaultCalcExamItemCd == item2.defaultCalcExamItemCd &&
                  item2.dialysisProgressFlag != "0" && item2.dialysisProgressFlag != "" &&
                  item2.isDisp === "1") {
                if (item1.dialysisProgressFlag == "1" && item2.dialysisProgressFlag != "2") examItemFalg = false;
                if (item1.dialysisProgressFlag == "2" && item2.dialysisProgressFlag != "1") examItemFalg = false;
                if (item1.dialysisProgressFlag == "3" && item2.dialysisProgressFlag != "0") examItemFalg = false;
              }
            })
          }
        })
        if(!examItemFalg){
          // メッセージ組み立て
          const title = DIALOG_MESSAGES[12000012].title;
          let message = `
              ${
                !examItemFalg
                  // add 全マスタメッセージ調整 王 start
                  // ? "同じな検査項目の透析前、透析後は重複です。<br>"
                  ? DIALOG_MESSAGES[12000012].message + "<br>"
                  // add 全マスタメッセージ調整 王 end
                  : ""
              }`;
          // ダイアログ表示
          this.$ons.notification.alert({
            title: title,
            message: message
          });
          this.setLoadingScreenVisible(false);
          return;
        }
      }

      // add 休日マスタ 障害対応No217 追加重複の情報（年）チェック start
      if (this.masterPhysicalName == "mst_holiday") {
        const yearList = this.getMasterRecordList.data
          .filter(f => f.isDisp === "1")
          .map(item => {
            return item.year + item.class
          });
        if (yearList.length > 1) {
          let repeatCount = 0;
          yearList.sort().sort((a, b) => {
            if (a == b) {
              repeatCount++;
            }
          })
          if (repeatCount > 0) {
            // add 全マスタメッセージ調整 王 start
            // message = message + "重複の情報（年）があります。</br> 恢復したい場合は重複の情報（年）をご削除ください。";
            message = message + DIALOG_MESSAGES[12000049].message;
            // add 全マスタメッセージ調整 王 end
          }
        }
      }
      this.$refs.grid.$el.lastChild.scrollTop = this.getScrollTopPosition;
      this.$refs.grid.$el.lastChild.scrollLeft = this.getScrollLeftPosition;
      // add 休日マスタ 障害対応No217 追加重複の情報（年）チェック end

      if ((this.masterPhysicalName === "mst_treatment" || this.masterPhysicalName === "mst_comsv_setting" )&& this.getUpdateRecordList.filter(item => (item.operation === 2)).length != 0) {
        let mstMachineList = [];
        await Promise.all([
          ApiHelper.get(`/master_maintenance/mst_machine/data/${this.getFacilitySwitch}`).then(response => {
            if(response.data) {
              mstMachineList = response.data.localDataSource.data
            }
          })
        ])
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MasterRecordComponent.vue', 'created', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          throw error;
        });

        await Promise.all([ ApiHelper.get(`master_maintenance/mnt_machine_state/${this.getFacilitySwitch}`)]).then(async response => {
            const result = response[0].data.filter(e => e.facilityCd == this.getFacilitySwitch)
            result.forEach(async item => {
              let itemData = mstMachineList.filter(e=> e.machineTypeCd == item.machineTypeCd && e.machineSerial == item.machineSerial && e.facilityCd == item.facilityCd);

              const params = {
                ordNo: item.nextOrdNo, //オーダー番号
                // #9863 MasterRecordComponent.vue:1830 Uncaught (in promise) TypeError: Cannot read properties of undefined (reading 'code') 横展開2 linjunfeng start
                // machineNo: itemData[0].code, //装置マスタ.装置番号
                // deviceEdgeNo: itemData[0].deviceEdgeNo, //デバイスエッジ番号
                machineNo: itemData[0]?.code, //装置マスタ.装置番号
                deviceEdgeNo: itemData[0]?.deviceEdgeNo, //デバイスエッジ番号
                 // #9863 MasterRecordComponent.vue:1830 Uncaught (in promise) TypeError: Cannot read properties of undefined (reading 'code') 横展開2 linjunfeng end
                facilityCd: this.getFacilitySwitch //施設コード
              };
              // await this.sendNextPatInfo(params);
            })
        })
        .catch(error => {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MasterRecordComponent.vue', 'created', error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            throw error;
        });
      }
      // add redmine 4652 治療方法変更に伴う指示変更が不正 孔 start
      if (this.masterPhysicalName === "mst_treatment") {
        const editRecord = this.getUpdateRecordList
          .filter(item => (item.operation === 1 && item.edited) || item.operation === 2)

        /* add 内部#6279 by zhangruixue 2023-06-15 --start */
        let deviceModeEmptyFlg = false;
        for(let item of editRecord) {
          if(!item.deviceMode){
            deviceModeEmptyFlg = true;
            break;
          }
        }
        if (deviceModeEmptyFlg) {
          this.$ons.notification.alert({
            title: DIALOG_MESSAGES['22010001'].title,
            message: messageFormat(DIALOG_MESSAGES['22010001'].message, '装置モード')
          });
          this.setLoadingScreenVisible(false);
          return;
        }
        /* mod 内部#6279 by zhangruixue 2023-06-15 --start */
        //   // add #6797 2023/01/10 利用開始日A、Bが未登録の状態でも登録できてしまう dou start
           if (editRecord && editRecord.length > 0) {
          //mod 6797 利用開始日A、Bが未登録の状態でも登録できてしまう start zhao
          // add #6797 2023/01/10 利用開始日A、Bが未登録の状態でも登録できてしまう dou start
          let errorlist = editRecord.filter(x =>
          //mod 6797 利用開始日A、Bが未登録の状態でも登録できてしまう end zhao
            (x.inHospAStartdate == null
              && (!!x.inHospitalCdA1
                || !!x.inHospitalCdA2
                || !!x.inHospitalCdA3
                || !!x.inHospitalCdA4))
            || (x.inHospBStartdate == null
              && (!!x.inHospitalCdB1
                || !!x.inHospitalCdB2
                || !!x.inHospitalCdB3
                || !!x.inHospitalCdB4))
          )
          //mod 6797 利用開始日A、Bが未登録の状態でも登録できてしまう start zhao
          let hospFlg = false;
          errorlist.forEach(it1 => {
            if(it1.isDisp === "1"){
              hospFlg = true;
            }
          });
          // if (errorlist.length > 0) {
          if (errorlist.length > 0 && hospFlg) {
          //mod 6797 利用開始日A、Bが未登録の状態でも登録できてしまう end zhao
            message = message + DIALOG_MESSAGES[12000084].message;
          }
          // add #6797 2023/01/10 利用開始日A、Bが未登録の状態でも登録できてしまう dou end
          // 現在のユーザー権限
          const userAuthorityCds = await ApiHelper.get("/user-authority/login/list");
          const ind_edit = userAuthorityCds.data.includes(AUTHORITY_CODES.IND_EDIT);
          const ind_pedit = userAuthorityCds.data.includes(AUTHORITY_CODES.IND_PEDIT);
          if (!(ind_edit || ind_pedit)) {
            message = message + DIALOG_MESSAGES[12000063].message;
          }
        }
      }
      // add redmine 4652 治療方法変更に伴う指示変更が不正 孔 end

      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000049].title,
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        this.waterSurveyPointValueFalg = false;
        return;
      }

      // add FNSI-分類変更のメッセージ表示 李 start
      let classiFicationFlg = false;
      this.getMasterRecordList.data.forEach(
        item => {
          if (item.operation !== 1) {
            // 医療材料の分類が変更された
            if(item.dirtyFields && item.dirtyFields.classCd) {
              classiFicationFlg = true;
            } else if(item.dirtyFields && item.dirtyFields.classType){// 薬剤の分類が変更された
              classiFicationFlg = true;
            } else if (item.classiFicationFlg) {
              classiFicationFlg = true;
            }
          }
      });

      // add 分類区分/分類 修正 王 start
      if (
        this.masterPhysicalName === 'mst_medicine_class' ||
        this.masterPhysicalName === 'mst_equipment_class' ||
        this.masterPhysicalName === 'mst_equipment' ||
        this.masterPhysicalName === 'mst_medicine' ||
        this.masterPhysicalName === 'mst_medicine_mix'
      ){
        let tempData = null;
        await ApiHelper.get(
          `/master_maintenance/${this.masterPhysicalName}/data/${this.facilitylistValue}`
        ).then(response => {
          tempData = response.data.localDataSource.data
        });
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          for (let j = 0; j < tempData.length; j++) {
            if (tempData[j].code === this.getMasterRecordList.data[i].code){
              // mod IES_6711 【試験T】【結合テスター】調製薬マスター：「並び順表示」修正後保存できない zhou start
              //if (this.getMasterRecordList.data[i].classType !== undefined ){
              if (this.getMasterRecordList.data[i].classType !== undefined && this.getMasterRecordList.data[i].classType !== null){
              // mod IES_6711 【試験T】【結合テスター】調製薬マスター：「並び順表示」修正後保存できない zhou end
                console.log("j" ,j,tempData[j].classType)
                if(tempData[j].classType.toString() == this.getMasterRecordList.data[i].classType){
                  classiFicationFlg = false;
                } else {
                  classiFicationFlg = true;
                  i = this.getMasterRecordList.data.length;
                  break;
                }
              }
              // mod IES_6711 【試験T】【結合テスター】調製薬マスター：「並び順表示」修正後保存できない zhou start
              //if (this.getMasterRecordList.data[i].classCd !== undefined){
              if (this.getMasterRecordList.data[i].classCd !== undefined && this.getMasterRecordList.data[i].classCd !== null){
                // mod IES_6711 【試験T】【結合テスター】調製薬マスター：「並び順表示」修正後保存できない zhou end
                if(tempData[j].classCd.toString() == this.getMasterRecordList.data[i].classCd){
                  classiFicationFlg = false;
                } else {
                  classiFicationFlg = true;
                  i = this.getMasterRecordList.data.length;
                  break;
                }
              }
            }
          }
        }
      }
      // add 分類区分/分類 修正 王 end

      // add redmine 5702 溶解装置のトレンドグラフ 宋qy start
      if (this.masterPhysicalName === "mst_trend_graph_template" || this.masterPhysicalName === "mst_trend_graph_monitor_set") {
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          if (this.getMasterRecordList.data[i].model === "001" || this.getMasterRecordList.data[i].model === "002") {
            this.getMasterRecordList.data[i].comFormatCd = "";
          } else if (this.getMasterRecordList.data[i].model === "003") {
            this.getMasterRecordList.data[i].comFormatCd = "D";
          } else if (this.getMasterRecordList.data[i].model === "006") {
            this.getMasterRecordList.data[i].model = "003";
            this.getMasterRecordList.data[i].comFormatCd = "I";
          } else if (this.getMasterRecordList.data[i].model === "007") {
            this.getMasterRecordList.data[i].model = "003";
            this.getMasterRecordList.data[i].comFormatCd = "J";
          }
        }
      }
      // add redmine 5702 溶解装置のトレンドグラフ 宋qy end

      // 画面上で医療材料の分類が変更された場合
      if (classiFicationFlg) {
        await this.$ons.notification.alert({
          title: DIALOG_MESSAGES[12000051].title,
          // add 全マスタメッセージ調整 王 start
          // message: "分類が変更されました。透析指示に影響がないことを確認してください"
          message: DIALOG_MESSAGES[12000051].message
          // add 全マスタメッセージ調整 王 end
        });
        this.updateRecordList();
      } else {
        // 更新処理呼び出す
        this.updateRecordList();
      }
      // add FNSI-分類変更のメッセージ表示 李 end
    },

    // 水質検査箇所マスタ 水質調査種別  変更不可 start Du
    async validateWaterSurveyPointValue() {
      let surveyTypeCdList =[];
      this.getMasterRecordList.data.forEach(element =>{
        JSON.parse(this.comparisonRecordModel).forEach(item =>{
          if (element.code == item.code && element.surveyTypeCd != item.surveyTypeCd)
            surveyTypeCdList.push(item);
        });
      });
      if(surveyTypeCdList.length <= 0) {
        return
      }
      let str = surveyTypeCdList.map(
        record => record.code
      );
      let startDateStr = new Date().getFullYear()-1 +"-"+new Date().getMonth()+"-"+new Date().getDate()
      let endDateStr = new Date().getFullYear()+1 +"-"+new Date().getMonth()+"-"+new Date().getDate()
      let startDate = moment(startDateStr).format("YYYYMMDD");
      let endDate = moment(endDateStr).format("YYYYMMDD");
      let url = `waterSurvey/filter`;
      let postParams = {
        startDate,
        endDate,
        listSurveytypeCd: [],
        listBedGroupCd: []
      };
      try {
        this.setLoadingScreenVisible(true);
        const response = await ApiHelper.post(url, postParams);
        response.data.forEach(e =>{
           JSON.parse(e.surveyData).forEach(item =>{
              if (str.includes(item.point_cd) && item.text != "0") {
                this.waterSurveyPointValueFalg = true;
                return
              }
           });
        })
        this.setLoadingScreenVisible(false);
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('MasterRecordComponent.vue', 'validateWaterSurveyPointValue' , error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        this.setLoadingScreenVisible(false);
      }
      // 水質検査箇所マスタ 水質調査種別  変更不可 start Du
    },
    // mod FNSI-分類変更のメッセージ表示 李 start
    updateRecordList() {
      /* add スクロールの位置を維持 楊 start */
      // this.setLastScroll();
      /* add スクロールの位置を維持 楊 end */
      // 調製薬剤マスタ画面の分類が変更されない場合
      if (this.masterPhysicalName === "mst_medicine_mix" || this.masterPhysicalName === "mst_medicine") {
        for (let i = 0; i < this.getUpdateRecordList.length; i++) {
          delete this.getUpdateRecordList[i].classiFicationFlg;
        }
      }

      /* mod EOL対応内部#6937 by zhangruixue 2023-07-07 --start */
      if (this.masterPhysicalName === "mst_infection") {
        for (let i = 0; i < this.getUpdateRecordList.length; i++) {
          delete this.getUpdateRecordList[i].port;
        }
      }
      /* mod #6937 by zhangruixue 2023-07-07 --end */

      // apiをコールして値を保存
      this.updateRecordListByFacilityCd({facilityCd: this.facilitylistValue, request: this.getUpdateRecordList})
        .then(async response => {
          this.updateResponse = response.data;
          // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
          if (this.masterPhysicalName === "mst_treatment") {
            this.sendSetUpdateFlag();
            // this.masterSynchroIndCondInfo(this.getUpdateRecordList, this.comparisonRecordModel)
            // add #7327 治療方法マスタ操作時の動作がおかしい 付 start
            // mod #7327 削除の時エーラメッセージを処理する 徐博 start
            const editRecord = this.getUpdateRecordList.filter(item => (item.operation === 1 && item.edited) || item.operation === 2)
            const comparisonRecord = JSON.parse(this.comparisonRecordModel)
            editRecord.forEach(item => {
              // add 9664 by kangjie 20231211 start
              item.selectedDoctorNo = this.indUserId;
              // add 9664 by kangjie 20231211 end
              const oldItem = comparisonRecord.find(t => t.code === item.code);
              if(oldItem){
                item.oldTreatmentConditionSetting = oldItem.treatmentConditionSetting;
              item.oldDeviceMode = oldItem.deviceMode;
                }
            });
            ApiHelper.put(
              `/mst_treatment/updateOrdMainForTreatment/${this.facilitylistValue}`,
              editRecord
            )
            let count = 0
            for (const item of editRecord) {
              if (item.isDisp === "0") {
                count += 1
              }
            }
            if (count !== editRecord.length  && this.getUpdateRecordList.length === this.oldLocalDataSource.length ) {
              // mod #7327 治療方法マスタ操作時の動作がおかしい 付 start
              // let changetips = null
              let msg = ''
              // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --start /
              let cdList = []
              for(let i =0;i<editRecord.length;i++){
                cdList.push(editRecord[i].code);
              }
              const resp = await ApiHelper.post(`/mst_treatment/getOrdMainByCds`,cdList)
              // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --end /
              // del 9664 by kangjie 20231214 start
              // for (let i = 0; i < editRecord.length; i++) {
              //   // changetips = await ApiHelper.get(`/mst_treatment/getOrdMainByCd/${editRecord[i].code}`)
              //   // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --start /
              //   if (resp.data && resp.data[editRecord[i].code]> 0) {
              //     // mod #7327 治療方法マスタ操作時の動作がおかしい 王永吉 start
              //     // msg += this.oldLocalDataSource.find(item => item.code === editRecord[i].code).name + 'を' + '<br/>'
              //     // msg += editRecord[i].name + 'に変更しました。' + '<br/>'
              //     msg +=　'治療方法：' + editRecord[i].name + 'を変更しました。' + '<br/>'
              //     // mod #7327 治療方法マスタ操作時の動作がおかしい 王永吉 end
              //     if(i === editRecord.length-1){
              //       this.setLoadingScreenVisible(false);
              //     }
              //     // add by zhaoqj 2023-03-29 [#8495] 解決フライアウト早期クローズと一括クエリーの変更 --end /
              //   }
              //   // changetips = null
              // }
              // this.$ons.notification.alert({
              //   // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              //   // title: "更新完了",
              //   // message: msg + '指示内容を再確認してください。'
              //   title: DIALOG_MESSAGES[12000106].title,
              //   message: messageFormat(DIALOG_MESSAGES[12000106].message, msg),
              //   // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              // });
              // del 9664 by kangjie 20231214 end
              // mod #7327 治療方法マスタ操作時の動作がおかしい 付 end
            // 内部 治療法マスタ:新規モード保存後はメ~セ~ジの内容が不正です start
            } else {
              this.setLoadingScreenVisible(false);
              this.$ons.notification.alert({
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "更新完了",
                // message: "マスタ更新が完了しました。"
                title: DIALOG_MESSAGES[12000004].title,
                message: messageFormat(DIALOG_MESSAGES[12000004].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
              // 内部 治療法マスタ:新規モード保存後はメ~セ~ジの内容が不正です end
            }
            // mod #7327 削除の時エーラメッセージを処理する 徐博 end
            // add #7327 治療方法マスタ操作時の動作がおかしい 付 end
          } else {
            if (this.masterPhysicalName === "mst_exam_item") {
              // add #8344 【デグレ】チェックリストマスタの保存までが長い dou start
              this.setLoadingScreenVisible(true);
              // add #8344 【デグレ】チェックリストマスタの保存までが長い dou end
              this.masterSynchroOrder();
            } else if (this.masterPhysicalName === "mst_alarm_notification") {
              const facilityCds = this.getMasterRecordList.data
                .map(currentVal => currentVal.destinationFacilityCd)
                .filter((currentVal, index, self) => {
                  return self.indexOf(currentVal) === index;
                });
              this.synchroMstAlermToDeviceEdge(facilityCds, 0);
            } else {
              this.setLoadingScreenVisible(false);
              this.$ons.notification.alert({
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // title: "更新完了",
                // message: "マスタ更新が完了しました。"
                title: DIALOG_MESSAGES[12000004].title,
                message: messageFormat(DIALOG_MESSAGES[12000004].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
          }
          // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end
          this.findList();
        })
        .catch(error => {
          this.setLoadingScreenVisible(false);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          getErrorMessage('MasterRecordComponent.vue', 'updateRecordListByFacilityCd' , error);
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        })
    },
    // mod FNSI-分類変更のメッセージ表示 李 end
    // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s start
    masterSynchroIndCondInfo(updateRecordList, comparisonRecordModel) {
      const editRecord = updateRecordList
        .filter(item => (item.operation === 1 && item.edited) || item.operation === 2)

      const comparisonRecord = JSON.parse(comparisonRecordModel)

      editRecord.forEach(item => {
        const oldItem = comparisonRecord.find(t => t.code === item.code)
        if (oldItem) item.oldDeviceMode = oldItem.deviceMode
      })

      ApiHelper.put(
        `/mst_treatment/updateOrdMainForTreatment/${this.facilitylistValue}`,
        editRecord
      )
    },
    // add 治療方法マスタ 4・条件項目の対象を変更した場合の条件送信未実施治療予定および自動延長用パターンデータへの不足jsonキーの配布 孔s end
    // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
    formatValue(dataItem, column) {
      if (this.masterPhysicalName == "mst_monitor_graph" && ["leftGraphUpperLimit", "leftGraphLowerLimit", "rightGraphUpperLimit", "rightGraphLowerLimit"].includes(column.field)) {
        const dataIndexObj = {
          leftGraphUpperLimit: {
            dataIndex: dataItem.leftDataIndex
          },
          leftGraphLowerLimit: {
            dataIndex: dataItem.leftDataIndex
          },
          rightGraphUpperLimit: {
            dataIndex: dataItem.rightDataIndex
          },
          rightGraphLowerLimit: {
            dataIndex: dataItem.rightDataIndex
          },
        };
        if (dataIndexObj[column.field]?.dataIndex) {
          const sysMonitorItemObj = this.sysMonitorItemList.find(item => item.moni_data_no == dataIndexObj[column.field].dataIndex);
          if (!sysMonitorItemObj) {
            return dataItem[column.field] ?? "";
          }
          const decimals = sysMonitorItemObj.decimal_figure;
          return dataItem[column.field] != null ? Number(dataItem[column.field]).toFixed(decimals) : "";
        }
      }
      // #11241 11047残バグ：数値入力欄がnullと表示する linjunfeng start
      // return dataItem[column.field];
      let value = dataItem[column.field] ?? "";
      if (value !== "") {
        value = BigNumber(value).toFixed();　// 指数表記を通常表記に変換
      }
      return value;
      // #11241 11047残バグ：数値入力欄がnullと表示する linjunfeng end
    },
    // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
    // マスタ同期（警報通知マスタ）
    synchroMstAlermToDeviceEdge(facilityCds, idx) {
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 start
      // let title = `${this.getLogicalMasterName}同期`;
      let title = messageFormat(DIALOG_MESSAGES['00100009'].title, this.getLogicalMasterName);
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 end
      if (facilityCds.length <= idx) {
        return;
      }
      const facilityCd = facilityCds[idx];

      // マスタ同期
      this.setLoadingScreenVisible(true);
      this.startMstSynchro({
        mstTable: this.mstSynchroApiParams.mstTable,
        facilityCd: facilityCd,
        deviceEdgeNo: this.mstSynchroApiParams.deviceEdgeNo
      })
        .then(() => {
          if (facilityCds.length === idx + 1) {
            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            if (this.errorNameMstAlerm.length > 0){
              let name = "";
              this.errorNameMstAlerm.forEach(e => {
                name = name + e.text + "</br>";
              });
              name = "デバイスエッジ：</br>" + name + "</br>";
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            } else {
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message: "マスタ同期が完了しました。"
                message: messageFormat(DIALOG_MESSAGES['00100009'].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
            this.errorNameMstAlerm = [];
          } else {
            // 次の施設
            this.synchroMstAlermToDeviceEdge(facilityCds, idx + 1);
          }
        })
        .catch(error => {
          getErrorMessage('MasterRecordComponent.vue', 'synchroMstAlermToDeviceEdge' , error);
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            for (const edge of error.response.data.failedDeviceEdgeList) {
              this.errorNameMstAlerm.push(edge.deviceName);
            }
            if (facilityCds.length === idx + 1) {
              let name = "";
              this.errorNameMstAlerm.forEach(e => {
                name = name + e + "</br>";
              });
              name = "デバイスエッジ：</br>" + name + "</br>";
              //共通ローダー：表示終了
              this.setLoadingScreenVisible(false);
              //共通ローダー：表示終了
              this.$ons.notification.alert({
                title: title,
                 // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   "<div style='max-height: 60vh; overflow-y: auto;'>" + name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。</div>"
                //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
                // message: messageFormat(`${DIALOG_MESSAGES[12000320].message}</div>`, `<div style='max-height: 60vh; overflow-y: auto;'>${name}}`),
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
                //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
              this.errorNameMstAlerm = [];
            } else {
              // 次の施設
              this.synchroMstAlermToDeviceEdge(facilityCds, idx + 1);
            }
          }
        });
    },
    // マスタ同期（検査項目マスタ）
    masterSynchroOrder() {
      // ADD 検査項目マスタ-別施設のデバイスエッジとの同期ができなかったと表示される cuifc
      let facilityCdStr = this.getFacilitySwitch
      this.getMasterDeviceEdgeNoListByFacilityCd(facilityCdStr).then(res => {
        let array = res.data;
        if (array && array.length > 0) {
          array =  array.sort((a,b) => {
            if (a.deviceEdgeNo < b.deviceEdgeNo) return -1;
            if (a.deviceEdgeNo > b.deviceEdgeNo) return 1;
            return 0;
          })
          this.synchroMstToDeviceEdge(array, 0);
        }
      })
    },
    showRecalculationModal() {
      this.findList();
      this.showMstExamItemRecManagementModal();
    },
    // 指定したデバイスエッジとのマスタ同期
    synchroMstToDeviceEdge(list, idx) {
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 start
      // let title = `${this.getLogicalMasterName}同期`;
      let title = messageFormat(DIALOG_MESSAGES['00100009'].title, this.getLogicalMasterName);
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 end
      const infos = list;
      if (infos.length <= idx) {
        return;
      }
      const info = infos[idx];
      let name = "デバイスエッジ：" + this.errorMessage + "</br></br>";

      // マスタ同期
      this.mstSyncDeviceEdge({
        facilityCd: null,
        deviceEdgeNo: info.deviceEdgeNo
      })
        .then(() => {
          if (infos.length === idx + 1) {
            name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            if (this.errorMessage === "") {
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message: "マスタ同期が完了しました。
                message: messageFormat(DIALOG_MESSAGES['00100009'].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            } else {
              // 共通ローダー：表示終了
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
            this.errorMessage = "";
          } else {
            // 次のデバイスエッジ
            this.synchroMstToDeviceEdge(list, idx + 1);
          }
        })
        .catch(error => {
          if (this.errorMessage === "") {
            this.errorMessage += "</br>" + info.deviceName + "</br>";
          } else {
            this.errorMessage += info.deviceName + "</br>";
          }
          this.synchroMstToDeviceEdge(list, idx + 1);
          if (infos.length === idx + 1) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MasterRecordComponent.vue', 'synchroMstToDeviceEdge' , error);
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            this.setLoadingScreenVisible(false);
            if (error.response.status === 400) {
              name = "デバイスエッジ：" + this.errorMessage + "</br></br>";
              // 共通ローダー：表示終了
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
              this.errorMessage = "";
              this.setLoadingScreenVisible(false);
            }
          }
        });
    },
    addRow(holidayNkkYear, holidayNkkCode) {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
      Object.keys(fields).forEach(k => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          // modify start #9301
          if (['medicateTimingCd', 'procedureCd'].includes(k)) {
            d[k] = null;
          } else {
            d[k] = "";
          }
          // modify end #9301
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (fields[k].type === "date") {
          d[k] = new Date();
        } else if (fields[k].type === "color") {
          d[k] = "#000000";
        } else if (fields[k].type === "textarea") {
          d[k] = "";
        } else {
          d[k] = null;
        }
        d["isAddRow"] = true;
        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
        /* mod EOL対応内部 #6927 by ztc 2023-07-08 --start */
        if (k === "facilityCd") {
          d[k] = this.facilitylistValue;
        }
        /* mod EOL対応内部 #6927 by ztc 2023-07-08--end */
      });
		  // add #7003-ダイアライザマスタ・医療材料マスタの新規登録時の使用開始日と使用終了日の初期値に当日の日付が設定される 徐博 start
      if (this.masterPhysicalName === "mst_dialyzer") {
        d.useStartDate = ""
        d.useEndDate = ""
      }
      // add #7003-ダイアライザマスタ・医療材料マスタの新規登録時の使用開始日と使用終了日の初期値に当日の日付が設定される 徐博 end
      // add #7300-マスタ新規追加時に利用開始日/使用開始日/使用終了日にデフォルト値が入る 徐博 start
      if (this.masterPhysicalName === "mst_equipment") {
        d.useStartDate = ""
        d.useEndDate = ""
      }
      if (this.masterPhysicalName === "mst_treatment") {
        d.inHospAStartdate = ""
        d.inHospBStartdate = ""
      }
      if (this.masterPhysicalName === "mst_procedure") {
        d.inHospAStartdate = ""
        d.inHospBStartdate = ""
      }
      // add #7300-マスタ新規追加時に利用開始日/使用開始日/使用終了日にデフォルト値が入る 徐博 end
      if (this.masterPhysicalName === "mst_pat_viewer_layout") {
        d.dispItemInfo = JSON.stringify(mstPatViewerLayout);
      }
      if (this.masterPhysicalName == "mst_holiday") {
        d.class = "0";
      }
      if(holidayNkkYear && holidayNkkCode){
        d.year = holidayNkkYear;
        d.code = holidayNkkCode;
      }
      if (this.masterPhysicalName == "mst_medicine_mix") {
        d.classCd = -1;
        // add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 susny start
        d.medicineSetNum = 1;
        // add #11801 治療条件.抗凝固剤に調整薬剤をセットしたときに配布リストの出力が不適切 susny end
      }

      if (this.masterPhysicalName === "mst_water_survey_type") {
        d.initialString = JSON.stringify(deepCopy(MST_DEFAULT_VALUE.mst_water_survey_type));
      }
      if (this.masterPhysicalName === "mst_mainte_category") {
        d.detail = JSON.stringify(deepCopy(MST_DEFAULT_VALUE.mst_mainte_category));
        d.mainteClass = MainteClass.Daily;
      }
      if (this.masterPhysicalName === "mst_mainte_layout") {
        d.detailInfo1 = JSON.stringify([]);
        d.layoutClass = MainteClass.Daily;
      }
      if (this.masterPhysicalName === "mst_pat_calendar_layout") {
        d.dispItemInfo = JSON.stringify(deepCopy(MST_DEFAULT_VALUE.mst_pat_calendar_layout));
      }
      if (this.masterPhysicalName == "mst_addition") {
        // 加算マスタ の 算定回数上限 の defaultValue が null または undefined の場合は
        // 初期値を null として、詳細画面での初期値は空欄となるようにする
        if (fields.additionLimit?.defaultValue == null) {
          d.additionLimit = null;
        }
      }
      if (this.masterPhysicalName === "mst_url_link_register") {
        d.urlInfo = JSON.stringify(deepCopy(MST_DEFAULT_VALUE.mst_url_link_register.urlInfo));
      }      
      if (this.masterPhysicalName === "mst_menu_group") {
        d.iconInfo = JSON.stringify(deepCopy(MST_DEFAULT_VALUE.mst_menu_group.iconInfo));
      }

      // データ行を一番下に追加してスクロールダウン
      this.lastScrollTop = this.$refs.grid.$el.lastChild.scrollHeight;

      this.edit({ editRecord: d, isSortMode: this.isSortMode, isHolidayNkk:holidayNkkYear ? true : undefined});
      this.dataSourceItems = this.generatedGridData();
      this.isRecordModified && this.editBackgroundColor(this.masterPhysicalName);
      // add 医療材料セットマスタ 追加の時、スクロール位置を取得 start 鞠
      if (this.masterPhysicalName == "mst_equipment") {
        const grid = $("div.k-grid-content")[0];
        this.scrollPosition.left = grid.scrollLeft;
      }
      // add 医療材料セットマスタ 追加の時、スクロール位置を取得 end 鞠
    },
    loadGridData(){
      // add #8541 ベッドグループ・透析室マスタ画面にて、虫眼鏡に抽出条件を入力後、検索すると、【透析室・ベッドグループ名】列が隠される。 付 start
      // delete start #9590
      // if (this.masterPhysicalName !== 'mst_room_bed_group') {
      //   // add マスタ障害対応 No43 孔 start
      //   EventBus.$emit("clearHeaderSearch");
      //   // add マスタ障害対応 No43 孔 start
      //   this.setCondition(this.condition);
      // }
      // delete end #9590
      // add #8541 ベッドグループ・透析室マスタ画面にて、虫眼鏡に抽出条件を入力後、検索すると、【透析室・ベッドグループ名】列が隠される。 付 start
      this.findList();
    },
    getMstMonitorData() {
      /* ===== 2024-07-04 #9312 Mod Start ===== */

      // ApiHelper.get("/mstInfo/mstPatViewerLayout/monitorItem", {
      //   facilityCd: this.getFacilitySwitch,
      //   /* add by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --start */
      //   // クエリー条件を追加し、モニタータイプのみをクエリーする
      //   vitalMonitorClass: "2"
      //   /* add by chamaojia 2023-06-05 モニタレイアウトマスタ下拉框可以选择バイタル的项目  --end */
      // }).then(response => {

      const mstAddMonitorRequestParam = {
        facility_cd: this.getFacilitySwitch,
        vital_monitor_class: ""
      }

      Promise.all([
        // this api return this particular result for this element.
        ApiHelper.get("/treatment-record/particularSMItems/treatment-graph"),
        ApiHelper.get("/mstInfo/mstAddMonitorByClass", mstAddMonitorRequestParam),
      ]).then(response => {
//         let selectVitalMonitorItemList = response;
//         //selectVitalMonitorItemListのフィルタ条件を削除します xiemj add start
//         // selectVitalMonitorItemList.data = selectVitalMonitorItemList.data.filter(item => (item.vitalMonitorClass == 2))
//         //selectVitalMonitorItemListのフィルタ条件を削除します xiemj add end
//         for (let i = 0; i < selectVitalMonitorItemList.data.length; i++) {
//           if (selectVitalMonitorItemList.data[i].tableType === 2) {
//             selectVitalMonitorItemList.data[i].moniDataNo = "MST" + selectVitalMonitorItemList.data[i].moniDataNo;
//             selectVitalMonitorItemList.data[i].upper = 0;
//             selectVitalMonitorItemList.data[i].lower = 0;
//           }
//         }
//         this.mstMonitorInitial = selectVitalMonitorItemList.data;
//         let dataSource = [{
//           value: "",
//           text: ""
//         }];
//         // 8574 add 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
//         const DISPLAYLIST=['31','0','A1','D1','Z11','Z21','Z232','Z364','I1','J1']
//         // 8574 add 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
//         selectVitalMonitorItemList.data.forEach((item) => {
// // 8574 add 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 start
//           if(!DISPLAYLIST.includes(item.moniDataNo)){
//             dataSource.push({
//               value: item.moniDataNo,
//               text: item.vitalMonitorItemName
//             })
//           }
// // 8574 add 患者経過総合ビューアにてグラフ項目が正しく表示されない 張 end
//         })

        // 透析：モニタ項目
        const sysMonitorItem = response[0].data ? response[0].data : [];
        // 施設固有：バイタル・モニタ個別項目
        const mstAddMonitor = response[1].data ? response[1].data : [];
        // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng start
        this.sysMonitorItemList = sysMonitorItem;
        // add #11047 No7 治療記録モニタグラフマスタ＞詳細 左グラフ上限 左グラフ下限 右グラフ上限 右グラフ下限 マイナス値の入力ができない。linjunfeng end
        let monitorItemList = sysMonitorItem.filter( s => s.is_disp === '1' )
          .map( item => {
            return {
              value: item.moni_data_no,
              text: item.moni_data_name
              // text: item.moni_data_short_name
            }
          });

        mstAddMonitor.forEach(
          mst => {
            if (mst.is_disp === '1') {
              monitorItemList.push({
                value: "MST" + mst.vital_monitor_item_cd,
                text: mst.vital_monitor_item_name
              })
            }
          }
        );

        this.mstMonitorGraphItem = monitorItemList;
      });
    },
    // redmine 5344 日常点検を選択した場合も内容3が登録できる 宋qy start
    stringEditor(container, data) {
      if (this.masterPhysicalName == "mst_mainte_detail" && (!data.model.mainteClass || data.model.mainteClass == "1")) {
        return;
      } else {
        $(`<input type="text" name="${data.field}" class="k-input k-textbox k-valid"/>`).appendTo(container);
      }
    },
    // redmine 5344 日常点検を選択した場合も内容3が登録できる 宋qy end
    
    /**
     * 患者カレンダーレイアウトマスタで
     * categoryItem + vitalChild を表示状態に応じて正規化し、治療情報のcategoryItem 用の配列を返す
     */
    buildCategoryItemsVitalMonitor(categoryItem) {
      const result = [];
    
      const targets = [
        categoryItem,
        ...(categoryItem.vitalChild ?? [])
      ];
    
      targets.forEach((item, index) => {
        // 中項目のisDispがOFF、かつ、subCategoryItem が 1件も無い場合は追加しない
        if (!item.isDisp && (!Array.isArray(item.subCategoryItem) || item.subCategoryItem.length === 0)) {
          return;
        }

        delete item.isDispflag;
  
        item.subCategoryItem?.forEach(sub => {
          delete sub.isDisp;
          delete sub.isDispflag;
        });
  
        // 先頭（N-1）のみ vitalChild を削除
        if (index === 0) {
          delete item.vitalChild;
        }
  
        result.push(item);

      });
    
      return result;
    }
  },
  async created() {
    this.facilityHemoDialysis = this.getAdvancedSettings.func_advcds.some(
      setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
    );
    this.setLoadingScreenVisible(true);
    // apiをコールして施設一覧を取得

    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // this.findFacilityList();
    if (this.getFacilitySwitch !== "") {
      this.facilitylistValue = this.getFacilitySwitch;
    }
    // add start #9301
    if (this.masterPhysicalName === 'mst_medicine_mix') {
      this.getDefaultCd();
    }
    // add end #9301
    if (this.masterPhysicalName == "mst_holiday" && this.getFacilitySwitch != "nkknkk") {
      let responseData = "";
      await sendRequestFindRecordListByFacilityCd("mst_holiday","nkknkk").then(
        response => {
          responseData = response.data.localDataSource.data;
        }
      );
      this.mstHolidayNkkData = responseData;
    }
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
    this.calculateColumnsWidth();

    // add 治療記録モニタグラフマスタ 項目不正 start
    if (this.masterPhysicalName === "mst_monitor_graph") {
      this.getMstMonitorData();
      if (this.mstMonitorGraphItem.length === 0) {
        setTimeout(() => {
          this.loadGridData();
        },1500)
      } else {
        this.loadGridData();
      }
    } else {
      this.loadGridData();
    }
    // add 治療記録モニタグラフマスタ 項目不正 end

    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
    if (this.masterPhysicalName === "mst_treatment_set") {
      // #11375 治療方法セットマスタの投与薬剤の薬剤選択が開かない。 linjunfeng start
      // this.getMstMedicineIncludeDeleted({ facilityCd: this.facilityCd });
      // this.getMstMedicineMixIncludeDeleted({ facilityCd: this.facilityCd });
      // this.getMstProcedure({ facilityCd: this.facilityCd });
      // this.getMstMedicateTiming({ facilityCd: this.facilityCd });
      this.getMstMedicineIncludeDeleted({ facilityCd: this.getFacilitySwitch });
      this.getMstMedicineMixIncludeDeleted({ facilityCd: this.getFacilitySwitch });
      this.getMstProcedure({ facilityCd: this.getFacilitySwitch });
      this.getMstMedicateTiming({ facilityCd: this.getFacilitySwitch });
      // #11375 治療方法セットマスタの投与薬剤の薬剤選択が開かない。 linjunfeng end
    }
    // add #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // add #8541 ベッドグループ・透析室マスタ画面にて、虫眼鏡に抽出条件を入力後、検索すると、【透析室・ベッドグループ名】列が隠される。 付 start
    await this.setCondition(this.condition)
    // add #8541 ベッドグループ・透析室マスタ画面にて、虫眼鏡に抽出条件を入力後、検索すると、【透析室・ベッドグループ名】列が隠される。 付 end
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    // EventBus.$on("refresh", this.refresh);

  },
  updated() {
    if (!this.isRecordModified) {
      const kDirtyCell = document.getElementsByClassName('k-dirty');
      if (kDirtyCell.length > 0) {
        for(let i=0; i<kDirtyCell.length; i++){
          kDirtyCell[i].setAttribute('class', '');
        }
      }
    }
    // Storeの更新等で画面が再描画された場合に背景色を変更
    // #8519 【デグレ】編集した項目のバッググラウンドが黄緑にならない 訾浩 start
    this.isRecordModified && this.editBackgroundColor();
    // #8519 【デグレ】編集した項目のバッググラウンドが黄緑にならない 訾浩 end
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
    EventBus.$on("refresh", this.refresh);
  },
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    if (this.resizeObserver != null) {
      this.resizeObserver.disconnect();
      this.resizeObserver = null;
    }
    this.setMasterRecordList([])
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
  overflow: auto;
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
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.csv-btn {
  margin-right: 1em;
}
.k-grid-toolbar {
  padding: 0.1em 0.3em;
}
.kendo-grid-toolbar-style >>> .k-tooltip.k-tooltip-validation {
  width: auto;
}

.kendo-grid-toolbar-style
  >>> .k-grid
  tr:nth-child(n + 3):last-child
  .k-tooltip.k-tooltip-validation
  .k-callout {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}

.kendo-grid-toolbar-style
  >>> .k-grid
  tr:nth-child(n + 3):last-child
  .k-tooltip.k-tooltip-validation {
  bottom: 38px;
}
/* 内部 患者経過総合ビューアレイアウトマスタ】最後から2行目レイアウト名は空にしなければならないとmessage表示します start */
.kendo-grid-toolbar-style
  >>> .k-grid
  tr:nth-last-child(2):nth-child(n + 2)
  .k-tooltip.k-tooltip-validation {
  bottom: 38px;
}
.kendo-grid-toolbar-style
  >>> .k-grid
  tr:nth-last-child(2):nth-child(n + 2)
  .k-tooltip.k-tooltip-validation
  .k-callout {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}
/* 内部 患者経過総合ビューアレイアウトマスタ】最後から2行目レイアウト名は空にしなければならないとmessage表示します end */
.kendo-grid-toolbar-style >>> .k-edit-cell {
  position: relative;
  overflow: visible;
}

.kendo-grid-toolbar-style >>> .k-grid-content > .k-selectable {
  box-shadow: 1px 0px 0px 0px white;
  border-right: 1px solid transparent;
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

.kendo-grid-toolbar-style >>> .k-grid-header-locked > table {
  border-right-width: 0px;
}

.kendo-grid-toolbar-style >>> .k-grid-content-locked > .k-selectable {
  border-right-width: 0px;
}


@media print {
  .print-grid-style >>> .k-grid {
    border: none !important;
  }
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
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
</style>
