/**
 * 治療記録の子機能 体重（体重）
 */
<template>
  <div class="expandable-content">
    <div>
      <com-number-display labelName="前回後体重" unitName="kg" :digits="2" v-model="inputModel.lastWeight" :required="false"/>
      <!-- mod FNSI-共有を追加 王 20200921 start -->
      <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
      <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
      <!-- <com-number-input labelName="透析前体重" unitName="kg" input-min-width="10em" :step=0.01 :min=0.00 :max=300.00 :initValue="initModel.weightBefore" :commandButton=weightBeforeDetailButton v-model="inputModel.weightBefore" :nonAuthorize="true" @blur="calcWeightDecreased" :required="false" :disabled="!isShared"/> -->
      <com-number-input :key="'weightBefore-' + weightFieldsKey" labelName="透析前体重" unitName="kg" input-min-width="10em" :step=0.01 :inputMin=0.00 :inputMax=300.00 :inputType='"number"' :initValue="initModel.weightBefore" :commandButton=weightBeforeDetailButton :buttonDisabled="!isShared" v-model="inputModel.weightBefore" :nonAuthorize="true" @blur="calcWeightDecreased(); setWeightBeforeDate()" :required="false" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"/>
      <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
      <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
      <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
      <!-- <com-date-time-input labelName="測定日時" v-model="inputModel.weightBeforeDate" :required="false" :disabled="!isShared"/> -->
      <!-- #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng start -->
      <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start -->
      <!-- <com-date-time-input :is-show-clear="true" labelName="測定日時" v-model="inputModel.weightBeforeDate" :required="false" :disabled="!isShared" dateID="weightBeforeDate" :errorMsg="true" @handleClearInput="inputModel.weightBeforeDate = null"/> -->
      <com-date-time-input ref="weightBeforeDate" :is-show-clear="true" labelName="測定日時" v-model="inputModel.weightBeforeDate" :required="false" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" dateID="weightBeforeDate" :errorMsg="true" @handleClearInput="inputModel.weightBeforeDate = null" :initValue="initModel.weightBeforeDate" @handleCurrentDateChange="handleWeightBeforeDate" @handleCurrentTimeChange="handleWeightBeforeTime" />
      <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end -->
      <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
      <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
      <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
      <!-- <com-number-input labelName="DW" unitName="kg" input-min-width="10em" :step=0.01 :min=0.00 :max=300.00 v-model="inputModel.rstDw" :disabled="!isShared" :initValue="initModel.rstDw" /> -->
      <com-number-input labelName="DW" unitName="kg" input-min-width="10em" :step=0.01 :inputMin=0.00 :inputMax=300.00 :inputType='"number"' v-model="inputModel.rstDw" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :initValue="initModel.rstDw" />
      <!-- <com-number-input labelName="CTR" unitName="%" input-min-width="10em" :step=0.01 :min=0.00 :max=100.00 v-model="inputModel.ctr" :required="false" :disabled="!isShared" :initValue="initModel.ctr" /> -->
      <com-number-input labelName="CTR" unitName="%" input-min-width="10em" :step=0.01 :inputMin=0.00 :inputMax=100.00 :inputType='"number"' v-model="inputModel.ctr" :required="false" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :initValue="initModel.ctr" />
      <!-- <com-number-input labelName="CTR測定時体重" unitName="kg" input-min-width="10em" :step=0.01 :min=0.00 :max=300.00 v-model="inputModel.ctrWeight" :required="false" :disabled="!isShared" :initValue="initModel.ctrWeight" /> -->
      <com-number-input labelName="CTR測定時体重" unitName="kg" input-min-width="10em" :step=0.01 :inputMin=0.00 :inputMax=300.00 :inputType='"number"' v-model="inputModel.ctrWeight" :required="false" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :initValue="initModel.ctrWeight" />
      <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
      <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
      <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
      <!-- <com-date-time-input labelName="測定日" v-model="inputModel.ctrMeasureDate" :timeVisible="false" :required="false" :disabled="!isShared"/> -->
      <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start -->
      <!-- <com-date-time-input :is-show-clear="true" labelName="CTR測定日" v-model="inputModel.ctrMeasureDate" :value="inputModel.ctrMeasureDate" :timeVisible="false" :required="false" :disabled="!isShared" dateID="ctrMeasureDate" :errorMsg="true" @handleClearInput="inputModel.ctrMeasureDate = null"/> -->
      <com-date-time-input :is-show-clear="true" labelName="CTR測定日" v-model="inputModel.ctrMeasureDate" :value="inputModel.ctrMeasureDate" :timeVisible="false" :required="false" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" dateID="ctrMeasureDate" :errorMsg="true" @handleClearInput="inputModel.ctrMeasureDate = null" :initValue="initModel.ctrMeasureDate" />
      <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end -->
      <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
      <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
      <com-number-display labelName="目標体重" unitName="kg" :digits="2" :value="inputModel.targetWeight == -1 ? inputModel.rstDw : inputModel.targetWeight" :required="false"/>
     <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
      <!-- <com-number-input labelName="目標除水量" unitName="L" input-min-width="10em" :step=0.01 :min=0.00 :max=39.90 v-model="inputModel.waterRemovalTarget" :required="false" :disabled="!isShared" :initValue="initModel.waterRemovalTarget" /> -->
      <com-number-input :key="'waterRemovalTarget-' + weightFieldsKey" labelName="目標除水量" unitName="L" input-min-width="10em" :step=0.01 :inputMin=0.00 :inputMax=39.90 :inputType='"number"' v-model="inputModel.waterRemovalTarget" :required="false" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :initValue="initModel.waterRemovalTarget" />
      <!-- <com-number-input labelName="実績除水量" unitName="L" input-min-width="10em" :step=0.01 :min=0.00 :max=39.99 v-model="inputModel.waterRemovalRst" :required="false" :disabled="!isShared" :initValue="initModel.waterRemovalRst" /> -->
      <com-number-input :key="'waterRemovalRst-' + weightFieldsKey" labelName="実績除水量" unitName="L" input-min-width="10em" :step=0.01 :inputMin=0.00 :inputMax=39.99 :inputType='"number"' v-model="inputModel.waterRemovalRst" :required="false" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :initValue="initModel.waterRemovalRst" />
      <!-- <com-number-input labelName="実績補液量" unitName="L" input-min-width="10em" :step=0.01 :min=0.00 :max=999 v-model="inputModel.addWaterTotal" :required="false" :disabled="!isShared" :initValue="initModel.addWaterTotal" /> -->
      <com-number-input labelName="実績補液量" unitName="L" input-min-width="10em" :step=0.01 :inputMin=0.00 :inputMax=999 :inputType='"number"' v-model="inputModel.addWaterTotal" :required="false" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :initValue="initModel.addWaterTotal" />
      <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
      <!-- add FNSI-体重情報のJSONに四つカラムを追加 徐 start -->
      <!-- mod FNSI修正 486修正 房 start -->
      <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
      <!-- <com-number-input labelName="I-HDF引き残し" unitName="L" input-min-width="10em" :step=0.01 :min=0 :max=100 v-model="inputModel.ihdfPll" :required="false" :disabled="!isShared" :initValue="initModel.ihdfPll" /> -->
      <com-number-input labelName="I-HDF引き残し" unitName="L" input-min-width="10em" :step=0.01 :inputMin=0 :inputMax=100 :inputType='"number"' v-model="inputModel.ihdfPll" :required="false" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :initValue="initModel.ihdfPll" />
      <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
      <!-- mod FNSI修正 486修正 房 end -->
      <!-- add FNSI-体重情報のJSONに四つカラムを追加 徐 end -->
     <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
      <!-- <com-number-input labelName="透析後体重" unitName="kg" input-min-width="10em" :step=0.01 :min=0.00 :max=300.00 :commandButton=weightAfterDetailButton v-model="inputModel.weightAfter" :nonAuthorize="true" @blur="calcWeightDecreased" :required="false" :disabled="!isShared" :initValue="initModel.weightAfter" /> -->
      <com-number-input :key="'weightAfter-' + weightFieldsKey" labelName="透析後体重" unitName="kg" input-min-width="10em" :step=0.01 :inputMin=0.00 :inputMax=300.00 :inputType='"number"' :commandButton=weightAfterDetailButton :buttonDisabled="!isShared" v-model="inputModel.weightAfter" :nonAuthorize="true" @blur="calcWeightDecreased(); setWeightAfterDate()" :required="false" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" :initValue="initModel.weightAfter" />
      <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
      <!-- add FNSI-横展開 日付のチェックの追加 徐 start -->
      <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
      <!-- <com-date-time-input labelName="測定日時" v-model="inputModel.weightAfterDate" :required="false" :disabled="!isShared" /> -->
      <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start -->
      <!-- <com-date-time-input :is-show-clear="true" labelName="測定日時" v-model="inputModel.weightAfterDate" :required="false" :disabled="!isShared" dateID="weightAfterDate" :errorMsg="true" @handleClearInput="inputModel.weightAfterDate = null"/> -->
      <!-- #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng start -->
      <!-- <com-date-time-input :is-show-clear="true" labelName="測定日時" v-model="inputModel.weightAfterDate" :required="false" :disabled="!isShared" dateID="weightAfterDate" :errorMsg="true" @handleClearInput="inputModel.weightAfterDate = null" :initValue="initModel.weightAfterDate"/> -->
      <com-date-time-input ref="weightAfterDate" :is-show-clear="true" labelName="測定日時" v-model="inputModel.weightAfterDate" :required="false" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared" dateID="weightAfterDate" :errorMsg="true" @handleClearInput="inputModel.weightAfterDate = null" :initValue="initModel.weightAfterDate" @handleCurrentDateChange="handleWeightAfterDate" @handleCurrentTimeChange="handleWeightAfterTime" />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
      <!-- #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng end -->
      <!-- #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end -->
      <!-- #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng end -->
      <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
      <!-- add FNSI-横展開 日付のチェックの追加 徐 end -->
      <!-- mod FNSI-共有を追加 王 20200921 end -->
      <com-number-display labelName="減少量" unitName="kg" :digits="2" :value="inputModel.weightDecreased" :required="false"/>
    </div>
  </div>
