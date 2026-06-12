/**
 * 薬剤マスタモーダル
 * MstMedicineMainModalComponent
 */
<template>
  <div id="exam-item-modal-content">
    <v-ons-row class="input-row">
      <v-ons-col>
        <button
          class="button btn3-normal"
          style="height: 2em;"
          @click="onSelect">標準医薬品マスタ検索</button>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="st-medicine-cd">YJコード</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-input
          type="text"
          :class="handleJudgeEdited(inputModel.standard_medicine_cd, 'standard_medicine_cd')"
          input-id="st-medicineCd"
          maxlength="12"
          v-model="inputModel.standard_medicine_cd"
        >
        </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="medicine-name">薬剤名</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-input
          type="text"
          :class="handleJudgeEdited(inputModel.medicine_name, 'medicine_name')"
          input-id="medicineName"
          v-model="inputModel.medicine_name">
        </v-ons-input>
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="medicine-short-name">省略薬剤名</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-input
          type="text"
          :class="handleJudgeEdited(inputModel.medicine_short_name, 'medicine_short_name')"
          input-id="medicineShortName"
          v-model="inputModel.medicine_short_name">
        </v-ons-input>
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="class-cd">薬剤分類区分</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-select
          select-id="class-cd"
          v-model="inputModel.class_cd"
          :class="handleJudgeEdited(inputModel.class_cd, 'class_cd')"
          name="class-cd"
          >
          <option v-for="(item, index) in comboMedicineClass" :key="index" :value="item.value">
            {{ item.text }}
          </option>
        </v-ons-select>
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="unit">指示単位</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-input
          type="text"
          :class="handleJudgeEdited(inputModel.unit, 'unit')"
          input-id="unit"
          v-model="inputModel.unit">
        </v-ons-input>
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="unit-second">レセ単位</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-input
          type="text"
          :class="handleJudgeEdited(inputModel.unit_second, 'unit_second')"
          input-id="unitSecond"
          v-model="inputModel.unit_second">
        </v-ons-input>
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="unit">指示単位小数部桁数</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <!-- #10713 小数点以下桁数指定を0～8までにする linjunfeng start -->
        <!-- <v-ons-input
          type="number"
          step="1"
          :class="handleJudgeEdited(inputModel.unit_decimal_point, 'unit_decimal_point')"
          input-id="unitDecimalPoint"
          @change="changeValuePoint"
          min="0"
          max="9"
          v-model="inputModel.unit_decimal_point">
        </v-ons-input> -->
        <custom-input-number-pro
          :class="handleJudgeEdited(inputModel.unit_decimal_point, 'unit_decimal_point')"
          :step="1"
          :value="inputModel.unit_decimal_point"
          :min="0"
          :max="8"
          :emptyVal="null"
          @handlerInput="(val) =>{ inputModel.unit_decimal_point =  val;changeValuePoint()}"
        />
        <!-- #10713 小数点以下桁数指定を0～8までにする linjunfeng end -->
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="unit-second">レセ単位小数部桁数</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <!-- #10713 小数点以下桁数指定を0～8までにする linjunfeng start -->
        <!-- <v-ons-input
          type="number"
          step="1"
          :class="handleJudgeEdited(inputModel.unit_decimal_point_second, 'unit_decimal_point_second')"
          input-id="unitDecimalPointSecond"
          @change="changeValuePointSecond"
          min="0"
          max="9"
          v-model="inputModel.unit_decimal_point_second">
        </v-ons-input> -->
        <custom-input-number-pro
          :class="handleJudgeEdited(inputModel.unit_decimal_point_second, 'unit_decimal_point_second')"
          :step="1"
          :value="inputModel.unit_decimal_point_second"
          :min="0"
          :max="8"
          :emptyVal="null"
          @handlerInput="(val) =>{ inputModel.unit_decimal_point_second =  val;changeValuePointSecond()}"
        />
        <!-- #10713 小数点以下桁数指定を0～8までにする linjunfeng end -->
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="isExchange">レセ換算</label>
      </v-ons-col>
      <v-ons-col class="input-item-radio">
        <v-ons-radio
        name="isExchange"
        value="2"
        input-id="fixed"
        modifier="round"
        v-model="inputModel.is_exchange"
        />
        <label for="fixed">固定</label>
      </v-ons-col>
      <v-ons-col class="input-item-radio">
        <v-ons-radio
        name="isExchange"
        value="0"
        input-id="conversion"
        modifier="round"
        v-model="inputModel.is_exchange"
        />
        <label for="conversion">換算</label>
      </v-ons-col>
      <v-ons-col class="input-item-radio">
        <v-ons-radio
        name="isExchange"
        value="1"
        input-id="discard-remaining-amount"
        modifier="round"
        v-model="inputModel.is_exchange"
        />
        <label for="discard-remaining-amount">残量破棄</label>
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="unit-converted"></label>
      </v-ons-col>
      <!--  薬剤マスタのレセ換算固定の場合の入力欄を左に寄せる 鞠 mod is_exchange !=='2'   -->
      <v-ons-col class="input-item-converted" v-if="inputModel.is_exchange !=='2'">
        <div v-show="isDisPaly">
          基準数量<br>
          <v-ons-input
          type="number"
          min="0"
          :class="handleJudgeEdited(inputModel.unit_converted_amount, 'unit_converted_amount')"
          :step="this.unitStep"
          @keydown="preventScientificNotationInput"
          @blur="blurValueUnitConvertAmount"
          @change="changeValueUnitConvertAmount"
          @input="inputValueUnitConvertAmount"
          input-id="unit-converted-amount"
          v-model="inputModel.unit_converted_amount">
          </v-ons-input>
        </div>
      </v-ons-col>
      <v-ons-col class="input-item-converted-label" v-if="inputModel.is_exchange !=='2'">
          <div v-show="isDisPaly">
          指示単位<br>
          <div style = "padding-top:6px;font-size: 1em;min-width: 4.0em;">
            &nbsp;{{inputModel.unit}}
          </div>
        </div>
      </v-ons-col>
      <v-ons-col class="input-item-converted-equal" v-if="inputModel.is_exchange !=='2'">
        <div v-show="isDisPaly">
          <br>＝
        </div>
      </v-ons-col>
      <v-ond-vol class="input-newline">
      </v-ond-vol>
      <v-ons-col class="input-item-converted">
        換算数量<br>
        <v-ons-input
          type="number"
          min="0"
          :class="handleJudgeEdited(inputModel.unit_converted_amount_second, 'unit_converted_amount_second')"
          :step="this.unitStepSecond"
          @keydown="preventScientificNotationInput"
          @blur="blurValueUnitConvertAmountSecond"
          @change="changeValueUnitConvertAmountSecond"
          @input="inputValueUnitConvertAmountSecond"
          input-id="unit-converted-amount-second"
          v-model="inputModel.unit_converted_amount_second">
        </v-ons-input>
      </v-ons-col>
      <v-ons-col class="input-item-converted-label">
        レセ単位<br>
        <div style = "padding-top:6px;font-size: 1em;min-width: 4.0em;">
          &nbsp;{{inputModel.unit_second}}
        </div>
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name choose-box">
        <label for="is-trial">治験</label>
      </v-ons-col>
      <v-ons-col class="input-item-check">
      <custom-checkbox
        :value="inputModel.is_trial"
        :checked-value="'1'"
        :unchecked-value="'0'"
      ></custom-checkbox>
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name choose-box">
        <label for="is-trial">注射薬</label>
      </v-ons-col>
      <v-ons-col class="input-item-check">
      <custom-checkbox
        :value="inputModel.is_shot"
        :checked-value="'1'"
        :unchecked-value="'0'"
      ></custom-checkbox>
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name choose-box">
        <label for="is-trial">自動実施</label>
      </v-ons-col>
      <v-ons-col class="input-item-check">
      <custom-checkbox
        :value="inputModel.is_medicated"
        :checked-value="'1'"
        :unchecked-value="'0'"
      ></custom-checkbox>
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <!--   mod redmine 5145 mlの表記不正→mL 孔 start-->
        <!--   <label for="unit-converted">ml換算<br></label>-->
        <label for="unit-converted">mL換算<br></label>
        <!--   mod redmine 5145 mlの表記不正→mL 孔 end-->
      </v-ons-col>
      <v-ons-col class="input-item-converted">
        基準数量<br>
        <v-ons-input
          type="number"
          min="0"
          :class="handleJudgeEdited(inputModel.anticoagulant_original_quantity, 'anticoagulant_original_quantity')"
          :step="this.unitStep"
          @keydown="preventScientificNotationInput"
          @blur="blurValueAntiOriginQuantity"
          @change="changeValueAntiOriginQuantity"
          @input="inputValueUnitConvertAmount"
          input-id="unit-converted-amount"
          v-model="inputModel.anticoagulant_original_quantity">
        </v-ons-input>
      </v-ons-col>
      <v-ons-col class="input-item-converted-label">
        指示単位<br>
        <div style = "padding-top:6px;font-size: 1em;min-width: 4.0em;">
          &nbsp;{{inputModel.unit}}
        </div>
      </v-ons-col>

      <v-ons-col class="input-item-converted-equal">
        <br>＝
      </v-ons-col>
      <v-ond-vol class="input-newline">
      </v-ond-vol>
      <v-ons-col class="input-item-converted">
        換算数量<br>
        <v-ons-input
          type="number"
          step="0.1"
          :class="handleJudgeEdited(inputModel.after_anticoagulant_quantity, 'after_anticoagulant_quantity')"
          @keydown="preventScientificNotationInput"
          @blur="blurValueAfterAntiQuantity"
          input-id="after-anticoagulant-quantity"
          v-model="inputModel.after_anticoagulant_quantity">
        </v-ons-input>
      </v-ons-col>
      <v-ons-col class="input-item-converted-ml">
        <!--  mod redmine 5145 mlの表記不正→mL 孔 start-->
        <!--  <div class="input-item-ml">&nbsp;ml&emsp;</div>-->
        <div class="input-item-ml">&nbsp;mL&emsp;</div>
        <!--  mod redmine 5145 mlの表記不正→mL 孔 end-->
      </v-ons-col>

    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="medicate-timing-cd">投与タイミング</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-select
          select-id="medicate-timing-cd"
          v-model="inputModel.medicate_timing_cd"
          name="medicate-timing-cd"
          :class="handleJudgeEdited(inputModel.medicate_timing_cd, 'medicate_timing_cd')"
          >
          <option v-for="(item, index) in comboMedicineTiming" :key="index" :value="item.value">
            {{ item.text }}
          </option>
        </v-ons-select>
      </v-ons-col>
    </v-ons-row>

    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="procedure-cd">手技</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt">
        <v-ons-select
          select-id="procedure-cd"
          :class="handleJudgeEdited(inputModel.procedure_cd, 'procedure_cd')"
          v-model="inputModel.procedure_cd"
          name="procedure-cd"
          >
          <option v-for="(item, index) in comboMedicineProcedure" :key="index" :value="item.value">
            {{ item.text }}
          </option>
        </v-ons-select>
      </v-ons-col>
    </v-ons-row>

    <!-- mod redmine 5324 連携コード1～4の判別不可 宋qy start -->
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="in-hospital">連携コード1</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt-short">
        <v-ons-input
          type="text"
          input-id="inHospitalCd1"
          maxlength="20"
          :class="handleJudgeEdited(inputModel.in_hospital_cd1, 'in_hospital_cd1')"
          v-model="inputModel.in_hospital_cd1">
        </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="in-hospital">連携コード2</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt-short">
        <v-ons-input
          type="text"
          maxlength="20"
          input-id="inHospitalCd2"
          :class="handleJudgeEdited(inputModel.in_hospital_cd2, 'in_hospital_cd2')"
          v-model="inputModel.in_hospital_cd2">
        </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="in-hospital">連携コード3</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt-short">
        <v-ons-input
          type="text"
          maxlength="20"
          input-id="inHospitalCd3"
          :class="handleJudgeEdited(inputModel.in_hospital_cd3, 'in_hospital_cd3')"
          v-model="inputModel.in_hospital_cd3">
        </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="in-hospital">連携コード4</label>
      </v-ons-col>
      <v-ons-col class="input-item-txt-short">
        <v-ons-input
          type="text"
          maxlength="20"
          :class="handleJudgeEdited(inputModel.in_hospital_cd4, 'in_hospital_cd4')"
          input-id="inHospitalCd4"
          v-model="inputModel.in_hospital_cd4">
        </v-ons-input>
      </v-ons-col>
    </v-ons-row>
    <!-- mod redmine 5324 連携コード1～4の判別不可 宋qy end -->
    <v-ons-row class="input-row">
      <v-ons-col class="input-item-name">
        <label for="in-hospital">使用期間</label>
      </v-ons-col>
      <v-ons-col class="input-item-date" style="width:auto;">
        <div class="flex-align-center">
          <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 start -->
          <!-- <v-ons-input
            class="ntss-input-date ntss-control-size"
            type="date"
            min='1880-01-01' max='2099-12-31'
            id="useStartDate"
            style="width:auto;min-width: 180px"
            :class="handleJudgeEdited(inputModel.useStartDate, 'useStartDate')"
            v-model="inputModel.useStartDate" /> -->
          <date-input
            class="ntss-input-date ntss-control-size"
            min='1880-01-01'
            max='2099-12-31'
            id="useStartDate"
            style="width:auto;min-width: 180px"
            :class="handleJudgeEdited(inputModel.useStartDate, 'useStartDate')"
            v-model="inputModel.useStartDate"
            @handleClearInput="inputModel.useStartDate = null"
             />
            <!-- #5590 2023/04/18 ×を常に表示するように修正 張博 end -->
          <common-calendar v-model="inputModel.useStartDate" />
        </div>
      </v-ons-col>
      <v-ons-col class="input-item-symbol">
      ～
      </v-ons-col>
      <v-ons-col class="input-item-date" style="width:auto;">
        <div class="flex-align-center">
          <!-- <v-ons-input
            class="ntss-input-date ntss-control-size"
            type="date"
            min='1880-01-01' max='2099-12-31'
            id="useEndDate"
            :class="handleJudgeEdited(inputModel.useEndDate, 'useEndDate')"
            style="width:auto;;min-width: 180px"
            v-model="inputModel.useEndDate" /> -->
            <date-input
            class="ntss-input-date ntss-control-size"
            min='1880-01-01' max='2099-12-31'
            id="useEndDate"
            :class="handleJudgeEdited(inputModel.useEndDate, 'useEndDate')"
            style="width:auto;;min-width: 180px"
            v-model="inputModel.useEndDate"
            @handleClearInput="inputModel.useEndDate = null"
             />
          <common-calendar v-model="inputModel.useEndDate" />
        </div>
      </v-ons-col>
    </v-ons-row>

  </div>
