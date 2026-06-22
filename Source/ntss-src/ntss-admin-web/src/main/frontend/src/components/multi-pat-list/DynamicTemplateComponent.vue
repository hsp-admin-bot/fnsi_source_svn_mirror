<template>
  <div
    id="multi-pat-list-dynamic"
    ref="gridContainer"
    class="multi-pat-list"
    style="width: 100%; height: 100%"
  >
    <KendoGridView
      ref="grid"
      :columns="gridColumns"
      :options="gridDataSourceOptions"
      :height="gridHeight"
      :scrollable="scrollableConfig"
      :pageable="false"
      :resizable="true"
      :data-bound="onGridDataBound"
    />
  </div>
</template>

<script>
import _ from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";
import { EventBus } from "@/compat/vue/event-bus.js";
import encoding from "@/compat/encoding/encoding-japanese";
import { mapGetters, mapActions, mapMutations } from "@/compat/vue/vuex";
import { ApiHelper } from "@/apis/AxiosHelper";
import { DATE_TEMPLATE_CD, MONTH_TEMPLATE_CD } from "@/constants/dataListConstant";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import { deepCopy } from "@/functions/common/CommonFunctions";
import { sortableCompare } from "@/functions/SortFunctions";
import PrintMixin from "@/components/PrintMixin";
import KendoGridView from "@/components/kendo-ui/KendoGridView.vue";
import {
  plusDecimal
} from "@/functions/treatment-record/NumberFunctions.js";
import $ from "@/compat/jquery";
import * as workbook_1 from "@/functions/common/KendoFunctions";
import * as kendo_file_saver_1 from "@/functions/common/KendoFunctions";

