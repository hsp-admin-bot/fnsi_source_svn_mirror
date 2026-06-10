/**
 * 施設管理マスタメンテナンスデータページ  MainContent
 */
<template>
  <div class='main-content-area master-maintenance-page'>
    <div class='ntss-list' v-if="this.columns.length" v-kendo-validator="kendoValidatorSetup">
      <div v-if="isMobileDevice" id="grid-header" class="header-btn-area right" style="height: 30px;">
        <v-ons-row style="width: 7em;">
          <v-ons-col width="45%" vertical-align="center">
            <label class="fab-font-color">編集</label>
          </v-ons-col>
          <v-ons-col width="55%" vertical-align="center">
            <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
          </v-ons-col>
        </v-ons-row>
      </div>
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <!-- <div v-if="isMasterUser" class='header-btn-area right'> -->
          <!-- del マスタ一覧 1･施設切替を可能とする 孔 start-->
          <!--<kendo-dropdownlist
                    v-model="facilitylistValue"
                    :data-source="facilitys"
                    :data-text-field="'facilityName'"
                    :data-value-field="'facilityCd'"
                    :filter="'contains'"
                    @open="onOpenFacility"
                    @change="onChangeFacility"
                    style="width: 13em;">
          </kendo-dropdownlist>-->
          <!-- del マスタ一覧 1･施設切替を可能とする 孔 end-->
        <!-- </div>
        <div v-else class='header-btn-area left'>
        </div> -->
        <kendo-grid
          ref="grid"
          :class="fontSizeSet"
          :key="tableKey"
          style="clear: both;"
          :data-source="masterRecords"
          :editable="true"
          :selectable="true"
          :reorderable="false"
          :height=kendoGridHeight
          :scrollable="true"
          :beforeEdit=editStart
          :cellClose=editEnd
          @save="onSave"
          @databound="onDataBoundKendoGrid">
          <template v-for="(column, index) in columns" >
            <kendo-grid-column v-if="column.title === '設定値'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              :encoded="column.encoded"
              :editor="editorInput"
              >
            </kendo-grid-column>
            <kendo-grid-column v-else-if="column.field === 'dispOrder'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              width="4em"
              :format="column.format"
              :values="column.values"
              :encoded="column.encoded"
              :editor="editorInput"
              >
            </kendo-grid-column>
            <kendo-grid-column v-else
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              :encoded="column.encoded"
              >
            </kendo-grid-column>
          </template>
        </kendo-grid>
      </kendo-grid-toolbar>
      <!-- 高さ調整 -->
      <div id="grid-footer">
        <v-ons-row v-show="!isSortMode" width="100%">
          <v-ons-col width="50%">
            <v-ons-button
              class="button btn2-cancel denial-btn"
              style="width: auto;"
              @click="cancel"
            >
              キャンセル
            </v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="button btn1-execute registration-btn"
              style="width: auto;"
              :disabled="!isChanged"
              @click="saveRecord"
            >
              保存
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
      <message-dialog
        v-if="isDialogVisible"
        :visible.sync="isDialogVisible"
        :message-cd="messageCd"
        :string-params="stringParams"
        type="1"
      />
    </div>
  </div>
</template>

<script>
import $ from "jquery";
import _ from "underscore";
import moment from "moment";
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import { EventBus } from "@/eventBus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import { sendRequestGetMstFacilityHashByFacilityCd } from "@/apis/mst-facility-hash";
import {
  URL_SIGNIN,
  URL_SIGNIN_SECRETKEY,
  TREATMENT_PROGRESS_CHART,
  TREATMENT_PROGRESS_CHART_HANDWRITING,
  DAILY_INSPECTION_RECORD_BOOK,
  PERIODIC_INSPECTION_RECORD_BOOK,
  // add #12462 患者情報共有 ligh start
  SHR_PAT_INFO,
  // add #12462 患者情報共有 ligh end
  STATUS_MAP_TREATMENT_INDICATOR,
  STATUS_MAP_SCHEDULE_INDICATOR
} from "@/constants/facilitySetting";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import { cloneDeep, isEqual } from "lodash";

