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
        id="allArea"
        class="scroll-table"
        style="position: sticky;"
      >
        <!-- 固定エリア -->
        <div
          id="fixedArea"
          class="fixed-area"
          @mousewheel="onWheel($event, 'fixedArea')"
          @touchstart="onTouchStart"
          @touchmove="onTouchMove"
        >
          <table
            id="fixedTable"
            class="ntss-list-table split-table"
            style="border-left: solid 1px var(--ntss-list-border-color);"
            :class="addClassInitTable"
          >
            <thead>
              <tr>
                <th class="custom-checkbox custom-header freeze ntss-list-header-th-sticky">
                  <v-ons-checkbox v-model="selectAll" :disabled="!hasDevEditAuthority"></v-ons-checkbox>
                </th>
                <th
                  id="bedName"
                  class="custom-bed custom-header freeze-vertical ntss-list-header-th-sticky word-break-th manual-width"
                  :class="[addClassInitheader, sortedClass('bedOrderIndex')]"
                  draggable="true"
                  @dragstart="onDragStart(false)"
                  @drag="onDragOver($event, false)"
                  @dragend="onDragEnd(false)"
                ><span @click="sortBy('bedOrderIndex')">ベッド</span></th>
                <th
                  id="machineName"
                  class="custom-equip custom-header freeze-vertical ntss-list-header-th-sticky word-break-th manual-width"
                  :class="[addClassInitheader, sortedClass('machineOrderIndex')]"
                  draggable="true"
                  @dragstart="onDragStart(false)"
                  @drag="onDragOver($event, false)"
                  @dragend="onDragEnd(false)"
                ><span @click="sortBy('machineOrderIndex')">装置名</span></th>
                <th
                  id="machineType"
                  class="custom-model custom-header freeze-vertical ntss-list-header-th-sticky word-break-th manual-width"
                  :class="[addClassInitheader, sortedClass('machineTypeCd')]"
                  draggable="true"
                  @dragstart="onDragStart(false)"
                  @drag="onDragOver($event, false)"
                  @dragend="onDragEnd(false)"
                ><span @click="sortBy('machineTypeCd')">型式</span></th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(item, index) in dataSourceSorted" :key="index">
                <td class="custom-checkbox freeze-horizontal ntss-list-body-td">
                  <v-ons-checkbox
                    v-model="item.machine.selected"
                    :disabled="!hasDevEditAuthority"
                    :value="false"
                    @change="onChangeSelect(item.machine.machineTypeCd, $event)"
                  />
                </td>
                <td
                  class="custom-bed freeze-horizontal ntss-list-body-td word-break-td"
                  @click="showHistorySearch(item)"
                >{{ item.machine.bedName }}</td>
                <td
                  class="custom-equip freeze-horizontal ntss-list-body-td word-break-td"
                  @click="showHistorySearch(item)"
                >
                  <img
                    v-if="getTheme === 0"
                    id="stop-watch-icon"
                    src="img/periodic-inspection/stop-watch.png"
                    @click.stop="showSomeThing(item.machine.machineTypeCd, item.machine.machineSerial)"
                  />
                  <img
                    v-else-if="getTheme === 1"
                    id="stop-watch-icon"
                    src="img/periodic-inspection/stop-watch-dark.png"
                    @click.stop="showSomeThing(item.machine.machineTypeCd, item.machine.machineSerial)"
                  />
                  <span>{{ item.machine.machineName }}</span>
                </td>
                <td
                  class="custom-model freeze-horizontal ntss-list-body-td word-break-td"
                  @click="showHistorySearch(item)"
                >{{ item.machine.machineType }}</td>
              </tr>
            </tbody>
          </table>
          <!-- スクロール調整エリア -->
          <div id="scrollAdjustArea" />
        </div>
        <!-- スクロールエリア -->
        <div
          id="scrollArea"
          class="scroll-area"
          @mousewheel="onWheel($event, 'scrollArea')"
          @scroll="onScroll"
        >
          <table
            id="scrollTable"
            class="ntss-list-table split-table"
            :class="addClassInitTable"
          >
            <thead>
              <tr
                @mouseover="onMouseOver"
                @mouseleave="onMouseLeave"
              >
                <th
                  v-for="item in listDate"
                  v-show="!getLoadingScreenVisible"
                  :key="item.dateString"
                  :id="`${item.dateString}`"
                  class="custom-col-date ntss-list-header-th-sticky word-break-th manual-width"
                  style="max-width: 400px; min-width: 150px; width: 150px; --base-width: 150px;"
                  :style="dateStyle(item)"
                  :class="sortedClass(item.dateString)"
                  draggable="true"
                  @mousedown="onGetID"
                  @dragstart="onDragStart(true)"
                  @drag="onDragOver($event, true)"
                  @dragend="onDragEnd(true)"
                >
                  <span
                    :class="getStyle(item.dateString)"
                    @click="showPopover($event, item.dateString)"
                  >{{ formatListDate(item) }}</span>
                </th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(item, index) in dataSourceSorted" :key="index">
                <td
                  v-for="(inspect, colIndex) in item.itemList"
                  v-show="!getLoadingScreenVisible"
                  :key="colIndex"
                  class="custom-xo freeze-horizontal ntss-list-body-td ntss-list-body-td-center word-break-td"
                  style="padding: 5.6px !important;"
                  @click="isCellBlank(inspect) && showResult(inspect, item, $event)"
                >
                  <span
                    v-if="!isCellBlank(inspect)"
                    style="width: 100%; height: 100%; padding: 0px"
                  >
                    <span
                      v-for="(groupName, groupIndex) in inspect.menteLayoutGroupName"
                      :key="groupIndex"
                    >
                      <span
                        style="vertical-align: text-top; white-space: pre-wrap; word-break: break-all;"
                        @click="showResult(inspect, item, $event, groupIndex)"
                      >
                        <span
                          v-if="isAnswerPass(inspect, groupIndex)"
                          class="inspected-radian-black"
                        >●</span>
                        <span
                          v-else-if="isAnswerProgress(inspect, groupIndex)"
                        >⦿</span>
                        <span
                          v-else-if="isAnswerFail(inspect, groupIndex)"
                          class="inspected-radian-red"
                        >●</span>
                        <span
                          v-else
                        >〇</span>
                        {{ groupName }}
                      </span><br />
                    </span>
                  </span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <!-- 日付列クリック時 吹き出し -->
    <v-ons-popover
      :class="[fontSizeSet, 'popover-content popover-content-header']"
      cancelable
      :visible.sync="popoverHeader.popoverVisible"
      :target="popoverHeader.popoverTarget"
      :direction="popoverHeader.popoverDirection"
    >
      <div class="popover-content-div">
        <v-ons-row class="popover-content-row">
          <v-ons-col class="popover-content-col">
            <v-ons-button
              class="btn4-alert button"
              :disabled="!hasDevEditAuthority"
              @click="cancelAllAtColumn(popoverHeader.dateString)"
            >一括中止</v-ons-button>
          </v-ons-col>
        </v-ons-row>
        <v-ons-row class="popover-content-row">
          <v-ons-col class="popover-content-col">
            <v-ons-button
              class="btn3-normal button"
              @click="sortBy(popoverHeader.dateString)"
            >ソート</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </v-ons-popover>
    <!-- セルクリック時 吹き出し -->
    <v-ons-popover
      cancelable
      :visible.sync="popoverInfo.popoverVisible"
      :target="popoverInfo.popoverTarget"
      :direction="popoverInfo.popoverDirection"
      :class="[fontSizeSet, 'popover-style']"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="popover-content-div">
        <v-ons-row
          class="popover-content-row"
          v-for="selectedInfo in popoverInfo.listvalue"
          :key="selectedInfo.id + selectedInfo.name"
        >
          <v-ons-col class="popover-content-col">
            <v-ons-button
              :class="`${selectedInfo.isAlert ? 'btn4-alert' : 'popover-content-button'} button ${selectedInfo.extClass}`"
              :disabled="selectedInfo.doAuthorityCheck && !hasDevEditAuthority"
              @click="updateData(selectedInfo)"
            >{{ selectedInfo.name }}</v-ons-button>
          </v-ons-col>
        </v-ons-row>
      </div>
    </v-ons-popover>
    <message-dialog
      :visible.sync="messageDialogInfo.confirmVisible"
      :message-cd="messageDialogInfo.messageCd"
      :type="messageDialogInfo.type"
      :title="messageDialogInfo.title"
      @confirm="confirm"
    />
  </v-card>
</template>

<script>
import { ApiHelper } from "@/apis/AxiosHelper";
import { deepCopy, getHolidayStyle } from "@/functions/common/CommonFunctions";
import { AUTHORITY_CODES } from "@/constants/userAuthority";
import { MainteClass } from "@/constants/mainteConstants";
import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import moment from "moment";
import { mapActions, mapGetters, mapMutations } from "vuex";
import { sendRequestGetAllMachine } from "@/apis/periodic-inspection";
import { EventBus } from "@/eventBus";
import messageDialog from "@/components/common/message-dialog/MessageDialog";
import PopoverMixin from "@/components/PopoverMixin";
import { getCurrentFunctionCd } from "@/router/routing-helper";
import { getErrorMessage } from "@/functions/common/AppLogMessageFormat";
import {
  popoverPosthide,
  popoverPostShow,
  popoverPreShow,
} from "@/functions/common/CommonPopoverFunctions";
import store from "@/stores";
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";
import {
  confirmIsOkByKey,
  alertByKey,
} from "@/functions/common/OnsenFunctions";
import {
  updateSort,
  getSortedClass,
  sortableCompare,
} from "@/functions/SortFunctions";
import $ from "jquery";
import PrintMixin from "@/components/PrintMixin";

