// 再検査計算予約
<template>
  <modal-base @onClose="showMstExamItemRecManagementModal">
    <template #body>
      <div class="modal-body-content">
        <div class="date-content">
          <label>対象期間</label>
          <div>
            <date-input
              v-model="startDate"
              @handleClearInput="startDate = '';"
            />
            <common-calendar
              v-model="startDate"
              :disableDatesAfter="maxDate"
              class="calender"
            />
          </div>
          <span>～</span>
          <div>
            <date-input
              v-model="endDate"
              @handleClearInput="endDate = '';"
            />
            <common-calendar
              v-model="endDate"
              :disableDatesBefore="minDate"
              class="calender"
            />
          </div>
        </div>
        <div class="table-content">
          <div class="table-content-left">
            <label>対象患者</label>
            <div
              id="leftGrid"
              ref="leftGrid"
              class="ntss-kendo-grid-legacy mst-exam-item-rec-booking-direct-jq-grid"
            ></div>
          </div>
          <div class="table-content-right">
            <label>対象検査計算項目</label>
            <div
              id="rightGrid"
              ref="rightGrid"
              class="ntss-kendo-grid-legacy mst-exam-item-rec-booking-direct-jq-grid"
            ></div>
          </div>
        </div>
      </div>
    </template>
    <template #footer>
      <div class="flex-container">
        <v-ons-button class="btn2-cancel denial-btn" @click="showMstExamItemRecManagementModal">
          キャンセル
        </v-ons-button>
        <v-ons-button
          class="btn1-execute registration-btn"
          :disabled="saveBtnDisabled"
          @click="handleSave"
        >
          保存
        </v-ons-button>
      </div>
    </template>
  </modal-base>
</template>
<script>
import dayjs from "@/compat/date/dayjs";
import { createApp, markRaw } from "@/compat/vue/runtime";
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapState, mapActions } from "@/compat/vue/vuex";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import ModalBase from "@/components/modals/ModalBase";
import DateInput from "@/components/common/DateInput";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import RadioGroup from "./RadioGroup";
import PatNameCell from './PatNameCell';
import VueOnsenBridge from "@/compat/onsen/components";
import kendo from "@progress/kendo-ui";
import $ from "jquery";

function installComponentJQuery() {
  if (typeof window !== "undefined") {
    window.$ = window.$ || $;
    window.jQuery = window.jQuery || $;
  }
  if (typeof globalThis !== "undefined") {
    globalThis.$ = globalThis.$ || $;
    globalThis.jQuery = globalThis.jQuery || $;
  }
}