export default {
  components: {
    "message-dialog": messageDialog
  },
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
  data() {
    return {
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
      condition: {
        recordName: ""
      },
      kendoGridToolbarHeight: 500,
      kendoGridHeight: '100%',
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      facilitylistValue: "",

      // DB取得個別ドロップダウンリスト表示項目
      kendoGridDrop:{
        doctorList:null
        // add 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s start
        ,reportList:null
        // add 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s end
      },

      // 並び順管理マスタ
      mstSelector: [],

      isDialogVisible: false,
      stringParams: null,
      messageCd: null,
      isSortChacked: false,

      delUserId: -1,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      //ソートはしないが共通画面仕様で使うため設定
      isSortMode: false,
      isSorted : false,
      //自画面の名称
      selfScreenName: "",
      // 表示権限ユーザー
      userType: "",
      //変更前の施設
      prevFacilityCd: "",
      footerHeight: 40,
      tableKey: 0,
      iosFlg: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      // 初期値退避用オブジェクト
      originalDataSource: null,
      scrollTop: 0,
      scrollLeft: 0,
    };
  },
  computed: {
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),

    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "height": `calc(100% - ${this.footerHeight}px)` };
    },
    ...mapGetters("mst-facility-setting", {
      getFacilityList: "getFacilityList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getEditRecord: "getEditRecord",
      getUpdateRecordList: "getUpdateRecordList",
      getMasterRecordList: "getMasterRecordList"
    }),
    isMasterUser() {
        return this.getStateUserAccountInfo.userType === 1 ? true : false;
    },
    facilitys() {
      // storeからデータを取得
      return this.getFacilityList;
    },
    masterRecords() {
      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    isChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (data.filter(row => row.operation > 0).length ||
          this.isSorted ||
          this.kendoValidator && !this.kendoValidator.validate())
      );
    },
    editRecord(){
      return this.getEditRecord;
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    }
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    async facilitylistValue() {
      if (this.facilitylistValue) {
        // 施設のシステム利用設定を取得する
        const mstFacilityHash = await sendRequestGetMstFacilityHashByFacilityCd(this.facilitylistValue);
        this.setFacilitySysUseSetting(mstFacilityHash.data.systemUseSetting ? mstFacilityHash.data.systemUseSetting : "");
      } else {
        this.setFacilitySysUseSetting("");
      }
    },
    columns:function(val){
      this.$nextTick(function(){
        if (val.length > 1)
        this.setLoadingScreenVisible(false);
      });
    }
  },
  methods: {
    ...mapActions("multi-modal", [
      "showUserMasterIdReset",
      "showUserMasterAuthFunction"
    ]),
    ...mapActions("mst-facility-setting", [
      "getFacilitySettingDataList",
      "edit",
      "setEditRecord",
      "facilityList",
      "setCondition",
      "setUserData",
      "setMasterRecordList",
      "setUserType",
      "getDoctorsAtFacility",
      "setFacilitySysUseSetting"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("user", ["setSignInFailSetting"]),
    onSave(ev) {
      if(ev.model.facilitySettingNo == '1012' || ev.model.facilitySettingNo == '1014')  return;
      // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 start
      if(ev.model.inputType === 7)  return;
      // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 end
      // スクロールの位置を維持
      this.scrollLeft = ev.sender._scrollLeft;
      this.scrollTop = ev.sender.wrapper[0].children[1].scrollTop;
      this.editFlg = true;

      this.editingFlg = false;
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });

      // 初期値と現在値を比較し、差分が無い場合はdirty状態を解除
      this.handleUnchangedState(ev);

      ev.sender.refresh();
      if (ev.model.operation === 1) {
        ev.model.edited = true;
      }

      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
    },
    onDataBoundKendoGrid(ev) {
      if (this.scrollTop > 0 || this.scrollLeft > 0) {
        //スクロールバーの位置をイベント発生前の位置に戻す
        this.$nextTick(() => {
          ev.sender.content[0].scrollTop = this.scrollTop;
          ev.sender.content[0].scrollLeft = this.scrollLeft;
        });
      }
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.editingFlg) {
        const wh = this.windowHeight;
        const hh = Array.prototype.slice
          .call(document.getElementsByClassName("header"))
          .pop().clientHeight;
        const fmh =
          this.isDispMenu === 1
            ? document.getElementById("footer-menu").clientHeight
            : 0;
        this.kendoGridToolbarHeight = wh - hh - fmh;
        this.kendoGridToolbarHeight =
          this.kendoGridToolbarHeight < 340 ? 340 : this.kendoGridToolbarHeight;

        // const gfh = document.getElementById("grid-footer").clientHeight;
        // const hbh = document.querySelector(".header-btn-area").clientHeight;
        const footerHeight = document.getElementById('grid-footer').clientHeight
        this.footerHeight = footerHeight
        this.tableKey += 1
        this.kendoGridHeight = '100%';
      }
    },
    editStart(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      if (this.androidFlg) {
        this.editingFlg = true;
      }
    },
    editEnd(ev) {
      this.editingFlg = false;
      // mod redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 start
      //if(ev.model.facilitySettingNo == '1012' || ev.model.facilitySettingNo == '1014') {
      if (ev.model.facilitySettingNo == '1012' || ev.model.facilitySettingNo == '1014' ||
        (ev.model.inputType === 7 && ev.model.val)) {
      // mod redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 end
        this.edit({ editRecord: ev.model, isSortMode: false });

        // 初期値と現在値を比較し、差分が無い場合はdirty状態を解除
        this.handleUnchangedState(ev);

        ev.sender.refresh();
        if (ev.model.operation === 1) {
          ev.model.edited = true;
        }

        // 状態に合わせて背景色を変更
        this.editBackgroundColor();
      }
    },

    /**
     * 編集終了時（saveまたはcellClose）に、初期値とセルの値が同一か判定し、同一の場合はGrid行のdirty状態を解除する
     * @param {Object} e - KendoGridのイベント引数
     */
    handleUnchangedState(e) {
      const { facilitySettingNo } = e.model;
      const originalItem = this.originalDataSource.find((item) => {
        return item.facilitySettingNo === facilitySettingNo;
      });

      let editField;
      let editedValue;
      if (e.values && typeof e.values === "object") {
        // save()からの呼出しの場合、e.valuesから編集フィールドを取得
        editField = Object.keys(e.values)[0];
        // 現在値取得
        editedValue = e.values[editField];
      } else {
        // cellClose()からの呼出しの場合、e.valuesが無い為<td>から取得
        const colIndex = e.container[0].cellIndex;
        editField = e.sender.columns[colIndex]?.field || e.sender.thead[0].querySelectorAll('th')[colIndex]?.getAttribute('data-field');
        // 現在値取得
        editedValue = e.model[editField];
      }
      // 初期値取得
      const originalValue = originalItem?.[editField];

      let isUnchanged;
      if (e.model.inputType === 6) {
        // 入力分類(inputType)が6:テキストエリア（複数行対応）の場合、改行コードを\nに統一し初期値と現在値を比較
        isUnchanged = isEqual(String(originalValue ?? '').replace(/\r\n|\r/g, '\n'), String(editedValue ?? '').replace(/\r\n|\r/g, '\n'));
      } else {
      // 初期値と現在値を比較
        isUnchanged = isEqual(originalValue, editedValue);
      }
      if (isUnchanged) {
        // 初期値と現在値に差が無い場合、行のdirty状態を解除
        e.sender.dataSource.cancelChanges(e.model);
        delete e.model.operation;
      }
    },

    // マスタ一覧のデータを取得
    async findList() {
      // スクロールの位置を維持
      let scrollTop = 0;
      let scrollLeft = 0;
      if(this.$refs.grid != null){
        scrollTop = this.$refs.grid.$el.children[1].scrollTop;
        scrollLeft = this.$refs.grid.$el.children[1].scrollLeft;
      }
      // 設定値リストのうちDB参照系をコールして再取得
      await this.setkendoGridDropList();

      // apiをコールして施設設定マスタの値を取得
      this.getFacilitySettingDataList(this.facilitylistValue)
        .then(async response => {
          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach(column => {
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // add redmine 4635 パンくずリストを用いて画面の再読み込みを行うとレイアウトが崩れる 孔 start
          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 設定説明列の幅を拡張するように指定
            column.width = column.field === "description" ? "24em" : "14em";
            column.encoded = column.field === "description" || column.field === "functionName" ? false : true;
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
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });

          // カラム幅等初期調整
          // 編集モードによって並び順項目の表示・非表示を切り替える（この画面ではソート順変更の変更はしない）
          // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
          const sortRankIndex = this.columns.findIndex(
            col => col.field === "sortRank"
          );
          if (sortRankIndex >= 0) {
            this.columns[sortRankIndex].hidden = true;
            const dummyIndex = this.columns.findIndex(
              col => col.field === "dummy"
            );
            if (dummyIndex >= 0) {
              this.columns[dummyIndex].hidden = false;
            }
          }

          this.$nextTick(() => {
            this.calculateGridHeight();
            // 元のスクロール位置に移動
            this.$refs.grid.$el.children[1].scrollTop = scrollTop;
            this.$refs.grid.$el.children[1].scrollLeft = scrollLeft;
          });
          // add redmine 4635 パンくずリストを用いて画面の再読み込みを行うとレイアウトが崩れる 孔 end

          // マスタから選択肢の一覧をとる行の情報リスト
          let masterPhysicalNameList = [];
          // add #12462 患者情報共有 ligh start
          let options = [];
          // add #12462 患者情報共有 ligh end
          let referenceMasterList = [];

          // 画面表示項目と値格納項目の分離
          this.getMasterRecordList.data.forEach((columnData,index)=> {
            if(columnData.inputType === 9){
              // 施設別医師選択専用
              let matchData = this.kendoGridDrop.doctorList.filter(function(item){
                if(item.id == columnData.value) return true;
              });
              // 設定医師のデフォルトフォーカス
              if(matchData.length > 0){
                columnData.dispValue = matchData[0].name;
              }else{
                columnData.dispValue = " ";
              }
              columnData.optionValue = JSON.stringify(this.kendoGridDrop.doctorList);

            // add 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s start
            }else if(columnData.inputType === 8){
              // 帳票選択専用
              let matchData = this.kendoGridDrop.reportList.filter(function(item){
                if(item.id == columnData.value) return true;
              });
              if(matchData.length > 0){
                columnData.dispValue = matchData[0].name;
              }else{
                columnData.dispValue = " ";
              }
              columnData.optionValue = JSON.stringify(this.kendoGridDrop.reportList);
            // add 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s end

            // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 start
            }else if(columnData.inputType === 7){
              let jsonData = $.parseJSON(columnData.optionValue);
              // mod #12462 患者情報共有 ligh start
              if (jsonData.length == 1) {
                // 対象テーブルを取得
                const optionValueOld = $.parseJSON(columnData.optionValue)
                const masterPhysicalName = optionValueOld[0].master_physical_name;

                // この行の情報をリストに格納
                masterPhysicalNameList.push(masterPhysicalName);
                options.push(optionValueOld[0]);
                referenceMasterList.push({
                  masterPhysicalName: masterPhysicalName,
                  index: index
                });
              } else {
                if (!columnData.value || columnData.value == "") columnData.value = "[]"
                const values = $.parseJSON(columnData.value)

                let matchData = []
                values.forEach(item => {
                  const matchItem = jsonData.find(json => json.id === item)
                  if (matchItem) {
                    matchData.push(matchItem)
                  }
                })

                let dispText = ""
                matchData.forEach(item => dispText = this.buildTextMultiSelect(dispText, item.name, columnData))

                columnData.dispValue = dispText;
              }
              // mod #12462 患者情報共有 ligh end
            // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 end
            }else if(columnData.inputType === 5){
              // 対象テーブルを取得
              const optionValueOld = $.parseJSON(columnData.optionValue)
              const masterPhysicalName = optionValueOld[0].master_physical_name;

              // この行の情報をリストに格納
              masterPhysicalNameList.push(masterPhysicalName);
              // add #12462 患者情報共有 ligh start
              options.push(optionValueOld[0]);
              // add #12462 患者情報共有 ligh end
              referenceMasterList.push({
                masterPhysicalName: masterPhysicalName,
                index: index
              });

            }else if(columnData.inputType === 4){
              let jsonData = $.parseJSON(columnData.optionValue);

              let matchData = jsonData.filter(function(item){
                if(item.id == columnData.value) return true;
              });
              columnData.dispValue = matchData[0].name;

            }else if (columnData.inputType === 3){
              let jsonData = [{"id":"0", "name":"OFF"},{"id":"1", "name":"ON"}];
              let matchData = jsonData.filter(function(item){
                if(item.id == columnData.value) return true;
              });
              columnData.dispValue = matchData[0].name;

            } else if (columnData.inputType === 2) {
              // 入力分類(inputType)が2:数値型の場合、処理内で数値型だったり文字列だったり揺れがある。数値型だと不都合な処理がある為、文字列に統一
              columnData.dispValue = columnData.value;
              if (columnData.dispValue != null) {
                columnData.dispValue = String(columnData.dispValue);
              }

            }else{
              columnData.dispValue = columnData.value;
            }

            if (columnData.facilitySettingNo == '1012' || columnData.facilitySettingNo == '1014') {
              // 時間項目の施設設定番号(facilitySettingNo)の場合、表示用に99:99フォーマットに変換
              columnData.dispValue = columnData.value;
              if (columnData.dispValue != null) {
                const str = String(columnData.dispValue);
                if (/^\d{4}$/.test(str)) {
                  columnData.dispValue = str.substring(0, 2) + ':' + str.substring(2);
                }
              }
            }
          });
          // マスタから選択肢の一覧をとる
          //del 施設設定マスタ バッグ修正 孔s start
          // const selectorResponse =
          //   await ApiHelper.get(
          //     `/facilitySetting/getSelectorDataList/${this.facilitylistValue}/${masterPhysicalNameList}`
          //   );
          //del 施設設定マスタ バッグ修正 孔s end
          //add 施設設定マスタ バッグ修正 孔s start
          let selectorResponse = [];
          // mod #12462 患者情報共有 ligh start
          // if(masterPhysicalNameList.length>0){
          //   selectorResponse =
          //     await ApiHelper.get(
          //       `/facilitySetting/getSelectorDataList/${this.facilitylistValue}/${masterPhysicalNameList}`
          //     )
          // }
          if(options.length>0){
            let facilityList = options.reduce((map, item) => {
              const key = item.facility_cd || '__NO_FACILITY__'
              if (!map[key]) {
                map[key] = []
              }
              map[key].push(item.master_physical_name)
              return map
            }, {});
            for (const key in facilityList) {
              const facilityCd = key === '__NO_FACILITY__' ? this.facilitylistValue : key
              const items = facilityList[key];
              let res = await ApiHelper.get(
                `/facilitySetting/getSelectorDataList/${facilityCd}/${items}`
              )
              selectorResponse.push(...res.data);
            }
          }

          // 共有設定を持つ施設リスト取得 Add ligh start
          let shrRes = await ApiHelper.get(
            `/shrPatInfo/facilityCdDown`
          )
          const shrFacilityList = shrRes.data.filterFacility
          // 共有設定を持つ施設リスト取得 Add ligh end

          //add 施設設定マスタ バッグ修正 孔s end
          for (const ref of referenceMasterList) {

            // const mstSelector = selectorResponse.data.filter(item => {
            //   if (item.masterPhysicalName == ref.masterPhysicalName) return true;
            // });
            const mstSelector = selectorResponse.filter(item => {
              if (item.masterPhysicalName == ref.masterPhysicalName) return true;
            });
            let columnData = this.getMasterRecordList.data[ref.index];

            if (columnData.inputType == 7) {
              // 並び順管理マスタから設定値リストを抽出
              let jsonData = [];
              if (mstSelector[0]) {
                for (let item of mstSelector[0].orderSettings.items) {
                  if (mstSelector[0].masterPhysicalName == 'mst_facility') {
                    const matchedFacility = shrFacilityList.find(shrItem => shrItem.facilityCd === item.name);
                    if (matchedFacility) {
                      jsonData.push({
                        id: matchedFacility.facilityCd,
                        name: matchedFacility.facilityName
                      });
                    }
                  } else {
                    jsonData.push({
                      id: item.code,
                      name: item.name
                    });
                  }
                }
              }
              columnData.optionValue = JSON.stringify(jsonData);
              if (!columnData.value || columnData.value == "") columnData.value = "[]"
              const values = $.parseJSON(columnData.value)

              let matchData = []
              values.forEach(item => {
                const matchItem = jsonData.find(json => json.id === item)
                if (matchItem) {
                  matchData.push(matchItem)
                }
              })

              let dispText = ""
              matchData.forEach(item => dispText = this.buildTextMultiSelect(dispText, item.name, columnData))

              columnData.dispValue = dispText;
            } else {

              // 並び順管理マスタから設定値リストを抽出
              let jsonData = [{ id: "-1", name: " " }];
              if (mstSelector[0]) {
                for (let item of mstSelector[0].orderSettings.items) {
                  jsonData.push({
                    id: item.code,
                    name: item.name
                  });
                }
              }
              columnData.optionValue = JSON.stringify(jsonData);

              // デフォルト値の選択
              let matchData = jsonData.filter(function (item) {
                if (item.id == columnData.value) return true;
              });

              if (matchData.length > 0) {
                columnData.dispValue = matchData[0].name;
              } else {
                columnData.dispValue = " ";
              }

              this.getMasterRecordList.data[ref.index] = columnData;
            }
          }
          this.setMasterRecordList(this.getMasterRecordList);
          // 初期値退避用オブジェクトに検索結果をディープコピー
          this.originalDataSource = cloneDeep(this.getMasterRecordList.data);
          this.tableKey += 1;
          // mod #12462 患者情報共有 ligh end

          // del redmine 4635 パンくずリストを用いて画面の再読み込みを行うとレイアウトが崩れる 孔 start
          // // 横スクロールバーを表示するために列幅を指定
          // this.columns.forEach(column => {
          //   // 設定説明列の幅を拡張するように指定
          //   column.width = column.field === "description" ? "24em" : "14em";
          //   column.encoded = column.field === "description" || column.field === "functionName" ? false : true;
          // });
          // // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          // this.columns.unshift({
          //   title: " ",
          //   field: "dummy",
          //   hidden: false,
          //   editable: () => false,
          //   width: "10px",
          //   format: "",
          //   values: null
          // });
          //
          // // カラム幅等初期調整
          // // 編集モードによって並び順項目の表示・非表示を切り替える（この画面ではソート順変更の変更はしない）
          // // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
          // const sortRankIndex = this.columns.findIndex(
          //   col => col.field === "sortRank"
          // );
          // if (sortRankIndex >= 0) {
          //   this.columns[sortRankIndex].hidden = true;
          //   const dummyIndex = this.columns.findIndex(
          //     col => col.field === "dummy"
          //   );
          //   if (dummyIndex >= 0) {
          //     this.columns[dummyIndex].hidden = false;
          //   }
          // }
          //
          // this.$nextTick(() => {
          //   this.calculateGridHeight();
          //   // 元のスクロール位置に移動
          //   this.$refs.grid.$el.children[1].scrollTop = scrollTop;
          //   this.$refs.grid.$el.children[1].scrollLeft = scrollLeft;
          // });
          // del redmine 4635 パンくずリストを用いて画面の再読み込みを行うとレイアウトが崩れる 孔 end
        })
        .catch(error => {
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
    },
    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        this.setFacilitylistValue();
        // 選択した施設を元に利用者一覧の取得
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          this.setFacilitylistValue();
          // 選択した施設を元に利用者一覧の取得
          this.findList();
        })
        .catch(error => {
          alert(error);
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
    },
    setFilterCondition(condition) {
      this.condition.userType = this.getStateUserAccountInfo.userType;
      this.condition.recordName = condition.recordName;
    },
    setFacilitylistValue() {
      this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
    },

    async setkendoGridDropList(){
      // 施設別医師リスト取得
      const doctorResponse= await this.getDoctorsAtFacility(this.facilitylistValue);
      let doctorList = [{id: "0", name: " "}];
      doctorResponse.data.forEach(doctor => {
        doctorList.push({
          id:`${doctor.user_id}`,
          name:`${doctor.user_last_name} ${doctor.user_first_name}`
        });
      });
      this.kendoGridDrop.doctorList = doctorList;

      // add 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s start
      // 帳票リスト取得
      // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy start
      // const reportResponse = await ApiHelper.get(`/report/getMstReportByFacilityCd/${this.facilitylistValue}`)
      const reportResponse = await ApiHelper.get(`/report/getMstReportByFacilityCdNoIsDisp/${this.facilitylistValue}`)
      // mod #12326 【因島】帳票マスタの「非表示」設定が意図せぬ動作をしている sunsy end
      let reportList = [{id: "0", name: " "}];
      if (reportResponse.data && reportResponse.data.length > 0) {
        reportResponse.data.forEach(report => {
          if (report.reportClass === 1) {
            reportList.push({
              id:`${report.reportCd}`,
              name:`${report.reportName}`
            });
          }
        });
      }
      this.kendoGridDrop.reportList = reportList;
      // add 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s end
    },
    onOpenFacility(e) {
      //変更前の施設を取得
      this.prevFacilityCd = e.sender._old;
    },
    onChangeFacility(e) {
      if(this.prevFacilityCd != e.sender._old) {
        if (this.isChanged){
          // 編集時は未保存確認メッセージを出力する
          const newFacilityCd = e.sender._old;
          e.preventDefault();
          this.$ons.notification.confirm({
           // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end,
            callback: answer => {
              if (answer === 1) {
                // 選択した施設を元に施設設定一覧の取得
                this.facilitylistValue = newFacilityCd;
                this.findList();
              } else {
                // 変更前の施設を設定する
                this.facilitylistValue = this.prevFacilityCd;
              }
            }
          });
        } else {
          // 選択した施設を元に施設設定一覧の取得
          this.facilitylistValue = e.sender._old;
          this.findList();
        }
      }
    },

    editBackgroundColor() {
      this.$nextTick(() => {
        const gridHeader = this.$refs.grid.$el.firstChild;
        if (gridHeader.textContent !== " ") {
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
          // return;
          gridHeader.classList?.add("master-grid-header")
          // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 end
        }
        // グリッドにレコードがなければ処理終了
        if (!this.$refs.grid.$el.lastChild.lastChild.tBodies) {
          return;
        }

        const tbodyc = this.$refs.grid.$el.lastChild.lastChild.tBodies[0]
          .children;
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;

          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc);

          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, edited, false);
        }
      });
    },
    changeEditColor(currentTrc) {
      let edited = false;
      // 変更されたセルの文字色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount]) &&
          clCount !== this.getColumnIndex("sortRank")
        ) {
          currentTrc[clCount].classList?.add("master-edited-cell");
          edited = true;

          if (clCount === this.getColumnIndex("value")) {
            // プルダウンリスト項目(inputTypeが4,5,9)の場合、表示されるdispValueセルではなく、非表示のvalueセルに.k-dirty-cellクラスが設定される。
            // .k-dirty-cellを目印に.master-edited-cell追加を行うと、プルダウンリスト項目だけは.master-edited-cellスタイルが視覚上確認できない。(非表示セルに設定されているから)
            // 上記理由から、.k-dirty-cellを持つ項目のindexが"value"の場合は、indexが"dispValue"のセルにも.master-edited-cellクラス追加を行う。
            currentTrc[this.getColumnIndex("dispValue")].classList?.add("master-edited-cell");
          }
        }
      }
      return edited;
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains("k-dirty-cell");
    },
    changeRowColor(currentTrc, edited, deleted) {
      // 並び順より後の項目の背景色を変更
      if (edited || deleted) {
        const addClass = deleted ? "master-deleted-row" : "master-edited-row";

        for (
          let clCount = this.getColumnIndex("sortRank") + 1;
          clCount < currentTrc.length;
          clCount++
        ) {
          currentTrc[clCount].classList?.add(addClass);
        }
      }
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },

    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      //イベント発生前のスクロールバーの位置を保持
      const scrollTop = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop;
      const scrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft;
      this.scrollTop = scrollTop;
      this.scrollLeft = scrollLeft;
      // masterListの表示値から登録値を再設定(ドロップダウンリストの表示と値を再設定)
      //画面表示項目と値格納項目の再分離
      this.getMasterRecordList.data.forEach(columnData=> {
        // mod 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s start
        // if(columnData.inputType === 4 || columnData.inputType === 5 || columnData.inputType === 9){
        if(columnData.inputType === 4 || columnData.inputType === 5 || columnData.inputType === 9 || columnData.inputType === 8){
        // mod 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s end
          //4:ドロップダウンリスト時
          let jsonData = $.parseJSON(columnData.optionValue);

          let matchData = jsonData.filter(function(item){
            if(item.name == columnData.dispValue && columnData.val == item.id) return true;
          });
          if(matchData.length > 0){
            columnData.value = matchData[0].id;
          }

        // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 start
        }else if(columnData.inputType === 7){
          //4:ドロップダウンリスト時
          let jsonData = $.parseJSON(columnData.optionValue);
          if (!columnData.val || columnData.val == "") columnData.val = "[]"
          let valueData = $.parseJSON(columnData.val);

          let matchData = []
          valueData.forEach(value => {
            const jsonItem = jsonData.find(json => json.id === value)
            if (jsonItem) matchData.push(jsonItem)
          })
          if(matchData.length > 0){
            columnData.value = JSON.stringify(matchData.map(item => item.id));
          }
        // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 end
        }else if (columnData.inputType === 3){
          //3:ON/OFF設定時(トグル不可のためドロップダウンリストで代替)
          let jsonData = [{"id":"0", "name":"OFF"},{"id":"1", "name":"ON"}];
          let matchData = jsonData.filter(function(item){
            if(item.name == columnData.dispValue) return true;
          });
          columnData.value = matchData[0].id;

        }else{
          //2:数値入力 1:テキスト入力時
          columnData.value = columnData.dispValue;
        }
      });
      this.setMasterRecordList(this.getMasterRecordList);

      // 登録用項目一覧
      const keys = [
        "facilitySettingNo",
        "value"
      ];

      // 必須入力チェック
      if (!this.isFilledRequired()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 編集中のレコードを取得
      const insertRecords = [];
      for (const record of this.getUpdateRecordList) {
         if (record.operation === 2) {
           //更新対象データ
            insertRecords.push(record);
        }
      }

      // 登録日時・更新日時用の現在日時
      const now = moment().format("YYYY-MM-DDTHH:mm:ss.SSSZ");

      const serializedInsertRecords = insertRecords.map(record =>
        JSON.stringify({
          ..._.pick(record, keys),
          facilityCd: this.facilitylistValue,
          regDate: now,
          upDate: now
        })
      );

      //登録更新用レコードの作成
      const editRecord = {
        insertRecord: serializedInsertRecords
      };

      // apiをコールして値を保存
      await ApiHelper.put("/master_maintenance/saveMstFacilitySetting", editRecord).catch(
        error => {
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          throw new Error(error);
        }
      );

      // サインイン失敗時の設定
      await this.setSignInFailSetting(this.facilitylistValue);

      this.$ons.notification.alert({
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // title: "更新完了",
        // message: "マスタ更新が完了しました。"
        title: DIALOG_MESSAGES[12000004].title,
        message: messageFormat(DIALOG_MESSAGES[12000004].message),
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      });

      await this.findList();
      // 共通ローダー:表示終了
      this.setLoadingScreenVisible(false);
    },
    /**
     * @description 必須項目チェック
     * @summary 未入力の必須項目があったらダイアログを表示する
     * @returns {Boolean} true: 未入力なし, false: 未入力あり
     */
    isFilledRequired() {
      // 設定によって必須の有無が変わる項目の値を取得
      const urlSignin = this.getUpdateRecordList.find(
        item => item.facilitySettingNo === URL_SIGNIN
      );
      let req = false;
      // URLサインイン設定で、秘密鍵が必要な場合のみ必須判定する
      if (urlSignin && urlSignin.value === "1") {
        req = this.getUpdateRecordList.some(
          item => item.facilitySettingNo === URL_SIGNIN_SECRETKEY && (item.dispValue === null || item.dispValue === "")
        )
      }
      if (
        this.getUpdateRecordList.some(
          item => item.facilitySettingNo != URL_SIGNIN_SECRETKEY &&
            item.facilitySettingNo != TREATMENT_PROGRESS_CHART &&
            item.facilitySettingNo != TREATMENT_PROGRESS_CHART_HANDWRITING &&
            item.facilitySettingNo != DAILY_INSPECTION_RECORD_BOOK &&
            item.facilitySettingNo != PERIODIC_INSPECTION_RECORD_BOOK &&
            // add #12462 患者情報共有 ligh start
            item.facilitySettingNo != SHR_PAT_INFO &&
            // add #12462 患者情報共有 ligh end
            item.facilitySettingNo != STATUS_MAP_TREATMENT_INDICATOR &&
            item.facilitySettingNo != STATUS_MAP_SCHEDULE_INDICATOR &&
            (item.dispValue === null || item.dispValue === "")
        ) || req
      ) {
        this.isDialogVisible = true;
        this.messageCd = 20010002;
        this.stringParams = ["設定値"];
        return false;
      }
      return true;
    },

    // -----------------------------------------
    // 抽出UI表示イベント
    // -----------------------------------------
    showPopover(event) {
      this.popoverTarget = event;
      this.popoverVisible = true;
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name
          && document.getElementsByTagName("ons-alert-dialog").length === 0) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
           // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                this.clearScrollPosition();
                this.findList();
              }
            }
          });
        } else {
          this.clearScrollPosition();
          this.findList();
        }
      }
    },
    /**
     * @description スクロールバーの位置をクリアする
     */
    clearScrollPosition() {
      this.scrollTop = 0;
      this.scrollLeft = 0;
    },
    /**
     * @description 編集時、テキストボックスをDB指定の入力フィールドへ変換
     * @summary inputType 1.テキストボックス 2.数値用テキストボックス 3.ドロップダウンリスト(ON/OFF選択用) 4.ドロップダウンリスト(DB設定項目の選択)
     * @param container grid生成情報
     * @param data DB取得値
     */
    editorInput(container, data) {
      // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 start
      if(data.model.inputType == 7){
        const valuesInitial = data.model.val ? data.model.val : data.model.value;
        data.model.dispValue = JSON.parse(valuesInitial);
        const vm = this;
        const syncAndSave = (widget) => {
          let values = widget.value();
          const optionValue = JSON.parse(data.model.optionValue);
          const limitedNo = [
            TREATMENT_PROGRESS_CHART,
            TREATMENT_PROGRESS_CHART_HANDWRITING,
            DAILY_INSPECTION_RECORD_BOOK,
            PERIODIC_INSPECTION_RECORD_BOOK
          ];
          if (limitedNo.includes(data.model.facilitySettingNo)) {
            if (values.length > 3) {
              values = values.slice(0, 3);
              widget.value(values);
            }
          }
          data.model["val"] = JSON.stringify(values);
          data.model["value"] = JSON.stringify(values);
          if (optionValue) {
            const selectedItems = [];
            values.forEach(v => {
              const item = optionValue.find(opt => opt.id === v);
              if (item) selectedItems.push(item);
            });
            let dispText = "";
            selectedItems.forEach(item => {
              dispText = vm.buildTextMultiSelect(dispText, item.name, data.model);
            });
            data.model.dispValue = dispText;
          }
        };
        $(`<select name="${data.field}" multiple="multiple"></select>`)
          .appendTo(container)
          .kendoMultiSelect({
            autoClose: false,
            filter: "contains",
            dataSource: $.parseJSON(data.model.optionValue),
            dataTextField: "name",
            dataValueField: "id",
            headerTemplate: `
              <div style="padding: 8px 10px; border-bottom: 1px solid \\#ccc;">
                <span id="custom-search-container" class="k-textbox k-space-right" 
                      style="width: 100%; display: flex; align-items: center; transition: all 0.2s ease; border-color: \\#ccc;">
                  <input 
                    class="custom-header-search" 
                    style="width: 100%; border: none; outline: none; background: transparent; padding: 4px 0;" 
                    onmousedown="window.preventKendoClose = true;"
                    onblur="window.preventKendoClose = false;"
                  />
                  <span class="k-icon k-i-zoom" style="margin-right: 8px; color: \\#666;"></span>
                </span>
              </div>
            `,
            open: function (e) {
              const widget = e.sender;
              const popup = widget.popup.element;
              const headerInput = popup.find(".custom-header-search");
              const searchContainer = popup.find("#custom-search-container");
              
              headerInput.on("mousedown click", function (ev) {
                ev.stopPropagation(); 
                $(this).focus(); 
              });

              headerInput.on("focus", function() {
                  searchContainer.attr("style", searchContainer.attr("style") + "border: 2px solid green !important;");
              }).on("blur", function() {
                  searchContainer.attr("style", searchContainer.attr("style").replace("border: 2px solid green !important;", "border: 1.5px solid \\#ced4da !important;"));
              });

              headerInput.on("input", function () {
                const value = $(this).val();
                widget.dataSource.filter({
                  field: "name",
                  operator: "contains",
                  value: value
                });
              });
            },
            change: function (e) {
              const widget = e.sender;
              syncAndSave(e.sender);
              const headerInput = widget.popup.element.find(".custom-header-search");
              headerInput.val("");
              widget.dataSource.filter({});
              e.sender.input.val("");
              e.sender.search("");
            },
            close: function (e) {
              if (window.preventKendoClose || $(document.activeElement).hasClass("custom-header-search")) {
                e.preventDefault();
                return false;
              }
            }
          })
          .blur(() => {
            const valuesJson = data.model["val"] || data.model["value"]
            const optionValue = JSON.parse(data.model.optionValue);
            if (optionValue && valuesJson) {
              // 選択項目を取り出す
              const values = JSON.parse(valuesJson)
              const optionValueItem = []
              values.forEach(value => {
                const optItem = optionValue.find(item => item.id === value)
                if (optItem) optionValueItem.push(optItem)
              })
              // dispValue設定
              let dispText = ""
              optionValueItem.forEach(item => dispText = vm.buildTextMultiSelect(dispText, item.name, data.model));
              data.model.dispValue = dispText
            }

          });
      // add redmine 4675 医療材料表示順、投与薬剤表示順の不正 孔 end
      } else if(data.model.facilitySettingNo == '1012' || data.model.facilitySettingNo == '1014'){
     //#10715：日付IF修正20240910検証NG対応：村上Start
     //   $(`<input type='time' name="${data.field}" class="k-input k-textbox k-valid" data-bind="value:dispValue"/>`)
     //   .appendTo(container);
        if(data.model.facilitySettingNo == '1012') {
          $(`<span style="position:relative"><input type="time"  id="${data.field}" name="${data.field}" class="time-wrapper" style="width: 7em;" data-bind="value:dispValue" ></span>`
          ).appendTo(container);
        } else {
          $(`<span style="position:relative"><input type="time"  id="${data.field}" name="${data.field}" class="time-wrapper" style="width: 7em;" data-bind="value:dispValue" ></span>`
          ).appendTo(container);
        }

        const idtag = document.getElementById("dispValue");
        this.listener = (event) => {
                    if (event.key === "Delete" || event.key === "Backspace") {
                      // イベントのデフォルト動作をキャンセルする
                      event.preventDefault();
                    }
                };
        idtag.addEventListener('keydown', this.listener);

        //#10715：日付IF修正20240910検証NG対応：村上End
      // mod 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s start
      // if (data.model.inputType == 4 || data.model.inputType == 5 || data.model.inputType == 9 ) {
      } else if (data.model.inputType == 4 || data.model.inputType == 5 || data.model.inputType == 9 || data.model.inputType == 8) {
        // data.model.dispValue = data.model.val ? data.model.val : data.model.value;
      // mod 施設設定マスタ 帳票未指定時のデフォルト帳票を指定可能 孔s end
      // $(`<input class="k-textbox" name="${data.field}"/>`)
      $(`<input class="k-textbox" name="${data.field}" data-bind="value:value"/>`)
        .appendTo(container)
        .kendoDropDownList({
          dataSource: $.parseJSON(data.model.optionValue),
          dataTextField: "name",
          dataValueField: "id",
          change:function(e){
            // #8676 文字列検索＋プルダウン選択にて、検索結果から選択できない。修正 林峻峰 start
            // data.model["val"] = JSON.parse(data.model.optionValue)[e.sender.selectedIndex].id
            // data.model.dispValue = JSON.parse(data.model.optionValue)[e.sender.selectedIndex].name
            const optionValue = JSON.parse(data.model.optionValue);
            let name = ''
            optionValue.forEach((item)=>{
              if (item.id === e.sender._old) {
                name = item.name;
              }
            })
            data.model["val"] = e.sender._old;
            data.model.dispValue = name;
            // #8676 文字列検索＋プルダウン選択にて、検索結果から選択できない。修正 林峻峰 end

          },
          filter: "contains",
        })
        // add 施設設定マスタ テキストが正しく表示されない  孔s start
        .blur(() => {
          const value = data.model["val"] || data.model["value"]
          const optionValue = JSON.parse(data.model.optionValue)
          if (optionValue && value) {
            const optionValueItem = optionValue.find(e => e.id === value)
            if (optionValueItem && optionValueItem.name) {
              data.model.dispValue = optionValueItem.name
            }
          }
        });
        // add 施設設定マスタ テキストが正しく表示されない  孔s end

      }else if(data.model.inputType == 3){
        $(`<input class="k-textbox" name="${data.field}"/>`)
          .appendTo(container)
          .kendoDropDownList({
            dataSource: [{"id":"0", "name":"OFF"},{"id":"1", "name":"ON"}],
            dataTextField: "name",
            dataValueField: "name"
          });

      }else if(data.model.inputType == 2){
        var numberScope = $.parseJSON(data.model.optionValue ? data.model.optionValue : null);
        // mode 9200 by kangjie 20230908 start
        const numericTextBoxOptions = {
            min:numberScope ? numberScope[0].min : null,
            max:numberScope ? numberScope[0].max : null,
            decimals: 0,
            format: "n0",
                restrictDecimals: true,
                change:function(e){
            if (data.model.facilitySettingNo == "3008") {
              // 有効投薬指示取得期間設定値 -1: 上限なし
              data.model.dispValue = data.model.dispValue === "-1" || data.model.dispValue == null ? "-1":data.model.dispValue +"日";
            }
          }
        };
        $(`<input class="k-numerictextbox" name="${data.field}"/>`)
          .appendTo(container)
            .kendoNumericTextBox(numericTextBoxOptions);
        // mode 9200 by kangjie 20230908 end
      }else if(data.model.inputType == 1){
        /** mod テキストボックスの桁数制御を対応 劉 start*/
        var textScope;
        data.model.optionValue !== "" ? textScope = $.parseJSON(data.model.optionValue)[0].maxlength : textScope = "128";
        /* $(`<input type="text" class="k-input k-textbox k-valid" name="${data.field}" maxlength="128" data-bind="value:dispValue"/>`).appendTo(container)*/
        $(`<input type="text" class="k-input k-textbox k-valid" name="${data.field}" maxlength="${textScope}" data-bind="value:dispValue"/>`)
          .appendTo(container)
        /** mod テキストボックスの桁数制御を対応 劉 end*/
      }else if(data.model.inputType == 6){
        $('<textarea data-text-field="Label" class="k-textbox k-valid" data-value-field="Value" data-bind="value:dispValue" style="width: ' + (container.width() - 10) + 'px;height:' + (container.height() - 12) + 'px;margin-top:10px;margin-bottom:10px;resize:vertical;max-height:65vh;" />').appendTo(container);

      }else{
        this.editingFlg = false;
        $(`<label>${data.model.value}</label>`).appendTo(container);
      }
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      this.$router.go(-1);
    },
    /**
     * 入力分類「7: マルチセレクト」表示用のテキスト生成 
     */
    buildTextMultiSelect(text = "", addText = "", columnData) {
      const concatString = [SHR_PAT_INFO, STATUS_MAP_TREATMENT_INDICATOR, STATUS_MAP_SCHEDULE_INDICATOR].includes(columnData.facilitySettingNo) ? " " : " > ";
      const sym = text.length > 0 ? concatString : "";
      return text + sym + " [ " + addText + " ] ";
    }
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.setUserType(this.getStateUserAccountInfo.userType);
    // mod マスタ一覧 1･施設切替を可能とする 孔s start
    // this.findFacilityList();`
    this.facilitylistValue = this.getFacilitySwitch
    this.findList()
    // mod マスタ一覧 1･施設切替を可能とする 孔s end
    this.setCondition(this.condition);
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
    EventBus.$on("refresh", this.refresh);
    this.$nextTick(() => {
      const footerHeight = document.getElementById('grid-footer').clientHeight
      this.footerHeight = footerHeight
    })
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },
  beforeDestroy() {
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
  }
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.ntss-list{
  display: flex;
  flex-direction: column;
  height: 100%;
}
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
#grid-footer {
  margin: 0;
  padding: 5px 5px 5px 5px;
  /* bottom: 0;
  position: absolute; */
  width: inherit;
}
.kendo-grid-toolbar-style {
  height: calc(100% - 40px);
  border-bottom: none;
}
.toolbar-btn {
  font-size: 1.0em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.k-grid-toolbar {
  padding: 0 0.3em;
}
::v-deep .k-selectable tbody tr td{
  overflow:  visible;
  white-space: normal;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
</style>
