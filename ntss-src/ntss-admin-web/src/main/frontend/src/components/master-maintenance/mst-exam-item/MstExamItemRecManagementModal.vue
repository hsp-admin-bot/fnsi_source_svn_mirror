// 再検査計算管理
<template>
  <modal-base @onClose="hideModal">
    <template #body>
      <div class="modal-body-content">
        <div class="tool-bar">
          <v-ons-button
            class="btn3-normal add-btn"
            @click="showMstExamItemRecBookingModal"
            :disabled="addBtnDisabled"
            >予約追加</v-ons-button
          >
        </div>
        <div class="grid-content">
          <div
            ref="grid"
            class="ntss-kendo-grid-legacy mst-exam-item-rec-management-direct-jq-grid"
          ></div>
        </div>
      </div>
    </template>
    <template #footer>
      <div class="flex-container">
        <v-ons-button
          class="btn2-cancel common-style-cancel-button"
          @click="hideModal"
          :disabled="false"
          >閉じる</v-ons-button
        >
      </div>
    </template>
  </modal-base>
</template>

<script>
import dayjs from "@/compat/date/dayjs";
import { markRaw } from "@/compat/vue/runtime";
import { ApiHelper } from "@/apis/AxiosHelper";
import { mapState, mapActions } from "@/compat/vue/vuex";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import ModalBase from "@/components/modals/ModalBase";
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

