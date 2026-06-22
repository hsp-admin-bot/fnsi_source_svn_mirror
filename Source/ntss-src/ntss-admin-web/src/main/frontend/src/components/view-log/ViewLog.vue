<template>
  <div ref="refMain" class="main-content-area log-list">
    <!-- 体重計測定記録一覧のグリッド -->
    <div :style="{'height': 'inherit'}">
        <!-- update 様式修正  馬宇婷  start-->
        <!-- <v-ons-row v-bind:style="heightRow" id="log-table">-->
      <v-ons-row :style="{ height: heightUp+'%' }" class="up-div" id="log-table">
        <!-- update 様式修正  馬宇婷  end-->
        <!-- update FNSI-mongoDBに挿入、検索できることの対応 start -->
        <div class='scroll-area' @scroll="scrollHandler" ref="ntssList" >
         <!--  update FNSI-mongoDBに挿入、検索できることの対応 end -->
          <table
            v-for="(tab, idxTab) in displayTabs"
            :key="`log_reference_${idxTab}`"
            class="table data-table"
            :style="logTableStyle(tab)"
            :ref="`download_${tab.cd}`"
          >
            <thead>
              <tr>
                <th
                  :colspan="isMasterUser ? 2 : 1"
                  class="fit-column ntss-list-header-th-sticky"
                >番号</th>
                <th
                  v-for="item in columns"
                  :key="`col_${item.cd}`"
                  :class="colTheadClass(item)"
                  :style="{ width: colHeaderWidth(item) }"
                >
                <div class="thead-container" @click="theadClicked(item)">
                  <span :class="colTheadSpanClass(item)">
                    {{ item.name }}
                  </span>
                  <img
                    :src="filterIcon(item)"
                    alt="filter"
                    class="filter-icon"
                    @click.stop="showFilter($event, item)"
                  />
                </div>
                </th>
              </tr>
            </thead>
              <draggable
                :v-model="filteredSortLog"
                tag="tbody"
                animation="200"
                delay="10"
                :disabled="!isMasterUser"
                :force-fallback="true"
                :key="`draggable_key_${draggableKey}_${idxTab}`"
              >
                <tr
                  v-for="(item, idxRow) in filteredSortLog"
                  :key="`row_${idxRow}`"
                  :class="{
                    'ntss-list-body-tr': true,
                    active: item === tab.rowActive
                  }"
                  @click="onRowClick($event, item)"
                >
                  <td class="ntss-list-body-td fit-column">
                    {{ idxRow + 1 }}
                  </td>
                  <td
                    :class="{
                      'visible-style': !isMasterUser,
                      'ntss-list-body-td fit-column': true,
                      'color-column': true
                    }"
                    v-bind:style="statusColor(item.logType)"
                  >
                  </td>
                  <td
                    scope="row"
                    v-for="(field, inxCol) in columns"
                    :key="`row_${idxRow}_col_${inxCol}`"
                    :class="colTbodyClass(item, field)"
                  > {{ getFieldText(item, field) }} </td>
                </tr>
              </draggable>
          </table>
        </div>
      </v-ons-row>
      <!-- update 様式修正  馬宇婷  start-->
      <div class="y-handle" v-if="viewDetail" @mousedown="mouseDown"></div>
     <!-- <v-ons-row class="master-maintenance-page" v-if="viewDetail" v-bind:style="{height: '20%'}">-->
      <v-ons-row class="down-div" v-if="viewDetail" :style="{ height: heightDown+'%' }">
        <!-- update 様式修正  馬宇婷  end-->
        <!-- update テキストフィールドのスタイルを変更します  馬宇婷  start-->
      <!--  <span class="content-node">{{ contentNode }}</span>-->
      <!--  <div class="content-node" v-html="contentNode" ></div>-->
        <!-- #10977 インジェクション対応 linjunfeng start -->
        <!-- <div v-html="contentNode"></div> -->
        <div>
          <div v-for="(item,index) in contentNode.split('<br/>')" :key="index">
            {{item}}
          </div>
        </div>
        <!-- #10977 インジェクション対応 linjunfeng end -->
        <!-- update  テキストフィールドのスタイルを変更します  馬宇婷  start-->
      </v-ons-row>
    </div>
    <v-ons-popover
      cancelable
      v-model:visible="filterVisible"
      :target="filterTarget"
      :direction="filterDirection"
      :cover-target="false"
      :class="[fontSizeSet, 'popover-area']"
    >
      <div class="pop-area">
        <div class="pop-main-area">
          <!-- フリーワード -->
          <v-ons-row class="condition-row">
            <v-ons-col vertical-align="center">
              <label>フリーワード</label>
            </v-ons-col>
            <v-ons-col vertical-align="center">
              <v-ons-input v-model="tempFreeword" class="input-area ntss-custom-input filter-freeword-input" type="text"></v-ons-input>
            </v-ons-col>
          </v-ons-row>
        </div>
      </div>
      <div class="condition-row condition-button-area">
        <div class="ok-button">
          <v-ons-button class="ok btn3-normal" @click="filterOK">OK</v-ons-button>
        </div>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
import {getErrorMessage} from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
import _ from "@/compat/collections/lodash";
import dayjs from "@/compat/date/dayjs";
import { mapGetters, mapActions } from "@/compat/vue/vuex";
import { VueDraggable } from "@/compat/drag/VueDraggable";
import {
  //update FNSI-mongoDBに挿入、検索できることの対応 start
  sendRequestGetFilterLog
  // getSysAllFunction
  // update FNSI-mongoDBに挿入、検索できることの対応 end
} from "@/apis/log-reference";
import {
  createColumns,
  createDisplayColumns
} from "./Functions.js";
import { TabModel } from "./TabModel";
import PopoverMixin from "@/components/PopoverMixin";
import PrintMixin from "@/components/PrintMixin";
import { EventBus } from "@/compat/vue/event-bus.js";
import { ApiHelper } from "@/apis/AxiosHelper.js";
//add FNSI-mongoDBに挿入、検索できることの対応 start
import { PAGE_SIZE } from "@/constants/PageableConstant.js";
import encoding from "@/compat/encoding/encoding-japanese";
//add FNSI-mongoDBに挿入、検索できることの対応 end
const uriUser = "/master_maintenance/mst_user";
//add FNSI-mongoDBに挿入、検索できることの対応 start
const appPropertiesLogging = "1";
const eventPropertiesLogging = "0";
//add FNSI-mongoDBに挿入、検索できることの対応 end
// add #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat'
import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages'
// add #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
import { LOG_REFERENCE_GENERAL_PAT_ID, LOG_REFERENCE_PAT_ID, LOG_REFERENCE_USER_ID } from "@/components/view-log/Definitions";
import filterImg from "../../assets/filter.png";
import filterDarkImg from "../../assets/filter_dark.png";
import { getViewportHeight, getScopedUserAgent, triggerScopedDownload } from "@/functions/common/LayoutMeasureHelper";

