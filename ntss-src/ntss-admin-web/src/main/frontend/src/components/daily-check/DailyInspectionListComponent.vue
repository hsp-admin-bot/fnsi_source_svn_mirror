<template>
  <v-card>
    <div
      class="main-content-area"
      style="overflow: hidden;"
      @mousedown="onMouseDown"
      @mouseup="onMouseUp"
      @mouseleave="onInitialize"
    >
      <!-- 全体エリア -->
      <div
        :id="Keys.allArea"
        class="scroll-table"
        style="position: sticky;"
      >
        <!-- 固定列エリア -->
        <div
          :id="Keys.fixedArea"
          class="fixed-area"
          @mousewheel="onWheel($event, Keys.fixedArea)"
          @touchstart="onTouchStart"
          @touchmove="onTouchMove"
        >
          <table
            :id="Keys.fixedTable"
            class="custom-ntss-list ntss-list-table"
          >
            <thead>
              <tr>
                <th
                  :id="Keys.no"
                  class="custom-no ntss-list-header-th-sticky text-left word-break-th manual-width-scoped"
                  draggable="true"
                  @dragstart="onDragStart(false)"
                  @drag="onDragOver($event, false)"
                  @dragend="onDragEnd(false)"
                >No</th>
                <th
                  :id="Keys.bedName"
                  class="custom-bed ntss-list-header-th-sticky text-left word-break-th manual-width-scoped"
                  draggable="true"
                  @dragstart="onDragStart(false)"
                  @drag="onDragOver($event, false)"
                  @dragend="onDragEnd(false)"
                >
                  <div
                    class="resizable-head-container"
                    @click="updateSort(Keys.bedName, sort)"
                  >
                    <span
                      class="span-grow-area"
                      :class="getSortedClass(Keys.bedName, sort)"
                    >ベッド</span>
                  </div>
                </th>
                <th
                  :id="Keys.machineName"
                  class="custom-equip ntss-list-header-th-sticky text-left word-break-th manual-width-scoped"
                  draggable="true"
                  @dragstart="onDragStart(false)"
                  @drag="onDragOver($event, false)"
                  @dragend="onDragEnd(false)"
                >
                  <div
                    class="resizable-head-container"
                    @click="updateSort(Keys.machineName, sort)"
                  >
                    <span
                      class="span-grow-area"
                      :class="getSortedClass(Keys.machineName, sort)"
                    >装置名</span>
                  </div>
                </th>
                <th
                  :id="Keys.machineType"
                  class="custom-model ntss-list-header-th-sticky text-left word-break-th manual-width-scoped"
                  draggable="true"
                  @dragstart="onDragStart(false)"
                  @drag="onDragOver($event, false)"
                  @dragend="onDragEnd(false)"
                >
                  <div
                    class="resizable-head-container"
                    @click="updateSort(Keys.machineType, sort)"
                  >
                    <span
                      class="span-grow-area"
                      :class="getSortedClass(Keys.machineType, sort)"
                    >型式</span>
                  </div>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="(item, index) in sortList"
                :key="item.machine.machineNo"
                v-show="showFlg(item)"
              >
                <td
                  class="custom-no ntss-list-body-td text-left word-break-td"
                >{{ index + 1 }}</td>
                <td
                  class="custom-bed ntss-list-body-td text-left word-break-td"
                  @click="showDetailModal(item.machine)"
                >{{ item.machine.bedName }}</td>
                <td
                  class="custom-equip ntss-list-body-td text-left word-break-td"
                  @click="showDetailModal(item.machine)"
                >{{ item.machine.machineName }}</td>
                <td
                  class="custom-model ntss-list-body-td text-left word-break-td"
                  @click="showDetailModal(item.machine)"
                >{{ item.machine.machineType }}</td>
              </tr>
            </tbody>
          </table>
          <!-- スクロール調整エリア -->
          <div :id="Keys.scrollAdjustArea" />
        </div>
        <!-- スクロール列エリア -->
        <div
          :id="Keys.scrollArea"
          class="scroll-area"
          @mousewheel="onWheel($event, Keys.scrollArea)"
          @scroll="onScroll"
        >
          <table
            :id="Keys.scrollTable"
            class="custom-ntss-list ntss-list-table"
          >
            <thead>
              <tr
                @mouseover="onMouseOver"
                @mouseleave="onMouseLeave"
              >
                <th
                  v-for="(layout, index) in layoutList"
                  :key="layout.menteLayoutCd"
                  :id="`${layout.menteLayoutCd}`"
                  v-show="showLayoutFlg[index]"
                  class="ntss-list-header-th-sticky text-left word-break-th manual-width-scoped"
                  style="max-width: 400px; min-width: 150px; width: 150px; --base-width: 150px;"
                  @mousedown="onGetID"
                  @dragstart="onDragStart(true)"
                  @drag="onDragOver($event, true)"
                  @dragend="onDragEnd(true)"
                >
                  <div
                    class="resizable-head-container"
                    @click="updateSort(`${Keys.layout}${layout.menteLayoutCd}`, sort)"
                  >
                    <span
                      class="span-grow-area"
                      :class="getSortedClass(`${Keys.layout}${layout.menteLayoutCd}`, sort)"
                    >{{ layout.layoutName }}</span>
                    <img
                      :src="imageSrcInfoIcon"
                      alt="info"
                      class="img-info-icon"
                      @click.stop="showPopover($event, layout)"
                    />
                  </div>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="item in sortList"
                :key="item.machine.machineNo"
                v-show="showFlg(item)"
              >
                <td
                  v-for="(detail, index) in item.details"
                  :key="detail.menteLayoutCd"
                  v-show="showLayoutFlg[index]"
                  class="ntss-list-body-td text-center word-break-td"
                  :class="{ 'cell-disabled': detail.isDisabled }"
                  @click="updateResult(detail)"
                >{{ convertStatus(detail.menteAns1) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <v-ons-popover
      cancelable
      :visible.sync="popoverVisible"
      :target="popoverTarget"
      direction="down"
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div id="popover" style="margin: 10px;">
        <div style="height: 50vh; overflow: auto;">
          <div style="margin-bottom: 10px; text-align: center;">
            <label class="title-popup">{{ selectedLayoutName }}</label>
          </div>
          <div class="table">
            <table class="ntss-list" style="position: relative;">
              <tbody>
                <tr
                  v-for="rowData in layoutDetailList"
                  :key="`${rowData.mainteCategoryCd}_${rowData.mainteDetailCd}`"
                  class="select-layout-tr"
                >
                  <td
                    v-if="rowData.isHeader"
                    colspan="2"
                    class="ntss-list-body-td select-layout-td-header color-header"
                  >{{ rowData.categoryName }}<br>{{ rowData.typeName }}</td>
                  <td
                    v-if="!rowData.isHeader"
                    class="ntss-list-body-td select-layout-td"
                  >{{ rowData.menteContent1 }}</td>
                  <td
                    v-if="!rowData.isHeader"
                    class="ntss-list-body-td select-layout-td"
                  >{{ rowData.menteContent2 }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <v-ons-row class="confirm">
          <v-ons-col width="35%" vertical-align="center">
            <v-ons-button
              class="btn2-cancel"
              @click="dialogClose"
            >閉じる</v-ons-button>
          </v-ons-col>
          <v-ons-col vertical-align="center"></v-ons-col>
          <v-ons-col width="30%" vertical-align="center">
            <v-ons-button
              class="btn1-execute"
              :disabled="passAllDisabled"
              @click="dialogPassAll"
            >全台合格</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </v-ons-popover>
  </v-card>
</template>

<script>
import store from "@/stores";
import { mapGetters, mapActions, mapMutations } from "vuex";
import { EventBus } from "@/eventBus";
import moment from "moment";
import PopoverMixin from "@/components/PopoverMixin";
import {
  MainteClass,
  Answer,
} from "@/constants/mainteConstants";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {
  popoverPreShow,
  popoverPostShow,
  popoverPosthide,
} from "@/functions/common/CommonPopoverFunctions";
import {
  addColResizeListeners,
  removeColResizeListeners,
} from "@/functions/common/ColResizeFunctions";
import { alertByKey } from "@/functions/common/OnsenFunctions";
import { convertStatus } from "@/functions/DailyInspectionFunction";
import { updateSort, getSortedClass, sortableCompare } from "@/functions/SortFunctions";
import $ from "jquery";
import {
  sendRequestGetMachinesConditionRes,
  sendRequestGetLayoutForDailyCheck,
  sendRequestGetCheckResult,
  sendRequestUpdateAllCheckResult,
  sendRequestUpdateCheckResult,
} from "@/apis/daily-check";
import PrintMixin from "@/components/PrintMixin";

const isDispOn = layout => (layout?.isDisp === "1");

// キー系文字列定義
const Keys = Object.freeze({
  allArea: "allArea",
  fixedArea: "fixedArea",
  fixedTable: "fixedTable",
  scrollArea: "scrollArea",
  scrollTable: "scrollTable",
  scrollAdjustArea: "scrollAdjustArea",

  no: "no",
  bedName: "bedOrderIndex",
  machineName: "machineOrderIndex",
  machineType: "machineTypeCd",

  defaultSort: "",
  layout: "layout",

  Y: "Y",
  XY: "XY",
});

// ソート情報の初期状態
// （ソート指定がない場合のデフォルトソート順は
// 　第一ソートキー：装置マスタ型式＞mst_machine_type.model　昇順
// 　第二ソートキー：ベッドマスタ表示順昇順　空後方）
const DefaultSortInfo = Object.freeze({
  key: Keys.defaultSort,
  isAsc: true,
});

export default {
  mixins: [PopoverMixin, ComponentGuardMixin, PrintMixin],
  name: "DailyInspectionListComponent",
  data() {
    return {
      Keys,
      popoverVisible: false,
      popoverTarget: null,
      popoverLayoutCd: null,
      inspectionList: [],
      layoutList: [],
      machinesList: [],
      selectedLayoutName: "",
      sort: {
        ...DefaultSortInfo,
      },
      authorityCds: [
        AUTHORITY_CODES.DEV_PEDIT,  // 機器保守-代行編集
        AUTHORITY_CODES.DEV_EDIT,   // 機器保守-編集
      ],
      hasDailyCheckAuthority: false,
      isClicked: false,
      isOvered: false,
      targetID: null,
      intervalIDList: [],
      buffer: 0,
      noWidth: 30,
      maxWidth: 400,
      minWidth: 150,
      fixedColsResizeInfo: null,
      scrollColsResizeInfo: null,
      beforeUpdateScrollTopPosition: 0,
      scrollTopPosition: 0,
      scrollState: false,
      isScrollY: false,
      touchStartY: 0,
      iosFlg: false,
      androidFlg: false,
      imageSrcInfoIcon: require("../../assets/info_icon_1.png"),
      scrollQuerySelector: ".scroll-area", // スクロールコンテナ
      addClassTargetQuerySelector: ["#scrollTable"] // scroll-rightmostクラスを付与する対象のクエリセレクタ
    };
  },
  computed: {
    // add #11285 機能帳票の印刷情報対応② 高 start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #11285 機能帳票の印刷情報対応② 高 end
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("window-size", [
       "getWindowHeight",
       "getWindowWidth",
       "getMainWindowWidth",
       "getSidebarWidth",
    ]),
    ...mapGetters("account-edit", ["getFontSize"]),
    ...mapGetters("daily-check", [
      "getLayoutDetail",
      "getDailyDateSearch",
      "getCondition",
      "getConditionForReportParams",
      "getIsOpenBySubView",
    ]),
    ...mapGetters("mst-layout", [
      "getCategoryList",
      // getMachineTypeList の値を設定する sendRequestGetMachineTypeList は
      // ヘッダー部の created で呼ばれる
      "getMachineTypeList",
    ]),
    ...mapGetters("pat-info", ["selectedPatId"]),

    searchDate() {
      return moment(this.getDailyDateSearch || undefined).format("YYYY-MM-DD");
    },
    sortList() {
      const list = [];
      if (this.inspectionList.length) {
        list.push(...this.inspectionList);
        const { key, isAsc } = this.sort;
        if (key !== Keys.defaultSort) {
          // ソート指定が有効な場合はソート処理を行う
          if (key.startsWith(Keys.layout)) {
            // レイアウトの点検結果でのソートの場合
            const layoutCd = parseInt(key.replace(Keys.layout, ""));
            list.sort((itemA, itemB) => compareLayoutAnswer(
              itemA, itemB, isAsc, layoutCd
            ));
          } else {
            // 装置に紐づくマスタ情報でのソートの場合
            // ベッド：ベッドマスタ表示順　空後方
            // 　※降順ではこの反転で空前方になる
            // 装置名：装置マスタ表示順　(空欄なし)
            // 型式：型式コード3桁数字で文字列ソート
            const listForSort = list.map(item => (
              { item, [key]: item.machine[key] }
            ));
            listForSort.sort((itemA, itemB) => sortableCompare(
              itemA, itemB, key, isAsc, { notUseSortKeyMap: true }
            ));
            list.splice(0, Infinity, ...listForSort.map(item => item.item));
          }
        }
        // #11086対応時のメモ：
        // 装置リスト取得APIのレスポンスの順がデフォルトソート順になるように
        // 実装しているので、ソート指定がない場合は
        // レスポンスから生成した順のままにする
      }
      return list;
    },
    dailyCategoryList() {
      const result = [];
      this.getCategoryList.forEach(item => {
        if (item.mainteClass !== MainteClass.Daily) return;
        result.push({
          ...item,
          ...this.makeCategoryDetailInfo(item.detail),
        });
      });
      return result
    },
    layoutDetailList() {
      const result = [];
      if (!this.getLayoutDetail.category) return result;

      // this.getLayoutDetail のグループ情報から
      // this.dailyCategoryList 相当のグループ名称、対象型式名称情報を生成し
      // 点検項目情報リストを付与する
      const detailMstList = this.getLayoutDetail.detail;
      // java側での綴り間違いによる表記ゆれを吸収するため
      // プロパティ名の読み替え処理を行なっておく
      detailMstList?.forEach(mst => {
        mst.mainteDetailCd = mst.menteDetailCd;
      });
      const groupList = this.getLayoutDetail.category.map(category => {
        const detailInfo = this.makeCategoryDetailInfo(category.detail);
        const details = [];
        detailInfo.detailList.forEach(item => {
          const detail = detailMstList?.find(
            mst => mst.mainteDetailCd === item.code
          );
          if (!detail) return;
          details.push(detail);
        });
        return {
          mainteCategoryCd: category.menteCategoryCd,
          category: {
            ...category,
            ...detailInfo,
          },
          details,
        };
      });

      // tbody内でtempleteを使わないで済むように
      // 点検項目グループのヘッダー行のデータを含んだ配列を作成する
      groupList.forEach(({ mainteCategoryCd, category, details }) => {
        result.push({
          isHeader: true,
          mainteCategoryCd,
          mainteDetailCd: null,
          ...category,
        });
        details.forEach(detail => {
          result.push({
            isHeader: false,
            mainteCategoryCd,
            ...detail,
          });
        });
      });
      return result;
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
    // 各レイアウトの列を表示するかどうかのフラグ配列
    showLayoutFlg() {
      const showList = this.sortList.filter(item => this.showFlg(item));
      // 表示対象の装置の中に点検結果データを持たないものがあるか判定する
      const existsNoDataMachine = showList.some(item => (
        item.details.every(detail => detail.devMenteNo == null)
      ));
      // 表示対象の装置がすべて点検結果データを持っている場合は
      // どの装置にも点検結果データがないレイアウト列を非表示にする
      // （いずれかの装置に点検結果データあるレイアウト列のみを表示する）
      // 削除済みのレイアウトについては常に
      // いずれかの表示対象の装置に点検結果データあるレイアウト列のみを表示する
      return this.layoutList.map((layout, index) => (
        (existsNoDataMachine && isDispOn(layout)) || showList.some(item => (
          item.details[index].devMenteNo != null
        ))
      ));
    },
    // 全台合格処理の対象とする装置番号のリスト
    machineNoListForPassAll() {
      const machineNoList = [];
      this.sortList.forEach(item => {
        if (this.showFlg(item) && item.details.some(detail => (
          detail.menteLayoutCd === this.popoverLayoutCd
          && !detail.isDisabled
        ))) {
          // 画面に表示されていて
          // 対象レイアウトのセルがグレーアウトしていない装置を対象とする
          machineNoList.push(item.machine.machineNo);
        }
      });
      return machineNoList;
    },
    // 全台合格ボタン非活性フラグ
    passAllDisabled() {
      // 編集権限がない、もしくは全台合格の対象装置がない場合はtrue
      return !this.hasDailyCheckAuthority || !this.machineNoListForPassAll.length;
    },
  },
  methods: {
    ...mapActions("daily-check", [
      "sendRequestGetLayoutDetail",
      "setMachine",
    ]),
    ...mapActions("mst-layout", ["sendRequestGetAllCategoryByFacilityCd"]),
    ...mapActions("multi-modal", ["showDailyModal"]),
    ...mapActions("loading-screen", ["executeWithLoadingScreen"]),
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays",
    ]),
    ...mapMutations("daily-check", ["setIsOpenBySubView"]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    convertStatus,
    updateSort,
    getSortedClass,

    makeCategoryTypeName(typeCdList) {
      const typeNames = [];
      if (typeCdList.length) {
        typeCdList.forEach(typeCd => {
          const typeMst = this.getMachineTypeList.find(
            type => type.machineTypeCd === typeCd
          );
          if (!typeMst) return;
          typeNames.push(typeMst.machineType);
        });
      } else {
        // 装置型式が未指定の場合は「すべて」扱いとする
        typeCdList.push(...this.getMachineTypeList.map(
          type => type.machineTypeCd
        ));
        typeNames.push("すべて");
      }
      return typeNames.join(",");
    },
    makeCategoryDetailInfo(detail) {
      const detailObj = (detail && JSON.parse(detail)) || null;
      const typeCdList = [];
      const detailList = [];
      if (detailObj?.type_info) {
        typeCdList.push(...detailObj.type_info);
        if (detailObj.detail_list) {
          detailList.push(...detailObj.detail_list.filter(isDispOn));
        }
      } else {
        if (detailObj) {
          detailList.push(...detailObj.filter(isDispOn));
        }
      }
      return {
        typeCdList,
        detailList,
        typeName: this.makeCategoryTypeName(typeCdList),
      };
    },

    requestReportParams(param) {
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      if (this.getIsOpenBySubView) return;
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      // 機能コード判定
      if (param.substring(0, 3) !== getCurrentFunctionCd().substring(0, 3)) return;

      // 印刷パラメータを応答
      // add #11285 機能帳票の印刷情報対応② 高 start
      const {
        rstDialysisState,
        kurNames,
        selectedPatGroupNames,
        treatDate,
      } = this.getStorSimlpSearchQurey;
      const expressCondCdStr = (rstDialysisState?.length) ? (
        (rstDialysisState.length === 2) ? "予定・実績" : (
          (rstDialysisState[0] === "1") ? "予定" : "実績"
        )
      ) : "";
      const kurNamesStr = (kurNames?.length) ? kurNames.join("・") : "すべて";
      const patGroups = selectedPatGroupNames || "すべて";
      // add #11285 機能帳票の印刷情報対応② 高 end
      const {
        bedCdListString,
        machineTypeName,
      } = this.getConditionForReportParams;
      const date = moment(this.getDailyDateSearch).format("YYYYMMDD");
      const reportParams = {
        patId: this.selectedPatId,
        date,
        machineNos: this.inspectionList.map(item => item.machine.machineNo),
        selectNos: [],
        functionCd: "03401",
        facilityCd: this.getFacilityCd,
        fromDate: date,
        toDate: date,
        // add #11285 機能帳票の印刷情報対応② 高 start
        treatDate,
        bedCdListString,
        freeWord: this.getCondition.keyword,
        expressCondCdStr,
        kurNames: kurNamesStr,
        patGroups,
        type: machineTypeName.replaceAll("、", "・"),
        // add #11285 機能帳票の印刷情報対応② 高 end
      };
      EventBus.$emit("sendReportParams", reportParams);
    },
    async refreshData(forUpdateResult = false) {
      if (forUpdateResult) {
        // グリッドのセルをクリックして点検結果を更新した際は点検結果情報の取り直しのみを行う
        await this.reloadInspectionResult();
      } else {
        await this.applyConditionList();
      }
    },
    showPopover(event, { menteLayoutCd, layoutName }) {
      this.sendRequestGetLayoutDetail(menteLayoutCd);
      this.selectedLayoutName = layoutName;
      this.popoverTarget = event;
      this.popoverVisible = true;
      this.popoverLayoutCd = menteLayoutCd;
    },
    async updateResult(item) {
      // 装置がレイアウトの対象外で点検結果も未実施場合は点検結果を変更しない
      if (
        item.isDisabled
        && ([Answer.NotDate, Answer.NotDateForDb].includes(item.menteAns1))
      ) return;
      if (!this.hasDailyCheckAuthority) return;
      await this.executeWithLoadingScreen(async () => {
        switch (item.menteAns1) {
          // mod #10896 mnt_mainte_main.mainte_ans_1の登録データ不正 日常点検 dengshen start
          case Answer.NotDate:
          case Answer.NotDateForDb:
          // mod #10896 mnt_mainte_main.mainte_ans_1の登録データ不正 日常点検 dengshen end
            item.menteAns1 = Answer.Good;
            break;
          case Answer.Good:
            item.menteAns1 = Answer.Running;
            break;
          case Answer.Running:
            item.menteAns1 = Answer.NotGood;
            break;
          case Answer.NotGood:
            // mod #10896 mnt_mainte_main.mainte_ans_1の登録データ不正 日常点検 dengshen start
            item.menteAns1 = Answer.NotDateForDb;
            // mod #10896 mnt_mainte_main.mainte_ans_1の登録データ不正 日常点検 dengshen end
            break;
          default:
            break;
        }
        try {
          await sendRequestUpdateCheckResult(item);
        } catch (error) {
          getErrorMessage("DailyInspectionListComponent.vue", "updateResult", error);
        }
        await this.refreshData(true);
      });
    },
    dialogClose() {
      this.popoverVisible = false;
    },
    async dialogPassAll() {
      this.popoverVisible = false;
      await this.executeWithLoadingScreen(async () => {
        // 対象となる装置が存在しない場合は処理を中断する
        if (!this.machineNoListForPassAll.length) return;

        await sendRequestUpdateAllCheckResult({
          params: {
            menteLayoutCd: this.popoverLayoutCd,
            menteDate: this.searchDate,
          },
          machineNoList: this.machineNoListForPassAll,
        }).catch(error => {
          getErrorMessage("DailyInspectionListComponent.vue", "dialogPassAll", error);
          // title: "エラー",
          // message: "システムエラーが発生しました。",
          alertByKey("00200002");
        });
        await this.refreshData();
      });
    },
    showDetailModal(machine) {
      store.dispatch("report/getMstReport", { funcCd: "03401", printFlag: 1 });
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      this.setIsOpenBySubView(true);
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      this.setMachine(machine);
      this.showDailyModal();
    },
    // レイアウトマスタリストについて
    // 最新マスタには存在しない（削除済み）のレイアウトの部分を
    // コード降順にソートする
    sortLayout(layoutList) {
      // ソートしない部分と
      // 最新マスタには存在しない（削除済み）のレイアウトの部分に振り分ける
      const result = [];
      const target = [];
      layoutList.forEach(layout => {
        (isDispOn(layout) ? result : target).push(layout);
      });
      if (target.length) {
        target.sort((a, b) => (b.menteLayoutCd - a.menteLayoutCd));
        result.push(...target);
      }
      return result;
    },
    async applyConditionList() {
      await this.executeWithLoadingScreen(async () => {
        const detailListMaster = [];
        const params = {
          bedGroupCd: this.getCondition.bedGroupCd,
          machineTypeList: this.getCondition.machineTypeList,
          keyword: this.getCondition.keyword,
        };
        const menteDate = this.searchDate;
        const [
          machinesConditionRes,
          layoutRes,
          detailConditionRes,
        ] = await Promise.all([
          sendRequestGetMachinesConditionRes(params),
          sendRequestGetLayoutForDailyCheck(menteDate),
          sendRequestGetCheckResult(menteDate),
          this.sendRequestGetAllCategoryByFacilityCd(this.getFacilityCd),
        ]).catch(error => {
          getErrorMessage("DailyInspectionListComponent.vue", "applyConditionList", error);
        });
        const detailConditionList = detailConditionRes.data;
        this.machinesList = machinesConditionRes.data;
        this.layoutList = this.sortLayout(layoutRes.data);
        this.machinesList.forEach(machine => {
          const machineNo = machine.machineNo;
          const detailByLayoutList = [];
          machine.nonFlg = false;
          machine.passFlg = true;
          machine.unfinishedFlg = false;
          machine.unpassFlg = false;
          const hasMachineData = detailConditionList.some(detail => (
            machineNo === detail.machineNo
          ));
          this.layoutList.forEach(layout => {
            const menteLayoutCd = layout.menteLayoutCd;
            let devMenteNo = null;
            // mod #10896 mnt_mainte_main.mainte_ans_1の登録データ不正 日常点検 dengshen start
            let menteAns1 = Answer.NotDateForDb;
            // mod #10896 mnt_mainte_main.mainte_ans_1の登録データ不正 日常点検 dengshen end
            let isDisabled = false;
            const detailItem = detailConditionList.find(detail => (
              machineNo === detail.machineNo
              && menteLayoutCd === detail.menteLayoutCd
            ));
            if (detailItem) {
              devMenteNo = detailItem.devMenteNo;
              menteAns1 = detailItem.menteAns1;
            }
            // 対象外か否かの判定
            if (hasMachineData) {
              // いずれかのレイアウトでの点検結果データがある装置の場合
              if (!detailItem) {
                // 点検結果データがないレイアウトは対象外とする
                isDisabled = true;
              }
            } else {
              // 点検結果データがない装置の場合
              if (!isDispOn(layout) || !layout.detailInfo1) {
                // レイアウトが削除済みの場合、もしくは
                // レイアウトの点検項目情報がない場合は対象外とする
                isDisabled = true;
              } else {
                // 装置型式がグループの対象型式に含まれていなければ対象外とする
                const groupsInfo = JSON.parse(layout.detailInfo1);
                if (!groupsInfo.some(({ isDisp, cd }) => {
                  // レイアウトで選択されていないグループの場合はfalseを返す
                  if (!isDisp) return false;
                  const categoryMst = this.dailyCategoryList.find(
                    category => category.mainteCategoryCd === cd
                  );
                  // レイアウトで選択されているグループが
                  // 最新のグループマスタには存在しない場合はfalseを返す
                  if (!categoryMst) return false;
                  // グループマスタで点検項目が選択されていない場合はfalseを返す
                  if (!categoryMst.detailList.length) return false;
                  // 装置型式がグループマスタの対象型式に含まれているかを返す
                  // 装置型式が未指定の場合は「すべて」扱いとするための対応は
                  // dailyCategoryList の生成時に入っている
                  return categoryMst.typeCdList.includes(machine.machineTypeCd);
                })) {
                  isDisabled = true;
                }
              }
            }
            detailByLayoutList.push({
              devMenteNo,
              machineNo,
              menteDate,
              menteLayoutCd,
              menteAns1,
              isDisabled,
            });
            // mod #10896 mnt_mainte_main.mainte_ans_1の登録データ不正 日常点検 dengshen start
            if (menteAns1 === Answer.NotDateForDb && !isDisabled) {
            // mod #10896 mnt_mainte_main.mainte_ans_1の登録データ不正 日常点検 dengshen end
              machine.nonFlg = true;
            }
            if (menteAns1 !== Answer.Good && !isDisabled) {
              machine.passFlg = false;
            }
            if (menteAns1 === Answer.Running) {
              machine.unfinishedFlg = true;
            }
            if (menteAns1 === Answer.NotGood) {
              machine.unpassFlg = true;
            }
          });
          detailListMaster.push({
            machine,
            details: detailByLayoutList,
          });
        });
        this.inspectionList = detailListMaster;
      });
    },
    async reloadInspectionResult() {
      await this.executeWithLoadingScreen(async () => {
        const detailConditionRes = await sendRequestGetCheckResult(
          this.searchDate
        ).catch(error => {
          getErrorMessage("DailyInspectionListComponent.vue", "reloadInspectionResult", error);
        });
        const detailConditionList = detailConditionRes.data;
        // グリッド表示する情報を取得しなおした点検結果を反映したものに作りなおす
        // （this.inspectionListの要素のオブジェクトは作り直さないが
        // 　this.inspectionList自体はapplyConditionListと同様に
        // 　新たなArrayに差し替えることでそのリアクションによる表示更新を発生させる）
        // 装置行の表示判定のためのフラグ類は
        // 直前のapplyConditionList実行時に設定された状態のまま変更しない
        // グレーアウト判定結果についてもこの関数を通るケースでは
        // 既存の点検結果データが更新されたか、最新マスタに従って
        // 新規の点検結果データが追加されたという場面なので
        // （データがない装置がある状態からない状態に変化するケースでも）
        // グレーアウト判定結果やレイアウト列の表示状態が変化することはない想定
        // （他利用者が並行してマスタを変更しているようなケースは
        // 　この関数を使う場合ではもともと想定から外されている）
        this.inspectionList = this.inspectionList.map(inspectionItem => {
          const machineNo = inspectionItem.machine.machineNo;
          inspectionItem.details.forEach(detailByLayout => {
            const menteLayoutCd = detailByLayout.menteLayoutCd;
            const detailItem = detailConditionList.find(detail => (
              machineNo === detail.machineNo
              && menteLayoutCd === detail.menteLayoutCd
            ));
            if (detailItem) {
              detailByLayout.devMenteNo = detailItem.devMenteNo;
              detailByLayout.menteAns1 = detailItem.menteAns1;
            } else {
              detailByLayout.devMenteNo = null;
              // mod #10896 mnt_mainte_main.mainte_ans_1の登録データ不正 日常点検 dengshen start
              detailByLayout.menteAns1 = Answer.NotDateForDb;
              // mod #10896 mnt_mainte_main.mainte_ans_1の登録データ不正 日常点検 dengshen end
            }
          });
          return inspectionItem;
        });
      });
    },
    showFlg(sortListItem) {
      const condition = this.getCondition;
      if (!condition) return true;

      const targetMachine = sortListItem.machine;
      // 未実施を表示する判定
      if (condition.isNon && targetMachine.nonFlg) {
        // 未実施のレイアウトがある場合
        return true;
      }
      // 全件合格を表示する判定
      if (condition.isPass && targetMachine.passFlg) {
        // 合格以外のレイアウトはない場合
        return true;
      }
      // 点検途中を表示する判定
      if (condition.isUnfinished && targetMachine.unfinishedFlg) {
        // 点検途中のレイアウトがある場合
        return true;
      }
      // 不合格を表示する判定
      if (condition.isUnpass && targetMachine.unpassFlg) {
        // 不合格のレイアウトがある場合
        return true;
      }
      return false;
    },
    getDailyCheckAuthority() {
      return (
        this.hasAuthorityByCd(AUTHORITY_CODES.DEV_PEDIT)
        || this.hasAuthorityByCd(AUTHORITY_CODES.DEV_EDIT)
      );
    },
    async refresh() {
      await this.executeWithLoadingScreen(async () => {
        await this.applyConditionList();
        updateSort(Keys.defaultSort, this.sort);
      });
    },
    // マウスダウンイベント
    onMouseDown(event) {
      // マウス左ボタン押下の場合
      if (event.button == 0) {
        // マウスボ左タン押下状態
        this.isClicked = true;
      }
    },
    // マウスアップイベント
    onMouseUp(event) {
      // マウス左ボタン押下の場合
      if (event.button == 0) {
        // マウス左ボタン未押下状態
        this.isClicked = false;
      }
    },
    // 初期化イベント
    onInitialize(event) {
      // マウス左ボタン押下の場合
      if (event.button == 0) {
        // 初期化処理
        this.isClicked = false;
        this.isOvered = false;
      }
    },
    // マウスオーバーイベント
    onMouseOver() {
      // マウスオーバー状態
      this.isOvered = true;
    },
    // マウスリーブイベント
    onMouseLeave() {
      // マウス未オーバー状態
      this.isOvered = false;
    },
    // ID取得イベント
    onGetID(event) {
      // マウス左ボタン押下の場合
      if (event.button == 0) {
        // 対象IDの登録
        this.targetID = event.target.id;
      }
    },
    // ドラッグ開始イベント
    onDragStart(isScrollTableHeader) {
      // スクロールテーブルヘッダー かつ、対象ID ≠ "NULL"の場合
      if (isScrollTableHeader && this.targetID != "" && this.targetID != null) {
        // スクロールテーブル幅の設定
        this.setScrollTableWidth();
      }
      // テーブル高の同期
      this.syncTableHeight();
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
    },
    // ドラッグオーバーイベント
    onDragOver(event, isScrollTableHeader) {
      // ドラッグオーバーイベントの解除
      event.preventDefault();
      // 再帰処理
      this.intervalIDList.push(setInterval(function() {
        // スクロールテーブルヘッダー かつ、対象ID ≠ "NULL"の場合
        if (isScrollTableHeader && this.targetID != "" && this.targetID != null) {
          // スクロールテーブル幅の設定
          this.setScrollTableWidth();
        }
        // テーブル高の同期
        this.syncTableHeight();
        // 表示エリアサイズの設定
        this.setDisplayAreaSize();
        // 再帰処理の停止
        if (!this.isClicked && !this.isOvered) {
          // インターバルの削除
          this.disposeInterval();
          // 対象IDの削除
          this.targetID = null;
        }
      }.bind(this), 200));
    },
    // ドラッグ終了イベント
    onDragEnd(isScrollTableHeader) {
      // スクロールテーブルヘッダー かつ、対象ID ≠ "NULL"の場合
      if (isScrollTableHeader && this.targetID != "" && this.targetID != null) {
        // スクロールテーブル幅の設定
        this.setScrollTableWidth();
      }
      // テーブル高の同期
      this.syncTableHeight();
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
      // インターバルの削除
      this.disposeInterval();
      // 対象IDの削除
      this.targetID = null;
    },
    // マウスホイールイベント
    onWheel(event, name) {
      // 全体エリアスクロール状態の場合
      if (this.scrollState) {
        // スクロール(Y：横スクロール無し)状態の場合
        if (this.isScrollY) {
          // イベント発生元 = 固定エリアの場合
          if (name === Keys.fixedArea) {
            // 日付数の取得
            const cols = this.getScrollThCount();
            // 日付数 = "0"の場合
            if (cols === 0) {
              // スクロールトップの取得
              const scrollPosition = document.getElementById(Keys.fixedArea).scrollTop;
              // (固定エリア)スクロールの同期
              document.getElementById(Keys.fixedArea).scrollTop = scrollPosition + event.deltaY;
              // 終了
              return false;
            }
          } else if (name === Keys.scrollArea) {
            // シフトキー押下の場合
            if (event.shiftKey) {
               // 終了：シフトキー押下時は反応させないため、後続処理(縦軸移動)は実施しない
               return false;
            }
          }
        } else {
          // シフトキー押下の場合
          if (event.shiftKey) {
            // 終了：スクロールは横軸移動だけのため、後続処理(縦軸移動)は実施しない
            return false;
          }
        }
      } else {
        // イベント発生元 = 変動エリアの場合
        if (name === Keys.scrollArea) {
          // シフトキー押下の場合
          if (event.shiftKey) {
            // 終了：スクロールは横軸移動だけのため、後続処理(縦軸移動)は実施しない
            return false;
          }
        }
      }
      // 全体エリアスクロール状態 かつ スクロール(Y)状態以外の場合
      if (this.scrollState && !this.isScrollY) {
        // スクロールトップの取得
        const scrollPosition = document.getElementById(Keys.allArea).scrollTop;
        // (全体エリア)スクロールの同期
        document.getElementById(Keys.allArea).scrollTop = scrollPosition + event.deltaY;
      } else {
        // スクロールトップの取得
        const scrollPosition = document.getElementById(Keys.scrollArea).scrollTop;
        // (スクロールエリア)スクロールの同期
        document.getElementById(Keys.scrollArea).scrollTop = scrollPosition + event.deltaY;
      }
    },
    // マウススクロールイベント
    onScroll(event) {
      // 処理実行タイミングの最適化
      window.requestAnimationFrame(() => {
        // 縦スクロール(現在のスクロールトップ ≠ 前回のスクロールトップ)の場合
        if (event.target.scrollTop != this.scrollTopPosition) {
          // スクロール位置の設定
          this.setScrollPosition(event);
        }
        if (event.target.scrollWidth != 0) {
          // スクロールトップの保持
          const scrollArea = document.getElementById(Keys.scrollArea);
          const maxScrollTop = scrollArea.scrollHeight - scrollArea.clientHeight;
          const currentScrollTop = Math.min(Math.floor(event.target.scrollTop), maxScrollTop);
          if (maxScrollTop >= this.scrollTopPosition) {
            this.scrollTopPosition = currentScrollTop;
          }
          // 横スクロール位置の保持
          this.scrollLeftPosition = event.target.scrollLeft;
        }
      });
    },
    // インターバルの削除
    disposeInterval() {
      // 再帰処理IDs > "0"の場合
      if (this.intervalIDList.length > 0) {
        // 再帰処理の終了
        clearInterval(this.intervalIDList.shift());
      }
    },
    // スクロールテーブルの非表示列を除いたth要素の配列の取得
    getScrollThList() {
      return $(`#${Keys.scrollTable} th:visible`).get();
    },
    // スクロールテーブルの非表示列を除いたth要素の数を取得
    getScrollThCount() {
      return this.getScrollThList().length;
    },
    // バッファーの取得
    getBufferSize() {
      // 日付数の取得
      const cols = this.getScrollThCount();
      // バッファーの算出
      const borderWidthPx = 1;
      const paddingWidthPx = 8 * 2;
      this.buffer = (cols * (borderWidthPx + paddingWidthPx)) + borderWidthPx;
      // #11086対応時のメモ：
      // this.buffer はヘッダーセルのstyle.widthの値に含まれない
      // borderとpaddingを含めたテーブル全体の幅を計算するための値と思われる。
      // テーブルの幅を計算してテーブルのstyle.widthに設定している理由は不明だが
      // そうする場合には this.buffer の値を正確に計算しておかないと
      // ヘッダーセルの表示上の幅がstyle.widthの値と乖離してしまい
      // 列幅変更処理で設定値と見た目の幅がずれるなどの問題が起きる。
    },
    // テーブル高の同期
    syncTableHeight() {
      // テーブル行高の初期化
      this.initTableHeight();
      // テーブル行高の設定
      this.setTableHeight();
    },
    // テーブル行高の初期化
    initTableHeight() {
      // 行件数の取得
      const queryFixedTr = `#${Keys.fixedTable} tr`;
      const rows = $(queryFixedTr).length;
      // 行件数処理
      const queryScrollTr = `#${Keys.scrollTable} tr`;
      for (let i = 0; i < rows; i++) {
        // 固定テーブル行高の初期化
        $(queryFixedTr).eq(i).css("height", "");
        // スクロールテーブル行高の初期化
        $(queryScrollTr).eq(i).css("height", "");
      }
    },
    // テーブル行高の設定
    setTableHeight() {
      // 行件数の取得
      const queryFixedTr = `#${Keys.fixedTable} tr`;
      const rows = $(queryFixedTr).length;
      // 行件数処理
      const queryScrollTr = `#${Keys.scrollTable} tr`;
      for (let i = 0; i < rows; i++) {
        // 固定テーブル行の取得
        const fixedTableRow = $(queryFixedTr).get(i).getBoundingClientRect();
        // スクロールテーブル行の取得
        const scrollTableRow = $(queryScrollTr).get(i).getBoundingClientRect();
        // 固定テーブル行高の取得
        const fixedTableRowHeight = fixedTableRow.height;
        // スクロールテーブル行高の取得
        const scrollTableRowHeight = scrollTableRow.height;
        // 固定テーブル行高 > スクロールテーブル行高の場合
        if (fixedTableRowHeight > scrollTableRowHeight) {
          // 固定テーブル行高の設定
          $(queryFixedTr).eq(i).css("height", fixedTableRowHeight + "px");
          // スクロールテーブル行高の設定
          $(queryScrollTr).eq(i).css("height", fixedTableRowHeight + "px");
        } else {
          // 固定テーブル行高の設定
          $(queryFixedTr).eq(i).css("height", scrollTableRowHeight + "px");
          // スクロールテーブル行高の設定
          $(queryScrollTr).eq(i).css("height", scrollTableRowHeight + "px");
        }
      }
    },
    // 表示エリアサイズの設定
    setDisplayAreaSize() {
      // 固定エリアサイズの設定
      this.setFixedAreaSize();
      // スクロールエリアサイズの設定
      this.setScrollAreaSize();
      // スクロールバーの設定
      this.setScrollBar();
      // スクロール位置の設定
      this.setScrollPosition();
    },
    // 固定エリアサイズの設定
    setFixedAreaSize() {
      // -----height-----
      // ヘッダー高の取得
      const headerHeight = document.getElementsByClassName("header")[0].offsetHeight;
      // フッター高の取得
      const footerHeight = document.getElementById("footer-menu").clientHeight;
      // 画面表示幅 - ヘッダー高 - フッター高 - 調整高
      const fixedAreaHeight = this.getWindowHeight - headerHeight - footerHeight - 20;
      // 固定テーブル高の取得
      const fixedTableHeight = document.getElementById(Keys.fixedTable).clientHeight;
      // 固定エリア高 > 固定テーブル高
      if (fixedAreaHeight > fixedTableHeight) {
        // 横スクロールバーの高さ
        const scrollArea = document.getElementById(Keys.scrollArea);
        const scrollBarHeight = scrollArea.offsetHeight - scrollArea.clientHeight;
        // 固定テーブル高 + 調整高
        const val = fixedTableHeight + scrollBarHeight;
        // 固定エリア高の設定
        document.getElementById(Keys.fixedArea).style.height = val + "px";
        // スクロール調整エリアマージンの初期化
        document.getElementById(Keys.scrollAdjustArea).style.marginTop = "0px";
      } else {
        // 固定エリア高 - 調整高
        const val = fixedAreaHeight + (20 - 8);
        // 固定エリア高の設定
        document.getElementById(Keys.fixedArea).style.height = val + "px";
        // スクロール調整エリアマージンの固定化
        if (!this.isMobileDevice) {
          document.getElementById(Keys.scrollAdjustArea).style.marginTop = "18px";
        }
      }
    },
    // スクロールエリアサイズの設定
    setScrollAreaSize() {
      // -----height-----
      // ヘッダー高の取得
      const headerHeight = document.getElementsByClassName("header")[0].offsetHeight;
      // フッター高の取得
      const footerHeight = document.getElementById("footer-menu").clientHeight;
      // スクロールエリア高の計算
      const scrollAreaHeight = this.getWindowHeight - headerHeight - footerHeight - 20;
      // スクロールテーブル高の取得
      const scrollTableHeight = document.getElementById(Keys.scrollTable).clientHeight;
      // スクロールエリア高 > スクロールテーブル高
      if (scrollAreaHeight > scrollTableHeight) {
        // 横スクロールバーの高さ
        const scrollArea = document.getElementById(Keys.scrollArea);
        const scrollBarHeight = scrollArea.offsetHeight - scrollArea.clientHeight;
        // スクロールエリア高 + 調整高
        const val = scrollTableHeight + scrollBarHeight;
        // スクロールエリア高の設定
        document.getElementById(Keys.scrollArea).style.height = val + "px";
      } else {
        // スクロールエリア高 - 調整高
        const val = scrollAreaHeight + (20 - 8);
        // スクロールエリア高の設定
        document.getElementById(Keys.scrollArea).style.height = val + "px";
      }
      // -----width-----
      // サイドバー開閉有無の取得
      const sideBarIsOpen = document.getElementById("patientSearchSidebarArea").style.cssText.toString().indexOf("transform:") === -1;
      // 固定エリア幅の取得
      const fixedAreaWidth = document.getElementById(Keys.fixedArea).clientWidth;
      // サイドバー閉の場合
      if (!sideBarIsOpen) {
        // 画面表示幅 - 固定エリア幅 - 調整幅
        const val = this.getWindowWidth - fixedAreaWidth - 10;
        // スクロールエリア幅の設定
        document.getElementById(Keys.scrollArea).style.width = val + "px";
      } else {
        // 画面表示幅(サイドバー含む) - 固定エリア幅 - 調整幅
        const val = this.getMainWindowWidth - fixedAreaWidth - 11;
        // スクロールエリア幅の設定
        document.getElementById(Keys.scrollArea).style.width = val + "px";
      }
    },
    // スクロールテーブル幅の初期化
    initScrollTableWidth() {
      // 日付数の取得
      const cols = this.getScrollThCount();
      // 最小幅 * 日付数 + バッファー
      const val = this.minWidth * cols + this.buffer;
      // スクロールテーブル幅の設定
      document.getElementById(Keys.scrollTable).style.width = val + "px";
    },
    // スクロールテーブル幅の取得
    getScrollTableWidth() {
      // スクロールテーブル幅の初期値
      let val = 0;
      // 日付数の取得
      const scrollThList = this.getScrollThList();
      const cols = scrollThList.length;
      // 列件数処理
      for (let i = 0; i < cols; i++) {
        // ヘッダーの取得
        const th = scrollThList[i];
        // 日付列幅の取得
        const dateWidth = Number(th.style.width.replace("px", ""));
        // 日付列幅の加算
        val += dateWidth;
      }
      return val;
    },
    // スクロールテーブル幅の設定
    setScrollTableWidth() {
      // ヘッダーの取得
      let th = document.getElementById(this.targetID);
      // ヘッダー幅の取得
      const thWidth = Number(th.style.width.replace("px", ""));
      // 現在列幅の評価
      const currentWidth = this.evaluateCurrentWidth(thWidth, this.maxWidth, this.minWidth);
      // 基準(前回)列幅の取得
      const baseWidth = Number(th.style.getPropertyValue("--base-width").replace("px", ""));
      // スクロールテーブル幅の取得
      const scrollTableWidth = this.getScrollTableWidth();
      // スクロールテーブル幅の計算
      const val = this.calculateScrollTableWidth(scrollTableWidth, currentWidth, baseWidth);
      // スクロールテーブル幅の設定
      document.getElementById(Keys.scrollTable).style.width = val + this.buffer + "px";
      // 現在列幅の記録
      th.style.width = currentWidth + "px";
      // 基準(前回)列幅の記録
      th.style.setProperty("--base-width", currentWidth + "px");
    },
    // 現在列幅の評価
    evaluateCurrentWidth(targetWidth, maxWidth, minWidth) {
      // 評価
      if (targetWidth > maxWidth) {
        // 最大値：400px
        return maxWidth;
      } else if (targetWidth < minWidth) {
        // 最小値：150px or 30px
        return minWidth;
      } else {
        // 許容値：150px or 30px ～ 400px
        return targetWidth;
      }
    },
    // スクロールテーブル幅の計算
    calculateScrollTableWidth(scrollTableWidth, currentWidth, baseWidth) {
      // 現在幅 > 基準幅 もしくは、現在幅 < 基準幅
      if (currentWidth > baseWidth || currentWidth < baseWidth) {
        // スクロールテーブル幅 + 変化値
        return scrollTableWidth + (currentWidth - baseWidth);
      } else {
        // 同値
        return scrollTableWidth;
      }
    },
    // スクロールバーの設定
    setScrollBar() {
      // サイドバー開閉有無の取得
      const sideBarIsOpen = document.getElementById("patientSearchSidebarArea").style.cssText.toString().indexOf("transform:") === -1;
      // 固定エリア幅の取得
      const fixedAreaWidth = document.getElementById(Keys.fixedArea).clientWidth;
      // スクロールテーブル幅の取得
      const scrollTableWidth = this.getScrollTableWidth();
      // 日付数の取得
      const scrollThList = this.getScrollThList();
      const cols = scrollThList.length;
      // スクロールテーブル一列目幅の取得
      const scrollTableColumnWidth = cols > 0 ? scrollThList[0].clientWidth : 0;
      // 固定エリア幅 + スクロールテーブル一列目幅
      const val_1 = fixedAreaWidth + scrollTableColumnWidth;
      // 固定エリア幅 + スクロールテーブル幅 + バッファー
      const val_2 = fixedAreaWidth + scrollTableWidth + this.buffer;
      // サイドバー閉の場合
      if (!sideBarIsOpen) {
        // 画面表示幅 > 固定エリア幅 + スクロールテーブル一列目幅の場合
        if (this.getWindowWidth > val_1) {
          // 画面表示幅 > 固定エリア幅 + スクロールテーブル幅の場合
          if (this.getWindowWidth > val_2) {
            // 日付数 = "0"の場合
            if (cols == 0) {
              // 固定エリアオーバーフローの有効化
              this.enableFixedAreaOverflow();
            } else {
              // スクロールエリアオーバーフローの有効化
              this.enableScrollAreaOverflow(Keys.Y);
            }
            // スクロールテーブル幅 + バッファー
            const val = scrollTableWidth + this.buffer;
            // 全体エリアサイズの最適化
            this.optimizeAllAreaSize(true);
            // スクロールエリア幅の再設定
            document.getElementById(Keys.scrollArea).style.width = "auto";
            // スクロールテーブル幅の再設定
            document.getElementById(Keys.scrollTable).style.width = val + "px";
            // 全体エリアスクロール状態
            this.scrollState = true;
            // スクロール(Y)状態
            this.isScrollY = true;
          } else {
            // スクロールテーブル幅 + バッファー
            const val = scrollTableWidth + this.buffer;
            // スクロールエリアオーバーフローの有効化
            this.enableScrollAreaOverflow(Keys.XY);
            // 全体エリアサイズの最適化
            this.optimizeAllAreaSize(true);
            // スクロールテーブル幅の再設定
            document.getElementById(Keys.scrollTable).style.width = val + "px";
            // スクロールエリアスクロール状態
            this.scrollState = false;
            // スクロール(XY)状態
            this.isScrollY = false;
          }
        } else {
          // 全体エリアオーバーフローの有効化
          this.enableAllAreaOverflow();
          // 全体エリアサイズの最適化
          this.optimizeAllAreaSize(false);
          // 全体エリアスクロール状態
          this.scrollState = true;
          // スクロール(XY)状態
          this.isScrollY = false;
        }
      } else {
        // 画面表示幅(サイドバー含む) > 固定エリア幅 + スクロールテーブル一列目幅の場合
        if (this.getMainWindowWidth > val_1) {
          // 画面表示幅(サイドバー含む) > 固定エリア幅 + スクロールテーブル幅の場合
          if (this.getMainWindowWidth > val_2) {
            // 日付数 = "0"の場合
            if (cols == 0) {
              // 固定エリアオーバーフローの有効化
              this.enableFixedAreaOverflow();
            } else {
              // スクロールエリアオーバーフローの有効化
              this.enableScrollAreaOverflow(Keys.Y);
            }
            // スクロールテーブル幅 + バッファー
            const val = scrollTableWidth + this.buffer;
            // 全体エリアサイズの最適化
            this.optimizeAllAreaSize(true);
            // スクロールエリア幅の再設定
            document.getElementById(Keys.scrollArea).style.width = "auto";
            // スクロールテーブル幅の再設定
            document.getElementById(Keys.scrollTable).style.width = val + "px";
            // 全体エリアスクロール状態
            this.scrollState = true;
            // スクロール(Y)状態
            this.isScrollY = true;
          } else {
            // スクロールテーブル幅 + バッファー
            const val = scrollTableWidth + this.buffer;
            // スクロールエリアオーバーフローの有効化
            this.enableScrollAreaOverflow(Keys.XY);
            // 全体エリアサイズの最適化
            this.optimizeAllAreaSize(true);
            // スクロールテーブル幅の再設定
            document.getElementById(Keys.scrollTable).style.width = val + "px";
            // スクロールエリアスクロール状態
            this.scrollState = false;
            // スクロール(XY)状態
            this.isScrollY = false;
          }
        } else {
          // 全体エリアオーバーフローの有効化
          this.enableAllAreaOverflow();
          // 全体エリアサイズの最適化
          this.optimizeAllAreaSize(false);
          // 全体エリアスクロール状態
          this.scrollState = true;
          // スクロール(XY)状態
          this.isScrollY = false;
        }
      }
    },
    // 全体エリアオーバーフローの有効化
    enableAllAreaOverflow() {
      // オーバーフロー
      document.getElementById(Keys.allArea).style.overflow = "auto";
      document.getElementById(Keys.fixedArea).style.overflow = "initial";
      document.getElementById(Keys.scrollArea).style.overflow = "initial";
      // 位置
      document.getElementById(Keys.fixedArea).style.left = "auto";
      // 調整(1)
      document.getElementById(Keys.fixedArea).style.height = "max-content";
      document.getElementById(Keys.scrollAdjustArea).style.marginTop = "0px";
      // 調整(2)
      document.getElementById(Keys.scrollArea).style.height = "max-content";
    },
    // 固定エリアオーバーフローの有効化
    enableFixedAreaOverflow() {
      // オーバーフロー
      document.getElementById(Keys.allArea).style.overflow = "hidden";
      document.getElementById(Keys.fixedArea).style.overflowX = "hidden";
      document.getElementById(Keys.fixedArea).style.overflowY = "auto";
      document.getElementById(Keys.scrollArea).style.overflow = "hidden";
      // 位置
      document.getElementById(Keys.fixedArea).style.left = "auto";
      // 調整
      document.getElementById(Keys.scrollAdjustArea).style.marginTop = "0px";
    },
    // スクロールエリアオーバーフローの有効化
    enableScrollAreaOverflow(type) {
      // オーバーフロー
      document.getElementById(Keys.allArea).style.overflow = "hidden";
      document.getElementById(Keys.fixedArea).style.overflow = "hidden";
      if (type === Keys.XY) {
        document.getElementById(Keys.scrollArea).style.overflow = "auto";
        document.getElementById(Keys.fixedArea).style.overflowX = "scroll";
      } else {
        document.getElementById(Keys.scrollArea).style.overflowX = "hidden";
        document.getElementById(Keys.scrollArea).style.overflowY = "auto";
      }
      // 位置
      document.getElementById(Keys.fixedArea).style.left = "0";
    },
    // 全体エリアサイズの最適化
    optimizeAllAreaSize(isScrollAreaOverflow) {
      // スクロールエリアオーバーフローの場合
      if (isScrollAreaOverflow) {
        // 全体エリアの最大化
        document.getElementById(Keys.allArea).style.width = "max-content";
        document.getElementById(Keys.allArea).style.height = "max-content";
      } else {
        // 全体エリアの初期化
        document.getElementById(Keys.allArea).style.width = "auto";
        document.getElementById(Keys.allArea).style.height = "auto";
      }
    },
    // スクロール位置の設定
    setScrollPosition(event = null) {
      // イベント = "NULL"の場合
      if (event == null) {
        // スクロールトップの取得
        const scrollTop = document.getElementById(Keys.scrollArea).scrollTop;
        // (固定エリア)スクロール位置の同期
        document.getElementById(Keys.fixedArea).scrollTop = scrollTop;
      } else {
        // スクロールトップの取得
        const scrollTop = event.target.scrollTop;
        // (固定エリア)スクロール位置の同期
        document.getElementById(Keys.fixedArea).scrollTop = scrollTop;
      }
    },
    // レイアウトの再調整
    modifyLayout() {
      // テーブル高の同期
      this.syncTableHeight();
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
      setTimeout(() => {
        // ここまでのレイアウト計算処理結果によって
        // スクロールバーの表示状態が変化してからレイアウトを再計算する
        // （nextTickではDOMのレンダリング結果の変化を待てないようなのでsetTimeoutを使用する）
        // 表示エリアサイズの設定
        this.setDisplayAreaSize();
      });
    },
    // タッチ開始位置を記録
    onTouchStart(event) {
      if (event.touches.length === 1) {
        this.touchStartY = event.touches[0].clientY;
      }
    },
    // タッチ移動でスクロール処理
    onTouchMove(event) {
      if (event.touches.length === 1) {
        const currentY = event.touches[0].clientY;
        const deltaY = this.touchStartY - currentY;

        const fixedArea = document.getElementById(Keys.fixedArea);
        const scrollArea = document.getElementById(Keys.scrollArea);
        // 固定列スクロール
        fixedArea.scrollTop += deltaY;
        // 可動列スクロールを同期（補正なし）
        scrollArea.scrollTop = fixedArea.scrollTop;
        // 次の移動のために位置更新
        this.touchStartY = currentY;
      }
    },
  },
  watch: {
    getWindowHeight() {
      // レイアウトの再調整
      this.modifyLayout();
    },
    getWindowWidth() {
      // レイアウトの再調整
      this.modifyLayout();
    },
    getSidebarWidth() {
      // レイアウトの再調整
      this.modifyLayout();
    },
    getFontSize() {
      // 印刷中はスキップ
      if (this.isPrint) return;
      
      // レイアウトの再調整
      this.modifyLayout();
    },
    // レイアウトリストが変化したら
    // スクロールエリアの列幅変更用イベントハンドラを削除して
    // 設定しなおす
    layoutList() {
      // スクロールエリアの列幅変更用イベントハンドラを削除
      if (this.scrollColsResizeInfo) {
        removeColResizeListeners(this.scrollColsResizeInfo);
        this.scrollColsResizeInfo = null;
      }
      this.$nextTick(() => {
        // スクロールエリアの列幅変更用イベントハンドラを設定
        const scrollTable = document.getElementById(Keys.scrollTable);
        if (scrollTable?.rows?.[0]?.cells?.length) {
          this.scrollColsResizeInfo = addColResizeListeners(scrollTable.rows[0].cells);
        }
      });
    },
    // 登録データの監視
    sortList() {
      this.$nextTick(() => {
        // DOM更新前スクロールトップの保持
        this.beforeUpdateScrollTopPosition = this.scrollTopPosition;
        // DOMの更新時
        setTimeout(() => {
          // バッファーの取得
          this.getBufferSize();
          // スクロールテーブル幅の初期化
          this.initScrollTableWidth();
          // テーブル高の同期
          this.syncTableHeight();
          // 表示エリアサイズの設定
          this.setDisplayAreaSize();
          // 画面操作時のスクロール位置の設定
          const scrollArea = document.getElementById(Keys.scrollArea);
          scrollArea.scrollTop = this.beforeUpdateScrollTopPosition;
          scrollArea.scrollLeft = this.scrollLeftPosition;
          // 固定エリアのスクロール位置を設定
          this.setScrollPosition();
          setTimeout(() => {
            // ここまでのレイアウト計算処理結果によって
            // スクロールバーの表示状態が変化してからレイアウトを再計算する
            // （nextTickではDOMのレンダリング結果の変化を待てないようなのでsetTimeoutを使用する）
            // 表示エリアサイズの設定
            this.setDisplayAreaSize();
          });
        });
      });
    },
  },
  created() {
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.hasDailyCheckAuthority = this.getDailyCheckAuthority();

    EventBus.$off("filterDailyCheckList");
    EventBus.$off("dialogOkAdd");
    EventBus.$off("refreshData");

    EventBus.$on("filterDailyCheckList", this.applyConditionList);
    EventBus.$on("dialogOkAdd", this.applyConditionList);
    EventBus.$on("refreshData", this.refreshData);
    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestReportParams);
    EventBus.$on("refresh", this.refresh);

    // 休日マスタの休日を取得
    this.fetchHolidays(this.getFacilityCd);
  },
  mounted() {
    // 固定エリアの列幅変更用イベントハンドラを設定
    const fixedTable = document.getElementById(Keys.fixedTable);
    if (fixedTable?.rows?.[0]?.cells?.length) {
      this.fixedColsResizeInfo = addColResizeListeners(fixedTable.rows[0].cells);
    }
  },
  beforeDestroy() {
    // 固定エリアの列幅変更用イベントハンドラを削除
    if (this.fixedColsResizeInfo) {
      removeColResizeListeners(this.fixedColsResizeInfo);
      this.fixedColsResizeInfo = null;
    }
    // スクロールエリアの列幅変更用イベントハンドラを削除
    if (this.scrollColsResizeInfo) {
      removeColResizeListeners(this.scrollColsResizeInfo);
      this.scrollColsResizeInfo = null;
    }

    this.clearHolidays(); // storeの休日マスタをクリア
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("filterDailyCheckList", this.applyConditionList);
    EventBus.$off("dialogOkAdd", this.applyConditionList);
    EventBus.$off("refreshData", this.refreshData);
    EventBus.$off("requestReportParams", this.requestReportParams);

    // インターバルの削除
    this.disposeInterval();
    // 対象IDの削除
    this.targetID = null;

    Object.assign(this.$data, this.$options.data());
  },
};

// 点検レイアウト列でのソート指定時に使用するソート関数
// 点検レイアウト列：
// 　昇順：空欄→点検途中→不合格→合格→グレーアウト
// 　降順：合格→不合格→点検途中→空欄→グレーアウト
const compareLayoutAnswer = (itemA, itemB, isAsc, layoutCd) => {
  const key = "value";
  const [a, b] = [itemA, itemB].map(item => {
    // ソート対象のレイアウトの点検結果とグレーアウトの値を見て
    // グレーアウトなら null、グレーアウトでなければ
    // 点検結果の 空欄、点検途中、不合格、合格 の順のインデックスに
    // 置き換えた値でソートを行う
    const result = { [key]: null };
    const detail = item.details.find(
      detailItem => detailItem.menteLayoutCd === layoutCd
    );
    if (!detail || detail.isDisabled) {
      return result;
    }
    const menteAns1 = (detail.menteAns1 === Answer.NotDate)
      ? Answer.NotDateForDb
      : detail.menteAns1;
    const seq = [
      Answer.NotDateForDb,
      Answer.Running,
      Answer.NotGood,
      Answer.Good,
    ].indexOf(menteAns1);
    if (seq > -1) {
      result[key] = seq;
    }
    return result;
  });
  return sortableCompare(
    a, b, key, isAsc, {
      notUseSortKeyMap: true,
      nullOrderRule: { [key]: "last" },
    }
  );
};
</script>

<style>
@media print {
  /** 抽出条件エリアレイアウト崩れ回避 */
  body:has(#daily-inspection-condition-list) .header-item {
    height: auto;
  }
  #daily-inspection-condition-list {
    margin: 0 !important;
    padding-right: 0 !important;
    width: 38em;
    height: auto;
  }
}
</style>

<style scoped>
.list-header-th-center {
  text-align: center;
  background-color: rgb(175, 173, 173);
  height: 20px;
  color: #050505 !important;
  border: solid 1px var(--ntss-list-border-color);
}
#popover {
  margin: 5px 10px 5px 10px;
  position: relative;
}
.table {
  height: auto;
}
.confirm {
  margin-top: 10px;
  width: 100%;
  height: 40px;
}
.title-popup {
  font-size: 1.5em;
  width: 100%;
  text-align: center;
  color: var(--ntss-list-body-color);
}
.ok {
  float: right;
  width: 100px;
}
.custom-ntss-list th {
  padding: 4px 8px;
}
.custom-ntss-list .ntss-list-header-th-sticky {
  white-space: unset;
}
.ntss-list-body-td {
  min-width: 100px;
  color: var(--ntss-list-body-color);
}
.select-layout-tr {
  border: solid 1px #cccccc;
  background-color: var(--ntss-list-background-color);
}
.select-layout-td-header {
  text-align: center;
  color: var(--ntss-header-color);
  line-height: unset;
  padding-left: unset;
}
.select-layout-td {
  border: solid 1px #cccccc;
  color: var(--ntss-list-body-color);
}
.manual-width-scoped {
  overflow-x: hidden;
}
.ntss-list {
  width: max-content;
  min-width: 100%;
}

