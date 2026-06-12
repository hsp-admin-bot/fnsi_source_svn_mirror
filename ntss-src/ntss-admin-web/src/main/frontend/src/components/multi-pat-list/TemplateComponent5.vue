<template>
  <!-- 集計 -->
  <div
    id="multi-pat-list-template5"
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
      // add #11528 【たくしん会】データリスト並び順不正 房 start
      condition: [],
      // add #11528 【たくしん会】データリスト並び順不正 房 end
      condition1: [],
      condition2: [],
      layoutData: [],
      dateTitle: [],
      dataTitle: [],
      isDis: false,
      hasDetail: false,
      hasMec: false,
      hasMecPass: false,
      hasMecNg: false,
      hasMecSch: false,
      mecName: "",
      mecPassName: "",
      mecNgName: "",
      mecSchName: "",
      sort: {
        key: "",
        isAsc: true,
      },
      gridHeight: 400,
      isPrintMode: false,
      gridResizeObserver: null,
      scrollQuerySelector: "#multi-pat-list-template5 .k-virtual-scrollable-wrap",
      addClassTargetQuerySelector: ["#multi-pat-list-template5 .k-grid table"],
    };
  },

  computed: {
    ...mapGetters('data-list', [
      'getSelectedDynamicLayout',
      'getRangeDate',
      'getRequestExportExcel',
      'getRequestExportCSV',
    ]),
    ...mapGetters('user', ['getFacilityCd']),
    ...mapGetters('pat-info', ['searchedPatList', 'selectedPatId']),
    ...mapGetters('exam-record/list', ['getCondition']),
    ...mapGetters('account-edit', ['getFontSize']),
    
    sortedLayoutData() {
      const sortField = this.sort.key;
      const isAsc = this.sort.isAsc;
      // ソートなしは元のリストをそのままreturn
      if (!sortField) return this.layoutData;

      let sorted = [];
      // レイアウトカテゴリ名、レイアウト名以外は個別にソート
      if (sortField.includes(":")) {
        const itemIndex = sortField.split(":")[1]; // ソート対象の可変列のインデックス
        const isAsc = this.sort.isAsc;
        
        // ソートキーの列が非表示の場合はソート実行しない。元のリストをそのままreturn（抽出条件変更時やパンくずリスト押下時）
        if (!this.layoutData[0]?.items || itemIndex >= this.layoutData[0].items.length) return this.layoutData;
        
        sorted = [...this.layoutData].sort((a, b) => {
          const aVal = Number(a.items[itemIndex].value);
          const bVal = Number(b.items[itemIndex].value);
        
          const aIsEmpty = isNaN(aVal);
          const bIsEmpty = isNaN(bVal);
        
          // 空欄（数値に変換できない）の扱い（昇順なら後方、降順なら前方）
          if (aIsEmpty && !bIsEmpty) return isAsc ? 1 : -1;
          if (!aIsEmpty && bIsEmpty) return isAsc ? -1 : 1;
          if (aIsEmpty && bIsEmpty) return 0;
        
          // 数値として比較
          if (aVal < bVal) return isAsc ? -1 : 1;
          if (aVal > bVal) return isAsc ? 1 : -1;
          return 0;
        });
      } else {
        // 共通関数でソート
        sorted = [...this.layoutData].sort((a, b) => {
          return sortableCompare(a, b, sortField, isAsc);
        });
      }
  
      return sorted;
    },
    countGroup() {
      let iCount = 0;
      if (this.hasMecPass) {
        iCount = iCount + 1;
      }
      if (this.hasMecNg) {
        iCount = iCount + 1;
      }
      if (this.hasMecSch) {
        iCount = iCount + 1;
      }
      return iCount;
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
    ...mapActions('loading-screen', [
      'setLoadingScreenVisible',
      'setLoadingScreenMessage',
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
      const displayTitle = title == null ? "" : String(title);
      return `<span class="clickable-header-label" data-sort-key="${this.escapeHtml(sortKey)}">${this.escapeHtml(displayTitle)}</span>`;
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
      const isLocked = this.dateTitle != null && this.dateTitle.length > 0;
      const columns = [];

      if (this.isDis) {
        columns.push(
          this.gridColumn({
            field: "layout_category_name",
            title: " ",
            sortKey: "layout_category_name",
            width: 120,
          }, isLocked)
        );
      }

      columns.push(
        this.gridColumn({
          field: "layout_name",
          title: " ",
          sortKey: "layout_name",
          width: 150,
        }, isLocked)
      );

      this.dateTitle.forEach((date, dateIndex) => {
        const subColumns = [];
        let subIndex = 0;

        if (this.hasMecSch) {
          const flatIndex = dateIndex * this.countGroup + subIndex;
          const title = this.dataTitle[flatIndex] || "装置台数";
          subColumns.push({
            field: `${date} mecSch`,
            title,
            width: 100,
            headerTemplate: () =>
              this.makeSortableHeader(title, `title:${flatIndex}`),
          });
          subIndex += 1;
        }
        if (this.hasMecPass) {
          const flatIndex = dateIndex * this.countGroup + subIndex;
          const title = this.dataTitle[flatIndex] || "合格台数";
          subColumns.push({
            field: `${date} mecPass`,
            title,
            width: 100,
            headerTemplate: () =>
              this.makeSortableHeader(title, `title:${flatIndex}`),
          });
          subIndex += 1;
        }
        if (this.hasMecNg) {
          const flatIndex = dateIndex * this.countGroup + subIndex;
          const title = this.dataTitle[flatIndex] || "不合格台数";
          subColumns.push({
            field: `${date} mecNg`,
            title,
            width: 100,
            headerTemplate: () =>
              this.makeSortableHeader(title, `title:${flatIndex}`),
          });
        }

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
              title: `${col.title} ${sub.title}`,
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
        const flat = {};
        if (this.isDis) {
          flat.layout_category_name = row.layout_category_name;
        }
        flat.layout_name = row.layout_name;
        row.items.forEach((item, index) => {
          const indexDate = Math.floor(index / this.countGroup);
          flat[this.dateTitle[indexDate] + item.key] = item.value;
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
      this.scrollQuerySelector = "#multi-pat-list-template5 .k-grid-content";
      this.$nextTick(() => {
        this.$refs.grid?.setScrollable(true);
        this.$refs.grid?.resize();
      });
    },

    _restorePrintGrid() {
      this.isPrintMode = false;
      this.scrollQuerySelector = "#multi-pat-list-template5 .k-virtual-scrollable-wrap";
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

    refreshGrid() {
      this.$nextTick(() => {
        this.$refs.grid?.refreshColumns(this.kendoColumns);
        this.$refs.grid?.refreshData(this.gridFlatRows);
        this.$refs.grid?.resize();
      });
    },

    requestrReportParams(param) {
      // 機能コード判定

      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // add #9113 【IES起票】データ画面にて機能帳票でブレビューを押下するとエラーがでる liuc start
        let rowTmp = [];
        this.layoutData.forEach(item => {
          if (item.machine_no) {
            rowTmp.push(item.machine_no);
          }
        });
        rowTmp = Array.from(new Set(rowTmp));
        // add #9113  【IES起票】データ画面にて機能帳票でブレビューを押下するとエラーがでる liuc end
        // 機能一致
        // 印刷パラメータを応答
        // mod #9113 【IES起票】データ画面にて機能帳票でブレビューを押下するとエラーがでる liuc start
        // const param = {
        //   patId: this.selectedPatId,
        //   patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
        //   facilityCd: this.getFacilityCd,
        // };
        const param = {
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //patId: this.selectedPatId,
          date: dayjs(Date.now()).format("YYYYMMDD"),
          fromDate: dayjs(Date.now()).format("YYYYMMDD"),
          toDate: dayjs(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: dayjs(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          patIds: [],
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          facilityCd: this.getFacilityCd,
          functionCd: "00801",
          machineNos: rowTmp
        };
        // mod #9113 【IES起票】データ画面にて機能帳票でブレビューを押下するとエラーがでる liuc end
        EventBus.$emit('sendReportParams', param);
      }
    },
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
    async initLayout(flag) {
      this.setLoadingScreenVisible(true);
      const url = `sysDataListDetail/getByLayoutCd/${this.getSelectedDynamicLayout.patListLayoutCd}`;
      let response;
      try {
        response = await ApiHelper.get(url);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        getErrorMessage('TemplateComponent5.vue', 'initLayout', error);
        this.setLoadingScreenVisible(false);
        console.log(error);
      } finally {
        const data = response.data;
        if (data && data.length) {
          // add #11528 【たくしん会】データリスト並び順不正 房 start
          this.condition = [];
          // add #11528 【たくしん会】データリスト並び順不正 房 end
          this.condition1 = [];
          this.condition2 = [];
          this.isDis = false;
          this.hasDetail = false;
          this.hasMecPass = false;
          this.hasMecNg = false;
          this.hasMecSch = false;
          this.mecName = "";
          this.mecPassName = "";
          this.mecNgName = "";
          this.mecSchName = "";
          data.forEach(x => {
            if (x.dataListDetailCd && x.items[0]) {
              if (x.dataListDetailCd + '' === '1352') {
                this.isDis = true;
              } else if (x.dataListDetailCd + '' === '1354') {
                this.hasMecPass = true;
                this.mecPassName = x.items[0].name;
              } else if (x.dataListDetailCd + '' === '1355') {
                this.hasMecNg = true;
                this.mecNgName = x.items[0].name;
              } else if (x.dataListDetailCd + '' === '1440') {
                this.hasMecSch = true;
                this.mecSchName = x.items[0].name;
              } else if (x.dataListDetailCd + '' === '1350') {
                // mod #11528 【たくしん会】データリスト並び順不正 房 start
                x.items.sort((a, b) => {
                  let aIndex = x.itemCds.findIndex(itemCd => a.id == itemCd);
                  let bIndex = x.itemCds.findIndex(itemCd => b.id == itemCd);
                  return aIndex - bIndex;
                });
                x.items.forEach(y => {
                  this.condition1.push({name: y.name, detailCd: y.id + ''});
                  this.condition.push({name: y.name, detailCd: y.id + '', type: 1});
                });
                // mod #11528 【たくしん会】データリスト並び順不正 房 end
              } else if (x.dataListDetailCd + '' === '1351') {
                // mod #11528 【たくしん会】データリスト並び順不正 房 start
                x.items.sort((a, b) => {
                  let aIndex = x.itemCds.findIndex(itemCd => a.id == itemCd);
                  let bIndex = x.itemCds.findIndex(itemCd => b.id == itemCd);
                  return aIndex - bIndex;
                });
                x.items.forEach(y => {
                  this.condition2.push({name: y.name, detailCd: y.id + ''});
                  this.condition.push({name: y.name, detailCd: y.id + '', type: 2});
                });
                // mod #11528 【たくしん会】データリスト並び順不正 房 end
              }
            }
          });
        }
        if (this.hasMecPass || this.hasMecNg || this.hasMecSch) {
          this.hasDetail = true;
        }
        this.initData(flag);
      }
    },

    async initData(flag) {
      let initData = [];
      this.layoutData = [];
      // add #11528 【たくしん会】データリスト並び順不正 房 start
      this.condition.forEach(condition => {
        let items = [];
        if(condition.type === 1) {
          initData.push({
            type: 1,
            layout_category_name: "日常点検",
            layout_name: condition.name,
            detailCd: condition.detailCd,
            items: items
          });
        } else {
          initData.push({
            type: 2,
            layout_category_name: "定期点検",
            layout_name: condition.name,
            detailCd: condition.detailCd,
            items: items
          });
        }
      })
      // add #11528 【たくしん会】データリスト並び順不正 房 end
      // del #11528 【たくしん会】データリスト並び順不正 房 start
      // if (this.condition1.length > 0 || this.condition2.length > 0) {
      //   this.condition1.forEach(condition => {
      //     let items = [];
      //     initData.push({
      //       type: 1,
      //       layout_category_name: "日常点検",
      //       layout_name: condition.name,
      //       detailCd: condition.detailCd,
      //       items: items
      //     });
      //   });
      //   this.condition2.forEach(condition => {
      //     let items = [];
      //     initData.push({
      //       type: 2,
      //       layout_category_name: "定期点検",
      //       layout_name: condition.name,
      //       detailCd: condition.detailCd,
      //       items: items
      //     });
      //   });
      // }
      // del #11528 【たくしん会】データリスト並び順不正 房 end
      this.layoutData = initData;

      if (flag == 1 && this.hasDetail) {
        this.getListData();
      } else {
        this.refreshGrid();
      }
    },

    async getListData() {
      this.setLoadingScreenVisible(true);
      const patListLayoutCd = this.getSelectedDynamicLayout.patListLayoutCd;
      const rangeDate = this.getRangeDate.find(
        d => d.layoutCd === patListLayoutCd
      );
      if (!rangeDate) return;
      let startDate = rangeDate.dayObj.startDate.format('YYYYMMDD');
      let endDate = rangeDate.dayObj.endDate.format('YYYYMMDD');
      const url = `sysDataListDetail/getListData/${this.getSelectedDynamicLayout.templateCd}/${this.getFacilityCd}/${startDate}/${endDate}`;
      let response;
      try {
        response = await ApiHelper.get(url);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        getErrorMessage('TemplateComponent5.vue', 'getListData', error);
        this.setLoadingScreenVisible(false);
        console.log(error);
      } finally {
        const devMenteMainDatalist = response.data.devMenteMainDatalist;
        const devMenteMainlayoutans1List = response.data.devMenteMainlayoutans1List;
        const devMenteMainlayoutans2List = response.data.devMenteMainlayoutans2List;
        const devMenteMaingroupans1List = response.data.devMenteMaingroupans1List;
        const devMenteMaingroupans2List = response.data.devMenteMaingroupans2List;
        // add bug 5866 修正 chen start
        const devMenteMainDatalistByComType = response.data.devMenteMainDatalistByComType;
        // add bug 5866 修正 chen end

        let layoutList = {};
        let dateTitleTmp = [];
        this.dateTitle = [];
        this.dataTitle = [];
        devMenteMainDatalist.forEach(devMenteMain => {
          if (layoutList[devMenteMain.menteComment1]) {
            let mainteClassTmp = layoutList[devMenteMain.menteComment1];
            if (devMenteMain.menteClass + "" === "1") {
              let layoutTmp = mainteClassTmp["1"];
              if (layoutTmp[devMenteMain.menteLayoutCd]) {
                let itemTmp = layoutTmp[devMenteMain.menteLayoutCd];
                itemTmp["mec"] = devMenteMain.detail;
              } else {
                let itemTmp = {};
                itemTmp["mec"] = devMenteMain.detail;
                layoutTmp[devMenteMain.menteLayoutCd] = itemTmp;
              }
            } else if (devMenteMain.menteClass + "" === "3") {
              let layoutTmp = mainteClassTmp["2"];
              if (layoutTmp[devMenteMain.menteLayoutGroupCd]) {
                let itemTmp = layoutTmp[devMenteMain.menteLayoutGroupCd];
                itemTmp["mecSch"] = devMenteMain.detail;
              } else {
                let itemTmp = {};
                itemTmp["mecSch"] = devMenteMain.detail;
                layoutTmp[devMenteMain.menteLayoutGroupCd] = itemTmp;
              }
            // add bug 5866 修正 chen start
            } else if (devMenteMain.menteClass + "" === "4") {
              let layoutTmp = mainteClassTmp["1"];
              if (layoutTmp[devMenteMain.menteLayoutCd]) {
                let itemTmp = layoutTmp[devMenteMain.menteLayoutCd];
                itemTmp["mecSch"] = devMenteMain.detail;
              } else {
                let itemTmp = {};
                itemTmp["mecSch"] = devMenteMain.detail;
                layoutTmp[devMenteMain.menteLayoutCd] = itemTmp;
              }
            // add bug 5866 修正 chen end
            }
          } else {
            let mainteClassTmp = {
              "1": {},
              "2": {}
            };
            let layoutTmp = {};
            let itemTmp = {};
            if (devMenteMain.menteClass + "" === "1") {
              itemTmp["mec"] = devMenteMain.detail;
              layoutTmp[devMenteMain.menteLayoutCd] = itemTmp;
              mainteClassTmp["1"] = layoutTmp;
              layoutList[devMenteMain.menteComment1] = mainteClassTmp;
            } else if (devMenteMain.menteClass + "" === "3") {
              itemTmp["mecSch"] = devMenteMain.detail;
              layoutTmp[devMenteMain.menteLayoutGroupCd] = itemTmp;
              mainteClassTmp["2"] = layoutTmp;
              layoutList[devMenteMain.menteComment1] = mainteClassTmp;
            // add bug 5866 修正 chen start
            } else if (devMenteMain.menteClass + "" === "4") {
              itemTmp["mecSch"] = devMenteMain.detail;
              layoutTmp[devMenteMain.menteLayoutCd] = itemTmp;
              mainteClassTmp["1"] = layoutTmp;
              layoutList[devMenteMain.menteComment1] = mainteClassTmp;
            // add bug 5866 修正 chen end
            }
            dateTitleTmp.push(devMenteMain.menteComment1);
          }
        });
        devMenteMainlayoutans1List.forEach(devMenteMain => {
          let mainteClassTmp = layoutList[devMenteMain.menteComment1];
          let layoutTmp = mainteClassTmp["1"];
          let itemTmp = layoutTmp[devMenteMain.menteLayoutCd];
          itemTmp["mecPass"] = devMenteMain.detail;
        });
        devMenteMainlayoutans2List.forEach(devMenteMain => {
          let mainteClassTmp = layoutList[devMenteMain.menteComment1];
          let layoutTmp = mainteClassTmp["1"];
          let itemTmp = layoutTmp[devMenteMain.menteLayoutCd];
          itemTmp["mecNg"] = devMenteMain.detail;
        });
        devMenteMaingroupans1List.forEach(devMenteMain => {
          let mainteClassTmp = layoutList[devMenteMain.menteComment1];
          let layoutTmp = mainteClassTmp["2"];
          let itemTmp = layoutTmp[devMenteMain.menteLayoutGroupCd];
          itemTmp["mecPass"] = devMenteMain.detail;
        });
        devMenteMaingroupans2List.forEach(devMenteMain => {
          let mainteClassTmp = layoutList[devMenteMain.menteComment1];
          let layoutTmp = mainteClassTmp["2"];
          let itemTmp = layoutTmp[devMenteMain.menteLayoutGroupCd];
          itemTmp["mecNg"] = devMenteMain.detail;
        });
        dateTitleTmp = Array.from(new Set(dateTitleTmp));
        dateTitleTmp = dateTitleTmp.sort(
          (a, b) => a.replace(/\//g, '') - b.replace(/\//g, '')
        );

        dateTitleTmp.forEach(date => {
          let hasflg = false;
          let layoutTmp = layoutList[date];
          let mainteClassTmp1 = layoutTmp["1"];
          this.condition1.forEach(condition => {
            if (mainteClassTmp1[condition.detailCd]) {
              let itemTmp = mainteClassTmp1[condition.detailCd];
              if (this.hasMecPass && itemTmp["mecPass"] && itemTmp["mecPass"] !== "") {
                hasflg = true;
              }
              if (this.hasMecNg && itemTmp["mecNg"] && itemTmp["mecNg"] !== "") {
                hasflg = true;
              }
              if (this.hasMecSch && itemTmp["mecSch"] && itemTmp["mecSch"] !== "") {
                hasflg = true;
              }
            }
          });
          let mainteClassTmp2 = layoutTmp["2"];
          this.condition2.forEach(condition => {
            if (mainteClassTmp2[condition.detailCd]) {
              let itemTmp = mainteClassTmp2[condition.detailCd];
              if (this.hasMecPass && itemTmp["mecPass"] && itemTmp["mecPass"] !== "") {
                hasflg = true;
              }
              if (this.hasMecNg && itemTmp["mecNg"] && itemTmp["mecNg"] !== "") {
                hasflg = true;
              }
              if (this.hasMecSch && itemTmp["mecSch"] && itemTmp["mecSch"] !== "") {
                hasflg = true;
              }
            }
          });
          if (hasflg) {
            this.dateTitle.push(date);
          }
        });

        this.dateTitle.forEach(date => {
          let mainteClassTmp = layoutList[date];
          if (this.hasMecSch) {
            this.dataTitle.push("装置台数");
          }
          if (this.hasMecPass) {
            this.dataTitle.push("合格台数");
          }
          if (this.hasMecNg) {
            this.dataTitle.push("不合格台数");
          }
          this.layoutData.forEach(rowLayout => {
            let itemTmp = null;
            if (rowLayout.type === 1) {
              let layoutTmp = mainteClassTmp["1"];
              itemTmp = layoutTmp[rowLayout.detailCd];
            } else if (rowLayout.type === 2) {
              let layoutTmp = mainteClassTmp["2"];
              itemTmp = layoutTmp[rowLayout.detailCd];
            }
            if (this.hasMecSch) {
              if (itemTmp && itemTmp["mecSch"]) {
                rowLayout.items.push({
                  value: itemTmp["mecSch"],
                  key: " mecSch"
                });
              } else {
                if (rowLayout.type === 1) {
                  // mod bug 5866 修正 chen start
                  rowLayout.items.push({
                    value: "0",
                    key: " mecSch"
                  });
                  // mod bug 5866 修正 chen end
                } else if (rowLayout.type === 2) {
                  rowLayout.items.push({
                    value: "0",
                    key: " mecSch"
                  });
                }
              }
            }
            if (this.hasMecPass) {
              if (itemTmp && itemTmp["mecPass"]) {
                rowLayout.items.push({
                  value: itemTmp["mecPass"],
                  key: " mecPass"
              });
              } else {
                rowLayout.items.push({
                  value: "0",
                  key: " mecPass"
                });
              }
            }
            if (this.hasMecNg) {
              if (itemTmp && itemTmp["mecNg"]) {
                rowLayout.items.push({
                  value: itemTmp["mecNg"],
                  key: " mecNg"
                });
              } else {
                rowLayout.items.push({
                  value: "0",
                  key: " mecNg"
                });
              }
            }
          });
        });
        // add bug 5866 修正 chen start
        devMenteMainDatalistByComType.forEach(mst => {
          this.layoutData.forEach(rowLayout => {
            if(rowLayout.type + "" === "1" && mst.menteLayoutCd + "" === rowLayout.detailCd + "") {
              rowLayout.items.forEach(colLayout => {
                if(colLayout.key === " mecSch") {
                  colLayout.value = (parseInt(colLayout.value) + parseInt(mst.detail)) + "";
                }
              });
            }
          });
        });
        // add bug 5866 修正 chen end
        this.refreshGrid();
      }
    },

    onCreateTemplateToExcel() {
      if (this.sortedLayoutData.length === 0) return;

      const columns = this.getColumns();
      const data = this.getData();
      this.saveExcel({
        data: data.length === 0 ? null : data,
        fileName: `データリスト_${dayjs().format('YYYYMMDDHHmmss')}`,
        columns: columns,
      });
    },
    saveExcel(exportOptions) {
      let saveFn = function (dataURL) {
        kendo_file_saver_1.saveAs(dataURL, exportOptions.fileName, {
          forceProxy: exportOptions.forceProxy,
          proxyURL: exportOptions.proxyURL
        });
      };
      let options = workbook_1.workbookOptions(exportOptions);
      options.sheets.forEach(item => {
        item.rows.forEach(row => {
          if (row.type === 'data') {
            let height = 15;
            row.cells.forEach(cell => {
              let vals = 1;
              if (cell.value) {
                vals = (cell.value + "").split('\n').length;
              }
              if (vals * 15 > height){
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
      if (!this.sortedLayoutData || !this.sortedLayoutData.length) {
        return [];
      }
      return this.flattenExportColumns(this.buildKendoColumns());
    },

    getData() {
      return this.buildFlatRows(this.sortedLayoutData, true);
    },

    exportToCSV() {
      const columns = this.getColumns();
      const data = this.getData();

      let physicalNames = '';
      const arrayFields = [];

      columns.forEach((field, index) => {
        physicalNames += field.title;
        arrayFields.push(field.field);
        if (index <= columns.length - 1) {
          physicalNames += ',';
        }
      });
      physicalNames += '\n';
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
            if (temp.indexOf(',') > -1)
              r = temp.replace(temp, '"' + temp + '"');
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

      const sjisCodes = encoding.convert(charCodes, 'sjis', 'unicode');
      const uint8s = new Uint8Array(sjisCodes);
      const blob = new Blob([uint8s], { type: 'test/csv' });
      triggerScopedDownload({
        blob,
        filename: `データリスト_${dayjs().format('YYYYMMDDHHmmss')}.csv`,
        root: this.$el
      });
    },
  },

  async created() {
    this.refreshHandler = () => this.initLayout(1);
    EventBus.$on('onInitLayout', this.initLayout);
    EventBus.$on('refresh', this.refreshHandler);
    EventBus.$on('requestReportParams', this.requestrReportParams);
  },

  beforeUnmount() {
    /* modify by chamaojia 2023-06-08 [8610] EventBusイベントの結合解除は結合と一致する（イベントコールバック関数を指定）  --start */
    EventBus.$off('onInitLayout', this.initLayout);
    EventBus.$off('refresh', this.refreshHandler);
    EventBus.$off('requestReportParams', this.requestrReportParams);
    /* modify by chamaojia 2023-06-08 [8610] EventBusイベントの結合解除は結合と一致する（イベントコールバック関数を指定）  --end */
    window.removeEventListener("beforeprint", this._preparePrintGrid, true);
    window.removeEventListener("afterprint", this._restorePrintGrid, true);
    if (this.gridResizeObserver) {
      this.gridResizeObserver.disconnect();
      this.gridResizeObserver = null;
    }
    const root = this.$refs.gridContainer;
    if (root && this._gridSortClickHandler) {
      root.querySelector(".k-grid")?.removeEventListener("click", this._gridSortClickHandler);
    }
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style>
@media print {
  /** tableレイアウト崩れ回避 */
  body:has(#multi-pat-list-template5) #main-id {
    display: inline-block;
  }
  /** ヘッダレイアウト崩れ回避 */
  body:has(#multi-pat-list-template5) #bbs-search-area {
    width: 60%;
  }
  body:has(#multi-pat-list-template5) .file-button {
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

:deep(.multi-pat-list .k-grid td) {
  width: 150px !important;
}

:deep(.multi-pat-list .k-grid .k-table-td) {
  width: 150px !important;
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

#multi-pat-list-template5 :deep(.k-grid-container td) {
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
