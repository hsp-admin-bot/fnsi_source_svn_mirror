/** * スケールベッド一覧 画面 */
<template>
  <div
    class="main-content-area master-maintenance-page status-list-page"
    :style="{ height: mainHeight + 'px' }"
  >
    <div :style="tableContainerStyle">
      <table class="ntss-list" :style="tableStyle">
        <thead>
          <tr>
            <th
              ref="gridComponent"
              v-for="(item, index) in dataColumns"
              :key="index"
              class="ntss-list-header-th-sticky manual-width"
              :style="{
                width: columnWidthList[index],
                'min-width': initialColumnWidthList[index] || item.minWidth,
              }"
            >
              <span
                v-if="item.sortable !== false"
                @click="setSort(item.field)"
                :class="sortedClass(item.field)"
                class="clickable-header-label"
              >
                {{ item.title }}
              </span>
              <!-- <span
                v-else
                class="clickable-header-label"
                style="cursor: default"
              > -->
              <span
                v-else
                class="clickable-header-label"
                style="cursor: default"
              >
                {{ item.title }}
              </span>
            </th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="(record, idx) in filteredDataSource"
            :key="idx"
            class="ntss-list-body-tr"
          >
            <template v-for="(col, cIdx) in dataColumns">
              <td
                v-if="col.field === 'bedName'"
                :key="col.field"
                :class="[getBedNameStateClass(record), 'ntss-list-body-td']"
                :style="{
                  width: columnWidthList[cIdx],
                  'min-width': columnWidthList[cIdx],
                }"
              >
                {{ record["bedName"] }}
              </td>
              <td
                v-if="col.field === 'hospPatId'"
                :key="col.field"
                class="ntss-list-body-td"
                :style="{
                  width: columnWidthList[cIdx],
                  'min-width': columnWidthList[cIdx],
                }"
              >
                {{ record["hospPatId"] }}
              </td>
              <td
                v-else-if="col.field === 'kurCd'"
                :key="col.field"
                class="ntss-list-body-td"
                :style="{
                  width: columnWidthList[cIdx],
                  'min-width': columnWidthList[cIdx],
                }"
              >
                {{ getKurName(record["kurCd"]) }}
              </td>
              <pat-name-cell-template
                v-else-if="col.field === 'patName'"
                :key="col.field"
                class="ntss-list-body-td"
                :data-item="record"
                field="patName"
                :style="{
                  width: columnWidthList[cIdx],
                  'min-width': columnWidthList[cIdx],
                }"
              ></pat-name-cell-template>
              <td
                v-else-if="col.field === 'rstDialysisState'"
                :key="col.field"
                class="ntss-list-body-td"
                :style="{
                  width: columnWidthList[cIdx],
                  'min-width': columnWidthList[cIdx],
                }"
              >
                <!-- 患者IDが空白の場合は空白表示 -->
                <template
                  v-if="
                    (!record['hospPatId'] || record['hospPatId'] === '') &&
                    record['ord_no']
                  "
                ></template>
                <template
                  v-else-if="
                    record['hospPatId'] &&
                    record['hospPatId'] !== '' &&
                    Number(record['rstDialysisState']) < 3
                  "
                >
                  透析前
                </template>
                <template v-else-if="Number(record['rstDialysisState']) === 3">
                  透析中
                </template>
                <template v-else-if="Number(record['rstDialysisState']) > 3">
                  透析後
                </template>
              </td>
              <td
                v-else-if="col.field === 'scaleValue'"
                :key="col.field"
                class="ntss-list-body-td"
                :style="{
                  width: columnWidthList[cIdx],
                  'min-width': columnWidthList[cIdx],
                }"
              >
                <span v-if="record['scaleValue']">{{
                  Number(record["scaleValue"]).toFixed(2)
                }}</span>
                <span v-else>-</span>
              </td>
              <td
                v-else-if="col.field === 'weightValue'"
                :key="col.field"
                class="ntss-list-body-td"
                :style="{
                  width: columnWidthList[cIdx],
                  'min-width': columnWidthList[cIdx],
                }"
              >
                <span v-if="record['weightValue'] != null">{{
                  record["weightValue"].toFixed(2)
                }}</span>
                <span v-else>-</span>
              </td>
              <td
                v-else-if="col.field === 'detail'"
                :key="col.field"
                :class="`${
                  record['isConnect'] !== '1'
                    ? 'process-state-td-99'
                    : record['sendStatus'] === 1
                    ? 'scale-bed-btn-error'
                    : record['sendStatus'] === 2
                    ? 'scale-bed-btn-warning'
                    : ''
                } ntss-list-body-td`"
                :style="{
                  width: columnWidthList[cIdx],
                  'min-width': columnWidthList[cIdx],
                  'text-align': 'center',
                }"
              >
                <!--次患者ある場合で、透析中の場合送信ボタンは非表示-->
                <v-ons-button
                  v-if="
                    Number(record['ordNo'] > 0) &&
                    Number(record['rstDialysisState']) !== 3
                  "
                  class="common-style-select-button btn3-normal"
                  @click="moveWeightPage(record)"
                  style="height: 2em; position: inherit"
                >
                  詳細
                </v-ons-button>
              </td>
              <td
                v-else-if="col.field === 'send'"
                :key="col.field"
                class="ntss-list-body-td"
                :style="{
                  width: columnWidthList[cIdx],
                  'min-width': columnWidthList[cIdx],
                  'text-align': 'center',
                }"
              >
                <!--未測定な場合もしくは、透析中、次患者がセットされていない場合送信ボタンは非表示-->
                <v-ons-button
                  v-if="
                    record['scaleValue'] &&
                    record['scaleValue'] > 0 &&
                    Number(record['rstDialysisState']) !== 3 &&
                    Number(record['processState']) !== 99 &&
                    record['sendStatus'] == 0 &&
                    Number(record['weightScaleStatus']) === 0 &&
                    Number(record['scaleClass']) === 2
                  "
                  class="common-style-select-button btn3-normal"
                  @click="sendCondition(record)"
                  style="height: 2em; position: inherit"
                >
                  送信
                </v-ons-button>
              </td>
              <td
                v-else-if="col.field === 'weightScaleStatus'"
                :key="col.field"
                class="ntss-list-body-td"
                :style="{
                  width: columnWidthList[cIdx],
                  'min-width': columnWidthList[cIdx],
                }"
              >
                <!-- weightScaleStatus =0 空白
                    weightScaleStatus =1 指示中 要確認
                    weightScaleStatus =2 （待機）？ 要確認
                    weightScaleStatus =3 送信成功
                    weightScaleStatus =4 送信失敗 -->
                <template
                  v-if="
                    record['scaleValue'] == null ||
                    Number(record['scaleValue']) === 0 ||
                    (Number(record['rstDialysisState']) == 3 &&
                      Number(record['sendStatus']) == 0) ||
                    (Number(record['rstDialysisState']) == 0 &&
                      Number(record['sendStatus']) == 0)
                  "
                ></template>
                <template
                  v-else-if="
                    (Number(record['weightScaleStatus']) === 3 ||
                      Number(record['rstDialysisState']) > 4 ||
                      Number(record['rstDialysisState']) === 1) &&
                    record['sendStatus'] == 0 &&
                    Number(record['scaleClass'] !== 2)
                  "
                >
                  成功
                </template>
                <template
                  v-else-if="
                    Number(record['sendStatus']) > 0 ||
                    Number(record['weightScaleStatus']) === 4
                  "
                >
                  失敗
                </template>
                <template v-else-if="Number(record['weightScaleStatus']) === 1">
                  指示中
                </template>
                <template v-else-if="Number(record['weightScaleStatus']) === 2">
                  待機中
                </template>
              </td>
            </template>
          </tr>
        </tbody>
      </table>
    </div>
    <div id="grid-footer">
      <div id="area_usage_guide" v-if="condition.isShowUsageGuide">
        <div class="usage-guide-div">
          <div
            class="usage-guide-element"
            style="background-color: white; border: silver solid 1px"
          ></div>
          次患者
        </div>
        <div class="usage-guide-div">
          <div
            class="usage-guide-element"
            style="background-color: #42cb92; border: #42cb92 solid 1px"
          ></div>
          前体重測定済
        </div>
        <div class="usage-guide-div">
          <div
            class="usage-guide-element"
            style="background-color: #2ca06f; border: #2ca06f solid 1px"
          ></div>
          治療中
        </div>
        <div class="usage-guide-div">
          <div
            class="usage-guide-element"
            style="background-color: #557769; border: #557769 solid 1px"
          ></div>
          治療終了
        </div>
        <div class="usage-guide-div">
          <div
            class="usage-guide-element"
            style="background-color: #00b0f0; border: #00b0f0 solid 1px"
          ></div>
          洗浄・消毒
        </div>
        <div class="usage-guide-div">
          <div class="usage-guide-element-alarm"></div>
          測定時エラー
        </div>
        <div class="usage-guide-div">
          <div class="usage-guide-element-info"></div>
          測定時警告
        </div>
        <div class="usage-guide-div">
          <div
            class="usage-guide-element"
            style="background-color: #ff6699; border: #ff6699 solid 1px"
          ></div>
          通信エラー
        </div>
        <div class="usage-guide-div">
          <div style="color: #a356a3">患者名</div>
          ：入院患者
        </div>
        <div style="display: flex">
          <div>患者名</div>
          ：外来患者
        </div>
      </div>
    </div>
    <scale-bed-web-socket-component
      @onReceiveMeasureValue="refresh"
      @onReceiveConnectStatus="refresh"
      @onReceiveSendConditionResults="refresh"
    ></scale-bed-web-socket-component>
  </div>
</template>

<script>
import { mapActions, mapGetters, mapMutations } from "@/compat/vue/vuex";
import NextTransitionMixin from "@/components/NextTransitionMixin";
import {
  getSortedClass,
  sortableCompare,
  addPatNameSortToList,
} from "@/functions/SortFunctions";
import PatNameCellTemplate from "@/components/status-list/sub-item/PatNameCellTemplate.vue";
import {
  sendRequestGetScaleBedViewList,
  sendRequestPostSendConditionScaleBed,
  sendRequestPostSendAfterWeightScaleBed,
} from "@/apis/scale-bed";
import { EventBus } from "@/compat/vue/event-bus.js";
import { SCALE_BED_AUTO_SETTING } from "@/constants/facilitySetting";
import { sendRequestGetMstFacilitySettingValue as getMstFacilitySettingValue } from "@/apis/facility-setting";
import ScaleBedWebSocketComponent from "./ScaleBedWebSocketComponent.vue";
import { tareG2Kg } from "@/functions/common/WeightFunctions";
import {
  addColResizeListeners,
  removeColResizeListeners,
} from "@/functions/common/ColResizeFunctions";
import { getHeaderHeight, getFooterMenuClientHeight, getLatestHeaderElement, getScopedElementById } from "@/functions/common/LayoutMeasureHelper";
// メッセージダイアログの定数
import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages";

// 印刷フラグの定数
const FLG_TRUE = 1;
const DEFAULT_COLUMN_WIDTH_LIST = [
  "100px",
  "120px",
  "120px",
  "80px",
  "100px",
  "100px",
  "100px",
  "100px",
  "100px",
  "100px",
];

/**
 * @typedef scaleBedListDataSource
 * @property { string | null } isConnect 接続状況
 * @property { number } ordNo オーダー番号
 * @property { number } bedCd ベッドコード
 * @property { string } bedName ベッド名
 * @property { number } bedGroupCd ベッドグループコード
 * @property { number } kurCd クールコード
 * @property { string } kurName クール名
 * @property { number } patId 患者ID
 * @property { string } hospPatId 患者院内ID
 * @property { string } patName 患者名
 * @property { string } inOutClass 入院外来区分
 * @property { string } isSame 同名患者フラグ
 * @property { number } rstDialysisState ステータス
 * @property { string } scaleValue 測定値(kg)
 * @property { string } sendStatus 0: 正常 1: 前体重異常 2: 前体重警告 3: 後体重異常 4: 後体重警告
 * @property { string } detail 詳細
 * @property { number } weightScaleStatus 結果
 * @property { string } processState 工程状態
 * @property { number } comFormatCd 通信フォーマット
 * @property { string } comType 通信種別
 * @property { string } indTareInfo 指示風袋値
 * @property { string } patLastNameKana カナ性
 * @property { string } patFirstNameKana カナ名
 * @property { string } indTareInfo 指示風袋値
 * @property { string } rstTareInfo 実績風袋値
 * @property { long } bedOrderIndex ベッド名の並び順データ
 * @property { long } wheelChairCd 車いすコード
 * @property { number } isWheelChair 車いす測定患者フラグ
 * @property { string } weightBefore 測定値(kg)
 */

export default {
  mixins: [NextTransitionMixin],
  components: {
    PatNameCellTemplate,
    ScaleBedWebSocketComponent,
  },
  data() {
    return {
      /** @type { scaleBedListDataSource[] } */
      dataSource: [],
      toolbarHeight: 500,
      mainAreaHeight: 300,
      mainHeight: 300,
      selfScreenName: "",
      refreshInterval: 30000,
      scaleBedAfterFlg: 5,
      timerId: null,
      colResizeInfo: null,

      /** データカラム定義 */
      dataColumns: [
        {
          field: "bedName",
          title: "ベッド名",
          minWidth: `${80}px`,
        },
        {
          field: "hospPatId",
          title: "患者ID",
          text: "hospPatId",
          minWidth: `${80}px`,
        },
        {
          field: "patName",
          title: "患者名",
          minWidth: `${80}px`,
        },
        {
          field: "kurCd",
          title: "クール",
          minWidth: `${80}px`,
        },
        {
          field: "rstDialysisState",
          title: "ステータス",
          minWidth: `${80}px`,
        },
        {
          field: "scaleValue",
          title: "測定値[kg]",
          minWidth: `${80}px`,
        },
        {
          field: "weightValue",
          title: "体重値[kg]",
          minWidth: `${80}px`,
        },
        {
          field: "detail",
          title: "詳細",
          minWidth: `${80}px`,
          //ソート不可
          sortable: false,
        },
        {
          field: "send",
          title: "送信",
          minWidth: `${80}px`,
          //ソート不可
          sortable: false,
        },
        {
          field: "weightScaleStatus",
          title: "結果",
          minWidth: `${80}px`,
          //ソート不可
          sortable: false,
        },
      ],
      columnWidthList: [...DEFAULT_COLUMN_WIDTH_LIST],
      initialColumnWidthList: [...DEFAULT_COLUMN_WIDTH_LIST],
    };
  },
  computed: {
    ...mapGetters("scale-bed/list", [
      "getFilterParam",
      "getSortSetting",
      "getKurListData",
      "getMstBedGroupList",
      "getColumnResizeData",
    ]),
    ...mapGetters("send-condition/weight", ["getMstWeightList"]),
    ...mapGetters("window-size", {
      windowHeight: "getWindowHeight",
      windowWidth: "getWindowWidth",
    }),
    ...mapGetters("account-edit", {
      isDispMenu: "isDispMenu",
      getFontSize: "getFontSize",
      getStateUserAccountInfo: "getStateUserAccountInfo",
    }),
    ...mapGetters("user", ["getFacilityCd"]),
    condition() {
      const filter = this.getFilterParam;
      return {
        isShowUsageGuide: !filter.notUsageGuide,
        filteredKurCdList: filter.kurCdList,
        filteredBedGroupCd: filter.bedGroupCd,
      };
    },
    tableContainerStyle() {
      if (this.condition.isShowUsageGuide) {
        return {
          height: this.mainAreaHeight + "px",
          overflowX: "auto",
          overflowY: "auto",
          position: "relative",
        };
      }
      return {
        overflowX: "auto",
        position: "relative",
      };
    },
    tableStyle() {
      const tableWidth = this.columnWidthList.reduce((sum, width) => {
        const parsed = parseFloat(width);
        return sum + (isNaN(parsed) ? 0 : parsed);
      }, 0);
      return {
        width: `${tableWidth}px`,
        tableLayout: "fixed",
      };
    },
    /**
     * @description 絞り込み・ソート後のデータソース取得
     * @return { Array } 絞り込み・ソート後のデータソース
     */
    filteredDataSource() {
      let result = addPatNameSortToList(this.dataSource);

      // クール絞り込み
      if (
        this.condition.filteredKurCdList &&
        this.condition.filteredKurCdList.length > 0
      ) {
        result = result.filter((item) =>
          this.condition.filteredKurCdList.includes(item.kurCd)
        );
      }

      // ベッドグループ絞り込み
      if (this.condition.filteredBedGroupCd) {
        result = result.filter((item) => {
          const bedGroup = this.getMstBedGroupList.find(
            (bg) => bg.roomBedGroupCd === this.condition.filteredBedGroupCd
          );
          // bedGroup.bedListには、'[2217, 2575, 2410, 3136]'のように格納されるため、JSON.parseで配列に変換してからincludesで判定する
          return (
            bedGroup !== null &&
            bedGroup.bedList &&
            JSON.parse(bedGroup.bedList).includes(item.bedCd)
          );
        });
      }

      // ソート
      if (
        this.getSortSetting.sortColumn &&
        this.getSortSetting.sortKind !== "normal"
      ) {
        result = result
          .slice()
          .sort((a, b) =>
            sortableCompare(
              a,
              b,
              this.getSortSetting.sortColumn,
              this.getSortSetting.sortKind === "asc"
            )
          );
      }

      return result;
    },
    /**
     * 印刷設定
     */
    isPrint: {
      get() {
        return this.getIsPrint;
      },
      set(value) {
        // 印刷モードセット
        this.setPrintMode(value);
      },
    },
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
  },
  methods: {
    // 共通ローダー設定
    ...mapActions("loading-screen", {
      setLoadingScreenVisible: "setLoadingScreenVisible",
      setLoadingScreenMessage: "setLoadingScreenMessage",
      resetLoadingScreenVisibleCount: "resetLoadingScreenVisibleCount",
    }),
    ...mapActions("treatment-record/common", [
      "setOrdNo",
      "setOrdNoForSideBarRecord",
      "setOrd",
    ]),
    ...mapActions("send-condition/scale", [
      "setSelectOrdNo",
      "setInputPatId",
      "setBaseOrdWeightNo",
      "setPrintMode",
      "sendPrintOrder",
    ]),
    ...mapActions("send-condition/scale/setting", [
      "setWeightConfigInfo",
      "clearWeightConfigInfo",
    ]),
    ...mapActions("scale-bed/list", ["setSortSetting", "setColumnResizeData"]),
    ...mapActions("scale-bed/send-cond", ["setScaleBedToWeightView"]),
    ...mapActions("send-condition/weight", [
      "fetchMstWeightList",
      "setMstWeightListByScaleBed",
      "selectMstWeightByCd",
    ]),
    ...mapMutations("pat-info", {
      setSrcFuncName: "setSrcFuncName",
    }),
    /** ベッド名のバックカラーセット まとめ*/
    /** 必ず、戻り値として、文字列（process-state-td-" + stateCd）もしくは、空白がかえります。*/
    /** 左側から実行されていくので、空白の場合は、次のクラス次々と実行する。 */
    getBedNameStateClass(record) {
      return (
        this.getProcessStateClass(record) ||
        this.getDialysisStateClass(record) ||
        this.getProcessStateCleaningClass(record) ||
        ""
      );
    },
    /** ベッド名のバックカラーセット 治療状態*/
    getDialysisStateClass(record) {
      if (
        record.rstDialysisState === null ||
        record.rstDialysisState === undefined ||
        record.rstDialysisState <= 0
      ) {
        return "";
      }
      return "dialysis-state-td-" + record.rstDialysisState;
    },
    /** ベッド名のバックカラーセット 通信状態*/
    getProcessStateClass(record) {
      const stateCd = record.processState;
      if (stateCd === null || stateCd === undefined || stateCd === 0) {
        return "";
        //return "process-state-td-0";
      }
      let rtn = "";
      if (stateCd === "99") {
        rtn = "process-state-td-" + stateCd;
      } else if (
        (record.ComType === 0 && record.com_format_cd === "F") != "0"
      ) {
        rtn = "process-state-td-" + stateCd;
      }
      return rtn;
    },
    /** ベッド名のバックカラーセット 洗浄・消毒*/
    getProcessStateCleaningClass(record) {
      const stateCd = record.processState;
      if (stateCd === null || stateCd === undefined || stateCd === 0) {
        return "process-state-td-0";
      }
      let rtn = "";
      if (stateCd === "02" || stateCd === "04") {
        rtn = "process-state-td-" + stateCd;
      }
      return rtn;
    },

    /** クール名取得 */
    getKurName(kurCd) {
      const kur = this.getKurListData.find((k) => k.kurCd === kurCd);
      return kur ? kur.kurName : "";
    },
    // Windowの高さからGirdコンポーネント領域の高さを算出
    calculateGridHeight() {
      const wh = this.windowHeight;
      const hh = getHeaderHeight(getLatestHeaderElement(this.$el || document), 0);
      const fmh =
        (this.isDispMenu === 1 ? getFooterMenuClientHeight(this.$el || null) : 0) + 5;
      this.toolbarHeight = wh - hh - fmh - 3;
      this.mainHeight = wh - hh - fmh;
      this.toolbarHeight =
        this.toolbarHeight < 340 ? this.mainHeight : this.toolbarHeight;

      const guideClientHeight =
        getScopedElementById("area_usage_guide", this.$el || this)?.clientHeight || 0;
      this.mainAreaHeight = this.toolbarHeight - guideClientHeight;
    },
    editBackgroundColor() {
      // 背景色変更
    },
    // 昇順/降順のclassを作成
    sortedClass(key) {
      const sort = {
        key:
          this.getSortSetting.sortKind === "normal"
            ? ""
            : this.getSortSetting.sortColumn,
        isAsc: this.getSortSetting.sortKind === "asc",
      };
      return getSortedClass(key, sort);
    },
    /**
     * @description ソート対象列・順序種類設定
     * @param { any } sortColumn ソート対象項目列キー
     */
    setSort(sortColumn) {
      const sortSetting = {
        sortColumn: "",
        sortKind: "normal", // normal, asc, desc
      };
      if (this.getSortSetting.sortColumn === sortColumn) {
        // 同じ列をソート対象の場合、順序のみを変更
        sortSetting.sortColumn = this.getSortSetting.sortColumn;
        switch (this.getSortSetting.sortKind) {
          case "normal":
            sortSetting.sortKind = "asc";
            break;
          case "asc":
            sortSetting.sortKind = "desc";
            break;
          case "desc":
            sortSetting.sortKind = "normal";
            break;

          default:
            sortSetting.sortKind = "normal";
            break;
        }
      } else {
        // 別の列をソート対象の場合、対象列と順序(昇順)を設定
        sortSetting.sortColumn = sortColumn;
        sortSetting.sortKind = "asc";
      }
      this.setSortSetting(sortSetting);
    },
    /**
     * 詳細ボタンのスタイル設定
     * @param { scaleBedListDataSource } record
     */
    gedDetailButtonClass(record) {
      if (record.wheelChairCd !== null) {
        // 車いす測定患者は詳細ボタンを赤色表示
        return "common-style-select-button scale-bed-btn-error";
      } else if (record.sendStatus === 2 || record.sendStatus === 4) {
        return "common-style-select-button scale-bed-btn-warning";
      } else if (record.sendStatus === 1 || record.sendStatus === 3) {
        return "common-style-select-button scale-bed-btn-error";
      }
      return "common-style-select-button btn3-normal";
    },
    /** データソース取得 */
    async fetchDataSource(initialize = true) {
      // データ取得処理
      const response = await sendRequestGetScaleBedViewList(initialize);
      if (response && response.data) {
        this.dataSource = [];
        for (const record of response.data) {
          if (record.scaleValue) {
            // 透析中の場合のみ直接体重値をセットする。
            if (Number(record.weightScaleStatus) === 3) {
              record.weightValue = Number(record["weightBefore"]);
            } else {
              // 風袋引き
              record.weightValue =
                Number(record["scaleValue"]) -
                Number(this.getIndTareWeightSum(record));
            }
          }
          this.dataSource.push(record);
        }
      }
    },
    moveWeightPage(record) {
      // 体重測定画面へ遷移
      if (!record.ordNo) {
        // オーダー番号が存在しない場合は何もしない
        return;
      }
      // 患者IDを設定
      this.setInputPatId(record.hospPatId);
      // オーダー番号を設定
      this.setSelectOrdNo({
        ordNo: record.ordNo,
        ordNo2: null,
      });
      // 選択の体重マスタを設定
      this.selectMstWeightByCd(record.weightCd);
      this.setWeightConfigInfo(
        this.getMstWeightList.find((w) => w.weightCd === record.weightCd)
      );
      // 関連する体重測定番号をセット（条件送信済みを除く）
      if (![1, 3, 4].includes(record.weightScaleStatus)) {
        this.setBaseOrdWeightNo(record.weightScaleNo);
      }
      this.setScaleBedToWeightView({
        weightCd: record.weightCd,
        scaleValue: record.scaleValue,
      });

      // 選択 ord_no を保持
      this.setOrdNoForSideBarRecord(record.ordNo);
      // 画面遷移
      this.setSrcFuncName(this.$router.currentRoute.name);
      this.$router.push({ name: "send-condition" });
    },
    refresh(initialize = true) {
      if (this.selfScreenName !== this.$router.currentRoute.name) {
        return;
      }
      window.clearTimeout(this.timerId);
      this.fetchDataSource(initialize).then(() => {
        if (this.refreshInterval > 0) {
          // 指定時間後に再度実行(共通ローダーなし)
          this.timerId = window.setTimeout(
            () => this.refresh(false),
            this.refreshInterval
          );
        }
      });
    },
    async getFacilitySettings() {
      let data = await getMstFacilitySettingValue(
        this.getFacilityCd,
        SCALE_BED_AUTO_SETTING
      );
      if (data.status == 200) {
        if (data.data) {
          this.refreshInterval = data.data * 1000;
        } else {
          this.refreshInterval = 30000;
        }
      } else {
        this.refreshInterval = 30000;
      }
    },
    /**
     * 体重送信処理
     * @param { scaleBedListDataSource } record
     */
    async sendCondition(record) {
      // 体重送信処理ログ
      console.log("体重送信処理開始", record);

      // 条件送信処理判定
      if (Number(record["rstDialysisState"]) < 3) {
        // 条件送信処理
        try {
          const sendResponse = await sendRequestPostSendConditionScaleBed({
            ordNo: record.ordNo,
            bedCd: record.bedCd,
            weightCd: record.weightCd,
            measureValue: record.scaleValue,
          });
          record.weightScaleNo = sendResponse.data.printWeightScaleNo;
          // 前体重印刷フラグチェック
          if (record.isDefaultPrintBefore === FLG_TRUE) {
            this.sendPrintOrder({
              weightScaleNo: record.weightScaleNo,
              facilityCd: record.facilityCd,
              weightNo: record.weightNo,
            });
          }
        } catch (error) {
          console.log("前体重送信処理異常", error);
          if (
            error.response.status === 400 &&
            error.response.data
            // error.response.data.errorMessage
          ) {
            // 400エラー時は受け取ったエラーメッセージを表示
            console.log("前体重送信処理異常", error.response.data.errorTitle);
            console.log("前体重送信処理異常", error.response.data.errorMessage);
            // メッセージ組み立て
            // const title = "チェックエラー";
            const title = DIALOG_MESSAGES["12000015"].title;
            // 送信に失敗しました。
            const message = DIALOG_MESSAGES["99999998"].message;
            // ダイアログ表示
            this.$ons.notification.alert({
              title: title,
              message: message,
            });

            this.$ons.notification.alert({
              title: error.response.data.errorTitle,
              message: error.response.data.errorMessage,
            });
          } else {
            // 条件送信処理失敗
            this.$ons.notification.alert({
              title: error.response.data.errorTitle,
              message: error.response.data.errorMessage,
            });
          }
        }
        this.refresh(false);
      } else if (Number(record["rstDialysisState"]) === 3) {
        // 何もしない。透析中
        // 基本、透析中は送信ボタンは非表示なので、ここに来ることはない想定
        return;
      } else {
        // 後体重送信処理呼び出し
        let sendResponse = await sendRequestPostSendAfterWeightScaleBed({
          ordNo: record.ordNo,
          bedCd: record.bedCd,
          weightCd: record.weightCd,
          measureValue: record.scaleValue,
        });
        if (sendResponse.status === 200) {
          record.weightScaleNo = sendResponse.data.printWeightScaleNo;
        } else {
          // 条件送信処理失敗
          console.log("後体重送信処理異常", sendResponse);
          console.log("後体重送信処理異常", sendResponse.errorTitle);
          console.log(
            "後体重送信処理異常",
            sendResponse.scaleBedSendConditionError
          );
          this.$ons.notification.alert({
            title: sendResponse.errorTitle,
            message: sendResponse.scaleBedSendConditionError,
          });
        }

        // 後体重の場合
        if (record.isDefaultPrintAfter === FLG_TRUE) {
          this.sendPrintOrder({
            weightScaleNo: record.weightScaleNo,
            facilityCd: record.facilityCd,
            weightNo: record.weightNo,
          });
        }
        this.refresh(false);
      }

      // 条件送信処理を実行ログ
      console.log("体重送信処理終了", record);
    },
    getIndTareWeightSum(record) {
      if (record.rstDialysisState === null) {
        return;
      }
      let tareInfo;
      if (Number(record.rstDialysisState) < 4) {
        // 前体重の場合
        tareInfo = 0;
        // rstTareInfoを取得し空の場合はindTareInfoを取得する
        // rstTareInfoを取得
        if (record.rstTareInfo) {
          try {
            const rstTareInfo =
              typeof record.rstTareInfo === "string"
                ? JSON.parse(record.rstTareInfo)
                : record.rstTareInfo;
            tareInfo = rstTareInfo?.before ? rstTareInfo.before : {};
            return this.calcTareWeight(tareInfo);
          } catch (e) {
            tareInfo = 0;
          }
        }
        // indTareInfoが空の場合は0を返す
        if (!record.indTareInfo) return 0;
        try {
          tareInfo =
            typeof record.indTareInfo === "string"
              ? JSON.parse(record.indTareInfo)
              : record.indTareInfo;
        } catch (e) {
          return 0;
        }
      } else if (Number(record.rstDialysisState) >= 4) {
        // 後体重の場合
        // rstTareInfoが空の場合は0を返す
        if (!record.rstTareInfo) return 0;
        try {
          const rstTareInfo =
            typeof record.rstTareInfo === "string"
              ? JSON.parse(record.rstTareInfo)
              : record.rstTareInfo;
          tareInfo = rstTareInfo?.after ? rstTareInfo.after : {};
        } catch (e) {
          return 0;
        }
      }
      return this.calcTareWeight(tareInfo);
    },
    calcTareWeight(tareInfoJson) {
      let sum = 0;
      for (let i = 1; i <= 5; i++) {
        const w = tareInfoJson[`weight_${i}`];
        if (typeof w === "number") sum += w;
        else if (typeof w === "string" && w !== "") sum += Number(w);
      }
      sum = tareG2Kg(sum);
      return sum;
    },
    getColumnWidthArray() {
      const returnValue = [];

      // グリッドコンポーネント参照から直接列情報を取得（Kendoグリッドの場合）
      const gridElement = this.$refs.gridComponent; // テンプレートで ref="gridComponent" を設定

      if (gridElement && gridElement.length > 0) {
        // グリッドAPIから列情報を取得
        for (const col of gridElement) {
          if (col && col.clientWidth) {
            returnValue.push(col.clientWidth);
          } else {
            returnValue.push(null);
          }
        }
      } else {
        // フォールバック：DOMから取得
        const headers = this.$el?.querySelectorAll("th") || [];
        headers.forEach((header) => {
          returnValue.push(header.clientWidth);
        });
      }

      return returnValue;
    },
    saveColumnWidths() {
      const widths = this.columnWidthList.map((width) => {
        const parsed = parseFloat(width);
        return isNaN(parsed) ? null : parsed;
      });
      this.setColumnResizeData(widths);
    },
    setupColResizeListeners() {
      if (this.colResizeInfo) {
        removeColResizeListeners(this.colResizeInfo);
        this.colResizeInfo = null;
      }

      const headerCells = this.$el?.querySelectorAll("thead th.manual-width");
      if (!headerCells?.length) {
        return;
      }

      this.colResizeInfo = addColResizeListeners(headerCells, {
        onWidthChanged: ({ index, cell }) => {
          const width = parseFloat(cell.style.width);
          if (!isNaN(width)) {
            this.columnWidthList[index] = `${width}px`;
          }
        },
        onFinishResize: () => {
          this.saveColumnWidths();
        },
      });
    },
  },
  created() {
    this.setLoadingScreenVisible(true);

    // 共通ローダー:表示名設定
    this.setLoadingScreenMessage("処理中・・・");
    this.fetchMstWeightList(this.getFacilityCd).then((r) => {
      this.setMstWeightListByScaleBed(r.data);
      this.selectMstWeightByCd(-1);
      this.clearWeightConfigInfo();
    });

    this.selfScreenName = this.$router.currentRoute.name;
    EventBus.$on("refresh", this.refresh);
    this.setLoadingScreenVisible(false);

    // 初期表示時のみ、先頭列を昇順にする
    if (
      !this.getSortSetting.sortColumn ||
      this.getSortSetting.sortKind === "normal"
    ) {
      this.setSortSetting({
        sortColumn: this.dataColumns[0].field, // 先頭列
        sortKind: "asc",
      });
    }
  },
  updated() {
    // Storeの更新等で画面が再描画された場合に背景色を変更
    this.editBackgroundColor();
    this.$nextTick(() => {
      this.calculateGridHeight();
    });
  },
  mounted() {
    // 列幅復元処理
    // 注意 列幅登録処理は、親ScaleBedVide.vueの「beforeRouteLeave」で行う
    const savedWidths = this.getColumnResizeData;
    if (savedWidths && Array.isArray(savedWidths)) {
      for (let i = 0; i < savedWidths.length; i++) {
        if (savedWidths[i]) {
          const minWidth = parseFloat(this.initialColumnWidthList[i]);
          const restoredWidth = Math.max(
            savedWidths[i],
            isNaN(minWidth) ? 0 : minWidth
          );
          this.columnWidthList.splice(i, 1, restoredWidth + "px");
          const target = this.$el?.getElementsByClassName("manual-width")?.[i];
          if (target) {
            target.style.width = restoredWidth + "px";
          }
        }
      }
    }
    this.getFacilitySettings().then(() => {
      this.refresh();
    });
    this.$nextTick(() => {
      this.calculateGridHeight();
      this.setupColResizeListeners();
    });
  },
  beforeUnmount() {
    if (this.colResizeInfo) {
      removeColResizeListeners(this.colResizeInfo);
      this.colResizeInfo = null;
    }
    this.dataSource = [];
    const ownerWindow = this.$el?.ownerDocument?.defaultView || window;
    ownerWindow.clearTimeout(this.timerId);
    EventBus.$off("refresh", this.refresh);
    // 共通ローダー:表示カウントリセット
    this.resetLoadingScreenVisibleCount();
  },
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

.main-content-area {
  position: relative;
}

#grid-footer {
  margin: 0;
  bottom: 0;
  position: absolute;
  left: 0;
  right: 0;
  height: auto; /* 高さを明示的に指定 */
  min-height: 30px; /* 最小高さを設定 */
  display: flex;
  align-items: flex-start;
  justify-content: flex-start;
}

.toolbar-btn {
  padding: 0.2em 1em 0em 1em;
  line-height: 2em;
  width: auto;
}

.k-grid-toolbar {
  padding: 0.1em 0.3em;
}

.machine-dialog > .alert-dialog {
  width: auto;
}

.custom-switch {
  transform: scale(0.85);
  transform-origin: center;
  touch-action: manipulation;
}

.mobile-header {
  /* モバイル用の高さ */
  min-height: 30px;
}

.usage-guide-div {
  display: flex;
  align-items: center !important;
  margin-right: 1em;
  justify-content: flex-start;
  gap: 0.3em;
}

/* 凡例 */
#area_usage_guide {
  width: 100%;
  display: flex;
  flex-wrap: wrap;
  color: var(--ntss-list-body-color);
  margin: 0; /* マージンを0にリセット */
  padding: 2px 5px; /* margin の代わりに padding を使用 */
  align-items: center;
  gap: 0.3em; /* 要素間の間隔 */
}

.usage-guide-element,
.usage-guide-element-info,
.usage-guide-element-alarm {
  width: 1em;
  height: 1em;
  margin: 0 !important; /* マージンをリセット */
  flex-shrink: 0; /* 縮小を防ぐ */
}

/* 通常色指定なし */
.usage-guide-element {
  width: 1em;
  height: 1em;
  margin-top: 0.2em;
}

/* 警告色 */
.usage-guide-element-info {
  width: 1em;
  height: 1em;
  margin-top: 0.2em;
  /* 背景色 */
  background: #ffff66;
  /* フォント色 */
  color: #333333;
  /* 枠線 */
  border: solid 1px #cccccc;
  align-items: flex-end;
}

/* 異常色 */
.usage-guide-element-alarm {
  width: 1em;
  height: 1em;
  margin-top: 0.2em;
  /* 背景色 */
  background: #ff6666;
  /* フォント色 */
  color: #333333;
  /* 枠線 */
  border: solid 1px #cccccc;
  align-items: flex-end;
}

.manual-width {
  resize: none !important;
  overflow: hidden;
}

.clickable-header-label {
  display: block;
  width: 100%;
  padding: 0 4px;
  box-sizing: border-box;
  overflow: hidden;
}

/** 通信エラー */
.process-state-td-99 {
  background-color: #ff6699 !important;
  color: black;
}

/** 赤色ボタンの色 */
.scale-bed-btn-error {
  background-color: #ff6666 !important;
  color: black !important;
  box-shadow: unset;
}

/** 黄色ボタンの色 */
.scale-bed-btn-warning {
  background-color: #ffff66 !important;
  color: black !important;
  box-shadow: unset;
}

/** 次患者 */
.process-state-td-01 {
  background-color: #ffffff !important;
  color: black;
}

/** 条件送信済み */
.dialysis-state-td-01 {
  background-color: #42cb92 !important;
}

/** 治療中 */
.process-state-td-10 {
  background-color: #2ca06f !important;
  color: #fff !important;
}

/** 治療終了 */
.dialysis-state-td-4 {
  color: #fff !important;
  background-color: #557769 !important;
}

/** 透析準備 */
.status-list-page :deep(.dialysis-state-td-0),
.status-list-page :deep(.process-state-td-01),
.status-list-page :deep(.process-state-td-07),
.status-list-page :deep(.process-state-td-08),
.status-list-page :deep(.process-state-td-09),
.status-list-page :deep(.process-state-td-20),
.status-list-page :deep(.process-state-td-29),
.status-list-page :deep(.process-state-td-40),
.status-list-page :deep(.process-state-td-45),
.status-list-page :deep(.process-state-td-61),
.status-list-page :deep(.process-state-td-A0),
.status-list-page :deep(.process-state-td-A5),
.status-list-page :deep(.process-state-td-A6),
.status-list-page :deep(.process-state-td-A7),
.status-list-page :deep(.process-state-td-AE),
.status-list-page :deep(.process-state-td-B0),
.status-list-page :deep(.process-state-td-B8),
.status-list-page :deep(.process-state-td-BC) {
  background-color: #ffffff !important;
  color: black;
}

/** 洗浄・消毒 */
.status-list-page :deep(.process-state-td-02),
.status-list-page :deep(.process-state-td-03),
.status-list-page :deep(.process-state-td-04),
.status-list-page :deep(.process-state-td-05),
.status-list-page :deep(.process-state-td-06),
.status-list-page :deep(.process-state-td-23),
.status-list-page :deep(.process-state-td-24),
.status-list-page :deep(.process-state-td-25),
.status-list-page :deep(.process-state-td-26),
.status-list-page :deep(.process-state-td-27),
.status-list-page :deep(.process-state-td-28),
.status-list-page :deep(.process-state-td-46),
.status-list-page :deep(.process-state-td-47),
.status-list-page :deep(.process-state-td-62),
.status-list-page :deep(.process-state-td-63),
.status-list-page :deep(.process-state-td-64),
.status-list-page :deep(.process-state-td-65),
.status-list-page :deep(.process-state-td-A8),
.status-list-page :deep(.process-state-td-A9),
.status-list-page :deep(.process-state-td-AA),
.status-list-page :deep(.process-state-td-AB),
.status-list-page :deep(.process-state-td-AC),
.status-list-page :deep(.process-state-td-AD),
.status-list-page :deep(.process-state-td-B1),
.status-list-page :deep(.process-state-td-B2),
.status-list-page :deep(.process-state-td-B6),
.status-list-page :deep(.process-state-td-B7),
.status-list-page :deep(.process-state-td-B9),
.status-list-page :deep(.process-state-td-BA),
.status-list-page :deep(.process-state-td-BB) {
  background-color: #00b0f0 !important;
  color: black;
}

/** 条件送信済み */
.status-list-page :deep(.dialysis-state-td-1),
.status-list-page :deep(.dialysis-state-td-2) {
  background-color: #42cb92 !important;
}

/** 治療中 */
.status-list-page :deep(.dialysis-state-td-3),
.status-list-page :deep(.process-state-td-10),
.status-list-page :deep(.process-state-td-11),
.status-list-page :deep(.process-state-td-21),
.status-list-page :deep(.process-state-td-22),
.status-list-page :deep(.process-state-td-41),
.status-list-page :deep(.process-state-td-42),
.status-list-page :deep(.process-state-td-43),
.status-list-page :deep(.process-state-td-44),
.status-list-page :deep(.process-state-td-60),
.status-list-page :deep(.process-state-td-A1),
.status-list-page :deep(.process-state-td-A2),
.status-list-page :deep(.process-state-td-A3),
.status-list-page :deep(.process-state-td-A4),
.status-list-page :deep(.process-state-td-B3),
.status-list-page :deep(.process-state-td-B4),
.status-list-page :deep(.process-state-td-B5) {
  background-color: #2ca06f !important;
  color: #fff !important;
}

/** 通信エラー */
.status-list-page :deep(.process-state-td-99) {
  background-color: #ff6699 !important;
  color: black;
}

/** 治療終了 */
.status-list-page :deep(.dialysis-state-td-4),
.status-list-page :deep(.dialysis-state-td-5) {
  color: #fff !important;
  background-color: #557769 !important;
}

/** 実績確定 */
.status-list-page :deep(.dialysis-state-td-6) {
  color: #fff !important;
  background-color: rgb(0, 26, 0) !important;
}
</style>
