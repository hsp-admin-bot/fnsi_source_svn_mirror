<template>
  <div class="main-content-area master-maintenance-page">
    <div
      v-kendo-validator="kendoValidatorSetup"
      class="ntss-list"
      :style="ntssListStyles"
    >
      <kendo-grid-toolbar
        class="k-grid-toolbar kendo-grid-toolbar-style"
        :style="heightStyles"
      >
        <div :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button
            v-show="!isSortMode && isAllowAddRecord"
            style="float: left;"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="addRow()"
          >
            追加
          </v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" class="custom-switch" style="float: left; margin-left: 2px;" v-model="allowEdit"></v-ons-switch>
            </v-ons-col>
          </v-ons-row>
          <v-ons-button
            modifier="outline"
            class="btn3-normal toolbar-btn csv-btn"
            style="margin-right: 10px;"
            v-show="!isSortMode && isAllowAddRecord"
            @click="importCsv()"
            >CSV取込
          </v-ons-button>
          <!-- delete #6217 全施設マスタ画面が遅い guanhao start-->
          <!-- add redmine 4490 全施設マスタの並び順 鞠 start -->
          <!-- <v-ons-button
            v-show="!isSortMode && isAllowSort"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="toRankEditBtnClick()"
          >
            並び順表示
          </v-ons-button>
          <v-ons-button
            v-show="isSortMode && isAllowSort"
            modifier="outline"
            class="btn3-normal toolbar-btn"
            @click="sortBtnClick()"
          >
            反映
          </v-ons-button>-->
          <!-- add redmine 4490 全施設マスタの並び順 鞠 end -->
          <!-- delete #6217 全施設マスタ画面が遅い guanhao end-->
        </div>
        <!-- ソート後グリッド表示 -->
        <span v-show="isSortChacked">
          <kendo-grid :class="fontSizeSet"
            id="grid-font-size"
            ref="grid"
            :data-source="masterRecords"
            :editable="true"
            :selectable="true"
            :reorderable="false"
            :height="kendoGridHeight"
            :scrollable="true"
            :beforeEdit=modifyEditStart
            :cellClose=editEnd
            @save="onSave"
            @databound="onDataBoundKendoGrid">
          >
            <template v-for="(column, index) in columns">
              <!-- 施設コード列はeditorを適用 -->
              <kendo-grid-column
                v-if="column.field === 'medicalInstitutionCd'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="medicalInstitutionCdEditor"
              />
              <!-- 削除列はeditorを適用 -->
              <kendo-grid-column
                v-else-if="column.field === 'isDisp'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="isDispEditor"
              />
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
                :attributes="{ class: column.field === 'name' ? 'facility-name' : '' }"
              />
            </template>
          </kendo-grid>
        </span>
      </kendo-grid-toolbar>
      <div id="grid-footer">
        <v-ons-row v-show="!isSortMode" width="100%">
          <v-ons-col width="50%">
            <v-ons-button
              class="btn2-cancel button denial-btn"
              style="width: auto;"
              @click="cancel"
            >
              キャンセル
            </v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="btn1-execute button registration-btn"
              style="width: auto;"
              :disabled="!isChanged"
              @click="saveRecord"
            >
              保存
            </v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </div>
    <master-csv
      :popoverVisible="masterCsvVisible"
      :popoverTarget="masterCsvTarget"
      @popover-close="prehideCsvPopover"
    />
    <message-dialog
      v-if="isDialogVisible"
      :visible.sync="isDialogVisible"
      :message-cd="messageCd"
      :string-params="stringParams"
      type="1"
    />
  </div>
</template>

<script>
import $ from "jquery";
import _ from "underscore";
import moment from "moment";
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapActions, mapGetters, mapState } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";

