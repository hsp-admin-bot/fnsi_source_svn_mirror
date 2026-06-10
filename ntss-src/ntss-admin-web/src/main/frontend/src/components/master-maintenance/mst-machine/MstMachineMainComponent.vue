/** * 装置マスタメンテナンスデータページ MainContent */
<template>
  <div class="main-content-area master-maintenance-page">
    <div
      class="ntss-list"
      :style="ntssListStyles"
      v-kendo-validator="kendoValidatorSetup"
    >
      <kendo-grid-toolbar
        class="k-grid-toolbar kendo-grid-toolbar-style"
        :style="heightStyles"
      >
        <div id="grid-header" :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button
            class="btn3-normal toolbar-btn"
            style="float: left; margin-right:10px;"
            v-show="!isSortMode && isAllowAddRecord"
            @click="addRow()"
            >追加</v-ons-button
          >
          <v-ons-button
            v-show="!isSortMode && isAllowAddRecord"
            class="btn3-normal toolbar-btn"
            style="float: left; margin-left: 1px"
            @click="showRegistModal"
            >装置検索登録</v-ons-button
          >
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 1em;">
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
            style="margin-right: 10px"
            v-show="!isSortMode && isAllowSort"
            @click="importCsv()"
            >CSV取込
          </v-ons-button>
          <v-ons-button
            class="btn3-normal toolbar-btn"
            v-show="!isSortMode && isAllowSort"
            @click="toRankEditBtnClick()"
            >並び順表示</v-ons-button
          >
          <v-ons-button
            class="btn3-normal toolbar-btn"
            v-show="isSortMode && isAllowSort"
            @click="sortBtnClick()"
            >反映</v-ons-button
          >
        </div>
        <kendo-grid
          :class="fontSizeSet"
          id="grid-font-size"
          ref="grid"
          :data-source="masterRecords"
          :editable="true"
          :selectable="true"
          :reorderable="false"
          :height="kendoGridHeight"
          :scrollable="true"
          :beforeEdit="onBeforeEdit"
          :cellClose="editEnd"
          @save="onSave"
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
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              :command="{ text: '詳細', click: showMasterEditModal }"
            ></kendo-grid-column>
            <!-- #8918 ポート 整数を制限します 张博 start -->
            <kendo-grid-column
              v-else-if="column.field === 'port'"
              :key="index"
              :title="column.title"
              :field="column.field"
              :hidden="column.hidden"
              :locked="column.locked"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              :editor="editorInput"
            ></kendo-grid-column>
            <!-- #8918 ポート 整数を制限します 张博 end -->
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
        <v-ons-row
          width="100%"
          :style="{ visibility: this.isSortMode ? 'hidden' : 'visible' }"
        >
          <v-ons-col width="50%">
            <v-ons-button
              class="btn2-cancel denial-btn"
              style="width: auto"
              @click="cancel"
              >キャンセル</v-ons-button
            >
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="btn1-execute registration-btn"
              style="width: auto"
              :disabled="!isChanged"
              @click="saveRecord"
              >保存</v-ons-button
            >
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
import $ from "jquery";
import { mapActions, mapGetters, mapMutations } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { sendRequestGetMstFacilityHashByFacilityCd } from "@/apis/mst-facility-hash";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from "@/functions/common/MessageFormat";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  components: {
    "master-csv": MasterCsvComponent,
  },
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
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
      isSorted: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {},
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      // 編集前情報のバックアップ
      preEditMasterRecordList: [],
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0,
      },
      // 選択中の施設コード
      facilitylistValue: "",
      // 自画面の名称
      selfScreenName: "",
      //変更前の施設
      prevFacilityCd: "",
      //選択施設のシステム利用設定
      facilitySysUseSetting: "",
      masterCsvVisible: false,
      masterCsvTarget: null,
      // add デバイスエッジのいずれか同期失敗であれば、同期中止問題の対応 劉 start
      // 同期失敗のデバイスエッジ
      errorName: [],
      // add デバイスエッジのいずれか同期失敗であれば、同期中止問題の対応 劉 end
      // add #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei start
      intervalID: null,
      // add #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
    };
  },
  computed: {
    ...mapGetters("master-maintenance", {
      getFacilitySwitch: "getFacilitySwitch",
      // #9275 装置マスタの並び順が保存できない linjunfeng start
      isRecordModified: "isRecordModified",
      // #9275 装置マスタの並び順が保存できない linjunfeng end
    }),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth",
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
    }),
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
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
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
        data !== undefined &&
        (data.filter((row) => row.operation > 0).length ||
          this.isSorted ||
          // #9275 装置マスタの並び順が保存できない linjunfeng start
          this.isRecordModified ||
          // #9275 装置マスタの並び順が保存できない linjunfeng end
          !this.kendoValidator?.validate())
      );
    },
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
    ...mapGetters("mst-machine", {
      getMachineTypeList: "getMachineTypeList",
      getDeviceEdgeList: "getDeviceEdgeList",
      getFacilityList: "getFacilityList",
      getComTypeList: "getComTypeList",
      getMessageList: "getMessageList",
    }),
    ...mapGetters("toggle-dev-tool", ["isLockDevTool"]),
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
    columns: function (val) {
      this.$nextTick(function () {
        if (val.length > 1) this.setLoadingScreenVisible(false);
      });
    },
  },
  methods: {
    ...mapActions("multi-modal", ["showMasterEdit", "showMntFindMachineModal"]),
    ...mapActions("master-maintenance", [
      "findRecordListByFacilityCd",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "findColumnInfo",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      // #9275 装置マスタの並び順が保存できない linjunfeng start
      "setComparisonRecordModel",
      // #9275 装置マスタの並び順が保存できない linjunfeng end
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount",
    }),
    ...mapActions("mst-machine", [
      "getComboRecordList",
      "deleteMstMachineList",
      "synchroMstMachine",
      "facilityList",
      "updateSwitchOfflineMachineState",
      "updateChangeMachineState",
      "setFacilitySysUseSetting",
      "sendRequestGetDialysisState",
      "setEntryMachineList",
      "setEditCode",
    ]),
    ...mapMutations("mst-machine", ["setSelectedFacilityCd"]),
    // 装置マスタ 障害対応 編集してない状態で「マスタ編集（装置マスタ）」ボタンを押下するとメッセージが表示される start
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (
        this.selfScreenName === this.$router.currentRoute.name &&
        document.getElementsByTagName("ons-alert-dialog").length === 0
      ) {
        if (this.isChanged) {
          this.$ons.notification.confirm({
            title: DIALOG_MESSAGES[12000014].title,
            // add 全マスタメッセージ調整 王 start
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: DIALOG_MESSAGES[12000014].message,
            // add 全マスタメッセージ調整 王 end
            callback: (answer) => {
              if (answer === 1) {
                this.loadGridData();
              }
            },
          });
        } else {
          this.loadGridData();
        }
      }
    },
    // 装置マスタ 障害対応 編集してない状態で「マスタ編集（装置マスタ）」ボタンを押下するとメッセージが表示される end
    // グリッドのデータ再表示
    gridDataRefresh() {
      const grid = this.$refs.grid;
      grid.dataSource = [];
      grid.dataSource = this.masterRecords;
    },
    async systemUseSetting() {
      if (this.facilitylistValue) {
        // 施設のシステム利用設定を取得する
        const mstFacilityHash = await sendRequestGetMstFacilityHashByFacilityCd(
          this.facilitylistValue
        );
        this.facilitySysUseSetting = mstFacilityHash.data.systemUseSetting
          ? mstFacilityHash.data.systemUseSetting
          : "";
      } else {
        this.facilitySysUseSetting = "";
      }
    },
    // マスタ一覧のデータを取得
    findList() {
      // システム利用設定取得処理
      this.systemUseSetting();
      // 選択中の施設コードをStoreに保存する
      this.setSelectedFacilityCd(this.facilitylistValue);
      // apiをコールして既存の装置マスタから条件送信済み～治療中の装置を取得
      this.sendRequestGetDialysisState(this.facilitylistValue).then(
        (response) => {
          this.setEntryMachineList(response.data);
        }
      );
      // apiをコールして型式マスタ、デバイスエッジの値を取得
      this.getComboRecordList(this.facilitylistValue).then(() => {
        // apiをコールして値を取得
        this.findRecordListByFacilityCd(this.facilitylistValue)
          .then((response) => {
            // 編集前初期値を保存
            this.preEditMasterRecordList = deepCopy(this.getMasterRecordList);
            // editableをKendoUI用にfunctionオブジェクトに変換
            const toFunction = response.data.columns;
            toFunction.forEach((column) => {
              // 初期表示時の編集可否を退避
              column.originalEditable = column.editable;
              // 編集可否を関数化
              column.editable = column.editable ? () => true : () => false;
              // 列幅初期化
              column["width"] = column.width ? column.width : "0";
            });
            // 型式コンボボックス用データ取得
            const machineTypeList = this.getMachineTypeList;
            // デバイスエッジコンボボックス用データ取得
            const deviceEdgeList = this.getDeviceEdgeList;
            // 通信種別コンボボックス用データ取得
            const comTypeList = this.getComTypeList;
            toFunction.forEach((column) => {
              // 型式コンボ用データを追加
              if (column.field === "machineTypeCd") {
                column.values = machineTypeList;
              }
              // デバイスエッジコンボ用データを追加
              if (column.field === "deviceEdgeNo") {
                column.values = deviceEdgeList;
              }
              // 通信種別コンボ用データを追加
              if (column.field === "comType") {
                column.values = comTypeList;
              }
            });

            this.columns = toFunction.filter(function (col) {
              return col;
            });

            // 横スクロールバーを表示するために列幅を指定
            this.columns.forEach((column) => {
              // 「削除」のプルダウンが改行しない幅に調整
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
              column.width =
                column.field === "isDisp" ? "9em" : this.columnWidth + "em";
              // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
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
            // ReMsの場合、装置ビューア使用を非表示
            if (this.facilitySysUseSetting === "1") {
              this.columns.forEach((column) => {
                if (column.field === "isVa") {
                  column.hidden = true;
                }
              });
            }
            // #9275 装置マスタの並び順が保存できない linjunfeng start
            // 初期データ内容を保存
            this.setComparisonRecordModel();
            // #9275 装置マスタの並び順が保存できない linjunfeng end
            // カラム幅等初期調整
            this.showSortColumn();
            this.$nextTick(() => {
              this.calculateGridHeight();
              this.calculateGridWidth();
              // 元のスクロール位置に移動
              // mod スクロールの位置を維持
              this.$refs.grid.$el.children[2].scrollTop = this.lastscrollTop;
              this.$refs.grid.$el.children[2].scrollLeft = this.lastscrollLeft;
              setTimeout(() => {
                this.lastScrollTop = 0;
                this.lastScrollLeft = 0;
              }, 1000);
              // mod スクロールの位置を維持
            });
          })
          .catch((error) => {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage(
              "MstMachineMainComponent.vue",
              "findList",
              "指定されたマスタが見つかりません。"
            );
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
      });
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    //#8918 ポート 整数を制限します 张博 start
    editorInput(container, data) {
      $(`<input class="k-numerictextbox" name="${data.field}"/>`)
        .appendTo(container)
        .kendoNumericTextBox({
          //整数を制限します
          max: 65535,
          min: 0,
          decimals: 0,
          format: "n0",
          restrictDecimals: true,
        });
    },
    //#8918 ポート 整数を制限します 张博 end
    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
        // 選択した施設を元に装置一覧の取得
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
          // 選択した施設を元に装置一覧の取得
          this.findList();
        })
        .catch((error) => {
          if (error.response.status === 400) {
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
            getErrorMessage(
              "MstMachineMainComponent.vue",
              "findFacilityList",
              "指定されたマスタが見つかりません。"
            );
            //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
          }
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          else {
            getErrorMessage(
              "MstMachineMainComponent.vue",
              "findFacilityList",
              error
            );
          }
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
        });
    },
    onOpenFacility(e) {
      // 変更前の値を取得
      this.prevFacilityCd = e.sender._old;
    },
    // 施設を選択時の動作
    onChangeFacility(e) {
      if (this.prevFacilityCd != e.sender._old) {
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
          this.findList();
        }
      }
    },
    // 指定したデバイスエッジとのマスタ同期
    synchroMstMachineToDeviceEdge(list, idx) {
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 start
      // let title = "装置マスタ同期";
      let title = messageFormat(
        DIALOG_MESSAGES["00100009"].title,
        "装置マスタ"
      );
      // mod #6107 2023/04/04 メッセージボックス全調整 林峻峰 end

      const infos = list;
      // 同期対象のデバイスエッジがない、または再帰処理でリスト末尾を超えた場合、共通ローダーを終了し処理を抜ける
      if (!infos || infos.length <= idx) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.resetLoadingScreenVisibleCount();
        this.$ons.notification.alert({
          title: DIALOG_MESSAGES[12000004].title,
          message: messageFormat(DIALOG_MESSAGES[12000004].message),
        });
        return;
      }

      const info = infos[idx];
      // マスタ同期
      this.synchroMstMachine({
        deviceEdgeNo: info.value,
        facilityCd: this.facilitylistValue,
      })
        .then(() => {
          if (infos.length === idx + 1) {
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            this.resetLoadingScreenVisibleCount();
            // mod デバイスエッジのいずれか同期失敗であれば、同期中止問題の対応。 劉 start
            if (this.errorName.length > 0) {
              let name = "";
              this.errorName.forEach((e) => {
                name = name + e.text + "</br>";
              });
              name = "デバイスエッジ：</br>" + name + "</br>";
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message:
                //   name +
                //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
                message: messageFormat(DIALOG_MESSAGES[12000333].message, name),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            } else {
              this.$ons.notification.alert({
                title: title,
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
                // message: "マスタ同期が完了しました。"
                message: messageFormat(DIALOG_MESSAGES["00100009"].message),
                // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              });
            }
            this.errorName = [];
            // mod デバイスエッジのいずれか同期失敗であれば、同期中止問題の対応。 劉 end
          } else {
            // 次のデバイスエッジ
            this.synchroMstMachineToDeviceEdge(list, idx + 1);
          }
        })
        .catch((error) => {
          getErrorMessage("MstMachineMainComponent.vue", "synchroMstMachineToDeviceEdge", error);

          const deviceEdgeName = info && info.text ? info.text : "デバイスエッジ";
          getErrorMessage(
            "MstMachineMainComponent.vue",
            "synchroMstMachineToDeviceEdge",
            deviceEdgeName +
              "との同期に失敗しました。デバイスエッジの装置と整合性が取れていないので再度「保存」を行ってください。"
          );

          this.errorName.push(info);
          if (infos.length === idx + 1) {
            let name = "";
            this.errorName.forEach((e) => {
              name = name + e.text + "</br>";
            });
            name = "デバイスエッジ：</br>" + name + "</br>";
            //共通ローダー：表示終了
            this.setLoadingScreenVisible(false);
            // add/ #12573装置マスタで保存後にマスタ同期中にもかかわらず処理中が消える tianqidong start
            this.resetLoadingScreenVisibleCount();
            // add/ #12573装置マスタで保存後にマスタ同期中にもかかわらず処理中が消える tianqidong end
            this.$ons.notification.alert({
              title: title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // message:
              //   name +
              //   "との同期に失敗しました。<br>デバイスエッジの装置と整合性が<br>取れていないので<br>再度「保存」を行ってください。"
              message: messageFormat(DIALOG_MESSAGES[12000333].message, name),
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
            });
            this.errorName = [];
          } else {
            // 次のデバイスエッジ
            this.synchroMstMachineToDeviceEdge(list, idx + 1);
          }
        });
    },
    async validCanNotChangeParam(editedRecords) {
      // apiをコールして既存の装置マスタから条件送信済み～治療中の装置を取得
      let ret = [];
      const response = await this.sendRequestGetDialysisState(
        this.facilitylistValue
      );
      if (response.data) {
        // 治療完了前の装置のコード
        const dialysisCodeList = response.data.map((r) => r.machineNo);
        // 編集されたレコードかつ治療完了前の装置のコード
        const editedRecordList = editedRecords.data.filter(
          (r) =>
            r.facilityCd === this.facilitylistValue &&
            r.operation === 2 &&
            dialysisCodeList.includes(r.code)
        );
        // 編集前のレコード
        const editedCodeList = editedRecordList.map((r) => r.code);
        const preEditRecordList = this.preEditMasterRecordList.data.filter(
          (r) =>
            r.facilityCd === this.facilitylistValue &&
            editedCodeList.includes(r.code)
        );
        for (const edited of editedRecordList) {
          const preEdit = preEditRecordList.find((r) => r.code === edited.code);
          if (
            edited.machineSerial !== preEdit.machineSerial || // 製造番号
            edited.machineTypeCd !== preEdit.machineTypeCd || // 型式
            edited.comType !== preEdit.comType || // 通信種別
            edited.comFormatCd !== preEdit.comFormatCd || // 通信フォーマット
            edited.ipAddress !== preEdit.ipAddress || // IPアドレス
            +edited.port !== +preEdit.port || // ポート番号
            edited.deviceEdgeNo !== preEdit.deviceEdgeNo || // デバイスエッジ
            edited.isDisp === "0" || // 削除フラグ
            edited.isDel === "1"
          ) {
            ret.push(`装置名: ${edited.name}`);
          }
        }
      }
      return this.convertToStr(ret);
    },
    buildSwitchOfflineRequest(editedRecords) {
      // 新たにオフライン装置となったレコード
      const newOfflineCodeList = editedRecords.data
        .filter(
          (r) =>
            r.facilityCd === this.facilitylistValue &&
            r.comFormatCd === "F" &&
            r.operation === 2
        )
        .map((r) => r.code);
      // オフラインから新たにオンライン装置となったレコード
      const editedRecordList = editedRecords.data
        .filter(
          (r) =>
            r.facilityCd === this.facilitylistValue &&
            r.comFormatCd !== "F" &&
            r.operation === 2
        )
        .map((r) => r.code);
      const newOnlineCodeList = this.preEditMasterRecordList.data
        .filter(
          (r) =>
            r.facilityCd === this.facilitylistValue &&
            r.comFormatCd === "F" &&
            editedRecordList.includes(r.code)
        )
        .map((r) => r.code);

      return {
        facilityCd: this.facilitylistValue,
        offline: newOfflineCodeList,
        online: newOnlineCodeList,
      };
    },
    buildChangeMachineRequest(editedRecords) {
      // 編集された装置のコード
      const editedRecordList = editedRecords.data.filter(
        (r) => r.facilityCd === this.facilitylistValue && r.operation === 2
      );
      // 編集前のレコード
      const editedCodeList = editedRecordList.map((r) => r.code);
      const preEditRecordList = this.preEditMasterRecordList.data.filter(
        (r) =>
          r.facilityCd === this.facilitylistValue &&
          editedCodeList.includes(r.code)
      );
      let newOfflineAndCommonCodeList = [];
      let changeMachineCodeList = [];

      console.log("Machine Check!");

      for (const edited of editedRecordList) {
        const preEdit = preEditRecordList.find((r) => r.code === edited.code);
        if (
          edited.machineSerial !== preEdit.machineSerial || // 製造番号
          edited.comType !== preEdit.comType || // 通信種別
          edited.comFormatCd !== preEdit.comFormatCd // 通信フォーマット
        ) {
          // 装置の変更があった
          changeMachineCodeList.push(edited.code);
          if (
            edited.comFormatCd !== preEdit.comFormatCd &&
            edited.comFormatCd === "F"
          ) {
            // 新たにオフラインになった
            newOfflineAndCommonCodeList.push(edited.code);
          } else if (
            edited.comType !== preEdit.comType &&
            +edited.comType === 3
          ) {
            // 新たに医器工になった
            newOfflineAndCommonCodeList.push(edited.code);
          }
        }
      }

      return {
        facilityCd: this.facilitylistValue,
        newOfflineAndCommonCodeList: newOfflineAndCommonCodeList,
        changeMachineCodeList: changeMachineCodeList,
      };
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      // add #8344 【デグレ】チェックリストマスタの保存までが長い dou start
      this.setLoadingScreenVisible(true);
      this.setLoadingScreenVisible(true);
      // add #8344 【デグレ】チェックリストマスタの保存までが長い dou end
      // add スクロールの位置を維持
      this.lastscrollTop = document.getElementsByClassName(
        "k-grid-content k-auto-scrollable"
      )[0].scrollTop;
      this.lastscrollLeft = document.getElementsByClassName(
        "k-grid-content k-auto-scrollable"
      )[0].scrollLeft;
      // add スクロールの位置を維持
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        // add #8580 「マスタの保存時に制限による注意喚起メッセージ後に処理中のまま固まる」について、対応する。 dengshen start
        this.resetLoadingScreenVisibleCount();
        // add #8580 「マスタの保存時に制限による注意喚起メッセージ後に処理中のまま固まる」について、対応する。 dengshen end
        return;
      }

      // 更新前の情報をバックアップ
      this.backupMasterRecordList = JSON.parse(
        JSON.stringify(this.getMasterRecordList)
      );

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
      // 型式+製造番号、IPアドレス重複チェック
      const validateMachineInfoMessage = this.validateMachineTypeSerialNo(
        this.isLockDevTool
      );
      const validateCannotEditedValueMessage =
        await this.validCanNotChangeParam(records);

      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message =
          messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message +
          messageFormat(DIALOG_MESSAGES[12000006].message) +
          validateComboMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateMachineInfoMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の項目で問題があります。" + validateMachineInfoMessage;
          message +
          messageFormat(DIALOG_MESSAGES["00200071"].message) +
          validateMachineInfoMessage;
        // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }
      if (validateCannotEditedValueMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の装置は治療完了前につき変更できない項目が編集されています。" + validateCannotEditedValueMessage;
          message +
          messageFormat(DIALOG_MESSAGES["00200072"].message) +
          validateCannotEditedValueMessage;
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
          message: '<div style="text-align:left;">' + message + "</div>",
        });
        // add #7663 C重複情報のメッセージ画面を表示する。 zhou start
        this.resetLoadingScreenVisibleCount();
        this.$refs.grid.$el.children[2].scrollTop=this.lastscrollTop
        // add #7663 C重複情報のメッセージ画面を表示する。 zhou end
        return;
      }

      // デバイスエッジ一覧
      //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
      const deviceEdgeList = this.getDeviceEdgeList.filter(item => item.del !== '1');
      //mod #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される end
      const switchOfflineRequest = this.buildSwitchOfflineRequest(records);
      const changeMachineRequest = this.buildChangeMachineRequest(records);
      const updRecLst = this.getUpdateRecordList.map((rec) => {
        rec.machineSerial = rec.machineSerial.trim();
        return rec;
      });

      // apiをコールして値を保存
      this.updateRecordListByFacilityCd({
        facilityCd: this.facilitylistValue,
        request: updRecLst,
      })
        .then((response) => {
          this.updateResponse = response.data;

          Promise.all([
            // 新たにオフライン・オンライン装置化したレコードの工程を変更する
            this.updateSwitchOfflineMachineState(switchOfflineRequest),
            this.updateChangeMachineState(changeMachineRequest),
          ]).then(() => {
            this.isSorted = false;
            this.findList();
            // マスタ同期開始
            this.synchroMstMachineToDeviceEdge(deviceEdgeList, 0);
          });
        })
        .catch((error) => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage("MstMachineMainComponent.vue", "saveRecord", error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          // add #7663 C重複情報のメッセージ画面を表示する。 zhou start
          this.resetLoadingScreenVisibleCount();
          // add #7663 C重複情報のメッセージ画面を表示する。 zhou end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage,
            });
          }
          // 更新前の情報に戻す
          const backups = this.backupMasterRecordList;
          this.setMasterRecordList(backups);

          // グリッドのデータ再表示
          this.gridDataRefresh();
        });
    },
    // 装置名、型式+製造番号、IPアドレス重複チェック
    validateMachineTypeSerialNo(isLockDevTool) {
      let validateMessageArr = [];
      let checkMachineTypeSerialNo = [];
      let checkIpAddress = [];

      // IPアドレス正規表現
      const reg = new RegExp(
        "^(([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([1-9]?[0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
      );

      // 製造番号 正規表現
      const regSerial = new RegExp(/^[a-zA-Z0-9!-/:-@¥[-`{-~]*$/);

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data;
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        const rowNo = rowIdx + 1;
        // 製造番号取得
        const machineSerial = rows[rowIdx]["machineSerial"];
        // 型式+製造番号取得
        const key = rows[rowIdx]["machineTypeCd"] + "_" + machineSerial;
        // IPアドレス取得
        const ip = rows[rowIdx]["ipAddress"];
        // 削除対象判定
        const del = rows[rowIdx]["isDisp"] === "1" ? "" : "(削除分)";
        // オフラインフラグ
        const isOffline =
          rows[rowIdx]["comFormatCd"] === "" ||
          rows[rowIdx]["comFormatCd"] === "F";
        // 装置名
        const name = rows[rowIdx]["name"];

        // 装置名未入力チェック
        if (!name) {
          let strerr = "装置名未入力：" + rowNo + " 行目";
          validateMessageArr.push(strerr);
        }
        // 製造番号不正文字チェック
        if (
          machineSerial &&
          machineSerial.length > 0 &&
          !regSerial.test(machineSerial)
        ) {
          let strerr = "製造番号不正文字あり：" + rowNo + " 行目" + del;
          validateMessageArr.push(strerr);
        }
        // 型式+製造番号重複チェック
        let idxNo = 1 + checkMachineTypeSerialNo.indexOf(key);
        if (1 <= idxNo) {
          // 重複あり
          let strerr =
            "型式 + 製造番号重複あり：<br>　　　" +
            idxNo +
            "行目と" +
            rowNo +
            "行目" +
            del;
          validateMessageArr.push(strerr);
        }
        checkMachineTypeSerialNo.push(key);

        // IPアドレス形式チェック
        if (ip && ip.length > 0 && !reg.test(ip)) {
          let strerr = "IPアドレス不正：" + rowNo + " 行目" + del;
          validateMessageArr.push(strerr);
        }

        if (!isOffline && rows[rowIdx]["isDisp"] === "1") {
          // 削除分とオフラインはチェック対象外
          if (reg.test(ip) == true) {
            // IPアドレスOK
            // ユーザーフロートボタン赤でない場合、IPアドレス重複チェックを行う

            if (isLockDevTool) {
              idxNo = 1 + checkIpAddress.indexOf(ip);
              if (1 <= idxNo) {
                // 重複あり
                let strerr =
                  "IPアドレス重複あり：<br>　　　" +
                  idxNo +
                  "行目と" +
                  rowNo +
                  "行目" +
                  del;
                validateMessageArr.push(strerr);
              }
              checkIpAddress.push(ip);
            }
          }
        } else {
          checkIpAddress.push("");
        }
      }

      return this.convertToStr(validateMessageArr);
    },
    showMasterEditModal(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $("div.k-grid-content")[0];
      this.scrollPosition.top = grid.scrollTop;
      this.scrollPosition.left = grid.scrollLeft;

      // モーダルを表示
      this.showMasterEdit();

      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      let code = selectedRowItem.code;
      this.setEditCode(code);

      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
        code = this.getMasterRecordList.data[0].code;
      }

      // プロパティを正規化する。
      const normalizedItem = this.normalization(selectedRowItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);

      // モーダル画面表示用のシステム利用設定を設定
      this.setFacilitySysUseSetting(this.facilitySysUseSetting);
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
          //8918 初期に不正を追加します 张博 start
          d[k] = "";
          //8918 初期に不正を追加します 张博 end
        } else if (fields[k].type === "date") {
          d[k] = new Date();
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
      this.editComFormatCd();
    },
    editComFormatCd() {
      this.$nextTick(() => {
        // グリッドの要素がなかったら処理終了
        if (this.$refs.grid === undefined) {
          return;
        }

        // グリッドが表示されていなかったら処理終了
        const gridHeader = this.$refs.grid.$el.firstChild;
        if (gridHeader.textContent === " ") {
          return;
        }

        // グリッドにレコードがなければ処理終了
        if (!this.$refs.grid.$el.lastChild.lastChild.tBodies) {
          return;
        }
        const tbodyc =
          this.$refs.grid.$el.lastChild.lastChild.tBodies[0].children;
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;

          const comTypeList = this.getComTypeList;
          if (currentTrc[7] !== undefined) {
            const filteredComTypeList = comTypeList.filter(
              (type) => type.text === currentTrc[7].textContent
            );
            if (filteredComTypeList.length > 0) {
              const ComFormatCdList = filteredComTypeList[0].com_format_cd;
              const FilteredComFormatCdList = ComFormatCdList.filter(
                (format) => format.value === currentTrc[8].textContent
              );
              if (FilteredComFormatCdList.length > 0) {
                currentTrc[8].textContent = FilteredComFormatCdList[0].text;
              }
            }
          }
        }
      });
    },
    loadGridData() {
      this.findList();
    },
    showRegistModal() {
      this.findList();
      this.showMntFindMachineModal();
    },
    messageMachine() {
      // mod #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei start
      this.intervalID = setInterval(() => {
        // 他の画面に遷移したときもmessageMachine()が発生する為、自分の画面のみ処理する
        if (
          this.selfScreenName === this.$router.currentRoute.name &&
          document.getElementsByTagName("ons-alert-dialog").length === 0
        ) {
          // メッセージの確認
          if (this.getMessageList.length > 0) {
            let messages = "";
            for (const item of this.getMessageList) {
              // 型式、通信フォーマット、製造番号、通信種別、IPアドレス
              messages =
                messages +
                "・【型式】" +
                item.machineTypeName +
                " 【通信フォーマット】" +
                item.comFormatName +
                " 【製造番号】" +
                item.machineSerial +
                " 【通信種別】" +
                item.comType +
                " 【ＩＰアドレス】" +
                item.ipAddress +
                "<br>";
            }

            this.$ons.notification.alert({
              class: "machine-dialog",
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "下記は重複したので登録しない。",
              title: DIALOG_MESSAGES["00300033"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              messageHTML: messages,
            });
            clearInterval(this.intervalID);
          }
        }
        // mod #7663 C重複情報のメッセージ画面を表示する。 zhou start
      });
      // mod #7663 C重複情報のメッセージ画面を表示する。 zhou end
      // mod #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei end
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
    //#11234
    // onDataBoundKendoGrid() {
    //   const lockedContent = this.$el.querySelector('.k-grid-content-locked');
    //   const scrollableContent = this.$el.querySelector('.k-grid-content');
    //   let isSyncingScroll = false;

    //   if (lockedContent && scrollableContent) {
    //     const syncScroll = (source, target) => {
    //       if (isSyncingScroll) return;
    //       isSyncingScroll = true;
    //       target.scrollTop = source.scrollTop;
    //       isSyncingScroll = false;
    //     };

    //     scrollableContent.addEventListener('scroll', () => syncScroll(scrollableContent, lockedContent));
    //     lockedContent.addEventListener('scroll', () => syncScroll(lockedContent, scrollableContent));
    //   }
    // }
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.calculateColumnsWidth();
    // mod マスタ一覧 1･施設切替を可能とする 孔 start
    this.facilitylistValue = this.getFacilitySwitch;
    this.findList();
    // mod マスタ一覧 1･施設切替を可能とする 孔 end
    this.setCondition(this.condition);

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");

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
    EventBus.$on("messageMachine", this.messageMachine);
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
    // 通信種別に応じて通信フォーマットの値を変更
    this.editComFormatCd();
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
    EventBus.$off("messageMachine", this.messageMachine);
    // add #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei start
    clearInterval(this.intervalID);
    // add #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei end
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
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.k-grid-toolbar {
  padding: 0.1em 0.3em;
}
/* add 8130 全施設マスタでフリーズする 周安寧 start */
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

/* add #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei start*/
.machine-dialog > .alert-dialog {
  width: auto;
}
/* add #7663 C重複情報のメッセージ画面を表示する。 xiaosonglei end*/
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
</style>
