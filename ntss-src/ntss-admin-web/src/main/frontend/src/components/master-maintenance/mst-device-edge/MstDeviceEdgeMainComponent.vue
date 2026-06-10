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
        <div :class="['header-btn-area', 'left', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button
            v-show="!isSortMode && isAllowAddRecord"
            class="btn3-normal toolbar-btn"
            @click="addRow()"
          >
            追加
          </v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="width: 6em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" class="custom-switch" style="float: left; margin-left: 2px;" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <!-- <v-ons-button
            v-show="!isSortMode && isAllowSort"
            class="btn3-normal toolbar-btn"
            @click="toRankEditBtnClick()"
          >
            並び順表示
          </v-ons-button> -->
          <v-ons-button
            v-show="isSortMode && isAllowSort"
            class="btn3-normal toolbar-btn"
            @click="sortBtnClick()"
          >
            反映
          </v-ons-button>
        </div>

        <!-- 施設情報を表示用に変換してから画面表示 -->
        <span v-show="isSettedFacilityDataChacked">
          <kendo-grid
            id="grid-font-size"
            ref="grid"
            v-show="isSettedFacilityDataChacked"
            :class="fontSizeSet"
            :data-source="masterRecords"
            :editable="true"
            :selectable="true"
            :reorderable="false"
            :height=kendoGridHeight
            :scrollable="true"
            :beforeEdit=onBeforeEdit
            :cellClose=editEnd
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
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '詳細', click: showMasterEditModal }"
              />
              <!-- 製造番号列はeditorを適用 -->
              <kendo-grid-column
                v-else-if="column.field === 'serialNo'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="serialNoEditor"
              />
              <!-- デバイスエッジ番号列はeditorを適用 -->
              <kendo-grid-column
                v-else-if="column.field === 'deviceEdgeNo'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="deviceEdgeNoEditor"
              />
              <!-- 施設名列はeditorを適用 -->
              <kendo-grid-column
                v-else-if="column.field === 'facilityName'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="editorDropDown"
              />
              <kendo-grid-column
                v-else-if="column.dataType === 'date'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                @editor="eachModelCalendar">
              </kendo-grid-column>
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
              />
            </template>
          </kendo-grid>
        </span>
      </kendo-grid-toolbar>
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
    </div>

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
//#10715：日付IF修正20240910検証NG対応：村上Start
import Vue from "vue";
//#10715：日付IF修正20240910検証NG対応：村上End
import $ from "jquery";
import _ from "underscore";
import moment from "moment";
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import { prefectures } from "@/components/master-maintenance/mst-device-edge/Prefectures.js";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuimx add end
// add #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou start
import { ERROR_DEVICE_EDGE_SAVE } from "@/constants/deviceEdgeManageDefine";
// add #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
//#10715：日付IF修正20240910検証NG対応：村上Start
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
//#10715：日付IF修正20240910検証NG対応：村上End
export default {

  // 共通タグコンポーネント読み込み
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
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      // 編集失敗時のマスタ/列/スキーマ情報のバックアップ
      backupMasterRecordList: [],
      // 施設マスタ
      mstFacility: null,
      // 表示データ変換フラグ
      isSettedFacilityDataChacked: false,
      // 施設マスタ取得フラグ
      isGetMstFacility: false,
      // エラーメッセージ内容
      stringParams: null,
      messageCd: null,
      isDialogVisible: false,
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      // 自画面の名称
      selfScreenName: "",
      mntFacilityCancelManageList: "",
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
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length === 1 ? "none" : "inherit" };
    },
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn"
    }),
    masterRecords() {
      // storeからデータを取得

      // del デバイスエッジマスタ 更新後の画面表示異常 孔 start
      // 表示内容切替「施設名・都道府県・部署符号」※DBデバイスエッジマスタに無いカラムの初期表示は施設コードで表示される
      // if (this.getMasterRecordList.length !== 0) {
      //   if (this.isGetMstFacility) {
      //     // 施設マスタが空の状態ではエラーになる
      //
      //     // ディープコピー
      //     const editMasterRecordData = this.getMasterRecordList.data.map(
      //       record => ({ ...record })
      //     );
      //     // 施設データ設定
      //     const data = editMasterRecordData.map(record =>
      //       this.setFacilityData(record)
      //     );
      //
      //     // ディープコピー
      //     const schema = JSON.parse(
      //       JSON.stringify(this.getMasterRecordList.schema)
      //     );
      //
      //     // 施設名と各施設情報を紐づけるため、id設定
      //     schema.model.id = "code";
      //
      //     const editedMasterRecordList = {
      //       ...this.getMasterRecordList,
      //       data,
      //       schema
      //     };
      //
      //     this.sortRecords(editedMasterRecordList.data);
      //
      //     // 表示内容を更新するため、storeに設定
      //     this.setMasterRecordList(editedMasterRecordList);
      //     this.showDisplay();
      //   }
      // }
      // del デバイスエッジマスタ 更新後の画面表示異常 孔 end

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
        (data.filter(row => row.operation > 0).length ||
          this.isSorted ||
          !this.kendoValidator?.validate())
      );
    },

    ...mapGetters("mst-machine", {
      getMachineTypeList: "getMachineTypeList",
      getDeviceEdgeList: "getDeviceEdgeList"
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

  async created() {
    this.setLoadingScreenVisible(true);

    const response = await ApiHelper.get("/mstInfo/mstFacility").catch(
      error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
        getErrorMessage('MstDeviceEdgeMainComponent.vue', 'created', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        throw error;
      }
    );
    this.mstFacility = response.data;

    this.setCondition(this.condition);
    this.findList();
    this.calculateColumnsWidth();
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 施設マスタ取得フラグ
    this.isGetMstFacility = true;
    const mntFacilityCancelManage = await ApiHelper.get("/facilities/MntFacilityCancelManage/SelectAll").catch(error => {
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      getErrorMessage('MstDeviceEdgeMainComponent.vue', 'created', error);
      //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      throw error;
    });
    this.mntFacilityCancelManageList =  mntFacilityCancelManage.data.map(e => e.facilityCd)
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("refresh", this.refresh);
  },

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
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
  },

  beforeDestroy() {
    EventBus.$off("refresh", this.refresh);
  },

  methods: {
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "setEditRecord",
      "editRecordBeEmpty"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-machine", [
      "getComboRecordList",
      "deleteMstMachineList",
      "synchroMstMachine"
    ]),
    // add デバイスエッジマスタ 更新後の画面表示異常 孔 start
    changeMasterRecordsData(){
      // 表示内容切替「施設名・都道府県・部署符号」※DBデバイスエッジマスタに無いカラムの初期表示は施設コードで表示される
      if (this.getMasterRecordList.length !== 0) {
        // if (this.isGetMstFacility) {
        // 施設マスタが空の状態ではエラーになる

        // ディープコピー
        const editMasterRecordData = this.getMasterRecordList.data.map(
          record => ({ ...record })
        );
        // 施設データ設定
        const data = editMasterRecordData.map(record =>
          this.setFacilityData(record)
        );

        // ディープコピー
        const schema = JSON.parse(
          JSON.stringify(this.getMasterRecordList.schema)
        );

        // 施設名と各施設情報を紐づけるため、id設定
        schema.model.id = "code";

        const editedMasterRecordList = {
          ...this.getMasterRecordList,
          data,
          schema
        };

        this.sortRecords(editedMasterRecordList.data);

        // 表示内容を更新するため、storeに設定
        this.setMasterRecordList(editedMasterRecordList);
        this.showDisplay();
        // }
      }
    },
    // add デバイスエッジマスタ 更新後の画面表示異常 孔 end
    eachModelCalendar(container, data) {
      if (this.androidFlg === true) {
        // Androidの場合は、HTML5のカレンダーを表示
        $(`<input type="date" name="${data.field}" />`).appendTo(container);
      } else {
        // デスクトップ、iOSの場合は、処理で補正したHTML5のカレンダーを表示
        const nowData = new Date(data.model[data.field]);
        const nowDtatString = nowData.getFullYear() + "-" + ('0' + (nowData.getMonth()+1)).slice(-2) + "-" + ('0' + nowData.getDate()).slice(-2);
       //#10715：日付IF修正20240910検証NG対応：村上Start
       // $(
       //   `<input type="date" id="displayedDummyEditor" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;"/>`
       // ).appendTo(container);
       //#10715：日付IF修正20240910検証NG対応：村上Start
        $(
        `<span style="position:relative"><input type="date" style="width:8em" id="displayedDummyEditor" class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;" /><span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:absolute;left:75%;top:1px;color: #212529;z-index:9999999" ></span></span>`
        ).appendTo(container);
        //#10715：日付IF修正20240910検証NG対応：村上End
        // フォーカスアウトで編集データを反映するイベントを発火
        document.getElementById("displayedDummyEditor").addEventListener("blur", function(ev) {
          const dayData = new Date(ev.target.value);
          const resultData = dayData.getFullYear() + "-" + ('0' + (dayData.getMonth()+1)).slice(-2) + "-" + ('0' + dayData.getDate()).slice(-2);
          // 変更前の値と比較し、同じ値の場合は処理しない
          if (nowDtatString != resultData) {
            document.getElementById("hiddenDateInputEditor").value = resultData;
            // name="${data.field}" で割り当てた箇所に付与されているchangeメソッドを発火します。次いで@saveの処理が発生します。
            $(document.getElementById("hiddenDateInputEditor")).trigger('change');
          }
        });
        //#10715：日付IF修正20240910検証NG対応：村上Start
        let commonCalenderPicker = new (Vue.extend(commonCalender))();
        commonCalenderPicker.$on("input", (value) => {
          document.getElementById("hiddenDateInputEditor").value = value;
          $(document.getElementById("hiddenDateInputEditor")).trigger("change");
        });
        commonCalenderPicker.$mount();
        commonCalenderPicker.setSilently(nowDtatString);
        container.append(commonCalenderPicker.$el);
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
        document.getElementById("clear").addEventListener("mousedown", function(ev) {
          document.getElementById("hiddenDateInputEditor").value = null;
          $(document.getElementById("hiddenDateInputEditor")).trigger('change');
        });
        document.getElementById("clear").addEventListener("touchstart", function(ev) {
          document.getElementById("hiddenDateInputEditor").value = null;
          $(document.getElementById("hiddenDateInputEditor")).trigger('change');
        });
        //#10715：日付IF修正20240910検証NG対応：村上End
      }
    },
    // グリッドのデータ再表示
    gridDataRefresh() {
      const grid = this.$refs.grid;
      // grid.dataSource = [];
      grid.dataSeource = this.masterRecords;
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして値を取得
      this.findRecordList()
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
          // add デバイスエッジマスタ 更新後の画面表示異常 孔 start
          this.changeMasterRecordsData()
          // add デバイスエッジマスタ 更新後の画面表示異常 孔 end
          // カラム幅等初期調整
          this.showSortColumn();
          this.$nextTick(() => {
            this.calculateGridHeight();
            this.calculateGridWidth();
          });
        })
        .catch(error => {
          if (error.response.status === 400) {
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
            getErrorMessage('MstDeviceEdgeMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
            //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
            });
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
          else{
            getErrorMessage('MstDeviceEdgeMainComponent.vue', 'findList', error);
          }
          //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
        });
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      /* add スクロール位置を保存 楊  start */
      this.setLastScroll();
      /* add スクロール位置を保存 楊 end */
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 必須チェック
      if (!this.isFilledRequired()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 半角英数字チェック
      if (!this.validateSerialNo()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 重複チェック
      if (this.hasSameRecord()) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      const keys = [
        "deleteDate",
        "deviceEdgeNo",
        "deviceName",
        "facilityCd",
        "isDel",
        "isDisp",
        "memo",
        "serialNo",
        "settingDate"
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
            deleteCdList.push(record.serialNo);
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
          regDate: now,
          upDate: now
        })
      );

      const serializedUpdateRecords = updateRecords.map(record =>
        JSON.stringify({
          ..._.pick(record, keys),
          upDate: now
        })
      );

      const editRecord = {
        insertRecord: serializedInsertRecords,
        updateRecord: serializedUpdateRecords,
        deleteCdList
      };

      // // 登録日時・更新日時用の現在日時
      // const now = moment().format("YYYY-MM-DDTHH:mm:ss.SSSZ");

      // // ※編集レコード
      // const editedRecords = this.getUpdateRecordList.filter(record => {
      //   if (_.has(record, "operation")) {
      //     return record;
      //   }
      // });

      // // ※新規レコードは空配列で判定
      // const saveRecords = editedRecords.map(record => {
      //   // 更新レコード
      //   const saveRecord = {
      //     record: { ..._.pick(record, keys), upDate: now },
      //     orgSerialNo: record.orgSerialNo,
      //     deleteSerialNo: null
      //   };
      //   if (record.operation === 1) {
      //     // 新規レコード
      //     saveRecord.record = { ...saveRecord.record, regDate: now };
      //   } else if (record.operation === 2) {
      //     if (record.isDisp === "0") {
      //       // 削除レコード
      //       saveRecord.deleteSerialNo = record.orgSerialNo;
      //     }
      //   }
      //   saveRecord.record = JSON.stringify(saveRecord.record);
      //   return saveRecord;
      // });

      // mod #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou start
      // await ApiHelper.put("/mstInfo/saveMstDeviceEdge/", editRecord).catch(
      //   error => {
      //     //FNSI-修正 VUEのエラー場合のログ対応 liumx add start
      //     getErrorMessage('MstDeviceEdgeMainComponent.vue', 'saveRecord', error);
      //     //FNSI-修正 VUEのエラー場合のログ対応 liumx add end
      //     //共通ローダー：表示終了
      //     this.setLoadingScreenVisible(false);
      //     throw error;
      //     // console.log(`API:"${uri}"の実行に失敗しました。`);
      //     // console.log(error);
      //   }
      // );
      //
      // this.$ons.notification.alert({
      //   title: "更新完了",
      //   message: "マスタ更新が完了しました。"
      // });
      //
      // this.isSorted = false;
      // this.findList();
      //
      // // 画面表示フラグ
      // this.isSettedFacilityDataChacked = false;
      // // 施設マスタ取得フラグ
      // this.isGetMstFacility = true;
      //
      // //共通ローダー：表示終了
      // this.setLoadingScreenVisible(false);
      //
      // // グリッドのデータ再表示
      // this.gridDataRefresh();
      // apiをコールして値を登録
      await ApiHelper.put("/mstInfo/saveMstDeviceEdge/", editRecord).then(() => {
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
        // 施設マスタ取得フラグ
        this.isGetMstFacility = true;
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        // グリッドのデータ再表示
        this.gridDataRefresh();
      }).catch(
        error => {
          getErrorMessage('MstDeviceEdgeMainComponent.vue', 'saveRecord', error);
          //共通ローダー：表示終了
          this.setLoadingScreenVisible(false);
          this.$ons.notification.alert(ERROR_DEVICE_EDGE_SAVE,{title: ""});
        }
      );
      // 画面表示フラグ
      this.setLoadingScreenVisible(false);
      // mod #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou end
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      // 空レコードをストアに登録
      const d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;

      // 追加レコードに対応した初期値を設定
      Object.keys(fields).forEach(k => {
        if (fields[k].defaultValue) {
          d[k] = fields[k].defaultValue;
        } else if (k === "isDisp") {
          d[k] = "1";
        } else if (k === "isDel") {
          d[k] = "0";
        } else if (fields[k].type === "string") {
          d[k] = "";
        // add #9502 デバイスエッジ番号の範囲とデフォルト 宮崎 start
        } else if (k === "deviceEdgeNo") {
          d[k] = 1;
        // add #9502 デバイスエッジ番号の範囲とデフォルト 宮崎 end
        } else if (fields[k].type === "number") {
          d[k] = 0;
        } else if (k === "deleteDate") {
          d[k] = null;
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
      // 画面編集内容をstoreに反映※レコード（d）追加
      this.edit({ editRecord: d, isSortMode: this.isSortMode });

      // 色変え？
      this.editBackgroundColor();
    },
    /**
     * @description 編集時、テキストエリアをプルダウンメニューに変換
     * @summary コンボ代用: ReferenceCombo.java: identifierValue(Long型)でfacility_cd(character varying型)エラー発生するため
     * @param {}
     * @param {}
     */
    editorDropDown(container, data) {
      // add 追加時に編集可能、他の状態は編集できません 宋qy start
      if (data.model.operation === 1) {
      // add 追加時に編集可能、他の状態は編集できません 宋qy end

        // 新規レコードは編集可なのでinput
        $(`<input class="k-textbox" name="${data.field}"/>`)
          .appendTo(container)
          .kendoDropDownList({
            dataSource: this.mstFacility.filter(e=> !this.mntFacilityCancelManageList.includes(e.facilityCd)),
            dataTextField: "facilityName",
            dataValueField: "facilityName",
            filter: "contains",
            change: () => {
              const editRecord = this.setFacilityInfo(data.model);

              // 強制的に表示内容を変更
              this.setDisplayFacilityData(editRecord);

              // ストアへ値を登録
              this.edit({
                editRecord,
                isSortMode: this.isSortMode
              });
            }
          });
      } else {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 既存レコードはlabelにして編集させない
        $(`<label>${data.model.facilityName}</label>`).appendTo(container);
      }
    },

    /**
     * @description 製造番号列のkendo editor
     */
    serialNoEditor(container, data) {
      /* mod 制御条件の変更 楊 start */
      // if (data.model.operation) {
      if (data.model.operation === 1) {
      /* mod 制御条件の変更 楊 end */
        // 新規レコードは編集可なのでinput
        $(
          `<input class="k-textbox" name="${data.field}" maxlength="20" />`
        ).appendTo(container);
      } else {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 既存レコードはlabelにして編集させない
        $(`<label>${data.model.serialNo}</label>`).appendTo(container);
      }
    },

    /**
     * @description デバイスエッジ番号列のkendo editor
     */
    deviceEdgeNoEditor(container, data) {
      /* mod 制御条件の変更 楊 start */
      // if (data.model.operation) {
      if (data.model.operation === 1) {
      /* mod 制御条件の変更 楊 end */
        // 新規レコードは編集可なのでinput
        $(`<input class="deviceSetInfo-numbersTextbox" name="${data.field}"/>`)
          .appendTo(container)
          .kendoNumericTextBox({
            min: 1,
            max: 99
            // step: this.numericStepValue,
            // decimals: this.numericDecimalsValue
          });
      } else {
        // 編集不可時でもeditStart()が発火するため、ここでフラグをoffにする
        this.editingFlg = false;
        // 既存レコードはlabelにして編集させない
        $(`<label>${data.model.deviceEdgeNo}</label>`).appendTo(container);
      }
    },

    /**
     * @description 施設名に一致したレコードに各施設情報を設定
     * @param {Object} record
     */
    setFacilityInfo(record) {
      for (const facilityRecord of this.mstFacility) {
        if (facilityRecord.facilityName === record.facilityName) {
          const prefecture = prefectures.find(
            prefecture => prefecture.prefCd === facilityRecord.prefecturesCd
          );

          record.facilityCd = facilityRecord.facilityCd;
          record.departmentCd = facilityRecord.departmentCd;

          if (prefecture === undefined) {
            record.prefecturesCd = null;
          } else {
            record.prefecturesCd = prefecture.prefName;
          }
        }
      }
      return record;
    },

    /**
     * @description kendo画面表示内容を強制的に変更
     * @param {Object} editRecord:レコード
     */
    setDisplayFacilityData(editRecord) {
      // DB登録値を保持
      const saveFacilityCd = editRecord.facilityCd;
      const savePrefecturesCd = editRecord.prefecturesCd;
      const saveDepartmentCd = editRecord.departmentCd;

      // 表示内容を強制的に変更するためにDB登録値を表示させたい内容とは別の値を設定させる
      editRecord.facilityCd = null;
      editRecord.prefecturesCd = null;
      editRecord.departmentCd = null;

      //強制的に表示内容を変更
      const grid = $("#grid-font-size").data("kendoGrid");
      const dataItem = grid.dataSource.get(editRecord.code);
      dataItem.set("facilityCd", saveFacilityCd);
      dataItem.set("prefecturesCd", savePrefecturesCd);
      dataItem.set("departmentCd", saveDepartmentCd);

      // DB登録値に元の値を設定
      editRecord.facilityCd = saveFacilityCd;
      editRecord.prefecturesCd = savePrefecturesCd;
      editRecord.departmentCd = saveDepartmentCd;
    },

    /**
     * @description 施設コードに一致したレコードに各施設情報を設定
     * @param {Object}
     * @returns {Object}
     */
    setFacilityData(record) {
      for (const facilityRecord of this.mstFacility) {
        if (facilityRecord.facilityCd === record.facilityCd) {
          const prefecture = prefectures.find(
            prefecture => prefecture.prefCd === facilityRecord.prefecturesCd
          );

          // 表示内容を適当な値に修正
          record.facilityName = facilityRecord.facilityName;
          record.departmentCd = facilityRecord.departmentCd;
          if (prefecture === undefined) {
            record.prefecturesCd = null;
          } else {
            record.prefecturesCd = prefecture.prefName;
          }
        }
      }
      // 各レコードを識別させるためcodeを設定
      record.code = `record_${record.serialNo}`;
      return record;
    },

    /**
     * @description 表示順設定
     * @summary 施設コードでソート、同じなら製造番号
     * @param {Array}
     */
    sortRecords(records) {
      records.sort((a, b) => {
        if (a.facilityCd === b.facilityCd) {
          // 施設コードが同じなら製造番号でソート

          const serialNoA = a.serialNo.toLowerCase(); // 大文字と小文字を無視する
          const serialNoB = b.serialNo.toLowerCase(); // 大文字と小文字を無視する
          if (serialNoA < serialNoB) {
            return -1;
          }
          if (serialNoA > serialNoB) {
            return 1;
          }
          return 0;
        } else {
          return a.facilityCd - b.facilityCd;
        }
      });
    },

    /**
     * @description 画面表示関数
     */
    showDisplay() {
      // 画面表示フラグ
      this.isSettedFacilityDataChacked = true;
      // 施設情報更新フラグ
      this.isGetMstFacility = false;
    },

    /**
     * @description 必須項目チェック
     * @summary 未入力の必須項目があったらダイアログを表示する
     * @returns {Boolean} true: 未入力なし, false: 未入力あり
     */
    isFilledRequired() {
      if (
        this.getUpdateRecordList.some(
          item => item.serialNo === null || item.serialNo === ""
        )
      ) {
        this.isDialogVisible = true;
        this.messageCd = 20010002;
        this.stringParams = ["製造番号"];
        return false;
      }
      return true;
    },

    /**
     * @description 重複レコードチェック
     * @summary 施設コードが重複する項目があったらダイアログを表示する
     * @returns {Boolean} true: 重複あり, false: 重複なし
     */
    hasSameRecord() {
      const serialNoList = this.getUpdateRecordList.map(
        record => record.serialNo
      );
      // 施設コードリストをSetオブジェクトに(重複排除)
      const set = new Set(serialNoList);

      if (serialNoList.length !== set.size) {
        // 元のリストと重複排除リストの長さが違うなら重複あり
        this.isDialogVisible = true;
        this.messageCd = 60000001;
        this.stringParams = ["製造番号"];
        return true;
      }

      const deviceEdgeNoList = this.getUpdateRecordList.map(item => {
        return {
          // mod #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou start
          // deviceEdgeNo: +item.deviceEdgeNo,
          // facilityCd: +item.facilityCd
          deviceEdgeNo: item.deviceEdgeNo,
          facilityCd: item.facilityCd
          // mod #8403 【デグレ】デバイスエッジマスタで新規レコードが保存できない dou end
        }
      });
      const uniqueDeviceEdgeNoList =  deviceEdgeNoList.reduce((unique, current) => {
        if(!unique.some(item => item.deviceEdgeNo === current.deviceEdgeNo && item.facilityCd === current.facilityCd)) {
          unique.push(current);
        }
        return unique;
      },[])

      if (deviceEdgeNoList.length !== uniqueDeviceEdgeNoList.length) {
        // 元のリストと重複排除リストの長さが違うなら重複あり
        this.isDialogVisible = true;
        this.messageCd = 60000001;
        this.stringParams = ["デバイスエッジ番号"];
        return true;
      }

      return false;
    },

    /**
     * @description 製造番号チェック
     * @summary 半角英数字でない部署符号があったらダイアログを表示する
     * @returns {Boolean} true: 部署符号が全て正しい, false: 半角英数字でない部署符号あり
     */
    validateSerialNo() {
      // 部署符号リスト
      const serialNoList = this.getUpdateRecordList.map(
        record => record.serialNo
      );
      // 半角英数字の正規表現パターン
      const regexp = /^[0-9a-zA-Z]*$/;
      if (serialNoList.some(cd => !regexp.test(cd))) {
        this.isDialogVisible = true;
        this.messageCd = 60000002;
        this.stringParams = ["製造番号"];
        return false;
      }
      return true;
    },

    // /**
    //  * 画面再描画処理
    //  */
    async refresh() {
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
                this.isSorted = false;
                this.findList();
                // 画面表示フラグ
                this.isSettedFacilityDataChacked = false;
                // 施設マスタ取得フラグ
                this.isGetMstFacility = true;
              }
            }
          });
        } else {
          this.isSorted = false;
          this.findList();
          // 画面表示フラグ
          this.isSettedFacilityDataChacked = false;
          // 施設マスタ取得フラグ
          this.isGetMstFacility = true;
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
<style scoped>
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
  display: flex;
  gap: 10px;
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
.k-grid-toolbar>span{
  margin-left: 0rem;
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
</style>
