/**
* マスタメンテナンスデータページ  MainContent
*/
<template>
  <div class='main-content-area master-maintenance-page'>
    <div class='ntss-list' :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <div :class="['header-btn-area', 'right', isMobileDevice ? 'mobile-header' : '']">
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" style="float: left;"
                        v-show="!isSortMode && isAllowSort" @click="addRow()">追加
          </v-ons-button>
          <v-ons-row v-show="isMobileDevice" style="float: left; width: 6em; height: 1em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" class="custom-switch" style="float: left; margin-left: 2px;" v-model="allowEdit"></v-ons-switch>
            </v-ons-col>
          </v-ons-row>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn csv-btn" style="margin-right: 10px;" v-show="!isSortMode && isAllowAddRecord" @click="importCsv()">CSV取込</v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="!isSortMode && isAllowSort"
                        @click="toRankEditBtnClick()">並び順表示
          </v-ons-button>
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show="isSortMode && isAllowSort"
                        @click="sortBtnClick()">反映
          </v-ons-button>
        </div>
        <kendo-grid ref="grid" :class="fontSizeSet"
                    :data-source="dataSourceItems"
                    :editable="true"
                    :selectable="true"
                    :reorderable="false"
                    :height=kendoGridHeight
                    :scrollable="true"
                    :beforeEdit=modifyEditStart
                    :edit=addInputAssist
                    :cellClose=editEnd
                    @save="onSave"
                    @databound="onDataBoundKendoGridVirtual">
          <template v-for="(column, index) in columns">
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
                               @editor="numericEditor">
            </kendo-grid-column>
            <!-- add 鞠 start カレンダーの追加-->
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
            <!-- add 鞠 end カレンダーの追加-->
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
        <v-ons-row width="100%" v-show="!isSortMode">
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged"
                          @click="saveRecord">保存
            </v-ons-button>
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
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import {Validator} from "@progress/kendo-validator-vue-wrapper";
import {mapActions, mapGetters, mapState } from "vuex";
import {EventBus} from "@/eventBus";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import $ from "jquery";
import {deepCopy} from "@/functions/common/CommonFunctions";
import {ApiHelper} from "@/apis/AxiosHelper";
// add 鞠 start
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import Vue from "vue";
// add 鞠 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end

