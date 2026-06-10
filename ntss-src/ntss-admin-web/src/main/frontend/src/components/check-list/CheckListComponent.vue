/**
 * チェックリスト画面
 */
<template>
  <div class="main-content-area master-maintenance-page" :style="{'height': mainHeight + 'px'}">
    <div class="check-list-head-content"></div>
    <div class="check-list-main-content">
      <!-- 患者一覧のグリッド -->
      <div :style="[condition.isShowUsageGuide ? { 'height':kendoGridHeight + 'px', 'overflow': 'auto', 'position': 'relative' } : {}]" class="grid-area">
        <kendo-grid
          id="kendo"
                    ref="grid"
                    :data-source="listDataSource"
                    :data-bound="gridSetting"
                    :resizable="true"
                    :selectable='"cell"'
                    :change="onCellClick"
                    :sortable="{ compare: compareByField }"
                    :height="kendoGridHeight"
                    :sort="sortHandler"
                    :columnResize="columnResizeEvevt"
                    class="ntss-list check-list-main-content-list">
          <kendo-grid-column v-for="column in checkGridColumnsHeader" :key="column.field"
                            :field="column.field"
                            :locked="lockFlg"
                            :title="$sanitize(column.title)"
                            :attributes="{'class':'#= setDataClass({rstDialysisState})#'}"
                            :width="column.width[selectedFontSize]">
          </kendo-grid-column>
          <kendo-grid-column v-for="column in getChecklistColumn" :key="column.field"
                            :hidden="column.hidden"
                            :field="column.field"
                            :template="column.template"
                            :title="$sanitize(column.title)"
                            :attributes="column.field === 'hospPatId' ? { class: 'hosp-pat-id-body' } : {}"
                            :width="column.width[selectedFontSize]">
          </kendo-grid-column>
        </kendo-grid>
      </div>
        <div v-if="condition.isShowUsageGuide" id="area_usage_guide">
        <div class="usage-guide-div">
          <div class="usage-guide-element" style="background-color: white; border: silver solid 1px;"></div>
          ：予定
        </div>
        <div class="usage-guide-div">
          <div class="usage-guide-element" style="background-color: #42CB92; border: #42CB92 solid 1px;"></div>
          ：前体重測定済
        </div>
        <div class="usage-guide-div">
          <div class="usage-guide-element" style="background-color: #2CA06F; border: #2CA06F solid 1px;"></div>
          ：治療中
        </div>
        <div class="usage-guide-div">
          <div class="usage-guide-element" style="background-color: #557769; border: #557769 solid 1px;"></div>
          ：治療終了(未確定)
        </div>
        <div class="usage-guide-div">
          <div class="usage-guide-element" style="background-color: #808080; border: #808080 solid 1px;"></div>
          ：確定実績
        </div>
        <div class="usage-guide-div">
          <!-- mod FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start -->
          <!-- <div style="color: purple">患者名</div> -->
          <div class="pat-name-in-hospital">患者名</div>
          <!-- mod FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end -->
            <div>：入院患者</div>
        </div>
        <div style="display: flex;">
          <div>患者名</div>
          ：外来患者
        </div>
      </div>
    </div>
  </div>
</template>

<script>
// add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
import Kendo from "@progress/kendo-ui";
// add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
import { mapGetters, mapActions, mapMutations } from "vuex";
import { EventBus } from "@/eventBus.js";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import PatHeaderControlMixin from "@/components/common/PatHeadControlMixin";
import moment from "moment";
import { dialysisState } from "@/constants/weightDefine";
import { getCurrentFunctionCd } from "@/router/routing-helper";
//FNSI-修正 左サイドバー切り替えする時、画面の右スクロールバーの表示がおかしいについての修正 xugj add start
import $$ from "jquery";
//FNSI-修正 左サイドバー切り替えする時、画面の右スクロールバーの表示がおかしいについての修正 xugj add end
// add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
import store from "@/stores";
// add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
import { CHECK_LIST_FORCE_SIGNOUT } from "@/constants/facilitySetting";
import { initForceSignOutFlag } from "@/functions/common/CommonFunctions";
import { addPatNameSortToList, sortableCompare } from "@/functions/SortFunctions";

// ソートキー変換用のマップ
const SORT_KEY_MAP = {
  viewTreatDate: "treatDate", // 治療日 ※viewTreatDateは"MM/DD(曜日)" 形式のためtreatDateでソートする
};

