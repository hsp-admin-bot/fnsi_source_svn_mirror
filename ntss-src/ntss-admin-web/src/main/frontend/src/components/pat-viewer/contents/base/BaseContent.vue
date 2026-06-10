<template>
  <div>
    <v-ons-row class="list-content-row-height">
      <!-- 項目名列(縦文字タイトル)のセル -->
      <v-ons-col
        v-show="isDispFuncName"
        class="list-content-col-title-vertical"
        @click="onTitleClick($event)"
      >
        {{ funcName }}
      </v-ons-col>

      <div
        v-if="isMedicine"
        v-show="medAuxiliaryShowFlg"
      >
        <v-ons-popover
          :class="[fontSizeSet, 'popover-style']"
          :visible.sync="medAuxiliaryShowFlg"
          :target="popoverTarget"
          :direction="popoverDirection"
          :cover-target="popoverCoverTarget"
          cancelable
          @preshow="popoverPreShow"
          @postshow="popoverPostShow"
          @posthide="popoverPosthide"
        >
          <div class="modal-contents">
            <v-ons-row>
              <v-ons-col>{{ popDispDataItem.shiji_kaishi_nichi.label }}</v-ons-col>
              <v-ons-col>{{ this.dateFormat(popDispDataItem.shiji_kaishi_nichi.value) }}</v-ons-col>
            </v-ons-row>
            <v-ons-row v-show="isShowMaxDate">
              <v-ons-col>{{ popDispDataItem.shiji_shuuryou_nichi.label }}</v-ons-col>
              <v-ons-col>{{ this.dateFormat(popDispDataItem.shiji_shuuryou_nichi.value) }}</v-ons-col>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col>{{ popDispDataItem.touyo_kankaku.label }}</v-ons-col>
              <v-ons-col>{{ this.getDateInterval(popDispDataItem.touyo_kankaku.value) }}</v-ons-col>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col>{{ popDispDataItem.youbi.label }}</v-ons-col>
              <v-ons-col>{{ this.getWeek(popDispDataItem.youbi.value) }}</v-ons-col>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col>{{ popDispDataItem.shokai_touyo_nichi.label }}</v-ons-col>
              <v-ons-col>{{ this.dateFormat(popDispDataItem.shokai_touyo_nichi.value) }}</v-ons-col>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col>{{ popDispDataItem.bunrui_meishou.label }}</v-ons-col>
              <v-ons-col>{{ this.nameFormat(popDispDataItem.bunrui_meishou.value) }}</v-ons-col>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col>{{ popDispDataItem.yakuzai_meishou.label }}</v-ons-col>
              <v-ons-col>{{ this.nameFormat(popDispDataItem.yakuzai_meishou.value) }}</v-ons-col>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col>{{ popDispDataItem.shugi.label }}</v-ons-col>
              <v-ons-col>{{ this.getProcedure(popDispDataItem.shugi.value) }}</v-ons-col>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col>{{ popDispDataItem.touyo_taimingu.label }}</v-ons-col>
              <v-ons-col>{{ this.getTiming(popDispDataItem.touyo_taimingu.value) }}</v-ons-col>
            </v-ons-row>
            <v-ons-row>
              <v-ons-col>{{ popDispDataItem.komento.label }}</v-ons-col>
              <v-ons-col>{{ popDispDataItem.komento.value }}</v-ons-col>
            </v-ons-row>
          </div>
        </v-ons-popover>
      </div>

      <!-- 横方向のセル -->
      <v-ons-col class="list-content-row">
        <v-ons-row
          v-for="(dispDataItem, dispDataItemIndex) in dispDataList"
          :key="dispDataItemIndex"
          class="list-content-row-height"
        >
          <!-- LF適用項目名列(横文字部分)のセル -->
          <v-ons-col
            v-if="isAbleLf"
            :class="[
              { 'list-content-col-title-horizon': isDispFuncName },
              'list-content-lf-col-title'
            ]"
            :style="
              addBorderBottom(dispDataList.length - 1 === dispDataItemIndex)
            "
            @click="onSubTitleClick($event, dispDataItem, dispDataItemIndex)"
          >
            <span v-if="isAbleLf && dispDataItem.itemName.indexOf('\t') > -1" > &emsp;&emsp;&emsp;{{ addSpace(dispDataItem.itemName) }} </span>
            <span v-else > {{ dispDataItem.itemName }} </span>
          </v-ons-col>
          <v-ons-col v-else-if="isChartRst || isDrugGraph" class="list-content-col-chart-label list-content-lf-col-title">
            <v-ons-row>
              <v-ons-col>{{ dispDataItem.itemName }}</v-ons-col>
              <v-ons-col
                v-for="(subName, subNameIndex) in getTickPositions[dispDataItem.itemName]"
                :key="subNameIndex"
                class="list-content-col-chart-tick"
              >
                <v-ons-row
                  v-for="(name, nameIndex) in subName.tickArr"
                  :key="nameIndex"
                >
                  {{ name }}
                </v-ons-row>
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
          <v-ons-col v-else-if="isComprehensiveGraph" class="list-content-col-chart-label comprehensive-graph list-content-lf-col-title">
            <v-ons-row>
              <v-ons-col>{{ dispDataItem.itemName }}</v-ons-col>
              <v-ons-col
                v-for="(subName, subNameIndex) in getTickPositions[dispDataItem.itemName]"
                :key="subNameIndex"
                class="list-content-col-chart-tick"
              >
                <v-ons-row
                  v-for="(name, nameIndex) in subName.tickArr"
                  :key="nameIndex"
                >
                  {{ name }}
                </v-ons-row>
              </v-ons-col>
            </v-ons-row>
          </v-ons-col>
          <v-ons-col v-else-if="dispDataItem.isAdd"
            :class="[
              { 'list-content-col-title-horizon': isDispFuncName },
              { 'header--alert': includesAlertPrefix(dispDataItem.itemName) },
              'list-content-col-title'
            ]"
            @click="onSubTitleClick($event, dispDataItem, dispDataItemIndex)"
          >新規追加</v-ons-col>
          <v-ons-col v-else-if="isMedicine"
            :class="[
              { 'list-content-col-title-horizon': isDispFuncName },
              { 'header--alert': includesAlertPrefix(dispDataItem.itemName) },
              'list-content-col-title',
              fontSizeMedicine
            ]"
          >
            <label
              @click="onSubTitleClick($event, dispDataItem, dispDataItemIndex)"
            >{{ dispDataItem.itemName }}
            </label>
            <v-ons-icon icon="fa-info-circle"
              v-if="dispDataItem.itemNo !== -1"
              @click="showPopoverSetting($event, 'right', false); showIndMedicineModal(dispDataItem)"
            />
          </v-ons-col>
          <v-ons-col
            v-else
            :class="[
              { 'list-content-col-title-horizon': isDispFuncName },
              { 'header--alert': includesAlertPrefix(dispDataItem.itemName) },
              'list-content-col-title'
            ]"
            @click="onSubTitleClick($event, dispDataItem, dispDataItemIndex)"
          >
            {{ dispDataItem.itemName }}
          </v-ons-col>
          <v-ons-col
            v-for="(dispData, dispDataIndex) in dispDataItem.data"
            :key="dispDataIndex"
            :style="
              addBorderBottom(
                dispDataList.length - 1 === dispDataItemIndex ||
                  'lf' !== dispData.type
              )
            "
            :class="
              setIndTextAlign(
                dispDataItem.itemName,
                dispData
              )
            "
          >
            <div
              v-if="dispData.isShowAddImg &&
                getItemAuthorized('Indication', 'default_authority')"
              :class="[{ 'cell-disabled': dispData.isDisabled1 }, 'add-img-wrapper']"
              @click="onAddImgClick(dispData)">
              <img src="img/pat-info/add.png" class="add-img">
            </div>
            <!-- 装置設定チャート -->
            <div
              v-if="dispData.type === 'chart'"
              class="chart-content"
              @click="
                onCellClick(
                  $event,
                  dispData,
                  dispDataItem.itemName,
                  dispDataItemIndex
                )
              "
            >
              <v-ons-col v-if="!dispData.data">
                {{ dispData.value1 }}
              </v-ons-col>
              <device-program-chart
                v-for="chart in dispData.chartData"
                v-else
                :key="chart.mode"
                :data="chart"
                :show-tick-label="false"
                :height="100"
              />
            </div>

            <!-- 実績情報チャート -->
            <div
              v-else-if="dispData.type === 'chart-rst'"
              class="rst-chart-con"
              @click="
                onCellClick(
                  $event,
                  dispData,
                  dispDataItem.itemName,
                  dispDataItemIndex
                )
              "
            >
              <rst-chart
                :chart-data="dispData.chartData"
                :x-axis-min="dispData.chartXAxisMin"
                :x-axis-max="dispData.chartXAxisMax"
                :breaks="dispData.breaks"
                :y-axis-range-values="dispData.chartYAxisRangeValues"
                :display-period="dispData.chartDisplayPeriod"
                :disp-data-item="dispDataItem.itemName"
                :yAxis="dispData.yAxis"
                :chartType="dispData.chartType"
                :showLegend="dispData.showLegend"
              />
            </div>

            <div
              v-else-if="dispData.type === 'drug-graph'"
              class="drug-graph-con"
              @click="
                onCellClick(
                  $event,
                  dispData,
                  dispDataItem.itemName,
                  dispDataItemIndex
                )
              "
            >
              <drug-graph
                :chart-data="dispData.chartData"
                :x-axis-min="dispData.chartXAxisMin"
                :x-axis-max="dispData.chartXAxisMax"
                :y-axis-range-values="dispData.chartYAxisRangeValues"
                :display-period="dispData.chartDisplayPeriod"
                :disp-data-item="dispDataItem.itemName"
                :yAxis="dispData.yAxis"
              />
            </div>

            <div
              v-else-if="dispData.type === 'comprehensive-graph'"
              class="comprehensive-graph-con"
              @click="
                onCellClick(
                  $event,
                  dispData,
                  dispDataItem.itemName,
                  dispDataItemIndex
                )
              "
            >
              <comprehensive-graph
                :chart-data="dispData.chartData"
                :x-axis-min="dispData.chartXAxisMin"
                :x-axis-max="dispData.chartXAxisMax"
                :y-axis-range-values="dispData.chartYAxisRangeValues"
                :display-period="dispData.chartDisplayPeriod"
                :disp-data-item="dispDataItem.itemName"
                :yAxis="dispData.yAxis"
              />
            </div>

            <!-- 一覧 (LF適用) -->
            <div
              v-else-if="dispData.type === 'lf'"
              class="div-style"
              @click="
                onCellClick(
                  $event,
                  dispData,
                  dispDataItem.itemName,
                  dispDataItemIndex
                )
              "
            >
              <v-ons-col
                v-if="dispData.value1 && dispData.isRstRoundsFlg"
              >
                <button
                  style="width:80px;
                    border:0.2px solid #0E3F69;
                    margin-top:1.5px"
                >
                  {{ dispData.value1 }}
                </button>
              </v-ons-col>

              <!-- 加算・管理料 -->
              <v-ons-col
                v-else-if="dispData.value1 && dispData.dataItem === 1"
                style="text-align: left;"
              >
                <div v-for="(item, index) in dispData.value1" :key="index">{{ item.name }}</div>
              </v-ons-col>

              <v-ons-col v-else>
                {{ dispData.value1 }}
                <img v-if="showComplaint(dispData)"
                style="cursor: pointer"
                :src="showImg(dispData.value2.complaintData)"
                @click.stop="showMedicine(dispData.value2.complaintData,arguments[0])"
                width="24"
                height="24"
              />
              </v-ons-col>
            </div>
            <!-- 一覧 (長期集計用) -->
            <div
              v-else-if="dispData.type === 'cf'"
              class="div-style"
            >
              <v-ons-col>
                {{ dispData.value1 }}
              </v-ons-col>
            </div>
            <!-- 一覧 (LF未適用) -->
            <div v-else class="div-style">
              <v-ons-row>
                <!-- 指示表示 -->
                <v-ons-col
                  v-if="
                    isShowIndData(
                      dispData.value1,
                      dispData.ordNo,
                      dispDataItem.itemName
                    )
                  "
                  :class="
                    setVerticalBorder(
                      dispData.value1,
                      dispData.value2,
                      dispData.ordNo,
                      dispDataItem.itemName
                    )
                  "
                  @click="
                    onCellClick(
                      $event,
                      dispData,
                      dispDataItem.itemName,
                      dispDataItemIndex,
                      dispDataItem.isEditable === undefined ? true: dispDataItem.isEditable=== '1' ? true : dispDataItem.isEditable=== 1 ? true : false
                    )
                  "
                  @touchstart="
                    onTouchStart(
                      $event,
                      dispData)
                  "
                  @touchend="
                    onTouchEnd(
                      $event,
                      dispData)
                  "
                  @mousedown="
                    onMouseDown(
                      $event,
                      dispData)
                  "
                  @mouseup="
                    onMouseUp(
                      $event,
                      dispData)
                  "
                >
                  <v-ons-row>
                    <v-ons-col v-if="checkImagePNG(dispData.value1) && dispData.scrollBarPositioningFlg"
                      class="cell-style-image"
                      :class="[{ 'cell-disabled': dispData.isDisabled1 }, { 'cell--alert': shouldApplyAlertClass(dispDataItem.itemName, dispData) }]">
                      <div id="scrollBarPositioning"></div>
                      <img :src="setImage(dispData.value1)" class="cell-image"/>
                    </v-ons-col>
                    <v-ons-col v-else-if="checkImagePNG(dispData.value1) && !dispData.scrollBarPositioningFlg"
                      class="cell-style-image"
                      :class="[{ 'cell-disabled': dispData.isDisabled1 }, { 'cell--alert': shouldApplyAlertClass(dispDataItem.itemName, dispData) }]">
                      <img :src="setImage(dispData.value1)" class="cell-image"/>
                    </v-ons-col>
                    <v-ons-col v-else class="cell-style" :class="[{ 'cell-disabled': dispData.isDisabled1 }, { 'cell--alert': shouldApplyAlertClass(dispDataItem.itemName, dispData) }]"
                        :title = "setTooltrip(dispDataItem.medicineType,
                          dispData.value1,
                          dispData.toolText1
                        )">
                       <div :class="setRedcircle(dispData.isExpired, dispDataItem.itemName, dispData.value1, dispData.colorFlg)"
                        >{{showCellDataInd(dispData.isExpired, dispData.value1, dispData.unit1)}}</div>
                    </v-ons-col>
                  </v-ons-row>
                </v-ons-col>
                <!-- 実績表示 -->
                <v-ons-col
                  v-if="
                    isShowRstData(
                      dispData.value2,
                      dispData.ordNo,
                      dispDataItem.itemName
                    )
                  "
                  @click="
                    onCellClick(
                      $event,
                      dispData,
                      dispDataItem.itemName,
                      dispDataItemIndex,
                      false
                    )
                  "
                  :class="
                    dataCellClassObj(
                      dispData.value1,
                      dispData.value2,
                      dispData.ordNo,
                      dispDataItem.itemName,
                      dispData.type,
                      dispData.treatDate,
                      dispData.isNotClickable,
                      dispData.type === 'chart' && dispData.isDisabled2 || dispData.isDisabled2,
                      dispDataItem.isAdd
                    )
                  "
                >
                  <v-ons-row>
                    <v-ons-col class="cell-style" :title = "setTooltrip(dispDataItem.medicineType,
                          dispData.value2,
                          dispData.toolText2
                        )">
                      <div :class="setRedcircle('rstData', dispDataItem.itemName, dispData.value2, '')">
                        {{showCellData(dispDataItem.itemNo,dispData.value2, dispData.unit2)}}
                      </div>
                    </v-ons-col>
                  </v-ons-row>
                </v-ons-col>

                <v-ons-col v-else-if="isShowRstDataSen(dispData.ordNo, dispDataItem.itemName )">
                  <v-ons-row>
                    <v-ons-col class="cell-style" :class="{ 'cell-disabled': dispData.isDisabled }">
                    </v-ons-col>
                  </v-ons-row>
                </v-ons-col>

              </v-ons-row>
            </div>
          </v-ons-col>
        </v-ons-row>
      </v-ons-col>
    </v-ons-row>
    <treatment-medicine
      :popoverVisible="popoverVisible"
      :popoverTarget="mpopoverTarget"
      :popoverTreatment="popoverTreatment"
      @popover-close="closePopover"
    />
  </div>
