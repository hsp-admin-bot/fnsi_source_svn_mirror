/**
 * 治療記録の子機能 体重（モニタ）
 */
<template>
  <div class="expandable-content">
    <div>
      <!-- mod FNSI-共有を追加 王 20200921 start -->
      <!-- 5521 治療記録の体重で入力制限のない項目がある 房 start -->
      <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
      <!-- <com-number-input
        labelName="Kt/V測定値"
        :step="0.01"
        :min="0.00"
        :max="3.00"
        v-model="inputModel.ktVMeasure"
        :disabled="!isShared"
        :initValue="initModel.ktVMeasure"
      />
      <com-number-input
        labelName="URR"
        unitName="%"
        :step="0.01"
        :min="0.0"
        :max="100.0"
        v-model="inputModel.urr"
        :disabled="!isShared"
        :initValue="initModel.urr"
      /> -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
      <com-number-input
        labelName="Kt/V測定値"
        :step="0.01"
        :inputMin="0.00"
        :inputMax="3.00"
        :inputType='"number"'
        v-model="inputModel.ktVMeasure"
        :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
        :initValue="initModel.ktVMeasure"
      />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
      <com-number-input
        labelName="URR"
        unitName="%"
        :step="0.01"
        :inputMin="0.0"
        :inputMax="100.0"
        :inputType='"number"'
        v-model="inputModel.urr"
        :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
        :initValue="initModel.urr"
      />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
      <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
      <!-- mod FNSI-共有を追加 王 20200921 end -->
      <!-- add FNSI-体重情報のJSONに四つカラムを追加 徐 start -->
      <!-- TODO:再循環率コンポーネント作成後に入れ替える -->
      <!-- <v-ons-row>
        <v-ons-col class="title">
          <label class="theme">再循環率</label>
        </v-ons-col>
        <v-ons-col class="select-value">
          <v-ons-select v-model="inputModel.reLoopRateMain">
            <option
              v-for="(item, index) in comboList"
              :key="index"
              :value="item.value"
              v-html="item.text"
            ></option>
          </v-ons-select>
        </v-ons-col>
      </v-ons-row> -->
      <v-ons-row>
        <v-ons-col class="title" style="align-items: start;">
          <label class="theme">再循環率</label>
        </v-ons-col>
        <v-ons-col style="display: flex;align-items: start;">
          <div style="float: left; width: 100%;">
            <table class="mon-table">
              <thead>
              <tr>
                <th class="mon-table-head-one"> </th>
                <th class="mon-table-head-one">再循環率</th>
                <th class="mon-table-head-one">血流量</th>
                <th class="mon-table-head">測定日時</th>
                <th class="mon-table-head-one">コメント</th>
              </tr>
              </thead>
              <tbody>
              <template v-for="(data, index) in inputModel.recrclRtList" :key="index">
                <tr>
                  <!-- mod FNSI-共有を追加 王 20200921 start -->
                  <!-- add FNSI-修正 権限関連 周雨晴 2020/09/28 start -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                  <td class="align-center mon-list-body-td ntss-checkbox-shaving">
                    <v-ons-checkbox
                      type="checkbox"
                      :input-id="'checkbox-' + index"
                      :value="index"
                      @click="check(index)"
                      :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared "
                      v-model="data.validFlg">
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                    </v-ons-checkbox>
                  </td>
                  <!-- add FNSI-修正 権限関連 周雨晴 2020/09/28 end -->
                  <!-- add FNSI-修正 権限関連 周雨晴 2020/09/28 start -->
                  <td class='mon-list-body-td' style='width:1em'>
                    <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
                    <!-- <com-number-input
                      style="width: 6em;"
                      input-id="rate"
                      v-model="data.rate"
                      name="rate"
                      unitName="％\u3000\u3000"
                      :titile-visible="false"
                      :min=0
                      :max=100
                      :initialValueLock="true"
                      :disabled="!isShared || !hasTreatmentRecordAuthority"
                      :isEmpty = "true"
                      :initValue="initModel.recrclRtList[index].rate"
                    /> -->
                    <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                    <com-number-input
                      style="width: 6em;"
                      input-id="rate"
                      v-model="data.rate"
                      name="rate"
                      unitName="％　　"
                      :titile-visible="false"
                      :inputMin=0
                      :inputMax=100
                      :inputType='"number"'
                      :initialValueLock="true"
                      :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared "
                      :isEmpty = "true"
                      :initValue="initModel.recrclRtList[index].rate"
                      @blur="onBlurRate(index)"
                    />
                    <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                    <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
                  </td>
                  <!-- add FNSI-修正 権限関連 周雨晴 2020/09/28 end -->
                  <!-- add FNSI-修正 権限関連 周雨晴 2020/09/28 start -->
                  <td class='mon-list-body-td' style='width:1em'>
                    <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
                    <!-- <com-number-input
                      style="width: 8em;"
                      input-id="bldVl"
                      v-model="data.bldVl"
                      name="bldVl"
                      unitName="mL/min"
                      :titile-visible="false"
                      :min=0
                      :max=600
                      :initialValueLock="true"
                      :disabled="!isShared || !hasTreatmentRecordAuthority"
                      :initValue="initModel.recrclRtList[index].bldVl"
                    /> -->
                    <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                    <com-number-input
                      style="width: 8em;"
                      input-id="bldVl"
                      v-model="data.bldVl"
                      name="bldVl"
                      unitName="mL/min"
                      :titile-visible="false"
                      :inputMin=0
                      :inputMax=600
                      :inputType='"number"'
                      :initialValueLock="true"
                      :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared "
                      :initValue="initModel.recrclRtList[index].bldVl"
                    />
                    <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                    <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
                  </td>
                  <!-- add FNSI-修正 権限関連 周雨晴 2020/09/28 end -->
                  <td class='mon-list-body-td'>
                    <div style="display: flex; flex-wrap: nowrap;">
                      <!-- <com-date-time-input
                        class="ntss-style-date-time"
                        labelName=""
                        :required="false"
                        v-model="data.datetime"
                      /> -->
                      <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
                      <!-- add FNSI-修正 権限関連 周雨晴 2020/09/28 start -->
                      <!-- <input
                        :class="timeClass(index, 'date')"
                        class="ntss-input-date ntss-control-size"
                        style="display: none;"
                        type="date"
                        name="dateValue"
                        v-model="data.date"
                        :disabled="!isShared || !hasTreatmentRecordAuthority"
                      /> -->
                    <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                      <date-input
                        :classes="timeClass(index, 'date') + ' ntss-input-date ntss-control-size'"
                        style="display: none;"
                        name="dateValue"
                        v-model="data.date"
                        :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared "
                        @handleClearInput="data.date = null"
                      />
                    <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                      <!-- add FNSI-修正 権限関連 周雨晴 2020/09/28 end -->
                      <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end -->
                      <!-- #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start -->
                      <!-- add FNSI-修正 権限関連 周雨晴 2020/09/28 start -->
                      <!-- <input
                        :class="timeClass(index, 'time')"
                        @change="dateInit(index)"
                        type="time"
                        name="timeValue"
                        v-model="data.time"
                        :disabled="!isShared || !hasTreatmentRecordAuthority"
                      /> -->
                    <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                      <time-input
                        :classes="'time-input-focus ' +timeClass(index, 'time')"
                        @change="dateInit(index)"
                        @focus="onFocusTime(index)"
                        name="timeValue"
                        v-model="data.time"
                        :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared "
                        @handleClearInput="data.time = null; dateInit(index)"
                      />
                    <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                      <!-- #5590 2023/04/19 ×を常に表示するように修正 end -->
                    <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                      <common-calendar v-model="data.date" :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared "/>
                    <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                    </div>
                  </td>
                  <!-- 5521 治療記録の体重で入力制限のない項目がある 房 end -->
                    <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
                  <td class='mon-list-body-td'>
                    <custom-simple-textarea-b
                      style="width: 100%;"
                      v-model="data.comment"
                      :class="timeClass(index, 'comment')"
                      :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared "
                    />
                    <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
                    <!-- 印刷用 -->
                    <div class="print-textarea">
                      {{ data.comment }}
                    </div>
                  </td>
                  <!-- add FNSI-修正 権限関連 周雨晴 2020/09/28 end -->
                  <!-- mod FNSI-共有を追加 王 20200921 end -->
                </tr>
              </template>
              </tbody>
            </table>
          </div>
        </v-ons-col>
      </v-ons-row>
      <!-- mod FNSI-共有を追加 王 20200921 start -->
      <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 start -->
      <!-- <com-number-input
        labelName="静的静脈圧"
        unitName="mmHg"
        :step="1"
        :min="-100"
        :max="300"
        v-model="inputModel.sttcVnsPrssr"
        :disabled="!isShared"
        :initValue="initModel.sttcVnsPrssr"
      /> -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
       <com-number-input
        labelName="静的静脈圧"
        unitName="mmHg"
        :step="1"
        :inputMin="-100"
        :inputMax="300"
        :inputType='"number"'
        v-model="inputModel.sttcVnsPrssr"
        :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
        :initValue="initModel.sttcVnsPrssr"
      />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
      <!-- mod FNSI修正 486修正 房 start -->
      <!-- <com-number-input
        labelName="IAP Ratio"
        unitName="%"
        :step="0.01"
        :min="-1.0"
        :max="3.0"
        v-model="inputModel.iapRt"
        :disabled="!isShared"
        :initValue="initModel.iapRt"
      /> -->
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 start-->
      <com-number-input
        labelName="IAP Ratio"
        unitName="%"
        :step="0.01"
        :inputMin="-1.0"
        :inputMax="3.0"
        :inputType='"number"'
        v-model="inputModel.iapRt"
        :disabled="!getItemAuthorized('TreatmentRecord', 'default_authority')||!isShared"
        :initValue="initModel.iapRt"
      />
        <!-- #10359 mod 編集権限の動作不正 2024-06-05 卓 end-->
      <!-- mod #5589 2023/03/31 数値IFのスタイル全不正 張博 end -->
      <!-- mod FNSI修正 486修正 房 end -->
      <!-- mod FNSI-共有を追加 王 20200921 end -->
      <!-- add FNSI-体重情報のJSONに四つカラムを追加 徐 end -->
    </div>
  </div>