const ScrollStartPostionState = Object.freeze({
  Initial: 0,
  AfterInitData: 1,
  AfterSetData: 2,
  AfterSetPositon: 3,
});

// 点検結果データがないセルに割り当てるデータ
const BlankData = Object.freeze({
  devMenteNo: null,
  facilityCd: null,
  menteClass: MainteClass.Periodic,
  machineNo: 0,
  recNo: null,
  menteDate: "",
  menteLayoutGroupCd: null,
  menteLayoutCd: 0,
  checkerId1: 0,
  checkerId2: null,
  menteAns1: "",
  menteAns2: null,
  menteComment1: null,
  menteComment2: null,
  detail: "[]",
  isDisp: "1",
  isDel: "0",
  upDate: "",
  menteLayoutGroupName: "",
  regDate: "",
});

const AnswerNone = ""; // 総合判定の値：入力無し
const AnswerPass = "1"; // 総合判定の値：合格
const AnswerProgress = "2"; // 総合判定の値：作業中
const AnswerFail = "3"; // 総合判定の値：不合格
const JudgeNone = ""; // 点検結果の値：入力無し

const ItemNameCancel = "予定中止";
const StateHaveResult = 1;
const StateNoResult = 2;
const TypeCancelOrShowResult = 1;
const TypeMove = 2;
const TypeAdd = 3;
// 点検予定あり点検結果ありセルクリック時のポップアップメニュー項目
const ListItemsHaveResult = Object.freeze([
  { id: 1, type: TypeCancelOrShowResult, name: ItemNameCancel, state: StateHaveResult, extClass: "btn1-execute", doAuthorityCheck: true, isAlert: true },
  { id: 2, type: TypeCancelOrShowResult, name: "点検記録", extClass: "btn3-normal", doAuthorityCheck: false, isAlert: false },
]);
// 点検予定あり点検結果なしセルクリック時のポップアップメニュー項目
const ListItemsNoResult = Object.freeze([
  { id: 1, type: TypeCancelOrShowResult, name: ItemNameCancel, state: StateNoResult, extClass: "btn1-execute", doAuthorityCheck: true, isAlert: true },
  { id: 2, type: TypeCancelOrShowResult, name: "点検記録", extClass: "btn3-normal", doAuthorityCheck: false, isAlert: false },
  { id: 2, type: TypeMove, name: "予定移動", extClass: "btn3-normal", doAuthorityCheck: true, isAlert: false },
]);
// type: 1 => 予定中止 or 点検記録、type: 2 => 予定移動、type: 3 => 予定追加
// state: 1 => 点検結果が登録済、state: 2 => 点検結果が未登録
// isAlert: true => 予定中止（背景色：赤） false => 予定中止以外（背景色：青）

