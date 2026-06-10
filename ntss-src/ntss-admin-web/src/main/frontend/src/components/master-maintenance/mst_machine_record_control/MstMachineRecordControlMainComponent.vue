/**
 * 装置記録マスタページ  MainContent
 */
<template>
  <div class='main-content-area master-maintenance-page'>
    <div class='ntss-list' :style="ntssListStyles" v-kendo-validator="kendoValidatorSetup">
      <kendo-grid-toolbar class="k-grid-toolbar kendo-grid-toolbar-style" :style="heightStyles">
        <div id="grid-header" class='header-btn-area right'>
          <v-ons-row v-show="isMobileDevice" style="width: 7em;">
            <v-ons-col width="45%" vertical-align="center">
              <label class="fab-font-color">編集</label>
            </v-ons-col>
            <v-ons-col width="55%" vertical-align="center">
              <v-ons-switch modifier="outline" class="custom-switch" v-model="allowEdit" />
            </v-ons-col>
          </v-ons-row>
          <!-- del マスタ一覧 1･施設切替を可能とする 王 start -->
          <!-- <v-ons-button modifier="outline" class="toolbar-btn" style="float: left;" v-show="!isSortMode && isAllowAddRecord" @click="addRow()">追加</v-ons-button> -->
          <!--          <kendo-dropdownlist ref="dropDownList" v-if="isMasterUser"-->
          <!--              v-model="facilitylistValue"-->
          <!--              :data-source="facilities"-->
          <!--              :data-text-field="'facilityName'"-->
          <!--              :data-value-field="'facilityCd'"-->
          <!--              :filter="'contains'"-->
          <!--              @open="onOpenFacility"-->
          <!--              @change="onChangeFacility"-->
          <!--              style="width: 13em;">-->
          <!--          </kendo-dropdownlist>-->
          <v-ons-button modifier="outline" class="btn3-normal toolbar-btn" v-show=" !iosFlg && !androidFlg" @click="importCsv()">CSV取込</v-ons-button>
          <!-- <v-ons-button modifier="outline" class="toolbar-btn" v-show="!isSortMode && isAllowSort" @click="toRankEditBtnClick()">並び順表示</v-ons-button> -->
          <!-- <v-ons-button modifier="outline" class="toolbar-btn" v-show="isSortMode && isAllowSort" @click="sortBtnClick()">反映</v-ons-button> -->
          <!-- del マスタ一覧 1･施設切替を可能とする 王 start -->
        </div>
        <kendo-grid ref="grid" :class="fontSizeSet"
            :data-source="dataSourceItems"
            :editable="true"
            :selectable="true"
            :reorderable="false"
            :height=kendoGridHeight
            :scrollable-virtual="true"
            :beforeEdit=onBeforeEdit
            :edit=addInputAssist
            :cellClose=editEnd
            @save="onSave"
            @databound="onDataBoundKendoGrid">
            <template v-for="(column, index) in columns" >
              <kendo-grid-column v-if="column.field === 'code'"
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="false"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
              <kendo-grid-column v-else
                :key="index"
                :title="column.title"
                :field="column.field"
                :hidden="column.hidden"
                :locked="column.locked"
                :editable="column.editable"
                :width="column.width"
                :format="column.format"
                :values="column.values">
              </kendo-grid-column>
            </template>
        </kendo-grid>
      </kendo-grid-toolbar>
      <div id="grid-footer">
<!--        del 装置記録マスタ ページネーションを削除 start-->
<!--        <v-ons-row width="100%" style="margin-bottom: 3px;text-align: center;">-->
<!--          <v-ons-col width="100%" vertical-align='center' >-->
<!--            <v-ons-button class="button toolbar-btn paginationClass" v-show="true" :disabled="pageNum<=1" @click="setPage(pageNum-1)">前のページ</v-ons-button>-->
<!--            <a href="#" class="paginationClass" @click="setPage(1)" v-if="startPage>1&&totalPage>7">1···</a>-->
<!--            <a href="#"-->
<!--              class="paginationClass"-->
<!--              v-for="(n,key) in totalPage>7 ? 7: totalPage"-->
<!--              :key ="key"-->
<!--              v-text="startPage+n-1"-->
<!--              @click="setPage(startPage+n-1)"-->
<!--              :disabled="startPage+n-1==pageNum"-->
<!--              :class="{'disableATag':startPage+n-1==pageNum}"-->
<!--            ></a>-->
<!--            <a href="#" class="paginationClass" v-text="'···'+totalPage" @click="setPage(totalPage)" v-if="startPage+6<totalPage&&totalPage>7"></a>-->
<!--            <v-ons-button class="button toolbar-btn paginationClass" :disabled="pageNum>=totalPage" @click="setPage(pageNum+1)">次のページ</v-ons-button>-->
<!--            <v-ons-input type='number' class="pageInput paginationClass" float :disabled="totalPage==1" @blur="formatPage" @keydown.enter='pageInputEnter' style="height: 100%;width: 30px"></v-ons-input>-->
<!--            <v-ons-button class="button toolbar-btn paginationClass" :disabled="totalPage==1" @click="setPage(pageInputValue)">ジャンプ</v-ons-button>-->
<!--          </v-ons-col>-->
<!--        </v-ons-row>-->
<!--        del 装置記録マスタ ページネーションを削除 end-->
        <v-ons-row width="100%" v-show="!isSortMode" >
          <v-ons-col width="50%">
            <v-ons-button class="btn2-cancel denial-btn" style="width: auto;" @click="cancel">キャンセル</v-ons-button>
          </v-ons-col>
          <v-ons-col width="50%" class="right">
            <v-ons-button class="btn1-execute registration-btn" style="width: auto;" :disabled="!isChanged" @click="saveRecord">保存</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    <master-csv
      :popoverVisible="masterCsvVisible"
      :popoverTarget="masterCsvTarget"
      @popover-close="prehideCsvPopover"
    />
    </div>
  </div>
