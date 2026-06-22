<!-- 患者情報共有リスト -->
<template>
  <div class="main-content-area kendo-grid-style-page">
    <div class="shr-list-main-content">
      <div
        ref="shrListGrid"
        class="shr-list-direct-grid ntss-list check-list-main-content-list"
        :style="{ cursor: isPatInfoVisible ? 'default' : 'pointer' }"
      ></div>
    </div>
  </div>
</template>

<script>
import $$ from "@/compat/jquery";
import Kendo from "@progress/kendo-ui";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import { EventBus } from "@/compat/vue/event-bus.js";
import PopoverMixin from "@/components/PopoverMixin";
import { sortableCompare } from "@/functions/SortFunctions";
import { getMainContentAreaElement } from "@/functions/common/LayoutMeasureHelper";
import nameDuplicationImg from "../../../assets/name_duplication.png";

export default {
  mixins: [NextTransitionMixin, PopoverMixin],
  data() {
    return {
      kendoGridHeight: 300,
      directGridWidget: null,
      directGridLayoutRafId: null,
      shrListDataSource: null,
      shrGridColumns: [
        {
          key: "patId",
          field: "hospPatId",
          colName: "患者ID",
          width: 140,
          locked: true,
        },
        {
          key: "patName",
          field: "patName",
          colName: "患者名(同姓同名アイコン)",
          width: 235,
          locked: true,
        },
        {
          key: "gender",
          field: "genderName",
          colName: "性別",
          width: 120,
        },
        {
          key: "bloodType",
          field: "bloodTypeName",
          colName: "血液型",
          width: 120,
        },
        {
          key: "birthday",
          field: "birthday",
          colName: "生年月日",
          width: 150,
        },
        {
          key: "facilityCdTo",
          field: "facilityCdTo",
          colName: "共有先",
          width: 120,
        },
        {
          key: "facilityCdFrom",
          field: "facilityCdFrom",
          colName: "共有元",
          width: 120,
        },
        {
          key: "prohibitedCount",
          field: "prohibitedCount",
          colName: "共有禁止",
          width: 130,
        },
        {
          key: "shrPending",
          field: "shrPending",
          colName: "未完了",
          width: 120,
        },
      ],
      bloodTypeAbo: { 0: "不明", 1: "A型", 2: "B型", 3: "O型", 4: "AB型" },
      bloodTypesRh: { 0: "不明", 1: "(Rh+)", 2: "(Rh−)" },
      gender: { 0: "不明", 1: "男性", 2: "女性" },
      currentSort: null,
      image_src_same: nameDuplicationImg,
      shrGridHoverSyncIndex: null,
      shrGridHoverOverHandler: null,
      shrGridHoverOutHandler: null,
      shrGridHoverBg: "#eef6ff",
      shrGridHoverBgNull: "#f7e671",
    };
  },
  watch: {
    getFilterSignal(val, oldVal) {
      if (val === true && oldVal === false) {
        this.searchList();
        this.setFilterSignal(false);
      }
    },
    getSelectedPatId(newId) {
      this.$nextTick(() => {
        const grid = this.getShrListGridWidget();
        if (!grid) return;
        const items = grid.items();
        items.each((idx, row) => {
          const dataItem = grid.dataItem(row);
          if (dataItem.patId === newId) {
            row.classList.add("selected-row");
            grid.select(row);
            this.scrollToRow(row);
          } else {
            row.classList.remove("selected-row");
          }
        });
      });
    },
  },
  computed: {
    ...mapGetters("pat-info-sharing", [
      "getCondition",
      "getShrInfoList",
      "getFilterSignal",
      "getSelectedPatId",
      "getUnfinishedShareFlg",
    ]),
    ...mapGetters("pat-info", ["isPatInfoVisible", "searchedPatList"]),
    ...mapGetters("account-edit", {
      getPatientShareMode: "getPatientShareMode",
      getPatientShareFacilityCdMode: "getPatientShareFacilityCdMode",
    }),
    condition: {
      get() {
        return this.getCondition;
      },
      set(val) {
        this.setCondition(val);
      },
    },
  },
  methods: {
    ...mapActions("pat-info-sharing", [
      "setCondition",
      "setFilterSignal",
      "setIsSearching",
      "setUnfinishedShareFlg",
      "setOutHospPatId",
      "setSelectedPatId",
      "fetchShrInfoList",
      "fetchShrDetailsInfoList",
    ]),
    ...mapActions("loading-screen", ["setLoadingScreenVisible"]),
    ...mapActions("pat-info", [
      "selectSharePat",
      "clearSelectedPat",
      "setSearchedShrPatList",
    ]),
    getShrListGridRef() {
      return this.$refs.shrListGrid || null;
    },
    getShrListGridWidget() {
      return (
        this.directGridWidget ||
        this.getShrListGridRef()?.kendoWidget?.() ||
        this.getShrListGridRef()?.gridWidget?.() ||
        null
      );
    },
    installDirectGridFacade() {
      const root = this.getShrListGridRef();
      if (!root) return;
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
    },
    getShrGridContainerWidth() {
      const container = this.$el?.querySelector?.(".shr-list-main-content");
      const root = this.getShrListGridRef();
      const width =
        container?.getBoundingClientRect()?.width ||
        root?.getBoundingClientRect()?.width ||
        1320;
      return Math.floor(width);
    },
    buildDirectGridColumns(gridWidth) {
      const containerWidth = gridWidth ?? this.getShrGridContainerWidth();
      const lockedCols = this.shrGridColumns.filter((c) => c.locked);
      const lockedWidth = lockedCols.reduce(
        (sum, c) => sum + (c.width || 0),
        0
      );
      const birthdayWidth = 170;
      const otherFlexColumns = this.shrGridColumns.filter(
        (c) => !c.locked && c.key !== "birthday"
      );
      const remainWidth = containerWidth - lockedWidth - birthdayWidth - 18;
      const avgWidth = Math.max(
        Math.floor(remainWidth / otherFlexColumns.length),
        118
      );
      const imgSrc = this.image_src_same;
      return this.shrGridColumns.map((col) => {
        let width = col.width;
        if (!col.locked) {
          width = col.key === "birthday" ? birthdayWidth : avgWidth;
        }
        return {
          field: col.field,
          title: col.colName,
          width,
          locked: col.locked,
          ...(col.key === "patName"
            ? {
                template:
                  `<span class="pat-name-container" style="display:flex;align-items:center;">` +
                  `<span style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">#: patName #</span>` +
                  `# if(isSame === '1') { # <img src="${imgSrc}" class="same-icon" style="width:16px;margin-left:4px;flex-shrink:0;" /> # } #` +
                  `</span>`,
              }
            : {}),
        };
      });
    },
    buildShrListDataSource() {
      const shrInfoList = this.mapPatientList(this.getShrInfoList);
      const freeWord = this.getCondition?.freeWord || "";
      const filteredPatList = freeWord
        ? shrInfoList.filter(
            (pat) =>
              (pat.patName && pat.patName.includes(freeWord)) ||
              (pat.hospPatId && pat.hospPatId.includes(freeWord))
          )
        : shrInfoList;
      this.shrListDataSource = new Kendo.data.DataSource({
        data: filteredPatList,
        sort: this.currentSort || undefined,
      });
    },
    initDirectGridIfReady() {
      const root = this.getShrListGridRef();
      if (!root || !this.shrListDataSource) return;

      if (this.directGridWidget) {
        this.applyDirectGridDataSourceContract();
        this.installDirectGridFacade();
        this.scheduleDirectGridLayoutContract();
        return;
      }

      $$(root).kendoGrid({
        dataSource: this.shrListDataSource,
        columns: this.buildDirectGridColumns(this.getShrGridContainerWidth()),
        editable: false,
        reorderable: true,
        resizable: true,
        selectable: "row",
        height: this.kendoGridHeight,
        scrollable: true,
        sortable: {
          allowUnsort: true,
          showIndexes: true,
          compare: this.compareByField,
        },
        change: (event) => this.onRowClick(event),
        dataBound: (event) => this.onDataBound(event),
        sort: (event) => this.sortHandler(event),
      });
      this.directGridWidget = $$(root).data("kendoGrid") || null;
      this.installDirectGridFacade();
      this.enableShrGridLockedHoverSync();
      this.scheduleDirectGridLayoutContract();
    },
    applyDirectGridDataSourceContract() {
      const grid = this.getShrListGridWidget();
      if (!grid || !this.shrListDataSource) return;
      if (grid.dataSource !== this.shrListDataSource) {
        grid.setDataSource(this.shrListDataSource);
      } else {
        grid.refresh();
      }
      this.installDirectGridFacade();
      this.scheduleDirectGridLayoutContract();
    },
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        this.runDirectGridLayoutContract();
      });
    },
    runDirectGridLayoutContract() {
      const grid = this.getShrListGridWidget();
      const root = this.getShrListGridRef();
      if (!grid || !root) return;
      root.style.width = "100%";
      root.style.height = `${this.kendoGridHeight}px`;
      try {
        grid.wrapper?.height?.(this.kendoGridHeight);
        grid.resize?.();
      } catch (_error) {
        // noop
      }
    },
    destroyDirectGrid() {
      this.clearShrGridLockedHoverSync();
      try {
        this.directGridWidget?.destroy?.();
      } catch (_error) {
        // noop
      }
      this.directGridWidget = null;
      const root = this.getShrListGridRef();
      if (root?.nodeType === 1) {
        root.innerHTML = "";
      }
    },
    calculateGridHeight() {
      this.kendoGridHeight =
        getMainContentAreaElement(this.$el || document)?.clientHeight || 300;
      this.scheduleDirectGridLayoutContract();
    },
    scheduleGridRefresh() {
      requestAnimationFrame(() => {
        this.initDirectGridIfReady();
        this.calculateGridHeight();
      });
    },
    /**
     * フィルター条件設定処理
     */
    setFilterCondition(condition) {
      this.condition = condition;
      this.buildShrListDataSource();
      this.scheduleGridRefresh();
    },
    /**
     * 患者情報共有リスト検索処理
     */
    async searchList() {
      try {
        await this.setLoadingScreenVisible(true);
        if (this.$route.name === "pat-info-sharing-detail") {
          this.setIsSearching(true);
          this.setSelectedPatId("");
          this.goShrSplitView("pat-info-sharing");
          await this.$nextTick();
        }
        await this.fetchShrInfoList(this.condition);
        this.buildShrListDataSource();
      } finally {
        this.setIsSearching(false);
        await this.setLoadingScreenVisible(false);
      }
      this.scheduleGridRefresh();
    },
    /**
     * リスト更新処理
     */
    refresh(payload) {
      if (payload && payload.source != "PAT_INFO_SHARING") {
        return;
      }
      if (this.getFilterSignal === true) {
        this.setFilterSignal(false);
      }
      this.searchList();
    },
    /**
     * フィールド比較処理
     */
    compareByField(a, b) {
      if (!this.currentSort || !this.currentSort.field) return;
      const sortField = this.currentSort.field;
      if (sortField === "genderName") {
        return this.compareGender(a, b);
      }
      if (sortField === "bloodTypeName") {
        return this.compareBloodType(a, b);
      }
      let options = {};
      if (sortField === "patName") {
        options.notUseSortKeyMap = true;
      }
      options.reverseFields = ["isSame"];
      return sortableCompare(a, b, sortField, true, options);
    },
    /**
     * 性別比較処理
     */
    compareGender(a, b) {
      const order = {
        1: 0, // 男性
        2: 1, // 女性
        0: 2, // 不明
      };
      const valA = order[a.gender] ?? 3;
      const valB = order[b.gender] ?? 3;
      return valA - valB;
    },
    /**
     * 血液型比較処理
     */
    compareBloodType(a, b) {
      const aboOrder = {
        1: 0, // A
        2: 1, // B
        3: 2, // O
        4: 3, // AB
        0: 4, // 不明
      };
      const rhOrder = {
        1: 0, // Rh+
        2: 1, // Rh−
        0: 2, // 不明
      };
      const main =
        (aboOrder[a.bloodTypeAbo] ?? 4) - (aboOrder[b.bloodTypeAbo] ?? 4);
      if (main !== 0) return main;
      return (rhOrder[a.bloodTypesRh] ?? 2) - (rhOrder[b.bloodTypesRh] ?? 2);
    },
    /**
     * ソートハンドラ処理
     */
    sortHandler(e) {
      this.currentSort = e.sort;
    },
    /**
     * 患者リストマッピング処理
     */
    mapPatientList(rawList) {
      return rawList.map((item) => {
        return {
          hospPatId: item.hosp_pat_id,
          patId: item.patId,
          patName: (item.pat_last_name + " " + item.pat_first_name).trim(),
          isSame: item.is_same,
          gender: item.pat_sex,
          genderName: this.gender[item.pat_sex] || "",
          bloodTypeAbo: item.pat_blood_type_abo,
          bloodTypesRh: item.pat_blood_type_rh,
          bloodTypeName:
            (this.bloodTypeAbo[item.pat_blood_type_abo] || "") +
            (this.bloodTypesRh[item.pat_blood_type_rh] || ""),
          birthday: item.pat_birthday,
          facilityCdTo: String(item.shareToCount),
          facilityCdFrom: String(item.shareFromCount),
          shrPending: String(item.pendingCount),
          prohibitedCount: String(item.prohibitedCount),
        };
      });
    },
    /**
     * 行クリック処理
     */
    async onRowClick(e) {
      if (this.isPatInfoVisible) {
        return;
      }
      const grid = e.sender;
      const selectedRow = grid.select();
      if (!selectedRow || selectedRow.length === 0) {
        return;
      }
      const dataItem = grid.dataItem(selectedRow);

      this.setSelectedPatId(dataItem.patId);
      grid.items().removeClass("selected-row");
      selectedRow.addClass("selected-row");

      const hasHospPatId = Boolean(dataItem.hospPatId);
      this.setUnfinishedShareFlg(!hasHospPatId);
      this.setOutHospPatId(dataItem.hospPatId);

      await this.selectSharePat({
        selectedPatId: dataItem.patId,
        unfinishedShareFlg: !hasHospPatId,
      });
      const searchPatList = this.getShrInfoList.map((pat) => {
        return {
          pat_id: pat.patId,
          hosp_pat_id: pat.hosp_pat_id,
          pat_sex: pat.pat_sex,
          pat_last_name: pat.pat_last_name,
          pat_first_name: pat.pat_first_name,
          is_same: pat.is_same,
          pat_first_name_kana: pat.pat_first_name_kana,
          pat_last_name_kana: pat.pat_last_name_kana,
          in_out_class: pat.in_out_class,
        };
      });
      await this.setSearchedShrPatList(searchPatList);
      await this.fetchShrDetailsInfoList(dataItem.patId);
      this.goShrSplitView("pat-info-sharing-detail");
    },
    /**
     * データバウンド処理
     */
    onDataBound(ev) {
      this.clearShrGridHoverSync();
      const grid = ev.sender;
      const items = grid.items();
      let targetRow = null;
      items.each((idx, row) => {
        const dataItem = grid.dataItem(row);
        if (!dataItem.hospPatId) {
          row.classList.add("null-pat-id-row");
        }
        if (dataItem.patId === this.getSelectedPatId) {
          row.classList.add("selected-row");
          targetRow = row;
        }
      });
      if (targetRow) {
        this.scrollToRow(targetRow);
      }
    },
    getShrGridRowIndex(row) {
      const tbody = row?.closest?.("tbody");
      if (!tbody || !row) return -1;
      return Array.prototype.indexOf.call(tbody.children, row);
    },
    applyShrGridHoverSync(sourceRow) {
      const index = this.getShrGridRowIndex(sourceRow);
      if (index < 0) return;
      const grid = this.getShrListGridWidget();
      if (!grid) return;
      const lockedRow = grid.lockedTable?.find("tbody tr").get(index);
      const normalRow = grid.table?.find("tbody tr").get(index);
      if (!lockedRow && !normalRow) return;
      const isNullRow =
        lockedRow?.classList.contains("null-pat-id-row") ||
        normalRow?.classList.contains("null-pat-id-row");
      const hoverBg = isNullRow ? this.shrGridHoverBgNull : this.shrGridHoverBg;
      if (index === this.shrGridHoverSyncIndex) {
        [lockedRow, normalRow].forEach((row) => {
          this.paintShrGridHoverRow(row, hoverBg);
        });
        return;
      }
      this.clearShrGridHoverSync();
      this.shrGridHoverSyncIndex = index;
      [lockedRow, normalRow].forEach((row) => {
        this.paintShrGridHoverRow(row, hoverBg);
      });
    },
    paintShrGridHoverRow(row, hoverBg) {
      if (!row) return;
      row.classList.add("hover-sync");
      row.classList.remove("k-hover");
      row.querySelectorAll("td, .k-table-td").forEach((cell) => {
        cell.classList.remove("k-hover");
        cell.style.setProperty("background-color", hoverBg, "important");
      });
    },
    resetShrGridHoverRow(row) {
      if (!row) return;
      row.classList.remove("hover-sync", "k-hover");
      row.querySelectorAll("td, .k-table-td").forEach((cell) => {
        cell.classList.remove("k-hover");
        cell.style.removeProperty("background-color");
      });
    },
    clearShrGridHoverSync() {
      if (this.shrGridHoverSyncIndex == null) return;
      const grid = this.getShrListGridWidget();
      if (grid) {
        grid.lockedTable?.find("tbody tr.hover-sync").each((_, row) => {
          this.resetShrGridHoverRow(row);
        });
        grid.table?.find("tbody tr.hover-sync").each((_, row) => {
          this.resetShrGridHoverRow(row);
        });
      }
      this.shrGridHoverSyncIndex = null;
    },
    enableShrGridLockedHoverSync() {
      this.clearShrGridLockedHoverSync();
      const root = this.getShrListGridRef();
      if (!root) return;
      this.shrGridHoverOverHandler = (event) => {
        const row = event.target?.closest?.("tbody tr");
        if (!row || !root.contains(row)) return;
        this.applyShrGridHoverSync(row);
      };
      this.shrGridHoverOutHandler = (event) => {
        const row = event.target?.closest?.("tbody tr");
        if (!row || !root.contains(row)) return;
        if (row.contains(event.relatedTarget)) return;
        const relatedRow = event.relatedTarget?.closest?.("tbody tr");
        if (
          relatedRow &&
          root.contains(relatedRow) &&
          this.getShrGridRowIndex(relatedRow) === this.getShrGridRowIndex(row)
        ) {
          return;
        }
        this.clearShrGridHoverSync();
      };
      root.addEventListener("mouseover", this.shrGridHoverOverHandler);
      root.addEventListener("mouseout", this.shrGridHoverOutHandler);
    },
    clearShrGridLockedHoverSync() {
      const root = this.getShrListGridRef();
      if (root && this.shrGridHoverOverHandler) {
        root.removeEventListener("mouseover", this.shrGridHoverOverHandler);
        root.removeEventListener("mouseout", this.shrGridHoverOutHandler);
      }
      this.shrGridHoverOverHandler = null;
      this.shrGridHoverOutHandler = null;
      this.clearShrGridHoverSync();
    },
    scrollToRow(row) {
      const grid = this.getShrListGridWidget();
      if (!grid) return;
      const content = grid.content[0];
      if (!content) return;
      const rowTop = row.offsetTop;
      const rowHeight = row.offsetHeight;
      const contentHeight = content.clientHeight;
      const currentScroll = content.scrollTop;
      if (
        rowTop < currentScroll ||
        rowTop + rowHeight > currentScroll + contentHeight
      ) {
        row.scrollIntoView({
          behavior: "smooth",
          block: "center",
        });
      }
    },
  },
  async created() {
    EventBus.$off("filterPatInfoSharingList", this.setFilterCondition);
    EventBus.$off("refresh", this.refresh);
    EventBus.$on("filterPatInfoSharingList", this.setFilterCondition);
    EventBus.$on("refresh", this.refresh);
  },
  mounted() {
    this.$nextTick(() => {
      this.calculateGridHeight();
      this.buildShrListDataSource();
      requestAnimationFrame(() => {
        this.initDirectGridIfReady();
      });
    });
  },
  async beforeUnmount() {
    if (this.directGridLayoutRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = null;
    }
    this.destroyDirectGrid();
    EventBus.$off("filterPatInfoSharingList", this.setFilterCondition);
    EventBus.$off("refresh", this.refresh);
    this.setSelectedPatId("");
  },
};
</script>