export default {
  props: {},
  components: {},
  mixins: [NextTransitionMixin, MasterMaintenanceMixin, PatHeaderControlMixin],
  data() {
    return {
      androidFlg: false,
      iosFlg: false,
      sendOrdNo: null,
      kendoMode: false,
      kendoGridToolbarHeight: 500,
      kendoGridHeight: 300,
      mainHeight: 300,
      // mod FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      // sort: {
      //   key: "",
      //   isAsc: true
      // },
      // mod FNSI-redmine_#3907_コンソールエラーを修正 周 start
      // listDataSource: null,
      listDataSource: [],
      getOrdMainList: [],
      // mod FNSI-redmine_#3907_コンソールエラーを修正 周 end
      // mod FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
      autoReload: 0,
      selfScreenName: "",
      // add #11285 機能帳票の印刷情報対応② 高 start
      bedCdListString: "",
      // add #11285 機能帳票の印刷情報対応② 高 end
      currentScrollTop: 0,
      currentScrollLeft: 0,
      currentSort: null,
      lockFlg:true
    };
  },
  computed: {
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth"
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo"
    }),
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
    // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
    ...mapGetters("check-list/medimodal", {
      getSelectOrdMainMedimodal: "getSelectOrdMain"
    }),
    ...mapGetters("check-list/modal", {
      getSelectOrdMainModal: "getSelectOrdMain",
    }),
    // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
    // add FNSI-redmine_#3908_ソート方法の改善 周 start
    selectedFontSize: {
      get() {
        return this.getFontSize;
      }
    },
    // add FNSI-redmine_#3908_ソート方法の改善 周 end
    /**
     * 現在の表示グリッドから患者選択リストを取得する
     */
    CheckListToPatList() {
      let ret = [];

      // gridの全行取得
      // FNSI-チェックリスト画面表示を修正 周 mod start
      // const view = this.listDataSource;
      const view = this.listDataSource._view;
      // FNSI-チェックリスト画面表示を修正 周 mod end
      view.forEach(function(value, index, array) {
        // 治療実績判定
        const info = array[index];
        if (info.ordNo !== null && info.ordNo !== undefined) {
          let list = {
            pat_id: info.patId,
            pat_last_name: info.patLastName,
            pat_first_name: info.patFirstName,
            ord_no: info.ordNo,
            kur_name: info.kurName,
            bed_name: info.bedName,
            is_same: info.isSame,
            in_out_class: info.inOutClass,
            ...info
          };
          ret.push(list);
        }
      });
      return ret;
    },
    heightStyles() {
      // main部の高さをCSS変数を利用して書き換え
      return { "--height": `${this.kendoGridToolbarHeight}px` };
    },
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("check-list/list", [
      "getCondition",
      "getIsDisplayTreatingMode",
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      "getIsAsynComplete",
      "getChecklistSetting",
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
      "getMstKurSelector",
      "getMstBedGroupList",
      "getChecklistColumn",
      "getChecklistColumnHeader",
      // "getOrdMainList",
      "isDispTreatData",
      "getIsDataLoading",
      "getIsDataLoadCancel",
      "getReloadInterval"
    ]),
    // add 画面印刷プレビューと印刷の実現 黄 start
    ...mapGetters("pat-info", ["searchedPatList", "selectedPatId"]),
    // add 画面印刷プレビューと印刷の実現 黄 end
    condition: {
      get() {
        return this.getCondition;
      }
    },
    ordMainList() {
      // storeからデータを取得
      let dataList = [];

      if (this.getOrdMainList) {
        /* modify by chamaojia 2024-04-24 [10456] data processing has been completed in the backend --start */
        // // 表示画面判定
        // if (this.getIsDisplayTreatingMode) {
        //   // 治療状況
        //   dataList = this.getOrdMainList.map(rec => {
        //     let ret = null;
        //     if (this.isDispTreatData(rec)) {
        //       ret = rec;
        //     }
        //     return ret;
        //   });
        // } else {
        //   // 予定日
        //   dataList = this.getOrdMainList;
        // }
        dataList = this.getOrdMainList;
        /* modify by chamaojia 2024-04-24 [10456] data processing has been completed in the backend --end */
      }

      // リストをソート
      const sortList = dataList
        .filter(data => data !== null)
        .sort(function(a, b) {
          const aOrdNo = a.ordNo === null ? 0 : a.ordNo;
          const aBedName = a.bedName === null ? "" : a.bedName;
          const aRstDialysisState =
            a.rstDialysisState === null ? "0" : a.rstDialysisState;
          const aPatName = a.patName === null ? "" : a.patName;
          const bOrdNo = b.ordNo === null ? 0 : b.ordNo;
          const bBedName = b.bedName === null ? "" : b.bedName;
          const bRstDialysisState =
            b.rstDialysisState === null ? "0" : b.rstDialysisState;
          const bPatName = b.patName === null ? "" : b.patName;

          let ret =
            aBedName < bBedName
              ? -1
              : aBedName > bBedName
              ? 1
              : aRstDialysisState < bRstDialysisState
              ? -1
              : aRstDialysisState > bRstDialysisState
              ? 1
              : aPatName < bPatName
              ? -1
              : aPatName > bPatName
              ? 1
              : aOrdNo < bOrdNo
              ? -1
              : 1;
          return ret;
        });

      return sortList;
    },
    checkGridColumns() {
      return this.getChecklistColumn;
    },
    checkGridColumnsHeader() {
      return this.getChecklistColumnHeader;
    },
    // mod FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
    // sortedItems() {
    //   const list = this.ordMainList.slice(); // ソート時でstate自体の順序を書き換えないため
    //   if (this.sort.key) {
    //     list.sort((a, b) => {
    //       a = a[this.sort.key];
    //       b = b[this.sort.key];

    //       let sortItem1 = 0;
    //       let sortItem2 = 0;

    //       if (a === b) {
    //         sortItem1 = 0;
    //       } else if (a > b) {
    //         sortItem1 = 1;
    //       } else {
    //         sortItem1 = -1;
    //       }
    //       if (this.sort.isAsc) {
    //         sortItem2 = 1;
    //       } else {
    //         sortItem2 = -1;
    //       }
    //       return sortItem1 * sortItem2;
    //     });
    //   }
    //   return list;
    // },
    // listDataSource() {
    //   // 選択状態最更新
    //   const retList = this.filteredScheduleList(this.sortedItems);
    //   retList.map(e => e.setDataClass = this.dialysisStateBackColor);
    //   return retList;
    // }
    getListDataSource() {
      const retList = this.filteredScheduleList(this.ordMainList.slice());
      retList.map(e => e.setDataClass = this.dialysisStateBackColor);
      return retList;
    }
    // mod FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
  },
  methods: {
    ...mapActions("multi-modal", [
      "showChecklist",
      "showMedicine",
      "showSchedule"
    ]),
    ...mapActions("check-list/list", [
      "setCondition",
      "changeIsDisplayTreatingMode",
      "getCheckListSetting",
      "setStatusGridColumn",
      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
      // "getOrderMainListTreatment",
      // "getOrderMainListByTreatDate",
      // "getOrderMainListChiryouchuu",
      // "getOrderMainListShiteibi",
      "getRequestGetOrdCheckListAll",
      "getRequestGetOrdMainChiryouchuu",
      "getRequestGetOrdMainShiteibi",
      "setIsAsynComplete",
      // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
      // add FNSI-redmine_#3908_ソート方法の改善 周 start
      "setChecklistColumnWidth",
      "setChecklistColumnHeaderWidth",
      // add FNSI-redmine_#3908_ソート方法の改善 周 end
      "setChecklistColumn",
      "getChecklistName",
      "setIsDataLoadCancel",
      "setIsDataLoading",
      "fetchReloadInterval",
      "setReloadInterval"
    ]),
    ...mapActions("check-list/modal", ["setSelectCheckList"]),
    ...mapActions("check-list/medimodal", ["setSelectOrdNo"]),
    ...mapActions("send-condition/scale", {
      sendConditionSetSelectOrdNo: "setSelectOrdNo"
    }),
    ...mapActions("treatment-record/common", {
      //add FNSI修正 治療記録画面バッグ 房 start
      setOrd: "setOrd",
      //add FNSI修正 治療記録画面バッグ 房 end
      setTreatmentRecordOrdNo: "setOrdNo",
      setOrdNoForSideBarRecord: "setOrdNoForSideBarRecord"
    }),
    ...mapActions("schedule-assignment/modal", {
      scheduleAssignmentSetSelectOrdNo: "setSelectOrdNo"
    }),
    ...mapMutations("pat-info", {
      updateTreatmentPatList: "updateTreatmentPatList",
      setSrcFuncName: "setSrcFuncName"
    }),
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount"
    }),
    /**
     * 列ヘッダクリック時にソート順を設定
     * @param {*} e
     */
    sortHandler(e) {
      this.currentSort = e.sort;
    },
    /**
     * 列ヘッダクリック時のソート処理
     * @param {*} a
     * @param {*} b
     */
    compareByField(a, b) {
      // ソートなしはreturn
      if (!this.currentSort || !this.currentSort.field) return;

      const sortField = SORT_KEY_MAP[this.currentSort.field] || this.currentSort.field;

      // 投与薬剤・チェックリスト列の場合は独自ソート
      if (sortField === "medicine" || sortField.startsWith("checklist_")) {
        const countField = sortField === "medicine" ? "medi_count" : `${sortField}_count`
        const chkField = sortField === "medicine" ? "medi_chkcount" : `${sortField}_chkcount`

        // - 第1ソートキー：分母－分子（未実施数）降順
        // - 第2ソートキー：分母　降順
        // - ↑を昇順ソートとする。(未実施の頭出し)
        const diffA = a[countField] - a[chkField];
        const diffB = b[countField] - b[chkField];
        return (diffB - diffA) || (b[countField] - a[countField]);
      }

      // 投与薬剤・チェックリスト列以外は共通関数でソート
      return sortableCompare(a, b, sortField, true);
    },
    /**
     * フィルタリング処理
     */
    filteredScheduleList(dataSource) {
      if (dataSource === null) {
        return null;
      }

      return dataSource
        .filter(dat => {
          let isFilteringKur = true;
          // 指定日の場合
          if (this.getIsDisplayTreatingMode === false) {
            // クールフィルター作成
            if (`${this.condition.kurCd}` !== "-1") {
              isFilteringKur =
                dat.kurCd !== null &&
                `${dat.kurCd}` === `${this.condition.kurCd}`;
            }
          }

          // ベッドグループフィルター作成
          let isFilteringBed = true;
          if (this.condition.bedGroupCd > -1) {
            isFilteringBed = false;
            let bedGroup = this.getMstBedGroupList.find(bg => bg.roomBedGroupCd === this.condition.bedGroupCd);
            if (bedGroup !== null && bedGroup.bedList)
            {
              for (const bedCd of bedGroup.bedList) {
                if (dat.bedCd === bedCd) {
                  isFilteringBed = true;
                  break;
                }
              }
            }
          }
          const retValue = isFilteringKur && isFilteringBed;

          return retValue;
        })
        .slice();
    },

    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      const wh = this.windowHeight;
      const hc = Array.prototype.slice
        .call(document.getElementsByClassName("header"))
        .shift();
      const hh = hc ? hc.clientHeight : 0;
      const fmh =
        (this.isDispMenu === 1
          ? document.getElementById("footer-menu").clientHeight
          : 0) + 5;
      this.kendoGridToolbarHeight = wh - hh - fmh - 3;
      this.mainHeight = wh - hh - fmh;
      this.kendoGridToolbarHeight =
        this.kendoGridToolbarHeight < 340
          ? this.mainHeight
          : this.kendoGridToolbarHeight;

      //const gfh = document.getElementById("grid-footer").clientHeight;
      //this.kendoGridHeight = this.kendoGridToolbarHeight - (gfh + 40);
      const guideClientHeight = document.getElementById("area_usage_guide")
        ? document.getElementById("area_usage_guide").clientHeight
        : 0;
      this.kendoGridHeight = this.kendoGridToolbarHeight - guideClientHeight;

      //FNSI-修正 左サイドバー切り替えする時、画面の右スクロールバーの表示がおかしいについての修正 xugj add start
      const gridWidget = $$('#kendo').data('kendoGrid');
      gridWidget.resize($$('.k-grid-header'));
      gridWidget.resize($$('.k-grid-content'));
      //FNSI-修正 左サイドバー切り替えする時、画面の右スクロールバーの表示がおかしいについての修正 xugj add end
      // add bug 6697 修正 chen start
      this.$nextTick(() => {
        const headerHeight = document.getElementsByClassName("k-grid-header")[0].offsetHeight + 2;
        const gridContent = document.getElementsByClassName("k-grid-content")[0];
        const isHorizontalScroll = gridContent.scrollWidth > gridContent.clientWidth;
        let lockRowHeight = this.kendoGridHeight - headerHeight;
        // PCでの表示時のみ、スクロールバー分の不要な高さが発生する為、高さの調整を行う
        if (!this.androidFlg && !this.iosFlg && isHorizontalScroll) {
          lockRowHeight -= 17;
        }
        const lockedRows = document.getElementsByClassName("k-grid-content-locked");
        if (lockedRows && lockedRows.length > 0) {
          lockedRows[0].style.height = lockRowHeight + "px";
        }
        if  (gridContent) {
          // スクロール位置復帰
          gridContent.scrollTop = this.currentScrollTop;
          gridContent.scrollLeft = this.currentScrollLeft;
        }
      });
      // add bug 6697 修正 chen end
    },
    // 抽出条件変更イベント
    setFilterCondition(chgFlg) {
      // 次患者または治療日が変更された場合
      if (chgFlg) {
        // スケジュール取得
        this.dataLoad();
      } else {
        this.filteredCheckList();
        // add FNSI-横展開 表示条件のサインイン内保持_チェックリスト機能分 周 start
        this.listDataSource = new Kendo.data.DataSource({
          data: this.getListDataSource,
          sort: this.currentSort ? this.currentSort : null // ソート条件保持
        });
        // add FNSI-横展開 表示条件のサインイン内保持_チェックリスト機能分 周 end
      }
    },
    // データ更新(チェックリスト登録後, 投与薬剤登録後, 治療中/指定日切替)
    setCheckList(autoRefreshFlag) {
      if (this.getIsDataLoading) {
        return;
      }
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      this.endPolling();
      this.setIsDataLoading(true);
      this.setLoadingScreenVisible(true);
      this.setIsDataLoadCancel(true);
      this.dataLoad(autoRefreshFlag);
      this.setLoadingScreenVisible(false);
      this.startPolling();
    },
    async dataLoad(autoRefreshFlag) {
      // スクロール位置を保存
      const gridContent = document.getElementsByClassName("k-grid-content")[0];
      this.currentScrollTop = gridContent.scrollTop;
      this.currentScrollLeft = gridContent.scrollLeft;
      // FNSI-修正 #5407 xie add start
      this.setLoadingScreenVisible(true);
      // FNSI-修正 #5407 xie add end
      // 表示モード[true:治療中, false:指定日]
      const displayModeIsDialysis = this.getIsDisplayTreatingMode;

      // チェックリストマスタ設定情報取得
      await this.getCheckListSetting({facilityCd: this.getFacilityCd, autoRefreshFlag});
      this.fetchReloadInterval(autoRefreshFlag).then(r => {
        this.setReloadInterval(r.data);
      });
      // チェックリストグリッド列作成
      await this.setStatusGridColumn();
      // 治療中の場合
      if (displayModeIsDialysis) {
        // odr_mainの情報取得(指定日)
        // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
        // await this.getOrderMainListTreatment({
        await this.getOrderMainListChiryouchuu({
        // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
          facilityCd: this.getFacilityCd,
          nextPat: this.condition.nextPat,
          autoRefreshFlag
        });
        // 検索条件で表示内容を更新
        this.filteredCheckList();
      } else {
        // 指定日の場合
        // odr_mainの情報取得(指定日)
        // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 start
        // await this.getOrderMainListByTreatDate({
        await this.getOrderMainListShiteibi({
        // mod FNSI-チェックリスト仕様変更対応#401、#439_チェックリスト機能分。 周 end
          facilityCd: this.getFacilityCd,
          treatDate: this.condition.treatDate.replace(/-/g, ""),
          autoRefreshFlag
        });
        // 検索条件で表示内容を更新
        this.filteredCheckList();
      }
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      this.listDataSource = new Kendo.data.DataSource({
        data: this.getListDataSource,
        sort: this.currentSort ? this.currentSort : null // ソート条件保持
      });
      this.calculateGridHeight();
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end

      // 読み込み処理が走ってしまった時点でフラグを落とす
      this.setIsDataLoading(false);
      this.setLoadingScreenVisible(false);
    },

    /**
     * 治療中
     * ord_main情報を取得
     * facilityCd: 施設コード
     * nextPat: 次患者[0:次クール, 1:当日, 2:次クール以降]
     */
    async getOrderMainListChiryouchuu(parm) {
      // ord_main情報取得
      const response = await this.getRequestGetOrdMainChiryouchuu(parm);

      // 取得データの変換
      let dataList = response.data.copyWithin(0, 0);
      dataList.forEach(async (value, index, array) => {
        // 治療日を作成
        let tDate =
          array[index].treatDate.substr(4, 2) +
          "/" +
          array[index].treatDate.substr(6, 2);
        let weekList = ["", "月", "火", "水", "木", "金", "土", "日"];
        let tWeek = "(" + weekList[array[index].treatWeek] + ")";
        array[index].viewTreatDate = tDate + tWeek;

        // 登録されていない場合は条件送信前扱い
        if (
          array[index].rstDialysisState === "" ||
          array[index].rstDialysisState === null
        ) {
          array[index].rstDialysisState = "0";
        }

        // 指示：投与薬剤情報を取得
        if (array[index].indMediInfo !== null) {
          array[index].indMediInfo = JSON.parse(array[index].indMediInfo);
        }
        // 実績：投与薬剤情報を取得
        if (array[index].rstMediInfo !== null) {
          array[index].rstMediInfo = JSON.parse(array[index].rstMediInfo);
        }

        // 条件送信前の場合「指示：投与薬剤情報」
        // 条件送信後の場合「実績：投与薬剤情報」
        array[index].mediInfo =
          array[index].rstDialysisState === "0" ?
            array[index].indMediInfo :
            array[index].rstMediInfo;

        // 投与薬剤項目数
        let mediChkCount = 0;
        // 投与薬剤実施済み項目数
        let mediOnChkCount = 0;

        if (array[index].mediInfo !== null) {
          // 投与薬剤項目数セット
          mediChkCount = array[index].mediInfo.length;
          // 投与薬剤実施済み項目数セット
          mediOnChkCount = array[index].mediInfo.filter(item => item.effect_flg == 1).length;
        }

        array[index].medi_count = mediChkCount;
        array[index].medi_chkcount = mediOnChkCount;
        array[index].medicine = mediOnChkCount + "/" + mediChkCount;
      });

      // システム共通患者名ソート用(フリガナ優先文字列)を追加
      dataList = addPatNameSortToList(dataList);

      // 取得したord_main情報をセット
      this.setIsDataLoadCancel(false);
      this.getOrdMainList = dataList;

      // チェックリスト実績を取得
      await this.getOrderCheckListByOrdNo(parm.autoRefreshFlag);
    },
    /**
     * 治療日指定
     * ord_main情報を取得
     * facilityCd: 施設コード
     */
    async getOrderMainListShiteibi(parm) {
      // ord_main情報取得
      const response = await this.getRequestGetOrdMainShiteibi(parm);

      // 取得データの変換
      let dataList = response.data.copyWithin(0, 0);
      dataList.forEach(async (value, index, array) => {
        // 治療日を作成
        let tDate =
          array[index].treatDate.substr(4, 2) +
          "/" +
          array[index].treatDate.substr(6, 2);
        let weekList = ["", "月", "火", "水", "木", "金", "土", "日"];
        let tWeek = "(" + weekList[array[index].treatWeek] + ")";
        array[index].viewTreatDate = tDate + tWeek;

        // 登録されていない場合は条件送信前扱い
        if (
          array[index].rstDialysisState === "" ||
          array[index].rstDialysisState === null
        ) {
          array[index].rstDialysisState = "0";
        }

        // 指示：投与薬剤情報を取得
        if (array[index].indMediInfo !== null) {
          array[index].indMediInfo = JSON.parse(array[index].indMediInfo);
        }
        // 実績：投与薬剤情報を取得
        if (array[index].rstMediInfo !== null) {
          array[index].rstMediInfo = JSON.parse(array[index].rstMediInfo);
        }

        // 条件送信前の場合「指示：投与薬剤情報」
        // 条件送信後の場合「実績：投与薬剤情報」
        array[index].mediInfo =
          array[index].rstDialysisState === "0" ?
            array[index].indMediInfo :
            array[index].rstMediInfo;

        // 投与薬剤項目数
        let mediChkCount = 0;
        // 投与薬剤実施済み項目数
        let mediOnChkCount = 0;

        if (array[index].mediInfo !== null) {
          // 投与薬剤項目数セット
          mediChkCount = array[index].mediInfo.length;
          // 投与薬剤実施済み項目数セット
          mediOnChkCount = array[index].mediInfo.filter(item => item.effect_flg == 1).length;
        }

        array[index].medi_count = mediChkCount;
        array[index].medi_chkcount = mediOnChkCount;
        array[index].medicine = mediOnChkCount + "/" + mediChkCount;
      });

      // システム共通患者名ソート用(フリガナ優先文字列)を追加
      dataList = addPatNameSortToList(dataList);

      // 取得したord_main情報をセット
      this.setIsDataLoadCancel(false);
      this.getOrdMainList = dataList;

      // チェックリスト実績を取得
      await this.getOrderCheckListByOrdNo(parm.autoRefreshFlag);
    },
    /**
     * チェックリスト実績情報を取得
     */
    async getOrderCheckListByOrdNo(autoRefreshFlag) {
      let listChecklistResponse = [];
      let listChgRecord = [];
      let list = this.getOrdMainList;
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      this.setIsAsynComplete(false);
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end

      if (this.getIsDataLoadCancel) {
        // ページ切り替えなどでデータ読み込みの中断があった
        this.setIsDataLoadCancel(false);
      } else {
        listChgRecord = listChgRecord.concat(list);
        let params = list.map(item=>{
          return {
            ordNo: item.ordNo,
            rstDialysisState: item.rstDialysisState
          }
        })
        // console.log(params);
        await this.getRequestGetOrdCheckListAll({params, autoRefreshFlag}).then(checklistResponse=>{
          listChecklistResponse = listChecklistResponse.concat(checklistResponse.data);
        });
      }

      // console.log(listChecklistResponse);

      // チェックリスト
      let checkSettings = this.getChecklistSetting.checklistSettings;
      listChecklistResponse.forEach((checklistResponse, index) => {
        const chgRecord = listChgRecord[index];
        let ordChecklist = checklistResponse;

        for (let checkSetting of checkSettings) {
          // チェック表示項目数
          let checkString = "checklist_" + checkSetting.list_cd.toString();
          // チェック済み項目数
          let checkStringChecked = checkString + "_chkcount";
          chgRecord[checkStringChecked] = ordChecklist[checkSetting.list_cd][0];
          // チェック項目数
          let checkStringTotal = checkString + "_count";
          chgRecord[checkStringTotal] = ordChecklist[checkSetting.list_cd][1];

          chgRecord[checkString] =
            ordChecklist[checkSetting.list_cd][0] +
            "/" +
            ordChecklist[checkSetting.list_cd][1];
        }

        // 実績にチェックリストコードが登録されている場合
        // mod FNSI-４００エラー対応 周 start
        // if (ordChecklist[0][0] !== null) {
        //   // チェックリストコード
        //   chgRecord.checklistCd = ordChecklist[0][0];
        // }
        chgRecord.checklistCd = ordChecklist[0][0] === null ? 0 : ordChecklist[0][0];
        // mod FNSI-４００エラー対応 周 end

        if (this.getIsDataLoadCancel) {
          // ページ切り替えなどでデータ読み込みの中断があった
          return;
        }

        // データ更新
        list.splice(index, 1, chgRecord);

        // 取得したord_main情報をセット
        this.getOrdMainList = list;
      });
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
      this.setIsAsynComplete(true);
      // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
    },
    /**
     * ベッド名の背景色変更
     */
    dialysisStateBackColor(dataItem) {
      if (
        dataItem.rstDialysisState == dialysisState.afterSendCondition ||
        dataItem.rstDialysisState == dialysisState.checkedSendCondition
      ) {
        // 背景色変更
        // 条件送信済み
        return "td-send-condition";
      } else if (dataItem.rstDialysisState == dialysisState.dialysis) {
        // 治療中
        return "td-dialysis";
      } else if (
        dataItem.rstDialysisState == dialysisState.afterDialysis ||
        dataItem.rstDialysisState == dialysisState.afterWeight
      ) {
        // 治療終了
        return "td-after-dialysis";
      } else if (dataItem.rstDialysisState == dialysisState.afterPastRecord) {
        // 実績確定
        return "td-after-record";
      }

      return "td-not-send-condition";
    },
    /**
     * 進捗バー表示スタイル
     */
    progressBackgroundColor(column, dataItem) {
      if (column.field === "medicine") {
        // 実施済み項目の幅
        let width = dataItem.medi_count
          ? (100 / dataItem.medi_count) * dataItem.medi_chkcount
          : 0;
        let color = "var(--check-list-progress-incomplete)";

        // 実施済み項目がある場合
        if (dataItem.medi_chkcount > 0) {
          // 全て実施済みの場合
          if (dataItem.medi_count === dataItem.medi_chkcount) {
            color = "var(--check-list-progress-complete)";
          }
          return `background: linear-gradient(to right,${color} ${width}%, rgba(0,0,0,0) 0%)`;
        }
      } else if (column.field.startsWith("checklist_")) {
        const strCheck = column.field;
        const strCount = strCheck + "_count";
        const strCheckCount = strCheck + "_chkcount";

        // 実施済み項目の幅
        let width = (100 / dataItem[strCount]) * dataItem[strCheckCount];
        let color = "var(--check-list-progress-incomplete)";

        // チェック済み項目がある場合
        if (dataItem[strCheckCount] > 0) {
          // 全てチェック済みの場合
          if (dataItem[strCount] === dataItem[strCheckCount]) {
            color = "var(--check-list-progress-complete)";
          }
          return `background: linear-gradient(to right,${color} ${width}%, rgba(0,0,0,0) 0%)`;
        }
      }
    },
    // 検索条件が変更されたら表示内容を更新
    filteredCheckList() {
      // 治療日列の表示/非表示
      let colSetting = this.getChecklistColumn;
      let dateIndex = colSetting.findIndex(p => p.field === "viewTreatDate");
      if (dateIndex >= 0) {
        colSetting[dateIndex].hidden = !this.condition.viewTreatDate;
        this.setChecklistColumn(colSetting);
      }
      // 自動更新の有無
      if (this.condition.isAutoReload) {
        this.startPolling();
      } else {
        this.endPolling();
      }
    },
    // add FNSI-redmine_#3908_ソート方法の改善 周 start
    columnResizeEvevt (event) {
      if (event.column.field === "bedName") {
        this.setChecklistColumnHeaderWidth({
          selectedFontSize: this.selectedFontSize,
          width: event.newWidth
        });
      } else {
        this.setChecklistColumnWidth({
          field: event.column.field,
          selectedFontSize: this.selectedFontSize,
          width: event.newWidth
        });
      }
    },
    // add FNSI-redmine_#3908_ソート方法の改善 周 end
    startPolling() {
      // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
      const funcCd = getCurrentFunctionCd();
      if (funcCd) {
        store.dispatch("report/getMstReport", {funcCd: funcCd,printFlag: 0,autoRefreshFlag:true});
      }
      // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
      this.endPolling();
      if (this.condition.isAutoReload) {
        this.autoReload = setInterval(() => {
          this.setCheckList(true)
        }, this.getReloadInterval * 60 * 1000);
      }
    },
    endPolling() {
      clearInterval(this.autoReload);
    },
    /**
     * ベッドのクリック
     */
    onClickBed(src) {
      const selOrdNo = src.ordNo;
      const selPatId = src.patId;
      // 治療状況
      const selRstDialysisState = src.rstDialysisState;
      // 治療中の次患者または条件送信済み患者の場合
      // かつ？？？？患者でない場合
      if (
        ((selRstDialysisState === dialysisState.beforeSendCondition &&
          this.getIsDisplayTreatingMode) ||
          selRstDialysisState === dialysisState.afterSendCondition ||
          selRstDialysisState === dialysisState.checkedSendCondition) &&
        selPatId !== null
      ) {
        // 患者選択リストに格納
        this.updateTreatmentPatList(this.CheckListToPatList);
        // 機能コード設定、選択 ord_no を保持
        this.setOrdNoForSideBarRecord(selOrdNo);
        this.setSrcFuncName(this.$router.currentRoute.name);

        // ordNoセット
        this.sendConditionSetSelectOrdNo({
          ordNo: selOrdNo,
          ordNo2: null
        }).then(() => {
          // 条件送信画面へ遷移
          this.goSpecifiedView("send-condition");
        });
      } else if (
        Number(selRstDialysisState) > Number(dialysisState.checkedSendCondition)
      ) {
        // 患者選択リストに格納
        this.updateTreatmentPatList(this.CheckListToPatList);
        // 機能コード設定、選択 ord_no を保持
        this.setOrdNoForSideBarRecord(selOrdNo);
        this.setSrcFuncName(this.$router.currentRoute.name);

        // 治療中以降の患者の場合
        this.setSelectedPatHeader(selPatId).then(() => {
          // ordNoセット
          this.$nextTick(() => {
            this.setTreatmentRecordOrdNo(selOrdNo);
            //add FNSI修正 治療記録画面バッグ 房 start
            this.setOrd({
              readOnly: false,
            });
            //add FNSI修正 治療記録画面バッグ 房 end
            // 治療記録画面へ遷移
            this.$router.push({ name: "treatment-record" });
          });
        });
      }
    },
    // グリッドクリック時
    onClick(src, column) {
      // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
      const funcCd = getCurrentFunctionCd();
      if (funcCd) {
        store.dispatch("report/getMstReport", {funcCd: funcCd,printFlag: 1});
      }
      // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
      const selOrdNo = src.ordNo;
      // 患者ID
      const selPatId = src.patId;
      // 治療状況
      const selRstDialysisState = src.rstDialysisState;

      // 患者名列の場合
      if (column.field === "patName") {
        if (selPatId === null) {
          // ？？？患者の場合
          // 名前割り当て画面へ遷移
          // 選択されたord_noの情報をセット
          this.scheduleAssignmentSetSelectOrdNo(selOrdNo).then(() => {
            // スケジュール・名前割り当てモーダル画面表示
            // mod FNSI-？？？？患者割り当てtitle名不正 陳 start
            // mod FNSI-？？？？患者割り当てtitle名不正 付 start
            // this.showSubModals(this.showSchedule);
            // this.showSubModals(this.showSchedule({title :"スケジュール割り当て"}));
            // FNSI-チェックリスト画面表示を修正 周 mod start
            // this.showSubModals(this.showSchedule({title :"？？？？患者治療割り当て"}));
            this.showSubModals(this.showSchedule, {title :"？？？？患者治療割り当て"});
            // FNSI-チェックリスト画面表示を修正 周 mod end
            // mod FNSI-？？？？患者割り当てtitle名不正 付 end
            // mod FNSI-？？？？患者割り当てtitle名不正 陳 end
          });
        } else if (
          selRstDialysisState === dialysisState.beforeSendCondition &&
          this.getIsDisplayTreatingMode
        ) {
          // 治療中モードの次患者の場合

          // 患者選択リストに格納
          this.updateTreatmentPatList(this.CheckListToPatList);
          // 機能コード設定、選択 ord_no を保持
          this.setOrdNoForSideBarRecord(selOrdNo);
          this.setSrcFuncName(this.$router.currentRoute.name);

          // ordNoセット
          this.sendConditionSetSelectOrdNo({
            ordNo: selOrdNo,
            ordNo2: null
          }).then(() => {
            // 条件送信画面へ遷移
            this.goSpecifiedView("send-condition");
          });
        } else if (
          Number(selRstDialysisState) >
          Number(dialysisState.beforeSendCondition)
        ) {
          // 条件送信以降
          // 患者選択リストに格納
          this.updateTreatmentPatList(this.CheckListToPatList);
          // 機能コード設定、選択 ord_no を保持
          this.setOrdNoForSideBarRecord(selOrdNo);
          this.setSrcFuncName(this.$router.currentRoute.name);

          // 条件送信以降の患者の場合
          this.setSelectedPatHeader(selPatId).then(() => {
            // ordNoセット
            this.$nextTick(() => {
              this.setTreatmentRecordOrdNo(selOrdNo);
              //add FNSI修正 治療記録画面バッグ 房 start
              this.setOrd({
                readOnly: false,
              });
              //add FNSI修正 治療記録画面バッグ 房 end
              // 治療記録画面へ遷移
              this.$router.push({ name: "treatment-record" });
            });
          });
        }
      } else if (column.field === "medicine") {
        // 投与薬剤列の場合
        // 選択されたord_noの情報をセット
        this.setSelectOrdNo(selOrdNo).then(() => {
          // 投与薬剤モーダル画面表示
          this.showSubModals(this.showMedicine);
        });
      } else if (column.field.startsWith("checklist_")) {
        // チェックリスト列の場合
        const listCd = column.code;
        const checklistCd = src.checklistCd;

        // 選択されたord_noとlist_cdの情報をセット
        this.setSelectCheckList({
          ordNo: selOrdNo,
          listCd: listCd,
          checklistCd: checklistCd
        });

        // 選択されたlist_cdのチェックリストマスタのlist_name取得
        this.getChecklistName(listCd).then(listName => {
          // チェックリストモーダル画面表示
          this.showSubModals(this.showChecklist, listName);
        });
      }
    },
    /**
     * ？？？？患者割当後の治療記録画面への遷移
     */
    moveTreatmentRecord(params) {
      this.setSelectedPatHeader(params.patId).then(() => {
        // ordNoセット
        this.$nextTick(() => {
          this.setTreatmentRecordOrdNo(params.ordNo);
          //add FNSI修正 治療記録画面バッグ 房 start
          this.setOrd({
            readOnly: false,
          });
          //add FNSI修正 治療記録画面バッグ 房 end
          // 治療記録画面へ遷移
          this.$router.push({ name: "treatment-record" });
        });
      });
    },
    /**
     * @param {function} callModalFunction コールバック関数
     * @param {any} arg コールバック関数の引数
     */
    showSubModals(callModalFunction, arg) {
      this.endPolling();
      callModalFunction(arg);
    },
    requestrReportParams(param) {
      // 機能コード判定
      if ( param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {

        // add #11285 機能帳票の印刷情報対応② 高 start
        var expressCondCd="";
        if (null != this.getStorSimlpSearchQurey.rstDialysisState && this.getStorSimlpSearchQurey.rstDialysisState.length > 0) {
          if (this.getStorSimlpSearchQurey.rstDialysisState.length == 2) {
            expressCondCd = "予定・実績";
          } else {
            if (this.getStorSimlpSearchQurey.rstDialysisState[0] == 1) {
              expressCondCd = "予定";
            } else {
              expressCondCd = "実績";
            }
          }
        }
        let kurNames = null;
        // del #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
        // if(this.getStorSimlpSearchQurey.kurNames && this.getStorSimlpSearchQurey.kurNames.length > 0) {
        //   kurNames = this.getStorSimlpSearchQurey.kurNames.join("・");
        // } else {
        //   kurNames = "すべて";
        // }
        // del #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
        let patGroups = null;
        if(this.getStorSimlpSearchQurey.selectedPatGroupNames) {
          patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames;
        } else {
          patGroups = "すべて";
        }
        // eslint-disable-next-line vue/no-side-effects-in-computed-properties
        this.bedCdListString = JSON.parse(sessionStorage.getItem('roomBedGroupNameCheckList')) || [];
        // add #11285 機能帳票の印刷情報対応② 高 end
        // 機能一致

        // 印刷パラメータを応答
        // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
        if (this.getSelectOrdMainMedimodal == null && this.getSelectOrdMainModal == null) {
          let treatdDte = null;
          // 治療中の場合
          if (this.getIsDisplayTreatingMode === true) {
            treatdDte = Date.now();
            // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
            kurNames = JSON.parse(sessionStorage.getItem('kurGroupNameStatusList'));
            // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
          } else {
            treatdDte = this.condition.treatDate;
            // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy start
            kurNames = JSON.parse(sessionStorage.getItem('kurGroupNameStatusList')) || "すべて";
            // add #12280 クールやベッドグループ等が「全部」であるときの表現が画面と違う sunsy end
          }
          // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
          const param = {
            // add 画面印刷プレビューと印刷の実現 黄 start
            // del #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
            // patId: this.selectedPatId,
            // del #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end
            patIds: this.getListDataSource.map(({ patId }) => patId),
            ordNos: this.getListDataSource.map(({ ordNo }) => ordNo),
            // add 画面印刷プレビューと印刷の実現 黄 end
            facilityCd: this.getFacilityCd,
            // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
            functionCd: "01501",
            // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 start
            // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
            // bedCds: this.getListDataSource.map(({ bedCd }) => bedCd),
            bedCds: this.getListDataSource.map(({ bedCd }) => bedCd),
            // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end
            // mod #11285 機能帳票の印刷情報対応② 高 start
            // bedCdListString:this.getStorSimlpSearchQurey.selectedBedGName,
            bedCdListString:this.bedCdListString,
            // mod #11285 機能帳票の印刷情報対応② 高 end
            // mod #9660、#9558、#9332 機能帳票でパラメータが正しく渡されていない 高 end
            // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
            // mod 5984 機能帳票でパラメータが正しく渡されていない 歴 start
            // date: moment(treatdDte).format("YYYY/MM/DD"),
            // fromDate: moment(treatdDte).format("YYYY/MM/DD"),
            // toDate: moment(treatdDte).format("YYYY/MM/DD")
            date: moment(treatdDte).format("YYYYMMDD"),
            fromDate: moment(treatdDte).format("YYYYMMDD"),
            toDate: moment(treatdDte).format("YYYYMMDD"),
            // add #11285 機能帳票の印刷情報対応② 高 start
            treatDate:this.getStorSimlpSearchQurey.treatDate,
            freeWord:this.getStorSimlpSearchQurey.freeWord,
            expressCondCdStr:expressCondCd,
            kurNames:kurNames,
            patGroups:patGroups,
            // add #11285 機能帳票の印刷情報対応② 高 end
            // mod 5984 機能帳票でパラメータが正しく渡されていない 歴 end
          };
          EventBus.$emit("sendReportParams", param);
        // add 5984 機能帳票でパラメータが正しく渡されていない 歴 start
        } else {
          if (this.getSelectOrdMainMedimodal !== null){
            const param = {
              functionCd: "01501",
              // add #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　start
              facilityCd: this.getFacilityCd,
              // add #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　end
              patId: this.getSelectOrdMainMedimodal.patId,
              bedCd: this.getSelectOrdMainMedimodal.bedCd,
              date: moment(this.getSelectOrdMainMedimodal.treatDate).format("YYYYMMDD"),
              fromDate: moment(this.getSelectOrdMainMedimodal.treatDate).format("YYYYMMDD"),
              toDate: moment(this.getSelectOrdMainMedimodal.treatDate).format("YYYYMMDD")
            };
            EventBus.$emit("sendReportParams", param);
          }

          if (this.getSelectOrdMainModal !== null){
            const param = {
              functionCd: "01501",
              // add #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　start
              facilityCd: this.getFacilityCd,
              // add #11968 iPadで治療記録画面の機能帳票表示に失敗する 高　end
              patId: this.getSelectOrdMainModal.patId,
              bedCd: this.getSelectOrdMainModal.bedCd,
              date: moment(this.getSelectOrdMainModal.treatDate).format("YYYYMMDD"),
              fromDate: moment(this.getSelectOrdMainModal.treatDate).format("YYYYMMDD"),
              toDate: moment(this.getSelectOrdMainModal.treatDate).format("YYYYMMDD")
            };
            EventBus.$emit("sendReportParams", param);
          }
        }
        // add 5984 機能帳票でパラメータが正しく渡されていない 歴 end
      }
    },
    addCustomClass() {
      const $grid = this.$refs.grid.kendoWidget();
      const that = this;
      this.$refs.grid.kendoWidget().tbody.find("tr").each(function() {
        const row = document.querySelectorAll(`[data-uid="${this.getAttribute("data-uid")}"]`);
        if (row.length > 1) {
          const cells = row[1].querySelectorAll("td");
          cells.forEach((cell, cellIndex) => {
            const headerData = document.querySelectorAll("th[role='columnheader']");
            const field = headerData[cellIndex + 1].getAttribute("data-field");
            const rowData = $grid.dataItem(row);
            const style = that.progressBackgroundColor({field}, rowData);
            if (style && style != null) {
              const styleSplit = style.split(':');
              cell.style.cssText = `${styleSplit[0]} : ${styleSplit[1]}`;
            }
            if (field == 'patName' && rowData['inOutClass'] == 1) {
              // mod FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
              // cell?.classList?.add("change-color-patient");
              cell?.classList?.add("pat-name-in-hospital");
              // mod FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
            }
            // del FNSI-入院患者名の配布表示を修正 周 start
            // // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 start
            // if (field == 'patName' && rowData['isSame'] == 1 && cell.lastChild.tagName !== "IMG") {
            //   var img = new Image();
            //   img.src = require('../../assets/name_duplication.png');
            //   img.className = "pat-name-same-icon";
            //   cell.appendChild(img);
            // }
            // // add FNSI-横展開 入院患者名の配布_チェックリスト機能分 周 end
            // del FNSI-入院患者名の配布表示を修正 周 end
          });
        }
      });
    },
    onCellClick(event) {
      event.preventDefault();

      const $grid = this.$refs.grid.kendoWidget();
      const selectedRow = $grid.select().closest("tr");
      const selectedRowData = $grid.dataItem(selectedRow);
      const cellIndex = event.sender.cellIndex(event.sender.select().closest("td"));
      const headerData = document.querySelectorAll("th[role='columnheader']");
      const field = headerData[cellIndex].getAttribute("data-field");
      let columnCode = null;

      if (field.startsWith("checklist_")) {
        columnCode = this.getChecklistColumn.find(col => col.field === field).code;
      }
      if (field == 'bedName') {
        this.onClickBed(selectedRowData);
      } else {
        this.onClick(selectedRowData, {field, code: columnCode});
      }
    },
    gridSetting(){
      this.addCustomClass();
      const lockedContent = document.querySelector('.k-grid-content-locked');
      const scrollableContent = document.querySelector('.k-grid-content');
      if (!lockedContent || !scrollableContent) return;

      // Grid高さの調整
      this.$nextTick(() => {
        this.calculateGridHeight();
        const headerHeight = document.getElementsByClassName("k-grid-header")[0].offsetHeight + 2;
        const gridContent = document.getElementsByClassName("k-grid-content")[0];
        const isHorizontalScroll = gridContent.scrollWidth > gridContent.clientWidth;
        let lockRowHeight = this.kendoGridHeight - headerHeight;
        // PCでの表示時のみ、スクロールバー分の不要な高さが発生する為、高さの調整を行う
        if (!this.androidFlg && !this.iosFlg && isHorizontalScroll) {
          lockRowHeight -= 17;
        }
        document.getElementsByClassName("k-grid-content-locked")[0].style.height = lockRowHeight + "px";
      });

      if (lockedContent) {
        let startY = 0;
        // タッチ開始位置を記録（iOS/Android対応）
        lockedContent.addEventListener('touchstart', (e) => {
          startY = e.touches[0].clientY;
        }, { passive: false });

        lockedContent.addEventListener('touchmove', (e) => {
          // タッチ移動に応じてスクロール（iOS/Android対応）
          const deltaY = startY - e.touches[0].clientY;
          lockedContent.scrollTop += deltaY;
          startY = e.touches[0].clientY;
          e.preventDefault(); // 慣性スクロールを有効にするために必要
        }, { passive: false });
      }

      if (lockedContent && scrollableContent) {
        // 固定列のスクロールに応じて可動列を同期（縦スクロールの一体化）
        lockedContent.addEventListener('scroll', () => {
          scrollableContent.scrollTop = lockedContent.scrollTop;
        });

        // 可動列のスクロールに応じて固定列を同期（双方向同期）
        scrollableContent.addEventListener('scroll', () => {
          lockedContent.scrollTop = scrollableContent.scrollTop;
        });
      }
      // ヘッダーにスタイル適用
      this.$refs.grid.$el.firstElementChild.style.backgroundColor = "var(--ntss-list-header-background-color)";
      this.$refs.grid.$el.firstElementChild.firstElementChild.style.borderColor = "var(--ntss-base-background-color)";
      // 慣性スクロール用のクラスを追加
      document.getElementsByClassName("k-auto-scrollable")[1].style.WebkitOverflowScrolling = "touch";
    },
    getGridColumnResize() {
      const that = this;
      // FNSI-チェックリスト画面表示を修正 周 mod start
      // const $grid = this.$refs.grid.kendoWidget();
      // $grid.bind("columnResize", function() {
      //   that.gridSetting();
      // });
      if (that && this.$refs && this.$refs.grid && this.$refs.grid.kendoWidget()) {
        const $grid = this.$refs.grid.kendoWidget();
        $grid.bind("columnResize", function() {
          that.gridSetting();
        });
      }
      // FNSI-チェックリスト画面表示を修正 周 mod end
    },
    /**
     * 列固定切り替え(印刷時)
     */
    changeLock(){
      this.lockFlg = !this.lockFlg;
    }
  },
  watch: {
    windowHeight() {
      this.calculateGridHeight();
    },
    windowWidth() {
      this.calculateGridHeight();
    },
    isDispMenu() {
      this.calculateGridHeight();
    },
    getFontSize() {
      this.calculateGridHeight();
    },
    getIsDisplayTreatingMode() {
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    },
    // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 start
    getIsAsynComplete(value) {
      if (value) {
        this.$nextTick(() => {
          this.listDataSource = new Kendo.data.DataSource({
            data: this.getListDataSource
          });
          // FNSI-修正 #5407 xie add start
          this.setLoadingScreenVisible(false);
          // FNSI-修正 #5407 xie add end
        });
      }
    },
    // add FNSI-横展開 患者名ソート改善_チェックリスト機能分 周 end
    condition() {
      this.$nextTick(() => {
        this.calculateGridHeight();
      });
    }
  },
  created() {
    // FNSI-修正 #5407 xie add start
    this.setLoadingScreenMessage("処理中・・・");
    //FNSI-修正 #5407 xie add end
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    // add 性能改善メモリ不足 shan start
    EventBus.$off("filterCheckList", this.setFilterCondition);
    EventBus.$off("dataUpdate", this.setCheckList);
    EventBus.$off("refresh", this.setCheckList);
    EventBus.$off("closeModal", this.startPolling);
    EventBus.$off("requestReportParams", this.requestrReportParams );
    EventBus.$off("ScheduleAssignment", this.moveTreatmentRecord);
    // add 性能改善メモリ不足 shan end

    EventBus.$on("filterCheckList", this.setFilterCondition);
    EventBus.$on("dataUpdate", this.setCheckList);
    EventBus.$on("refresh", this.setCheckList);
    EventBus.$on("closeModal", this.startPolling);

    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams );

    // スケジュール割当後の治療記録への遷移
    EventBus.$on("ScheduleAssignment", this.moveTreatmentRecord);

    // 画面名称取得
    this.selfScreenName = this.$router.currentRoute.name;

    // del FNSI-横展開 表示条件のサインイン内保持_チェックリスト機能分 周 start
    // let today = moment(new Date());
    // this.condition.treatDate = today.format("YYYY-MM-DD");
    // // 抽出条件セット
    // this.setCondition(this.condition);
    // // 初期表示を治療中にセット
    // this.changeIsDisplayTreatingMode(true);
    // del FNSI-横展開 表示条件のサインイン内保持_チェックリスト機能分 周 end

  },
  async mounted() {
    /* 自動更新サインアウトフラグ取得 */
    await initForceSignOutFlag("check-list/list/setForceSignOutFlag", CHECK_LIST_FORCE_SIGNOUT);
    // データ取得
    this.dataLoad();
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
    this.getGridColumnResize();
    // Rootページのサイドバーボタン要素のイベントリスナー設定
    // ※「左サイドバー切り替えする時、画面の右スクロールバーの表示がおかしいについての修正」をリファクタ
    const rootSideBarBtn = document.querySelector('#showPatientSearchSidebarBtn');
    rootSideBarBtn?.addEventListener('click', this.calculateGridHeight);
    EventBus.$on("print-start", this.changeLock);
    EventBus.$on("print-end", this.changeLock);
  },
  beforeDestroy() {
    EventBus.$off("print-start", this.changeLock);
    EventBus.$off("print-end", this.changeLock);
    EventBus.$off("filterCheckList", this.setFilterCondition);
    EventBus.$off("dataUpdate", this.setCheckList);
    EventBus.$off("refresh", this.setCheckList);
    EventBus.$off("closeModal", this.startPolling);
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams );

    // スケジュール割当後の治療記録への遷移
    EventBus.$off("ScheduleAssignment", this.moveTreatmentRecord);

    this.setIsDataLoadCancel(true);
    this.setIsDataLoading(false);
    this.endPolling();

    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    // Rootページのサイドバーボタン要素のイベントリスナー解除
    const rootSideBarBtn = document.querySelector('#showPatientSearchSidebarBtn');
    rootSideBarBtn?.removeEventListener('click', this.calculateGridHeight);
  }
};
</script>
<style scoped>
div >>> .k-i-sort-asc-sm::before {
  content: "▲" !important;
  color: #ffffff;
}