</template>

<script>
import dayjs from "@/compat/date/dayjs";
import BigNumber from "@/compat/number/bignumber";
import { mapActions, mapGetters } from "@/compat/vue/vuex";
import MasterMaintenanceMixin from "@/components/master-maintenance/MasterMaintenanceMixin";
import customCheckbox from "@/components/common/custom-form-tags/CustomCheckbox.vue";
import commonCalender from "@/components/common/custom-calendar/CustomCalendar.vue";
import { EventBus } from "@/compat/vue/event-bus.js";
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 start

import DIALOG_MESSAGES from '@/components/common/message-dialog/DialogMessages';
// add #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
//#5590 2023/04/18 ×を常に表示するように修正 張博 start
import DateInput from "@/components/common/DateInput.vue";
//#5590 2023/04/18 ×を常に表示するように修正 張博 end
import CustomInputNumberPro from "@/components/common/custom-form-tags/CustomInputNumberPro";
import cloneDeep from "@/compat/collections/lodash/cloneDeep";
import { getModalBodyElement, getScopedElementsByClassName } from "@/functions/common/LayoutMeasureHelper";
import { messageFormat } from "@/functions/common/MessageFormat";

export default {
  mixins: [MasterMaintenanceMixin],
  name: "medicineMainModal",
  components: {
    "common-calendar": commonCalender,
    "custom-checkbox": customCheckbox,
    //#5590 2023/04/18 ×を常に表示するように修正 張博 start
    DateInput,
    //#5590 2023/04/18 ×を常に表示するように修正 張博 end
    // add #10713 小数点以下桁数指定を0～8までにする linjunfeng start
    "custom-input-number-pro":CustomInputNumberPro,
    // add #10713 小数点以下桁数指定を0～8までにする linjunfeng end
  },
  data() {
    return {
      inputModel: {
        medicine_cd:"",
        standard_medicine_cd:"",
        medicine_name:"",
        medicine_short_name:"",
        class_cd:"",
        unit:"",
        unit_second:"",
        unit_decimal_point:"",
        unit_decimal_point_second:"",
        is_exchange:"",
        unit_converted_amount:"",
        unit_converted_amount_second:"",
        is_trial:{ initValue: null, editValue: null },
        is_shot:{ initValue: null, editValue: null },
        is_medicated:{ initValue: null, editValue: null },
        anticoagulant_original_quantity:"",
        after_anticoagulant_quantity:"",
        medicate_timing_cd:"",
        procedure_cd:"",
        in_hospital_cd1:"",
        in_hospital_cd2:"",
        in_hospital_cd3:"",
        in_hospital_cd4:"",
        useStartDate:"",
        useEndDate:"",
        // add FNSI-分類変更のメッセージ表示 李 start
        classiFicationFlg:null,
        // add FNSI-分類変更のメッセージ表示 李 end
        isDisPaly:true
      },
      inputModel_clone: {},
      //コンボボックス
      comboMedicineClass:[],
      comboMedicineTiming:[],
      comboMedicineProcedure:[],
      pattern: new RegExp("[+-]?\\d+(?:\\.\\d+)?(?:[eE][+-]?\\d+)?"),
      // add FNSI-分類変更のメッセージ表示 李 start
      classCd:null,
      // add FNSI-分類変更のメッセージ表示 李 end
      editRecordClone: null
    };
  },
  computed: {
    // add マスタ一覧 1･施設切替を可能とする 王 start
    ...mapGetters("master-maintenance", { getFacilitySwitch: "getFacilitySwitch",}),
    // add マスタ一覧 1･施設切替を可能とする 王 end
    ...mapGetters("master-maintenance", {
        masterName: "getMasterName",
        editRecord: "getEditRecord",
        columns: "getColumns",
        isEdited: "isEdited",
        masterRecord: "getMasterRecordList",
    }),
    ...mapGetters("user", { facilityCd: "getFacilityCd" }),
    // 標準医薬品マスタ検索モーダルStore
    ...mapGetters("sys-medicine-sub-modal",["getSelectedSysMedicine"]),

    // 指示単位小数部桁数取得
    getDecimalPoint() {
      var num = parseFloat(this.inputModel.unit_decimal_point);
      if(isNaN(num)){
        num = null;
      }
      return num;
    },

    // 指示単位小数部:step制御用パラメータ
    unitStep(){
      var num = parseInt(this.inputModel.unit_decimal_point);
      if(isNaN(num)){
        num = 0;
      }
      var data = BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf();
      return parseFloat(data);
    },

    // レセ単位小数部桁数取得
    getDecimalPointSecond() {
      var num = parseFloat(this.inputModel.unit_decimal_point_second);
      if(isNaN(num)){
        num = null;
      }
      return num;
    },

    // レセ単位小数部:step制御用パラメータ
    unitStepSecond(){
      var num = parseInt(this.inputModel.unit_decimal_point_second);
      if(isNaN(num)){
        num = 0;
      }
      var data = BigNumber(10).exponentiatedBy(BigNumber(num).negated()).valueOf();
      return parseFloat(data);
    },

  },
  watch: {
    inputModel: {
      handler(newVal) {
        if (this.editRecord["medicineCd"] !== newVal.medicine_cd) {
          this.editRecordClone["medicineCd"] = newVal.medicine_cd;
        }
        if (this.editRecord["standardMedicineCd"] !== newVal.standard_medicine_cd) {
          this.editRecordClone["standardMedicineCd"] = newVal.standard_medicine_cd;
        }
        if (this.editRecord["name"] !== newVal.medicine_name) {
          this.editRecordClone["name"] = newVal.medicine_name;
        }
        if (this.editRecord["medicineShortName"] !== newVal.medicine_short_name) {
          this.editRecordClone["medicineShortName"] = newVal.medicine_short_name;
        }
        if (this.editRecord["classCd"] !== newVal.class_cd) {
          this.editRecordClone["classCd"] = newVal.class_cd;
        }
        if (this.editRecord["unit"] !== newVal.unit) {
          this.editRecordClone["unit"] = newVal.unit;
        }
        if (this.editRecord["unitSecond"] !== newVal.unit_second) {
          this.editRecordClone["unitSecond"] = newVal.unit_second;
        }
        if (this.editRecord["unitDecimalPoint"] !== newVal.unit_decimal_point) {
          this.editRecordClone["unitDecimalPoint"] = newVal.unit_decimal_point;
        }
        if (this.editRecord["unitDecimalPointSecond"] !== newVal.unit_decimal_point_second) {
          this.editRecordClone["unitDecimalPointSecond"] = newVal.unit_decimal_point_second;
        }
        if (this.editRecord["isExchange"] !== newVal.is_exchange) {
          this.editRecordClone["isExchange"] = newVal.is_exchange;
        }
        if (this.editRecord["unitConvertedAmount"] !== newVal.unit_converted_amount) {
          this.editRecordClone["unitConvertedAmount"] = newVal.unit_converted_amount;
        }
        if (this.editRecord["unitConvertedAmountSecond"] !== newVal.unit_converted_amount_second) {
          this.editRecordClone["unitConvertedAmountSecond"] = newVal.unit_converted_amount_second;
        }
        //ADD レセ換算固定の場合の換算式入力IFの表示レセ換算固定は指示数量に関わらずレセ数量を固定に換算する。そのため基準数量の表示が不要となる。 楊zc START
        this.isDisPaly = newVal.is_exchange === "2" ? false:true;
        if(!this.isDisPaly) {
          // newVal.unit = "";
          newVal.unit_converted_amount = "";
        }
        //ADD レセ換算固定の場合の換算式入力IFの表示レセ換算固定は指示数量に関わらずレセ数量を固定に換算する。そのため基準数量の表示が不要となる。 楊zc START

        if (this.editRecord["isTrial"] !== newVal.is_trial.editValue) {
          this.editRecordClone["isTrial"] = newVal.is_trial.editValue;
        }
        if (this.editRecord["isShot"] !== newVal.is_shot.editValue) {
          this.editRecordClone["isShot"] = newVal.is_shot.editValue;
        }
        if (this.editRecord["isMedicated"] !== newVal.is_medicated.editValue) {
          this.editRecordClone["isMedicated"] = newVal.is_medicated.editValue;
        }
        if (this.editRecord["anticoagulantOriginalQuantity"] !== newVal.anticoagulant_original_quantity) {
          this.editRecordClone["anticoagulantOriginalQuantity"] = newVal.anticoagulant_original_quantity;
        }
        if (this.editRecord["afterAnticoagulantQuantity"] !== newVal.after_anticoagulant_quantity) {
          this.editRecordClone["afterAnticoagulantQuantity"] = newVal.after_anticoagulant_quantity;
        }
        if (this.editRecord["medicateTimingCd"] !== newVal.medicate_timing_cd) {
          //投与タイミング及び手技は空項目選択時にnullへ
          if (newVal.medicate_timing_cd == "") {
            this.editRecordClone["medicateTimingCd"]  = null;
          } else {
            this.editRecordClone["medicateTimingCd"] = newVal.medicate_timing_cd;
          }
        }
        if (this.editRecord["procedureCd"] !== newVal.procedure_cd) {
          if (newVal.procedure_cd == "") {
            this.editRecordClone["procedureCd"]  = null;
          } else {
            this.editRecordClone["procedureCd"] = newVal.procedure_cd;
          }
        }
        if (this.editRecord["inHospitalCd1"] !== newVal.in_hospital_cd1) {
          this.editRecordClone["inHospitalCd1"] = newVal.in_hospital_cd1;
        }
        if (this.editRecord["inHospitalCd2"] !== newVal.in_hospital_cd2) {
          this.editRecordClone["inHospitalCd2"] = newVal.in_hospital_cd2;
        }
        if (this.editRecord["inHospitalCd3"] !== newVal.in_hospital_cd3) {
          this.editRecordClone["inHospitalCd3"] = newVal.in_hospital_cd3;
        }
        if (this.editRecord["inHospitalCd4"] !== newVal.in_hospital_cd4) {
          this.editRecordClone["inHospitalCd4"] = newVal.in_hospital_cd4;
        }
        //日付項目FROM-TOは変換不可ならnullセット
        if (newVal.useStartDate ==="Invalid date" || newVal.useStartDate === null || newVal.useStartDate === "") {
          this.editRecordClone["useStartDate"] = null;
        } else {
          this.editRecordClone["useStartDate"] = dayjs(newVal.useStartDate).format("YYYYMMDD");
        }
        if (newVal.useEndDate ==="Invalid date" || newVal.useEndDate === null || newVal.useEndDate === "") {
          this.editRecordClone["useEndDate"]  = null;
        } else {
          this.editRecordClone["useEndDate"]  = dayjs(newVal.useEndDate).format("YYYYMMDD");
        }
        // add FNSI-分類変更のメッセージ表示 李 start
        if (this.classCd && this.classCd != newVal.class_cd) {
          this.editRecordClone["classiFicationFlg"] = true;
        }
        //mod マスタ詳細画面がありません破棄メッセージ 张博 start
        // add FNSI-分類変更のメッセージ表示 李 end
        if (newVal.standard_medicine_cd==="") {
          newVal.standard_medicine_cd=null
        }
        if (newVal.in_hospital_cd1==="") {
          newVal.in_hospital_cd1=null
        }
        if (newVal.in_hospital_cd2==="") {
          newVal.in_hospital_cd2=null
        }
        if (newVal.in_hospital_cd3==="") {
          newVal.in_hospital_cd3=null
        }
        if (newVal.in_hospital_cd4==="") {
          newVal.in_hospital_cd4=null
        }
        if (newVal.medicine_short_name==="") {
          newVal.medicine_short_name = null
        }
        newVal.medicate_timing_cd = newVal.medicate_timing_cd?.toString();
        newVal.procedure_cd = newVal.procedure_cd?.toString();
        if(JSON.stringify(newVal) !== JSON.stringify(this.inputModel_clone)){
          this.changeButton();
        } else {
          EventBus.$emit("mstHolidayRegistered", true);
        }
        //mod マスタ詳細画面がありません破棄メッセージ 张博 end
      },
      deep: true,
    },
  },
  methods: {
    preventScientificNotationInput(event) {
      if (event.key === "e" || event.key === "E") {
        event.preventDefault();
      }
    },
    // delete start #9301
    // ...mapActions("master-maintenance",
    // ["findFacilitySettingInfo"]
    // ),
    // delete end #9301
    /**
     * SubModalのアクション
     */
    ...mapActions("multi-sub-modal", ["showSysMedicineSearchSubModal"]),

    // 指示単位小数部桁数変更時の処理
    changeValuePoint() {
      var returnVal;
      var num;
      var decPoint = this.getDecimalPoint;
      // 入力値上限または下限チェック
      if(decPoint !== null){
        // #10713 小数点以下桁数指定を0～8までにする linjunfeng start
        // decPoint > 9 ? decPoint = 9 : decPoint < 0 ? decPoint = 0 : decPoint = Math.floor(decPoint);
        decPoint > 8 ? decPoint = 8 : decPoint < 0 ? decPoint = 0 : decPoint = Math.floor(decPoint);
        // #10713 小数点以下桁数指定を0～8までにする linjunfeng end
        this.inputModel.unit_decimal_point = decPoint;
      }
      //step値セット
      var decStep = BigNumber(10).exponentiatedBy(BigNumber(decPoint)).valueOf();
      var setStep = BigNumber(10).exponentiatedBy(BigNumber(decPoint).negated()).valueOf();
      // ml換算指示基準数量
      num = this.inputModel.anticoagulant_original_quantity;
      if(this.pattern.test(num) && decPoint !== null){
          num = BigNumber(num).multipliedBy(BigNumber(decStep)).valueOf();
          num = num >=0 ?  Math.floor(num):Math.ceil(num);
          returnVal = BigNumber(num).multipliedBy(BigNumber(setStep)).valueOf();
          this.inputModel.anticoagulant_original_quantity = BigNumber(returnVal).toFixed(decPoint);
      }
      // レセ換算指示基準数量
      num = this.inputModel.unit_converted_amount;
      if(this.pattern.test(num) && decPoint !== null){
          //入力された値が数値の場合
          num = BigNumber(num).multipliedBy(BigNumber(decStep)).valueOf();
          num = num >=0 ?  Math.floor(num):Math.ceil(num);
          returnVal = BigNumber(num).multipliedBy(BigNumber(setStep)).valueOf();
          this.inputModel.unit_converted_amount = BigNumber(returnVal).toFixed(decPoint);
      }
    },

    // レセ単位小数部桁数変更時の処理
    changeValuePointSecond() {
      var decPoint = this.getDecimalPointSecond;
      // 入力値上限または下限チェック
      if(decPoint !== null){
        // #10713 小数点以下桁数指定を0～8までにする linjunfeng start
        // decPoint > 9 ? decPoint = 9 : decPoint < 0 ? decPoint = 0 : decPoint = Math.floor(decPoint);
        decPoint > 8 ? decPoint = 8 : decPoint < 0 ? decPoint = 0 : decPoint = Math.floor(decPoint);
        // #10713 小数点以下桁数指定を0～8までにする linjunfeng end
        this.inputModel.unit_decimal_point_second = decPoint;
      }
      var returnVal;
      // レセ換算指示基準数量
      var num = this.inputModel.unit_converted_amount_second;
      var decStep = BigNumber(10).exponentiatedBy(BigNumber(decPoint)).valueOf();
      var setStep = BigNumber(10).exponentiatedBy(BigNumber(decPoint).negated()).valueOf();
      if(this.pattern.test(num) && decPoint !== null){
          //入力された値が数値の場合
          num = BigNumber(num).multipliedBy(BigNumber(decStep)).valueOf();
          num = num >=0 ?  Math.floor(num):Math.ceil(num);
          returnVal = BigNumber(num).multipliedBy(BigNumber(setStep)).valueOf();
          this.inputModel.unit_converted_amount_second = BigNumber(returnVal).toFixed(decPoint);
      }
    },

    // レセ換算-基準数量の値変更時制御
    changeValueUnitConvertAmount(){
      if(this.pattern.test(this.inputModel.unit_converted_amount) && this.getDecimalPoint !== null){
          this.inputModel.unit_converted_amount
          = this.convertExponential(this.inputModel.unit_converted_amount,this.getDecimalPoint);
      }
    },

    // レセ換算-基準数量の値入力時制御(inputType=number固有入力時)
    inputValueUnitConvertAmount(event){
      if(this.pattern.test(event.target.value) && this.getDecimalPoint !== null && event.inputType == null){
          event.target.value = this.convertExponential(event.target.value, this.getDecimalPoint);
      }
    },

    // レセ換算-基準数量のfocusOut時制御
    blurValueUnitConvertAmount() {
      if(!this.inputModel.unit_converted_amount){
        this.inputModel.unit_converted_amount = null;
      }
    },
    //[確認]ボタンの状態の変更をトリガーします
    changeButton() {
      EventBus.$emit("mstHolidayRegistered", false);
    },
    // レセ換算-換算数量の値変更時制御
    changeValueUnitConvertAmountSecond(){
      if(this.pattern.test(this.inputModel.unit_converted_amount_second) && this.getDecimalPointSecond !== null){
          this.inputModel.unit_converted_amount_second
           = this.convertExponential(this.inputModel.unit_converted_amount_second,this.getDecimalPointSecond);

      }
    },

    // レセ換算-換算数量の値変更時制御
    inputValueUnitConvertAmountSecond(event){
      if(this.pattern.test(event.target.value) && this.getDecimalPointSecond !== null && event.inputType == null){
          event.target.value = this.convertExponential(event.target.value, this.getDecimalPointSecond);
      }
    },

    // レセ換算-換算数量のfocusOut時制御
    blurValueUnitConvertAmountSecond() {
      if(!this.inputModel.unit_converted_amount_second){
        this.inputModel.unit_converted_amount_second = null;
      }
    },

    // ml換算-基準数量の値変更時制御
    changeValueAntiOriginQuantity(){
      if(this.pattern.test(this.inputModel.anticoagulant_original_quantity) && this.getDecimalPoint !== null){
          this.inputModel.anticoagulant_original_quantity
          = this.convertExponential(this.inputModel.anticoagulant_original_quantity,this.getDecimalPoint);
      }
    },

    // ml換算-基準数量のfocusOut時制御
    blurValueAntiOriginQuantity() {
      if(!this.inputModel.anticoagulant_original_quantity){
        this.inputModel.anticoagulant_original_quantity = null;
      }
    },

    // ml換算-換算数量のfocusOut時制御
    blurValueAfterAntiQuantity() {
      if(!this.inputModel.after_anticoagulant_quantity){
        this.inputModel.after_anticoagulant_quantity = null;
      }
      //add start 鞠 mL換算は小数点1桁
      // #9863 Error in v-on handler: "TypeError: Cannot read properties of null (reading 'toString')" 横展開2 linjunfeng start
      // if (this.inputModel.after_anticoagulant_quantity.toString().split(".").length && this.inputModel.after_anticoagulant_quantity.toString().split(".")[1].length > 1) {
      if (this.inputModel.after_anticoagulant_quantity?.toString().split(".")?.length && this.inputModel.after_anticoagulant_quantity.toString().split(".")[1]?.length > 1) {
      // #9863 Error in v-on handler: "TypeError: Cannot read properties of null (reading 'toString')" 横展開2 linjunfeng end  
        let str = this.inputModel.after_anticoagulant_quantity.toString();
        let strIndex = str.indexOf('.');
        this.inputModel.after_anticoagulant_quantity = str.substring(0, strIndex + 2);
      }
      // add end
    },

    // 指数整数変換
    convertExponential(num,decPoint){
      var decStep;
      var setStep;
      var setNum;
      decStep = BigNumber(10).exponentiatedBy(BigNumber(decPoint)).valueOf();
      setStep = BigNumber(10).exponentiatedBy(BigNumber(decPoint).negated()).valueOf();
      num = BigNumber(num).multipliedBy(BigNumber(decStep)).valueOf();
      setNum = num >=0 ?  Math.floor(num):Math.ceil(num);
      var returnVal = BigNumber(setNum).multipliedBy(BigNumber(setStep)).valueOf();
      return BigNumber(returnVal).toFixed(decPoint);
    },

    validateData() {
      // 表示条件があるのに条件式が未設定
      let isConvertPoint = true;
      let isConvert2Point = true;
      let isAntiOriginPoint = true;
      let isMlPoint = true;
      let isnullDecPoint = true;
      let isnullDecPoint2 = true;

      //1.対象項目取得
      var decPoint = this.getDecimalPoint;
      var decPoint2 = this.getDecimalPointSecond;
      var convertAmount = this.inputModel.unit_converted_amount;
      var convertAmount2 = this.inputModel.unit_converted_amount_second;
      var antiOriginQuantity = this.inputModel.anticoagulant_original_quantity;
      var afterAntiQuantity = this.inputModel.after_anticoagulant_quantity;

      //1-1.指示単位小数部桁数設定
      if(decPoint === null){
        isnullDecPoint = false;
      }
      //1-2.レセ単位小数部桁数設定
      if(decPoint2 === null){
        isnullDecPoint2 = false;
      }
      if(!decPoint || !decPoint2){
        return {
          decPointValid:isnullDecPoint,
          decPointValid2:isnullDecPoint2,
          unitConvertAmountValid: isConvertPoint,
          unitConvertAmount2Valid: isConvert2Point,
          antiOriginQuantityValid: isAntiOriginPoint,
          mlValid:isMlPoint
        };
      }

      //2-1.レセ換算:指示基準数量小数部桁数:設定値オーバーの場合にエラー
      if(this.getDecimalPointLength(convertAmount) > decPoint){
        isConvertPoint = false;
      }
      //2-2.レセ換算:レセ換算数量小数部桁数:設定値オーバーの場合にエラー
      if(this.getDecimalPointLength(convertAmount2) > decPoint2){
        isConvert2Point = false;
      }
      //2-3.ml換算：指示基準数量小数部桁数:設定値オーバーの場合にエラー
      if(this.getDecimalPointLength(antiOriginQuantity) > decPoint){
        isAntiOriginPoint = false;
      }
      //2-4.ml換算数量:小数部1桁まで
      if(this.getDecimalPointLength(afterAntiQuantity) > 1){
        isMlPoint = false;
      }
      return {
        decPointValid:isnullDecPoint,
        decPointValid2:isnullDecPoint2,
        unitConvertAmountValid: isConvertPoint,
        unitConvertAmount2Valid: isConvert2Point,
        antiOriginQuantityValid: isAntiOriginPoint,
        mlValid:isMlPoint
      };
    },
    validateOnRegistration() {
      const validationResult = this.validateData();
      if (Object.values(validationResult).every(v => v === true)) {
        return true;
      }
      // メッセージ組み立て
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
      // const title = "小数部設定エラー";
      const title = DIALOG_MESSAGES[12000119].title;
      // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
      const message = `
          ${
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // !validationResult.decPointValid ? "指示単位小数部桁数：未入力エラー<br>": ""
            !validationResult.decPointValid ? messageFormat(DIALOG_MESSAGES[12000119].message): ""
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          }
          ${
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // !validationResult.decPointValid2 ? "レセ単位小数部桁数：未入力エラー<br>": ""
            !validationResult.decPointValid2 ? messageFormat(DIALOG_MESSAGES[12000120].message): ""
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          }
          ${
            !validationResult.unitConvertAmountValid
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
              // ? "レセ換算:基準数量小数部オーバー<br>"
              ? messageFormat(DIALOG_MESSAGES[12000121].message)
              // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
              : ""
          }
          ${
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // !validationResult.unitConvertAmount2Valid ? "レセ換算:換算数量小数部オーバー<br>": ""
            !validationResult.unitConvertAmount2Valid ? messageFormat(DIALOG_MESSAGES[12000122].message): ""
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          }
          ${
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // !validationResult.antiOriginQuantityValid ? "ml換算:基準数量小数部オーバー<br>": ""
            !validationResult.antiOriginQuantityValid ? messageFormat(DIALOG_MESSAGES[12000123].message): ""
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          }
          ${
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 start
            // !validationResult.antiOriginQuantityValid ? "ml換算:換算数量小数部オーバー<br>": ""
            !validationResult.mlValid ? messageFormat(DIALOG_MESSAGES[12000124].message): ""
            // mod #6107 2023/03/09 メッセージボックス全調整 林峻峰 end
          }
        `;
      // ダイアログ表示
      this.$ons.notification.alert({
        title: title,
        message: message
      });
      return false;
    },
    getDecimalPointLength(number){
      var numbers = String(number).split('.');
      return (numbers[1]) ? numbers[1].length : 0;
    },
    /**
     * 標準医薬品マスタ検索モーダルを表示する.
     */
    onSelect() {
      this.showSysMedicineSearchSubModal();
    },
    /**
     * 標準医薬品マスタ検索モーダルを閉じた時のイベント
     */
    closeSelectSysMedicineModal() {
      // 標準医薬品マスタ未選択の場合
      if (!this.getSelectedSysMedicine) {
        return;
      }
      // 標準医薬品マスタが選択された場合
      const selectedSysMedicine = this.getSelectedSysMedicine;
      // YJコード(個別医薬品コード)
      this.inputModel.standard_medicine_cd = selectedSysMedicine.standardMedicineCd;
      // 薬剤名(レセプト電算処理システム医薬品名)
      this.inputModel.medicine_name = selectedSysMedicine.receiptMedicineName;
      // 省略薬剤名(販売名)
      this.inputModel.medicine_short_name = selectedSysMedicine.salesName;
      // 指示単位
      this.inputModel.unit = selectedSysMedicine.unit;
      // レセ単位
      this.inputModel.unit_second = selectedSysMedicine.unitSecond;
      // レセ換算
      // ※レセ換算数量がnullでない場合
      if (selectedSysMedicine.unitConvertedAmountSecond !== null) {
        this.inputModel.is_exchange = "0";
      }
      // レセ換算基準数量
      this.inputModel.unit_converted_amount = selectedSysMedicine.unitConvertedAmount;
      this.changeValuePoint();
      // レセ換算換算数量
      this.inputModel.unit_converted_amount_second = selectedSysMedicine.unitConvertedAmountSecond;
      this.changeValuePointSecond();
      // 注射薬(区分が注射の場合ON)
      this.inputModel.is_shot.initValue = selectedSysMedicine.usageCategoryClass === "3" ? "1" : "0";
      this.inputModel.is_shot.editValue = selectedSysMedicine.usageCategoryClass === "3" ? "1" : "0";
    },
    handleJudgeEdited (val, key) {
      if ([null, undefined, ''].includes(this.inputModel_clone[key]) && !val) {
        return ''
      }
      if (this.inputModel_clone && this.inputModel_clone[key] != val) {
        return 'custom-input-edited'
      } else {
        return ''
      }
    }
  },
  async created() {
    this.editRecordClone = cloneDeep(this.editRecord);
    // 選択したデータを画面表示用に変数へ代入
    this.inputModel.medicine_cd = this.editRecord["medicineCd"];
    this.inputModel.standard_medicine_cd = this.editRecord["standardMedicineCd"];
    this.inputModel.medicine_name = this.editRecord["name"];
    this.inputModel.medicine_short_name = this.editRecord["medicineShortName"];
    this.inputModel.class_cd = this.editRecord["classCd"];
    this.inputModel.unit = this.editRecord["unit"];
    this.inputModel.unit_second = this.editRecord["unitSecond"];
    this.inputModel.unit_decimal_point = this.editRecord["unitDecimalPoint"];
    this.inputModel.unit_decimal_point_second = this.editRecord["unitDecimalPointSecond"];
    this.inputModel.is_exchange = this.editRecord["isExchange"];
    this.inputModel.unit_converted_amount = this.editRecord["unitConvertedAmount"];
    this.inputModel.unit_converted_amount_second = this.editRecord["unitConvertedAmountSecond"];
    this.inputModel.is_trial.initValue = this.editRecord["isTrial"];
    this.inputModel.is_trial.editValue = this.editRecord["isTrial"];
    this.inputModel.is_shot.initValue = this.editRecord["isShot"];
    this.inputModel.is_shot.editValue = this.editRecord["isShot"];
    this.inputModel.is_medicated.initValue = this.editRecord["isMedicated"];
    this.inputModel.is_medicated.editValue = this.editRecord["isMedicated"];
    this.inputModel.anticoagulant_original_quantity = this.editRecord["anticoagulantOriginalQuantity"];
    this.inputModel.after_anticoagulant_quantity = this.editRecord["afterAnticoagulantQuantity"];
    //ADD レセ換算固定の場合の換算式入力IFの表示レセ換算固定は指示数量に関わらずレセ数量を固定に換算する。そのため基準数量の表示が不要となる。 楊zc START
    this.isDisPaly = this.inputModel.is_exchange === "2" ? false:true;
    //ADD レセ換算固定の場合の換算式入力IFの表示レセ換算固定は指示数量に関わらずレセ数量を固定に換算する。そのため基準数量の表示が不要となる。 楊zc END
    //投与タイミングと手技は新規作成かつ初回限定で施設設定マスタのデフォルト値を取る
    this.inputModel.in_hospital_cd1 = this.editRecord["inHospitalCd1"];
    this.inputModel.in_hospital_cd2 = this.editRecord["inHospitalCd2"];
    this.inputModel.in_hospital_cd3 = this.editRecord["inHospitalCd3"];
    this.inputModel.in_hospital_cd4 = this.editRecord["inHospitalCd4"];
    this.inputModel.procedure_cd = this.editRecord["procedureCd"];
    if(this.editRecord["useStartDate"] === null){
      this.inputModel.useStartDate = null;
    }else{
      this.inputModel.useStartDate = dayjs(this.editRecord["useStartDate"]).format("YYYY-MM-DD");
    }
    if(this.editRecord["useEndDate"] === null){
      this.inputModel.useEndDate = null;
    }else{
      this.inputModel.useEndDate = dayjs(this.editRecord["useEndDate"]).format("YYYY-MM-DD");
    }
    this.inputModel.medicate_timing_cd = this.editRecord["medicateTimingCd"];
    this.inputModel.procedure_cd = this.editRecord["procedureCd"];
    // 選択リストのデータはsys_master_defineで定義したものを取得
    // 薬剤分類区分
    let combo1 = this.columns.find((column) => {
      return (column.field === 'classCd');
    });
    this.comboMedicineClass = combo1.values;

    // 投与タイミング区分
    combo1 = this.columns.find((column) => {
      return (column.field === 'medicateTimingCd');
    });
    this.comboMedicineTiming = combo1.values;

    // 手技
    combo1 = this.columns.find((column) => {
      return (column.field === 'procedureCd');
    });
    this.comboMedicineProcedure = combo1.values;

    // 標準医薬品マスタ検索画面が閉じられた時のイベントを登録する.
    EventBus.$on("applySysMedicineSubModal", this.closeSelectSysMedicineModal);
  },
  async mounted() {
    // 縦スクロールバー表示
    const modalObj = getModalBodyElement(this.$el || this);
    if (modalObj){
      modalObj.classList.remove("modal-overflow-hidden");
      modalObj?.classList?.add("modal-scroll");
    }
    //画面表示
    this.changeValuePoint();
    this.changeValuePointSecond();

    this.$nextTick(() => {
      this.inputModel_clone = JSON.parse(JSON.stringify(this.inputModel))
      setTimeout(() => {
        let checkBoxStyle = getScopedElementsByClassName("checkbox__checkmark checkbox--material__checkmark", this.$el || this)
        for (let i = 0; i < 3; i++) {
          if (checkBoxStyle[0] !== undefined) {
            checkBoxStyle[0].classList.remove("checkbox--material__checkmark");
          }
        }
        let radioStyle = getScopedElementsByClassName("radio-button__input radio-button--material__input radio-button--round__input", this.$el || this)
        let spanStyle = getScopedElementsByClassName("radio-button__checkmark radio-button--material__checkmark radio-button--round__checkmark", this.$el || this)
        for (let i = 0; i < 5; i++) {
          if (spanStyle[0] !== undefined && radioStyle[0] !== undefined) {
            radioStyle[0].classList.remove("radio-button--material__input");
            spanStyle[0].classList.remove("radio-button--material__checkmark");
          }
        }
      }, 100);
    });
    //最初のボタンはグレーで表示されます
    setTimeout(() => {
      EventBus.$emit("mstHolidayRegistered", true);
    }, 200);
  },
  /**
   * 画面を破棄する時の処理
   */
  beforeUnmount() {
    // 標準医薬品マスタ検索画面が閉じられた時のイベント解除する.
    EventBus.$off("applySysMedicineSubModal", this.closeSelectSysMedicineModal);
  }
};
</script>