</template>

<script>
// add FNSI-共有を追加 王 20200921 start
import { mapGetters } from "@/compat/vue/vuex";
// add FNSI-共有を追加 王 20200921 end
import CommonNumberInputComponent from "@/components/treatment-record/submenu/common/CommonNumberInputComponent";
import { Monitor } from "@/models/treatment-record/weight/Monitor";
import { mapActions } from "@/compat/vue/vuex";
//  add FNSI-修正 権限関連 周雨晴 2020/09/28 start
//#10359 mod 編集権限の動作不正 2024-06-05 卓 start
// import ComponentGuardMixin from "@/components/common/ComponentGuardMixin";
import CustomSimpleTextareaTypeB from "@/components/common/custom-form-tags/CustomSimpleTextareaTypeB";
//import { AUTHORITY_CODES } from "@/constants/userAuthority";
//  add FNSI-修正 権限関連 周雨晴 2020/09/28 end
import {DATE_FORMAT, dateFormat } from "@/functions/common/DateTimeUtils.js";
import { CODES } from "@/constants/TreatmentRecord.js";
// del FNSI-体重情報のJSONに四つカラムを追加 徐 start
// import {
//   DATE_TIME_FORMAT,
//   dateFormat
// } from "@/functions/common/DateTimeUtils.js";
// import moment from "moment";
// del FNSI-体重情報のJSONに四つカラムを追加 徐 start
// add FNSI-体重情報のJSONに四つカラムを追加 徐 start
import commonCalender from "@/components/common/custom-calendar/CustomCalendar";
// add FNSI-体重情報のJSONに四つカラムを追加 徐 end
// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
import DateInput from "@/components/common/DateInput.vue";
import TimeInput from "@/components/common/TimeInput.vue";
// #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
import { getAuthorized } from "@/functions/common/CommonFunctions";
//#10359 mod 編集権限の動作不正 2024-06-05 卓 end
export default {
//#10359 del 編集権限の動作不正 2024-06-05 卓 start
  // mixins: [ComponentGuardMixin],
//#10359 del 編集権限の動作不正 2024-06-05 卓 end
  components: {
    "com-number-input": CommonNumberInputComponent,
    // add FNSI-体重情報のJSONに四つカラムを追加 徐 start
    "common-calendar": commonCalender,
    // add FNSI-体重情報のJSONに四つカラムを追加 徐 end
    "custom-simple-textarea-b": CustomSimpleTextareaTypeB,
    // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 start
    "date-input": DateInput,
    "time-input": TimeInput,
    // #5590 2023/04/19 ×を常に表示するように修正 林峻峰 end
  },
  emits: ["update:modelValue"],
  props: {
    // Vue3 既定 v-model は modelValue / update:modelValue を使用する。
    modelValue: {
      type: Monitor
    },
    ordNo: {
      type: Number
    }
  },
  data() {
    return {
      inputModel: new Monitor(),
      // del FNSI-体重情報のJSONに四つカラムを追加 徐 star
      // comboList: []
      // del FNSI-体重情報のJSONに四つカラムを追加 徐 end
      // add FNSI-修正 権限関連 周雨晴 2020/09/28 start
      //#10359 del 編集権限の動作不正 2024-06-05 卓 start
      // hasTreatmentRecordAuthority: false,
      //#10359 del 編集権限の動作不正 2024-06-05 卓 end
      // add FNSI-修正 権限関連 周雨晴 2020/09/28 end
      initModel: new Monitor(),
      initFlag: 1,
    };
  },
  methods: {
    ...mapActions("treatment-record/weight", ["getRecirculationRate"]),
    // FNSI-体重情報のJSONに四つカラムを追加 徐 start
    check(id) {
      this.inputModel.recrclRtList.forEach((item, index) => {
        if (index !== id) item.validFlg = false;
        else item.validFlg = true;
      });
    },
     // add FNSI-修正 権限関連 周雨晴 2020/09/28 start
    //#10359 del 編集権限の動作不正 2024-06-05 卓 start
    // getTreatmentRecordAuthority() {
    //  return this.hasAuthorityByCd(AUTHORITY_CODES.RST_PEDIT) || this.hasAuthorityByCd(AUTHORITY_CODES.RST_EDIT);
    // },
    //#10359 del 編集権限の動作不正 2024-06-05 卓 end
    // add FNSI-修正 権限関連 周雨晴 2020/09/28 end
    // del FNSI-体重情報のJSONに四つカラムを追加 徐 end
    /**
     * 再循環率コンボの選択肢を生成する.
     */
    // del FNSI-体重情報のJSONに四つカラムを追加 徐 start
    // createComboList() {

      // const result = await this.getRecirculationRate(this.ordNo);
      // this.comboList = result.data.map(r => {
      //   const d = dateFormat.format(new Date(r.date), DATE_TIME_FORMAT);
      //   return {
      //     value: r.bio_moni_ctl_no,
      //     text: `${d}&emsp;${r.recirculation_rate}%&emsp;&emsp;${r.blood_flow}ml/min`
      //   };
      // });
    // }
    // del FNSI-体重情報のJSONに四つカラムを追加 徐 end
    timeClass(index, element){
      let beforeValue = this.initModel.recrclRtList[index][element];
      let afterValue =  this.inputModel.recrclRtList[index][element];
      beforeValue = beforeValue == "" ? null : beforeValue;
      afterValue = afterValue == "" ? null : afterValue;
      if (beforeValue != afterValue) {
        return "time-input-edited";
      } else {
        return "";
      }
    },
    initValueEdit(){
      Object.assign(this.initModel, this.inputModel);
    },
     /** 
    * 測定日時をクリア（×ボタン、手入力クリア）した際、カレンダー表示した際のデフォルト日付を変更するためデフォルト値を日付（非表示）に設定
    * ※時刻はクリア状態
    */
    dateInit(index){
// デフォルト日付を設定
      this.setDefaultDate(this.inputModel.recrclRtList[index], false);
    },
    /** 
    * 再循環率入力フォーカスアウト
    */
    onBlurRate(index){
      // 再循環率入力ありの場合にデフォルト日時を設定
      if (this.inputModel.recrclRtList[index].rate !== null && this.inputModel.recrclRtList[index].rate !== "") {
        this.setDefaultDate(this.inputModel.recrclRtList[index], true);
      // add #11416 【たくしん会】治療記録＞再循環率の入力IFバグ　V1.0B linjunfeng start
      } else {
        this.inputModel.recrclRtList[index].date = null;
        this.inputModel.recrclRtList[index].time = null;
      // add #11416 【たくしん会】治療記録＞再循環率の入力IFバグ　V1.0B linjunfeng end
      }
    },
    /** 
    * 測定日時時刻入力フォーカス
    */
    onFocusTime(index){
      // デフォルト日時を設定
      this.setDefaultDate(this.inputModel.recrclRtList[index], true);
    },
    /** 
    * 測定日時未入力の場合にデフォルト値を設定
    *   rst_dialysis_state1～3の場合：sysdate
    *   rst_dialysis_state4～6の場合の場合：治療終了日時
    * @param setTimeFlg デフォルト時刻をセットするかのフラグ
    */
    setDefaultDate(record, setTimeFlg) {
      if (!record.time) {
        if ([
            CODES.DIALYSIS_STATE.AFTER_SEND_CONDITION.cd,
            CODES.DIALYSIS_STATE.CONFIRMED_SEND_CONDITION.cd,
            CODES.DIALYSIS_STATE.DURING_TREATMENT.cd
          ].includes(this.getRstDialysisState)) {
          // rst_dialysis_state1～3
          record.date = dateFormat.format(new Date(), DATE_FORMAT);
          record.time = setTimeFlg ? this.getTime(new Date()) : record.time;
        } else {
          // rst_dialysis_state4～6
          const rstEndDate = this.getRstEndDate ? new Date(this.getRstEndDate) : new Date();
          record.date = dateFormat.format(rstEndDate, DATE_FORMAT);
          record.time = setTimeFlg ? this.getTime(rstEndDate) : record.time;
        }
      }
    },
    /**
     * 時刻を"HH:mm"形式の文字列で取得
     */
    getTime(date) {
      const hours = String(date.getHours()).padStart(2, '0');
      const minutes = String(date.getMinutes()).padStart(2, '0');
      return `${hours}:${minutes}`;
    },
      // del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
    /**
     * 再表示処理
     */
    // refresh() {
    //   // パンくず押下時に初期表示フラグをリセットする
    //   this.resetInitFlag();
    // },
    /** 
     * 初期表示フラグをリセット
     */
    // resetInitFlag() {
    //   this.initFlag = 1;
    // }
      // del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 start
    getItemAuthorized(pageCd, itemCd) {
      return getAuthorized(pageCd, itemCd);
    },
    //#10359 mod 編集権限の動作不正 2024-06-05 卓 end
  },
  // add FNSI-共有を追加 王 20200921 start
  computed: {
    ...mapGetters("user", ["getFacilityCd"]),
    ...mapGetters("treatment-record/common", ["getSharedFacilityCd"]),
    ...mapGetters("treatment-record/weight", ["getUpDate", "getRstDialysisState", "getRstEndDate"]),
    isShared() {
      return this.getFacilityCd === this.getSharedFacilityCd;
    }
  },
  // add FNSI-共有を追加 王 20200921 end
  watch: {
    modelValue() {
      this.inputModel = this.modelValue;
      // del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
      // if (this.initFlag == 1) {
      // del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
      // 測定日時が未登録の場合、カレンダー表示した際のデフォルト日付を変更するためデフォルト値を日付（非表示）に設定する
      this.modelValue.recrclRtList.forEach((rec, index) => {
        this.setDefaultDate(rec, false);
      });
      Object.assign(this.initModel, this.modelValue)
      // 5521 治療記録の体重で入力制限のない項目がある 房 start
      this.initModel.recrclRtList = JSON.parse(JSON.stringify(this.modelValue.recrclRtList))
      // 5521 治療記録の体重で入力制限のない項目がある 房 end
      // del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
      // this.initFlag = 2;
      // }
      // del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
    },
    inputModel: {
      handler: function(val) {
        this.$emit("update:modelValue", val);
      },
      deep: true
    },
    // del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
    // getOrdNo() {
    //   // 初期表示フラグをリセット
    //   this.resetInitFlag();
    // },
    // getUpDate() {
    //   // 初期表示フラグをリセット
    //   this.resetInitFlag();
    // }
    // del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
  },
  created() {
    // del FNSI-体重情報のJSONに四つカラムを追加 徐 start
    // this.createComboList();
    // del FNSI-体重情報のJSONに四つカラムを追加 徐 end
    // add FNSI-修正 権限関連 周雨晴 2020/09/28 start
    //#10359 del 編集権限の動作不正 2024-06-05 卓 start
    // this.hasTreatmentRecordAuthority = this.getTreatmentRecordAuthority();
    //#10359 del 編集権限の動作不正 2024-06-05 卓 end
    // add FNSI-修正 権限関連 周雨晴 2020/09/28 end
    // del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
    // EventBus.$on("refresh", this.refresh); 
    // del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end

  },
  // del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 start
  // beforeDestroy() {
  //   EventBus.$off("refresh", this.refresh);
  // }
  // del 10823 治療記録>治療条件で別治療日の内容を表示すると緑枠で表示されることがある 張玲 end
};
</script>