</template>

<script>
import { getAuthorized } from "@/functions/common/CommonFunctions.js";
/**
 * Vue関連
 */
import { mapActions, mapGetters } from "vuex";

/**
 * 装置設定チャート
 */
import DeviceProgramChart from "@/components/pat-info/device-set-info/DeviceProgramChart";

/**
 * 実績情報チャート
 */
import RstChart from "@/components/pat-viewer/contents/treatment/RstChart";
import ComprehensiveGraph from "@/components/pat-viewer/contents/treatment/ComprehensiveGraph";
import DrugGraph from "@/components/pat-viewer/contents/treatment/DrugGraph";
import { ApiHelper } from "@/apis/AxiosHelper";
import moment from "moment";
import PopoverMixin from "@/components/PopoverMixin";
import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
import TreatmentMedicineComponent from "@/components/treatment-record/submenu/complaint/TreatmentMedicineComponent";
import { PREFIX, ALERT_PREFIXES } from "@/constants/PatViewerConstants";

export default {
  mixins: [PopoverMixin],
  components: {
    /**
     * 装置設定チャート
     */
    "device-program-chart": DeviceProgramChart,

    /**
     * 実績情報チャート
     */
    "rst-chart": RstChart,
    "comprehensive-graph": ComprehensiveGraph,
    "drug-graph": DrugGraph,
    "treatment-medicine": TreatmentMedicineComponent
  },

  props: {
    /**
     * 項目列の縦文字表示のタイトル文字列
     * @summary 未設定の場合は縦方向領域は非表示となる
     */
    funcName: {
      type: String,
      default: null,
      required: false
    },

    /**
     * 表示するデータのリスト
     */
    dispDataList: {
      type: Array,
      default: () => [],
      required: false
    },
    /**
     * LFの適用
     */
    isAbleLf: {
      type: Boolean,
      default: false
    },
    /**
     * 実績情報チャート
     */
    isChartRst: {
      type: Boolean,
      default: false
    },

    /**
     * 複合情報チャート
     */
    isComprehensiveGraph: {
      type: Boolean,
      default: false
    },

    /**
     * 投与薬剤項目
     */
    isMedicine: {
      type: Boolean,
      default: false
    },

    isDrugGraph: {
      type: Boolean,
      default: false
    }
  },

  data() {
    return {
      //add 5807  愁訴処置の表示不正  張 start
      popoverVisible: false,
      mpopoverTarget: null,
      popoverTreatment: {},
      //add 5807  愁訴処置の表示不正  張 end
      // add FutreNetWeb+SI課題管理No5188対応 呉 start
      isShowMaxDate:true,
      // add FutreNetWeb+SI課題管理No5188対応 呉 end
      // mod FNSI-期限切れ削除済みと表示するの修正 李 start
      MedicineString: "medicineDel",
      // mod FNSI-期限切れ削除済みと表示するの修正 李 end

      // add FNSI-FutreNetWeb+SI課題管理No.4360 李 start
      medAuxiliaryShowFlg: false,
      popoverTarget: null,
      popoverDirection: "right",
      popoverCoverTarget: false,
      sourceDataItem: {
        amount: null,
        cd: null,
        classCd: null,
        data: [],
        dateInterval: null,
        decPoint: null,
        index: null,
        isTabooAllergy: null,
        itemName: null,
        itemNo: null,
        medicateTimingCd: null,
        medicineType: null,
        procedureCd: null,
        unit: null,
      },
      popDispDataItem: {
        // 指示開始日
        shiji_kaishi_nichi: {
          label: "指示開始日：",
          value: ""
        },
        // 指示終了日
        shiji_shuuryou_nichi: {
          label: "指示終了日：",
          value: ""
        },
        // 投与間隔
        touyo_kankaku: {
          label: "投与間隔：",
          value: ""
        },
        // 曜日
        youbi: {
          label: "曜日：",
          value: ""
        },
        // 初回投与日
        shokai_touyo_nichi: {
          label: "初回投与日：",
          value: ""
        },
        // 分類名称
        bunrui_meishou: {
          label: "分類名称：",
          value: ""
        },
        // 薬剤名称
        yakuzai_meishou: {
          label: "薬剤名称：",
          value: ""
        },
        // 手技
        shugi: {
          label: "手技：",
          value: ""
        },
        // 投与タイミング
        touyo_taimingu: {
          label: "投与タイミング：",
          value: ""
        },
        // コメント
        komento: {
          label: "コメント：",
          value: ""
        },
      },
      // add FNSI-FutreNetWeb+SI課題管理No.4360 李 end
    };
  },

  computed: {
    ...mapGetters("pat-viewer", [
    "getSelectIndRst",
    "getTreatmentData",
    "getTickPositions",
    ]),
    // add FNSI-投与薬剤の補助画面を追加 周 start
    ...mapGetters("account-edit", ["getFontSize"]),
    // add FNSI-FutreNetWeb+SI課題管理No.4360 李 start
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("pat-info", ["selectedPatId"]),
    ...mapGetters("pat-viewer", [
      // 手技マスタ
      "getMstProcedureData",
      // 投与タイミングマスタ
      "getMstMedicateTimingData"
    ]),
    // add FNSI-FutreNetWeb+SI課題管理No.4360 李 end

    /**
     * フォントサイズに応じたCSSセレクタを返す.
     */
    fontSizeMedicine() {
      const names = ["small", "medium", "large", "x-large"];
      return "list-content-col-title-medicine-" + names[this.getFontSize];
    },
    // add FNSI-投与薬剤の補助画面を追加 周 end
    /**
     * 項目列の縦文字表示のタイトルを表示するかどうかのフラグ
     * @summary 空文字も非表示とする
     */
    isDispFuncName() {
      return false === !this.funcName;
    },

    /**
     * 指示・実績表示切替選択
     */
    selectedIndRst() {
      return this.getSelectIndRst;
    },

    /**
     * 指示情報
     */
    ordMainData() {
      return this.getTreatmentData;
    },
  },
  async created() {},

  // mod #11147 患者経過総合ビューアの子画面で編集後に親画面のスクロール位置を元の位置のままとする。 start
  // add 更新中の予定を表示する様にする。 李 start
  //mounted() {
  //  this.$nextTick(() => {
  //    setTimeout(() => {
  //      // DIVIDによる画面の定位
  //      const scrollBarPositioning = document.getElementById("scrollBarPositioning");
  //      if (scrollBarPositioning) {
  //        // 画面の定位
  //        document.getElementById('pat_viewer').scrollTop = scrollBarPositioning.getBoundingClientRect().top - 164;
  //        // 唯一を保証するために、DIVIDを消去する
  //        document.getElementById("scrollBarPositioning").removeAttribute("id");
  //      }
  //    }, 3500);
  //  })
  //},
  // add 更新中の予定を表示する様にする。 李 end
  // mod #11147 患者経過総合ビューアの子画面で編集後に親画面のスクロール位置を元の位置のままとする。 end

  methods: {
    ...mapActions("treatment-record/common", ["setOrdNo"]),
    // add 更新中の予定を表示する様にする。 李 start
    // OrdNoによって操作するデータを見つける
    ...mapActions("pat-viewer", ["setScrollBarPositioningOrdNo"]),
    // add 更新中の予定を表示する様にする。 李 end
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,
    // add #10359 編集権限の動作不正 dengshen start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    // add #10359 編集権限の動作不正 dengshen end

    // del FNSI-FutreNetWeb+SI課題管理No.4360 李 start
    // // add FNSI-投与薬剤の補助画面を追加 周 start
    // ...mapActions("multi-modal", ["showIndMedicineModal"]),
    // // add FNSI-投与薬剤の補助画面を追加 周 end
    // del FNSI-FutreNetWeb+SI課題管理No.4360 李 end

    // add FNSI-FutreNetWeb+SI課題管理No.4360 李 start
    //add 5807  愁訴処置の表示不正  張 start
    showImg(dispData){
     return dispData.treat_medicine_name.includes("【禁忌】")||
     dispData.treat_medicine_name.includes("【禁忌・ｱﾚﾙｷﾞｰ】") ||
     dispData.treat_medicine_name.includes("【ｱﾚﾙｷﾞｰ】")?'img/treatment-record/medicine-bottle-red.png':'img/treatment-record/medicine-bottle.png'
    },
    showComplaint(dispData){
      if (dispData.value2==null||dispData.value2.complaintData==null) {
        return false;
      }
      return dispData.value2.complaintData.iscomplaint;
    },
    /**
     * 薬瓶アイコンのクリックイベントハンドラ.
     *
     * @param {Treatment} treatment クリックされた行の処置データ
     * @param {MouseEvent} event クリックされたマウスイベント
     */
    showMedicine(treatment,event) {
      this.popoverTreatment = {
        treatMedicine: treatment.treat_medicine_name,
        amount: treatment.amount,
        unit: treatment.unit,
        procedure: treatment.procedure_name
      };
      this.popoverVisible = true;
      this.mpopoverTarget = event.target;
    },
    /**
     * ポップオーバクローズ処理
     */
    closePopover() {
      this.popoverVisible = false;
      this.popoverTarget = null;
      this.popoverTreatment = {};
    },
    //add 5807  愁訴処置の表示不正  張 end
    showIndMedicineModal(dispDataItem) {
      this.sourceDataItem = dispDataItem;

      // 投与間隔
      this.popDispDataItem.touyo_kankaku.value = this.sourceDataItem.dateInterval2;
      // 分類名称
      this.popDispDataItem.bunrui_meishou.value = this.sourceDataItem.className;
      // 薬剤名称
      this.popDispDataItem.yakuzai_meishou.value = this.sourceDataItem.medicineName;
      // 手技
      this.popDispDataItem.shugi.value = this.sourceDataItem.procedureCd2;
      // 投与タイミング
      this.popDispDataItem.touyo_taimingu.value = this.sourceDataItem.medicateTimingCd2;
      // コメント
      this.popDispDataItem.komento.value = this.sourceDataItem.comment;

      /* upd by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --start */
      // const url = `mainData/getIndMediInfoHistory/${this.selectedPatId}/${this.getFacilityCd}/${this.sourceDataItem.itemNo}`;
      const url = `mainData/getIndMediInfoHistory/${dispDataItem.patId}/${dispDataItem.facilityCd}/${this.sourceDataItem.itemNo}`;
      /* upd by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --end */
      ApiHelper.get(url).then(response => {
        // 開始日
        this.popDispDataItem.shiji_kaishi_nichi.value = response.data.mindate;
        // 終了日
        this.popDispDataItem.shiji_shuuryou_nichi.value = response.data.maxdate;
        // 曜日
        this.popDispDataItem.youbi.value = response.data.dow;
        // 初回投与日
        this.popDispDataItem.shokai_touyo_nichi.value = this.popDispDataItem.shiji_kaishi_nichi.value;
        //add FutreNetWeb+SI課題管理No5188対応 呉 start
        let youbi = this.popDispDataItem.youbi.value.split(",");
        /* upd by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --start */
        // const url2 = `mainData/getPatMediniceNoCount/${this.selectedPatId}/${this.getFacilityCd}/${this.sourceDataItem.itemNo}/${youbi}`;
        const url2 = `mainData/getPatMediniceNoCount/${dispDataItem.patId}/${dispDataItem.facilityCd}/${this.sourceDataItem.itemNo}/${youbi}`;
        /* upd by chamaojia 2026-03-24 [12462] 患者情報共有->患者経過総合ビューア --end */
        ApiHelper.get(url2).then(response => {
          if(response.data > 0){
            this.isShowMaxDate = false;
          } else {
            this.isShowMaxDate = true;
          }
        }).catch(error => {
          throw error;
        });
        //add FutreNetWeb+SI課題管理No5188対応 呉 end
      })
      .catch(error => {
          throw error;
      });
    },

    dateFormat(txt) {
      return moment(txt).format("YYYY/MM/DD");
    },

    nameFormat(txt) {
      // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
      // return txt.replace(this.MedicineString, "");
      return txt?.replace(this.MedicineString, "");
      // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
    },

    getDateInterval(code) {
      switch (code) {
        case 0: return "毎回";
        case 1: return "毎週";
        case 2: return "1回／2週";
        case 3: return "1回／3週";
        case 4: return "1回／4週";
        case 5: return "1回／月：第1曜日";
        case 6: return "1回／月：第2曜日";
        case 7: return "1回／月：第3曜日";
        case 8: return "1回／月：第4曜日";
        case 9: return "1回／月：最終曜日";
        case 10: return "1回／月：最終治療日";
        default: return "";
      }
    },

    getProcedure(code) {
      const mediFind = this.getMstProcedureData.find(mstData => {
        return mstData.procedureCd === code;
      });
      if (mediFind) {
        return mediFind.pricedureName;
      }
    },

    getTiming(code) {
      const mediFind = this.getMstMedicateTimingData.find(mstData => {
        return mstData.medicateTimingCd === code;
      });
      if (mediFind) {
        return mediFind.medicateTimingName;
      }
    },

    getWeek(code) {
      const result = [{
        key: 1,
        disp: false,
        name: "月",
        sort: 10
      }, {
        key: 2,
        disp: false,
        name: "火",
        sort: 20
      }, {
        key: 3,
        disp: false,
        name: "水",
        sort: 30
      }, {
        key: 4,
        disp: false,
        name: "木",
        sort: 40
      }, {
        key: 5,
        disp: false,
        name: "金",
        sort: 50
      }, {
        key: 6,
        disp: false,
        name: "土",
        sort: 60
      }, {
        key: 0,
        disp: false,
        name: "日",
        sort: 100
      }];

      for (const resultItem of result) {
        if (code.indexOf(resultItem.key) > -1) {
          resultItem.disp = true;
        }
      }

      return result
        .filter(p => p.disp)
        .sort(function(a, b) {
          return a.sort > b.sort ? 1 : -1;
        })
        .map(p => p.name)
        .join('、');
    },
    // add FNSI-FutreNetWeb+SI課題管理No.4360 李 end

    // add FNSI-指示コメントの表示位置の修正 楊 start
    /**
     * 指示コメントの表示位置設定
     * @param itemName 項目名
     */
    setIndTextAlign(itemName, dispData) {
      const classObj = {
        // del FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
        // // add 1006-398 指示の切り替わりポイントを赤くする 陳 start
        // "dispData-color-b": false,
        // "dispData-color-o": false,
        // // add 1006-398 指示の切り替わりポイントを赤くする 陳 end
        // del FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 end
        // add #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm start
        "cell-left-pre-line-style": false,
        // add #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm end
        "cell-left-style": false,
        //mod FNSI-6840 劉全航 start
        "cell-disabled": false,
        //mod FNSI-6840 劉全航 end
        "list-content-col": false
      };
      // mod FNSI-紹介状を追加 楊 start
      //if (itemName.indexOf("コメント") >= 0) {
      if (itemName?.indexOf("コメント") >= 0 || itemName?.indexOf("紹介状") >= 0) {
        // mod FNSI-紹介状を追加 楊 end
        // mod bug 6080 修正 chen start
        if (dispData && dispData.value1 && (dispData.value1 + "").indexOf("：") >= 0) {
          classObj["cell-left-style"] = true;
          // add #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm start
          if (itemName?.indexOf("紹介状") >= 0) {
            classObj["cell-left-pre-line-style"] = true;
          }
          // add #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm end
        } else {
          classObj["list-content-col"] = true;
        }
        // mod bug 6080 修正 chen end
      } else {
        classObj["list-content-col"] = true;
        //mod FNSI-6840 劉全航 start
        if(itemName === "I-HDF設定" && !dispData.data ){
          classObj["cell-disabled"] = true;
        }
        //mod FNSI-6840 劉全航 end
        // add bug #6038 修正 chen start
        //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 start
        // if(itemName === "QB・QDプログラム" && dispData.isDisabled ){
        //mod 7926　【デグレ】特殊血液浄化でB液濃度プログラムが活性化　赵 start
        //if((itemName === "QB・QDプログラム"||itemName === "除水プログラム"||itemName === "Na注入プログラム"||itemName === "透析液濃度プログラム"||itemName === "BV-UFC"||itemName === "透析量プログラム"||itemName === "\t検査日"||itemName === "\t目標Kt/V"  ) && dispData.isDisabled ){
        if((itemName === "B液濃度プログラム"||itemName === "QB・QDプログラム"||itemName === "除水プログラム"||itemName === "Na注入プログラム"||itemName === "透析液濃度プログラム"||itemName === "BV-UFC"||itemName === "透析量プログラム"||itemName === "\t検査日"||itemName === "\t目標Kt/V"  ) && dispData.isDisabled ){
         //mod 7926　【デグレ】特殊血液浄化でB液濃度プログラムが活性化　赵 start
          //mod 6925　治療モードを変更した際の制限事項，注意メッセージについて　張 end
          classObj["cell-disabled"] = true;
        }
        // add bug #6038 修正 chen end
      }
      // del FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
      // if (dispData.colorFlg === 2) {
      //   classObj["dispData-color-o"] = true;
      // } else if (dispData.colorFlg === 1) {
      //   classObj["dispData-color-b"] = true;
      // }
      // del FNSI-障害票一覧_患者経過総合ビューアNo.16-19(指示の切り替わりポイントを赤くする) 李 start
      return classObj;
    },
    // add FNSI-指示コメントの表示位置の修正 楊 end

    /**
     * 一般撮影検査予定には、〇を充てる
     * @param itemName 項目名
     * @param isNispData 回数
     */
    setRedcircle(isExpired, itemName, isNispData, colorFlg) {
      const classObj = {
        "circle-fill-type": false,
        "dispData-color-b": false,
        "dispData-color-o": false
      };

      if (isExpired != 'rstData') {
        if (colorFlg === 2) {
          classObj["dispData-color-o"] = true;
        } else if (colorFlg === 1) {
          classObj["dispData-color-b"] = true;
        }
      }

      // 一般撮影検査予定、かつ、回数があるの場合、〇を充てる
      if (itemName?.indexOf("検査予定") >= 0) {
        if (isNispData) {
          classObj["circle-fill-type"] = true;
        }
      }
      return classObj;
    },

    /**
     * 文字列に警告対象の接頭語（ALERT_PREFIXES）が含まれるか判定する。
     * @param value - 判定する文字列。valueが文字列以外の場合はfalseを返却。
     */
    includesAlertPrefix(value) {
      if (typeof value !== 'string') return false;
      return ALERT_PREFIXES.some(prefix => value.includes(prefix));
    },
    /**
     * セルに警告用cssクラスを適用するか判定する。
     * TODO: 本来は警告対象の判定をフラグで行いたがデータによりフラグ有無があるため、確実に判断できる文言（行ヘッダ/セル）から警告対象を判定する。
     * @param itemName - 行ヘッダー名称
     * @param dispData - セルのデータセット
     */
    shouldApplyAlertClass(itemName, dispData) {
      // セルに値が無い場合、falseを返却
      if ((dispData?.value1 ?? "") === "") return false;

      // セル値に警告対象の接頭語が含まれる場合、trueを返却
      if (this.includesAlertPrefix(dispData.value1)) return true;

      // セルの期限切れフラグがtrueの場合、trueを返却
      if (dispData.isExpired === true) return true;

      // 行ヘッダーに期限切れ文言が含まれるか？
      const hasExpiredPrefix = String(itemName).includes(PREFIX.EXPIRED_PREFIX);
      // 行ヘッダーに期限切れ文言が含まれるが、isExpiredがtrue以外の場合、そのセルは期限切れ前なのでfalseを返却
      if (hasExpiredPrefix && dispData.isExpired !== true) return false;

      // 行ヘッダーに警告対象の接頭語が含まれる場合、trueを返却（投与薬剤や医療材料などは、セルではなく行ヘッダーで警告対象か判断する）
      if (this.includesAlertPrefix(itemName)) return true;

      return false;
    },

    // add FNSI-投与薬剤の詳細情報の修正 楊 start
    /**
     * ツールチップの設定
     * @param medicineType 投与薬剤
     * @param value 薬剤/数量
     * @param setTooltipText 手技/投与タイミング/コメント
     */
    setTooltrip(medicineType, value, setTooltipText) {
      let tooltipText = "";

      // 投与薬剤の場合、ツールチップを設定する
      if (undefined !== medicineType) {
        if (value) {
          tooltipText = value.concat(setTooltipText ? setTooltipText : "")
          // add FNSI-期限切れ削除済みと表示するの修正 李 start
          if (tooltipText.indexOf(this.MedicineString) >= 0) {
            return tooltipText.replace(this.MedicineString, "");
          }
          // add FNSI-期限切れ削除済みと表示するの修正 李 end
        }
      } else {
        // 処理なし
      }
      return tooltipText;
    },
    // add FNSI-投与薬剤の詳細情報の修正 楊 end

    // add FNSI-紹介状を追加 楊 start
    /**
     * 出力データの設定
     * @param isExpired value2
     * @param value1 unit2
     * @param unit1 unit2
     */
    showCellDataInd(isExpired, value1, unit1) {
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng start
      // let rtn = isExpired && value1 ? this.expiredString : "";
      let rtn = "";
      // #10659 禁忌、アレルギー、削除済み、分類不一致、期限切れ、削除済み含むの接頭文字対応 linjunfeng end
      // mod FNSI-障害票一覧_透析液情報編集 楊 start
      // rtn = rtn.concat(value1 ? value1 : "").concat(unit1 ? unit1 : "");
      rtn = rtn.concat(value1 || value1 == 0 ? value1 : "").concat(unit1 ? unit1 : "");
      // mod FNSI-障害票一覧_透析液情報編集 楊 end
      // add FNSI-期限切れ削除済みと表示するの修正 李 start
      if (rtn.indexOf(this.MedicineString) >= 0) return rtn.replace(this.MedicineString, "");
      // add FNSI-期限切れ削除済みと表示するの修正 李 end
      return rtn;
    },

    /**
     * 実績データの出力設定
     * @param value value2
     * @param unit unit2
     */
    showCellData(itemNo,value, unit) {
      // mod 7961抗凝固剤の表示が不正 zhao start
      //let rtn = value ? value : "";
      let rtn;
      if(itemNo==26||itemNo==27||itemNo==28){
          if (value!=null) {
            rtn = value ? value : 0;
          } else {
            rtn = value ? value : "";
          }
      }else{
        // mod 8927【デグレ】患者経過総合ビューアで実測の補液使用数が表示されない chen start
        // rtn = value ? value : "";
        rtn = value != undefined && value != null ? value : "";
        // mod 8927【デグレ】患者経過総合ビューアで実測の補液使用数が表示されない chen  end
      }

      // mod 7961抗凝固剤の表示が不正 zhao end
      // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#3。 周 start
      // rtn = rtn.concat(unit ? unit : "")
      rtn = rtn.toString().concat(unit ? unit : "")
      // mod FNSI-障害票一覧_患者経過総合ビューア_初期表示#3。 周 end
      // add FNSI-障害票一覧_患者経過総合ビューア_初期表示#4。 李 start
      if (rtn.indexOf(this.MedicineString) >= 0) return rtn.replace(this.MedicineString, "");
      // add FNSI-障害票一覧_患者経過総合ビューア_初期表示#4。 李 end
      return rtn;
    },
    // add FNSI-紹介状を追加 楊 end

    /**
     * 指示データ表示フラグ
     * @param value 指示値
     * @param ordNo オーダー番号
     * @param itemName 項目名
     */
    isShowIndData(value, ordNo, itemName) {
      if ("治療予定" === itemName) {
        return true;
      }
      //add 5948 紹介状を押下すると患者イベント画面に遷移する 張 start
      if ("3" === this.selectedIndRst&&"紹介状" === itemName) {
        return false;
      }
      //add 5948 紹介状を押下すると患者イベント画面に遷移する 張 start
      // add bug 6080 修正 chen start
      if ("-1" === ordNo) {
        return true;
      }
      // add bug 6080 修正 chen end

      // add FNSI-障害票一覧_患者経過総合ビューアNo.20 李 start
      if (itemName && itemName.indexOf('検査予定') >= 0) return true;
      // add FNSI-障害票一覧_患者経過総合ビューアNo.20 李 end

      /**
       * 「実績優先表示」選択時しかつ、条件送信後の場合非表示
       *  又は
       * 「指示実績併記表示」選択時かつ、値がnullの場合
       */
      if ("2" === this.selectedIndRst && "0" !== this.getTreatState(ordNo)) {
        return false;
      } else {
        return true;
      }
    },

    checkImagePNG(value) {
      if (value == 'PNG0'
        || value == 'PNG1'
        || value == 'PNG2'
        || value == 'PNG3'
        || value == 'PNG4'
        || value == 'PNG5'
        || value == 'PNG6'
      ) {
        return true
      } else {
        return false
      }
    },

     setImage(value) {
      switch (value) {
        // 条件送信前
        case "PNG0":
          return require("../../../../assets/0.png");
        case "PNG1":
        case "PNG2":
          return require("../../../../assets/1.png");
        case "PNG3":
          return require("../../../../assets/3.png");
        case "PNG4":
        case "PNG5":
          return require("../../../../assets/4.png");
        case "PNG6":
          return require("../../../../assets/6.png");
        default:
          break;
      }
    },

    /**
     * 実績データ表示フラグ
     */
    isShowRstData(value, ordNo, itemName) {
      // 実績データがnullの場合、実績表示しない
      if (null === value) {
        return false;
      }
      if ("治療予定" === itemName) {
        return false;
      }
      // add bug 6080 修正 chen start
      if ("-1" === ordNo) {
        return false;
      }
      // add bug 6080 修正 chen end
      /**
       * 実績データを非表示にする条件
       * 1. 「指示のみ」選択時
       * 2. 「実績優先表示」選択時かつ、条件送信前の場合
       * 3. 「指示実績併記表示」選択時かつ、条件送信前の場合 ←2019/11/21追加
       */
      if (
        "1" === this.selectedIndRst ||
        ("2" === this.selectedIndRst && "0" === this.getTreatState(ordNo)) ||
        ("3" === this.selectedIndRst && "0" === this.getTreatState(ordNo))
      ) {
        return false;
      } else {
        return true;
      }
    },

    // add FNSI-障害票一覧_患者経過総合ビューアNo.84 李 start
    /**
     * 実績データ表示フラグ
     */
    isShowRstDataSen(ordNo, itemName) {
      if ("治療予定" === itemName) {
        return false;
      }
      // add bug 6080 修正 chen start
      if ("-1" === ordNo) {
        return false;
      }
      // add bug 6080 修正 chen end
      /**
       * 実績データを非表示にする条件
       * 1. 「指示のみ」選択時
       * 2. 「実績優先表示」選択時かつ、条件送信前の場合
       * 3. 「指示実績併記表示」選択時かつ、条件送信前の場合 ←2019/11/21追加
       */
      if (
        "1" === this.selectedIndRst ||
        ("2" === this.selectedIndRst && "0" === this.getTreatState(ordNo)) ||
        ("3" === this.selectedIndRst && "0" === this.getTreatState(ordNo))
      ) {
        return false;
      } else {
        return true;
      }
    },
    // add FNSI-障害票一覧_患者経過総合ビューアNo.84 李 end

    /**
     * データセルクラスオブジェクト
     * @param value1   指示値
     * @param value2   実績値
     * @param ordNo    オーダー番号
     * @param itemName 項目名
     * @param type     表示タイプ
     * @param treatDate 治療日
     * @param isNotClickable     無効データフラグ
     */
    // TODO:一時的にコメントアウト
    // dataCellClassObj(value1, value2, ordNo, itemName, type, treatDate) {
    /* eslint-disable no-unused-vars */
    // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
    // dataCellClassObj(value1, value2, ordNo, itemName, type, treatDate, isNotClickable, isCellDisabled) {
    dataCellClassObj(value1, value2, ordNo, itemName, type, treatDate, isNotClickable, isCellDisabled, isAdd) {
    // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
      // 指示表示フラグ
      const indShow = this.isShowIndData(value1, ordNo, itemName);
      // 実績表示フラグ
      const rstShow = this.isShowRstData(value2, ordNo, itemName);
      // チャートタイプフラグ
      const speChartType =
        type !== "chart" && type !== "chart-rst" && type !== "lf";

      const classObj = {
        "data-cell-style": false,
        "rst-data-cell": false,
        "difference-ind-rst-cell": false,
        "today-content-cell": false,
        "past-date-content-cell": false,
        "no-clickable-data-cell": false,
        "cell-disabled": false
      };

      // if (
      //   parseInt(moment().format("YYYYMMDD")) ===
      //   parseInt(moment(treatDate).format("YYYYMMDD"))
      // ) {
      //   classObj["today-content-cell"] = true;
      // } else if (
      //   parseInt(moment().format("YYYYMMDD")) >
      //   parseInt(moment(treatDate).format("YYYYMMDD"))
      // ) {
      //   classObj["past-date-content-cell"] = true;
      // }

      if (null !== ordNo) {
        if (indShow && rstShow && speChartType) {
          // 指示、実績併記
            // mod FNSI-指示と実績の背景色の修正 楊 start
            //classObj["data-cell-style"] = true;
            classObj["rst-data-cell"] = true;
            // mod FNSI-指示と実績の背景色の修正 楊 end
          if (value1 !== value2) {
            classObj["difference-ind-rst-cell"] = true;
          }
        } else if (!indShow && rstShow) {
          // 実績のみ
          classObj["rst-data-cell"] = true;
        }
        if (indShow) {
          // 指示表示
          // クリック不可、灰色背景
          if (isNotClickable) {
            classObj["no-clickable-data-cell"] = true;
          }
        }

        classObj["cell-disabled"] = isCellDisabled;
      }
      // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
      if (isAdd) {
        classObj["rst-data-cell"] = false;
      }
      // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
      return classObj;
    },

    /**
     * 治療状況取得
     */
    getTreatState(ordNo) {
      // 治療状況
      let state = null;
      this.ordMainData.forEach(element => {
        for (const date in element) {
          if (null !== element[date]) {
            // 治療情報一覧のオーダー番号と引数のオーダー番号が一致したら格納
            if (ordNo === element[date].ordNo) {
              state = element[date].rstDialysisState;
            }
          }
        }
      });
      return state;
    },

    /**
     * 縦文字タイトル列クリックイベント
     * @summary 親画面側でイベント処理を実装
     */
    onTitleClick(event) {
      // add 更新中の予定を表示する様にする。 李 start
      let sbpOrdNo = null;
      this.dispDataList.forEach(itemList => {
        itemList.data.forEach(item => {
          if (item.ordNo) sbpOrdNo = item.ordNo;
          return;
        })
      })
      if (sbpOrdNo) this.setScrollBarPositioningOrdNo({ ordNo: sbpOrdNo });
      // add 更新中の予定を表示する様にする。 李 end
      this.$emit("onTitleClick", event, this.dispDataList);
    },
    // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
    onAddImgClick (dispData) {
      // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc start
      if (dispData.isDisabled1) {
        return;
      }
      // upd #11255 FNWで指示無し実績をコンバートしたデータを患者経過総合ビューアで表示するとフリーズする。 20241203 ztc end
      // add 更新中の予定を表示する様にする。 李 start
      let sbpOrdNo = null;
      this.dispDataList.forEach(itemList => {
        itemList.data.forEach(item => {
          if (item.ordNo) sbpOrdNo = item.ordNo;
          return;
        })
      })
      if (sbpOrdNo) this.setScrollBarPositioningOrdNo({ ordNo: sbpOrdNo });
      // add 更新中の予定を表示する様にする。 李 end
      this.$emit("onAddImgClick", dispData);
    },
    // #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end

    /**
     * 横文字タイトル列クリックイベント
     * @summary 親画面側でイベント処理を実装
     * @param event ターゲット
     * @param rowData 行情報
     * @param itemIndex 行番号
     */
    onSubTitleClick(event, rowInfo, index) {
      // add 更新中の予定を表示する様にする。 李 start
      let sbpOrdNo = null;
      this.dispDataList.forEach(itemList => {
        itemList.data.forEach(item => {
          if (item.ordNo) sbpOrdNo = item.ordNo;
          return;
        })
      })
      if (sbpOrdNo) this.setScrollBarPositioningOrdNo({ ordNo: sbpOrdNo });
      // add 更新中の予定を表示する様にする。 李 end
      this.$emit("onSubTitleClick", event, rowInfo, this.dispDataList, index);
    },

    /**
     * データ表示列クリックイベント
     * @summary 親画面側でイベント処理を実装
     * @param event ターゲット
     * @param cellInfo セル情報
     * @param itemName 行項目名
     * @param itemIndex 行番号
     * @param isIndClick 指示データクリックフラグ
     */
    onCellClick(event, cellInfo, itemName, itemIndex, isIndClick) {
      /* del by chamaojia 2023-07-12 患者経総合ビューア：治療進行中に緑色の領域をクリックして画面が遷移しない  --start */
      //add 8105 2023-04-11 GX連携で実装されていない機能 張 start
      // if (!isIndClick) {
      //   return
      // }
      //add 8105 2023-04-11 GX連携で実装されていない機能 張 end
      /* del by chamaojia 2023-07-12 患者経総合ビューア：治療進行中に緑色の領域をクリックして画面が遷移しない  --end */
      // add 更新中の予定を表示する様にする。 李 start
      if (itemName === "クール" || itemName === "治療開始時刻" || itemName === "ベッド") {
        this.setScrollBarPositioningOrdNo({
          ordNo: cellInfo.ordNo
        });
      }
      // add 更新中の予定を表示する様にする。 李 end

      this.$emit(
        "onCellClick",
        event,
        cellInfo,
        itemName,
        this.dispDataList,
        itemIndex,
        isIndClick
      );
    },

    /**
     * データ表示列マウスダウンイベント
     * @summary 親画面側でイベント処理を実装
     * @param event ターゲット
     * @param cellInfo セル情報
     */
    onMouseDown(event, cellInfo) {
      this.$emit(
        "onMouseDown",
        event,
        cellInfo
      );
    },

    /**
     * データ表示列マウスアップイベント
     * @summary 親画面側でイベント処理を実装
     * @param event ターゲット
     * @param cellInfo セル情報
     */
    onMouseUp(event, cellInfo) {
      this.$emit(
        "onMouseUp",
        event,
        cellInfo
      );
    },

    /**
     * データ表示列タッチ開始イベント
     * @summary 親画面側でイベント処理を実装
     * @param event ターゲット
     * @param cellInfo セル情報
     */
    onTouchStart(event, cellInfo) {
      this.$emit(
        "onTouchStart",
        event,
        cellInfo
      );
    },

    /**
     * データ表示列タッチ終了イベント
     * @summary 親画面側でイベント処理を実装
     * @param event ターゲット
     * @param cellInfo セル情報
     */
    onTouchEnd(event, cellInfo) {
      this.$emit(
        "onTouchEnd",
        event,
        cellInfo
      );
    },

    /**
     * HTML出力用空白を付与
     * @description \tをHTML特殊文字の空白に変換
     */
    addSpace(str) {
      if (this.isAbleLf) {
        if (str) {
          // #10977 インジェクション対応 linjunfeng start
          // str = str.replace(/\t/g, "&emsp;&emsp;&emsp;");
          str = str.replace(/\t/g, "");
          // #10977 インジェクション対応 linjunfeng end
        }
      }
      return str;
    },

    /**
     * 下枠線のスタイルを適用させる
     * @description 下枠が必要な場合は下枠線を追加し、不要の場合は外す
     * @param isBorderBottom 下枠線が必要かどうか
     */
    addBorderBottom(isBorderBottom) {
      if (isBorderBottom) {
        return { "border-bottom": "solid 1px var(--ntss-border-color)" };
      } else {
        return { "border-bottom": "none" };
      }
    },

    /**
     * 指示・実績の区切り線を設定
     * @param value1   指示表示値
     * @param value2   実績表示値
     * @param ordNo    オーダー番号
     * @param itemName 表示名
     */
    setVerticalBorder(value1, value2, ordNo, itemName) {
      // 実績表示フラグ
      const rstShow = this.isShowRstData(value2, ordNo, itemName);
      if (null !== ordNo && rstShow) {
        return "vertical-border";
      } else {
        return "";
      }
    },

    // add FNSI-FutreNetWeb+SI課題管理No.4360 李 start
    /**
     * 表示条件設定ポップオーバー表示
     */
     showPopoverSetting(event, direction, coverTarget) {
      this.popoverTarget = event;
      this.popoverDirection = direction;
      this.popoverCoverTarget = coverTarget;
      this.medAuxiliaryShowFlg = true;
    }
    // add FNSI-FutreNetWeb+SI課題管理No.4360 李 end
  },

  beforeDestroy() {
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
  },

  // mod #11147 患者経過総合ビューアの子画面で編集後に親画面のスクロール位置を元の位置のままとする。 start
  // add FNSI-性能を最適化する 李 start
  //destroyed() {
  //  const scrollBarPositioning = document.getElementById("scrollBarPositioning");
  //  if (scrollBarPositioning) {
  //    // 画面の定位
  //    document.getElementById('pat_viewer').scrollTop = null;
  //  }
  //}
  // add FNSI-性能を最適化する 李 end
  // mod #11147 患者経過総合ビューアの子画面で編集後に親画面のスクロール位置を元の位置のままとする。 end
};
</script>

