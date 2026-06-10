// 影響範囲:
// 38:職種マスタ mst_job
// 190:よく使う施設マスタ mst_favorite_facility
// 210:禁忌・アレルギーマスタ mst_taboo_allergy
// 300:病名マスタ mst_disease
// 460:薬剤マスタ mst_medicine
// 610:検査項目マスタ mst_exam_item
// 1100:日常・定期点検項目マスタ mst_mainte_detail
<template>
  <div class="virtual-container master-maintenance-page" v-kendo-validator>
    <div class="tool-bar" :class="{ 'sort-mode': isSortMode, 'sort-mode-exam-item': masterPhysicalName === 'mst_exam_item' } ">
      <div :class="['tool-bar-left', isMobileDevice ? 'mobile-header' : '']">
        <v-ons-button
          v-if="!isSortMode && isAllowAddRecord && isAddButton"
          modifier="outline"
          class="btn3-normal toolbar-btn"
          @click="onAdd"
          >追加
        </v-ons-button>
        <v-ons-button
          modifier="outline"
          v-if="masterPhysicalName === 'mst_exam_item'"
          class="btn3-normal toolbar-btn re-calculation-btn"
          @click="showMstExamItemRecManagementModal"
          >再計算</v-ons-button
        >
        <v-ons-row v-show="isMobileDevice" style="float: right; width: 7em; height: 1em; margin-left: 1em;">
          <v-ons-col width="45%" vertical-align="center">
            <label class="fab-font-color">編集</label>
          </v-ons-col>
          <v-ons-col width="55%" vertical-align="center">
            <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
          </v-ons-col>
        </v-ons-row>
      </div>
      <div class="tool-bar-right">
        <v-ons-button
          v-if="
            !isSortMode &&
            isAllowAddRecord &&
            masterPhysicalName !== 'mst_favorite_facility'
          "
          modifier="outline"
          class="btn3-normal toolbar-btn right10"
          @click="importCsv"
          >CSV取込</v-ons-button
        >
        <v-ons-button
          v-if="isAllowSort"
          modifier="outline"
          class="btn3-normal toolbar-btn"
          @click="handleToggleSortMode"
          >{{ isSortMode ? "反映" : "並び順表示" }}
        </v-ons-button>
      </div>
    </div>
    <div class="grid-content">
      <kendo-grid
        :key="keys"
        ref="grid"
        :class="isSortMode ? 'sort-mode' : ''"
        :data-source="gridData"
        height="100%"
        :editable="{
          createAt: 'bottom',
        }"
        :columns="gridColumns"
        :selectable="true"
        :scrollable-virtual="true"
        :filterable="false"
        @save="onSave"
        @databound="onDataBound"
        @edit="onEdit"
        @beforeedit="onBeforeEdit"
        @cellclose="onCellClose"
      >
        <!-- :pageable-previous-next="false" -->
        <!-- :pageable-numeric="true" -->
        <!-- :pageable-messages-display="'Showing {2} data items'" -->
      </kendo-grid>
    </div>
    <div v-if="!isSortMode" class="footer">
      <v-ons-button class="btn2-cancel toolbar-btn" @click="onCancel"
        >キャンセル</v-ons-button
      >
      <v-ons-button
        type="submit"
        modifier="outline"
        class="btn3-normal toolbar-btn"
        :disabled="isNotChanged"
        @click="onSaveChanges"
        >保存
      </v-ons-button>
    </div>
    <master-csv
      :popoverVisible="masterCsvVisible"
      :popoverTarget="masterCsvTarget"
      @popover-close="masterCsvVisible = false"
      @addRow="getCsvData"
    />
  </div>
</template>

<script>
import {
  sendRequestFindRecordListByFacilityCd,
  sendRequestUpdateRecordListByFacilityCd,
  sendRequestFindRecordListByFacilityCdWithSql,
} from "@/apis/master-maintenance";
import { sendRequestGetMstFacilitySettingValue } from "@/apis/facility-setting";
import {
  PERMISSION_CHANGE_SIGNOUT,
  DEFAULT_PROCEDURE,
  DEFAULT_MEDICATE_TIMING,
} from "@/constants/facilitySetting";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
import { EventBus } from "@/eventBus.js";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
import { messageFormat } from "@/functions/common/MessageFormat";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { mapState, mapActions, mapMutations } from "vuex";
import _ from "lodash";
import {
  customComparator,
  emToPx,
  pxForFontSize,
  diffObj,
  isEmpty,
} from "@/utils/util.js";
import MstValidateMixins from "./MstValidateMixins";
import MstExamItemMixins from "./MstExamItemMixins";
import ColumnWidthMap from "./MasterColumnWidth.js";
import $ from "jquery";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
import Vue from "vue";
import { deleteDataProcessing } from "@/functions/mst/MasterMaintenanceFunctions";