</template>

<script>
// mod FNSI-共有を追加 王 20200921 start
import { mapActions, mapGetters } from "@/compat/vue/vuex";
// mod FNSI-共有を追加 王 20200921 end
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
import CommonNumberDisplayComponent from "@/components/treatment-record/submenu/common/CommonNumberDisplayComponent";
import CommonDateTimeComponent from "@/components/treatment-record/submenu/common/CommonDateTimeComponent";
import {
  truncateDecimal,
  plusDecimal
} from "@/functions/treatment-record/NumberFunctions.js";
import { Weight } from "@/models/treatment-record/weight/Weight";
import { EventBus } from "@/compat/vue/event-bus.js";
//#10359 add 編集権限の動作不正 2024-06-05 卓 start
import { getAuthorized } from "@/functions/common/CommonFunctions";
//#10359 add 編集権限の動作不正 2024-06-05 卓 end
import dayjs from "@/compat/date/dayjs";
export default {
  components: {
    "com-number-input": CommonNumberInputComponent,
    "com-number-display": CommonNumberDisplayComponent,
    "com-date-time-input": CommonDateTimeComponent
  },
  emits: ["update:modelValue"],
  props: {
    // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
    modelValue: {
      type: Weight
    },
//#10359 del 編集権限の動作不正 2024-06-05 卓 end
    // authorityCds: Array
//#10359 del 編集権限の動作不正 2024-06-05 卓 end
  },
  data() {
    return {
      inputModel: new Weight(),
      weightBeforeDetailButton: {
        name: "詳細",
        onClick: () => this.onClickBeforeWeightInput()
      },
      weightAfterDetailButton: {
        name: "詳細",
        onClick: () => this.onClickAfterWeightInput()
      },
      initModel: new Weight(),
      initFlag: 1,
      // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng start
      weightBeforeDate: null,
      weightBeforeTime: null,
      weightAfterDate: null,
      weightAfterTime: null,
      // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng end
      weightFieldsKey: 0,
    };
  },
  watch: {
    modelValue() {
      this.inputModel = this.modelValue;
      //mod 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
      Object.assign(this.initModel, this.modelValue)
      // if (this.initFlag == 1) {
      //   Object.assign(this.initModel, this.modelValue)
      //   this.initFlag = 2;
      // }
      //mod 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
    },
    inputModel: {
      handler: function(val) {
        this.$emit("update:modelValue", val);
      },
      deep: true
    },
    getOrdNo() {
      // 初期表示フラグをリセット
      this.initFlag = 1;
    }
  },
  // add FNSI-共有を追加 王 20200921 start
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd", "getOrdNo", "getDialysisState", "getRstStartDate", "getRstEditionDate"]),
    ...mapGetters("mst-user", {getSharedFlag: "getIsRegisteredShared"}),
    ...mapGetters("user", {facilityCd: "getFacilityCd"}),
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    }
  },
  // add FNSI-共有を追加 王 20200921 end
  methods: {
    ...mapActions("multi-modal", ["showTreatmentRecordWeightInput"]),
    ...mapActions("treatment-record/weight", ["setModalInfo"]),
    /**
     * 透析前体重入力モーダル表示.
     */
    onClickBeforeWeightInput() {
      // 透析前体重、目標除水量をモーダルへ渡すデータに設定
      if (this.inputModel.weightBefore) {
        this.inputModel.modalBefore.weightBefore = this.inputModel.weightBefore;
      }
      if (this.inputModel.waterRemovalTarget) {
        this.inputModel.modalBefore.targetOffWater = this.inputModel.waterRemovalTarget;
      }

      // モーダルへ渡すデータ設定
      this.setModalInfo({
        inputAfterWeight: false,
        weightModal: this.inputModel.modalBefore
      });

      // モーダル表示
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
      // this.showTreatmentRecordWeightInput({ title: "透析前体重入力", authorityCds: this.authorityCds });
      this.showTreatmentRecordWeightInput({ title: "透析前体重入力"  });
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    },
    /**
     * 透析後体重入力モーダル表示.
     */
    onClickAfterWeightInput() {
      // 透析後体重、実績除水量をモーダルへ渡すデータに設定
      if (this.inputModel.weightAfter) {
        this.inputModel.modalAfter.weightAfter = this.inputModel.weightAfter;
      }
      if (this.inputModel.waterRemovalRst) {
        this.inputModel.modalAfter.targetOffWater = this.inputModel.waterRemovalRst;
      }

      // モーダルへ渡すデータ設定
      this.setModalInfo({
        inputAfterWeight: true,
        weightModal: this.inputModel.modalAfter
      });

      // モーダル表示
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
      // this.showTreatmentRecordWeightInput({ title: "透析後体重入力", authorityCds: this.authorityCds });
      this.showTreatmentRecordWeightInput({ title: "透析後体重入力" });
      //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
    },
    /**
     * 減少量計算.
     */
    calcWeightDecreased() {
      const before = this.inputModel.weightBefore;
      const after = this.inputModel.weightAfter;
      //upd 治療記録減少量NaN kg表示エラー 20230629 ztc start
      // if (before !== undefined && after !== undefined) {
      if (!!before && !!after) {
        //upd 治療記録減少量NaN kg表示エラー 20230629 ztc end
        // 小数点第3位以下は切り捨て
        this.inputModel.weightDecreased = truncateDecimal(
          plusDecimal(before, -after),
          2
        );
      } else {
        this.inputModel.weightDecreased = null;
      }
    },
    /**
     * 透析前測定日時セット.
     */
    setWeightBeforeDate() {
      // 透析前体重入力あり、透析前測定日時入力なしの場合実施
      if(this.inputModel.weightBefore != null && !this.inputModel.weightBeforeDate){
        const dialysisState = this.getDialysisState;
        if (1 <= dialysisState && dialysisState <= 2) {
          // 1,2の場合透析前測定日時に現在日時を反映
          this.inputModel.weightBeforeDate =  dayjs(new Date()).startOf('minute').toDate();
        }else if(3 <= dialysisState && dialysisState <= 6){
          // 3~6の場合透析前測定日時に治療開始日時を反映
          this.inputModel.weightBeforeDate = dayjs(this.getRstStartDate).startOf('minute').toDate();
        }
      }
    },
    /**
     * 透析後測定日時セット.
     */
    setWeightAfterDate() {
      // 透析後体重入力あり、透析後測定日時入力なしの場合実施
      if(this.inputModel.weightAfter != null && !this.inputModel.weightAfterDate){
        const dialysisState = this.getDialysisState;
        if (1 <= dialysisState && dialysisState <= 5) {
          // 1~5の場合透析後測定日時に現在日時を反映
          this.inputModel.weightAfterDate =  dayjs(new Date()).startOf('minute').toDate();
        }else if(dialysisState == 6){
          // 6の場合透析後測定日時に初版確定日時を反映
          this.inputModel.weightAfterDate = dayjs(this.getRstEditionDate).startOf('minute').toDate();
        }
      }
    },
    initValueEdit(){
      Object.assign(this.initModel, this.inputModel);
      // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng start
      if (!this.initModel.weightBeforeDate) {
        this.$refs.weightBeforeDate.clearDateTime();
      }
      if (!this.initModel.weightAfterDate) {
        this.$refs.weightAfterDate.clearDateTime();
      }
      // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng end
    },
    // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng start
    handleWeightBeforeDate(date) {
      this.weightBeforeDate = date;
      if (!this.weightBeforeDate && !this.weightBeforeTime) {
        this.inputModel.weightBeforeDate = null;
      }
    },
    handleWeightBeforeTime(time) {
      this.weightBeforeTime = time;
      if (!this.weightBeforeDate && !this.weightBeforeTime) {
        this.inputModel.weightBeforeDate = null;
      }
    },
    handleWeightAfterDate(date) {
      this.weightAfterDate = date;
      if (!this.weightAfterDate && !this.weightAfterTime) {
        this.inputModel.weightAfterDate = null;
      }
    },
    handleWeightAfterTime(time) {
      this.weightAfterTime = time;
      if (!this.weightAfterDate && !this.weightAfterTime) {
        this.inputModel.weightAfterDate = null;
      }
    },
    // #10044 時刻の時分どちらか一方でも消すると日付も消える linjunfeng end
//#10359 add 編集権限の動作不正 2024-06-05 卓 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
//#10359 add 編集権限の動作不正 2024-06-05 卓 end
    applyWeightModal(isAfter, model, dialysisState) {
      if (!isAfter) {
        this.inputModel.modalBefore = model;
        this.inputModel.weightBefore = model.weightBefore;
        this.inputModel.waterRemovalTarget = model.targetOffWater;

        // 透析後の除水補正情報に入力した値を反映
        this.inputModel.modalAfter.applyOffWaterInfos(model.offWaterInfos);

        // rst_dialysis_stateが1～3の場合、透析前の風袋変更時に透析後の風袋も変更する
        if (1 <= dialysisState && dialysisState <= 3) {
          // 透析後の風袋情報に入力した値を反映
          this.inputModel.modalAfter.applyTareInfos(model.tareInfos);
        }

        // 透析前測定日時が空欄の場合セットする
        this.setWeightBeforeDate();
      } else {
        this.inputModel.modalAfter = model;
        this.inputModel.weightAfter = model.weightAfter;
        this.inputModel.waterRemovalRst = model.targetOffWater;

        // 透析前の除水補正情報に入力した値を反映
        this.inputModel.modalBefore.applyOffWaterInfos(model.offWaterInfos);

        // 透析後測定日時が空欄の場合セットする
        this.setWeightAfterDate();
      }

      // 減少量の再計算する
      this.calcWeightDecreased();
      // #10628 数値IF: モーダル確定後に親画面の数値入力表示を同期
      this.weightFieldsKey++;
    },
  },
  created() {
    EventBus.$off("applyWeightModal", this.applyWeightModal);
    EventBus.$on("applyWeightModal", this.applyWeightModal);
  },
  // add 性能改善メモリ不足 shan start
  beforeUnmount() {
    EventBus.$off("applyWeightModal", this.applyWeightModal);
  }
  // add 性能改善メモリ不足 shan end
};
</script>

<style scoped>
.expandable-content {
  overflow: auto;
  padding: 0.2em 0px 0.2em 0;
}
</style>
