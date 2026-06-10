<template>
  <div id="multi-pat-list-dynamic" class="multi-pat-list" style="width: 100%; height: 100%">
    <div class="scroll-table">
      <table class="grid-record-list" style="width: max-content;">
        <col />
        <thead>
          <tr id="first-row">
            <th rowspan="2" class="ntss-list-header-th-sticky headcol frezee-column-name manual-width">
              <span @click="sortBy('name')" class="clickable-header-label" :class="sortedClass('name')">データ名</span>
            </th>
            <template v-for="(dayObj, index) in rangeDate(getSelectedDynamicLayout.templateCd)">
            <!-- //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善、initFlag追加 xugj add start -->
              <th
                v-if="dayObj.showGroup && initFlag !== 0"
                :colspan="dayObj.countGroup"
                class="ntss-list-header-th-sticky headcol text-center manual-width"
                :key="index"
              >
                {{ dayObj.headerGroupItem }}
              </th>
            </template>
            <th v-if="initFlag !== 0" rowspan="2" class="ntss-list-header-th-sticky headcol frezee-column-name manual-width">
              <span @click="sortBy('total')" class="clickable-header-label" :class="sortedClass('total')">合計</span>
            </th>
          </tr>
          <tr v-if="initFlag !== 0">
          <!-- //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善、initFlag追加 xugj add end -->
            <!-- <th
              class="ntss-list-header-th-sticky headcol text-center th-sticky-day"
              :style="{top: topPosition + 'px'}"
              v-for="(dayObj, index) in rangeDate(getSelectedDynamicLayout.templateCd)"
              :key="index"
            >{{ dayObj.headerItem + "(" + dayObj.name + ")" }}</th> -->
            <th
              class="ntss-list-header-th-sticky headcol text-center th-sticky-day manual-width"
              v-for="(dayObj, index) in rangeDate(getSelectedDynamicLayout.templateCd)"
              :key="index"
            >
              <span @click="sortBy('title:' + index)" class="clickable-header-label" :class="sortedClass('title:' + index)">{{ dayObj.headerItem + "(" + dayObj.name + ")" }}</span>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(item, indexRow) in sortedListItems" :key="indexRow">
            <td class="frezee-column-name sticky-body-items">{{ item.name }}</td>
            <td
              v-for="(dayObj, indexCol) in item.dateRange"
              :key="indexCol"
              :id="dayObj.date + '|' + item.id + '|' + item.dataListDetailCd"
            >
              <!-- mod #6543 付 start -->
              <span v-if="dayObj.data !== null">{{ dayObj.data + item.cellDisplayPattern }}</span>
              <!-- mod #6543 付 end -->
              <span v-else-if="checkFlag !== 0"></span>
              <span class="align-loading" v-else>
                <v-ons-icon icon="fa-spinner" spin />
              </span>
            </td>
            <!-- //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add start -->
            <td v-if="initFlag !== 0">
            <!-- //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add end -->
              <span v-if="item.total !== ''">{{ item.total + ' ' + item.unit}}</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script>
import _ from "underscore";
import moment from "moment";
import { EventBus } from "@/eventBus.js";
import encoding from "encoding-japanese";
// mod FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou start
// import { mapGetters, mapActions } from "vuex";
import { mapGetters, mapActions, mapMutations } from "vuex";
// mod FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou end
import { ApiHelper } from "@/apis/AxiosHelper";
// import { saveExcel } from "@progress/kendo-vue-excel-export";
var workbook_1 = require("@progress/kendo-vue-excel-export");
var kendo_file_saver_1 = require("@progress/kendo-file-saver");
import { DATE_TEMPLATE_CD, MONTH_TEMPLATE_CD } from "@/constants/dataListConstant";
// add 画面印刷プレビューと印刷の実現 黄 start
import { getCurrentFunctionCd } from "@/router/routing-helper";
// add 画面印刷プレビューと印刷の実現 黄 end
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
//FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add start
import { deepCopy } from "@/functions/common/CommonFunctions";
//FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add end
import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";
import PrintMixin from "@/components/PrintMixin";