export default {
  mixins: [MstValidateMixins, MstExamItemMixins],
  data() {
    return {
      keys: 0,
      gridData: null,
      gridColumns: [],
      allGridData: [],
      gridSchemaModel: {},
      nextId: 0,
      isSortMode: false,
      isAllowSort: false,
      isAllowAddRecord: false,
      isAddButton: false,
      masterCsvVisible: false,
      masterCsvTarget: null,
      originalDataSource: null,
      isNotChanged: true,
      requiredFields: [],
      fieldsMap: new Map(),
      signoutFlg: false, // used for 職種マスタ
      zoomObserver: null,
      androidFlg: false,
      iosFlg: false,
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      scrollPosition: {
        top: 0,
        left: 0
      },
      scrollRestored: true,
      updatedFlg: false,
      saveFlg: false,
    };
  },
  components: {
    "master-csv": MasterCsvComponent,
  },
  computed: {
    ...mapState("master-maintenance", {
      facilityCd: "facilitySwitch",
      masterPhysicalName: "selectedMasterName",
      editedRowItem: "editRecord",
      virtualCondition: "virtualCondition",
      mstFavoriteFacilityAddRows: "mstFavoriteFacilityAddRows",
    }),
    ...mapState("account-edit", ["fontSize", "showSidebarFlg"]),
    ...mapState("window-size", ["windowWidth", "windowHeight"]),
    isChanged() {
      return !this.isNotChanged;
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  methods: {
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
    ]),
    ...mapActions("multi-modal", [
      "showMasterEdit",
      "showJobMasterEditAuthority",
      "showMstExamItemRecManagementModal",
      "showMstFavoriteFacilityModal",
      "showMstJobEditDefaultSettingModal",
      "showMstJobEditNotificationSettingModal"
    ]),
    ...mapActions("mst-job", ["setIsEditAuthority", "setIsMenuSettings", "setIsDefaultDispSettings", "setIsDefaultNotificationSettings"]),
    ...mapActions("master-maintenance", ["findColumnInfo", "setEditRecord"]),
    ...mapMutations("master-maintenance", [
      "setColumns",
      "setVirtualCondition",
      "resetVirtualCondition",
      "setGridData",
      "setSchemaModel",
      "setMstFavoriteFacilityAddRows",
    ]),
    getCsvData(dataArr) {
      const grid = this.$refs.grid.kendoWidget();
      // フィルタ条件をクリア
      if (this.virtualCondition.value) {
        this.resetVirtualCondition();
      }
      // スクロールバーの頂点
      this.gridData.filter({});
      this.gridData.page(1);
      grid.virtualScrollable._scrollTo(0);

      const nonDeletedData = this.gridData.data().filter((item) => {
        return (
          item.isDisp === "1" &&
          (item.hasOwnProperty("isDel") ? item.isDel === "0" : true)
        );
      });
      let codeTemp = -1;
      let sortTemp = 0;
      if (this.gridData.data().length > 0) {
        let { code } = _.maxBy(this.gridData.data(), "code");
        codeTemp = code;
      }
      if (nonDeletedData.length > 0) {
        let { sortRank } = _.maxBy(nonDeletedData, "sortRank");
        sortTemp = sortRank;
      }
      let dataMap = new Map();
      let schemaKeys = Object.keys(this.gridSchemaModel);

      dataArr = dataArr.map((item) => {
        if (item.code) {
          dataMap.set(item.code, item);
        }
        schemaKeys.forEach((key) => {
          if (!item.hasOwnProperty(key)) {
            let defaultValue =
              this.gridSchemaModel[key].type === "number" ? 0 : "";
            item[key] =
              Number(this.gridSchemaModel[key]?.defaultValue) || defaultValue;
          } else if (this.gridSchemaModel[key].type === "number" && item[key]) {
            item[key] = Number(item[key]) || item[key];
          }
        });
        return {
          ...item,
          code: item.code || ++codeTemp,
          sortRank: ++sortTemp,
          isImport: true,
          dirty: true,
          isDisp: "1",
          // isDel: "0",
        };
      });
      const repeatDataSet = new Set();
      dataMap.size &&
        this.gridData.data().forEach((item) => {
          if (item.isDisp === "1" && dataMap.has(item.code)) {
            item.init(dataMap.get(item.code));
            repeatDataSet.add(codeTemp);
          }
        });
      this.gridData.unbind("change");
      dataArr.forEach((item) => {
        if (repeatDataSet.size && repeatDataSet.has(item.code)) {
          return;
        }
        const row = this.gridData.add(item);
        row.set("dirty", true);
      });
      this.gridData.bind("change");
      this.gridData.trigger("change");
      this.$nextTick(() => {
        this.keys++;
        this.handleFilterByCondition(this.virtualCondition);
      });
    },
    importCsv(event) {
      // グリッドでエラーが発生している場合は処理を中断
      if (this.kendoValidator && !this.kendoValidator.validate()) {
        return;
      }
      this.masterCsvTarget = event.target;
      this.masterCsvVisible = true;
    },
    onAdd() {
      this.setVirtualCondition({
        value: "",
        fields: this.virtualCondition.fields,
        includeDeleted: false,
      });
      if (this.masterPhysicalName === "mst_favorite_facility") {
        this.setEditRecord({});
        this.setMstFavoriteFacilityAddRows([]);
        this.setGridData(_.cloneDeep(this.gridData.data().toJSON()));
        this.showMstFavoriteFacilityModal();
        return;
      }
      this.$nextTick(() => {
        const grid = this.$refs.grid.kendoWidget();
        if (this.gridData.data().length > 0) {
          let { code } = _.maxBy(this.gridData.data(), "code");
          grid.addRow();
          const newItem = this.gridData.data().at(this.gridData.total() - 1);
          newItem.set("code", ++code);
          // this.$refs.grid.kendoWidget().refresh();
        } else {
          grid.addRow();
        }
      });
    },
    onCellClose() {
      this.$nextTick(() => {
        this.$refs.grid.kendoWidget()._resize(30, true);
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
      this.$nextTick(() => {
        this.$refs.grid.kendoWidget().virtualScrollable.repaintScrollbar();
      });
    },
    onEdit(e) {
      const textBoxList = e.container.find(".k-textbox");
      textBoxList.attr("title", "");
      const inputList = e.container.find(".k-input");
      inputList.attr("title", "");
      const dropdownList = e.container.find(".k-dropdown");
      dropdownList.attr("title", "");
      const linkList = e.container.find(".k-link");
      linkList.attr("title", "");
      this.$nextTick(() => {
        this.$refs.grid.kendoWidget().virtualScrollable.repaintScrollbar();
        // this.$refs.grid.kendoWidget()._resize(30, true);
      });
    },
    onSave(e) {
      const { uid } = e.model;
      const originalItem = this.originalDataSource.find((item) => {
        return item.uid === uid;
      });
      if (this.masterPhysicalName === "mst_mainte_detail") {
        // 日常・定期点検項目マスタ
        if (e.values.isCmt) {
          // 補足コメント有無
          e.model.set("iniText", null); // 初期展開テキスト
        }
        if (e.values.mainteClass) {
          // 用途
          e.model.set("mainteContent3", null); // 内容3
          if (e.values.mainteClass === "1") {
            // 用途: 日常点検
            e.model.set("ansPattern", "0"); // 回答パターン: 日常点検
          } else if (e.values.mainteClass === "2") {
            // 用途: 定期点検
            e.model.set("ansPattern", "1"); // 回答パターン: 定期点検
          }
        }
      }
      // 新追加行
      if (e.model.isNew()) {
        if (e.model.sortRank) {
          return;
        }
        // e.model.sortRank === 0
        this.judgeNewRowRequiredFields(e.model);
        this.handleChangeEditedBackgroundColor(e, uid, "new", "addBg");
        return;
      }
      if (this.isSortMode && e.values.sortRank) {
        e.model.sortInputTime = Date.now();
      }
      const editField = Object.keys(e.values)[0];
      const editedValue = e.values[editField];
      const isEqual = _.isEqualWith(
        originalItem?.[editField],
        editedValue,
        customComparator
      );
      if (isEqual && editField !== "sortRank") {
        delete e.model.dirtyFields[editField];
        this.$nextTick(() => {
          e.container[0].classList.remove("k-dirty-cell");
        });
        if (Object.keys(e.model.dirtyFields).length === 0) {
          e.model.set("dirty", false);
          delete e.model.dirtyFields.dirty;
          this.handleChangeEditedBackgroundColor(e, uid, "edited", "removeBg");
        } else if (
          Object.keys(e.model.dirtyFields).length === 1 &&
          Object.keys(e.model.dirtyFields)[0] === "sortRank"
        ) {
          this.handleChangeEditedBackgroundColor(e, uid, "edited", "removeBg");
        }
        // this.$nextTick(() => {
        //   this.gridData.updated();
        // });
        return;
      }
      if (
        Object.keys(e.model.dirtyFields).length === 1 &&
        Object.keys(e.model.dirtyFields)[0] === "sortRank"
      ) {
        this.isNotChanged = !this.gridData?.hasChanges();
        return;
      }
      this.handleChangeEditedBackgroundColor(e, uid, "edited", "addBg");
    },
    judgeNewRowRequiredFields(newRowItem) {
      const dataTemp = _.cloneDeep(this.gridData.data().toJSON());
      const nonDeletedData = dataTemp.filter((item) => {
        return (
          item.isDisp === "1" &&
          (item.hasOwnProperty("isDel") ? item.isDel === "0" : true) &&
          item.code !== newRowItem.code
        );
      });
      let sortTemp = 0;
      if (nonDeletedData.length > 0) {
        let { sortRank } = _.maxBy(nonDeletedData, "sortRank");
        sortTemp = sortRank;
      }
      this.$nextTick(() => {
        let allRequiredFieldsEdited = this.requiredFields.every(
          (item) => !isEmpty(newRowItem[item])
        );
        if (allRequiredFieldsEdited) {
          newRowItem.set("sortRank", ++sortTemp);
        }
      });
    },
    async onSaveChanges() {
      let grid = this.$refs.grid.kendoWidget();
      if (!this.kendoValidator.validate()) {
        return;
      }
      this.saveFlg = true;
      this.scrollRestored = false;
      //イベント発生前のスクロールバーの位置を保持
      const scrollTop = document.getElementsByClassName('k-scrollbar k-scrollbar-vertical')[0].scrollTop;
      const scrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft;
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      this.handleValidate(async () => {
        // MstValidateMixins
        await this.handleUpdateRecordList().then(() => {
          grid.saveChanges();
          this.isNotChanged = true;
          this.getRecordDataList();
          // this.$nextTick(() => {
          //   this.originalDataSource = _.cloneDeep(this.gridData.data());
          // });
        });
      });
    },
    async handleUpdateRecordList() {
      this.setLoadingScreenMessage("処理中・・・");
      this.setLoadingScreenVisible(true);

      let data = _.cloneDeep(this.gridData.data());
      data.forEach(item => {
        if (item.dirty) {
          if (item.isImport || item.isNew()) {
            item.set("operation", 1);
            delete item.isImport;
          } else {
            item.set("operation", 2);
          }
        }
        // add #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng start
        if (this.masterPhysicalName === "mst_taboo_allergy" && (item.detailInfo === "" || item.detailInfo == null)) {
          item.detailInfo = "[]";
        }
        // add #11559 禁忌・アレルギーマスタで詳細の登録が行われていないと患者経過総合ビューアで医材のマスタが表示されなくなる linjunfeng end
        if (this.masterPhysicalName === "mst_favorite_facility") {
          const keys = [
            "code",
            "favoriteFacilityCd",
            "medicalInstitutionCd",
            "sortRank",
            "sortInputTime",
            "isDisp",
            "operation",
          ];
          Object.keys(item).forEach(key => {
            if (!keys.includes(key)) {
              delete item[key];
            }
          });
        }
      });
      data = data.toJSON();
      const tasks = [];
      if ([
        "mst_mainte_detail",
        "mst_mainte_category",
        "mst_mainte_layout",
        "mst_mainte_layout_group",
      ].includes(this.masterPhysicalName)) {
        tasks.push(deleteDataProcessing(
          this.facilityCd,
          this.masterPhysicalName,
          data
        ));
      }
      tasks.push(new Promise((resolve, reject) => {
        sendRequestUpdateRecordListByFacilityCd(
          this.masterPhysicalName,
          this.facilityCd,
          data
        ).then(response => {
          if (this.masterPhysicalName === "mst_exam_item") {
            this.masterSynchroOrder(); // MstExamItemMixins
          } else {
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES[12000004].title,
              message: messageFormat(DIALOG_MESSAGES[12000004].message),
            });
          }
          resolve(response);
        }).catch(error => {
          getErrorMessage(
            "MasterRecordVirtualScrollableComponent.vue",
            "handleUpdateRecordList",
            error
          );
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              title: DIALOG_MESSAGES["00300005"].title,
              message: error.response.data.errorMessage,
            });
          }
          reject(error);
        });
      }));
      await Promise.all(tasks).finally(() => {
        this.setLoadingScreenVisible(false);
      });
    },
    onDataBound(e) {
      if (!this.scrollRestored && (this.scrollPosition.top > 0 || this.scrollPosition.left > 0)) {
        //保存ボタン押下イベント以外の場合、フラグを更新する
        if(!this.saveFlg){
          this.scrollRestored = true;
        }
        //スクロールバーの位置をイベント発生前の位置に戻す
        this.$nextTick(() => {
          e.sender.content[0].lastChild.scrollTop = this.scrollPosition.top;
          e.sender.content[0].firstChild.scrollLeft = this.scrollPosition.left;
        });
      }
      this.$nextTick(() => {
        let deletedRows = [];
        let editedRows = [];
        e.sender.dataItems().forEach((item) => {
          if (item.dirty) {
            item.dirty && editedRows.push(item);
          } else if (item.isDisp === "0") {
            deletedRows.push(item);
          }
        });
        deletedRows.forEach((tr) => {
          this.handleChangeEditedBackgroundColor(e, tr.uid, "deleted", "addBg");
        });
        editedRows.forEach((tr) => {
          const dirtyFieldsKeys = Object.keys(tr.dirtyFields);
          if (
            dirtyFieldsKeys.length === 1 &&
            dirtyFieldsKeys[0] === "sortRank"
          ) {
            return;
          }
          this.handleChangeEditedBackgroundColor(e, tr.uid, "edited", "addBg");
        });

        const grid = this.$refs.grid?.kendoWidget?.();
        if (!grid || !grid.virtualScrollable) return;
        const wrapper = grid.wrapper?.[0];
        if (!wrapper) return;

        let startY = 0;
        let scrollStart = 0;
        let isVerticalScroll = false;

        wrapper.addEventListener('touchstart', (e) => {
          if (e.touches.length === 1) {
            startY = e.touches[0].clientY;
            scrollStart = grid.virtualScrollable.verticalScrollbar[0].scrollTop;
            isVerticalScroll = false;
          }
        }, { passive: true });

        wrapper.addEventListener('touchmove', (e) => {
          if (e.touches.length === 1) {
            const currentY = e.touches[0].clientY;
            const deltaY = startY - currentY;

            if (!isVerticalScroll && Math.abs(deltaY) > 10) {
              isVerticalScroll = true;
            }
            if (isVerticalScroll) {
              const newScrollTop = scrollStart + deltaY;
              requestAnimationFrame(() => {
                grid.virtualScrollable.verticalScrollbar[0].scrollTop = newScrollTop;
              });
              e.preventDefault(); // iOSでスクロールを有効にするために必要
            }
          }
        }, { passive: false });
      });
    },
    onCancel() {
      this.$router.go(-1);
    },
    /**
     * 編集行の背景色を変える
     * @param {*} e
     * @param {String} uid
     * @param {String} type new, edited, deleted
     * @param {String} operation  addBg, removeBg
     */
    handleChangeEditedBackgroundColor(e, uid, type, operation) {
      const el = e.sender.wrapper?.find('tr[data-uid="' + uid + '"]');
      el?.each((index, item) => {
        if (type === "deleted") {
          operation === "addBg"
            ? item.classList.add("deleted-bg")
            : item.classList.remove("deleted-bg");
        } else if (type === "edited" || type === "new") {
          operation === "addBg"
            ? item.classList.add("edited-bg")
            : item.classList.remove("edited-bg");
        }
      });
      this.isNotChanged = !this.gridData?.hasChanges();
    },
    generatedData() {
      var that = this;
      const rowHeight = this.$el.querySelector('.k-grid-content tr')?.clientHeight || 30;
      const gridHeight = this.$refs.grid?.$el?.offsetHeight || 900;
      const pageSize = Math.floor(gridHeight / rowHeight);
      // eslint-disable-next-line no-undef
      const dataSource = new kendo.data.DataSource({
        pageSize: pageSize,
        data: that.allGridData,
        schema: {
          model: {
            fields: that.gridSchemaModel,
            id: "code",
          },
        },
      });
      return dataSource;
    },
    getRecordDataList() {
      let getDataList = sendRequestFindRecordListByFacilityCd;
      if (this.masterPhysicalName === "mst_favorite_facility") {
        this.setLoadingScreenVisible(true);
        getDataList = sendRequestFindRecordListByFacilityCdWithSql;
      }
      getDataList(this.masterPhysicalName, this.facilityCd)
        .then((response) => {
          if (response.status === 200) {
            const localDataSource = response.data.localDataSource;
            this.gridColumns = this.handleFormatColumns(response.data.columns);
            this.allGridData = localDataSource.data.filter(item => (
              item.hasOwnProperty("isDel") ? item.isDel === "0" : true
            ));
            this.gridSchemaModel = this.handleFormatModel(
              localDataSource.schema.model.fields
            );
            this.gridData = this.generatedData();
            this.handleFilterByCondition(this.virtualCondition);
            this.$nextTick(() => {
              this.originalDataSource = _.cloneDeep(this.gridData.data());
            });
          }
        })
        .catch((error) => {
          getErrorMessage(
            "MasterRecordVirtualScrollableComponent.vue",
            "getRecordDataList",
            error
          );
        })
        .finally(() => {
          this.masterPhysicalName === "mst_favorite_facility" &&
            this.setLoadingScreenVisible(false);
        });
    },
    handleFormatColumns(columns) {
      const fieldsMap = new Map();
      columns.forEach((col) => {
        col.neverEditable = !col.editable;
        col.isEditable = col.editable;
        col.editable = () => col.isEditable;
        col.width = emToPx(
          ColumnWidthMap.get(this.masterPhysicalName) || 14,
          this.fontSize
        );
        if (col.field === "allowAddRecord") {
          this.isAllowAddRecord = true;
        }
        if (col.field === "allowSort") {
          this.isAllowSort = true;
        }
        if (col.field === "sortRank") {
          col.template = ({ sortRank }) => {
            return `${this.isSortMode ? (sortRank ? sortRank : "") : ""}`;
          };
          col.width = this.isSortMode
            ? emToPx(9, this.fontSize)
            : emToPx(1, this.fontSize);
          col.editable = () => this.isSortMode;
          col.title = this.isSortMode ? col.title : "&nbsp;";
          col.neverEditable = false;
        }
        if (col.dataType === "modal") {
          const titleForBtnTextContrast = {
            詳細: {
              text: "詳細",
              width: 7,
            },
            デフォルト権限設定: {
              text: "権限設定",
              width: 13,
            },
            デフォルトメニュー設定: {
              text: "機能設定",
              width: 13,
            },
            施設選択: {
              text: "変更",
              width: 7,
            },
            デフォルト表示設定: {
              text: "表示設定",
              width: 13,
            },
            デフォルト通知設定: {
              text: "通知設定",
              width: 13,
            },
          };
          col.width = emToPx(
            titleForBtnTextContrast[col.title].width,
            this.fontSize
          );
          col.command = {
            text: titleForBtnTextContrast[col.title].text,
            click: (e) => this.showEditModal(e, col.title),
            className: "detail-btn",
          };
        }
        if (col.field === "isDisp") {
          col.width = emToPx(7, this.fontSize);
        }
        if (!col.hidden && col.title) {
          fieldsMap.set(col.field, col.title);
        }
        if (col.dataType === "date") {
          col.editor = (container, data) =>
            this.eachModelCalendar(container, data);
        }
        if (col.field === "mainteContent3") {
          col.editor = (container, data) => {
            if (
              this.masterPhysicalName == "mst_mainte_detail" &&
              (!data.model.mainteClass || data.model.mainteClass === "1")
            ) {
              container.text(data.model[data.field] || '');
            } else {
              $(
                `<input type="text" name="${data.field}" class="k-input k-textbox k-valid"/>`
              ).appendTo(container);
            }
          };
        }
        if (
          this.masterPhysicalName == "mst_mainte_detail"
          && col.field === "iniText"
        ) {
          // 点検項目マスタの初期展開テキストの場合
          col.editor = (container, data) => {
            if (data.model.isCmt === "1") {
              // 補足コメント有無がコメント要の場合はテキスト入力可能とする
              $(
                `<input type="text" name="${data.field}" class="k-input k-textbox k-valid"/>`
              ).appendTo(container);
            } else {
              container.text(data.model[data.field] || "");
            }
          };
        }
        if (col.dataType === "textarea") {
          col.editor = (container, data) => {
            $(
              `<textarea name="${data.field}" class="k-valid k-textarea resize-obs-target" style="font-size: 1.0em; width:100%; resize: vertical; max-height: 65vh;"/>`
            ).appendTo(container);
          };
        }
      });
      this.setColumns(columns);
      columns = columns.filter((col) => {
        return col.hidden === false;
      });
      this.fieldsMap = fieldsMap;
      return columns;
    },
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
        if (!editedData) {
          nowDtatString = "";
        }
        $(
          `<span style="position:relative"><input type="date" style="width:8em" id="displayedDummyEditor" class="ntss-input-date" min="1880-01-01" max="2099-12-31" value="${nowDtatString}"/><input type="date" id="hiddenDateInputEditor" name="${data.field}" style="display: none;"/><span id="clear" class="k-icon k-i-close close-btn" title="clear" style="position:absolute;left:75%;top:1px;color: #212529;z-index:9999999" ></span></span>`
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
          $(document.getElementById("hiddenDateInputEditor")).trigger("change");
          this.$refs.grid.kendoWidget().closeCell();
        });
        commonCalenderPicker.$mount();
        commonCalenderPicker.setSilently(nowDtatString);
        container.append(commonCalenderPicker.$el);
        const userAgent = window.navigator.userAgent;
        if (userAgent.indexOf("Intel Mac OS") > -1) {
          document
            .getElementById("displayedDummyEditor")
            .addEventListener("change", (ev) => {
              document.getElementById("hiddenDateInputEditor").value =
                ev.target.value;
              $(document.getElementById("hiddenDateInputEditor")).trigger(
                "change"
              );
            });
        } else {
          document
            .getElementById("displayedDummyEditor")
            .addEventListener("change", (ev) => {
              commonCalenderPicker.setSilently(ev.target.value);
            });
          document
            .getElementById("clear")
            .addEventListener("mousedown", function () {
              document.getElementById("hiddenDateInputEditor").value = null;
              $(document.getElementById("hiddenDateInputEditor")).trigger(
                "change"
              );
            });
          document
            .getElementById("clear")
            .addEventListener("touchstart", function () {
              document.getElementById("hiddenDateInputEditor").value = null;
              $(document.getElementById("hiddenDateInputEditor")).trigger(
                "change"
              );
            });
        }
      }
    },
    handleFormatModel(fields) {
      const getTitleText = (fieldName) => {
        const item = this.gridColumns.find((col) => {
          return col.field === fieldName;
        });
        if (item) {
          return item.title;
        }
        return "";
      };
      const requiredFields = [];
      Object.keys(fields).forEach((key) => {
        if (fields[key]?.validation?.required) {
          fields[key].validation.validationMessage = `${getTitleText(
            key
          )}は必須入力です。`;
          if (this.fieldsMap.get(key)) {
            requiredFields.push(key);
          }
        }
        if (key === "isDel") {
          fields[key].defaultValue = "0";
        }
        if (fields[key]?.type === "date") {
          fields[key].defaultValue = "";
        }
      });
      if (this.masterPhysicalName === "mst_exam_item") {
        fields.normalValueClass.defaultValue = "0"; // 正常値区分
        fields.examClass.defaultValue = "0"; // 検査使用区分
        fields.dataType.defaultValue = "1"; // データ形式
      }
      this.requiredFields = requiredFields;
      return fields;
    },
    handleToggleSortMode() {
      const grid = this.$refs.grid.kendoWidget();
      const take = this.gridData.take();
      const currentRangeStart = this.gridData._currentRangeStart;
      const scrollTop = grid.virtualScrollable._scrollTop;
      const top = grid.virtualScrollable.verticalScrollbar[0].scrollTop;
      this.isSortMode = !this.isSortMode;
      this.gridColumns = this.gridColumns.map((column) => {
        if (column.field === "$modalType") {
          column.command.disabled = this.isSortMode;
        }
        if (column.field === "sortRank") {
          column.width = this.isSortMode
            ? emToPx(9, this.fontSize)
            : emToPx(1, this.fontSize);
          column.editable = () => this.isSortMode;
          column.title = this.isSortMode ? "並び順" : "&nbsp;";
          column.template = ({ sortRank }) => {
            return `${this.isSortMode ? ((sortRank || sortRank === 0) ? sortRank : "") : ""}`;
          };
        } else {
          column.editable = () => {
            if (column.neverEditable) {
              return false;
            } else {
              return !this.isSortMode;
            }
          };
        }
        return column;
      });
      // mod #10072 病名マスタの並び順修正 fang start
      // パフォーマンス最適化: originalDataSource を Map 化して O(n²) → O(n) に改善
      const originalMap = new Map(
        this.originalDataSource.map((i) => [i.uid, i])
      );

      const dataSource = this.gridData;

      // イベント通知を一時停止してバッチ更新を行う
      dataSource.unbind("change");

      dataSource.data()?.sort((a, b) => {
        return a.sortRank - b.sortRank || a.sortInputTime - b.sortInputTime;
      });

      dataSource.data()?.forEach((item, index) => {
        if (item.isDisp === "1") {
          const newRank = index + 1;
          // item.set() の代わりに直接プロパティを更新してイベント発火を抑制
          item.sortRank = newRank;
          if (item.dirty && item.dirtyFields.sortRank) {
            const originalItem = originalMap.get(item.uid);
            if (originalItem && newRank === originalItem.sortRank) {
              delete item.dirtyFields.sortRank;
              delete item.dirtyFields.dirty;
              if (Object.keys(item.dirtyFields).length === 0) {
                item.dirty = false;
                delete item.dirtyFields.dirty;
              }
            }
          } else {
            delete item.dirtyFields.sortRank;
            delete item.dirtyFields.dirty;
            if (Object.keys(item.dirtyFields).length === 0) {
              item.dirty = false;
            }
          }
        }
      });

      // イベント通知を再開し、一度だけ change を発火
      dataSource.bind("change");
      dataSource.trigger("change");

      this.keys++;
      // mod #10072 病名マスタの並び順修正 fang end
      this.isNotChanged = !this.gridData?.hasChanges();
      this.$nextTick(() => {
        this.gridData.range(currentRangeStart, take, () => {
          this.$refs.grid.kendoWidget().virtualScrollable._scrollTo(scrollTop);
        });
        this.$refs.grid.kendoWidget().virtualScrollable.verticalScrollbar[0].scrollTop =
          top;
      });
    },
    handleFilterByCondition(condition) {
      let { value, fields, includeDeleted } = condition;
      const filters = [];
      if (!includeDeleted) {
        filters.push({
          logic: "or",
          filters: [
            {
              logic: "and",
              filters: [
                {
                  field: "isDisp",
                  operator: "eq",
                  value: "1",
                },
              ],
            },
            {
              field: "dirty",
              operator: "eq",
              value: true,
            },
          ],
        });
        if (
          !["mst_job", "mst_favorite_facility"].includes(
            this.masterPhysicalName
          )
        ) {
          filters[0].filters[0].filters.push({
            field: "isDel",
            operator: "eq",
            value: "0",
          });
        }
      }
      let fieldFilterList = [];
      if (fields?.length === 0) {
        fields = ["name"];
      }
      fields?.forEach((field) => {
        fieldFilterList.push({
          field: field,
          operator: "contains",
          value: value,
        });
      });
      fieldFilterList.push({
        field: "dirty",
        operator: "eq",
        value: true,
      });
      value &&
        filters.push({
          name: "condition",
          logic: "or",
          filters: fieldFilterList,
        });
      this.gridData?.filter({
        logic: "and",
        filters: filters,
      });
      this.$refs.grid.kendoWidget().virtualScrollable.scrollToTop();
    },
    showEditModal(e, title) {
      this.scrollRestored = false;
　　　//イベント発生前のスクロールバーの位置を保持
      const scrollTop = document.getElementsByClassName('k-scrollbar k-scrollbar-vertical')[0].scrollTop;
      const scrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft;
      this.scrollPosition.top = scrollTop;
      this.scrollPosition.left = scrollLeft;
      e.preventDefault();
      const grid = this.$refs.grid.kendoWidget();
      const dataItem = grid.dataItem(e.currentTarget.closest("tr"));
      if (
        this.masterPhysicalName === "mst_medicine" &&
        (dataItem.isNew() || dataItem.isImport)
      ) {
        dataItem.set(
          "medicateTimingCd",
          dataItem.medicateTimingCd || (this.DEFAULT_MEDICATE_TIMING === '-1' ? '' : this.DEFAULT_MEDICATE_TIMING)
        );
        dataItem.set(
          "procedureCd",
          dataItem.procedureCd || (this.DEFAULT_PROCEDURE === '-1' ? '' : this.DEFAULT_PROCEDURE)
        );
      }
      if (["mst_taboo_allergy"].includes(this.masterPhysicalName)) {
        this.setSchemaModel(this.gridSchemaModel);
      }
      if (
        ["mst_exam_item", "mst_favorite_facility"].includes(
          this.masterPhysicalName
        )
      ) {
        this.setGridData(_.cloneDeep(this.gridData.data().toJSON()));
      }
      this.setEditRecord(dataItem);
      if (title === "デフォルト権限設定") {
        this.showJobMasterEditAuthority();
      }
      if (title === "施設選択") {
        this.showMstFavoriteFacilityModal();
      }
      if (["詳細", "デフォルトメニュー設定"].includes(title)) {
        this.showMasterEdit();
      }
      if (title === "デフォルト表示設定") {
        this.showMstJobEditDefaultSettingModal();
      }
      if (title === "デフォルト通知設定") {
        this.showMstJobEditNotificationSettingModal();
      }
    },
    onClickBreadcrumb() {
      if (this.isChanged) {
        this.$ons.notification.confirm({
          title: DIALOG_MESSAGES[13000004].title,
          message: messageFormat(DIALOG_MESSAGES[13000004].message),
          callback: (answer) => {
            if (answer) {
              this.getRecordDataList();
            }
          },
        });
        return;
      }
      this.getRecordDataList();
    },
    getMstFacilitySetting() {
      const contrast = {
        mst_job: {
          permissiones: {
            PERMISSION_CHANGE_SIGNOUT: PERMISSION_CHANGE_SIGNOUT
          },
          isBoolean: true,
        },
        mst_medicine_mix: {
          permissiones: {
            DEFAULT_MEDICATE_TIMING: DEFAULT_MEDICATE_TIMING,
            DEFAULT_PROCEDURE: DEFAULT_PROCEDURE
          },
        },
        mst_medicine: {
          permissiones: {
            DEFAULT_MEDICATE_TIMING: DEFAULT_MEDICATE_TIMING,
            DEFAULT_PROCEDURE: DEFAULT_PROCEDURE
          },
        }
      };
      const permissionesObj = contrast[this.masterPhysicalName]?.permissiones;
      Object.keys(permissionesObj).forEach((key) => {
        sendRequestGetMstFacilitySettingValue(this.facilityCd, permissionesObj[key]).then(
          (response) => {
            this[key] = contrast[this.masterPhysicalName]
              .isBoolean
              ? response.data === 1
              : response.data;
          }
        );
      });
    },
    initZoomObserver() {
      const target = this.$el.querySelector('.grid-content');
      if (!target || typeof ResizeObserver === 'undefined') return;

      this.zoomObserver = new ResizeObserver(() => {
        const grid = this.$refs.grid?.kendoWidget?.();
        if (grid?.virtualScrollable) {
          const dirtyItemsMap = new Map();
          if (!this.gridData || !this.gridData.data) return;
          this.gridData.data().forEach(item => {
            if (item.dirty) {
              dirtyItemsMap.set(item.code, item.toJSON());
            }
          });

          const newDataSource = this.generatedData();
          grid.setDataSource(newDataSource);
          this.gridData = newDataSource;

          // 復元処理
          this.gridData.data().forEach(item => {
            const saved = dirtyItemsMap.get(item.code);
            if (saved) {
              item.dirtyFields = {};
              Object.keys(saved).forEach(key => {
                item.set(key, saved[key]);
              });
              item.set("dirty", true);
              item.dirtyFields = saved.dirtyFields || {};
            }
          });

          this.handleFilterByCondition(this.virtualCondition);

          grid.refresh();
          grid.virtualScrollable.refresh();
          grid._resize(30, true);
        }
      });

      this.zoomObserver.observe(target);
    },
  },
  created() {
    this.findColumnInfo();
    this.getRecordDataList();
    if (["mst_job", "mst_medicine", "mst_medicine_mix"].includes(this.masterPhysicalName)) {
      this.getMstFacilitySetting();
    }
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
  },
  updated() {
    //updatedが2回目に呼ばれた場合
    if(this.updatedFlg){
      this.updatedFlg = false;
      this.saveFlg = false;
      this.scrollRestored = true;
    }
    //updatedが最初に呼ばれた場合
    if(this.saveFlg){
      this.updatedFlg = true;
    }
  },
  mounted() {
    EventBus.$on("refresh", this.onClickBreadcrumb);
    this.initZoomObserver();
  },
  beforeDestroy() {
    this.setVirtualCondition({
      fields: [],
      includeDeleted: false,
      value: "",
    });
    EventBus.$off("refresh", this.onClickBreadcrumb);
    if (this.zoomObserver) {
      this.zoomObserver.disconnect();
    }
  },
  watch: {
    masterPhysicalName: {
      handler(val) {
        this.isAddButton = ![
          "sys_medicine",
          "mst_take_medicine",
          "mst_vital_graph",
        ].includes(val);
      },
      immediate: true,
    },
    virtualCondition: {
      handler(condition) {
        this.handleFilterByCondition(condition);
      },
      deep: true,
    },
    editedRowItem: {
      handler(val) {
        if (val && Object.keys(val).length) {
          if (this.masterPhysicalName === "mst_exam_item") {
            this.gridData.data().forEach((item) => {
              if (item.infectionCd && item.infectionCd == val.infectionCd && item.code !== val.code) {
                item.set("infectionCd", null);
              }
            })
          }
          const currentItem = this.gridData.getByUid(val.uid);
          const diff = diffObj(currentItem.toJSON(), val.toJSON());
          Object.keys(val).forEach((key) => {
            if (Object.keys(diff).includes(key)) {
              currentItem.set(key, val[key]);
            }
          });
          if (val.isNew() && val.sortRank === 0) {
            this.judgeNewRowRequiredFields(val);
          }
        }
      },
      deep: true,
    },
    windowWidth() {
      this.$refs.grid.kendoWidget().refresh();
      this.$refs.grid.kendoWidget().virtualScrollable.refresh();
    },
    windowHeight() {
      this.$refs.grid.kendoWidget().refresh();
      this.$refs.grid.kendoWidget().virtualScrollable.refresh();
    },
    fontSize: {
      handler(newVal, oldVal) {
        this.gridColumns.forEach((column, index) => {
          if (column.width) {
            column.width = pxForFontSize(column.width, oldVal, newVal);
            this.$refs.grid
              .kendoWidget()
              .resizeColumn(
                this.$refs.grid.kendoWidget().columns[index],
                parseFloat(column.width)
              );
          }
        });
        const isScrollBottom = this.$refs.grid
          .kendoWidget()
          .virtualScrollable._isScrolledToBottom();

        this.$refs.grid.kendoWidget().refresh();
        this.$refs.grid.kendoWidget().virtualScrollable.refresh();
        if (isScrollBottom) {
          this.$nextTick(() => {
            this.$refs.grid.kendoWidget().virtualScrollable.scrollToBottom();
          });
        }
      },
    },
    showSidebarFlg() {
      this.$refs.grid.kendoWidget().refresh();
      this.$refs.grid.kendoWidget().virtualScrollable.refresh();
    },
    mstFavoriteFacilityAddRows: {
      handler(val) {
        if (val?.length) {
          this.getCsvData(val);
        }
      },
      deep: true,
    },
  },
};
</script>

