<!-- 患者情報共有リスト -->
<template>
  <div class="main-content-area kendo-grid-style-page">
    <div class="shr-list-main-content">
      <kendo-grid
        v-if="isReady"
        ref="shrListGrid"
        :data-source="this.shrListData"
        :resizable="true"
        :scrollable="true"
        :reorderable="true"
        :height="kendoGridHeight"
        :sortable-allow-unsort="true"
        :sortable-show-indexes="true"
        :sortable="{ compare: compareByField }"
        :sort="sortHandler"
        selectable="row"
        @change="onRowClick"
        @databound="onDataBound"
        :style="{ cursor: isPatInfoVisible ? 'default' : 'pointer' }"
        class="ntss-list check-list-main-content-list"
      >
        <kendo-grid-column
          v-for="column in computedColumns"
          :key="column.key"
          :title="column.colName"
          :field="column.field"
          :width="column.width"
          :locked="column.locked"
          :template="column.template"
        />
      </kendo-grid>
    </div>
  </div>
</template>

<script>
import NextTransitionMixin from "@/components/NextTransitionMixin";
import { mapActions, mapGetters } from "vuex";
import { EventBus } from "@/eventBus.js";
import PopoverMixin from "@/components/PopoverMixin";
import { sortableCompare } from "@/functions/SortFunctions";

