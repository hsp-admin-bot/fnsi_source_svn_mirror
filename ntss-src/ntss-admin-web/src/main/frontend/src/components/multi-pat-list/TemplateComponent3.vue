<template>
  <div id="multi-pat-list-template3" class="multi-pat-list" style="width: 100%; height: 100%">
    <div class="scroll-table">
      <table class="grid-record-list" style="width: max-content;">
        <col />
        <thead>
          <tr id="first-row">
            <th rowspan="2" class="ntss-list-header-th-sticky headcol frezee-column-name manual-width">
              <span @click="sortBy('machine_name')" class="clickable-header-label" :class="sortedClass('machine_name')">装置名</span>
            </th>
            <th rowspan="2" class="ntss-list-header-th-sticky headcol manual-width">
              <span @click="sortBy('machine_serial')" class="clickable-header-label" :class="sortedClass('machine_serial')">製造番号</span>
            </th>
            <template v-for="(titleObj, index) in dataTitle">
              <th
                class="ntss-list-header-th-sticky headcol text-center manual-width"
                :key="`${titleObj.detailCd}-${index}`"
              >
                <span @click="sortBy('title:' + index)" class="clickable-header-label" :class="sortedClass('title:' + index)">{{ titleObj.name }}</span>
              </th>
            </template>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(layout, machineTypeCd) in sortLayoutData" :key="machineTypeCd">
            <td class="frezee-column-name sticky-body-items">{{ layout.machine_name }}</td>
            <td class="sticky-body-items">{{ layout.machine_serial }}</td>
            <template v-for="(item, d) in layout.items">
              <td :key="d">{{ item }}</td>
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
//add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
import { getCurrentFunctionCd } from '@/router/routing-helper';
//add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";
import PrintMixin from "@/components/PrintMixin";
export default {
  mixins: [PrintMixin],
  data() {
    return {
      condition: [],
      layoutData: [],
      dataTitle: [],
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
    ...mapGetters("account-edit", {
      getFontSize: "getFontSize",
    }),
    
    sortLayoutData() {      
      const sortField = this.sort.key;
      const isAsc = this.sort.isAsc;
      // ソートなしは元のリストをそのままreturn
      if (!sortField) return this.layoutData;

      let sorted = [];
      // 装置名、装置番号以外は個別にソート
      if (sortField.includes(":")) {
        const itemIndex = sortField.split(":")[1]; // ソート対象の可変列のインデックス
        const isAsc = this.sort.isAsc;
      
        sorted = [...this.layoutData].sort((a, b) => {
          const aVal = a.items[itemIndex];
          const bVal = b.items[itemIndex];
      
          const aIsEmpty = aVal === null || aVal === undefined || aVal === "";
          const bIsEmpty = bVal === null || bVal === undefined || bVal === "";
      
          // 空欄の扱い（昇順なら後方、降順なら前方）
          if (aIsEmpty && !bIsEmpty) return isAsc ? 1 : -1;
          if (!aIsEmpty && bIsEmpty) return isAsc ? -1 : 1;
          if (aIsEmpty && bIsEmpty) return 0;
      
          // 数値判定
          const aNum = Number(aVal);
          const bNum = Number(bVal);
          const aIsNum = !isNaN(aNum);
          const bIsNum = !isNaN(bNum);
      
          // 数値と文字列が混在する場合の優先順位
          if (aIsNum && !bIsNum) return isAsc ? -1 : 1; // 昇順なら数値が前
          if (!aIsNum && bIsNum) return isAsc ? 1 : -1; // 昇順なら文字列が後
      
          // 両方数値
          if (aIsNum && bIsNum) {
            if (aNum < bNum) return isAsc ? -1 : 1;
            if (aNum > bNum) return isAsc ? 1 : -1;
            return 0;
          }
      
          // 両方文字列（辞書順）
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
      let firstRowEle = null;
      const interval = setInterval(() => {
        firstRowEle = document.getElementById('first-row');
        if (firstRowEle) {
          clearInterval(interval);
        }
      }, 1000);
    },
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
    requestrReportParams(param) {
      // 機能コード判定
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
        let startDate = moment(rangeDate.dayObj.startDate).format('YYYY-MM-DD');
        let endDate = moment(rangeDate.dayObj.endDate).format('YYYY-MM-DD');
        const param = {
          // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //patId: this.selectedPatId,
          // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          patIds: [],
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          facilityCd: this.getFacilityCd,
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          // date:moment(startDate).format('YYYY/MM/DD'),
          // fromDate: moment(startDate).format('YYYY/MM/DD'),
          // toDate: moment(endDate).format('YYYY/MM/DD'),
          date: moment(Date.now()).format("YYYYMMDD"),
          fromDate: moment(Date.now()).format("YYYYMMDD"),
          toDate: moment(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: moment(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          functionCd:"00801",
          machineNos:rowTmp
        };
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
        getErrorMessage('TemplateComponent3.vue', 'initLayout', error);
        this.setLoadingScreenVisible(false);
        // console.log(error);
      } finally {
        const data = response.data;
        if (data && data.length) {
          this.dataTitle = [];
          this.condition = [];
          data.forEach(x => {
            if (x.dataListDetailCd && x.items[0]) {
              if (x.dataListDetailCd + '' === '1368' || x.dataListDetailCd + '' === '1369' || x.dataListDetailCd + '' === '1370') {
                x.items.forEach(y => this.dataTitle.push({name: y.name, detailCd: x.dataListDetailCd + ''}));
              } else if (x.dataListDetailCd + '' !== '1366' && x.dataListDetailCd + '' !== '1367') {
                x.items.forEach(y => this.condition.push({name: y.name, detailCd: x.dataListDetailCd + ''}));
              }
            }
          });
          if (this.condition.length > 0) {
            this.condition.forEach(dataItem => {
              switch(dataItem.detailCd) {
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
          this.dataTitle.push({name: ' ', detailCd: 'typeCd'});
          this.dataTitle.push({name: ' ', detailCd: 'detailCd'});
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
        getErrorMessage('TemplateComponent3.vue', 'initData', error);
        this.setLoadingScreenVisible(false);
        // console.log(error);
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
                  items.push(moment(mstMachineData.setting_date).format('YYYY/MM/DD'));
                } else {
                  items.push("");
                }
              }
              let typeTmp = "";
              let typeCd = "";
              switch(dataItem.detailCd) {
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
                //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
                machine_no: mstMachineData.machine_no,
                //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
                machine_serial: mstMachineData.machine_serial,
                machine_type_cd: mstMachineData.machine_type_cd,
                typeCd: typeCd,
                detailCd: dataItem.detailCd,
                items: items
              });
            });
          });
        }
        this.layoutData = initData;

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
      let startDate = rangeDate.dayObj.startDate.format('YYYYMMDD');
      let endDate = rangeDate.dayObj.endDate.format('YYYYMMDD');
      const url = `sysDataListDetail/getListData/${this.getSelectedDynamicLayout.templateCd}/${this.getFacilityCd}/${startDate}/${endDate}`;
      let response;
      try {
        response = await ApiHelper.get(url);
        this.setLoadingScreenVisible(false);
      } catch (error) {
        getErrorMessage('TemplateComponent3.vue', 'getListData', error);
        this.setLoadingScreenVisible(false);
        // console.log(error);
      } finally {
        const colData = response.data.mntMotionRecordList;
        colData.forEach(motionRecord => {
          let contentsTmp = "";
          // mod 11892 【因島】データリスト「装置情報(自己診断)」テンプレート出力結果のフォーマットおよびパフォーマンス不正 zkm start
          let contents
          if (null !== motionRecord.contents) {
            motionRecord.contents.split(",").forEach(item => {
              contentsTmp = contentsTmp + item.replace(/: (\d+)(\.\d+)/,': "$1$2"') + ","
            });
            contents = JSON.parse(contentsTmp.substring(0, contentsTmp.length - 1));
          }
          // let contents = JSON.parse(contentsTmp.substring(0, contentsTmp.length - 1));
          // mod 11892 【因島】データリスト「装置情報(自己診断)」テンプレート出力結果のフォーマットおよびパフォーマンス不正 zkm end
          let hasflg = false;
          if (contents) {
            this.condition.forEach(data => {
              let valueTmp = contents[data.detailCd];
              if (valueTmp && valueTmp !== "") {
                hasflg = true;
                if ((motionRecord.testType + '' === "1" && data.detailCd === "47")
                  || (motionRecord.testType + '' === "4" && data.detailCd === "65")) {
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
            // mod 11892 【因島】データリスト「装置情報(自己診断)」テンプレート出力結果のフォーマットおよびパフォーマンス不正 zkm start
            // let eventRegDate = moment(motionRecord.eventRegDate).format('YYYY/MM/DD HH:mm:ss');
            let eventRegDate = moment(motionRecord.eventRegDate).format('YYYY/MM/DD');
            // mod 11892 【因島】データリスト「装置情報(自己診断)」テンプレート出力結果のフォーマットおよびパフォーマンス不正 zkm end
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
                  && rowTmp.typeCd === motionRecord.testType + '') {
                  valueTmp = contents[rowTmp.detailCd];
                  pushFlg = true;
                }
                rowTmp.items.push(valueTmp);
              });
              if (pushFlg) {
                this.dataTitle.push({name: eventRegDate, detailCd: eventRegDate});
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
                  && rowTmp.typeCd === motionRecord.testType + '') {
                  valueTmp = contents[rowTmp.detailCd];
                }
                if (valueTmp !== "") {
                  rowTmp.items[indexTmp] = valueTmp;
                }
              });
            }
          }
        });
      }
    },

    onCreateTemplateToExcel() {
      if (this.sortLayoutData.length === 0) return;

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
      if (this.sortLayoutData && this.sortLayoutData.length > 0) {
        columns = [
          {
            field: 'machine_name',
            title: '装置名',
          },
          {
            field: 'machine_serial',
            title: '装置番号',
          },
        ];
        this.dataTitle.forEach(x => {
          columns.push({
            field: x.detailCd,
            title: x.name,
          });
        });
      }
      return columns;
    },

    getData() {
      let data = [];
      if (this.sortLayoutData && this.sortLayoutData.length > 0) {
        data = this.sortLayoutData.map(x => {
          let dataTmp = {};
          dataTmp["machine_name"] = x.machine_name;
          dataTmp["machine_serial"] = x.machine_serial;
          x.items.forEach((y, index) => {
            dataTmp[this.dataTitle[index].detailCd] = y;
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
      // mod #11528 【たくしん会】データリスト並び順不正 関 start
      // let addNewData = [];
      // data.forEach(data => {
      //   const tempData = [];
      //   Object.keys(data).forEach(key => {
      //     if (!arrayFields.includes(key)) {
      //       return;
      //     } else {
      //       tempData.push(data[key]);
      //     }
      //   });
      //   addNewData.push(tempData);
      // });
      // addNewData = addNewData.map(i => i.reverse());
      // addNewData = addNewData.map(ii => {
      //   if (ii.length > 0) {
      //     const first = ii[0];
      //     ii.shift();
      //     ii.push(first);
      //   }
      //   return ii;
      // });
      let addNewData = [];
      data.forEach(data => {
        const tempData = [];
        arrayFields.forEach(item => {
        if(data.hasOwnProperty(item)) {
          // mod #11600 データリスト画面不正 関 start
          tempData.push(data[item] ?? "");
          // mod #11600 データリスト画面不正 関 end
        }
        });
        addNewData.push(tempData);
      });
      // mod #11528 【たくしん会】データリスト並び順不正 関 end

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
    EventBus.$on('onInitLayout', this.initLayout);
    EventBus.$on('refresh', this.initLayout);
    EventBus.$on('requestReportParams', this.requestrReportParams);
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    /* modify by chamaojia 2023-06-08 [8610] EventBusイベントの結合解除は結合と一致する（イベントコールバック関数を指定）  --start */
    EventBus.$off('onInitLayout', this.initLayout);
    EventBus.$off('refresh', this.initLayout);
    EventBus.$off('requestReportParams', this.requestrReportParams);
    /* modify by chamaojia 2023-06-08 [8610] EventBusイベントの結合解除は結合と一致する（イベントコールバック関数を指定）  --end */
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },
  // add 性能改善メモリ不足 shan end
};
</script>

<style>
@media print {
  /** ヘッダレイアウト崩れ回避 */
  body:has(#multi-pat-list-template3) #bbs-search-area {
    width: 60%;
  }
  body:has(#multi-pat-list-template3) .file-button {
    margin-left: 10%;
  }
  /** 右端スクロール時はみ出し回避 */
  body:has(#multi-pat-list-template3) #main-id {
    margin-left: -1px;
  }
}
</style>

<style scoped lang="scss">
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
      top: 38px;
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