</template>

<script>
import moment from "moment";
import _ from "underscore";
import { mapActions, mapGetters } from "vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import { EventBus } from "@/eventBus.js";
import { Validator } from "@progress/kendo-validator-vue-wrapper";
import { ApiHelper } from "@/apis/AxiosHelper";
// import $ from "jquery";
import MasterCsvComponent from "@/components/master-maintenance/MasterCsvComponent";
// import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
// import Vue from "vue";
import { ADVANCED_SETTINGS } from "@/constants/advancedSettings";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
//FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
import { messageFormat } from '@/functions/common/MessageFormat';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end

/**
 * TODO
 * more: モーダルで編集した項目が、一覧上で「編集済み（三角マーク）」をつけたい。
 */
export default {
  name:"MstMachineRecordControl",
  mixins: [NextTransitionMixin, MasterMaintenanceMixin],
  Validator,
    components: {
    "master-csv": MasterCsvComponent
  },
  data() {
    return {
      recordList: [],
      // 初期状態で1列がないとその後の表示が行われないため初期列を定義
      columns: [
        {
          field: "code",
          title: "code",
          hidden: false,
          locked: false,
          editable: () => true,
          values: null
        }
      ],
      condition: {
        recordCode: "",
        recordMessage: "",
        recordName: "",
        dispFlg: "",
        includeDeleted: false
      },
      updateResponse: {
        isSuccess: false,
        errorMessage: ""
      },
      isSortMode: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      columnWidth: 14,
      kendoValidatorSetup: {
        rules: {},
        messages: {}
      },
      mstSynchroApiParams: {
        mstTable: "mst_m_notice",
        deviceEdgeNo: -1
      },
      //Android端末で編集中であることを示すフラグ
      editingFlg: false,
      androidFlg: false,
      iosFlg: false,
      scrollPosition: {
        top: 0,
        left: 0
      },
      //自画面の名称
      selfScreenName: "",
      masterCsvVisible: false,
      masterCsvTarget: null,
      // 選択中の施設コード
      facilitylistValue: "",
      // 選択中施設の在宅機能有無
      facilityHemoDialysis: false,
      //変更前の施設
      prevFacilityCd: "",
      // del 装置記録マスタ ページネーションを削除 start
      // pageNum:1,
      // pageSize:100,
      // totalPage:0,
      // pageInputValue:1
      // del 装置記録マスタ ページネーションを削除 end
      lastScrollTop: 0,
      lastScrollLeft: 0,
      // add 性能改善 劉 start
      dataSourceItems: {},
      // add 性能改善 劉 end
      allowEdit: true, // NOTE: true = 編集モード、 false = 閲覧モード
      zoomObserver: null,
      scrollRestored: true,
    };
  },
  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    ...mapGetters("user", ["getAdvancedSettings", "getSystemUseSetting"]),
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ntssListStyles() {
      return { display: this.columns.length == 1 ? "none" : "inherit" };
    },
    ...mapGetters("master-maintenance", {
      getMasterRecordList: "getMasterRecordList",
      getFilteredMasterRecordList: "getFilteredMasterRecordList",
      getUpdateRecordList: "getUpdateRecordList",
      masterPhysicalName: "getMasterName",
      getLogicalMasterName: "getLogicalMasterName",
      columnDefinition: "getColumns",
      editRecord: "getEditRecord",
      isEdited: "isEdited",
      hasValueColumn: "hasValueColumn",
      isRecordModified: "isRecordModified",
      getFacilityList: "getFacilityList"
    }),
    // 装置記録マスタ バグ修正 start
    viewMasterRecords() {
      return this.dataSourceItems._view;
    },
    // 装置記録マスタ バグ修正 end
    facilities() {
      // storeからデータを取得
      return this.getFacilityList;
    },
    isMasterUser: {
      get() {
        return this.getStateUserAccountInfo.userType === 1 ? true : false;
      },
      set() {}
    },
    startPage(){
      if(this.totalPage <= 7 || this.pageNum-3 < 1){
        return 1;
      }
      if(this.pageNum+3 > this.totalPage){
        return this.totalPage - 6;
      }
      return this.pageNum-3;
    },
    masterRecords() {
      // storeからデータを取得
      let RecordList = this.getFilteredMasterRecordList;
      if(!RecordList.data)RecordList={data:[]}
      // mod 装置記録マスタ ページネーションを削除 start
      // const searchRecord = this.searchRecord(RecordList);
      // this.setTotalPage(searchRecord);
      // const PaginationList = this.Pagination(searchRecord);
      // return PaginationList;
      return this.searchRecord(RecordList);
      // mod 装置記録マスタ ページネーションを削除 end
    },
    isAllowAddRecord() {
      // allowAddRecordが定義されていない場合は追加ボタンは使用不可
      return !(this.getColumnIndex("allowAddRecord") < 0);
    },
    isAllowSort() {
      // allowSortが定義されていない場合は並び替えボタンは使用不可
      return !(this.getColumnIndex("allowSort") < 0);
    },
    isChanged() {
      const data = this.getMasterRecordList.data;
      return (
        this.getStateUserAccountInfo !== null &&
        data !== undefined &&
        (this.isRecordModified || (this.kendoValidator&&!this.kendoValidator.validate()))
      );
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  watch: {
    // 装置記録マスタ バグ修正 start
    viewMasterRecords: {
      handler() {
        this.editBackgroundColor()
      },
      deep: true
    },
    // getMasterRecordList: {
    //   handler() {
    //     this.dataSourceItems = this.generatedGridData();
    //   },
    //   deep: true
    // },
    // 装置記録マスタ バグ修正 end
    windowHeight() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      // this.calculateGridWidth();
      // add start 馬 #9185
      this.$refs.grid.kendoWidget().resize(document.getElementsByClassName("k-grid-content-locked"));
      // add end 馬 #9185
    },
    windowWidth() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      // this.calculateGridWidth();
      // add start 馬 #9185
      this.$refs.grid.kendoWidget().resize(document.getElementsByClassName("k-grid-content-locked"));
      // add end 馬 #9185
    },
    isDispMenu() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      // this.calculateGridWidth();
      // add start 馬 #9185
      this.$refs.grid.kendoWidget().resize(document.getElementsByClassName("k-grid-content-locked"));
      // add end 馬 #9185
    },
    getFontSize() {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      // this.calculateGridWidth();
      // add start 馬 #9185
      this.$nextTick(() => {
        this.$refs.grid.kendoWidget().resize(document.getElementsByClassName("k-grid-content-locked"));
        // Gridインスタンスの取得と仮想スクロールの存在確認
        const grid = this.$refs.grid?.kendoWidget?.();
        if (!grid || !grid.virtualScrollable) return;
        // フォントサイズ変更に伴う行高変化に対応して pageSize を再計算
        const rowHeight = this.$el.querySelector('.k-grid-content tr')?.clientHeight ?? 30;
        const gridHeight = this.$refs.grid?.$el?.offsetHeight ?? 900;
        const newPageSize = Math.floor(gridHeight / rowHeight);
        // 現在の pageSize を取得（仮想スクロールの表示行数）
        const currentPageSize = this.dataSourceItems?.pageSize();
        // pageSize が変化している場合は、DataSource を再生成して Grid をリサイズ
        if (newPageSize !== currentPageSize) {
          this.dataSourceItems = this.generatedGridData(newPageSize);
          grid.resize();
        }
      });
      // add end 馬 #9185
    },
    columns:function(val){
      this.$nextTick(function(){
        if (val.length > 1)
        this.setLoadingScreenVisible(false);
      });
    },
    // #10142 装置記録マスタにてメッセージを変更したCSV取り込みを行ったが更新されない linjunfeng start
    masterRecords () {
      this.dataSourceItems = this.generatedGridData();
    },
    // #10142 装置記録マスタにてメッセージを変更したCSV取り込みを行ったが更新されない linjunfeng end
  },
  methods: {
    ...mapActions("multi-modal", ["showMasterEdit"]),
    ...mapActions("master-maintenance", [
      "findRecordList",
      "findColumnInfo",
      "setMasterRecordList",
      "edit",
      "setCondition",
      "updateRecordList",
      "updateRecordListByFacilityCd",
      "setEditRecord",
      "editRecordBeEmpty",
      "setComparisonRecordModel",
      "findRecordListByFacilityCdWithSql"
     ,"updateIndCondInfo"
    ]),
    ...mapActions("master-maintenance", {
      facilityList: "facilityList"
    }),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount:  "resetLoadingScreenVisibleCount"
    }),
    // 装置記録マスタ バグ修正 start
    // delete start #9395
    // calculateGridWidth() {
    //   // 描画後に実行
    //   if (document.getElementsByClassName("k-grid-content-locked").length !== 0) {
    //     // 固定列数のカウント
    //     const lockedColumns = this.columns
    //       .filter(col => col.locked === true && col.hidden === false).length;

    //     // 固定列幅算出
    //     // ソートモード以外では -1 する(ダミー列)
    //     const sortColumn = this.isSortMode ? 0 : 1;
    //     let lockedColumnWidth = (lockedColumns - sortColumn) * this.columnWidth;
    //     if (this.lockedColumnsWidth) {
    //       lockedColumnWidth = this.lockedColumnsWidth;
    //     }
    //     // リサイズする前のscroll値を取得する
    //     let tmpScrollLeft = 0;
    //     let tmpScrollTop = 0;
    //     if (this.editFlg) {
    //       tmpScrollLeft = this.scrollLeft;
    //       tmpScrollTop = this.scrollTop;
    //       this.editFlg = false;
    //     } else {
    //       tmpScrollLeft = document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].scrollLeft;
    //       tmpScrollTop = document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].scrollTop;
    //     }

    //     // スマートフォン以外で固定行有：空白行幅の調整値
    //     const targetWidth = ((this.androidFlg || this.iosFlg) || lockedColumnWidth == 0) ? 0 : 14;
    //     // kendoGridのリサイズを呼び出して自動リサイズがされないケースがある問題に対応
    //     if (this.$refs.grid != null) {
    //       const setWidth = parseInt(this.$refs.grid.kendoWidget().columns[0].width);
    //       this.$refs.grid.kendoWidget().resizeColumn(this.$refs.grid.kendoWidget().columns[0], setWidth);
    //     }
    //     if (lockedColumnWidth != 0) {
    //     // 固定列の幅確保
    //       document.getElementsByClassName("k-grid-header-locked")[0].style.width = lockedColumnWidth + 'em';
    //       document.getElementsByClassName("k-grid-content-locked")[0].style.width = lockedColumnWidth + 'em';
    //     }

    //     // 画面幅よりも固定列の幅が大きくなった場合、可変列のヘッダが見切れるため
    //     // グリッドサイズを画面幅以上に拡張する
    //     if (document.getElementsByClassName('k-grid')[0].clientWidth
    //       < document.getElementsByClassName("k-grid-header-locked")[0].clientWidth
    //     ) {
    //       // グリッドサイズ拡張
    //       document.getElementsByClassName('k-grid')[0].style.width
    //         = (document.getElementsByClassName("k-grid-header-locked")[0].clientWidth
    //         + 100 + targetWidth) + 'px';
    //       // 拡張分の幅で可変列のヘッダ幅定義
    //       document.getElementsByClassName("k-grid-header-wrap k-auto-scrollable")[0].style.width
    //         = (100 + targetWidth) + 'px';
    //     } else {
    //         const scrollbarWidth = document.getElementsByClassName('k-scrollbar k-scrollbar-vertical')[0].offsetWidth

    //       const headerLockWidth = (document.getElementsByClassName('k-grid')[0].clientWidth
    //         - document.getElementsByClassName("k-grid-header-locked")[0].clientWidth) + targetWidth;
    //       const contentScrollableWidth = (document.getElementsByClassName('k-grid')[0].clientWidth
    //         - document.getElementsByClassName("k-grid-content-locked")[0].clientWidth) + targetWidth - scrollbarWidth;

    //       // 固定列の幅を確保
    //       document.getElementsByClassName("k-grid-header-wrap k-auto-scrollable")[0].style.width = headerLockWidth + 'px';
    //       document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].style.width = contentScrollableWidth + 'px';
    //       // 縦スクロールの幅を確保
    //       if (headerLockWidth === contentScrollableWidth && lockedColumnWidth) {
    //         document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].style.width = (contentScrollableWidth - 17) + 'px';
    //       }
    //       if (this.iosFlg) {
    //         document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].style.width = (contentScrollableWidth) + 'px';
    //       }
    //     }

    //     if (document.getElementsByClassName("k-grid-content").length !== 0
    //       && document.getElementsByClassName('k-grid-content-locked')[0].clientHeight
    //       !== document.getElementsByClassName('k-grid-content')[0].clientHeight
    //       && !this.androidFlg && !this.iosFlg
    //     ) {
    //       document.getElementsByClassName('k-grid-content-locked')[0].style.height =
    //         document.getElementsByClassName('k-grid-content')[0].offsetHeight - 17 + 'px';
    //     }

    //     // 固定列の幅確保後、リサイズする前のscroll値を設定
    //     setTimeout(() => {
    //       document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].scrollLeft = tmpScrollLeft;
    //       document.getElementsByClassName("k-grid-content k-auto-scrollable")[0].scrollTop = tmpScrollTop;
    //     });
    //   }
    // },
    // delete end #9395
    // add start #9395
    onDataBoundKendoGrid(ev) {
      if (!this.scrollRestored && (this.lastScrollTop > 0 || this.lastScrollLeft > 0)) {
        this.scrollRestored = true;
        //スクロールバーの位置をイベント発生前の位置に戻す
        this.$nextTick(() => {
          ev.sender.content[0].lastChild.scrollTop = this.lastScrollTop;
          ev.sender.content[0].firstChild.scrollLeft = this.lastScrollLeft;
        });
      }

      const grid = this.$refs.grid?.kendoWidget?.();
      if (!grid || !grid.virtualScrollable) return;

      const wrapper = grid.wrapper?.[0];
      if (!wrapper) return;

      let startY = 0;
      let scrollStart = 0;
      let isVerticalScroll = false;

      wrapper.addEventListener('touchstart', (e) => {
        if (e.touches.length === 1) {
          startY = e.touches[0].clientY;
          scrollStart = grid.virtualScrollable.verticalScrollbar[0].scrollTop;
          isVerticalScroll = false;
        }
      }, { passive: true });

      wrapper.addEventListener('touchmove', (e) => {
        if (e.touches.length === 1) {
          const currentY = e.touches[0].clientY;
          const deltaY = startY - currentY;

          if (!isVerticalScroll && Math.abs(deltaY) > 10) {
            isVerticalScroll = true;
          }

          if (isVerticalScroll) {
            const newScrollTop = scrollStart + deltaY;

            requestAnimationFrame(() => {
              grid.virtualScrollable.verticalScrollbar[0].scrollTop = newScrollTop;
            });

            e.preventDefault(); // iOSでスクロールを有効にするために必要
          }
        }
      }, { passive: false });
    },
    // add end #9395
    editBackgroundColor() {
      this.$nextTick(() => {
        // グリッドが表示されていなかったら処理終了
        const gridHeader = this.$refs.grid.$el.firstChild;
        if (gridHeader.textContent === " ") {
          return;
        }
        gridHeader?.classList?.add("master-grid-header");

        // グリッドにレコードがなければ処理終了
        // 固定列、可変列、データソースの取得
        const tbodyc = this.$refs.grid.$el.lastChild.firstChild.lastChild.tBodies?.[0].children;
        const gridData = this.$refs.grid.dataSource;

        // 列の行数は固定・可変で同一なため可変列の行数を使用
        for (let rwCount = 0; rwCount < tbodyc?.length; rwCount++) {
          const currentTrc = tbodyc[rwCount].children;
          const currentLockTrc = [];

          // 編集項目の色を変更
          let edited = this.changeEditColor(currentTrc, currentLockTrc);
          // this.changeEditColor(currentTrc, currentLockTrc);

          // モーダルからの編集も色を変更する
          if (
            this.isEdited(gridData._view[rwCount].code)
          ) {
            edited = true;
          }
          // 並び順以外の項目が変更されていた場合は、削除か修正にあわせて並び順より後の項目の背景色を変更
          this.changeRowColor(currentTrc, currentLockTrc, edited, false);
          // データ参照エラーコンボの背景色を変更
          // this.changeRefErrorComboColor(currentTrc, false);
        }
      });
    },
    // 装置記録マスタ バグ修正 end
    // del 装置記録マスタ ページネーションを削除 start
    // pageInputEnter(event){
    //   this.formatPage(event);
    //   this.setPage(this.pageInputValue);
    // },
    // formatPage(event){
    //   if(event && event.target.value && event.target.value!="" && event.target.value!=null){
    //     if(event.target.value <= 1){
    //       event.target.value = 1
    //       return this.pageInputValue = 1;
    //     }
    //     if(event.target.value >= this.totalPage){
    //       event.target.value = this.totalPage
    //       return this.pageInputValue = this.totalPage;
    //     }
    //     return this.pageInputValue = parseInt(event.target.value);
    //   }
    //   event.target.value = this.pageInputValue;
    // },
    // setTotalPage(List){
    //   List=List.data&&List.data.length>0?List:{data:[]};
    //   this.totalPage = Math.ceil(List.data.length/this.pageSize) || 1;
    // },
    // Pagination(RecordList){
    //   RecordList = JSON.parse(JSON.stringify(RecordList))
    //   let temp = []
    //   const startItem = this.pageSize*(this.pageNum-1)+1;
    //   const endItem = this.pageSize*this.pageNum;
    //   for (let index = 1; index <= RecordList.data.length; index++) {
    //     if (index >= startItem && index <= endItem){
    //       const element = RecordList.data[index-1];
    //       temp.push(element);
    //     }
    //   }
    //   RecordList.data=temp
    //   return RecordList
    // },
    // setPage(num){
    //   if(num <= 1){
    //     return this.pageNum = 1;
    //   }
    //   if(num >= this.totalPage){
    //     return this.pageNum = this.totalPage;
    //   }
    //   this.pageNum = num;
    // },
    // del 装置記録マスタ ページネーションを削除 end
    // add 性能改善 劉 start
    // データ処理
    generatedGridData: function(pageSize = 30){
      var that = this;

      const columnObject = {};
      that.columns.forEach(column => {
        let name = column.field;
        if ("dummy" !== name){
          columnObject[name] = {};
        } else {
          columnObject[name] = column;
        }
      })
      // eslint-disable-next-line no-undef
      return new kendo.data.DataSource({
        // mod #6251 装置記録マスタの表がMAX30行固定のため無駄な余白ができる 付 start
        pageSize: pageSize,
        // mod #6251 装置記録マスタの表がMAX30行固定のため無駄な余白ができる 付 end
        transport: {
          read: function(e){
            e.success(that.masterRecords.data)
          }
        },
        schema: {
          fields: columnObject
        }
      })
    },
    // add 性能改善 劉 end
    //  条件にマスタ名が設定されている場合は名前で抽出
    searchRecord(RecordList){
      RecordList = JSON.parse(JSON.stringify(RecordList))
      let RecordListData = RecordList.data;
      if (RecordListData && RecordListData.length > 0){
        const parseString = data => (data ? String(data) : "");
        if (this.condition.recordCode != "") {
          const recordCode = parseString(this.condition.recordCode);
          const includesrecordCode = data =>
            parseString(data).indexOf(recordCode) !== -1;
          RecordListData = RecordListData.filter(
            e => includesrecordCode(e["code"])
          );
        }
        if (this.condition.recordMessage != "") {
          const recordMessage = parseString(this.condition.recordMessage);
          const includesRecordMessage = data =>
            parseString(data).indexOf(recordMessage) !== -1;
          RecordListData = RecordListData.filter(
            e => includesRecordMessage(e["machineRecordMessage"])
          );
        }
        if (this.condition.dispFlg != "") {
          const dispFlg = parseString(this.condition.dispFlg);
          const includesDispFlg = data =>
            parseString(data).indexOf(dispFlg) !== -1;
          RecordListData = RecordListData.filter(
            e => includesDispFlg(e["dispFlg"])
          );
        }
        RecordList.data = RecordListData;
      }
      return RecordList
    },
    setMchineRecordColntrolcondition(value){
      this.condition.recordCode = value.recordCode;
      this.condition.recordMessage = value.recordMessage;
      this.condition.dispFlg = value.dispFlg;
      this.pageNum=1;

      // 装置記録マスタ バグ修正 start
      this.dataSourceItems = this.generatedGridData();
      // 装置記録マスタ バグ修正 end
    },

    // グリッドのデータ再表示
    gridDataRefresh() {
      const grid = this.$refs.grid;
      // mod 性能改善 劉 start
      // grid.dataSource = this.masterRecords;
      grid.dataSource = this.generatedGridData();
      // mod 性能改善 劉 end
    },

    // 施設一覧のデータを取得
    findFacilityList() {
      // 日機装ユーザ以外の場合
      if (this.getStateUserAccountInfo.userType !== 1) {
        // ログイン者の担当施設を選択（初期値は自分の所属する施設）
        this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
        // 選択した施設を元にベッド一覧の取得
        this.findList();
        return;
      }
      // apiをコールして施設一覧を取得
      this.facilityList()
        .then(() => {
          // ログイン者の担当施設を選択
          this.facilitylistValue = this.getStateUserAccountInfo.facilityCd;
          // 選択した施設を元にベッド一覧の取得
          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstMachineRecordControlMainComponent.vue', 'findFacilityList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000003].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              // add 全マスタメッセージ調整 王 start
              // message: "指定されたマスタが見つかりません。"
              message: DIALOG_MESSAGES[12000003].message
              // add 全マスタメッセージ調整 王 end
            });
          }
        });
    },
    onOpenFacility(e) {
      // 変更前の値を取得
      this.prevFacilityCd = e.sender._old;
    },
    // 施設を選択時の動作
    onChangeFacility(e) {
      if(this.prevFacilityCd != e.sender._old) {
        this.pageNum = 1;
        // 選択施設の拡張設定を取得
        var newFacilityAdvancedSettings = {};
        let selectedIndex = e.sender.selectedIndex;
        try {
          if (e.sender.dataSource.options.data[selectedIndex].advancedSettings) {
            newFacilityAdvancedSettings = JSON.parse(e.sender.dataSource.options.data[selectedIndex].advancedSettings);
          }
        } catch(error) {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstMachineRecordControlMainComponent.vue', 'onChangeFacility', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          newFacilityAdvancedSettings = {};
        }

        if (!newFacilityAdvancedSettings.func_advcds) {
          newFacilityAdvancedSettings.func_advcds = [];
        }

        const enableHomeDialysis = newFacilityAdvancedSettings.func_advcds.some(
          setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
        );

        if (this.isChanged){
          // 編集時は未保存確認メッセージを出力する
          const newFacilityCd = e.sender._old;
          e.preventDefault();
          this.$ons.notification.confirm({
             // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
              // title: "内容破棄",
              title: DIALOG_MESSAGES[13000004].title,
              // message: "編集内容が破棄されます。</br>よろしいですか？",
              message: messageFormat(DIALOG_MESSAGES[13000004].message),
              // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
            callback: answer => {
              if (answer === 1) {
                // 選択した施設を元に装置一覧の取得
                this.facilitylistValue = newFacilityCd;
                // 選択施設の在宅機能有無を取得
                this.facilityHemoDialysis = enableHomeDialysis;
                this.findList();
              } else {
                // 変更前の施設を設定する
                this.facilitylistValue = this.prevFacilityCd;
              }
            }
          });
        } else {
          // 選択した施設を元に装置一覧の取得
          this.facilitylistValue = e.sender._old;
          // 選択施設の在宅機能有無を取得
          this.facilityHemoDialysis = enableHomeDialysis;
          this.findList();
        }
      }
    },
    // マスタ一覧のデータを取得
    findList() {
      this.setLoadingScreenVisible(true)
      // apiをコールして値を取得
      this.findRecordListByFacilityCdWithSql(this.facilitylistValue)
        .then(response => {
          // カラム情報のJSONが未定義の場合には、ダイアログを出して画面を閉じる
          if (response.data.columns.length === 0) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000001].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message:
              // add 全マスタメッセージ調整 王 start
              // "マスタ定義にカラム情報が登録されていません。<BR>カラム情報を登録してください。",
              DIALOG_MESSAGES[12000001].message,
              // add 全マスタメッセージ調整 王 end
              callback: () => {
                this.cancel();
              }
            });
          }

          // editableをKendoUI用にfunctionオブジェクトに変換
          const toFunction = response.data.columns;
          const myFacility = this.getFacilityList.filter(
            e => e.facilityCd === this.facilitylistValue
          );
          const sysUseSetNo = myFacility.length > 0 ? myFacility[0].systemUseSetting : this.getSystemUseSetting;
          toFunction.forEach(column => {
            // 初期表示時の編集可否を退避
            column.originalEditable = column.editable;
            // 編集可否を関数化
            column.editable = column.editable ? () => true : () => false;
            // 列幅初期化
            column["width"] = column.width ? column.width : "0";
            // 表示設定カラムを、ReMSのみの場合非表示にする
            if (sysUseSetNo === "1" & column.field === "dispFlg") {
              column.hidden = true;
            }
          });
          this.columns = toFunction;

          // 横スクロールバーを表示するために列幅を指定
          this.columns.forEach(column => {
            // 「削除」のプルダウンが改行しない幅に調整
            column.width = this.columnWidth + "em";
            if (column.field === "machineRecordMessage")column.width = "20em";
            if (column.field === "dispFlg")column.width = "20em";
            // del 装置記録マスタ 装置フラグを削除，警報フラグを削除 start
            // if (column.field === "machineFlg")column.width = "20em";
            // if (column.field === "alarmFlg")column.width = "20em";
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng start
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 start
            // if (column.locked && column.dataType === "string" && column.field === "name") {
            //   column.width = typeof column.width == 'string' ? Number(column.width.slice(0,-2)) * 15 : column.width * 15
            // }
            // #8612 ウィンドウサイズの変更で、マスタレイアウトが崩れる。林峻峰 end
            // #9185 最小フォント、mst画面編集文字、テキストボックス幅を超えます linjunfeng end
          });

          // 先頭列ダミー要素追加（並び順列の変更内容が"かぶって"表示されてしまう事象の対応のため）
          this.columns.unshift({
            title: " ",
            field: "dummy",
            hidden: false,
            locked: true,
            editable: () => false,
            width: "10px",
            format: "",
            values: null
          });

          // カラム幅等初期調整
          this.showSortColumn();
          // this.$nextTick(() => {
          //   this.calculateGridHeight();
          //   this.calculateGridWidth();
          //   /* add スクロールの位置を維持 楊 start */
          //   document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollTop = this.lastScrollTop;
          //   document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft = this.lastScrollLeft;
          //   setTimeout(() => {
          //       this.lastScrollTop = 0;
          //       this.lastScrollLeft = 0;
          //     }, 1000);
          //   });
            /* add スクロールの位置を維持 楊 end */
          // 初期データ内容を保存
          this.setComparisonRecordModel();
          // add 性能改善 劉 start
          this.dataSourceItems = null;
          this.dataSourceItems = this.generatedGridData();
          // add 性能改善 劉 end
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstMachineRecordControlMainComponent.vue', 'findList', '指定されたマスタが見つかりません。');
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
             // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "取得失敗",
              title: DIALOG_MESSAGES[12000003].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              // add 全マスタメッセージ調整 王 start
              // message: "指定されたマスタが見つかりません。"
              message: DIALOG_MESSAGES[12000003].message
              // add 全マスタメッセージ調整 王 end
            });
          }
        })
        .finally(() => this.setLoadingScreenVisible(false));
      // カラム定義情報を取得
      this.findColumnInfo();
      this.scrollRestored = false;
    },
    setFilterCondition(condition) {
      this.condition.recordName = condition.recordName;
      this.condition.includeDeleted = condition.includeDeleted;
    },
    async saveRecord() {
      // 共通ローダー:表示開始
      this.setLoadingScreenVisible(true);
      //イベント発生前のスクロールバーの位置を保持
      this.lastScrollTop = document.getElementsByClassName('k-scrollbar k-scrollbar-vertical')[0].scrollTop;
      this.lastScrollLeft = document.getElementsByClassName('k-grid-content k-auto-scrollable')[0].scrollLeft;
      // グリッドでエラーが発生している場合は処理を中断
      if (!this.kendoValidator.validate()) {
        // 共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        return;
      }

      // 新規追加＆未入力のレコードを除外
      const records = this.getMasterRecordList;
      records.data = records.data.filter(
        r => !((!r.operation || r.operation === 1) && !r.edited)
      );
      this.setMasterRecordList(records);

      // 必須エラーをチェック
      const validateMessage = this.validateRequired();
      // コンボで削除済みのレコードが指定されていないかをチェック
      const validateComboMessage = this.validateComboValue();

      let message = "";
      // add 全マスタメッセージ調整 王 start
      if (validateMessage.length !== 0) {
        // message = "以下の列に未入力項目が存在します。" + validateMessage;
        message = DIALOG_MESSAGES[12000005].message + validateMessage;
      }
      if (validateComboMessage.length !== 0) {
        if (message.length !== 0) message = message + "</br>";
        message =
          // message + "以下の列の選択を見直してください。" + validateComboMessage;
          message + DIALOG_MESSAGES[12000006].message + validateComboMessage;
      }
      // add 全マスタメッセージ調整 王 end
      // エラーメッセージは左寄せで表示
      if (message.length !== 0) {
        //共通ローダー：表示終了
        this.setLoadingScreenVisible(false);
        this.$ons.notification.alert({
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
          // title: "チェックエラー",
          title: DIALOG_MESSAGES[12000005].title,
          // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
          message: '<div style="text-align:left;">' + message + "</div>"
        });
        return;
      }

      // 登録用項目一覧
      const keys = [
        // "machineRecordCd",
        "machineRecordMessage",
        "dispFlg",
        // del 装置記録マスタ 装置フラグを削除，警報フラグを削除 start
        // "machineFlg",
        // "alarmFlg"
        // del 装置記録マスタ 装置フラグを削除，警報フラグを削除 end
      ];

      // 編集中のレコードを取得
      const insertRecords = [];
      for (const record of this.getUpdateRecordList) {
         if (record.operation === 2) {
           //更新対象データ
            insertRecords.push(record);
        }
      }

      // 登録日時・更新日時用の現在日時
      const now = moment().format("YYYY-MM-DDTHH:mm:ss.SSSZ");

      const serializedInsertRecords = insertRecords.map(record =>
        JSON.stringify({
          ..._.pick(record, keys),
          machineRecordCd: record["code"],
          facilityCd: this.facilitylistValue,
          regDate: now,
          upDate: now
        })
      );

      //登録更新用レコードの作成
      const editRecord = {
        insertRecord: serializedInsertRecords
      }
      ApiHelper.put(`/master_maintenance/saveMachineRecord/${this.facilitylistValue}`,editRecord)
        .then(response => {
          this.updateResponse = response.data;
          this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新完了",
              title: DIALOG_MESSAGES[12000004].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              // add 全マスタメッセージ調整 王 start
              // message: "マスタ更新が完了しました。"
              message: DIALOG_MESSAGES[12000004].message
              // add 全マスタメッセージ調整 王 end
          });
          this.findList();
        })
        .catch(error => {
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add start
          getErrorMessage('MstMachineRecordControlMainComponent.vue', 'saveRecord', error);
          //FNSI-修正 VUEのエラー場合のログ対応 Sunm add end
          if (error.response.status === 400) {
            this.$ons.notification.alert({
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 start
              // title: "更新失敗",
              title: DIALOG_MESSAGES["00300005"].title,
              // mod #6107 2023/03/10 メッセージボックス全調整 林峻峰 end
              message: error.response.data.errorMessage
            });
          }
        })
        // 共通ローダー：表示終了
        .finally(() => this.setLoadingScreenVisible(false));
      this.scrollRestored = false;
    },
    loadGridData(){
      this.findList();
      // del 装置記録マスタ 装置フラグを削除，警報フラグを削除 start
      // this.pageNum=1;
      // del 装置記録マスタ 装置フラグを削除，警報フラグを削除 end
    },
    refresh() {
      // 他の画面に遷移したときもrefresh()が発生する為、自分の画面のみ処理する
      if (this.selfScreenName === this.$router.currentRoute.name
        && document.getElementsByTagName('ons-alert-dialog').length === 0) {
        if (this.getisChanged()) {
          this.$ons.notification.confirm({
            // title: "内容破棄",
            title: DIALOG_MESSAGES[13000004].title,
            // message: "編集内容が破棄されます。</br>よろしいですか？",
            message: messageFormat(DIALOG_MESSAGES[13000004].message),
            callback: answer => {
              if (answer === 1) {
                //スクロールバーの位置をクリア
                this.clearScrollPosition();
                this.findList();
              }
            },
          });
        }
        else {
          //スクロールバーの位置をクリア
          this.clearScrollPosition();
          this.findList();
        }
      }
    },
    /**
     * @description スクロールバーの位置をクリアする
    */
    clearScrollPosition() {
      this.lastScrollTop = 0;
      this.lastScrollLeft = 0;
    },
    onSave(ev) {
      this.scrollRestored = false;
      //イベント発生前のスクロールバーの位置を保持
      const scrollTop = ev.sender.content[0].lastChild.scrollTop;
      const scrollLeft = ev.sender.content[0].firstChild.scrollLeft;
      this.lastScrollTop = scrollTop;
      this.lastScrollLeft = scrollLeft;
      this.editFlg = true;
      this.editingFlg = false;
      this.edit({editRecord: ev.model, isSortMode: this.isSortMode});
      ev.sender.refresh();
      if (ev.model.operation === 1) {
        ev.model.edited = true;
      }
      // 状態に合わせて背景色を変更
      this.editBackgroundColor();
    },
    onBeforeEdit(e) {
      if (this.isMobileDevice && !this.allowEdit) {
        /* NOTE:
         * モバイル系は、スワイプ・フリック操作で入力パッドが表示される。
         * そのため、スクロール操作が損なわれるので、閲覧モードのときは
         * 後続のイベントを発火させないように制御する。
         */
        e.preventDefault();
        return;
      }
      this.editStart(e);
    },
    observeZoomChange() {
      const target = document.body;
      this.zoomObserver = new ResizeObserver(() => {
        this.$nextTick(() => {
          const rowHeight = this.$el.querySelector('.k-grid-content tr')?.clientHeight || 30;
          const gridHeight = this.$refs.grid?.$el?.offsetHeight || 900;
          const newPageSize = Math.floor(gridHeight / rowHeight);

          const currentPageSize = this.dataSourceItems?.pageSize();
          if (newPageSize !== currentPageSize) {
            this.dataSourceItems = this.generatedGridData(newPageSize);
            this.$refs.grid?.kendoWidget?.().resize();
          }
        });
      });
      this.zoomObserver.observe(target);
    },
  },
  created() {
    this.setLoadingScreenVisible(true);
    this.facilityHemoDialysis = this.getAdvancedSettings.func_advcds.some(
      setting => setting.func_advcd === ADVANCED_SETTINGS.HOME_DIALYSIS
    );
    // apiをコールして施設一覧を取得
    // add マスタ一覧 1･施設切替を可能とする 王 start
    // this.findFacilityList();
    this.facilitylistValue = this.getFacilitySwitch
    this.findList();
    // add マスタ一覧 1･施設切替を可能とする 王 end
    this.calculateColumnsWidth();
    // mod 装置記録マスタ 装置フラグを削除，警報フラグを削除 start
    // this.loadGridData();
    this.setCondition(this.condition);
    // mod 装置記録マスタ 装置フラグを削除，警報フラグを削除 end
    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$on("refresh", this.refresh);
    EventBus.$on("setMchineRecordColntrolcondition", this.setMchineRecordColntrolcondition);
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      // this.calculateGridWidth();
    });
    //スクロールバーの位置が再描画の前後で変化している場合、スクロールバーの位置を制御するフラグを更新する
    if(this.lastScrollTop != document.getElementsByClassName('k-scrollbar k-scrollbar-vertical')[0].scrollTop){
      this.scrollRestored = false;
    }
  },

  mounted() {
    this.$nextTick(() => {
      this.calculateColumnsWidth();
      this.calculateGridHeight();
      // this.calculateGridWidth();
      this.observeZoomChange();
    });
    EventBus.$on("clearScrollPosition", this.clearScrollPosition);
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    if (this.zoomObserver) {
      this.zoomObserver.disconnect();
      this.zoomObserver = null;
    }
    EventBus.$off("onCloseMasterEditModal", this.onCloseMasterEditModal);
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("setMchineRecordColntrolcondition", this.setMchineRecordColntrolcondition);
    EventBus.$off("clearScrollPosition", this.clearScrollPosition);
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<!-- 個別スタイル定義 -->
<style scoped>
.right {
  text-align: right;
}
.header-btn-area {
  height: auto;
  padding: 0.1em 0.1em 0.1em 0.1em;
}
#grid-footer {
  margin: 0;
  padding: 5px;
  bottom: 0;
  position: absolute;
  width: inherit;
}
.kendo-grid-toolbar-style {
  --height: 200px;
  height: var(--height);
  border-bottom: none;
}
/*del 装置記録マスタ ページネーションを削除 start*/
.toolbar-btn {
 padding: 0.2em 1em 0em 1em;
 line-height: 2em;
 width: auto;
}
.csv-btn {
 margin-right: 1em;
}
/*del 装置記録マスタ ページネーションを削除 start*/
.k-grid-toolbar {
  padding: 0.1em 0.3em;
}
/*del 装置記録マスタ ページネーションを削除 start*/
/* .kendo-grid-toolbar-style >>> .k-tooltip.k-tooltip-validation { */
/*  width: auto;*/
/*}
/*del 装置記録マスタ ページネーションを削除 start*/