function createCellApp(component, templateArgs) {
  const app = createApp({
    extends: component,
    data() {
      const originalData = typeof component.data === "function" ? component.data.call(this) : {};
      return {
        ...originalData,
        templateArgs
      };
    }
  });
  app.use(VueOnsenBridge);
  return app;
}
export default {
  name: "MstExamItemRecBookingModal",
  components: {
    "modal-base": ModalBase,
    "date-input": DateInput,
    "common-calendar": commonCalender,
  },
  watch: {
    startDate() {
      this.getPatListByFacilityCd();
    },
    endDate() {
      this.getPatListByFacilityCd();
    },
    windowWidth () {
      this.refreshDirectBookingGrids();
    },
    windowHeight () {
      this.refreshDirectBookingGrids();
    },
    fontSize () {
      this.refreshDirectBookingGrids();
    }
  },
  data() {
    return {
      startDate: '',
      endDate: '',
      leftDataSource: [],
      rightDataSource: [],
      hasSelectedItem: false,
      gridKey: 0,
      leftGridWidget: null,
      rightGridWidget: null,
      leftGridDataSource: null,
      rightGridDataSource: null,
      directGridLayoutRafIds: markRaw({ left: null, right: null }),
      directCellApps: markRaw([])
    };
  },
  computed: {
    ...mapState("user", ["facilityCd"]),
    ...mapState("account-edit", ["userAccountInfo", "fontSize"]),
    ...mapState("window-size", ["windowWidth", "windowHeight"]),
    saveBtnDisabled () {
      return !(this.hasSelectedItem && (!!this.startDate || !!this.endDate));
    },
    maxDate () {
      return this.endDate ? dayjs(this.endDate).format('YYYYMMDD') : '';
    },
    minDate () {
      return this.startDate ? dayjs(this.startDate).format('YYYYMMDD') : '';
    },
  },
  methods: {
    ...mapActions("multi-modal", ["hideModal", "showMstExamItemRecManagementModal"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible", "setLoadingScreenMessage"]),
    getGridRoot(gridName) {
      return this.$refs[gridName] || null;
    },
    getGridWidget(gridName) {
      return gridName === "leftGrid" ? this.leftGridWidget : this.rightGridWidget;
    },
    getGridData(gridName) {
      return gridName === "leftGrid"
        ? (Array.isArray(this.leftDataSource) ? this.leftDataSource : [])
        : (Array.isArray(this.rightDataSource) ? this.rightDataSource : []);
    },
    createDirectGridDataSource(gridName) {
      const idField = gridName === "leftGrid" ? "pat_id" : "examItemCd";
      const dataSource = markRaw(new kendo.data.DataSource({
        data: this.getGridData(gridName),
        schema: {
          model: {
            id: idField
          }
        }
      }));
      if (gridName === "leftGrid") {
        this.leftGridDataSource = dataSource;
      } else {
        this.rightGridDataSource = dataSource;
      }
      return dataSource;
    },
    buildDirectGridColumns(gridName) {
      if (gridName === "leftGrid") {
        return [
          { selectable: true, width: "3em" },
          { field: "hosp_pat_id", title: "患者ID", width: "12em" },
          {
            title: "患者名",
            width: "12em",
            template: dataItem => `<span class="direct-cell-host direct-pat-name-cell" data-grid="leftGrid" data-uid="${dataItem.uid || ""}"></span>`
          }
        ];
      }
      return [
        { selectable: true, width: "3em" },
        { field: "examItemName", title: "検査計算項目名", width: "12em" },
        {
          title: "既存結果への上書き",
          width: "12em",
          template: dataItem => `<span class="direct-cell-host direct-radio-cell" data-grid="rightGrid" data-uid="${dataItem.uid || ""}"></span>`
        }
      ];
    },
    initDirectGrid(gridName) {
      const root = this.getGridRoot(gridName);
      if (!root) {
        return;
      }
      const existingGrid = this.getGridWidget(gridName);
      if (existingGrid) {
        this.refreshDirectGridDataSource(gridName);
        return;
      }
      installComponentJQuery();
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.createDirectGridDataSource(gridName),
        height: "100%",
        // 复选框列由 _checkBoxSelection 处理；行级 selectable 会导致点击行时清空其它已选
        selectable: false,
        persistSelection: true,
        columns: this.buildDirectGridColumns(gridName),
        change: () => {
          this.$nextTick(() => this.handleChange());
        },
        dataBound: () => {
          this.installDirectGridFacade(gridName);
          this.mountDirectCellTemplates(gridName);
          this.applyDirectGridStyleContract(gridName);
          this.bindDirectGridSelectionBehavior(gridName);
          this.scheduleDirectGridLayoutContract(gridName);
        }
      });
      const widget = markRaw($(root).data("kendoGrid"));
      if (gridName === "leftGrid") {
        this.leftGridWidget = widget;
      } else {
        this.rightGridWidget = widget;
      }
      this.installDirectGridFacade(gridName);
      this.applyDirectGridStyleContract(gridName);
    },
    destroyDirectGrid(gridName) {
      this.unbindDirectGridSelectionBehavior(gridName);
      const grid = this.getGridWidget(gridName);
      if (grid) {
        try {
          grid.destroy();
        } catch (_error) {
          // noop
        }
      }
      const root = this.getGridRoot(gridName);
      if (root) {
        $(root).empty();
      }
      if (gridName === "leftGrid") {
        this.leftGridWidget = null;
        this.leftGridDataSource = null;
      } else {
        this.rightGridWidget = null;
        this.rightGridDataSource = null;
      }
    },
    destroyDirectCellApps(gridName = null) {
      const rest = [];
      this.directCellApps.forEach(entry => {
        if (!gridName || entry.gridName === gridName) {
          try {
            entry.app.unmount();
          } catch (_error) {
            // noop
          }
        } else {
          rest.push(entry);
        }
      });
      this.directCellApps = markRaw(rest);
    },
    installDirectGridFacade(gridName) {
      const root = this.getGridRoot(gridName);
      if (!root) {
        return;
      }
      root.kendoWidget = () => this.getGridWidget(gridName);
      root.gridWidget = () => this.getGridWidget(gridName);
      root.gridRootEl = () => root;
      root.clearGridSelection = () => this.getGridWidget(gridName)?.clearSelection?.();
    },
    refreshDirectGridDataSource(gridName) {
      const grid = this.getGridWidget(gridName);
      if (!grid?.dataSource) {
        this.$nextTick(() => this.initDirectGrid(gridName));
        return;
      }
      grid.dataSource.data(this.getGridData(gridName));
      this.scheduleDirectGridLayoutContract(gridName);
    },
    refreshDirectBookingGrids() {
      ["leftGrid", "rightGrid"].forEach(gridName => {
        const grid = this.getGridWidget(gridName);
        if (grid) {
          grid.refresh?.();
          grid.resize?.(true);
          this.scheduleDirectGridLayoutContract(gridName);
        }
      });
    },
    mountDirectCellTemplates(gridName) {
      this.destroyDirectCellApps(gridName);
      const grid = this.getGridWidget(gridName);
      const root = this.getGridRoot(gridName);
      if (!grid || !root) {
        return;
      }
      const selector = gridName === "leftGrid" ? ".direct-pat-name-cell" : ".direct-radio-cell";
      root.querySelectorAll(selector).forEach(host => {
        const row = host.closest("tr");
        const item = grid.dataItem(row);
        if (!item) {
          return;
        }
        const component = gridName === "leftGrid" ? PatNameCell : RadioGroup;
        const app = createCellApp(component, {
          parentComponent: this,
          item
        });
        app.config.globalProperties.$ons = this.$ons;
        app.mount(host);
        this.directCellApps.push({ gridName, app });
      });
    },
    applyDirectGridStyleContract(gridName) {
      const root = this.getGridRoot(gridName);
      if (!root) {
        return;
      }
      root.classList.add("ntss-kendo-grid-legacy", "k-widget", "k-grid", "k-display-block");
      root.querySelectorAll(".k-grid-header th, .k-grid-header .k-table-th").forEach(cell => {
        cell.classList.add("k-header");
      });
      root.querySelectorAll(".k-grid-content tbody").forEach(tbody => {
        Array.from(tbody.querySelectorAll("tr")).forEach((row, index) => {
          row.classList.add("k-master-row");
          row.classList.toggle("k-alt", index % 2 === 1);
        });
      });
      root.querySelectorAll(".k-grid-content tbody td").forEach(cell => {
        cell.classList.add("k-td", "k-table-td");
      });
    },
    scheduleDirectGridLayoutContract(gridName) {
      const key = gridName === "leftGrid" ? "left" : "right";
      if (this.directGridLayoutRafIds[key] != null) {
        cancelAnimationFrame(this.directGridLayoutRafIds[key]);
      }
      this.directGridLayoutRafIds[key] = requestAnimationFrame(() => {
        this.directGridLayoutRafIds[key] = null;
        const grid = this.getGridWidget(gridName);
        grid?.resize?.(true);
        this.applyDirectGridStyleContract(gridName);
      });
    },
    isDirectBookingCustomCellInteraction(target) {
      return !!target?.closest?.(".direct-pat-name-cell, .direct-radio-cell, .direct-cell-host");
    },
    unbindDirectGridSelectionBehavior(gridName) {
      const root = this.getGridRoot(gridName);
      const handler = root?._directBookingSelectionHandler;
      if (root) {
        if (handler) {
          root.querySelectorAll(".k-grid-content, .k-grid-content-locked").forEach(content => {
            content.removeEventListener("click", handler, true);
          });
          root._directBookingSelectionHandler = null;
        }
        $(root).off("change.directBookingCheck");
      }
    },
    bindDirectGridSelectionBehavior(gridName) {
      const root = this.getGridRoot(gridName);
      if (!root) {
        return;
      }
      this.unbindDirectGridSelectionBehavior(gridName);
      const handler = (event) => {
        if (this.isDirectBookingCustomCellInteraction(event.target)) {
          event.stopPropagation();
          return;
        }
        const row = event.target.closest(
          ".k-grid-content tbody tr, .k-grid-content-locked tbody tr, .k-table-tbody .k-table-row"
        );
        const isCheckboxClick = !!event.target.closest(
          "input[type='checkbox'], .k-checkbox, .k-checkbox-wrap, .k-checkbox-label"
        );
        // 行クリックでは選択しない（チェックボックス列のみ Kendo に任せる）
        if (row && !isCheckboxClick) {
          event.stopPropagation();
        }
      };
      root._directBookingSelectionHandler = handler;
      root.querySelectorAll(".k-grid-content, .k-grid-content-locked").forEach(content => {
        content.addEventListener("click", handler, true);
      });
      $(root).on("change.directBookingCheck", "input[type='checkbox']", () => {
        this.handleChange();
      });
    },
    getSelectedGridDataItems(gridName) {
      const grid = this.getGridWidget(gridName);
      if (!grid) {
        return [];
      }
      return Array.from(grid.select?.() || [])
        .map(row => grid.dataItem(row))
        .filter(Boolean);
    },
    handleChange () {
      const checkedPatsElements = this.getSelectedGridDataItems("leftGrid");
      const checkedItemsElements = this.getSelectedGridDataItems("rightGrid");
      if (checkedPatsElements?.length && checkedItemsElements?.length) {
        this.hasSelectedItem = true;
      } else {
        this.hasSelectedItem = false;
      }
    },
    getPatListByFacilityCd() {
      this.setLoadingScreenVisible(true);
      ApiHelper.post("/exam/getPatListByFacilityCd", {
        facilityCd: this.facilityCd,
        startDate: this.startDate,
        endDate: this.endDate,
      }).then((res) => {
        const data = res.data;
        data.forEach((item) => {
          if (!item.pat_last_name && !item.pat_first_name) {
            item.patName = '？？？？患者'
          } else {
            item.patName = (item.pat_last_name ? (item.pat_last_name + ' ') : '') + item.pat_first_name || '';
          }
        });
        this.leftDataSource = data;
        this.$nextTick(() => this.refreshDirectGridDataSource("leftGrid"));
      }).catch(error => {
         getErrorMessage('MstExamItemRecBookingModal.vue', 'getPatListByFacilityCd', error);
         throw error;
      }).finally(() => {
        this.handleChange();
        this.setLoadingScreenVisible(false);
      });
    },
    getMstExamItem () {
      this.setLoadingScreenVisible(true);
      ApiHelper.get(`/exam/examRecord/examItemForRecalc/${this.facilityCd}`).then((res) => {
        const data = res.data;
        data.forEach((item, index) => {
          item.isCover = false;
          item.index = index;
        });
        this.rightDataSource = data;
        this.$nextTick(() => this.refreshDirectGridDataSource("rightGrid"));
      }).catch(error => {
         getErrorMessage('MstExamItemRecBookingModal.vue', 'getMstExamItem', error);
         throw error;
      }).finally(() => {
        this.setLoadingScreenVisible(false);
      });
    },
    handleSave () {
      if (!this.startDate && !this.endDate) {
        this.$ons.notification.alert({
          title: "注意",
          message: "対象期間を入力してください。"
        });
        return;
      }
      this.setLoadingScreenVisible(true);
      const checkedPats = this.getSelectedGridDataItems("leftGrid")
        .map(item => item.pat_id);
      const checkedItems = this.getSelectedGridDataItems("rightGrid")
        .map(item => ({
          exam_item_cd: item.examItemCd,
          compute_cover: item.isCover
        }));
      let content = {
       pat_id: checkedPats,
       to_date: this.endDate,
       from_date: this.startDate,
       item: checkedItems
      }
      let detail = {
        exam_main_cd: "",
        total_cnt: 0,
        done_cnt: 0
      }
      ApiHelper.post(
        `/exam/createMntRecalcQue`, {
          facilityCd: this.facilityCd,
          status: "0",
          content: JSON.stringify(content),
          detail: JSON.stringify(detail),
          regId: this.userAccountInfo.userId
        }).then(() => {
        this.$refs.leftGrid?.clearGridSelection?.();
        this.$refs.rightGrid?.clearGridSelection?.();
        this.showMstExamItemRecManagementModal();
      }).catch(error => {
         getErrorMessage('MstExamItemRecBookingModal.vue', 'handleSave', error);
         throw error;
      }).finally(() => {
        this.setLoadingScreenVisible(false);
      });
    },
  },
  mounted() {
    this.setLoadingScreenMessage("処理中・・・");
    this.initDirectGrid("leftGrid");
    this.initDirectGrid("rightGrid");
    this.getPatListByFacilityCd();
    this.getMstExamItem();
    // 获取起始日期和结束日期
    const startDate = dayjs().subtract(90, 'days').format('YYYY-MM-DD');
    const endDate = dayjs().format('YYYY-MM-DD');
    this.startDate = startDate;
    this.endDate = endDate;
  },
  beforeUnmount() {
    Object.values(this.directGridLayoutRafIds || {}).forEach(id => {
      if (id != null) {
        cancelAnimationFrame(id);
      }
    });
    this.destroyDirectCellApps();
    this.destroyDirectGrid("leftGrid");
    this.destroyDirectGrid("rightGrid");
  },
};
</script>

