<template>
  <div
    id="multi-pat-list-template4"
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
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import encoding from "@/compat/encoding/encoding-japanese";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import * as workbook_1 from "@/functions/common/KendoFunctions";
import * as kendo_file_saver_1 from "@/functions/common/KendoFunctions";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";
import PrintMixin from "@/components/PrintMixin";
import { ApiHelper } from "@/apis/AxiosHelper";
import KendoGridView from "@/components/kendo-ui/KendoGridView.vue";

const GRID_PAGE_SIZE = 30;
const DATE_FIELD_SUFFIX = {
  1398: "checker_id_1",
  1399: "checker_id_2",
  1400: "judge",
  1401: "rec_no",
  1402: "comment",
  1403: "sub_cmt",
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
      // add #11528 【たくしん会】データリスト並び順不正 房 start
      conditionSort: [],
      // add #11528 【たくしん会】データリスト並び順不正 房 end
      condition: [],
      condition2: [],
      condition3: [],
      layoutData: [],
      listItems: [],
      dataTitle: [],
      dataTitle2: [],
      dateList: [],
      isShowLayoutClass: false,
      sort: {
        key: "",
        isAsc: true,
      },
      gridHeight: 400,
      isPrintMode: false,
      gridResizeObserver: null,
      scrollQuerySelector: "#multi-pat-list-template4 .k-virtual-scrollable-wrap",
      addClassTargetQuerySelector: ["#multi-pat-list-template4 .k-grid table"],
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
    ...mapGetters('account-edit', ['getFontSize']),

    ...mapGetters('pat-info', ['searchedPatList', 'selectedPatId']),
    ...mapGetters('exam-record/list', ['getCondition']),

    sortedLayoutData() {
      const sortField = this.sort.key;
      const isAsc = this.sort.isAsc;
      // ソートなしは元のリストをそのままreturn
      if (!sortField) return this.layoutData;
      
      let sorted = [];
      // 実施者、確認者、点検結果、点検記録番号、点検コメント、補足コメントの場合はデータの持ち方が異なるため個別でソート
      if (sortField.includes(":")) {
        const [date, field] = sortField.split(":");
  
        sorted = [...this.layoutData].sort((a, b) => {
          const aDay = a.daylist.find(day => day.d === date);
          const bDay = b.daylist.find(day => day.d === date);
          const aVal = aDay ? aDay[field] : null;
          const bVal = bDay ? bDay[field] : null;
  
          const aIsEmpty = aVal === null || aVal === undefined || aVal.trim() === "";
          const bIsEmpty = bVal === null || bVal === undefined || bVal.trim() === "";
          if (aIsEmpty && !bIsEmpty) return isAsc ? 1 : -1;
          if (!aIsEmpty && bIsEmpty) return isAsc ? -1 : 1;
          if (aIsEmpty && bIsEmpty) return 0;
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
            date
          }))
      );
    },
    hasMachineType() {
      return this.fixedTitle.some(x => x.id + '' == '1387');
    },
    hasBedName() {
      return this.fixedTitle.some(x => x.id + '' == '1388');
    },
    hasSettingDate() {
      return this.fixedTitle.some(x => x.id + '' == '1389');
    },
    hasLayoutClass() {
      return this.fixedTitle.some(x => x.id + '' == '1392');
    },
    hasMainteContent1() {
      return this.dataTitle2.some(x => x.id + '' == '1395');
    },
    hasMainteContent2() {
      return this.dataTitle2.some(x => x.id + '' == '1396');
    },
    hasMainteContent3() {
      return this.dataTitle2.some(x => x.id + '' == '1397');
    },
    hasCheckerId1() {
      return this.dataTitle.some(x => x.id + '' == '1398');
    },
    hasCheckerId2() {
      return this.dataTitle.some(x => x.id + '' == '1399');
    },
    hasJudge() {
      return this.dataTitle.some(x => x.id + '' == '1400');
    },
    hasRecNo() {
      return this.dataTitle.some(x => x.id + '' == '1401');
    },
    hasComment() {
      return this.dataTitle.some(x => x.id + '' == '1402');
    },
    hasSubCmt() {
      return this.dataTitle.some(x => x.id + '' == '1403');
    },
    hasDateData() {
      return this.hasCheckerId1 || this.hasCheckerId2 || this.hasJudge || this.hasRecNo || this.hasComment || this.hasSubCmt;
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
    // 共通ローダー設定
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
        }),
      ];

      this.fixedTitle.forEach(x => {
        if (x.id + "" == "1387" && this.hasMachineType) {
          columns.push(
            this.gridColumn({
              field: "machine_type",
              title: x.name,
              sortKey: "machine_type",
              width: 120,
            })
          );
        } else if (x.id + "" == "1388" && this.hasBedName) {
          columns.push(
            this.gridColumn({
              field: "bed_name",
              title: x.name,
              sortKey: "bed_name",
              width: 120,
            })
          );
        } else if (x.id + "" == "1389" && this.hasSettingDate) {
          columns.push(
            this.gridColumn({
              field: "setting_date",
              title: x.name,
              sortKey: "setting_date",
              width: 120,
            })
          );
        } else if (x.id + "" == "1392" && this.hasLayoutClass) {
          columns.push(
            this.gridColumn({
              field: "layout_class",
              title: x.name,
              sortKey: "layout_class",
              width: 120,
            })
          );
        }
      });

      columns.push(
        this.gridColumn({
          field: "category_name",
          title: "点検項目",
          sortKey: "category_name",
          width: 150,
        })
      );

      if (this.isShowLayoutClass) {
        columns.push(
          this.gridColumn({
            field: "mainte_type",
            title: "点検種別",
            sortKey: "mainte_type",
            width: 120,
          })
        );
      }

      this.dataTitle2.forEach(x => {
        if (x.id + "" == "1395" && this.hasMainteContent1) {
          columns.push(
            this.gridColumn({
              field: "mainte_content_1",
              title: x.name,
              sortKey: "mainte_content_1",
              width: 120,
            })
          );
        } else if (x.id + "" == "1396" && this.hasMainteContent2) {
          columns.push(
            this.gridColumn({
              field: "mainte_content_2",
              title: x.name,
              sortKey: "mainte_content_2",
              width: 120,
            })
          );
        } else if (x.id + "" == "1397" && this.hasMainteContent3) {
          columns.push(
            this.gridColumn({
              field: "mainte_content_3",
              title: x.name,
              sortKey: "mainte_content_3",
              width: 120,
            })
          );
        }
      });

      if (this.hasDateData) {
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
      }

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
      const hasCheckerId1 = this.hasCheckerId1;
      const hasCheckerId2 = this.hasCheckerId2;
      const hasJudge = this.hasJudge;
      const hasRecNo = this.hasRecNo;
      const hasComment = this.hasComment;
      const hasSubCmt = this.hasSubCmt;

      return layoutData.map(row => {
        const flat = { ...row };
        if (row.daylist) {
          row.daylist.forEach(y => {
            if (hasCheckerId1) {
              flat[y.d + "checker_id_1"] = y.checker_id_1;
            }
            if (hasCheckerId2) {
              flat[y.d + "checker_id_2"] = y.checker_id_2;
            }
            if (hasJudge) {
              flat[y.d + "judge"] = y.judge;
            }
            if (hasRecNo) {
              flat[y.d + "rec_no"] = y.rec_no;
            }
            if (hasComment) {
              flat[y.d + "comment"] = y.comment;
            }
            if (hasSubCmt) {
              flat[y.d + "sub_cmt"] = y.sub_cmt;
            }
          });
        }
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
      this.scrollQuerySelector = "#multi-pat-list-template4 .k-grid-content";
      this.$nextTick(() => {
        this.$refs.grid?.setScrollable(true);
        this.$refs.grid?.resize();
      });
    },

    _restorePrintGrid() {
      this.isPrintMode = false;
      this.scrollQuerySelector = "#multi-pat-list-template4 .k-virtual-scrollable-wrap";
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
        1387: "machine_type",
        1388: "bed_name",
        1389: "setting_date",
        1392: "layout_class",
        1395: "mainte_content_1",
        1396: "mainte_content_2",
        1397: "mainte_content_3",
        1398: "checker_id_1",
        1399: "checker_id_2",
        1400: "judge",
        1401: "rec_no",
        1402: "comment",
        1403: "sub_cmt",
      };

      let sortKey = sortKeyMap[data.id] || "";
      if ([1398, 1399, 1400, 1401, 1402, 1403].includes(data.id)) {
        sortKey = `${data.date}:${sortKey}`;
      }
      return sortKey;
    },

    refreshGrid() {
      this.$nextTick(() => {
        this.$refs.grid?.refreshColumns(this.kendoColumns);
        this.$refs.grid?.refreshData(this.gridFlatRows);
        this.$refs.grid?.resize();
      });
    },

    async initLayout(flag) {
      this.setLoadingScreenVisible(true);
      const url = `sysDataListDetail/getByLayoutCd/${this.getSelectedDynamicLayout.patListLayoutCd}`;
      let response;
      try {
        response = await ApiHelper.get(url);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        getErrorMessage('TemplateComponent4.vue', 'initLayout', error);
        this.setLoadingScreenVisible(false);
        console.log(error);
      } finally {
        this.dataTitle = [];
        this.dataTitle2 = [];
        const data = response.data;
        if (data && data.length) {
          this.condition = [];
          this.condition2 = [];
          this.condition3 = [];
          this.isShowLayoutClass = false;
          data.forEach(x => {
            let id = '';
            let name = '';
            let isShow = false;
            if (x.categoryCd + '' == '156') {
              isShow = true;
            }
            if (x.dataListDetailCd && x.items[0]) {
              id = x.dataListDetailCd;
              if (x.categoryCd + '' == '151') {
                // mod #11528 【たくしん会】データリスト並び順不正 房 start
                x.items.sort((a, b) => {
                  let aIndex = x.itemCds.findIndex(itemCd => a.id == itemCd);
                  let bIndex = x.itemCds.findIndex(itemCd => b.id == itemCd);
                  return aIndex - bIndex;
                });
                x.items.forEach(y => {
                  this.condition.push(y.name);
                  this.conditionSort.push({
                    layout_class: 1,
                    name: y.name
                  });
                });
                // mod #11528 【たくしん会】データリスト並び順不正 房 end
              } else if (x.categoryCd + '' == '152') {
                // mod #11528 【たくしん会】データリスト並び順不正 房 start
                x.items.sort((a, b) => {
                  let aIndex = x.itemCds.findIndex(itemCd => a.id == itemCd);
                  let bIndex = x.itemCds.findIndex(itemCd => b.id == itemCd);
                  return aIndex - bIndex;
                });
                x.items.forEach(y => {
                  this.condition2.push(y.name);
                  this.conditionSort.push({
                    layout_class: 2,
                    name: y.name
                  });
                });
                // mod #11528 【たくしん会】データリスト並び順不正 房 end
              } else if (x.categoryCd + '' == '154') {
                x.items.forEach(y => this.condition3.push(y.name));
                this.isShowLayoutClass = true;
              } else if (x.categoryCd + '' == '155') {
                name = x.items[0].name;
                this.dataTitle2.push({
                  id: id,
                  name: name,
                  isShow: isShow,
                });
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
        if (flag == 1) {
          this.getListData();
        } else {
          this.refreshGrid();
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
      let startDate = dayjs(rangeDate.dayObj.startDate).format('YYYY-MM-DD');
      let endDate = dayjs(rangeDate.dayObj.endDate).format('YYYY-MM-DD');
      const url = `sysDataListDetail/getListData/${this.getSelectedDynamicLayout.templateCd}/${this.getFacilityCd}/${startDate}/${endDate}`;
      let response;
      try {
        response = await ApiHelper.get(url);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        getErrorMessage('TemplateComponent4.vue', 'getListData', error);
        this.setLoadingScreenVisible(false);
        console.log(error);
      } finally {
        const colData = response.data.mstMachineDatalistMainte;
        let rowData = response.data.mstMachineDatalistMainteInit;
        const userList = response.data.mstPersonalUsers;
        // add #11528 【たくしん会】データリスト並び順不正 房 start
        let deviceOrders = rowData.map(el => el.machine_no);
        deviceOrders = [...new Set(deviceOrders)];
        rowData.sort((a, b) => {
          let aIndex = deviceOrders.findIndex(devOrder => devOrder == a.machine_no);
          let bIndex = deviceOrders.findIndex(devOrder => devOrder == b.machine_no);
          if(aIndex == bIndex) {
            let aConditionIndex = this.conditionSort.findIndex(conditionOrder => conditionOrder.layout_class == a.layout_class
              && conditionOrder.name == a.category_name);
            let bConditionIndex = this.conditionSort.findIndex(conditionOrder => conditionOrder.layout_class == b.layout_class
              && conditionOrder.name == b.category_name);
            return aConditionIndex - bConditionIndex;
          } else {
            return aIndex - bIndex;
          }
        });
        // add #11528 【たくしん会】データリスト並び順不正 房 end
        if (this.condition.length > 0) {
          rowData = rowData.filter(x =>
            x.layout_class + "" === '1' ? this.condition.some(y => y == x.category_name) : true
          );
        }
        if (this.condition2.length > 0) {
          rowData = rowData.filter(x =>
            x.layout_class + "" === '2' ? this.condition2.some(y => y == x.category_name) : true
          );
        }
        if (this.condition3.length > 0) {
          rowData = rowData.filter(x =>
            x.layout_class + "" === '2' ? this.condition3.some(y => y == x.mainte_type) : true
          );
        }
        let date_list = [];
        colData.forEach(x =>
          date_list.push(x.mainte_date.substring(0, 10).replace(/-/g, '/'))
        );
        date_list = Array.from(new Set(date_list));
        date_list = date_list.sort(
          (a, b) => a.replace(/\//g, '') - b.replace(/\//g, '')
        );
        this.dateList = date_list;
        if (rowData.length == 0) {
          this.layoutData = [];
          this.refreshGrid();
        } else {
        // if (this.loopTitle.length == 0) {
        //   return;
        // }
        let zindex = 0;
        rowData = rowData.map(row => {
          let daylist = [];
          date_list.forEach(x => {
            daylist.push({
              d: x,
              checker_id_1: ' ',
              checker_id_2: ' ',
              judge: ' ',
              rec_no: ' ',
              comment: ' ',
              sub_cmt: ' ',
            });
          });
          row.daylist = daylist;
          row.isDis = false;
          colData.forEach(col => {
            let colDate = col.mainte_date.substring(0, 10).replace(/-/g, '/');
            if (
              col.machine_type_cd == row.machine_type_cd &&
              col.machine_serial == row.machine_serial &&
              col.machine_name == row.machine_name &&
              col.machine_no == row.machine_no &&
              col.machine_type == row.machine_type &&
              col.bed_name == row.bed_name &&
              col.setting_date == row.setting_date &&
              col.category_name == row.category_name &&
              col.mainte_type == row.mainte_type &&
              col.layout_class == row.layout_class &&
              col.mainte_content_1 == row.mainte_content_1 &&
              col.mainte_content_2 == row.mainte_content_2 &&
              col.mainte_content_3 == row.mainte_content_3
            ) {
              let daylistFilter = row.daylist.filter(y => y.d == colDate);
              if (
                daylistFilter[0].checker_id_1 + '' == ' ' &&
                daylistFilter[0].checker_id_2 + '' == ' ' &&
                daylistFilter[0].judge + '' == ' ' &&
                daylistFilter[0].rec_no + '' == ' ' &&
                daylistFilter[0].comment + '' == ' ' &&
                daylistFilter[0].sub_cmt + '' == ' '
              ) {
                let index = row.daylist.indexOf(daylistFilter[0]);
                let checker_id_1 = '';
                let user = userList.filter(u => u.userId == col.checker_id_1);
                if (user.length > 0) {
                  checker_id_1 =
                    user[0].userLastName + ' ' + user[0].userFirstName;
                }
                let checker_id_2 = '';
                let user2 = userList.filter(u => u.userId == col.checker_id_2);
                if (user2.length > 0) {
                  checker_id_2 =
                    user2[0].userLastName + ' ' + user2[0].userFirstName;
                }
                let judge = col.judge;
                if (row.layout_class + '' == '1') {
                  if (col.judge + '' == '1') {
                    judge = '合格';
                  } else if (col.judge + '' == '2') {
                    judge = '点検途中';
                  } else if (col.judge + '' == '3') {
                    judge = '不合格';
                  }
                } else if (row.layout_class + '' == '2' && row.mainte_type + '' == '点検記録簿') {
                  if (col.judge + '' == '1') {
                    judge = 'レ';
                  } else if (col.judge + '' == '2') {
                    judge = '〇';
                  } else if (col.judge + '' == '3') {
                    judge = '✖';
                  } else if (col.judge + '' == '4') {
                    judge = 'A';
                  } else if (col.judge + '' == '5') {
                    judge = 'T';
                  } else if (col.judge + '' == '6') {
                    judge = 'C';
                  }
                } else if (row.layout_class + '' == '2' && row.mainte_type + '' == '交換部品記録簿') {
                  if (col.judge + '' == '1') {
                    judge = '交換済み';
                  }
                }
                // if (checker_id_1 || checker_id_2 || judge || col.rec_no || col.comment || col.sub_cmt) {
                //   row.isDis = true;
                // }
                let data = {};
                // mod #11528 【たくしん会】データリスト並び順不正 関 start
                // mod bug 6407 修正 chen start
                if ((this.hasCheckerId1 && checker_id_1) ||
                  (this.hasCheckerId2 && checker_id_2) ||
                  (this.hasJudge && judge) ||
                  (this.hasRecNo && col.rec_no) || (this.hasComment && col.comment)) {
                  row.isDis = true;
                  data = {
                    d: colDate,
                    checker_id_1: checker_id_1 ? checker_id_1 : "",
                    checker_id_2: checker_id_2 ? checker_id_2 : "",
                    judge: judge ? judge : "",
                    rec_no: col.rec_no ? col.rec_no : "",
                    comment: col.comment ? col.comment : "",
                    sub_cmt: judge ? col.sub_cmt : "",
                  };
                  // mod bug 6407 修正 chen end
                } else {
                  row.isDis = true;
                  // mod #11528 【たくしん会】データリスト並び順不正 関 end
                  data ={
                    d: colDate,
                    checker_id_1: "",
                    checker_id_2: "",
                    judge: "",
                    rec_no: "",
                    comment: "",
                    sub_cmt: "",
                  };
                }
                zindex = zindex + 1;
                row.daylist.splice(index, 1, data);
              }
            }
          });
          if (row.layout_class + '' == '1') {
            row.layout_class = '日常';
          } else if (row.layout_class == '2') {
            row.layout_class = '定期';
          }
          if (row.setting_date) {
            row.setting_date = row.setting_date
              .substring(0, 10)
              .replace(/-/g, '/');
          }
          return row;
        });
        let rowDataTmp = [];
        let rowTmp = [];
        // mod bug 6407 修正 chen start
        let dateListTmp = [];
        rowData.forEach(item => {
          if (item.isDis) {
            let key = item.machine_type_cd + item.machine_serial + item.machine_name + item.machine_no + item.machine_type
              + item.bed_name + item.setting_date + item.category_name + item.mainte_type + item.layout_class + item.mainte_content_1
              + item.mainte_content_2 + item.mainte_content_3
            if (rowTmp.indexOf(key) === -1) {
              rowDataTmp.push(item);
              rowTmp.push(key);
              item.daylist.forEach(day => {
                // mod #11528 【たくしん会】データリスト並び順不正 関 start
                if ((day.checker_id_1.trim() || day.checker_id_2.trim() || day.judge.trim() || day.rec_no.trim() ||
                  day.comment.trim()) && !dateListTmp.includes(day.d)) {
                  // mod #11528 【たくしん会】データリスト並び順不正 関 end
                  dateListTmp.push(day.d);
                }
              });
            }
          }
        });
        // add bug 6407 修正 chen start
        dateListTmp = dateListTmp.sort(
          (a, b) => a.replace(/\//g, '') - b.replace(/\//g, '')
        );
        // add bug 6407 修正 chen end
        this.dateList = dateListTmp;
        rowDataTmp.forEach(item => {
          let daylistTmp = [];
          item.daylist.forEach(day => {
            if (dateListTmp.includes(day.d)) {
              daylistTmp.push(day);
            }
          });
          item.daylist = daylistTmp;
        });
        // mod bug 6407 修正 chen end
        this.layoutData = rowDataTmp;
        this.refreshGrid();
        }
      }
    },

    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
        let rowTmp = [];
        const patListLayoutCd = this.getSelectedDynamicLayout.patListLayoutCd;
        const rangeDate = this.getRangeDate.find(
          d => d.layoutCd === patListLayoutCd
        );
        if (!rangeDate) return;
        let startDate = dayjs(rangeDate.dayObj.startDate).format('YYYY-MM-DD');
        let endDate = dayjs(rangeDate.dayObj.endDate).format('YYYY-MM-DD');
        this.layoutData.forEach(item => {
          if (item.machine_no) {
            rowTmp.push(item.machine_no);
          }
        });
        rowTmp = Array.from(new Set(rowTmp));
        //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
        const param1 = {
          // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //patId: this.selectedPatId,
          // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          patIds: [],
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          facilityCd: this.getFacilityCd,
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          // date:dayjs(startDate).format('YYYY/MM/DD'),
          // fromDate: dayjs(startDate).format('YYYY/MM/DD'),
          // toDate: dayjs(endDate).format('YYYY/MM/DD'),
          date: dayjs(Date.now()).format("YYYYMMDD"),
          fromDate: dayjs(Date.now()).format("YYYYMMDD"),
          toDate: dayjs(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: dayjs(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          functionCd:"00801",
          machineNos:rowTmp
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
        };
        EventBus.$emit('sendReportParams', param1);
      }
    },

    onCreateTemplateToExcel() {
      if (this.sortedLayoutData.length === 0) return;

      const columns = this.getColumns(this.sortedLayoutData);
      const data = this.getData(this.sortedLayoutData);
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
        // mod #11528 【たくしん会】データリスト並び順不正 関 start
        charCodes.push(physicalNames.replace('✖', '×').charCodeAt(i));
        // mod #11528 【たくしん会】データリスト並び順不正 関 end
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
    EventBus.$on('onInitLayout', this.initLayout);
    EventBus.$on('refresh', this.initLayout);
    EventBus.$on('requestReportParams', this.requestrReportParams);
  },

  beforeUnmount() {
    /* modify by chamaojia 2023-06-08 [8610] EventBusイベントの結合解除は結合と一致する（イベントコールバック関数を指定）  --start */
    EventBus.$off('onInitLayout', this.initLayout);
    EventBus.$off('refresh', this.initLayout);
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
  body:has(#multi-pat-list-template4) #main-id {
    display: inline-block;
  }
  /** ヘッダレイアウト崩れ回避 */
  body:has(#multi-pat-list-template4) #bbs-search-area {
    width: 60%;
  }
  body:has(#multi-pat-list-template4) .file-button {
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

#multi-pat-list-template4 :deep(.k-grid-container td) {
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
