/** * 治療予定(操作) * 各モーダルに、過去日、当日、未来日のデータを送る */

<template>
  <div>
    <!-- cancelable:背景をタッチした際にポップオーバーを閉じる -->
    <v-ons-popover
      :visible.sync="popoverData.popoverVisible"
      :target="popoverData.popoverTarget"
      :direction="popoverData.popoverDirection"
      @posthide="closePopover"
      :class="[fontSizeSet, 'selection-button']"
      canselable
    >
      <div>
        <v-ons-modal :visible="modalVisibleCreate">
          <input-item
            v-if="modalVisibleCreate"
            :settingData="settingData"
            @hide-modal="hideModalCreate"
          >
            <div :is="selectTag" :component-names="componentNames" v-bind="sampleDates"></div>
          </input-item>
        </v-ons-modal>
        <v-ons-row style="text-align: center;">
          <v-ons-button
            v-if="popoverData.planCreateVisible"
            class="button-style"
            @click="showModalCreate('ind-plan-create', '治療予定作成');"
          >
            治療予定作成
          </v-ons-button>
        </v-ons-row>
        <v-ons-row style="text-align: center;">
          <v-ons-button
            v-if="popoverData.copyFromVisible"
            class="button-style"
            @click="showModalCopy(popoverData.setFlag, '123', '2', '1');"
            >治療予定(コピー元)</v-ons-button
          >
        </v-ons-row>
        <v-ons-row style="text-align: center;">
          <v-ons-button
            v-if="popoverData.copyToVisible"
            class="button-style"
            @click="showModalCopy(popoverData.setFlag, '123', '2', '1');"
            >治療予定(コピー先)</v-ons-button
          >
        </v-ons-row>
        <v-ons-modal :visible="modalVisibleCopy">
          <treatPlan-copy
            :propOrdNo="ordNo"
            :propPatId="popoverData.patId"
            :propFacilityCd="facilityCd"
            :propDateFrom="dateStart"
            :propDateTo="dateEnd"
            :propSelFlag="popoverData.setFlag"
            :propShowFlag="modalVisibleCopy"
            @hide-modal="hideModalCopy"
          />
        </v-ons-modal>
        <v-ons-row style="text-align: center;">
          <v-ons-button
            v-if="popoverData.moveVisible"
            class="button-style"
            @click="showModalMove(popoverData.selectDate, '123', '3', '1');"
            >移動</v-ons-button
          >
        </v-ons-row>
        <v-ons-modal :visible="modalVisibleMove">
          <treatPlan-move
            :propOrdNo="ordNo"
            :propFacilityCd="facilityCd"
            :propPatId="patId"
            :propDialysisDate="dialysisDate"
            :propShowFlag="modalVisibleMove"
            @setHistoryJson="setHistoryJson"
            @hide-modal="hideModalMove"
          />
        </v-ons-modal>
        <v-ons-row style="text-align: center;">
          <v-ons-button
            v-if="popoverData.changeWeekVisible"
            class="button-style"
            @click="showModalChangeWeek"
            >曜日パターン変更</v-ons-button
          >
        </v-ons-row>
        <v-ons-modal :visible="modalVisibleChangeWeek">
          <changedayofweekpattern
            :facilityCd="facilityCd"
            :propKurCd="kurCd"
            :propKurName="kurName"
            :treatItemCd="treatItemCd"
            :treatItemName="treatItemName"
            :pat-id="popoverData.patId"
            :showFlag="modalVisibleChangeWeek"
            :date-start="dateStart"
            :date-end="dateEnd"
            :header-title="headerTitleChangeWeek"
            :ind-class="indClass"
            @hide-modal="hideModalChangeWeek"
          />
        </v-ons-modal>
        <v-ons-row style="text-align: center;">
          <v-ons-button
            v-if="popoverData.stopVisible"
            class="button-style"
            @click="showModalCreate('ind-plan-delete', '治療予定削除');"
            >中止</v-ons-button
          >
        </v-ons-row>
        <!-- 中止のモーダルはまだできていないので、できたらここに挿入 -->
        <v-ons-row style="text-align: center;">
          <v-ons-button v-if="popoverData.manualCreateVisible" class="button-style"
            >手動実績作成</v-ons-button
          >
          <!-- 手動実績作成のモーダルはまだできていないので、できたらここで挿入 -->
        </v-ons-row>
        <v-ons-row style="text-align: center;">
          <v-ons-button class="button-style" @click="closePopover">閉じる</v-ons-button>
        </v-ons-row>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