<style scoped>
.shr-list-main-content {
  font-size: 1em;
  flex: 1;
  min-height: 0;
  display: flex;
  flex-direction: column;
  width: 100%;
}
.shr-list-direct-grid {
  width: 100%;
  flex: 1;
  min-width: 0;
}
:deep(.shr-list-direct-grid.k-grid) {
  width: 100% !important;
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
  overflow-y: auto;
  scrollbar-width: none;
}
.shr-list-main-content :deep(.k-grid-content-locked)::-webkit-scrollbar {
  display: none;
}
:deep(.k-grid tbody tr.null-pat-id-row:not(.selected-row) td),
:deep(.k-grid-content-locked tbody tr.null-pat-id-row:not(.selected-row) td),
:deep(.k-grid tbody tr.null-pat-id-row:not(.selected-row) .k-table-td),
:deep(.k-grid-content-locked tbody tr.null-pat-id-row:not(.selected-row) .k-table-td) {
  background-color: #fff3a0 !important;
}
/* 原生 hover は無効化し、hover-sync（JS 直書き）のみ表示 */
.main-content-area.kendo-grid-style-page .shr-list-direct-grid.k-grid :deep(.k-grid-content tr:not(.hover-sync):not(.selected-row):hover),
.main-content-area.kendo-grid-style-page .shr-list-direct-grid.k-grid :deep(.k-grid-content-locked tr:not(.hover-sync):not(.selected-row):hover),
.main-content-area.kendo-grid-style-page .shr-list-direct-grid.k-grid :deep(.k-grid-content tr:not(.hover-sync):not(.selected-row).k-hover),
.main-content-area.kendo-grid-style-page .shr-list-direct-grid.k-grid :deep(.k-grid-content-locked tr:not(.hover-sync):not(.selected-row).k-hover) {
  background-color: transparent !important;
}
.main-content-area.kendo-grid-style-page .shr-list-direct-grid.k-grid :deep(.k-grid-content tr:not(.hover-sync):not(.selected-row):hover > td),
.main-content-area.kendo-grid-style-page .shr-list-direct-grid.k-grid :deep(.k-grid-content-locked tr:not(.hover-sync):not(.selected-row):hover > td),
.main-content-area.kendo-grid-style-page .shr-list-direct-grid.k-grid :deep(.k-grid-content tr:not(.hover-sync):not(.selected-row):hover > .k-table-td),
.main-content-area.kendo-grid-style-page .shr-list-direct-grid.k-grid :deep(.k-grid-content-locked tr:not(.hover-sync):not(.selected-row):hover > .k-table-td),
.main-content-area.kendo-grid-style-page .shr-list-direct-grid.k-grid :deep(.k-grid-content tr:not(.hover-sync):not(.selected-row).k-hover > td),
.main-content-area.kendo-grid-style-page .shr-list-direct-grid.k-grid :deep(.k-grid-content-locked tr:not(.hover-sync):not(.selected-row).k-hover > td),
.main-content-area.kendo-grid-style-page .shr-list-direct-grid.k-grid :deep(.k-grid-content tr:not(.hover-sync):not(.selected-row).k-hover > .k-table-td),
.main-content-area.kendo-grid-style-page .shr-list-direct-grid.k-grid :deep(.k-grid-content-locked tr:not(.hover-sync):not(.selected-row).k-hover > .k-table-td) {
  background-color: inherit !important;
}
:deep(.k-grid tbody tr.selected-row td),
:deep(.k-grid-content-locked tbody tr.selected-row td) {
  background-color: rgba(0, 123, 255, 0.25) !important;
}
:deep(.k-grid tbody tr.null-pat-id-row.selected-row td),
:deep(.k-grid-content-locked tbody tr.null-pat-id-row.selected-row td) {
  background-color: rgba(0, 123, 255, 0.25) !important;
}
.main-content-area {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}
</style>
