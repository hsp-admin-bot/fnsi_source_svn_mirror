/**
 * 自己診断判定マスタメンテナンスデータページ  MainContent
 */
<template>
  <div class="main-content-area master-maintenance-page">
    <div class='ntss-list ntss-new-width' :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button v-show="!isSortMode && isAllowAddRecord" style="float: left;" modifier="outline" class="btn3-normal toolbar-btn" @click="addRow()">追加</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn csv-btn" style="margin-right:1em" v-show="!isSortMode && isAllowAddRecord && !iosFlg && !androidFlg && systemUseSetting !== '1'" @click="importCsv()">CSV取込</v-ons-button>
          <div v-show="isMobileDevice" class="custom-switch-wrapper">
            <label class="fab-font-color">編集</label>
            <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
          </div>
          <v-ons-button v-show="!isSortMode && isAllowSort" modifier="outline" class="btn3-normal toolbar-btn" @click="toRankEditBtnClick()">並び順表示</v-ons-button>
          <v-ons-button v-show="isSortMode && isAllowSort" modifier="outline" class="btn3-normal toolbar-btn" @click="sortBtnClick()">反映</v-ons-button>
        </div>
        <!-- ソート後グリッド表示 -->
          <kendo-grid :class="fontSizeSet"
          id="grid-font-size"
          ref="grid"
          :data-source="masterRecords"
          :editable="true"
          :selectable="true"
          :reorderable="false"
          :height="kendoGridHeight"
          :scrollable="true"
          :beforeEdit=onBeforeEdit
          :cellClose=editEnd
          class="content-style"
          @save="onSave"
          @databound="onDataBoundKendoGrid">
          <template v-for="(column, index) in columns" >
            <kendo-grid-column
              v-if="column.title === '対象機種'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
            />
            <!-- 編集モーダル列 -->
            <kendo-grid-column
              v-else-if="column.title === '詳細'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :attributes="{ class: 'btn3-kendo-normal' }"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              :command="{ text: '詳細', click: showMasterEditModal }"
            />
            <!-- add #7289-マスタの削除ボタンが縦表示になる 徐博 start-->
            <kendo-grid-column
              v-else-if="column.title === '削除'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              :locked="column.locked"
              width="9em"
              :format="column.format"
              :values="column.values"
            />
            <!-- add #7289-マスタの削除ボタンが縦表示になる 徐博 end-->
            <kendo-grid-column v-else
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :editable="column.editable"
              :locked="column.locked"
              :width="column.width"
              :format="column.format"
              :values="column.values">
            </kendo-grid-column>
          </template>
        </kendo-grid>
      </kendo-grid-toolbar>
      <div id="grid-footer">
        <v-ons-row :style="{ visibility:this.isSortMode ?  'hidden' : 'visible' }" width="100%">
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord">保存</v-ons-button>
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
import $ from "jquery";
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
import { UFRC, BLOOD_LEAKAGE, DIALYSATE_FLOW_RATE, CONCENTRATION } from "@/constants/mstSelfMeasureResultDefine";

