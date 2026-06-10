<template>
<!-- 集計 -->
  <div id="multi-pat-list-template5" class="multi-pat-list" style="width: 100%; height: 100%">
    <div class="scroll-table">
      <table class="grid-record-list" style="width: max-content;">
        <col />
        <thead>
          <tr id="first-row">
            <th rowspan="2" v-if="isDis" class="ntss-list-header-th-sticky headcol frezee-column-name text-center manual-width">
              <span @click="sortBy('layout_category_name')" class="clickable-header-label" :class="sortedClass('layout_category_name')"> </span>
            </th>
            <th rowspan="2" class="ntss-list-header-th-sticky headcol frezee-column-name text-center manual-width">
              <span @click="sortBy('layout_name')" class="clickable-header-label" :class="sortedClass('layout_name')"> </span>
            </th>
            <template v-for="(dayObj, index) in dateTitle">
              <th
                class="ntss-list-header-th-sticky headcol text-center manual-width"
                :colspan="countGroup"
                :key="index"
              >{{ dayObj }}</th>
            </template>
          </tr>
          <tr>
            <th
              v-for="(data, id) in dataTitle"
              :key="id"
              class="ntss-list-header-th-sticky headcol text-center th-sticky-day manual-width"
            >
              <span @click="sortBy('title:' + id)" class="clickable-header-label" :class="sortedClass('title:' + id)">{{ data }}</span>
            </th>
          </tr>
        </thead>
        <tbody>
        <tr v-for="(layout, id) in sortedLayoutData" :key="id">
          <td v-if="isDis" class="frezee-column-name sticky-body-items">{{ layout.layout_category_name }}</td>
          <td class="frezee-column-name sticky-body-items">{{ layout.layout_name }}</td>
            <template v-for="(item, d) in layout.items">
              <td :key="d">{{ item.value }}</td>
            </template>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>

import {EventBus} from "@/eventBus";
import {ApiHelper} from "@/apis/AxiosHelper";
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
import {mapActions, mapGetters} from "vuex";
import moment from "moment";
// import { saveExcel } from "@progress/kendo-vue-excel-export";
var workbook_1 = require("@progress/kendo-vue-excel-export");
var kendo_file_saver_1 = require("@progress/kendo-file-saver");
import encoding from "encoding-japanese";
import _ from "underscore";
//add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
import { getCurrentFunctionCd } from '@/router/routing-helper';
//add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";
import PrintMixin from "@/components/PrintMixin";