<style scoped lang="scss">
* {
  box-sizing: border-box;
}
.virtual-container {
  height: 100%;
  padding: 0 5px;
}
.grid-content {
  height: calc(100% - 5.4em);
}
.tool-bar {
  display: flex;
  flex-direction: row;
  justify-content: space-between;
  padding: 0.2em 0;
}
.re-calculation-btn {
  margin-left: 10px;
}
.sort-mode {
  justify-content: flex-end;
  &.sort-mode-exam-item{
    justify-content: space-between;
  }
}
.tool-bar-right {
  align-self: flex-end;
}
.toolbar-btn {
  font-size: 1em;
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}
.right10 {
  margin-right: 10px;
}
.footer {
  margin: 0.5em 0;
  display: flex;
  flex-direction: row;
  justify-content: space-between;
}
::v-deep .k-widget {
  border-width: 0 1px !important;
}
::v-deep .k-grid tr {
  td {
    border-width: 0 0 0 1px !important;
  }
}
::v-deep .edited-bg {
  color: #003300;
  td {
    background-color: #ccffcc !important;
    &[data-field="sortRank"] {
      background-color: unset !important;
      .k-dirty {
        border-width: 0;
      }
    }
  }
}
::v-deep td.k-dirty-cell {
  font-weight: bold;
  &[data-field="sortRank"] {
    background-color: #ffff66 !important;
    .k-dirty {
      border-width: 0;
    }
  }
}
::v-deep .sort-mode td.k-dirty-cell {
  &[data-field="sortRank"] {
    .k-dirty {
      border-width: 5px;
    }
  }
}
::v-deep .deleted-bg {
  color: #050505 !important;
  background-color: #aaaaaa !important;
  &:hover {
    background-color: #aaaaaa;
  }
}
::v-deep .detail-btn {
  color: #ffffff !important;
  background-color: var(--btn3-normal-color);
  background-image: linear-gradient(
    var(--btn3-normal-color),
    var(--btn3-normal-color)
  ) !important;
  border-bottom: solid 3px var(--btn-common-border-color) !important;
  box-shadow: unset;
}
// ::v-deep .sort-edited-cell {
//   background-color: #ffff66 !important;
// }
::v-deep .k-tooltip.k-tooltip-validation {
  width: auto;
}