// 自己診断判定マスタ デフォルト値
const SELF_MEASURE_RESULT_ITEMS = [
  ...UFRC,
  ...BLOOD_LEAKAGE,
  ...DIALYSATE_FLOW_RATE,
  ...CONCENTRATION
];

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
      condition: {
        recordName: "",
        includeDeleted: false
      },
      updateResponse: {
        isSuccess: false,
        errorMessage: ""
      },
      isSortMode: false,
      isSorted: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      masterCsvVisible: false,
      masterCsvTarget: null,
      //自画面の名称
      selfScreenName: "",
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
    };
  },
  computed: {
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
      systemUseSetting: "getSystemUseSetting"
    }),
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      getFacilitySwitch: "getFacilitySwitch",
      // #9275 自己診断判定マスタの並び順が保存できない linjunfeng start
      isRecordModified: "isRecordModified"
      // #9275 自己診断判定マスタの並び順が保存できない linjunfeng end
    }),

    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
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
        data !== undefined &&
        // add #6279[自己診断判定マスタ] dengshen start
        this.kendoValidator !== undefined &&
        // add #6279[自己診断判定マスタ] dengshen end
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 20240119 linjunfeng start
        // (data.filter(row => row.operation > 0).length ||
        // #10053 破棄確認・保存活性(複数変更含む)・削除対応_自己診断判定マスタ 20240119 linjunfeng end
          (this.isSorted ||
          // #9275 自己診断判定マスタの並び順が保存できない linjunfeng start
          this.isRecordModified || 
          // #9275 自己診断判定マスタの並び順が保存できない linjunfeng end
          !this.kendoValidator.validate())
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

  created() {
    this.setLoadingScreenVisible(true);
    this.calculateColumnsWidth();
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
    EventBus.$on("refresh", this.refresh)
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
  },
  // add 性能改善メモリ不足 shan end
  mounted() {
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
  },

  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
    this.$nextTick(() => {
      this.autoFitGridColumns();
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
  },

  methods: {
    ...mapActions("multi-modal", [
      "showMstSelfMeasureResultMainModal"
    ]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "findColumnInfo",
      "setMasterRecordList",
      "edit",
      "setComparisonRecordModel",
      "setCondition",
      "updateRecordList",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      "findRecordListByFacilityCdWithSql",
    ]),
    ...mapActions("mst-self-measure-result", [
      "fetchMachineTypeList"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    /**
     * @description 内容列のkendo editor
     */
    // contentEditor(container, data) {
    //   $(
    //     `<textarea name="${data.field}" class="k-valid k-textarea" style="font-size: 1.0em;"/>`
    //   ).appendTo(container);
    //   this.$refs.grid.kendoWidget().autoFitColumn(
    //     this.columns.findIndex(c => c.field === data.field)
    //   );
    //   this.calculateGridWidth();
    // },
    // データの取得
    loadGridData() {
      // delete start #9590
      // this.setCondition(this.condition);
      // delete end #9590
      this.findList();
    },
    // マスタ一覧のデータを取得
    async findList() {
      // 型式一覧を取得
      await this.fetchMachineTypeList();
      // apiをコールして値を取得
      // add マスタ一覧 1･施設切替を可能とする 王
      // this.findRecordList()
      this.findRecordListByFacilityCdWithSql(this.getFacilitySwitch)
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
          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          toFunction.forEach(column => {
            // 初期表示時の編集可否を退避
            column.originalEditable = column.editable;
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column.width = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            if (column.field === "dispMachineName") {
              column.width = "25em";
            } else {
              column.width = "8em";
            }
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
            locked: true,
            width: "10px",
            format: "",
            values: null
          });
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          // カラム幅等初期調整
          this.showSortColumn();

          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
            // 元のスクロール位置に移動
            // mod スクロールの位置を維持
            this.$refs.grid.$el.children[2].scrollTop = this.scrollTop;
            this.$refs.grid.$el.children[2].scrollLeft = this.scrollLeft;
            setTimeout(() => {
              this.scrollTop = 0;
              this.scrollLeft = 0;
            }, 1000);
            // mod スクロールの位置を維持
          });
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstSelfMeasureResultMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
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

    showMasterEditModal(e){
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $("div.k-grid-content")[0];
      this.scrollTop = grid.scrollTop;
      this.scrollLeft = grid.scrollLeft;
      this.editFlg = true;
      // モーダル画面表示
      this.showMstSelfMeasureResultMainModal();
      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      let code = selectedRowItem.code;

      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
        code = this.getMasterRecordList.data[0].code;
      }

      // プロパティを正規化する。
      const normalizedItem = this.normalization(selectedRowItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);
    },
    saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $("div.k-grid-content")[0];
      this.scrollTop = grid.scrollTop;
      this.scrollLeft = grid.scrollLeft;
      this.editFlg = true;
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        r => !(r.operation === 1 && !r.edited)
      );
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message +  messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage;
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
           // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES[12000006].title,
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        return;
      }

      // apiをコールして値を保存
      // add マスタ一覧 1･施設切替を可能とする 王
      // this.updateRecordList(this.getUpdateRecordList)
      this.updateRecordListByFacilityCd({facilityCd: this.getFacilitySwitch, request: this.getUpdateRecordList})
        .then(response => {
          this.updateResponse = response.data;
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);

          this.$ons.notification.alert({
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "マスタ更新が完了しました。"
            title: DIALOG_MESSAGES[12000004].title,
            message: messageFormat(DIALOG_MESSAGES[12000004].message),
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          });
          this.isSorted = false;

          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstSelfMeasureResultMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
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

      // 初期値を設定
      Object.keys(fields).forEach(k => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (fields[k].type === "string") {
          d[k] = "";
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (fields[k].type === "date") {
          d[k] = new Date();
        } else {
          d[k] = null;
        }

        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        } else if (k === "machineInfo") {
          d[k] = "[]"
        } else if (k === "selfMeasureResult") {
          // デフォルト値を展開
          const selfMeasureResult = SELF_MEASURE_RESULT_ITEMS.map(item => ({
            key: item.jsonAddress,
            judge: "0",
            caution_up: item.default_caution_up,
            failure_up: item.default_failure_up,
            caution_low: item.default_caution_low,
            failure_low: item.default_failure_low
          }));
          d[k] = JSON.stringify(selfMeasureResult);
        }
      });
      this.lastScrollTop = this.$refs.grid.$el.lastChild.scrollHeight;
      // 画面編集内容をstoreに反映 ※新規レコード追加
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      // 色変え？
      this.editBackgroundColor();
    },
    /**
     * KendoGridデータバインド時イベントハンドラ.
     * 値変更時にスクロール位置が先頭に戻ってしまう問題の対処
     *
     * @param {*} ev イベント
     */
    onDataBoundKendoGrid(ev) {
      this.autoFitGridColumns();
      // スクロール位置が先頭でない場合、その位置を保持する
      const scrollTop = ev.sender.content[0].scrollTop;
      const scrollLeft = ev.sender.content[0].scrollLeft;
      if (scrollTop != 0) {
        this.lastScrollTop = scrollTop;
      }
      if (scrollLeft != 0) {
        this.lastScrollLeft = scrollLeft;
      }

      if (this.lastScrollTop != 0 || this.lastScrollLeft != 0) {
        this.$nextTick(() => {
          ev.sender.content[0].scrollTop = this.lastScrollTop;
          ev.sender.content[0].scrollLeft = this.lastScrollLeft;
          setTimeout(() => {
            this.lastScrollTop = 0;
            this.lastScrollLeft = 0;
          }, 1000)
        });
      }
    },
    autoFitGridColumns() {
      for (let i = 0; i < this.$refs.grid.kendoWidget().columns.length; i++) {
        if (["name", "content"].includes(this.$refs.grid.kendoWidget().columns[i].field)) {
          this.$refs.grid.kendoWidget().autoFitColumn(i);
        }
      }
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
  }
};
</script>

<!-- 個別スタイル定義 -->
<style>
.ntss-new-width .k-grid-edit-row td>.k-widget.k-tooltip-validation:not(.k-switch), .k-edit-cell>.k-widget.k-tooltip-validation:not(.k-switch) {
  width: 170px;
}
</style>
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
.k-grid-toolbar span {
  margin: 0;
}
.content-style >>> .k-grid-content{
  white-space: pre-wrap;
}
.custom-switch-wrapper {
  display: flex;
  float: left;
  align-items: center;
  min-width: 7em;
  margin-left: 10px;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
.mobile-header {
  min-height: 35px; /* モバイル用の高さ */
}
</style>