import BasePage from "@/components/BasePage";
import HeaderItem from "@/components/header-contents/CommonPatientInformationHeaderItem";
import TreatPlanMainDriver from "@/components/indication/TreatPlanMainDriver";
import TreatPlanCopy from "@/components/indication/TreatPlanCopy";
import TreatPlanMove from "@/components/indication/TreatPlanMove";
import ChangeDayOfWeekPattern from "@/components/indication/ChangeDayOfWeekPattern";
import IndPlanCreate from "@/components/indication/IndPlanCreate";
import IndPlanDelete from "@/components/indication/IndPlanDelete";
import InputItem from "@/components/indication/IndEditBase";
import PopoverMixin from "@/components/PopoverMixin";

export default {
  mixins: [PopoverMixin],

  components: {
    "base-page": BasePage,
    "header-content": HeaderItem,
    "main-content": TreatPlanMainDriver,
    "treatPlan-copy": TreatPlanCopy,
    "treatPlan-move": TreatPlanMove,
    "ind-plan-create": IndPlanCreate,
    "ind-plan-delete": IndPlanDelete,
    "input-item": InputItem,
    changedayofweekpattern: ChangeDayOfWeekPattern
  },

  props: {
    popoverData: {
      ordNo: {
        type: String,
        default: "123"
      },
      facilityCd: {
        type: String,
        default: "000001"
      },
      patId: {
        type: String,
        default: "000000000001"
      },
      popoverVisible: {
        type: Boolean,
        default: false
      },
      popoverDirection: {
        type: String,
        default: "down"
      },
      popoverTarget: {},
      planCreateVisible: {
        type: Boolean,
        default: true
      },
      copyFromVisible: {
        type: Boolean,
        default: true
      },
      copyToVisible: {
        type: Boolean,
        default: true
      },
      moveVisible: {
        type: Boolean,
        default: true
      },
      stopVisible: {
        type: Boolean,
        default: true
      },
      changeWeekVisible: {
        type: Boolean,
        default: true
      },
      manualCreateVisible: {
        type: Boolean,
        default: true
      },
      setFlag: {
        type: String,
        default: "0"
      },
      selectDate: {
        type: String,
        default: "2018-10-01"
      },
      selectLastDate: {
        type: String,
        default: "2018-10-07"
      },
      dateFlag: {
        type: Number,
        default: 0
      },
      clickLocationFlag: {
        //行項目(0)、セル(1)、日時ヘッダー(2)
        type: Number,
        default: 0
      },
      TreatPlanDataSet: {
        type: Array,
        default: []
      },
      dateStart: {}
    }
  },
  data() {
    return {
      ordNo: "123",
      patId: "100000000001",
      facilityCd: "000001",
      dateStart: "",
      dateEnd: "",
      indClass: "1",
      modalVisible: false,
      modalVisibleCreate: false, //治療予定 作成 画面の表示非表示フラグ
      modalVisibleCopy: false, //治療予定 コピー 画面の表示非表示フラグ
      modalVisibleMove: false, //治療予定 移動   画面の表示非表示フラグ
      modalVisibleChangeWeek: false, //曜日パターン変更   画面の表示非表示フラグ
      headerTitleCopy: "予定コピー", //治療予定 コピー 画面のタイトル
      headerTitleMove: "予定移動", //治療予定 移動   画面のタイトル
      headerTitleChangeWeek: "曜日パターン変更", //曜日パターン変更   画面のタイトル
      selectedDate: "2018-10-18",
      setFlag: "0", //選択された日付がコピー元(0)かコピー先(1)かのフラグ
      kurCd: "", //クールコード
      bedCd: "", //ベッドコード
      kurName: "", //クール名
      treatItemCd: "", //治療方法コード
      treatItemName: "", //治療方法名称
      dialysisDate: "", //透析日
      historyJson: {}, //履歴ロガー用
      saveFlag: false, //履歴ロガー登録発火用
      selectTag: "ind-plan-create",
      settingData: {
        headerTitle: "治療予定作成",
        patId: "000000000001",
        startDate: "2019-01-07",
        endDate: "2019-01-14",
        segmentLabel1: "通常",
        segmentLabel2: "隔日",
        segmentLabel3: "編集",
        segmentLabel4: "中止",
        segmentLabel5: "隔週",
        showSegment: true,
        showNewEdit: false,
        showWeeks: true,
        showKur: false,
        showTreat: false
      },
      componentNames: [
        { id: "1", name: "ind-treat-time", fields: {} },
        { id: "2", name: "ind-treat-va", fields: {} },
        { id: "3", name: "ind-treat-target-weight", fields: {} },
        { id: "4", name: "ind-treat-filter-limit", fields: {} },
        { id: "5", name: "ind-treat-dialyzer", fields: {} },
        { id: "6", name: "ind-treat-separatory-column", fields: {} },
        { id: "7", name: "ind-treat-first-pass", fields: {} },
        { id: "8", name: "ind-treat-second-pass", fields: {} },
        { id: "9", name: "ind-treat-needle", fields: {} },
        { id: "13", name: "ind-treat-tube", fields: {} },
        { id: "14", name: "ind-treat-blood-flow", fields: {} },
        { id: "15", name: "ind-treat-dialysate", fields: {} },
        { id: "17", name: "ind-treat-dialysate-amount", fields: {} },
        { id: "16", name: "ind-treat-dialysate-flow-rate", fields: {} },
        { id: "18", name: "ind-treat-dialysate-temperature", fields: {} },
        { id: "19", name: "ind-treat-iv", fields: {} },
        { id: "20", name: "ind-treat-iv-amount", fields: {} },
        { id: "21", name: "ind-treat-iv-selection", fields: {} },
        { id: "22", name: "ind-treat-iv-count", fields: {} },
        { id: "23", name: "ind-treat-iv-temperature", fields: {} },
        { id: "24", name: "ind-treat-iv-flow-rate", fields: {} },
        { id: "25", name: "ind-treat-anti-coagulant", fields: {} },
        { id: "26", name: "ind-treat-anti-coagulant-amount", fields: {} },
        { id: "27", name: "ind-treat-anti-coagulant-flow-rate", fields: {} },
        { id: "28", name: "ind-treat-anti-coagulant-amount-total", fields: {} },
        { id: "29", name: "ind-treat-ip-selection", fields: {} },
        { id: "30", name: "ind-treat-ip-amount", fields: {} },
        { id: "31", name: "ind-treat-ip-start", fields: {} },
        { id: "32", name: "ind-treat-ip-flow-rate", fields: {} },
        { id: "33", name: "ind-treat-ip-flow-rate-limit", fields: {} },
        { id: "34", name: "ind-treat-ip-oneshot-selection", fields: {} },
        { id: "35", name: "ind-treat-ip-auto-off", fields: {} },
        { id: "36", name: "ind-treat-ip-auto-off-timing", fields: {} },
        { id: "37", name: "ind-treat-ip-monitor-off", fields: {} },
        { id: "38", name: "ind-treat-ip-monitor-off-timing", fields: {} }
      ],
      sampleDates: {
        disabledDates: [
          "20181224",
          "20181225",
          "20181226",
          "20181227",
          "20181228",
          "20181229",
          "20181230"
        ],
        selectedDates: [
          "20181223",
          "20181217",
          "20181218",
          "20181219",
          "20181220",
          "20181221",
          "20181222",
          "20181223"
        ]
      }
    };
  },

  methods: {
    /**
     * モーダル非表示化処理(選択肢 呼び出し元)
     */
    closePopover() {
      //console.log('選択肢モーダルを閉じます');
      this.popoverData.popoverVisible = false;
    },

    /**
     * モーダル表示処理(治療予定 作成)
     */
    showModalCreate(code, title) {
      //console.log('治療予定の作成をします');
      this.SetData();
      //呼び出し元ポップオーバー非表示
      this.popoverData.popoverVisible = false;
      //スロット変更
      this.selectTag = code;
      if (this.selectTag == "ind-plan-delete") {
        this.settingData.showWeeks = false;
        this.settingData.showNewEdit = false;
        this.settingData.showDelete = true;
        this.settingData.showSegment = false;
        this.settingData.showKur = true;
        this.settingData.showTreat = true;
        this.settingData.hrOnder = false;
        this.settingData.hrUnder = true;
        this.settingData.monday = true;
        this.settingData.tuesday = true;
        this.settingData.wednesday = true;
        this.settingData.thursday = true;
        this.settingData.friday = true;
        this.settingData.saturday = true;
        this.settingData.sunday = true;
      } else {
        this.settingData.showDelete = false;
        this.settingData.showWeeks = true;
        this.settingData.hrOnder = true;
        this.settingData.hrUnder = true;
        this.settingData.monday = false;
        this.settingData.tuesday = false;
        this.settingData.wednesday = false;
        this.settingData.thursday = false;
        this.settingData.friday = false;
        this.settingData.saturday = false;
        this.settingData.sunday = false;
        this.settingData.showSegment = true;
        this.settingData.showNewEdit = false;
        this.settingData.showKur = false;
        this.settingData.showTreat = false;
      }
      //スロットタイトル変更
      this.settingData.headerTitle = title;
      //ポップオーバーの表示
      this.modalVisibleCreate = true;
    },

    /**
     * モーダル非表示化処理(治療予定 作成)
     */
    hideModalCreate() {
      this.modalVisibleCreate = false;
    },

    /**
     *  モーダル表示処理(治療予定 コピー)
     *  @param setDate      選択された日付
     *  @param setFlag      選択された日付がコピー元(0)かコピー先(1)かのフラグ
     *  @param ordNo        オーダー番号
     *  @param patId        患者ID
     *  @param facilityCd   施設コード
     */
    showModalCopy(setFlag, ordNo, patId, facilityCd) {
      this.ordNo = ordNo;
      this.patId = patId;
      this.facilityCd = facilityCd;
      this.setFlag = setFlag;
      if (0 == setFlag) {
        //コピー元
        this.dateStart = this.popoverData.selectDate;
        //console.log(`dateStart: ${this.dateStart}`);
        //console.log('コピー元モーダル表示');
      } else {
        //コピー先
        this.dateEnd = this.popoverData.selectDate;
        //console.log(`dateEnd: ${this.dateEnd}`);
        //console.log('コピー先モーダル表示');
      }
      //呼び出し元(選択肢)モーダルを非表示化処理
      this.popoverData.popoverVisible = false;
      //モーダル表示
      this.modalVisibleCopy = true;
    },

    /**
     * モーダル非表示処理(治療予定 コピー)
     */
    hideModalCopy() {
      this.modalVisibleCopy = false;
    },

    /**
     * モーダル表示処理(治療予定 移動)
     * @param dialysisDate 透析日
     * @param ordNo オーダー番号
     * @param patId 患者ID
     * @param facilityCd 施設コード
     */
    showModalMove(dialysisDate, ordNo, patId, facilityCd) {
      //console.log('治療予定を移動します');
      //引数のパラメータ変数へのセット
      this.ordNo = ordNo;
      this.patId = patId;
      this.facilityCd = facilityCd;
      this.dialysisDate = dialysisDate;
      //console.log(`dialysisDate: ${this.dialysisDate}`);
      //呼び出し元(選択肢)モーダルを非表示化処理
      this.popoverData.popoverVisible = false;
      //モーダル表示
      this.modalVisibleMove = true;
    },

    /**
     * モーダル非表示化処理(治療予定 移動)
     */
    hideModalMove() {
      this.modalVisibleMove = false;
    },

    /**
     * モーダル表示処理(治療予定 曜日パターン変更)
     * @param setDate 移動元日付
     * @param kurCd クールコード
     * @param kurName クール名
     * @param treatItemCd 治療方法コード
     * @param treatItemName 治療方法名称
     */
    showModalChangeWeek() {
      //呼び出し元(選択肢)モーダルを非表示化処理
      this.popoverData.popoverVisible = false;
      //モーダル表示
      this.modalVisibleChangeWeek = true;
    },

    /**
     * モーダル非表示化処理(治療予定 曜日パターン変更)
     */
    hideModalChangeWeek() {
      this.modalVisibleChangeWeek = false;
    },

    //settingDateにpropsのデータを格納する
    SetData() {
      this.settingData.patId = this.popoverData.patId;
      this.settingData.startDate = this.popoverData.selectDate;
      this.settingData.endDate = this.popoverData.selectLastDate;
      //console.log(`this.settingData.patId: ${this.settingData.patId}`);
      //console.log(`this.settingData.startDate: ${this.settingData.startDate}`);
      //console.log(`this.settingData.endDate: ${this.settingData.endDate}`);
    },

    /**
     *   履歴ログのSetter(格納先はロガーのPrpsにバインド)
     */
    setHistoryJson(jsonValue) {
      //console.log('setHistoryJson start');
      this.historyJson = jsonValue;
      //console.log('setHistoryJson end');
    }
  }
};
</script>

<style scoped>
.button-style {
  padding: 0 !important;
  width: 100px !important;
  height: 30px !important;
  font-size: 10pt !important;
  margin-top: 10px;
}
.selection-button {
  text-align: center;
}
</style>
