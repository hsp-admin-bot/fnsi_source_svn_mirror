<!-- 患者情報共有詳細リスト -->
<template>
  <div
    v-show="!isPatInfoVisible"
    class="main-content-area kendo-grid-style-page grid-wrapper"
  >
    <div class="shr-list-main-content">
      <div class="custom-grid-header">
        <span>共有先</span>
        <button
          v-if="!getUnfinishedShareFlg"
          class="examRecord-style-select-button btn3-normal btn-detail-row btn-add-cls"
          @click="handleHeaderClick(false)"
        >
          新規
        </button>
      </div>
      <kendo-grid
        ref="shrToListGrid"
        :data-source="this.shrToListData"
        :resizable="true"
        :scrollable="true"
        :sortable-allow-unsort="true"
        :sortable-show-indexes="true"
        selectable="row"
        @databound="(ev) => onDataBound(ev, false)"
      >
        <kendo-grid-column
          v-for="column in dynamicColumns(false)"
          :key="column.key"
          :title="column.colName"
          :field="column.field"
          :width="column.width"
          :template="column.template"
        ></kendo-grid-column>
      </kendo-grid>
    </div>

    <div class="shr-list-main-content">
      <div class="custom-grid-header">
        <span>共有受</span>
        <button
          v-if="!getUnfinishedShareFlg"
          class="examRecord-style-select-button btn3-normal btn-detail-row btn-add-cls"
          @click="handleHeaderClick(true)"
        >
          新規
        </button>
      </div>
      <kendo-grid
        ref="shrFromListGrid"
        :data-source="this.shrFromListData"
        :resizable="true"
        :scrollable="true"
        :reorderable="true"
        :sortable-allow-unsort="true"
        :sortable-show-indexes="true"
        selectable="row"
        @databound="(ev) => onDataBound(ev, true)"
      >
        <kendo-grid-column
          v-for="column in dynamicColumns(true)"
          :key="column.key"
          :title="column.colName"
          :field="column.field"
          :width="column.width"
          :template="column.template"
        />
      </kendo-grid>
    </div>
  </div>
</template>

<script>
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import $ from "jquery";
import { EventBus } from "@/compat/vue/event-bus.js";
import PopoverMixin from "@/components/PopoverMixin";
import { CONSENT_OPTIONS, SHR_STATUS_OPTIONS } from "@/constants/PatShrInfo.js";