<style scoped>
#exam-item-modal-content {
  font-size: 1em;
  padding-left: 20px;
}
.modal-scroll {
  overflow-x: hidden;
  overflow-y: scroll;
}
table {
  max-width: 100%;
  border-collapse: collapse;
  margin-bottom: 20px;
}
table thead {
  font-size: 1.2em;
  color: #ffffff;
  background-color: #3f3f3f;
}
table thead tr {
  height: 25px;
}
table tr {
  border-bottom: 1px solid #bbb;
}
.input-row {
  margin-bottom: 5px;
  max-width: 1024px;
}
.input-item-name {
  /* UPDATE 仕样变更 楊zc start*/
  font-size: 1em;
  /* font-weight: bold; */
  /* UPDATE 仕样变更 楊zc end */
  margin-top: 10px;
  max-width: 21%;
}
.input-item-txt {
  max-width: 40%;
}
.input-item-txt-short{
  max-width: 18%;
}
.input-item-txt-long {
  max-width: 70%;
}
.input-item-button {
  max-width: 10%;
}
.input-item-radio {
  max-width: 6.5em;
  font-size:1em;
  margin-top: 10px;
}
.input-item-check {
  max-width: 10%;
  font-size:1.2em;
  margin-top: 10px;
}
.input-item-date{
  flex: none;
}
.input-item-converted{
  max-width: 15%;
  min-width: 15%;
}
.input-item-converted-label{
  max-width: 15%;
  min-width: 15%;
  word-wrap: break-word;
}
.input-item-converted-equal{
  max-width: 5%;
  min-width: 1em;
  font-size: 1em;
  text-align: center;
  margin-top:5px;
}
.input-item-symbol{
  max-width: 2em;
  font-size: 1em;
  text-align: center;
  margin-top: 5px;
}
.input-item-converted-ml{
  padding-top:1.0em;
  max-width: 25%;
}
.input-item-ml{
  font-size:1em;
  padding-top:1.0em;
}
.input-newline{
  min-width:0%;
  max-width:0%;
}

