/**
 * 治療状況ベッドレイアウトマスタメンテナンスデータページ  MainContent
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
          <v-ons-button modifier="outline" class="btn3-normal csv-btn" v-show="!isSortMode && isAllowAddRecord && !iosFlg && !androidFlg && false" @click="importCsv()">CSV取込</v-ons-button>
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
            :beforeEdit=editStart
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
                :attributes="{ class: 'btn3-kendo-normal' }"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values"
                :command="{ text: '詳細', click: showMasterEditModal }">
              </kendo-grid-column>
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
                @editor="colorEditor">
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
                :values="column.values">
              </kendo-grid-column>
            </template>
        </kendo-grid>
      </kendo-grid-toolbar>
      <div id="grid-footer">
        <v-ons-row width="100%" :style="{ visibility:this.isSortMode ?  'hidden' : 'visible' }" >
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
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import $ from "jquery";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
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
        deviceEdgeNo: -1
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
      masterCsvVisible: false,
      masterCsvTarget: null,
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
    ...mapGetters("mst-status-map-bed-layout", {
      getScrollPosition: "getScrollPosition",
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
      getLogicalMasterName: "getLogicalMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      isRecordModified: "isRecordModified",
      getFacilitySwitch: "getFacilitySwitch"
    }),
    masterRecords() {
      // storeからデータを取得
      let MasterRecordList = this.getFilteredMasterRecordList;

      if (MasterRecordList.data) {
        let RecordList = this.getFilteredMasterRecordList.data.filter(row => row.sortRank == null || row.sortRank == 999999);
        if (RecordList.length > 0) {
          MasterRecordList = this.getFilteredMasterRecordList;
          let j = 0;
          for (let i = 0; i < MasterRecordList.data.length; i++) {
            if (MasterRecordList.data[i].isDisp == '1') {
              MasterRecordList.data[i].sortRank = j + 1;
              j = j+1
            }
          }
        }
      }
      return MasterRecordList;
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
        (this.$store.getters["master-maintenance/isRecordModified"] || data.filter(row => row.operation > 0).length || !this.kendoValidator.validate())
      );
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  watch: {
    windowHeight() {
      this.calculateColumnsdWidth()
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    windowWidth() {
      this.calculateColumnsdWidth()
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    isDispMenu() {
      this.calculateColumnsdWidth()
      this.calculateGridHeight();
      this.calculateGridWidth();
    },
    getFontSize() {
      this.calculateColumnsdWidth()
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
    ...mapActions("master-maintenance", [
      "findRecordList",
      "findRecordListByFacilityCdWithSql",
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
      "mstSyncDeviceEdge"
    ]),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    ...mapActions("mst-status-map-bed-layout", {
      setScrollPositions: "setScrollPositions"
    }),
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      if (!this.editingFlg) {
        const wh = this.windowHeight;
        const hh = Array.prototype.slice
          .call(document.getElementsByClassName("header"))
          .pop().clientHeight;
        const fmh =
          (this.isDispMenu === 1
            ? document.getElementById("footer-menu").clientHeight
            : 0) + 5;
        this.kendoGridToolbarHeight = wh - hh - fmh - 10;

        const gfh = document.getElementById("grid-footer").clientHeight;
        this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + 45);
      }
    },
    calculateGridWidth() {
      // 描画後に実行
      if (document.getElementsByClassName("k-grid-content-locked").length !== 0) {
        // 固定列数のカウント
        const lockedColmuns = this.columns
          .filter(col => col.locked === true && col.hidden === false).length;

        // 固定列幅算出
        // ソートモード以外では -1 する(ダミー列)
        const sortColumn = this.isSortMode ? 0 : 1;
        const lockedColumnWidth = (lockedColmuns - sortColumn) * this.columnWidth;

        // スマートフォン以外で固定行有：空白行幅の調整値
        const targetWidth = ((this.androidFlg || this.iosFlg) || lockedColumnWidth == 0 ) ? 0 : 14;
        // kendoGridのリサイズを呼び出して自動リサイズがされないケースがある問題に対応
        if(this.$refs.grid != null){
          const setWidth = parseInt(this.$refs.grid.kendoWidget().columns[0].width);
          this.$refs.grid.kendoWidget().resizeColumn(this.$refs.grid.kendoWidget().columns[0], setWidth);
        }
        // 固定列の幅確保
        document.getElementsByClassName("k-grid-header-locked")[0].style.width = lockedColumnWidth + 'em';
        document.getElementsByClassName("k-grid-content-locked")[0].style.width = lockedColumnWidth + 'em';

        // 画面幅よりも固定列の幅が大きくなった場合、可変列のヘッダが見切れるため
        // グリッドサイズを画面幅以上に拡張する
        if (document.getElementsByClassName('k-grid')[0].clientWidth
             < document.getElementsByClassName("k-grid-header-locked")[0].clientWidth) {
           // グリッドサイズ拡張
           document.getElementsByClassName('k-grid')[0].style.width
             = (document.getElementsByClassName("k-grid-header-locked")[0].clientWidth
               + 100 + targetWidth)  + 'px';
           // 拡張分の幅で可変列のヘッダ幅定義
           document.getElementsByClassName("k-grid-header-wrap k-auto-scrollable")[0].style.width
             = (100 + targetWidth) + 'px';
        } else {
          // 固定列の幅を確保
          const headerLockWidth = ((document.getElementsByClassName('k-grid')[0].clientWidth
               - document.getElementsByClassName("k-grid-header-locked")[0].clientWidth) + targetWidth);
          const contentScrollableWidth = ((document.getElementsByClassName('k-grid')[0].clientWidth
               - document.getElementsByClassName("k-grid-content-locked")[0].clientWidth) +targetWidth);

          document.getElementsByClassName("k-grid-header-wrap k-auto-scrollable")[0].style.width = headerLockWidth +'px';
          document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].style.width = contentScrollableWidth +'px';
          // 縦スクロールの幅を確保
          if (headerLockWidth === contentScrollableWidth && lockedColumnWidth) {
            document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].style.width = (contentScrollableWidth - 17) + 'px';
          }
        }
      }
    },
    calculateColumnsdWidth() {
      this.columnWidth = parseFloat(
        window
          .getComputedStyle(document.getElementById("app"), null)
          .getPropertyValue("width")
      ) > 1000 ? 14 : 9;
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
    addInputAssist() {
      // iOS/PWA環境でスピナーをタップすると編集が終了してしまう現象の対策
      if (this.iosFlg) {
        if (document.getElementsByClassName("k-numerictextbox").length !== 0) {
          let spinnerObj = document.getElementsByClassName("k-select")[0];
          // 編集が終了するとオブジェクトが削除される為、removeEvent処理は不要
          spinnerObj.ontouchend = function (event){ event.stopPropagation(); };
        }
      }
    },
    editEnd() {
      this.editingFlg = false;
    },
    eachModelCalendar(container, data) {
      if (this.androidFlg === true) {
        // Androidの場合は、HTML5のカレンダーを表示
        $(`<input type="date" name="${data.field}" />`).appendTo(container);
      } else {
        // デスクトップ、iOSの場合は、処理で補正したHTML5のカレンダーを表示
        const nowData = new Date(data.model[data.field]);
        const nowDtatString = nowData.getFullYear() + "-" + ('0' + (nowData.getMonth()+1)).slice(-2) + "-" + ('0' + nowData.getDate()).slice(-2);
        $(
          `<input type="date" id="displayedDummyEditor" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;"/>`
        ).appendTo(container);
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
            height: 24
          },
          change: (e) => {
            // コンソールにエラーが出るためにnextTickで遅らせている
            this.$nextTick(() => {
              dummyField.val(e.value).trigger("change");
            });
          }
        });

      // パレットを開く
      colorPicker.data("kendoColorPicker").open();
    },
    // マスタ一覧のデータを取得
    findList() {
      // apiをコールして値を取得
      // add マスタ一覧 1･施設切替を可能とする 王
      // this.findRecordList()
      this.findRecordListByFacilityCdWithSql(this.getFacilitySwitch)
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
            column["width"] = column.width ? column.width : "0";
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
            // del #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue start 
            // locked: true,
            // del #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue end 
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
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstStatusMapBedLayoutMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              // message: "指定されたマスタが見つかりません。"
              title: DIALOG_MESSAGES[12000003].title,
              message: messageFormat(DIALOG_MESSAGES[12000003].message),
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
      //イベント発生前のスクロールバーの位置を保持
      const grid = $("div.k-grid-content")[0];
      this.getScrollPosition.top = grid.scrollTop;
      this.getScrollPosition.left = grid.scrollLeft;
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
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message =  messageFormat(DIALOG_MESSAGES[12000005].message) + validateMessage;
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
          title: DIALOG_MESSAGES[12000005].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
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
          getErrorMessage('MstStatusMapBedLayoutMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        })
        // 共通ローダー：表示終了
        .finally(() => this.setLoadingScreenVisible(false));
    },
    validateRequired() {
      let validateMessageArr = [];
      const gridData = this.getMasterRecordList;
      // ストアに保存されているデータについて必須項目の未入力をチェックする
      for (let idx = 0; idx < gridData.data.length; idx++) {
        // スキーマ情報の件数分をチェック
        const keys = Object.keys(gridData.schema.model.fields);
        for (let keyCount = 0; keyCount < keys.length; keyCount++) {
          // バリデーションで必須が定義されている項目を対象
          const validation =
            gridData.schema.model.fields[keys[keyCount]].validation;
          if (typeof validation !== "undefined" && validation.required) {
            if (
              gridData.data[idx][keys[keyCount]] !== null &&
              gridData.data[idx][keys[keyCount]] === ""
            ) {
              // カラム名からタイトルを取得
              const columnInfo = this.columns.find(
                e => e.field == keys[keyCount]
              );
              // 項目名が重複していなければ、メッセージに追加
              validateMessageArr.push(columnInfo.title);
            }
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    validateComboValue() {
      // コンボ項目のfieldを取り出す
      const comboFields = this.columns
        .filter(column => column.values != null)
        .map(column => ({
          field: column.field,
          title: column.title,
          values: column.values
        }));

      // 削除されていないレコード
      const gridData = this.getMasterRecordList;
      const rows = gridData.data.filter(row => row.isDisp !== "0");
      // コンボの列を対象に、ストアの値がコンボのvaluesに存在することをチェック
      let validateMessageArr = [];
      for (let rowIdx = 0; rowIdx < rows.length; rowIdx++) {
        for (let comboIdx = 0; comboIdx < comboFields.length; comboIdx++) {
          const columnValue = rows[rowIdx][comboFields[comboIdx].field];
          // valuesにデータ値が存在せず、データ値がNullか空文字でなければエラー
          const index = comboFields[comboIdx].values.findIndex(
            e => e.value == columnValue
          );
          if (index < 0 && (columnValue !== null && columnValue !== "")) {
            validateMessageArr.push(comboFields[comboIdx].title);
          }
        }
      }
      return this.convertToStr(validateMessageArr);
    },
    convertToStr(messageArr) {
      if (messageArr.length === 0) return "";

      const unique = messageArr.reduce((acc, cur) => {
        if (acc.indexOf(cur) === -1) {
          acc.push(cur);
        }
        return acc;
      }, []);

      const prefix = "</br>&nbsp&nbsp・";
      return prefix + unique.join(prefix);
    },
    onSave(ev) {
      //イベント発生前のスクロールバーの位置を保持
      const scrollTop = ev.sender.content[0].scrollTop;
      const scrollLeft = ev.sender.content[0].scrollLeft;
      this.getScrollPosition.top = scrollTop;
      this.getScrollPosition.left = scrollLeft;
      
      this.editingFlg = false;
      this.edit({ editRecord: ev.model, isSortMode: this.isSortMode });
      ev.sender.refresh();
      if (ev.model.operation === 1) {
        ev.model["edited"] = true;
      }
      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
    },
    onDataBoundKendoGrid(ev) {
      if (this.getScrollPosition.top > 0 || this.getScrollPosition.left > 0) {
        //スクロールバーの位置をイベント発生前の位置に戻す
        this.$nextTick(() => {
          ev.sender.content[0].scrollTop = this.getScrollPosition.top;
          ev.sender.content[0].scrollLeft = this.getScrollPosition.left;
        });
      }
    },
    cancel() {
      // 前画面に戻る
      // 編集破棄確認はMasterRecordView.vueで行う
      // mod #8183 2022/12/15 治療状況ベッドレイアウトマスタからマスター一覧に戻れない。 dou start
      // this.$router.go(-1);
      this.$router.push({ name: "master-maintenance" });
      // mod #8183 2022/12/15 治療状況ベッドレイアウトマスタからマスター一覧に戻れない。 dou end
    },
    showMasterEditModal(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $("div.k-grid-content")[0];
      this.getScrollPosition.top = grid.scrollTop;
      this.getScrollPosition.left = grid.scrollLeft;
      this.setScrollPositions(this.getScrollPosition);

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
      let normalizedItem = this.normalization(selectedRowItem);
      normalizedItem["scrollPosition"] = this.scrollPosition;
      // ストアに保存する。
      this.setEditRecord(normalizedItem);

      // 詳細を表示
      this.goSpecifiedView("individual-master-ex-map-bed-layout");
    },
    onCloseMasterEditModal() {
      this.$nextTick(() => {
        this.setScrollPosition(this.scrollPosition);
      });
      // Androidでスクロール位置が戻らない場合があるのでもう一度設定
      setTimeout(() => {
        this.setScrollPosition(this.scrollPosition);
      }, 1000);
    },
    setScrollPosition(position) {
      $("div.k-grid-content")
        .scrollTop(position.top)
        .scrollLeft(position.left);
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
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
      });
      // this.edit({ editRecord: d, isSortMode: this.isSortMode });
      // this.editBackgroundColor();

      // プロパティを正規化する。
      const normalizedItem = this.normalization(d);
      this.getScrollPosition.top = this.$refs.grid.$el.lastChild.scrollHeight;
      // ストアに保存する。
      this.setEditRecord(normalizedItem);

      // 詳細を表示
      this.goSpecifiedView("individual-master-ex-map-bed-layout");
    },
    importCsv() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }

      this.masterCsvTarget = event.target;
      this.masterCsvVisible = true;
    },
    prehideCsvPopover() {
      this.masterCsvVisible = false;
      this.editBackgroundColor();
    },
    showSortColumn() {
      // 編集・並び順設定モードによって並び順項目の表示・非表示を切り替える
      // （先頭ダミー要素列と並び順列を交互に表示・非表示する）
      const sortRankIndex = this.columns.findIndex(
        col => col.field === "sortRank"
      );
      if (sortRankIndex >= 0) {
        this.columns[sortRankIndex].hidden = !(
          this.isAllowSort && this.isSortMode
        );
        const dummyIndex = this.columns.findIndex(col => col.field === "dummy");
        if (dummyIndex >= 0) {
          this.columns[dummyIndex].hidden = !this.columns[sortRankIndex].hidden;
        }
      }
    },
    disableColumns() {
      this.columns.forEach(column => {
        // 並び順列を編集可、並び順列以外を編集不可に。
        column.editable =
          column.field == "sortRank"
            ? this.isAllowSort
              ? () => true
              : () => false
            : () => false;
      });
    },
    editableColumns() {
      this.columns.forEach(column => {
        // 編集可否の設定を初期表示時の状態に戻す
        column.editable =
          column.field == "sortRank"
            ? () => false
            : column.originalEditable
              ? () => true
              : () => false;
      });
    },
    getColumnIndex(fieldName) {
      // 指定された項目がない場合はマイナスが返る
      return this.columns.findIndex(e => e.field === fieldName);
    },
    editBackgroundColor() {
      this.$nextTick(() => {
        // グリッドが表示されていなかったら処理終了
        const gridHeader = this.$refs.grid.$el.firstChild;
        if (gridHeader.textContent === " ") {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");

        // グリッドにレコードがなければ処理終了
        if (!this.$refs.grid.$el.lastChild.lastChild.tBodies) {
          return;
        }
        // 固定列、可変列、データソースの取得
        const tbodyc = this.$refs.grid.$el.lastChild.lastChild
        .tBodies[0].children;
        const lockTbodyc = this.$refs.grid.$el.children[1].lastChild
        .tBodies[0].children;
        const gridData = this.$refs.grid.dataSource;

        // 列の行数は固定・可変で同一なため可変列の行数を使用
        for (let rwCount = 0; rwCount < tbodyc.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;
          const currentLockTrc = lockTbodyc[rwCount].children;

          // 並び順の色変更
          // mod #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue start 
          // this.changeSortColor(currentLockTrc);
          this.changeSortColor(currentLockTrc, currentTrc);
          // mod #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue end 
          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc,currentLockTrc);
          // 削除対象を判定
          const deleted = this.isDeleteRow(currentTrc);

          // モーダルからの編集も色を変更する
          if (
            this.isEdited(gridData.data[rwCount].code)
          ) {
            edited = true;
          }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
          // データ参照エラーコンボの背景色を変更
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // this.changeRefErrorComboColor(currentTrc, deleted);
          this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
        }
      });
    },
    // mod #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue start 
    changeSortColor(currentLockTrc, currentTrc) {
      // 並び順が変更されていれば並び順とダミー項目背景色を変更
      for (let clCount = 0; clCount < currentLockTrc.length; clCount++) {
        if (
          this.isEditRow(currentLockTrc[clCount])
          && clCount === this.getColumnIndex('sortRank') - 1
        ) {
          currentLockTrc[clCount]?.classList?.add("master-sort-edited");    
          const dummyIndex = this.getColumnIndex("dummy");
          if (dummyIndex > -1) {
            currentTrc[dummyIndex]?.classList?.add("master-sort-edited");
          }
        }
      }
    },
    // mod #11001 並び順の変更後反映を押しても並び順が切り替わらない。 zhangyue end 
    changeEditColor(currentTrc,currentLockTrc) {
      let edited = false;
      // 変更されたセルの文字色を変更(固定列と可変列の行数は一致)
      for (let lockClCount = 0; lockClCount < currentLockTrc.length; lockClCount++) {
        // 固定列セル:並び順以外の編集列
        if (
          this.isEditRow(currentLockTrc[lockClCount]) &&
          lockClCount !== this.getColumnIndex("sortRank")
        ) {
          currentLockTrc[lockClCount]?.classList?.add("master-edited-cell");
          edited = true;
        }
      }

      for(let clCount = 0; clCount < currentTrc.length; clCount++) {
        // 可変列セル
        if(
          this.isEditRow(currentTrc[clCount])
        ){
          currentTrc[clCount]?.classList?.add("master-edited-cell");
          edited = true;
        }
      }
      return edited;
    },
    isDeleteRow(currentTrc) {
      let deleted = false;
      // 削除カラムで削除が選択されている場合は削除フラグを設定
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        if (
          this.isEditRow(currentTrc[clCount])
        ) {
          if (
            currentTrc[clCount].children[0].nextSibling &&
            currentTrc[clCount].children[0].nextSibling.data === "削除" &&
            this.getColumnIndex("isDisp") === clCount
          ) {
            deleted = true;
          }
        }
      }
      return deleted;
    },
    changeRowColor(currentTrc, currentLockTrc, edited, deleted) {
      // 並び順より後の項目の背景色を変更
      if (edited || deleted) {
        const addClass = deleted ? "master-deleted-row" : "master-edited-row";

        // 固定列（ソート順付）：ソート順後のみ
        for (
          let lockClCount = this.getColumnIndex("sortRank") + 1;
          lockClCount < currentLockTrc.length;
          lockClCount++
        ) {
          currentLockTrc[lockClCount]?.classList?.add(addClass);
        }
        // 可変列：全列対象
        for (
          let clCount  = 0;
          clCount < currentTrc.length;
          clCount++
        ){
          currentTrc[clCount]?.classList?.add(addClass);
        }
      }
    },
    // mod #9863 編集時背景色表示異常の横展開 蔡 start
    // changeRefErrorComboColor(currentTrc, rowDeleted) {
    // currentLockTrc：左gridのリストを取得する
    changeRefErrorComboColor(currentUnLockTrc, rowDeleted, currentLockTrc) {
    // mod #9863 編集時背景色表示異常の横展開 蔡 end
      // 削除行は処理対象外
      if (rowDeleted) {
        return;
      }
      // add #9863 編集時背景色表示異常の横展開 蔡 start
      let currentTrc = [];
      for (let clCount = 0; clCount < currentLockTrc.length; clCount++) {
        currentTrc.push(currentLockTrc[clCount]);
      }
      for (let clCount = 0; clCount < currentUnLockTrc.length; clCount++) {
        currentTrc.push(currentUnLockTrc[clCount]);
      }
      if (currentTrc.length !== this.columns.length) {
        return;
      }
      // add #9863 編集時背景色表示異常の横展開 蔡 end
      // コンボリストが設定されていてデータが存在するが、画面表示上は空の場合は削除済みレコードを参照として背景色を変更
      for (let clCount = 0; clCount < currentTrc.length; clCount++) {
        const columnInfo = this.columns[clCount];
        const hasValueColumn = this.hasValueColumn(
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // currentTrc[this.getColumnIndex("code")].textContent,
          currentTrc[this.getColumnIndex('code')].textContent.replaceAll(",", ""),
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
          columnInfo.field
        );
        if (
          columnInfo.values !== null &&
          hasValueColumn &&
          currentTrc[clCount].textContent === ""
        ) {
          currentTrc[clCount]?.classList?.add("master-deleted-combo");
        }
      }
    },
    isEditRow(currentTd) {
      // 編集した行を判定
      return currentTd.classList.contains("k-dirty-cell");
    },
    normalization(items) {
      // columnの定義にあわせてデータを正規化する。
      const columnNames = this.columnDefinition.map(column => column.field);

      return Object.keys(items)
        .filter(key => columnNames.includes(key))
        .reduce((acc, key) => {
          acc[key] = items[key];
          return acc;
        }, {});
    },
    loadGridData(){
      // delete start #9590
        // this.setCondition(this.condition);
        // delete end #9590
      this.findList();
    },
    getIsChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (this.$store.getters["master-maintenance/isRecordModified"] || !this.kendoValidator.validate())
      );
    },
    // パンくずリストをクリックされた場合に呼び出される関数
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name
          && document.getElementsByTagName("ons-alert-dialog").length === 0) {
        if (this.getIsChanged()) {
          this.$ons.notification.confirm({
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                //スクロールバーの位置をクリアする
                this.clearScrollPosition();
                this.loadGridData();
              }
            }
          });
        } else {
          //スクロールバーの位置をクリアする
          this.clearScrollPosition();
          this.loadGridData();
        }
      }
    },
    /**
     * @description スクロールバーの位置をクリアする
    */
    clearScrollPosition() {
      this.getScrollPosition.top = 0;
      this.getScrollPosition.left = 0;
    }
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.calculateColumnsdWidth()
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
    // EventBus.$on("refresh", this.refresh);
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
    this.$nextTick(() => {
      this.calculateColumnsdWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
  },

  mounted() {
    this.$nextTick(() => {
      this.calculateColumnsdWidth();
      this.calculateGridHeight();
      this.calculateGridWidth();
    });
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
  }
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
  font-size: 1.0em;
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
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
</style>