::v-deep
  .k-grid
  tr:nth-child(n + 3):last-child
  .k-tooltip.k-tooltip-validation {
  bottom: 38px;
}

::v-deep .k-grid tr:nth-last-child(2) .k-tooltip.k-tooltip-validation {
  bottom: 38px;
}

::v-deep .k-edit-cell {
  position: relative;
  overflow: visible;
}

::v-deep .k-grid-content,
::v-deep .k-grid-content-locked,
::v-deep .k-pager-wrap {
  white-space: nowrap;
}

::v-deep
  .k-grid
  tr:nth-child(n + 3):last-child
  .k-tooltip.k-tooltip-validation
  .k-callout {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}

::v-deep
  .k-grid
  tr:nth-last-child(2)
  .k-tooltip.k-tooltip-validation
  .k-callout {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}

::v-deep .k-grid-edit-row {
  .k-button,
  .k-textbox,
  .k-input.k-textbox {
    height: 2em;
  }
  .k-widget {
    white-space: normal;
  }
  td {
    text-overflow: ellipsis;
  }
}

.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
::v-deep .k-grid-content,
::v-deep .k-grid-content-locked {
  touch-action: manipulation !important;
  -webkit-overflow-scrolling: touch !important;
}
.mobile-header {
  min-height: 30px; /* モバイル用の高さ */
}
</style>