export default {
  mixins: [PopoverMixin, ComponentGuardMixin, PrintMixin],
  components: {
    "message-dialog": messageDialog,
  },
  data() {
    return {
      authorityCds: [AUTHORITY_CODES.DEV_PEDIT, AUTHORITY_CODES.DEV_EDIT],
      hasDevEditAuthority: false,
      dataSourceList: [],
      isDialogVisible: true,
      dataSource: [],
      listDate: [],
      inspectSelected: null,
      machineSelected: null,
      popoverHeader: {
        popoverVisible: false,
        popoverTarget: null,
        popoverDirection: "down"
      },
      popoverInfo: {
        popoverVisible: false,
        popoverTarget: null,
        popoverDirection: "down",
        titleLabel: null,
        listvalue: [],
      },
      dateCancelAll: "",
      messageDialogInfo: {
        confirmVisible: false,
        messageCd: 11111111,
        type: "2",
        title: DIALOG_MESSAGES[11111111].title,
      },
      listLayoutGroup: [],
      sort: {
        key: "",
        isAsc: true,
      },
      dataArray: null,
      isClicked: false,
      isOvered: false,
      targetID: null,
      intervalIDList: [],
      buffer: 0,
      maxWidth: 400,
      minWidth: 150,
      beforeUpdateScrollTopPosition: 0,
      scrollTopPosition: 0,
      scrollLeftPosition: 0,
      scrollState: false,
      isScrollY: false,
      touchStartY: 0,
      iosFlg: false,
      androidFlg: false,
      setScrollStartPostionState: ScrollStartPostionState.Initial,
      scrollQuerySelector: ".scroll-area", // スクロールコンテナ
      addClassTargetQuerySelector: ["#scrollTable"] // scroll-rightmostクラスを付与する対象のクエリセレクタ      
    };
  },
  computed: {
    // add #11285 機能帳票の印刷情報対応② 高 start
    ...mapGetters("periodic-inspection", ["getStorSimlpSearchQurey"]),
    // add #11285 機能帳票の印刷情報対応② 高 end
    ...mapGetters("window-size", {
       windowHeight: "getWindowHeight",
       windowWidth: "getWindowWidth",
       mainWindowWidth: "getMainWindowWidth",
       sidebarWidth: "getSidebarWidth",
    }),
    ...mapGetters("account-edit", ["getTheme", "getFontSize"]),
    ...mapGetters("periodic-inspection", [
      "getListDataMaster",
      "getLayoutGroupList",
      "getLayoutGroupListByMachineType",
      "getMachineSelected",
      "getListMachine",
      "getSelectedCondition",
      "getSearchedMachineList",
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      "getHistoryParams",
      "getIsOpenBySubView",
      "getIsOpenByHistoryView",
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
    ]),
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("loading-screen", ["getLoadingScreenVisible"]),

    selectAll: {
      get() {
        return this.dataSourceCheckable.every(item => item.machine.selected);
      },
      set(value) {
        // 選択可能な装置のみを操作対象にする
        this.dataSourceCheckable.forEach(item => {
          item.machine.selected = value;
        });
      },
    },
    addClassInitheader() {
      const headerClass = {
        "ct-header": false,
      };
      if (!this.listDate.length && !this.dataSource.length) {
        headerClass["ct-header"] = true;
      }
      return headerClass;
    },
    addClassInitTable() {
      const headerClass = {
        "full-width": false,
      };
      if (!this.listDate.length && !this.dataSource.length) {
        headerClass["full-width"] = true;
      }
      return headerClass;
    },
    // デフォルトソート順
    //  - 第一ソートキー：mst_machine_type.model　昇順
    //  - 第二ソートキー：ベッドマスタ表示順昇順　空後方
    dataSourceSorted() {
      if (!this.dataSource.length) return [];

      const list = this.dataSource.slice();
      const { key, isAsc } = this.sort || {};
      if (!key) return list;

      // ** ソート用のフラグ値取得関数 **
      //  優先度: 〇＞⦿＞●赤＞● に該当する値を返す
      //  返り値: "": 〇 予定あり、"2": ⦿ 作業中、"3": ●赤 不合格、"1": ● 合格、null: 空欄
      const getFlagValue = (row) => {
        const item = row.itemList.find(i => i.temDate === key);
        if (!item) {
          // ソートキーに一致する日付列が存在しない場合はソート状態クリア
          this.sort = { key: "", isAsc: true };
          return null;
        }

        if (item.menteLayoutGroupName === "") return null;

        const flags = item.flag1 || [];
        const details = item.detailFlag || [];

        // 配列全体を対象に優先度順でチェック
        if (flags.some((f, idx) => (
          (f == AnswerNone || f == null) && details[idx] == null
        ))) return AnswerNone;
        if (flags.some((f, idx) => (
          f == AnswerProgress
          || ((f == AnswerNone || f == null) && details[idx] != null)
        ))) return AnswerProgress;
        if (flags.includes(AnswerFail)) return AnswerFail;
        if (flags.includes(AnswerPass)) return AnswerPass;

        return null; // 空欄
      };

      // ソート
      list.sort((a, b) => {
        // 装置列は共通関数でソート
        if (["bedOrderIndex", "machineOrderIndex", "machineTypeCd"].includes(key)) {
          return sortableCompare(a.machine, b.machine, key, isAsc);
        }

        // 日付列ソート（個別ソート）
        //  - 昇順　〇＞⦿＞●赤＞●＞空欄
        //  - 降順　●＞●赤＞⦿＞〇＞空欄
        //  - 複数存在の場合は、〇＞⦿＞●赤＞●の優先で1件にフォーカスしてソート
        const aVal = getFlagValue(a);
        const bVal = getFlagValue(b);

        if (aVal === bVal) return 0;

        // null は常に最後
        if (aVal == null || bVal == null) return aVal == null ? 1 : -1;

        // ランク表
        const rank = isAsc
          ? { [AnswerNone]: 1, [AnswerProgress]: 2, [AnswerFail]: 3, [AnswerPass]: 4 }
          : { [AnswerPass]: 1, [AnswerFail]: 2, [AnswerProgress]: 3, [AnswerNone]: 4 };

        // ランク差でソート
        return rank[aVal] - rank[bVal];
      });

      return list;
    },
    // dataSourceSorted を装置の型式に対応する
    // 点検レイアウトグループが存在するもののみに絞り込んだリスト
    dataSourceCheckable() {
      return this.dataSourceSorted.filter(item => (
        this.existsLayoutGroupByMachineTypeCd(item.machine.machineTypeCd)
      ));
    },
    isMobileDevice() {
      return this.iosFlg || this.androidFlg;
    },
  },
  methods: {
    ...mapActions("periodic-inspection", [
      "waitReadyToSearchByParam",
      "sendRequestGetAllLayoutGroup",
      "sendRequestLayoutGroupByMachineType",
      "sendRequestCreateMentePlan",
      "sendRequestCreateMenteTemp",
    ]),
    ...mapMutations("periodic-inspection", [
      "setListMachine",
      "setMachineSelected",
      "setListDataMaster",
      "setParamsGetDetail",
      "setMachine",
      "setParamsCalendar",
      "setBeforeModel",
      "setHistoryParams",
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      "setIsOpenBySubView",
      "setIsOpenByHistoryView",
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
    ]),
    ...mapActions("multi-modal", [
      "showPeriodicModal",
      "showPeriodicCalendar",
      "showMachineModal",
      "showHistoryModal",
      "hideModal",
    ]),
    ...mapActions("loading-screen", [
      "startLoadingScreen",
      "finishLoadingScreen",
      "executeWithLoadingScreen",
    ]),
    ...mapActions("mst-holiday", [
      "fetchHolidays",
      "clearHolidays",
    ]),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    isCellBlank(inspect) {
      return !inspect.menteDate || inspect.devMenteNo == null;
    },

    isAnswerPass(inspect, groupIndex) {
      return inspect.flag1[groupIndex] === AnswerPass;
    },
    isAnswerProgress(inspect, groupIndex) {
      const flag1 = inspect.flag1[groupIndex];
      return flag1 === AnswerProgress || (
        (flag1 === AnswerNone || flag1 == null)
        && inspect.detailFlag[groupIndex] != null
      );
    },
    isAnswerFail(inspect, groupIndex) {
      return inspect.flag1[groupIndex] === AnswerFail;
    },

    getDateParams(dateParam) {
      this.dataArray = dateParam;
    },
    requestrReportParams(param) {
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        // add #11285 機能帳票の印刷情報対応② 高 start
        let expressCondCdStr = "";
        if (this.getStorSimlpSearchQurey.rstDialysisState?.length) {
          if (this.getStorSimlpSearchQurey.rstDialysisState.length === 2) {
            expressCondCdStr = "予定・実績";
          } else if (this.getStorSimlpSearchQurey.rstDialysisState[0] == 1) {
            expressCondCdStr = "予定";
          } else {
            expressCondCdStr = "実績";
          }
        }
        const kurNames = this.getStorSimlpSearchQurey.kurNames?.length
          ? this.getStorSimlpSearchQurey.kurNames.join("・")
          : "すべて";
        const patGroups = this.getStorSimlpSearchQurey.selectedPatGroupNames
          ? this.getStorSimlpSearchQurey.selectedPatGroupNames
          : "すべて";
        const bedCdListString = JSON.parse(sessionStorage.getItem("bedGroupListPeriodic")) || [];
        const machineTypeName = JSON.parse(sessionStorage.getItem("machineInspectionPeriodic"))
          .replaceAll("、", "・") || "";
        // add #11285 機能帳票の印刷情報対応② 高 end
        // mod #11985 定期点検一覧帳票が正常に出せない limingzhe start
        const list = [];
        if (this.getListDataMaster.length) {
          list.push(...this.getListDataMaster);
          if (this.sort.key) {
            const { key, isAsc } = this.sort;
            list.sort((a, b) => {
              a = a.machine[key];
              b = b.machine[key];
              const sortItem1 = a === b ? 0 : a > b ? 1 : -1;
              const sortItem2 = isAsc ? 1 : -1;
              return sortItem1 * sortItem2;
            });
          }
        }
        const machineNos = list.map(x => x.machine.machineNo);
        // mod #11985 定期点検一覧帳票が正常に出せない limingzhe end
        const selectNos = this.getListDataMaster
          .filter(item => item.machine.selected)
          .map(x => x.machine.machineNo);
        // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
        if (this.getIsOpenByHistoryView) {
          // 定期点検(履歴)
          let fromDate = Date.now();
          let toDate = Date.now();
          if (this.getHistoryParams?.date != null) {
            fromDate = new Date(this.getHistoryParams.date);
            toDate = new Date(this.getHistoryParams.date);
          }
          if (this.getHistoryParams?.numOfYear != null) {
            fromDate = new Date(fromDate.setFullYear(
              fromDate.getFullYear() - this.getHistoryParams.numOfYear
            ));
          }
          const reportParams = {
            functionCd: "03301",
            facilityCd: this.getFacilityCd,
            date:  moment(toDate).format("YYYYMMDD"),
            fromDate: moment(fromDate).format("YYYYMMDD"),
            toDate: moment(toDate).format("YYYYMMDD"),
            machineNos: this.getHistoryParams?.machineNo != null ? [this.getHistoryParams.machineNo] : [],
            mainteNos: this.getHistoryParams?.devMenteNoArr != null ? this.getHistoryParams.devMenteNoArr : [],
            treatDate: this.getStorSimlpSearchQurey.treatDate,
            bedCdListString,
            freeWord: this.getStorSimlpSearchQurey.freeWord,
            expressCondCdStr,
            kurNames,
            patGroups,
            type: machineTypeName,
          };
          EventBus.$emit("sendReportParams", reportParams);
        }
        if (!this.getIsOpenBySubView && !this.getIsOpenByHistoryView) {
          // 定期点検(一覧)
          // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
          const fromDate = this.dataArray?.fromDate
            || this.dataArray?.toDate
            || moment(Date.now()).format("YYYYMMDD");
          const toDate = this.dataArray?.toDate
            || this.dataArray?.fromDate
            || moment(Date.now()).format("YYYYMMDD");
          const reportParams = {
            // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
            date: fromDate,
            fromDate,
            toDate,
            // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
            machineNos,
            facilityCd: this.getFacilityCd,
            selectNos,
            functionCd: "03301",
            // add #11285 機能帳票の印刷情報対応② 高 start
            treatDate: this.getStorSimlpSearchQurey.treatDate,
            bedCdListString,
            freeWord: this.getStorSimlpSearchQurey.freeWord,
            expressCondCdStr,
            kurNames,
            patGroups,
            type: machineTypeName,
            // add #11285 機能帳票の印刷情報対応② 高 end
          };
          EventBus.$emit("sendReportParams", reportParams);
        // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
        }
        // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      }
    },

    async postUpdate() {
      this.executeWithLoadingScreen(this.initData());
    },
    async confirm(answer) {
      this.isDialogVisible = false;
      if (answer !== "OK") return;

      this.popoverHeader.popoverVisible = false;
      // 画面に表示されている装置番号のリストを取得
      const dispMachineNos = this.dataSource.map(
        item => item.machine.machineNo
      );
      const params = {
        mainteDate: this.dateCancelAll,
        machineNoList: dispMachineNos,
      };
      await ApiHelper.post("mente-main/delele_mainte_by_temDate", params);
      this.postUpdate();
    },
    cancelAllAtColumn(dateCancel) {
      this.messageDialogInfo.confirmVisible = true;
      this.dateCancelAll = dateCancel;
    },
    showInspectionResult() {
      const selectedItem = this.machineSelected.itemList.find(
        x => x.menteDate === this.inspectSelected.menteDate
      );
      const {
        menteLayoutGroupCd,
        devMenteNo,
        menteLayoutCd,
        menteDate,
        letmenteLayoutGroupName,
        letmenteLayoutGroupNo,
        devMenteNoArr,
      } = selectedItem;
      const {
        machineTypeCd,
        machineNo,
      } = this.machineSelected.machine;
      const paramsGetDetail = {
        facilityCd: this.getFacilityCd,
        menteLayoutGroupCd,
        machineTypeCd,
        machineNo,
        devMenteNo,
        menteLayoutCd,
        menteDate,
        letmenteLayoutGroupName,
        letmenteLayoutGroupNo,
        devMenteNoArr,
      };
      this.setParamsGetDetail(paramsGetDetail);
      store.dispatch("report/getMstReport", { funcCd: "03301", printFlag: 1 });
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      this.setIsOpenBySubView(true);
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      this.showSubModals(this.showPeriodicModal);
    },
    showSubModals(callModalFunction, arg = []) {
      callModalFunction(arg);
    },
    showResult(inspect, machineItem, event, groupIndex = null) {
      // 編集権限がない場合は処理しない
      if (!this.hasDevEditAuthority) return;

      this.machineSelected = machineItem;
      const machineTypeCd = machineItem.machine.machineTypeCd;
      if (null != groupIndex) {
        // 点検予定があるセルの場合
        // クリックされたレイアウトグループの情報を設定する
        inspect.devMenteNo = inspect.devMenteNoArr[groupIndex];
        inspect.menteLayoutGroupCd = inspect.letmenteLayoutGroupNo[groupIndex];
      }
      this.inspectSelected = inspect;
      // 状況に応じたポップアップ表示
      const popoverDirection = (event.clientY < 600) ? "down" : "up";
      if (inspect.menteDate === "") {
        // 点検予定がないセルの場合
        const listLayoutGroup = this.getLayoutGroupByMachineTypeCd(machineTypeCd);
        if (!listLayoutGroup.length) {
          // 装置が対象となるレイアウトグループがない場合
          // title: "マスタ未登録エラー",
          // message: "対象型式のマスタが登録されていません。\nマスタを登録してください。",
          alertByKey(13000166);
          return;
        }
        this.popoverInfo.listvalue = listLayoutGroup;
        this.popoverInfo.popoverTarget = event;
        this.popoverInfo.popoverVisible = true;
        this.popoverInfo.popoverDirection = popoverDirection;
        return;
      }
      if (inspect.menteDate) {
        // 点検予定があるセルの場合
        if (
          inspect.detailFlag[groupIndex] == null
          && inspect.flag1[groupIndex] === AnswerNone
        ) {
          // 点検結果が未登録の場合
          this.popoverInfo.listvalue = ListItemsNoResult;
        } else {
          // 点検結果が登録済の場合
          this.popoverInfo.listvalue = ListItemsHaveResult;
        }
        this.popoverInfo.popoverTarget = event;
        this.popoverInfo.popoverVisible = true;
        this.popoverInfo.popoverDirection = popoverDirection;
        return;
      }
    },
    getLayoutGroupByMachineTypeCd(machineTypeCd) {
      const listLayoutGroup = [];
      this.getLayoutGroupListByMachineType.forEach(item => {
        if (item.typeInfo.includes(machineTypeCd)) {
          listLayoutGroup.push({
            type: TypeAdd,
            id: item.mainteLayoutGroupCd,
            name: item.groupName,
            extClass: "btn1-execute inline-show"
          });
        }
      });
      return listLayoutGroup;
    },
    existsLayoutGroupByMachineTypeCd(machineTypeCd) {
      return !!this.getLayoutGroupByMachineTypeCd(machineTypeCd).length;
    },
    showSomeThing(machineTypeCd, machineSerial) {
      const params = {
        facilityCd: this.getFacilityCd,
        machineTypeCd,
        machineSerial,
      };
      this.setMachine(params);
      this.setBeforeModel({ name: null });
      this.showSubModals(this.showMachineModal);
    },
    // mod #11582 定期点検画面不正 関 start
    async cancelInspection(hasResult) {
      if (hasResult) {
        // 点検結果入力済みの場合
        // title: "削除確認",
        // message: "点検結果登録済みです。点検結果も削除しますがよろしいですか？",
        const isOk = await confirmIsOkByKey(13000116);
        // キャンセルされたら処理を中断する
        if (!isOk) return;
      }

      const cancelIdList = [];
      this.inspectSelected.menteDate = "";
      if (
        this.inspectSelected.devMenteNo !== 0
        && this.inspectSelected.devMenteNo !== null
      ) {
        cancelIdList.push(this.inspectSelected.devMenteNo);
      }
      if (!cancelIdList.length) return;

      try {
        await this.sendRequestCreateMentePlan({ cancelIdList });
        this.postUpdate();
      } catch (error) {
        getErrorMessage(
          "PeriodicInspectionMainComponent.vue",
          "cancelInspection",
          error
        );
      }
    },
    // mod #11582 定期点検画面不正 関 end
    updateData(itemSelect) {
      switch (itemSelect.type) {
        case TypeCancelOrShowResult: {
          // 予定中止 or 点検記録
          this.popoverInfo.popoverVisible = false;
          if (itemSelect.name !== ItemNameCancel) {
            // 点検記録
            this.showInspectionResult();
          } else {
            // 予定中止
            this.cancelInspection(itemSelect.state === StateHaveResult);
          }
          break;
        }
        case TypeMove: {
          // 予定移動
          this.popoverInfo.popoverVisible = false;
          this.setMachineSelected([
            this.inspectSelected.machineNo,
          ]);
          this.setParamsCalendar({
            date: this.inspectSelected.menteDate,
            layoutGroupCd: this.inspectSelected.menteLayoutGroupCd,
            isModify: true,
          });
          this.showPeriodicCalendar();
          break;
        }
        case TypeAdd: {
          this.popoverInfo.popoverVisible = false;
          const layoutGroupId = itemSelect.id;
          // #11961対応時のメモ：
          // itemSelect.id の値は点検レイアウトグループのコード値であるが
          // sendRequestLayoutGroupByMachineType で取得された
          // getLayoutGroupListByMachineType の内容から作られており
          // API側のレスポンスの型定義により文字列となっている
          const { temDate } = this.inspectSelected;
          this.inspectSelected.menteLayoutGroupCd = layoutGroupId;
          this.setMachineSelected([
            this.machineSelected.machine.machineNo,
          ]);
          this.inspectSelected.menteDate = temDate;
          this.inspectSelected.isNewFromPast = true;

          const machineInfoList = this.getListMachine.filter(
            x => this.getMachineSelected.includes(x.machineNo)
          ).map(item => ({
            machineNo: String(item.machineNo),
            machineTypeCd: item.machineTypeCd,
          }));
          const params = {
            layoutGroupId,
            body: {
              machineInfoList,
              menteDateList: [temDate],
            },
          };
          this.sendRequestCreateMenteTemp(params).then(() => {
            this.postUpdate();
          });
          break;
        }
      }
    },
    // ヘッダ画面のdialogOkイベントのemitによりこの関数が呼び出される
    setDataSource(resultData) {
      // グリッドの行（装置）データを検索条件のベッドグループと型式に
      // 従って絞り込みなおす
      let dataSourceFiltered = [];
      const conditon = this.getSelectedCondition;
      if (!conditon || (
        conditon.bedGroupCd === null
        && !conditon.machineTypeList.length
      )) {
        // 型式とベッドグループがいずれも未選択の場合
        dataSourceFiltered = deepCopy(this.dataSourceList);
      } else if (
        conditon.bedGroupCd === null
        && conditon.machineTypeList.length
      ) {
        // 型式だけ選択された場合
        const list = this.dataSourceList.filter(
          data => conditon.machineTypeList.some(
            cd => data.machine.machineTypeCd === cd
          )
        );
        dataSourceFiltered = deepCopy(list);
      } else {
        // 型式とベッドグループが選択された場合
        // #10972対応時の調査メモ：
        // getSearchedMachineList の内容を取得する際にヘッダーの search で
        // Storeの setSearchedList に渡される検索条件を生成する処理では
        // 型式が未選択の場合に型式リストのすべての型式を入れた状態にするため
        // APIに渡される型式の条件が空になることはない
        // そのためベッドグループの条件が指定されている場合は
        // 画面上の型式条件の有無にかかわらず getSearchedMachineList による
        // 絞り込みを行えば型式とベッドグループの条件に沿った結果になる
        const list = [];
        this.getSearchedMachineList.forEach(item => {
          const { machineTypeCd, machineName, bedName } = item;
          const targetList = this.dataSourceList.filter(data => (
            data.machine.machineTypeCd === machineTypeCd
            && data.machine.machineName === machineName
            && data.machine.bedName === bedName
          ));
          if (targetList.length) {
            list.push(...targetList);
          }
        });
        dataSourceFiltered = deepCopy(list);
      }

      // グリッドの列（点検日）データを検索条件の表示期間に従って取得した
      // 点検結果リストから、行データの装置の点検結果が存在する日付の
      // リストとして生成する
      this.listDate = makeListDate(resultData, dataSourceFiltered);
      // 点検結果リストから列（点検日）データに対応した
      // 行データの装置の点検結果情報を設定する
      this.setItemList(dataSourceFiltered, resultData);

      this.dataSource = deepCopy(dataSourceFiltered);
      this.setListDataMaster(this.dataSource);

      if (this.setScrollStartPostionState === ScrollStartPostionState.AfterInitData) {
        // 画面開始時のスクロール位置設定処理状態を進める
        this.setScrollStartPostionState = ScrollStartPostionState.AfterSetData;
      }
    },
    setItemList(dataSource, resultData) {
      dataSource.forEach(dataItem => {
        const { machine } = dataItem;
        const dataListByMachine = [];
        const periodicByMachine = resultData.filter(
          item => item.machineNo === machine.machineNo
        );
        this.listDate.forEach(dateTime => {
          const temDate = dateTime.dateString;
          const periodicList = periodicByMachine.filter(
            item => item.menteDate === temDate
          );
          if (periodicList.length) {
            const periodic = periodicList[0];
            const menteLayoutGroupName = [];
            const menteLayoutGroupNo = [];
            const devMenteNoArr = [];
            const flag1 = [];
            const flag2 = [];
            const detailFlag = [];
            this.listLayoutGroup.forEach(layoutGroup => {
              for (let i = 0; i < periodicList.length; i++) {
                const {
                  menteLayoutGroupCd,
                  devMenteNo,
                  menteAns1,
                  menteAns2,
                  detail,
                } = periodicList[i];
                if (layoutGroup.id === menteLayoutGroupCd) {
                  menteLayoutGroupName.push(layoutGroup.name);
                  menteLayoutGroupNo.push(menteLayoutGroupCd);
                  devMenteNoArr.push(devMenteNo);
                  flag1.push(menteAns1);
                  flag2.push(menteAns2);
                  if (null != detail) {
                    const detailList = JSON.parse(detail);

                    // detailの各要素が[]で、且つ、もう片方が「1: 合格」の場合は
                    // inspect.flag1、inspect.flag2に「"1": 合格」を設定して、
                    // 各エリア0件の場合でも全件合格判定が行えるようにする
                    // detailList[0] -> 定期点検記録簿、detailList[1] -> 定期交換部品記録簿
                    if (!detailList[0].length && flag2[i] === AnswerPass) {
                      flag1[i] = AnswerPass;
                    }
                    if (!detailList[1].length && flag1[i] === AnswerPass) {
                      flag2[i] = AnswerPass;
                    }
                    // #11961対応時のメモ
                    // 点検結果レコードに menteAns2 というカラムは存在しないので
                    // (flag2[i] === AnswerPass) となることなく、
                    // さらに flag2 の値はとくに使っている箇所がないので
                    // 上の処理はおそらく現状不要になっているものと思われる
                    // （flag1 flag2 のインデックスとして i を使っているのも
                    // 　正しくないように思われる）

                    const flag = (
                      (detailList[0]?.some(item => JudgeNone != item.judge))
                      || (detailList[1]?.some(item => JudgeNone != item.judge))
                    ) ? detail : null;
                    detailFlag.push(flag);
                  } else {
                    detailFlag.push(null);
                  }
                }
              }
            });
            dataListByMachine.push({
              ...periodic,
              menteLayoutGroupName,
              letmenteLayoutGroupNo: menteLayoutGroupNo,
              devMenteNoArr,
              flag1,
              flag2,
              detailFlag,
              temDate,
            });
          } else {
            dataListByMachine.push({
              ...BlankData,
              temDate,
              machineNo: machine.machineNo,
            });
          }
        });
        dataItem.itemList = dataListByMachine;
      });
    },
    async refresh() {
      await this.initData();
    },
    async initData() {
      this.startLoadingScreen();
      this.listDate = [];
      this.dataSource = [];

      const [machineRes] = await Promise.all([
        sendRequestGetAllMachine(),
        this.sendRequestGetAllLayoutGroup(),
        this.sendRequestLayoutGroupByMachineType(),
      ]);
      if (this.getLayoutGroupList.length) {
        this.listLayoutGroup = this.getLayoutGroupList.map(item => ({
          id: item.menteLayoutGroupCd,
          name: item.groupName,
        }));
      } else {
        // 装置が対象となるレイアウトグループがない場合
        // title: "定期点検マスタ未登録",
        // message: "マスタが不足しているため定期点検機能は使えません。\nマスタを登録してください。",
        alertByKey(13000168);
      }
      this.setListMachine(machineRes.data);

      // this.dataSource の初期状態（全装置で点検結果情報は空）を作成
      this.dataSource = machineRes.data.map(machine => ({
        machine: {
          ...machine,
          selected: false,
        },
        itemList: [],
      }));
      this.setListDataMaster(this.dataSource);
      this.dataSourceList = deepCopy(this.dataSource);

      // #12499対応時のメモ：
      // 画面開始時には created を起点とする initData の中で
      // "searchByParam"イベントをemitしてヘッダー側の検索処理を起動するが、
      // 画面開始時の非同期処理のタイミングによっては
      // ヘッダー側が"searchByParam"イベントの購読を開始する前に
      // "searchByParam"イベントがemitされてしまい、
      // 初期検索の結果待ちの処理中表示のまま進行しなくなる場合があったため、
      // ヘッダー側で"searchByParam"イベントの購読が開始されている状態を待つ
      // 仕組みを追加した
      await this.waitReadyToSearchByParam();
      EventBus.$emit("searchByParam");

      this.finishLoadingScreen();
    },
    onChangeSelect(machineTypeCd, event) {
      if (
        event.target.checked
        && !this.existsLayoutGroupByMachineTypeCd(machineTypeCd)
      ) {
        // 選択しようとした装置が対象となるレイアウトグループがない場合
        // 選択を解除してメッセージ表示する
        event.target.checked = false;
        // title: "マスタ未登録エラー",
        // message: "対象型式のマスタが登録されていません。\nマスタを登録してください。",
        alertByKey(13000166);
        return;
      }
    },
    sortedClass(key) {
      return getSortedClass(key, this.sort);
    },
    // ソートするキーを設定する
    sortBy(key) {
      updateSort(key, this.sort);
    },
    // 日付列ヘッダクリック時
    showPopover(event, dateString) {
      this.popoverHeader.popoverTarget = event;
      this.popoverHeader.popoverVisible = true;
      this.popoverHeader.dateString = dateString;
    },
    formatListDate(item) {
      const week = moment(item.dateString).format("dd");
      return `${item.year}/${item.mounth}/${item.date} (${week})`;
    },
    dateStyle(item) {
      let result = {};
      const dateCurrent = moment(new Date()).format("YYYYMMDD");
      if (
        item.dateString !== "" &&
        moment(item.dateString).isSame(dateCurrent)
      ) {
        result["background-color"] = "#2ca06f";
      }
      return result;
    },

    /**
     * 休日のスタイル取得
     */
    getStyle(date) {
      return getHolidayStyle(date);
    },
    // マウスダウンイベント
    onMouseDown(event) {
      // マウス左ボタン押下の場合
      if (event.button == 0) {
        // マウス左ボタン押下状態
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
      if (isScrollTableHeader && this.targetID != "" && this.targetID != null && this.targetID != undefined) {
        // スクロールテーブル幅の設定
        this.setScrollTableWidth();
      }
      // テーブル高の同期
      this.syncTableHeight();
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
      // 固定テーブル列最小幅の補正
      this.resetFixedTableColumnMinWidth();
    },
    // ドラッグオーバーイベント
    onDragOver(event, isScrollTableHeader) {
      // ドラッグオーバーイベントの解除
      event.preventDefault();
      // 再帰処理
      this.intervalIDList.push(setInterval(function() {
        // スクロールテーブルヘッダー かつ、対象ID ≠ "NULL"の場合
        if (isScrollTableHeader && this.targetID != "" && this.targetID != null && this.targetID != undefined) {
          // スクロールテーブル幅の設定
          this.setScrollTableWidth();
        }
        // テーブル高の同期
        this.syncTableHeight();
        // 表示エリアサイズの設定
        this.setDisplayAreaSize();
        // 固定テーブル列最小幅の補正
        this.resetFixedTableColumnMinWidth();
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
      if (isScrollTableHeader && this.targetID != "" && this.targetID != null && this.targetID != undefined) {
        // スクロールテーブル幅の設定
        this.setScrollTableWidth();
      }
      // テーブル高の同期
      this.syncTableHeight();
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
      // 固定テーブル列最小幅の補正
      this.resetFixedTableColumnMinWidth();
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
          if (name === 'fixedArea') {
             // 日付数の取得
             const cols = $("#scrollTable th").length;
             // 日付数 = "0"の場合
             if (cols === 0) {
               // スクロールトップの取得
               const scrollPosition = document.getElementById("fixedArea").scrollTop;
               // (固定エリア)スクロールの同期
               document.getElementById("fixedArea").scrollTop = scrollPosition + event.deltaY;
               // 終了
               return false;
             }
          } else if (name === 'scrollArea') {
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
        if (name === 'scrollArea') {
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
        const scrollPosition = document.getElementById("allArea").scrollTop;
        // (全体エリア)スクロールの同期
        document.getElementById("allArea").scrollTop = scrollPosition + event.deltaY;
      } else {
        // スクロールトップの取得
        const scrollPosition = document.getElementById("scrollArea").scrollTop;
        // (スクロールエリア)スクロールの同期
        document.getElementById("scrollArea").scrollTop = scrollPosition + event.deltaY;
      }
    },
    // マウススクロールイベント
    onScroll(event) {
      // 処理実行タイミングの最適化
      window.requestAnimationFrame(async () => {
        // 縦スクロール(現在のスクロールトップ ≠ 前回のスクロールトップ)の場合
        if (event.target.scrollTop != this.scrollTopPosition) {
          // スクロール位置の設定
          await this.setScrollPosition(event);
        }
        if (event.target.scrollWidth != 0) {
          // スクロールトップの保持
          // dataSource変更時のwatch内でスクロールエリアの行高などを再設定する過程で高さが完全に設定されない状態の時にonScrollイベントが発生するため、
          // 縦スクロール可能な最大位置を取得して、操作時のスクロール位置が最大位置以下の場合のみ操作時のスクロール位置を退避する
          const scrollArea = document.getElementById("scrollArea");
          const maxScrollTop = scrollArea.scrollHeight - scrollArea.clientHeight;
          const maxScrollLeft = scrollArea.scrollWidth - scrollArea.clientWidth;
          const currentScrollTop = Math.min(Math.floor(event.target.scrollTop), maxScrollTop);
          if (maxScrollTop >= this.scrollTopPosition) {
            this.scrollTopPosition = currentScrollTop;
          }
          if (maxScrollLeft >= this.scrollLeftPosition) {
            this.scrollLeftPosition = event.target.scrollLeft;
          }
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
    // バッファーの取得
    getBufferSize() {
      // 日付数の取得
      const cols = $("#scrollTable th").length;
      // バッファーの算出
      this.buffer = cols * 30;
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
      const rows = $("#fixedTable tr").length;
      // 行件数処理
      for (let i=0; i < rows; i++) {
        // 固定テーブル行高の初期化
        $("#fixedTable tr").eq(i).css("height", "");
        // スクロールテーブル行高の初期化
        $("#scrollTable tr").eq(i).css("height", "");
      }
    },
    // テーブル行高の設定
    setTableHeight() {
      // 行件数の取得
      const rows = $("#fixedTable tr").length;
      // 行件数処理
      for (let i=0; i < rows; i++) {
        // 固定テーブル行の取得
        const fixedTableRow = $("#fixedTable tr").get(i).getBoundingClientRect();
        // スクロールテーブル行の取得
        const scrollTableRow = $("#scrollTable tr").get(i).getBoundingClientRect();
        // 固定テーブル行高の取得
        const fixedTableRowHeight = fixedTableRow.height;
        // スクロールテーブル行高の取得
        const scrollTableRowHeight = scrollTableRow.height;
        // 固定テーブル行高 > スクロールテーブル行高の場合
        if(fixedTableRowHeight > scrollTableRowHeight){
          // 固定テーブル行高の設定
          $("#fixedTable tr").eq(i).css("height", fixedTableRowHeight + "px");
          // スクロールテーブル行高の設定
          $("#scrollTable tr").eq(i).css("height", fixedTableRowHeight + "px");
        } else {
          // 固定テーブル行高の設定
          $("#fixedTable tr").eq(i).css("height", scrollTableRowHeight + "px");
          // スクロールテーブル行高の設定
          $("#scrollTable tr").eq(i).css("height", scrollTableRowHeight + "px");
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
      const fixedAreaHeight = this.windowHeight - headerHeight - footerHeight - 20;
      // 固定テーブル高の取得
      const fixedTableHeight = document.getElementById("fixedTable").clientHeight;
      // 固定エリア高 > 固定テーブル高
      if (fixedAreaHeight > fixedTableHeight) {
        // 横スクロールバーの高さ
        const scrollArea = document.getElementById("scrollArea");
        const scrollBarHeight = scrollArea.offsetHeight - scrollArea.clientHeight;
        // 固定テーブル高 + 調整高
        const val = fixedTableHeight + scrollBarHeight;
        // 固定エリア高の設定
        document.getElementById("fixedArea").style.height = val + "px";
        // スクロール調整エリアマージンの初期化
        document.getElementById("scrollAdjustArea").style.marginTop = "0px";
      } else {
        // 固定エリア高 - 調整高
        const val = fixedAreaHeight + (20 - 8);
        // 固定エリア高の設定
        document.getElementById("fixedArea").style.height = val + "px";
        // スクロール調整エリアマージンの固定化
        if (!this.isMobileDevice) {
          document.getElementById("scrollAdjustArea").style.marginTop = "18px";
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
      const scrollAreaHeight = this.windowHeight - headerHeight - footerHeight - 20;
      // スクロールテーブル高の取得
      const scrollTableHeight = document.getElementById("scrollTable").clientHeight;
      // スクロールエリア高 > スクロールテーブル高
      if (scrollAreaHeight > scrollTableHeight) {
        // 横スクロールバーの高さ
        const scrollArea = document.getElementById("scrollArea");
        const scrollBarHeight = scrollArea.offsetHeight - scrollArea.clientHeight;
        // スクロールエリア高 + 調整高
        const val = scrollTableHeight + scrollBarHeight;
        // スクロールエリア高の設定
        document.getElementById("scrollArea").style.height = val + "px";
      } else {
        // スクロールエリア高 - 調整高
        const val = scrollAreaHeight + (20 - 8);
        // スクロールエリア高の設定
        document.getElementById("scrollArea").style.height = val + "px";
      }
      // -----width-----
      // サイドバー開閉有無の取得
      const sideBarIsOpen = document.getElementById("patientSearchSidebarArea").style.cssText.toString().indexOf("transform:") === -1;
      // 固定エリア幅の取得
      const fixedAreaWidth = document.getElementById("fixedArea").clientWidth;
      // サイドバー閉の場合
      if (!sideBarIsOpen) {
        // 画面表示幅 - 固定エリア幅 - 調整幅
        const val = this.windowWidth - fixedAreaWidth - 10;
        // スクロールエリア幅の設定
        document.getElementById("scrollArea").style.width = val + "px";
      } else {
        // 画面表示幅(サイドバー含む) - 固定エリア幅 - 調整幅
        const val = this.mainWindowWidth - fixedAreaWidth - 11;
        // スクロールエリア幅の設定
        document.getElementById("scrollArea").style.width = val + "px";
      }
    },
    // スクロールテーブル幅の初期化
    initScrollTableWidth() {
      // 日付数の取得
      const cols = $("#scrollTable th").length;
      // 最小幅 * 日付数 + バッファー
      const val = this.minWidth * cols + this.buffer;
      // スクロールテーブル幅の設定
      document.getElementById("scrollTable").style.width = val + "px";
    },
    // スクロールテーブル幅の取得
    getScrollTableWidth() {
      // スクロールテーブル幅の初期値
      let val = 0;
      // 日付数の取得
      const cols = $("#scrollTable th").length;
      // 列件数処理
      for (let i=0; i < cols; i++) {
        // ヘッダーの取得
        const th = $("#scrollTable th")[i];
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
      const val = this.calculateScrollTableWidth(scrollTableWidth, currentWidth, baseWidth) + this.buffer;
      // スクロールテーブル幅の設定
      document.getElementById("scrollTable").style.width = val + "px";
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
        // 最小値：150px
        return minWidth;
      } else {
        // 許容値：150px ～ 400px
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
      const fixedAreaWidth = document.getElementById("fixedArea").clientWidth;
      // スクロールテーブル幅の取得
      const scrollTableWidth = this.getScrollTableWidth();
      // 日付数の取得
      const cols = $("#scrollTable th").length;
      // スクロールテーブル一列目幅の取得
      const scrollTableColumnWidth = cols > 0 ? $("#scrollTable th")[0].clientWidth : 0;
      // 固定エリア幅 + スクロールテーブル一列目幅
      const val_1 = fixedAreaWidth + scrollTableColumnWidth;
      // 固定エリア幅 + スクロールテーブル幅 + バッファー
      const val_2 = fixedAreaWidth + scrollTableWidth + this.buffer;
      // サイドバー閉の場合
      if (!sideBarIsOpen) {
        // 画面表示幅 > 固定エリア幅 + スクロールテーブル一列目幅の場合
        if (this.windowWidth > val_1) {
          // 画面表示幅 > 固定エリア幅 + スクロールテーブル幅の場合
          if (this.windowWidth > val_2) {
            // 日付数 = "0"の場合
            if (cols == 0) {
              // 固定エリアオーバーフローの有効化
              this.enableFixedAreaOverflow("Y");
            } else {
              // スクロールエリアオーバーフローの有効化
              this.enableScrollAreaOverflow("Y");
            }
            // スクロールテーブル幅 + バッファー
            const val = scrollTableWidth + this.buffer;
            // 全体エリアサイズの最適化
            this.optimizeAllAreaSize(true);
            // スクロールエリア幅の再設定
            document.getElementById("scrollArea").style.width = "auto";
            // スクロールテーブル幅の再設定
            document.getElementById("scrollTable").style.width = val +  "px";
            // 全体エリアスクロール状態
            this.scrollState = true;
            // スクロール(Y)状態
            this.isScrollY = true;
          } else {
            // スクロールテーブル幅 + バッファー
            const val = scrollTableWidth + this.buffer;
            // スクロールエリアオーバーフローの有効化
            this.enableScrollAreaOverflow("XY");
            // 全体エリアサイズの最適化
            this.optimizeAllAreaSize(true);
            // スクロールテーブル幅の再設定
            document.getElementById("scrollTable").style.width = val + "px";
            // スクロールエリアスクロール状態
            this.scrollState = false;
            // スクロール(XY)状態
            this.isScrollY = false;
          }
        } else {
          // 全体エリアオーバーフローの有効化
          this.enableAllAreaOverflow("XY");
          // 全体エリアサイズの最適化
          this.optimizeAllAreaSize(false);
          // 全体エリアスクロール状態
          this.scrollState = true;
          // スクロール(XY)状態
          this.isScrollY = false;
        }
      } else {
        // 画面表示幅(サイドバー含む) > 固定エリア幅 + スクロールテーブル一列目幅の場合
        if (this.mainWindowWidth > val_1) {
          // 画面表示幅(サイドバー含む) > 固定エリア幅 + スクロールテーブル幅の場合
          if (this.mainWindowWidth > val_2) {
            // 日付数 = "0"の場合
            if (cols == 0) {
              // 固定エリアオーバーフローの有効化
              this.enableFixedAreaOverflow("Y");
            } else {
              // スクロールエリアオーバーフローの有効化
              this.enableScrollAreaOverflow("Y");
            }
            // スクロールテーブル幅 + バッファー
            const val = scrollTableWidth + this.buffer;
            // 全体エリアサイズの最適化
            this.optimizeAllAreaSize(true);
            // スクロールエリア幅の再設定
            document.getElementById("scrollArea").style.width = "auto";
            // スクロールテーブル幅の再設定
            document.getElementById("scrollTable").style.width = val + "px";
            // 全体エリアスクロール状態
            this.scrollState = true;
            // スクロール(Y)状態
            this.isScrollY = true;
          } else {
            // スクロールテーブル幅 + バッファー
            const val = scrollTableWidth + this.buffer;
            // スクロールエリアオーバーフローの有効化
            this.enableScrollAreaOverflow("XY");
            // 全体エリアサイズの最適化
            this.optimizeAllAreaSize(true);
            // スクロールテーブル幅の再設定
            document.getElementById("scrollTable").style.width = val + "px";
            // スクロールエリアスクロール状態
            this.scrollState = false;
            // スクロール(XY)状態
            this.isScrollY = false;
          }
        } else {
          // 全体エリアオーバーフローの有効化
          this.enableAllAreaOverflow("XY");
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
      document.getElementById("allArea").style.overflow = "auto";
      document.getElementById("fixedArea").style.overflow = "initial";
      document.getElementById("scrollArea").style.overflow = "initial";
      // 位置
      document.getElementById("fixedArea").style.left = "auto";
      // 調整(1)
      document.getElementById("fixedArea").style.height = "max-content";
      document.getElementById("scrollAdjustArea").style.marginTop = "0px";
      // 調整(2)
      document.getElementById("scrollArea").style.height = "max-content";
    },
    // 固定エリアオーバーフローの有効化
    enableFixedAreaOverflow(type) {
      // オーバーフロー
      document.getElementById("allArea").style.overflow = "hidden";
      document.getElementById("fixedArea").style.overflowX = "hidden";
      document.getElementById("fixedArea").style.overflowY = "auto";
      document.getElementById("scrollArea").style.overflow = "hidden";
      // 位置
      document.getElementById("fixedArea").style.left = "auto";
      // 調整
      document.getElementById("scrollAdjustArea").style.marginTop = "0px";
    },
    // スクロールエリアオーバーフローの有効化
    enableScrollAreaOverflow(type) {
      // オーバーフロー
      document.getElementById("allArea").style.overflow = "hidden";
      document.getElementById("fixedArea").style.overflow = "hidden";
      if (type == "XY") {
        document.getElementById("scrollArea").style.overflow = "auto";
        document.getElementById("fixedArea").style.overflowX = "scroll";
      } else {
        document.getElementById("scrollArea").style.overflowX = "hidden";
        document.getElementById("scrollArea").style.overflowY = "auto";
      }
      // 位置
      document.getElementById("fixedArea").style.left = "0";
    },
    // 全体エリアサイズの最適化
    optimizeAllAreaSize(isScrollAreaOverflow) {
      // スクロールエリアオーバーフローの場合
      if (isScrollAreaOverflow) {
        // 全体エリアの最大化
        document.getElementById("allArea").style.width = "max-content";
        document.getElementById("allArea").style.height = "max-content";
      } else {
        // 全体エリアの初期化
        document.getElementById("allArea").style.width = "auto";
        document.getElementById("allArea").style.height = "auto";
      }
    },
    // スクロール位置の設定
    setScrollPosition(event = null) {
      // イベント = "NULL"の場合
      if (event == null) {
        // スクロールトップの取得
        const scrollTop = document.getElementById("scrollArea").scrollTop;
        // (固定エリア)スクロール位置の同期
        document.getElementById("fixedArea").scrollTop = scrollTop;
      } else {
        // スクロールトップの取得
        const scrollTop = event.target.scrollTop;
        // (固定エリア)スクロール位置の同期
        document.getElementById("fixedArea").scrollTop = scrollTop;
      }
    },
    // 固定テーブル列最小幅の補正
    resetFixedTableColumnMinWidth() {
      // 全体エリアスクロール状態の場合
      if (this.scrollState) {
        // -----ベッド-----
        // 列幅の取得
        const bedNameWidth = document.getElementById("bedName").style.width != "" ? Number(document.getElementById("bedName").style.width.replace("px", "")) : this.minWidth;
        // 現在列幅の評価
        const currentBedNameWidth = this.evaluateCurrentWidth(bedNameWidth, this.maxWidth, this.minWidth);
        // 最小列幅の設定
        document.getElementById("bedName").style.minWidth = currentBedNameWidth + "px";
        // -----装置名-----
        // 列幅の取得
        const machineNameWidth = document.getElementById("machineName").style.width != "" ? Number(document.getElementById("machineName").style.width.replace("px", "")) : this.minWidth;
        // 現在列幅の評価
        const currentMachineNameWidth = this.evaluateCurrentWidth(machineNameWidth, this.maxWidth, this.minWidth);
        // 最小列幅の設定
        document.getElementById("machineName").style.minWidth = currentMachineNameWidth + "px";
        // -----型式名-----
        // 列幅の取得
        const machineTypeWidth = document.getElementById("machineType").style.width != "" ? Number(document.getElementById("machineType").style.width.replace("px", "")) : this.minWidth;
        // 現在列幅の評価
        const currentMachineTypeWidth = this.evaluateCurrentWidth(machineTypeWidth, this.maxWidth, this.minWidth);
        // 最小列幅の設定
        document.getElementById("machineType").style.minWidth = currentMachineTypeWidth + "px";
      } else {
        // -----ベッド-----
        // 最小列幅の初期化
        document.getElementById("bedName").style.minWidth = "";
        // -----装置名-----
        // 最小列幅の初期化
        document.getElementById("machineName").style.minWidth = "";
        // -----型式名-----
        // 最小列幅の初期化
        document.getElementById("machineType").style.minWidth = "";
      }
    },
    showHistorySearch(item) {
      this.setHistoryParams({ searchDate: this.getSelectedCondition.endDate || null });
      this.showHistory(item);
    },
    showHistory(item) {
      if (item) {
        let devMenteNo, menteLayoutGroupCd;

        for (let i = 0; i < item.itemList.length; i++) {
          if (item.itemList[i].devMenteNo !== undefined) {
            devMenteNo = item.itemList[i].devMenteNo;
          }
          if (item.itemList[i].menteLayoutGroupCd !== undefined) {
            menteLayoutGroupCd = item.itemList[i].menteLayoutGroupCd;
          }

          if (devMenteNo !== undefined && menteLayoutGroupCd !== undefined) {
            break;
          }
        }
        if (menteLayoutGroupCd == null) {
          this.dataSource.forEach(data => {
            data.itemList.some(item => {
              if (item.menteLayoutGroupCd != null) {
                menteLayoutGroupCd = item.menteLayoutGroupCd;
                return true;
              }
              return false;
            });
          });
        }

        const paramsGetDetail = {
          facilityCd: this.getFacilityCd,
          menteLayoutGroupCd,
          machineTypeCd: item.machine.machineTypeCd,
          machineNo: item.machine.machineNo,
          devMenteNo,
          menteLayoutCd: null,
          menteDate: null,
          letmenteLayoutGroupName: null,
          letmenteLayoutGroupNo: null,
          devMenteNoArr: null,
        };
        this.setParamsGetDetail(paramsGetDetail);
      }
      // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      store.dispatch("report/getMstReport", { funcCd: "03301", printFlag: 2 });
      this.setIsOpenByHistoryView(true);
      // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
      this.showSubModals(this.showHistoryModal);
    },
    closeHistory() {
      this.hideModal();
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
      store.dispatch("report/getMstReport", { funcCd: "03301", printFlag: 0 });
      this.setIsOpenByHistoryView(false);
      // add #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
    },
    async closesMachineModal(obj) {
      await this.hideModal();
      if (obj.name === "PeriodicHistoryModel") {
        const { searchDate, numOfYear } = obj.data;
        this.setHistoryParams({
          searchDate,
          // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe start
          searchNumOfYear: numOfYear,
          // mod #12262 定期点検画面の機能帳票で装置毎の点検一覧と記録簿が出せない limingzhe end
        });
        this.showSubModals(this.showHistoryModal);
      } else if (obj.name === "PeriodicInspectionModal") {
        this.showSubModals(this.showPeriodicModal);
      }
    },
    // スクロール開始位置
    setScrollStartPostion() {
      const scrollArea = document.getElementById("scrollArea");
      // スクロール開始位置調整が不要な状況の場合は処理しない
      if (!scrollArea || scrollArea.scrollLeft !== 0) return;
      const cols = scrollArea.childNodes[0].childNodes[0].childNodes[0].childNodes;
      // スクロール部分がゼロ列の場合は処理しない
      if (!cols.length) return;
      // セル幅が有効な状態になっていなければ100ms後に再実行する
      if (!cols[0].scrollWidth) {
        setTimeout(() => {
          this.setScrollStartPostion();
        }, 100);
        return;
      }

      const today = moment().format("YYYY/MM/DD");
      let length = 0;
      for (let i = 0; i < cols.length; i++) {
        const date = cols[i].textContent.substring(0, 10);
        if (date >= today) {
          break;
        }
        length += cols[i].scrollWidth + 1;
      }
      scrollArea.scrollLeft = length;
    },
    // レイアウトの再調整
    modifyLayout() {
      // テーブル高の同期
      this.syncTableHeight();
      // 表示エリアサイズの設定
      this.setDisplayAreaSize();
      // 固定テーブル列最小幅の補正
      this.resetFixedTableColumnMinWidth();
      setTimeout(() => {
        // ここまでのレイアウト計算処理結果によって
        // スクロールバーの表示状態が変化してからレイアウトを再計算する
        // （nextTickではDOMのレンダリング結果の変化を待てないようなのでsetTimeoutを使用する）
        // 表示エリアサイズの設定
        this.setDisplayAreaSize();
        // 固定テーブル列最小幅の補正
        this.resetFixedTableColumnMinWidth();
      });
    },
    onTouchStart(event) {
      if (event.touches.length === 1) {
        this.touchStartY = event.touches[0].clientY;
      }
    },
    onTouchMove(event) {
      if (event.touches.length === 1) {
        const currentY = event.touches[0].clientY;
        const deltaY = this.touchStartY - currentY;
        const fixedArea = document.getElementById("fixedArea");
        const scrollArea = document.getElementById("scrollArea");
        fixedArea.scrollTop += deltaY;
        scrollArea.scrollTop = fixedArea.scrollTop;
        this.touchStartY = currentY;
      }
    },
  },
  watch: {
    // WindowHeightの監視
    windowHeight() {
      // レイアウトの再調整
      this.modifyLayout();
    },
    // WindowWidthの監視
    windowWidth() {
      // レイアウトの再調整
      this.modifyLayout();
    },
    // SideBarWidthの監視
    sidebarWidth() {
      // レイアウトの再調整
      this.modifyLayout();
    },
    // FontSizeの監視
    getFontSize() {
      // 印刷中はスキップ
      if (this.isPrint) return;

      // レイアウトの再調整
      this.modifyLayout();
    },
    // 登録データの監視
    dataSourceSorted() {
      // クリック対象情報のクリア
      this.inspectSelected = null;
      this.machineSelected = null;

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
          // 固定テーブル列最小幅の補正
          this.resetFixedTableColumnMinWidth();
          // 画面操作時のスクロール位置の設定
          // 一括中止、予定中止、予定登録、結果登録、予定移動をして画面更新した際にスクロール位置を操作時の位置にする
          const scrollArea = document.getElementById("scrollArea");
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
            // 固定テーブル列最小幅の補正
            this.resetFixedTableColumnMinWidth();
            if (this.setScrollStartPostionState === ScrollStartPostionState.AfterSetData) {
              // 画面開始時のスクロール位置設定処理状態を進める
              this.setScrollStartPostionState = ScrollStartPostionState.AfterSetPositon;
              // スクロール開始位置
              this.setScrollStartPostion();
            }
          });
        });
      });
    },
  },
  async created() {
    // 端末判別
    const ua = navigator.userAgent.toLowerCase();
    if (/android/.test(ua)) {
      this.androidFlg = true;
    } else if (/iphone|ipad|mac|os/.test(ua)) {
      this.iosFlg = true;
    }
    this.hasDevEditAuthority = this.hasAuthority();
    this.startLoadingScreen();
    // #10972対応時のメモ：
    // beforeDestroyでハンドラ指定なしのEventBus.$offを行うと
    // ホットリロード時にはホットリロード後のcreatedの後に
    // ホットリロード後のbeforeDestroyが実行されるため
    // ホットリロード後のcreatedでEventBus.$onしたハンドラが無効化されてしまう。
    // そのため次善の策としてbeforeDestroyではハンドラ指定ありのEventBus.$offを行い、
    // createdのEventBus.$onの前にハンドラ指定なしのEventBus.$offを行うようにしている。
    // ※await this.initData() より後の EventBus.$on については
    // 　ホットリロード後のbeforeDestroyより後に実行されるため
    // 　beforeDestroyでハンドラ指定なしのEventBus.$offを行っても上記の問題は起きない。
    // 　ここの"dialogOk"はthis.initDataを起点とする処理の中で呼ばれるイベントのため
    // 　その前にEventBus.$onを行わざるを得ない。
    EventBus.$off("dialogOk");
    EventBus.$on("dialogOk", this.setDataSource);
    await this.initData();
    // 画面開始時のスクロール位置設定処理状態を進める
    this.setScrollStartPostionState = ScrollStartPostionState.AfterInitData;

    EventBus.$on("postUpdate", this.postUpdate);
    // 印刷パラメータ要求
    EventBus.$on("requestReportParams", this.requestrReportParams);
    EventBus.$on("setDateParams", this.getDateParams);
    // 休日マスタの休日を取得
    await this.fetchHolidays(this.getFacilityCd);
    // モーダル制御
    EventBus.$on("showHistory", this.showHistory);
    EventBus.$on("closeHistory", this.closeHistory);
    EventBus.$on("closesMachineModal", this.closesMachineModal);
    EventBus.$on("refresh", this.refresh);
    this.finishLoadingScreen();
  },
  beforeDestroy() {
    this.clearHolidays(); // storeの休日マスタをクリア
    EventBus.$off("refresh", this.refresh);
    EventBus.$off("dialogOk", this.setDataSource);
    EventBus.$off("postUpdate", this.postUpdate);
    // 印刷パラメータ要求
    EventBus.$off("requestReportParams", this.requestrReportParams);
    EventBus.$off("setDateParams", this.getDateParams);
    // インターバルの削除
    this.disposeInterval();
    // 対象IDの削除
    this.targetID = null;
    // モーダル制御
    EventBus.$off("showHistory");
    EventBus.$off("closeHistory");
    EventBus.$off("closesMachineModal");

    Object.assign(this.$data, this.$options.data());
  },
};

// YYYY-MM-DD形式の日付文字列から this.listDate 用のオブジェクトを生成する
const makeListDateItem = (dateString) => {
  const [year, mounth, date] = dateString.split("-");
  return {
    dateString,
    date,
    mounth,
    year,
    timeValue: moment(dateString).valueOf(), // ソート処理用
  };
};
// 点検結果リストから this.listDate に入れる値を生成する
// dataSource が渡された場合は dataSource に存在する装置の
// 点検結果のみを対象とする
const makeListDate = (resultData, dataSource) => {
  const listDate = [];

  if (dataSource) {
    // dataSource が渡された場合は dataSource に存在する装置の
    // 点検結果のみを対象とする
    const machineNos = dataSource.map(item => item.machine.machineNo);
    resultData = resultData.filter(
      item => machineNos.includes(item.machineNo)
    );
  }

  resultData.forEach(({ menteDate }) => {
    if (
      menteDate && !listDate.some(
        dateTime => dateTime.dateString === menteDate
      )
    ) {
      listDate.push(makeListDateItem(menteDate));
    }
  });
  listDate.sort((a, b) => a.timeValue - b.timeValue);

  return listDate;
};

</script>

<style scoped>
.inspected {
  font-size: 1.2em;
  color: var(--ntss-list-body-color);
}
.non-inspected {
  font-size: 1.2em;
  color: blue;
}
.inspected-radian-black {
  font-family: monospace;
}
.inspected-radian-red {
  font-family: monospace;
  color: #FF6666;
}
.inspected-radian-spot {
  font-family: serif;
}
#popover {
  margin: 5px 10px 5px 10px;
  position: relative;
  height: 250px;
}
.table {
  height: 200px;
}
.popover-style >>> .popover,
.popover-style >>> .popover__content {
  width: 200px;
  min-height: 45px;
}
.popover-content >>> .popover--top,
.popover-content >>> .popover--right,
.popover-content >>> .popover--left,
.popover-content >>> .popover--bottom {
  width: initial;
}
.popover-content-header >>> .popover__content {
  width: 200px;
  min-height: auto;
}
.popover-content-div {
  margin: 5px;
}
.popover-content-row {
  margin-bottom: 10px;
}
.ntss-list-body-td-center {
  text-align: center;
}
.ntss-list-body-td {
  min-width: 150px;
  color: var(--ntss-list-body-color);
}
.confirmselec-group-layout {
  width: 100%;
  height: 23px;
}
.select-label-style {
  margin-top: 5px;
  font-size: 15px;
  color: black;
}

.dis-selected-color:hover {
  background-color: #dddddd;
}
.selected-color {
  color: white;
}
.botton-submit-area {
  width: 100%;
  position: absolute;
  bottom: 10px;
  height: 50px;
}
.submit {
  position: relative;
  float: right;
  width: 80px;
  margin-right: 20px;
  background-image: -webkit-gradient(
    linear,
    left top,
    left bottom,
    from(#b1cbd8),
    color-stop(30%, #2055cc),
    color-stop(50%, #3262af),
    to(#0f77ab)
  );
  background-image: linear-gradient(
    #b1cbd8 0%,
    #2055cc 30%,
    #3262af 50%,
    #0f77ab 100%
  );
}
.clear {
  position: relative;
  float: left;
  width: 80px;
  margin-left: 20px;
  background-image: -webkit-gradient(
    linear,
    left top,
    left bottom,
    from(#b1cbd8),
    color-stop(30%, #2055cc),
    color-stop(50%, #3262af),
    to(#0f77ab)
  );
  background-image: linear-gradient(
    #b1cbd8 0%,
    #2055cc 30%,
    #3262af 50%,
    #0f77ab 100%
  );
}
.split-table {
  border-spacing: 0;
  width: max-content;
  border-collapse: inherit !important;
}
.split-table th {
  padding: 4px 9px;
}
.split-table th,
.split-table td {
  border: solid var(--ntss-list-border-color);
  border-width: 0 1px 1px 0;
}
.custom-checkbox >>> .checkbox {
  margin-top: 2px;
}
.custom-col-date {
  z-index: 1;
  white-space: unset;
  text-align: center;
}
.custom-xo {
  z-index: 0;
}
.custom-header {
  white-space: unset;
  height: 2em;
}
.custom-header,
.custom-col-date {
  color: #ffffff;
}
.custom-data {
  background: #afadad;
  color: #000000;
}
.freeze {
  max-width: 50px;
  min-width: 50px;
  width: 50px;
  left: 0;
}
.freeze-vertical {
  max-width: 400px;
  min-width: 150px;
  width: 150px;
}
.freeze-horizontal {
  max-width: 400px;
  min-width: 150px;
  width: 150px;
}
.freeze,
.freeze-vertical {
  border: solid 1px var(--ntss-list-border-color);
  position: -webkit-sticky;
  position: sticky;
  top: 0;
}
.freeze,
.freeze-horizontal {
  border: solid 1px var(--ntss-list-border-color);
  left: 0;
}
.custom-bed,
.custom-equip,
.custom-model {
  text-align: left;
}
.custom-checkbox {
  max-width: 1.4em;
  min-width: 1.4em;
  width: 1.4em;
}
.custom-checkbox {
  text-align: center;
}
.custom-checkbox,
.custom-equip,
.custom-model,
.custom-bed {
  z-index: 4;
}
.freeze-horizontal.custom-checkbox,
.freeze-horizontal.custom-equip,
.freeze-horizontal.custom-model,
.freeze-horizontal.custom-bed {
  z-index: 3;
}
.ct-header {
  padding: 8px;
  position: relative;
  left: unset;
}
.full-width {
  width: 100%;
}
@media screen and (max-width: 620px) {
  .freeze,
  .freeze-vertical,
  .freeze-horizontal {
    position: relative;
    left: unset;
  }
  .custom-header,
  .custom-col-date {
    position: -webkit-sticky;
    position: sticky;
  }
}
.manual-width {
  resize: horizontal;
  overflow-x: hidden;
}
.inline-show {
  text-align: left;
  white-space: pre-wrap;
  word-break: break-all;
  line-height: 18px;
  display: inline-table;
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
#stop-watch-icon {
  float: left;
  width: 20px;
  height: 20px;
  z-index: 10001;
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
/* 一括中止アラートダイアログを手前に表示 */
ons-alert-dialog[modifier="rowfooter"] {
  z-index: 100001 !important;
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
