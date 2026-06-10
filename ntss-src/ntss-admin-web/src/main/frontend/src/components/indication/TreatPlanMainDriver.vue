/**
* テストビューア
*/

<template>
  <main-content>
    <div>
      <p style="text-align: center">
        <!-- setDate,selFlag,ordNo,patId,facilityCd -->
        <v-ons-button @click="showModalCopy('2018-10-18', '0', '123', '2', '1')"
          >治療予定(コピー) コピー元選択 2018-10-18</v-ons-button
        >
      </p>
      <p style="text-align: center">
        <!-- setDate,selFlag,ordNo,patId,facilityCd -->
        <v-ons-button @click="showModalCopy('2018-10-22', '1', '123', '2', '1')"
          >治療予定(コピー) コピー先選択 2018-10-22</v-ons-button
        >
      </p>

      <v-ons-modal :visible="modalVisibleCopy">
        <treatplan-copy
          :propOrdNo="ordNo"
          :propPatId="patId"
          :propFacilityCd="facilityCd"
          :propDateFrom="dateStart"
          :propDateTo="dateEnd"
          :propSelFlag="selFlag"
          :propShowFlag="modalVisibleCopy"
          @hide-modal="hideModalCopy"
        />
      </v-ons-modal>
    </div>
    <div>
      <p style="text-align: center">
        <v-ons-button @click="showModalMove('2018-10-25', '123', '3', '1')"
          >治療予定(移動)</v-ons-button
        >
      </p>
      <v-ons-modal :visible="modalVisibleMove">
        <treatplan-move
          :propOrdNo="ordNo"
          :propFacilityCd="facilityCd"
          :propPatId="patId"
          :propDialysisDate="dialysisDate"
          :propShowFlag="modalVisibleMove"
          @setHistoryJson="setHistoryJson"
          @hide-modal="hideModalMove"
        />
        <!--
              :propBedCd="bedCd"
              :propKurCd="kurCd"
              :propKurName="kurName"
              :propTreatItemCd="treatItemCd"
              :propTreatItemName="treatItemName"
-->
      </v-ons-modal>
    </div>
    <div>
      <p style="text-align: center">
        <v-ons-button
          @click="
            showModalChangeWeek(
              '2018-10-25',
              '002',
              '午後2',
              '00000000000000000001',
              'ECUM'
            )
          "
          >曜日パターン変更</v-ons-button
        >
      </p>
      <v-ons-modal :visible="modalVisibleChangeWeek">
        <changedayofweekpattern
          :facilityCd="facilityCd"
          :propKurCd="kurCd"
          :propKurName="kurName"
          :treatItemCd="treatItemCd"
          :treatItemName="treatItemName"
          :pat-id="patId"
          :showFlag="modalVisibleChangeWeek"
          :date-start="dateStart"
          :date-end="dateEnd"
          :header-title="headerTitleChangeWeek"
          :ind-class="indClass"
          @hide-modal="hideModalChangeWeek"
        />
        <!-- <input-item></input-item> -->
      </v-ons-modal>
    </div>
    <div>
      <inputCalendar
        ref="refInputCalendarTo"
        :propHeight="15"
        :propWidth="100"
        :propDispFlag="modalVisibleMove"
        :propSetMinMaxFromTodayTo1Year="true"
        @getDateValue="getDateValue"
      ></inputCalendar>
    </div>
    <div>
      <historyLogger
        :propHistoryJson="historyJson"
        :propSaveFlag="saveFlag"
      ></historyLogger>

      <!--仮送信ボタン-->
      <input type="button" value="ログ送信開始ボタン" @click="setSendLog()" />
    </div>
  </main-content>
</template>

<script>
/* eslint-disable */
// import Vue from 'vue';
import TreatPlanCopy from "@/components/indication/TreatPlanCopy";
import TreatPlanMove from "@/components/indication/TreatPlanMove";
import ChangeDayOfWeekPattern from "@/components/indication/ChangeDayOfWeekPattern";
import inputCalendar from "./InputCalendar";
import historyLogger from "./HistoryLogger";

const components = {
  "treatplan-copy": TreatPlanCopy,
  "treatplan-move": TreatPlanMove,
  changedayofweekpattern: ChangeDayOfWeekPattern,
  inputCalendar,
  historyLogger,
};

const computed = {};

const watch = {};

const filters = {};

const created = function () {};

const mounted = function () {};