<style scoped>
ons-select {
  width: 13em;
  font-size: 1.5em !important;
}
/* add FNSI-体重情報のJSONに四つカラムを追加 徐 start */
.mon-table-head-one {
  color: #fff;
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
  padding: 4px;
  /* 一覧のボーダーライン */
  border: solid 1px var(--ntss-list-border-color);
  /* 上のボーダーラインは非表示 */
  border-top: none;
  white-space: pre;
  text-align: left;
  position: -webkit-sticky;
  position: sticky;
  top: 0;
}
.mon-table-head {
  color: #fff;
  background-color: var(--ntss-list-header-background-color);
  font-weight: 100;
  padding: 4px;
  /* 一覧のボーダーライン */
  border: solid 1px var(--ntss-list-border-color);
  /* 上のボーダーラインは非表示 */
  border-top: none;
  white-space: pre;
  text-align: left;
  position: -webkit-sticky;
  position: sticky;
  top: 0;
  width: 6em;
}

.mon-table {
  border-collapse: collapse;
  min-width: 700px;
  width: 100%;
  margin: 0 auto;
  font-size: 1em;
  background-color: var(--ntss-list-background-color);
}
.align-center {
  text-align: center;
}
.ntss-checkbox-shaving {
  width: 1em;
}
.mon-list-body-td {
  /* 一覧のボーダーライン */
  border: solid 1px var(--ntss-list-border-color);
  padding: 1px;
  color: var(--ntss-list-body-color);
}
.time-input-edited {
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
/* add FNSI-体重情報のJSONに四つカラムを追加 徐 end */
.expandable-content {
  overflow: auto;
  padding: 0.2em 0px 0.2em 0;
}
/* ntss.css の .custom-textarea:disabled と競合する為、個別定義 */
td textarea:focus {
  border-style: inset;
  border-color: unset;
  /* #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng start */
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
  /* #9404 治療記録>体重画面にて保存した後も編集した箇所が緑枠のまま残る linjunfeng end */
}
/* 印刷用テキストエリア */
.print-textarea {
  display: none; /* 通常は隠す */
}
@media print {
  .mon-table {
    min-width: unset;
  }
  /** テキストエリア非表示 */
  td textarea {
    display: none !important;
  }
  /** 再循環率のヘッダがページ毎に表示されるのを回避 */
  .mon-table thead {
    display: table-row-group !important;
  }
}
</style>