export default {
  mixins: [PrintMixin],
  data() {
    return {
      //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add start
      initFlag: 0,
      //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add end
      layoutData: [],
      listItems: [],
      topPosition: 0,
      breakCallApi: false,
      checkFlag: 0,
      selfScreenName: "",
      sort: {
        key: "",
        isAsc: true
      },
      // ソート可否フラグ（集計中のソートを抑止するフラグ）
      isSortAllowed: true ,
      scrollQuerySelector: ".scroll-table", // スクロールコンテナ
      addClassTargetQuerySelector: ["table.grid-record-list"], // scroll-rightmostクラスを付与する対象のクエリセレクタ
    };
  },

  computed: {
    ...mapGetters("data-list", [
      "getSelectedDynamicLayout",
      "getRangeDate",
      "getRequestExportExcel",
      "getRequestExportCSV"
    ]),
// add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou start
    ...mapGetters("multi-pat-list", ["getLoopFlag"]),
// add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou end
    ...mapGetters("account-edit", ["getFontSize"]),

    // add 画面印刷プレビューと印刷の実現 黄 start
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
    ...mapGetters('user', ['getFacilityCd']),
    // add #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
    ...mapGetters("exam-record/list",["getCondition"]),
    // add 画面印刷プレビューと印刷の実現 黄 end

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
    }
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
      }
    },

    getRequestExportExcel() {
      this.onCreateTemplateToExcel();
    },

    getRequestExportCSV() {
      this.exportToCSV();
    }
  },

  methods: {
    // 共通ローダー設定
    ...mapActions("loading-screen", [
      "setLoadingScreenVisible",
      "setLoadingScreenMessage"
    ]),
// add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou start

    ...mapMutations("multi-pat-list", [
      "setLoopFlag",
    ]),
// add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou end

    // 昇順/降順のclassを作成
    sortedClass(key) {
      return getSortedClass(key, this.sort);
    },
    // ソートするキーを設定する
    sortBy(key) {
      if (!this.isSortAllowed) return; // 集計中はソート不可
      updateSort(key, this.sort);
    },
    getPositionHeader() {
      let firstRowEle = null;
      const interval = setInterval(() => {
        firstRowEle = document.getElementById("first-row");
        if (firstRowEle) {
          const rowHeight = firstRowEle.offsetHeight;
          this.topPosition = rowHeight;
          clearInterval(interval);
        }
      }, 1000);
    },

    async initLayout(flag) {
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      this.checkFlag = flag;
      //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add start
      this.initFlag = 0;
      //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add end
      if (!this.breakCallApi) {
        this.breakCallApi = true;
      }
      if (this.checkFlag === 0) {
        this.breakCallApi = false;
      }
      this.listItems = [];
      this.setLoadingScreenVisible(true);
      const url = `sysDataListDetail/getByLayoutCd/${this.getSelectedDynamicLayout.patListLayoutCd}`;
      let response;
      try {
        response = await ApiHelper.get(url);
        // del FNSI6272-集計処理に時間がかかりすぎる 周 start
        //this.setLoadingScreenVisible(false);
        // del FNSI6272-集計処理に時間がかかりすぎる 周 end
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('DynamicTemplateComponent.vue', 'initLayout', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        // del FNSI6272-集計処理に時間がかかりすぎる 周 start
        //this.setLoadingScreenVisible(false);
        // del FNSI6272-集計処理に時間がかかりすぎる 周 end
        console.log(error);
      } finally {
        // mod FNSI6272-集計処理に時間がかかりすぎる 周 start
        // let list = [];
        // //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add start
        // let initList = [];
        // let tmpListItems = [];
        // //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add start
        // const data = response.data;
        // if (data && data.length) {
        //   const dataRange = this.rangeDate(
        //           this.getSelectedDynamicLayout.templateCd
        //         );
        //   data.forEach(d => {
        //     const listItems = d.items;
        //     const displayName = !d.displayName ? "" : d.displayName.trim();
        //     if (listItems && listItems.length) {
        //       listItems.forEach(item => {
        //         item.categoryCd = d.categoryCd;
        //         item.name = this.formatName(item, displayName);
        //         item.dataListDetailCd = d.dataListDetailCd;
        //         item.dispOrder = d.dispOrder;
        //         item.dateRange = dataRange
        //         item.total = "";
        //         item.unit = "";
        //       });
        //       list.push(listItems);

        //       //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add start
        //       tmpListItems = deepCopy(listItems);
        //       tmpListItems = tmpListItems.map(item => {
        //         item.categoryCd = d.categoryCd;
        //         item.name = this.formatName(item, displayName);
        //         item.dataListDetailCd = d.dataListDetailCd;
        //         item.dispOrder = d.dispOrder;
        //         item.dateRange = [];
        //         item.total = "";
        //         item.unit = "";

        //         return item;
        //       });
        //       initList.push(tmpListItems);
        //       //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add end
        //     }
        //   });
        // }


        // //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add start
        // this.listItems = _.flatten(initList);
        // //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add end

        // // ソート
        // this.listItems.sort((a, b) => {
        //   if (a.categoryCd > b.categoryCd) return -1;
        //   if (a.categoryCd < b.categoryCd) return 1;

        //   if (a.dispOrder > b.dispOrder) return -1;
        //   if (a.dispOrder < b.dispOrder) return 1;
        // });

        // // this.listItems.forEach(elem => {
        // //   });

        // this.breakCallApi = false;
        // if (this.checkFlag === 1) {
        //   //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add start
        //   this.listItems = _.flatten(deepCopy(list));
        //   // ソート
        //   this.listItems.sort((a, b) => {
        //   if (a.categoryCd > b.categoryCd) return -1;
        //   if (a.categoryCd < b.categoryCd) return 1;

        //   if (a.dispOrder > b.dispOrder) return -1;
        //   if (a.dispOrder < b.dispOrder) return 1;
        //   });
        //   this.initFlag = 1;
        //   //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add end
        //   this.loadCellDisplay();
        //   this.checkFlag = 0;
        // }

        this.breakCallApi = false;
        if (this.checkFlag === 1) {
          let list = [];
          const data = response.data;
          // add #11528 【たくしん会】データリスト並び順不正 房 start
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
          // add #11528 【たくしん会】データリスト並び順不正 房 end
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
          // ソート
          // del #11528 【たくしん会】データリスト並び順不正 房 start
          // ソート
          // this.listItems.sort((a, b) => {
          // if (a.categoryCd > b.categoryCd) return -1;
          // if (a.categoryCd < b.categoryCd) return 1;
          //
          // if (a.dispOrder > b.dispOrder) return -1;
          // if (a.dispOrder < b.dispOrder) return 1;
          // });
          // del #11528 【たくしん会】データリスト並び順不正 房 end
          this.initFlag = 1;
          //FNSI-修正 【集計(日別)_物品予定】【集計(日別)_物品実績】【集計(日別)_治療.検査状況】【集計（日別）部品】初期化性能改善 xugj add end
          this.loadCellDisplay();
          this.checkFlag = 0;

        } else {
          let initList = [];
          let tmpListItems = [];
          const data = response.data;
          // add #11528 【たくしん会】データリスト並び順不正 房 start
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
          // add #11528 【たくしん会】データリスト並び順不正 房 end
          if (data && data.length) {
            const dataRange = this.rangeDate(
                    this.getSelectedDynamicLayout.templateCd
                  );
            data.forEach(d => {
              const listItems = d.items;
              const displayName = !d.displayName ? "" : d.displayName.trim();
              if (listItems && listItems.length) {
                tmpListItems = deepCopy(listItems);
                tmpListItems = tmpListItems.map(item => {
                  item.categoryCd = d.categoryCd;
                  item.name = this.formatName(item, displayName);
                  item.dataListDetailCd = d.dataListDetailCd;
                  item.dispOrder = d.dispOrder;
                  item.dateRange = [];
                  item.total = "";
                  item.unit = "";

                  return item;
                });
                initList.push(tmpListItems);
              }
            });
          }

          this.listItems = _.flatten(initList);

          // ソート
          // del #11528 【たくしん会】データリスト並び順不正 房 start
          // this.listItems.sort((a, b) => {
          //   if (a.categoryCd > b.categoryCd) return -1;
          //   if (a.categoryCd < b.categoryCd) return 1;
          //
          //   if (a.dispOrder > b.dispOrder) return -1;
          //   if (a.dispOrder < b.dispOrder) return 1;
          // });
          // del #11528 【たくしん会】データリスト並び順不正 房 end
        }
        // add end
      }

      this.setLoadingScreenVisible(false);
      // mod FNSI6272-集計処理に時間がかかりすぎる 周 end
    },

    // add 画面印刷プレビューと印刷の実現 黄 start
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
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
          machineNos: [],
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          facilityCd: this.getFacilityCd,
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
          functionCd:"00801",
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          // date:moment(startDate).format('YYYY/MM/DD'),
          //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
          // fromDate: moment(startDate).format('YYYY/MM/DD'),
          // toDate: moment(endDate).format('YYYY/MM/DD'),
          date: moment(Date.now()).format("YYYYMMDD"),
          fromDate: moment(Date.now()).format("YYYYMMDD"),
          toDate: moment(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: moment(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
    // add 画面印刷プレビューと印刷の実現 黄 end

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
      let start = moment(startDate);
      let end = moment(endDate);
      while (start <= end) {
        const dateObj = {
          // add #6543 付 start
          from:moment(start).format("YYYYMMDD"),
          to:moment(end).format("YYYYMMDD"),
          // add #6543 付 end
          headerItem: moment(start).format("DD"),
          headerGroupItem: moment(start).format("YYYY/MM"),
          date: moment(start).format("YYYYMMDD"),
          name: moment(start)
            .format("dddd")
            .replace("曜日", ""),
          data: null
        };
        dateRange.push(dateObj);
        start = moment(start).add(1, "days");
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
      let start = moment(startDate);
      let end = moment(endDate);
      // add #6543 付 start
      let endDay = end.endOf('month').format("YYYYMMDD")
      // add #6543 付 end
      while (start <= end) {
        const dateObj = {
          // add #6543 付 start
          from: moment(start).format('YYYYMMDD'),
          to: endDay,
          // add #6543 付 end
          headerItem: moment(start).format("MM"),
          headerGroupItem: moment(start).format("YYYY"),
          date: moment(start).format("YYYYMMDD"),
          name: "月",
          data: null
        };
        dateRange.push(dateObj);
        start = moment(start).add(1, "months");
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

    async loadCellDisplay() {
      if (this.listItems.length === 0) return;
      // 集計処理中はソート不可
      this.isSortAllowed = false;
      let listObj = [];
      this.listItems.forEach(item => {
        const dateRange = item.dateRange;
        if (dateRange.length) {
          // mod #6543 付 start
          // dateRange.forEach(dateObj => {
          //   const obj = {
          //     date: dateObj.date,
          //     id: item.id,
          //     dataListDetailCd: item.dataListDetailCd,
          //     // add bug #5177 修正 chen start
          //     kubun: item.kubun ? item.kubun : 0
          //     // add bug #5177 修正 chen end
          //   };
          //   if ("type" in item) {
          //     obj["type"] = item.type;
          //   }
          //   listObj.push(obj);
          // });
          const obj = {
            id: item.id,
            dataListDetailCd: item.dataListDetailCd,
            kubun: item.kubun ? item.kubun : 0,
            date: item.dateRange[0].date,
            from: item.dateRange[0].from,
            to: item.dateRange[0].to
          }
          if ("type" in item) {
            obj["type"] = item.type
          }
          listObj.push(obj)
          // mod #6543 付 end
        }
      });
      const pageSize = 10;
      const totalPage = Math.ceil(listObj.length / pageSize);
      let index = 0;
// add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou start
      this.setLoopFlag(false);
// add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou end
      do {
// mod FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou start
        // if (this.$route.name !== "multi-pat-list") {
        //   break;
        // }
        if (this.$route.name !== "multi-pat-list" || this.getLoopFlag) {
          break;
        }
// mod FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou end
        index += 1;
        let i = (index - 1) * 10;
        const listDataParams = listObj.slice(i, i + 10).map(obj => {
          let paramDateObj = {
            dateFrom: "",
            dateTo: ""
          };
          if (
            this.getSelectedDynamicLayout &&
            this.getSelectedDynamicLayout.templateCd == DATE_TEMPLATE_CD
          ) {
            // mod #6543 付 start
            // paramDateObj.dateFrom = obj.date;
            // paramDateObj.dateTo = obj.date;
            paramDateObj.dateFrom = obj.from;
            paramDateObj.dateTo = obj.to;
            // mod #6543 付 end
          }
          if (
            this.getSelectedDynamicLayout &&
            this.getSelectedDynamicLayout.templateCd == MONTH_TEMPLATE_CD
          ) {
            // mod #6543 付 start
            // paramDateObj.dateFrom = moment(obj.date)
            //   .startOf("month")
            //   .format("YYYYMMDD");
            // paramDateObj.dateTo = moment(obj.date)
            //   .endOf("month")
            //   .format("YYYYMMDD");
            paramDateObj.dateFrom = obj.from;
            paramDateObj.dateTo = obj.to;
            // mod #6543 付 end
          }
          // mod #6543 付 start
          // let url = `sysDataListDetail/cellResult?dataListDetailCd=${obj.dataListDetailCd}&itemId=${obj.id}&dateFrom=${paramDateObj.dateFrom}&dateTo=${paramDateObj.dateTo}&kubun=${obj.kubun}`;
          let url = `sysDataListDetail/rowResult?dataListDetailCd=${obj.dataListDetailCd}&itemId=${obj.id}&dateFrom=${paramDateObj.dateFrom}&dateTo=${paramDateObj.dateTo}&kubun=${obj.kubun}`;
          // mod #6543 付 end
          if ("type" in obj) {
            url = url.concat(`&type=${obj.type}`);
          }
          return {
            ...obj,
            url: url
          };
        });
        const getData = param =>
          ApiHelper.get(param.url)
            .then(res => this.mapData(res.data, param))
            .catch(() => this.mapData({}, param));
        const listPromise = listDataParams.map(param => getData(param));
        await Promise.all(listPromise);
      } while (index < totalPage && !this.breakCallApi);
      this.$nextTick(() => {
        EventBus.$emit("setFooterMsgFlg", false);
        EventBus.$emit("allowEditTrue", false);
        // 集計処理完了後にソート許可
        this.isSortAllowed = true;
      });
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
            // mod #6543 付 start
            // this.listItems[indexItem].dateRange[indexDate].data = "";
            for (let i = 0; i < this.listItems[indexItem].dateRange.length; i++) {
              this.listItems[indexItem].dateRange[i].data = ''
            }
            // mod #6543 付 end
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
          // mod #6543 付 start
          const arr = cellDisplayPattern.split(' ')
          if (arr[arr.length - 1] !== '集計') {
            this.listItems[indexItem].unit = ' ' + unit + ' ' + arr[arr.length - 1]
          } else {
            this.listItems[indexItem].unit = unit
          }
          this.listItems[indexItem].cellDisplayPattern = ' ' + unit + ' ' + arr[arr.length - 1]
          // let count = !dataResponse.count ? 0 : dataResponse.count;
          let count = !dataResponse.count ? [] : dataResponse.count;
          let item;
          if (count.length > 0) {
            for (let i = 0; i < this.listItems[indexItem].dateRange.length; i++) {
              this.listItems[indexItem].dateRange[i].data = 0
              for (let j = 0; j < count.length; j++) {
                if (this.getSelectedDynamicLayout.templateCd == DATE_TEMPLATE_CD) {
                  item = this.listItems[indexItem].dateRange.find(item => item.date == count[j].treat_date)
                } else if (this.getSelectedDynamicLayout.templateCd == MONTH_TEMPLATE_CD) {
                  // mod 11528 【たくしん会】データリスト並び順不正 zkm start
                  // item = this.listItems[indexItem].dateRange.find(item => { return moment(item.date).format('YYYYMM') == count[j].treat_date })
                  item = this.listItems[indexItem].dateRange.find(item => { return moment(item.date).format('YYYYMM') == moment(count[j].treat_date).format('YYYYMM') })
                  // mod 11528 【たくしん会】データリスト並び順不正 zkm end
                }
                if (item) {
                  // mod 11600 【たくしん会】データリスト並び順不正 zkm start
                  // item.data = count[j].count
                  if (this.getSelectedDynamicLayout.templateCd == MONTH_TEMPLATE_CD) {
                    item.data += count[j].count
                  } else {
                    item.data = count[j].count
                  }
                  // mod 11600 【たくしん会】データリスト並び順不正 zkm end
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

          // mod #6543 付 end

          // Object.keys(dataResponse).forEach(key => {
          //   if (cellDisplayPattern.includes(`[${key}]`)) {
          //     let dataReplace;
          //     if (_.isNumber(dataResponse[key])) {
          //       dataReplace = dataResponse[key];
          //     // add #6543 付 start
          //     } else if (Array.isArray(dataResponse[key])) {
          //       dataReplace = dataResponse[key] // [{...}, {...}]
          //     }
          //     // add #6543 付 end
          //     else {
          //       dataReplace = !dataResponse[key] ? "" : dataResponse[key];
          //     }
          //     cellDisplayPattern = cellDisplayPattern.split(`[${key}]`).join(dataReplace);
          //   }
          // });
          // // mod FNSI-改修内容単位の表示不正 付 start
          // let arr = cellDisplayPattern.trim().split(" ");
          // if (unit === "" && arr[1]) {
          //   unit = arr[1];
          // }
          // let cellDisplayPat = "";
          // if (arr[2] == "[unit]") {
          //   cellDisplayPat = arr[0] + arr[1] + arr[3];
          //   this.listItems[indexItem].dateRange[indexDate].data = cellDisplayPat.trim();
          // } else if (arr[0] == "[count]" && arr[1] == "件") {
          //   cellDisplayPat = '0 ' + arr[1];
          //   this.listItems[indexItem].dateRange[indexDate].data = cellDisplayPat;
          // } else {
          //   this.listItems[indexItem].dateRange[indexDate].data = cellDisplayPattern.trim();
          // }
          // // mod FNSI-改修内容単位の表示不正 付 end
          // this.listItems[indexItem].unit = unit;
          // const total = +this.listItems[indexItem].total;
          // this.listItems[indexItem].total = this.addNum(total, count);
        }
      }
    },
    addNum(num1, num2) {
      let sq1 = 0;
      let sq2 = 0;
      let m = 0;
      try {
        sq1 = num1.toString().split(".")[1].length;
      } catch (e) {
        sq1 = 0;
      }
      try {
        sq2 = num2.toString().split(".")[1].length;
      } catch (e) {
        sq2 = 0;
      }
      m = Math.pow(10, Math.max(sq1, sq2));
      return (num1 * m + num2 * m) / m;
    },

    onCreateTemplateToExcel() {
      if (this.sortedListItems.length === 0) return;

      const columns = this.getColumns(this.sortedListItems);
      const data = this.getData(this.sortedListItems);
      this.saveExcel({
        data: data.length === 0 ? null : data,
        fileName: `データリスト_${moment().format("YYYYMMDDHHmmss")}`,
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
          field: "dataName",
          title: "データ名"
        };
        const lastCol = {
          field: "total",
          title: "合計"
        };
        columns.push(firstCol);
        if (listItems[0].dateRange.length) {
          listItems[0].dateRange.forEach(dayObj => {
            let dateFormat;
            if (this.getSelectedDynamicLayout.templateCd === DATE_TEMPLATE_CD) {
              dateFormat = moment(dayObj.date).format("YYYY/MM/DD");
            }

            if (this.getSelectedDynamicLayout.templateCd === MONTH_TEMPLATE_CD) {
              dateFormat = `${dayObj.headerGroupItem}/${dayObj.headerItem}`;
            }

            const colObj = {
              field: dayObj.date,
              title: `${dateFormat}(${dayObj.name})`
            };
            columns.push(colObj);
          });
        }
        columns.push(lastCol);
      }
      return columns;
    },

    getData(listItems) {
      let data = [];
      if (listItems && listItems.length) {
        listItems.forEach(item => {
          const obj = {};
          if (item.dateRange && item.dateRange.length) {
            item.dateRange.forEach(dayObj => {
              obj[dayObj.date] = dayObj.data;
            });
          }
          obj["dataName"] = item.name;
          obj["total"] = item.total + " " + item.unit;
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

    exportToCSV() {
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
        // Object.keys(data).forEach(key => {
        //   if (!arrayFields.includes(key)) {
        //     return;
        //   } else {
        //     tempData.push(data[key]);
        //   }
        // });
        addNewData.push(tempData);
      });
      // addNewData = addNewData.map(i => i.reverse());
      // addNewData = addNewData.map(ii => {
      //   if (ii.length > 0) {
      //     const first = ii[0];
      //     ii.shift();
      //     ii.push(first);
      //   }
      //   return ii;
      // });

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
      link.download = `データリスト_${moment().format("YYYYMMDDHHmmss")}.csv`;
      link.click();
    }
  },

  async created() {
    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;
// add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou start
    this.setLoopFlag(true);
    // add 性能改善メモリ不足 shan start
    EventBus.$off("onInitLayout", this.initLayout);
    EventBus.$off("refresh", this.initLayout);
    EventBus.$off("requestReportParams", this.requestrReportParams);
    // add 性能改善メモリ不足 shan end
// add FNSI-No.530 処理が遅い。非同期処理となっているが、別機能遷移でサーバー側の処理をとめる dou end
    EventBus.$on("onInitLayout", this.initLayout);
    EventBus.$on("refresh", this.initLayout);
    // add 画面印刷プレビューと印刷の実現 黄 start
    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);
    // add 画面印刷プレビューと印刷の実現 黄 end
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    EventBus.$off("onInitLayout", this.initLayout);
    EventBus.$off("refresh", this.initLayout);
    EventBus.$off("requestReportParams", this.requestrReportParams);

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<style>
@media print {
  /** ヘッダレイアウト崩れ回避 */
  body:has(#multi-pat-list-dynamic) #bbs-search-area {
    width: 60%;
  }
  body:has(#multi-pat-list-dynamic) .file-button {
    margin-left: 10%;
  }
  /** 右端スクロール時はみ出し回避 */
  body:has(#multi-pat-list-dynamic) #main-id {
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
      height: 32.8px;
      min-width: 80px;
      box-shadow: 0 0 0 0.5px var(--ntss-list-border-color);
      z-index: 9;
    }
    // add スタイル  shan start
    .th-sticky-day {
      top: 41px;
    }
    // add スタイル  shan end
    .frezee-column-id {
      box-shadow: 0 0 0 0.5px var(--ntss-list-border-color);
      left: 0;
      z-index: 9;
      position: sticky;
      min-width: 70px;
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
          // white-space: nowrap;
          color: var(--ntss-base-color);

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