export default {
  components,
  data() {
    return {
      ordNo: "123",
      patId: "100000000001",
      facilityCd: "000001",
      dateStart: "",
      dateEnd: "",
      indClass: "1",
      modalVisible: false,
      modalVisibleCopy: false, //治療予定 コピー 画面の表示非表示フラグ
      modalVisibleMove: false, //治療予定 移動   画面の表示非表示フラグ
      modalVisibleChangeWeek: false, //曜日パターン変更   画面の表示非表示フラグ
      headerTitleCopy: "予定コピー", //治療予定 コピー 画面のタイトル
      headerTitleMove: "予定移動", //治療予定 移動   画面のタイトル
      headerTitleChangeWeek: "曜日パターン変更", //曜日パターン変更   画面のタイトル
      selectedDate: "2018-10-18",
      selFlag: "0", //選択された日付がコピー元(0)かコピー先(1)かのフラグ
      kurCd: "", //クールコード
      bedCd: "", //ベッドコード
      kurName: "", //クール名
      treatItemCd: "", //治療方法コード
      treatItemName: "", //治療方法名称
      dialysisDate: "", //透析日
      historyJson: {}, //履歴ロガー用
      saveFlag: false, //履歴ロガー登録発火用
    };
  },
  methods: {
    /**
     */
    setSendLog() {
      //saveFlagの変化がfalse->trueという方向でほしいので以下のような処理となります。
      //console.log("bfr this.saveFlag:" + this.saveFlag);
      //      if(this.saveFlag)
      //      {//一旦falseに変更
      //        this.saveFlag = false ;
      //      }
      //      this.saveFlag = true ;
      this.saveFlag = !this.saveFlag;
      //console.log("aft this.saveFlag:" + this.saveFlag);
    },
    /**
     */
    testMethod() {
      //console.log("なんか呼んだ?・ω・?");
    },
    /**
     *   履歴ログのSetter(格納先はロガーのPrpsにバインド)
     */
    setHistoryJson(jsonValue) {
      //console.log("setHistoryJson start") ;
      this.historyJson = jsonValue;
      //console.log("setHistoryJson end") ;
    },

    getDateValue(value) {},
    showModal() {
      this.modalVisible = true;
    },
    hideModal() {
      this.modalVisible = false;
    },
    /**
     * モーダル表示処理(治療予定 コピー)
     *   @param setDate      選択された日付
     *   @param setFlag      選択された日付がコピー元(0)かコピー先(1)かのフラグ
     *   @param ordNo        オーダー番号
     *   @param patId        患者ID
     *   @param facilityCd   施設コード
     */
    showModalCopy(setDate, selFlag, ordNo, patId, facilityCd) {
      this.ordNo = ordNo;
      this.patId = patId;
      this.facilityCd = facilityCd;

      this.selFlag = selFlag;
      if (0 == selFlag) {
        //コピー元
        this.dateStart = setDate;
      } else {
        //コピー先
        this.dateEnd = setDate;
      }
      this.modalVisibleCopy = true;
    },
    /**
     *   モーダル非表示化処理(コピー画面)
     */
    hideModalCopy() {
      this.modalVisibleCopy = false;
    },
    /**
     *   モーダル表示処理(移動画面)
     *   @param dialysisDate 透析日
     *   @param ordNo        オーダー番号
     *   @param patId        患者ID
     *   @param facilityCd   施設コード
     */
    showModalMove(dialysisDate, ordNo, patId, facilityCd) {
      //引数のパラメータ変数へのセット
      this.ordNo = ordNo;
      this.patId = patId;
      this.facilityCd = facilityCd;
      this.dialysisDate = dialysisDate;
      //モーダル表示
      this.modalVisibleMove = true;
    },
    /**
     *   モーダル非表示化処理(移動画面)
     */
    hideModalMove() {
      this.modalVisibleMove = false;
    },
    //モーダル表示:曜日パターン変更処理
    /**
     *   @param setDate    移動元日付
     *   @param kurCd      クールコード
     *   @param kurCd      クール名
     *   @param treatItemCd  治療方法コード
     *   @param treatItemName  治療方法名称
     */
    showModalChangeWeek(setDate, kurCd, kurName, treatItemCd, treatItemName) {
      //モーダル表示ON
      this.modalVisibleChangeWeek = true;
    },
    /**
     *   モーダル非表示化処理(曜日パターン変更画面)
     */
    hideModalChangeWeek() {
      this.modalVisibleChangeWeek = false;
    },
  },
  computed,
  watch,
  filters,
  created,
  mounted,
};
</script>

<style scoped>
</style>