@media screen and (min-width:650px) and (max-width: 850px) {
  .input-item-converted{
    max-width: 15%;
    min-width: 15%;
  }
  .input-item-converted-label{
    max-width: 20%;
    min-width: 20%;
  }
}

@media screen and (max-width: 650px) {
  .input-item-name {
    text-align: left;
  /* UPDATE 仕样变更 楊zc start*/
    font-size: 1em;
    /* font-weight: bold; */
  /* UPDATE 仕样变更 楊zc end */
    margin-bottom: 5px;
    min-width: 95%;
  }
  .choose-box {
    min-width: 40% !important;
  }
  .input-item-txt {
    min-width: 90%;
  }
  .input-item-txt-long {
    text-align: left;
    min-width: 90%;
  }
  .input-item-txt-short {
    min-width: 90%;
  }
  .input-item-button {
    text-align: left;
    min-width: 90%;
  }
  .input-item-radio {
    font-size:1.2em;
    /*min-width: 6.5em;*/
  }
  .input-item-check {
    font-size:1.2em;
    /*min-width: 90%;*/
    max-width: 5%;
  }
  .input-item-date{
    text-align: left;
  }
  .input-item-symbol{
    min-width: 90%;
    text-align: left;
  }
  .input-item-converted{
    text-align: left;
    min-width: 30%;
    max-width: 30%;
  }
  .input-item-converted-label{
    text-align: left;
    min-width: 35%;
    max-width: 35%;
  }
  .input-item-converted-equal{
    text-align: center;
    min-width: 10%;
    max-width: 10%;
  }
  .input-newline{
    min-width:90%;
    max-width:90%;
  }
}
:deep(.custom-input-edited>input[type="number"]), :deep(.custom-input-edited>input[type="date"]), :deep(.custom-input-edited>select){
  border: 2px green solid;
  outline: 0;
  border-radius: 5px;
}
</style>