export default {
  mixins: [NextTransitionMixin, PopoverMixin],
  data() {
    return {
      isReady: false,
      resizeTimer: null,
      resizeObserver: null,
      kendoGridHeight: "100%",
      gridWidth: 0,
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
      image_src_same: require("../../../assets/name_duplication.png"),
    };
  },
  watch: {
    getFilterSignal(val, oldVal) {
      if (val === true && oldVal === false) {
        this.searchList();
        this.setFilterSignal(false);
      }
    },
    $route(to) {
      if (to.name === "pat-info-sharing-detail") {
        this.$nextTick(() => {
          this.updateGridWidth();
        });
      }
    },
    getSelectedPatId(newId) {
      this.$nextTick(() => {
        const grid = this.$refs.shrListGrid?.kendoWidget();
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
    shrListData() {
      const shrInfoList = this.mapPatientList(this.getShrInfoList);
      const filteredPatList = shrInfoList.filter((pat) => {
        const patName = pat.patName;
        const regexp = this.condition.freeWord;
        return (
          (patName && patName.includes(regexp)) ||
          (pat.hospPatId && pat.hospPatId.includes(regexp))
        );
      });
      return filteredPatList;
    },
    computedColumns() {
      const gridWidth = this.gridWidth || 1320;
      const lockedCols = this.shrGridColumns.filter((c) => c.locked);
      const lockedWidth = lockedCols.reduce(
        (sum, c) => sum + (c.width || 0),
        0
      );
      const birthdayWidth = 170;
      const otherFlexColumns = this.shrGridColumns.filter(
        (c) => !c.locked && c.key !== "birthday"
      );
      const remainWidth = gridWidth - lockedWidth - birthdayWidth - 18;
      const avgWidth = Math.max(
        Math.floor(remainWidth / otherFlexColumns.length),
        118
      );
      const imgSrc = this.image_src_same;
      return this.shrGridColumns.map((col) => {
        let newCol = { ...col };
        if (!newCol.locked) {
          if (newCol.key === "birthday") {
            newCol.width = birthdayWidth;
          } else {
            newCol.width = avgWidth;
          }
        }
        if (newCol.key === "patName") {
          newCol.template = (dataItem) => {
            const name = dataItem.patName || "";
            if (dataItem.isSame === "1") {
              return `
                <span class="pat-name-container" style="display: flex; align-items: center;">
                  <span style="overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${name}</span>
                  <img src="${imgSrc}" class="same-icon" style="width:16px; margin-left:4px; flex-shrink:0;" />
                </span>
              `;
            }
            return `<span>${name}</span>`;
          };
        }
        return newCol;
      });
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
    /**
     * フィルター条件設定処理
     */
    setFilterCondition(condition) {
      this.condition = condition;
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
      } finally {
        this.setIsSearching(false);
        await this.setLoadingScreenVisible(false);
      }
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
      this.$nextTick(() => {
        this.syncHoverRow();
      });
      if (targetRow) {
        this.scrollToRow(targetRow);
      }
    },
    /**
     * グリッド幅更新処理
     */
    updateGridWidth() {
      if (this.resizeTimer) clearTimeout(this.resizeTimer);
      this.resizeTimer = setTimeout(() => {
        if (this.$refs.shrListGrid?.$el) {
          const rect = this.$refs.shrListGrid.$el.getBoundingClientRect();
          this.gridWidth = rect.width;
          const grid = this.$refs.shrListGrid.kendoWidget();
          if (grid) {
            grid.resize();
          }
        }
      }, 150);
    },

    /**
     * ロック列と通常列のホバー同期処理
     */
    syncHoverRow() {
      const grid = this.$refs.shrListGrid?.kendoWidget();
      if (!grid) return;
      const lockedRows = grid.lockedTable?.find("tbody tr");
      const normalRows = grid.table?.find("tbody tr");
      if (!lockedRows || !normalRows) return;
      lockedRows.each(function (index) {
        const lockedRow = this;
        const normalRow = normalRows[index];
        if (!normalRow) return;
        lockedRow.addEventListener("mouseenter", () => {
          lockedRow.classList.add("hover-sync");
          normalRow.classList.add("hover-sync");
        });
        lockedRow.addEventListener("mouseleave", () => {
          lockedRow.classList.remove("hover-sync");
          normalRow.classList.remove("hover-sync");
        });
        normalRow.addEventListener("mouseenter", () => {
          lockedRow.classList.add("hover-sync");
          normalRow.classList.add("hover-sync");
        });
        normalRow.addEventListener("mouseleave", () => {
          lockedRow.classList.remove("hover-sync");
          normalRow.classList.remove("hover-sync");
        });
      });
    },
    scrollToRow(row) {
      const grid = this.$refs.shrListGrid?.kendoWidget();
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
    }
  },
  async created() {
    EventBus.$off("filterPatInfoSharingList", this.setFilterCondition);
    EventBus.$off("refresh", this.refresh);
    EventBus.$on("filterPatInfoSharingList", this.setFilterCondition);
    EventBus.$on("refresh", this.refresh);
  },
  mounted() {
    const container = this.$el.querySelector(".shr-list-main-content");
    if (container) {
      this.gridWidth = container.getBoundingClientRect().width;
    }
    this.isReady = true;
    this.$nextTick(() => {
      if (this.$refs.shrListGrid?.$el) {
        this.resizeObserver = new ResizeObserver(() => {
          this.updateGridWidth();
        });
        this.resizeObserver.observe(container);
      }
    });
    window.addEventListener("resize", this.updateGridWidth);
  },
  async beforeDestroy() {
    window.removeEventListener("resize", this.updateGridWidth);
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
    EventBus.$off("filterPatInfoSharingList", this.setFilterCondition);
    EventBus.$off("refresh", this.refresh);
    this.setSelectedPatId("");
    clearTimeout(this.timerObj);
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
}
.shr-list-main-content >>> .k-i-sort-asc-sm::before {
  content: "▲" !important;
  color: #ffffff;
}
.shr-list-main-content >>> .k-i-sort-desc-sm::before {
  content: "▼" !important;
  color: #ffffff;
}
.shr-list-main-content >>> .k-grid-content-locked {
  touch-action: auto;
  -webkit-overflow-scrolling: touch;
  overflow-y: auto;
  scrollbar-width: none;
}
.shr-list-main-content >>> .k-grid-content-locked::-webkit-scrollbar {
  display: none;
}
::v-deep .k-grid tbody tr.null-pat-id-row:not(.selected-row) td,
::v-deep .k-grid-content-locked tbody tr.null-pat-id-row:not(.selected-row) td {
  background-color: #fff3a0 !important;
}
::v-deep .k-grid tbody tr.hover-sync:not(.selected-row) td,
::v-deep .k-grid-content-locked tbody tr.hover-sync:not(.selected-row) td {
  background-color: #eef6ff !important;
}
::v-deep .k-grid tbody tr.null-pat-id-row.hover-sync:not(.selected-row) td,
::v-deep
  .k-grid-content-locked
  tbody
  tr.null-pat-id-row.hover-sync:not(.selected-row)
  td {
  background-color: #f7e671 !important;
}
::v-deep .k-grid tbody tr.selected-row td,
::v-deep .k-grid-content-locked tbody tr.selected-row td {
  background-color: rgba(0, 123, 255, 0.25) !important;
}
::v-deep .k-grid tbody tr.null-pat-id-row.selected-row td,
::v-deep .k-grid-content-locked tbody tr.null-pat-id-row.selected-row td {
  background-color: rgba(0, 123, 255, 0.25) !important;
}
.main-content-area {
  display: flex;
  flex-direction: column;
  height: 100%;
  overflow: hidden;
}
::v-deep .k-grid {
  height: 100% !important;
}
</style>