.kendo-grid-toolbar-style
  >>> .k-grid
  tr:nth-child(n + 3):last-child
  .k-tooltip.k-tooltip-validation
  .k-callout {
  border-bottom: 0;
  border-top: 6px solid #000;
  top: unset;
  bottom: -6px;
}

.kendo-grid-toolbar-style
  >>> .k-grid
  tr:nth-child(n + 3):last-child
  .k-tooltip.k-tooltip-validation {
  bottom: 38px;
}

.kendo-grid-toolbar-style >>> .k-edit-cell {
  position: relative;
  overflow: visible;
}

.kendo-grid-toolbar-style >>> .k-grid-content > .k-selectable {
  box-shadow: 1px 0px 0px 0px white;
  border-right: 1px solid transparent;
}

.kendo-grid-toolbar-style >>> .k-grid-header-locked > table {
  border-right-width: 0px;
}

.kendo-grid-toolbar-style >>> .k-grid-header-locked {
  border-right: 1px solid var(--ntss-list-border-color) !important;
}

.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  z-index: 1;
  box-shadow: 1px 0px 0px 0px var(--ntss-border-color) !important;
}

.kendo-grid-toolbar-style >>> .k-grid-header-locked > table {
  border-right-width: 0px;
}

.kendo-grid-toolbar-style >>> .k-grid-content-locked > .k-selectable {
  border-right-width: 0px;
}
.paginationClass {
  margin-left: 0.5em;
  margin-right: 0.5em;
}
.disableATag {
  text-decoration: none;
  pointer-events: none;
  color: #000;
}
.pageInput >>> input{
  height: 100%;
}
.pageInput >>> input::-webkit-outer-spin-button,
.pageInput >>> input::-webkit-inner-spin-button {
  -webkit-appearance: none;
}
.pageInput >>> input[type="number"]{
  -moz-appearance: textfield;
}
.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}
</style>