export default {
  mixins: [PopoverMixin, PrintMixin],
  name: "ViewLogComponent",
  components: {
    draggable: VueDraggable
  },
  data() {
    return {
      /*add 変数を増やす 馬宇婷 start*/
      lastY: "",
      heightUp: 100,
      heightDown: 20,
      /*add 変数を増やす 馬宇婷 end*/
      draggableKey: 0,
      filterVisible: false,
      filterTarget: null,
      filterDirection: "down",
      click: undefined,
      tempFreeword: "",
      displayTabs: [],
      openingTab: null,
      actionRemoveFlag: false,
      maxWidth: 1000,
      contentNode: "",
      viewDetail: false,
      isItemSelectorVisible: false,
      itemSelectorData: null,
      displayItems: [],
      columns: [],
      viewLogAreaHeight: 500,
      colWidth: 180,
      columnWidths: {},
      userList: [],
      isResizing: false,
      timeOut: null,
      filteringColName: [],
      //add FNSI-mongoDBに挿入、検索できることの対応 start
      limitTo: 0,
      filterTimes: 0,
      scrollFlg: true,
      //add FNSI-mongoDBに挿入、検索できることの対応 end
      image_src_filter: filterImg,           // フィルタ適用あり
      image_src_filter_dark: filterDarkImg, // フィルタ適用なし
      lastScrollTop: 0,
      // フィルタ実行時に行の追加読込をスキップするフラグ
      skipScrollHandler: false,
      updatedTimerId: null,
      scrollQuerySelector: ".scroll-area",
      addClassTargetQuerySelector: ["table.data-table"]
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowWidth: "getWindowWidth",
      windowHeight: "getWindowHeight",
    }),
    ...mapGetters("view-log", {
      searchRequest: "getSearchRequest"
    }),
    ...mapGetters("view-log", [
      "getCondition",
      "getDefaultCondition",
      "getTabData",
      "getSelectedItemList",
      "getSelectedItem"
    ]),
    ...mapGetters("account-edit", {
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),

    isMasterUser() {
      return this.getStateUserAccountInfo.userType === 1 ? true : false;
    },

    filteredSortLog() {
      return this.filterLog(this.sortLog);
    },

    sortLog() {
      let list = [];
      if (this.openingTab.dataSource && this.openingTab.dataSource.length > 0) {
        list = this.openingTab.dataSource.slice();
        //del FNSI-mongoDBに挿入、検索できることの対応 start
        // if (this.openingTab.sort.key) {
        //   const thatSort = this.openingTab.sort;
        //   list.sort((a, b) => {
        //     a = a[thatSort.key];
        //     b = b[thatSort.key];
        //     const sortItem1 = a === b ? 0 : a > b ? 1 : -1;
        //     const sortItem2 = thatSort.isAsc ? 1 : -1;
        //     return sortItem1 * sortItem2;
        //   });
        // }
          //del FNSI-mongoDBに挿入、検索できることの対応 end
      }
      return list;
    },

    heightRow() {
      return {
        height: this.viewDetail ? "80%" : "100%",
        "overflow-y": "hidden",
      };
    },

    tabWidth() {
      return {
        'max-width': `${this.maxWidth}px`
      };
    },
  },

  watch: {
    windowWidth() {
      this.calculateMaxWidth();
    },

    windowHeight() {
      this.calculateMaxHeight();
    },

    async searchRequest() {
      await this.getUser();
      this.ensureDefaultCondition();
      this.createTab(this.getCondition);
    },

    displayTabs() {
      this.calculateMaxWidth();
    },
  },

  mounted() {
    EventBus.$emit('getDisplayColumns', {
      displayItems: this.displayItems,
      columns: this.columns
    });
    // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong start
    if (this.getSelectedItem) {
      this.$nextTick(() => {
        this.columns = this.getSelectedItemList;
        this.displayItems = this.getSelectedItemList;
      });
    }
    // add/ #9603 ログ参照画面の表示項目の内容保持されていない。 tianqidong end
    this.clearManagedRuntimeHandlers();
    const tables = this.getDataTables();
    for (let i=0; i<tables.length;i++){
      this.resizableGrid(tables[i]);
    }
  },

  updated() {
    this.$nextTick(() => {
      const ownerWindow = this.getViewLogOwnerDocument()?.defaultView || window;
      if (this.updatedTimerId) {
        ownerWindow.clearTimeout?.(this.updatedTimerId);
      }
      this.updatedTimerId = this.setManagedTimeout(() => {
        this.updatedTimerId = null;
        this.calculateMaxHeight();
        // mod FNSI-解決の糸口がつかめない 関 start
        // this.calculateColumnWidth();
        // mod FNSI-解決の糸口がつかめない 関 end
      }, 1000);
    });
  },

  methods: {
    clearManagedRuntimeHandlers() {
      if (Array.isArray(this._managedEventDisposers)) {
        while (this._managedEventDisposers.length) {
          try {
            this._managedEventDisposers.pop()?.();
          } catch (_error) {
            // noop
          }
        }
      }
      if (Array.isArray(this._managedTimeouts)) {
        const ownerWindow = this.getViewLogOwnerDocument()?.defaultView || window;
        this._managedTimeouts.forEach((timerId) => ownerWindow.clearTimeout?.(timerId));
        this._managedTimeouts = [];
      }
      this.updatedTimerId = null;
    },
    addManagedEventListener(target, eventName, handler, options) {
      if (!target?.addEventListener || typeof handler !== "function") {
        return handler;
      }
      this._managedEventDisposers = this._managedEventDisposers || [];
      target.addEventListener(eventName, handler, options);
      this._managedEventDisposers.push(() => target.removeEventListener?.(eventName, handler, options));
      return handler;
    },
    setManagedTimeout(handler, delay = 0) {
      const ownerWindow = this.getViewLogOwnerDocument()?.defaultView || window;
      this._managedTimeouts = this._managedTimeouts || [];
      const timerId = ownerWindow.setTimeout?.(() => {
        this._managedTimeouts = (this._managedTimeouts || []).filter((id) => id !== timerId);
        handler?.();
      }, delay);
      if (timerId !== undefined && timerId !== null) {
        this._managedTimeouts.push(timerId);
      }
      return timerId;
    },
    getViewLogRootElement() {
      return this.$refs.refMain || this.$el || null;
    },
    getViewLogOwnerDocument() {
      return this.getViewLogRootElement()?.ownerDocument || document;
    },
    getDataTables() {
      return Array.from(this.getViewLogRootElement()?.getElementsByClassName?.("data-table") || []);
    },
    getLogTableElement() {
      return this.getViewLogRootElement()?.querySelector?.("#log-table") || null;
    },
    getSortedHeaderElement(className) {
      return this.getViewLogRootElement()?.getElementsByClassName?.(className)?.[0] || null;
    },
    ...mapActions("multi-modal", ["showItemSettingModal"]),
    ...mapActions("view-log", [
      "setRole",
      "setTabData",
      //add FNSI-mongoDBに挿入、検索できることの対応 start
      "setDefaultCondition",
      //add FNSI-mongoDBに挿入、検索できることの対応 end
      "syncTabLocalToStore",
    ]),
    ...mapActions("mst-user", ["getUserDataList"]),
    ...mapGetters("app", ["getQueryParameters"]),
    ...mapActions("app", ["setQueryParameters"]),
    //add FNSI-7366 追加読み込みの実施中にローダーが発生しない 劉全航 start
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
    }),
    
    /**
     * フィルタアイコン設定
     *  - フィルタ適用なし: 濃いロート
     *  - フィルタ適用あり: 白いロート
     * @param {*} item 
     */
    filterIcon(item) {
      const filtered = this.filteringColName.find(n => n.name.trim() == item.name.trim());
      if (filtered) {
        return this.image_src_filter;
      }
      return this.image_src_filter_dark;
    },
    
    //add FNSI-7366 追加読み込みの実施中にローダーが発生しない 劉全航 end
    /*add マウスの盗聴方法を追加します 馬宇婷 start*/
    widthChange(movement) {
      let height = getViewportHeight();
      this.heightUp -= (movement / height) * 100;

      if (this.heightUp < 20) {
        this.heightUp = 20;
      }
      if (this.heightUp > 80) {
        this.heightUp = 80;
      }

      this.heightDown += (movement / height) * 100;
      if (this.heightDown < 20) {
        this.heightDown = 20;
      }
      if (this.heightDown > 80) {
        this.heightDown = 80;
      }
    },
    mouseDown(event) {
      this.getViewLogOwnerDocument().removeEventListener("mousemove", this.mouseMove);
      this.getViewLogOwnerDocument().addEventListener("mousemove", this.mouseMove);
      this.lastY = event.clientY;
    },
    mouseMove(event) {
      this.widthChange(this.lastY - event.clientY);
      this.lastY = event.clientY;
    },
    mouseUp() {
      this.lastY = "";
      this.getViewLogOwnerDocument().removeEventListener("mousemove", this.mouseMove);
    },
    /*add マウスの盗聴方法を追加します 馬宇婷 end*/

    onGetTabData() {
      let tabs = this.getTabData;
      if (tabs && tabs.length > 0) {
        this.displayTabs = tabs;
        this.switchTab(this.displayTabs[0]);
        this.previousTab = this.displayTabs[0];
      }
    },
    ensureDefaultCondition() {
      if (!this.getDefaultCondition) {
        this.setDefaultCondition(Object.assign({}, this.defaultCondition()));
      }
      return this.getDefaultCondition || this.defaultCondition();
    },
    //add FNSI-mongoDBに挿入、検索できることの対応 start
    async scrollHandler() {
      const e = this.$refs.ntssList;
      
      // 縦スクロール変化なし（横スクロールだけ）の場合はスキップ
      const scrollDelta = e.scrollTop - this.lastScrollTop;
      this.lastScrollTop = e.scrollTop; // 縦スクロール位置を退避
      if (scrollDelta <= 0) return;
      
      // フィルタ直後はスキップ
      if (this.skipScrollHandler) {
        this.skipScrollHandler = false; // 一度だけスキップ
        return;
      }
      
      const isScrolledBottom = Math.abs(e.scrollTop + e.clientHeight - e.scrollHeight) < 4;
      if (isScrolledBottom) {
        if (this.scrollFlg == true) {
          this.scrollFlg = false;
          this.limitTo = this.openingTab.dataSource.length;
          //add #6547 ログ表示不正の修正。 start
          this.filterTimes = this.filterTimes+1;
          //add #6547 ログ表示不正の修正。 end
          this.getCondition.pageSize = PAGE_SIZE;
          this.getCondition.limitTo = this.limitTo;
          this.getCondition.filterTimes = this.filterTimes;
          this.getCondition.sortKey = this.openingTab.sort.key;
          this.getCondition.sortOrder = this.openingTab.sort.isAsc;
          this.getLogReference(this.getCondition, true);
        }
      }
    },
    //add FNSI-mongoDBに挿入、検索できることの対応 end

    filterLog(logs) {
      // mod #10016 列ヘッダフィルタはAPIで再取得する（追加読込分だけクライアント絞込みしない）
      this.skipScrollHandler = true;
      return logs || [];
    },

    // ソートするキーを設定する
    sortBy(key) {
      // 利用者、患者名、ログ内容、対応内容はソート不可とする
      const nonSortableKeys = ["user", "patName", "logMessage", "supportMessage"];
      if (nonSortableKeys.includes(key)) {
        return;
      }
      
      if (key === this.openingTab.sort.key && !this.openingTab.sort.isAsc) {
        // ソートなし デフォルトソート：日時降順
        this.openingTab.sort.key = "";
        this.openingTab.sort.isAsc = null;
      } else {
        this.openingTab.sort.isAsc = this.openingTab.sort.key === key ? !this.openingTab.sort.isAsc : true;
        this.openingTab.sort.key = key;
      }
      //add FNSI-mongoDBに挿入、検索できることの対応 start
      this.limitTo = 0;
      this.filterTimes = 0;
      this.getCondition.limitTo = this.limitTo;
      this.getCondition.filterTimes = this.filterTimes;
      this.getCondition.pageSize = PAGE_SIZE;
      this.getCondition.sortKey = this.openingTab.sort.key;
      this.getCondition.sortOrder = this.openingTab.sort.isAsc;
    // add FNSI-NO7326検索条件に施設IDが漏れ、追加する。ljx start
      // this.getCondition.facilityCd = [{facilityCd: this.getStateUserAccountInfo.facilityCd}];
    // add FNSI-NO7326検索条件に施設IDが漏れ、追加する。ljx end
      this.getLogReference(this.getCondition, false, { clearColumnFilter: false });
      //add FNSI-mongoDBに挿入、検索できることの対応 end
    },

    logTableStyle(tab) {
      return {
        // mod FNSI-解決の糸口がつかめない 関 start
        // 'width': `100%`,
        'width': "max-content",
        // mod FNSI-解決の糸口がつかめない 関 end
        'min-width': "100%",
        'display': tab.cd === this.openingTab.cd ? 'block' : 'none'
      }
    },

    statusColor(status) {
      let bg = "white";
      switch (status.toUpperCase()) {
        case "INFO":
          bg = "white";
          break;
        case "WARNING":
          bg = "orange";
          break;
        case "ERROR":
          bg = "red";
          break;
      }
      return {
        background: bg
      };
    },

    onRowClick(event, rowClicked) {
      let acceptManipulationCol = this.isMasterUser ? 2: 1;
      if (event.target.cellIndex >= acceptManipulationCol) {
        /* add クリック機能の追加  馬宇婷 start*/
        let str = "";
        for (let i = 0; i < this.columns.length; i++) {
          let j = rowClicked[this.columns[i].key];
          let k = undefined;
          if (j == (k)) {
            j = " ";
          } else {
            // mod 障害票一覧_ログ参照 修正 chen start
            j = this.getFieldText(rowClicked, this.columns[i]);
            // j = rowClicked[this.columns[i].key];
            // mod 障害票一覧_ログ参照 修正 chen end
          }
          str = str + this.columns[i].name + "：" + j + "<br/>";


        }
        this.contentNode = str;
       /* this.contentNode = event.target.innerText;*/
        /* add クリック機能の追加  馬宇婷 end*/
        this.openingTab.rowSelected = rowClicked;
        this.openingTab.cellSelected = this.columns[event.target.cellIndex - 2].key
      }
    },

    colTheadClass(field) {
      let hideColumn = false;
      if (!this.displayItems.find(i => i.cd === field.cd)) {
        //(cd 2)はログ種別
        hideColumn = true;
      }
      return {
        'ntss-list-header-th-sticky': true,
		//add 解決の糸口がつかめない 周炜博 start
        'resize-col': true,
		//add 解決の糸口がつかめない 周炜博 end
        'visible-style': hideColumn,
      };
    },
    
    colTheadSpanClass(field) {
      return {
        'clickable-header-label': true,
        'sorted-desc':
          this.openingTab.sort.key === this.columns.find(f => f.cd === field.cd).key &&
          this.openingTab.sort.isAsc === true,
        'sorted-asc':
          this.openingTab.sort.key === this.columns.find(f => f.cd === field.cd).key &&
          this.openingTab.sort.isAsc === false,
        'non-sort': this.openingTab.sort.key !== this.columns.find(f => f.cd === field.cd).key,
      };
    },

    colTbodyClass(item, field) {
      let hideColumn = false;
      if (!this.displayItems.find(i => i.cd === field.cd)) {
        //(cd 2)はログ種別
        hideColumn = true;
      }
      return {
        active: item === this.openingTab.rowSelected && field.key === this.openingTab.cellSelected,
        'visible-style': hideColumn,
        'ntss-list-body-td': true,
        'hosp-pat-id-body': field.key === LOG_REFERENCE_GENERAL_PAT_ID.key || field.key === LOG_REFERENCE_PAT_ID.key || field.key === LOG_REFERENCE_USER_ID.key
      };
    },

    changeViewDetail() {
      this.syncColumnWidthsFromDom();
      this.viewDetail = !this.viewDetail;
      /* update 様式修正  馬宇婷  start */
      this.heightUp = this.viewDetail ? 80 : 100;
     /* update 様式修正  馬宇婷  end */
      this.$nextTick(() => this.applyStoredColumnWidths());
    },

    getModuleName(serviceName) {
        //update FNSI-mongoDBに挿入、検索できることの対応 start
        if (serviceName != null && serviceName != "") {
            const moduleName = serviceName.split(',')[0];
            if (!moduleName) return "";
            return moduleName.includes("ntss") ? moduleName : "";
        }
        return "";
        //update FNSI-mongoDBに挿入、検索できることの対応 end
    },

    getFunctionName(sysFunction, logData) {
        //update FNSI-mongoDBに挿入、検索できることの対応 start
        if(sysFunction != null) {
            const functionName = sysFunction.find(item => item.functionCd == logData.functionCd);
            return functionName ? functionName.functionName : "";
        }
        return "";
        //update FNSI-mongoDBに挿入、検索できることの対応 end
    },
      //update FNSI-mongoDBに挿入、検索できることの対応 start
    async getLogReference(condition, scrollSelect, options = {}) {
      const clearColumnFilter = options.clearColumnFilter === true;
      // #10016 ログ参照画面でフィルタ検索で追加読みで検索条件が破棄されている fang start
      if (scrollSelect === false && clearColumnFilter && this.openingTab) {
        this.cancelFilter();
      }
      // #10016 ログ参照画面でフィルタ検索で追加読みで検索条件が破棄されている fang end
      let displayTabs = this.displayTabs;
      let sendCondition = this.formatSendCondition(condition);
      // 追加読込前も列幅を退避（読込後の tbody 再描画で表头幅がリセットされるのを防ぐ）
      this.syncColumnWidthsFromDom();

      const params = {
        folderName: this.getStateUserAccountInfo.facilityCd,
        condition: JSON.parse(JSON.stringify(sendCondition))
      }
      // let that = this;
      //add FNSI-7366 追加読み込みの実施中にローダーが発生しない 劉全航 start
      this.setLoadingScreenMessage("処理中...");
      this.setLoadingScreenVisible(true);
      //add FNSI-7366 追加読み込みの実施中にローダーが発生しない 劉全航 end
      await sendRequestGetFilterLog(params, scrollSelect).then(async response => {
        if (response.status === 200) {
          if (response.data && response.data.length > 0) {
              this.scrollFlg = true;
              if (scrollSelect == false) {
                  const e = this.$refs.ntssList;
                  e.scrollTop = 0;
              }

            //   let sysFunction = [];
            // if (response.data[0].facilityCd != "") {
            //     await getSysAllFunction(response.data[0].facilityCd).then(responseSysFunc => {
            //         if (responseSysFunc.status === 200) {
            //
            //             sysFunction = responseSysFunc;
            //         }
            //     }).catch(err => {
            //         throw new Error(err);
            //     });
            // }
            // response.data = response.data.map(obj=> {
            //     return {
            //       ...obj,
            //       moduleName: this.getModuleName(obj.serviceName),
            //       userName: that.getUserName(obj.userId),
            //       functionName: this.getFunctionName(sysFunction.data, obj),
            //       user: this.isMasterUser ? obj.userId : that.getUserName(obj.userId)
            //     }
            //   }
            // );
              let savedTabData;
              if (scrollSelect == false) {
                  const e = this.$refs.ntssList;
                  e.scrollTop = 0;
                  // mod bug #4273 修正 chen start
                  let sortKey = condition ? condition.sortKey : '';
                  let isAsc = condition ? condition.sortOrder : null;
                  savedTabData = new TabModel(
                      Math.round(Math.random() * 1000000),
                      this.titleTab(condition),
                      { key: sortKey, isAsc: isAsc },
                      this.cloneOpeningTabFilter(),
                      response.data
                  );
                  // mod bug #4273 修正 chen end
              } else {
                // 追加読込時
                let list = this.openingTab.dataSource.slice();
                            response.data.forEach(e => {
                                list.push(e);
                            });
                 savedTabData = new TabModel(
                    Math.round(Math.random() * 1000000),
                    this.titleTab(condition),
                    { key: this.openingTab.sort.key, isAsc: this.openingTab.sort.isAsc },
                    this.openingTab?.filter ?? { freeWord: "", column: "" },
                    list
                );
              }

            if (this.openingTab) {
              this.openingTab.name = savedTabData.name;
              /* del ページリストのソートが正常に表示されない 周炜博 start
              this.openingTab.sort = savedTabData.sort;
                 del ページリストのソートが正常に表示されない 周炜博 end  */
              this.openingTab.dataSource = savedTabData.dataSource;
              this.openingTab.rowSelected = null;
              this.openingTab.cellSelected = null;
              this.openingTab.rowActive = null;
              this.switchTab(this.openingTab);
            } else {
              displayTabs.push(savedTabData);
              this.switchTab(savedTabData);
            }
            // del ログ件数が多すぎるとLocalToStoreエラー発生対応 韓 start
            // this.syncTabLocalToStore(displayTabs);
            // del ログ件数が多すぎるとLocalToStoreエラー発生対応 韓 end
          } else {
              if (scrollSelect == false) {
                if (this.openingTab) {
                  this.openingTab.dataSource = [];
                }
                this.$ons.notification.alert({
                  // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
                  // title: "",
                  // message: "データがありません",
                  title: DIALOG_MESSAGES['00100020'].title,
                  message: messageFormat(DIALOG_MESSAGES['00100020'].message),
                  // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
                });
                this.contentNode = ''
              }
          }
        } else {
            if (scrollSelect == false) {
              if (this.openingTab) {
                this.openingTab.dataSource = [];
              }
                this.$ons.notification.alert({
                  // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
                    // title: "",
                    // message: "データがありません",
                    title: DIALOG_MESSAGES['00100020'].title,
                    message: messageFormat(DIALOG_MESSAGES['00100020'].message),
                    // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
                });
            }
        }
        //add FNSI-7366 追加読み込みの実施中にローダーが発生しない 劉全航 start
        this.$nextTick(() => this.applyStoredColumnWidths());
        this.setLoadingScreenVisible(false);
        //add FNSI-7366 追加読み込みの実施中にローダーが発生しない 劉全航 end
      })
      .catch((err) => {
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
        getErrorMessage('ViewLog.vue','getLogReference',err);
        //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        //add FNSI-7366 追加読み込みの実施中にローダーが発生しない 劉全航 start
        this.$nextTick(() => this.applyStoredColumnWidths());
        this.setLoadingScreenVisible(false);
        //add FNSI-7366 追加読み込みの実施中にローダーが発生しない 劉全航 end
        if (scrollSelect == false) {
          console.log("Log reference error: ", err);
          if (this.openingTab) {
            this.openingTab.dataSource = [];
          }
          this.$ons.notification.alert({
            // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 start
            // title: "",
            // message: "データがありません",
            title: DIALOG_MESSAGES['00100020'].title,
            message: messageFormat(DIALOG_MESSAGES['00100020'].message),
            // add #6107 2023/03/08 メッセージボックス全調整 林峻峰 end
          });
        }
      });
    },
    async getLogReferenceAll(condition) {
      let sendCondition = this.formatSendCondition(condition);
      sendCondition.pageSize = null;
      sendCondition.limitTo = 0;
      sendCondition.filterTimes = 0;
      const params = {
        folderName: this.getStateUserAccountInfo.facilityCd,
        condition: JSON.parse(JSON.stringify(sendCondition))
      }
      let savedTabData = null;
      await sendRequestGetFilterLog(params, true).then(async response => {
        if (response.status === 200) {
          if (response.data && response.data.length > 0) {
            this.scrollFlg = true;
             savedTabData = new TabModel(
              Math.round(Math.random() * 1000000),
              this.titleTab(condition),
              { key: 'date', isAsc: false },
              { freeWord: "", column: "" },
              response.data
            );
          }
        }
      });
      return savedTabData;
    },
      //update FNSI-mongoDBに挿入、検索できることの対応 end

    buildDisplayItemsForRequest() {
      const filterColumns = this.openingTab?.filter?.columns || [];
      return this.displayItems.map(item => {
        const matched = filterColumns.find(
          column => String(column.cd) === String(item.cd)
        );
        const freeWord =
          matched?.freeWord != null && String(matched.freeWord).trim() !== ""
            ? String(matched.freeWord)
            : "";
        return { ...item, freeWord };
      });
    },

    formatSendCondition(condition) {
      const startTime = condition.noticeStartTime ? `${condition.noticeStartTime}:00` : dayjs().startOf('day').format("HH:mm:ss");
      const endTime = condition.noticeEndTime ? `${condition.noticeEndTime}:00` : dayjs().format("HH:mm:ss");
      const startDateTime = condition.noticeStartDate
        ? `${dayjs(condition.noticeStartDate).format("YYYY/MM/DD")} ${startTime}`
        : null
      const endDateTime = condition.noticeEndDate
        ? `${dayjs(condition.noticeEndDate).format("YYYY/MM/DD")} ${endTime}`
        : null
      return {
        strFromDate: startDateTime,
        strToDate: endDateTime,
        // mod FNSI-NO578日機装ユーザーでログ検索が実行されない。(施設ユーザでは検索可能) 張岩 start
        // facilityCd: condition.facilityCd.map(facility => facility.facilityCd),
        // facilityCd: condition.facilityCd.filter(facility =>{if(facility.facilityCd!=undefined){return facility.facilityCd}}).length>0?condition.facilityCd.map(facility => facility.facilityCd):condition.facilityCd,
        // mod FNSI-NO578日機装ユーザーでログ検索が実行されない。(施設ユーザでは検索可能) 張岩 end
        // mod #7183 【デグレ】ログ画面でファイルのダウンロードができない 林峻峰 start
        facilityCd: condition.facilityCd.filter(facility =>{if(facility!=undefined){return facility}}).length>0 ? condition.facilityCd : [this.getStateUserAccountInfo.facilityCd],
        // mod #7183 【デグレ】ログ画面でファイルのダウンロードができない 林峻峰 end
       logType: condition.logType && condition.logType.length > 0
          ? condition.logType.toString()
          : null,
        userId: this.getListCd(condition.userId),
        serviceName: this.getListCd(condition.serviceName),
        patId: this.getListCd(condition.patId),
        classification: condition.logClass && condition.logClass.length > 0
          ? condition.logClass.toString()
          : null,
        keySearch: condition.keySearch ? condition.keySearch : null,
        typeSearch: condition.typeSearch,
          //add FNSI-mongoDBに挿入、検索できることの対応 start
          limitTo: condition.limitTo,
          filterTimes: condition.filterTimes,
          // mod #7183 【デグレ】ログ画面でファイルのダウンロードができない 林峻峰 start
          // sortKey: condition.sortKey === "" ? "date" : condition.sortKey,
          // sortOrder: condition.sortKey === "" ? false : condition.sortOrder,
          sortKey: (condition.sortKey === "" || condition.sortKey === undefined) ? "date" : condition.sortKey,
          sortOrder: (condition.sortKey === "" || condition.sortKey === undefined) ? false : condition.sortOrder,
          // mod #7183 【デグレ】ログ画面でファイルのダウンロードができない 林峻峰 end
          pageSize: condition.pageSize,
          //add FNSI-mongoDBに挿入、検索できることの対応 end
          // add #6775 ログの抽出が正しく行われない 鄭爽 start
          displayItems: this.buildDisplayItemsForRequest(),
          // add #6775 ログの抽出が正しく行われない 鄭爽 end
        moduleName: condition.moduleName && condition.moduleName.length > 0
          ? condition.moduleName[0].toString()
          : null
      };
    },

    /**
     * @description 新しいデータが利用可能になったらタブを作成
     * @param { Object } 検索条件
     */
    createTab(condition) {
      if (condition) {
        //update FNSI-mongoDBに挿入、検索できることの対応 start
        this.getCondition.limitTo = 0;
        this.getCondition.filterTimes = 0;
        this.filterTimes = 0;
        this.getCondition.pageSize = PAGE_SIZE;
        // add FNSI-NO7326検索条件に施設IDが漏れ、追加する。ljx start
        // this.getCondition.facilityCd = [{facilityCd: this.getStateUserAccountInfo.facilityCd}];
        // add FNSI-NO7326検索条件に施設IDが漏れ、追加する。ljx end
        // this.openingTab.sort.key = "date";
        // this.openingTab.sort.isAsc = false;
        if (this.openingTab && this.openingTab.sort) {
          condition.sortKey = this.openingTab.sort.key;
          condition.sortOrder = this.openingTab.sort.isAsc;
        } else {
          condition.sortKey = "";
          condition.sortOrder = null;
        }
        this.getLogReference(condition, false, { clearColumnFilter: true });
        //update FNSI-mongoDBに挿入、検索できることの対応 end
      } else {
        //update FNSI-mongoDBに挿入、検索できることの対応 start
        // let savedTabData = new TabModel(
        //   Math.round(Math.random() * 1000000),
        //   '新規タブ',
        //   { key: "", isAsc: true },
        //   { freeWord: "", column: "" },
        //   []
        // );
        // this.displayTabs.push(savedTabData);
        // this.syncTabLocalToStore(this.displayTabs);
        // this.switchTab(savedTabData);
        this.getCondition.noticeStartDate = dayjs().format("YYYY-MM-DD");
        this.getCondition.noticeStartTime = dayjs().startOf('day').format("HH:mm");
        this.getCondition.noticeEndDate = dayjs().format("YYYY-MM-DD");
        this.getCondition.noticeEndTime = dayjs().format("HH:mm");
        this.getCondition.limitTo = 0;
        this.filterTimes = 0;
        this.getCondition.pageSize = PAGE_SIZE;
        this.getCondition.sortKey = "";
        this.getCondition.sortOrder = null;
        // add 障害票一覧_NKK 修正 chen start
        if (this.openingTab && this.openingTab.sort) {
          this.openingTab.sort.key = "";
          this.openingTab.sort.isAsc = null;
        }
        const sortedDesc = this.getSortedHeaderElement("sorted-desc");
        if (sortedDesc) {
          sortedDesc.classList.remove("sorted-desc");
        }
        const sortedAsc = this.getSortedHeaderElement("sorted-asc");
        if (sortedAsc) {
          sortedAsc.classList.remove("sorted-asc");
        }
        // add 障害票一覧_NKK 修正 chen end

        // 画面遷移パラメータ取得
        const queryParameters = this.getQueryParameters();
        if (queryParameters.DATE) {
          this.getCondition.noticeStartDate = queryParameters.DATE;
          this.getCondition.noticeEndDate = queryParameters.DATE;
          this.getCondition.noticeStartTime = "00:00";
          this.getCondition.noticeEndTime = "23:59";
        }

        // add FNSI-NO578日機装ユーザーでログ検索が実行されない。(施設ユーザでは検索可能) 張岩 start
        // this.getCondition.facilityCd = [{facilityCd: this.getStateUserAccountInfo.facilityCd}]
        //del 6513 2023-03-09 引き継いだ抽出条件での利用者選択・患者選択で内容が表示されない 張 end
        // add FNSI-NO578日機装ユーザーでログ検索が実行されない。(施設ユーザでは検索可能) 張岩 end
        const defaults = this.defaultCondition();
        this.getCondition.logClass = defaults.logClass;
        this.getCondition.logType = defaults.logType;
        this.getCondition.typeSearch = defaults.typeSearch;
        this.setDefaultCondition(Object.assign({}, defaults));
        this.getLogReference(this.getCondition, false, { clearColumnFilter: true });
        //update FNSI-mongoDBに挿入、検索できることの対応 end
      }
    },
      //add FNSI-mongoDBに挿入、検索できることの対応 start
      defaultCondition() {
          let ret = {
              noticeStartDate: dayjs().format("YYYY-MM-DD"),
              noticeStartTime: dayjs().startOf('day').format("HH:mm"),
              noticeEndDate: dayjs().format("YYYY-MM-DD"),
              noticeEndTime: dayjs().format("HH:mm"),
              duration: 0,
              facilityCd: [],
              moduleName: [],
              logClass: [],
              logType: [],
              userId: [],
              patId: [],
              keySearch: "",
              serviceName: [],
              typeSearch: 4,
          };
          if (this.isMasterUser) {
              ret.logClass = [appPropertiesLogging, eventPropertiesLogging]
              ret.logType = ["error", "warning", "info"];
          } else {
              ret.logClass = [eventPropertiesLogging]
              ret.logType = ["error", "warning", "info"];
          }
          return ret;
      },
      //add FNSI-mongoDBに挿入、検索できることの対応 end

    /**
     * @description スイッチタブ
     * @param { Object } タブ
     */
    switchTab(tab) {
      if (this.actionRemoveFlag) {
        this.actionRemoveFlag = false;
        return;
      }
      if (this.displayTabs.length > 0) {
        if (this.displayTabs.find(item => item === tab)) {
          this.openingTab = tab;
        } else {
          this.openingTab = this.displayTabs[0];
        }
        if (this.openingTab.rowSelected && this.openingTab.cellSelected) {
          this.contentNode = this.openingTab.rowSelected[this.openingTab.cellSelected];
        } else {
          this.contentNode = "";
        }
      } else {
        this.openingTab = null;
      }
    },

    /**
     * @description タブを削除
     * @param { Object } 削除するタブ
     */
    removeTab(clickedTab) {
      this.actionRemoveFlag = true;
      let index = this.displayTabs.indexOf(clickedTab);
      this.contentNode = "";
      this.displayTabs.splice(index, 1);
      if (this.displayTabs.length > 0) {
        if (this.openingTab === clickedTab) {
          this.actionRemoveFlag = false;
          if (this.displayTabs[index]) {
            this.switchTab(this.displayTabs[index]);
          } else {
              this.setManagedTimeout(() => {
                this.switchTab(this.displayTabs[index - 1]);
              }, 300); // switchTab関数の効果を制限する
          }
        }
      } else {
        this.dataSource = [];
        this.actionRemoveFlag = false;
      }
      this.syncTabLocalToStore(this.displayTabs);
    },

    /**
     * @description 優先度によるカスタムタイトルタブ
     * @param { Object } 現状
     * @returns { String } タイトルタブ
     */
    titleTab(currentCondition) {
      const defaultCondition = this.ensureDefaultCondition();

      if (currentCondition != defaultCondition) {
        // 1. 検索文字列
        if (currentCondition.keySearch !== "") {
          return this.limitTitleLength("検索文字列", currentCondition.keySearch);
        }

        // 2. 表示期間
        if (currentCondition.noticeStartDate !== "" || currentCondition.noticeEndDate !== "") {
          if (currentCondition.noticeStartDate != defaultCondition.noticeStartDate ||
          currentCondition.noticeEndDate != defaultCondition.noticeEndDate ||
          currentCondition.noticeStartTime != defaultCondition.noticeStartTime ||
          currentCondition.noticeEndTime != defaultCondition.noticeEndTime) {
            let value = `${currentCondition.noticeStartDate}~${currentCondition.noticeEndDate}`;
            return this.limitTitleLength("表示期間", value);
          }
        }

        // 3. 利用者ID
        if (currentCondition.userId && currentCondition.userId.length > 0) {
          return this.limitTitleLength("利用者ID", this.getListUser(currentCondition.userId));
        }

        // 4. 内部患者ID
        if (currentCondition.patId && currentCondition.patId.length > 0) {
          return this.limitTitleLength("患者ID", this.getListCd(currentCondition.patId));
        }

        // 5. 種別（ログ分類）
        if (
          currentCondition.logType.sort().toString() != defaultCondition.logType.sort().toString() &&
          currentCondition.logType && currentCondition.logType.length > 0
        ) {
          return this.limitTitleLength("種別（ログ分類）", currentCondition.logType.toString().replace(",", "+").toUpperCase());
        }

        if (
          currentCondition.logClass.sort().toString() != defaultCondition.logClass.sort().toString() &&
          currentCondition.logClass && currentCondition.logClass.length > 0
        ) {
          const value = currentCondition.logClass.toString().replace("service", "サービスログ").replace("event", "イベントログ");
          return this.limitTitleLength("種別（ログ分類）", value.replace(",", "+"));
        }

        // 6. サービス名
        if (currentCondition.serviceName && currentCondition.serviceName.length > 0) {
          return this.limitTitleLength("サービス名", this.getListName(currentCondition.serviceName));
        }
      }
      let value = `${currentCondition.noticeStartDate}~${currentCondition.noticeEndDate}`;
      return this.limitTitleLength("表示期間", value);
    },

    /**
     * @description タイトルの文字制限はデバイスによって異なります
     * @param { String, String } の左側、右側：
     * @returns { String } タイトルが編集されました
     */
    limitTitleLength(title, value) {
      const ua = getScopedUserAgent(this.$el);
      const limit = ua.match(/Android/) || ua.match(/iPhone|iPad/) ? 6 : 24;
      let titleTab = "";
      switch (title) {
        case "検索文字列":
        case "表示期間":
          titleTab = `${title}：${value}`;
          return titleTab.length < limit ? titleTab : titleTab.substring(0, limit) + "…";
        case "患者ID":
        case "利用者ID":
          titleTab = `${title}：${value}`;
          return titleTab.length < limit ? titleTab.substring(0, limit) : `${title}：複数名`;
        case "種別（ログ分類）":
        case "サービス名":
          titleTab = `${title}：${value}`;
          return titleTab.length < limit ? titleTab.substring(0, limit) : `${title}：複数`;
      }
    },

    /**
     * @description ダウンロードデータを確認する
     */
    onClickDownload() {
      this.$ons.notification.confirm({
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
        // title: "",
        title: DIALOG_MESSAGES[13000043].title,
        // message: "ログファイルをダウンロードします。<br>よろしいですか？",
        message: messageFormat(DIALOG_MESSAGES[13000043].message),
        buttonLabels: ["Cancel", "OK"],
        // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
        callback: answer => {
          if (answer === 1) {
            this.exportCSV();
          }
        }
      });
    },

    /**
     * @description データをcsvにエクスポートする
     */
    async exportCSV() {
      let csvContent = "";
      // mod ダウンロードしたファイルに検索条件に満たす対象レコードが一部だけ含めてしまう。全部含む必要 修正 陳 start
      /* modify by chamaojia 2022-11-10 [7183] downloadエラー  --start */
      const condition = this.getCondition;
      if (this.openingTab && this.openingTab.sort) {
        condition.sortKey = this.openingTab.sort.key;
        condition.sortOrder = this.openingTab.sort.isAsc;
      } else {
        condition.sortKey = "";
        condition.sortOrder = null;
      }
      const logReferenceAll = await this.getLogReferenceAll(condition);
      /* modify by chamaojia 2022-11-10 [7183] downloadエラー  --end */
      const datas = logReferenceAll.dataSource;
      csvContent += '"' + "番号" + '",';
      this.displayItems.forEach(item => {
        csvContent += '"' + item.name + '",';
      });
      csvContent += "\r\n";
      for (let i = 1; i < datas.length + 1; i++) {
        csvContent += '"' + i + '",';
        let data = datas[i - 1];
        this.displayItems.forEach(item => {
          csvContent += '"' + this.getFieldText(data, item) + '",';
        });
        csvContent += "\r\n";
      }
      const charCodes = [];

      for (let i = 0; i < csvContent.length; i++) {
        charCodes.push(csvContent.charCodeAt(i));
      }

      // csvをエクスポート
      const sjisCodes = encoding.convert(charCodes, 'sjis', 'unicode');
      const uint8s = new Uint8Array(sjisCodes);

      const blob = new Blob([uint8s], { type: 'text/csv;charset=sjis;' });
      triggerScopedDownload({
        blob,
        filename: `ログ_${dayjs().format("YYYYMMDDHHmmssSSS")}.csv`,
        root: this.$el
      });
      // let downloadTable = this.$refs[`download_${this.openingTab.cd}`];
      // let tableRows = downloadTable[0].rows;
      // let rowData = [...tableRows];
      // rowData.forEach(row => {
      //   let columns = [...row.children];
      //   columns.forEach(col => {
      //     if (col.className !== "" && !col.className.includes("visible-style") && !col.className.includes("color-column")) {
      //       let cellData = col.textContent.trim();
      //       csvContent += '"' + cellData + '",';
      //     }
      //   });
      //   csvContent += "\n";
      // });
      // let link = document.createElement("a");
      // link.href = "data:text/csv;charset=utf-8,%EF%BB%BF" + encodeURI(csvContent);
      // link.download = `ログ_${dayjs().format("YYYYMMDDHHmmssSSS")}.csv`;
      // link.click();
      // mod ダウンロードしたファイルに検索条件に満たす対象レコードが一部だけ含めてしまう。全部含む必要 修正 陳 end
    },

    /**
     * @description テーブルデータセルの値を取得
     * @returns { String } テーブルデータセルの値
     */
    getFieldText(item, field) {
      const key = this.columns.find(i => i.cd === field.cd).key;
      if (field.key === "date" && key) {
        return dayjs(item[key]).format("YYYY/MM/DD HH:mm:ss");
      }
      return item[key] ? item[key] : "";
    },

    /**
     * @description 表示項目設定リストセレクターを作成する
     * @returns 項目設定リストを表示する
     */
    listSelectItem() {
      this.isItemSelectorVisible = true;
      this.itemSelectorData = this.createItemSelectorData();
    },

    /**
     * @description 表示項目設定リストセレクターを作成する
     * @returns 項目設定リストを表示する
     */
    createItemSelectorData() {
      const title = "";
      const class1 = null;
      const class2 = null;

      const defaultSelection = _.isEmpty(this.displayItems)
        ? []
        : this.displayItems.map(item => item.cd);

      const itemList = this.columns;

      return { title, itemList, class1, class2, defaultSelection };
    },

    /**
     * @description スタッフ選択確定
     */
    commitItemListSelect(selectedList) {
      this.displayItems = this.columns
        .filter(item => selectedList.find(i => i.cd === item.cd))
        .sort((a, b) => {
          return selectedList.findIndex(i => i.cd === a.cd) - selectedList.findIndex(i => i.cd === b.cd);
        });
      const unselectColumn = this.columns.filter(i => !this.displayItems.find(d => d.cd === i.cd));
      this.columns = [...this.displayItems, ...unselectColumn];
    },

    /**
     * @description コンポーネントを再利用させないためのkey属性値(現在日時+文字列)
     * @summary コンポーネントの再利用によって選択項目やフィルタに設定した値が残ったままになるのを防ぐ
     * @param {String} str 任意の文字列 ※コンポーネントごとに変えること
     * @returns {String} YYYYMMDDHHmmssSSS
     */
    componentKey(str) {
      return `${dayjs().format("YYYYMMDDHHmmssSSS")}${str}`;
    },

    /**
     * @description リスト選択表示起点
     */
    selectorTarget(refName) {
      return this.$refs[`${refName}`];
    },

    /**
     * @description 列ヘッダクリック時の処理
     */
    theadClicked(item) {
      if (this.isResizing) return;
      this.syncColumnWidthsFromDom();
      this.draggableKey++;
      // ソート実行
      this.sortBy(item.key);
    },

    colHeaderWidth(item) {
      return this.columnWidths[item.cd] || `${this.colWidth}px`;
    },

    syncColumnWidthsFromDom() {
      const tables = this.getDataTables();
      const table = tables.find(t => t.style.display !== "none") || tables[0];
      if (!table) return;

      const ths = table.querySelectorAll("thead tr th");
      for (let i = 1; i < ths.length && i - 1 < this.columns.length; i++) {
        const col = this.columns[i - 1];
        const th = ths[i];
        const measured = Math.round(this.getThColumnWidth(th));
        if (measured <= 0) continue;

        const saved = parseInt(this.columnWidths[col.cd], 10);
        const defaultWidth = this.colWidth;
        // 已保存且与 DOM 一致：跳过，避免 offsetWidth 反复叠加 padding/border 导致变宽
        if (saved && Math.abs(measured - saved) <= 2) continue;
        // 未拉宽（仍接近默认宽）：不写 columnWidths
        if (!saved && Math.abs(measured - defaultWidth) <= 2) continue;

        this.columnWidths[col.cd] = `${measured}px`;
      }
    },

    applyStoredColumnWidths() {
      if (!Object.keys(this.columnWidths).length) {
        return;
      }
      const tables = this.getDataTables();
      const table = tables.find(t => t.style.display !== "none") || tables[0];
      if (!table) {
        return;
      }
      const ths = table.querySelectorAll("thead tr th");
      for (let i = 1; i < ths.length && i - 1 < this.columns.length; i++) {
        const col = this.columns[i - 1];
        const width = this.columnWidths[col.cd];
        if (width) {
          ths[i].style.width = width;
        }
      }
    },

    getThColumnWidth(th) {
      const inlineWidth = parseInt(th.style.width, 10);
      if (inlineWidth > 0) return inlineWidth;
      const rect = th.getBoundingClientRect();
      const style = getComputedStyle(th);
      if (style.boxSizing === "border-box") {
        return rect.width;
      }
      const padding =
        parseFloat(style.paddingLeft) + parseFloat(style.paddingRight);
      const border =
        parseFloat(style.borderLeftWidth) + parseFloat(style.borderRightWidth);
      return rect.width - padding - border;
    },

    saveColumnWidthFromTh(th) {
      const row = th.parentElement;
      if (!row) return;
      const thIndex = Array.from(row.children).indexOf(th);
      if (thIndex <= 0 || thIndex - 1 >= this.columns.length) return;
      const col = this.columns[thIndex - 1];
      const width = Math.round(this.getThColumnWidth(th));
      if (width > 0) {
        this.columnWidths[col.cd] = `${width}px`;
      }
    },
    /**
     * @description 列ヘッダ フィルタアイコン クリック時の処理
     */
    showFilter(event, item) {
      this.filterTarget = event;
      this.filterVisible = true;
      const currentColumnName = item.name;
      const savedColumn = this.openingTab.filter.columns ? this.openingTab.filter.columns.find(c => c.name === currentColumnName) : null;
      this.tempFreeword = savedColumn ? savedColumn.freeWord : "";
    },

    filterOK() {
      const filterTargetName = this.filterTarget.target.previousElementSibling.textContent.trim();
      // add bug #4110 修正 chen start
      if (this.openingTab.filter.columns) {
        const targetColumnIndex = this.openingTab.filter.columns.findIndex(c => c.name === filterTargetName);
        if (targetColumnIndex !== -1) {
          this.openingTab.filter.columns.splice(targetColumnIndex, 1);
          const filteringIndex = this.filteringColName.findIndex(c => c.name === filterTargetName);
          if (filteringIndex > -1) {
            this.filteringColName.splice(filteringIndex, 1);
          }
        }
      }
      // add bug #4110 修正 chen end
      const targetColumn = this.displayItems.find(item => item.name.trim() === filterTargetName);
      if (!targetColumn) {
        this.filterVisible = false;
        return;
      }
      const filterWord = (this.tempFreeword ?? "").trim();
      this.openingTab.filter.column = targetColumn;
      this.filterVisible = false;
      this.openingTab.filter.freeWord = filterWord;
      targetColumn.freeWord = filterWord;
      const matchedColumn = this.columns.find(item => String(item.cd) === String(targetColumn.cd));
      if (matchedColumn) {
        matchedColumn.freeWord = filterWord;
      }
      if (!this.openingTab.filter.columns) {
        this.openingTab.filter.columns = [];
      }
      if (filterWord !== "") {
        this.openingTab.filter.columns.push({ ...targetColumn, freeWord: filterWord });
        if (!this.filteringColName.find(c => String(c.cd) === String(targetColumn.cd))) {
          this.filteringColName.push(targetColumn);
        }
      } else {
        this.openingTab.filter.column = null;
        this.openingTab.filter.freeWord = "";
      }

      // mod #10016 列フィルタ確定後はAPIで先頭ページから再取得（列ヘッダフィルタ状態は維持）
      this.limitTo = 0;
      this.filterTimes = 0;
      this.getCondition.limitTo = 0;
      this.getCondition.filterTimes = 0;
      this.getCondition.pageSize = PAGE_SIZE;
      if (this.openingTab?.sort) {
        this.getCondition.sortKey = this.openingTab.sort.key;
        this.getCondition.sortOrder = this.openingTab.sort.isAsc;
      }
      this.getLogReference(this.getCondition, false, { clearColumnFilter: false });

      // フィルタ直後にスクロール位置が最下端の場合のみ下方向スクロール領域を確保するため上に10pxずらす
      this.$nextTick(() => {
        const e = this.$refs.ntssList;
        const isScrolledBottom = Math.abs(e.scrollTop + e.clientHeight - e.scrollHeight) < 4;
        if (isScrolledBottom) {
          e.scrollTop = Math.max(0, e.scrollTop - 10);
        }
      });
    },
    cloneOpeningTabFilter() {
      const filter = this.openingTab?.filter;
      if (!filter) {
        return { freeWord: "", column: null, columns: [] };
      }
      return {
        freeWord: filter.freeWord ?? "",
        column: filter.column ? { ...filter.column } : null,
        columns: (filter.columns || []).map(column => ({ ...column }))
      };
    },

    /**
     * 列ヘッダのフィルタクリア
     */ 
    cancelFilter() {
      this.openingTab.filter.columns = [];
      this.filteringColName = [];
      this.openingTab.filter.column = null;
      this.filterVisible = false;
      this.openingTab.filter.freeWord = "";
      this.tempFreeword = "";
      this.skipScrollHandler = true;
      const clearColumnFreeWord = column => {
        column.freeWord = "";
      };
      this.displayItems.forEach(clearColumnFreeWord);
      this.columns.forEach(clearColumnFreeWord);
    },

    filterValidate(data) {
      if (
        !this.openingTab.filter.columns
        ||this.openingTab.filter.columns.length === 0) {
        return true;
      }
      let isValid = true;
      this.openingTab.filter.columns.forEach(column => {
        if (column.key === "date" && !dayjs(data[column.key]).format("YYYY/MM/DD HH:mm:ss").includes(column.freeWord)) {
          isValid = false;
        } else if (
          data[column.key] != null &&
          !String(data[column.key]).toLowerCase().includes(String(column.freeWord ?? "").toLowerCase())
        ) {
          isValid = false;
        }
      });
      return isValid;
    },

    getListCd(array) {
      return array && array.length > 0 ? array.map(item => item.cd).join(",") : null;
    },

    getListName(array) {
      return array && array.length > 0 ? array.map(item => item.name).join(",") : null;
    },

    getListUser(array) {
      return array && array.length > 0 ? array.map(item => `${item.cd}:${item.name}`).join(",") : null;
    },

    calculateMaxWidth() {
      this.maxWidth = this.$refs.refTab ? ((this.$refs.refTab.clientWidth - 25) / this.displayTabs.length) - 30 : 0;
    },

    calculateMaxHeight() {
      if (this.$refs.refTab && this.$refs.refBottomControl) {
        const mainId = this.$refs.refMain || this.getViewLogRootElement();
        let mainIdHeight = mainId ? mainId.offsetHeight : 0;
        this.viewLogAreaHeight =
          mainIdHeight -
          this.$refs.refTab.clientHeight -
          this.$refs.refBottomControl.clientHeight;
      }
    },

    calculateColumnWidth() {
      const table = this.getDataTables()[0];
      const columnNumbers = this.isMasterUser ? this.displayItems.length : this.displayItems.length - 1;
      // columnNumbersマネージャーには列ログ種別が表示されないため、1を減算する必要があります
      if (table) {
        this.colWidth = table.offsetWidth / columnNumbers
      }
    },
    /**
     * usernameを取得する。
     */
    getUserName(userId) {
        //update FNSI-mongoDBに挿入、検索できることの対応 start
        if(userId != null && userId != "") {
            let user = this.userList.find(usr => usr.userId.toString() === userId.toString());
            return user ? user.userName : "";
        }
        return "";
        //update FNSI-mongoDBに挿入、検索できることの対応 end
    },
    /**
     * ユーザーリストを取得する
     */
    async getUser() {
      let facCds = this.getCondition.facilityCd && this.getCondition.facilityCd.length > 0
          ? this.getCondition.facilityCd
          : this.getStateUserAccountInfo.facilityCd;
      if (!Array.isArray(facCds)) {
        facCds = [facCds]
      }
      const requestUser = [];
      facCds.forEach(facility => {
        if (Object.prototype.hasOwnProperty.call(facility, 'facilityCd')) {
          requestUser.push(ApiHelper.get(`${uriUser}/${facility.facilityCd}`));
        } else {
          requestUser.push(ApiHelper.get(`${uriUser}/${facility}`));
        }
      });
      let responseUser = await Promise.all(requestUser).catch(e =>{
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add start
          getErrorMessage('ViewLog.vue','getUser',e);
          //FNSI-修正 VUEのエラー場合のログ対応 yuqizheng add end
        console.log(e)});
      responseUser = responseUser.map(u => u.data.localDataSource.data);
      this.userList = [];
      if (responseUser) {
        this.userList = [...responseUser].flat();
      } else {
        this.userList = [];
      }
    },
    resizableGrid(table) {
      let that = this;
      let row = table.getElementsByTagName('tr')[0];
      let cols = row ? row.children : undefined;
      let header = table.getElementsByTagName('th')[0];
      if (!cols) return;

      table.style.overflow = 'hidden';
      let headerHeight = header.offsetHeight;

      let spliter = createSpliter();
      const logTable = this.getLogTableElement();
      logTable?.appendChild(spliter);
      setTableListeners(spliter);

      for (let i=0;i<cols.length;i++){
        let div = createDiv(headerHeight);
        cols[i].appendChild(div);
        cols[i].style.position = 'relative';
        setListeners(div);
        setListenerForParent(cols[i]);
      }

      function setListenerForParent(parent) {
        that.addManagedEventListener(parent, 'click', (e) => {
          e.preventDefault();
          e.stopPropagation();
        });
      }

      const resizeOwnerDocument = table?.ownerDocument || this.getViewLogOwnerDocument();

      function setTableListeners(div){
      let pageY,tableHeight;
      const table = this.getLogTableElement();
      that.addManagedEventListener(div, 'mousedown', (e) => {
        pageY = e.pageY;
        tableHeight = table ? table.offsetHeight : 0;

      });

      that.addManagedEventListener(resizeOwnerDocument, 'mousemove', (e) => {
        if (table) {
        let diffY = e.pageY - pageY;
        table.style.height = tableHeight + diffY + 'px';
        }
      });

      that.addManagedEventListener(resizeOwnerDocument, 'mouseup', () => {
        pageY = undefined;
        tableHeight = undefined;
      });
      }

      function setListeners(div){
      let pageX,curCol,curColWidth,tableWidth;

      that.addManagedEventListener(div, 'mousedown', (e) => {
        clearTimeout(that.timeOut);
        that.isResizing = true;
        curCol = e.target.parentElement;
        pageX = e.pageX;
        curColWidth = curCol.offsetWidth;
        tableWidth = table.offsetWidth;
      });

      that.addManagedEventListener(resizeOwnerDocument, 'mousemove', (e) => {
        if (curCol) {
        let diffX = e.pageX - pageX;
        curCol.style.width = (curColWidth + diffX)+'px';
        table.style.width = tableWidth + diffX + 'px';
        }
      });

      that.addManagedEventListener(resizeOwnerDocument, 'mouseup', () => {
        if (curCol) {
          that.saveColumnWidthFromTh(curCol);
        }
        curCol = undefined;
        pageX = undefined;
        curColWidth = undefined
        if (that.isResizing) {
          that.timeOut = that.setManagedTimeout(() => {
            that.isResizing = false;
          }, 0);
        }
      });
      }

      function createDiv(height){
        let div = resizeOwnerDocument.createElement('div');
        div.style.top = 0;
        div.style.right = 0;
        div.style.width = '5px';
        div.style.position = 'absolute';
        div.style.cursor = 'col-resize';
        div.style.userSelect = 'none';
        div.style.height = height + 'px';
        return div;
      }
      function createSpliter(){
        let div = resizeOwnerDocument.createElement('div');
        div.style.bottom = 0;
        div.style.right = 0;
        div.style.width = '100%';
        div.style.position = 'absolute';
        div.style.cursor = 'n-resize';
        div.style.userSelect = 'none';
        div.style.backgroundColor = 'black'
        div.style.height = 2 + 'px';
        return div;
      }
    },
    onSelectDisplayColumns({displayItems, columns}) {
      this.displayItems = displayItems,
      this.columns = columns
    }

  },


  async created() {
    /*add マウスを追加する 馬宇婷 start*/
    this.getViewLogOwnerDocument().addEventListener("mouseup", this.mouseUp);
    /*add マウスを追加する 馬宇婷 end*/

    // add 性能改善メモリ不足 shan start
    EventBus.$off('download', this.onClickDownload);
    EventBus.$off('changeViewDetail', this.changeViewDetail);
    EventBus.$off('selectDisplayColumns', this.onSelectDisplayColumns);
    // add 性能改善メモリ不足 shan end
    EventBus.$on('selectDisplayColumns', this.onSelectDisplayColumns);
    EventBus.$on('download', this.onClickDownload);
    EventBus.$on('changeViewDetail', this.changeViewDetail);
    this.columns = createColumns(this.isMasterUser);
    this.displayItems = createDisplayColumns(this.isMasterUser);
    this.ensureDefaultCondition();
    // mod bug 修正 chen start
    if (this.getCondition.noticeStartDate) {
      this.createTab(this.getCondition);
    } else {
      this.createTab(null);
    }
    // this.createTab(null);
    // mod bug 修正 chen end
    this.onGetTabData();
    await this.getUser();
    if (this.openingTab && this.openingTab.filter && this.openingTab.filter.columns) {
      this.openingTab.filter.columns = [];
    }
  },

  beforeUnmount() {
    this.clearManagedRuntimeHandlers();
    this.getViewLogOwnerDocument().removeEventListener("mousemove", this.mouseMove);
    this.getViewLogOwnerDocument().removeEventListener("mouseup", this.mouseUp);
    EventBus.$off('download', this.onClickDownload);
    EventBus.$off('changeViewDetail', this.changeViewDetail);
    // mod 画面パフォーマンス対応 chen start
    EventBus.$off('selectDisplayColumns', this.onSelectDisplayColumns);
    this.setQueryParameters({});
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  }
};
</script>
<style scoped>
  /* add 様式をふやす 馬宇婷 start */
  .y-handle {
    width: 100%;
    height: 2px;
    cursor: s-resize;
    z-index: 10;
    background: #ccc;
  }

  .up-div {
    /*background-color: rebeccapurple;*/
    width: 100%;
    overflow-y: auto;
  }

  .down-div {
    /*background-color: yellow;*/
    width: 100%;
    overflow-y: auto;
    /* add フォントの色を変える 馬宇婷 start */
    color: var(--send-cond-font-color);
    /* add フォントの色を変える 馬宇婷 end */
  }
  /* add 様式をふやす 馬宇婷 end */