export default {
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
        isAsc: true
      },
      scrollQuerySelector: ".scroll-table", // スクロールコンテナ
      addClassTargetQuerySelector: ["table.grid-record-list"], // scroll-rightmostクラスを付与する対象のクエリセレクタ 
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
      let iCount = 0
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
  },

  watch: {
    getRangeDate(value) {
      if (value) {
        this.getPositionHeader();
      }
    },

    getFontSize: {
      immediate: true,
      handler() {
        this.getPositionHeader();
      },
    },

    getRequestExportExcel() {
      this.onCreateTemplateToExcel();
    },

    getRequestExportCSV() {
      this.exportToCSV();
    },
  },

  methods: {
    ...mapActions('loading-screen', [
      'setLoadingScreenVisible',
      'setLoadingScreenMessage',
    ]),
    // 昇順/降順のclassを作成
    sortedClass(key) {
      return getSortedClass(key, this.sort);
    },
    // ソートするキーを設定する
    sortBy(key) {
      updateSort(key, this.sort);
    },
    getPositionHeader() {
      const elm = document.getElementById('first-row');
      if (elm) {
        const height = elm.getBoundingClientRect().height;
        document.documentElement.style.setProperty('--multi-pat-list-template5-top',`${height}px`);
      }
    },
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
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
          date: moment(Date.now()).format("YYYYMMDD"),
          fromDate: moment(Date.now()).format("YYYYMMDD"),
          toDate: moment(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: moment(Date.now()).format("YYYYMMDD"),
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
        dateTitleTmp = _.uniq(dateTitleTmp);
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
        this.$nextTick(() => {
          this.getPositionHeader();
        });
      }
    },

    onCreateTemplateToExcel() {
      if (this.sortedLayoutData.length === 0) return;

      const columns = this.getColumns();
      const data = this.getData();
      this.saveExcel({
        data: data.length === 0 ? null : data,
        fileName: `データリスト_${moment().format('YYYYMMDDHHmmss')}`,
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
      let columns = [];
      if (this.sortedLayoutData && this.sortedLayoutData.length > 0) {
        if (this.isDis) {
          columns.push({
            field: 'layout_category_name',
            title: ' ',
          });
        }
        columns.push({
          field: 'layout_name',
          title: ' ',
        });
        this.dateTitle.forEach(x => {
          if (this.hasMecSch) {
            columns.push({
              field: x + ' mecSch',
              title: x + " 装置台数",
            });
          }
          if (this.hasMecPass) {
            columns.push({
              field: x + ' mecPass',
              title: x + " 合格台数",
            });
          }
          if (this.hasMecNg) {
            columns.push({
              field: x + ' mecNg',
              title: x + " 不合格台数",
            });
          }
        });
      }
      return columns;
    },

    getData() {
      let data = [];
      if (this.sortedLayoutData && this.sortedLayoutData.length > 0) {
        data = this.sortedLayoutData.map(x => {
          let dataTmp = {};
          if (this.isDis) {
            dataTmp["layout_category_name"] = x.layout_category_name;
          }
          dataTmp["layout_name"] = x.layout_name;
          x.items.forEach((y, index) => {
            let indexDate = Math.floor(index / this.countGroup);
            dataTmp[this.dateTitle[indexDate] + y.key] = y.value;
          });
          return dataTmp;
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

      let link = document.createElement('a');
      link.href = window.URL.createObjectURL(blob);
      link.download = `データリスト_${moment().format('YYYYMMDDHHmmss')}.csv`;
      link.click();
    },
  },

  async created() {
    this.refreshHandler = () => this.initLayout(1);
    EventBus.$on('onInitLayout', this.initLayout);
    EventBus.$on('refresh', this.refreshHandler);
    EventBus.$on('requestReportParams', this.requestrReportParams);
  },

  beforeDestroy() {
    /* modify by chamaojia 2023-06-08 [8610] EventBusイベントの結合解除は結合と一致する（イベントコールバック関数を指定）  --start */
    EventBus.$off('onInitLayout', this.initLayout);
    EventBus.$off('refresh', this.refreshHandler);
    EventBus.$off('requestReportParams', this.requestrReportParams);
    /* modify by chamaojia 2023-06-08 [8610] EventBusイベントの結合解除は結合と一致する（イベントコールバック関数を指定）  --end */
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
};
</script>

<style>
@media print {
  /** ヘッダレイアウト崩れ回避 */
  body:has(#multi-pat-list-template5) #bbs-search-area {
    width: 60%;
  }
  body:has(#multi-pat-list-template5) .file-button {
    margin-left: 10%;
  }
  /** 右端スクロール時はみ出し回避 */
  body:has(#multi-pat-list-template5) #main-id {
    margin-left: -1px;
  }
}
</style>

<style scoped lang="scss">
:root {
  --multi-pat-list-template5-top: 32px;
}

.scroll-table {
  overflow: auto;
  height: 100%;
  overflow-x:scroll;

  .grid-record-list {
    border-collapse: collapse;
    background-color: var(--ntss-list-background-color);

    .text-center {
      text-align: center;
      min-width: 80px;
      box-shadow: 0 0 0 0.5px var(--ntss-list-border-color);
      z-index: 9;
    }

    .th-sticky-day {
      top: var(--multi-pat-list-template5-top);
    }

    .frezee-column-name {
      box-shadow: 0 0 0 0.5px var(--ntss-list-border-color);
      left: 0px;
      z-index: 10;
      position: sticky;
    }

    .sticky-body-items {
      z-index: 8;
      background-color: var(--body-background-color);
    }

    thead {
      tr {
        height: 2em;
      }
    }
    tbody {
      tr {
        td {
          border: solid 1px var(--ntss-list-border-color);
          padding: 4px;
          height: 23px;
          white-space: nowrap;
          color: var(--ntss-base-color);
          max-width: 20em;
          overflow: hidden;
          text-overflow: ellipsis;
          word-break: break-all;
          .align-loading {
            display: flex;
            justify-content: center;
            z-index: -1;
          }
        }
        &:nth-child(even) {
          background-color: var(
              --ntss-list-content-2nd-background-color
          ) !important;
          td {
            background-color: var(
                --ntss-list-content-2nd-background-color
            ) !important;
          }
        }
      }
    }
  }
}
.manual-width {
  resize: horizontal;
  overflow-x: auto;
}.clickable-header-label {
  display: block;
  width: 100%;
  height: 100%;
  padding: 0 4px;
  box-sizing: border-box;
  overflow: hidden;
  align-content: center;
}
@media print {
  /** ヘッダ固定 */
  .ntss-list-header-th-sticky {
    position: sticky !important;
  }
  /** スクロールコンテナ */
  .scroll-table {
    overflow: hidden !important;
    height: auto !important;
  }
  .scroll-rightmost {
    position: relative;
    float: right;
  }
}
</style>