.resizable-head-container {
  display: flex;
  align-items: center;
  justify-content: left;
  position: relative;
  width: 100%;
  height: 100%;
  box-sizing: border-box;
}
span.span-grow-area {
  flex-grow: 1;
}
img.img-info-icon {
  flex-shrink: 0;
  display: block;
  cursor: pointer;
  height: 1.5em;
  width: 1.5em;
}

table th {
  line-height: unset;
}

.text-left {
  text-align: left;
}
.text-center {
  text-align: center;
}
.custom-no {
  max-width: 400px;
  min-width: 30px;
  width: 30px;
}
.custom-bed,
.custom-equip,
.custom-model
 {
  max-width: 400px;
  min-width: 150px;
  width: 150px;
}
.scroll-table {
  display: flex;
  height: auto;
  max-height: -webkit-fill-available;
  width: auto;
  width: max-content;
}
.fixed-area {
  left: 0;
  position: sticky;
  white-space: nowrap;
  will-change: transform;
  z-index: 999;
}
.scroll-area {
  margin-left: -1px;
  overflow-y: visible;
  will-change: transform;
  width: auto;
}
.ntss-list-table {
  background-color: var(--ntss-list-background-color);
  border-collapse: collapse;
  margin: 0;
  position: relative;
  top: 0px;
  width: -webkit-fill-available;
}
.modal-container .ntss-list-table,
.modal-container .modal-container,
.sub-modal-container .ntss-list-table {
  font-size: 1em;
}
.ntss-list-table tr:nth-child(2n) {
  background-color: var(--ntss-list-content-2nd-background-color);
}
.ntss-list-table tr {
  border-spacing: 0px;
  border-collapse: separate;
  background-color: var(--ntss-list-item-background-color);
  border-color: 1px solid var(--master-maintenance-kgrid-border-color);
}
.word-break-th {
  word-wrap: break-word;
}
.word-break-td {
  white-space: pre-wrap;
  word-break: break-all;
}
.cell-disabled {
  background-color: var(--pat-viewer-ind-cond-info-disabled);
}
/* 固定列・横スクロールバーの表示調整 */
.fixed-area {
  /* スクロールバーのつまみ部分とトラック部分の色 */
  scrollbar-color: var(--ntss-list-background-color) var(--ntss-list-background-color);
}
.fixed-area::-webkit-scrollbar-thumb {
  /* スクロールバーのつまみ部分の色 */
  background-color: var(--ntss-list-background-color);
}
.fixed-area::-webkit-scrollbar-track {
  /* スクロールバーのトラック部分の色 */
  background-color: var(--ntss-list-background-color);
}
.fixed-area::-webkit-scrollbar-button {
  /* スクロールバーの矢印を非表示にする */
  display: none;
}
@media print {
  #allArea {
    width: 100% !important;
  }
  
  /** 固定列、スクロールコンテナ */
  #fixedArea {
    overflow: visible !important;
    height: auto !important;
  }
  #scrollArea {
    overflow: hidden !important;
    height: auto !important;
  }
  
  /** テーブル */
  #fixedTable,
  #scrollTable {
    table-layout: fixed !important;
  }
  #fixedTable tr,
  #scrollTable tr {
    page-break-inside: avoid;
    break-inside: avoid;
  }
  
  /* 右端スクロール時はテーブルを右寄せ */
  #scrollArea:has(table.scroll-rightmost) {
    display: flex;
    justify-content: flex-end;
  }
}
</style>