export default {
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
  components: {
    "master-csv": MasterCsvComponent
  },
  data() {
    return {
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
      masterCsvVisible: false,
      masterCsvTarget: null,
      lastScrollTop: 0,
      lastInputScrollLeft: 0,
      facilitylistValue: "",

      dataSourceItems: {},
      scrollFlag: false,
      offset: 0,
      // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 start
      sysMedicineDataTotal: null,
      // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
    }
  },
  async created() {
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
    this.setLoadingScreenVisible(true);
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.setCondition(this.condition);
    this.loadGridData();
    this.selfScreenName = this.$router.currentRoute.name;
    this.facilitylistValue = this.getFacilitySwitch;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("onSearchForMstVirtualScrollable", this.onSearch);
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
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
    // 关闭loading
    columns:function(val){
      this.$nextTick(function(){
        if (val.length > 1)
          this.setLoadingScreenVisible(false);
      });
    },
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
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
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
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
      getFacilitySwitch: "getFacilitySwitch",
    }),
    // add #9590 start
    ...mapState("master-maintenance", {
      conditions: "condition"
    }),
    // add #9590 end
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return {"--height": `${this.kendoGridToolbarHeight}px`};
    },
    ntssListStyles() {
      return {display: this.columns.length == 1 ? "none" : "inherit"};
    },
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    isAddButton() {
      let addMasterName = ["sys_medicine","mst_take_medicine","mst_vital_graph"]
      return addMasterName.indexOf(this.masterPhysicalName) < 0 ;
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return "font-size-set-" + names[this.getFontSize];
    },
    masterRecords() {
      // storeからデータを取得
      return this.getFilteredMasterRecordList;
    },
    isChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        this.kendoValidator !== undefined &&
        data !== undefined &&
        (data.filter(row => row.operation > 0).length ||
          this.isSorted || (this.kendoValidator &&
            !this.kendoValidator.validate()))
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
      "findRecordListByFacilityCd",
      "updateIndCondInfo",
      "setColumns"
    ]),
    ...mapActions("master-maintenance", {
      facilityList: "facilityList"
    }),
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible"
    }),
    // add 鞠 start カレンダー機能の追加
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
        $(
          `<input type="date" id="displayedDummyEditor" class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;"/>`
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

        document.getElementById("displayedDummyEditor").addEventListener("change", (ev) => {
          commonCalenderPicker.setSilently(ev.target.value);
        });
      }
    },
    // add 鞠 end カレンダーの追加
    setScrollPosition(position) {
      const grid = $("div.k-grid-content")[0]
      $(grid.lastChild).scrollTop(position.top)
      $(grid.firstChild).scrollLeft(position.left);
      this.editBackgroundColor();
    },
    showMasterEditModal(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $("div.k-grid-content")[0];
      this.scrollPosition.top = grid.lastChild.scrollTop;
      this.scrollPosition.left = grid.firstChild.scrollLeft;

      // モーダルを表示
      this.showMasterEdit();

      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      const row = this.$refs.grid.kendoWidget();
      let selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
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
    onDataBoundKendoGridVirtual() {
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
    onSearch(){
      this.dataSourceItems = this.generatedGridData();
    },
    _calculateGridWidth() {
      // 描画後に実行
      if (document.getElementsByClassName("k-grid-content-locked").length !== 0) {
        // 固定列数のカウント
        const lockedColumns = this.columns
          .filter(col => col.locked === true && col.hidden === false).length;

        // 固定列幅算出
        // ソートモード以外では -1 する(ダミー列)
        const sortColumn = this.isSortMode ? 0 : 1;
        let lockedColumnWidth = (lockedColumns - sortColumn) * this.columnWidth;
        if (this.lockedColumnsWidth) {
          lockedColumnWidth = this.lockedColumnsWidth;
        }
        // リサイズする前のscroll値を取得する
        let tmpScrollLeft = 0;
        let tmpScrollTop = 0;
        if (this.editFlg) {
          tmpScrollLeft = this.lastInputScrollLeft;
          tmpScrollTop = this.lastScrollTop -40;
          this.editFlg = false;
        } else {
          tmpScrollLeft = document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].firstChild.scrollLeft;
          tmpScrollTop = document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].lastChild.scrollTop;
        }

        // スマートフォン以外で固定行有：空白行幅の調整値
        const targetWidth = ((this.androidFlg || this.iosFlg) || lockedColumnWidth == 0) ? 0 : 14;
        // kendoGridのリサイズを呼び出して自動リサイズがされないケースがある問題に対応
        if (this.$refs.grid != null) {
          const setWidth = parseInt(this.$refs.grid.kendoWidget().columns[0].width);
          this.$refs.grid.kendoWidget().resizeColumn(this.$refs.grid.kendoWidget().columns[0], setWidth);
        }
        // 固定列の幅確保
        document.getElementsByClassName("k-grid-header-locked")[0].style.width = `calc(${lockedColumnWidth}em + 10px)`;
        document.getElementsByClassName("k-grid-content-locked")[0].style.width = `calc(${lockedColumnWidth}em + 10px)`;

        // 画面幅よりも固定列の幅が大きくなった場合、可変列のヘッダが見切れるため
        // グリッドサイズを画面幅以上に拡張する
        if (document.getElementsByClassName('k-grid')[0].clientWidth
          < document.getElementsByClassName("k-grid-header-locked")[0].clientWidth
        ) {
          // グリッドサイズ拡張
          document.getElementsByClassName('k-grid')[0].style.width
            = (document.getElementsByClassName("k-grid-header-locked")[0].clientWidth
            + 100 + targetWidth) + 'px';
          // 拡張分の幅で可変列のヘッダ幅定義
          document.getElementsByClassName("k-grid-header-wrap k-auto-scrollable")[0].style.width
            = (100 + targetWidth) + 'px';
        } else {
          document.getElementsByClassName('k-grid')[0].style.width = 'auto';
          const headerLockWidth = (document.getElementsByClassName('k-grid')[0].clientWidth
            - document.getElementsByClassName("k-grid-header-locked")[0].clientWidth) - 10;
          const contentScrollableWidth = (document.getElementsByClassName('k-grid')[0].clientWidth
            - document.getElementsByClassName("k-grid-content-locked")[0].clientWidth) - 10;
          // 固定列の幅を確保
          document.getElementsByClassName("k-grid-header-wrap k-auto-scrollable")[0].style.width = headerLockWidth + 'px';
          document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].style.width = contentScrollableWidth  + 'px';

          // 縦スクロールの幅を確保
          if (headerLockWidth === contentScrollableWidth && lockedColumnWidth) {
            document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].style.width = (contentScrollableWidth - 18) + 'px';
          }
        }

        if (document.getElementsByClassName("k-grid-content").length !== 0
          && document.getElementsByClassName('k-grid-content-locked')[0].clientHeight
          !== document.getElementsByClassName('k-grid-content')[0].clientHeight
          && !this.androidFlg && !this.iosFlg
        ) {
          document.getElementsByClassName('k-grid-content-locked')[0].style.height =
            document.getElementsByClassName('k-grid-content')[0].offsetHeight - 17 + 'px';
        }
        // mod #8745 【デグレ】マスタにて追加をし行が増えると縦横のスクロールが発生する。テキストボックスが切れる。 林峻峰 start
        document.getElementsByClassName('main-content-area')[0].style.overflowY = 'hidden'
        document.getElementsByClassName('main-content-area')[0].style.overflowX = 'hidden'
        document.getElementsByClassName('k-grid')[0].style.width = `${document.getElementsByClassName('header-btn-area')[0].clientWidth
              -18}px`;
        // mod #8745 【デグレ】マスタにて追加をし行が増えると縦横のスクロールが発生する。テキストボックスが切れる。 林峻峰 end

        // 固定列の幅確保後、リサイズする前のscroll値を設定
        setTimeout(() => {
          document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].firstChild.scrollLeft = tmpScrollLeft;
          document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].lastChild.scrollTop = tmpScrollTop;
          // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
          document.getElementsByClassName('k-virtual-scrollable-wrap')[0].scrollTop = tmpScrollTop;
          // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
        });
      }
    },
    sortBtnClick() {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const grid = $("div.k-grid-content")[0];
      this.scrollPosition.top = grid.firstChild.scrollTop;
      this.scrollPosition.left = grid.lastChild.scrollLeft;
      EventBus.$emit("onCloseMasterEditModal", this.onCloseMasterEditModal);

      const tempData = deepCopy(this.getMasterRecordList.data);
      this.isSortMode = false;
      this.editableColumns();
      this.showSortColumn();
      this.sort();
      this.isSorted = this.sortChange(tempData);
      this.dataSourceItems.read()
      EventBus.$emit("setSortMode", this.isSortMode);
      this.$nextTick(() => {
        // this.editBackgroundColor()
        this.calculateGridWidth();
      });
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
        const tbodyc = this.$refs.grid.$el.lastChild.lastChild.tBodies[0].children;
        const gridData = this.$refs.grid.dataSource;
        let lockTbodyc = null;
        if(this.$refs.grid.$el.children[1].lastChild.tBodies != undefined ){
          lockTbodyc = this.$refs.grid.$el.children[1].lastChild.tBodies[0].children;

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
            if (
              this.isEdited(gridData._view[rwCount].code)
            ) {
              edited = true;
            }
            // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
            this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
            // データ参照エラーコンボの背景色を変更
            this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
          }
        }
      });
    },
    gridDataRefresh() {
      const grid = this.$refs.grid;
      grid.dataSource = this.generatedGridData();
    },
    generatedGridData() {
      let that = this;

      // const columnObject = {};
      // that.columns.forEach(column => {
      //   let name = column.field;
      //   if ("dummy" !== name) {
      //     columnObject[name] = {};
      //   } else {
      //     columnObject[name] = column;
      //   }
      // })
      // eslint-disable-next-line no-undef
      return new kendo.data.DataSource({
        pageSize: 300000,
        // mod 5515 標準医薬品マスタ検索で検索できない 周安寧 start
         data : that.masterRecords.data,
        // transport: {
        //   read: function (e) {
        //     if(that.masterRecords.data != null)
        //       e.success(that.masterRecords.data)
        //   },
        // },
         schema: that.masterRecords.schema
        // mod 5515 標準医薬品マスタ検索で検索できない 周安寧 end
      })
    },
    numericEditor(container, options) {
      const format = options.format.slice(3, options.format.length - 1);
      const decimals = format.slice(1);

      let parameter = { format, decimals, round: false };
      let  strinput= '<input data-bind="value:' + options.field + '"/> ';
      const masterField = this.getMasterRecordList.schema.model.fields[options.field];
      if (this.masterPhysicalName == "sys_medicine"){
        if(masterField.validation.maxlength) {
            let maxlength = masterField.validation.maxlength;
            masterField.validation.max = Math.pow(10,maxlength-decimals) - Math.pow(10,-decimals);
            masterField.validation.min = (Math.pow(10,maxlength-decimals) - Math.pow(10,-decimals)) *-1;
        }
        parameter = { format, decimals, round: false, min: masterField.validation.min, max: masterField.validation.max, step :Math.pow(10,-decimals),};
      }
      $(strinput).appendTo(container).kendoNumericTextBox(parameter);
    },
    loadGridData() {
      // modify #9590 start
      // this.setCondition(this.condition);
      // EventBus.$emit("clearHeaderSearch");
      if (this.conditions.recordName) {
        EventBus.$emit("handleSearch");
      } else {
        this.findList();
      }
      // modify #9590 end
    },
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name
        && document.getElementsByTagName('ons-alert-dialog').length === 0) {
        if (this.getisChanged()) {
          this.$ons.notification.confirm({
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: answer => {
              if (answer === 1) {
                //スクロールバーの位置をクリア
                this.lastScrollTop = 0;
                this.lastInputScrollLeft = 0;
                this.findList();
              }
            },
          });
        }
        else {
          //スクロールバーの位置をクリア
          this.lastScrollTop = 0;
          this.lastInputScrollLeft = 0;
          this.findList();
        }
      }
    },
    findList() {
      // apiをコールして値を取得
      this.findRecordListByFacilityCd(this.getFacilitySwitch)
        .then(response => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          if (response.data.columns.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000001].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message:
                DIALOG_MESSAGES[12000001].message,
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
            document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop = this.lastScrollTop;
            document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft = this.lastInputScrollLeft;
            setTimeout(() => {
              this.lastScrollTop = 0;
              this.lastInputScrollLeft = 0;
            }, 1000);
          });
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          this.dataSourceItems = this.generatedGridData();
        })
        .catch(error => {
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000003].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message:
                DIALOG_MESSAGES[12000003].message
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
        d["isAddRow"] = true;
        // 初期時、新しいレコードに全レコードの並び順の最大値をセット
        if (k === "sortRank") {
          d[k] = this.getMaxSortRank() + 1;
        }
      });
      this.lastScrollTop = this.$refs.grid.$el.lastChild.lastChild.scrollHeight;
      this.edit({editRecord: d, isSortMode: this.isSortMode});
      // this.dataSourceItems.add(d)
      // this.dataSourceItems.read()
      // // this.dataSourceItems.insert(-1, d)
      this.dataSourceItems = this.generatedGridData()
      // this.dataSourceItems.read({data: this.masterRecords.data})
      // this.$refs.grid.dataSource.refresh()
      this.editBackgroundColor();
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      this.scrollTop = 0;
      this.scrollLeft = 0;
      this.lastScrollTop = 0;
      this.lastInputScrollLeft = 0;
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      let isSysMedicine = false;
      if (this.masterPhysicalName == "sys_medicine") isSysMedicine = true;
      records.data = records.data.filter(
        r => !(r.operation === 1 && (!r.edited || !(r.isAddRow && (r.isDisp == '1'|| isSysMedicine))))
      );

      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();
      let message = "";
      if (validateMessage.length !== 0) {
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
        // message = "以下の列に未入力項目が存在します。" + validateMessage +"</br>";
        message = messageFormat(DIALOG_MESSAGES[12000270].message) + validateMessage +"</br>";
        // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage +"</br>";
          message + messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage +"</br>";
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
              if (this.getMasterRecordList.data[i].classType !== undefined ){
                if(tempData[j].classType.toString() == this.getMasterRecordList.data[i].classType){
                  classiFicationFlg = false;
                } else {
                  classiFicationFlg = true;
                  i = this.getMasterRecordList.data.length;
                  break;
                }
              }
              if (this.getMasterRecordList.data[i].classCd !== undefined){
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

      // 画面上で医療材料の分類が変更された場合
      if (classiFicationFlg) {
        await this.$ons.notification.alert({
          title: DIALOG_MESSAGES[12000051].title,
          // add 全マスタメッセージ調整 王 start
          // message: "分類が変更されました。透析指示に影響がないことを確認してください"
          message: DIALOG_MESSAGES[12000051].message
          // add 全マスタメッセージ調整 王 end
        });
      }
      // 更新処理呼び出す
      this.updateRecordList();
      // add FNSI-分類変更のメッセージ表示 李 end
    },
    updateRecordList() {
      /* add スクロールの位置を維持 楊 start */
      this.setLastScroll();
      /* add スクロールの位置を維持 楊 end */
      // 調製薬剤マスタ画面の分類が変更されない場合
      if (this.masterPhysicalName === "mst_medicine_mix" || this.masterPhysicalName === "mst_medicine") {
        for (let i = 0; i < this.getUpdateRecordList.length; i++) {
          delete this.getUpdateRecordList[i].classiFicationFlg;
        }
      }
      

      const keys = [
        "code",
        "standardNo",
        "prescriptionNo",
        "companyNo",
        "dispensingNo",
        "logisticsNo",
        "janCd",
        "drugPriceStandardCd",
        "standardMedicineCd",
        "receiptCd1",
        "receiptCd2",
        "noticeName",
        "name",
        "receiptMedicineName",
        "standardUnit",
        "pkgPresentation",
        "pkgAmount",
        "pkgUnit",
        "pkgTotalAmount",
        "pkgTotalUnit",
        "usageCategoryClass",
        "manufactureCompany",
        "salesCompany",
        "recordClass",
        "standardUpDate",
        "pkgQtyQuantity",
        "pkgQtyUnit",
        "pkgQtyPerCartonQuantity",
        "pkgQtyPerCartonUnit",
        "unit",
        "unitSecond",
        "unitConvertedAmount",
        "unitConvertedAmountSecond",
        "unitDecimalPoint",
        "unitDecimalPointSecond",
        "operation"
      ];

      const updateRecords = this.getUpdateRecordList.map(record =>
          _.pick(record, keys)
      );

      // console.log(this.getUpdateRecordList)
      // apiをコールして値を保存
      this.updateRecordListByFacilityCd({facilityCd: this.facilitylistValue, request: updateRecords})
        .then(response => {
          this.updateResponse = response.data;
          // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 start
          ApiHelper.get(`/sys_medicine/getTotal`).then((res) => {
            this.sysMedicineDataTotal = res.data
          });
          // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 end
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
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
    scrollRight() {
      if (this.$refs.grid !== undefined) {
        let e = this.$refs.grid.$el.lastChild;
        let scrollBottom = Math.abs(e.scrollHeight - e.scrollTop - e.clientHeight) < 4;
        if(Math.abs(e.scrollHeight - e.scrollTop - e.clientHeight) >= 4){
          this.scrollFlag=true;
        }
        if(scrollBottom){
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
            this.sysMedicineDataPage();
          }
        }
      }
    },
    async sysMedicineDataPage() {
      this.offset = this.getMasterRecordList.data.length;
      const obj = document.getElementById("recordName");
      let keyword = "";
      if(obj){
        keyword = document.getElementById("recordName").value;
      }
      // 標準医薬品マスタ
      let sysMedicineData = await ApiHelper.get(`/sys_medicine/getSysMedicineByLimitAndOffset/${this.offset}/${keyword}`);
      this.sysMedicine = sysMedicineData.data;

      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }
      for (let i = 0; i < this.sysMedicine.length; i++) {
        let d = new Object();
        const fields = this.getMasterRecordList.schema.model.fields;
        Object.keys(fields).forEach(k => {
          Object.keys(this.sysMedicine[i]).forEach(sysMedicineKey => {
            if (sysMedicineKey === k) {
              d[k] = this.sysMedicine[i][sysMedicineKey];
            }
          });
          if (k === "sortRank") {
            d[k] = this.getMaxSortRank() + 1;
          }
          if (k === "code") {
            d[k] = this.sysMedicine[i].standardNo;
          }
          d["name"] = this.sysMedicine[i].salesName;
        });
        // mod redmine 6619 標準医薬品マスタで抽出条件に関係ないデータが表示される,6620 編集していないのに編集内容破棄メッセージが表示される 宋qy start
        this.getMasterRecordList.data.push(d);
        // mod redmine 6619 標準医薬品マスタで抽出条件に関係ないデータが表示される,6620 編集していないのに編集内容破棄メッセージが表示される 宋qy end
        this.edit({editRecord: d, isSortMode: true});
      }

      this.dataSourceItems = this.generatedGridData();
      this.lastScrollTop = this.$refs.grid.$el.lastChild.scrollHeight - this.$refs.grid.$el.lastChild.clientHeight;
      this.setLoadingScreenVisible(false);
      this.$nextTick(() => {
        const gridContent = this.$refs.grid?.$el?.lastChild;
        if (gridContent) {
          gridContent.scrollTop = this.lastScrollTop || 0;
        }
      });
    },
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
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
    // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 start
    ApiHelper.get(`/sys_medicine/getTotal`).then((res) => {
      this.sysMedicineDataTotal = res.data
    });
    // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 end
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
    // 滚动条监听
    window.addEventListener("scroll", this.scrollRight,true);
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("onSearchForMstVirtualScrollable", this.onSearch);
    // add by shiyw for 6119
    window.removeEventListener("scroll", this.scrollRight,true);
  },
  // add 性能改善メモリ不足 shan start
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
/*.kendo-grid-toolbar-style >>> .k-grid-header-locked > table {
  border-right-width: 0px;
}

.kendo-grid-toolbar-style >>> .k-grid-header-locked {
  border-right: 1px solid var(--ntss-list-border-color) !important;
}

.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  z-index: 1;
  box-shadow: 1px 0px 0px 0px var(--ntss-border-color) !important;
}*/
</style>