div >>> .k-i-sort-desc-sm::before {
  content: "▼" !important;
  color: #ffffff;
}
.check-list-main-content {
  flex: 1;
}

.k-grid >>> .change-color-patient{
  /* mod FNSI-障害票一覧_チェックリスト#2。 周 start */
  /* color: mediumorchid; */
  color: purple;
  /* mod FNSI-障害票一覧_チェックリスト#2。 周 end */
}

.master-maintenance-page >>> .k-state-selected {
  background-color: unset !important;
}

.master-maintenance-page >>> .k-state-selected:hover {
  background-color: #FFFFFF !important;
}

.master-maintenance-page >>> .k-grid-header {
  background: var(--ntss-list-header-background-color);
  background-image: linear-gradient(rgba(255,255,255,.3) 0%,transparent 50%,transparent 50%,rgba(0,0,0,0.1) 100%);
}

#area_usage_guide {
  position: absolute;
  bottom: 0;
  width: 100%;
  padding-top: 3px;
  display: flex;
  flex-wrap: wrap;
  color: var(--ntss-list-body-color);
}

.usage-guide-div {
  margin-right: 1em;
  display: flex;
}

.usage-guide-element {
  width: 1em;
  height: 1em;
  margin-top: 0.2em;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style >>> .k-grid-content-locked::-webkit-scrollbar {
  display: none;
}

@media print {
  /* 背景の高さ固定を解除 */
  .main-content-area
  ,.grid-area
  , .check-list-main-content-list
  ,.check-list-main-content-list >>> .k-grid-content-locked
  , .check-list-main-content-list >>> .k-auto-scrollable{
    height: auto !important;
  }

  /* 各セルの横幅設定を削除 */
  .check-list-main-content-list >>> colgroup {
    display: none;
  }

  /* 見切れ文字改行設定 */
  .check-list-main-content-list  >>> .k-grid-header th
  ,  .check-list-main-content-list  >>> .k-grid-header th
  ,  .check-list-main-content-list  >>> .k-grid-content td {
    white-space: normal;
    word-break: break-all;
  }

  /* テーブルの横幅をレスポンシブ化 */
  .check-list-main-content-list >>> table {
    width: 100% !important;
  }

  /* テーブル内部の横幅を微調整 */
  .check-list-main-content-list >>> .k-grid-content {
    width: calc(100% - 16px) !important;
  }

    /* テーブル内部の横幅を微調整 */
  .check-list-main-content-list >>> .k-grid-content {
    width: calc(100% - 16px) !important;
  }

    /* 配置設定を修正 */
  .check-list-main-content-list, #area_usage_guide {
    position: static !important;
  }
}

</style>
