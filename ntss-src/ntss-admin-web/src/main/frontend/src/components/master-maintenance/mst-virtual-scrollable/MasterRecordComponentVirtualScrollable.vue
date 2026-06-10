/**
* マスタメンテナンスデータページ  MainContent
*/
<template>
  <div class="main-content-area master-maintenance-page main-content-area-style">
    <div
      class="ntss-list ntss-list-style"
      :style="ntssListStyles"
      v-kendo-validator="kendoValidatorSetup"
    >
      <div class="header-btn-area right">
        <v-ons-button
          modifier="outline"
          class="btn3-normal toolbar-btn"
          style="float: left"
          v-show="!isSortMode && isAllowAddRecord && isAddButton"
          @click="addRow()"
        >追加</v-ons-button>
        <v-ons-button
          modifier="outline"
          class="btn3-normal toolbar-btn csv-btn"
          style="margin-right: 10px"
          v-show="!isSortMode && isAllowAddRecord"
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
      <div class="grid-area kendo-grid-toolbar-style">
        <kendo-grid
          ref="grid"
          :class="fontSizeSet"
          :data-source="dataSourceItems"
          :editable="true"
          :selectable="true"
          :reorderable="false"
          :scrollable-virtual="true"
          :beforeEdit="editStart"
          :edit="addInputAssist"
          :cellClose="editEnd"
          @save="onSaveWrapper"
          @databound="onDataBoundKendoGridVirtual"
        >
          <template v-for="(column, index) in columns">
            <kendo-grid-column
              v-if="column.field === '$modalType'"
              :key="index"
              :title="
                column.title == null || column.title == '' ? ' ' : column.title
              "
              :field="column.field"
              :hidden="column.hidden"
              :attributes="{ class: 'btn3-kendo-normal' }"
              :locked="column.locked"
              :editable="column.editable"
              :width="column.width"
              :format="column.format"
              :values="column.values"
              :command="{ text: '詳細', click: showMasterEditModal }"
            >
            </kendo-grid-column>
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
            >
            </kendo-grid-column>
            <!-- add 鞠 start カレンダーの追加-->
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
            >
            </kendo-grid-column>
            <!-- add 鞠 end カレンダーの追加-->
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
            >
            </kendo-grid-column>
          </template>
        </kendo-grid>
      </div>
      <div id="grid-footer">
        <v-ons-row width="100%" v-show="!isSortMode">
          <v-ons-col width="50%">
            <v-ons-button
              class="btn2-cancel denial-btn"
              style="width: auto"
              @click="cancel"
            >キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button
              class="btn1-execute registration-btn"
              style="width: auto"
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
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import $ from "jquery";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { ApiHelper } from "@/apis/AxiosHelper";
// add 鞠 start
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import Vue from "vue";
// add 鞠 end
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
// add start #9301
import { DEFAULT_PROCEDURE,DEFAULT_MEDICATE_TIMING } from "@/constants/facilitySetting";
// add end #9301
export default {
  name: "MasterRecordVirtualScrollable",
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
  components: {
    "master-csv": MasterCsvComponent,
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
      columnWidth: 14,
      condition: {
        recordName: "",
        includeDeleted: false,
      },
      scrollPosition: {
        top: 0,
        left: 0,
      },
      //自画面の名称
      selfScreenName: "",
      masterCsvVisible: false,
      masterCsvTarget: null,
      facilitylistValue: "",

      dataSourceItems: {},
      // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 付 start
      scrollFlag: false,
      offset: 0,
      mstDiseaseDataTotal: null,
      // sysMedicine
      // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 付 end
      // add start #9301
      defaultMedicateTimingDataCd: null,
      defaultProcedureCd: null
      // add end #9301
    };
  },
  async created() {
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
    this.setLoadingScreenVisible(true);
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
    this.setCondition(this.condition);
    this.loadGridData();
    this.selfScreenName = this.$router.currentRoute.name;
    this.facilitylistValue = this.getFacilitySwitch;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("onSearchForMstVirtualScrollable", this.onSearch);
  },
  watch: {
    masterRecords() {
      this.dataSourceItems = this.generatedGridData();
    },
    windowHeight() {
      this.calculateGridWidth();
    },
    windowWidth() {
      this.calculateGridWidth();
    },
    isDispMenu() {
      // 表示領域のサイス変更を反映させる
      this.$refs.grid?.kendoWidget()._refreshHandler();
    },
    getFontSize() {
      // スクロール領域のサイズ更新のためグリッド全体の再表示を発生させる
      this.redisplayGrid();
    },
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy start
    // 关闭loading
    columns: function (val) {
      this.$nextTick(function () {
        if (val.length > 1) this.setLoadingScreenVisible(false);
      });
    },
    // add redmine 6238 標準医薬品マスタでデータが表示されない 宋qy end
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
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
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
      // add kj 9073 start
      getComparisonRecordModel: "getComparisonRecordModel",
      // add kj 9073 end
    }),
    ntssListStyles() {
      return this.columns.length == 1 ? { display: "none" } : {};
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
      let addMasterName = [
        "sys_medicine",
        "mst_take_medicine",
        "mst_vital_graph",
      ];
      return addMasterName.indexOf(this.masterPhysicalName) < 0;
    },
    fontSizeSet() {
      const names = ["small", "medium", "large", "x-large"];
      return ["grid-style", "font-size-set-" + names[this.getFontSize]];
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
        (this.isRecordModified || !this.kendoValidator.validate())
      );
    },
  },
  methods: {
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("master-maintenance", [
      "findColumnInfo",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "setComparisonRecordModel",
      "findRecordListByFacilityCd",
      "findFacilitySettingInfo"
    ]),
    ...mapActions("master-maintenance", {
      facilityList: "facilityList",
    }),
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
    }),
    init() {
      if (this.dataSourceItems && typeof this.dataSourceItems.data === 'function') {
        this.dataSourceItems.data([...this.masterRecords.data])
      }
    },
    // add 鞠 start カレンダー機能の追加
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
          nowDtatString = null
        }
        // #5590 2023/04/20 ×を常に表示するように修正 林峻峰 end
        $(
          `<span style="position:relative"><input type="date" style="width:120px" id="displayedDummyEditor" class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;"/><span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:absolute;left:100px;top:1px;color: #212529;z-index:9999999" ></span></span>`
        ).appendTo(container);
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
              document.getElementById("hiddenDateInputEditor").value =
                resultData;
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
        // let clear = `<span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:absolute;left:110px;top:12px;color: #212529;z-index:9999999" ></span>`
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
    // add 鞠 end カレンダーの追加
    setScrollPosition(position) {
      this.setScrollTopLeft({
        scrollTop: position.top,
        scrollLeft: position.left,
      });
    },
    // add start #9301
    async getDefaultCd () {
      const defaultMedicateTimingData = await this.findFacilitySettingInfo({facilityCd: this.getFacilitySwitch,settingNo: DEFAULT_MEDICATE_TIMING});
      this.defaultMedicateTimingDataCd = defaultMedicateTimingData?.data || null;
      const defaultProcedureData = await this.findFacilitySettingInfo({facilityCd: this.getFacilitySwitch,settingNo: DEFAULT_PROCEDURE});
      this.defaultProcedureCd = defaultProcedureData?.data || null;
    },
    // add end #9301
    // modify start #9301
    async showMasterEditModal(e) {
      // モーダル確定時にスクロール位置が戻ってしまう問題の対処
      const scrollPosition = this.getScrollTopLeft();
      this.scrollPosition.top = scrollPosition.scrollTop;
      this.scrollPosition.left = scrollPosition.scrollLeft;

      const row = this.$refs.grid.kendoWidget();
      const selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      if (selectedRowItem.isAddRow) {
        selectedRowItem.medicateTimingCd = this.defaultMedicateTimingDataCd;
        selectedRowItem.procedureCd = this.defaultProcedureCd
      }

      /**
       * 「詳細」ボタンを押下したレコードのデータを取得する。
       * see: https://www.telerik.com/forums/selected-row-at-wrappers-for-vue
       */
      e.preventDefault();
      // const row = this.$refs.grid.kendoWidget();
      // let selectedRowItem = row.dataItem(e.currentTarget.closest("tr"));
      let code = selectedRowItem.code;

      // codeがない場合はcodeを付番
      if (!code) {
        this.edit({ editRecord: selectedRowItem, isSortMode: this.isSortMode });
        code = this.getMasterRecordList.data[0].code;
      }

      // プロパティを正規化する。
      const normalizedItem = this.normalization(selectedRowItem);

      // ストアに保存する。
      this.setEditRecord(normalizedItem);// モーダルを表示
      // モーダルを表示
      this.showMasterEdit();
    },
    // modify end #9301
    onDataBoundKendoGridVirtual() {
      this.editBackgroundColor();
      this.calculateGridWidth();
    },
    onSaveWrapper(event) {
      this.runTaskAndRestoreScroll(() => {
        this.onSave(event);
      });
    },
    onSearch() {
      this.dataSourceItems = this.generatedGridData();
    },
    async calculateGridWidth() {
      // 描画後に実行
      await this.$nextTick();

      const gridWidget = this.$refs.grid?.kendoWidget();
      const lockedContent = gridWidget?.lockedContent?.[0];
      const lockedHeader = gridWidget?.lockedHeader?.[0];
      if (!lockedContent || !lockedHeader) return;

      // 固定列数のカウント
      // ソートモード以外ではダミー列があるため -1 する
      const lockedColumnCount = this.columns.filter(
        col => col.locked && !col.hidden
      ).length - (this.isSortMode ? 0 : 1);

      // 固定列幅算出
      const lockedColumnWidth = lockedColumnCount * this.columnWidth;
      if (this.editFlg) {
        this.editFlg = false;
      }

      // kendoGridのリサイズを呼び出して自動リサイズがされないケースがある問題に対応
      if (this.$refs.grid != null) {
        const setWidth = parseInt(this.$refs.grid.kendoWidget().columns[0].width);
        this.$refs.grid.kendoWidget().resizeColumn(this.$refs.grid.kendoWidget().columns[0], setWidth);
      }
      // 固定列の幅確保
      const prevLockedWidthPx = lockedContent.clientWidth;
      const lockedWidth = (lockedColumnWidth == 0) ? "10px": `${lockedColumnWidth}em`;
      lockedHeader.style.width = lockedContent.style.width = lockedWidth;
      [lockedHeader, lockedContent].forEach((locked) => {
        const nameCol = locked.querySelector("colgroup")?.childNodes[1];
        console.log(`locked.className:${locked.className}, nameCol.outerHTML:${nameCol.outerHTML}.`);
        if (!nameCol) return;
        nameCol.style.width = `${this.columnWidth}em`;
      });

      // 固定列の幅の変化に応じて可変列の幅を調整する
      const newLockedWidthPx = lockedContent.clientWidth;
      const lockedWidthPxAdder = (newLockedWidthPx - prevLockedWidthPx);
      [...gridWidget.scrollables].forEach((scrollable) => {
        const currentWidthPx = Number(scrollable.style.width.slice(0, -2));
        scrollable.style.width = `${currentWidthPx - lockedWidthPxAdder}px`;
      });

      if (document.getElementsByClassName('k-grid-content').length !== 0
        && document.getElementsByClassName('k-grid-content-locked')[0].clientHeight
        !== document.getElementsByClassName('k-grid-content')[0].clientHeight
        && !this.androidFlg && !this.iosFlg
      ) {
        document.getElementsByClassName('k-grid-content-locked')[0].style.height = `${document.getElementsByClassName('k-grid-content')[0].offsetHeight - 17}px`;
      }
    },
    toRankEditBtnClick() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) return;

      this.runTaskAndRestoreScroll(() => {
        this.isSortMode = true;
        this.disableColumns();
        this.showSortColumn();
        this.calculateGridWidth();
        EventBus.$emit('setSortMode', this.isSortMode);
      });
    },
    sortBtnClick() {
      this.runTaskAndRestoreScroll(() => {
        const tempData = deepCopy(this.getMasterRecordList.data);
        this.isSortMode = false;
        this.editableColumns();
        this.showSortColumn();
        this.calculateGridWidth();
        this.sort();
        this.isSorted = this.sortChange(tempData);
        this.dataSourceItems.read();
        EventBus.$emit("setSortMode", this.isSortMode);
      });
    },
    async editBackgroundColor() {
      await this.$nextTick();

      // グリッドが表示されていなかったら処理終了
      const gridHeader = this.$refs.grid.$el.firstChild;
      if (gridHeader.textContent === " ") {
        return;
      }
      gridHeader?.classList?.add("master-grid-header");

      // 固定列、可変列、データソースの取得
      const gridWidget = this.$refs.grid?.kendoWidget();
      const lockedTrList = gridWidget?.lockedContent?.[0]?.querySelector("tbody")?.children;
      const contentTrList = gridWidget?.content?.[0]?.querySelector("tbody")?.children;
      const viewDataList = this.$refs.grid?.dataSource?.view();
      // グリッドにレコードがなければ処理終了
      if (!contentTrList || !lockedTrList || !viewDataList) {
        return;
      }

      const getMasterRecordListData = this.getMasterRecordList.data;
      const getComparisonRecordModel = this.getComparisonRecordModel ? JSON.parse(this.getComparisonRecordModel) : null;

      viewDataList.forEach((viewData, trIndex) => {
        const currentTrc = contentTrList[trIndex].children;
        const currentLockTrc = lockedTrList[trIndex].children;

        // 並び順の色変更
        this.changeSortColor(currentLockTrc);
        // 編集項目の色を変更
        let edited = this.changeEditColor(currentTrc, currentLockTrc);
        // 削除対象を判定
        const deleted = this.isDeleteRow(currentTrc);
        // モーダルからの編集も色を変更する
        if (this.isEdited(viewData.code)) {
          edited = true;
        }
        // add kang 9074 start
        if (!getComparisonRecordModel) {
          return;
        }
        const dataIndex = getMasterRecordListData.findIndex((data) => data.code === viewData.code);
        if (dataIndex < 0) {
          return;
        }
        // ソースデータです
        const rowDataSource = getComparisonRecordModel[dataIndex];
        // アフターデータです
        const operationData = getMasterRecordListData[dataIndex];
        if (rowDataSource && operationData?.operation != undefined) {
          rowDataSource.operation = operationData.operation;
        }
        if (rowDataSource != undefined && JSON.stringify(rowDataSource) === JSON.stringify(operationData)) {
          edited = false;
        } else {
          edited = true;
        }
        // add kang 9074 end
        // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
        this.changeRowColor(currentTrc, currentLockTrc, edited, deleted);
        // データ参照エラーコンボの背景色を変更
        if (this.masterPhysicalName !== "mst_medicine") {
          // mod #9863 編集時背景色表示異常の横展開 蔡 start
          // this.changeRefErrorComboColor(currentTrc, deleted);
          this.changeRefErrorComboColor(currentTrc, deleted, currentLockTrc);
          // mod #9863 編集時背景色表示異常の横展開 蔡 end
        }
      });
    },
    getScroller() {
      const gridRoot = this.$refs.grid?.$el;
      const vScroller = gridRoot?.querySelector(".k-scrollbar-vertical");
      const hScroller = gridRoot?.querySelector(".k-virtual-scrollable-wrap");
      return { vScroller, hScroller };
    },
    getScrollTopLeft() {
      const { vScroller, hScroller } = this.getScroller();
      const scrollTop = vScroller?.scrollTop;
      const scrollLeft = hScroller?.scrollLeft;
      return { scrollTop, scrollLeft };
    },
    setScrollTopToBottom() {
      const { vScroller } = this.getScroller();
      if (!vScroller) return;
      const scrollTop = vScroller.scrollHeight - vScroller.clientHeight;
      this.setScrollTopLeft({ scrollTop });
    },
    setScrollTopLeft({ scrollTop, scrollLeft }) {
      const { vScroller, hScroller } = this.getScroller();
      if (vScroller && scrollTop) {
        vScroller.scrollTop = scrollTop;
      }
      if (hScroller && scrollLeft) {
        hScroller.scrollLeft = scrollLeft;
      }
    },
    runTaskAndRestoreScroll(task) {
      const scrollPositions = this.getScrollTopLeft();
      task();
      this.$nextTick(() => {
        this.setScrollTopLeft(scrollPositions);
      });
    },
    redisplayGrid() {
      this.runTaskAndRestoreScroll(() => {
        this.dataSourceItems = this.generatedGridData();
      });
    },
    generatedGridData() {
      return new kendo.data.DataSource({
        pageSize: 40,
        page: 0,
        data : this.masterRecords.data,
        schema: this.masterRecords.schema
      });
    },
    numericEditor(container, options) {
      const format = options.format.slice(3, options.format.length - 1);
      const decimals = format.slice(1);

      let parameter = { format, decimals, round: false };
      let strinput = '<input data-bind="value:' + options.field + '"/> ';
      const masterField =
        this.getMasterRecordList.schema.model.fields[options.field];
      if (this.masterPhysicalName == "sys_medicine") {
        if (masterField.validation.maxlength) {
          let maxlength = masterField.validation.maxlength;
          masterField.validation.max =
            Math.pow(10, maxlength - decimals) - Math.pow(10, -decimals);
          masterField.validation.min =
            (Math.pow(10, maxlength - decimals) - Math.pow(10, -decimals)) * -1;
        }
        parameter = {
          format,
          decimals,
          round: false,
          min: masterField.validation.min,
          max: masterField.validation.max,
          step: Math.pow(10, -decimals),
        };
      }
      $(strinput).appendTo(container).kendoNumericTextBox(parameter);
    },
    loadGridData() {
      // delete start #9590
      // this.setCondition(this.condition);
      // EventBus.$emit("clearHeaderSearch");
      // delete end #9590
      this.findList();
    },
    findList(options) {
      const { scrollPositions } = options || {};
      // apiをコールして値を取得
      this.findRecordListByFacilityCd(this.getFacilitySwitch)
        .then((response) => {
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
          });
          this.columns = toFunction;
          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach((column) => {
            // 「削除」のプルダウンが改行しない幅に調整
            // mod #7289-マスタの削除ボタンが縦表示になる 徐博 start
            // column.width = column.field === "isDisp" ? "8em" : (this.columnWidth + "em");
            column.width =
              column.field === "isDisp" ? "9em" : this.columnWidth + "em";
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
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          this.dataSourceItems = this.generatedGridData();
          if (scrollPositions) {
            this.$nextTick(() => {
              this.setScrollTopLeft(scrollPositions);
            });
          }
        })
        .catch((error) => {
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
        });
      // カラム定義情報を取得
      this.findColumnInfo();
    },
    addRow() {
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        return;
      }
      this.setLoadingScreenVisible(true);
      // 空レコードをストアに登録
      let d = new Object();
      const fields = this.getMasterRecordList.schema.model.fields;
      Object.keys(fields).forEach((k) => {
        // バリデーションで必須が定義されているかどうか
        const validation = fields[k].validation;
        const isRequired =
          typeof validation !== "undefined" && validation.required;
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
      this.edit({ editRecord: d, isSortMode: this.isSortMode });
      this.dataSourceItems = this.generatedGridData();
      this.$nextTick(() => {
        this.setScrollTopToBottom();
        this.setLoadingScreenVisible(false);
      });
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);

      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;

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
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
          // message + "以下の列の選択を見直してください。" + validateComboMessage +"</br>";
          message + messageFormat(DIALOG_MESSAGES[12000006].message) + validateComboMessage +"</br>";
          // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      }

      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES["00300006"].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>",
        });
        this.waterSurveyPointValueFalg = false;
        return;
      }

      // add FNSI-分類変更のメッセージ表示 李 start
      let classiFicationFlg = false;
      this.getMasterRecordList.data.forEach((item) => {
        if (item.operation !== 1) {
          // 医療材料の分類が変更された
          if (item.dirtyFields && item.dirtyFields.classCd) {
            classiFicationFlg = true;
          } else if (item.dirtyFields && item.dirtyFields.classType) {
            // 薬剤の分類が変更された
            classiFicationFlg = true;
          } else if (item.classiFicationFlg) {
            classiFicationFlg = true;
          }
        }
      });

      // add 分類区分/分類 修正 王 start
      if (this.masterPhysicalName === "mst_medicine") {
        let tempData = null;
        await ApiHelper.get(
          `/master_maintenance/${this.masterPhysicalName}/data/${this.facilitylistValue}`
        ).then((response) => {
          tempData = response.data.localDataSource.data;
        });
        for (let i = 0; i < this.getMasterRecordList.data.length; i++) {
          for (let j = 0; j < tempData.length; j++) {
            if (tempData[j].code === this.getMasterRecordList.data[i].code) {
              if (this.getMasterRecordList.data[i].classType !== undefined) {
                if (
                  tempData[j].classType.toString() ==
                  this.getMasterRecordList.data[i].classType
                ) {
                  classiFicationFlg = false;
                } else {
                  classiFicationFlg = true;
                  i = this.getMasterRecordList.data.length;
                  break;
                }
              }
              if (this.getMasterRecordList.data[i].classCd !== undefined) {
                if (
                  tempData[j].classCd.toString() ==
                  this.getMasterRecordList.data[i].classCd
                ) {
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
          message: DIALOG_MESSAGES[12000051].message
        });
      }
      // 更新処理呼び出す
      this.updateRecordList();
      // add FNSI-分類変更のメッセージ表示 李 end
    },
    updateRecordList() {
      const scrollPositions = this.getScrollTopLeft();
      // 薬剤マスタ画面の分類が変更されない場合
      if (this.masterPhysicalName === "mst_medicine") {
        for (let i = 0; i < this.getUpdateRecordList.length; i++) {
          delete this.getUpdateRecordList[i].classiFicationFlg;
        }
      }

      // apiをコールして値を保存
      this.updateRecordListByFacilityCd({
        facilityCd: this.facilitylistValue,
        request: this.getUpdateRecordList,
      })
        .then((response) => {
          this.updateResponse = response.data;
          // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 付 start
          ApiHelper.get(`/master_maintenance/getTotal/${this.facilityCd}`).then(
            (res) => {
              this.mstDiseaseDataTotal = res.data;
            }
          );
          // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 付 end
          this.$ons.notification.alert({
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
            // title: "更新完了",
            // message: "マスタ更新が完了しました。"
            title: DIALOG_MESSAGES[12000004].title,
            message: messageFormat(DIALOG_MESSAGES[12000004].message),
            // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          });

          this.findList({ scrollPositions });
        })
        .catch((error) => {
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage,
            });
          }
        })
        // 共通ローダー：表示終了
        .finally(() => this.setLoadingScreenVisible(false));
    },
    // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 付 start
    scrollRight() {
      if (this.masterPhysicalName === "mst_disease") {
        if (this.$refs.grid !== undefined) {
          let e = this.$refs.grid.$el.lastChild.lastChild;
          let scrollBottom =
            Math.abs(e.scrollHeight - e.scrollTop - e.clientHeight) < 4;
          if (Math.abs(e.scrollHeight - e.scrollTop - e.clientHeight) >= 4) {
            this.scrollFlag = true;
          }
          if (scrollBottom) {
            if (this.scrollFlag) {
              // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 start
              if (this.offset === this.mstDiseaseDataTotal) {
                this.setLoadingScreenVisible(false);
                return;
              }
              // add #6930 標準医薬品マスタの抽出で追加読み込みが行われない 付 end
              this.setLoadingScreenVisible(true);
              this.scrollFlag = false;
              this.mstDiseaseDataPage();
            }
          }
        }
      }
    },
    async mstDiseaseDataPage() {
      // #9863 Uncaught (in promise) TypeError: Cannot read properties of undefined (reading 'length') 横展開2 linjunfeng start
      if (this.getMasterRecordList.data == null) {
        return;
      }
      // #9863 Uncaught (in promise) TypeError: Cannot read properties of undefined (reading 'length') 横展開2 linjunfeng end
      this.offset = this.getMasterRecordList.data.length;
      let mstDiseaseData = await ApiHelper.get(
        `/master_maintenance/getMstDiseaseByLimitAndOffset/${this.facilityCd}/${this.offset}`
      );
      this.sysMedicine = mstDiseaseData.data;
      if (!this.kendoValidator.validate()) {
        return;
      }
      for (let i = 0; i < this.sysMedicine.length; i++) {
        let d = new Object();
        const fields = this.getMasterRecordList.schema.model.fields;
        Object.keys(fields).forEach((k) => {
          Object.keys(this.sysMedicine[i]).forEach((sysMedicineKey) => {
            if (sysMedicineKey === k) {
              d[k] = this.sysMedicine[i][sysMedicineKey];
            }
          });
          if (k === "sortRank") {
            d[k] = this.getMaxSortRank() + 1;
          }
          if (k === "code") {
            d[k] = this.sysMedicine[i].diseaseCd;
          }
          d["name"] = this.sysMedicine[i].diseaseName;
        });
        // mod redmine 6619 標準医薬品マスタで抽出条件に関係ないデータが表示される,6620 編集していないのに編集内容破棄メッセージが表示される 宋qy start
        this.getMasterRecordList.data.push(d);
        // mod redmine 6619 標準医薬品マスタで抽出条件に関係ないデータが表示される,6620 編集していないのに編集内容破棄メッセージが表示される 宋qy end
        this.edit({ editRecord: d, isSortMode: true });
      }
      this.redisplayGrid();
      this.setLoadingScreenVisible(false);
    },
    // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 付 end
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
    this.editBackgroundColor();
    // #8519 編集した項目のバッググラウンドが黄緑にならない 訾浩 start
    this.calculateGridWidth();
  },
  mounted() {
    // add start #9301
    this.getDefaultCd();
    // add end #9301
    // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 付 start
    ApiHelper.get(`/master_maintenance/getTotal/${this.facilityCd}`).then(
      (res) => {
        this.mstDiseaseDataTotal = res.data;
      }
    );
    window.addEventListener("scroll", this.scrollRight, true);
    // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 付 end
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("onSearchForMstVirtualScrollable", this.onSearch);
    // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 付 start
    window.removeEventListener("scroll", this.scrollRight, true);
    // add #7390 コンバート後、病名マスタを開くと処理中のまま終わらない 付 end
  },
  // add 性能改善メモリ不足 shan start
};
</script>

<style scoped>
.right {
  text-align: right;
}

.main-content-area-style {
  margin: unset;
  padding: 5px;
  padding-top: 0;
  box-sizing: border-box;
  height: 100%;
}

.ntss-list-style {
  position: unset;
  height: 100%;
  display: flex;
  flex-flow: column nowrap;
}

.header-btn-area {
  flex-shrink: 0;
  padding: 1px;
}

.grid-area {
  flex-grow: 1;
  overflow-y: hidden;
}
.grid-style {
  height: 100%;
}

#grid-footer {
  flex-shrink: 0;
  margin: 0;
  padding: 5px;
  padding-bottom: 0;
}

.toolbar-btn {
  font-size: 1em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
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

.kendo-grid-toolbar-style >>> .k-grid-header {
  background: var(--ntss-list-header-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,.1) 100%);
}
</style>