export default {
  components: {
    KendoGridView,
  },
  mixins: [PrintMixin],
  data() {
    return {
      pageSize: 200,
      listItems: [],
      selfScreenName: "",
      sort: {
        key: "",
        isAsc: true
      },
      isSortAllowed: true ,
      scrollQuerySelector: "#multi-pat-list-dynamic .k-virtual-scrollable-wrap",
      addClassTargetQuerySelector: ["#multi-pat-list-dynamic .k-grid table"],
      gridResizeObserver: null,
      gridColumns: [
        { field: "name", title: "データ名", locked: true, width: "240px;", headerAttributes: { style: "text-align: center" } },
        { field: "totalCount", title: "合計", width: "100px", headerAttributes: { style: "text-align: center" } }
      ],
      total: 0,
      searchData: null,
      pageList: new Set(),
      scrollableConfig: {
        virtual: {
          itemHeight: 40,
          scrollContainer: null,
        }
      },
      gridHeight: 580,
      params: []
    };
  },
  computed: {
    ...mapGetters("data-list", [
      "getSelectedDynamicLayout",
      "getRangeDate",
      "getRequestExportExcel",
      "getRequestExportCSV"
    ]),
    ...mapGetters("pat-info", ["searchedPatList"]),
    ...mapGetters('user', ['getFacilityCd']),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight"
    }),
    ...mapGetters('account-edit', ['getFontSize']),
    ...mapGetters("window-size", {
      windowWidth: "getSplittedWidth",
      windowHeight: "getWindowHeight"
    }),

    sortedListItems() {
      const sortField = this.sort.key;
      const isAsc = this.sort.isAsc;
      // ソートなしは元のリストをそのままreturn
      if (!sortField) return this.listItems;

      let sorted = [];
      // レイアウトカテゴリ名、レイアウト名以外は個別にソート
      if (sortField.includes(":")) {
        const itemIndex = sortField.split(":")[1]; // ソート対象の可変列のインデックス
        const isAsc = this.sort.isAsc;
        
        // ソートキーの列が非表示の場合はソート実行しない。元のリストをそのままreturn（抽出条件変更時やパンくずリスト押下時）
        if (!this.listItems[0]?.dateRange || itemIndex >= this.listItems[0].dateRange.length) return this.listItems;
      
        sorted = [...this.listItems].sort((a, b) => {
          const aVal = a.dateRange[itemIndex].data;
          const bVal = b.dateRange[itemIndex].data;
      
          const aIsEmpty = aVal === null || aVal === undefined || aVal === "";
          const bIsEmpty = bVal === null || bVal === undefined || bVal === "";
      
          // 空欄の扱い（昇順なら後方、降順なら前方）
          if (aIsEmpty && !bIsEmpty) return isAsc ? 1 : -1;
          if (!aIsEmpty && bIsEmpty) return isAsc ? -1 : 1;
          if (aIsEmpty && bIsEmpty) return 0;
      
          // 通常の比較
          if (aVal < bVal) return isAsc ? -1 : 1;
          if (aVal > bVal) return isAsc ? 1 : -1;
          return 0;
        });
      } else {
        // 共通関数でソート
        sorted = [...this.listItems].sort((a, b) => {
          return sortableCompare(a, b, sortField, isAsc);
        });
      }
  
      return sorted;
    },
    isShowData() {
      return this.getRangeDate.length !== null;
    },

    gridDataSourceOptions() {
      return {
        transport: {
          read: options => this.onGridDataSourceRead(options),
        },
        schema: {
          data: "data",
          total: "total",
        },
        pageSize: this.pageSize,
        serverPaging: true,
        serverSorting: true,
        serverFiltering: true,
      };
    },
  },

  watch: {
    getRequestExportExcel() {
      this.onCreateTemplateToExcel();
    },
    getRequestExportCSV() {
      this.exportToCSV();
    },
    windowWidth() {
      this.calculateReportArea();
    },
    windowHeight() {
      this.calculateReportArea();
    },
    getFontSize() {
      this.$nextTick(() => {
        this.updateGridHeight();
        this.$refs.grid?.resize();
      });
    },
  },

  methods: {
    // 共通ローダー設定
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage"
    ]),
    ...mapMutations("multi-pat-list", [
      "setLoopFlag",
    ]),
    async initHeaderColumn(){
      let listRangeDate = this.rangeDate(this.getSelectedDynamicLayout.templateCd);
      this.gridColumns = [{ field: "name", title: "データ名", locked: true, width: "240px", headerAttributes: { style: "text-align: center" } }];
      if(listRangeDate) {
        let level1Title = '';
        let tempColumns = [];
        listRangeDate.forEach(el => {
          let tempTitle = this.getSelectedDynamicLayout.templateCd === MONTH_TEMPLATE_CD ? el.date.substring(0, 4) : (el.date.substring(0, 4) + '/' + el.date.substring(4, 6))
          if(level1Title !== tempTitle) {
            if(level1Title !== '' ) {
              this.gridColumns.push({
                title: level1Title,
                headerAttributes: { style: "text-align: center" },
                columns: tempColumns,
              });
              tempColumns = [];
            }
            level1Title = tempTitle;
          }
          tempColumns.push({
            date: el.date,
            field: "item" + (this.getSelectedDynamicLayout.templateCd === MONTH_TEMPLATE_CD ? el.date.substring(0, 6) : el.date),
            title: el.headerItem + "(" + el.name + ")",
            headerAttributes: { style: "text-align: center" },
            width: "100px"
          });
        });
        if(level1Title !== '' ) {
          this.gridColumns.push({
            title: level1Title,
            headerAttributes: { style: "text-align: center" },
            columns: tempColumns,
          });
        }
      }
      this.gridColumns.push({ field: "totalCount", title: "合計", width: "100px", headerAttributes: { style: "text-align: center" } })
    },
    async initLayout(flag) {
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      this.searchData = [];
      this.pageList = new Set();
      this.listItems = [];
      await this.initHeaderColumn();
      this.setLoadingScreenVisible(true);
      const url = `sysDataListDetail/getByLayoutCd/${this.getSelectedDynamicLayout.patListLayoutCd}`;
      let response;
      try {
        response = await ApiHelper.get(url);
        let list = [];
        const data = response.data;
        if(data) {
          data.forEach(dataEl => {
            let hasCd = dataEl.items.some(itemObj => itemObj.hasOwnProperty("cd"));
            if(hasCd) {
              let tempSortItems = dataEl.items;
              if(dataEl.items) {
                dataEl.items.sort((a, b) => {
                  let aIndex = dataEl.itemCds.findIndex(itemCd => itemCd == a.cd);
                  let bIndex = dataEl.itemCds.findIndex(itemCd => itemCd == b.cd);
                  if(aIndex == bIndex) {
                    let aSubIndex = tempSortItems.findIndex(itemIdObj => itemIdObj.id == a.id);
                    let bSubIndex = tempSortItems.findIndex(itemIdObj => itemIdObj.id == b.id);
                    return aSubIndex - bSubIndex;
                  } else {
                    return aIndex - bIndex;
                  }
                });
              }
            } else {
              if(dataEl.items) {
                dataEl.items.sort((a, b) => {
                  let aIndex = dataEl.itemCds.findIndex(itemCd => itemCd == a.id);
                  let bIndex = dataEl.itemCds.findIndex(itemCd => itemCd == b.id);
                  return aIndex - bIndex;
                });
              }
            }
          });
        }
        if (data && data.length) {
          const dataRange = this.rangeDate(
                  this.getSelectedDynamicLayout.templateCd
                );
          data.forEach(d => {
            const listItems = d.items;
            const displayName = !d.displayName ? "" : d.displayName.trim();
            if (listItems && listItems.length) {
              listItems.forEach(item => {
                item.categoryCd = d.categoryCd;
                item.name = this.formatName(item, displayName);
                item.dataListDetailCd = d.dataListDetailCd;
                item.dispOrder = d.dispOrder;
                item.dateRange = dataRange
                item.total = "";
                item.unit = "";
              });
              list.push(listItems);
            }
          });
        }
        this.listItems = _.flatten(deepCopy(list));
        this.total = this.listItems.length;
        if(this.total > 0) {
          this.editDisplayParams();
          if(this.params) {
            await this.loadCellDisplay();
          }
        }
      } catch (error) {
        getErrorMessage('DynamicTemplateComponent.vue', 'initLayout', error);
      } finally {
        this.setLoadingScreenVisible(false);
      }
    },
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        const patListLayoutCd = this.getSelectedDynamicLayout.patListLayoutCd;
        const rangeDate = this.getRangeDate.find(
          d => d.layoutCd === patListLayoutCd
        );
        if (!rangeDate) return;
        let startDate = dayjs(rangeDate.dayObj.startDate).format('YYYY-MM-DD');
        let endDate = dayjs(rangeDate.dayObj.endDate).format('YYYY-MM-DD');
        const param = {
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          patIds: [],
          machineNos: [],
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          facilityCd: this.getFacilityCd,
          functionCd:"00801",
          date: dayjs(Date.now()).format("YYYYMMDD"),
          fromDate: dayjs(Date.now()).format("YYYYMMDD"),
          toDate: dayjs(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: dayjs(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    formatName(item, displayName) {
      let strName = "";
      if (!displayName && item.id !== 0) {
        return strName;
      }
      if (item.id === 0) {
        return (strName = item.name);
      }

      strName = displayName;
      Object.keys(item).forEach(key => {
        if (!displayName.includes(key)) return;

        strName = strName.split(`[${key}]`).join(item[key]);
      });
      return strName.trim();
    },
    rangeDate(templateCd) {
      let listRangeDate = [];
      if (this.getRangeDate.length === 0) {
        return listRangeDate;
      }

      if (!this.getSelectedDynamicLayout) {
        return listRangeDate;
      }

      const patListLayoutCd = this.getSelectedDynamicLayout.patListLayoutCd;

      const rangeDate = this.getRangeDate.find(
        d => d.layoutCd === patListLayoutCd
      );

      if (!rangeDate) return listRangeDate;
      const dayObj = rangeDate.dayObj;
      if (templateCd === DATE_TEMPLATE_CD) {
        listRangeDate = this.groupDateByMonth(dayObj.startDate, dayObj.endDate);
      }
      if (templateCd === MONTH_TEMPLATE_CD) {
        listRangeDate = this.groupMonthByYear(dayObj.startDate, dayObj.endDate);
      }

      return listRangeDate;
    },
    groupDateByMonth(startDate, endDate) {
      const dateRange = [];
      let start = dayjs(startDate);
      let end = dayjs(endDate);
      while (start <= end) {
        const dateObj = {
          from:dayjs(start).format("YYYYMMDD"),
          to:dayjs(end).format("YYYYMMDD"),
          headerItem: dayjs(start).format("DD"),
          headerGroupItem: dayjs(start).format("YYYY/MM"),
          date: dayjs(start).format("YYYYMMDD"),
          name: dayjs(start)
            .format("dddd")
            .replace("曜日", ""),
          data: null
        };
        dateRange.push(dateObj);
        start = dayjs(start).add(1, "days");
      }

      let a = 1;
      dateRange.reduce((prev, curr) => {
        if (
          prev.length &&
          curr.headerGroupItem === prev[prev.length - 1].headerGroupItem
        ) {
          prev[prev.length - 1].countGroup = a++;
        } else {
          a = 1;
          prev.push(curr);
          curr.showGroup = true;
          curr.countGroup = a++;
        }
        return prev;
      }, []);
      return dateRange;
    },
    groupMonthByYear(startDate, endDate) {
      const dateRange = [];
      let start = dayjs(startDate);
      let end = dayjs(endDate);
      let endDay = end.endOf('month').format("YYYYMMDD")
      while (start <= end) {
        const dateObj = {
          from: dayjs(start).format('YYYYMMDD'),
          to: endDay,
          headerItem: dayjs(start).format("MM"),
          headerGroupItem: dayjs(start).format("YYYY"),
          date: dayjs(start).format("YYYYMMDD"),
          name: "月",
          data: null
        };
        dateRange.push(dateObj);
        start = dayjs(start).add(1, "months");
      }

      let a = 1;
      dateRange.reduce((prev, curr) => {
        if (
          prev.length &&
          curr.headerGroupItem === prev[prev.length - 1].headerGroupItem
        ) {
          prev[prev.length - 1].countGroup = a++;
        } else {
          a = 1;
          prev.push(curr);
          curr.showGroup = true;
          curr.countGroup = a++;
        }
        return prev;
      }, []);
      return dateRange;
    },
    editDisplayParams() {
      // パラメーター初期化
      this.params = [];
      if (this.listItems.length === 0) return;
      this.listItems.forEach(item => {
        const dateRange = item.dateRange;
        if (dateRange.length) {
          const obj = {
            id: item.id,
            name: item.name,
            dataListDetailCd: item.dataListDetailCd,
            kubun: item.kubun ? item.kubun : 0,
            date: item.dateRange[0].date,
            from: item.dateRange[0].from,
            to: item.dateRange[0].to
          }
          if ("type" in item) {
            obj["type"] = item.type
          }
          this.params.push(obj)
        }
      });
    },
    async onGridDataSourceRead(options) {
      const params = this.params ?? [];
      if (!params.length) {
        options.success({ total: 0, data: [] });
        return;
      }

      let startIndex = (options.data.page - 1) * options.data.pageSize;
      let endIndex = startIndex + options.data.pageSize;
      if (endIndex > params.length) {
        endIndex = params.length;
      }
      const searchData = this.searchData ?? [];
      if (!this.pageList.has(options.data.page) && searchData.length > 0) {
        const tempData = params.slice(startIndex, endIndex);
        if (tempData.length > 0) {
          for (let i = 0; i < tempData.length; i++) {
            const handleIndex = searchData.findIndex(
              el =>
                el.id == tempData[i].id &&
                el.detailCd == tempData[i].dataListDetailCd
            );
            this.mapData(searchData[handleIndex], tempData[i]);
          }
        }
        this.pageList.add(options.data.page);
      }
      const tempResult = this.getData(this.listItems.slice(startIndex, endIndex));
      EventBus.$emit("allowEditTrue", false);
      EventBus.$emit("setFooterMsgFlg", false);
      options.success({
        total: this.total,
        data: tempResult,
      });
    },
    async loadCellDisplay() {
      await this.editResData(this.params);
      this.$nextTick(() => {
        this.$refs.grid?.getWidget()?.dataSource?.read();
        this.calculateReportArea();
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
      this.$nextTick(() => {
        this.setLockedContentHeight();
        this.setLockedHeaderHeight();
        this.setRowHeight();
        this.$refs.grid?.resize();
      });
    },
    async editResData(params) {
      let url = `sysDataListDetail/rowResult`;
      let reqParams = [];
      if(params) {
        params.forEach(el => {
          reqParams.push({
            dataListDetailCd: el.dataListDetailCd,
            itemId: el.id,
            dateFrom: el.from,
            dateTo: el.to,
            kubun: el.kubun
          });
        });
      }
      const res = await ApiHelper.post(url, reqParams);
      if(res.status == 200) {
        this.searchData = res.data;
      }
    },
    mapData(dataResponse, dataParams) {
      const indexItem = this.listItems.findIndex(
        i =>
          i.id === dataParams.id &&
          i.dataListDetailCd === dataParams.dataListDetailCd
      );
      if (indexItem >= 0) {
        const indexDate = this.listItems[indexItem].dateRange.findIndex(
          dateObj => dateObj.date === dataParams.date
        );
        if (indexDate >= 0) {
          if (_.isEmpty(dataResponse)) {
            for (let i = 0; i < this.listItems[indexItem].dateRange.length; i++) {
              this.listItems[indexItem].dateRange[i].data = ''
            }
            return;
          }
          let unit = "";
          if (!("cellDisplay" in dataResponse)) return;

          if ("unit" in dataResponse) {
            unit = !dataResponse.unit ? "" : dataResponse.unit;
          }
          let cellDisplayPattern = !dataResponse.cellDisplay
            ? ""
            : dataResponse.cellDisplay;
          const arr = cellDisplayPattern.split(' ')
          if (arr[arr.length - 1] !== '集計') {
            this.listItems[indexItem].unit = ' ' + unit + ' ' + arr[arr.length - 1]
          } else {
            this.listItems[indexItem].unit = unit
          }
          this.listItems[indexItem].cellDisplayPattern = ' ' + unit + ' ' + arr[arr.length - 1]
          let count = !dataResponse.count ? [] : dataResponse.count;
          let item;
          if (count.length > 0) {
            for (let i = 0; i < this.listItems[indexItem].dateRange.length; i++) {
              this.listItems[indexItem].dateRange[i].data = 0
              for (let j = 0; j < count.length; j++) {
                if (this.getSelectedDynamicLayout.templateCd == DATE_TEMPLATE_CD) {
                  item = this.listItems[indexItem].dateRange.find(item => item.date == count[j].treat_date)
                } else if (this.getSelectedDynamicLayout.templateCd == MONTH_TEMPLATE_CD) {
                  item = this.listItems[indexItem].dateRange.find(item => { return dayjs(item.date).format('YYYYMM') == dayjs(count[j].treat_date).format('YYYYMM') })
                }
                if (item) {
                  // if (this.getSelectedDynamicLayout.templateCd == MONTH_TEMPLATE_CD) {
                  //   item.data += count[j].count
                  // } else {
                  //   item.data = count[j].count
                  // }
                  item.data = count[j].count
                }
              }
            }
          } else {
            for (let i = 0; i < this.listItems[indexItem].dateRange.length; i++) {
              this.listItems[indexItem].dateRange[i].data = 0
            }
          }
          this.listItems[indexItem].total = 0
          let total = 0
          for (let i = 0; i < this.listItems[indexItem].dateRange.length; i++) {
            total += this.listItems[indexItem].dateRange[i].data
          }
          if (String(total).indexOf('.') > -1) {
            total = parseFloat(total).toFixed(1)
          }
          this.listItems[indexItem].total = total
        }
      }
    },
    async onCreateTemplateToExcel() {
      if (this.sortedListItems.length === 0) return;
      await this.asyncExportData();
      const columns = this.getColumns(this.sortedListItems);
      const data = this.getData(this.sortedListItems);
      this.saveExcel({
        data: data.length === 0 ? null : data,
        fileName: `データリスト_${dayjs().format("YYYYMMDDHHmmss")}`,
        columns: columns
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
    getColumns(listItems) {
      const columns = [];
      if (listItems && listItems.length) {
        const firstCol = {
          field: "name",
          title: "データ名"
        };
        const lastCol = {
          field: "totalCount",
          title: "合計"
        };
        columns.push(firstCol);
        if (listItems[0].dateRange.length) {
          listItems[0].dateRange.forEach(dayObj => {
            let dateFormat;
            if (this.getSelectedDynamicLayout.templateCd === DATE_TEMPLATE_CD) {
              dateFormat = dayjs(dayObj.date).format("YYYY/MM/DD");
            }

            if (this.getSelectedDynamicLayout.templateCd === MONTH_TEMPLATE_CD) {
              dateFormat = `${dayObj.headerGroupItem}/${dayObj.headerItem}`;
            }
            let field = "item" + (this.getSelectedDynamicLayout.templateCd === MONTH_TEMPLATE_CD ? dayObj.date.substring(0, 6) : dayObj.date)
            const colObj = {
              field: field,
              title: `${dateFormat}(${dayObj.name})`
            };
            columns.push(colObj);
          });
        }
        columns.push(lastCol);
      }
      return columns;
    },
    async asyncExportData() {
      EventBus.$emit("allowEditTrue", true);
      EventBus.$emit("setFooterMsgFlg", true);
      const totalPage = Math.ceil(this.total / this.pageSize);
      for(let i = 1; i <= totalPage; i++) {
        if(!this.pageList.has(i)) {
          this.pageList.add(i);
          let startIndex = (i - 1) * this.pageSize;
          let endIndex = startIndex + this.pageSize;
          if(endIndex > this.params.length) {
            endIndex = this.params.length;
          }
          // 検索条件
          let tempData = this.params.slice(startIndex, endIndex);
          // 項目分、繰り返す
          if(tempData && tempData.length > 0) {
            for(let i = 0; i < tempData.length; i++) {
              let handleIndex = this.searchData.findIndex(el => el.id == tempData[i].id 
                && el.detailCd == tempData[i].dataListDetailCd);
              this.mapData(this.searchData[handleIndex], tempData[i]);
            }
          }
        }
      }
      EventBus.$emit("allowEditTrue", false);
      EventBus.$emit("setFooterMsgFlg", false);
    },
    getData(listItems) {
      let data = [];
      if (listItems && listItems.length) {
        listItems.forEach(item => {
          const obj = {};
          if (item.dateRange && item.dateRange.length) {
            item.dateRange.forEach(dayObj => {
              let field = "item" + (this.getSelectedDynamicLayout.templateCd === MONTH_TEMPLATE_CD ? dayObj.date.substring(0, 6) : dayObj.date)
              if(dayObj.data) {
                obj[field] = dayObj.data + item.cellDisplayPattern;
              } else {
                obj[field] = "0 " + item.unit;
              }
            });
          }
          obj["name"] = item.name;
          obj["totalCount"] = item.total + " " + item.unit;
          data.push(obj);
        });
      }
      data = data.map(obj => {
        return {
          ...obj,
          cellOptions: { wrap: true, format: "@" },
        };
      });
      return data;
    },
    async exportToCSV() {
      await this.asyncExportData();
      const columns = this.getColumns(this.sortedListItems);
      const data = this.getData(this.sortedListItems);

      let physicalNames = "";
      const arrayFields = [];

      columns.forEach(field => {
        if (field.width !== "0px") {
          physicalNames += field.title;
          arrayFields.push(field.field);
          physicalNames += ",";
        }
      });
      physicalNames = physicalNames.substring(0, physicalNames.length - 1);
      physicalNames += "\n";
      let addNewData = [];
      data.forEach(data => {
        const tempData = [];
        arrayFields.forEach(field => {
          if (data[field]) {
            tempData.push(data[field]);
          } else {
            tempData.push("");
          }
        });
        addNewData.push(tempData);
      });
      Array(addNewData).forEach(t => {
        Object.values(t).forEach(k => {
          Object.values(k).forEach(r => {
            let temp = String(r);
            if (temp.indexOf(",") > -1)
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

      const sjisCodes = encoding.convert(charCodes, "sjis", "unicode");
      const uint8s = new Uint8Array(sjisCodes);
      const blob = new Blob([uint8s], { type: "test/csv" });

      let link = document.createElement("a");
      link.href = window.URL.createObjectURL(blob);
      link.download = `データリスト_${dayjs().format("YYYYMMDDHHmmss")}.csv`;
      link.click();
    },
    calculateReportArea() {
      this.$nextTick(() => {
        this.updateGridHeight();
        const grid = this.$refs.grid?.getWidget();
        if (!grid) {
          return;
        }
        grid.resize($(".multi-pat-list-header-switch"));
        this.setLockedContentHeight();
        this.setLockedHeaderHeight();
        this.setRowHeight();
      });
    },
    /**
     * 固定列、スクロール列の高さが倍率変更時にズレる為
     * 二つを合わせる処理を行う
     */
    setLockedContentHeight() {
      // 固定列、スクロール列の要素の高さを合わせる
      const scrollHeight = parseFloat(getComputedStyle(document.getElementsByClassName("k-auto-scrollable")[1]).height);
      const lockedArea = document.getElementsByClassName("k-grid-content-locked");
      if(lockedArea && lockedArea[0]) {
        lockedArea[0].style.height = `${scrollHeight}px`;
      }
    },
    /**
     * フォントサイズの変更時に固定列ヘッダの高さがズレる為
     * スクロール列ヘッダの高さと合わせる処理を行う
     */
    setLockedHeaderHeight() {
      // ヘッダ要素取得
      const lockHeader = document.getElementsByClassName('k-grid-header-locked')[0];
      const scrollHeader = document.getElementsByClassName('k-auto-scrollable')[0];
      const scrollTh = scrollHeader.children[0].children[1];

      // 固定列要素の高さ更新
      const lockHeaderHeight = scrollTh.getBoundingClientRect().height;
      if(lockHeader) {
        const lockTr = lockHeader.children[0].children[1].children[0];
        lockTr.style.height = `${lockHeaderHeight}px`;
      }
    },
    /**
     * テーブル内の各行の高さの調節を行う
     */
    setRowHeight() {
      // tr要素取得
      let lockTrs = $(".k-grid-content-locked").find('tr');
      let scrollTrs = $(".k-grid-content").find('tr');

      // 高さ設定
      for (let i = 0; i < lockTrs.length; i += 1) {
        let lockTr = lockTrs[i];
        let scrollTr = scrollTrs[i];

        // スタイルリセット
        lockTr.style.height = `auto`;
        scrollTr.style.height = `auto`;

        // 要素の高さを取得
        let lockH = lockTr.getBoundingClientRect().height;
        let scrollH = scrollTr.getBoundingClientRect().height;

        // 高さが異なる場合は高いほうに合わせる
        if (lockH < scrollH) {
          lockTr.style.height = `${scrollH}px`;
        } else if (scrollH < lockH) {
          scrollTr.style.height = `${lockH}px`;
        }
      }
    }
  },
  mounted() {
    this.setupGridHeightObserver();
    this.$nextTick(() => this.updateGridHeight());
  },
  async created() {
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
    this.setLoopFlag(true);
    EventBus.$off("onInitLayout", this.initLayout);
    EventBus.$off("refresh", this.initLayout);
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$on("onInitLayout", this.initLayout);
    EventBus.$on("refresh", this.initLayout);
    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);
  },
  beforeDestroy() {
    EventBus.$off("onInitLayout", this.initLayout);
    EventBus.$off("refresh", this.initLayout);
    EventBus.$off("requestReportParams", this.requestrReportParams);

    if (this.gridResizeObserver) {
      this.gridResizeObserver.disconnect();
      this.gridResizeObserver = null;
    }

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>

<style>
@media print {
  /** tableレイアウト崩れ回避 */
  body:has(#multi-pat-list-dynamic) #main-id {
    display: inline-block;
  }
  /** ヘッダレイアウト崩れ回避 */
  body:has(#multi-pat-list-dynamic) #bbs-search-area {
    width: 60%;
  }
  body:has(#multi-pat-list-dynamic) .file-button {
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

.multi-pat-list :deep(.k-grid-header-locked th),
.multi-pat-list :deep(.k-grid-header-locked .k-table-th) {
  background-image: none;
  background-color: #333333;
}

.multi-pat-list :deep(.k-grid-header-wrap table tr:nth-child(2) th),
.multi-pat-list :deep(.k-grid-header-wrap table tr:nth-child(2) .k-table-th) {
  background-image: none;
}

.multi-pat-list :deep(.k-grid-header-wrap .k-header[data-field='totalCount']),
.multi-pat-list :deep(.k-grid-header-wrap .k-table-th[data-field='totalCount']) {
  background-image: none;
}

.multi-pat-list :deep(.k-grid-header-wrap .k-header),
.multi-pat-list :deep(.k-grid-header-wrap .k-table-th) {
  background-color: #333333;
}

.multi-pat-list :deep(.k-virtual-scrollable-wrap) {
  width: 100%;
}

#multi-pat-list-dynamic :deep(.k-grid-content-locked td),
#multi-pat-list-dynamic :deep(.k-grid-content-locked .k-table-td),
#multi-pat-list-dynamic :deep(.k-virtual-scrollable-wrap td),
#multi-pat-list-dynamic :deep(.k-virtual-scrollable-wrap .k-table-td) {
  white-space: nowrap !important;
  overflow: hidden !important;
  text-overflow: ellipsis !important;
}

:deep(.k-grid-header) {
  background: var(--ntss-list-header-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,0.1) 100%);
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

:deep(.k-grid-header-locked th),
:deep(.k-grid-header-locked .k-table-th) {
  background-image: none;
}
</style>