.ntss-list-header-th-sticky {
  text-align: center;
}

#log-table {
  position: relative;
  max-height: 100%;
}

.fit-column {
  width: 1%;
  min-width: 35px;
  text-align: center;
  padding: 8px;
}

table.table {
  border-collapse: collapse;
}

.content-textarea {
  width: 100%;
  border: 0;
  font-size: 2em;
}

.content-node {
  /*update テキストフィールドのスタイルを変更します  馬宇婷 start*/
  /*width: 100%;
  border: 0;
  height: fit-content;*/
  width: 100%;
  border: 0;
  height: 10em;
  overflow-y: scroll;
  font-size: 1em;
  cursor: default;
  position: sticky;
  bottom: 0;
  /*update テキストフィールドのスタイルを変更します  馬宇婷 end*/
}

/* タブのスタイル */
.tab {
  overflow-y: hidden;
  position: sticky;
  top: 0;
  width: 100%;
  overflow-x: auto;
  white-space: nowrap;
}

.tab:-webkit-scrollbar {
  display: none;
}

.scroll-area {
  height: 100%;
  width: 100%;
  overflow-y: auto;
  position: relative;
}
.data-table td.active {
  font-weight: bold;
}

.data-table tr.active,
.tab-table th.active {
  background-color: var(--master-maintenance-kgrid-selected-background-color);
}

