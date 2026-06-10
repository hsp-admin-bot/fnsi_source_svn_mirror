<template>
  <div id="multi-pat-list-template4" class="multi-pat-list" style="width: 100%; height: 100%">
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
            <th
              v-for="(data, id) in fixedTitle"
              :key="data.name + id"
              rowspan="2"
              class="ntss-list-header-th-sticky headcol manual-width"
            >
              <span @click="sortBy(getSortKey(data))" class="clickable-header-label" :class="sortedClass(getSortKey(data))">{{ data.name }}</span>
            </th>
            <th rowspan="2" class="ntss-list-header-th-sticky headcol manual-width">
              <span @click="sortBy('category_name')" class="clickable-header-label" :class="sortedClass('category_name')">点検項目</span>
            </th>
            <th rowspan="2" class="ntss-list-header-th-sticky headcol manual-width" v-show="isShowLayoutClass">
              <span @click="sortBy('mainte_type')" class="clickable-header-label" :class="sortedClass('mainte_type')">点検種別</span>
            </th>
            <th
              v-for="(data, id) in dataTitle2"
              :key="data.name + id"
              rowspan="2"
              class="ntss-list-header-th-sticky headcol manual-width"
            >
              <span @click="sortBy(getSortKey(data))" class="clickable-header-label" :class="sortedClass(getSortKey(data))">{{ data.name }}</span>
            </th>
            <template v-for="(dayObj, index) in dateList">
              <th
                class="ntss-list-header-th-sticky headcol text-center manual-width"
                :colspan="countGroup"
                :key="dayObj + index"
                v-show="hasDateData"
              >
              {{ dayObj }}</th>
            </template>
          </tr>
          <tr>
            <th
              v-for="(data, id) in loopTitle"
              :key="data + id"
              class="ntss-list-header-th-sticky headcol text-center th-sticky-day manual-width"
            >
              <span @click="sortBy(getSortKey(data))" class="clickable-header-label" :class="sortedClass(getSortKey(data))">{{ data.name }}</span>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, index) in sortedLayoutData" :key="item.machine_name + item.machine_serial + item.bed_name + index">
            <td class="frezee-column-name sticky-body-items">{{ item.machine_name }}</td>
            <td class="sticky-body-items">{{ item.machine_serial }}</td>
            <td v-show="hasMachineType" class="sticky-body-items">{{ item.machine_type }}</td>
            <td v-show="hasBedName" class="sticky-body-items">{{ item.bed_name }}</td>
            <td v-show="hasSettingDate" class="sticky-body-items">{{ item.setting_date }}</td>
            <td v-show="hasLayoutClass" class="sticky-body-items">{{ item.layout_class }}</td>
            <td class="sticky-body-items">{{ item.category_name }}</td>
            <td class="sticky-body-items" v-show="isShowLayoutClass">{{ item.mainte_type }}</td>
            <td v-show="hasMainteContent1" class="sticky-body-items">{{ item.mainte_content_1 }}</td>
            <td v-show="hasMainteContent2" class="sticky-body-items">{{ item.mainte_content_2 }}</td>
            <td v-show="hasMainteContent3" class="sticky-body-items">{{ item.mainte_content_3 }}</td>
            <template v-show="hasDateData" v-for="dayObj in item.daylist">
              <td v-show="hasCheckerId1" >{{ dayObj.checker_id_1 }}</td>
              <td v-show="hasCheckerId2" >{{ dayObj.checker_id_2 }}</td>
              <td v-show="hasJudge" >{{ dayObj.judge }}</td>
              <td v-show="hasRecNo" >{{ dayObj.rec_no }}</td>
              <td v-show="hasComment">{{ dayObj.comment }}</td>
              <td v-show="hasSubCmt">{{ dayObj.sub_cmt }}</td>
            </template>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import _ from 'underscore';
import moment from 'moment';
import { EventBus } from '@/eventBus.js';
import encoding from 'encoding-japanese';
import { mapGetters, mapActions } from 'vuex';
import { ApiHelper } from '@/apis/AxiosHelper';
// import { saveExcel } from "@progress/kendo-vue-excel-export";
var workbook_1 = require("@progress/kendo-vue-excel-export");
var kendo_file_saver_1 = require("@progress/kendo-file-saver");
import { getCurrentFunctionCd } from '@/router/routing-helper';
import { getErrorMessage } from '@/functions/common/AppLogMessageFormat';
import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";
import PrintMixin from "@/components/PrintMixin";