<style scoped lang="scss">
/* 患者経過総合ビューア共通スタイル定義 */
@import "../../css/style.scss";

/*
 * 指示・実績併記
 */
.data-cell-style {
  background: linear-gradient(
    450deg,
    transparent,
    var(--ntss-list-content-rst-background-color)
  );
}

img {
  width: auto;
  height: 27px;
  margin-top: 1px;;
}

@media screen and (max-width:480px) {
  img {
    width: 100%;
    height: auto;
    margin-top: 5px;
  }
}

.chart-con{
  height: 100px;
}

.rst-chart-con, .drug-graph-con {
  height: 150px;
}

.comprehensive-graph-con{
  height: 150px;
}
/*
 * 実績
 */
.rst-data-cell {
  background-color: var(--ntss-list-content-rst-background-color);
}

/*
 * 身体情報DW
 */
.no-clickable-data-cell {
  background-color: var(--ntss-list-content-disable-background-color);
}

/*
 * 改行スタイル
 */
.lf-style {
  padding: 3px;
}

/*
 * 指示、実績区切り線
 */
.data-cell-separator {
  background: linear-gradient(to top, lightg, #000) repeat-y center/1px;
}

/* add FNSI-投与薬剤の補助画面を追加 周 start */
.list-content-col-title-medicine-small > label,
.list-content-col-title-medicine-medium > label,
.list-content-col-title-medicine-large > label,
.list-content-col-title-medicine-x-large > label {
  float: left;
  height: 100%;

  // mod 6737         張 start
  //mod 7269 投与薬剤補足情報の吹き出し表示ができない 張 start
  min-width: 95px;
  max-width: 95px;
  // width: 100%;
  //mod 7269 投与薬剤補足情報の吹き出し表示ができない 張 end
  //mod 6737         張 start
}
.list-content-col-title-medicine-large > label,
.list-content-col-title-medicine-x-large > label {
  min-width: 90px;
  max-width: 90px;
}

.list-content-col-title-medicine-small > .fa-info-circle.fa,
.list-content-col-title-medicine-medium > .fa-info-circle.fa,
.list-content-col-title-medicine-large > .fa-info-circle.fa,
.list-content-col-title-medicine-x-large > .fa-info-circle.fa {
  float: left;
  height: 100%;
  margin: 4px;
  font-size: 1.5em;
}
.list-content-col-title-medicine-medium > .fa-info-circle.fa {
  font-size: 1.3em;
}
.list-content-col-title-medicine-large > .fa-info-circle.fa,
.list-content-col-title-medicine-x-large > .fa-info-circle.fa {
  font-size: 1.2em;
}
/* add FNSI-投与薬剤の補助画面を追加 周 end */

/* add FNSI-グラフ３軸表示対応「グラフ共通」 周 start */
.list-content-col-chart-label {
  max-width: 170px;
  min-width: 170px;
  //mod FNSI-6868 劉全航 start
  // z-index: 2;
  z-index: 1;
  //mod FNSI-6868 劉全航 end
}
.list-content-col-chart-label > ons-row {
  word-break: break-all;
  /*max-width: 160px;*/
  /*min-width: 160px;*/
  -webkit-box-sizing: border-box;
  -o-box-sizing: border-box;
  box-sizing: border-box;
  border-bottom: solid 1px var(--ntss-border-color);
  border-right: solid 1px var(--ntss-border-color);

  background-color: var(--ntss-header-background-color);
  color: var(--ntss-header-color);
  left: 0px;
  position: sticky;
  position: -webkit-sticky;
  z-index: 1;
}
.list-content-col-chart-label > ons-row > ons-col:first-child {
  word-break: break-all;
  -webkit-writing-mode: vertical-lr;
  -ms-writing-mode: tb-lr;
  writing-mode: vertical-lr;
  /* max-width: 30px; */
  /* min-width: 1em; */
  height: 150px;
  max-width: 2.5em;
  line-height: 1.1em;

  -webkit-box-align: center;
  -ms-flex-align: center;
  align-items: center;
  display: -webkit-box;
  display: -ms-flexbox;
  display: flex;
  padding: 5px 3px;
  font-size: 11pt;
}
.list-content-col-chart-label .list-content-col-chart-tick {
  font-size: 10pt;
  padding-bottom: 11px;
  border-left: solid 1px var(--ntss-border-color);
}
.comprehensive-graph {
  height: 150px;
}
/* add FNSI-グラフ３軸表示対応「グラフ共通」 周 end */

.list-content-col-chart-tick {
  flex-direction: column-reverse;
  justify-content: space-between;
  display: flex;
}

.list-content-col-chart-tick > ons-row {
  flex-direction: row-reverse;
  height: auto;
}

.difference-ind-rst-cell {
  // color: blue;
}

/*
 * 本日のデータセルスタイル
 */
.today-content-cell {
  background: #ffa500;
}

/*
 * 過去日のデータセルスタイル
 */
.past-date-content-cell {
  background: #f7ca79;
}

.div-style {
  height: 100%;
}

.vertical-border {
  // border-right: 1px solid black;
}

.cell-style {
  margin: auto;
  padding: 1px 3px;
  height: 100%;
  /* add FNSI-障害票一覧_患者経過総合ビューア_初期表示#7。 周 start */
  word-break: break-word;
  /* add FNSI-障害票一覧_患者経過総合ビューア_初期表示#7。 周 end */
}

// add FNSI-指示コメントの表示位置の修正 楊 start
.cell-left-style {
  @include word-break;
  @include list-border-style;
  align-items: center;
  text-align: left;
  width: 100%;
  min-width: 75px;
  height: auto;
  color: var(--ntss-base-color);
}
// add FNSI-指示コメントの表示位置の修正 楊 end
// add #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm start
.cell-left-pre-line-style {
  white-space: pre-line;
}
// add #12166 患者経過総合ビューアの項目「紹介状」の表示不正 zkm end

// add FNSI-放射線検査の表示の修正 楊 start
.circle-fill-type {
  width: 16px;
  height: 16px;
  border-radius: 50%;
  border: solid 1px;
  //mod FutreNetWeb+SI課題管理 no.5932 劉全航 start
  // border-color: #000000;
  border-color: var(--ntss-base-color);
  //mod FutreNetWeb+SI課題管理 no.5932 劉全航 end
  text-align: center;
  overflow: hidden;
  font-size: 0.8em;
  left: 0;
  top: 0;
  right: 0;
  bottom: 0;
  margin: auto;
}
// add FNSI-放射線検査の表示の修正 楊 end

.cell-style-image {
  margin: 0 auto;
}

.cell-disabled {
  background-color: var(--pat-viewer-ind-cond-info-disabled);
}

.padding-chart {
  padding-bottom: 11px;
}

.dispData-color-b {
  color: #0055ff;
}

.dispData-color-o {
  color: var(--pat-viewer-same-medicine-cell-text-color); /* テーマ毎に、同日同薬の文字色を変える */
}

.cell--alert {
  background-color: var(--pat-viewer-alert-cell-background-color);
  color: var(--pat-viewer-alert-cell-text-color); /* 警告スタイル適用時文字色はテーマ関係なく、白テーマのbase-colorを使用する */
}

.cell--alert .dispData-color-o {
  color: #FFbb00; /* 警告スタイル適用時、同日同薬文字色指定を上書き */
}

.header--alert {
  color: #FF6666;
}

@media screen and (max-width:480px) {
  img {
    width: 100%;
    height: auto;
    margin-top: 5px;
  }
  .cell-image{
    width: auto;
    height: 27px;
    margin-top: 5px;
  }
}
// #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng start
.add-img-wrapper{
  width: 100%;
  height: 100%;
  text-align: right;
}
.add-img{
  height: 25px;
}
// #10266 患者経過総合ビューアの投与薬剤、医療材料、指示コメントの新規追加行 linjunfeng end
@media print {
  .list-content-row-height {
    display: inline-flex;
    line-height: normal;
  }
  div /deep/ .highcharts-container  {
    width: auto !important;
    height: auto !important;
  }
  div /deep/ .highcharts-root  {
    width: 100%;
    height: 100%;
  }
}

</style>

<style>
  .modal-contents > ons-row {
    border-bottom: 1px solid var(--ntss-border-color);
    color: var(--ntss-base-color);
    padding: 10px;
    margin: 3px;
    width: auto;
  }
  .popover-style .popover--left__content {
    width: 370px;
  }

</style>
