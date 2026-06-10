/**
 * 車いすマスタメンテナンスデータページ  MainContent
 */
<template>
  <div class='main-content-area master-maintenance-page'>
    <div class='ntss-list' :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <div :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord" @click="addRow()">追加</v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 7em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn csv-btn" style="margin-right: 10px;" v-show="!isSortMode && isAllowSort" @click="importCsv()">CSV取込</v-ons-button>
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
            :beforeEdit=onBeforeEdit
            :edit=addInputAssist
            :cellClose=editEnd
            @save="onSave"
            @databound="onDataBoundKendoGrid">
            <template v-for="(column, index) in columns" >
              <kendo-grid-column v-if="column.field === '$modalType'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :attributes="{ class: 'btn3-kendo-normal' }"
                :command="{ text: '詳細', click: showMasterEditModal }">
              </kendo-grid-column>
              <kendo-grid-column v-else-if="column.field === 'wheelChairWeight'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :values="column.values"
                :template="column.template"
                @editor="numericEditor">
              </kendo-grid-column>
              <kendo-grid-column v-else
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                >
              </kendo-grid-column>
            </template>
        </kendo-grid>
      </kendo-grid-toolbar>
      <div id="grid-footer">
        <v-ons-row width="100%" v-show="!isSortMode" >
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel button denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute button registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
    <master-csv
      :popoverVisible="masterCsvVisible"
      :popoverTarget="masterCsvTarget"
      @popover-close="prehideCsvPopover"
    />
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import kendo from "@progress/kendo-ui";
import $ from "jquery";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
import { deepCopy } from "@/functions/common/CommonFunctions";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
  components: {
    "master-csv": MasterCsvComponent
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
          editable: () => true,
          values: null
        }
      ],
      // 初期状態のcolumnsを保持
      _initialColumns: [],
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
      lastScrollTop: 0,
      lastScrollLeft: 0,
      facilitylistValue: "",
      masterCsvVisible: false,
      masterCsvTarget: null,
      getMasterRecordListOld: null,
      pageTypeName: 'MstWheelChairMainComponent',
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      isRecordModified: "isRecordModified"
    }),
    masterRecords() {
      // storeからデータを取得
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
        this.kendoValidator !== undefined &&
        data !== undefined &&
        (this.isRecordModified || !this.kendoValidator.validate())
      );
    },
    ...mapGetters("mst-wheel-chair", {
      getPersonalUserList: "getPersonalUserList",
      getPatPersonalList: "getPatPersonalList",
      getMstWeightScaleData: "getMstWeightScaleData",
      getFetchPersonalUserWithDeleted:"fetchPersonalUserWithDeleted"
    }),
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
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
      "setMasterRecordList",
      "edit",
      "setCondition",
      "findColumnInfo",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty",
      "setComparisonRecordModel",
      "findRecordListByFacilityCd",
      "updateRecordListByFacilityCd"
    ]),
    ...mapActions("mst-wheel-chair", [
      "fetchPersonalUserByFacilityCd",
      "fetchPersonalUser",
      "fetchPatPersonal",
      "fetchMstWeightScale",
      "setMstWeightScale",
      "fetchPatNameByFacilityCd",
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    numericEditor(container, options){
      $('<input data-bind="value:' + options.field + '"/> ')
        .appendTo(container)
        .kendoNumericTextBox({"format": "n2", "decimals": 2, "round": false, "step": "0.01", "min": 0, "max": 300});
    },
    // add 車いすマスタ BUG改修 「個人所有」がキャンセルされる場合、まだ「所有患者」している start
    onSave(ev) {
      this.editingFlg = false;
      //所有患者なしの場合
      if (ev.values.isPersonal && ev.values.isPersonal=="0") {
        ev.model.patId=""
      }
      if (ev.values.wheelChairWeight && Number(ev.values.wheelChairWeight) != 0) {
        ev.model.scaleUserId = this.getStateUserAccountInfo.userId;
      }
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      ev.sender.refresh();
      if (ev.model.operation === 1) {
        ev.model.edited = true;
      }
      // 状態に合わせて背景色を変更
      this.$nextTick(() => {
        this.isRecordModified && this.editBackgroundColor();
      });
    },
    // add 車いすマスタ BUG改修 「個人所有」がキャンセルされる場合、まだ「所有患者」している end
    getG2KgTemplate() {
      const template =
        "#:  wheelChairWeight == null ? '' : (wheelChairWeight).toFixed(2) #";
      const compiledTemplate = kendo.template(template);
      return compiledTemplate.bind(this);
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして値を取得
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.findRecordList => this.findRecordListByFacilityCd
      // this.findRecordList()
      this.findRecordListByFacilityCd(this.facilitylistValue)
        .then(async response => {
                this.getMasterRecordListOld = deepCopy(this.getMasterRecordList.data)
                this.getMasterRecordListOld.forEach(item => {
                  if (item.wheelChairWeight) {
                    item.wheelChairWeight = (item.wheelChairWeight / 1000).toFixed(2)
                  }
                });
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
            /* del by chamaojia 2023-07-10 装置マスタ初期化エラー  --start */
            // // 利用者氏名・・・
            // if (column.field === "scaleUserId") {
            //   column.values = personalUserList;
            // }
            // // 患者氏名・・・
            // if (column.field === "patId") {
            //   column.values = patPersonalList;
            // }
            /* del by chamaojia 2023-07-10 装置マスタ初期化エラー  --end */
          });
          // 利用者氏名のデータ取得
          const personalUserList = this.getPersonalUserList;
          // 患者氏名のデータ取得
          const patPersonalList = this.getPatPersonalList;
          toFunction.forEach(column => {
            // 利用者データを追加
            if (column.field === "scaleUserId") {
              column.values = personalUserList;
            }
            // 患者氏名用データを追加
            if (column.field === "patId") {
              column.values = patPersonalList;
            }
            // 表示設定
            if (column.field === "wheelChairWeight") {
              column.format = "{0:##,#}";
              column.template = this.getG2KgTemplate();
            }
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            column.width = column.field === "isDisp" ? "9em" : (this.columnWidth + "em");
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
            values: null
          });
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

          for (const argument of response.data.localDataSource.data) {
            argument.wheelChairWeight /= 1000;
          }

          // 初期データ内容を保存
          this.setComparisonRecordModel();

        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWheelChairMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
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
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロールの位置を維持 楊 start */
       this.lastScrollTop = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop;
       this.lastScrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft;
      /* add スクロールの位置を維持 楊 end */
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }
      for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
        this.getMasterRecordList.data[i].wheelChairWeight = this.getMasterRecordList.data[i].wheelChairWeight * 1000;
      }
      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        r => !(r.operation === 1 && !r.edited)
      );
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // 所有チェック
      const validatePersonalMessage = this.validatePersonal();
      // 所有者の重複チェック
      const validateSamePatIdMessage = this.validateSamePatId();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validatePersonalMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message + "以下の項目で問題があります。" + validatePersonalMessage;
          message +  messageFormat(DIALOG_MESSAGES['00200071'].message) + validatePersonalMessage;
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message + "以下の列に異常な項目が存在します。" + validateComboMessage;
          message +  messageFormat(DIALOG_MESSAGES['00200110'].message) + validateComboMessage;
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validateSamePatIdMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message + "以下の項目で問題があります。" + validateSamePatIdMessage;
          message +  messageFormat(DIALOG_MESSAGES['00200071'].message) + validateSamePatIdMessage;
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          this.getMasterRecordList.data[i].wheelChairWeight = this.getMasterRecordList.data[i].wheelChairWeight / 1000;
        }
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES['00200071'].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        return;
      }

      // apiをコールして値を保存
      // mod マスタ一覧 1･施設切替を可能とする 孔 this.updateRecordList => this.updateRecordListByFacilityCd
      // await this.updateRecordList(this.getUpdateRecordList)
      await this.updateRecordListByFacilityCd({
        facilityCd: this.facilitylistValue,
        request: this.getUpdateRecordList
      })
        .then(response => {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          this.updateResponse = response.data;
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "マスタ更新が完了しました。"
            title: DIALOG_MESSAGES[12000004].title,
            message: messageFormat(DIALOG_MESSAGES[12000004].message),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });
          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWheelChairMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        });
    },
    /**
     * 各項目の検証
     */
    validatePersonal() {
      let validateMessageArr = [];
      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data;
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        let rowNo = rowIdx + 1;
        // 所有フラグ
        let isPersonal = rows[rowIdx]["isPersonal"];
        // 患者指定
        let patId = rows[rowIdx]["patId"];
        // 所有患者未指定チェック
        if (isPersonal === "1" && (patId === null || patId === "")) {
          // 患者未指定
          const strErr =
            "所有患者未指定：<br>　　　" +
            rowNo +
            "行目";
          validateMessageArr.push(strErr);
        }
      }
      this.getMasterRecordList.data = rows;
      this.setMasterRecordList(this.getMasterRecordList);
      return this.convertToStr(validateMessageArr);
    },
    /**
     * 患者重複チェック
     */
    validateSamePatId() {
      let validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      const rows = gridData.data;
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        let rowNo = rowIdx + 1;
        // 患者指定
        let patId = rows[rowIdx]["patId"];
        if(patId !== null && patId !== "") {
          const ret = rows.filter(item => {
            return +item.patId === +patId;
          })
          if(ret.length > 1){
            // 指定患者が重複
            const strErr =
              "所有患者が重複してます：<br>　　　" +
              rowNo +
              "行目";
            validateMessageArr.push(strErr);
          }
        }
      }
      return this.convertToStr(validateMessageArr);
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
      this.$nextTick(() => {
        this.isRecordModified && this.editBackgroundColor();
      });
    },
    async loadGridData(){
      // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
      // mod マスタ一覧 1･施設切替を可能とする 孔 start
      // await this.fetchPersonalUser();
      const facilityCds = new Array();
      facilityCds.push(this.facilitylistValue)
      if (this.facilitylistValue !== "nkknkk") {
        facilityCds.push("nkknkk")
      }
      await this.fetchPersonalUserByFacilityCd(facilityCds);
      // await this.fetchPatPersonal(this.getFacilityCd);
      await this.fetchPatNameByFacilityCd(this.facilitylistValue);
      // mod マスタ一覧 1･施設切替を可能とする 孔 end

      // mod マスタ一覧 1･施設切替を可能とする 孔 this.getFacilityCd => this.facilitylistValue
      // this.fetchMstWeightScale(this.getFacilityCd).then(response => {
      this.fetchMstWeightScale(this.facilitylistValue).then(response => {
        this.setMstWeightScale(response.data).then(() => {
          this.findList();
        }).catch(e => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstWheelChairMainComponent.vue', 'loadGridData', e);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          console.error(e);
          this.findList();
        });
      }).catch(e => {
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
        getErrorMessage('MstWheelChairMainComponent.vue', 'loadGridData', e);
        //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        console.error(e);
        this.findList();
      });
    },
    onBeforeEdit(e) {
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
    
    /** 画面印刷前の処理 */
    handleBeforePrint() {
      const grid = this.$refs.grid.kendoWidget();
      const columns = grid.getOptions().columns;
    
      columns.forEach((col, index) => {
        col.locked = false;
        if (index === 0) {
          col.hidden = true;      // 1列目は強制非表示
        } else if (!col.hidden) {
          col.width = undefined;  // 表示列のみ幅リセット
        }
      });
      
      // 重量校正日だけ幅指定
      const scaleDateCol = columns.find(col => col.field === 'scaleDate');
      if (scaleDateCol) {
        scaleDateCol.width = 90; // px指定
      }
          
      grid.setOptions({ columns });
    },
    /** 画面印刷後の処理 */
    handleAfterPrint() {
      // 初期状態に完全復元
      this._initialColumns.forEach((savedCol, index) => {
        Object.assign(this.columns[index], savedCol);
      });
      
      const grid = this.$refs.grid.kendoWidget();
      grid.dataSource.read(); // 再バインド
    }
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.calculateColumnsWidth();
    // add マスタ一覧 1･施設切替を可能とする 孔 start
    this.facilitylistValue = this.getFacilitySwitch;
    // add マスタ一覧 1･施設切替を可能とする 孔 end
    this.loadGridData();

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
    this.$nextTick(() => {
        this.isRecordModified && this.editBackgroundColor();
      });
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
      window.addEventListener("beforeprint", this.handleBeforePrint);
      window.addEventListener("afterprint", this.handleAfterPrint);
    });
    
    // 初期columnsをシャローコピーで保存（関数も保持される）
    this._initialColumns = this.columns.map(col => ({ ...col }));
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    window.removeEventListener("beforeprint", this.handleBeforePrint);
    window.removeEventListener("afterprint", this.handleAfterPrint);
  },
  // add 性能改善メモリ不足 shan end
  // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc start
  beforeRouteLeave(to, from, next) {
    if (this.getisChanged()) {
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "内容破棄",
        title: DIALOG_MESSAGES[13000004].title,
        // message: "編集内容が破棄されます。</br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000004].message),
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          next(answer === 1);
        }
      });
    } else {
      next();
    }
  },
  // add #10053：優先00：破棄確認・保存活性(複数変更含む)・削除対応#9809（車いすマスタ画面）20231107 ztc end
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