<style lang="css" scoped>
:deep(.k-widget) {
  font-size: 1em;
}
:deep(.modal-body) {
  width: calc(100% - 16px);
  left: 8px;
  height: calc(100% - 76px - 2em);
}
.modal-body-content {
  width: 100%;
  height: 100%;
}
.date-content {
  display: flex;
  flex-direction: row;
  margin-bottom: 10px;
}
.date-content label, .date-content span {
  line-height: 2em;
  margin: 0 8px;
}
.flex-container> :deep(.button) {
  width: auto;
}
.table-content {
  width: 100%;
  height: calc(100% - 3em);
  display: flex;
  flex-direction: row;
  justify-content: space-between;
}
.table-content-left {
  width: 48%;
  height: 100%;
  display: flex;
  flex-direction: column;
}
.table-content-right {
  width: 48%;
  height: 100%;
  display: flex;
  flex-direction: column;
}
:deep(.k-grid){
  flex: 1;
}
/* グリッド選択：丸型チェック（Kendo 新 DOM: .k-checkbox / 旧 DOM: .k-checkbox-label） */
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox-wrap) {
  display: inline-flex;
  align-items: center;
  justify-content: flex-start;
  vertical-align: middle;
}
.mst-exam-item-rec-booking-direct-jq-grid :deep(th:first-child),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-table-th:first-child),
.mst-exam-item-rec-booking-direct-jq-grid :deep(td:first-child),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-table-td:first-child) {
  text-align: left;
  vertical-align: middle !important;
}
.mst-exam-item-rec-booking-direct-jq-grid :deep(input.k-checkbox),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox) {
  position: relative !important;
  width: 22px !important;
  height: 22px !important;
  min-width: 22px !important;
  min-height: 22px !important;
  border-radius: 50% !important;
  border: 1px solid #c7c7cd !important;
  background-color: #fff !important;
  background-image: none !important;
  box-shadow: none !important;
}
/* 対号は上書き列ラジオ（.radio-button--round__checkmark::after）と同じ */
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox::before) {
  content: "" !important;
  display: block !important;
  position: absolute !important;
  top: 7px !important;
  left: 5px !important;
  width: 11px !important;
  height: 5px !important;
  margin: 0 !important;
  font-size: 0 !important;
  font-family: inherit !important;
  box-sizing: border-box !important;
  border: 1px solid transparent !important;
  border-top: none !important;
  border-right: none !important;
  border-bottom: 1px solid #fff !important;
  border-left: 1px solid #fff !important;
  background: transparent !important;
  mask-image: none !important;
  -webkit-mask-image: none !important;
  transform: rotate(-45deg) !important;
  opacity: 0 !important;
}
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox:checked),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox.k-checked) {
  background-color: #3B7FA3 !important;
  border-color: #3B7FA3 !important;
  color: #fff !important;
}
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox:checked::before),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox.k-checked::before) {
  opacity: 1 !important;
  transform: rotate(-45deg) !important;
}
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox:focus),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox.k-focus) {
  box-shadow: none !important;
}
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox-label::before) {
  background-color: #fff;
  border-radius: 50% !important;
  width: 22px !important;
  height: 22px !important;
  border: 1px solid #c7c7cd !important;
}
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox:checked + .k-checkbox-label::before),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox.k-checked + .k-checkbox-label::before) {
  background-color: #3B7FA3 !important;
  border: 0 !important;
}
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox-label::after) {
  position: absolute !important;
  content: "" !important;
  top: 7px !important;
  left: 5px !important;
  width: 11px !important;
  height: 5px !important;
  box-sizing: border-box !important;
  border: 1px solid #fff !important;
  border-top: none !important;
  border-right: none !important;
  border-radius: 0 !important;
  background: transparent !important;
  transform: rotate(-45deg) !important;
}
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox:focus + .k-checkbox-label::before),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox.k-focus + .k-checkbox-label::before) {
  box-shadow: none !important;
}
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-checkbox-label.k-no-text),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-radio-label.k-no-text) {
  width: 22px !important;
  height: 22px !important;
}
/* 選択行：マスタメンテ標準の淡い青（ゼブラ行・Kendo既定色を上書き） */
.mst-exam-item-rec-booking-direct-jq-grid :deep(tr.k-selected),
.mst-exam-item-rec-booking-direct-jq-grid :deep(tr.k-state-selected),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-table-row.k-selected),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-table-row.k-state-selected) {
  background-color: #b8dafb !important;
  background-image: none !important;
  box-shadow: none !important;
}
.mst-exam-item-rec-booking-direct-jq-grid :deep(tr.k-selected > td),
.mst-exam-item-rec-booking-direct-jq-grid :deep(tr.k-state-selected > td),
.mst-exam-item-rec-booking-direct-jq-grid :deep(tr.k-selected.k-alt > td),
.mst-exam-item-rec-booking-direct-jq-grid :deep(tr.k-state-selected.k-alt > td),
.mst-exam-item-rec-booking-direct-jq-grid :deep(tr.k-master-row.k-selected > td),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-table-row.k-selected > .k-table-td),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-table-row.k-state-selected > .k-table-td),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-table-row.k-selected.k-table-alt-row > .k-table-td),
.mst-exam-item-rec-booking-direct-jq-grid :deep(.k-table-row.k-state-selected.k-table-alt-row > .k-table-td) {
  color: var(--master-maintenance-kgrid-body-color, #333) !important;
  background-color: #b8dafb !important;
  background-image: none !important;
  box-shadow: none !important;
}
/* 上書き列：丸型ラジオ */
.mst-exam-item-rec-booking-direct-jq-grid :deep(.direct-radio-cell :checked + .radio-button--round__checkmark::before) {
  background-color: #3B7FA3 !important;
}
:deep(.k-grid td) {
  border-width: 0 1px 1px 0 !important;
  border-color: var(--master-maintenance-kgrid-border-color);
}

:deep(.k-grid .k-table-td) {
  border-width: 0 1px 1px 0 !important;
  border-color: var(--master-maintenance-kgrid-border-color);
}

:deep(.direct-pat-name-cell .same-icon) {
  position: relative;
  top: 0.25em;
  height: 20px;
}

.mst-exam-item-rec-booking-direct-jq-grid {
  flex: 1;
  min-height: 0;
}
</style>
