<template>
  <!-- mod FNSI-7483 劉全航 start -->
  <!-- <div class="multi-pat-list" style="height: 100%" v-if="isDisplay"> -->
  <div
    id="multi-pat-list-template"
    ref="gridContainer"
    class="multi-pat-list"
    style="height: 100%"
    v-show="isDisplay"
  >
    <!-- mod FNSI-7483 劉全航 end -->
    <KendoGridView
      ref="grid"
      class="pat-num"
      :columns="kendoColumns"
      :options="gridDataSourceOptions"
      :height="gridHeight"
      :scrollable="gridScrollable"
      :sortable="gridSortable"
      :resizable="true"
      :reorderable="true"
      :data-bound="kgridDataBound"
    />

    <v-ons-popover
      v-if="isPopoverVisible"
      :visible.sync="isPopoverVisible"
      :target="popoverTarget"
      cancelable
      :class="fontSizeSet"
      @preshow="popoverPreShow"
      @postshow="popoverPostShow"
      @posthide="popoverPosthide"
    >
      <div class="transition-popover">
        <v-ons-button
          v-for="(link) in linkList"
          :key="link.key"
          class="transition-button btn3-normal"
          :disabled="link.disabled"
          @click="moveTo(popoverTarget, link.key)"
        ><img class="icon" :src="link.imageInfo"/>{{ link.name }}</v-ons-button>
      </div>
    </v-ons-popover>
  </div>
</template>

<script>
  import { publicAssetPath } from "@/compat/assets/public-path";
  //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
  import { getCurrentFunctionCd } from "@/router/routing-helper";
  //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
  import $$ from "@/compat/jquery";
  import { EventBus } from "@/compat/vue/event-bus.js";
  import { has, values } from "@/compat/collections/lodash";
  import * as workbook_1 from "@/functions/common/KendoFunctions";
  import * as kendo_file_saver_1 from "@/functions/common/KendoFunctions";
  import dayjs from "@/compat/date/dayjs";
  import { mapActions, mapGetters } from "@/compat/vue/vuex";
  import encoding from "@/compat/encoding/encoding-japanese";
  import {ApiHelper} from '@/apis/AxiosHelper';
  import {AUTHORITY_CODES} from '@/constants/userAuthority';
  import ComponentGuardMixin from '@/components/common/ComponentGuardMixin';
  import {updatePatRecords} from './Functions.js';
  import {getVitalMonitorsData} from './template.js';
  import {getTreatmentPlanData} from './template2.js';
  import {
    DEVICE_SET,
    INSPECTION_RADIATION,
    PAT_INFO_TWO_TEMPLATE_CD,
    TREATMENT_PLAN_TREATMENT_RECORD,
    VITAL_MONITORS_COMPLAINTS_CD,
  } from '@/constants/dataListConstant';
  import IndUserSelectMixin from '@/components/common/IndUserSelectMixin';
  import PopoverMixin from '@/components/PopoverMixin';
  //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
  import {getErrorMessage} from '@/functions/common/AppLogMessageFormat';
  //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
  import {
    ORD_NO,
    ACCESS_REC_MEASURE_CD,
    ADDITION_AUTO_CALC_EFFECTIVE_CD,
    ADDITION_LATEST_CALC_DAY_CD,
    ADDITION_NAME_CD,
    ARTER_BUBBLE_DETECTOR_CD,
    ARTERIAL_BLOOD_DETECTOR_SELECT_CD,
    ARTERIAL_CHAMBER_LIQUID_TIME_AFTE_CD,
    ARTERIAL_CHAMBER_LIQUID_TIME_BEFO_CD,
    ARTERIAL_FILLING_LIQUID_CD,
    ARTERIAL_FILLING_OPERAT_SELECT_CD,
    ARTERIAL_FILLING_VELOCITY_CD,
    ARTERIAL_RETURN_CHOICE_CD,
    AUTO_MEASURE1_CD,
    AUTO_MEASURE2_CD,
    AUTO_MEASURE3_CD,
    AUTO_MEASURE4_CD,
    AUTO_MEASURE5_CD,
    AUTO_PRIM_CIRCULATE_TIME_CD,
    AUTO_PRIM_CIRCULATE_VELOCI_CD,
    AUTO_PRIM_FALL_CD,
    AUTO_PRIM_FEED_DISCHARGE_CD,
    AUTO_PRIM_FEED_VELOCITY1_CD,
    AUTO_PRIM_FEED_VELOCITY2_CD,
    AUTO_PRIM_GROSS_CD,
    AVE_BLOOD_PRESS_LOWER_CD,
    AVE_BLOOD_PRESS_UPPER_CD,
    B_DENSITY_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    B_DENSITY_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    BASIC_INFO_ADDRESS,
    BASIC_INFO_E_MAIL,
    BASIC_INFO_FAX,
    BASIC_INFO_IN_HOSPITAL_STATE,
    BASIC_INFO_IN_OUT_CLASS,
    BASIC_INFO_MEMO1,
    BASIC_INFO_MEMO2,
    BASIC_INFO_NATIONALITY,
    BASIC_INFO_PAT_BIRTHDAY,
    BASIC_INFO_PAT_BLOOD_TYPE_ABO,
    BASIC_INFO_PAT_BLOOD_TYPE_RH,
    BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
    BASIC_INFO_PAT_NAME_ALPHA,
    BASIC_INFO_PAT_NAME_KANA,
    BASIC_INFO_PAT_SEX,
    BASIC_INFO_TEL1,
    BASIC_INFO_TEL2,
    BLOOD_DISCR_END_SELECT_CD,
    BLOOD_FLOW_AMOUNT_CD,
    BLOOD_FLOW_UPPER_CD,
    BLOOD_LOSS_AMOUNT_CD,
    BLOOD_LOSS_METHOD_CD,
    BLOOD_LOSS_SPEED_CD,
    BLOOD_OR_WATER_CHANGE_PRESS_MEASURE_CD,
    BLOOD_PRESS_AUTO_INTERVAL_CD,
    BLOOD_PRESS_CONT_MEASURET_SELECT_CD,
    BLOOD_PRESS_KOTO_SELECT_CD,
    BLOOD_PRESS_MEASURE_AUTO_SELECT_CD,
    BLOOD_PRESS_MEASURE_SELECT_CD,
    BOOST_METHOD_CD,
    BOOST_VALUE_CD,
    BUBBLE_EXTRACT_TIME_AFTER_CD,
    BUBBLE_REMOVAL_OPERAT_SELECT_CD,
    BUBBLE_VELOCITY_CD,
    BUBBLE_VOLUME_CD,
    // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
    SO2_DELTA_NOTIFICATION_POINT_CD,
    // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
    BV__WATER_REMOVE_LOW_DELAY_TIME_CD,
    BV__WATER_REMOVE_LOW_SPEED_CD,
    BV_DELTA_CHANGE_RATE_WARNING_POINT_CD,
    BV_DELTA_WARNING_POINT1_CD,
    BV_DELTA_WARNING_POINT2_CD,
    CHARGESTAFF_INFO_CHARGE_CD,
    CHARGESTAFF_INFO_DOCTORCODE_CD,
    CHARGESTAFF_INFO_NAME_CD,
    CHARGESTAFF_INFO_PUNCTURE_CD,
    CIR_CLEAN_TIME_AFTER_CD,
    CIR_CLEAN_TIME_BEFOR_CD,
    DIA_ENTR_AUTO_SET_MONITOR_WARNING_YN_CD,
    DIALYSATE_AUTO_SET_MONITOR_WARNING_YN_CD,
    DIALYSATE_DENSITY_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    DIALYSATE_DENSITY_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    DIALYSATE_FLOW_SET_MODE_CD,
    DIALYSATE_RATE_CD,
    DIALYSATE_TEMPERATURE_LOWER_CD,
    DIALYSATE_TEMPERATURE_UPPER_CD,
    DIALYSIS_START_BEFORE_CD,
    DIFF_AUTO_SET_MONITOR_WARNING_YN_CD,
    DISEASE_BIOPSY_CONFIR_ALI_CD,
    DISEASE_CLINIC_CD,
    DISEASE_COMMENT_CD,
    DISEASE_CRISIS_DAY_CD,
    DISEASE_DIAGNOS_DAY_CD,
    DISEASE_DIAGNOS_FACILITY_CD,
    DISEASE_DIAGNOSTIC_PHYSICIAN_CD,
    DISEASE_HAVE_PALPATION_CD,
    DISEASE_IS_DIAGNOSED_CD,
    DISEASE_MAIN_CD,
    DISEASE_NAME_CD,
    DISEASE_NOTICE_CD,
    DISEASE_PRIMARY_DISEASES_CD,
    DISEASE_RETURN_CHANGE_DAY_CD,
    DISEASE_RETURNE_CD,
    DP_IV_ADD_RATE_CD,
    ECUM_AMOUNT_CD,
    ECUM_DIA_DIFF_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    ECUM_DIA_DIFF_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    ECUM_DIA_DIFF_FIXED_WARNING_POINT_LOWER_CD,
    ECUM_DIA_DIFF_FIXED_WARNING_POINT_UPPER_CD,
    ECUM_DIA_ENTR_AUTO_SET_WARNING_LIMIT_LOWER_CD,
    ECUM_DIA_ENTR_AUTO_SET_WARNING_LIMIT_UPPER_CD,
    ECUM_DIA_ENTR_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    ECUM_DIA_ENTR_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    ECUM_DIA_ENTR_FIXED_WARNING_POINT_LOWER_CD,
    ECUM_DIA_ENTR_FIXED_WARNING_POINT_UPPER_CD,
    ECUM_HYD_AUTO_SET_WARNING_LIMIT_LOWER_CD,
    ECUM_HYD_AUTO_SET_WARNING_LIMIT_UPPER_CD,
    ECUM_HYD_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    ECUM_HYD_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    ECUM_HYD_FIXED_PRESS_WARNING_POINT_LOWER_CD,
    ECUM_HYD_FIXED_PRESS_WARNING_POINT_UPPER_CD,
    ECUM_SELECT_CD,
    ECUM_TIME_CD,
    ECUM_TIME_COUNT_SELECT_CD,
    ECUM_TMP_AUTO_FOLLOW_WARNING_WIDTH_LOWER_CD,
    ECUM_TMP_AUTO_FOLLOW_WARNING_WIDTH_UPPER_CD,
    ECUM_TMP_AUTO_SET_WARNING_LIMIT_LOWER_CD,
    ECUM_TMP_AUTO_SET_WARNING_LIMIT_UPPER_CD,
    ECUM_TMP_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    ECUM_TMP_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    ECUM_TMP_FIXED_WARNING_POINT_LOWER_CD,
    ECUM_TMP_FIXED_WARNING_POINT_UPPER_CD,
    ECUM_VEN_AUTO_SET_WARNING_LIMIT_LOWER_CD,
    ECUM_VEN_AUTO_SET_WARNING_LIMIT_UPPER_CD,
    ECUM_VEN_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    ECUM_VEN_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    ECUM_VEN_FIXED_WARNING_POINT_LOWER_CD,
    ECUM_VEN_FIXED_WARNING_POINT_UPPER_CD,
    EMERGC_IV_AMOUNT_CD,
    EMERGC_IV_RATE_CD,
    EXAM_CLASS_CD,
    FILTER_RATE_IV_AFTER_CD,
    FILTER_RATE_IV_BEFORE_CD,
    FREEMEMO_CD,
    HEMATOCRIT_HT_VALUE_CD,
    HEMATOCRIT_HT_DATE_CD,
    HF_DIA_DIFF_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    HF_DIA_DIFF_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    HF_DIA_ENTR_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    HF_DIA_ENTR_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    HF_HYD_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    HF_HYD_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    HF_TMP_AUTO_FOLLOW_WARNING_WIDTH_LOWER_CD,
    HF_TMP_AUTO_FOLLOW_WARNING_WIDTH_UPPER_CD,
    HF_TMP_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    HF_TMP_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    HF_VEN_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    HF_VEN_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    HIGH_SPEED_MEASURE_SELECT_CD,
    HOL_BLOOD_CIRCUIT_CLEANING_REPLACE_USE_CD,
    HOL_BLOOD_PUMP_SPEED_CD,
    HOL_BUBBLE_OPERAT_CD,
    HOL_MAX_DELIVERY_LIQUID_TIME_CD,
    HOL_PRESS_ADD_UPPER_CD,
    IMPLANT_CONTENT_CD,
    IMPLANT_REG_DATE_CD,
    IMPLANT_REMOVE_DATE_CD,
    INFECT_DISEASE_CHECK_DATE_CD,
    INFECT_DISEASE_ITEM_CD,
    INFECT_DISEASE_NO_CHECK_DATE_CD,
    INFECT_DISEASE_NO_ITEM_CD,
    INFECT_DISEASE_NO_UPDATE_CD,
    INFECT_DISEASE_RESULT_CD,
    INFECT_DISEASE_UPDATE_CD,
    INFECT_DISEASE_YES_CHECK_DATE_CD,
    INFECT_DISEASE_YES_ITEM_CD,
    INFECT_DISEASE_YES_UPDATE_CD,
    INFECT_DISEASE_YN_CHECK_DATE_CD,
    INFECT_DISEASE_YN_ITEM_CD,
    INFECT_DISEASE_YN_RESULT_CD,
    INFECT_DISEASE_YN_UPDATE_DATE_CD,
    INFECT_TREAT_INFECT_DISEASE_CD,
    INOUT_INFO_CLINIC_CD,
    INOUT_INFO_COMMENT_CD,
    INOUT_INFO_DIVISION_CD,
    INOUT_INFO_DOCTOR_CD,
    INOUT_INFO_END_DATE_CD,
    INOUT_INFO_FACILITY_CD,
    INOUT_INFO_INOUT_CD,
    INOUT_INFO_START_DATE_CD,
    INSU_CONFIRM_DATE_CD,
    INSU_DST_DIAL_DIFF_COMMENT_CD,
    INSU_DST_LOGIN_DATE_CD,
    INSU_DST_MAIN_REASONS_CD,
    INSU_END_DATE_CD,
    INSU_EXPENSE_INSURANCE_MEMO1_CD,
    INSU_EXPENSE_INSURANCE_MEMO2_CD,
    INSU_EXPENSE_NAME_CD,
    INSU_FUTAN_G_CD,
    INSU_FUTAN_N_CD,
    INSU_INSURANCE_MEMO1_CD,
    INSU_INSURANCE_MEMO2_CD,
    INSU_LARGE_PAYER_CD,
    INSU_LONG_HIGH_PRICE_TREAT_CD,
    INSU_NAME_CD,
    INSU_NAME_SHORT_CD,
    INSU_NUMBER_CD,
    INSU_PROVISION_CD,
    INSU_PUBLIC_BURDEN_NUM_CD,
    INSU_PUBLIC_CONFIRM_DATE_CD,
    INSU_PUBLIC_DISABILITY_NO_CD,
    INSU_PUBLIC_END_DATE_CD,
    INSU_PUBLIC_INSURANCE_MEMO1_CD,
    INSU_PUBLIC_INSURANCE_MEMO2_CD,
    INSU_PUBLIC_NAME_CD,
    INSU_PUBLIC_NAME_SHORT_CD,
    INSU_PUBLIC_PUB_NAME_CD,
    INSU_PUBLIC_RECIPIENT_NUM_CD,
    INSU_PUBLIC_START_DATE_CD,
    INSU_SET_INSU_CD,
    INSU_SET_INSURANCE_MEMO1_CD,
    INSU_SET_INSURANCE_MEMO2_CD,
    INSU_SET_NAME_CD,
    INSU_SET_NAME_SHORT_CD,
    INSU_SET_PUBLIC1_CD,
    INSU_SET_PUBLIC2_CD,
    INSU_SET_PUBLIC3_CD,
    INSU_SET_PUBLIC4_CD,
    INSU_START_DATE_CD,
    INSU_UND_SIX_CD,
    INSU_USER_NAME_CD,
    INSURED_NUMBER_CD,
    INSURED_SYMBOL_CD,
    INTERMITTENT_STOP_TIME_CD,
    INTERMITTENT_WORKING_TIME_CD,
    INTRAVENOUS_FILLING_LIQUID_CD,
    INTRAVENOUS_FILLING_OPERAT_SELECT_CD,
    ITEM_NAME_CD,
    IV_RATIO_CD,
    IV_RATIO_USE_SELECT_CD,
    IV_SPEED_UPPER_HDF_AFTER_CD,
    IV_SPEED_UPPER_HDF_BEFOR_CD,
    IV_SPEED_UPPER_HF_AFTER_CD,
    IV_SPEED_UPPER_HF_BEFOR_CD,
    TMP_ZERO_HD_UP,
    TMP_ZERO_HD_DOWN,
    IV_SPEED_UPPER_HD_BEFOR_CD,
    IV_SPEED_UPPER_HD_AFTER_CD,
    IV_SPEED_UPPER_OHDF_AFTER_CD,
    IV_SPEED_UPPER_OHDF_BEFOR_CD,
    IV_SPEED_UPPER_OHF_AFTER_CD,
    IV_SPEED_UPPER_OHF_BEFOR_CD,
    IV_START_DELAY_TIME_CD,
    LAM__WATER_REMOVE_DRAINAGE_SPEED_CD,
    LAM_BLOOD_CIRCUIT_CLEANING_REPLACE_USE_CD,
    LAM_BLOOD_PUMP_SPEED_CD,
    LAM_BUBBLE_OPERAT_CD,
    LAM_MAX_DELIVERY_LIQUID_TIME_CD,
    LAM_PRESS_ADD_UPPER_CD,
    LIQUID_EXCHANGE_CD,
    LOWER_CD,
    MAX_ARTERIAL_RETURN_CD,
    MAX_BLOOD_PRESS_LOWER_CD,
    MAX_BLOOD_PRESS_LOWER_WARNING_BP_SELECT_CD,
    MAX_BLOOD_PRESS_LOWER_WARNING_BP_SPEED_CD,
    MAX_BLOOD_PRESS_LOWER_WARNING_IV_SELECT_CD,
    MAX_BLOOD_PRESS_LOWER_WARNING_IV_SPEED_CD,
    MAX_BLOOD_PRESS_LOWER_WARNING_NA_SELECT_CD,
    MAX_BLOOD_PRESS_LOWER_WARNING_NA_SPEED_CD,
    MAX_BLOOD_PRESS_LOWER_WARNING_WATER_REMOVE_SELECT_CD,
    MAX_BLOOD_PRESS_LOWER_WARNING_WATER_REMOVE_SPEED_CD,
    MAX_BLOOD_PRESS_UPPER_CD,
    MAX_BLOOD_PRESS_UPPER_WARNING_BP_SELECT_CD,
    MAX_BLOOD_PRESS_UPPER_WARNING_BP_SPEED_CD,
    MAX_BLOOD_PRESS_UPPER_WARNING_IV_SELECT_CD,
    MAX_BLOOD_PRESS_UPPER_WARNING_IV_SPEED_CD,
    MAX_BLOOD_PRESS_UPPER_WARNING_NA_SELECT_CD,
    MAX_BLOOD_PRESS_UPPER_WARNING_NA_SPEED_CD,
    MAX_BLOOD_PRESS_UPPER_WARNING_WATER_REMOVE_SELECT_CD,
    MAX_BLOOD_PRESS_UPPER_WARNING_WATER_REMOVE_SPEED_CD,
    MIN_BLOOD_PRESS_LOWER_CD,
    MIN_BLOOD_PRESS_UPPER_CD,
    MONITOR_1_CD,
    MONITOR_2_CD,
    NA_AUTO_SET_MONITOR_WARNING_YN_CD,
    NO_REMOVAL_BLOOD_LOSS_AMOUNT_CD,
    OHDF_IV_SPEED_RATE_AFTER_CD,
    OHDF_IV_SPEED_RATE_BEFORE_CD,
    OHDF_OHF_IV_PRI_CALC_ITEM_CD,
    OHDF_OHF_IV_SETTING_LIMIT_CD,
    PAT_ADDRESS_CD,
    PAT_EMAIL_CD,
    PAT_FAX_CD,
    PAT_FRIGANA_CD,
    PAT_GROUP_NAME_CD,
    PAT_ID_CD,
    PAT_KEY_PERSON_CD,
    PAT_MEMO1_CD,
    PAT_MEMO2_CD,
    PAT_MEMO_INFO_CONTENT1,
    PAT_MEMO_INFO_CONTENT10,
    PAT_MEMO_INFO_CONTENT11,
    PAT_MEMO_INFO_CONTENT12,
    PAT_MEMO_INFO_CONTENT13,
    PAT_MEMO_INFO_CONTENT14,
    PAT_MEMO_INFO_CONTENT15,
    PAT_MEMO_INFO_CONTENT16,
    PAT_MEMO_INFO_CONTENT17,
    PAT_MEMO_INFO_CONTENT18,
    PAT_MEMO_INFO_CONTENT19,
    PAT_MEMO_INFO_CONTENT2,
    PAT_MEMO_INFO_CONTENT20,
    PAT_MEMO_INFO_CONTENT3,
    PAT_MEMO_INFO_CONTENT4,
    PAT_MEMO_INFO_CONTENT5,
    PAT_MEMO_INFO_CONTENT6,
    PAT_MEMO_INFO_CONTENT7,
    PAT_MEMO_INFO_CONTENT8,
    PAT_MEMO_INFO_CONTENT9,
    PAT_MEMO_INFO_TITLE1,
    PAT_MEMO_INFO_TITLE10,
    PAT_MEMO_INFO_TITLE11,
    PAT_MEMO_INFO_TITLE12,
    PAT_MEMO_INFO_TITLE13,
    PAT_MEMO_INFO_TITLE14,
    PAT_MEMO_INFO_TITLE15,
    PAT_MEMO_INFO_TITLE16,
    PAT_MEMO_INFO_TITLE17,
    PAT_MEMO_INFO_TITLE18,
    PAT_MEMO_INFO_TITLE19,
    PAT_MEMO_INFO_TITLE2,
    PAT_MEMO_INFO_TITLE20,
    PAT_MEMO_INFO_TITLE3,
    PAT_MEMO_INFO_TITLE4,
    PAT_MEMO_INFO_TITLE5,
    PAT_MEMO_INFO_TITLE6,
    PAT_MEMO_INFO_TITLE7,
    PAT_MEMO_INFO_TITLE8,
    PAT_MEMO_INFO_TITLE9,
    PAT_NAME_CD,
    PAT_RELATION_CD,
    PAT_TEL1_CD,
    PAT_TEL2_CD,
    PAT_WORK_NAME_CD,
    PAT_WORK_TEL_CD,
    PAT_ZIP_CD,
    PHYSICAL_INFO_BREAST_DIA_CD,
    PHYSICAL_INFO_CHEST_DIA_CD,
    PHYSICAL_INFO_CTR_CD,
    PHYSICAL_INFO_DW_CD,
    PHYSICAL_INFO_DW_TARGET_WEIGHT_CD,
    PHYSICAL_INFO_IND_START_DATE_CD,
    PHYSICAL_INFO_INDICATOR_CD,
    PHYSICAL_INFO_INSPECTION_DATE_TIME_CD,
    PHYSICAL_INFO_INSPECTION_WEIGHT_CD,
    PHYSICAL_INFO_MEASURE_TIMING_CD,
    PHYSICAL_INFO_MEMO_CD,
    PHYSICAL_INFO_STATURE_CD,
    PRE_DIA_ENTR_FIXED_WARNING_POINT_LOWER_CD,
    PRE_DIA_ENTR_FIXED_WARNING_POINT_UPPER_CD,
    PRE_NA_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    PRE_NA_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    PRE_NA_FIXED_WARNING_POINT_LOWER_CD,
    PRE_NA_FIXED_WARNING_POINT_UPPER_CD,
    PRE_VEN_FIXED_WARNING_POINT_LOWER_CD,
    PRE_VEN_FIXED_WARNING_POINT_UPPER_CD,
    PRE_WEIGHT_TOLERANCE_LOWER_LIMIT_CD,
    PREVIOUS_WEIGHT_ALLOWANCE_LIMIT_CD,
    PULSE_COUNT_LOWER_CD,
    PULSE_COUNT_UPPER_CD,
    REC_RATE_NOTIFI_CD,
    REMOVAL_BLOOD_LOSS_AMOUNT_CD,
    RESULT_CD,
    RESULT_DATE_CD,
    RETURN_BLOOD_USE_LIQUID_CD,
    RETURN_BLOOD_VELOCITY_CD,
    SIN_DIA_ENTR_FIXED_WARNING_LOWER_CD,
    SIN_DIA_ENTR_FIXED_WARNING_UPPER_CD,
    SIN_HYD_AUTO_SET_WARNING_LIMIT_LOWER_CD,
    SIN_HYD_AUTO_SET_WARNING_LIMIT_UPPER_CD,
    SIN_HYD_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    SIN_HYD_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    SIN_HYD_FIXED_WARNING_POINT_LOWER_CD,
    SIN_HYD_FIXED_WARNING_POINT_UPPER_CD,
    SIN_TMP_AUTO_FOLLOW_WARNING_WIDTH_LOWER_CD,
    SIN_TMP_AUTO_FOLLOW_WARNING_WIDTH_UPPER_CD,
    SIN_TMP_AUTO_SET_WARNING_LIMIT_LOWER_CD,
    SIN_TMP_AUTO_SET_WARNING_LIMIT_UPPER_CD,
    SIN_TMP_AUTO_SET_WARNING_WIDTH_LOWER_CD,
    SIN_TMP_AUTO_SET_WARNING_WIDTH_UPPER_CD,
    SIN_TMP_FIXED_WARNING_POINT_LOWER_CD,
    SIN_TMP_FIXED_WARNING_POINT_UPPER_CD,
    SIN_VEN_FIXED_WARNING_POINT_LOWER_CD,
    SIN_VEN_FIXED_WARNING_POINT_UPPER_CD,
    SINGLE_NEEDLE_SWITCH_PRESSURE_LOWER_CD,
    SINGLE_NEEDLE_SWITCH_PRESSURE_UPPER_CD,
    SPEED_CHANGE_RATE_DROP_CD,
    SPEED_CHANGE_RATE_RETURN_CD,
    SPEED_RANGE_LOWER_CD,
    SPEED_RANGE_UPPER_CD,
    TABOO_ADJ_MEDICINE_CD,
    TABOO_ALLERGY_CD,
    TABOO_CONTENT_CD,
    TABOO_DETAIL_CD,
    TABOO_DIALYZER_CD,
    TABOO_EQUIPMENT_CD,
    TABOO_FREEWORD_CD,
    TABOO_GENERIC_MEDICINE_CD,
    TABOO_MEDICINE_CD,
    TABOO_REMARK_CD,
    TMP_AUTO_SET_MONITOR_WARNING_YN_CD,
    TMP_MONITOR_MODE_CD,
    TMP_THRESHOLD_SPEED_DROP_CD,
    TMP_THRESHOLD_SPEED_RETURN_CD,
    TMP_ZERO_CORRECT_SELECT_CD,
    TMP_ZERO_CORRECT_WARNING_LOWER_ECUM_CD,
    TMP_ZERO_CORRECT_WARNING_LOWER_HD_CD,
    TMP_ZERO_CORRECT_WARNING_LOWER_HDF_CD,
    TMP_ZERO_CORRECT_WARNING_LOWER_HF_CD,
    TMP_ZERO_CORRECT_WARNING_LOWER_OHF_CD,
    TMP_ZERO_CORRECT_WARNING_LOWER_OHHDF_CD,
    TMP_ZERO_CORRECT_WARNING_UPPER_ECUM_CD,
    TMP_ZERO_CORRECT_WARNING_UPPER_HD_CD,
    TMP_ZERO_CORRECT_WARNING_UPPER_HDF_CD,
    TMP_ZERO_CORRECT_WARNING_UPPER_HF_CD,
    TMP_ZERO_CORRECT_WARNING_UPPER_OHF_CD,
    TMP_ZERO_CORRECT_WARNING_UPPER_OHHDF_CD,
    EMERGC_IV_VALUE_CD,
    EMERGC_IV_DATE_CD,
    TRANSFUSION_DIALYTIC_PRESSURE_CD,
    TREAT_SYN_MEASURE_TIME_CD,
    UNIT_CD,
    UP_DATE_CD,
    UPPER_CD,
    USE_BLOOD_VOLUME_METER_SELECT_CD,
    USE_CHOICE_CD,
    VA_CONFIRM_NOTIFI_VALUE_CD,
    VA_CONFIRM_REFERENCE_VALUE_CD,
    VEIN_PRESS_WARNING_MEASURE_PRESSURE_CD,
    VENDORCONTACT_ADDRESS_CD,
    VENDORCONTACT_COMPANY_NAME_CD,
    VENDORCONTACT_COMPANY_TEL_CD,
    VENDORCONTACT_EMAIL_CD,
    VENDORCONTACT_FAX_CD,
    VENDORCONTACT_MEMO1_CD,
    VENDORCONTACT_MEMO2_CD,
    VENDORCONTACT_WORKER_NAME_CD,
    VENDORCONTACT_WORKER_TEL_CD,
    VENDORCONTACT_ZIP_CD,
    VENOUS_AUTO_SET_MONITOR_WARNING_YN_CD,
    VENOUS_FILLING_VELOCITY_CD,
    VENOUS_MAXIMUM_RETURN_CD,
    VENOUS_PRESS_STATIC_RECORD_AUTO_SELECT_CD,
    VENOUS_RETURN_BLOOD_DISCR_SELECT_CD,
    VENOUS_RETURN_VELOCITY_CD,
    VITAL_1_CD,
    VITAL_2_CD,
    WARNING_SYN_MEASURE_START_TIME_CD,
    WATER_REMOVE_CAL_PRIORIT_SELECTION_CD,
    WATER_REMOVE_CAL_SELECTION_CD,
    WATER_REMOVE_DELAY_TIME_CD_CD,
    WATER_REMOVE_RATE_UPPER_CD,
    INSU_DST_SEVERITY_CD,
    INSU_DST_TRANSPORT_CD,
    INSU_DST_IS_WHEEL_CHAIR,
    MEDICAL_CARE_MAIN_COURSE_CD,
    MEDICAL_CARE_DIALYSIS_COURSE_CD,
    MEDICAL_CARE_WARD_CD,
    MEDICAL_CARE_DIALYSIS_COUNT,
    MEDICAL_CARE_PURIFICATION_COUNT,
    MEDICAL_CARE_DYALYSIS_HST,
    MEDICAL_HST_IS_DIABETES,
    MEDICAL_HST_IS_BLOOD_SUGER_EXAM,
    MEDICAL_HST_DISEASE_CD,
    HOSTNOTICE_BPMAXUPPER,
    HOSTNOTICE_BPMAXLOWER,
    HOSTNOTICE_BPMAXJUDGE,
    HOSTNOTICE_BPMINUPPER,
    HOSTNOTICE_BPMINLOWER,
    HOSTNOTICE_BPMINJUDGE,
    HOSTNOTICE_BPAVEUPPER,
    HOSTNOTICE_BPAVELOWER,
    HOSTNOTICE_BPAVEJUDGE,
    HOSTNOTICE_PULSEUPPER,
    HOSTNOTICE_PULSELOWER,
    HOSTNOTICE_PULSEJUDGE,
    HOSTNOTICE_BLOODFLOWUPPER,
    HOSTNOTICE_BLOODFLOWLOWER,
    HOSTNOTICE_BLOODFLOWJUDGE,
    HOSTNOTICE_IPSPEEDUPPER,
    HOSTNOTICE_IPSPEEDLOWER,
    HOSTNOTICE_IPSPEEDJUDGE,
    HOSTNOTICE_UFRUPPER,
    HOSTNOTICE_UFRLOWER,
    HOSTNOTICE_UFRJUDGE,
    HOSTNOTICE_VPUPPER,
    HOSTNOTICE_VPLOWER,
    HOSTNOTICE_VPJUDGE,
    HOSTNOTICE_APUPPER,
    HOSTNOTICE_APLOWER,
    HOSTNOTICE_APJUDGE,
    HOSTNOTICE_NACONCUPPER,
    HOSTNOTICE_NACONCLOWER,
    HOSTNOTICE_NACONCJUDGE,
    HOSTNOTICE_DIALYSTEMPUPPER,
    HOSTNOTICE_DIALYSTEMPLOWER,
    HOSTNOTICE_DIALYSTEMPJUDGE,
    HOSTNOTICE_DBVROCUPPER,
    HOSTNOTICE_DBVROCLOWER,
    HOSTNOTICE_DBVROCJUDGE,
    HOSTNOTICE_LDQBUPPER,
    HOSTNOTICE_LDQBLOWER,
    HOSTNOTICE_LDQBJUDGE,
    HOSTNOTICE_BPMIINTERVAL,
    HOSTNOTICE_BPMIJUDGE,
    HOSTNOTICE_CAREIINTERVAL,
    HOSTNOTICE_CAREIJUDGE,
    ITEM_DISP_ORDER,
    // add #6523 DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される dou start
    IND_CATEGORY_LIST,
    RST_CATEGORY_LIST,
    // add #6523 DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される dou end
  } from './TemplateConstant';
  import {MASTER_DELETE_DISPLAY} from "@/constants/TreatmentRecord";
  import { dialysisDifficultySelector, severitySelector, transportSelector, wardSelector } from "@/functions/mst/MstGetters";
  import { popoverPreShow, popoverPostShow, popoverPosthide } from "@/functions/common/CommonPopoverFunctions";
  import {deepCopy} from "@/functions/common/CommonFunctions";
  // add #6107 2023/03/10 メッセージボックス全調整 張博 start
  import DIALOG_MESSAGES from "@/components/common/message-dialog/DialogMessages.js";
  import { messageFormat } from '@/functions/common/MessageFormat';
  // add #6107 2023/03/10 メッセージボックス全調整 張博 end
  import { dateFormat } from "@/functions/common/DateTimeUtils";
  import { sortableCompare } from "@/functions/SortFunctions";
  import PrintMixin from "@/components/PrintMixin";
  import KendoGridView from "@/components/kendo-ui/KendoGridView.vue";

  const GRID_PAGE_SIZE = 20;
  const CLASS_EDITED_CELL = 'grid-edited-cell';
  const CLASS_AFTERSENDCONDITION_CELL = "grid-after-send-condition-cell";
  const CLASS_DIALYSIS_CELL = "grid-dialysis-cell";
  const CLASS_AFTERDIALYSIS_CELL = "grid-after-dialysis-cell";

  function omitKey(object, key) {
    const { [key]: _omitted, ...rest } = object;
    return rest;
  }

  function groupByKey(items, keySelector) {
    return items.reduce((groups, item) => {
      const groupKey = keySelector(item);
      if (!groups[groupKey]) {
        groups[groupKey] = [];
      }
      groups[groupKey].push(item);
      return groups;
    }, {});
  }

  function intersectionArrays(left, right) {
    const rightSet = new Set(right);
    return left.filter(item => rightSet.has(item));
  }

export default {
  components: {
    KendoGridView,
  },
  mixins: [IndUserSelectMixin, PopoverMixin, ComponentGuardMixin, PrintMixin],
  data() {
    return {
      // add #6523 DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される dou start
      isOnlyRst: false,
      // add #6523 DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される dou end
      // add #6256 背景色が変わらない 徐博 start
      changeArr: [],
      // add #6256 背景色が変わらない 徐博 end
      //No.7167 upd Paging Optimization runtime by ztc start
      patIdArr: [],
      patIdArrOfSearch: 0,
      offset: 0,
      scrollFlag: true,
      scrollOffsetFlag: true,
      currentScrollTop: 0,
      currentScrollLeft: 0,
      //No.7167 upd Paging Optimization runtime by ztc end
      inOutList: [],
      sameList: [],
      //検査結果
      hasExamRecordAuthority: false,
      //検査依頼
      hasExamRequestAuthority: false,
      //装置設定
      hasDevicesetInfoAuthority: false,
      //患者経過総合ビューア
      hasPatViewerAuthority: false,
      //治療記録
      hasTreatmentRecordAuthority: false,
      // 患者情報
      hasPatInfoAuthority: false,
      //FNSI-修正 【治療予定・治療記録】初期化性能改善 xugj add start
      isDisplay: true,
      detailCdList: [],
      titleList: [],
      titleListCategory: [],
      firstFlg: false,
      imagePatInfo: publicAssetPath("img/pat-info/pat-info.png"),
      imagePatViewer: publicAssetPath("img/pat-viewer/pat-viewer.png"),
      imageTreatmentRecord: publicAssetPath("img/treatment-record/treatment-record.png"),
      imageExamRecord: publicAssetPath("img/exam-record/exam-record.png"),
      imageExamRequest: publicAssetPath("img/exam-request/exam-request.png"),
      imageDevicesetInfo: publicAssetPath("img/deviceset-info/deviceset-info.png"),
      //FNSI-修正 【治療予定・治療記録】初期化性能改善 xugj add end
      idList: [],
      kendoGridColumns: [],
      items: [],
      kendoDataSource: null,
      // 初期患者レコード
      initialPatRecords: null,
      // 更新用患者レコード
      patRecordsForUpdating: [],
      // 編集した患者IDとカラム名の対応 { id: [field, ...] }
      editedPatIdFieldList: {},
      selectedPatId: null,
      isLoading: false,
      isUpdating: false,
      isPopoverVisible: false,
      popoverTarget: null,
      isNoEditDialogVisible: false,
      isCancelEditDialogVisible: false,
      isSomeStaffDialogVisible: false,
      stringParams: null,
      validateObject: {},
      isValidateVisible: false,
      validateStringParams: '',
      isCardDeviceConnected: false,
      socketInterval: null,
      // 指示者
      selectDoctor: null,
      doctorList: [],
      getWriteCardResponse: null,
      linkList: [],
      patInfoList: [],
      columns: [
        {
          field: 'hosp_pat_id',
          title: '患者ID',
          width:'150px',
          locked: true,
          attributes: 'cell-hosppatid hosp-pat-id-body',
        },
        {
          field: 'pat_name',
          title: '患者名',
          width:'150px',
          locked: true,
          attributes: 'cell-patname',
        },
        {
          field: '',
          title: '',
          width: '0px',
          hidden: true,
          locked: false,
        },
      ],
      /* add by chamaojia 2023-05-05 [8610] ヘッダーロードフラグ変数の追加 --start */
      titleLoadingFlag : false,  // ヘッダロードフラグ   true:ロード中
      /* add by chamaojia 2023-04-21 [8610] ヘッダーロードフラグ変数の追加 --end */
      // 列リサイズ前の初期幅を保持（パンくずリフレッシュ時に復元する）
      initialColumnsSnapshot: null,
      initialKendoGridColumnsSnapshot: null,
      currentSort: null,
      gridHeight: 400,
      gridResizeObserver: null,
      scrollQuerySelector: "#multi-pat-list-template .k-virtual-scrollable-wrap",
      addClassTargetQuerySelector: ["#multi-pat-list-template .k-grid table"],
    };
  },
  // add #6256 背景色が変わらない 徐博 start
  props: {
    ordArr: {
      type: Object,
      default: () => ({
        afterSendConditionArr: [],
        dialysisArr: [],
        afterDialysisArr: []
      })
    },
  },
  // add #6256 背景色が変わらない 徐博 end
  computed: {
    ...mapGetters('pat-info', ['searchedPatList']),
    ...mapGetters('user', { facilityCd: 'getFacilityCd' }),
    ...mapGetters('data-list', {
      getRangeDate: 'getRangeDate',
      reqExportExcel: 'getRequestExportExcel',
      reqExportCSV: 'getRequestExportCSV',
      getkendoGridColumn: 'getkendoGridColumn',
      getSelectedDynamicLayout: 'getSelectedDynamicLayout',
      getSelectedLayout: 'getSelectedLayout',
    }),
    ...mapGetters("data-list", { initflg: "getInitflg"}),
    ...mapGetters("account-edit", ["getFontSize"]),
    ...mapGetters("window-size", {
      windowWidth: "getSplittedWidth",
      windowHeight: "getWindowHeight"
    }),

    isSelectedLayout() {
      return this.getSelectedLayout !== null;
    },

    patIdListToDisplay() {
      return this.searchedPatList.map(el => el.pat_id);
    },

    isSameList() {
      return this.searchedPatList
        .filter(el => el.is_same == '1')
        .map(el => el.pat_id);
    },

    isInOutList() {
      return this.searchedPatList
        .filter(el => el.in_out_class == 1)
        .map(el => el.pat_id);
    },

    isEdited() {
      return Object.keys(this.editedPatIdFieldList).length > 0;
    },

    isSearchData() {
      // if (
      //   this.getSelectedDynamicLayout.templateCd == PAT_INFO_TWO_TEMPLATE_CD ||
      //   this.getSelectedDynamicLayout.templateCd == DEVICE_SET
      // ) {
      //   return true;
      // }
      return false;
    },

    /**
     * @description 関係情報変更関数
     */
    changeInfo() {
      return {
        other_contact_info: this.changeInfoToOtherContact,
        other_contact_key_person_info: this.changeInfoToOtherContact,
        charge_staff_info: this.changeInfoToChargeStaffInfo,
        medical_hst_info: this.changeInfoToMedicalHstInfo,
        physical_info: this.changeInfoToPhysicalInfo,
      };
    },

    kendoColumns() {
      const fixedColumns = (this.columns || []).map(col => {
        const kendoCol = {
          field: col.field,
          title: col.title,
          width: col.width,
          locked: col.locked,
          hidden: col.hidden,
        };
        if (col.attributes) {
          kendoCol.attributes = { class: col.attributes };
        }
        return kendoCol;
      });
      return [...fixedColumns, ...(this.kendoGridColumns || [])];
    },

    gridDataSourceOptions() {
      const ds = this.kendoDataSource;
      if (!ds) {
        return {
          data: [],
          serverPaging: false,
          pageSize: GRID_PAGE_SIZE,
        };
      }
      const options = {
        data: ds.data ?? [],
        serverPaging: false,
        pageSize: GRID_PAGE_SIZE,
      };
      if (ds.schema) {
        options.schema = ds.schema;
      }
      if (ds.sort) {
        options.sort = ds.sort;
      }
      return options;
    },

    gridScrollable() {
      return { virtual: "rows, columns" };
    },

    gridSortable() {
      return { compare: this.compareByField };
    },
  },
  watch: {
    // add #6256 背景色が変わらない 徐博 start
    ordArr(val) {
      this.changeArr = val;
    },
    kendoDataSource() {
      this.$nextTick(() => {
        this.findPatInDialysis();
      });
    },
    // add #6256 背景色が変わらない 徐博 end
    /**
     * @description テンプレート切り替え時
     */
    reqExportCSV() {
      this.onCreateTemplateToCSV();
    },
    reqExportExcel() {
      this.onCreateTemplateToExcel();
    },
    windowWidth() {
      this.calculateReportArea();
    },
    windowHeight() {
      this.calculateReportArea();
    },
    getFontSize() {
      this.calculateReportArea();
    },
    patIdListToDisplay() {
      this.isLoading = true;
      // mod #11528 【たくしん会】データリスト並び順不正 房 start
      // if (
      //   this.getSelectedDynamicLayout.templateCd == PAT_INFO_TWO_TEMPLATE_CD ||
      //   this.getSelectedDynamicLayout.templateCd == DEVICE_SET ||
      //   this.getSelectedDynamicLayout.templateCd == INSPECTION_RADIATION ||
      //   this.getSelectedDynamicLayout.templateCd == TREATMENT_PLAN_TREATMENT_RECORD
      // ) {
      //     if (!this.initflg) {
      //       this.getInitData();
      //     }
      // }
      // this.setInitflg(false);
      if (!this.initflg) {
        this.getInitData();
      }
      // mod #11528 【たくしん会】データリスト並び順不正 房 end
    },

    async getSelectedDynamicLayout() {
      if (this.getSelectedDynamicLayout) {
        /* modify by chamaojia 2023-05-05 [8610] ヘッダロードフラグ切り替え --start */
        this.titleLoadingFlag = true;
        await this.getTitle();
        this.titleLoadingFlag = false;
        /* modify by chamaojia 2023-05-05 [8610] ヘッダロードフラグ切り替え --end */
        if (this.isSearchData) {
          // mod FNSI6519-実行ボタンを押下しなくてもデータが読み込まれる 周 start
          //this.getInitData();
          await this.getInitData();
          // mod FNSI6519-実行ボタンを押下しなくてもデータが読み込まれる 周 end
        }
      }
    },
  },

  async created() {
    // mod #6256-背景色が変わらない 徐博 start
    this.changeArr = this.ordArr;
    // mod #6256-背景色が変わらない 徐博 end
    this.setAuthority();
    EventBus.$on("requestReportParams", this.requestrReportParams);
    EventBus.$on('onInitLayout', this.getInitData);
    EventBus.$on('refresh', this.getInitData);
    if (this.getSelectedDynamicLayout) {
      /* modify by chamaojia 2023-05-05 [8610] ヘッダロードフラグ切り替え --start */
      this.titleLoadingFlag = true;
      await this.getTitle();
      this.titleLoadingFlag = false;
      /* modify by chamaojia 2023-05-05 [8610] ヘッダロードフラグ切り替え --end */
      // mod #11528 【たくしん会】データリスト並び順不正 房 start
      await this.getInitData();
      this.setInitflg(false);
      // if (this.isSearchData) {
      //   this.getInitData();
      // }
      // mod #11528 【たくしん会】データリスト並び順不正 房 end
    } else {
      this.columns = [];
    }
  },
  mounted() {
    // Rootページのサイドバーボタン要素のイベントリスナー設定
    const rootSideBarBtn = document.querySelector('#showPatientSearchSidebarBtn');
    rootSideBarBtn?.addEventListener('click', this.setGridHeight);
    this.setupGridHeightObserver();
    this.$nextTick(() => this.updateGridHeight());
  },
  methods: {
    ...mapActions('pat-info', ['selectPat']),
    ...mapActions('websocket-card', [
      'init',
      'connect',
      'sendSocketMessage',
      'close',
      'clearSocketMessage',
    ]),
    ...mapActions('data-list', ['setSelectedLayout']),
    ...mapActions("data-list", [
      "setInitflg"
    ]),
    // 共通ローダー設定
    ...mapActions('loading-screen', ['setLoadingScreenVisible']),
    popoverPreShow,
    popoverPostShow,
    popoverPosthide,

    getGridWidget() {
      return this.$refs.grid?.getWidget?.() ?? null;
    },

    setupGridHeightObserver() {
      const container = this.$refs.gridContainer;
      if (!container || typeof ResizeObserver === "undefined") {
        return;
      }
      this.gridResizeObserver = new ResizeObserver(() => {
        this.updateGridHeight();
      });
      this.gridResizeObserver.observe(container);
    },

    updateGridHeight() {
      const container = this.$refs.gridContainer;
      if (!container) {
        return;
      }
      const height = container.clientHeight;
      if (height > 0 && height !== this.gridHeight) {
        this.gridHeight = height;
        this.$nextTick(() => this.$refs.grid?.resize());
      }
    },

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

      // 共通関数でソート
      return sortableCompare(a, b, this.currentSort.field, true);
    },
    //No.7167 upd Paging Optimization runtime by ztc start
    handleScroll() {
      const scrollable = document.getElementsByClassName("k-auto-scrollable")[1];
      const clientHeight = scrollable.clientHeight
      const scrollTop = scrollable.scrollTop
      const scrollHeight = scrollable.scrollHeight
      if (clientHeight + scrollTop === scrollHeight && this.scrollFlag) {
        let scrollable = document.getElementsByClassName("k-auto-scrollable")[1];
        this.currentScrollTop = scrollable.scrollTop;
        this.currentScrollLeft = scrollable.scrollLeft;
        if (this.getSelectedDynamicLayout.templateCd == PAT_INFO_TWO_TEMPLATE_CD) {
          //this.patIdArrOfSearch += 3;
        } else if (this.getSelectedDynamicLayout.templateCd == TREATMENT_PLAN_TREATMENT_RECORD) {
          //this.offset += 50
        }
        this.getDataSource();
      }
    },
    //No.7167 upd Paging Optimization runtime by ztc end
//add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
    // add #6256 背景色が変わらない 徐博 start
    findPatInDialysis() {
      if (this.kendoDataSource === null || !this.kendoDataSource.data || this.kendoDataSource.data.length === 0) {
        return;
      }
      const grid = this.getGridWidget();
      if (!grid) {
        return;
      }
      // 選択されたテンプレートコードを取得
      const templateCd = this.getSelectedDynamicLayout.templateCd;
      // 配色条件の定義
      const conditions = [
        { arr: this.ordArr.afterDialysisArr, className: CLASS_AFTERDIALYSIS_CELL },
        { arr: this.ordArr.dialysisArr, className: CLASS_DIALYSIS_CELL },
        { arr: this.ordArr.afterSendConditionArr, className: CLASS_AFTERSENDCONDITION_CELL }
      ];
      // 指定されたクラス名を特定の要素に適用する関数
      const applyClassToElements = (row, className, elementClass) => {
        // 行内の各セルをループ
        row.each((_, cell) => {
          // 指定されたクラス名を持つ要素を取得
          const elements = cell.getElementsByClassName(elementClass);
          // 各要素にクラス名を追加
          for (const element of elements) {
            element.classList.add(className);
          }
        });
      };
      // 行データを処理し、条件に基づいてクラスを適用する関数
      const processRow = (gridPat, gridIndex, elementClass) => {
        // 行データからオーダー番号を取得
        const ordNo = Number(gridPat[`$${ORD_NO}$0`] || gridPat.ord_no);
        // 各条件をチェック
        conditions.forEach((condition) => {
          // オーダー番号が条件の配列に含まれているか確認
          if (condition.arr.includes(ordNo)) {
            // 対応する行を取得
            const row = grid.element.find(`tr[data-uid=${grid.dataSource.at(gridIndex)?.uid}]`);
            // 指定されたクラスを要素に適用
            applyClassToElements(row, condition.className, elementClass);
          }
        });
      };
      // レコード数分ループ
      this.kendoDataSource.data.forEach((gridPat, gridIndex) => {
        switch (templateCd) {
          case TREATMENT_PLAN_TREATMENT_RECORD:
          case VITAL_MONITORS_COMPLAINTS_CD:
            processRow(gridPat, gridIndex, "cell-treatdata");
            break;
          case DEVICE_SET:
          case PAT_INFO_TWO_TEMPLATE_CD:
          case INSPECTION_RADIATION:
            processRow(gridPat, gridIndex, "cell-hosppatid");
            break;
        }
      });
    },
    // add #6256 背景色が変わらない 徐博 end
    // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
    getPatIdsbyhospPatIds(){
      var hospPatIds = Array.from(new Set(this.kendoDataSource.data.map(({ hosp_pat_id }) => hosp_pat_id)));
      var patIds = this.searchedPatList.filter(y => hospPatIds.includes(y.hosp_pat_id)).map(({ pat_id }) => pat_id);
      return patIds;
    },
    // add #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
    requestrReportParams(param) {
      // 機能コード判定
      if (param.substring(0, 3) === getCurrentFunctionCd().substring(0, 3)) {
        const param = {
          // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          //patId: this.selectedPatId,
          // del #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
          // patIds: this.searchedPatList.map(({ pat_id }) => pat_id),
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //patIds: this.kendoDataSource.data.map(({ hosp_pat_id }) => hosp_pat_id),
          patIds: this.getPatIdsbyhospPatIds(),
          // mod #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
          // facilityCd: this.getFacilityCd,
          // date:dayjs(this.indStartDate).format('YYYY/MM/DD'),
          // fromDate: dayjs(this.indStartDate).format('YYYY/MM/DD'),
          // toDate: dayjs(this.indEndDate).format('YYYY/MM/DD'),
          facilityCd: this.facilityCd,
          date: dayjs(Date.now()).format("YYYYMMDD"),
          fromDate: dayjs(Date.now()).format("YYYYMMDD"),
          toDate: dayjs(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe start
          //dialysisDate: dayjs(Date.now()).format("YYYYMMDD"),
          // del #11934 機能帳票出力時に検査結果と実績が不整合 limingzhe end
          // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
          functionCd:"00801",
        };
        EventBus.$emit("sendReportParams", param);
      }
    },
//add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
    setAuthority() {
      //患者経過総合ビューア
      this.hasPatViewerAuthority =
        this.hasAuthorityByCd(AUTHORITY_CODES.IND_PEDIT) ||
        this.hasAuthorityByCd(AUTHORITY_CODES.IND_EDIT);
      //治療記録
      this.hasTreatmentRecordAuthority =
        this.hasAuthorityByCd(AUTHORITY_CODES.RST_PEDIT) ||
        this.hasAuthorityByCd(AUTHORITY_CODES.RST_EDIT);
      // 患者情報
      this.hasPatInfoAuthority =
        this.hasAuthorityByCd(AUTHORITY_CODES.PAT_PEDIT) ||
        this.hasAuthorityByCd(AUTHORITY_CODES.PAT_EDIT);
      //検査結果
      this.hasExamRecordAuthority =
        this.hasAuthorityByCd(AUTHORITY_CODES.RST_EXAM_PEDIT) ||
        this.hasAuthorityByCd(AUTHORITY_CODES.RST_EXAM_EDIT);
      //検査依頼
      this.hasExamRequestAuthority =
        this.hasAuthorityByCd(AUTHORITY_CODES.IND_EXAM_PEDIT) ||
        this.hasAuthorityByCd(AUTHORITY_CODES.IND_EXAM_EDIT);
      //装置設定
      this.hasDevicesetInfoAuthority =
        this.hasAuthorityByCd(AUTHORITY_CODES.PAT_DEVSET_PEDIT) ||
        this.hasAuthorityByCd(AUTHORITY_CODES.PAT_DEVSET_EDIT);
    },
    setLink() {
      const templateCd = this.getSelectedDynamicLayout.templateCd;
      switch (templateCd) {
        case INSPECTION_RADIATION:
          this.linkList = [
            {
              key: 'exam-record-detail',
              name: '検査結果',
              disabled: !this.hasExamRecordAuthority,
              imageInfo: this.imageExamRecord
            },
            {
              key: 'exam-request-detail',
              name: '検査依頼',
              disabled: !this.hasExamRequestAuthority,
              imageInfo: this.imageExamRequest
            },
          ];
          break;
        case DEVICE_SET:
          this.linkList = [
            {
              key: 'deviceset-info',
              name: '装置設定',
              disabled: !this.hasDevicesetInfoAuthority,
              imageInfo: this.imageDevicesetInfo
            },
            {
              key: 'pat-viewer',
              name: '患者経過総合ビューア',
              disabled: !this.hasPatViewerAuthority,
              imageInfo: this.imagePatViewer
            },
            {
              key: 'treatment-record',
              name: '治療記録',
              disabled: !this.hasTreatmentRecordAuthority,
              imageInfo: this.imageTreatmentRecord
            },
          ];
          break;
        default:
          this.linkList = [
            {
              key: 'pat-info',
              name: '患者情報',
              disabled: !this.hasPatInfoAuthority,
              imageInfo: this.imagePatInfo
            },
            {
              key: 'pat-viewer',
              name: '患者経過総合ビューア',
              disabled: !this.hasPatViewerAuthority,
              imageInfo: this.imagePatViewer
            },
            {
              key: 'treatment-record',
              name: '治療記録',
              disabled: !this.hasTreatmentRecordAuthority,
              imageInfo: this.imageTreatmentRecord
            },
          ];
          break;
      }
    },
    // getTitle 完了時の列定義をスナップショットとして保存する
    saveInitialGridColumnSnapshot() {
      this.initialColumnsSnapshot = JSON.parse(JSON.stringify(this.columns));
      this.initialKendoGridColumnsSnapshot = JSON.parse(
        JSON.stringify(this.kendoGridColumns)
      );
    },
    // ユーザーによる列リサイズを破棄し、初期列幅に戻す
    restoreInitialGridColumns() {
      if (this.initialColumnsSnapshot) {
        this.columns = JSON.parse(JSON.stringify(this.initialColumnsSnapshot));
      }
      if (this.initialKendoGridColumnsSnapshot) {
        this.kendoGridColumns = JSON.parse(
          JSON.stringify(this.initialKendoGridColumnsSnapshot)
        );
      }
    },
    async getInitData() {
      //No.7167 upd Paging Optimization runtime by ztc start
      //del 9796データリスト画面で患者情報2のデータが表示されない。start
      //window.removeEventListener("scroll", this.handleScroll, true);
      //del 9796データリスト画面で患者情報2のデータが表示されない。end
      if (has(this.getSelectedDynamicLayout,'templateCd') &&
        (this.getSelectedDynamicLayout.templateCd == PAT_INFO_TWO_TEMPLATE_CD || this.getSelectedDynamicLayout.templateCd == TREATMENT_PLAN_TREATMENT_RECORD)) {
        //del 9796データリスト画面で患者情報2のデータが表示されない。start
        //window.addEventListener("scroll", this.handleScroll, true);
        //del 9796データリスト画面で患者情報2のデータが表示されない。end
        this.kendoDataSource = {
          data: [],
          schema: {
            model: {
              fields: {},
            },
          },
        };
      }
      this.offset = 0;
      this.scrollFlag = true;
      this.scrollOffsetFlag = true;
      this.currentScrollTop = 0;
      this.currentScrollLeft = 0;
      this.patIdArr = this.patIdListToDisplay;
      //No.7167 upd Paging Optimization runtime by ztc end
      this.setLink();
      this.restoreInitialGridColumns();
      this.setLoadingScreenVisible(true);
      await this.getDataSource();
      this.setLoadingScreenVisible(false);
      this.$nextTick(() => {
        this.$refs.grid?.refreshColumns(this.kendoColumns);
        this.$refs.grid?.resize();
      });
      setTimeout(() => {
        const sortGrid = this.getGridWidget();
        if (sortGrid != null) {
          this.bindShowPopoverEvent();
          sortGrid.bind('sort', e => {
            this.sortHandler(e);
            this.bindShowPopoverEvent();
            this.$nextTick(() => {
              this.findPatInDialysis();
            });
          });
        }
        this.setSame();
      }, 100);
    },
    calculateReportArea() {
      this.isDisplay = false;
      this.$nextTick(() => {
        this.isDisplay = true;
        this.$nextTick(() => {
          this.updateGridHeight();
        });
      });
    },
    /**
     * kendo-gridのdata-bound時にcallされる関数
     * 一覧部の調整を行う
     */
    kgridDataBound() {
      this.$nextTick(() => {
        this.setSame();
      });
    },

    setSame() {
      if (this.inOutList.length > 0) {
        this.inOutList.forEach(x => {
          let el = $$(`td.cell-patname:contains(${x})`);
          if (el.html()) {
            el.html(el.html().replace('!', ''));
            el.css('color', '#A356A3');
          }
        });
      }

      if (this.sameList.length > 0) {
        if (this.sameList.length > 0) {
          this.sameList = Array.from(new Set(this.sameList));
          let img = `<img class="same-icon" src="${new URL('../../assets/name_duplication.png', import.meta.url).href}"/>`;
          this.sameList.forEach(x => {
            let el = $$(`td.cell-patname:contains(${x})`);
            if (el.html()) {
              el.html(el.html().replace('*', ''));
              el.html(el.html() + img);
            }
          });
        }
      }
    },

    async getTitle() {
      this.setLoadingScreenVisible(true);
      this.columns = [
        {
          field: 'hosp_pat_id',
          title: '患者ID',
          width:'150px',
          locked: true,
          attributes: 'cell-hosppatid hosp-pat-id-body',
        },
        {
          field: 'pat_name',
          title: '患者名',
          width:'150px',
          locked: true,
          attributes: 'cell-patname',
        },
        {
          field: 'datetime',
          title: '日時',
          hidden: true,
          locked: false,
        },
      ];
      const templateCd = this.getSelectedDynamicLayout.templateCd;
      const url = `sysDataListDetail/getByLayoutCd/${this.getSelectedDynamicLayout.patListLayoutCd}`;
      const url2 = `sysDataListDetail/getTitleName/${templateCd}`;
      // add #10077 by zhangruixue 2024-01-03 --start
      const mstAddMonitorRequestParam = {
        facility_cd: this.facilityCd
      }
      const url3 = `mstInfo/mstAddMonitorByFacilityCd`;
      // add #10077 by zhangruixue 2024-01-03 --end
      let [response, response2, response3] = await Promise.all([
        ApiHelper.get(url),
        ApiHelper.get(url2),
        // add #10077 by zhangruixue 2024-01-03 --start
        ApiHelper.get(url3,mstAddMonitorRequestParam),
        // add #10077 by zhangruixue 2024-01-03 --end
      ]).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('TemplateComponent.vue', 'getTitle', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        console.log(error);
      });
      // add #10077 by zhangruixue 2024-01-03 --start
      if(response3){
        response3.data.forEach((item) => {
          item.vital_monitor_item_cd += 10000;
        });
      }
      // add #10077 by zhangruixue 2024-01-03 --end
      let selectedLayout = this.getSelectedDynamicLayout.dispItemInfo;
      // add FNSI6519-実行ボタンを押下しなくてもデータが読み込まれる 周 start
      selectedLayout = selectedLayout.filter(x => x !== null);
      // add FNSI6519-実行ボタンを押下しなくてもデータが読み込まれる 周 end
      this.idList = selectedLayout.filter(
        x =>
          x.data_list_detail_cd == VITAL_1_CD ||
          x.data_list_detail_cd == VITAL_2_CD ||
          x.data_list_detail_cd == MONITOR_1_CD ||
          x.data_list_detail_cd == MONITOR_2_CD
      );
      selectedLayout = selectedLayout.map(x => {
        let data = response.data.filter(
          y => y.dataListDetailCd == x.data_list_detail_cd
        );
        // mod FNSI6519-実行ボタンを押下しなくてもデータが読み込まれる 周 start
        // x.category = data[0].categoryCd;
        // return x;
        if(null !== data && data.length > 0) {
          x.category = data[0].categoryCd;
          return x;
        }
        // mod FNSI6519-実行ボタンを押下しなくてもデータが読み込まれる 周 end
      });
      this.titleListCategory = [];
      // add FNSI-7674 データリストで処理中のままになる 劉全航 start
      selectedLayout = selectedLayout.filter(o=> {return o != undefined});
      // add FNSI-7674 データリストで処理中のままになる 劉全航 end
      let kendoGridColumn = selectedLayout.map(x => {
        if (!this.titleListCategory.includes(x.category)) {
          this.titleListCategory.push(x.category);
        }
        x.key = x.category;
        // mod FNSI6519-実行ボタンを押下しなくてもデータが読み込まれる 周 start
        // let titleName = response2.data.filter(y => y.categoryCd == x.key);
        // x.title = titleName[0].categoryName;
        if(null !== response2 && undefined !== response2.data && null !== response2.data) {
          let titleName = response2.data.filter(y => y.categoryCd == x.key);
          x.title = titleName[0].categoryName;
        }
        // mod FNSI6519-実行ボタンを押下しなくてもデータが読み込まれる 周 end
        x = omitKey(x, 'category');
        x.columns = x.items;
        x = omitKey(x, 'items');
        x.columns = x.columns.map(y => ({ title: y }));
        let data = response.data.filter(
          y => y.dataListDetailCd == x.data_list_detail_cd
        );
        x.columns = x.columns.map(y => {
          //FNSI-修正 【治療予定・治療記録】初期化性能改善 xugj add start
          // 治療予定・治療記録
          // if (templateCd == TREATMENT_PLAN_TREATMENT_RECORD) {
          //   this.detailCdList.push(x.data_list_detail_cd);
          //   this.titleList.push(y.title.toString().replace('-', 'minus'));
          //
          //   // 治療予定・治療記録以外
          // } else {
          //FNSI-修正 【治療予定・治療記録】初期化性能改善 xugj add end
          let title = y.title + "";
          title = title.replace("[", "");
          title = title.replace("]", "");
          //mod 9796 データリスト画面で患者情報2のデータが表示されない。zhao start
          // y.field =
          //   '$' +
          //   x.data_list_detail_cd +
          //   '$' +
          //   /* modify by chamaojia 2023-06-08 [8610] データ中に特殊文字が存在する可能性があるため、エラーを報告し、hash値処理に移行する  --start */
          //   this.getHashCode(title.replace('-', 'minus'));
          /* modify by chamaojia 2023-06-08 [8610] データ中に特殊文字が存在する可能性があるため、エラーを報告し、hash値処理に移行する  --end */
          // }
          if (this.getSelectedDynamicLayout.templateCd == VITAL_MONITORS_COMPLAINTS_CD) {
            y.field =
              '$' +
              x.data_list_detail_cd +
              '$' +
              this.getHashCode(title.replace('-', 'minus'));
          } else {
            y.field =
              '$' +
              x.data_list_detail_cd +
              '$' +
              title.replace('-', 'minus');
          }
          //mod 9796 データリスト画面で患者情報2のデータが表示されない。zhao end
          y.width = '150px';
          return y;
        });
        x.columns = x.columns.map(y => {
          let item = data[0].items.filter(z => z.id == y.title);
          if (item[0]) {
            // バイタル・モニタは列ヘッダーに単位を表示する
            y.title = this.getSelectedDynamicLayout.templateCd === VITAL_MONITORS_COMPLAINTS_CD
              ? `${item[0].name}${item[0].unit != null ? `[${item[0].unit}]` : ""}`
              : item[0].name;
          }
          // add #10077 by zhangruixue 2024-01-03 --start
          if((y.title > 10000) && response3){
            for (let item of response3.data) {
              if(item.vital_monitor_item_cd == y.title){
                y.title = item.vital_monitor_item_name;
                break;
              }
            }
          }
          // add #10077 by zhangruixue 2024-01-03 --end
          return y;
        });
        x = omitKey(x, 'data_list_detail_cd');
        return x;
      });
      kendoGridColumn = groupByKey(kendoGridColumn, x => x.key);
      // add #6523 DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される dou start
      const allCategory = Object.keys(kendoGridColumn);
      // add #6523 DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される dou end
      kendoGridColumn = values(kendoGridColumn);
      let kendoGridColumnTmp = kendoGridColumn.map(x => {
        let m = [];
        x.forEach(y => m.push(y.columns));
        m = m.flat();
        let n = {
          key: x[0].key,
          title: x[0].title,
          columns: m,
        };
        return n;
      });
      if (templateCd === TREATMENT_PLAN_TREATMENT_RECORD) {
        let kendoGridColumns = [];
        this.titleListCategory.forEach(item => {
          kendoGridColumns.push(kendoGridColumnTmp.find(info => info.key === item));
        });
        kendoGridColumn = kendoGridColumns;
        // add #6523 DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される dou start
        if (intersectionArrays(allCategory, IND_CATEGORY_LIST).length == 0
          && intersectionArrays(allCategory, RST_CATEGORY_LIST).length > 0) {
          this.isOnlyRst = true;
          //No.7167 upd Paging Optimization runtime by ztc start
        } else {
          this.isOnlyRst = false;
          //No.7167 upd Paging Optimization runtime by ztc end
        }
        // add #6523 DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される dou end
      } else if (templateCd === DEVICE_SET) {
        let kendoGridColumns = [];
        kendoGridColumnTmp.forEach(item => {
          if (item.key + "" === "159") {
            let itemTmp = {
              key: 1590001,
              title: "ホスト報知 最高血圧",
              columns: []
            };
            let column1 = {
              field: "$1439000001$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            let column2 = {
              field: "$1439000002$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            let column3 = {
              field: "$1439000003$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590002,
              title: "ホスト報知 最低血圧",
              columns: []
            };
            column1 = {
              field: "$1439000004$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000005$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            column3 = {
              field: "$1439000006$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590003,
              title: "ホスト報知 平均血圧",
              columns: []
            };
            column1 = {
              field: "$1439000007$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000008$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            column3 = {
              field: "$1439000009$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590004,
              title: "ホスト報知 脈拍",
              columns: []
            };
            column1 = {
              field: "$1439000010$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000011$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            column3 = {
              field: "$1439000012$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590005,
              title: "ホスト報知 血流量",
              columns: []
            };
            column1 = {
              field: "$1439000013$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000014$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            column3 = {
              field: "$1439000015$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590006,
              title: "ホスト報知 IP速度",
              columns: []
            };
            column1 = {
              field: "$1439000016$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000017$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            column3 = {
              field: "$1439000018$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590007,
              title: "ホスト報知 除水速度",
              columns: []
            };
            column1 = {
              field: "$1439000019$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000020$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            column3 = {
              field: "$1439000021$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590008,
              title: "ホスト報知 静脈圧",
              columns: []
            };
            column1 = {
              field: "$1439000022$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000023$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            column3 = {
              field: "$1439000024$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590009,
              title: "ホスト報知 動脈圧",
              columns: []
            };
            column1 = {
              field: "$1439000025$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000026$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            column3 = {
              field: "$1439000027$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590010,
              title: "ホスト報知 Na濃度",
              columns: []
            };
            column1 = {
              field: "$1439000028$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000029$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            column3 = {
              field: "$1439000030$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590011,
              title: "ホスト報知 透析液温度",
              columns: []
            };
            column1 = {
              field: "$1439000031$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000032$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            column3 = {
              field: "$1439000033$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590012,
              title: "ホスト報知 ΔBV変化率",
              columns: []
            };
            column1 = {
              field: "$1439000034$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000035$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            column3 = {
              field: "$1439000036$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590013,
              title: "ホスト報知 LDQb",
              columns: []
            };
            column1 = {
              field: "$1439000037$0",
              title: "上限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000038$0",
              title: "下限(mmHg)",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            column3 = {
              field: "$1439000039$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column3);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590014,
              title: "ホスト報知 血圧測定間隔",
              columns: []
            };
            column1 = {
              field: "$1439000040$0",
              title: "血圧測定間隔",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000041$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            kendoGridColumns.push(itemTmp);

            itemTmp = {
              key: 1590015,
              title: "ホスト報知 ケア間隔",
              columns: []
            };
            column1 = {
              field: "$1439000042$0",
              title: "ケア間隔",
              width: "150px"
            };
            itemTmp.columns.push(column1);
            column2 = {
              field: "$1439000043$0",
              title: "有効/無効",
              width: "150px"
            };
            itemTmp.columns.push(column2);
            kendoGridColumns.push(itemTmp);
          } else {
            kendoGridColumns.push(item);
          }
        });
        kendoGridColumn = kendoGridColumns;
      } else {
        kendoGridColumn = kendoGridColumnTmp;
      }
      // 固定列のカラム設定（治療予定・治療記録）
      if (templateCd == TREATMENT_PLAN_TREATMENT_RECORD) {
        this.columns = [
          {
            field: 'hosp_pat_id',
            title: '患者ID',
            width:'150px',
            locked: true,
            attributes: 'cell-hosppatid hosp-pat-id-body',
          },
          {
            field: 'pat_name',
            title: '患者名',
            width:'150px',
            locked: true,
            attributes: 'cell-patname',
          },
          {
            field: 'treat_date',
            title: '治療日',
            width:'150px',
            locked: true,
            attributes: 'cell-treatdata',
          },
          {
            field: 'datetime',
            title: '日時',
            hidden: true,
            locked: false,
          },
        ];
      }
      if (templateCd == VITAL_MONITORS_COMPLAINTS_CD) {
        this.columns = [
          {
            field: 'hosp_pat_id',
            title: '患者ID',
            width:'150px',
            locked: true,
            attributes: 'cell-hosppatid hosp-pat-id-body',
          },
          {
            field: 'pat_name',
            title: '患者名',
            width:'150px',
            locked: true,
            attributes: 'cell-patname',
          },
          // mod bug 7578 修正 chen start
          {
            field: 'ind_date',
            title: '治療日',
            width: '150px',
            // hidden: true,
            locked: true,
            attributes: 'cell-treatdata',
          },
          {
            field: 'datetime',
            title: '発生日時',
            width: '150px',
            // hidden: true,
            locked: true,
          },
          // mod bug 7578 修正 chen end
          {
            field: 'ctl_no',
            title: '',
            width: '0px',
            hidden: true,
            locked: false,
          },
        ];
      }
      selectedLayout = selectedLayout.map(x => omitKey(x, 'key'));
      this.kendoGridColumns = kendoGridColumn;
      this.saveInitialGridColumnSnapshot();
      this.setSelectedLayout(selectedLayout);
      this.setLoadingScreenVisible(false);
      this.kendoDataSource = {
        data: [],
        schema: {
          model: {
            fields: {},
          },
        },
      };
      this.$nextTick(() => {
        this.$refs.grid?.refreshColumns(this.kendoColumns);
        this.$refs.grid?.resize();
      });
    },

    /* add by chamaojia 2023-06-08 [8610] hash値を取得する関数の追加  --start */
    getHashCode(str){
      let hash  =   1315423911,i,ch;
      for (i = str.length - 1; i >= 0; i--) {
        ch = str.charCodeAt(i);
        hash ^= ((hash << 5) + ch + (hash >> 2));
      }
      return  (hash & 0x7FFFFFFF);
    },
    /* add by chamaojia 2023-06-08 [8610] hash値を取得する関数の追加  --end */

    async getDataSource() {
      //No.7167 upd Paging Optimization runtime by ztc start
      this.setLoadingScreenVisible(true)
      /* modify by chamaojia 2023-05-05 [8610] ヘッダ・ロードでは、ヘッダ・データのロードが完了していないためにエラーが発生しないように再要求する必要があります --start */
      if (this.titleLoadingFlag) {
        await this.getTitle();
      }
      /* modify by chamaojia 2023-05-05 [8610] ヘッダ・ロードでは、ヘッダ・データのロードが完了していないためにエラーが発生しないように再要求する必要があります --end */
      this.scrollFlag = false
      //No.7167 upd Paging Optimization runtime by ztc end
      //FNSI-修正 【治療予定・治療記録】初期化性能改善 xugj add start
      const templateCd = this.getSelectedDynamicLayout.templateCd;
      // if (templateCd == TREATMENT_PLAN_TREATMENT_RECORD) {
      //   setTimeout(() => {
      //     var index = 0;
      //     const sortGrid = $$('#kendo').data('kendoGrid');
      //     this.kendoGridColumns = this.kendoGridColumns.map(x => {
      //       x.columns = x.columns.map(y => {
      //         y.field =
      //           '$' +
      //           this.detailCdList[index] +
      //           '$' +
      //           this.titleList[index];
      //           index ++;
      //         return y;
      //       });
      //       return x;
      //     })
      //     sortGrid.setOptions({columns: this.kendoGridColumns});
      //   }, 100);
      // }
      //FNSI-修正 【治療予定・治療記録】初期化性能改善 xugj add end
      //No.7167 upd Paging Optimization runtime by ztc start
      let patIdList = this.patIdArr;
      if (templateCd == PAT_INFO_TWO_TEMPLATE_CD) {
        //patIdList = this.patIdArr.slice(this.patIdArrOfSearch, this.patIdArrOfSearch + 3);
      }
      // let patIdList = this.patIdListToDisplay;
      if ((templateCd == TREATMENT_PLAN_TREATMENT_RECORD && !this.scrollOffsetFlag) || !patIdList || patIdList.length == 0) {
        this.setLoadingScreenVisible(false)
        //No.7167 upd Paging Optimization runtime by ztc end
        return;
      }
      let startDate = dayjs().format('YYYY-MM-DD');
      let endDate = dayjs().format('YYYY-MM-DD');
      const patListLayoutCd = this.getSelectedDynamicLayout.patListLayoutCd;
      const rangeDateTmp = this.getRangeDate.find(rangeDate => rangeDate.layoutCd === patListLayoutCd);
      if (rangeDateTmp && rangeDateTmp.dayObj) {
        startDate = dayjs(rangeDateTmp.dayObj.startDate).format(
          'YYYY-MM-DD'
        );
        endDate = dayjs(rangeDateTmp.dayObj.endDate).format(
          'YYYY-MM-DD'
        );
      }
      //FNSI-修正 【治療予定・治療記録】初期化性能改善 xugj add start
      // const templateCd = this.getSelectedDynamicLayout.templateCd;
      //FNSI-修正 【治療予定・治療記録】初期化性能改善 xugj add end
      //No.7167 upd Paging Optimization runtime by ztc start
      // mod #11718 【#11600持ち越し】データリスト画面不正② fang start
      let url = 'sysDataListDetail/getTemplateValueForTreatmentRecord';
      const reqParams = {
        patIdList: patIdList,
        startDate: startDate,
        endDate: endDate,
        templateCd: templateCd
      }
      if (templateCd == TREATMENT_PLAN_TREATMENT_RECORD) {
        // url = `sysDataListDetail/getTemplateValue/${patIdList}/${startDate}/${endDate}/${templateCd}/${this.offset}?isOnlyRst=${this.isOnlyRst}`;
        reqParams['offset'] = this.offset
        reqParams['isOnlyRst'] = this.isOnlyRst
      }
      // let url = `sysDataListDetail/getTemplateValue/${patIdList}/${startDate}/${endDate}/${templateCd}`;
      //No.7167 upd Paging Optimization runtime by ztc end
      /*add FNSI-改修内容5237 任 start*/
      const urlFigure = `sysDataListDetail/getFigureValue/${this.facilityCd}`;
      /*add FNSI-改修内容5237 任 end*/
      let response;
      /*add FNSI-改修内容5237 任 start*/
      let responseFigure;
      /*add FNSI-改修内容5237 任 end*/
      try {
        // response = await ApiHelper.get(url);
        response = await ApiHelper.post(url, reqParams);
        /*add FNSI-改修内容5237 任 start*/
        responseFigure = await ApiHelper.get(urlFigure);
        /*add FNSI-改修内容5237 任 end*/
      } catch (error) {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('TemplateComponent.vue', 'getDataSource', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        console.log(error);
      }
      // mod #11718 【#11600持ち越し】データリスト画面不正② fang end
      // add #11528 【たくしん会】データリスト並び順不正 房 start
      const sortFunc = (a, b) => {
        let aIndex = this.searchedPatList.findIndex(patInfoObj => patInfoObj.pat_id == a.pat_id);
        let bIndex = this.searchedPatList.findIndex(patInfoObj => patInfoObj.pat_id == b.pat_id);
        return aIndex - bIndex;
      };
      if(templateCd === PAT_INFO_TWO_TEMPLATE_CD) {
        if(response.data.templatePatMains) {
          response.data.templatePatMains.sort(sortFunc);
        }
      } else if(templateCd === INSPECTION_RADIATION) {
        if(response.data.templatePatExamMains) {
          response.data.templatePatExamMains.sort(sortFunc);
        }
      } else if(templateCd === DEVICE_SET) {
        if(response.data.patMains) {
          response.data.patMains.sort(sortFunc);
        }
      }
      // add #11528 【たくしん会】データリスト並び順不正 房 end
      //No.7167 upd Paging Optimization runtime by ztc start
      if (templateCd == TREATMENT_PLAN_TREATMENT_RECORD) {
        this.scrollOffsetFlag = !(response.data.ordMains.length < 50);
      }
      //No.7167 upd Paging Optimization runtime by ztc end
      /*mod FNSI-改修内容5237 任 start*/
      let templateValue = await this.getDataList(response.data,responseFigure);
      /*mod FNSI-改修内容5237 任 end*/
      let keyList = [];
      if (
        templateCd == TREATMENT_PLAN_TREATMENT_RECORD ||
        templateCd == INSPECTION_RADIATION
      ) {
        keyList = ['hosp_pat_id', 'pat_name', 'datetime'];
      } else if (templateCd == VITAL_MONITORS_COMPLAINTS_CD) {
        // mod bug 7578 修正 chen start
        // mod #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
        // keyList = ['hosp_pat_id', 'pat_name', 'ind_date', 'datetime', 'ctl_no'];
        keyList = ['hosp_pat_id', 'pat_name', 'ind_date', 'datetime', 'ctl_no', 'row_no'];
        // mod #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
        // mod bug 7578 修正 chen end
      } else {
        keyList = ['hosp_pat_id', 'pat_name'];
      }
      const keyList2 = ['value', 'data_list_detail_cd', 'id'];
      let templateValueList = this.dataGroupingToArray(templateValue, keyList);
      // add #11528 【たくしん会】データリスト並び順不正 房 start
      if (templateCd === TREATMENT_PLAN_TREATMENT_RECORD) {
        if(templateValueList) {
          templateValueList.sort((a, b) => {
            let aHospPatId = a["hosp_pat_idpat_namedatetime"].split("$")[1];
            let bHospPatId = b["hosp_pat_idpat_namedatetime"].split("$")[1];
            let aIndex = this.searchedPatList.findIndex(patInfoObj => patInfoObj.hosp_pat_id == aHospPatId);
            let bIndex = this.searchedPatList.findIndex(patInfoObj => patInfoObj.hosp_pat_id == bHospPatId);
            return aIndex - bIndex;
          });
        }
      } else if (templateCd === INSPECTION_RADIATION) {
        if(templateValueList) {
          templateValueList.sort((a, b) => {
            let aDateTime = a["list"][0]["value"];
            let bDateTime = b["list"][0]["value"];
            let aHospPatId = a["hosp_pat_idpat_namedatetime"].split("$")[1];
            let bHospPatId = b["hosp_pat_idpat_namedatetime"].split("$")[1];
            let aIndex = this.searchedPatList.findIndex(patInfoObj => patInfoObj.hosp_pat_id == aHospPatId);
            let bIndex = this.searchedPatList.findIndex(patInfoObj => patInfoObj.hosp_pat_id == bHospPatId);
            if(aIndex == bIndex) {
              // 検査日時
              return this.parseStrToDate(aDateTime).getTime() - this.parseStrToDate(bDateTime).getTime();
            } else {
              return aIndex - bIndex;
            }
          });
        }
      } else if (templateCd === VITAL_MONITORS_COMPLAINTS_CD) {
        if(templateValueList) {
          /* 日付文字列を比較し、時刻なし（"YYYY-MM-DD"）の方を優先して昇順に並べる */
          function compareDateTime(aDateTime, bDateTime) {
            // 文字列が「日付のみ（YYYY-MM-DD）」形式かどうかを判定
            const isDateOnly = str => /^\d{4}-\d{2}-\d{2}$/.test(str);
            // aDateTime：日付のみ、bDateTime：日時付きの場合、aDateTime を先に
            if (isDateOnly(aDateTime) && !isDateOnly(bDateTime)) return -1;
            // bDateTime：日付のみ、aDateTime：日時付きの場合、bDateTime を先に
            if (!isDateOnly(aDateTime) && isDateOnly(bDateTime)) return 1;
            // 両方とも同じ形式の場合は通常の日時比較を行う
            return new Date(aDateTime) - new Date(bDateTime);
          }
          templateValueList.sort((a, b) => {
            let aDateTime = a["list"][0]["datetime"];
            let bDateTime = b["list"][0]["datetime"];
            let aIndDate = Number(a["list"][0]["ind_date"]);
            let bIndDate = Number(b["list"][0]["ind_date"]);
            let aHospPatId = a["hosp_pat_idpat_nameind_datedatetimectl_norow_no"].split("$")[1];
            let bHospPatId = b["hosp_pat_idpat_nameind_datedatetimectl_norow_no"].split("$")[1];
            let aIndex = this.searchedPatList.findIndex(patInfoObj => patInfoObj.hosp_pat_id == aHospPatId);
            let bIndex = this.searchedPatList.findIndex(patInfoObj => patInfoObj.hosp_pat_id == bHospPatId);
            if(aIndex == bIndex) {
              // 治療日
              if(aIndDate == bIndDate) {
                // 発生日時
                return compareDateTime(aDateTime, bDateTime);
              } else {
                return aIndDate - bIndDate;
              }
            } else {
              return aIndex - bIndex;
            }
          });
        }
      }
      // add #11528 【たくしん会】データリスト並び順不正 房 end
      // add FNSI6516-テンプレート：検査結果の表示順不正 周 start
      // del #11528 【たくしん会】データリスト並び順不正 房 start
      // if(templateCd === INSPECTION_RADIATION) {
      //   templateValueList = this.sortPatInfoList(templateValueList);
      // }
      // del #11528 【たくしん会】データリスト並び順不正 房 end
      // add FNSI6516-テンプレート：検査結果の表示順不正 周 end

      templateValueList = templateValueList.map(x => {
        x.list = x.list.map(y => {
          if (!y.id) {
            y.id = '0';
          }
          return y;
        });
        x.list = this.dataGroupingToArray(x.list, keyList2);
        x.list = x.list.map(y => omitKey(y, 'list'));
        x.list.map(y => {
          let key = values(y);
          let list = key[0].substr(1).split('$');
          let value = list[0];
          list = list.slice(1);
          list = list.join('$');
          list = '$' + list;
          x[list] = value;
        });
        x = omitKey(x, 'list');
        let valueList = [];
        if (
          templateCd == TREATMENT_PLAN_TREATMENT_RECORD ||
          templateCd == INSPECTION_RADIATION
        ) {
          valueList = x.hosp_pat_idpat_namedatetime.substr(1).split('$');
          x.hosp_pat_id = valueList[0];
          x.pat_name = valueList[1];
          // NOTE: スクロール列側で設定していた「治療日(1404)」から固定列用に「治療日」を設定する
          x.treat_date = x[`$1404$0`];
          x.datetime = dayjs(valueList[2]).format('YYYY/MM/DD HH:mm');
          x = omitKey(x, 'hosp_pat_idpat_namedatetime');
        } else if (templateCd == VITAL_MONITORS_COMPLAINTS_CD) {
          // mod bug 7578 修正 chen start
          // mod #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
          // valueList = x.hosp_pat_idpat_nameind_datedatetimectl_no.substr(1).split('$');
          valueList = x.hosp_pat_idpat_nameind_datedatetimectl_norow_no.substr(1).split('$');
          // mod #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
          x.hosp_pat_id = valueList[0];
          x.pat_name = valueList[1];
          x.ind_date = dayjs(valueList[2]).format('YYYY/MM/DD');
          x.datetime = dayjs(valueList[3]).format('YYYY/MM/DD HH:mm');
          x.ctl_no = valueList[4];
          // mod #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
          x.row_no = valueList[5];
          // x = omitKey(x, 'hosp_pat_idpat_nameind_datedatetimectl_no');
          x = omitKey(x, 'hosp_pat_idpat_nameind_datedatetimectl_norow_no');
          // mod #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
          // mod bug 7578 修正 chen end
        } else {
          valueList = x.hosp_pat_idpat_name.substr(1).split('$');
          x.hosp_pat_id = valueList[0];
          x.pat_name = valueList[1];
          x = omitKey(x, 'hosp_pat_idpat_name');
        }
        return x;
      });
      if (templateCd == PAT_INFO_TWO_TEMPLATE_CD) {
        let templateValueListTmp = [];
        let keys = [];
        keys.push("pat_name");
        keys.push("hosp_pat_id");
        keys.push("$0$0");
        this.kendoGridColumns.forEach(title => {
          title.columns.forEach(column => {
            keys.push(column.field);
          });
        });
        templateValueList.forEach(row => {
          let maxIndex = 1;
          for (var key in row) {
            let value = row[key];
            if (value) {
              let values = value.split("(*)");
              row[key] = values;
              let lstval = values[values.length -1];
              if (keys.indexOf(key) !== -1 && maxIndex < values.length && lstval) {
                maxIndex = values.length;
              }
            }
          }

          // 同一レコードの患者ID、患者名設定
          ["hosp_pat_id", "pat_name"].forEach(key => {
            let originalValue = row[key][0];
            row[key] = Array(maxIndex).fill(originalValue);
          });

          for (let i = 0; i < maxIndex; i++) {
            let rowTmp = '[{';
            for (let key in row) {
              if (keys.indexOf(key) !== -1) {
                let value = " ";
                if (row[key][i]) {
                  value = row[key][i];
                }
                rowTmp = rowTmp + '"' + key + '":"' + value + '",';
              }
            }
            rowTmp = rowTmp.substring(0, rowTmp.length - 1);
            rowTmp = rowTmp + '}]'
            rowTmp = JSON.parse(rowTmp.replace(/\n/g, '\\n'));
            templateValueListTmp.push(rowTmp[0]);
          }
        });
        templateValueList = templateValueListTmp;
      }
      if (templateCd == INSPECTION_RADIATION) {
        let templateValueListTmp = [];
        templateValueList.forEach(row => {
          if (row.$1101$0) {
            templateValueListTmp.push(row);
          }
        });
        templateValueList = templateValueListTmp;
      }
      //add bug 6419 修正 zheng start
      const Fields = [];
      if (this.kendoGridColumns.length > 0) {
        this.kendoGridColumns.forEach((field) => {
          field.columns.forEach((f) => {
            Fields.push(f.field);
          });
        });
      }
      var templateList = [];
      let prevHospPatId = "";
      let prevIndDate = "";
      let ordNo = "";
      templateValueList.forEach((row) => {
        //add 9796 データリスト画面で患者情報2のデータが表示されない。zhao start
        if (this.getSelectedDynamicLayout.templateCd == VITAL_MONITORS_COMPLAINTS_CD) {
          //add 9796 データリスト画面で患者情報2のデータが表示されない。zhao end
          /* add by chamaojia 2023-06-08 [8610] データ中に特殊文字が存在する可能性があるため、エラーを報告し、hash値処理に移行する  --start */
          if (row["hosp_pat_id"] != prevHospPatId || row["ind_date"] != prevIndDate) {
            prevHospPatId = row["hosp_pat_id"];
            prevIndDate = row["ind_date"];
            ordNo = "";
          }
          for (const key in row) {
           const pos = key.indexOf('$', 2);
           if (pos >= 0) {
              if (key == "$0$0") {
                ordNo = row[key];
              }
              var keyNew = key.substr(0, pos + 1) + this.getHashCode(key.substr(pos + 1));
              row[keyNew] = row[key]
              delete row[key];
            }
          }

          if (!row.hasOwnProperty("ord_no")) {
            row["ord_no"] = ordNo;
          }
          /* add by chamaojia 2023-06-08 [8610] データ中に特殊文字が存在する可能性があるため、エラーを報告し、hash値処理に移行する  --end */
          //add 9796 データリスト画面で患者情報2のデータが表示されない。zhao start
        }
        //add 9796 データリスト画面で患者情報2のデータが表示されない。zhao end
        let flag1=-1;
        for (var key in row) {
          var  fdStart = key.indexOf('$');
          if(fdStart == 0){
            flag1= Fields.findIndex(item => item=== key);
            if(flag1>=0){
              break;
            }
          }
        }
        if (flag1 >= 0) {
          templateList.push(row);
        }
      });
      templateValueList = templateList;

      // 患者名 ソート用文字列をセット
      const patMap = new Map(this.searchedPatList.map(pat => [pat.hosp_pat_id, pat.pat_name_sort]));
      templateValueList.forEach(templateItem => {
        const patNameSort = patMap.get(templateItem.hosp_pat_id);
        if (patNameSort !== undefined) {
          templateItem.pat_name_sort = patNameSort;
        }
      });

      //add bug 6419 修正 zheng end
      this.kendoDataSource = {
        data: templateValueList,
        schema: {
          model: {
            fields: {},
         },
        },
        sort: this.currentSort ? this.currentSort : null // データリスト側のソート状態を保持
      };
      // add bug 5286 修正 chen start
      this.$nextTick(() => {
        this.updateGridHeight();
        const grid = this.getGridWidget();
        if (grid?.dataSource && this.currentSort) {
          grid.dataSource.sort(this.currentSort);
        }
        //No.7167 upd Paging Optimization runtime by ztc start
        if (has(this.getSelectedDynamicLayout,'templateCd') &&
          (this.getSelectedDynamicLayout.templateCd == PAT_INFO_TWO_TEMPLATE_CD || this.getSelectedDynamicLayout.templateCd == TREATMENT_PLAN_TREATMENT_RECORD)) {
          const scrollable = this.$refs.gridContainer?.querySelector(".k-virtual-scrollable-wrap")
            || document.getElementsByClassName("k-auto-scrollable")[1];
          if (scrollable) {
            scrollable.scrollTop = this.currentScrollTop;
            scrollable.scrollLeft = this.currentScrollLeft;
          }
        }
      });
      this.scrollFlag = true
      this.setLoadingScreenVisible(false)
      //No.7167 upd Paging Optimization runtime by ztc end
      // add bug 5286 修正 chen end
    },
    // add FNSI6516-テンプレート：検査結果の表示順不正 周 start
    sortPatInfoList(templateValueList) {
      if(undefined === templateValueList
        || null === templateValueList
        || templateValueList.length <= 1) {
          return templateValueList;
        }

      let resultList = [];
      let tempList = [];
      let patUnique = '';

      templateValueList.forEach(value => {
        let endPos = value.hosp_pat_idpat_namedatetime.lastIndexOf('$');
        let patIdName = value.hosp_pat_idpat_namedatetime.substr(0, endPos);

        if(patUnique == '') {
          patUnique = patIdName;
          tempList.push(value);
        } else if (patUnique == patIdName) {
          tempList.push(value);
        } else {
          //ソート：検査項目名
          tempList.sort((a, b) => {
            let itemOrdA;
            let itemOrdB;
            for(let idxA = 0; idxA < a.list.length; idxA++) {
              if(ITEM_DISP_ORDER === a.list[idxA].data_list_detail_cd) {
                itemOrdA = a.list[idxA].value;
                break;
              }
            }
            for(let idxB = 0; idxB < b.list.length; idxB++) {
              if(ITEM_DISP_ORDER === b.list[idxB].data_list_detail_cd) {
                itemOrdB = b.list[idxB].value;
                break;
              }
            }
            if(itemOrdA < itemOrdB) {
              return -1;
            } else {
              return 1;
            }
          });

          //ソート：検査区分
          tempList.sort((c, d) => {
            let itemTypeC;
            let itemTypeD;
            for(let idxA = 0; idxA < c.list.length; idxA++) {
              if(EXAM_CLASS_CD === c.list[idxA].data_list_detail_cd) {
                itemTypeC = c.list[idxA].value;
                break;
              }
            }
            for(let idxB = 0; idxB < d.list.length; idxB++) {
              if(EXAM_CLASS_CD === d.list[idxB].data_list_detail_cd) {
                itemTypeD = d.list[idxB].value;
                break;
              }
            }
            if(itemTypeC === itemTypeD) { return 0;}
            if(("透析前" === itemTypeC && "透析後" === itemTypeD)
            || ("透析後" === itemTypeC && "その他" === itemTypeD)
            || ("透析前" === itemTypeC && "その他" === itemTypeD)) {
              return -1;
            } else {
              return 1;
            }
          });

          //ソート：検査日時
          tempList.sort((e, f) => {
            let dateTimeE;
            let dateTimeF;
            for(let idxA = 0; idxA < e.list.length; idxA++) {
              if(RESULT_DATE_CD === e.list[idxA].data_list_detail_cd) {
                dateTimeE = e.list[idxA].value;
                break;
              }
            }
            for(let idxB = 0; idxB < f.list.length; idxB++) {
              if(RESULT_DATE_CD === f.list[idxB].data_list_detail_cd) {
                dateTimeF = f.list[idxB].value;
                break;
              }
            }
            if(dateTimeE < dateTimeF) {
              return -1;
            } else {
              return 1;
            }
          });

          for(const elem of tempList) {
            resultList.push(elem);
          }

          tempList = [];

          patUnique = patIdName;
          tempList.push(value);
        }
      });

      //ソート：検査項目名
      tempList.sort((a, b) => {
        let itemNameA;
        let itemNameB;
        for(let idxA = 0; idxA < a.list.length; idxA++) {
          if(ITEM_DISP_ORDER === a.list[idxA].data_list_detail_cd) {
            itemNameA = a.list[idxA].value;
            break;
          }
        }
        for(let idxB = 0; idxB < b.list.length; idxB++) {
          if(ITEM_DISP_ORDER === b.list[idxB].data_list_detail_cd) {
            itemNameB = b.list[idxB].value;
            break;
          }
        }
        if(itemNameA < itemNameB) {
          return -1;
        } else {
          return 1;
        }
      });

      //ソート：検査区分
      tempList.sort((c, d) => {
        let itemTypeC;
        let itemTypeD;
        for(let idxA = 0; idxA < c.list.length; idxA++) {
          if(EXAM_CLASS_CD === c.list[idxA].data_list_detail_cd) {
            itemTypeC = c.list[idxA].value;
            break;
          }
        }
        for(let idxB = 0; idxB < d.list.length; idxB++) {
          if(EXAM_CLASS_CD === d.list[idxB].data_list_detail_cd) {
            itemTypeD = d.list[idxB].value;
            break;
          }
        }
        if(itemTypeC === itemTypeD) { return 0;}
        if(("透析前" === itemTypeC && "透析後" === itemTypeD)
          || ("透析後" === itemTypeC && "その他" === itemTypeD)
          || ("透析前" === itemTypeC && "その他" === itemTypeD)) {
          return -1;
        } else {
          return 1;
        }
      });

      //ソート：検査日時
      tempList.sort((e, f) => {
        let dateTimeE;
        let dateTimeF;
        for(let idxA = 0; idxA < e.list.length; idxA++) {
          if(RESULT_DATE_CD === e.list[idxA].data_list_detail_cd) {
            dateTimeE = e.list[idxA].value;
            break;
          }
        }
        for(let idxB = 0; idxB < f.list.length; idxB++) {
          if(RESULT_DATE_CD === f.list[idxB].data_list_detail_cd) {
            dateTimeF = f.list[idxB].value;
            break;
          }
        }
        if(dateTimeE < dateTimeF) {
          return -1;
        } else {
          return 1;
        }
      });

      for(const elem of tempList) {
        resultList.push(elem);
      }

      return resultList;
    },
    // add FNSI6516-テンプレート：検査結果の表示順不正 周 end
    /*mod FNSI-改修内容5237 任 start*/
    getDataList(data,responseFigure) {
      switch (this.getSelectedDynamicLayout.templateCd) {
        // 患者情報2
        case PAT_INFO_TWO_TEMPLATE_CD:
          return this.getPatInfoData(data);
        // 治療予定・治療記録
        case TREATMENT_PLAN_TREATMENT_RECORD:
          return getTreatmentPlanData(this, data);
        // バイタル・モニタ・愁訴処置のコード
        case VITAL_MONITORS_COMPLAINTS_CD:
          return getVitalMonitorsData(this, data);
        // 検査・放射線
        case INSPECTION_RADIATION:
          return this.getInspectionData(data,responseFigure);
        /*mod FNSI-改修内容5237 任 end*/
        // 装置設定
        case DEVICE_SET:
          return this.getDeviceSetData(data);
        default:
          break;
      }
    },
    // 患者情報2
    async getPatInfoData(data) {
      let patInfo = data.patInfo;
      let templatePatMains = data.templatePatMains;
      let patPersonalMains = data.patPersonalMains;
      let patInsurances = data.patInsurances;
      // let mstInsurances = data.mstInsurances;
      let mstPersonalUsers = data.mstPersonalUsers;
      let patUniques = data.patUniques;
      // let mstFacilities = data.mstFacilities;
      //add 5222 施設、入外、コメントが表示されない 張 start
      let sysFacilitys = data.sysFacilitys;
      //add 5222 施設、入外、コメントが表示されない 張 end
      let mstDiseases = data.mstDiseases;
      let mstCourses = data.mstCourses;
      // let patGroups = data.patGroups;
      let mstImplants = data.mstImplants;
      let mstTabooAllergies = data.mstTabooAllergies;
      let mstInfections = data.mstInfections;
      let mstAdditions = data.mstAdditions;
      let additionList = data.additionList;
      patInfo = this.setPatInfo(patInfo);
      this.patInfoList = patInfo;
      let complaints = [];
      /*patMains*/
      this.firstFlg = false;
      const [
        mst_severity,
        mst_dialysis_difficulty,
        mstSysCountry,
        mst_transport,
        mst_ward
      ] = await Promise.all([
        severitySelector(this.facilityCd),
        dialysisDifficultySelector(this.facilityCd),
        ApiHelper.get("/mstInfo/sysCountry"),
        transportSelector(this.facilityCd),
        wardSelector(this.facilityCd)
      ]).catch(error => {
        throw new Error(error);
      });
      templatePatMains.forEach(x => {
        let nameList = patInfo.filter(y => y.pat_id == x.pat_id);
        let hosp_pat_id = '';
        let pat_name = '';
        if (nameList.length > 0) {
          hosp_pat_id = nameList[0].hosp_pat_id;
          pat_name = nameList[0].pat_name;
        }
        // NOTE: 治療進捗状態から最新の治療状況のord_noを取得する
        const acceptanceStatusInfo = JSON.parse(x.acceptance_status_info);
        let ord_no = null;
        if (acceptanceStatusInfo.length > 0) {
          // 最新の治療状況を取得する
          const latestEntry = acceptanceStatusInfo.reduce((latest, current) => {
            return new Date(current.start_date_time) > new Date(latest.start_date_time) ? current : latest;
          });
          ord_no = latestEntry.ord_no;
        }
        // NOTE: ord_noが設定されていた場合、配列に追加する
        if (ord_no) {
          complaints = this.setDataAddLine(ORD_NO,
            ord_no,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }

        if (x.is_wheel_chair === "1") {
          complaints = this.setDataAddLine(
            INSU_DST_IS_WHEEL_CHAIR,
            "〇",
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        let in_hospital_state = "";
        switch (x.in_out_current_state + "") {
          case "0":
            in_hospital_state = "在院";
            break;
          case "1":
            in_hospital_state = "導入予定";
            break;
          case "2":
            in_hospital_state = "転入予定";
            break;
          case "3":
            in_hospital_state = "転出";
            break;
          case "7":
            in_hospital_state = "離脱";
            break;
          case "8":
            in_hospital_state = "移植";
            break;
          case "9":
            in_hospital_state = "一時転出";
            break;
          case "10":
            in_hospital_state = "不明";
            break;
          case "11":
            in_hospital_state = "死亡";
            break;
          default:
            in_hospital_state = "不明";
            break;
        }
        complaints = this.setDataAddLine(
          BASIC_INFO_IN_HOSPITAL_STATE,
          in_hospital_state,
          hosp_pat_id,
          pat_name,
          complaints
        );
        if (x.is_diabetes === "1") {
          complaints = this.setDataAddLine(
            MEDICAL_HST_IS_DIABETES,
            "◯",
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        if (x.is_blood_suger_exam === "1") {
          complaints = this.setDataAddLine(
            MEDICAL_HST_IS_BLOOD_SUGER_EXAM,
            "◯",
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        // 患者メモ
        if (x.pat_memo_info) {
          let pat_memo_infos = JSON.parse(x.pat_memo_info);
          let pat_memo_info1 = pat_memo_infos.find(
            info => info.ctl_no === 1
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE1,
            pat_memo_info1.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT1,
            pat_memo_info1.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info2 = pat_memo_infos.find(
            info => info.ctl_no === 2
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE2,
            pat_memo_info2.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT2,
            pat_memo_info2.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info3 = pat_memo_infos.find(
            info => info.ctl_no === 3
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE3,
            pat_memo_info3.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT3,
            pat_memo_info3.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info4 = pat_memo_infos.find(
            info => info.ctl_no === 4
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE4,
            pat_memo_info4.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT4,
            pat_memo_info4.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info5 = pat_memo_infos.find(
            info => info.ctl_no === 5
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE5,
            pat_memo_info5.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT5,
            pat_memo_info5.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info6 = pat_memo_infos.find(
            info => info.ctl_no === 6
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE6,
            pat_memo_info6.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT6,
            pat_memo_info6.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info7 = pat_memo_infos.find(
            info => info.ctl_no === 7
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE7,
            pat_memo_info7.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT7,
            pat_memo_info7.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info8 = pat_memo_infos.find(
            info => info.ctl_no === 8
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE8,
            pat_memo_info8.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT8,
            pat_memo_info8.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info9 = pat_memo_infos.find(
            info => info.ctl_no === 9
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE9,
            pat_memo_info9.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT9,
            pat_memo_info9.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info10 = pat_memo_infos.find(
            info => info.ctl_no === 10
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE10,
            pat_memo_info10.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT10,
            pat_memo_info10.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info11 = pat_memo_infos.find(
            info => info.ctl_no === 11
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE11,
            pat_memo_info11.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT11,
            pat_memo_info11.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info12 = pat_memo_infos.find(
            info => info.ctl_no === 12
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE12,
            pat_memo_info12.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT12,
            pat_memo_info12.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info13 = pat_memo_infos.find(
            info => info.ctl_no === 13
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE13,
            pat_memo_info13.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT13,
            pat_memo_info13.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info14 = pat_memo_infos.find(
            info => info.ctl_no === 14
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE14,
            pat_memo_info14.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT14,
            pat_memo_info14.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info15 = pat_memo_infos.find(
            info => info.ctl_no === 15
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE15,
            pat_memo_info15.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT15,
            pat_memo_info15.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info16 = pat_memo_infos.find(
            info => info.ctl_no === 16
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE16,
            pat_memo_info16.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT16,
            pat_memo_info16.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info17 = pat_memo_infos.find(
            info => info.ctl_no === 17
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE17,
            pat_memo_info17.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT17,
            pat_memo_info17.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info18 = pat_memo_infos.find(
            info => info.ctl_no === 18
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE18,
            pat_memo_info18.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT18,
            pat_memo_info18.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info19 = pat_memo_infos.find(
            info => info.ctl_no === 19
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE19,
            pat_memo_info19.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT19,
            pat_memo_info19.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
          let pat_memo_info20 = pat_memo_infos.find(
            info => info.ctl_no === 20
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_TITLE20,
            pat_memo_info20.title,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO_INFO_CONTENT20,
            pat_memo_info20.content,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }

        // 診療情報
        if (x.medical_care_info) {
          let main_course = "";
          let dialysis_course = "";
          let care_ward = "";
          let dialysis_count = "";
          let purification_count = "";
          let dyalysis_hst = "";
          let y = JSON.parse(x.medical_care_info);
          let dialHstYear = dayjs().diff(y.dialysis_start_date, "years");
          let dialHstMonth = dayjs().diff(y.dialysis_start_date, "months") % 12;
          let dialHst = `${!dialHstYear ? 0 : dialHstYear}年 ${!dialHstMonth ? 0 : dialHstMonth}ヶ月`;
          //mod 9796 pat_mainで保存された旧データの中で、ward_cd、main_course_cd、dialysis_course_cdが文字型である場合あるので、ここの処理を調整。 ljx start
          //let course = mstCourses.find(item => item.courseCd === y.main_course_cd && item.facilityCd === x.facility_cd);
          let course = mstCourses.find(item => item.courseCd == y.main_course_cd && item.facilityCd === x.facility_cd);
          if (course) {
            main_course = course.courseName;
          }
          //let dialysisCourse = mstCourses.find(item => item.courseCd === y.dialysis_course_cd && item.facilityCd === x.facility_cd);
          let dialysisCourse = mstCourses.find(item => item.courseCd == y.dialysis_course_cd && item.facilityCd === x.facility_cd);
          if (dialysisCourse) {
            dialysis_course = dialysisCourse.courseName;
          }
          //let ward = mst_ward.find(item => item.code === y.ward_cd);
          let ward = mst_ward.find(item => item.code == y.ward_cd);
          // mod 9796 ljx end
          if (ward) {
            care_ward = ward.name;
          }
          dialysis_count = y.dialysis_count;
          purification_count = y.purification_count;
          dyalysis_hst = dialHst;
          complaints = this.setDataAddLine(
            MEDICAL_CARE_MAIN_COURSE_CD,
            main_course,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            MEDICAL_CARE_DIALYSIS_COURSE_CD,
            dialysis_course,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            MEDICAL_CARE_WARD_CD,
            care_ward,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            MEDICAL_CARE_DIALYSIS_COUNT,
            dialysis_count,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            MEDICAL_CARE_PURIFICATION_COUNT,
            purification_count,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            MEDICAL_CARE_DYALYSIS_HST,
            dyalysis_hst,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }

        // 担当者
        if (x.charge_staff_info) {
          let charge_staff_info = JSON.parse(x.charge_staff_info);
          //担当者_担当者名
          let chargestaffInfoName = '';
          let chargestaffInfoDoctorcode = '';
          let chargestaffInfoCharge = '';
          let chargestaffInfoPuncture = '';
          charge_staff_info.forEach(y => {
            let users = mstPersonalUsers.filter(z => z.userId == y.staff_cd);
            if (users.length > 0) {
              //担当者_担当者名
              chargestaffInfoName = this.addLinePatInfoTwo(
                chargestaffInfoName,
                this.addBlank(users[0].userLastName, users[0].userFirstName)
              );
            } else {
              chargestaffInfoName = this.addLinePatInfoTwo(chargestaffInfoName, ' ');
            }
            //担当者_主治医
            if (y.is_main == '1') {
              chargestaffInfoDoctorcode = this.addLinePatInfoTwo(
                chargestaffInfoDoctorcode,
                '〇'
              );
            } else {
              chargestaffInfoDoctorcode = this.addLinePatInfoTwo(
                chargestaffInfoDoctorcode,
                ' '
              );
            }
            //担当者_担当
            if (y.is_charge == '1') {
              chargestaffInfoCharge = this.addLinePatInfoTwo(chargestaffInfoCharge, '〇');
            } else {
              chargestaffInfoCharge = this.addLinePatInfoTwo(chargestaffInfoCharge, ' ');
            }
            //担当者_穿刺
            if (y.is_puncture == '1') {
              chargestaffInfoPuncture = this.addLinePatInfoTwo(
                chargestaffInfoPuncture,
                '〇'
              );
            } else {
              chargestaffInfoPuncture = this.addLinePatInfoTwo(
                chargestaffInfoPuncture,
                ' '
              );
            }
          });
          //担当者_担当者名
          complaints = this.setDataAddLine(
            CHARGESTAFF_INFO_NAME_CD,
            chargestaffInfoName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            CHARGESTAFF_INFO_DOCTORCODE_CD,
            chargestaffInfoDoctorcode,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            CHARGESTAFF_INFO_CHARGE_CD,
            chargestaffInfoCharge,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            CHARGESTAFF_INFO_PUNCTURE_CD,
            chargestaffInfoPuncture,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }

        // 禁忌
        if (x.taboo_allergy_info) {
          let taboo_allergy_info = JSON.parse(x.taboo_allergy_info);
          let tabooAllergy = '';
          let tabooContent = '';
          let tabooRemark = '';
          let tabooMedicine = '';
          let tabooAdjMedicine = '';
          let tabooEquipment = '';
          let tabooDialyzer = '';
          let tabooFreeword = '';
          let tabooGenericMedicine = '';
          let tabooDetail = '';
          taboo_allergy_info.forEach(y => {
            //禁忌_禁忌・アレルギー
            if (y.taboo_allergy_class == '1') {
              tabooAllergy = this.addLinePatInfoTwo(tabooAllergy, '禁忌');
            } else if (y.taboo_allergy_class == '2') {
              tabooAllergy = this.addLinePatInfoTwo(tabooAllergy, 'アレルギー');
            } else {
              tabooAllergy = this.addLinePatInfoTwo(tabooAllergy, ' ');
            }
            //禁忌_内容
            tabooContent = this.addLinePatInfoTwo(tabooContent, y.content);
            //禁忌_備考
            tabooRemark = this.addLinePatInfoTwo(tabooRemark, y.memo);
            /** modify 9987 by kangjie 20240513 start
             * if patMain table taboo_allergy_info json fields
             * -> category_class fields equal '0'  blongs to local system data
             * else bolongs to other system import data
             * */
            // local system data
            if (y.category_class == '0') {
              let tabooAllergies = mstTabooAllergies.filter(
                z => z.tabooAllergyCd == y.taboo_allergy_cd
              );
              if (tabooAllergies.length > 0) {
                //add 9796データリスト画面で患者情報2のデータが表示されない。zhao start
                if(tabooAllergies[0].detailInfo){
                  //add 9796データリスト画面で患者情報2のデータが表示されない。zhao end
                  let detail_info = JSON.parse(tabooAllergies[0].detailInfo);
                  if (detail_info.length > 0) {
                    let info1 = '';
                    // add 9987 by kangjie 20231223 start
                    let info2 = '';
                    // add 9987 by kangjie 20231223 end
                    let info3 = '';
                    let info4 = '';
                    let info5 = '';
                    let info6 = '';
                    let nameTmp = '';
                    let target = null;
                    let targetDel = null;
                    detail_info.forEach(m => {
                      switch (m.classCd + "") {
                        case "1":
                          target = data.mstMedicine.find(el => el.medicineCd === m.cd);
                          if (!target) {
                            if (data.mstMedicineDel) {
                              targetDel = data.mstMedicineDel.find(el => el.medicineCd === m.cd);
                              if (!targetDel || !targetDel.medicineName) {
                                nameTmp = "";
                              } else {
                                nameTmp = MASTER_DELETE_DISPLAY.DELETED + targetDel.medicineName;
                              }
                            } else {
                              nameTmp = "";
                            }
                          } else {
                            nameTmp = target.medicineName;
                          }
                          //禁忌_薬剤
                          // tabooMedicine = this.addLine(tabooMedicine, nameTmp);
                          if (nameTmp) {
                            info1 += nameTmp;
                            info1 += '、';
                          }
                          break;
                        // add 9987 by kangjie 20231223 start
                        case "2":
                          target = data.mstMedicineMixes.find(el => el.medicineMixCd === m.cd);
                          //   //禁忌_調整薬剤
                          //   tabooAdjMedicine = this.addLine(tabooAdjMedicine, m.name);
                          if (!target) {
                            if (data.mstMedicineMixesDel) {
                              targetDel = data.mstMedicineMixesDel.find(el => el.medicineMixCd === m.cd);
                              if (!targetDel || !targetDel.medicineMixName) {
                                nameTmp = "";
                              } else {
                                nameTmp = MASTER_DELETE_DISPLAY.DELETED + targetDel.medicineMixName;
                              }
                            } else {
                              nameTmp = "";
                            }
                          } else {
                            nameTmp = target.medicineMixName;
                          }
                          if (nameTmp) {
                            info2 += nameTmp;
                            info2 += '、';
                          }
                          break;
                        // add 9987 by kangjie 20231223 end
                        case "3":
                          target = data.mstEquipment.find(el => el.equipmentCd === m.cd);
                          if (!target) {
                            if (data.mstMedicineDel) {
                              targetDel = data.mstEquipmentDel.find(el => el.equipmentCd === m.cd);
                              if (!targetDel || !targetDel.equipmentName) {
                                nameTmp = "";
                              } else {
                                nameTmp = MASTER_DELETE_DISPLAY.DELETED + targetDel.equipmentName;
                              }
                            } else {
                              nameTmp = "";
                            }
                          } else {
                            nameTmp = target.equipmentName;
                          }
                          //禁忌_医療材料
                          // tabooEquipment = this.addLine(tabooEquipment, nameTmp);
                          if (nameTmp) {
                            info3 += nameTmp;
                            info3 += '、';
                          }
                          break;
                        case "4":
                          target = data.mstDialyzer.find(el => el.dialyzerCd === m.cd);
                          if (!target) {
                            if (data.mstMedicineDel) {
                              targetDel = data.mstDialyzerDel.find(el => el.dialyzerCd === m.cd);
                              if (!targetDel || !targetDel.modelNumber) {
                                nameTmp = "";
                              } else {
                                nameTmp = MASTER_DELETE_DISPLAY.DELETED + targetDel.modelNumber;
                              }
                            } else {
                              nameTmp = "";
                            }
                          } else {
                            nameTmp = target.modelNumber;
                          }
                          //禁忌_ダイアライザ
                          // tabooDialyzer = this.addLine(tabooDialyzer, nameTmp);
                          if (nameTmp) {
                            info4 += nameTmp;
                            info4 += '、';
                          }
                          break;
                        case "5":
                          //禁忌_フリーワード
                          // tabooFreeword = this.addLine(tabooFreeword, m.name);
                          if (m.name) {
                            info5 += m.name;
                            info5 += '、';
                          }
                          break;
                        case "6":
                          //禁忌_一般名処方
                          // tabooGenericMedicine = this.addLine(
                          //   tabooGenericMedicine,
                          //   m.name
                          // );

                          // modify 9987 by kangjie 20240523 start
                          // if (m.name) {
                          //   info6 += m.name;
                          //   info6 += '、';
                          // }
                          target = data.sysGenericMedicinesIncludeDel.filter(item => item.isDel == '0' && item.isDisp == '1');
                          target = target.find(item => item.genericCd == m.cd);
                          if (!target) {
                            targetDel = data.sysGenericMedicinesIncludeDel.filter(item => item.isDel == '1' && item.isDisp == '0');
                            if (targetDel) {
                              targetDel = targetDel.find(el => el.genericCd == m.cd);
                              if (!targetDel || !targetDel.genericName) {
                                nameTmp = "";
                              } else {
                                nameTmp = MASTER_DELETE_DISPLAY.DELETED + targetDel.genericName;
                              }
                            } else {
                              nameTmp = "";
                            }

                          } else {
                            nameTmp = target.genericName;
                          }
                          if (nameTmp) {
                            info6 += nameTmp;
                            info6 += '、';
                          }
                          // modify 9987 by kangjie 20240523 end
                          break;
                        default:
                          break;
                      }
                    });
                    //禁忌_詳細
                    if (info1 == '') {
                      info1 = 'なし';
                    } else {
                      info1 = info1.substring(0, info1.length - 1);
                    }
                    // add 9987 by kangjie 20231223 start
                    if (info2 == '') {
                      info2 = 'なし';
                    } else {
                      info2 = info2.substring(0, info2.length - 1);
                    }
                    // add 9987 by kangjie 20231223 end
                    if (info3 == '') {
                      info3 = 'なし';
                    } else {
                      info3 = info3.substring(0, info3.length - 1);
                    }
                    if (info4 == '') {
                      info4 = 'なし';
                    } else {
                      info4 = info4.substring(0, info4.length - 1);
                    }
                    if (info5 == '') {
                      info5 = 'なし';
                    } else {
                      info5 = info5.substring(0, info5.length - 1);
                    }
                    if (info6 == '') {
                      info6 = 'なし';
                    } else {
                      info6 = info6.substring(0, info6.length - 1);
                    }
                    let info = '';

                    if (info2 === 'なし') {
                      info = '【薬剤】 ' +
                        info1 +
                        // add 9987 by kangjie 20231223 start
                        // '\n【調整薬剤】 ' +
                        // info2 +
                        // add 9987 by kangjie 20231223 end
                        '\\n【医療材料】 ' +
                        info3 +
                        '\\n【ダイアライザ】 ' +
                        info4 +
                        '\\n【フリーワード】 ' +
                        info5 +
                        '\\n【一般名処方】 ' +
                        info6;
                    } else {
                      info = '【薬剤】 ' +
                        info1 +
                        // add 9987 by kangjie 20231223 start
                        '\n【調整薬剤】 ' +
                        info2 +
                        // add 9987 by kangjie 20231223 end
                        '\\n【医療材料】 ' +
                        info3 +
                        '\\n【ダイアライザ】 ' +
                        info4 +
                        '\\n【フリーワード】 ' +
                        info5 +
                        '\\n【一般名処方】 ' +
                        info6;
                    }
                    tabooDetail = this.addLinePatInfoTwo(tabooDetail, info);
                    tabooMedicine = this.addLinePatInfoTwo(tabooMedicine, info1);
                    // add 9987 by kangjie 20231225 start show tabooAdjMedicine col
                    tabooAdjMedicine = this.addLinePatInfoTwo(tabooAdjMedicine, info2);
                    // add 9987 by kangjie 20231225 end
                    tabooEquipment = this.addLinePatInfoTwo(tabooEquipment, info3);
                    tabooDialyzer = this.addLinePatInfoTwo(tabooDialyzer, info4);
                    tabooFreeword = this.addLinePatInfoTwo(tabooFreeword, info5);
                    tabooGenericMedicine = this.addLinePatInfoTwo(tabooGenericMedicine, info6);
                  }
                  //add 9796データリスト画面で患者情報2のデータが表示されない。zhao start
                }
                //add 9796データリスト画面で患者情報2のデータが表示されない。zhao end
                //add 9796 ljx start
              }else{//禁忌アレルギーの中で、手入力の場合も一行としてcomplaintsにpushする必要がある。
                let info1 = 'なし';
                // add 9987 by kangjie 20240122 start
                let info2 = 'なし';
                // add 9987 by kangjie 20240122 end
                let info3 = 'なし';
                let info4 = 'なし';
                let info5 = y.content;
                let info6 = 'なし';
                let info =
                  '【薬剤】 ' +
                  info1 +
                  '\\n【医療材料】 ' +
                  info3 +
                  '\\n【ダイアライザ】 ' +
                  info4 +
                  '\\n【フリーワード】 ' +
                  info5 +
                  '\\n【一般名処方】 ' +
                  info6;
                tabooDetail = this.addLinePatInfoTwo(tabooDetail, info);
                tabooMedicine = this.addLinePatInfoTwo(tabooMedicine, info1);
                // add 9987 by kangjie 20240122 start
                tabooAdjMedicine = this.addLinePatInfoTwo(tabooAdjMedicine, info2);
                // add 9987 by kangjie 20240122 end
                tabooEquipment = this.addLinePatInfoTwo(tabooEquipment, info3);
                tabooDialyzer = this.addLinePatInfoTwo(tabooDialyzer, info4);
                tabooFreeword = this.addLinePatInfoTwo(tabooFreeword, info5);
                tabooGenericMedicine = this.addLinePatInfoTwo(tabooGenericMedicine, info6);
                //add 9796 ljx end
              }
            } else {
              // other system import data
              let info1 = '';
              let info2 = '';
              let info3 = '';
              let info4 = '';
              let info5 = '';
              let info6 = '';
              let nameTmp = '';
              let target = null;
              let targetDel = null;
              switch (y.category_class + "") {
                case "1":
                  target = data.mstMedicine.find(el => el.medicineCd == y.taboo_allergy_cd);
                  if (!target) {
                    if (data.mstMedicineDel) {
                      targetDel = data.mstMedicineDel.find(el => el.medicineCd == y.taboo_allergy_cd);
                      if (!targetDel || !targetDel.medicineName) {
                        nameTmp = "";
                      } else {
                        nameTmp = MASTER_DELETE_DISPLAY.DELETED + targetDel.medicineName;
                      }
                    } else {
                      nameTmp = "";
                    }
                  } else {
                    nameTmp = target.medicineName;
                  }
                  //禁忌_薬剤
                  // tabooMedicine = this.addLine(tabooMedicine, nameTmp);
                  if (nameTmp) {
                    info1 += nameTmp;
                    info1 += '、';
                  }
                  break;
                // add 9987 by kangjie 20231223 start
                case "2":
                  target = data.mstMedicineMixes.find(el => el.medicineMixCd == y.taboo_allergy_cd);
                  //   //禁忌_調整薬剤
                  //   tabooAdjMedicine = this.addLine(tabooAdjMedicine, m.name);
                  if (!target) {
                    if (data.mstMedicineMixesDel) {
                      targetDel = data.mstMedicineMixesDel.find(el => el.medicineMixCd == y.taboo_allergy_cd);
                      if (!targetDel || !targetDel.medicineMixName) {
                        nameTmp = "";
                      } else {
                        nameTmp = MASTER_DELETE_DISPLAY.DELETED + targetDel.medicineMixName;
                      }
                    } else {
                      nameTmp = "";
                    }
                  } else {
                    nameTmp = target.medicineMixName;
                  }
                  if (nameTmp) {
                    info2 += nameTmp;
                    info2 += '、';
                  }
                  break;
                // add 9987 by kangjie 20231223 end
                case "3":
                  target = data.mstEquipment.find(el => el.equipmentCd == y.taboo_allergy_cd);
                  if (!target) {
                    if (data.mstMedicineDel) {
                      targetDel = data.mstEquipmentDel.find(el => el.equipmentCd == y.taboo_allergy_cd);
                      if (!targetDel || !targetDel.equipmentName) {
                        nameTmp = "";
                      } else {
                        nameTmp = MASTER_DELETE_DISPLAY.DELETED + targetDel.equipmentName;
                      }
                    } else {
                      nameTmp = "";
                    }
                  } else {
                    nameTmp = target.equipmentName;
                  }
                  //禁忌_医療材料
                  // tabooEquipment = this.addLine(tabooEquipment, nameTmp);
                  if (nameTmp) {
                    info3 += nameTmp;
                    info3 += '、';
                  }
                  break;
                case "4":
                  target = data.mstDialyzer.find(el => el.dialyzerCd == y.taboo_allergy_cd);
                  if (!target) {
                    if (data.mstMedicineDel) {
                      targetDel = data.mstDialyzerDel.find(el => el.dialyzerCd == y.taboo_allergy_cd);
                      if (!targetDel || !targetDel.modelNumber) {
                        nameTmp = "";
                      } else {
                        nameTmp = MASTER_DELETE_DISPLAY.DELETED + targetDel.modelNumber;
                      }
                    } else {
                      nameTmp = "";
                    }
                  } else {
                    nameTmp = target.modelNumber;
                  }
                  //禁忌_ダイアライザ
                  // tabooDialyzer = this.addLine(tabooDialyzer, nameTmp);
                  if (nameTmp) {
                    info4 += nameTmp;
                    info4 += '、';
                  }
                  break;
                case "5":
                  //禁忌_フリーワード
                  // tabooFreeword = this.addLine(tabooFreeword, m.name);
                  if (y.content) {
                    info5 += y.content;
                    info5 += '、';
                  }
                  break;
                case "6":
                  //禁忌_一般名処方
                  // tabooGenericMedicine = this.addLine(
                  //   tabooGenericMedicine,
                  //   m.name
                  // );

                  // modify 9987 by kangjie 20240523 start
                  // if (y.content) {
                  //   info6 += y.content;
                  //   info6 += '、';
                  // }
                  target = data.sysGenericMedicinesIncludeDel.filter(item => item.isDel == '0' && item.isDisp == '1');
                  target = target.find(item => item.genericCd == y.taboo_allergy_cd);
                  if (!target) {
                    targetDel = data.sysGenericMedicinesIncludeDel.filter(item => item.isDel == '1' && item.isDisp == '0');
                    if (targetDel) {
                      targetDel = targetDel.find(el => el.genericCd == y.taboo_allergy_cd);
                      if (!targetDel || !targetDel.genericName) {
                        nameTmp = "";
                      } else {
                        nameTmp = MASTER_DELETE_DISPLAY.DELETED + targetDel.genericName;
                      }
                    } else {
                      nameTmp = "";
                    }

                  } else {
                    nameTmp = target.genericName;
                  }
                  if (nameTmp) {
                    info6 += nameTmp;
                    info6 += '、';
                  }
                  // modify 9987 by kangjie 20240523 end
                  break;
                default:
                  break;
              }

              //禁忌_詳細
              if (info1 == '') {
                info1 = 'なし';
              } else {
                info1 = info1.substring(0, info1.length - 1);
              }
              // add 9987 by kangjie 20231223 start
              if (info2 == '') {
                info2 = 'なし';
              } else {
                info2 = info2.substring(0, info2.length - 1);
              }
              // add 9987 by kangjie 20231223 end
              if (info3 == '') {
                info3 = 'なし';
              } else {
                info3 = info3.substring(0, info3.length - 1);
              }
              if (info4 == '') {
                info4 = 'なし';
              } else {
                info4 = info4.substring(0, info4.length - 1);
              }
              if (info5 == '') {
                info5 = 'なし';
              } else {
                info5 = info5.substring(0, info5.length - 1);
              }
              if (info6 == '') {
                info6 = 'なし';
              } else {
                info6 = info6.substring(0, info6.length - 1);
              }
              let info = '';

              if (info2 === 'なし') {
                info = '【薬剤】 ' +
                  info1 +
                  // add 9987 by kangjie 20231223 start
                  // '\n【調整薬剤】 ' +
                  // info2 +
                  // add 9987 by kangjie 20231223 end
                  '\\n【医療材料】 ' +
                  info3 +
                  '\\n【ダイアライザ】 ' +
                  info4 +
                  '\\n【フリーワード】 ' +
                  info5 +
                  '\\n【一般名処方】 ' +
                  info6;
              } else {
                info = '【薬剤】 ' +
                  info1 +
                  // add 9987 by kangjie 20231223 start
                  '\n【調整薬剤】 ' +
                  info2 +
                  // add 9987 by kangjie 20231223 end
                  '\\n【医療材料】 ' +
                  info3 +
                  '\\n【ダイアライザ】 ' +
                  info4 +
                  '\\n【フリーワード】 ' +
                  info5 +
                  '\\n【一般名処方】 ' +
                  info6;
              }
              tabooDetail = this.addLinePatInfoTwo(tabooDetail, info);
              tabooMedicine = this.addLinePatInfoTwo(tabooMedicine, info1);
              // add 9987 by kangjie 20231225 start show tabooAdjMedicine col
              tabooAdjMedicine = this.addLinePatInfoTwo(tabooAdjMedicine, info2);
              // add 9987 by kangjie 20231225 end
              tabooEquipment = this.addLinePatInfoTwo(tabooEquipment, info3);
              tabooDialyzer = this.addLinePatInfoTwo(tabooDialyzer, info4);
              tabooFreeword = this.addLinePatInfoTwo(tabooFreeword, info5);
              tabooGenericMedicine = this.addLinePatInfoTwo(tabooGenericMedicine, info6);
            }

            /** modify 9987 by kangjie 20240513 end */
          });
          complaints = this.setDataAddLine(
            TABOO_ALLERGY_CD,
            tabooAllergy,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            TABOO_CONTENT_CD,
            tabooContent,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            TABOO_REMARK_CD,
            tabooRemark,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            TABOO_MEDICINE_CD,
            tabooMedicine,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            TABOO_ADJ_MEDICINE_CD,
            tabooAdjMedicine,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            TABOO_EQUIPMENT_CD,
            tabooEquipment,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            TABOO_DIALYZER_CD,
            tabooDialyzer,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            TABOO_FREEWORD_CD,
            tabooFreeword,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            TABOO_GENERIC_MEDICINE_CD,
            tabooGenericMedicine,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            TABOO_DETAIL_CD,
            tabooDetail,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }

        // 感染症
        if (x.infect_info) {
          //感染症有無_感染症患者として扱う感染症有無
          // mod #11528 【たくしん会】データリスト並び順不正 房 start
          if(x.is_infect == '1') {
            complaints = this.setComplaintsData(
              INFECT_TREAT_INFECT_DISEASE_CD,
              'あり',
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          // mod #11528 【たくしん会】データリスト並び順不正 房 end
          let infect_info = JSON.parse(x.infect_info);
          let infectDiseaseNoItem = '';
          let infectDiseaseNoCheckDate = '';
          let infectDiseaseNoUpdate = '';
          let infectDiseaseYnItem = '';
          let infectDiseaseYnResult = '';
          let infectDiseaseYnCheckDate = '';
          let infectDiseaseYnUpdateDate = '';
          let infectDiseaseYesItem = '';
          let infectDiseaseYesCheckDate = '';
          let infectDiseaseYesUpdate = '';
          let infectDiseaseItem = '';
          let infectDiseaseResult = '';
          let infectDiseaseCheckDate = '';
          let infectDiseaseUpdate = '';
          infect_info.forEach(y => {
            let infections = mstInfections.filter(
              z => z.infectionCd == y.infection_cd
            );
            let infection_name = '';
            if (infections.length > 0) {
              infection_name = infections[0].infectionName;
            }
            let infect = '';
            switch (y.infect + "") {
              case '0':
                infect = '不明';
                break;
              case '1':
                infect = '(-)';
                //感染症感染症(-)_項目
                infectDiseaseNoItem = this.addLinePatInfoTwo(
                  infectDiseaseNoItem,
                  infection_name
                );
                //感染症感染症(-)_検査日
                infectDiseaseNoCheckDate = this.addLinePatInfoTwo(
                  infectDiseaseNoCheckDate,
                  /*mod FNSI-改修内容5217 任 start*/
                  /*y.exam_date*/
                  dayjs(y.exam_date).isValid()
                    ? dayjs(y.exam_date).format('YYYY/MM/DD')
                    : ''
                  /*mod FNSI-改修内容5217 任 end*/
                );
                //感染症感染症(-)_更新日
                infectDiseaseNoUpdate = this.addLinePatInfoTwo(
                  infectDiseaseNoUpdate,
                  /*mod FNSI-改修内容5217 任 start*/
                  /*y.up_date*/
                  dayjs(y.up_date).isValid()
                    ? dayjs(y.up_date).format('YYYY/MM/DD')
                    : ''
                  /*mod FNSI-改修内容5217 任 end*/
                );
                //感染症感染症（+-）_項目
                infectDiseaseYnItem = this.addLinePatInfoTwo(
                  infectDiseaseYnItem,
                  infection_name
                );
                //感染症感染症（+-）_結果
                infectDiseaseYnResult = this.addLinePatInfoTwo(
                  infectDiseaseYnResult,
                  infect
                );
                //感染症感染症（+-）_検査日
                infectDiseaseYnCheckDate = this.addLinePatInfoTwo(
                  infectDiseaseYnCheckDate,
                  /*mod FNSI-改修内容5217 任 start*/
                  /*y.exam_date*/
                  dayjs(y.exam_date).isValid()
                    ? dayjs(y.exam_date).format('YYYY/MM/DD')
                    : ''
                  /*mod FNSI-改修内容5217 任 end*/
                );
                //感染症感染症（+-）_更新日
                infectDiseaseYnUpdateDate = this.addLinePatInfoTwo(
                  infectDiseaseYnUpdateDate,
                  /*mod FNSI-改修内容5217 任 start*/
                  /*y.up_date*/
                  dayjs(y.up_date).isValid()
                    ? dayjs(y.up_date).format('YYYY/MM/DD')
                    : ''
                  /*mod FNSI-改修内容5217 任 end*/
                );
                break;
              case '2':
                infect = '(+)';
                //感染症感染症(+)_項目
                infectDiseaseYesItem = this.addLinePatInfoTwo(
                  infectDiseaseYesItem,
                  infection_name
                );
                //感染症感染症(+)_検査日
                infectDiseaseYesCheckDate = this.addLinePatInfoTwo(
                  infectDiseaseYesCheckDate,
                  /*mod FNSI-改修内容5217 任 start*/
                  /*y.exam_date*/
                  dayjs(y.exam_date).isValid()
                    ? dayjs(y.exam_date).format('YYYY/MM/DD')
                    : ''
                  /*mod FNSI-改修内容5217 任 end*/
                );
                //感染症感染症(+)_更新日
                infectDiseaseYesUpdate = this.addLinePatInfoTwo(
                  infectDiseaseYesUpdate,
                  /*mod FNSI-改修内容5217 任 start*/
                  /*y.up_date*/
                  dayjs(y.up_date).isValid()
                    ? dayjs(y.up_date).format('YYYY/MM/DD')
                    : ''
                  /*mod FNSI-改修内容5217 任 end*/
                );
                //感染症感染症（+-）_項目
                infectDiseaseYnItem = this.addLinePatInfoTwo(
                  infectDiseaseYnItem,
                  infection_name
                );
                //感染症感染症（+-）_結果
                infectDiseaseYnResult = this.addLinePatInfoTwo(
                  infectDiseaseYnResult,
                  infect
                );
                //感染症感染症（+-）_検査日
                infectDiseaseYnCheckDate = this.addLinePatInfoTwo(
                  infectDiseaseYnCheckDate,
                  /*mod FNSI-改修内容5217 任 start*/
                  /*y.exam_date*/
                  dayjs(y.exam_date).isValid()
                    ? dayjs(y.exam_date).format('YYYY/MM/DD')
                    : ''
                  /*mod FNSI-改修内容5217 任 end*/
                );
                //感染症感染症（+-）_更新日
                infectDiseaseYnUpdateDate = this.addLinePatInfoTwo(
                  infectDiseaseYnUpdateDate,
                  /*mod FNSI-改修内容5217 任 start*/
                  /*y.up_date*/
                  dayjs(y.up_date).isValid()
                    ? dayjs(y.up_date).format('YYYY/MM/DD')
                    : ''
                  /*mod FNSI-改修内容5217 任 end*/
                );
                break;
              default:
                break;
            }
            //感染症_項目
            infectDiseaseItem = this.addLinePatInfoTwo(infectDiseaseItem, infection_name);
            //感染症_結果
            infectDiseaseResult = this.addLinePatInfoTwo(infectDiseaseResult, infect);
            //感染症_検査日
            infectDiseaseCheckDate = this.addLinePatInfoTwo(
              infectDiseaseCheckDate,
              /*mod FNSI-改修内容5217 任 start*/
              /*y.exam_date*/
              dayjs(y.exam_date).isValid()
                ? dayjs(y.exam_date).format('YYYY/MM/DD')
                : ''
              /*mod FNSI-改修内容5217 任 end*/
            );
            //感染症_更新日
            /*mod FNSI-改修内容5217 任 start*/
            /*infectDiseaseUpdate = this.addLine(infectDiseaseUpdate, y.up_date);*/
            infectDiseaseUpdate = this.addLinePatInfoTwo(infectDiseaseUpdate, dayjs(y.up_date).isValid()
              ? dayjs(y.up_date).format('YYYY/MM/DD')
              : '');
            /*mod FNSI-改修内容5217 任 end*/
          });
          complaints = this.setDataAddLine(
            INFECT_DISEASE_NO_ITEM_CD,
            infectDiseaseNoItem,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_NO_CHECK_DATE_CD,
            infectDiseaseNoCheckDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_NO_UPDATE_CD,
            infectDiseaseNoUpdate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_YN_ITEM_CD,
            infectDiseaseYnItem,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_YN_RESULT_CD,
            infectDiseaseYnResult,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_YN_CHECK_DATE_CD,
            infectDiseaseYnCheckDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_YN_UPDATE_DATE_CD,
            infectDiseaseYnUpdateDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_YES_ITEM_CD,
            infectDiseaseYesItem,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_YES_CHECK_DATE_CD,
            infectDiseaseYesCheckDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_YES_UPDATE_CD,
            infectDiseaseYesUpdate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_ITEM_CD,
            infectDiseaseItem,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_RESULT_CD,
            infectDiseaseResult,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_CHECK_DATE_CD,
            infectDiseaseCheckDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INFECT_DISEASE_UPDATE_CD,
            infectDiseaseUpdate,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }

        // インプラント
        if (x.implant_info) {
          let implant_info = JSON.parse(x.implant_info);
          let implantContent = '';
          let implantRegDate = '';
          let implantRemoveDate = '';
          implant_info.forEach(y => {
            //インプラント_内容
            let implants = mstImplants.filter(z => z.implantCd == y.implant_cd);
            if (implants.length > 0) {
              implantContent = this.addLinePatInfoTwo(
                implantContent,
                implants[0].implantName
              );
            }
            //インプラント_導入日
            /*mod FNSI-改修内容5217 任 start*/
            /*implantRegDate = this.addLine(implantRegDate, y.reg_date);*/
            implantRegDate = this.addLinePatInfoTwo(implantRegDate, dayjs(y.reg_date).isValid()
              ? dayjs(y.reg_date).format('YYYY/MM/DD')
              : '');
            /*mod FNSI-改修内容5217 任 end*/
            //インプラント_除去日
            /*mod FNSI-改修内容5217 任 start*/
            /*implantRemoveDate = this.addLine(implantRemoveDate, y.remove_date);*/
            implantRemoveDate = this.addLinePatInfoTwo(implantRemoveDate, dayjs(y.remove_date).isValid()
              ? dayjs(y.remove_date).format('YYYY/MM/DD')
              : '');
            /*mod FNSI-改修内容5217 任 end*/
          });
          complaints = this.setDataAddLine(
            IMPLANT_CONTENT_CD,
            implantContent,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            IMPLANT_REG_DATE_CD,
            implantRegDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            IMPLANT_REMOVE_DATE_CD,
            implantRemoveDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }

        if (x.pat_group_info) {
          let pat_group_info = JSON.parse(x.pat_group_info);
          if (pat_group_info.length > 0) {
            let pat_group_name = '';
            pat_group_info.forEach(y => {
              /*del FNSI-改修内容5195 任 start*/
              /*let group = patGroups.find(z => z.patGroupCd == y.pat_group_cd);
              if (!!group) {*/
              /*del FNSI-改修内容5195 任 end*/
                pat_group_name = this.addLinePatInfoTwo(
                  pat_group_name,
                  /*mod FNSI-改修内容5195 任 start*/
                  y
                  /*mod FNSI-改修内容5195 任 end*/
                );
              /*del FNSI-改修内容5195 任 start*/
              /*}*/
              /*del FNSI-改修内容5195 任 end*/
            });
            //患者グループ名
            complaints = this.setDataAddLine(
              PAT_GROUP_NAME_CD,
              pat_group_name,
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
        }

        if (x.addition_info) {
          let addition_info = JSON.parse(x.addition_info);
          let additionName = '';
          let additionAutoCalcEffective = '';
          let additionLatestCalcDay = '';
          //add 9796データリスト画面で患者情報2のデータが表示されない。zhao start
          let additionNameDay = '';
          //add 9796データリスト画面で患者情報2のデータが表示されない。zhao end
          addition_info.forEach(y => {
            //加算・管理料_加算・管理料
            let names = mstAdditions.filter(z => z.additionCd == y.cd);
            let name = '';
            if (names.length > 0) {
              name = names[0].additionName;
            }
            //add 9796データリスト画面で患者情報2のデータが表示されない。zhao start
            if (y && y.start_date) {
              //加算・管理料_算定日最新算定日
              additionNameDay = this.addLinePatInfoTwo(
                additionNameDay,
                dayjs(y.start_date).isValid()
                  ? dayjs(y.start_date).format('YYYY/MM/DD')
                  : ' '
              );
              name=name+additionNameDay;
            }
            //add 9796データリスト画面で患者情報2のデータが表示されない。zhao end
            additionName = this.addLinePatInfoTwo(additionName, name);
            //加算・管理料_自動算定算定有効
            if (y.is_enable == '1') {
              additionAutoCalcEffective = this.addLinePatInfoTwo(
                additionAutoCalcEffective,
                '〇'
              );
            } else {
              additionAutoCalcEffective = this.addLinePatInfoTwo(
                additionAutoCalcEffective,
                ' '
              );
            }
            let addition = additionList.find(item => item.pat_id === x.pat_id && item.cd === y.cd);
            if (addition && addition.last_date) {
              //加算・管理料_算定日最新算定日
              additionLatestCalcDay = this.addLinePatInfoTwo(
                additionLatestCalcDay,
                dayjs(addition.last_date).isValid()
                  ? dayjs(addition.last_date).format('YYYY/MM/DD')
                  : ' '
              );
            } else {
              additionLatestCalcDay = this.addLinePatInfoTwo(
                additionLatestCalcDay,
                ' ');
            }
          });
          complaints = this.setDataAddLine(
            ADDITION_NAME_CD,
            additionName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            ADDITION_AUTO_CALC_EFFECTIVE_CD,
            additionAutoCalcEffective,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            ADDITION_LATEST_CALC_DAY_CD,
            additionLatestCalcDay,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        this.firstFlg = true;
      });
      /*patUniques*/
      this.firstFlg = false;
      patUniques.forEach(x => {
        let nameList = patInfo.filter(y => y.pat_id == x.pat_id);
        let hosp_pat_id = '';
        let pat_name = '';
        if (nameList.length > 0) {
          hosp_pat_id = nameList[0].hosp_pat_id;
          pat_name = nameList[0].pat_name;
        }
        if (x.medical_hst_info) {
          let medical_hst_info = JSON.parse(x.medical_hst_info);
          const primaryDiseaseRecord = medical_hst_info.find(
            record => record.is_dialysis_underlying_disease === "1"
          );
          let primaryDisease = primaryDiseaseRecord ? primaryDiseaseRecord.disease_cd : "";
          //病名_病名
          let mstDisease = mstDiseases.filter(
            y => y.diseaseCd == primaryDisease
          );
          if (mstDisease.length > 0) {
            complaints = this.setDataAddLine(
              MEDICAL_HST_DISEASE_CD,
              mstDisease[0].diseaseName,
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          let diseaseName = '';
          let diseaseCrisisDay = '';
          let diseaseDiagnosDay = '';
          let diseaseDiagnosFacility = '';
          let diseaseMain = '';
          let diseasePrimaryDiseases = '';
          let diseaseNotice = '';
          let diseaseBiopsyConfirAli = '';
          let isDiagnosed = '';
          let diseaseHavePalpation = '';
          let diseaseReturne = '';
          let diseaseReturnChangeDay = '';
          let diseaseClinic = '';
          let diseaseDiagnosticPhysician = '';
          let diseaseComment = '';
          //add 9796データリスト画面で患者情報2のデータが表示されない。zhao start
          let diagnosisYear = '';
          let diagnosisMonth = '';
          let diagnosisDay = '';
          //add 9796データリスト画面で患者情報2のデータが表示されない。zhao end
          // add #9796データリスト画面で患者情報2のデータが表示されない。dengshen start
          let diseaseCrisisGetYear = '';
          let diseaseCrisisGetMonth = '';
          let diseaseCrisisGetDay = '';
          // add #9796データリスト画面で患者情報2のデータが表示されない。dengshen end
          medical_hst_info.forEach(m => {
            //病名_病名
            let mstDisease = mstDiseases.filter(
              y => y.diseaseCd == m.disease_cd
            );
            if (mstDisease.length > 0) {
              diseaseName = this.addLinePatInfoTwo(
                diseaseName,
                mstDisease[0].diseaseName
              );
            } else {
              diseaseName = this.addLinePatInfoTwo(
                diseaseName,
                ' '
              );
            }
            //病名_発症日
            /*mod FNSI-改修内容5217 任 start*/
            /*diseaseCrisisDay = this.addLine(diseaseCrisisDay, m.disease_date);*/
            // mod #9796データリスト画面で患者情報2のデータが表示されない。dengshen start
            // diseaseCrisisDay = this.addLinePatInfoTwo(diseaseCrisisDay, m.disease_date && dayjs(m.disease_date.substring(0, 8)).isValid()
            //   ? dayjs(m.disease_date.substring(0, 8)).format('YYYY/MM/DD')
            //   : '');
            if (!m.disease_year && !m.disease_month && !m.disease_day) {
              diseaseCrisisDay = this.addLinePatInfoTwo(
                diseaseCrisisDay,
                ' '
              );
            } else {
              if (m.disease_year) {
                diseaseCrisisGetYear = m.disease_year;
              } else {
                diseaseCrisisGetYear = '----';
              }
              if (m.disease_month) {
                diseaseCrisisGetMonth = m.disease_month;
              } else {
                diseaseCrisisGetMonth = '--';
              }
              if (m.disease_day) {
                diseaseCrisisGetDay = m.disease_day;
              } else {
                diseaseCrisisGetDay = '--';
              }
              diseaseCrisisDay = this.addLinePatInfoTwo(
                diseaseCrisisDay,
                diseaseCrisisGetYear+"/"+diseaseCrisisGetMonth+"/"+diseaseCrisisGetDay
              );
            }
            // mod #9796データリスト画面で患者情報2のデータが表示されない。dengshen end
            /*mod FNSI-改修内容5217 任 end*/
            //病名_診断日
            //add 9796データリスト画面で患者情報2のデータが表示されない。zhao start
            // add #9796データリスト画面で患者情報2のデータが表示されない。dengshen start
            if (!m.diagnosis_year && !m.diagnosis_month && !m.diagnosis_day) {
              diseaseDiagnosDay = this.addLinePatInfoTwo(
                diseaseDiagnosDay,
                ' '
              );
            } else {
            // add #9796データリスト画面で患者情報2のデータが表示されない。dengshen end
            if(m.diagnosis_year){
              diagnosisYear =  m.diagnosis_year;
            }else{
              diagnosisYear = '----';
            }
            if(m.diagnosis_month){
              diagnosisMonth = m.diagnosis_month;
            }else{
              diagnosisMonth = '--';
            }
            if(m.diagnosis_day){
              diagnosisDay = m.diagnosis_day;
            }else{
              diagnosisDay = '--';
            }
            //add 9796データリスト画面で患者情報2のデータが表示されない。zhao end
            diseaseDiagnosDay = this.addLinePatInfoTwo(
              diseaseDiagnosDay,
              /*mod FNSI-改修内容5217 任 start*/
              /*m.diagnosis_day*/
              //mod 9796データリスト画面で患者情報2のデータが表示されない。zhao start
              // m.diagnosis_day && dayjs(m.diagnosis_day.substring(0, 8)).isValid()
              //   ? dayjs(m.diagnosis_day.substring(0, 8)).format('YYYY/MM/DD')
              //   : ''
              // m.diagnosis_date && dayjs(m.diagnosis_date.substring(0, 8)).isValid()
              //   ? dayjs(m.diagnosis_day.substring(0, 8)).format('YYYY/MM/DD')
              //   : ''
              diagnosisYear+"/"+diagnosisMonth+"/"+diagnosisDay

              //mod 9796データリスト画面で患者情報2のデータが表示されない。zhao end
              /*mod FNSI-改修内容5217 任 end*/
            );
            // add #9796データリスト画面で患者情報2のデータが表示されない。dengshen end
            }
            // add #9796データリスト画面で患者情報2のデータが表示されない。dengshen end
            //病名_診断施設
            let facility = sysFacilitys.filter(
              y => y.medicalInstitutionCd == m.diagnosis_facility_cd
            );
            if (facility.length > 0) {
              diseaseDiagnosFacility = this.addLinePatInfoTwo(
                diseaseDiagnosFacility,
                facility[0].facilityName
              );
            } else {
              //9796 mod ljx start
              // diseaseDiagnosFacility = this.addLinePatInfoTwo(
              //   diseaseDiagnosFacility,
              //   ' '
              // );
              //病名_診断施設を手入力することができるので、その場合、手入力された内容(m.diagnosis_facility_cd)を表示する。
              diseaseDiagnosFacility = this.addLinePatInfoTwo(
                diseaseDiagnosFacility,
                m.diagnosis_facility_cd
              );
              //9796 mod ljx end
            }
            //病名_主病
            if (m.is_main_disease == '1') {
              diseaseMain = this.addLinePatInfoTwo(diseaseMain, '主');
            } else {
              diseaseMain = this.addLinePatInfoTwo(diseaseMain, ' ');
            }
            //病名_透析導入原疾患として扱う原疾患
            if (m.is_dialysis_underlying_disease == '1') {
              diseasePrimaryDiseases = this.addLinePatInfoTwo(
                diseasePrimaryDiseases,
                '原'
              );
            } else {
              diseasePrimaryDiseases = this.addLinePatInfoTwo(
                diseasePrimaryDiseases,
                ' '
              );
            }
            //病名_告知
            if (m.is_notice == '1') {
              diseaseNotice = this.addLinePatInfoTwo(diseaseNotice, 'あり');
            } else {
              diseaseNotice = this.addLinePatInfoTwo(diseaseNotice, ' ');
            }
            //病名_生検確認アリ
            if (m.is_confirmation_biopsy == '1') {
              diseaseBiopsyConfirAli = this.addLinePatInfoTwo(
                diseaseBiopsyConfirAli,
                'あり'
              );
            } else {
              diseaseBiopsyConfirAli = this.addLinePatInfoTwo(
                diseaseBiopsyConfirAli,
                ' '
              );
            }
            if (m.is_diagnosed == '1') {
              isDiagnosed = this.addLinePatInfoTwo(
                isDiagnosed,
                'あり'
              );
            } else {
              isDiagnosed = this.addLinePatInfoTwo(
                isDiagnosed,
                ' '
              );
            }
            //病名_触診あり
            if (m.is_diagnosed == '1') {
              diseaseHavePalpation = this.addLinePatInfoTwo(diseaseHavePalpation, 'あり');
            } else {
              diseaseHavePalpation = this.addLinePatInfoTwo(diseaseHavePalpation, ' ');
            }
            //病名_転帰
            switch (m.out_come + "") {
              case '1':
                diseaseReturne = this.addLinePatInfoTwo(diseaseReturne, '治療中');
                break;
              case '2':
                diseaseReturne = this.addLinePatInfoTwo(diseaseReturne, '診断のみ');
                break;
              case '3':
                diseaseReturne = this.addLinePatInfoTwo(diseaseReturne, '治癒');
                break;
              case '4':
                diseaseReturne = this.addLinePatInfoTwo(diseaseReturne, '軽快');
                break;
              case '5':
                diseaseReturne = this.addLinePatInfoTwo(diseaseReturne, '寛解');
                break;
              case '6':
                diseaseReturne = this.addLinePatInfoTwo(diseaseReturne, '不変');
                break;
              case '7':
                diseaseReturne = this.addLinePatInfoTwo(diseaseReturne, '増悪');
                break;
              case '8':
                diseaseReturne = this.addLinePatInfoTwo(diseaseReturne, '中止');
                break;
              case '9':
                diseaseReturne = this.addLinePatInfoTwo(diseaseReturne, '転医');
                break;
              case '10':
                diseaseReturne = this.addLinePatInfoTwo(diseaseReturne, '死亡');
                break;
              default:
                diseaseReturne = this.addLinePatInfoTwo(diseaseReturne, ' ');
                break;
            }
            //病名_転帰変更日
            diseaseReturnChangeDay = this.addLinePatInfoTwo(
              diseaseReturnChangeDay,
              /*mod FNSI-改修内容5217 任 start*/
              /*m.out_come_date*/
              dayjs(m.out_come_date).isValid()
                ? dayjs(m.out_come_date).format('YYYY/MM/DD')
                : ''
              /*mod FNSI-改修内容5217 任 end*/
            );
            //病名_診療科
            let course = mstCourses.filter(y => y.courseCd == m.course_cd);
            if (course.length > 0) {
              diseaseClinic = this.addLinePatInfoTwo(diseaseClinic, course[0].courseName);
            } else {
              //mod 9796 ljx start
              //病名_診療科を手入力することができるので、その場合、手入力された内容(m.course_cd)を表示する。
              //diseaseClinic = this.addLinePatInfoTwo(diseaseClinic, ' ');
              diseaseClinic = this.addLinePatInfoTwo(diseaseClinic, m.course_cd);
              //mod 9796 ljx end
            }
            //病名_診断医
            let personaluser = mstPersonalUsers.filter(
              y => y.userId == m.diagnostician_cd
            );
            if (personaluser.length > 0) {
              diseaseDiagnosticPhysician = this.addLinePatInfoTwo(
                diseaseDiagnosticPhysician,
                this.addBlank(
                  personaluser[0].userLastName,
                  personaluser[0].userFirstName
                )
              );
            } else {
              //mod 9796 ljx start
              //病名_診断医を手入力することができるので、その場合、手入力された内容(m.diagnostician_cd)を表示する。
              // diseaseDiagnosticPhysician = this.addLinePatInfoTwo(
              //   diseaseDiagnosticPhysician, ' '
              // );
              diseaseDiagnosticPhysician = this.addLinePatInfoTwo(
                diseaseDiagnosticPhysician, m.diagnostician_cd
              );
              //mod 9796 ljx end
            }
            //病名_コメント
            diseaseComment = this.addLinePatInfoTwo(diseaseComment, m.memo);
          });
          complaints = this.setDataAddLine(
            DISEASE_NAME_CD,
            diseaseName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_CRISIS_DAY_CD,
            diseaseCrisisDay,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_DIAGNOS_DAY_CD,
            diseaseDiagnosDay,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_DIAGNOS_FACILITY_CD,
            diseaseDiagnosFacility,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_MAIN_CD,
            diseaseMain,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_PRIMARY_DISEASES_CD,
            diseasePrimaryDiseases,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_NOTICE_CD,
            diseaseNotice,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_BIOPSY_CONFIR_ALI_CD,
            diseaseBiopsyConfirAli,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_IS_DIAGNOSED_CD,
            isDiagnosed,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_HAVE_PALPATION_CD,
            diseaseHavePalpation,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_RETURNE_CD,
            diseaseReturne,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_RETURN_CHANGE_DAY_CD,
            diseaseReturnChangeDay,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_CLINIC_CD,
            diseaseClinic,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_DIAGNOSTIC_PHYSICIAN_CD,
            diseaseDiagnosticPhysician,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            DISEASE_COMMENT_CD,
            diseaseComment,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }

        if (x.in_out_visit_history_info) {
          let in_out_visit_history_info = JSON.parse(
            x.in_out_visit_history_info
          );
          let inoutInfoDivision = '';
          let inoutInfoFacility = '';
          let inoutInfoClinic = '';
          let inoutInfoDoctor = '';
          let inoutInfoStartDate = '';
          let inoutInfoEndDate = '';
          let inoutInfoInout = '';
          let inoutInfoComment = '';
          in_out_visit_history_info.forEach(m => {
            //mod 5222 施設、入外、コメントが表示されない 張 start
            let facilityFrom = '';
            let facilityTo = '';
            if (m.facility_is_free === "1") {
              facilityFrom = m.from_facility;
              facilityTo = m.to_facility;
            } else {
              let facilityFroms = sysFacilitys.filter(
                y => y.medicalInstitutionCd == m.from_facility
              );
              if (facilityFroms.length > 0) {
                facilityFrom = facilityFroms[0].facilityName;
              }
              let facilityTos = sysFacilitys.filter(
                y => y.medicalInstitutionCd == m.to_facility
              );
              if (facilityTos.length > 0) {
                facilityTo = facilityTos[0].facilityName;
              }
            }
            //mod 5222 施設、入外、コメントが表示されない 張 end
            let courseFrom = '';
            let courseTo = '';
            if (m.course_is_free === "1") {
              courseFrom = m.from_course;
              courseTo = m.to_course;
            } else {
              let courseFroms = mstCourses.filter(y => y.courseCd == m.from_course);
              if (courseFroms.length > 0) {
                courseFrom = courseFroms[0].courseName;
              }
              let courseTos = mstCourses.filter(y => y.courseCd == m.to_course);
              if (courseTos.length > 0) {
                courseTo = courseTos[0].courseName;
              }
            }
            let userFrom = '';
            let userTo = '';
            if (m.course_is_free === "1") {
              userFrom = m.from_doctor;
              userTo = m.to_doctor;
            } else {
              let userFroms = mstPersonalUsers.filter(y => y.userId == m.from_doctor);
              if (userFroms.length > 0) {
                userFrom = this.addBlank(
                  userFroms[0].userLastName,
                  userFroms[0].userFirstName
                );
              }
              let userTos = mstPersonalUsers.filter(y => y.userId == m.to_doctor);
              if (userTos.length > 0) {
                userTo = this.addBlank(
                  userTos[0].userLastName,
                  userTos[0].userFirstName
                );
              }
            }
            if (m.move_in_out == '1') {
              //入外・転入出_区分
              inoutInfoDivision = this.addLinePatInfoTwo(inoutInfoDivision, '導入');
              //入外・転入出_施設
              inoutInfoFacility = this.addLinePatInfoTwo(inoutInfoFacility, facilityFrom);
              //入外・転入出_診療科
              inoutInfoClinic = this.addLinePatInfoTwo(inoutInfoClinic, courseFrom);
              //入外・転入出_医師
              inoutInfoDoctor = this.addLinePatInfoTwo(inoutInfoDoctor, userFrom);
            } else if (m.move_in_out == '2') {
              //入外・転入出_区分
              inoutInfoDivision = this.addLinePatInfoTwo(inoutInfoDivision, '転入');
              //入外・転入出_施設
              inoutInfoFacility = this.addLinePatInfoTwo(inoutInfoFacility, facilityFrom);
              //入外・転入出_診療科
              inoutInfoClinic = this.addLinePatInfoTwo(inoutInfoClinic, courseFrom);
              //入外・転入出_医師
              inoutInfoDoctor = this.addLinePatInfoTwo(inoutInfoDoctor, userFrom);
            } else if (m.move_in_out == '3') {
              //入外・転入出_区分
              inoutInfoDivision = this.addLinePatInfoTwo(inoutInfoDivision, '転出');
              //入外・転入出_施設
              inoutInfoFacility = this.addLinePatInfoTwo(inoutInfoFacility, facilityTo);
              //入外・転入出_診療科
              inoutInfoClinic = this.addLinePatInfoTwo(inoutInfoClinic, courseTo);
              //入外・転入出_医師
              inoutInfoDoctor = this.addLinePatInfoTwo(inoutInfoDoctor, userTo);
            } else if (m.move_in_out == '4') {
              //入外・転入出_区分
              inoutInfoDivision = this.addLinePatInfoTwo(inoutInfoDivision, '入院');
              //入外・転入出_施設
              inoutInfoFacility = this.addLinePatInfoTwo(inoutInfoFacility, facilityFrom);
              //入外・転入出_診療科
              inoutInfoClinic = this.addLinePatInfoTwo(inoutInfoClinic, courseFrom);
              //入外・転入出_医師
              inoutInfoDoctor = this.addLinePatInfoTwo(inoutInfoDoctor, userFrom);
            } else if (m.move_in_out == '5') {
              //入外・転入出_区分
              inoutInfoDivision = this.addLinePatInfoTwo(inoutInfoDivision, '退院');
              //入外・転入出_施設
              inoutInfoFacility = this.addLinePatInfoTwo(inoutInfoFacility, facilityFrom);
              //入外・転入出_診療科
              inoutInfoClinic = this.addLinePatInfoTwo(inoutInfoClinic, courseFrom);
              //入外・転入出_医師
              inoutInfoDoctor = this.addLinePatInfoTwo(inoutInfoDoctor, userFrom);
            } else if (m.move_in_out == '6') {
              //入外・転入出_区分
              inoutInfoDivision = this.addLinePatInfoTwo(inoutInfoDivision, '外来');
              //入外・転入出_施設
              inoutInfoFacility = this.addLinePatInfoTwo(inoutInfoFacility, facilityFrom);
              //入外・転入出_診療科
              inoutInfoClinic = this.addLinePatInfoTwo(inoutInfoClinic, courseFrom);
              //入外・転入出_医師
              inoutInfoDoctor = this.addLinePatInfoTwo(inoutInfoDoctor, userFrom);
            } else if (m.move_in_out == '7') {
              //入外・転入出_区分
              inoutInfoDivision = this.addLinePatInfoTwo(inoutInfoDivision, '離脱');
              //入外・転入出_施設
              inoutInfoFacility = this.addLinePatInfoTwo(inoutInfoFacility, facilityFrom);
              //入外・転入出_診療科
              inoutInfoClinic = this.addLinePatInfoTwo(inoutInfoClinic, courseFrom);
              //入外・転入出_医師
              inoutInfoDoctor = this.addLinePatInfoTwo(inoutInfoDoctor, userFrom);
            } else if (m.move_in_out == '8') {
              //入外・転入出_区分
              inoutInfoDivision = this.addLinePatInfoTwo(inoutInfoDivision, '移植');
              //入外・転入出_施設
              inoutInfoFacility = this.addLinePatInfoTwo(inoutInfoFacility, facilityFrom);
              //入外・転入出_診療科
              inoutInfoClinic = this.addLinePatInfoTwo(inoutInfoClinic, courseFrom);
              //入外・転入出_医師
              inoutInfoDoctor = this.addLinePatInfoTwo(inoutInfoDoctor, userFrom);
            } else if (m.move_in_out == '9') {
              //入外・転入出_区分
              inoutInfoDivision = this.addLinePatInfoTwo(inoutInfoDivision, '一時転出');
              //入外・転入出_施設
              inoutInfoFacility = this.addLinePatInfoTwo(inoutInfoFacility, facilityTo);
              //入外・転入出_診療科
              inoutInfoClinic = this.addLinePatInfoTwo(inoutInfoClinic, courseTo);
              //入外・転入出_医師
              inoutInfoDoctor = this.addLinePatInfoTwo(inoutInfoDoctor, userTo);
            } else if (m.move_in_out == '10') {
              //入外・転入出_区分
              inoutInfoDivision = this.addLinePatInfoTwo(
                inoutInfoDivision,
                '通院拒否・不明'
              );
              //入外・転入出_施設
              inoutInfoFacility = this.addLinePatInfoTwo(inoutInfoFacility, facilityFrom);
              //入外・転入出_診療科
              inoutInfoClinic = this.addLinePatInfoTwo(inoutInfoClinic, courseFrom);
              //入外・転入出_医師
              inoutInfoDoctor = this.addLinePatInfoTwo(inoutInfoDoctor, userFrom);
            } else if (m.move_in_out == '11') {
              //入外・転入出_区分
              inoutInfoDivision = this.addLinePatInfoTwo(
                inoutInfoDivision,
                '死亡'
              );
              //入外・転入出_施設
              inoutInfoFacility = this.addLinePatInfoTwo(inoutInfoFacility, facilityFrom);
              //入外・転入出_診療科
              inoutInfoClinic = this.addLinePatInfoTwo(inoutInfoClinic, courseFrom);
              //入外・転入出_医師
              inoutInfoDoctor = this.addLinePatInfoTwo(inoutInfoDoctor, userFrom);
            } else {
              //入外・転入出_区分
              inoutInfoDivision = this.addLinePatInfoTwo(inoutInfoDivision, ' ');
              //入外・転入出_施設
              inoutInfoFacility = this.addLinePatInfoTwo(inoutInfoFacility, ' ');
              //入外・転入出_診療科
              inoutInfoClinic = this.addLinePatInfoTwo(inoutInfoClinic, ' ');
              //入外・転入出_医師
              inoutInfoDoctor = this.addLinePatInfoTwo(inoutInfoDoctor, ' ');
            }
            // mod #9796データリスト画面で患者情報2のデータが表示されない。dengshen start
            // //入外・転入出_日付開始日
            // inoutInfoStartDate = this.addLinePatInfoTwo(
            //   inoutInfoStartDate,
            //   /*mod FNSI-改修内容5217 任 start*/
            //   /*m.period_start*/
            //   dayjs(m.period_start).isValid()
            //     ? dayjs(m.period_start).format('YYYY/MM/DD')
            //     : ''
            //   /*mod FNSI-改修内容5217 任 end*/
            // );
            // //入外・転入出_日付終了日
            // /*mod FNSI-改修内容5217 任 start*/
            // /*inoutInfoEndDate = this.addLine(inoutInfoEndDate, m.period_end);*/
            // inoutInfoEndDate = this.addLinePatInfoTwo(inoutInfoEndDate, dayjs(m.period_end).isValid()
            //   ? dayjs(m.period_end).format('YYYY/MM/DD')
            //   : '');
            // /*mod FNSI-改修内容5217 任 end*/
            let periodStartYear = '';
            let periodStartMonth = '';
            let periodStartDay = '';
            let periodEndYear = '';
            let periodEndMonth = '';
            let periodEndDay = '';
            //入外・転入出_日付開始日
            if (!m.period_start_year && !m.period_start_month && !m.period_start_day) {
              inoutInfoStartDate = this.addLinePatInfoTwo(
                inoutInfoStartDate,
                ' '
              );
            } else {
              if(m.period_start_year){
                periodStartYear =  m.period_start_year;
              }else{
                periodStartYear = '----';
              }
              if(m.period_start_month){
                periodStartMonth = m.period_start_month;
              }else{
                periodStartMonth = '--';
              }
              if(m.period_start_day){
                periodStartDay = m.period_start_day;
              }else{
                periodStartDay = '--';
              }
              inoutInfoStartDate = this.addLinePatInfoTwo(
                inoutInfoStartDate,
                periodStartYear+"/"+periodStartMonth+"/"+periodStartDay
              );
            }
            //入外・転入出_日付終了日
            if (!m.period_end_year && !m.period_end_month && !m.period_end_day) {
              inoutInfoEndDate = this.addLinePatInfoTwo(
                inoutInfoEndDate,
                ' '
              );
            } else {
              if(m.period_end_year){
                periodEndYear =  m.period_end_year;
              }else{
                periodEndYear = '----';
              }
              if(m.period_end_month){
                periodEndMonth = m.period_end_month;
              }else{
                periodEndMonth = '--';
              }
              if(m.period_end_day){
                periodEndDay = m.period_end_day;
              }else{
                periodEndDay = '--';
              }
              inoutInfoEndDate = this.addLinePatInfoTwo(
                inoutInfoEndDate,
                periodEndYear+"/"+periodEndMonth+"/"+periodEndDay
              );
            }
            // mod #9796データリスト画面で患者情報2のデータが表示されない。dengshen end
            /*inoutInfoEndDate = this.addLine(inoutInfoEndDate, m.period_end);*/
            //入外・転入出_入外
            switch (m.in_out + "") {
              //mod 5222 施設、入外、コメントが表示されない 張 statt
              // case '1':
              case '1':
                inoutInfoInout = this.addLinePatInfoTwo(inoutInfoInout, '入院');
                break;
              // case '2':
              case '0':
                inoutInfoInout = this.addLinePatInfoTwo(inoutInfoInout, '外来');
                break;
              // case '3':
              case '2':
                inoutInfoInout = this.addLinePatInfoTwo(inoutInfoInout, '死亡');
                break;
              case '3':
                inoutInfoInout = this.addLinePatInfoTwo(inoutInfoInout, '－');
                break;
              default:
                inoutInfoInout = this.addLinePatInfoTwo(inoutInfoInout, ' ');
                break;
            }
            //入外・転入出_コメント
            // inoutInfoComment = this.addLine(inoutInfoComment, m.comment);
            inoutInfoComment = this.addLinePatInfoTwo(inoutInfoComment, m.reason);
            //mod 5222 施設、入外、コメントが表示されない 張 end
          });
          complaints = this.setDataAddLine(
            INOUT_INFO_DIVISION_CD,
            inoutInfoDivision,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INOUT_INFO_FACILITY_CD,
            inoutInfoFacility,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INOUT_INFO_CLINIC_CD,
            inoutInfoClinic,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INOUT_INFO_DOCTOR_CD,
            inoutInfoDoctor,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INOUT_INFO_START_DATE_CD,
            inoutInfoStartDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INOUT_INFO_END_DATE_CD,
            inoutInfoEndDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INOUT_INFO_INOUT_CD,
            inoutInfoInout,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INOUT_INFO_COMMENT_CD,
            inoutInfoComment,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        if (x.physical_info) {
          let physical_info = JSON.parse(x.physical_info);
          let physicalInfoInspectionDateTime = '';
          let physicalInfoMeasureTiming = '';
          let physicalInfoStature = '';
          let physicalInfoInspectionWeight = '';
          let physicalInfoBreastDia = '';
          let physicalInfoChestDia = '';
          let physicalInfoCtr = '';
          let physicalInfoDw = '';
          let previousWeightAllowanceLimit = '';
          let preWeightToleranceLowerLimit = '';
          let physicalInfoDwTargetWeight = '';
          let physicalInfoIndicator = '';
          let physicalInfoIndStartDate = '';
          let physicalInfoMemo = '';
          physical_info.forEach(m => {
            //身体情報_測定日時
            physicalInfoInspectionDateTime = this.addLinePatInfoTwo(
              physicalInfoInspectionDateTime,
              dayjs(m.exam_date).isValid()
                ? dayjs(m.exam_date).format('YYYY/MM/DD HH:mm:ss')
                : ''
            );
            //身体情報_測定タイミング
            if (m.order_class == 1) {
              physicalInfoMeasureTiming = this.addLinePatInfoTwo(
                physicalInfoMeasureTiming,
                '透析前'
              );
            } else if (m.order_class == 2) {
              physicalInfoMeasureTiming = this.addLinePatInfoTwo(
                physicalInfoMeasureTiming,
                '透析後'
              );
            } else if (m.order_class == 3) {
              physicalInfoMeasureTiming = this.addLinePatInfoTwo(
                physicalInfoMeasureTiming,
                'その他'
              );
            }
            //身体情報_身長
            physicalInfoStature = this.addLinePatInfoTwo(
              physicalInfoStature,
              /*mod FNSI-改修内容5237 任 start*/
              m.height ? this.getDecimalValue(m.height,1) + ' cm' : null
              /*mod FNSI-改修内容5237 任 end*/
            );
            //身体情報_検査時体重
            physicalInfoInspectionWeight = this.addLinePatInfoTwo(
              physicalInfoInspectionWeight,
              /*mod FNSI-改修内容5237 任 start*/
              m.ctr_weight ? this.getDecimalValue(m.ctr_weight,2) + ' kg' : null
              /*mod FNSI-改修内容5237 任 end*/
            );
            //身体情報_心横径
            physicalInfoBreastDia = this.addLinePatInfoTwo(
              physicalInfoBreastDia,
              m.breast_dia
            );
            //身体情報_胸敦横径
            physicalInfoChestDia = this.addLinePatInfoTwo(
              physicalInfoChestDia,
              m.chest_dia
            );
            //身体情報_CTR
            physicalInfoCtr = this.addLinePatInfoTwo(
              physicalInfoCtr,
              /*mod FNSI-改修内容5237 任 start*/
              m.ctr ? this.getDecimalValue(m.ctr,2) + ' %' : null
              /*mod FNSI-改修内容5237 任 end*/
            );
            //身体情報_DW
            physicalInfoDw = this.addLinePatInfoTwo(
              physicalInfoDw,
              /*mod FNSI-改修内容5237 任 start*/
              m.dw ? this.getDecimalValue(m.dw,2) + ' kg' : null
              /*mod FNSI-改修内容5237 任 end*/
            );
            //身体情報_前体重許容上限
            previousWeightAllowanceLimit = this.addLinePatInfoTwo(
              previousWeightAllowanceLimit,
              /*mod FNSI-改修内容5237 任 start*/
              m.pre_scale_upper ? this.getDecimalValue(m.pre_scale_upper,2) + ' kg' : null
              /*mod FNSI-改修内容5237 任 end*/
            );
            //身体情報_前体重許容下限
            preWeightToleranceLowerLimit = this.addLinePatInfoTwo(
              preWeightToleranceLowerLimit,
              /*mod FNSI-改修内容5237 任 start*/
              m.pre_scale_lower ? this.getDecimalValue(m.pre_scale_lower,2) + ' kg' : null
              /*mod FNSI-改修内容5237 任 end*/
            );
            // mod FNSI-改修内容redmain 5209 start

            /*//身体情報_目標体重
            physicalInfoDwTargetWeight = this.addLine(
              physicalInfoDwTargetWeight,
              m.target_weight ? m.target_weight + ' kg' : null
            );*/

            if(m.target_weight + "" === "-1"){
              //身体情報_目標体重
              physicalInfoDwTargetWeight = this.addLinePatInfoTwo(
                physicalInfoDwTargetWeight,
                /*mod FNSI-改修内容5237 任 start*/
                // mod #11528 【たくしん会】データリスト並び順不正 房 start
                // m.dw ? this.getDecimalValue(m.dw, 2) + ' kg' : null
                "DWと同じ"
                // mod #11528 【たくしん会】データリスト並び順不正 房 end
                /*mod FNSI-改修内容5237 任 end*/
              );
            }else{
              //身体情報_目標体重
              physicalInfoDwTargetWeight = this.addLinePatInfoTwo(
                physicalInfoDwTargetWeight,
                /*mod FNSI-改修内容5237 任 start*/
                m.target_weight ? this.getDecimalValue(m.target_weight,2) + ' kg' : null
                /*mod FNSI-改修内容5237 任 end*/
              );
            }
            // mod FNSI-改修内容redmain 5209 end`

            let nameList = mstPersonalUsers.filter(y => y.userId == m.indicator_cd);
            let indicator_name = "";
            if (nameList && nameList.length > 0) {
              indicator_name = nameList[0].userName;
            }
            //身体情報_指示者
            physicalInfoIndicator = this.addLinePatInfoTwo(
              physicalInfoIndicator,
              indicator_name
            );
            //身体情報_指示開始日
            physicalInfoIndStartDate = this.addLinePatInfoTwo(
              physicalInfoIndStartDate,
              /*mod FNSI-改修内容5217 任 start*/
              /*m.indicator_start_date*/
              dayjs(m.indicator_start_date).isValid()
                ? dayjs(m.indicator_start_date).format('YYYY/MM/DD')
                : ''
              /*mod FNSI-改修内容5217 任 end*/
            );
            //身体情報_メモ
            physicalInfoMemo = this.addLinePatInfoTwo(physicalInfoMemo, m.memo);
          });
          complaints = this.setDataAddLine(
            PHYSICAL_INFO_INSPECTION_DATE_TIME_CD,
            physicalInfoInspectionDateTime,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PHYSICAL_INFO_MEASURE_TIMING_CD,
            physicalInfoMeasureTiming,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PHYSICAL_INFO_STATURE_CD,
            physicalInfoStature,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PHYSICAL_INFO_INSPECTION_WEIGHT_CD,
            physicalInfoInspectionWeight,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PHYSICAL_INFO_BREAST_DIA_CD,
            physicalInfoBreastDia,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PHYSICAL_INFO_CHEST_DIA_CD,
            physicalInfoChestDia,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PHYSICAL_INFO_CTR_CD,
            physicalInfoCtr,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PHYSICAL_INFO_DW_CD,
            physicalInfoDw,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PREVIOUS_WEIGHT_ALLOWANCE_LIMIT_CD,
            previousWeightAllowanceLimit,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PRE_WEIGHT_TOLERANCE_LOWER_LIMIT_CD,
            preWeightToleranceLowerLimit,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PHYSICAL_INFO_DW_TARGET_WEIGHT_CD,
            physicalInfoDwTargetWeight,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PHYSICAL_INFO_INDICATOR_CD,
            physicalInfoIndicator,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PHYSICAL_INFO_IND_START_DATE_CD,
            physicalInfoIndStartDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PHYSICAL_INFO_MEMO_CD,
            physicalInfoMemo,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        this.firstFlg = true;
      });
      /*patPersonalMains*/
      this.firstFlg = false;
      patPersonalMains.forEach(x => {
        let nameList = patInfo.filter(y => y.pat_id == x.pat_id);
        let hosp_pat_id = '';
        let pat_name = '';
        if (nameList.length > 0) {
          hosp_pat_id = nameList[0].hosp_pat_id;
          pat_name = nameList[0].pat_name;
        }
        //本人情報
        let pat_name_kana = "";
        // mod #6510 患者名（カナ）の姓と名の表示順がテンプレートにより異なる 王永吉 start
        // if (x.pat_first_name_kana) {
        //   pat_name_kana = pat_name_kana + x.pat_first_name_kana;
        // }
        if (x.pat_last_name_kana) {
          pat_name_kana = pat_name_kana + x.pat_last_name_kana;
        }
        // mod #6510 患者名（カナ）の姓と名の表示順がテンプレートにより異なる 王永吉 end
        if (pat_name_kana) {
          pat_name_kana = pat_name_kana + "　";
        }
        // mod #6510 患者名（カナ）の姓と名の表示順がテンプレートにより異なる 王永吉 start
        // if (x.pat_last_name_kana) {
        //   pat_name_kana = pat_name_kana + x.pat_last_name_kana;
        // }
        if (x.pat_first_name_kana) {
          pat_name_kana = pat_name_kana + x.pat_first_name_kana;
        }
        // mod #6510 患者名（カナ）の姓と名の表示順がテンプレートにより異なる 王永吉 end
        complaints = this.setDataAddLine(
          BASIC_INFO_PAT_NAME_KANA,
          pat_name_kana,
          hosp_pat_id,
          pat_name,
          complaints
        );
        let severity = mst_severity.find(item => item.code === x.severity_cd);
        if (severity) {
          complaints = this.setDataAddLine(
            INSU_DST_SEVERITY_CD,
            severity.name,
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else {
          complaints = this.setDataAddLine(
            INSU_DST_SEVERITY_CD,
            "不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        let transport = mst_transport.find(item => item.code === x.transport_cd);
        if (transport) {
          complaints = this.setDataAddLine(
            INSU_DST_TRANSPORT_CD,
            transport.name,
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else {
          complaints = this.setDataAddLine(
            INSU_DST_TRANSPORT_CD,
            "不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        }

        if (x.in_out_class == '1') {
          complaints = this.setDataAddLine(
            BASIC_INFO_IN_OUT_CLASS,
            '入院',
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.in_out_class == '0') {
          complaints = this.setDataAddLine(
            BASIC_INFO_IN_OUT_CLASS,
            '外来',
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.in_out_class == '2') {
          complaints = this.setDataAddLine(
            BASIC_INFO_IN_OUT_CLASS,
            '死亡',
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.in_out_class == '3') {
          complaints = this.setDataAddLine(
            BASIC_INFO_IN_OUT_CLASS,
            '－',
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        complaints = this.setDataAddLine(
          BASIC_INFO_PAT_BIRTHDAY,
          x.pat_birthday ? dayjs(x.pat_birthday).format("YYYY/MM/DD") : "",
          hosp_pat_id,
          pat_name,
          complaints
        );
        if (x.pat_sex == '1') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_SEX,
            "男性",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_sex == '0') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_SEX,
            "不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_sex == '2') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_SEX,
            "女性",
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        if (x.pat_blood_type_abo == '0') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_ABO,
            "不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_abo == '1') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_ABO,
            "A型",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_abo == '2') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_ABO,
            "B型",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_abo == '3') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_ABO,
            "O型",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_abo == '4') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_ABO,
            "AB型",
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        if (x.pat_blood_type_rh == '0') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_RH,
            "不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_rh == '1') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_RH,
            "Rh＋",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_rh == '2') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_RH,
            "Rh－",
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        if (x.pat_blood_type_serovar == '0') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '11') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A1",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '12') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aint",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '13') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A2",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '14') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A3",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '15') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ax",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '16') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Am",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '17') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ael",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '18') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aend",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '21') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "B1",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '22') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Bint",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '23') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "B2",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '24') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "B3",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '25') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Bx",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '26') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Bm",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '27') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Bel",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '28') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Bend",
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        //add 9796データリスト画面で患者情報2のデータが表示されない。 zhao start
        else if (x.pat_blood_type_serovar == '31') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Oh",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '32') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ah",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '33') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Bh",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '34') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Om",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '35') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Am",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '36') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Bm",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '400') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "不明　不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '401') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "不明　B1",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '402') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "不明　Bint",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '403') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "不明　B2",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '404') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "不明　B3",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '405') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "不明　Bx",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '406') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "不明　Bm",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '407') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "不明　Bel",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '408') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "不明　Bend",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '410') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A1　不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '411') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A1　B1",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '412') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A1　Bint",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '413') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A1　B2",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '414') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A1　B3",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '415') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A1　Bx",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '416') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A1　Bm",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '417') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A1　Bel",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '418') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A1　Bend",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '420') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aint　不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '421') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aint　B1",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '422') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aint　Bint",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '423') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aint　B2",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '424') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aint　B3",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '425') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aint　Bx",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '426') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aint　Bm",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '427') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aint　Bel",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '428') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aint　Bend",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '430') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A2　不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '431') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A2　B1",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '432') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A2　Bint",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '433') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A2　B2",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '434') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A2　B3",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '435') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A2　Bx",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '436') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A2　Bm",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '437') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A2　Bel",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '438') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A2　Bend",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '440') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A3　不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '441') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A3　B1",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '442') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A3　Bint",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '443') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A3　B2",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '444') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A3　B3",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '445') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A3　Bx",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '446') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A3　Bm",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '447') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A3　Bel",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '448') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "A3　Bend",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '450') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ax　不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '451') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ax　B1",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '452') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ax　Bint",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '453') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ax　B2",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '454') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ax　B3",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '455') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ax　Bx",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '456') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ax　Bm",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '457') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ax　Bel",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '458') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ax　Bend",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '460') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Am　不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '461') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Am　B1",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '462') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Am　Bint",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '463') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Am　B2",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '464') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Am　B3",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '465') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Am　Bx",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '466') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Am　Bm",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '467') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Am　Bel",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '468') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Am　Bend",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '470') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ael　不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '471') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ael　B1",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '472') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ael　Bint",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '473') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ael　B2",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '474') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ael　B3",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '475') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ael　Bx",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '476') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ael　Bm",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '477') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ael　Bel",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '478') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Ael　Bend",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '480') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aend　不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '481') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aend　B1",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '482') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aend　Bint",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '483') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aend　B2",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '484') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aend　B3",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '485') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aend　Bx",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '486') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aend　Bm",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '487') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aend　Bel",
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else if (x.pat_blood_type_serovar == '488') {
          complaints = this.setDataAddLine(
            BASIC_INFO_PAT_BLOOD_TYPE_SEROVAR,
            "Aend　Bend",
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        //add 9796データリスト画面で患者情報2のデータが表示されない。 zhao end
        let sysCountry = mstSysCountry.data.find(country => country.countryCdAlpha3 === x.nationality);
        if (sysCountry) {
          complaints = this.setDataAddLine(
            BASIC_INFO_NATIONALITY,
            sysCountry.countryName,
            hosp_pat_id,
            pat_name,
            complaints
          );
        } else {
          complaints = this.setDataAddLine(
            BASIC_INFO_NATIONALITY,
            "不明",
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        let pat_name_alpha = "";
        if (x.pat_first_name_alpha) {
          pat_name_alpha = pat_name_alpha + x.pat_first_name_alpha;
        }
        if (pat_name_alpha) {
          pat_name_alpha = pat_name_alpha + "　";
        }
        if (x.pat_last_name_alpha) {
          pat_name_alpha = pat_name_alpha + x.pat_last_name_alpha;
        }
        complaints = this.setDataAddLine(
          BASIC_INFO_PAT_NAME_ALPHA,
          pat_name_alpha,
          hosp_pat_id,
          pat_name,
          complaints
        );
        if (x.pat_contact_info) {
          let pat_contact_info = JSON.parse(x.pat_contact_info);
          complaints = this.setDataAddLine(
            BASIC_INFO_ADDRESS,
            pat_contact_info.address,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            BASIC_INFO_TEL1,
            pat_contact_info.tel1,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            BASIC_INFO_TEL2,
            pat_contact_info.tel2,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            BASIC_INFO_FAX,
            pat_contact_info.fax,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            BASIC_INFO_E_MAIL,
            pat_contact_info.e_mail,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            BASIC_INFO_MEMO1,
            pat_contact_info.memo1,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            BASIC_INFO_MEMO2,
            pat_contact_info.memo2,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }

        // 連絡先情報
        if (x.other_contact_info) {
          let other_contact_info = JSON.parse(x.other_contact_info);
          let patKeyPerson = '';
          let patId = '';
          let patName = '';
          let patFrigana = '';
          let patRelation = '';
          let patZip = '';
          let patAddress = '';
          let patTel1 = '';
          let patTel2 = '';
          let patFax = '';
          let patEmail = '';
          let patWorkName = '';
          let patWorkTel = '';
          let patMemo1 = '';
          let patMemo2 = '';
          other_contact_info.forEach(y => {
            // 連絡先_キーパーソン
            if (y.is_key_person == '1') {
              patKeyPerson = this.addLinePatInfoTwo(patKeyPerson, '〇');
            } else {
              patKeyPerson = this.addLinePatInfoTwo(patKeyPerson, '');
            }
            //連絡先_ID
            patId = this.addLinePatInfoTwo(patId, y.pat_id);
            //連絡先_氏名
            patName = this.addLinePatInfoTwo(
              patName,
              this.addBlank(y.last_name, y.first_name)
            );
            //連絡先_フリガナ
            patFrigana = this.addLinePatInfoTwo(
              patFrigana,
              this.addBlank(y.last_name_kana, y.first_name_kana)
            );
            //連絡先_続柄
            patRelation = this.addLinePatInfoTwo(patRelation, y.relation_name);
            //連絡先_郵便番号（ﾊｲﾌﾝなし）
            patZip = this.addLinePatInfoTwo(patZip, y.zip_cd);
            //連絡先_住所
            patAddress = this.addLinePatInfoTwo(patAddress, y.address);
            //連絡先_電話番号
            patTel1 = this.addLinePatInfoTwo(patTel1, y.tel1);
            //連絡先_電話番号2
            patTel2 = this.addLinePatInfoTwo(patTel2, y.tel2);
            //連絡先_FAX
            patFax = this.addLinePatInfoTwo(patFax, y.fax);
            //連絡先_Email
            patEmail = this.addLinePatInfoTwo(patEmail, y.e_mail);
            //連絡先_勤務先名
            patWorkName = this.addLinePatInfoTwo(patWorkName, y.work_name);
            //連絡先_勤務先電話番号
            patWorkTel = this.addLinePatInfoTwo(patWorkTel, y.work_tel);
            //連絡先_メモ1
            patMemo1 = this.addLinePatInfoTwo(patMemo1, y.memo1);
            //連絡先_メモ2
            patMemo2 = this.addLinePatInfoTwo(patMemo2, y.memo2);
          });
          complaints = this.setDataAddLine(
            PAT_KEY_PERSON_CD,
            patKeyPerson,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_ID_CD,
            patId,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_NAME_CD,
            patName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_FRIGANA_CD,
            patFrigana,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_RELATION_CD,
            patRelation,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_ZIP_CD,
            patZip,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_ADDRESS_CD,
            patAddress,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_TEL1_CD,
            patTel1,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_TEL2_CD,
            patTel2,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_FAX_CD,
            patFax,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_EMAIL_CD,
            patEmail,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_WORK_NAME_CD,
            patWorkName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_WORK_TEL_CD,
            patWorkTel,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO1_CD,
            patMemo1,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            PAT_MEMO2_CD,
            patMemo2,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        // 連絡先（業者）
        if (x.vendor_contact_info) {
          let vendor_contact_info = JSON.parse(x.vendor_contact_info);
          let vendorcontactCompanyName = '';
          let vendorcontactZip = '';
          let vendorcontactAddress = '';
          let vendorcontactCompanyTel = '';
          let vendorcontactFax = '';
          let vendorcontactWorkerName = '';
          let vendorcontactWorkerTel = '';
          let vendorcontactEmail = '';
          let vendorcontactMemo1 = '';
          let vendorcontactMemo2 = '';
          vendor_contact_info.forEach(y => {
            //連絡先（業者）_会社名
            vendorcontactCompanyName = this.addLinePatInfoTwo(
              vendorcontactCompanyName,
              y.company_name
            );
            //連絡先（業者）_郵便番号（ﾊｲﾌﾝなし）
            vendorcontactZip = this.addLinePatInfoTwo(vendorcontactZip, y.zip_cd);
            //連絡先（業者）_住所
            vendorcontactAddress = this.addLinePatInfoTwo(
              vendorcontactAddress,
              y.address
            );
            //連絡先（業者）_代表電話番号
            vendorcontactCompanyTel = this.addLinePatInfoTwo(
              vendorcontactCompanyTel,
              y.company_tel
            );
            //連絡先（業者）_代表者FAX
            vendorcontactFax = this.addLinePatInfoTwo(vendorcontactFax, y.fax);
            //連絡先（業者）_担当者名
            vendorcontactWorkerName = this.addLinePatInfoTwo(
              vendorcontactWorkerName,
              this.addBlank(y.worker_last_name, y.worker_first_name)
            );
            //連絡先（業者）_電話番号
            vendorcontactWorkerTel = this.addLinePatInfoTwo(
              vendorcontactWorkerTel,
              y.worker_tel
            );
            //連絡先（業者）_Email
            vendorcontactEmail = this.addLinePatInfoTwo(
              vendorcontactEmail,
              y.worker_e_mail
            );
            //連絡先（業者）_メモ1
            vendorcontactMemo1 = this.addLinePatInfoTwo(vendorcontactMemo1, y.memo1);
            //連絡先（業者）_メモ2
            vendorcontactMemo2 = this.addLinePatInfoTwo(vendorcontactMemo2, y.memo2);
          });
          complaints = this.setDataAddLine(
            VENDORCONTACT_COMPANY_NAME_CD,
            vendorcontactCompanyName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            VENDORCONTACT_ZIP_CD,
            vendorcontactZip,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            VENDORCONTACT_ADDRESS_CD,
            vendorcontactAddress,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            VENDORCONTACT_COMPANY_TEL_CD,
            vendorcontactCompanyTel,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            VENDORCONTACT_FAX_CD,
            vendorcontactFax,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            VENDORCONTACT_WORKER_NAME_CD,
            vendorcontactWorkerName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            VENDORCONTACT_WORKER_TEL_CD,
            vendorcontactWorkerTel,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            VENDORCONTACT_EMAIL_CD,
            vendorcontactEmail,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            VENDORCONTACT_MEMO1_CD,
            vendorcontactMemo1,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            VENDORCONTACT_MEMO2_CD,
            vendorcontactMemo2,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        // 保険情報
        // del bug #5213 修正 chen start
        // if (x.insurance_info) {
        //   let insurance_info = JSON.parse(x.insurance_info);
        //   let insuProvision = '';
        //   let insuNumber = '';
        //   let insuredSymbol = '';
        //   let insuredNumber = '';
        //   insurance_info.forEach(y => {
        //     //保険情報・保険_扶養区分
        //     switch (y.insurance_class) {
        //       case '0':
        //         insuProvision = this.addLine(insuProvision, '被保険者');
        //         break;
        //       case '1':
        //         insuProvision = this.addLine(insuProvision, '被扶養者');
        //         break;
        //       default:
        //         insuProvision = this.addUnderline(insuProvision);
        //     }
        //     //保険情報・保険_保険者番号
        //     insuNumber = this.addLine(insuNumber, y.insurance_no);
        //     //保険情報・保険_被保険者記号
        //     insuredSymbol = this.addLine(insuredSymbol, y.insured_cd);
        //     //保険情報・保険_被保険者番号
        //     insuredNumber = this.addLine(insuredNumber, y.insured_no);
        //   });
        //   complaints = this.setDataAddLine(
        //     INSU_PROVISION_CD,
        //     insuProvision,
        //     hosp_pat_id,
        //     pat_name,
        //     complaints
        //   );
        //   complaints = this.setDataAddLine(
        //     INSU_NUMBER_CD,
        //     insuNumber,
        //     hosp_pat_id,
        //     pat_name,
        //     complaints
        //   );
        //   complaints = this.setDataAddLine(
        //     INSURED_SYMBOL_CD,
        //     insuredSymbol,
        //     hosp_pat_id,
        //     pat_name,
        //     complaints
        //   );
        //   complaints = this.setDataAddLine(
        //     INSURED_NUMBER_CD,
        //     insuredNumber,
        //     hosp_pat_id,
        //     pat_name,
        //     complaints
        //   );
        // }
        // del bug #5213 修正 chen end
        // 透析困難情報
        if (x.dial_diff_com_info) {
          let dial_diff_com_info = JSON.parse(x.dial_diff_com_info);
          let insuDstMainReasons = '';
          let insuDstDialDiffComment = '';
          let insuDstLoginDate = '';
          dial_diff_com_info.forEach(y => {
            if (y.is_dial_diff === "1") {
              //透析困難_主たる理由
              if (y.is_main == '1') {
                insuDstMainReasons = this.addLinePatInfoTwo(insuDstMainReasons, '主');
              }
              let dialysisDifficulty = mst_dialysis_difficulty.find(country => country.code === y.dial_diff_cd);
              //透析困難_透析困難コメント
              //9796 データリスト画面で患者情報2のデータが表示されない。zhao start
              //   insuDstDialDiffComment = this.addLinePatInfoTwo(
              //   insuDstDialDiffComment,
              //   dialysisDifficulty.name
              // );
              // //透析困難_登録日時
              // /*mod FNSI-改修内容5217 任 start*/
              // /*insuDstLoginDate = this.addLine(insuDstLoginDate, y.reg_date);*/
              // insuDstLoginDate = this.addLinePatInfoTwo(insuDstLoginDate, dayjs(y.reg_date.substring(0, 8)).isValid()
              //   ? dayjs(y.reg_date.substring(0, 8)).format('YYYY/MM/DD')
              //   : '');
              if(dialysisDifficulty){
                insuDstDialDiffComment = this.addLinePatInfoTwo(
                  insuDstDialDiffComment,
                  dialysisDifficulty.name
                );
                //透析困難_登録日時
                /*mod FNSI-改修内容5217 任 start*/
                /*insuDstLoginDate = this.addLine(insuDstLoginDate, y.reg_date);*/
                insuDstLoginDate = this.addLinePatInfoTwo(insuDstLoginDate, dayjs(y.reg_date.substring(0, 8)).isValid()
                  ? dayjs(y.reg_date.substring(0, 8)).format('YYYY/MM/DD')
                  : '');
              }
              //9796 データリスト画面で患者情報2のデータが表示されない。zhao end
              /*mod FNSI-改修内容5217 任 end*/
            }
          });
          complaints = this.setDataAddLine(
            INSU_DST_MAIN_REASONS_CD,
            insuDstMainReasons,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_DST_DIAL_DIFF_COMMENT_CD,
            insuDstDialDiffComment,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_DST_LOGIN_DATE_CD,
            insuDstLoginDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        let insurances = patInsurances.filter(y => y.pat_id == x.pat_id);
        if (insurances.length > 0) {
          let insuName = '';
          let insuNameShort = '';
          let insuStartDate = '';
          let insuEndDate = '';
          let insuConfirmDate = '';
          let insuUserName = '';
          let insuLongHighPriceTreat = '';
          let insuLargePayer = '';
          let insuUndSix = '';
          let insuFutanG = '';
          let insuFutanN = '';
          let insuMemo1 = '';
          let insuMemo2 = '';
          let insuPublicName = '';
          let insuPublicNameShort = '';
          let insuPubName = '';
          let insuPubPassbookNo = '';
          let insuPubMemo1 = '';
          let insuPubMemo2 = '';
          let insuPublicStartDate = '';
          let insuPublicEndDate = '';
          let insuPublicConfirmDate = '';
          let insuPublicBurdenNum = '';
          let insuPublicRecipientNum = '';
          let insuSetName = '';
          let insuSetNameShort = '';
          let insuSetInsu = '';
          let insuSetPublic1 = '';
          let insuSetPublic2 = '';
          let insuSetPublic3 = '';
          let insuSetPublic4 = '';
          let insuSetMemo1 = '';
          let insuSetMemo2 = '';
          let insuExpenseName = '';
          let insuExpenseMemo1 = '';
          let insuExpenseMemo2 = '';
          // add bug #5213 修正 chen start
          let insuProvision = '';
          let insuNumber = '';
          let insuredSymbol = '';
          let insuredNumber = '';
          // add bug #5213 修正 chen end
          insurances.forEach(i => {
            if (i.insu_class == 0) {
              let insu_info = JSON.parse(i.insu_info);
              //保険情報・保険_保険名
              insuName = this.addLinePatInfoTwo(insuName, i.insu_name);
              //保険情報・保険_略称
              insuNameShort = this.addLinePatInfoTwo(insuNameShort, i.insu_name_short);
              //保険情報・保険_開始日
              /*mod FNSI-改修内容5217 任 start*/
              /*insuStartDate = this.addLine(insuStartDate, i.start_date);*/
              insuStartDate = this.addLinePatInfoTwo(insuStartDate, dayjs(i.start_date).isValid()
                ? dayjs(i.start_date).format('YYYY/MM/DD')
                : '');
              /*mod FNSI-改修内容5217 任 end*/
              //保険情報・保険_終了日
              /*mod FNSI-改修内容5217 任 start*/
              /*insuEndDate = this.addLine(insuEndDate, i.end_date);*/
              insuEndDate = this.addLinePatInfoTwo(insuEndDate, dayjs(i.end_date).isValid()
                ? dayjs(i.end_date).format('YYYY/MM/DD')
                : '');
              /*mod FNSI-改修内容5217 任 end*/
              //保険情報・保険_確認日
              /*mod FNSI-改修内容5217 任 start*/
              /*insuConfirmDate = this.addLine(insuConfirmDate, i.check_date);*/
              insuConfirmDate = this.addLinePatInfoTwo(insuConfirmDate, dayjs(i.check_date).isValid()
                ? dayjs(i.check_date).format('YYYY/MM/DD')
                : '');
              /*mod FNSI-改修内容5217 任 end*/
              //保険情報・保険_保険者名称
              insuUserName = this.addLinePatInfoTwo(
                insuUserName,
                insu_info ? insu_info.insu_pat_name : null
              );
              // add bug #5213 修正 chen start
              //保険情報・保険_扶養区分
              switch (insu_info.insu_kbn + "") {
                case '0':
                  insuProvision = this.addLinePatInfoTwo(insuProvision, '被保険者');
                  break;
                case '1':
                  insuProvision = this.addLinePatInfoTwo(insuProvision, '被扶養者');
                  break;
                default:
                  insuProvision = this.addLinePatInfoTwo(insuProvision, ' ');
              }
              //保険情報・保険_保険者番号
              insuNumber = this.addLinePatInfoTwo(insuNumber, insu_info.insu_no);
              //保険情報・保険_被保険者記号
              insuredSymbol = this.addLinePatInfoTwo(insuredSymbol, insu_info.insu_pat_mark);
              //保険情報・保険_被保険者番号
              insuredNumber = this.addLinePatInfoTwo(insuredNumber, insu_info.insu_pat_no);
              if (insu_info.und_six === "0") {
                insuUndSix = this.addLinePatInfoTwo(insuUndSix, "対象外");
              } else if (insu_info.und_six === "1") {
                insuUndSix = this.addLinePatInfoTwo(insuUndSix, "対象");
              } else {
                insuUndSix = this.addLinePatInfoTwo(insuUndSix, " ");
              }
              insuFutanG = this.addLinePatInfoTwo(insuFutanG, insu_info["futan-g"]);
              insuFutanN = this.addLinePatInfoTwo(insuFutanN, insu_info["futan-n"]);
              insuMemo1 = this.addLinePatInfoTwo(insuMemo1, i.memo1);
              insuMemo2 = this.addLinePatInfoTwo(insuMemo2, i.memo2);
              // add bug #5213 修正 chen end
              //保険情報・保険_長期高額療養
              if (insu_info) {
                if (insu_info.cki_class == '0') {
                  insuLongHighPriceTreat = this.addLinePatInfoTwo(
                    insuLongHighPriceTreat,
                    '対象外'
                  );
                } else if (insu_info.cki_class == '1') {
                  insuLongHighPriceTreat = this.addLinePatInfoTwo(
                    insuLongHighPriceTreat,
                    '対象者'
                  );
                } else if (insu_info.cki_class == '2') {
                  insuLongHighPriceTreat = this.addLinePatInfoTwo(
                    insuLongHighPriceTreat,
                    '１０００円対象者'
                  );
                } else if (insu_info.cki_class == '3') {
                  insuLongHighPriceTreat = this.addLinePatInfoTwo(
                    insuLongHighPriceTreat,
                    '２０００円対象者'
                  );
                } else {
                  insuLongHighPriceTreat = this.addLinePatInfoTwo(
                    insuLongHighPriceTreat,
                    ' '
                  );
                }
                //保険情報・保険_高額受給者又は
                if (insu_info.kki_class == '0') {
                  insuLargePayer = this.addLinePatInfoTwo(insuLargePayer, '対象外');
                } else if (insu_info.kki_class == '1') {
                  insuLargePayer = this.addLinePatInfoTwo(insuLargePayer, '一般・低所得');
                  // add #11528 【たくしん会】データリスト並び順不正 房 start
                } else if (insu_info.kki_class == '2') {
                  insuLargePayer = this.addLinePatInfoTwo(insuLargePayer, '7割給付');
                  // add #11528 【たくしん会】データリスト並び順不正 房 end
                } else {
                  insuLargePayer = this.addLinePatInfoTwo(insuLargePayer, ' ');
                }
              }
            } else if (i.insu_class == 1) {
              //保険情報・公費_公費名
              insuPublicName = this.addLinePatInfoTwo(insuPublicName, i.insu_name);
              //保険情報・公費_略称
              insuPublicNameShort = this.addLinePatInfoTwo(
                insuPublicNameShort,
                i.insu_name_short
              );
              //保険情報・公費_開始日
              insuPublicStartDate = this.addLinePatInfoTwo(
                insuPublicStartDate,
                /*mod FNSI-改修内容5217 任 start*/
                /*i.start_date*/
                dayjs(i.start_date).isValid()
                  ? dayjs(i.start_date).format('YYYY/MM/DD')
                  : ''
                /*mod FNSI-改修内容5217 任 end*/
              );
              //保険情報・公費_終了日
              /*mod FNSI-改修内容5217 任 start*/
              /*insuPublicEndDate = this.addLine(insuPublicEndDate, i.end_date);*/
              insuPublicEndDate = this.addLinePatInfoTwo(insuPublicEndDate, dayjs(i.end_date).isValid()
                ? dayjs(i.end_date).format('YYYY/MM/DD')
                : '');
              /*mod FNSI-改修内容5217 任 end*/
              //保険情報・公費_確認日
              insuPublicConfirmDate = this.addLinePatInfoTwo(
                insuPublicConfirmDate,
                /*mod FNSI-改修内容5217 任 start*/
                /*i.check_date*/
                dayjs(i.check_date).isValid()
                  ? dayjs(i.check_date).format('YYYY/MM/DD')
                  : ''
                /*mod FNSI-改修内容5217 任 end*/
              );
              let insu_pub_info = JSON.parse(i.insu_pub_info);
              if (insu_pub_info) {
                //保険情報・公費_負担者番号
                insuPublicBurdenNum = this.addLinePatInfoTwo(
                  insuPublicBurdenNum,
                  insu_pub_info.insu_pub_no
                );
                //保険情報・公費_受給者番号
                insuPublicRecipientNum = this.addLinePatInfoTwo(
                  insuPublicRecipientNum,
                  insu_pub_info.insu_pub_pat_no
                );
                insuPubName = this.addLinePatInfoTwo(insuPubName, insu_pub_info.insu_pub_name);
                insuPubPassbookNo = this.addLinePatInfoTwo(insuPubPassbookNo, insu_pub_info.passbook_no);
              }
              insuPubMemo1 = this.addLinePatInfoTwo(insuPubMemo1, i.memo1);
              insuPubMemo2 = this.addLinePatInfoTwo(insuPubMemo2, i.memo2);
            } else if (i.insu_class == 2) {
              //保険情報・セット_セット名
              insuSetName = this.addLinePatInfoTwo(insuSetName, i.insu_name);
              insuSetMemo1 = this.addLinePatInfoTwo(insuSetMemo1, i.memo1);
              insuSetMemo2 = this.addLinePatInfoTwo(insuSetMemo2, i.memo2);
              //保険情報・セット_略称
              insuSetNameShort = this.addLinePatInfoTwo(
                insuSetNameShort,
                i.insu_name_short
              );
              let insu_set_info = JSON.parse(i.insu_set_info);
              if (insu_set_info) {
                //保険情報・セット_保険
                let mstInsurance = patInsurances.find(
                  n => n.insurance_cd == insu_set_info.insu_cd
                );
                if (mstInsurance) {
                  insuSetInsu = this.addLinePatInfoTwo(insuSetInsu, mstInsurance.insu_name);
                }
                //保険情報・セット_公費1
                let mstInsurance1 = patInsurances.find(
                  n => n.insurance_cd + "" == insu_set_info.insu_pub1_cd + ""
                );
                if (mstInsurance1) {
                  insuSetPublic1 = this.addLinePatInfoTwo(
                    insuSetPublic1,
                    mstInsurance1.insu_name
                  );
                }
                //保険情報・セット_公費2
                let mstInsurance2 = patInsurances.find(
                  n => n.insurance_cd + "" == insu_set_info.insu_pub2_cd + ""
                );
                if (mstInsurance2) {
                  insuSetPublic2 = this.addLinePatInfoTwo(
                    insuSetPublic2,
                    mstInsurance2.insu_name
                  );
                }
                //保険情報・セット_公費3
                let mstInsurance3 = patInsurances.find(
                  n => n.insurance_cd + "" == insu_set_info.insu_pub3_cd + ""
                );
                if (mstInsurance3) {
                  insuSetPublic3 = this.addLinePatInfoTwo(
                    insuSetPublic3,
                    mstInsurance3.insu_name
                  );
                }
                //保険情報・セット_公費4
                let mstInsurance4 = patInsurances.find(
                  n => n.insurance_cd + "" == insu_set_info.insu_pub4_cd + ""
                );
                if (mstInsurance4) {
                  insuSetPublic4 = this.addLinePatInfoTwo(
                    insuSetPublic4,
                    mstInsurance4.insu_name
                  );
                }
              }
            } else if (i.insu_class == 3) {
              //保険情報・自費_名称
              insuExpenseName = this.addLinePatInfoTwo(insuExpenseName, i.insu_name);
              insuExpenseMemo1 = this.addLinePatInfoTwo(insuExpenseMemo1, i.memo1);
              insuExpenseMemo2 = this.addLinePatInfoTwo(insuExpenseMemo2, i.memo2);
            }
          });
          complaints = this.setDataAddLine(
            INSU_NAME_CD,
            insuName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_NAME_SHORT_CD,
            insuNameShort,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_START_DATE_CD,
            insuStartDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_END_DATE_CD,
            insuEndDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_CONFIRM_DATE_CD,
            insuConfirmDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_USER_NAME_CD,
            insuUserName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          // add bug #5213 修正 chen start
          complaints = this.setDataAddLine(
            INSU_PROVISION_CD,
            insuProvision,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_NUMBER_CD,
            insuNumber,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSURED_SYMBOL_CD,
            insuredSymbol,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSURED_NUMBER_CD,
            insuredNumber,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_UND_SIX_CD,
            insuUndSix,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_FUTAN_G_CD,
            insuFutanG,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_FUTAN_N_CD,
            insuFutanN,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_INSURANCE_MEMO1_CD,
            insuMemo1,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_INSURANCE_MEMO2_CD,
            insuMemo2,
            hosp_pat_id,
            pat_name,
            complaints
          );
          // add bug #5213 修正 chen end
          complaints = this.setDataAddLine(
            INSU_LONG_HIGH_PRICE_TREAT_CD,
            insuLongHighPriceTreat,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_LARGE_PAYER_CD,
            insuLargePayer,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_PUBLIC_NAME_CD,
            insuPublicName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_PUBLIC_NAME_SHORT_CD,
            insuPublicNameShort,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_PUBLIC_START_DATE_CD,
            insuPublicStartDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_PUBLIC_END_DATE_CD,
            insuPublicEndDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_PUBLIC_CONFIRM_DATE_CD,
            insuPublicConfirmDate,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_PUBLIC_BURDEN_NUM_CD,
            insuPublicBurdenNum,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_PUBLIC_RECIPIENT_NUM_CD,
            insuPublicRecipientNum,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_PUBLIC_PUB_NAME_CD,
            insuPubName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_PUBLIC_DISABILITY_NO_CD,
            insuPubPassbookNo,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_PUBLIC_INSURANCE_MEMO1_CD,
            insuPubMemo1,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_PUBLIC_INSURANCE_MEMO2_CD,
            insuPubMemo2,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_SET_NAME_CD,
            insuSetName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_SET_NAME_SHORT_CD,
            insuSetNameShort,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_SET_INSU_CD,
            insuSetInsu,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_SET_PUBLIC1_CD,
            insuSetPublic1,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_SET_PUBLIC2_CD,
            insuSetPublic2,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_SET_PUBLIC3_CD,
            insuSetPublic3,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_SET_PUBLIC4_CD,
            insuSetPublic4,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_SET_INSURANCE_MEMO1_CD,
            insuSetMemo1,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_SET_INSURANCE_MEMO2_CD,
            insuSetMemo2,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_EXPENSE_NAME_CD,
            insuExpenseName,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_EXPENSE_INSURANCE_MEMO1_CD,
            insuExpenseMemo1,
            hosp_pat_id,
            pat_name,
            complaints
          );
          complaints = this.setDataAddLine(
            INSU_EXPENSE_INSURANCE_MEMO2_CD,
            insuExpenseMemo2,
            hosp_pat_id,
            pat_name,
            complaints
          );
        }
        this.firstFlg = true;
      });
      return complaints;
    },

    setData(code, complaints, monitor_data, hosp_pat_id, pat_name, date, ctl_no) {
      let list = this.idList.map(y => {
        if (y.data_list_detail_cd == code) {
          return y.items + "";
        }
      });
      list = list.filter(y => y);
      if (list.length > 0) {
        list = list.flat();
        monitor_data = JSON.parse(monitor_data);
        list.forEach(item => {
          item.split(',').forEach(y => {
            if (monitor_data[y]) {
              let valueTmp = monitor_data[y];
              if (y + '' === "31") {
                switch (monitor_data[y] + "") {
                  case "0":
                    valueTmp = "HD";
                    break;
                  case "1":
                    valueTmp = "ECUM";
                    break;
                  case "2":
                    valueTmp = "HDF";
                    break;
                  case "3":
                    valueTmp = "HF";
                    break;
                  case "4":
                    valueTmp = "HD+補液";
                    break;
                  case "6":
                    valueTmp = "AFBF";
                    break;
                  case "7":
                    valueTmp = "OHDF";
                    break;
                  case "8":
                    valueTmp = "OHF";
                    break;
                  case "9":
                    valueTmp = "特殊血液浄化";
                    break;
                  case "10":
                    valueTmp = "I-HDF";
                    break;
                }
              }
              if (y + '' === "0") {
                switch (monitor_data[y] + "") {
                  case "1":
                    valueTmp = "プリセット";
                    break;
                  case "2":
                    valueTmp = "洗浄";
                    break;
                  case "3":
                    valueTmp = "酸洗";
                    break;
                  case "4":
                    valueTmp = "消毒";
                    break;
                  case "5":
                    valueTmp = "滞留";
                    break;
                  case "6":
                    valueTmp = "液置換";
                    break;
                  case "7":
                    valueTmp = "準備回収";
                    break;
                  case "8":
                    valueTmp = "ガスパージ";
                    break;
                  case "9":
                    valueTmp = "排液";
                    break;
                  case "10":
                    valueTmp = "停止";
                    break;
                  case "11":
                    valueTmp = "運転";
                    break;
                }
              }
              let yTmp = y + "";
              yTmp = yTmp.replace("[", "");
              yTmp = yTmp.replace("]", "");
              let m = {
                hosp_pat_id: hosp_pat_id,
                pat_name: pat_name,
                data_list_detail_cd: code,
                id: yTmp.replace('-', 'minus'),
                value: valueTmp,
                datetime: date,
                ctl_no: ctl_no,
              };
              complaints.push(m);
            }
          });
        });
      }
      return complaints;
    },

    // add bug 7578 修正 chen start
    setDataMonitor(code, complaints, monitor_data, hosp_pat_id, pat_name, date, ctl_no, ind_date) {
      let list = this.idList.map(y => {
        if (y.data_list_detail_cd == code) {
          return y.items + "";
        }
      });
      list = list.filter(y => y);
      if (list.length > 0) {
        list = list.flat();
        monitor_data = JSON.parse(monitor_data);
        list.forEach(item => {
          item.split(',').forEach(y => {
            if (monitor_data[y]) {
              let valueTmp = monitor_data[y];
              if (y + '' === "31") {
                switch (monitor_data[y] + "") {
                  case "0":
                    valueTmp = "HD";
                    break;
                  case "1":
                    valueTmp = "ECUM";
                    break;
                  case "2":
                    valueTmp = "HDF";
                    break;
                  case "3":
                    valueTmp = "HF";
                    break;
                  case "4":
                    valueTmp = "HD+補液";
                    break;
                  case "6":
                    valueTmp = "AFBF";
                    break;
                  case "7":
                    valueTmp = "OHDF";
                    break;
                  case "8":
                    valueTmp = "OHF";
                    break;
                  case "9":
                    valueTmp = "特殊血液浄化";
                    break;
                  case "10":
                    valueTmp = "I-HDF";
                    break;
                }
              }
              if (y + '' === "0") {
                switch (monitor_data[y] + "") {
                  case "1":
                    valueTmp = "プリセット";
                    break;
                  case "2":
                    valueTmp = "洗浄";
                    break;
                  case "3":
                    valueTmp = "酸洗";
                    break;
                  case "4":
                    valueTmp = "消毒";
                    break;
                  case "5":
                    valueTmp = "滞留";
                    break;
                  case "6":
                    valueTmp = "液置換";
                    break;
                  case "7":
                    valueTmp = "準備回収";
                    break;
                  case "8":
                    valueTmp = "ガスパージ";
                    break;
                  case "9":
                    valueTmp = "排液";
                    break;
                  case "10":
                    valueTmp = "停止";
                    break;
                  case "11":
                    valueTmp = "運転";
                    break;
                }
              }
              // 1: 経過時間
              // 2: 経過時間（ＥＣＵＭ）
              // 3: 残り時間（除水完了）
              // 4: 残り時間（透析完了）
              // 78: 残り時間（補液完了）
              // 「分」で登録されている値を「時分」に変換して表示 ※列ヘッダーの単位と合わせる
              if (["1", "2", "3", "4", "78"].includes(y + '')) {
                valueTmp = dateFormat.mChar2time(valueTmp);
              }
              let yTmp = y + "";
              yTmp = yTmp.replace("[", "");
              yTmp = yTmp.replace("]", "");
              let m = {
                hosp_pat_id: hosp_pat_id,
                pat_name: pat_name,
                data_list_detail_cd: code,
                id: yTmp.replace('-', 'minus'),
                value: valueTmp,
                datetime: date,
                ind_date: ind_date,
                ctl_no: ctl_no,
              };
              complaints.push(m);
            }
          });
        });
      }
      return complaints;
    },
    // add bug 7578 修正 chen end
    /*add FNSI-改修内容5237 任 start*/
    getDecimalValue(editedValue,number){
      // mod #9973 shiyw start
      //if (!editedValue && editedValue !== 0) {
      if (!editedValue && editedValue != 0) {
        // mod #9973 shiyw start
        return "";
      }
      let resultFigure = editedValue
      let num = '1';
      for(let i = 0;i<number;i++){
        num += '0';
      }
      let f_x = Math.round(editedValue * parseInt(num)) / parseInt(num);
      let s_x = f_x.toString();
      let pos_decimal = s_x.indexOf('.');
      if (pos_decimal < 0) {
        pos_decimal = s_x.length;
        s_x += '.';
      }
      while (s_x.length <= pos_decimal + number) {
        s_x += '0';
      }
      resultFigure = s_x;
      return resultFigure;
    },
    /*add FNSI-改修内容5237 任 end*/
    // 検査・放射線
    getInspectionData(data,responseFigure) {
      let templatePatExamMains = data.templatePatExamMains;
      let patInfo = data.patInfo;
      patInfo = this.setPatInfo(patInfo);
      this.patInfoList = patInfo;
      let complaints = [];
      let count = 0;
      // templateOrdMainsから必要な項目を抽出し、ord_noで昇順ソートする
      const ordMains = data.templateOrdMains.map(item => ({
        pat_id: item.pat_id,
        ord_no: item.ord_no,
        treat_date: item.treat_date
      })).sort((a, b) => a.ord_no - b.ord_no);

      templatePatExamMains.forEach(x => {
        let nameList = patInfo.filter(y => y.pat_id == x.pat_id);
        let hosp_pat_id = '';
        let pat_name = '';
        if (nameList.length > 0) {
          hosp_pat_id = nameList[0].hosp_pat_id;
          pat_name = nameList[0].pat_name;
        }
        if (x.exam_result_info) {
          let exam_result_info = JSON.parse(x.exam_result_info);
          const resultExamDate = new Date(x.result_exam_date);
          const _resultExamDate = resultExamDate.toISOString().slice(0, 10).replace(/-/g, '');
          const ordMain = ordMains.find(item => item.pat_id === x.pat_id && item.treat_date === _resultExamDate);

          exam_result_info.forEach(y => {
            /*add FNSI-改修内容5237 任 start*/
            let resultFigure = y.result
            //del #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
            // if (resultFigure) {
            //   responseFigure.data.forEach(item => {
            //     if(item.examItemCd.toString() === y.item_cd){
            //       let num = '1';
            //       for(let i = 0;i<item.inputDecimalFigure;i++){
            //         num += '0';
            //       }
            //       let f_x = Math.round(y.result * parseInt(num)) / parseInt(num);
            //       let s_x = f_x.toString();
            //       let pos_decimal = s_x.indexOf('.');
            //       if (pos_decimal < 0 && item.inputDecimalFigure > 0) {
            //         pos_decimal = s_x.length;
            //         s_x += '.';
            //       }
            //       while (s_x.length <= pos_decimal + item.inputDecimalFigure) {
            //         s_x += '0';
            //       }
            //       resultFigure = s_x;
            //     }
            //   })
            // }
            //del #10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
            /*add FNSI-改修内容5237 任 end*/
            count += 1;
            // 検査日時
            complaints = this.setComplaintsDatahasDate(
              RESULT_DATE_CD,
              dayjs(y.result_date).isValid()
                ? dayjs(y.result_date).format('YYYY/MM/DD HH:mm:ss')
                : '',
              hosp_pat_id,
              pat_name,
              count,
              complaints
            );
            // オーダー番号
            complaints = this.setComplaintsDatahasDate(
              ORD_NO,
              ordMain ? ordMain.ord_no : "",
              hosp_pat_id,
              pat_name,
              count,
              complaints
            );
            // 検査区分
            switch (x.reg_order_class + "") {
              case '0':
                complaints = this.setComplaintsDatahasDate(
                  EXAM_CLASS_CD,
                  'その他',
                  hosp_pat_id,
                  pat_name,
                  count,
                  complaints
                );
                break;
              case '1':
                complaints = this.setComplaintsDatahasDate(
                  EXAM_CLASS_CD,
                  '透析前',
                  hosp_pat_id,
                  pat_name,
                  count,
                  complaints
                );
                break;
              case '2':
                complaints = this.setComplaintsDatahasDate(
                  EXAM_CLASS_CD,
                  '透析後',
                  hosp_pat_id,
                  pat_name,
                  count,
                  complaints
                );
                break;

              default:
                break;
            }
            // 検査項目名
            complaints = this.setComplaintsDatahasDate(
              ITEM_NAME_CD,
              y.item_name,
              hosp_pat_id,
              pat_name,
              count,
              complaints
            );
            // 表示順
            complaints = this.setComplaintsDatahasDate(
              ITEM_DISP_ORDER,
              y.disp_order,
              hosp_pat_id,
              pat_name,
              count,
              complaints
            );
            // 検査結果
            complaints = this.setComplaintsDatahasDate(
              RESULT_CD,
              // mod #11718 【#11600持ち越し】データリスト画面不正② fang start
              resultFigure && !isNaN(resultFigure) ? Number(resultFigure).toFixed(2) : '0.00',
              // mod #11718 【#11600持ち越し】データリスト画面不正② fang end
              hosp_pat_id,
              pat_name,
              count,
              complaints
            );
            // 正常値（下限）
            complaints = this.setComplaintsDatahasDate(
              LOWER_CD,
              y.lower && y.lower != 'null' ? Number(y.lower).toFixed(2) : '0.00',
              hosp_pat_id,
              pat_name,
              count,
              complaints
            );
            // 正常値（上限）
            complaints = this.setComplaintsDatahasDate(
              UPPER_CD,
              y.upper && y.upper != 'null' ? Number(y.upper).toFixed(2) : '0.00',
              hosp_pat_id,
              pat_name,
              count,
              complaints
            );
            // 単位
            complaints = this.setComplaintsDatahasDate(
              UNIT_CD,
              y.unit,
              hosp_pat_id,
              pat_name,
              count,
              complaints
            );
            // コメント
            complaints = this.setComplaintsDatahasDate(
              FREEMEMO_CD,
              y.freememo,
              hosp_pat_id,
              pat_name,
              count,
              complaints
            );
            // 更新日時
            complaints = this.setComplaintsDatahasDate(
              UP_DATE_CD,
              dayjs(x.up_date).isValid()
                ? dayjs(x.up_date).format('YYYY/MM/DD HH:mm:ss')
                : '',
              hosp_pat_id,
              pat_name,
              count,
              complaints
            );
          });
        }
      });
      return complaints;
    },
    // 装置設定
    getDeviceSetData(data) {
      let deviceSetInfo = data.patMains.map(x => {
        let y = {
          pat_id: x.pat_id,
          device_set_info: x.device_set_info,
          host_notification_info: x.host_notification_info,
          acceptance_status_info: x.acceptance_status_info,
        };
        return y;
      });
      let patInfo = data.patInfo;
      patInfo = this.setPatInfo(patInfo);
      this.patInfoList = patInfo;
      let complaints = [];
      deviceSetInfo.forEach(x => {
        let nameList = patInfo.filter(y => y.pat_id == x.pat_id);
        let hosp_pat_id = '';
        let pat_name = '';
        if (nameList.length > 0) {
          hosp_pat_id = nameList[0].hosp_pat_id;
          pat_name = nameList[0].pat_name;
        }
        // NOTE: 治療進捗状態から最新の治療状況のord_noを取得する
        const acceptanceStatusInfo = JSON.parse(x.acceptance_status_info);
        let ord_no;
        if (acceptanceStatusInfo.length > 0) {
          const latestEntry = acceptanceStatusInfo.reduce((latest, current) => {
            return new Date(current.start_date_time) > new Date(latest.start_date_time) ? current : latest;
          });
          ord_no = latestEntry.ord_no;
        }
        if (x.device_set_info) {
          let device_set_info = JSON.parse(x.device_set_info);
          if (
            device_set_info.ope &&
            device_set_info.ope.dev &&
            device_set_info.ope.dev.A
          ) {
            // NOTE: ord_noが設定されていた場合、配列に追加する
            if (ord_no) {
              complaints = this.setComplaintsData(
                ORD_NO,
                ord_no,
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            // 血流量操作範囲上限
            complaints = this.setComplaintsData(
              BLOOD_FLOW_UPPER_CD,
              this.addUnits(device_set_info.ope.dev.A[179], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // 除水速度操作範囲上限
            complaints = this.setComplaintsData(
              WATER_REMOVE_RATE_UPPER_CD,
              /*mod FNSI-改修内容5237 任 start*/
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.A[181],2), ' L/h'),
              /*mod FNSI-改修内容5237 任 end*/
              hosp_pat_id,
              pat_name,
              complaints
            );
            //動脈側気泡検出器
            if (device_set_info.ope.dev.A[38] == '0') {
              complaints = this.setComplaintsData(
                ARTER_BUBBLE_DETECTOR_CD,
                '切り',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.ope.dev.A[38] == '1') {
              complaints = this.setComplaintsData(
                ARTER_BUBBLE_DETECTOR_CD,
                '入り',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //除水計算選択
            if (device_set_info.ope.dev.A[21] == '0') {
              complaints = this.setComplaintsData(
                WATER_REMOVE_CAL_SELECTION_CD,
                '透析時間',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.ope.dev.A[21] == '1') {
              complaints = this.setComplaintsData(
                WATER_REMOVE_CAL_SELECTION_CD,
                '設定時刻',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //除水計算優先項目選択
            if (device_set_info.ope.dev.A[22] == '0') {
              complaints = this.setComplaintsData(
                WATER_REMOVE_CAL_PRIORIT_SELECTION_CD,
                '除水速度算出',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.ope.dev.A[22] == '1') {
              complaints = this.setComplaintsData(
                WATER_REMOVE_CAL_PRIORIT_SELECTION_CD,
                '除水量設定算出',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //除水開始遅延時間
            complaints = this.setComplaintsData(
              WATER_REMOVE_DELAY_TIME_CD_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.ope.dev.A[39], ' min'),
              this.addUnits(device_set_info.ope.dev.A[39], ' 分'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //透析液温度操作範囲上限
            complaints = this.setComplaintsData(
              DIALYSATE_TEMPERATURE_UPPER_CD,
              /*mod FNSI-改修内容5237 任 start*/
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.A[182],1), ' ℃'),
              /*mod FNSI-改修内容5237 任 end*/
              hosp_pat_id,
              pat_name,
              complaints
            );
            //透析液温度操作範囲下限
            complaints = this.setComplaintsData(
              DIALYSATE_TEMPERATURE_LOWER_CD,
              /*mod FNSI-改修内容5237 任 start*/
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.A[183],1), ' ℃'),
              /*mod FNSI-改修内容5237 任 emd*/
              hosp_pat_id,
              pat_name,
              complaints
            );
            //透析液流量 設定方法
            if (device_set_info.ope.dev.A[268] == '1') {
              complaints = this.setComplaintsData(
                DIALYSATE_FLOW_SET_MODE_CD,
                '流量設定',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.ope.dev.A[268] == '2') {
              complaints = this.setComplaintsData(
                DIALYSATE_FLOW_SET_MODE_CD,
                '比率設定',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //透析液流量 比率設定
            complaints = this.setComplaintsData(
              DIALYSATE_RATE_CD,
              /*mod FNSI-改修内容5237 任 start*/
              this.getDecimalValue(device_set_info.ope.dev.A[269],1),
              /*mod FNSI-改修内容5237 任 end*/
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル切替圧上限
            complaints = this.setComplaintsData(
              SINGLE_NEEDLE_SWITCH_PRESSURE_UPPER_CD,
              this.addUnits(device_set_info.ope.dev.A[24], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル切替圧下限
            complaints = this.setComplaintsData(
              SINGLE_NEEDLE_SWITCH_PRESSURE_LOWER_CD,
              this.addUnits(device_set_info.ope.dev.A[25], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＴＭＰゼロ補正の選択
            if (device_set_info.ope.dev.A[241] == '0') {
              complaints = this.setComplaintsData(
                TMP_ZERO_CORRECT_SELECT_CD,
                'あり',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.ope.dev.A[241] == '1') {
              complaints = this.setComplaintsData(
                TMP_ZERO_CORRECT_SELECT_CD,
                'なし',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //ＴＭＰゼロ補正警報上限HD
            complaints = this.setComplaintsData(
              TMP_ZERO_CORRECT_WARNING_UPPER_HD_CD,
              this.addUnits(device_set_info.ope.dev.A[168], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＴＭＰゼロ補正警報下限HD
            complaints = this.setComplaintsData(
              TMP_ZERO_CORRECT_WARNING_LOWER_HD_CD,
              this.addUnits(device_set_info.ope.dev.A[169], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＴＭＰゼロ補正警報上限ECUM
            complaints = this.setComplaintsData(
              TMP_ZERO_CORRECT_WARNING_UPPER_ECUM_CD,
              this.addUnits(device_set_info.ope.dev.A[171], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＴＭＰゼロ補正警報下限ECUM
            complaints = this.setComplaintsData(
              TMP_ZERO_CORRECT_WARNING_LOWER_ECUM_CD,
              this.addUnits(device_set_info.ope.dev.A[172], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＴＭＰゼロ補正警報上限HDF
            complaints = this.setComplaintsData(
              TMP_ZERO_CORRECT_WARNING_UPPER_HDF_CD,
              this.addUnits(device_set_info.ope.dev.A[174], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＴＭＰゼロ補正警報下限HDF
            complaints = this.setComplaintsData(
              TMP_ZERO_CORRECT_WARNING_LOWER_HDF_CD,
              this.addUnits(device_set_info.ope.dev.A[175], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＴＭＰゼロ補正警報上限HF
            complaints = this.setComplaintsData(
              TMP_ZERO_CORRECT_WARNING_UPPER_HF_CD,
              this.addUnits(device_set_info.ope.dev.A[177], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＴＭＰゼロ補正警報下限HF
            complaints = this.setComplaintsData(
              TMP_ZERO_CORRECT_WARNING_LOWER_HF_CD,
              this.addUnits(device_set_info.ope.dev.A[178], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＴＭＰゼロ補正警報上限OHDF
            complaints = this.setComplaintsData(
              TMP_ZERO_CORRECT_WARNING_UPPER_OHHDF_CD,
              this.addUnits(device_set_info.ope.dev.A[391], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＴＭＰゼロ補正警報下限OHDF
            complaints = this.setComplaintsData(
              TMP_ZERO_CORRECT_WARNING_LOWER_OHHDF_CD,
              this.addUnits(device_set_info.ope.dev.A[392], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＴＭＰゼロ補正警報上限OHF
            complaints = this.setComplaintsData(
              TMP_ZERO_CORRECT_WARNING_UPPER_OHF_CD,
              this.addUnits(device_set_info.ope.dev.A[394], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＴＭＰゼロ補正警報下限OHF
            complaints = this.setComplaintsData(
              TMP_ZERO_CORRECT_WARNING_LOWER_OHF_CD,
              this.addUnits(device_set_info.ope.dev.A[395], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //補液量設定値制限（OHDF・OHF用）
            complaints = this.setComplaintsData(
              OHDF_OHF_IV_SETTING_LIMIT_CD,
              /*mod FNSI-改修内容5237 任 start*/
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.A[383],1), ' L'),
              /*mod FNSI-改修内容5237 任 end*/
              hosp_pat_id,
              pat_name,
              complaints
            );
            //補液計算優先項目（OHDF・OHF用）
            if (device_set_info.ope.dev.A[389] == '0') {
              complaints = this.setComplaintsData(
                OHDF_OHF_IV_PRI_CALC_ITEM_CD,
                '補液速度算出',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.ope.dev.A[389] == '1') {
              complaints = this.setComplaintsData(
                OHDF_OHF_IV_PRI_CALC_ITEM_CD,
                '補液量設定算出',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.ope.dev.A[389] == '2') {
              complaints = this.setComplaintsData(
                OHDF_OHF_IV_PRI_CALC_ITEM_CD,
                '補液比率',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.ope.dev.A[389] == '3') {
              complaints = this.setComplaintsData(
                OHDF_OHF_IV_PRI_CALC_ITEM_CD,
                '濾過率から算出',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //OHDF 補液速度比率 前補液
            complaints = this.setComplaintsData(
              OHDF_IV_SPEED_RATE_BEFORE_CD,
              this.addUnits(device_set_info.ope.dev.A[379], ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //OHDF 補液速度比率 後補液
            complaints = this.setComplaintsData(
              OHDF_IV_SPEED_RATE_AFTER_CD,
              this.addUnits(device_set_info.ope.dev.B[39], ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //補液開始遅延時間
            complaints = this.setComplaintsData(
              IV_START_DELAY_TIME_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.ope.dev.A[398], ' min'),
              this.addUnits(device_set_info.ope.dev.A[398], ' 分'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //DP=Qd+Qs(補液速度加算)
            if (device_set_info.ope.dev.A[369] == '1') {
              complaints = this.setComplaintsData(
                DP_IV_ADD_RATE_CD,
                '使用しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.ope.dev.A[369] == '2') {
              complaints = this.setComplaintsData(
                DP_IV_ADD_RATE_CD,
                '使用する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //濾過率 前補液
            complaints = this.setComplaintsData(
              FILTER_RATE_IV_BEFORE_CD,
              this.addUnits(device_set_info.ope.dev.A[90], ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //濾過率 後補液
            complaints = this.setComplaintsData(
              FILTER_RATE_IV_AFTER_CD,
              this.addUnits(device_set_info.ope.dev.B[40], ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ヘマトクリット（Ht）/検査日時
            const ope_dev_a91 = device_set_info.ope.dev.A[91] ? this.addUnits(device_set_info.ope.dev.A[91], ' %') : '';
            // mod #11528 【たくしん会】データリスト並び順不正 房 start
            // const ope_dev_c91 = dayjs(device_set_info.ope.dev.C[91]).isValid() ? dayjs(device_set_info.ope.dev.C[91]).format('YYYY/MM/DD HH:mm') : device_set_info.ope.dev.C[91];
            // mod #11718 【#11600持ち越し】データリスト画面不正② fang start
            let ope_dev_c91 = "";
            if(device_set_info.ope.dev.C[91] != null && device_set_info.ope.dev.C[91] != 'null') {
              ope_dev_c91 = device_set_info.ope.dev.C[91] + "";
              if(ope_dev_c91.trim().length >= 12) {
                ope_dev_c91 = ope_dev_c91.substring(0, 4) + "/" + ope_dev_c91.substring(4, 6) + "/" + ope_dev_c91.substring(6, 8)
                  + " " + ope_dev_c91.substring(8, 10) + ":" + ope_dev_c91.substring(10, 12);
              } else {
                ope_dev_c91 = "";
              }
            }
            // mod #11718 【#11600持ち越し】データリスト画面不正② fang end
            // mod #11528 【たくしん会】データリスト並び順不正 房 end
            // const hematocrit_ht_date_cd = ope_dev_a91 + " / " + ope_dev_c91;
            complaints = this.setComplaintsData(
              HEMATOCRIT_HT_VALUE_CD,
              /*mod FNSI-改修内容5237 任 start*/
              ope_dev_a91,
              /*mod FNSI-改修内容5237 任 end*/
              hosp_pat_id,
              pat_name,
              complaints
            );
            complaints = this.setComplaintsData(
              HEMATOCRIT_HT_DATE_CD,
              /*mod FNSI-改修内容5237 任 start*/
              ope_dev_c91,
              /*mod FNSI-改修内容5237 任 end*/
              hosp_pat_id,
              pat_name,
              complaints
            );
            //総タンパク(TP)/検査日時
            const ope_dev_a92 = device_set_info.ope.dev.A[92] ? this.addUnits(this.getDecimalValue(device_set_info.ope.dev.A[92],1), ' g/dL') : '';
            // mod #11528 【たくしん会】データリスト並び順不正 房 start
            // const ope_dev_c92 = dayjs(device_set_info.ope.dev.C[92]).isValid() ? dayjs(device_set_info.ope.dev.C[92]).format('YYYY/MM/DD HH:mm') : device_set_info.ope.dev.C[92];
            // mod #11718 【#11600持ち越し】データリスト画面不正② fang start
            let ope_dev_c92 = "";
            if(device_set_info.ope.dev.C[92] != null && device_set_info.ope.dev.C[92] != 'null') {
              ope_dev_c92 = "" + device_set_info.ope.dev.C[92];
              if(ope_dev_c92.trim().length >= 12) {
                ope_dev_c92 = ope_dev_c92.substring(0, 4) + "/" + ope_dev_c92.substring(4, 6) + "/" + ope_dev_c92.substring(6, 8)
                  + " " + ope_dev_c92.substring(8, 10) + ":" + ope_dev_c92.substring(10, 12);
              } else {
                ope_dev_c92 = ""
              }
            }
            // mod #11718 【#11600持ち越し】データリスト画面不正② fang end
            // mod #11528 【たくしん会】データリスト並び順不正 房 end
            // const total_tp_inspection_date_cd = ope_dev_a92 + " / " + ope_dev_c92;
            complaints = this.setComplaintsData(
              EMERGC_IV_VALUE_CD,
              /*mod FNSI-改修内容5237 任 start*/
              ope_dev_a92,
              /*mod FNSI-改修内容5237 任 end*/
              hosp_pat_id,
              pat_name,
              complaints
            );
            complaints = this.setComplaintsData(
              EMERGC_IV_DATE_CD,
              /*mod FNSI-改修内容5237 任 start*/
              ope_dev_c92,
              /*mod FNSI-改修内容5237 任 end*/
              hosp_pat_id,
              pat_name,
              complaints
            );
            //TMP閾値 速度低下
            complaints = this.setComplaintsData(
              TMP_THRESHOLD_SPEED_DROP_CD,
              this.addUnits(device_set_info.ope.dev.A[472], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //TMP閾値 速度復帰
            complaints = this.setComplaintsData(
              TMP_THRESHOLD_SPEED_RETURN_CD,
              this.addUnits(device_set_info.ope.dev.A[473], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //速度変化率 速度低下
            complaints = this.setComplaintsData(
              SPEED_CHANGE_RATE_DROP_CD,
              this.addUnits(device_set_info.ope.dev.A[474], ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //速度変化率 速度復帰
            complaints = this.setComplaintsData(
              SPEED_CHANGE_RATE_RETURN_CD,
              this.addUnits(device_set_info.ope.dev.A[475], ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //緊急補液 補液速度
            complaints = this.setComplaintsData(
              EMERGC_IV_RATE_CD,
              this.addUnits(device_set_info.ope.dev.A[336], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //緊急補液 補液量
            complaints = this.setComplaintsData(
              EMERGC_IV_AMOUNT_CD,
              this.addUnits(device_set_info.ope.dev.A[337], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //補液速度操作範囲上限（HDF）前補液
            complaints = this.setComplaintsData(
              IV_SPEED_UPPER_HDF_BEFOR_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.A[185],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //補液速度操作範囲上限（HDF）後補液
            complaints = this.setComplaintsData(
              IV_SPEED_UPPER_HDF_AFTER_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.B[31],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // 補液速度範囲上限（HD+補液）前補液
            complaints = this.setComplaintsData(
              IV_SPEED_UPPER_HD_BEFOR_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.B[30],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // 補液速度範囲上限（HD+補液）後補液
            complaints = this.setComplaintsData(
              IV_SPEED_UPPER_HD_AFTER_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.B[33],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // TMPゼロ補正時間上限HD+補液
            complaints = this.setComplaintsData(
              TMP_ZERO_HD_UP,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.B[37],2), ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // TMPゼロ補正時間下限HD+補液
            complaints = this.setComplaintsData(
              TMP_ZERO_HD_DOWN,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.B[38],2), ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //補液速度操作範囲上限（HF）前補液
            complaints = this.setComplaintsData(
              IV_SPEED_UPPER_HF_BEFOR_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.A[186],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //補液速度操作範囲上限（HF）後補液
            complaints = this.setComplaintsData(
              IV_SPEED_UPPER_HF_AFTER_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.B[32],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //補液速度操作範囲上限（OHDF）前補液
            complaints = this.setComplaintsData(
              IV_SPEED_UPPER_OHDF_BEFOR_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.A[396],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //補液速度操作範囲上限（OHDF）後補液
            complaints = this.setComplaintsData(
              IV_SPEED_UPPER_OHDF_AFTER_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.B[34],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //補液速度操作範囲上限（OHF）前補液
            complaints = this.setComplaintsData(
              IV_SPEED_UPPER_OHF_BEFOR_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.A[397],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //補液速度操作範囲上限（OHF）後補液
            complaints = this.setComplaintsData(
              IV_SPEED_UPPER_OHF_AFTER_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.B[35],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //補液比率使用選択
            if (device_set_info.ope.dev.A[384] == '0') {
              complaints = this.setComplaintsData(
                IV_RATIO_USE_SELECT_CD,
                '使用しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.ope.dev.A[384] == '1') {
              complaints = this.setComplaintsData(
                IV_RATIO_USE_SELECT_CD,
                '使用する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //補液比率
            complaints = this.setComplaintsData(
              IV_RATIO_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.A[385],1), ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (
            device_set_info.ope &&
            device_set_info.ope.dev &&
            device_set_info.ope.dev.B
          ) {
            //速度操作範囲上限
            complaints = this.setComplaintsData(
              SPEED_RANGE_UPPER_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.A[386],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //速度操作範囲下限
            complaints = this.setComplaintsData(
              SPEED_RANGE_LOWER_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ope.dev.A[387],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (
            device_set_info.ecum &&
            device_set_info.ecum.dev &&
            device_set_info.ecum.dev.A
          ) {
            //ＥＣＵＭ選択
            if (device_set_info.ecum.dev.A[16] == '0') {
              complaints = this.setComplaintsData(
                ECUM_SELECT_CD,
                'ＨＤ',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.ecum.dev.A[16] == '1') {
              complaints = this.setComplaintsData(
                ECUM_SELECT_CD,
                'ＥＣＵＭ',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //ＥＣＵＭ量
            complaints = this.setComplaintsData(
              ECUM_AMOUNT_CD,
              this.addUnits(this.getDecimalValue(device_set_info.ecum.dev.A[17],2), ' L'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＥＣＵＭ時間
            complaints = this.setComplaintsData(
              ECUM_TIME_CD,
              dayjs(device_set_info.ecum.dev.A[18]).isValid() ? dayjs("20200101").minute(device_set_info.ecum.dev.A[18]).format('HH:mm') : null,
              hosp_pat_id,
              pat_name,
              complaints
            );
            //ＥＣＵＭ時間カウント選択
            if (device_set_info.ecum.dev.A[19] == '0') {
              complaints = this.setComplaintsData(
                ECUM_TIME_COUNT_SELECT_CD,
                '透析時間に含まない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.ecum.dev.A[19] == '1') {
              complaints = this.setComplaintsData(
                ECUM_TIME_COUNT_SELECT_CD,
                '透析時間に含む',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
          }
          if (
            device_set_info.war &&
            device_set_info.war.dev &&
            device_set_info.war.dev.A
          ) {
            //ＴＭＰ監視モード
            if (device_set_info.war.dev.A[240] + "" == '0') {
              complaints = this.setComplaintsData(
                TMP_MONITOR_MODE_CD,
                'TMP自動追従',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.war.dev.A[240] + "" == '1') {
              complaints = this.setComplaintsData(
                TMP_MONITOR_MODE_CD,
                'TMP自動設定',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.war.dev.A[240] + "" == '2') {
              complaints = this.setComplaintsData(
                TMP_MONITOR_MODE_CD,
                '透析液圧',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //HD/ECUM_静脈圧_自動設定警報幅上限
            complaints = this.setComplaintsData(
              ECUM_VEN_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[100], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_静脈圧_自動設定警報幅下限
            complaints = this.setComplaintsData(
              ECUM_VEN_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[101], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_静脈圧_自動設定警報限界値上限
            complaints = this.setComplaintsData(
              ECUM_VEN_AUTO_SET_WARNING_LIMIT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[102], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_静脈圧_自動設定警報限界値下限
            complaints = this.setComplaintsData(
              ECUM_VEN_AUTO_SET_WARNING_LIMIT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[103], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_静脈圧_固定警報点上限
            complaints = this.setComplaintsData(
              ECUM_VEN_FIXED_WARNING_POINT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[104], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_静脈圧_固定警報点下限
            complaints = this.setComplaintsData(
              ECUM_VEN_FIXED_WARNING_POINT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[105], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_ダイアライザ入口圧_自動設定警報幅上限
            complaints = this.setComplaintsData(
              ECUM_DIA_ENTR_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[152], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_ダイアライザ入口圧_自動設定警報幅下限
            complaints = this.setComplaintsData(
              ECUM_DIA_ENTR_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[153], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_ダイアライザ入口圧_自動設定警報限界値上限
            complaints = this.setComplaintsData(
              ECUM_DIA_ENTR_AUTO_SET_WARNING_LIMIT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[154], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_ダイアライザ入口圧_自動設定警報限界値下限
            complaints = this.setComplaintsData(
              ECUM_DIA_ENTR_AUTO_SET_WARNING_LIMIT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[155], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_ダイアライザ入口圧_固定警報点上限
            complaints = this.setComplaintsData(
              ECUM_DIA_ENTR_FIXED_WARNING_POINT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[156], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_ダイアライザ入口圧_固定警報点下限
            complaints = this.setComplaintsData(
              ECUM_DIA_ENTR_FIXED_WARNING_POINT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[157], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_液圧_自動設定警報幅上限
            complaints = this.setComplaintsData(
              ECUM_HYD_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[112], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_液圧_自動設定警報幅下限
            complaints = this.setComplaintsData(
              ECUM_HYD_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[113], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_液圧_自動設定警報限界値上限
            complaints = this.setComplaintsData(
              ECUM_HYD_AUTO_SET_WARNING_LIMIT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[114], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_液圧_自動設定警報限界値下限
            complaints = this.setComplaintsData(
              ECUM_HYD_AUTO_SET_WARNING_LIMIT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[115], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_液圧_液圧固定警報点上限
            complaints = this.setComplaintsData(
              ECUM_HYD_FIXED_PRESS_WARNING_POINT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[116], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_液圧_液圧固定警報点下限
            complaints = this.setComplaintsData(
              ECUM_HYD_FIXED_PRESS_WARNING_POINT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[117], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_TMP_自動設定警報幅上限
            complaints = this.setComplaintsData(
              ECUM_TMP_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[128], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_TMP_自動設定警報幅下限
            complaints = this.setComplaintsData(
              ECUM_TMP_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[129], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_TMP_自動設定警報限界値上限
            complaints = this.setComplaintsData(
              ECUM_TMP_AUTO_SET_WARNING_LIMIT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[130], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_TMP_自動設定警報限界値下限
            complaints = this.setComplaintsData(
              ECUM_TMP_AUTO_SET_WARNING_LIMIT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[131], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_TMP_固定警報点上限
            complaints = this.setComplaintsData(
              ECUM_TMP_FIXED_WARNING_POINT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[132], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_TMP_固定警報点下限
            complaints = this.setComplaintsData(
              ECUM_TMP_FIXED_WARNING_POINT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[133], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_TMP_自動追従警報幅上限
            complaints = this.setComplaintsData(
              ECUM_TMP_AUTO_FOLLOW_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[126], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_TMP_自動追従警報幅下限
            complaints = this.setComplaintsData(
              ECUM_TMP_AUTO_FOLLOW_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[127], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_ダイアライザ差圧_自動設定警報幅上限
            complaints = this.setComplaintsData(
              ECUM_DIA_DIFF_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[146], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_ダイアライザ差圧_自動設定警報幅下限
            complaints = this.setComplaintsData(
              ECUM_DIA_DIFF_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[147], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_ダイアライザ差圧_固定警報点上限
            complaints = this.setComplaintsData(
              ECUM_DIA_DIFF_FIXED_WARNING_POINT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[148], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HD/ECUM_ダイアライザ差圧_固定警報点下限
            complaints = this.setComplaintsData(
              ECUM_DIA_DIFF_FIXED_WARNING_POINT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[149], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HDF/HF_静脈圧_自動設定警報幅上限
            complaints = this.setComplaintsData(
              HF_VEN_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[106], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HDF/HF_静脈圧_自動設定警報幅下限
            complaints = this.setComplaintsData(
              HF_VEN_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[107], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HDF/HF_ダイアライザ入口圧_自動設定警報幅上限
            complaints = this.setComplaintsData(
              HF_DIA_ENTR_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[158], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HDF/HF_ダイアライザ入口圧_自動設定警報幅下限
            complaints = this.setComplaintsData(
              HF_DIA_ENTR_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[159], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HDF/HF_液圧_自動設定警報幅上限
            complaints = this.setComplaintsData(
              HF_HYD_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[118], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HDF/HF_液圧_自動設定警報幅下限
            complaints = this.setComplaintsData(
              HF_HYD_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[119], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HDF/HF_TMP_自動設定警報幅上限
            complaints = this.setComplaintsData(
              HF_TMP_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[136], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HDF/HF_TMP_自動設定警報幅下限
            complaints = this.setComplaintsData(
              HF_TMP_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[137], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HDF/HF_TMP_自動追従警報幅上限
            complaints = this.setComplaintsData(
              HF_TMP_AUTO_FOLLOW_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[134], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HDF/HF_TMP_自動追従警報幅下限
            complaints = this.setComplaintsData(
              HF_TMP_AUTO_FOLLOW_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[135], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HDF/HF_ダイアライザ差圧_自動設定警報幅上限
            complaints = this.setComplaintsData(
              HF_DIA_DIFF_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[150], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //HDF/HF_ダイアライザ差圧_自動設定警報幅下限
            complaints = this.setComplaintsData(
              HF_DIA_DIFF_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[151], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_静脈圧_固定警報点上限
            complaints = this.setComplaintsData(
              SIN_VEN_FIXED_WARNING_POINT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[110], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_静脈圧_固定警報点下限
            complaints = this.setComplaintsData(
              SIN_VEN_FIXED_WARNING_POINT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[111], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_ダイアライザー入口圧_固定警報上限
            complaints = this.setComplaintsData(
              SIN_DIA_ENTR_FIXED_WARNING_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[162], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_ダイアライザー入口圧_固定警報下限
            complaints = this.setComplaintsData(
              SIN_DIA_ENTR_FIXED_WARNING_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[163], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_液圧_自動設定警報幅上限
            complaints = this.setComplaintsData(
              SIN_HYD_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[120], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_液圧_自動設定警報幅下限
            complaints = this.setComplaintsData(
              SIN_HYD_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[121], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_液圧_自動設定警報限界値上限
            complaints = this.setComplaintsData(
              SIN_HYD_AUTO_SET_WARNING_LIMIT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[122], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_液圧_自動設定警報限界値下限
            complaints = this.setComplaintsData(
              SIN_HYD_AUTO_SET_WARNING_LIMIT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[123], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_液圧_固定警報点上限
            complaints = this.setComplaintsData(
              SIN_HYD_FIXED_WARNING_POINT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[124], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_液圧_固定警報点下限
            complaints = this.setComplaintsData(
              SIN_HYD_FIXED_WARNING_POINT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[125], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_TMP_自動設定警報幅上限
            complaints = this.setComplaintsData(
              SIN_TMP_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[140], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_TMP_自動設定警報幅下限
            complaints = this.setComplaintsData(
              SIN_TMP_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[141], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_TMP_自動設定警報限界値上限
            complaints = this.setComplaintsData(
              SIN_TMP_AUTO_SET_WARNING_LIMIT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[142], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_TMP_自動設定警報限界値下限
            complaints = this.setComplaintsData(
              SIN_TMP_AUTO_SET_WARNING_LIMIT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[143], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_TMP_固定警報点上限
            complaints = this.setComplaintsData(
              SIN_TMP_FIXED_WARNING_POINT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[144], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_TMP_固定警報点下限
            complaints = this.setComplaintsData(
              SIN_TMP_FIXED_WARNING_POINT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[145], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_TMP_自動追従警報幅上限
            complaints = this.setComplaintsData(
              SIN_TMP_AUTO_FOLLOW_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[138], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //シングルニードル_TMP_自動追従警報幅下限
            complaints = this.setComplaintsData(
              SIN_TMP_AUTO_FOLLOW_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[139], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //透析準備_静脈圧_固定警報点上限
            complaints = this.setComplaintsData(
              PRE_VEN_FIXED_WARNING_POINT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[108], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //透析準備_静脈圧_固定警報点下限
            complaints = this.setComplaintsData(
              PRE_VEN_FIXED_WARNING_POINT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[109], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //透析準備_ダイアライザー入口圧_固定警報点上限
            complaints = this.setComplaintsData(
              PRE_DIA_ENTR_FIXED_WARNING_POINT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[160], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //透析準備_ダイアライザー入口圧_固定警報点下限
            complaints = this.setComplaintsData(
              PRE_DIA_ENTR_FIXED_WARNING_POINT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[161], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //透析準備_Na濃度_自動設定警報幅上限
            complaints = this.setComplaintsData(
              PRE_NA_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[254], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //透析準備_Na濃度_自動設定警報幅下限
            complaints = this.setComplaintsData(
              PRE_NA_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[255], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //透析準備_Na濃度_固定警報点上限
            complaints = this.setComplaintsData(
              PRE_NA_FIXED_WARNING_POINT_UPPER_CD,
              this.addUnits(device_set_info.war.dev.A[256], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //透析準備_Na濃度_固定警報点下限
            complaints = this.setComplaintsData(
              PRE_NA_FIXED_WARNING_POINT_LOWER_CD,
              this.addUnits(device_set_info.war.dev.A[257], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //自動設定警報_監視有無_静脈圧自動設定警報監視有無
            if (device_set_info.war.dev.A[242] == '0') {
              complaints = this.setComplaintsData(
                VENOUS_AUTO_SET_MONITOR_WARNING_YN_CD,
                '無',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.war.dev.A[242] == '1') {
              complaints = this.setComplaintsData(
                VENOUS_AUTO_SET_MONITOR_WARNING_YN_CD,
                '有',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //自動設定警報_監視有無_透析液圧自動設定警報監視有無
            if (device_set_info.war.dev.A[244] == '0') {
              complaints = this.setComplaintsData(
                DIALYSATE_AUTO_SET_MONITOR_WARNING_YN_CD,
                '無',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.war.dev.A[244] == '1') {
              complaints = this.setComplaintsData(
                DIALYSATE_AUTO_SET_MONITOR_WARNING_YN_CD,
                '有',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //自動設定警報_監視有無_差圧自動設定警報監視有無
            if (device_set_info.war.dev.A[246] == '0') {
              complaints = this.setComplaintsData(
                DIFF_AUTO_SET_MONITOR_WARNING_YN_CD,
                '無',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.war.dev.A[246] == '1') {
              complaints = this.setComplaintsData(
                DIFF_AUTO_SET_MONITOR_WARNING_YN_CD,
                '有',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //自動設定警報_監視有無_ダイアライザー血液入口圧自動設定警報監視有無
            if (device_set_info.war.dev.A[243] == '0') {
              complaints = this.setComplaintsData(
                DIA_ENTR_AUTO_SET_MONITOR_WARNING_YN_CD,
                '無',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.war.dev.A[243] == '1') {
              complaints = this.setComplaintsData(
                DIA_ENTR_AUTO_SET_MONITOR_WARNING_YN_CD,
                '有',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //自動設定警報_監視有無_ＴＭＰ自動設定警報監視有無
            if (device_set_info.war.dev.A[245] == '0') {
              complaints = this.setComplaintsData(
                TMP_AUTO_SET_MONITOR_WARNING_YN_CD,
                '無',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.war.dev.A[245] == '1') {
              complaints = this.setComplaintsData(
                TMP_AUTO_SET_MONITOR_WARNING_YN_CD,
                '有',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //自動設定警報_監視有無_Ｎａ濃度自動設定警報監視有無
            if (device_set_info.war.dev.A[247] == '0') {
              complaints = this.setComplaintsData(
                NA_AUTO_SET_MONITOR_WARNING_YN_CD,
                '無',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.war.dev.A[247] == '1') {
              complaints = this.setComplaintsData(
                NA_AUTO_SET_MONITOR_WARNING_YN_CD,
                '有',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
          }
          if (
            device_set_info.cpro &&
            device_set_info.cpro.dev &&
            device_set_info.cpro.dev.A
          ) {
            //濃度プログラム自動設定警報_Ｂ液濃度プログラム自動設定警報幅上限
            complaints = this.setComplaintsData(
              B_DENSITY_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(this.getDecimalValue(device_set_info.cpro.dev.A[252],1), ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //濃度プログラム自動設定警報_Ｂ液濃度プログラム自動設定警報幅下限
            complaints = this.setComplaintsData(
              B_DENSITY_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(this.getDecimalValue(device_set_info.cpro.dev.A[253],1), ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //濃度プログラム自動設定警報_透析液濃度プログラム自動設定警報幅上限
            complaints = this.setComplaintsData(
              DIALYSATE_DENSITY_AUTO_SET_WARNING_WIDTH_UPPER_CD,
              this.addUnits(this.getDecimalValue(device_set_info.cpro.dev.A[250],1), ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //濃度プログラム自動設定警報_透析液濃度プログラム自動設定警報幅下限
            complaints = this.setComplaintsData(
              DIALYSATE_DENSITY_AUTO_SET_WARNING_WIDTH_LOWER_CD,
              this.addUnits(this.getDecimalValue(device_set_info.cpro.dev.A[251],1), ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (
            device_set_info.bp &&
            device_set_info.bp.dev &&
            device_set_info.bp.dev.A
          ) {
            //血圧計_警報点設定_最高血圧上限
            complaints = this.setComplaintsData(
              MAX_BLOOD_PRESS_UPPER_CD,
              this.addUnits(device_set_info.bp.dev.A[211], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //血圧計_警報点設定_最高血圧下限
            complaints = this.setComplaintsData(
              MAX_BLOOD_PRESS_LOWER_CD,
              this.addUnits(device_set_info.bp.dev.A[212], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //血圧計_警報点設定_最低血圧上限
            complaints = this.setComplaintsData(
              MIN_BLOOD_PRESS_UPPER_CD,
              this.addUnits(device_set_info.bp.dev.A[213], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //血圧計_警報点設定_最低血圧下限
            complaints = this.setComplaintsData(
              MIN_BLOOD_PRESS_LOWER_CD,
              this.addUnits(device_set_info.bp.dev.A[214], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //血圧計_警報点設定_平均血圧上限
            complaints = this.setComplaintsData(
              AVE_BLOOD_PRESS_UPPER_CD,
              this.addUnits(device_set_info.bp.dev.A[215], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //血圧計_警報点設定_平均血圧下限
            complaints = this.setComplaintsData(
              AVE_BLOOD_PRESS_LOWER_CD,
              this.addUnits(device_set_info.bp.dev.A[216], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //血圧計_警報点設定_脈拍数上限
            complaints = this.setComplaintsData(
              PULSE_COUNT_UPPER_CD,
              this.addUnits(device_set_info.bp.dev.A[217], ' bpm'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //血圧計_警報点設定_脈拍数下限
            complaints = this.setComplaintsData(
              PULSE_COUNT_LOWER_CD,
              this.addUnits(device_set_info.bp.dev.A[218], ' bpm'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //最高血圧警報との連動動作_最高血圧上限警報_BP_速度
            complaints = this.setComplaintsData(
              MAX_BLOOD_PRESS_UPPER_WARNING_BP_SPEED_CD,
              this.addUnits(device_set_info.bp.dev.A[227], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //最高血圧警報との連動動作_最高血圧下限警報_BP_速度
            complaints = this.setComplaintsData(
              MAX_BLOOD_PRESS_LOWER_WARNING_BP_SPEED_CD,
              this.addUnits(device_set_info.bp.dev.A[228], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //最高血圧警報との連動動作_最高血圧上限警報_除水_速度
            complaints = this.setComplaintsData(
              MAX_BLOOD_PRESS_UPPER_WARNING_WATER_REMOVE_SPEED_CD,
              this.addUnits(this.getDecimalValue(device_set_info.bp.dev.A[229],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //最高血圧警報との連動動作_最高血圧下限警報_除水_速度
            complaints = this.setComplaintsData(
              MAX_BLOOD_PRESS_LOWER_WARNING_WATER_REMOVE_SPEED_CD,
              this.addUnits(this.getDecimalValue(device_set_info.bp.dev.A[230],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //最高血圧警報との連動動作_最高血圧上限警報_Na注入_速度
            complaints = this.setComplaintsData(
              MAX_BLOOD_PRESS_UPPER_WARNING_NA_SPEED_CD,
              this.addUnits(device_set_info.bp.dev.A[231], ' mEq/L'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //最高血圧警報との連動動作_最高血圧下限警報_Na注入_速度
            complaints = this.setComplaintsData(
              MAX_BLOOD_PRESS_LOWER_WARNING_NA_SPEED_CD,
              this.addUnits(device_set_info.bp.dev.A[232], ' mEq/L'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //最高血圧警報との連動動作_最高血圧上限警報_補液_速度
            complaints = this.setComplaintsData(
              MAX_BLOOD_PRESS_UPPER_WARNING_IV_SPEED_CD,
              this.addUnits(this.getDecimalValue(device_set_info.bp.dev.A[233],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //最高血圧警報との連動動作_最高血圧下限警報_補液_速度
            complaints = this.setComplaintsData(
              MAX_BLOOD_PRESS_LOWER_WARNING_IV_SPEED_CD,
              this.addUnits(this.getDecimalValue(device_set_info.bp.dev.A[234],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //最高血圧警報との連動動作_最高血圧上限警報_BP_動作選択
            // mod FNSI6062-装置情報で項目の不足 周 start
            if (device_set_info.bp.dev.A[219] == '1') {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_UPPER_WARNING_BP_SELECT_CD,
                //'動作',
                '連動する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_UPPER_WARNING_BP_SELECT_CD,
                '連動しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //最高血圧警報との連動動作_最高血圧下限警報_BP_動作選択
            if (device_set_info.bp.dev.A[220] == '1') {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_LOWER_WARNING_BP_SELECT_CD,
                //'動作',
                '連動する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_LOWER_WARNING_BP_SELECT_CD,
                '連動しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //最高血圧警報との連動動作_最高血圧上限警報_除水_動作選択
            if (device_set_info.bp.dev.A[221] == '1') {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_UPPER_WARNING_WATER_REMOVE_SELECT_CD,
                //'動作',
                '連動する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_UPPER_WARNING_WATER_REMOVE_SELECT_CD,
                '連動しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //最高血圧警報との連動動作_最高血圧下限警報_除水_動作選
            if (device_set_info.bp.dev.A[222] == '1') {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_LOWER_WARNING_WATER_REMOVE_SELECT_CD,
                //'動作',
                '連動する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_LOWER_WARNING_WATER_REMOVE_SELECT_CD,
                '連動しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //最高血圧警報との連動動作_最高血圧上限警報_Na注入_動作選択
            if (device_set_info.bp.dev.A[223] == '1') {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_UPPER_WARNING_NA_SELECT_CD,
                //'動作',
                '連動する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_UPPER_WARNING_NA_SELECT_CD,
                '連動しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //最高血圧警報との連動動作_最高血圧下限警報_Na注入_動作選択
            if (device_set_info.bp.dev.A[224] == '1') {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_LOWER_WARNING_NA_SELECT_CD,
                //'動作',
                '連動する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_LOWER_WARNING_NA_SELECT_CD,
                '連動しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //最高血圧警報との連動動作_最高血圧上限警報_補液_動作選択
            if (device_set_info.bp.dev.A[225] == '1') {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_UPPER_WARNING_IV_SELECT_CD,
                //'動作',
                '連動する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_UPPER_WARNING_IV_SELECT_CD,
                '連動しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //最高血圧警報との連動動作_最高血圧下限警報_補液_動作選択
            if (device_set_info.bp.dev.A[226] == '1') {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_LOWER_WARNING_IV_SELECT_CD,
                //'動作',
                '連動する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else {
              complaints = this.setComplaintsData(
                MAX_BLOOD_PRESS_LOWER_WARNING_IV_SELECT_CD,
                '連動しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            // mod FNSI6062-装置情報で項目の不足 周 end
            //血圧_血圧ｶﾌ選択
            if (device_set_info.bp.dev.A[191] == '0') {
              complaints = this.setComplaintsData(
                BLOOD_PRESS_KOTO_SELECT_CD,
                '成人',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.bp.dev.A[191] == '1') {
              complaints = this.setComplaintsData(
                BLOOD_PRESS_KOTO_SELECT_CD,
                '幼児',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //血圧_血圧自動測定間隔
            complaints = this.setComplaintsData(
              BLOOD_PRESS_AUTO_INTERVAL_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.bp.dev.A[190], ' min'),
              this.addUnits(device_set_info.bp.dev.A[190], ' 分'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //血圧_昇圧値
            complaints = this.setComplaintsData(
              BOOST_VALUE_CD,
              this.addUnits(device_set_info.bp.dev.A[192], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //血圧_昇圧方法
            if (device_set_info.bp.dev.A[193] == '0') {
              complaints = this.setComplaintsData(
                BOOST_METHOD_CD,
                '手動',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.bp.dev.A[193] == '1') {
              complaints = this.setComplaintsData(
                BOOST_METHOD_CD,
                '自動',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.bp.dev.A[193] == '2') {
              complaints = this.setComplaintsData(
                BOOST_METHOD_CD,
                'スマート昇圧',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //血圧_血圧測定方法選択
            if (device_set_info.bp.dev.A[195] == '1') {
              complaints = this.setComplaintsData(
                BLOOD_PRESS_MEASURE_SELECT_CD,
                '降圧測定',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.bp.dev.A[195] == '2') {
              complaints = this.setComplaintsData(
                BLOOD_PRESS_MEASURE_SELECT_CD,
                '昇圧測定',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //血圧_高速測定使用選択
            if (device_set_info.bp.dev.A[239] == '0') {
              complaints = this.setComplaintsData(
                HIGH_SPEED_MEASURE_SELECT_CD,
                'なし',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.bp.dev.A[239] == '1') {
              complaints = this.setComplaintsData(
                HIGH_SPEED_MEASURE_SELECT_CD,
                'あり',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //血圧_血圧連続測定動作選択
            if (device_set_info.bp.dev.A[194] == '0') {
              complaints = this.setComplaintsData(
                BLOOD_PRESS_CONT_MEASURET_SELECT_CD,
                '12分',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.bp.dev.A[194] == '1') {
              complaints = this.setComplaintsData(
                BLOOD_PRESS_CONT_MEASURET_SELECT_CD,
                '5分',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //血圧_警報連動測定開始時刻
            complaints = this.setComplaintsData(
              WARNING_SYN_MEASURE_START_TIME_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.bp.dev.A[235], ' min'),
              this.addUnits(device_set_info.bp.dev.A[235], ' 分'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //血圧_治療条件連動測定時刻
            complaints = this.setComplaintsData(
              TREAT_SYN_MEASURE_TIME_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.bp.dev.A[236], ' min'),
              this.addUnits(device_set_info.bp.dev.A[236], ' 分'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //血圧_静脈圧警報発生時の血圧測定
            if (device_set_info.bp.dev.A[237] == '0') {
              complaints = this.setComplaintsData(
                VEIN_PRESS_WARNING_MEASURE_PRESSURE_CD,
                '継続',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.bp.dev.A[237] == '1') {
              complaints = this.setComplaintsData(
                VEIN_PRESS_WARNING_MEASURE_PRESSURE_CD,
                '中断・終了',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //血圧_血流量または降水速度変更時の血圧測定
            if (device_set_info.bp.dev.A[238] == '0') {
              complaints = this.setComplaintsData(
                BLOOD_OR_WATER_CHANGE_PRESS_MEASURE_CD,
                '継続',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.bp.dev.A[238] == '1') {
              complaints = this.setComplaintsData(
                BLOOD_OR_WATER_CHANGE_PRESS_MEASURE_CD,
                '中断・終了',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
          }
          if (
            device_set_info.bv &&
            device_set_info.bv.dev &&
            device_set_info.bv.dev.A
          ) {
            //BV計_ブラッドボリューム計使用の選択
            if (device_set_info.bv.dev.A[267] == '0') {
              complaints = this.setComplaintsData(
                USE_BLOOD_VOLUME_METER_SELECT_CD,
                '使用しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.bv.dev.A[267] == '1') {
              complaints = this.setComplaintsData(
                USE_BLOOD_VOLUME_METER_SELECT_CD,
                '使用する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //BV計_ΔＢＶ低下警報点１
            complaints = this.setComplaintsData(
              BV_DELTA_WARNING_POINT1_CD,
              this.addUnits(this.getDecimalValue(device_set_info.bv.dev.A[260],1), ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //BV計_ΔＢＶ低下警報点２
            complaints = this.setComplaintsData(
              BV_DELTA_WARNING_POINT2_CD,
              this.addUnits(this.getDecimalValue(device_set_info.bv.dev.A[261],1), ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //BV計_ΔBV変化率警報点
            complaints = this.setComplaintsData(
              BV_DELTA_CHANGE_RATE_WARNING_POINT_CD,
              this.addUnits(this.getDecimalValue(device_set_info.bv.dev.A[262],1), ' %min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //BV計_ΔＢＶ除水低下速度
            complaints = this.setComplaintsData(
              BV__WATER_REMOVE_LOW_SPEED_CD,
              this.addUnits(this.getDecimalValue(device_set_info.bv.dev.A[277],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //BV計_ΔＢＶ除水低下遅延時間
            complaints = this.setComplaintsData(
              BV__WATER_REMOVE_LOW_DELAY_TIME_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.bv.dev.A[278], ' min'),
              this.addUnits(device_set_info.bv.dev.A[278], ' 分'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
            //BV計_ΔSO2低下報知点
            complaints = this.setComplaintsData(
              SO2_DELTA_NOTIFICATION_POINT_CD,
              this.addUnits(this.getDecimalValue(device_set_info.bv.dev.A[476],1), ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
            //BV計_アクセス再循環率測定_アクセス再循環測定使用選択
            if (device_set_info.bv.dev.A[258] == '0') {
              complaints = this.setComplaintsData(
                ACCESS_REC_MEASURE_CD,
                '使用しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.bv.dev.A[258] == '1') {
              complaints = this.setComplaintsData(
                ACCESS_REC_MEASURE_CD,
                '使用する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //BV計_アクセス再循環率測定_自動測定1
            complaints = this.setComplaintsData(
              AUTO_MEASURE1_CD,
              dayjs(device_set_info.bv.dev.A[259]).isValid() ? dayjs("20200101").minute(device_set_info.bv.dev.A[259]).format('HH:mm') : null,
              hosp_pat_id,
              pat_name,
              complaints
            );
            //BV計_アクセス再循環率測定_自動測定2
            complaints = this.setComplaintsData(
              AUTO_MEASURE2_CD,
              dayjs(device_set_info.bv.dev.A[263]).isValid() ? dayjs("20200101").minute(device_set_info.bv.dev.A[263]).format('HH:mm') : null,
              hosp_pat_id,
              pat_name,
              complaints
            );
            //BV計_アクセス再循環率測定_自動測定3
            complaints = this.setComplaintsData(
              AUTO_MEASURE3_CD,
              dayjs(device_set_info.bv.dev.A[264]).isValid() ? dayjs("20200101").minute(device_set_info.bv.dev.A[264]).format('HH:mm') : null,
              hosp_pat_id,
              pat_name,
              complaints
            );
            //BV計_アクセス再循環率測定_自動測定4
            complaints = this.setComplaintsData(
              AUTO_MEASURE4_CD,
              dayjs(device_set_info.bv.dev.A[265]).isValid() ? dayjs("20200101").minute(device_set_info.bv.dev.A[265]).format('HH:mm') : null,
              hosp_pat_id,
              pat_name,
              complaints
            );
            //BV計_アクセス再循環率測定_自動測定5
            complaints = this.setComplaintsData(
              AUTO_MEASURE5_CD,
              dayjs(device_set_info.bv.dev.A[266]).isValid() ? dayjs("20200101").minute(device_set_info.bv.dev.A[266]).format('HH:mm') : null,
              hosp_pat_id,
              pat_name,
              complaints
            );
            //BV計_アクセス再循環率測定_再循環率報知
            complaints = this.setComplaintsData(
              REC_RATE_NOTIFI_CD,
              this.addUnits(device_set_info.bv.dev.A[281], ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (
            device_set_info.pri &&
            device_set_info.pri.pat &&
            device_set_info.pri.pat.A
          ) {
            //プライミング補助_動脈充填液量
            complaints = this.setComplaintsData(
              ARTERIAL_FILLING_LIQUID_CD,
              this.addUnits(device_set_info.pri.pat.A[219], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //プライミング補助_動脈充填流速
            complaints = this.setComplaintsData(
              ARTERIAL_FILLING_VELOCITY_CD,
              this.addUnits(device_set_info.pri.pat.A[220], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //プライミング補助_動脈充填動作選択
            if (device_set_info.pri.pat.A[225] == '0') {
              complaints = this.setComplaintsData(
                ARTERIAL_FILLING_OPERAT_SELECT_CD,
                '継続しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.pri.pat.A[225] == '1') {
              complaints = this.setComplaintsData(
                ARTERIAL_FILLING_OPERAT_SELECT_CD,
                '継続する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //プライミング補助_静脈充填液量
            complaints = this.setComplaintsData(
              INTRAVENOUS_FILLING_LIQUID_CD,
              this.addUnits(device_set_info.pri.pat.A[221], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //プライミング補助_静脈充填流速
            complaints = this.setComplaintsData(
              VENOUS_FILLING_VELOCITY_CD,
              this.addUnits(device_set_info.pri.pat.A[222], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //プライミング補助_静脈充填動作選択
            if (device_set_info.pri.pat.A[226] == '0') {
              complaints = this.setComplaintsData(
                INTRAVENOUS_FILLING_OPERAT_SELECT_CD,
                '継続しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.pri.pat.A[226] == '1') {
              complaints = this.setComplaintsData(
                INTRAVENOUS_FILLING_OPERAT_SELECT_CD,
                '継続する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //プライミング補助_気泡抜き液量
            complaints = this.setComplaintsData(
              BUBBLE_VOLUME_CD,
              this.addUnits(device_set_info.pri.pat.A[223], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //プライミング補助_気泡抜き流速
            complaints = this.setComplaintsData(
              BUBBLE_VELOCITY_CD,
              this.addUnits(device_set_info.pri.pat.A[224], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //プライミング補助_気泡抜き動作選択
            if (device_set_info.pri.pat.A[227] == '0') {
              complaints = this.setComplaintsData(
                BUBBLE_REMOVAL_OPERAT_SELECT_CD,
                '連続',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.pri.pat.A[227] == '1') {
              complaints = this.setComplaintsData(
                BUBBLE_REMOVAL_OPERAT_SELECT_CD,
                '間欠',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //プライミング補助_液交換量
            complaints = this.setComplaintsData(
              LIQUID_EXCHANGE_CD,
              this.addUnits(device_set_info.pri.pat.A[228], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //プライミング補助_間欠動作動作時間
            complaints = this.setComplaintsData(
              INTERMITTENT_WORKING_TIME_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(this.getDecimalValue(device_set_info.pri.pat.A[229],1), ' sec'),
              this.addUnits(this.getDecimalValue(device_set_info.pri.pat.A[229],1), ' 秒'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //プライミング補助_間欠動作停止時間
            complaints = this.setComplaintsData(
              INTERMITTENT_STOP_TIME_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(this.getDecimalValue(device_set_info.pri.pat.A[230],1), ' sec'),
              this.addUnits(this.getDecimalValue(device_set_info.pri.pat.A[230],1), ' 秒'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //自動プライミング_落差
            complaints = this.setComplaintsData(
              AUTO_PRIM_FALL_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.pri.pat.A[232], ' sec'),
              this.addUnits(device_set_info.pri.pat.A[232], ' 秒'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //自動プライミング_総量
            complaints = this.setComplaintsData(
              AUTO_PRIM_GROSS_CD,
              this.addUnits(device_set_info.pri.pat.A[238], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //自動プライミング_透析開始前
            complaints = this.setComplaintsData(
              DIALYSIS_START_BEFORE_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.pri.pat.A[231], ' min'),
              this.addUnits(device_set_info.pri.pat.A[231], ' 分'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //自動プライミング_送液流量
            complaints = this.setComplaintsData(
              AUTO_PRIM_FEED_DISCHARGE_CD,
              this.addUnits(device_set_info.pri.pat.A[233], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //自動プライミング_送液流速（１回目）
            complaints = this.setComplaintsData(
              AUTO_PRIM_FEED_VELOCITY1_CD,
              this.addUnits(device_set_info.pri.pat.A[234], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //自動プライミング_送液流速（２回目以降）
            complaints = this.setComplaintsData(
              AUTO_PRIM_FEED_VELOCITY2_CD,
              this.addUnits(device_set_info.pri.pat.A[235], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //自動プライミング_循環流速
            complaints = this.setComplaintsData(
              AUTO_PRIM_CIRCULATE_VELOCI_CD,
              this.addUnits(device_set_info.pri.pat.A[236], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //自動プライミング_循環時間
            complaints = this.setComplaintsData(
              AUTO_PRIM_CIRCULATE_TIME_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.pri.pat.A[237], ' sec'),
              this.addUnits(device_set_info.pri.pat.A[237], ' 秒'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (
            device_set_info.pri &&
            device_set_info.pri.dev &&
            device_set_info.pri.dev.A
          ) {
            //返血機能_使用液量
            complaints = this.setComplaintsData(
              RETURN_BLOOD_USE_LIQUID_CD,
              this.addUnits(device_set_info.pri.dev.A[370], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //返血機能_流速
            complaints = this.setComplaintsData(
              RETURN_BLOOD_VELOCITY_CD,
              this.addUnits(device_set_info.pri.dev.A[371], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //返血機能_血液判別器による終了選択
            if (device_set_info.pri.dev.A[372] == '0') {
              complaints = this.setComplaintsData(
                BLOOD_DISCR_END_SELECT_CD,
                'OFF',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.pri.dev.A[372] == '1') {
              complaints = this.setComplaintsData(
                BLOOD_DISCR_END_SELECT_CD,
                'ON',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
          }
          if (
            device_set_info.pri &&
            device_set_info.pri.pat &&
            device_set_info.pri.pat.B
          ) {
            //オンラインプライミング_ダイアライザー気泡抜き時間 後補液
            complaints = this.setComplaintsData(
              BUBBLE_EXTRACT_TIME_AFTER_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.pri.pat.B[51], ' min'),
              this.addUnits(device_set_info.pri.pat.B[51], ' 分'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //オンラインプライミング_動脈チャンバ液面作成時間 前補液
            complaints = this.setComplaintsData(
              ARTERIAL_CHAMBER_LIQUID_TIME_BEFO_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.pri.pat.B[32], ' sec'),
              this.addUnits(device_set_info.pri.pat.B[32], ' 秒'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //オンラインプライミング_動脈チャンバ液面作成時間 後補液
            complaints = this.setComplaintsData(
              ARTERIAL_CHAMBER_LIQUID_TIME_AFTE_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.pri.pat.B[52], ' sec'),
              this.addUnits(device_set_info.pri.pat.B[52], ' 秒'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //オンラインプライミング_循環洗浄時間 前補液
            complaints = this.setComplaintsData(
              CIR_CLEAN_TIME_BEFOR_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.pri.pat.B[33], ' min'),
              this.addUnits(device_set_info.pri.pat.B[33], ' 分'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //オンラインプライミング_循環洗浄時間 後補液
            complaints = this.setComplaintsData(
              CIR_CLEAN_TIME_AFTER_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.pri.pat.B[53], ' min'),
              this.addUnits(device_set_info.pri.pat.B[53], ' 分'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (
            device_set_info.dfas &&
            device_set_info.dfas.pat &&
            device_set_info.dfas.pat.B
          ) {
            //D-FAS_IPプライミング_使用選択
            if (device_set_info.dfas.pat.B[1] == '0') {
              complaints = this.setComplaintsData(
                USE_CHOICE_CD,
                '使用しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.dfas.pat.B[1] == '1') {
              complaints = this.setComplaintsData(
                USE_CHOICE_CD,
                '使用する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //D-FAS_プライミング（中空糸型）_血液ポンプ速度
            complaints = this.setComplaintsData(
              HOL_BLOOD_PUMP_SPEED_CD,
              this.addUnits(device_set_info.dfas.pat.B[5], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_プライミング（中空糸型）_送液最大時間
            complaints = this.setComplaintsData(
              HOL_MAX_DELIVERY_LIQUID_TIME_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.dfas.pat.B[7], ' sec'),
              this.addUnits(device_set_info.dfas.pat.B[7], ' 秒'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_プライミング（中空糸型）_血液回路内洗浄 置換②使用液量
            complaints = this.setComplaintsData(
              HOL_BLOOD_CIRCUIT_CLEANING_REPLACE_USE_CD,
              this.addUnits(device_set_info.dfas.pat.B[8], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_プライミング（中空糸型）_気泡抜き動作 実行回数
            complaints = this.setComplaintsData(
              HOL_BUBBLE_OPERAT_CD,
              device_set_info.dfas.pat.B[9] ? this.addUnits(device_set_info.dfas.pat.B[9], ' 回') : '0 回',
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_プライミング（中空糸型）_気泡抜き動作 加圧時圧力上限
            complaints = this.setComplaintsData(
              HOL_PRESS_ADD_UPPER_CD,
              this.addUnits(device_set_info.dfas.pat.B[10], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_プライミング（積層型）_血液ポンプ速度
            complaints = this.setComplaintsData(
              LAM_BLOOD_PUMP_SPEED_CD,
              this.addUnits(device_set_info.dfas.pat.B[59], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_プライミング（積層型）_送液最大時間
            complaints = this.setComplaintsData(
              LAM_MAX_DELIVERY_LIQUID_TIME_CD,
              // mod FNSI6062-装置情報で項目の不足 周 start
              //this.addUnits(device_set_info.dfas.pat.B[54], ' sec'),
              this.addUnits(device_set_info.dfas.pat.B[54], ' 秒'),
              // mod FNSI6062-装置情報で項目の不足 周 end
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_プライミング（積層型）_血液回路内洗浄 置換②使用液量
            complaints = this.setComplaintsData(
              LAM_BLOOD_CIRCUIT_CLEANING_REPLACE_USE_CD,
              this.addUnits(device_set_info.dfas.pat.B[55], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_プライミング（積層型）_気泡抜き動作 実行回数
            complaints = this.setComplaintsData(
              LAM_BUBBLE_OPERAT_CD,
              device_set_info.dfas.pat.B[56] ? this.addUnits(device_set_info.dfas.pat.B[56], ' 回') : '0 回',
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_プライミング（積層型）_気泡抜き動作 加圧時圧力上限
            complaints = this.setComplaintsData(
              LAM_PRESS_ADD_UPPER_CD,
              this.addUnits(device_set_info.dfas.pat.B[57], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_プライミング（積層型）_除水ポンプ速度
            complaints = this.setComplaintsData(
              LAM__WATER_REMOVE_DRAINAGE_SPEED_CD,
              this.addUnits(this.getDecimalValue(device_set_info.dfas.pat.B[58],2), ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (
            device_set_info.dfas &&
            device_set_info.dfas.dev &&
            device_set_info.dfas.dev.A
          ) {
            //D-FAS_脱血_脱血方法
            if (device_set_info.dfas.dev.A[339] == '0') {
              complaints = this.setComplaintsData(
                BLOOD_LOSS_METHOD_CD,
                '同時脱血',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.dfas.dev.A[339] == '1') {
              complaints = this.setComplaintsData(
                BLOOD_LOSS_METHOD_CD,
                '片側脱血（除水あり）',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.dfas.dev.A[339] == '2') {
              complaints = this.setComplaintsData(
                BLOOD_LOSS_METHOD_CD,
                '片側脱血（除水なし）',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //D-FAS_脱血_脱血速度
            complaints = this.setComplaintsData(
              BLOOD_LOSS_SPEED_CD,
              this.addUnits(device_set_info.dfas.dev.A[333], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_脱血_同時脱血 脱血量
            complaints = this.setComplaintsData(
              BLOOD_LOSS_AMOUNT_CD,
              this.addUnits(device_set_info.dfas.dev.A[331], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_脱血_片側脱血(除水なし) 脱血量
            complaints = this.setComplaintsData(
              NO_REMOVAL_BLOOD_LOSS_AMOUNT_CD,
              this.addUnits(device_set_info.dfas.dev.A[334], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_脱血_片側脱血（除水あり） 脱血量
            complaints = this.setComplaintsData(
              REMOVAL_BLOOD_LOSS_AMOUNT_CD,
              this.addUnits(device_set_info.dfas.dev.A[338], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_脱血_片側脱血への切替え透析液圧
            complaints = this.setComplaintsData(
              TRANSFUSION_DIALYTIC_PRESSURE_CD,
              this.addUnits(device_set_info.dfas.dev.A[332], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_返血_静脈側返血速度
            complaints = this.setComplaintsData(
              VENOUS_RETURN_VELOCITY_CD,
              this.addUnits(device_set_info.dfas.dev.A[373], ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_返血_静脈側最大返血量
            complaints = this.setComplaintsData(
              VENOUS_MAXIMUM_RETURN_CD,
              this.addUnits(device_set_info.dfas.dev.A[374], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_返血_静脈側返血 血液判別機使用選択
            if (device_set_info.dfas.dev.A[377] == '0') {
              complaints = this.setComplaintsData(
                VENOUS_RETURN_BLOOD_DISCR_SELECT_CD,
                '使用しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.dfas.dev.A[377] == '1') {
              complaints = this.setComplaintsData(
                VENOUS_RETURN_BLOOD_DISCR_SELECT_CD,
                '使用する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //D-FAS_返血_動脈側返血使用選択
            if (device_set_info.dfas.dev.A[270] == '0') {
              complaints = this.setComplaintsData(
                ARTERIAL_RETURN_CHOICE_CD,
                '使用しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.dfas.dev.A[270] == '1') {
              complaints = this.setComplaintsData(
                ARTERIAL_RETURN_CHOICE_CD,
                '使用する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //D-FAS_返血_動脈側最大返血量
            complaints = this.setComplaintsData(
              MAX_ARTERIAL_RETURN_CD,
              this.addUnits(device_set_info.dfas.dev.A[376], ' mL'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //D-FAS_返血_動脈側返血 血液判別器使用選択
            if (device_set_info.dfas.dev.A[378] == '0') {
              complaints = this.setComplaintsData(
                ARTERIAL_BLOOD_DETECTOR_SELECT_CD,
                '使用しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.dfas.dev.A[378] == '1') {
              complaints = this.setComplaintsData(
                ARTERIAL_BLOOD_DETECTOR_SELECT_CD,
                '使用する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
          }
          if (
            device_set_info.dfas &&
            device_set_info.dfas.dev &&
            device_set_info.dfas.dev.B
          ) {
            //D-FAS_治療_治療開始時_血流量
            if (device_set_info.dfas.dev.B[36] == '0') {
              complaints = this.setComplaintsData(
                BLOOD_FLOW_AMOUNT_CD,
                '使用しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.dfas.dev.B[36] == '1') {
              complaints = this.setComplaintsData(
                BLOOD_FLOW_AMOUNT_CD,
                '使用する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
          }
          if (
            device_set_info.iap &&
            device_set_info.iap.dev &&
            device_set_info.iap.dev.A
          ) {
            //静的静脈圧_VA確認報知基準値(静的静脈圧)
            complaints = this.setComplaintsData(
              VA_CONFIRM_REFERENCE_VALUE_CD,
              this.addUnits(device_set_info.iap.dev.A[468], ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //静的静脈圧_VA確認報知基準値(アクセス内圧力比率)
            complaints = this.setComplaintsData(
              VA_CONFIRM_NOTIFI_VALUE_CD,
              this.addUnits(this.getDecimalValue(device_set_info.iap.dev.A[469],2), ' %'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            //静的静脈圧_静的静脈圧記録 自動実施選択
            if (device_set_info.iap.dev.A[470] + "" == '1') {
              complaints = this.setComplaintsData(
                VENOUS_PRESS_STATIC_RECORD_AUTO_SELECT_CD,
                '実施しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.iap.dev.A[470] + "" == '2') {
              complaints = this.setComplaintsData(
                VENOUS_PRESS_STATIC_RECORD_AUTO_SELECT_CD,
                '脱血時',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.iap.dev.A[470] + "" == '3') {
              complaints = this.setComplaintsData(
                VENOUS_PRESS_STATIC_RECORD_AUTO_SELECT_CD,
                '返血時',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
            //静的静脈圧_血圧測定 自動実施選択
            if (device_set_info.iap.dev.A[471] + "" == '0') {
              complaints = this.setComplaintsData(
                BLOOD_PRESS_MEASURE_AUTO_SELECT_CD,
                '実施しない',
                hosp_pat_id,
                pat_name,
                complaints
              );
            } else if (device_set_info.iap.dev.A[471] + "" == '1') {
              complaints = this.setComplaintsData(
                BLOOD_PRESS_MEASURE_AUTO_SELECT_CD,
                '実施する',
                hosp_pat_id,
                pat_name,
                complaints
              );
            }
          }
        }
        if (x.host_notification_info) {
          let host_notification_info = JSON.parse(x.host_notification_info);
          if (host_notification_info.bp_max) {
            // ホスト報知 最低血圧 上限(mmHg)
            complaints = this.setComplaintsData(
              HOSTNOTICE_BPMAXUPPER,
              this.addUnits(host_notification_info.bp_max.upper, ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 最低血圧 下限(mmHg)
            complaints = this.setComplaintsData(
              HOSTNOTICE_BPMAXLOWER,
              this.addUnits(host_notification_info.bp_max.lower, ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 最低血圧 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_BPMAXJUDGE,
              host_notification_info.bp_max.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.bp_min) {
            // ホスト報知 最低血圧 上限(mmHg)
            complaints = this.setComplaintsData(
              HOSTNOTICE_BPMINUPPER,
              this.addUnits(host_notification_info.bp_min.upper, ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 最低血圧 下限(mmHg)
            complaints = this.setComplaintsData(
              HOSTNOTICE_BPMINLOWER,
              this.addUnits(host_notification_info.bp_min.lower, ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 最低血圧 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_BPMINJUDGE,
              host_notification_info.bp_min.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.bp_ave) {
            // ホスト報知 平均血圧 上限(mmHg)
            complaints = this.setComplaintsData(
              HOSTNOTICE_BPAVEUPPER,
              this.addUnits(host_notification_info.bp_ave.upper, ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 平均血圧 下限(mmHg)
            complaints = this.setComplaintsData(
              HOSTNOTICE_BPAVELOWER,
              this.addUnits(host_notification_info.bp_ave.lower, ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 平均血圧 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_BPAVEJUDGE,
              host_notification_info.bp_ave.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.pulse) {
            // ホスト報知 脈拍 上限(bpm)
            complaints = this.setComplaintsData(
              HOSTNOTICE_PULSEUPPER,
              this.addUnits(host_notification_info.pulse.upper, ' bpm'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 脈拍 下限(bpm)
            complaints = this.setComplaintsData(
              HOSTNOTICE_PULSELOWER,
              this.addUnits(host_notification_info.pulse.lower, ' bpm'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 脈拍 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_PULSEJUDGE,
              host_notification_info.pulse.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.blood_flow) {
            // ホスト報知 血流量 上限(mL/min)
            complaints = this.setComplaintsData(
              HOSTNOTICE_BLOODFLOWUPPER,
              this.addUnits(host_notification_info.blood_flow.upper, ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 血流量 下限(mL/min)
            complaints = this.setComplaintsData(
              HOSTNOTICE_BLOODFLOWLOWER,
              this.addUnits(host_notification_info.blood_flow.lower, ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 血流量 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_BLOODFLOWJUDGE,
              host_notification_info.blood_flow.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.ip_speed) {
            // ホスト報知 IP速度 上限(mL/h)
            complaints = this.setComplaintsData(
              HOSTNOTICE_IPSPEEDUPPER,
              this.addUnits(host_notification_info.ip_speed.upper, ' mL/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 IP速度 下限(mL/h)
            complaints = this.setComplaintsData(
              HOSTNOTICE_IPSPEEDLOWER,
              this.addUnits(host_notification_info.ip_speed.lower, ' mL/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 IP速度 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_IPSPEEDJUDGE,
              host_notification_info.ip_speed.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.ufr) {
            // ホスト報知 除水速度 上限(L/h)
            complaints = this.setComplaintsData(
              HOSTNOTICE_UFRUPPER,
              this.addUnits(host_notification_info.ufr.upper, ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 除水速度 下限(L/h)
            complaints = this.setComplaintsData(
              HOSTNOTICE_UFRLOWER,
              this.addUnits(host_notification_info.ufr.lower, ' L/h'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 除水速度 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_UFRJUDGE,
              host_notification_info.ufr.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.vp) {
            // ホスト報知 静脈圧 上限(mmHg)
            complaints = this.setComplaintsData(
              HOSTNOTICE_VPUPPER,
              this.addUnits(host_notification_info.vp.upper, ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 静脈圧 下限(mmHg)
            complaints = this.setComplaintsData(
              HOSTNOTICE_VPLOWER,
              this.addUnits(host_notification_info.vp.lower, ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 静脈圧 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_VPJUDGE,
              host_notification_info.vp.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.ap) {
            // ホスト報知 動脈圧 上限(mmHg)
            complaints = this.setComplaintsData(
              HOSTNOTICE_APUPPER,
              this.addUnits(host_notification_info.ap.upper, ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 動脈圧 下限(mmHg)
            complaints = this.setComplaintsData(
              HOSTNOTICE_APLOWER,
              this.addUnits(host_notification_info.ap.lower, ' mmHg'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 動脈圧 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_APJUDGE,
              host_notification_info.ap.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.na_conc) {
            // ホスト報知 Na濃度 上限(mEq/L)
            complaints = this.setComplaintsData(
              HOSTNOTICE_NACONCUPPER,
              this.addUnits(host_notification_info.na_conc.upper, ' mEq/L'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 Na濃度 下限(mEq/L)
            complaints = this.setComplaintsData(
              HOSTNOTICE_NACONCLOWER,
              this.addUnits(host_notification_info.na_conc.lower, ' mEq/L'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 Na濃度 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_NACONCJUDGE,
              host_notification_info.na_conc.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.dialys_temp) {
            // ホスト報知 透析液温度 上限(℃)
            complaints = this.setComplaintsData(
              HOSTNOTICE_DIALYSTEMPUPPER,
              this.addUnits(host_notification_info.dialys_temp.upper, ' ℃'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 透析液温度 下限(℃)
            complaints = this.setComplaintsData(
              HOSTNOTICE_DIALYSTEMPLOWER,
              this.addUnits(host_notification_info.dialys_temp.lower, ' ℃'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 透析液温度 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_DIALYSTEMPJUDGE,
              host_notification_info.dialys_temp.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.d_bv_roc) {
            // ホスト報知 ΔBV変化率 上限(%/min)
            complaints = this.setComplaintsData(
              HOSTNOTICE_DBVROCUPPER,
              this.addUnits(host_notification_info.d_bv_roc.upper, ' %/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 ΔBV変化率 下限(%/min)
            complaints = this.setComplaintsData(
              HOSTNOTICE_DBVROCLOWER,
              this.addUnits(host_notification_info.d_bv_roc.lower, ' %/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 ΔBV変化率 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_DBVROCJUDGE,
              host_notification_info.d_bv_roc.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.ldqb) {
            // ホスト報知 LDQb 上限(mL/min)
            complaints = this.setComplaintsData(
              HOSTNOTICE_LDQBUPPER,
              this.addUnits(host_notification_info.ldqb.upper, ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 LDQb 下限(mL/min)
            complaints = this.setComplaintsData(
              HOSTNOTICE_LDQBLOWER,
              this.addUnits(host_notification_info.ldqb.lower, ' mL/min'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 LDQb 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_LDQBJUDGE,
              host_notification_info.ldqb.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.bpmi) {
            // ホスト報知 血圧測定間隔 (分)
            complaints = this.setComplaintsData(
              HOSTNOTICE_BPMIINTERVAL,
              this.addUnits(host_notification_info.bpmi.interval, ' 分'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 血圧測定間隔 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_BPMIJUDGE,
              host_notification_info.bpmi.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
          if (host_notification_info.care_i) {
            // ホスト報知 ケア間隔 (分)
            complaints = this.setComplaintsData(
              HOSTNOTICE_CAREIINTERVAL,
              this.addUnits(host_notification_info.care_i.interval, ' 分'),
              hosp_pat_id,
              pat_name,
              complaints
            );
            // ホスト報知 ケア間隔 有効/無効
            complaints = this.setComplaintsData(
              HOSTNOTICE_CAREIJUDGE,
              host_notification_info.care_i.judge ? "有効" : "無効",
              hosp_pat_id,
              pat_name,
              complaints
            );
          }
        }
      });
      return complaints;
    },

    setPatInfo(patInfo) {
      this.sameList = [];
      this.inOutList = [];
      patInfo = patInfo.map(x => {
        let isSame = this.isSameList.some(y => y == x.pat_id);
        let isInOut = this.isInOutList.some(y => y == x.pat_id);
        let pat_name = this.addBlank(x.pat_last_name, x.pat_first_name);
        if (isSame) {
          pat_name += '*';
          this.sameList.push(pat_name);
        }
        if (isInOut) {
          pat_name += '!';
          this.inOutList.push(pat_name);
        }
        let y = {
          pat_id: x.pat_id,
          hosp_pat_id: x.hosp_pat_id,
          pat_name: pat_name,
        };
        return y;
      });
      return patInfo;
    },

    setComplaintsData(
      data_list_detail_cd,
      value,
      hosp_pat_id,
      pat_name,
      complaints
    ) {
      if (value || value + "" === "0") {
        let m = {
          hosp_pat_id: hosp_pat_id,
          pat_name: pat_name,
          data_list_detail_cd: data_list_detail_cd,
          id: 0,
          value: value,
        };
        complaints.push(m);
      }
      return complaints;
    },

    setComplaintsDatahasDate(
      data_list_detail_cd,
      value,
      hosp_pat_id,
      pat_name,
      date,
      complaints
    ) {
      if (value || value + "" === "0") {
        let m = {
          hosp_pat_id: hosp_pat_id,
          pat_name: pat_name,
          data_list_detail_cd: data_list_detail_cd,
          id: 0,
          value: value,
          datetime: date,
        };
        complaints.push(m);
      }
      return complaints;
    },

    setComplaintsDatahasNo(
      data_list_detail_cd,
      value,
      ctl_no,
      // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
      row_no,
      // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
      hosp_pat_id,
      pat_name,
      date,
      complaints,
      // add bug 7578 修正 chen start
      ind_date
      // add bug 7578 修正 chen end
    ) {
      // del #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
      // if (value || value + "" === "0") {
      // del #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
        let m = {
          hosp_pat_id: hosp_pat_id,
          pat_name: pat_name,
          data_list_detail_cd: data_list_detail_cd,
          id: 0,
          // mod #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
          // value: value,
          value: value ? value : "",
          // mod #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
          // add bug 7578 修正 chen start
          ind_date: ind_date,
          // add bug 7578 修正 chen end
          datetime: date,
          ctl_no: ctl_no,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
          row_no: row_no,
          // add #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
        };
        complaints.push(m);
      // del #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm start
      // }
      // del #11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない。　V1.0B zkm end
      return complaints;
    },

    setDataAddLine(
      data_list_detail_cd,
      value,
      hosp_pat_id,
      pat_name,
      complaints
    ) {
      if (value) {
        // value = value.substring(0, value.length - 7);
        // value += '\n';
        // if (this.firstFlg) {
        //   value = '\\n' + value;
        // }
        let m = {
          hosp_pat_id: hosp_pat_id,
          pat_name: pat_name,
          data_list_detail_cd: data_list_detail_cd,
          id: 0,
          value: value,
        };
        complaints.push(m);
      }
      return complaints;
    },

    addLine(string, value) {
      if (string) {
        if (value) {
          string += '\n';
          string += value;
          string += '\n———————';
        } else {
          string += '\n \n———————';
        }
      } else {
        if (value) {
          string += value;
          string += '\n———————';
        } else {
          string += ' \n———————';
        }
      }
      return string;
    },

    addLinePatInfoTwo(string, value) {
      if (string) {
        if (value) {
          string += '(*)';
          string += value;
        } else {
          string += '(*) ';
        }
      } else {
        if (value) {
          string += value;
        } else {
          string += ' ';
        }
      }
      return string;
    },

    addUnderline(string) {
      return string;
    },

    addBlank(m, n) {
      if (!!m || !!n) {
        if (!!m && !!n) {
          return m + ' ' + n;
        } else {
          if (m) {
            return m;
          } else {
            return n;
          }
        }
      } else {
        // mod 9485 nullを空文字列判定に変換します 張博 start
        // return null;
        return "";
        // mod 9485 nullを空文字列判定に変換します 張博 end
      }
    },

    addUnits(m, n) {
      if (m || m + "" === "0") {
        return m + n;
      } else {
        return null;
      }
    },

    dataGroupingToArray(array, keyArry, resKey = 'list') {
      if (keyArry.length <= 0) return array;
      var aMap = [];
      var aResult = [];
      for (var i = 0; i < array?.length; i++) {
        var item = array[i];
        var repetitionValue = '';
        var repetitionKey = '';
        keyArry.forEach(keyValue => {
          repetitionKey = repetitionKey + keyValue;
          repetitionValue += '$' + item[keyValue];
        });
        if (aMap.indexOf(repetitionValue) === -1) {
          var oItem = {};
          oItem[resKey] = [item];

          oItem[repetitionKey] = repetitionValue;
          aResult.push(oItem);
          aMap.push(repetitionValue);
        } else {
          var index = aMap.indexOf(repetitionValue);
          aResult[index][resKey].push(item);
        }
      }
      return aResult;
    },

    async onCreateTemplateToCSV() {
      if (this.isEdited) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "更新確認",
          title: DIALOG_MESSAGES[13000104].title,
          // message: "編集中の項目があります。保存しますか？",
          message: messageFormat(DIALOG_MESSAGES[13000104].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          buttonLabels: ['いいえ', 'はい'],
          callback: async answer => {
            if (answer === 1) {
              await this.updatePatRecords();
              await this.exportToCSV();
            }
          },
        });
      } else await this.exportToCSV();
    },
    async exportToCSV() {
      let physicalNames = '';
      const arrayFields = [];
      // ソート後のdataSourceをファイル出力
      const grid = this.getGridWidget();
      if (!grid) {
        return;
      }
      const viewData = grid.dataSource.view();
      const dataArray = Array.from(viewData)

      this.columns.forEach(field => {
        if (field.width && field.width !== "0px") {
          physicalNames += field.title;
          arrayFields.push(field.field);
          physicalNames += ',';
        }
      });

      if (this.kendoGridColumns.length > 0) {
        this.kendoGridColumns.forEach(field => {
          field.columns.forEach(f => {
            physicalNames += field.title + ":" + f.title;
            arrayFields.push(f.field);
            physicalNames += ',';
          });
        });
      }
      physicalNames = physicalNames.substring(0, physicalNames.length - 1);
      physicalNames += '\n';

      if (this.kendoDataSource !== null) {
        const addNewData = [];
        Array(dataArray).forEach(data => {
          Object.values(data).forEach(e => {
            //   Object.keys(e).forEach(key => {
            //     if (!arrayFields.includes(key)) {
            //       return;
            //     } else {
            //       tempData.push(e[key]);
            //     }
            //   });
            const tempData = [];
            arrayFields.forEach(field => {
              if (e[field]) {
                tempData.push(e[field]);
              } else {
                tempData.push("");
              }
            });
            addNewData.push(tempData);
          });
        });

        Array(addNewData).forEach(t => {
          Object.values(t).forEach(k => {
            Object.values(k).forEach(r => {
              let temp = String(r);
              if (temp.indexOf(',') > -1)
                r = temp.replace(temp, '"' + temp + '"');
              else {
                if (r !== null) r = temp.replace(temp, '"' + temp + '"');
                else r = temp.replace(temp, '""');
              }
              physicalNames += `${r},`;
            });
            physicalNames += `\n`;
          });
        });
      }

      const charCodes = [];
      for (let i = 0; i < physicalNames.length; i++) {
        charCodes.push(physicalNames.charCodeAt(i));
      }

      const sjisCodes = encoding.convert(charCodes, 'sjis', 'unicode');
      const uint8s = new Uint8Array(sjisCodes);
      const blob = new Blob([uint8s], { type: 'test/csv' });

      let link = document.createElement('a');
      link.href = window.URL.createObjectURL(blob);
      link.download = `データリスト_${dayjs().format('YYYYMMDDHHmmss')}.csv`;
      link.click();
    },
    async onCreateTemplateToExcel() {
      // ソート後のdataSourceをファイル出力
      const grid = this.getGridWidget();
      if (!grid) {
        return;
      }
      const viewData = grid.dataSource.view();
      const dataArray = Array.from(viewData)

      if (this.isEdited) {
        this.$ons.notification.confirm({
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 start
          // title: "更新確認",
          title: DIALOG_MESSAGES[13000105].title,
          // message: "編集内容がありますので、保存しますか。？",
          message: messageFormat(DIALOG_MESSAGES[13000105].message),
          // mod #6107 2023/03/23 メッセージボックス全調整 張博 end
          buttonLabels: ['いいえ', 'はい'],
          callback: async answer => {
            if (answer === 1) {
              await this.updatePatRecords();
              this.saveExcel({
                data: dataArray,
                fileName: `データリスト_${dayjs().format('YYYYMMDDHHmmss')}`,
                columns: this.getData(),
              });
            }
          },
        });
      } else {
        this.saveExcel({
          data:
            this.kendoDataSource !== null ? dataArray : null,
          fileName: `データリスト_${dayjs().format('YYYYMMDDHHmmss')}`,
          columns: this.getData(),
        });
      }
    },
    saveExcel(exportOptions) {
      let saveFn = function (dataURL) {
        kendo_file_saver_1.saveAs(dataURL, exportOptions.fileName, {
          forceProxy: exportOptions.forceProxy,
          proxyURL: exportOptions.proxyURL
        });
      };
      let options = workbook_1.workbookOptions(exportOptions);
      options.sheets.forEach(item => {
        item.rows.forEach(row => {
          if (row.type === 'data') {
            let height = 15;
            row.cells.forEach(cell => {
              let vals = 1;
              if (cell.value) {
                vals = (cell.value + "").split('\n').length;
              }
              if (vals * 15 > height){
                height = vals * 15;
              }
              if (height > 15) {
                cell.wrap = true;
                row.height = height;
              } else {
                cell.wrap = false;
              }
            });
          }
        });
      });
      workbook_1.toDataURL(options).then(saveFn);
    },
    getData() {
      let physicalNames = [];

      this.columns.forEach(field => {
        // mod #11528 【たくしん会】データリスト並び順不正 房 start
        // if (field.field !== "datetime") {
        physicalNames.push(field);
        // }
        // mod #11528 【たくしん会】データリスト並び順不正 房 end
      });

      this.kendoGridColumns.forEach(field => {
        field.columns.forEach(column => {
          let columnTmp = deepCopy(column);
          columnTmp.title = field.title + ":" + columnTmp.title;
          physicalNames.push(columnTmp);
        });
      });

      physicalNames = physicalNames.map(obj => {
        return {
          ...obj,
          cellOptions: { wrap: true, format: "@" },
        };
      });
      return physicalNames;
    },
    setGridHeight() {
      if (this.isSelectedLayout) {
        this.$nextTick(() => {
          this.updateGridHeight();
        });
      }
    },

    reconnectSocket() {
      const param = this;
      this.socketInterval = setInterval(function () {
        param.connect();
        clearInterval(this.socketInterval);
      }, 10000);
    },

    async updatePatRecords() {
      if (!this.isEdited) {
        this.isNoEditDialogVisible = true;
        return;
      }
      if (!this.isValidate()) {
        this.isValidateVisible = true;
        return;
      }

      this.isUpdating = true;
      const updateTargetPatIdList = Object.keys(
        this.editedPatIdFieldList
      ).map(keyPatId => Number(keyPatId));
      const updateTargetPatList = this.patRecordsForUpdating.filter(record =>
        updateTargetPatIdList.includes(record.pat_personal_main.pat_id)
      );

      const changeNextPatColumnInfo = [
        'pat_personal_main$pat_sex',
        'pat_personal_main$pat_birthday',
        'pat_main$medical_care_info$ward_cd',
        'pat_main$medical_care_info$main_course_cd',
        'pat_main$charge_staff_info$staff_cd$is_main$1',
        'pat_main$charge_staff_info$staff_cd$is_main$2',
      ];
      const updatePatList = updateTargetPatList.map(record => {
        const editedItemList = this.editedPatIdFieldList[
          record.pat_personal_main.pat_id
        ];
        const isEdited = editedItemList.find(key =>
          changeNextPatColumnInfo.includes(key)
        );
        return { ...record, is_changed_next_pat_info: isEdited ? true : false };
      });

      await updatePatRecords(updatePatList).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('TemplateComponent.vue', 'updatePatRecords', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        this.isUpdating = false;
        throw new Error(error);
      });

      const updOrdMainPatList = this.patRecordsForUpdating.filter(record => {
        if (this.editedPatIdFieldList[record.pat_personal_main.pat_id]) {
          return this.editedPatIdFieldList[
            record.pat_personal_main.pat_id
          ].find(
            field =>
              (field.match(/physical_info\$indicator_start_date/) ||
                field.match(/physical_info\$ctr/) ||
                field.match(/physical_info\$target_weight/)) &&
              field.match(/physical_info\$indicator_start_date/)
          );
        }
      });

      await this.updateOrdMain(updOrdMainPatList).catch(error => {
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
        getErrorMessage('TemplateComponent.vue', 'updatePatRecords', error);
        //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
        this.isUpdating = false;
        throw new Error(error);
      });

      // 編集色クリア
      $$(`.${CLASS_EDITED_CELL}`).each((_, el) =>
        el.classList.remove(CLASS_EDITED_CELL)
      );
      this.bindShowPopoverEvent();
      this.isUpdating = false;
    },

    cancelEdit() {
      if (this.isEdited) {
        this.isCancelEditDialogVisible = true;
      }
    },

    bindShowPopoverEvent() {
      const sortGrid = this.getGridWidget();
      if (sortGrid == null) {
        return;
      }
      const sortedData = sortGrid.dataSource;
      this.$nextTick(() => {
        const vue = this;
        const clickHandler = $$ => {
          return function (e) {
            const selectedIndex = $$.index(this);
            let hosp_pat_id = "";
            if (sortedData && sortedData._view.length > 0) {
              vue.selectedPatId = sortedData._view[selectedIndex].pat_id;
              hosp_pat_id = sortedData._view[selectedIndex].hosp_pat_id;
            } else {
              vue.selectedPatId =
                vue.kendoDataSource.data[selectedIndex].pat_id;
              hosp_pat_id = vue.kendoDataSource.data[selectedIndex].pat_id;
            }
            if (hosp_pat_id === " ") {
              return;
            }
            vue.popoverTarget = e.target;
            vue.isPopoverVisible = true;
          };
        };

        const $$hospPatId = $$('.cell-hosppatid');
        $$hospPatId.on('click', clickHandler($$hospPatId));
        const $$patName = $$('.cell-patname');
        $$patName.on('click', clickHandler($$patName));
        this.setSame();
      });
    },

    async moveTo(e, routeName) {
      // add #10371 編集権限について、対応する。 dengshen start
      this.isPopoverVisible = false;
      // add #10371 編集権限について、対応する。 dengshen end
      if (e.innerHTML === " ") {
        return;
      }
      let patId = this.patInfoList.filter(x => {
        let pat_name = x.pat_name;
        pat_name = pat_name.replace('*', '');
        pat_name = pat_name.replace('!', '');
        if (
          x.hosp_pat_id == e.innerHTML ||
          e.innerHTML.indexOf(pat_name) != -1
        ) {
          return true;
        } else {
          return false;
        }
      });
      if (patId.length > 0) {
        await this.selectPat(patId[0].pat_id);
      }
      if (routeName == 'exam-record-detail') {
        this.$router.push({ name: 'exam-record' });
        this.$router.push({ name: 'exam-record-detail' });
      } else if (routeName == 'exam-request-detail') {
        this.$router.push({ name: 'exam-request' });
        this.$router.push({ name: 'exam-request-detail' });
      } else {
        this.$router.push({ name: routeName });
      }
    },

    /**
     * @description 連絡先配列要素番号変更
     */
    changeInfoToOtherContact(
      targetPatIndex,
      table,
      column,
      jsonArrayIndex,
      jsonKey,
      editedField,
      editedValue
    ) {
      const isKeyPerson =
        column === 'other_contact_key_person_info' ? '1' : '0';

      column = 'other_contact_info';
      const jsonArray = this.patRecordsForUpdating[targetPatIndex][table][
        column
      ];

      const otherContactInfo = jsonArray;
      jsonArrayIndex = this.getOtherContactInfoIndex(
        otherContactInfo,
        jsonArrayIndex,
        isKeyPerson
      );
      return [table, column, jsonKey, jsonArrayIndex, editedValue];
    },

    /**
     * @description 連絡先配列(キーパーソンのみ配列＋それ以外配列)要素番号取得
     */
    getOtherContactInfoIndex(otherContactInfo, jsonArrayIndex, isKeyPerson) {
      const hasKeyJsonArray = otherContactInfo.filter(
        el => el.is_key_person === isKeyPerson
      );
      const hasKeyJsonIndex = hasKeyJsonArray.length;

      const index = otherContactInfo.findIndex(json => {
        const ctlNo = hasKeyJsonArray[jsonArrayIndex]
          ? hasKeyJsonArray[jsonArrayIndex].ctl_no
          : undefined;
        return json.ctl_no === ctlNo;
      });

      return index >= 0
        ? index
        : // 最大要素番号 = 全体配列 - 取得した配列 + 選択したグリッド(配列要素)番号
          otherContactInfo.length - hasKeyJsonIndex + Number(jsonArrayIndex);
    },

    /**
     * @description 無限ループ配列要素番号変更
     */
    changeIndexToInfinity(jsonArray, jsonArrayIndex) {
      let index = jsonArrayIndex;
      // 無限ループ対策
      if (jsonArrayIndex < 0) {
        index = jsonArray.length;
      }
      return index;
    },

    /**
     * @description バリデーションチェック
     * @returns true: 保存, false: 保存失敗
     */
    isValidate() {
      const kendoValidator = $$('#multi-pat-list-template')
        .kendoValidator()
        .data('kendoValidator');
      const keys = Object.keys(this.validateObject);
      const requiredList = keys.filter(
        key => this.validateObject[key].length > 0
      );

      if (requiredList.length > 0) {
        let columns = [];
        this.kendoGridColumns.forEach(
          item => (columns = [...columns, ...item.columns])
        );

        const strList = requiredList.map(
          required => columns.find(item => item.field === required).title
        );

        this.validateStringParams = `「${strList.join('・')}」`;
      } else {
        this.validateStringParams = '';
      }

      return requiredList.length === 0 && kendoValidator.validate();
    },

    setPhysicalExamDate(physicalInfo, editedValue, isDay) {
      let initDate = null;
      let editDay = '0000-01-01';
      let editTime = null;
      if (physicalInfo) {
        initDate = physicalInfo.exam_date;
      }

      if (initDate) {
        editDay = initDate;
        if (editDay.match(/T/)) {
          const encodeInitDate = dayjs(
            `${initDate}:00+09:00`,
            'YYYY-MM-DDTHH:mm:ss.SSSZ'
          ).format('YYYY-MM-DDTHH:mm');
          const dateList = encodeInitDate.split(/T/);
          editDay = dateList[0];
          editTime = dateList[1];
        }
      }

      if (isDay) {
        editDay = editedValue ? editedValue : '0000-01-01';
      } else {
        editTime = editedValue;
      }
      if (editTime === '' || !editTime) {
        return editDay === '0000-01-01'
          ? null
          : dayjs(`${editDay}`, 'YYYY-MM-DD').format('YYYY-MM-DD');
      }

      const editDate = dayjs(
        `${editDay}T${editTime}`,
        'YYYY-MM-DDTHH:mm'
      ).format('YYYY-MM-DDTHH:mm:ss.SSSZ');
      return editDate;
    },

    changeInfoToChargeStaffInfo(
      targetPatIndex,
      table,
      column,
      jsonArrayIndex,
      jsonKey,
      editedField,
      editedValue
    ) {
      let staffClass, itemIndex;
      [table, column, jsonKey, staffClass, itemIndex] = editedField.split('$');
      itemIndex = Number(itemIndex);
      const jsonArray = this.patRecordsForUpdating[targetPatIndex][table][
        column
      ];

      let counter = 0;
      jsonArrayIndex = `${jsonArray.findIndex(
        staff => staff[staffClass] === '1' && ++counter === itemIndex
      )}`;

      if (jsonArrayIndex < 0) {
        const maxIndex = this.changeIndexToInfinity(jsonArray, jsonArrayIndex);
        const addStaffClassIndex = itemIndex - counter;
        jsonArrayIndex = maxIndex - 1 + addStaffClassIndex;
      }
      return [table, column, jsonKey, jsonArrayIndex, editedValue];
    },

    changeInfoToMedicalHstInfo(
      targetPatIndex,
      table,
      column,
      jsonArrayIndex,
      jsonKey,
      editedValue
    ) {
      if (jsonKey === 'is_diagnosed') {
        const medicalHstInfo = this.patRecordsForUpdating[targetPatIndex][
          table
        ][column];
        // 死亡時
        jsonArrayIndex = medicalHstInfo.findIndex(
          record => record.out_come === '10'
        );

        jsonArrayIndex = this.changeIndexToInfinity(
          medicalHstInfo,
          jsonArrayIndex
        );
        return [table, column, jsonKey, jsonArrayIndex, editedValue];
      }
    },

    changeInfoToPhysicalInfo(
      targetPatIndex,
      table,
      column,
      jsonArrayIndex,
      jsonKey,
      editedField,
      editedValue
    ) {
      const initPhysical = this.initialPatRecords[targetPatIndex][table][
        column
      ];
      const initCtlNoList = initPhysical.map(item => item.ctl_no);
      const editPhysical = this.patRecordsForUpdating[targetPatIndex][table][
        column
      ];
      const addIndex = -1;
      jsonArrayIndex =
        initPhysical.length < editPhysical.length
          ? editPhysical.findIndex(item => !initCtlNoList.includes(item.ctl_no))
          : addIndex;
      jsonArrayIndex = this.changeIndexToInfinity(editPhysical, jsonArrayIndex);

      // 測定日時設定
      const isDay = editedField.match(/exam_date/);
      if (isDay || editedField.match(/exam_time/)) {
        editedValue = this.setPhysicalExamDate(
          editPhysical[jsonArrayIndex],
          editedValue,
          isDay
        );
        jsonKey = 'exam_date';
      }
      return [table, column, jsonKey, jsonArrayIndex, editedValue];
    },

    /**
     * @description 指示更新
     * @param {Object} record 更新用身体情報レコード
     * @param {String} targetWeight 更新前目標体重
     */
    async updateOrdMain(recordList) {
      const sendJsonList = recordList.map(record => {
        const patId = record.pat_personal_main.pat_id;
        const physicalInfo = record.pat_unique.physical_info[0];
        const indStartDate = physicalInfo.indicator_start_date;
        // 一年後
        const indEndDate = dayjs(indStartDate, 'YYYYMMDD')
          .add(1, 'y')
          .subtract(1, 'days')
          .format('YYYYMMDD');

        return {
          // 施設コード
          facility_cd: this.facilityCd,
          // 患者ID
          pat_id: patId,
          // 治療開始日
          ind_start_date: indStartDate,
          // 治療終了日
          ind_end_date: indEndDate,
          // 曜日パターン
          week_pattern: "[{'text': '全','done': false,'value': 0}]",
          // 変更対象クールコード
          ind_kur_cd: JSON.stringify([]),
          // 変更対象治療方法コード
          ind_treatment_cd: JSON.stringify([]),
          // 終了日存在フラグ
          is_deadline: false,

          dw: physicalInfo.dw,
          ctr: physicalInfo.ctr,
          target_weight: physicalInfo.target_weight,
          indicator_cd: physicalInfo.indicator_cd,
          upd_user_cd: null,
        };
      });

      await ApiHelper.post('/mainData/updateOrdMainList', sendJsonList).catch(
        error => {
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add start
          getErrorMessage('TemplateComponent.vue', 'updateOrdMain', error);
          //FNSI-修正 VUEのエラー場合のログ対応 liuxl add end
          throw error;
        }
      );
    },
    // add #11528 【たくしん会】データリスト並び順不正 房 start
    parseStrToDate(dateStr) {
      return new Date(dateStr.replace(/\//g, "-").replace(" ", "T"));
    },
    // add #11528 【たくしん会】データリスト並び順不正 房 end
  },
  // add 性能改善メモリ不足 shan start
  beforeDestroy() {
    this.gridResizeObserver?.disconnect();
    // Rootページのサイドバーボタン要素のイベントリスナー解除
    const rootSideBarBtn = document.querySelector('#showPatientSearchSidebarBtn');
    rootSideBarBtn?.removeEventListener('click', this.setGridHeight);
    /* modify by chamaojia 2023-06-08 [8610] EventBusイベントの結合解除は結合と一致する（イベントコールバック関数を指定）  --start */
    EventBus.$off('onInitLayout', this.getInitData);
    EventBus.$off('refresh', this.getInitData);
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 start
    EventBus.$off("requestReportParams", this.requestrReportParams);
    /* modify by chamaojia 2023-06-08 [8610] EventBusイベントの結合解除は結合と一致する（イベントコールバック関数を指定）  --end */
    //add 5984 機能帳票でパラメータが正しく渡されていない 吉 end
    clearInterval(this.socketInterval);
    // dataの初期化
    Object.assign(this.$data, this.$options.data());
    //No.7167 upd Paging Optimization runtime by ztc start
    if (this.getSelectedDynamicLayout.templateCd == PAT_INFO_TWO_TEMPLATE_CD || this.getSelectedDynamicLayout.templateCd == TREATMENT_PLAN_TREATMENT_RECORD) {
      //del 9796データリスト画面で患者情報2のデータが表示されない。start
      //window.removeEventListener("scroll", this.handleScroll, true);
      //del 9796データリスト画面で患者情報2のデータが表示されない。end
    }
    //No.7167 upd Paging Optimization runtime by ztc end
  },
  // add 性能改善メモリ不足 shan end
};
</script>
<style>
@media print {
  /** tableレイアウト崩れ回避 */
  body:has(#multi-pat-list-template) #main-id {
    display: inline-block;
  }
  /** ヘッダレイアウト崩れ回避 */
  body:has(#multi-pat-list-template) #bbs-search-area {
    width: 60%;
  }
  body:has(#multi-pat-list-template) .file-button {
    margin-left: 10%;
  }
}
</style>

<style scoped>
.multi-pat-list {
  max-height: 97%;
  background-color: var(--main-background-color);
  color: var(--ntss-list-body-color);
}

.btn-save {
  position: fixed;
  bottom: 45px;
  right: 17px;
  text-align: center;
  box-sizing: border-box;
  outline: 0;
}

.btn-cancel {
  position: fixed;
  bottom: 45px;
  right: 120px;
  text-align: center;
  box-sizing: border-box;
  outline: 0;
}

.loading-modal {
  text-align: center;
  font-size: 30px;
}

.transition-popover {
  padding: 10px;
  float: left;
  width: 140px;
}

.transition-button {
  margin-bottom: 2px;
  justify-content: left;
  padding: 0;
  margin-right: 5px;
  width: 12.5em;
}

.transition-button:last-child {
  margin-bottom: 0;
}

/* kendo-grid用style */
/* 全体の色 */
.multi-pat-list :deep(.k-grid) {
  background-color: var(--ntss-list-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

.multi-pat-list :deep(.k-widget) {
  font-size: 1em;
}

/* セルの枠線(なぜか縦線にしか色がつかない) */
.multi-pat-list :deep(.k-grid tr),
.multi-pat-list :deep(.k-grid td) {
  border-color: var(--master-maintenance-kgrid-border-color) !important;
}

/* 行マウスオーバー */
.multi-pat-list :deep(.k-grid tr:hover) {
  background-color: var(--ntss-list-body-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

/* 列ヘッダ */
.multi-pat-list :deep(.k-header) {
  vertical-align: middle !important;
  background-color: var(--ntss-list-header-background-color);
  color: #ffffff;
}
.multi-pat-list :deep(.k-header[data-role='columnsorter']) {
  /* width: 125px; */
  vertical-align: middle !important;
  background-color: #333333;
  background-image: none;
}
.multi-pat-list :deep(.k-header[data-field='pat_personal_main$hosp_pat_id']) {
  /* width: 125px; */
  vertical-align: middle !important;
  background-color: #333333;
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  );
}
.multi-pat-list :deep(.k-header[data-field='pat_personal_main$pat_name']) {
  width: 125px;
  vertical-align: middle !important;
  background-color: #333333;
  background-image: linear-gradient(
    rgba(255, 255, 255, 0.3) 0%,
    transparent 50%,
    transparent 50%,
    rgba(0, 0, 0, 0.1) 100%
  ) !important;
}

/* 入力不可列のヘッダ */
.multi-pat-list :deep(.k-header-disabled) {
  background-color: #808080 !important;
  background-image: none;
}

/* 偶数行 */
.multi-pat-list :deep(.k-alt) {
  background-color: var(--ntss-list-content-2nd-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

/* 入力UI */
.multi-pat-list :deep(.k-textbox),
.multi-pat-list :deep(.k-dropdown-wrap),
.multi-pat-list :deep(.k-numeric),
.multi-pat-list :deep(.k-select),
.multi-pat-list :deep(.k-popup) {
  background-color: var(--main-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}

/* kendoDropDownListの選択肢 */
.multi-pat-list :deep(.k-popup) {
  border-color: var(--ntss-list-body-background-color) !important;
}

/* kendoDropDownListの選択肢のマウスオーバー */
.multi-pat-list :deep(.k-popup li:hover) {
  background-color: var(--ntss-list-body-background-color) !important;
  color: var(--ntss-list-body-color) !important;
}
.multi-pat-list :deep(.k-i-sort-asc-sm::before) {
  content: "▲" !important;
  color: #ffffff;
}
.multi-pat-list :deep(.k-i-sort-desc-sm::before) {
  content: "▼" !important;
  color: #ffffff;
}

#multi-pat-list-template :deep(.grid-required-cell) {
  background-color: #ff6358 !important;
}

#multi-pat-list-template :deep(.grid-edited-cell) {
  text-overflow: ellipsis !important;
  overflow: hidden !important;
}

ons-popover :deep(.popover__content) {
  width: 14em;
}

.transition-button .icon {
  height: 1.5em;
  width: 1.5em;
  margin: 0 5px 0 5px;
}
#multi-pat-list-template :deep(.same-icon) {
  height: 1em;
  display: inline-block;
  margin-left: 0.5em;
}

/* 携帯が似合う shan start */
/* :deep(.k-grid-header-locked){
   width: 375px !important;
 }
:deep(.k-grid-content-locked){
   width: 375px !important;
 } */
/* :deep(.k-grid-header-wrap){
   width: calc(100%-375px) !important;
 }
:deep(.k-grid-content){
   width: calc(100%-375px) !important;
 } */
:deep(.multi-pat-list .k-grid td) {
  width: 150px !important;
}

@media screen and (max-width: 600px) {
/* :deep(.k-grid-header-locked) {
     width: 180px !important;
   } */
/* :deep(.k-header[data-field="pat_personal_main$hosp_pat_id"]) {
    width: 65px !important;
    text-overflow: clip !important;
  }
:deep(.k-header[data-field="pat_personal_main$pat_name"]) {
    width: 65px !important;
  } */
/* :deep(.k-grid-content-locked){
   width: 180px !important;
 }
:deep(.multi-pat-list .k-grid td){
   width: 100px !important;
 } */
}
:deep(.k-grid td) {
  word-wrap: break-word;
}
:deep(.k-grid th) {
  word-wrap: break-word;
}
/* 携帯が似合う shan end */
/*add #6256 背景色が変わらない 徐博 start*/
#multi-pat-list-template :deep(.grid-required-cell) {
  background-color: #ff6358 !important;
}
/*add #6256 背景色が変わらない 徐博 end*/
/* 前体重測定済 */
#multi-pat-list-template :deep(.grid-after-send-condition-cell) {
  background-color: #42cb92 !important;
}
/* 治療中 */
#multi-pat-list-template :deep(.grid-dialysis-cell) {
  background-color: #2ca06f !important;
}
/* 治療終了 */
#multi-pat-list-template :deep(.grid-after-dialysis-cell) {
  background-color: #557769 !important;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked) {
  overflow-y: scroll !important;
  -webkit-overflow-scrolling: touch;
  scrollbar-width: none;
  -ms-overflow-style: none;
}
.kendo-grid-toolbar-style :deep(.k-grid-content-locked::-webkit-scrollbar) {
  display: none;
}
:deep(.k-grid-container td) {
  white-space: nowrap !important;
  overflow: hidden !important;
  text-overflow: ellipsis !important;
}
@media print {
  .multi-pat-list {
    position: absolute;
  }
  /** スクロールコンテナ */
  .multi-pat-list :deep(.k-grid-header-wrap),
  .multi-pat-list :deep(.k-grid-content) {
    overflow: hidden !important;
    height: auto !important;
  }
  /** 固定列調整 */
  .multi-pat-list :deep(.k-grid-content-locked) {
    height: auto !important;
  }
  /** 固定列枠線 */
  .multi-pat-list :deep(.k-grid-header-locked::after) {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-header-background-color);
    pointer-events: none;
  }
  .multi-pat-list :deep(.k-grid-content-locked::after) {
    content: "";
    position: absolute;
    top: 0;
    right: 0;
    width: 1px;
    height: 100%;
    background: var(--master-maintenance-kgrid-border-color);
    pointer-events: none;
  }
  /** ヘッダのズレ原因を除去 */
  .multi-pat-list :deep(.k-grid-header) {
    padding-right: 0 !important;
  }
  /** gridの幅 */
  .multi-pat-list :deep(.k-grid) {
    width: 100vw;
    height: auto !important;
  }
  /** 印刷時に横スクロール右端時に強制的にスクロール位置を調整 */
  /* 右端時固定列最前面表示*/
  .multi-pat-list:has(table.scroll-rightmost) :deep(.k-grid-content-locked),
  .multi-pat-list:has(table.scroll-rightmost) :deep(.k-grid-header-locked) {
    z-index: 1;
    background-color: inherit;
  }
  .multi-pat-list:has(table.scroll-rightmost) {
    margin-left: -1px !important;
  }
  .multi-pat-list :deep(.k-grid-header-wrap:has(table.scroll-rightmost)),
  .multi-pat-list :deep(.k-grid-content:has(table.scroll-rightmost)) {
    position: static;
  }
}
</style>