.kendo-grid-toolbar-style
  >>> .k-grid
  tr:nth-child(n + 3):nth-last-child(n-3)
  .k-tooltip.k-tooltip-validation
  .k-callout {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}
.kendo-grid-toolbar-style
  >>> .k-grid
  tr:nth-child(n + 3):nth-last-child(n-3)
  .k-tooltip.k-tooltip-validation {
  bottom: 38px;
}
.kendo-grid-toolbar-style >>> .k-edit-cell {
  position: relative;
  overflow: visible;
}
/* add 8130 全施設マスタでフリーズする 周安寧 end */
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
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}

@media print {
  /* kendoグリッド全体を紙幅に合わせる */
  .ntss-list >>> div,
  .kendo-grid-toolbar-style {
    height: auto !important;
  }
  .k-grid {
    width: 100% !important;
  }
  
  .k-grid >>> .k-grid-header {
    padding-right: 0 !important;
  }
  
  /* ヘッダー・ボディ両方のテーブルを紙幅に収める */
  .k-grid >>> table,
  .k-grid >>> .k-grid-header table,
  .k-grid >>> .k-grid-content table {
    width: 100% !important;
    table-layout: fixed !important;
  }
  .k-grid >>> td,
  .k-grid >>> th {
    padding: 1px 1px !important;
    white-space: normal !important;   /* 折り返しON */
    word-break: break-all !important; /* 強制折り返し */
    overflow: visible !important;
  }

  /* スクロール解除 */
  .k-grid >>> .k-grid-content,
  .k-grid >>> .k-grid-header-wrap {
    overflow: visible !important;
    height: auto !important;
  }
    
  /* 詳細ボタン幅 */
  .k-grid >>> .k-button {
    padding: .375rem .2rem;
  }
  
}
</style>