export default {
  mixins: [NextTransitionMixin, PopoverMixin],
  data() {
    return {
      currentSort: null,
    };
  },
  watch: {},
  computed: {
    ...mapGetters("pat-info-sharing", [
      "getShrFromInfoList",
      "getShrToInfoList",
      "getUnfinishedShareFlg",
    ]),
    ...mapGetters("pat-info", ["isPatInfoVisible"]),
    ...mapGetters("pat-info", {
      selectedPat: "selectedShrPat"
    }),
    patMain() {
      return this.selectedPat?.pat_personal_main || null;
    },
    patId() {
      return (this.patMain && this.patMain.pat_id) || null;
    },
    shrToListData() {
      return this.mapPatientList(this.getShrToInfoList, "shrTo");
    },

    shrFromListData() {
      return this.mapPatientList(this.getShrFromInfoList, "shrFrom");
    },
  },
  methods: {
    ...mapActions("pat-info-sharing", ["fetchShrDetailsInfoList"]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    ...mapActions("multi-modal", ["showShrPatEdit"]),
    /**
     * 動的カラム定義処理
     */
    dynamicColumns(isFrom) {
      const columns = [
        {
          key: "facilityName",
          field: "facilityName",
          colName: isFrom ? "共有元施設名" : "共有先施設名",
        },
        {
          key: "selfConsent",
          field: "selfConsent",
          colName: "自施設",
          width: 110,
        },
        {
          key: "otherConsent",
          field: "otherConsent",
          colName: isFrom ? "共有元" : "共有先",
          width: 110,
        },
        {
          key: "patConsent",
          field: "patConsentName",
          colName: "患者",
          width: 110,
        },
        {
          key: "sharedState",
          field: "sharedStateName",
          colName: "状態",
          width: 110,
        },
        {
          key: "editBtn",
          colName: "詳細",
          template: `<button class="examRecord-style-select-button btn3-normal btn-detail-row">詳細</button>`,
          width: 110,
        },
      ];
      return columns;
    },
    /**
     * リスト更新処理
     */
    async refresh() {
      if (this.patId) {
        try {
          await this.setLoadingScreenVisible(true);
          await this.fetchShrDetailsInfoList(this.patId);
        } finally {
          await this.setLoadingScreenVisible(false);
        }
      }
    },
    /**
     * 患者リストマッピング処理
     */
    mapPatientList(rawList, type) {
      const isFrom = type === "shrFrom";
      return rawList.map((item) => {
        return {
          selfConsent: this.getTextByValue(
            CONSENT_OPTIONS,
            isFrom ? item.isToConsent : item.isFromConsent
          ),
          otherConsent: this.getTextByValue(
            CONSENT_OPTIONS,
            isFrom ? item.isFromConsent : item.isToConsent
          ),
          patConsentName: this.getTextByValue(
            CONSENT_OPTIONS,
            item.isPatConsent
          ),
          sharedStateName: this.getTextByValue(
            SHR_STATUS_OPTIONS,
            item.sharedState
          ),
          facilityCd: isFrom ? item.toFacilityCd : item.fromFacilityCd,
          patId: isFrom ? item.toPatId : item.fromPatId,
          ...item,
        };
      });
    },
    /**
     * データバウンド処理
     */
    onDataBound(ev, isFrom) {
      const grid = ev.sender;
      const self = this;
      $(grid.tbody)
        .find(".btn-detail-row")
        .off("click")
        .on("click", function (e) {
          e.stopPropagation();
          const row = $(this).closest("tr");
          const dataItem = grid.dataItem(row);
          self.handleDetailClick(dataItem, isFrom);
        });
    },
    /**
     * ヘッダークリック処理
     */
    handleHeaderClick(isFrom) {
      const param = {
        isFrom: isFrom,
        isCreate: true,
        dataItem: null,
      };
      this.showShrPatEdit({
        title: this.shrEditorTitle(isFrom, true),
        initValues: param,
      });
    },
    /**
     * 詳細ボタンクリック処理
     */
    handleDetailClick(dataItem, isFrom) {
      const param = {
        isFrom: isFrom,
        isCreate: false,
        dataItem: dataItem,
      };
      this.showShrPatEdit({
        title: this.shrEditorTitle(isFrom, false),
        initValues: param,
      });
    },
    /**
     * 詳細画面タイトルの取得
     */
    shrEditorTitle(isFrom, isCreate) {
      const shrDirectionTitle = isFrom
        ? "（共有元→自施設："
        : "（自施設→共有先：";
      const actionTitle = isCreate ? "新規）" : "編集）";
      return "患者情報共有詳細" + shrDirectionTitle + actionTitle;
    },
    /**
     * 値からテキストの取得
     */
    getTextByValue(options, value) {
      const option = options.find((opt) => opt.value === value);
      return option ? option.text : "";
    },
  },
  beforeUnmount() {
    EventBus.$off("refresh", this.refresh);
    clearTimeout(this.timerObj);
    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style scoped>
.grid-wrapper {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}
.shr-list-main-content {
  flex: 1;
  display: flex;
  flex-direction: column;
  min-height: 0;
  overflow: hidden;
}
.shr-list-main-content :deep(.k-grid) {
  flex: 1;
  display: flex;
  flex-direction: column;
  height: 100% !important;
  min-height: 0;
}
.shr-list-main-content :deep(.k-grid-content) {
  flex: 1;
  overflow-y: scroll !important;
  height: calc(100% - 55px) !important;
  min-height: 0;
}
.shr-list-main-content :deep(.k-grid-header) {
  flex: 0 0 auto;
}
.shr-list-main-content :deep(.k-grid-header-wrap > table),
.shr-list-main-content :deep(.k-grid-content > table) {
  width: 100% !important;
  table-layout: fixed !important;
}
.shr-list-main-content kendo-grid {
  height: auto !important;
}
.shr-list-main-content :deep(.k-i-sort-asc-sm::before) {
  content: "▲" !important;
  color: #ffffff;
}
.shr-list-main-content :deep(.k-i-sort-desc-sm::before) {
  content: "▼" !important;
  color: #ffffff;
}
.shr-list-main-content :deep(.k-grid-content-locked) {
  touch-action: auto;
  -webkit-overflow-scrolling: touch;
  overflow-y: scroll;
  scrollbar-width: none;
}
.shr-list-main-content :deep(.k-grid-content-locked)::-webkit-scrollbar {
  display: none;
}
:deep(.k-grid table) {
  table-layout: fixed !important;
  width: 100% !important;
}
:deep(.k-grid colgroup col:first-child) {
  width: auto !important;
  min-width: 150px !important;
}
:deep(.k-grid td) {
  white-space: nowrap;
  text-overflow: ellipsis;
  overflow: hidden;
}
:deep(.k-grid-header-wrap > table) {
  width: 100% !important;
}
:deep(.null-pat-id-row td) {
  background-color: #fff3a0 !important;
}
:deep(.null-pat-id-row:hover td) {
  background-color: #f7e671 !important;
  transition: background-color 0.2s ease;
}
:deep(.k-grid tbody tr:hover td) {
  background-color: #eef6ff;
}
.custom-grid-header {
  flex: 0 0 41px;
  flex-shrink: 0;
  width: calc(100% - 17px);
  box-sizing: border-box;
  height: 40px;
  line-height: 40px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border: 1px solid #dee2e6;
  border-bottom: none;
  padding: 0px 18px 0px 13px;
  border-top-left-radius: 4px;
  border-top-right-radius: 4px;
  color: #fff;
  word-wrap: break-word;
  white-space: normal;
  background-color: var(--master-maintenance-kgrid-header-background-color);
  border-width: 0 1px 1px 0;
  border-style: solid;
  border-color: inherit;
  outline: 0;
  font-weight: inherit;
  text-align: inherit;
  overflow: hidden;
  text-overflow: ellipsis;
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
  font-size: 1em;
  margin-right: 17px;
  transition: background 0.2s;
  user-select: none;
}
:deep(.k-grid td:last-child),
:deep(.k-grid th.k-header:last-child) {
  text-align: center !important;
}
:deep(.k-grid th.k-header:last-child) {
  text-align: center !important;
}
:deep(.btn-detail-row) {
  border: none !important;
  line-height: 20px;
  height: 28px;
}
.btn-add-cls {
  line-height: 27px;
  height: 27px;
  width: 5em;
}
</style>
