<template>
  <div
    id="multi-pat-list-template3"
    ref="gridContainer"
    class="multi-pat-list"
    style="width: 100%; height: 100%"
  >
    <KendoGridView
      ref="grid"
      :columns="kendoColumns"
      :options="gridDataSourceOptions"
      :height="gridHeight"
      :scrollable="gridScrollable"
      :sortable="false"
      :resizable="true"
      :reorderable="true"
      :data-bound="onGridDataBound"
    />
  </div>
</template>

<script>
import { triggerScopedDownload } from "@/functions/common/LayoutMeasureHelper";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import dayjs from "@/compat/date/dayjs";
import * as workbook_1 from "@/functions/common/KendoFunctions";
import * as kendo_file_saver_1 from "@/functions/common/KendoFunctions";
import encoding from "@/compat/encoding/encoding-japanese";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";
import PrintMixin from "@/components/PrintMixin";
import KendoGridView from "@/components/kendo-ui/KendoGridView.vue";

const GRID_PAGE_SIZE = 30;

export default {
  components: {
    KendoGridView,
  },
  mixins: [PrintMixin],
  data() {
    return {
      condition: [],
      layoutData: [],
      dataTitle: [],
      sort: {
        key: "",
        isAsc: true,
      },
      gridHeight: 400,
      isPrintMode: false,
      gridResizeObserver: null,
      scrollQuerySelector: "#multi-pat-list-template3 .k-virtual-scrollable-wrap",
      addClassTargetQuerySelector: ["#multi-pat-list-template3 .k-grid table"],
    };
  },

  computed: {
    ...mapGetters("data-list", [
      "getSelectedDynamicLayout",
      "getRangeDate",
      "getRequestExportExcel",
      "getRequestExportCSV",
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    ...mapGetters("exam-record/list", ["getCondition"]),
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
    }),

    sortLayoutData() {
      const sortField = this.sort.key;
      const isAsc = this.sort.isAsc;
      if (!sortField) return this.layoutData;

      let sorted = [];
      if (sortField.includes(":")) {
        const itemIndex = sortField.split(":")[1];

        sorted = [...this.layoutData].sort((a, b) => {
          const aVal = a.items[itemIndex];
          const bVal = b.items[itemIndex];

          const aIsEmpty = aVal === null || aVal === undefined || aVal === "";
          const bIsEmpty = bVal === null || bVal === undefined || bVal === "";

          if (aIsEmpty && !bIsEmpty) return isAsc ? 1 : -1;
          if (!aIsEmpty && bIsEmpty) return isAsc ? -1 : 1;
          if (aIsEmpty && bIsEmpty) return 0;

          const aNum = Number(aVal);
          const bNum = Number(bVal);
          const aIsNum = !isNaN(aNum);
          const bIsNum = !isNaN(bNum);

          if (aIsNum && !bIsNum) return isAsc ? -1 : 1;
          if (!aIsNum && bIsNum) return isAsc ? 1 : -1;

          if (aIsNum && bIsNum) {
            if (aNum < bNum) return isAsc ? -1 : 1;
            if (aNum > bNum) return isAsc ? 1 : -1;
            return 0;
          }

          if (aVal < bVal) return isAsc ? -1 : 1;
          if (aVal > bVal) return isAsc ? 1 : -1;
          return 0;
        });
      } else {
        sorted = [...this.layoutData].sort((a, b) => {
          return sortableCompare(a, b, sortField, isAsc);
        });
      }

      return sorted;
    },

    gridFlatRows() {
      return this.buildFlatRows(this.sortLayoutData, false);
    },

    gridDataSourceOptions() {
      return {
        data: this.gridFlatRows,
        serverPaging: false,
        pageSize: GRID_PAGE_SIZE,
      };
    },

    gridScrollable() {
      if (this.isPrintMode) {
        return true;
      }
      return { virtual: true };
    },

    kendoColumns() {
      return this.buildKendoColumns();
    },
  },

  watch: {
    getRequestExportExcel() {
      this.onCreateTemplateToExcel();
    },

    getRequestExportCSV() {
      this.exportToCSV();
    },

    getFontSize() {
      this.$nextTick(() => {
        this.updateGridHeight();
        this.$refs.grid?.resize();
      });
    },

    sort: {
      deep: true,
      handler() {
        this.$nextTick(() => {
          this.$refs.grid?.refreshData(this.gridFlatRows);
          this.updateSortHeaderClasses();
        });
      },
    },
  },

  mounted() {
    this.setupGridHeightObserver();
    window.addEventListener("beforeprint", this._preparePrintGrid, true);
    window.addEventListener("afterprint", this._restorePrintGrid, true);
    this.$nextTick(() => this.updateGridHeight());
  },

  methods: {
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage",
    ]),

    gridColumn(def, locked = false) {
      const col = {
        ...def,
        lockable: false,
        headerTemplate: () =>
          this.makeSortableHeader(def.title, def.sortKey || def.field),
      };
      if (locked) {
        col.locked = true;
      }
      return col;
    },

    escapeHtml(text) {
      if (text == null) {
        return "";
      }
      return String(text)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;");
    },

    makeSortableHeader(title, sortKey) {
      return `<span class="clickable-header-label" data-sort-key="${this.escapeHtml(sortKey)}">${this.escapeHtml(title)}</span>`;
    },

    updateSortHeaderClasses() {
      const root = this.$refs.gridContainer?.querySelector(".k-grid");
      if (!root) {
        return;
      }
      root.querySelectorAll("[data-sort-key]").forEach(el => {
        el.classList.remove("sorted-asc", "sorted-desc");
        const sortKey = el.getAttribute("data-sort-key");
        if (!sortKey) {
          return;
        }
        const sortClass = getSortedClass(sortKey, this.sort);
        if (sortClass) {
          el.classList.add(sortClass);
        }
      });
    },

    buildKendoColumns() {
      const columns = [
        this.gridColumn({
          field: "machine_name",
          title: "装置名",
          sortKey: "machine_name",
          width: 150,
        }, true),
        this.gridColumn({
          field: "machine_serial",
          title: "製造番号",
          sortKey: "machine_serial",
          width: 150,
        }, true),
      ];

      const lastDataTitleLocked = this.dataTitle.length > 0
        && this.dataTitle[this.dataTitle.length - 1].locked === true;

      this.dataTitle.forEach((titleObj, index) => {
        let locked = titleObj.locked === true;
        if (lastDataTitleLocked) {
          locked = false;
        }
        const colDef = {
          field: String(titleObj.detailCd),
          title: titleObj.name,
          width: 120,
          sortKey: `title:${index}`,
          headerAttributes: { class: "text-center" },
        };
        columns.push(this.gridColumn(colDef, locked));
      });

      return columns;
    },

    flattenExportColumns(kendoCols) {
      const flat = [];
      kendoCols.forEach(col => {
        if (col.columns) {
          col.columns.forEach(sub => {
            flat.push({
              field: sub.field,
              title: `${col.title}${sub.title}`,
            });
          });
        } else if (col.field) {
          flat.push({
            field: col.field,
            title: col.title,
          });
        }
      });
      return flat;
    },

    buildFlatRows(layoutData, forExport) {
      if (!layoutData || !layoutData.length) {
        return [];
      }
      return layoutData.map(row => {
        const flat = {
          machine_name: row.machine_name,
          machine_serial: row.machine_serial,
        };
        row.items.forEach((value, index) => {
          if (this.dataTitle[index]) {
            flat[String(this.dataTitle[index].detailCd)] = value;
          }
        });
        if (forExport) {
          flat.cellOptions = { wrap: true, format: "@" };
        }
        return flat;
      });
    },

    setupGridHeightObserver() {
      const container = this.$refs.gridContainer;
      if (!container || typeof ResizeObserver === "undefined") {
        return;
      }
      this.gridResizeObserver = new ResizeObserver(() => {
        this.updateGridHeight();
      });
      this.gridResizeObserver.observe(container);
    },

    updateGridHeight() {
      const container = this.$refs.gridContainer;
      if (!container) {
        return;
      }
      const height = container.clientHeight;
      if (height > 0 && height !== this.gridHeight) {
        this.gridHeight = height;
        this.$nextTick(() => this.$refs.grid?.resize());
      }
    },

    onGridDataBound() {
      const root = this.$refs.gridContainer;
      if (!root) {
        return;
      }
      const $root = root.querySelector(".k-grid");
      if (!$root) {
        return;
      }
      const handler = event => {
        const target = event.target.closest("[data-sort-key]");
        if (!target) {
          return;
        }
        const sortKey = target.getAttribute("data-sort-key");
        if (sortKey) {
          this.sortBy(sortKey);
        }
      };
      $root.removeEventListener("click", this._gridSortClickHandler);
      this._gridSortClickHandler = handler;
      $root.addEventListener("click", handler);
      this.updateSortHeaderClasses();
      this.$nextTick(() => this.$refs.grid?.resize());
    },

    _preparePrintGrid() {
      this.isPrintMode = true;
      this.scrollQuerySelector = "#multi-pat-list-template3 .k-grid-content";
      this.$nextTick(() => {
        this.$refs.grid?.setScrollable(true);
        this.$refs.grid?.resize();
      });
    },

    _restorePrintGrid() {
      this.isPrintMode = false;
      this.scrollQuerySelector = "#multi-pat-list-template3 .k-virtual-scrollable-wrap";
      this.$nextTick(() => {
        this.$refs.grid?.setScrollable({ virtual: true });
        this.$refs.grid?.resize();
      });
    },

    sortedClass(key) {
      return getSortedClass(key, this.sort);
    },

    sortBy(key) {
      updateSort(key, this.sort);
    },

    requestrReportParams(param) {
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        let rowTmp = [];
        this.layoutData.forEach(item => {
          if (item.machine_no) {
            rowTmp.push(item.machine_no);
          }
        });
        rowTmp = Array.from(new Set(rowTmp));
        const patListLayoutCd = this.getSelectedDynamicLayout.patListLayoutCd;
        const rangeDate = this.getRangeDate.find(
          d => d.layoutCd === patListLayoutCd
        );
        if (!rangeDate) return;
        const param = {
          patIds: [],
          facilityCd: this.getFacilityCd,
          date: dayjs(Date.now()).format("YYYYMMDD"),
          fromDate: dayjs(Date.now()).format("YYYYMMDD"),
          toDate: dayjs(Date.now()).format("YYYYMMDD"),
          functionCd: "00801",
          machineNos: rowTmp,
        };
        EventBus.$emit("sendReportParams", param);
      }
    },

    async initLayout(flag) {
      this.setLoadingScreenVisible(true);
      const url = `sysDataListDetail/getByLayoutCd/${this.getSelectedDynamicLayout.patListLayoutCd}`;
      let response;
      try {
        response = await ApiHelper.get(url);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        getErrorMessage("TemplateComponent3.vue", "initLayout", error);
        this.setLoadingScreenVisible(false);
      } finally {
        const data = response.data;
        if (data && data.length) {
          this.dataTitle = [];
          this.condition = [];
          data.forEach(x => {
            if (x.dataListDetailCd && x.items[0]) {
              if (x.dataListDetailCd + "" === "1368" || x.dataListDetailCd + "" === "1369" || x.dataListDetailCd + "" === "1370") {
                x.items.forEach(y => this.dataTitle.push({ name: y.name, detailCd: x.dataListDetailCd + "", locked: true }));
              } else if (x.dataListDetailCd + "" !== "1366" && x.dataListDetailCd + "" !== "1367") {
                x.items.forEach(y => this.condition.push({ name: y.name, detailCd: x.dataListDetailCd + "" }));
              }
            }
          });
          if (this.condition.length > 0) {
            this.condition.forEach(dataItem => {
              switch (dataItem.detailCd) {
                case "1371":
                  dataItem.detailCd = "47";
                  break;
                case "1372":
                  dataItem.detailCd = "43";
                  break;
                case "1373":
                  dataItem.detailCd = "44";
                  break;
                case "1374":
                  dataItem.detailCd = "48";
                  break;
                case "1375":
                  dataItem.detailCd = "46";
                  break;
                case "1376":
                  dataItem.detailCd = "45";
                  break;
                case "1377":
                  dataItem.detailCd = "49";
                  break;
                case "1378":
                  dataItem.detailCd = "53";
                  break;
                case "1379":
                  dataItem.detailCd = "54";
                  break;
                case "1380":
                  dataItem.detailCd = "58";
                  break;
                case "1381":
                  dataItem.detailCd = "65";
                  break;
                case "1382":
                  dataItem.detailCd = "64";
                  break;
                case "1383":
                  dataItem.detailCd = "63";
                  break;
              }
            });
          }
          this.dataTitle.push({ name: " ", detailCd: "typeCd", locked: true });
          this.dataTitle.push({ name: " ", detailCd: "detailCd", locked: true });
        }
        this.initData(flag);
      }
    },

    async initData(flag) {
      this.setLoadingScreenVisible(true);
      const url = `sysDataListDetail/getInitData/${this.getSelectedDynamicLayout.templateCd}/${this.getFacilityCd}`;
      let response;
      try {
        response = await ApiHelper.get(url);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        getErrorMessage("TemplateComponent3.vue", "initData", error);
        this.setLoadingScreenVisible(false);
      } finally {
        const data = response.data;
        let initData = [];
        let hasType = this.dataTitle.some(item => item.detailCd === "1368");
        let hasBed = this.dataTitle.some(item => item.detailCd === "1369");
        let hasDate = this.dataTitle.some(item => item.detailCd === "1370");
        if (this.condition.length > 0 && data) {
          data.mstMachineDatalistInits.forEach(mstMachineData => {
            this.condition.forEach(dataItem => {
              let items = [];
              if (hasType) {
                items.push(mstMachineData.machine_type);
              }
              if (hasBed) {
                items.push(mstMachineData.bed_name);
              }
              if (hasDate) {
                if (mstMachineData.setting_date) {
                  items.push(dayjs(mstMachineData.setting_date).format("YYYY/MM/DD"));
                } else {
                  items.push("");
                }
              }
              let typeTmp = "";
              let typeCd = "";
              switch (dataItem.detailCd) {
                case "47":
                  typeTmp = "配管自己診断";
                  typeCd = "1";
                  break;
                case "43":
                  typeTmp = "配管自己診断";
                  typeCd = "1";
                  break;
                case "44":
                  typeTmp = "配管自己診断";
                  typeCd = "1";
                  break;
                case "48":
                  typeTmp = "配管自己診断";
                  typeCd = "1";
                  break;
                case "46":
                  typeTmp = "配管自己診断";
                  typeCd = "1";
                  break;
                case "45":
                  typeTmp = "配管自己診断";
                  typeCd = "1";
                  break;
                case "49":
                  typeTmp = "配管自己診断";
                  typeCd = "1";
                  break;
                case "53":
                  typeTmp = "漏血自己診断";
                  typeCd = "2";
                  break;
                case "54":
                  typeTmp = "漏血自己診断";
                  typeCd = "2";
                  break;
                case "58":
                  typeTmp = "透析液液量自己診断";
                  typeCd = "3";
                  break;
                case "65":
                  typeTmp = "濃度自己診断";
                  typeCd = "4";
                  break;
                case "64":
                  typeTmp = "濃度自己診断";
                  typeCd = "4";
                  break;
                case "63":
                  typeTmp = "濃度自己診断";
                  typeCd = "4";
                  break;
              }
              items.push(typeTmp);
              items.push(dataItem.name);
              initData.push({
                machine_name: mstMachineData.machine_name,
                machine_no: mstMachineData.machine_no,
                machine_serial: mstMachineData.machine_serial,
                machine_type_cd: mstMachineData.machine_type_cd,
                typeCd: typeCd,
                detailCd: dataItem.detailCd,
                items: items,
              });
            });
          });
        }
        this.layoutData = initData;

        if (flag == 1) {
          this.getListData();
        } else {
          this.$nextTick(() => {
            this.$refs.grid?.refreshColumns(this.kendoColumns);
            this.$refs.grid?.refreshData(this.gridFlatRows);
            this.$refs.grid?.resize();
          });
        }
      }
    },

    async getListData() {
      this.setLoadingScreenVisible(true);
      const patListLayoutCd = this.getSelectedDynamicLayout.patListLayoutCd;
      const rangeDate = this.getRangeDate.find(
        d => d.layoutCd === patListLayoutCd
      );
      if (!rangeDate) return;
      let startDate = rangeDate.dayObj.startDate.format("YYYYMMDD");
      let endDate = rangeDate.dayObj.endDate.format("YYYYMMDD");
      const url = `sysDataListDetail/getListData/${this.getSelectedDynamicLayout.templateCd}/${this.getFacilityCd}/${startDate}/${endDate}`;
      let response;
      try {
        response = await ApiHelper.get(url);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        getErrorMessage("TemplateComponent3.vue", "getListData", error);
        this.setLoadingScreenVisible(false);
      } finally {
        const colData = response.data.mntMotionRecordList;
        colData.forEach(motionRecord => {
          let contentsTmp = "";
          let contents;
          if (null !== motionRecord.contents) {
            motionRecord.contents.split(",").forEach(item => {
              contentsTmp = contentsTmp + item.replace(/: (\d+)(\.\d+)/, ': "$1$2"') + ",";
            });
            contents = JSON.parse(contentsTmp.substring(0, contentsTmp.length - 1));
          }
          let hasflg = false;
          if (contents) {
            this.condition.forEach(data => {
              let valueTmp = contents[data.detailCd];
              if (valueTmp && valueTmp !== "") {
                hasflg = true;
                if ((motionRecord.testType + "" === "1" && data.detailCd === "47")
                  || (motionRecord.testType + "" === "4" && data.detailCd === "65")) {
                  if (valueTmp && valueTmp.length > 2) {
                    if (valueTmp.substring(valueTmp.length - 2, valueTmp.length) === "01") {
                      contents[data.detailCd] = "正常";
                    } else {
                      contents[data.detailCd] = "異常";
                    }
                  } else {
                    contents[data.detailCd] = "";
                    hasflg = false;
                  }
                }
              }
            });
          }
          if (hasflg) {
            let eventRegDate = dayjs(motionRecord.eventRegDate).format("YYYY/MM/DD");
            let indexTmp = 0;
            this.dataTitle.forEach((data, index) => {
              if (data.name === eventRegDate) {
                indexTmp = index;
              }
            });
            if (indexTmp === 0) {
              let pushFlg = false;
              this.layoutData.forEach(rowTmp => {
                let valueTmp = "";
                if (rowTmp.machine_serial === motionRecord.machineSerial
                  && rowTmp.machine_type_cd === motionRecord.machineTypeCd
                  && rowTmp.typeCd === motionRecord.testType + "") {
                  valueTmp = contents[rowTmp.detailCd];
                  pushFlg = true;
                }
                rowTmp.items.push(valueTmp);
              });
              if (pushFlg) {
                this.dataTitle.push({ name: eventRegDate, detailCd: eventRegDate, locked: false });
              } else {
                this.layoutData.forEach(rowTmp => {
                  rowTmp.items.splice(rowTmp.items.length - 1);
                });
              }
            } else {
              this.layoutData.forEach(rowTmp => {
                let valueTmp = "";
                if (rowTmp.machine_serial === motionRecord.machineSerial
                  && rowTmp.machine_type_cd === motionRecord.machineTypeCd
                  && rowTmp.typeCd === motionRecord.testType + "") {
                  valueTmp = contents[rowTmp.detailCd];
                }
                if (valueTmp !== "") {
                  rowTmp.items[indexTmp] = valueTmp;
                }
              });
            }
          }
        });
        this.$nextTick(() => {
          this.$refs.grid?.refreshColumns(this.kendoColumns);
          this.$refs.grid?.refreshData(this.gridFlatRows);
          this.$refs.grid?.resize();
        });
      }
    },

    onCreateTemplateToExcel() {
      if (this.sortLayoutData.length === 0) return;

      const columns = this.getColumns();
      const data = this.getData();
      this.saveExcel({
        data: data.length === 0 ? null : data,
        fileName: `データリスト_${dayjs().format("YYYYMMDDHHmmss")}`,
        columns: columns,
      });
    },

    saveExcel(exportOptions) {
      let saveFn = function (dataURL) {
        kendo_file_saver_1.saveAs(dataURL, exportOptions.fileName, {
          forceProxy: exportOptions.forceProxy,
          proxyURL: exportOptions.proxyURL,
        });
      };
      let options = workbook_1.workbookOptions(exportOptions);
      options.sheets.forEach(item => {
        item.rows.forEach(row => {
          if (row.type === "data") {
            let height = 15;
            row.cells.forEach(cell => {
              let vals = 1;
              if (cell.value) {
                vals = (cell.value + "").split("\n").length;
              }
              if (vals * 15 > height) {
                height = vals * 15;
              }
              if (height > 15) {
                cell.wrap = true;
                row.height = height;
              } else {
                cell.wrap = false;
              }
            });
          }
        });
      });
      workbook_1.toDataURL(options).then(saveFn);
    },

    getColumns() {
      if (!this.sortLayoutData || !this.sortLayoutData.length) {
        return [];
      }
      return this.flattenExportColumns(this.buildKendoColumns());
    },

    getData() {
      return this.buildFlatRows(this.sortLayoutData, true);
    },

    exportToCSV() {
      const columns = this.getColumns();
      const data = this.getData();

      let physicalNames = "";
      const arrayFields = [];

      columns.forEach((field, index) => {
        physicalNames += field.title;
        arrayFields.push(field.field);
        if (index <= columns.length - 1) {
          physicalNames += ",";
        }
      });
      physicalNames += "\n";
      let addNewData = [];
      data.forEach(data => {
        const tempData = [];
        arrayFields.forEach(item => {
          if (Object.prototype.hasOwnProperty.call(data, item)) {
            tempData.push(data[item] ?? "");
          }
        });
        addNewData.push(tempData);
      });

      Array(addNewData).forEach(t => {
        Object.values(t).forEach(k => {
          Object.values(k).forEach(r => {
            let temp = String(r);
            if (temp.indexOf(",") > -1) r = temp.replace(temp, '"' + temp + '"');
            else {
              if (r !== null) r = temp.replace(temp, '"' + temp + '"');
              else r = temp.replace(temp, '""');
            }
            physicalNames += `${r},`;
          });
          physicalNames += `\n`;
        });
      });

      const charCodes = [];
      for (let i = 0; i < physicalNames.length; i++) {
        charCodes.push(physicalNames.charCodeAt(i));
      }

      const sjisCodes = encoding.convert(charCodes, "sjis", "unicode");
      const uint8s = new Uint8Array(sjisCodes);
      const blob = new Blob([uint8s], { type: "test/csv" });
      triggerScopedDownload({
        blob,
        filename: `データリスト_${dayjs().format("YYYYMMDDHHmmss")}.csv`,
        root: this.$el,
      });
    },
  },

  async created() {
    EventBus.$on("onInitLayout", this.initLayout);
    EventBus.$on("refresh", this.initLayout);
    EventBus.$on("requestReportParams", this.requestrReportParams);
  },

  beforeUnmount() {
    EventBus.$off("onInitLayout", this.initLayout);
    EventBus.$off("refresh", this.initLayout);
    EventBus.$off("requestReportParams", this.requestrReportParams);

    window.removeEventListener("beforeprint", this._preparePrintGrid, true);
    window.removeEventListener("afterprint", this._restorePrintGrid, true);

    if (this.gridResizeObserver) {
      this.gridResizeObserver.disconnect();
      this.gridResizeObserver = null;
    }

    const root = this.$refs.gridContainer;
    if (root && this._gridSortClickHandler) {
      const grid = root.querySelector(".k-grid");
      if (grid) {
        grid.removeEventListener("click", this._gridSortClickHandler);
      }
    }

    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style>
@media print {
  /** tableレイアウト崩れ回避 */
  body:has(#multi-pat-list-template3) #main-id {
    display: inline-block;
  }
  /** ヘッダレイアウト崩れ回避 */
  body:has(#multi-pat-list-template3) #bbs-search-area {
    width: 60%;
  }
  body:has(#multi-pat-list-template3) .file-button {
    margin-left: 10%;
  }
}
</style>

<style scoped>
.multi-pat-list {
  max-height: 97%;
  background-color: var(--main-background-color);
  color: var(--ntss-list-body-color);
}

/* kendo-grid用style */
.multi-pat-list :deep(.k-grid) {
  background-color: var(--ntss-list-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

.multi-pat-list :deep(.k-widget) {
  font-size: 1em;
}

.multi-pat-list :deep(.k-grid tr),
.multi-pat-list :deep(.k-grid td),
.multi-pat-list :deep(.k-grid th),
.multi-pat-list :deep(.k-grid .k-table-td),
.multi-pat-list :deep(.k-grid .k-table-th),
.multi-pat-list :deep(.k-grid-header-locked th),
.multi-pat-list :deep(.k-grid-header-locked .k-table-th) {
  border-color: var(--master-maintenance-kgrid-border-color) !important;
}

.multi-pat-list :deep(.k-grid tr:hover) {
  background-color: var(--ntss-list-body-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

.multi-pat-list :deep(.k-header) {
  vertical-align: middle !important;
  background-color: var(--ntss-list-header-background-color);
  color: #ffffff;
}
.multi-pat-list :deep(.k-header[data-role='columnsorter']) {
  vertical-align: middle !important;
  background-color: #333333;
  background-image: none;
}

.multi-pat-list :deep(.k-header-disabled) {
  background-color: #808080 !important;
  background-image: none;
}

.multi-pat-list :deep(.k-alt) {
  background-color: var(--ntss-list-content-2nd-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

.multi-pat-list :deep(.k-textbox),
.multi-pat-list :deep(.k-dropdown-wrap),
.multi-pat-list :deep(.k-numeric),
.multi-pat-list :deep(.k-select),
.multi-pat-list :deep(.k-popup),
:global(.multi-pat-list.k-popup),
:global(.multi-pat-list .k-popup) {
  background-color: var(--main-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

.multi-pat-list :deep(.k-picker),
.multi-pat-list :deep(.k-input-inner) {
  background-color: var(--main-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

.multi-pat-list :deep(.k-popup),
:global(.multi-pat-list.k-popup),
:global(.multi-pat-list .k-popup) {
  border-color: var(--ntss-list-body-background-color) !important;
}

.multi-pat-list :deep(.k-popup li:hover),
:global(.multi-pat-list.k-popup li:hover),
:global(.multi-pat-list .k-popup li:hover) {
  background-color: var(--ntss-list-body-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}
.multi-pat-list :deep(.k-i-sort-asc-sm::before) {
  content: "▲" !important;
  color: #ffffff;
}
.multi-pat-list :deep(.k-i-sort-desc-sm::before) {
  content: "▼" !important;
  color: #ffffff;
}

.multi-pat-list :deep(.k-grid td) {
  white-space: pre-line !important;
}

.multi-pat-list :deep(.k-grid .k-table-td) {
  white-space: pre-line !important;
}

.multi-pat-list :deep(.k-grid td.k-edit-cell),
.multi-pat-list :deep(.k-grid .k-table-td.k-edit-cell) {
  white-space: nowrap !important;
  vertical-align: middle !important;
}

.multi-pat-list :deep(.k-grid td.k-edit-cell > *:not(input):not(textarea):not(select)),
.multi-pat-list :deep(.k-grid .k-table-td.k-edit-cell > *:not(input):not(textarea):not(select)) {
  display: inline-flex !important;
  flex-flow: row nowrap !important;
  align-items: center !important;
  vertical-align: middle !important;
  width: auto !important;
  max-width: 100% !important;
  box-sizing: border-box !important;
  min-width: 0 !important;
}

:deep(.multi-pat-list .k-grid td) {
  width: 150px !important;
}

:deep(.multi-pat-list .k-grid .k-table-td) {
  width: 150px !important;
}

@media screen and (max-width: 600px) {
}

:deep(.k-grid td) {
  word-wrap: break-word;
}

:deep(.k-grid .k-table-td) {
  word-wrap: break-word;
}
:deep(.k-grid th) {
  word-wrap: break-word;
}

:deep(.k-grid .k-table-th) {
  word-wrap: break-word;
}

#multi-pat-list-template3 :deep(.k-grid-container td) {
  white-space: nowrap !important;
  overflow: hidden !important;
  text-overflow: ellipsis !important;
}

.multi-pat-list :deep(.clickable-header-label) {
  display: block;
  width: 100%;
  height: 100%;
  padding: 0 4px;
  box-sizing: border-box;
  overflow: hidden;
  cursor: pointer;
}

.multi-pat-list :deep(.k-grid-header th.text-center) {
  text-align: center;
}

@media print {
  .multi-pat-list {
    position: absolute;
  }
  .multi-pat-list :deep(.k-grid-header-wrap),
  .multi-pat-list :deep(.k-grid-content) {
    overflow: hidden !important;
    height: auto !important;
  }
  .multi-pat-list :deep(.k-grid-content-locked) {
    height: auto !important;
  }
  .multi-pat-list :deep(.k-grid-header-locked::after) {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-header-background-color);
    pointer-events: none;
  }
  .multi-pat-list :deep(.k-grid-content-locked::after) {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-border-color);
    pointer-events: none;
  }
  .multi-pat-list :deep(.k-grid-header) {
    padding-right: 0 !important;
  }
  .multi-pat-list :deep(.k-grid) {
    width: 100vw;
    height: auto !important;
  }
  .multi-pat-list:has(table.scroll-rightmost) :deep(.k-grid-content-locked),
  .multi-pat-list:has(table.scroll-rightmost) :deep(.k-grid-header-locked) {
    z-index: 1;
    background-color: inherit;
  }
  .multi-pat-list:has(table.scroll-rightmost) {
    margin-left: -1px !important;
  }
  .multi-pat-list :deep(.k-grid-header-wrap:has(table.scroll-rightmost)),
  .multi-pat-list :deep(.k-grid-content:has(table.scroll-rightmost)) {
    position: static;
  }
}

:deep(.k-grid-lockedcolumns .k-grid-header-locked),
:deep(.k-grid-lockedcolumns .k-grid-content-locked),
:deep(.k-grid-lockedcolumns .k-grid-footer-locked) {
  flex: 0 0 auto;
  flex-shrink: 0;
}

:deep(.k-grid-content) {
  height: 100% !important;
}

:deep(.k-grid-header) {
  background: var(--ntss-list-header-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,0.1) 100%);
}

:deep(.k-grid-header-locked th) {
  background-image: none;
}
</style>
