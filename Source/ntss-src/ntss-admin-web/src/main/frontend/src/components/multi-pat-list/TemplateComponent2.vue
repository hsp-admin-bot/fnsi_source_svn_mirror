<template>
  <div
    id="multi-pat-list-template2"
    ref="gridContainer"
    class="multi-pat-list template2-kendo-grid"
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
import encoding from "@/compat/encoding/encoding-japanese";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import * as workbook_1 from "@/functions/common/KendoFunctions";
import * as kendo_file_saver_1 from "@/functions/common/KendoFunctions";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";
import PrintMixin from "@/components/PrintMixin";
import dayjs from "@/compat/date/dayjs";
import { ApiHelper } from "@/apis/AxiosHelper";
import KendoGridView from "@/components/kendo-ui/KendoGridView.vue";

const GRID_PAGE_SIZE = 30;
const DATE_FIELD_SUFFIX = {
  1362: "time",
  1363: "value",
  1364: "picker",
  1365: "inspector",
};

function getDateFieldSuffix(id) {
  return DATE_FIELD_SUFFIX[id] ?? DATE_FIELD_SUFFIX[Number(id)];
}

export default {
  components: {
    KendoGridView,
  },
  mixins: [PrintMixin],
  data() {
    return {
      condition: [],
      condition2: [],
      layoutData: [],
      layoutDataTmp: [],
      listItems: [],
      dataTitle: [],
      dateList: [],
      hasMachineType: false,
      hasBedName: false,
      hasSettingDate: false,
      // add #11528 【たくしん会】データリスト並び順不正 房 start
      itemCds: [],
      // add #11528 【たくしん会】データリスト並び順不正 房 end
      sort: {
        key: "",
        isAsc: true,
      },
      gridHeight: 400,
      isPrintMode: false,
      gridResizeObserver: null,
      scrollQuerySelector: "#multi-pat-list-template2 .k-virtual-scrollable-wrap",
      addClassTargetQuerySelector: ["#multi-pat-list-template2 .k-grid table"],
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
    ...mapGetters("account-edit", ["getFontSize"]),
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    ...mapGetters("exam-record/list", ["getCondition"]),

    sortedLayoutData() {
      const sortField = this.sort.key;
      const isAsc = this.sort.isAsc;
      if (!sortField) return this.layoutData;

      let sorted = [];
      if (sortField.includes(":")) {
        const [date, field] = sortField.split(":");

        sorted = [...this.layoutData].sort((a, b) => {
          const aDay = a.daylist.find(day => day.d === date);
          const bDay = b.daylist.find(day => day.d === date);
          const aVal = aDay ? aDay[field] : null;
          const bVal = bDay ? bDay[field] : null;

          const aIsEmpty = aVal === null || aVal === undefined || aVal === "";
          const bIsEmpty = bVal === null || bVal === undefined || bVal === "";
          if (aIsEmpty && !bIsEmpty) return isAsc ? 1 : -1;
          if (!aIsEmpty && bIsEmpty) return isAsc ? -1 : 1;
          if (aIsEmpty && bIsEmpty) return 0;
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

    isShowData() {
      return this.getRangeDate.length !== null;
    },
    fixedTitle() {
      return this.dataTitle.filter(x => x.isShow == false);
    },
    showTitle() {
      return this.dataTitle.filter(x => x.isShow == true);
    },
    countGroup() {
      return this.showTitle.length;
    },
    loopTitle() {
      return this.dateList.flatMap(date =>
        this.dataTitle
          .filter(x => x.isShow === true)
          .map(x => ({
            id: x.id,
            name: x.name,
            date,
          }))
      );
    },
    hasTime() {
      return this.loopTitle.some(x => x.name == "採取時刻");
    },
    hasValue() {
      return this.loopTitle.some(x => x.name == "結果");
    },
    hasPicker() {
      return this.loopTitle.some(x => x.name == "採取者");
    },
    hasInspector() {
      return this.loopTitle.some(x => x.name == "検査者");
    },

    gridFlatRows() {
      return this.buildFlatRows(this.sortedLayoutData, false);
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

    fixedTitle() {
      this.hasMachineType = this.fixedTitle.some(x => x.id == 1358);
      this.hasBedName = this.fixedTitle.some(x => x.id == 1359);
      this.hasSettingDate = this.fixedTitle.some(x => x.id == 1360);
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
      const isLocked = this.dateList != null && this.dateList.length > 0;
      const columns = [
        this.gridColumn({
          field: "machine_name",
          title: "装置名",
          sortKey: "machine_name",
          width: 150,
        }, isLocked),
        this.gridColumn({
          field: "machine_serial",
          title: "製造番号",
          sortKey: "machine_serial",
          width: 150,
        }, isLocked),
      ];

      this.fixedTitle.forEach(x => {
        if (x.id == 1358 && this.hasMachineType) {
          columns.push(
            this.gridColumn({
              field: "machine_type",
              title: x.name,
              sortKey: "machine_type",
              width: 120,
            }, isLocked)
          );
        } else if (x.id == 1359 && this.hasBedName) {
          columns.push(
            this.gridColumn({
              field: "bed_name",
              title: x.name,
              sortKey: "bed_name",
              width: 120,
            }, isLocked)
          );
        } else if (x.id == 1360 && this.hasSettingDate) {
          columns.push(
            this.gridColumn({
              field: "setting_date",
              title: x.name,
              sortKey: "setting_date",
              width: 120,
            }, isLocked)
          );
        }
      });

      columns.push(
        this.gridColumn({
          field: "survey_type_name",
          title: "検査種別",
          sortKey: "survey_type_name",
          width: 120,
        }, isLocked),
        this.gridColumn({
          field: "point_name",
          title: "検査箇所",
          sortKey: "point_name",
          width: 120,
        }, isLocked)
      );

      this.dateList.forEach(date => {
        const subColumns = this.showTitle
          .map(item => {
            const suffix = getDateFieldSuffix(item.id);
            if (!suffix) {
              return null;
            }
            return {
              field: `${date}${suffix}`,
              title: item.name,
              width: 100,
              headerTemplate: () =>
                this.makeSortableHeader(item.name, `${date}:${suffix}`),
            };
          })
          .filter(Boolean);

        if (subColumns.length > 0) {
          columns.push({
            title: date,
            headerAttributes: { class: "text-center" },
            columns: subColumns,
          });
        }
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
      const hasTime = this.hasTime;
      const hasValue = this.hasValue;
      const hasPicker = this.hasPicker;
      const hasInspector = this.hasInspector;

      return layoutData.map(row => {
        const flat = { ...row };
        row.daylist.forEach(y => {
          if (hasTime) {
            flat[y.d + "time"] = y.time;
          }
          if (hasValue) {
            flat[y.d + "value"] = y.value;
          }
          if (hasPicker) {
            flat[y.d + "picker"] = y.picker;
          }
          if (hasInspector) {
            flat[y.d + "inspector"] = y.inspector;
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
      this.scrollQuerySelector = "#multi-pat-list-template2 .k-grid-content";
      this.$nextTick(() => {
        this.$refs.grid?.setScrollable(true);
        this.$refs.grid?.resize();
      });
    },

    _restorePrintGrid() {
      this.isPrintMode = false;
      this.scrollQuerySelector = "#multi-pat-list-template2 .k-virtual-scrollable-wrap";
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

    getSortKey(data) {
      const sortKeyMap = {
        1358: "machine_type",
        1359: "bed_name",
        1360: "setting_date",
        1362: "time",
        1363: "value",
        1364: "picker",
        1365: "inspector",
      };

      let sortKey = sortKeyMap[data.id] || "";
      if ([1362, 1363, 1364, 1365].includes(data.id)) {
        sortKey = `${data.date}:${sortKey}`;
      }
      return sortKey;
    },

    async initLayout(flag) {
      this.setLoadingScreenVisible(true);
      const url = `sysDataListDetail/getByLayoutCd/${this.getSelectedDynamicLayout.patListLayoutCd}`;
      let response;
      try {
        response = await ApiHelper.get(url);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        getErrorMessage("TemplateComponent2.vue", "initLayout", error);
        this.setLoadingScreenVisible(false);
        console.log(error);
      } finally {
        this.dataTitle = [];
        const data = response.data;
        if (data && data.length) {
          data.forEach(x => {
            let id = "";
            let name = "";
            let isShow = false;
            if (x.categoryCd == 141) {
              isShow = true;
            }
            if (x.dataListDetailCd && x.items[0]) {
              id = x.dataListDetailCd;
              if (x.dataListDetailCd == "1361") {
                this.condition = [];
                x.items.forEach(y => this.condition.push(y.name));
              } else if (x.dataListDetailCd == "1384") {
                this.condition2 = [];
                this.itemCds = x.itemCds;
                x.items.forEach(y => this.condition2.push(y.name));
              } else {
                name = x.items[0].name;
                this.dataTitle.push({
                  id: id,
                  name: name,
                  isShow: isShow,
                });
              }
            }
          });
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
        getErrorMessage("TemplateComponent2.vue", "initData", error);
        this.setLoadingScreenVisible(false);
        console.log(error);
      } finally {
        const data = response.data;
        let initData = data.mstMachineDatalistInits;
        if (this.condition.length > 0) {
          initData = initData.filter(x =>
            this.condition.some(y => y == x.survey_type_name)
          );
        }
        if (this.condition2.length > 0) {
          initData = initData.filter(x =>
            this.condition2.some(y => y == x.point_name)
          );
        }
        initData = initData.map(x => {
          if (x.setting_date) {
            x.setting_date = dayjs(x.setting_date).format("YYYY/MM/DD");
          }
          return x;
        });
        let key = "";
        let initDataTmp = [];
        let items = null;
        initData.forEach(x => {
          if (key !== "") {
            if (key === x.machine_name + "," + x.bed_name) {
              items.push(x);
            } else {
              key = x.machine_name + "," + x.bed_name;
              items = [];
              initDataTmp.push(items);
              items.push(x);
            }
          } else {
            key = x.machine_name + "," + x.bed_name;
            items = [];
            initDataTmp.push(items);
            items.push(x);
          }
        });
        initData = [];
        initDataTmp.forEach(items => {
          this.condition.forEach(x => {
            items.forEach(item => {
              if (x === item.survey_type_name) {
                initData.push(item);
              }
            });
          });
        });
        key = "";
        initDataTmp = [];
        items = null;
        initData.forEach(x => {
          if (key !== "") {
            if (key === x.machine_name + "," + x.bed_name + "," + x.survey_type_name) {
              items.push(x);
            } else {
              key = x.machine_name + "," + x.bed_name + "," + x.survey_type_name;
              items = [];
              initDataTmp.push(items);
              items.push(x);
            }
          } else {
            key = x.machine_name + "," + x.bed_name + "," + x.survey_type_name;
            items = [];
            initDataTmp.push(items);
            items.push(x);
          }
        });
        initData = [];
        initDataTmp.forEach(items => {
          this.condition2.forEach(x => {
            items.forEach(item => {
              if (x === item.point_name) {
                initData.push(item);
              }
            });
          });
        });
        this.layoutDataTmp = initData;
        this.layoutDataTmp.sort((a, b) => {
          let aIndex = this.itemCds.findIndex(itemCode => itemCode == a.survey_point_cd);
          let bIndex = this.itemCds.findIndex(itemCode => itemCode == b.survey_point_cd);
          return aIndex - bIndex;
        });
        if (flag == 1) {
          this.getListData();
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
      let startDate = rangeDate.dayObj.startDate;
      let endDate = rangeDate.dayObj.endDate;
      const url = `sysDataListDetail/getListData/${this.getSelectedDynamicLayout.templateCd}/${this.getFacilityCd}/${startDate}/${endDate}`;
      const urlDecimal = `sysDataListDetail/getDecimalValue/${this.getFacilityCd}`;
      let response;
      let responseDecimal;
      try {
        response = await ApiHelper.get(url);
        responseDecimal = await ApiHelper.get(urlDecimal);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        getErrorMessage("TemplateComponent2.vue", "getListData", error);
        this.setLoadingScreenVisible(false);
        console.log(error);
      } finally {
        const colData = response.data.mstMachineDatalists;
        const userList = response.data.mstPersonalUsers;
        const decimalValue = responseDecimal.data;
        let date_list = [];
        colData.forEach(x =>
          date_list.push(x.inspection_date.substring(0, 10).replace(/-/g, "/"))
        );
        date_list = Array.from(new Set(date_list));
        date_list = date_list.sort(
          (a, b) => a.replace(/\//g, "") - b.replace(/\//g, "")
        );
        this.dateList = date_list;
        let rowData = this.layoutDataTmp;
        rowData = rowData.map(row => {
          let daylist = [];
          date_list.forEach(x => {
            daylist.push({
              d: x,
              time: " ",
              value: " ",
              picker: " ",
              inspector: " ",
            });
          });
          row.daylist = daylist;

          colData.forEach(col => {
            let colDate = col.inspection_date
              .substring(0, 10)
              .replace(/-/g, "/");
            if (col.survey_point_cd == row.survey_point_cd) {
              let daylistFilter = row.daylist.filter(x => x.d == colDate);
              let index = row.daylist.indexOf(daylistFilter[0]);
              let value = "";
              if (col.value) {
                let resultFigure = col.value;
                if (decimalValue.length > 0) {
                  for (let de = 0; de < decimalValue.length; de++) {
                    if (de.surveyPointCd === Number(col.survey_point_cd)) {
                      let num = "1";
                      for (let i = 0; i < de.decimalDigits; i++) {
                        num += "0";
                      }
                      let f_x = Math.round(Number(col.value) * parseInt(num)) / parseInt(num);
                      let s_x = f_x.toString();
                      let pos_decimal = s_x.indexOf(".");
                      if (pos_decimal < 0) {
                        pos_decimal = s_x.length;
                        s_x += ".";
                      }
                      while (s_x.length <= pos_decimal + de.decimalDigits) {
                        s_x += "0";
                      }
                      resultFigure = s_x;
                    }
                  }
                }
                value = resultFigure + col.unit;
              }
              let initial_string = JSON.parse(col.initial_string);
              let text = Number(col.text) - 1;
              if (text > -1 && text < initial_string.length) {
                value = value + initial_string[text].text;
              }
              let picker = "";
              let pUser = userList.filter(u => u.userId == col.picker);
              if (pUser.length > 0) {
                picker = pUser[0].userLastName + " " + pUser[0].userFirstName;
              }
              let inspector = "";
              let iUser = userList.filter(u => u.userId == col.inspector);
              if (iUser.length > 0) {
                inspector =
                  iUser[0].userLastName + " " + iUser[0].userFirstName;
              }

              if (!value && (col.time || picker || inspector)) {
                value = "検査中";
              }

              let data = {
                d: colDate,
                time: col.time,
                value: value,
                picker: picker,
                inspector: inspector,
              };
              row.daylist.splice(index, 1, data);
            }
          });
          return row;
        });
        let rowDataTmp = [];
        let rowTmp = [];
        rowData.forEach(item => {
          let key =
            item.machineTypeCd +
            item.machine_name +
            item.machine_serial +
            item.machine_type +
            item.bed_name +
            item.setting_date +
            item.survey_type_name +
            item.point_name;
          if (rowTmp.indexOf(key) === -1) {
            rowDataTmp.push(item);
            rowTmp.push(key);
          }
        });
        this.layoutData = rowDataTmp;
        this.$nextTick(() => {
          this.$refs.grid?.refreshColumns(this.kendoColumns);
          this.$refs.grid?.refreshData(this.gridFlatRows);
          this.$refs.grid?.resize();
        });
      }
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

    onCreateTemplateToExcel() {
      if (this.sortedLayoutData.length === 0) return;

      const columns = this.getColumns(this.sortedLayoutData);
      const data = this.getData(this.sortedLayoutData);
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

    getColumns(layoutData) {
      if (!layoutData || !layoutData.length) {
        return [];
      }
      return this.flattenExportColumns(this.buildKendoColumns());
    },

    getData(layoutData) {
      return this.buildFlatRows(layoutData, true);
    },

    exportToCSV() {
      const columns = this.getColumns(this.sortedLayoutData);
      const data = this.getData(this.sortedLayoutData);

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
        Object.keys(data).forEach(key => {
          if (!arrayFields.includes(key)) {
            return;
          } else {
            tempData.push(data[key]);
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
  body:has(#multi-pat-list-template2) #main-id {
    display: inline-block;
  }
  /** ヘッダレイアウト崩れ回避 */
  body:has(#multi-pat-list-template2) #bbs-search-area {
    width: 60%;
  }
  body:has(#multi-pat-list-template2) .file-button {
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
/* 全体の色 */
.multi-pat-list :deep(.k-grid) {
  background-color: var(--ntss-list-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

.multi-pat-list :deep(.k-widget) {
  font-size: 1em;
}

/* セルの枠線(なぜか縦線にしか色がつかない) */
.multi-pat-list :deep(.k-grid tr),
.multi-pat-list :deep(.k-grid td),
.multi-pat-list :deep(.k-grid th),
.multi-pat-list :deep(.k-grid .k-table-td),
.multi-pat-list :deep(.k-grid .k-table-th),
.multi-pat-list :deep(.k-grid-header-locked th),
.multi-pat-list :deep(.k-grid-header-locked .k-table-th) {
  border-color: var(--master-maintenance-kgrid-border-color) !important;
}

/* 行マウスオーバー */
.multi-pat-list :deep(.k-grid tr:hover) {
  background-color: var(--ntss-list-body-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

/* 列ヘッダ */
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

/* 入力不可列のヘッダ */
.multi-pat-list :deep(.k-header-disabled) {
  background-color: #808080 !important;
  background-image: none;
}

/* 偶数行 */
.multi-pat-list :deep(.k-alt) {
  background-color: var(--ntss-list-content-2nd-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

/* 入力UI */
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

/* kendoDropDownListの選択肢 */
.multi-pat-list :deep(.k-popup),
:global(.multi-pat-list.k-popup),
:global(.multi-pat-list .k-popup) {
  border-color: var(--ntss-list-body-background-color) !important;
}

/* kendoDropDownListの選択肢のマウスオーバー */
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

/* 編集セルは折り返さない（上記 pre-line より優先） */
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

#multi-pat-list-template2 :deep(.k-grid-container td) {
  white-space: nowrap !important;
  overflow: hidden !important;
  text-overflow: ellipsis !important;
}

/* Template2 ソート用カスタムヘッダ */
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
  /** スクロールコンテナ */
  .multi-pat-list :deep(.k-grid-header-wrap),
  .multi-pat-list :deep(.k-grid-content) {
    overflow: hidden !important;
    height: auto !important;
  }
  /** 固定列調整 */
  .multi-pat-list :deep(.k-grid-content-locked) {
    height: auto !important;
  }
  /** 固定列枠線 */
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
  /** ヘッダのズレ原因を除去 */
  .multi-pat-list :deep(.k-grid-header) {
    padding-right: 0 !important;
  }
  /** gridの幅 */
  .multi-pat-list :deep(.k-grid) {
    width: 100vw;
    height: auto !important;
  }
  /** 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  /* 右端時固定列最前面表示*/
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

/* Vue2 Kendo locked layout contract.
   Kendo 2026 renders locked content inside flex containers; keep the locked area
   at the width Kendo/column definitions already calculated, as Kendo 2019 did. */
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
  background: var(--ntss-list-header-background-color) !important;
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,0.1) 100%) !important;
}

:deep(.k-grid-header-locked th) {
  background-image: none;
}
</style>