//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  components: {
    "message-dialog": messageDialog,
    "master-csv": MasterCsvComponent
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
          values: null
        }
      ],
      updateResponse: {
        isSuccess: false,
        errorMessage: ""
      },
      isSortMode: false,
      masterCsvVisible: false,
      masterCsvTarget: null,
      isSorted: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      isDialogVisible: false,
      stringParams: null,
      messageCd: null,
      isSortChacked: false,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      // 自画面の名称
      selfScreenName: "",
      lockedColumnsWidth: 0,
      // add #6217 全施設マスタ画面が遅い guanhao start
      scrollFlag: false,
      addRowScrollFlag: false,
      dataPageScrollFlag: false,
      offset: 0,
      sysFacilityDataTotal: null,
      keywordName: null,
      loadInsertRecords: null,
      // add #6217 全施設マスタ画面が遅い guanhao end
      // add 8130 全施設マスタでフリーズする 周安寧 start
      loadingFlag : true,
      // add 8130 全施設マスタでフリーズする 周安寧 end
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
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      // add redmine 4490 全施設マスタの並び順 鞠 start
      isRecordModified: "isRecordModified",
      getFacilitySwitch: "getFacilitySwitch",
      // add redmine 4490 全施設マスタの並び順 鞠 end
    }),
    ...mapGetters("mst-facility", {
      getMasterHashRecordList: "getMasterHashRecordList",
    }),
    // add start #9590
    ...mapState("master-maintenance", ["condition"]),
    // add end 9590

    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
    masterRecords() {
      if (this.getMasterRecordList.length !== 0) {
        // delete #6217 全施設マスタ画面が遅い guanhao start
        // add redmine 4490 全施設マスタの並び順 鞠 start
        // this.sortRank();
        // add redmine 4490 全施設マスタの並び順 鞠 end
        // delete #6217 全施設マスタ画面が遅い guanhao end
        if (!this.isSortChacked) {
          // storeからデータ取得後施設コードでソート
          // mod+del redmine 4490 全施設マスタの並び順 鞠 start
          // this.sortRecords(this.getFilteredMasterRecordList.data);

          // 表示順を更新するため、storeに設定
          // this.setMasterRecordList(this.getFilteredMasterRecordList);
          this.setMasterRecordList(this.getMasterRecordList);
          // mod+del redmine 4490 全施設マスタの並び順 鞠 end
          // ソート後グリッドを表示
          this.showDisplay();
        }
      }

      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    // delete #6217 全施設マスタ画面が遅い guanhao start
    // isAllowSort() {
    //   // allowSortが定義されていない場合は並び替えボタンは使用不可
    //   return !(this.getColumnIndex("allowSort") < 0);
    // },
    // delete #6217 全施設マスタ画面が遅い guanhao end
    isChanged() {
      const data = this.getMasterRecordList.data;
      // add #6217 全施設マスタ画面が遅い guanhao start
      // return (
      //   this.getStateUserAccountInfo !== null &&
      //   data !== undefined &&
      //   (data.filter(row => row.operation > 0).length ||
      //     this.isSorted || this.isRecordModified ||
      //     !this.kendoValidator.validate())
      // );
      return (
        this.getStateUserAccountInfo !== null &&
        this.kendoValidator !== undefined &&
        data !== undefined &&
        (data.filter(row => row.operation > 0).length ||
          this.isSorted || (this.kendoValidator &&
            !this.kendoValidator.validate()))
      );
      // add #6217 全施設マスタ画面が遅い guanhao end
    },
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
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("sysFacilityDataPage", this.sysFacilityDataPage);
    EventBus.$on("loadGridData", this.loadGridData);
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    // add #6217 全施設マスタ画面が遅い guanhao start
    window.removeEventListener("scroll", this.scrollRight,true);
    EventBus.$off("sysFacilityDataPage", this.sysFacilityDataPage);
    EventBus.$off("loadGridData", this.loadGridData);
    // add #6217 全施設マスタ画面が遅い guanhao end
    this.setCondition({
      recordName: null,
      includeDeleted: false
    });
  },
  // add 性能改善メモリ不足 shan end
  mounted() {
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
    // add #6217 全施設マスタ画面が遅い guanhao start
    ApiHelper.get(`/master_maintenance/getTotal`).then((res) => {
      this.sysFacilityDataTotal = res.data
    });
    window.addEventListener("scroll", this.scrollRight,true);
    // add #6217 全施設マスタ画面が遅い guanhao end
  },

  updated() {
    // オブジェクトの描画前に実行すると発生するエラーを抑制
    if (this.$refs.grid.$el.firstChild.classList != null) {
      // Storeの更新等で画面が再描画された場合に背景色を変更
      this.editBackgroundColor();
    }

    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
  },

  methods: {
    ...mapActions("multi-modal", [
      "showMasterEdit",
    ]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "setMasterRecordList",
      "setComparisonRecordModel",
      "edit",
      "setCondition",
      "findColumnInfo",
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),

    // delete #6217 全施設マスタ画面が遅い guanhao start
    // // add 4490 全施設マスタの並び順 鞠 start
    // sortRank(){
    //   if (this.getMasterRecordList.data.length !=0 && this.getMasterRecordList.data[0].sortRank === null) {
    //     for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
    //       this.getMasterRecordList.data[i].sortRank = i+1;
    //     }
    //   }
    // // #6231:is_disp 画面からの削除でロジック削除となります。ljg start
    // // for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
    // //     this.getMasterRecordList.data[i].isDisp = '1';
    // // }
    // // #6231:is_disp 画面からの削除でロジック削除となります。ljg end
    // },
    // // add redmine 4490 全施設マスタの並び順 鞠 end
    // delete #6217 全施設マスタ画面が遅い guanhao end
    /**
     * @description 施設コード列のkendo editor
     */
    medicalInstitutionCdEditor(container, data) {
      // add 追加時に編集可能、他の状態は編集できません 宋qy start
      if (data.model.operation === 1) {
      // add 追加時に編集可能、他の状態は編集できません 宋qy end

        // 新規レコードは編集可なのでinput
        $(
          `<input type="text" name="${data.field}" maxlength="10" class="k-input k-textbox"
            required="true" validationmessage="医療機関コードは必須入力です。" />`
        ).appendTo(container);
      } else {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 既存レコードはlabelにして編集させない
        $(`<label>${data.model.medicalInstitutionCd}</label>`).appendTo(container);
      }
    },

    /**
     * @description 削除列のkendo editor
     */
    isDispEditor(container, data) {
      if (data.model.operation === 1) {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 新規レコードはlabelにして編集させない
        $(`<label></label>`).appendTo(container);
      } else {
        // 既存レコードは編集可
        $(`<input class="k-textbox" name="${data.field}" />`)
          .appendTo(container)
          .kendoDropDownList({
            dataSource: [
              { text: " ", value: "1" },
              { text: "削除", value: "0" },
            ],
            dataTextField: "text",
            dataValueField: "value"
          });
      }
    },
    // グリッドのデータ再表示
    gridDataRefresh() {
      const grid = this.$refs.grid;
      // grid.dataSource = [];
      grid.dataSource = this.masterRecords;
    },
    // マスタ一覧のデータを取得
    async findList() {
      // apiをコールして値を取得
      this.findRecordList()
        .then(response => {
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
            column.width = column.width ? column.width : "0";
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            column.width = column.field === "isDisp" ? "9em" : (this.columnWidth + "em");
            // add 削除の欄が広い 王 start
            // column.width = column.field === "isDel" ? "8em" : (this.columnWidth + "em");
            column.width = column.field === "isDel" ? "9em" : (this.columnWidth + "em");
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 end
            // add 削除の欄が広い 王 end

            if (this.androidFlg || this.iosFlg) {
              if (column.field === "medicalInstitutionCd") {
                column.width = "6em";
              }

              if (column.field === "prefecturesCd") {
                column.width = "5em"
              }

              if (column.field === "name") {
                column.width = "6em"
              }
            }

            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && column.dataType === "string" && column.field === "name") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width * 15
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
          });

          if (this.androidFlg || this.iosFlg) {
            this.lockedColumnsWidth = 17.5;
          }

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
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
          });
        })
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        .catch(error => {
        getErrorMessage('SysFacilityMainComponent.vue', 'findList', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        });
        this.findColumnInfo();
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロール位置を保存 楊 start */
      this.setLastScroll();
      /* add スクロール位置を保存 楊 end */
      // 必須チェック
      if (!this.isFilledRequired()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 施設コードチェック
      if (!this.validateMmedicalInstitutionCd()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      const keys = [
        "medicalInstitutionCd",
        "prefecturesCd",
        "facilityName",
        "facilityShortName",
        "jsdtFacilityCd",
        "facilityCd",
        "zipcd",
        "address",
        "addressKana",
        "phoneNo1",
        "phoneNo2",
        "faxNo1",
        "faxNo2"
      ];

      // 編集中のレコードを新規/更新/削除に分類
      const insertRecords = [];
      const updateRecords = [];
      const deleteCdList = [];
      for (const record of this.getUpdateRecordList) {
        if (record.operation === 1) {
          // 新規レコード
          insertRecords.push(record);
        } else if (record.operation === 2) {
          if (record.isDisp === "0") {
            // 削除レコード
            deleteCdList.push(record.medicalInstitutionCd);
          } else {
            // 更新レコード
            updateRecords.push(record);
          }
        }
      }

      // 登録日時・更新日時用の現在日時
      const now = moment().format("YYYY-MM-DDTHH:mm:ss.SSSZ");

      const serializedInsertRecords = insertRecords.map(record =>
        JSON.stringify({
          ..._.pick(record, keys),
          facilityName: record.name,
          // kendoのドロップダウンにnullが設定できないため擬似的に設定している未登録コード'00'をnullに変換
          prefecturesCd:
            record.prefecturesCd === "00" ? null : record.prefecturesCd,
          regDate: now,
          upDate: now
        })
      );

      // add #6217 全施設マスタ画面が遅い guanhao start
      this.loadInsertRecords = serializedInsertRecords;
      // add #6217 全施設マスタ画面が遅い guanhao end
      const serializedUpdateRecords = updateRecords.map(record =>
        JSON.stringify({
          ..._.pick(record, keys),
          facilityName: record.name,
          prefecturesCd:
            record.prefecturesCd === "00" ? null : record.prefecturesCd,
          upDate: now
        })
      );
      // add redmine 4490 全施設マスタの並び順 鞠 start
      const getMasterRecordList = this.getMasterRecordList.data.map(record => {
        return JSON.stringify({
          facilityCd : record.facilityCd,
          facilityName : record.name,
          medicalInstitutionCd: record.medicalInstitutionCd
        })
      });

      const getFacility = [this.getFacilitySwitch,this.masterPhysicalName];
      // add redmine 4490 全施設マスタの並び順 鞠 end
      const editRecord = {
        insertRecord: serializedInsertRecords,
        updateRecord: serializedUpdateRecords,
        deleteCdList,
        // add redmine 4490 全施設マスタの並び順 鞠 start
        getMasterRecordList:getMasterRecordList,
        getFacility : getFacility
        // add redmine 4490 全施設マスタの並び順 鞠 end
      };

      // apiをコールして値を保存
      let errFlg = false; // NOTE: 一意制約違反（409）で返却された場合、catch内でフラグをOnにし準正常として処理を終了する
      await ApiHelper.put("/mstInfo/saveSysFacility", editRecord).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('SysFacilityMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          if (error.response.status == 409) {
            errFlg = true;
            this.isDialogVisible = true;
            this.messageCd = 60000001;
            this.stringParams = ["医療機関コード"];
            return;
          } else {
            throw new Error(error);
          }
        }
      );
      if (errFlg) return; // NOTE : 重複エラーのため、後続の処理は行わせない

      this.$ons.notification.alert({
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // title: "更新完了",
        // message: "マスタ更新が完了しました。"
        title: DIALOG_MESSAGES[12000004].title,
        message: messageFormat(DIALOG_MESSAGES[12000004].message),
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      });

      this.isSorted = false;
      // modify #6217 全施設マスタ画面が遅い guanhao start
      //await this.findList();
      const params = {
        insertRecord: serializedInsertRecords,
        limit: this.getMasterRecordList.data.length,
        keywordName : this.keywordName
      };
      let sysFacilityData = await ApiHelper.post("/master_maintenance/getSysFacilityAfterSaveByLimit", params);

      this.sysFacility = sysFacilityData.data;
      this.getMasterRecordList.data = [];
      for (let i = 0; i < this.sysFacility.length; i++) {
        let d = new Object();
        const fields = this.getMasterRecordList.schema.model.fields;
        Object.keys(fields).forEach(k => {
          Object.keys(this.sysFacility[i]).forEach(sysFacilityKey => {
            if (sysFacilityKey === k) {
              d[k] = this.sysFacility[i][sysFacilityKey];
            }
          });
          if (k === "code") {
            d[k] = this.sysFacility[i].medicalInstitutionCd;
          }
          d["name"] = this.sysFacility[i].facilityName;
        });
        this.getMasterRecordList.data.push(d);
        this.edit({editRecord: d, isSortMode: true});
      }

      ApiHelper.get(`/master_maintenance/getTotal`).then((res) => {
        this.sysFacilityDataTotal = res.data
      });
      // modify #6217 全施設マスタ画面が遅い guanhao end

      // 画面表示フラグ
      this.isSortChacked = false;
      //add FNSI-8129 劉全航 start
      this.loadGridData();
      //add FNSI-8129 劉全航 end
      //共通ローダー：表示終了
      this.setLoadingScreenVisible(false);

      // グリッドのデータ再表示
      this.gridDataRefresh();
    },

    /**
     * @description 必須項目チェック
     * @summary 未入力の必須項目があったらダイアログを表示する
     * @returns {Boolean} true: 未入力なし, false: 未入力あり
     */
    isFilledRequired() {
      let message = "";
      if (this.getUpdateRecordList.some( item => item.medicalInstitutionCd === null || item.medicalInstitutionCd === "" )) {
        // #10082 全施設マスタで追加行が空行で保存を押したときエラーにならない linjunfeng start
        // message = DIALOG_MESSAGES[20010002].replace(/{\$\d*}/, "医療機関コード");
        message = DIALOG_MESSAGES[20010002].message.replace(/{\$\d*}/, "医療機関コード");
        // #10082 全施設マスタで追加行が空行で保存を押したときエラーにならない linjunfeng end
      }
      if (this.getUpdateRecordList.some(item => item.name === null || item.name === "")) {
        if(message.length > 0){
          message = message.substring(0,message.indexOf("。")+1)
        }
        // #10082 全施設マスタで追加行が空行で保存を押したときエラーにならない linjunfeng start
        // message = message + DIALOG_MESSAGES[20010002].replace(/{\$\d*}/, "\n施設名");
        message = message + DIALOG_MESSAGES[20010002].message.replace(/{\$\d*}/, "\n施設名");
        // #10082 全施設マスタで追加行が空行で保存を押したときエラーにならない linjunfeng end
      }
      if(message.length > 0){
        // 改行文字列をbrタグに置換
        message = message.replace(/\n/g, "<br>");
        this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "チェックエラー",
            title: DIALOG_MESSAGES["00300006"].title,
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
            message: message
          });
        return false;
      }
      return true;
    },

    /**
     * @description 医療機関コードチェック
     * @summary 重複または半角数字以外があったらダイアログを表示する
     * @returns {Boolean} true: 正, false: 不正
     */
    validateMmedicalInstitutionCd() {
      const facilityCdList = this.getUpdateRecordList.map(
        record => record.medicalInstitutionCd
      );
      // 医療機関コードリストをSetオブジェクトに(重複排除)
      const set = new Set(facilityCdList);
      if (facilityCdList.length !== set.size) {
        // 元のリストと重複排除リストの長さが違うなら重複あり
        this.isDialogVisible = true;
        this.messageCd = 60000001;
        this.stringParams = ["医療機関コード"];
        return false;
      }

      // 半角数字の正規表現パターン
      const regexp = /^[0-9]*$/;
      if (facilityCdList.some(cd => !regexp.test(cd))) {
        this.isDialogVisible = true;
        this.messageCd = 60000002;
        this.stringParams = ["医療機関コード"];
        return false;
      }

      return true;
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      // add #6217 全施設マスタ画面が遅い guanhao start
      this.addRowScrollFlag = true;
      // add #6217 全施設マスタ画面が遅い guanhao end
      // add 8130 全施設マスタでフリーズする 周安寧 start
      this.loadingFlag = false;
      // add 8130 全施設マスタでフリーズする 周安寧 end

      // 空レコードをストアに登録
      let newRecord = {};
      const fields = this.getMasterRecordList.schema.model.fields;

      // 初期値を設定
      Object.keys(fields).forEach(colName => {
        switch (colName) {
          case "prefecturesCd":
            newRecord[colName] = "00";
            break;

          case "name":
            newRecord[colName] = "";
            break;

          default:
            newRecord[colName] = null;
            break;
        }
        // delete #6217 全施設マスタ画面が遅い guanhao start
// add redmine 4490 全施設マスタの並び順 鞠 start
//         // 初期時、新しいレコードに全レコードの並び順の最大値をセット
//         if (colName === "sortRank") {
//           newRecord[colName] = this.getMaxSortRank() + 1;
//         }
// add redmine 4490 全施設マスタの並び順 鞠 end
        // delete #6217 全施設マスタ画面が遅い guanhao end
      });
      this.lastScrollTop = this.$refs.grid.$el.lastChild.scrollHeight;
      // 画面編集内容をstoreに反映 ※新規レコード追加
      this.edit({ editRecord: newRecord, isSortMode: this.isSortMode });
      // 色変え？
      this.editBackgroundColor();
    },
    /**
     * @description 表示順設定
     * @param {Array}
     */
    sortRecords(records) {
      records.sort((a, b) => {
        // 施設コードでソート
        return a.medicalInstitutionCd - b.medicalInstitutionCd;
      });
    },

    /**
     * @description 画面表示関数
     */
    showDisplay() {
      // 画面表示フラグ
      this.isSortChacked = true;
    },

    // add #6217 全施設マスタ画面が遅い guanhao start
    scrollRight() {
      if (this.$refs.grid !== undefined) {
        let e = this.$refs.grid.$el.lastChild;
        let scrollBottom = Math.abs(e.scrollHeight - e.scrollTop - e.clientHeight) < 4;
        if (Math.abs(e.scrollHeight - e.scrollTop - e.clientHeight) >= 4) {
          this.scrollFlag=true;
          // del 8130 全施設マスタでフリーズする 周安寧 start
          // this.addRowScrollFlag = false;
          // del 8130 全施設マスタでフリーズする 周安寧 end
        }
        // mod 8130 全施設マスタでフリーズする 周安寧 start
        //if (scrollBottom) {
          //if (this.scrollFlag) {
            //if (this.dataPageScrollFlag || this.offset === this.sysFacilityDataTotal || this.addRowScrollFlag) {
              //this.setLoadingScreenVisible(false);
              //return
            //}
            //this.setLoadingScreenVisible(true);
           // this.scrollFlag = false;
           // this.dataPageFlag = false;
           // this.sysFacilityDataPage('');
            // add 8130 全施設マスタでフリーズする 周安寧 start
          //  this.setLoadingScreenVisible(false);
            // add 8130 全施設マスタでフリーズする 周安寧 end
          //}
        //}
        if (scrollBottom) {
          if (this.scrollFlag) {
            if (this.loadingFlag) {
                if (this.addRowScrollFlag) {
              this.loadingFlag = false;
                }
             } else {
              this.loadingFlag = true;
              this.setLoadingScreenVisible(false);
              this.scrollFlag = false;
              return
            }
            if (this.dataPageScrollFlag || this.offset === this.sysFacilityDataTotal) {
              this.setLoadingScreenVisible(false);
              return
            }
            // スクロール位置を保存
            this.lastScrollTop = e.scrollTop;
            this.setLoadingScreenVisible(true);
            this.scrollFlag = false;
            this.dataPageFlag = false;
            this.sysFacilityDataPage('');
          }
          // mod 8130 全施設マスタでフリーズする 周安寧 end
        }
      }
    },
    async sysFacilityDataPage(recordName) {

      if(recordName != '') {

        this.dataPageScrollFlag = false;
        this.keywordName = recordName;
        this.getMasterRecordList.data = [];
      }
      this.offset = this.getMasterRecordList.data.length;
      const paramsLoad = {
        insertRecord: this.loadInsertRecords,
        offset: this.getMasterRecordList.data.length,
        keywordName : this.keywordName
      };
      let sysFacilityData = await ApiHelper.post("/master_maintenance/getSysFacilityByLimitAndOffset", paramsLoad);

      if (sysFacilityData.data.length < 100) {

        this.dataPageScrollFlag = true;
      }

      this.sysFacility = sysFacilityData.data;
      if (!this.kendoValidator.validate()) {
        // add 8130 全施設マスタでフリーズする 周安寧 start
        this.setLoadingScreenVisible(false);
        // add 8130 全施設マスタでフリーズする 周安寧 end
        return;
      }
      for (let i = 0; i < this.sysFacility.length; i++) {
        let d = new Object();
        const fields = this.getMasterRecordList.schema?.model.fields;
        fields && Object.keys(fields)?.forEach(k => {
          Object.keys(this.sysFacility[i]).forEach(sysFacilityKey => {
            if (sysFacilityKey === k) {
              d[k] = this.sysFacility[i][sysFacilityKey];
            }
          });
          if (k === "code") {
            d[k] = this.sysFacility[i].medicalInstitutionCd;
          }
          d["name"] = this.sysFacility[i].facilityName;
        });
        // add start #9590
        if (!this.getMasterRecordList?.data) {
          return;
        }
        // add end #9590

        this.getMasterRecordList.data = this.getMasterRecordList.data.filter(data => data.code !== this.sysFacility[i].medicalInstitutionCd);

        // mod redmine 6619 標準医薬品マスタで抽出条件に関係ないデータが表示される,6620 編集していないのに編集内容破棄メッセージが表示される 宋qy start
        this.getMasterRecordList.data.push(d);
        // mod redmine 6619 標準医薬品マスタで抽出条件に関係ないデータが表示される,6620 編集していないのに編集内容破棄メッセージが表示される 宋qy end
        this.edit({editRecord: d, isSortMode: true});
      }

      for (const record of this.getUpdateRecordList) {
        if (record.operation === 1) {
          this.getMasterRecordList.data = this.getMasterRecordList.data.filter(data => data.code !== record.code);
          // 新規レコード
          this.getMasterRecordList.data.push(record);
        }
      }
      this.lastScrollTop = this.$refs.grid.$el.lastChild.scrollHeight - this.$refs.grid.$el.lastChild.clientHeight;
      this.setLoadingScreenVisible(false);
      this.$nextTick(() => {
        const gridContent = this.$refs.grid?.$el?.lastChild;
        if (gridContent) {
          gridContent.scrollTop = this.lastScrollTop || 0;
        }
      });
    },
    generatedGridData() {
      let that = this;
      // eslint-disable-next-line no-undef
      return new kendo.data.DataSource({
        pageSize: 300000,
        transport: {
          read: function (e) {
            if(that.masterRecords.data != null)
              e.success(that.masterRecords.data)
          },
        },
        schema: that.masterRecords.schema
      })
    },
    // add #6217 全施設マスタ画面が遅い guanhao end
    loadGridData(){
      // add #6217 全施設マスタ画面が遅い guanhao start
      this.keywordName = null;
      this.dataPageScrollFlag = false;
      // add #6217 全施設マスタ画面が遅い guanhao end
      // mod #9590 start
      if (this.condition.recordName) {
        this.setCondition(this.condition);
      } else {
        this.findList();
      }
      // mod #9590 start
    },
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
      this.editStart(e);
    },
    onDataBoundKendoGrid() {
      this.$nextTick(() => {
        const lockedContent = this.$el.querySelector('.k-grid-content-locked');
        const scrollableContent = this.$el.querySelector('.k-grid-content');

        if (lockedContent && scrollableContent) {
          // イベントの重複登録を防ぐため、一度 remove してから add
          lockedContent.removeEventListener('scroll', this.syncScrollFromLocked);
          scrollableContent.removeEventListener('scroll', this.syncScrollFromScrollable);

          lockedContent.addEventListener('scroll', this.syncScrollFromLocked);
          scrollableContent.addEventListener('scroll', this.syncScrollFromScrollable);
        }
      });
    },
    syncScrollFromLocked(e) {
      const scrollableContent = this.$el.querySelector('.k-grid-content');
      if (scrollableContent && Math.abs(scrollableContent.scrollTop - e.target.scrollTop) > 1) {
        scrollableContent.scrollTop = e.target.scrollTop;
      }
      this.scrollRight();
    },
    syncScrollFromScrollable(e) {
      const lockedContent = this.$el.querySelector('.k-grid-content-locked');
      if (lockedContent && Math.abs(lockedContent.scrollTop - e.target.scrollTop) > 1) {
        lockedContent.scrollTop = e.target.scrollTop;
      }
    },
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

@media screen and (max-width: 480px) {
  .kendo-grid-toolbar-style >>> .k-grid-header-locked th,
  .kendo-grid-toolbar-style >>> .k-grid-content-locked td {
    padding: 0.25rem !important;
  }
  .kendo-grid-toolbar-style >>> .k-grid-content-locked .facility-name {
    overflow-wrap: break-word;
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
  touch-action: pan-y;
  pointer-events: auto;
  scrollbar-width: none;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked::-webkit-scrollbar {
  width: 0px;
  height: 0px;
  background: transparent;
  display: none;
}
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}
</style>
