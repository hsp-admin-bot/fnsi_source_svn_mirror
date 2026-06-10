/**
 * 患者イベントサブカテゴリマスタ  mst_pat_event_sub_category
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class="ntss-list" :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button
            modifier="outline"
            class="btn3-normal toolbar-btn"
            style="float: left;"
            v-show="!isSortMode && isAllowAddRecord"
            @click="addRow()"
          >追加</v-ons-button>
          <!-- del マスタ一覧 1･施設切替を可能とする 王 start -->
          <!--          <kendo-dropdownlist-->
          <!--            ref="dropDownList"-->
          <!--            v-if="isMasterUser"-->
          <!--            v-model="facilitylistValue"-->
          <!--            :data-source="facilities"-->
          <!--            :data-text-field="'facilityName'"-->
          <!--            :data-value-field="'facilityCd'"-->
          <!--            :filter="'contains'"-->
          <!--            @open="onOpenFacility"-->
          <!--            @change="onChangeFacility"-->
          <!--            style="width: 13em;"-->
          <!--          ></kendo-dropdownlist>-->
          <!-- del マスタ一覧 1･施設切替を可能とする 王 end -->
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 7em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <v-ons-button
            modifier="outline"
            class="btn3-normal toolbar-btn csv-btn"
            v-show="!isSortMode && isAllowAddRecord && !iosFlg && !androidFlg"
            @click="importCsv()"
          >CSV取込</v-ons-button>
          <v-ons-button
            modifier="outline"
            class="btn3-normal toolbar-btn"
            v-show="!isSortMode && isAllowSort"
            @click="toRankEditBtnClick()"
          >並び順表示</v-ons-button>
          <v-ons-button
            modifier="outline"
            class="btn3-normal toolbar-btn"
            v-show="isSortMode && isAllowSort"
            @click="sortBtnClick()"
          >反映</v-ons-button>
        </div>
        <kendo-grid
          ref="grid"
          :class="fontSizeSet"
          :data-source="masterRecords"
          :editable="true"
          :selectable="true"
          :reorderable="false"
          :height="kendoGridHeight"
          :scrollable="true"
          :beforeEdit="modifyEditStart"
          :edit="addInputAssist"
          :cellClose="editEnd"
          @save="useTypeSave"
          @databound="onDataBoundKendoGrid"
        >
          <template v-for="(column, index) in columns">
            <kendo-grid-column
              v-if="column.field === '$modalType'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :attributes="{ class: 'btn3-kendo-normal' }"
              :locked="column.locked"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              :command="{ text: '選択', click: showMasterEditModalTransit }"
            ></kendo-grid-column>
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
            <kendo-grid-column
              v-else-if="column.dataType === 'date'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :locked="column.locked"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              @editor="eachModelCalendar"
            ></kendo-grid-column>
            <kendo-grid-column
              v-else-if="column.dataType === 'color'"
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
              @editor="colorEditor"
            ></kendo-grid-column>
            <kendo-grid-column
              v-else-if="column.dataType === 'textarea'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :locked="column.locked"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              @editor="textareaEditor"
            ></kendo-grid-column>
            <kendo-grid-column
              v-else-if="column.dataType === 'number'"
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
              @editor="numericEditor"
            ></kendo-grid-column>
            <kendo-grid-column
              v-else-if="column.field === 'templateCd'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :locked="column.locked"
              :editable="checkUseType"
              :width="column.width"
              :format="column.format"
              :values="column.values"
            ></kendo-grid-column>
            <kendo-grid-column
              v-else
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :locked="column.locked"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
            ></kendo-grid-column>
          </template>
        </kendo-grid>
      </kendo-grid-toolbar>
      <div id="grid-footer">
        <v-ons-row width="100%" v-show="!isSortMode">
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel button denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="btn1-execute button registration-btn"
              style="width: auto;"
              :disabled="!isChanged"
              @click="saveRecord"
            >保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
      <master-csv
        :popoverVisible="masterCsvVisible"
        :popoverTarget="masterCsvTarget"
        @popover-close="prehideCsvPopover"
      />
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import $ from "jquery";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import Vue from "vue";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import { ApiHelper } from "@/apis/AxiosHelper.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
  components: {
    "master-csv": MasterCsvComponent,
  },
  data() {
    return {
      recordList: [],
      // 初期状態で1列がないとその後の表示が行われないため初期列を定義
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
      condition: {
        recordName: "",
        includeDeleted: false,
      },
      updateResponse: {
        isSuccess: false,
        errorMessage: "",
      },
      isSortMode: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {},
      },
      mstSynchroApiParams: {
        mstTable: "mst_m_notice",
        deviceEdgeNo: -1,
      },
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0,
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
      reportlist:[],
      userType: "",
      lastScrollTop: 0,
      lastScrollLeft: 0,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth",
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
    }),
    ...mapGetters("user", ["getAdvancedSettings"]),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    ...mapGetters("master-maintenance", {
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
      getFacilityList: "getFacilityList",
      getFacilitySwitch: "getFacilitySwitch"
    }),
    facilities() {
      // storeからデータを取得
      return this.getFacilityList;
    },
    isMasterUser: {
      get() {
        return this.getStateUserAccountInfo.userType === 1 ? true : false;
      },
      set() {},
    },
    masterRecords() {
      // storeからデータを取得
      //add FNSI-改修内容テンプレートマスタ、カテゴリマスタにデータがない場合、サブカテゴリマスタのテンプレートとカテゴリ項目に表示されたCDを空白に修正必要 任 start
      this.columns.forEach((column) => {
        if (column.field === "categoryCd" && column.values.length === 0) {
          this.getFilteredMasterRecordList.data.forEach((item) => {
            item.categoryCd = null;
          });
        } else if (
          column.field === "templateCd" &&
          column.values.length === 0
        ) {
          this.getFilteredMasterRecordList.data.forEach((item) => {
            item.templateCd = null;
          });
        }
        // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
        // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
        // if (column.locked && column.dataType === "string" && column.field === "name") {
        //       column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width * 15
        //     }
        // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
        // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
      });
      //add FNSI-改修内容テンプレートマスタ、カテゴリマスタにデータがない場合、サブカテゴリマスタのテンプレートとカテゴリ項目に表示されたCDを空白に修正必要 任 end
      if (this.getFilteredMasterRecordList.data) {
          this.getFilteredMasterRecordList.data.forEach((item) => {
              //if(item.useType == "3"){
                  // this.getFilteredMasterRecordList.schema.model.fields.templateCd.validation.required = false;
                  //item.templateCd = null;
              if(item.useType == "3" && item.templateCd && item.templateCd.toString().indexOf('a') < 0 ) {
                  item.templateCd = 'a'+item.templateCd;
              }else{
                // this.getFilteredMasterRecordList.schema.model.fields.templateCd.validation.required = true;
                //item.dispItemInfo = null;
                  if (item.templateCd == null) {
                    item.templateCd = "";
                  }
              }

          });

      }
      return this.getFilteredMasterRecordList;
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (this.isRecordModified || this.kendoValidator && !this.kendoValidator.validate())
      );
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  watch: {
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
      "getDeviceEdgeNoList",
      "mstSyncDeviceEdge",
      "findRecordListByFacilityCd",
    ]),
    ...mapActions("master-maintenance", {
      facilityList: "facilityList",
    }),
    DisableDetailBtn() {
      if (this.$refs.grid.$el.lastChild.lastChild.tBodies != null && this.$refs.grid.dataSource.data) {
        const tbodyc = this.$refs.grid.$el.lastChild.lastChild.tBodies[0].children;
        const gridData = this.$refs.grid.dataSource.data;
        gridData.forEach((dataRow, index) => {
          // ログインユーザの行を無効化
          if (dataRow.useType != "3" && tbodyc[index].children[5]) {
            // ログインユーザの管理者／ID/PWリセット/ロック解除/削除機能を無効化
            tbodyc[index].children[5].children[0].style.display = "none"
          }
        });
      }
    },
    checkUseType(e) {
      if (e.useType == "") {
        return false;
      }
      return true;
    },
	//テンプレート データ設定
    modifyEditStart(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      if (e.model.useType == '3'){
        e.sender.columns[7].values = this.columns[7].values.filter(element => element.isReport);
      }else if (e.model.useType == '') {
        e.sender.columns[7].values = [];
      }else{
        e.sender.columns[7].values = this.columns[7].values.filter(element => !element.isReport);
      }
      this.editStart(e);
    },
    useTypeSave(e) {
      if (e.values.useType && e.values.useType != e.model.useType){
        e.model.templateCd = "";
      }
      this.onSave(e);
    },
    showMasterEditModalTransit(e) {
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      if (selectedRowItem.useType == "3") {
        this.showMasterEditModal(e);
      }
    },
    // グリッドのデータ再表示
    gridDataRefresh() {
      const grid = this.$refs.grid;
      grid.dataSource = this.masterRecords;
    },
    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        // add マスタ一覧 1･施設切替を可能とする 王 start
        // this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
        this.facilitylistValue = this.getFacilitySwitch;
        // add マスタ一覧 1･施設切替を可能とする 王 end
        // 選択した施設を元にベッド一覧の取得
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          // add マスタ一覧 1･施設切替を可能とする 王 start
          // this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
          this.facilitylistValue = this.getFacilitySwitch;
          // add マスタ一覧 1･施設切替を可能とする 王 end
          // 選択した施設を元にベッド一覧の取得
          this.findList();
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatEventSubCategoryMainComponent.vue', 'findFacilityList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }
        });
    },
    onOpenFacility(e) {
      // 変更前の値を取得
      this.prevFacilityCd = e.sender._old;
    },
    // 施設を選択時の動作
    onChangeFacility(e) {
      if (this.prevFacilityCd != e.sender._old) {
        // 選択施設の拡張設定を取得
        var newFacilityAdvancedSettings = {};
        let selectedIndex = e.sender.selectedIndex;
        try {
          if (
            e.sender.dataSource.options.data[selectedIndex].advancedSettings
          ) {
            newFacilityAdvancedSettings = JSON.parse(
              e.sender.dataSource.options.data[selectedIndex].advancedSettings
            );
          }
        } catch(error) {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatEventSubCategoryMainComponent.vue', 'onChangeFacility', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          newFacilityAdvancedSettings = {};
        }

        if (!newFacilityAdvancedSettings.func_advcds) {
          newFacilityAdvancedSettings.func_advcds = [];
        }

        const enableHomeDialysis = newFacilityAdvancedSettings.func_advcds.some(
          (setting) => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
        );

        if (this.isChanged) {
          // 編集時は未保存確認メッセージを出力する
          const newFacilityCd = e.sender._old;
          e.preventDefault();
          this.$ons.notification.confirm({
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: (answer) => {
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
            },
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
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount",
    }),
    ...mapActions("mst-synchro", ["startMstSynchro"]),
    eachModelCalendar(container, data) {
      if (this.androidFlg === true) {
        // Androidの場合は、HTML5のカレンダーを表示
        $(`<input type="date" name="${data.field}" />`).appendTo(container);
      } else {
        let moveOutFlg = false;
        container.mouseenter(() => (moveOutFlg = false));
        container.mouseleave(() => (moveOutFlg = true));
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
        nowDtatString =
          nowData.getFullYear() +
          "-" +
          ("0" + (nowData.getMonth() + 1)).slice(-2) +
          "-" +
          ("0" + nowData.getDate()).slice(-2);
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 start
        if (!editedData) {
          nowDtatString = "";
        }
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end
        //#10715：日付IF修正20240910検証NG対応：村上Start
        $(
          `<span style="position:relative"><input type="date" style="width:8em" id="displayedDummyEditor" class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;"/><span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:absolute;left:75%;top:1px;color: #212529;z-index:9999999" ></span></span>`
        ).appendTo(container);
        //#10715：日付IF修正20240910検証NG対応：村上End
        // フォーカスアウトで編集データを反映するイベントを発火
        document
          .getElementById("displayedDummyEditor")
          .addEventListener("blur", function (ev) {
            if (!moveOutFlg) {
              return;
            }

            let resultData;
            const dayData = new Date(ev.target.value);
            // 初期と編集後の値が空欄の場合、更新レコードとして判断しない
            if (ev.target.value === "" && !hasInitValue) {
              resultData = "";
              nowDtatString = "";
              hasInitValue = true;
            } else {
              resultData =
                dayData.getFullYear() +
                "-" +
                ("0" + (dayData.getMonth() + 1)).slice(-2) +
                "-" +
                ("0" + dayData.getDate()).slice(-2);
            }

            // 変更前の値と比較し、同じ値の場合は処理しない。又は、初期値がない場合、必ず処理する。
            if (!hasInitValue || nowDtatString != resultData) {
              document.getElementById(
                "hiddenDateInputEditor"
              ).value = resultData;
              // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
              $(document.getElementById("hiddenDateInputEditor")).trigger(
                "change"
              );
            }
          });

        let commonCalenderPicker = new (Vue.extend(commonCalender))();
        commonCalenderPicker.$on("input", (value) => {
          document.getElementById("hiddenDateInputEditor").value = value;
          // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
          $(document.getElementById("hiddenDateInputEditor")).trigger("change");
        });
        commonCalenderPicker.$mount();
        commonCalenderPicker.setSilently(nowDtatString);
        container.append(commonCalenderPicker.$el);
        //  #5590 2023/05/15 iPadでSafariを使うと、数字に×が被る。修正 張博 start
        const userAgent = window.navigator.userAgent;
        if (userAgent.indexOf("Intel Mac OS") > -1) {
           document.getElementById("displayedDummyEditor").addEventListener("change", (ev) => {
           document.getElementById("hiddenDateInputEditor").value = ev.target.value;
          // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
           $(document.getElementById("hiddenDateInputEditor")).trigger('change');
          //  commonCalenderPicker.setSilently(ev.target.value);
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
    colorEditor(container, data) {
      const dummyField = $("<input/>")
        .attr("name", data.field)
        .css("display", "none")
        .appendTo(container);

      const colorPicker = $("<input/>")
        .appendTo(container)
        .kendoColorPicker({
          value: data.model[data.field],
          palette: "basic",
          tileSize: {
            width: 32,
            height: 24,
          },
          change: (e) => {
            // コンソールにエラーが出るためにnextTickで遅らせている
            this.$nextTick(() => {
              dummyField.val(e.value).trigger("change");
            });
          },
        });

      // パレットを開く
      colorPicker.data("kendoColorPicker").open();
    },
    /**
     * @description textarea(改行可能なテキストボックス)用のkendo editor
     */
    textareaEditor(container, data) {
      $(
        `<textarea name="${data.field}" class="k-valid k-textarea" style="font-size: 1.0em;"/>`
      ).appendTo(container);
    },
    numericEditor(container, options) {
      const format = options.format.slice(3, options.format.length - 1);
      const decimals = format.slice(1);
      $('<input data-bind="value:' + options.field + '"/>')
        .appendTo(container)
        .kendoNumericTextBox({ format, decimals, round: false });
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして値を取得
      this.findRecordListByFacilityCd(this.facilitylistValue)
        .then((response) => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          if (response.data.columns.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message:
              //   "マスタ定義にカラム情報が登録されていません。<BR>カラム情報を登録してください。",
              title: DIALOG_MESSAGES[12000001].title,
              message: messageFormat(DIALOG_MESSAGES[12000001].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              callback: () => {
                this.cancel();
              },
            });
          }

          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach((column) => {
            // 初期表示時の編集可否を退避
            column.originalEditable = column.editable;
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
            if (column.field == "templateCd" ){
              this.reportlist.forEach(item => {
                column.values.push(item)
              }
              )
            }
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach((column) => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : this.columnWidth + "em";
            column.width = column.field === "isDisp" ? "9em" : this.columnWidth + "em";
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
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
            values: null,
          });
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            /* add スクロールの位置を維持 楊 start */
            // mod #9590 start
            // document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop = this.lastScrollTop;
            // document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft = this.lastScrollLeft;
            const ele = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0];
            if (ele) {
              ele.scrollTop = this.lastScrollTop;
              ele.scrollLeft = this.lastScrollLeft;
            }
            // mod #9590 end
            setTimeout(() => {
              this.lastScrollTop = 0;
              this.lastScrollLeft = 0;
            }, 1000);
            /* add スクロールの位置を維持 楊 end */
          });
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          // 色カラムのテンプレート生成
          this.columns
            .filter((column) => column.dataType === "color")
            .forEach((column) => {
              column.colorTemplate = (dataItem) => {
                const value = dataItem[`${column.field}`];
                return `<div style='background-color: ${value}; width: 4em;'>&nbsp;</div>`;
              };
            });
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatEventSubCategoryMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
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
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
      this.setLastScroll();
      /* add スクロールの位置を維持 楊 end */
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        (r) => !(r.operation === 1 && !r.edited)
      );
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();
      this.getMasterRecordList.data.forEach(e=> {
        if (e.useType == "3" && e.templateCd.toString().indexOf('a') >= 0)
          e.templateCd = e.templateCd.replace("a","");
      });
      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message + messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage;
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000006].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>",
        });
        return;
      }

      // apiをコールして値を保存
      this.updateRecordListByFacilityCd({
        facilityCd: this.facilitylistValue,
        request: this.getUpdateRecordList,
      })
        .then((response) => {
          this.updateResponse = response.data;

          if (this.masterPhysicalName === "mst_exam_item") {
            this.masterSynchroOrder();
          } else {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新完了",
              // message: "マスタ更新が完了しました。"
              title: DIALOG_MESSAGES[12000004].title,
              message: messageFormat(DIALOG_MESSAGES[12000004].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          }

          const facilityCds = this.getMasterRecordList.data
            .map((currentVal) => currentVal.destinationFacilityCd)
            .filter((currentVal, index, self) => {
              return self.indexOf(currentVal) === index;
            });

          this.findList();
          if (this.masterPhysicalName === "mst_alarm_notification") {
            this.masterSynchro(facilityCds);
          }
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatEventSubCategoryMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage,
            });
          }
        })
        // 共通ローダー：表示終了
        .finally(() => this.setLoadingScreenVisible(false));
    },
    masterSynchro(facilityCds) {
      facilityCds.forEach(async (facilityCd) => {
        await this.startMstSynchro({
          mstTable: this.mstSynchroApiParams.mstTable,
          facilityCd: facilityCd,
          deviceEdgeNo: this.mstSynchroApiParams.deviceEdgeNo,
        });
      });
    },
    // マスタ同期
    masterSynchroOrder() {
      this.setLoadingScreenVisible(true);
      this.getDeviceEdgeNoList().then((res) => {
        let array = res.data;
        if (array && array.length > 0) {
          array = array.sort((r) => r.deviceEdgeNo);
          this.synchroMstToDeviceEdge(array, 0);
        }
      });
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
      const name = "デバイスエッジ：" + info.deviceName + "</br></br>";

      // マスタ同期
      this.mstSyncDeviceEdge({
        facilityCd: null,
        deviceEdgeNo: info.deviceEdgeNo,
      })
        .then(() => {
          if (infos.length === idx + 1) {
            // 共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            this.$ons.notification.alert({
              title: title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // message: "マスタ同期が完了しました。"
              message: messageFormat(DIALOG_MESSAGES['00100009'].message),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
          } else {
            // 次のデバイスエッジ
            this.synchroMstToDeviceEdge(list, idx + 1);
          }
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstPatEventSubCategoryMainComponent.vue', 'synchroMstToDeviceEdge', name +'との同期に失敗しました。デバイスエッジの装置と整合性が取れていないので再度「保存」を行ってください。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          this.setLoadingScreenVisible(false);
          if (error.response.status === 400) {
            // 共通ローダー：表示終了
            this.$ons.notification.alert({
              title: title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // message:
              //   name +
              //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
              message: messageFormat(DIALOG_MESSAGES[12000320].message, name),
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            });
            return;
          }
        });
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
      Object.keys(fields).forEach((k) => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          d[k] = "";
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (fields[k].type === "date") {
          d[k] = new Date();
        } else if (fields[k].type === "color") {
          d[k] = "#000000";
        } else {
          d[k] = null;
        }

        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
      });
      // add #7300-マスタ新規追加時に利用開始日/使用開始日/使用終了日にデフォルト値が入る 徐博 start
      if (this.masterPhysicalName === "mst_pat_event_sub_category") {
        d.inHospAStartdate = ""
        d.inHospBStartdate = ""
      }
      // add #7300-マスタ新規追加時に利用開始日/使用開始日/使用終了日にデフォルト値が入る 徐博 end
      this.lastScrollTop = this.$refs.grid.$el.lastChild.scrollHeight;
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      this.editBackgroundColor();
    },
  },
  async created() {
    this.setLoadingScreenVisible(true);
    this.facilityHemoDialysis = this.getAdvancedSettings.func_advcds.some(
      (setting) => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
    );
    await Promise.all([
      // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
      // ApiHelper.get("/report/getMstReportByFacilityCd/" + this.getFacilitySwitch).then(response => {
      ApiHelper.get("/report/getMstReportByFacilityCdNoIsDisp/" + this.getFacilitySwitch).then(response => {
      // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
        if(response.data) {
          response.data.forEach(element => {
            // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
            // if (element.isDisp == "1" && element.reportClass == 9)
            if (element.reportClass == 9)
            // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
            this.reportlist.push({
                value: "a"+element.reportCd,
                text: element.reportName,
                isReport:true
              });
          });
        }
      })
    ])
    .catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
      getErrorMessage('MstPatEventSubCategoryMainComponent.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
      throw error;
    });
    // apiをコールして施設一覧を取得
    this.findFacilityList();
    this.calculateColumnsWidth();
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
    this.DisableDetailBtn();
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
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
  },
  // add 性能改善メモリ不足 shan end
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
  font-size: 1em;
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
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}
</style>
