<template>
  <div id="multi-pat-list-template2" class="multi-pat-list" style="width: 100%; height: 100%">
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
              :key="'fixedtitle-' + id"
              rowspan="2"
              class="ntss-list-header-th-sticky headcol manual-width"
            >
              <span @click="sortBy(getSortKey(data))" class="clickable-header-label" :class="sortedClass(getSortKey(data))">{{ data.name }}</span>
            </th>
            <th rowspan="2" class="ntss-list-header-th-sticky headcol manual-width">
              <span @click="sortBy('survey_type_name')" class="clickable-header-label" :class="sortedClass('survey_type_name')">検査種別</span>
            </th>
            <th rowspan="2" class="ntss-list-header-th-sticky headcol manual-width">
              <span @click="sortBy('point_name')" class="clickable-header-label" :class="sortedClass('point_name')">検査箇所</span>
            </th>
            <template v-for="(dayObj, index) in dateList">
              <th
                class="ntss-list-header-th-sticky headcol text-center manual-width"
                :colspan="countGroup"
                :key="'day-' + index"
              >{{ dayObj }}</th>
            </template>
          </tr>
          <tr>
            <th
              v-for="(data, id) in loopTitle"
              :key="'looptitle-' + id"
              class="ntss-list-header-th-sticky headcol text-center th-sticky-day manual-width"
            >
              <span @click="sortBy(getSortKey(data))" class="clickable-header-label" :class="sortedClass(getSortKey(data))">{{ data.name }}</span>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, machineTypeCd) in sortedLayoutData" :key="machineTypeCd">
            <td class="frezee-column-name sticky-body-items">{{ item.machine_name }}</td>
            <td class="sticky-body-items">{{ item.machine_serial }}</td>
            <td class="sticky-body-items" v-show="hasMachineType">{{ item.machine_type }}</td>
            <td class="sticky-body-items" v-show="hasBedName">{{ item.bed_name }}</td>
            <td class="sticky-body-items" v-show="hasSettingDate">{{ item.setting_date }}</td>
            <td class="sticky-body-items">{{ item.survey_type_name }}</td>
            <td class="sticky-body-items">{{ item.point_name }}</td>
            <template v-for="(dayObj, d) in item.daylist">
              <td v-show="hasTime" :key="'time-' + d">{{ dayObj.time }}</td>
              <td v-show="hasValue" :key="'value-' + d">{{ dayObj.value }}</td>
              <td v-show="hasPicker" :key="'picker-' + d">{{ dayObj.picker }}</td>
              <td v-show="hasInspector" :key="'inspector-' + d">{{ dayObj.inspector }}</td>
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
  import {EventBus} from '@/eventBus.js';
  import encoding from 'encoding-japanese';
  import {mapActions, mapGetters} from 'vuex';
  import {ApiHelper} from '@/apis/AxiosHelper';
  // import { saveExcel } from "@progress/kendo-vue-excel-export";
  var workbook_1 = require("@progress/kendo-vue-excel-export");
  var kendo_file_saver_1 = require("@progress/kendo-file-saver");
  import {getCurrentFunctionCd} from '@/router/routing-helper';
  import {getErrorMessage} from '@/functions/common/AppLogMessageFormat';
  import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";
  import PrintMixin from "@/components/PrintMixin";

  export default {
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
      // 採取時刻、結果、採取者、検査者の場合はデータの持ち方が異なるため個別でソート
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
    hasTime() {
      return this.loopTitle.some(x => x.name == '採取時刻');
    },
    hasValue() {
      return this.loopTitle.some(x => x.name == '結果');
    },
    hasPicker() {
      return this.loopTitle.some(x => x.name == '採取者');
    },
    hasInspector() {
      return this.loopTitle.some(x => x.name == '検査者');
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

    fixedTitle() {
      this.hasMachineType = this.fixedTitle.some(x => x.id == 1358);
      this.hasBedName = this.fixedTitle.some(x => x.id == 1359);
      this.hasSettingDate = this.fixedTitle.some(x => x.id == 1360);
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
        1358: "machine_type", // 型式
        1359: "bed_name",     // ベッド名
        1360: "setting_date", // 設置日
        1362: "time",         // 採取時刻
        1363: "value",        // 結果
        1364: "picker",       // 採取者
        1365: "inspector",    // 検査者  
      };
      
      let sortKey = sortKeyMap[data.id] || "";
      if ([1362, 1363, 1364, 1365].includes(data.id)) {
        sortKey = `${data.date}:${sortKey}`;
      }
      return sortKey;
    },
    getPositionHeader() {
      const elm = document.getElementById('first-row');
      if (elm) {
        const height = elm.getBoundingClientRect().height;
        document.documentElement.style.setProperty('--multi-pat-list-template2-top',`${height}px`);
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
        getErrorMessage('TemplateComponent2.vue', 'initLayout', error);
        this.setLoadingScreenVisible(false);
        console.log(error);
      } finally {
        this.dataTitle = [];
        const data = response.data;
        if (data && data.length) {
          data.forEach(x => {
            let id = '';
            let name = '';
            let isShow = false;
            if (x.categoryCd == 141) {
              isShow = true;
            }
            if (x.dataListDetailCd && x.items[0]) {
              id = x.dataListDetailCd;
              if (x.dataListDetailCd == '1361') {
                this.condition = [];
                x.items.forEach(y => this.condition.push(y.name));
              } else if (x.dataListDetailCd == '1384') {
                this.condition2 = [];
                // add #11528 【たくしん会】データリスト並び順不正 房 start
                this.itemCds = x.itemCds;
                // add #11528 【たくしん会】データリスト並び順不正 房 end
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
        getErrorMessage('TemplateComponent2.vue', 'initData', error);
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
            x.setting_date = moment(x.setting_date).format('YYYY/MM/DD');
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
        // add #11528 【たくしん会】データリスト並び順不正 房 start
        this.layoutDataTmp.sort((a, b) => {
          let aIndex = this.itemCds.findIndex(itemCode => itemCode == a.survey_point_cd);
          let bIndex = this.itemCds.findIndex(itemCode => itemCode == b.survey_point_cd);
          return aIndex - bIndex;
        });
        // add #11528 【たくしん会】データリスト並び順不正 房 end
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
      /*add FNSI-改修内容5237 任 start*/
      const urlDecimal = `sysDataListDetail/getDecimalValue/${this.getFacilityCd}`;
      /*add FNSI-改修内容5237 任 end*/
      let response;
      /*add FNSI-改修内容5237 任 start*/
      let responseDecimal;
      /*add FNSI-改修内容5237 任 end*/
      try {
        response = await ApiHelper.get(url);
        /*add FNSI-改修内容5237 任 start*/
        responseDecimal = await ApiHelper.get(urlDecimal);
        /*add FNSI-改修内容5237 任 end*/
        this.setLoadingScreenVisible(false);
      } catch (error) {
        getErrorMessage('TemplateComponent2.vue', 'getListData', error);
        this.setLoadingScreenVisible(false);
        console.log(error);
      } finally {
        const colData = response.data.mstMachineDatalists;
        const userList = response.data.mstPersonalUsers;
        /*add FNSI-改修内容5237 任 start*/
        const decimalValue = responseDecimal.data;
        /*add FNSI-改修内容5237 任 end*/
        let date_list = [];
        colData.forEach(x =>
          date_list.push(x.inspection_date.substring(0, 10).replace(/-/g, '/'))
        );
        date_list = _.uniq(date_list);
        date_list = date_list.sort(
          (a, b) => a.replace(/\//g, '') - b.replace(/\//g, '')
        );
        this.dateList = date_list;
        let rowData = this.layoutDataTmp;
        rowData = rowData.map(row => {
          let daylist = [];
          date_list.forEach(x => {
            daylist.push({
              d: x,
              time: ' ',
              value: ' ',
              picker: ' ',
              inspector: ' ',
            });
          });
          row.daylist = daylist;

          colData.forEach(col => {
            let colDate = col.inspection_date
              .substring(0, 10)
              .replace(/-/g, '/');
            if (col.survey_point_cd == row.survey_point_cd) {
              let daylistFilter = row.daylist.filter(x => x.d == colDate);
              let index = _.indexOf(row.daylist, daylistFilter[0]);
              let value = '';
              if (col.value) {
                /*add FNSI-改修内容5237 任 start*/
                let resultFigure = col.value
                if(decimalValue.length>0){
                  for(let de = 0;de<decimalValue.length;de++){
                    if(de.surveyPointCd === Number(col.survey_point_cd)){
                      let num = '1';
                      for(let i = 0;i<de.decimalDigits;i++){
                        num += '0';
                      }
                      let f_x = Math.round(Number(col.value) * parseInt(num)) / parseInt(num);
                      let s_x = f_x.toString();
                      let pos_decimal = s_x.indexOf('.');
                      if (pos_decimal < 0) {
                        pos_decimal = s_x.length;
                        s_x += '.';
                      }
                      while (s_x.length <= pos_decimal + de.decimalDigits) {
                        s_x += '0';
                      }
                      resultFigure = s_x;
                    }
                  }
                }
                value = resultFigure + col.unit;
                /*add FNSI-改修内容5237 任 end*/
              }
              let initial_string = JSON.parse(col.initial_string);
              let text = Number(col.text) - 1;
              // mod #11528 【たくしん会】データリスト並び順不正 関 start
              // if (text > -1 && initial_string.length > col.text) {
              if (text > -1 && text < initial_string.length) {
                // mod #11528 【たくしん会】データリスト並び順不正 関 end
                value = value + initial_string[text].text;
              }
              let picker = '';
              let pUser = userList.filter(u => u.userId == col.picker);
              if (pUser.length > 0) {
                picker = pUser[0].userLastName + ' ' + pUser[0].userFirstName;
              }
              let inspector = '';
              let iUser = userList.filter(u => u.userId == col.inspector);
              if (iUser.length > 0) {
                inspector =
                  iUser[0].userLastName + ' ' + iUser[0].userFirstName;
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
          let key = item.machineTypeCd + item.machine_name + item.machine_serial + item.machine_type + item.bed_name
            + item.setting_date + item.survey_type_name + item.point_name;
          if (rowTmp.indexOf(key) === -1) {
            rowDataTmp.push(item);
            rowTmp.push(key);
          }
        });
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
        //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
        const param = {
          // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //patId: this.selectedPatId,
          // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          patIds: [],
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          facilityCd: this.getFacilityCd,
          //mod 5984 機能帳票でパラメータが正しく渡されていない 吉 start
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
          //mod 5984 機能帳票でパラメータが正しく渡されていない 吉 end
        };
        EventBus.$emit('sendReportParams', param);
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
        let hasTime = this.hasTime;
        let hasValue = this.hasValue;
        let hasPicker = this.hasPicker;
        let hasInspector = this.hasInspector;
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
          if (x.id == 1358) {
            columns.push({
              field: 'machine_type',
              title: x.name,
            });
          } else if (x.id == 1359) {
            columns.push({
              field: 'bed_name',
              title: x.name,
            });
          } else if (x.id == 1360) {
            columns.push({
              field: 'setting_date',
              title: x.name,
            });
          }
        });
        columns.push({
          field: 'survey_type_name',
          title: '検査種別',
        });
        columns.push({
          field: 'point_name',
          title: '検査箇所',
        });
        this.dateList.forEach(x => {
          if (hasTime) {
            columns.push({
              field: x + 'time',
              title: x + '採取時刻',
            });
          }
          if (hasValue) {
            columns.push({
              field: x + 'value',
              title: x + '結果',
            });
          }
          if (hasPicker) {
            columns.push({
              field: x + 'picker',
              title: x + '採取者',
            });
          }
          if (hasInspector) {
            columns.push({
              field: x + 'inspector',
              title: x + '検査者',
            });
          }
        });
      }
      return columns;
    },

    getData(layoutData) {
      let data = [];
      if (layoutData && layoutData.length) {
        let hasTime = this.hasTime;
        let hasValue = this.hasValue;
        let hasPicker = this.hasPicker;
        let hasInspector = this.hasInspector;
        data = layoutData.map(x => {
          x.daylist.forEach(y => {
            if (hasTime) {
              x[y.d + 'time'] = y.time;
            }
            if (hasValue) {
              x[y.d + 'value'] = y.value;
            }
            if (hasPicker) {
              x[y.d + 'picker'] = y.picker;
            }
            if (hasInspector) {
              x[y.d + 'inspector'] = y.inspector;
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
    // 印刷パラメータ要求
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
  body:has(#multi-pat-list-template2) #bbs-search-area {
    width: 60%;
  }
  body:has(#multi-pat-list-template2) .file-button {
    margin-left: 10%;
  }
  /** 右端スクロール時はみ出し回避 */
  body:has(#multi-pat-list-template2) #main-id {
    margin-left: -1px;
  }
}
</style>

<style scoped lang="scss">
:root {
  --multi-pat-list-template2-top: 32px;
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
      height: 38.4px;
      top: var(--multi-pat-list-template2-top);
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