export default {
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
    // 共通ローダー設定
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
    // 固定項目からソートキーを取得
    getSortKey(data) {
      const sortKeyMap = {
        1387: "machine_type", // 型式
        1388: "bed_name",     // ベッド名
        1389: "setting_date", // 設置日
        1392: "layout_class", // 定期/日常
        1395: "mainte_content_1", // 項目1
        1396: "mainte_content_2", // 項目2
        1397: "mainte_content_3", // 項目3
        1398: "checker_id_1", // 実施者
        1399: "checker_id_2", // 確認者
        1400: "judge",        // 点検結果
        1401: "rec_no",       // 点検記録番号
        1402: "comment",      // 点検コメント
        1403: "sub_cmt",      // 補足コメント
      };
      
      let sortKey = sortKeyMap[data.id] || "";
      if ([1398, 1399, 1400, 1401, 1402, 1403].includes(data.id)) {
        sortKey = `${data.date}:${sortKey}`;
      }
      return sortKey;
    },
    
    getPositionHeader() {
      const elm = document.getElementById('first-row');
      if (elm) {
        const height = elm.getBoundingClientRect().height;
        document.documentElement.style.setProperty('--multi-pat-list-template4-top',`${height}px`);
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
      let startDate = moment(rangeDate.dayObj.startDate).format('YYYY-MM-DD');
      let endDate = moment(rangeDate.dayObj.endDate).format('YYYY-MM-DD');
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
        date_list = _.uniq(date_list);
        date_list = date_list.sort(
          (a, b) => a.replace(/\//g, '') - b.replace(/\//g, '')
        );
        this.dateList = date_list;
        if (rowData.length == 0) {
          this.layoutData = [];
          return;
        }
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
                let index = _.indexOf(row.daylist, daylistFilter[0]);
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
        this.$nextTick(() => {
          this.getPositionHeader();
        });
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
        let startDate = moment(rangeDate.dayObj.startDate).format('YYYY-MM-DD');
        let endDate = moment(rangeDate.dayObj.endDate).format('YYYY-MM-DD');
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

    getColumns(layoutData) {
      let columns = [];
      if (layoutData && layoutData.length) {
        let hasCheckerId1 = this.hasCheckerId1;
        let hasCheckerId2 = this.hasCheckerId2;
        let hasJudge = this.hasJudge;
        let hasRecNo = this.hasRecNo;
        let hasComment = this.hasComment;
        let hasSubCmt = this.hasSubCmt;
        columns = [
          {
            field: 'machine_name',
            title: '装置名',
          },
          {
            field: 'machine_serial',
            title: '製造番号',
          },
        ];
        this.fixedTitle.forEach(x => {
          if (x.id + '' == '1387') {
            columns.push({
              field: 'machine_type',
              title: x.name,
            });
          } else if (x.id + '' == '1388') {
            columns.push({
              field: 'bed_name',
              title: x.name,
            });
          } else if (x.id + '' == '1389') {
            columns.push({
              field: 'setting_date',
              title: x.name,
            });
          } else if (x.id + '' == '1392') {
            columns.push({
              field: 'layout_class',
              title: x.name,
            });
          }
        });
        columns.push({
          field: 'category_name',
          title: '点検項目',
        });
        columns.push({
          field: 'mainte_type',
          title: '点検種別',
        });
        this.dataTitle2.forEach(x => {
          if (x.id + '' == '1395') {
            columns.push({
              field: 'mainte_content_1',
              title: x.name,
            });
          } else if (x.id + '' == '1396') {
            columns.push({
              field: 'mainte_content_2',
              title: x.name,
            });
          } else if (x.id + '' == '1397') {
            columns.push({
              field: 'mainte_content_3',
              title: x.name,
            });
          }
        });
        this.dateList.forEach(x => {
          if (hasCheckerId1) {
            columns.push({
              field: x + 'checker_id_1',
              title: x + '実施者',
            });
          }
          if (hasCheckerId2) {
            columns.push({
              field: x + 'checker_id_2',
              title: x + '確認者',
            });
          }
          if (hasJudge) {
            columns.push({
              field: x + 'judge',
              title: x + '点検結果',
            });
          }
          if (hasRecNo) {
            columns.push({
              field: x + 'rec_no',
              title: x + '点検記録番号',
            });
          }
          if (hasComment) {
            columns.push({
              field: x + 'comment',
              title: x + '点検コメント',
            });
          }
          if (hasSubCmt) {
            columns.push({
              field: x + 'sub_cmt',
              title: x + '補足コメント',
            });
          }
        });
      }
      return columns;
    },

    getData(layoutData) {
      let data = [];
      if (layoutData && layoutData.length) {
        let hasCheckerId1 = this.hasCheckerId1;
        let hasCheckerId2 = this.hasCheckerId2;
        let hasJudge = this.hasJudge;
        let hasRecNo = this.hasRecNo;
        let hasComment = this.hasComment;
        let hasSubCmt = this.hasSubCmt;
        data = layoutData.map(x => {
          x.daylist.forEach(y => {
            if (hasCheckerId1) {
              x[y.d + 'checker_id_1'] = y.checker_id_1;
            }
            if (hasCheckerId2) {
              x[y.d + 'checker_id_2'] = y.checker_id_2;
            }
            if (hasJudge) {
              x[y.d + 'judge'] = y.judge;
            }
            if (hasRecNo) {
              x[y.d + 'rec_no'] = y.rec_no;
            }
            if (hasComment) {
              x[y.d + 'comment'] = y.comment;
            }
            if (hasSubCmt) {
              x[y.d + 'sub_cmt'] = y.sub_cmt;
            }
          });
          return x;
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

  beforeDestroy() {
    /* modify by chamaojia 2023-06-08 [8610] EventBusイベントの結合解除は結合と一致する（イベントコールバック関数を指定）  --start */
    EventBus.$off('onInitLayout', this.initLayout);
    EventBus.$off('refresh', this.initLayout);
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
  body:has(#multi-pat-list-template4) #bbs-search-area {
    width: 60%;
  }
  body:has(#multi-pat-list-template4) .file-button {
    margin-left: 10%;
  }
  /** 右端スクロール時はみ出し回避 */
  body:has(#multi-pat-list-template4) #main-id {
    margin-left: -1px;
  }
}
</style>

<style scoped lang="scss">
:root {
  --multi-pat-list-template4-top: 32px;
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
      top: var(--multi-pat-list-template4-top);
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