.resize-col {
  box-sizing: border-box;
  resize: horizontal;
  overflow-x: hidden;
}

.visible-style {
  display: none;
}

.popover-area :deep(.popover-mask) {
  z-index: 100;
}

.pop-area {
  margin: 10px;
}

/* フリーワード：通常の灰枠を維持、focus 時の緑枠（#7229）のみ抑止 */
.pop-area .filter-freeword-input {
  border: none !important;
  box-shadow: none !important;
}
.pop-area .filter-freeword-input :deep(.text-input) {
  border: 1px solid #ccc !important;
  outline: none !important;
  box-shadow: none !important;
  background-color: var(--search-input-background-color, #fff);
}
.pop-area .filter-freeword-input :deep(.text-input:focus) {
  border: 1px solid #ccc !important;
  outline: none !important;
}

.ok-button {
  float: right;
}

.condition-button-area {
  height: 30px;
  margin: 10px;
  text-align: center;
}

.tab-table {
  border-collapse: collapse;
  width: 100%;
  color: var(--send-cond-font-color);
}

.tab-table tr {
  height: 40px;
}

.tab-table th {
  /* font-size: 1.2em; */
  /* padding: 8px; */
  padding-right: 20px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  border: solid 1px var(--ntss-list-border-color);
  position: relative;
  color: var(--send-cond-font-color);
  background-color: var(--ntss-base-background-color);
}

.tab-table th:last-child {
  text-align: left;
  width: 100%;
  padding: 8px;
}

.tab-table span {
  width: calc(100% - 16px);
}

.tab-table .fa-times {
  position: absolute;
  right: 8px;
  top: 12px;
}

.tab-table .fa-plus {
  position: absolute;
  left: 8px;
  top: 12px;
}

.bottom-control {
  width: 100vw;
  border-top: thin solid gray;
  position: fixed;
  bottom: 44px;
  left: 0;
  z-index: 2;
  height: fit-content;
  color: var(--send-cond-font-color);
  background-color: var(--ntss-base-background-color);
}

.bottom-control ons-row {
  height: fit-content;
}

.bottom-control ons-col:last-child {
  text-align: right;
}

.bottom-control ons-icon {
  margin-top: 1px;
  margin-right: 16px;
}

.sql-content {
  font-size: 2em;
}

.sql-content .statement {
  color: orangered;
}

.ntss-list-body-td {
  overflow: hidden;
  text-overflow: clip;
  white-space: nowrap;
  max-width: 0;
  text-align: left;
  /* add bug #4188 修正 chen start */
  height: 1.95em;
  /* add bug #4188 修正 chen end */
}

.ntss-list-body-td:first-child {
  text-align: center;
}

.clickable-header-label.sorted-asc::after,
.clickable-header-label.sorted-desc::after,
.clickable-header-label.non-sort::after {
  margin-left: 0.3em;
}

.non-sort::after {
  display: initial;
  content: "▲";
  visibility: hidden;
}
.main-content-area {
  overflow-y: unset !important;
}
.thead-container {
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  width: 100%;
  height: 100%;
  box-sizing: border-box;
}

.filter-icon {
  width: 0.8em;
  height: 0.8em;
  position: relative;
  padding: 2px;
  right: 0px;
}
.clickable-header-label {
  display: block;
  width: 100%;
  height: 100%;
  box-sizing: border-box;
  overflow: hidden;
  align-content: center;
  padding-left: 1em;
  transform: translateX(2px);
}
/* add FNSI-改修内容5056修正 関　start */
@media only screen and (min-device-width : 768px) and (max-device-width : 1024px){
   .ntss-list-body-td{
    max-width: 1000px !important;
  }
  .ntss-list-header-th-sticky {
    width: 10px !important;
  }
}
/* add FNSI-改修内容5056修正 関　end */
@media print {
  /* スクロールコンテナ */
  .scroll-area {
    overflow: hidden !important;
  }
  /* 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  table.scroll-rightmost {
    position: relative !important;
    float: right !important;
  }
}
</style>