export default {
  name: "MstExamItemRecManagementModal",
  components: {
    "modal-base": ModalBase,
  },
  data() {
    return {
      columns: [
        { field: "regDate", title: "予約追加日時", width: '10em' },
        { field: "status", title: "状態", width: '10em' },
        { field: "date", title: "対象期間", width: '15em', template: `<span class="#: fromDate === '' ? 'placeholder' : '' #">#: date # </span>` },
        { field: "patient_count", title: "患者数", width: '5em' },
        {
          field: "item_count",
          title: "検査計算項目数",
          width: '9em',
        },
        { field: "progress", title: "進捗", width: '8em' },
        { field: "", title: "中止", width: '6em' },
      ],
      localDataSource: [],
      directGridWidget: null,
      directGridDataSource: null,
      directGridColumnSignature: "",
      directGridLayoutRafId: null,
    };
  },
  computed: {
    ...mapState("user", ["facilityCd"]),
    ...mapState("master-maintenance", ["facilitySwitch"]),
    ...mapState("account-edit", ["userAccountInfo", "fontSize"]),
    ...mapState("window-size", ["windowWidth", "windowHeight"]),
    addBtnDisabled() {
      return ['処理中', '未処理', '処理中(処理時間外)'].includes(this.localDataSource?.[0]?.status);
    },
  },
  methods: {
    getGridRoot() {
      return this.$refs.grid || null;
    },
    getGridWidget() {
      return this.directGridWidget || null;
    },
    getGridContent() {
      return this.getGridRoot()?.querySelector?.(".k-grid-content") || null;
    },
    buildColumnSignature(columns = this.columns) {
      return (columns || []).map(column => [
        column.field,
        column.title,
        column.width,
        column.template ? "template" : "",
      ].join(":")) .join("|");
    },
    buildDirectGridColumns() {
      return (this.columns || []).map((col) => {
        if (col.title === "中止") {
          return {
            title: col.title,
            width: col.width,
            command: [{
              text: "中止",
              click: event => this.handleDiscontinue(event),
              className: "btn3-normal shutdown-btn",
              visible: function(dataItem) {
                return dataItem.index === 0 && ["未処理", "処理中(処理時間外)"].includes(dataItem.status);
              },
            }]
          };
        }
        return {
          field: col.field,
          title: col.title,
          width: col.width,
          template: col.template,
        };
      });
    },
    createDirectGridDataSource() {
      this.directGridDataSource = markRaw(new kendo.data.DataSource({
        data: Array.isArray(this.localDataSource) ? this.localDataSource : []
      }));
      return this.directGridDataSource;
    },
    initDirectGridIfReady() {
      const root = this.getGridRoot();
      if (!root || !this.columns?.length) {
        return;
      }
      if (this.directGridWidget) {
        this.refreshDirectGridDataSource();
        this.applyDirectGridColumnsContract();
        this.scheduleDirectGridLayoutContract();
        return;
      }
      installComponentJQuery();
      $(root).empty();
      $(root).kendoGrid({
        dataSource: this.createDirectGridDataSource(),
        height: "100%",
        columns: this.buildDirectGridColumns(),
        scrollable: true,
        dataBound: () => {
          this.applyDirectGridStyleContract();
          this.scheduleDirectGridLayoutContract();
        }
      });
      this.directGridWidget = markRaw($(root).data("kendoGrid"));
      this.directGridColumnSignature = this.buildColumnSignature();
      this.installDirectGridFacade();
      this.applyDirectGridStyleContract();
    },
    destroyDirectGrid() {
      if (this.directGridWidget) {
        try {
          this.directGridWidget.destroy();
        } catch (_error) {
          // noop
        }
      }
      const root = this.getGridRoot();
      if (root) {
        $(root).empty();
      }
      this.directGridWidget = null;
      this.directGridDataSource = null;
      this.directGridColumnSignature = "";
    },
    installDirectGridFacade() {
      const root = this.getGridRoot();
      if (!root) {
        return;
      }
      root.kendoWidget = () => this.directGridWidget;
      root.gridWidget = () => this.directGridWidget;
      root.gridContentEl = () => this.getGridContent();
      root.refreshGrid = () => this.refreshGrid();
    },
    refreshGrid() {
      const grid = this.getGridWidget();
      if (!grid) {
        return;
      }
      grid.refresh?.();
      this.applyDirectGridStyleContract();
      this.scheduleDirectGridLayoutContract();
    },
    refreshDirectGridDataSource() {
      const grid = this.getGridWidget();
      if (!grid?.dataSource) {
        this.$nextTick(() => this.initDirectGridIfReady());
        return;
      }
      grid.dataSource.data(Array.isArray(this.localDataSource) ? this.localDataSource : []);
      this.scheduleDirectGridLayoutContract();
    },
    applyDirectGridColumnsContract() {
      const grid = this.getGridWidget();
      if (!grid) {
        return;
      }
      const signature = this.buildColumnSignature();
      if (signature !== this.directGridColumnSignature) {
        grid.setOptions({ columns: this.buildDirectGridColumns() });
        this.directGridColumnSignature = signature;
        this.installDirectGridFacade();
      }
    },
    applyDirectGridStyleContract() {
      const root = this.getGridRoot();
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
    scheduleDirectGridLayoutContract() {
      if (this.directGridLayoutRafId != null) {
        cancelAnimationFrame(this.directGridLayoutRafId);
      }
      this.directGridLayoutRafId = requestAnimationFrame(() => {
        this.directGridLayoutRafId = null;
        this.applyDirectGridStyleContract();
      });
    },
    ...mapActions("loading-screen", ["setLoadingScreenVisible", "setLoadingScreenMessage"]),
    ...mapActions("multi-modal", [
      "hideModal",
      "showMstExamItemRecBookingModal",
    ]),
    getMntRecalcQueList() {
      this.setLoadingScreenVisible(true);
      const statusContrast = {
        0: "未処理",
        1: "処理中",
        2: "完了",
        3: "中止",
        4: "処理中(処理時間外)",
        8: "エラー",
        9: "中止",
      };
      ApiHelper.get(`/exam/MntRecalcQue/${this.facilityCd}`).then(
        (response) => {
          const data = response.data;
          data.forEach((item, index) => {
            item.index = index;
            item.regDate = dayjs(item.regDate).format("YYYY/MM/DD HH:mm");
            // item.upDate = dayjs(item.upDate).format("YYYY/MM/DD HH:mm");
            item.status = statusContrast[item.status];
            const content = JSON.parse(item.content);
            item.toDate = content.to_date?.replaceAll('-', '/');
            item.fromDate = content.from_date?.replaceAll('-', '/');
            item.date = `${item.fromDate}  ～  ${item.toDate}`;
            item.detail = JSON.parse(item.detail);
            item.patient_count = content.pat_id.length;
            item.item_count = content.item.length;
            item.calcPatId = JSON.parse(item.calcPatId);
            item.progress =
              (item.calcPatId?.calc_pat_id?.length || 0) +
              " / " +
              item.patient_count + ' 人';
          });
          this.localDataSource = data;
          this.$nextTick(() => this.refreshDirectGridDataSource());
        }).catch(error => {
         getErrorMessage('MstExamItemRecManagementModal.vue', 'getMntRecalcQueList', error);
         throw error;
      }).finally(() => {
        this.setLoadingScreenVisible(false);
      });
    },
    handleDiscontinue() {
      const dataItem = this.localDataSource[0];
      this.setLoadingScreenVisible(true);
      ApiHelper.post("/exam/updateMntRecalcQue", {
        status: "9",
        content: dataItem?.content,
        upId: this.userAccountInfo.userId,
        recalcQueCd: dataItem?.recalcQueCd
      }).then(() => {
        this.getMntRecalcQueList();
      }).catch(error => {
         getErrorMessage('MstExamItemRecManagementModal.vue', 'handleDiscontinue', error);
         throw error;
      }).finally(() => {
        this.setLoadingScreenVisible(false);
      });
    },
  },
  mounted() {
    this.setLoadingScreenMessage("処理中・・・");
    this.getMntRecalcQueList();
    this.$nextTick(() => this.initDirectGridIfReady());
  },
  beforeUnmount() {
    if (this.directGridLayoutRafId != null) {
      cancelAnimationFrame(this.directGridLayoutRafId);
      this.directGridLayoutRafId = null;
    }
    this.destroyDirectGrid();
  },
  watch: {
    localDataSource() {
      this.refreshDirectGridDataSource();
    },
    windowWidth() {
      this.refreshGrid();
    },
    windowHeight() {
      this.refreshGrid();
    },
    fontSize() {
      this.refreshGrid();
    }
  }
};
</script>

<style lang="css" scoped>
:deep(.k-widget) {
  font-size: 1em;
}
:deep(.modal-body) {
  width: calc(100% - 16px);
  height: calc(100% - 76px - 2em);
  left: 8px;
}
.modal-body-content {
  width: 100%;
  height: 100%;
}
.tool-bar {
  width: 100%;
  display: inline-block;
}
.add-btn {
  float: right;
  width: auto;
}
:deep(.shutdown-btn) {
  font-size: 1em;
}
.grid-content {
  height: calc(100% - 3em);
  width: 100%;
}
:deep(.placeholder) {
  padding-left: 84px;
}
:deep(.flex-container) {
  flex-direction: column;
}
:deep(.btn2-cancel) {
  align-self: flex-end;
}
:deep(.k-grid td) {
  border-width: 0 1px 1px 0 !important;
  border-color: var(--master-maintenance-kgrid-border-color);
}

:deep(.k-grid .k-table-td) {
  border-width: 0 1px 1px 0 !important;
  border-color: var(--master-maintenance-kgrid-border-color);
}
.mst-exam-item-rec-management-direct-jq-grid {
  height: 100%;
}
</style>
