package jp.co.nikkiso.ntss.admin_web.service.statusList;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

import com.fasterxml.jackson.databind.JsonNode;

import jp.co.nikkiso.ntss.admin_web.service.utils.DateTimeUtils;
import jp.co.nikkiso.ntss.admin_web.service.utils.StrUtils;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.custom.TreatmentStatusList;

public class Util {
  /**
   * 与えられた治療情報テーブルのレコードから指定したフィールド名の情報を取得します。
   * @param treatmentStatusList 治療情報データ
   * @param columnName 取得するフィールド名
   * @return
   */
  public static Object getTreatmentStatusColumnData(TreatmentStatusList treatmentStatusList, String columnName) {
    final String ORD_NO = "ord_no";
    final String PAT_ID = "pat_id";
    final String FN_PAT_ID = "fn_pat_id";
    final String TREAT_DATE = "treat_date";
    final String TREAT_WEEK = "treat_week";
    final String FACILITY_CD = "facility_cd";
    final String FACILITY_NAME = "facility_name";
    final String IND_VA_CD = "ind_va_cd";
    final String IND_TREATMENT_CD = "ind_treatment_cd";
    final String IND_TREATMENT_NAME = "ind_treatment_name";
    final String IND_KUR_CD = "ind_kur_cd";
    final String IND_KUR_NAME = "ind_kur_name";
    final String IND_TREAT_START_TIME = "ind_treat_start_time";
    final String IND_BED_CD = "ind_bed_cd";
    final String IND_BED_NAME = "ind_bed_name";
    final String IND_SCHEDULE_USER_INFO = "ind_schedule_user_info";
    final String IND_COND_INFO = "ind_cond_info";
    final String IND_MEDI_INFO = "ind_medi_info";
    final String IND_EQUIP_INFO = "ind_equip_info";
    final String IND_IND_COMMENT_INFO = "ind_ind_comment_info";
    final String IND_TARE_INFO = "ind_tare_info";
    final String IND_OFF_WATER_INFO = "ind_off_water_info";
    final String IND_DEVICE_SET_INFO = "ind_device_set_info";
    final String RST_FN_DIALYSIS_NO = "rst_fn_dialysis_no";
    final String RST_RELATION_DIALYSIS_NO = "rst_relation_dialysis_no";
    final String RST_EDITION = "rst_edition";
    final String RST_IS_UPDATE_EDITION = "rst_is_update_edition";
    final String RST_INPUT_CLASS = "rst_input_class";
    final String RST_DIALYSIS_STATE = "rst_dialysis_state";
    final String RST_TREATMENT_CD = "rst_treatment_cd";
    final String RST_TREATMENT_NAME = "rst_treatment_name";
    final String RST_KUR_CD = "rst_kur_cd";
    final String RST_KUR_NAME = "rst_kur_name";
    final String RST_BED_CD = "rst_bed_cd";
    final String RST_BED_NAME = "rst_bed_name";
    final String RST_MACHINE_NO = "rst_machine_no";
    final String RST_MACHINE_NAME = "rst_machine_name";
    final String RST_COND_SEND_DATE = "rst_cond_send_date";
    final String RST_ACCEPT_DATE = "rst_accept_date";
    final String RST_START_DATE = "rst_start_date";
    final String RST_END_DATE = "rst_end_date";
    final String RST_RETURN_HOME_DATE = "rst_return_home_date";
    final String RST_IN_OUT_CLASS = "rst_in_out_class";
    final String RST_DIALYSIS_CNT = "rst_dialysis_cnt";
    final String RST_WARD_CD = "rst_ward_cd";
    final String RST_WARD_NAME = "rst_ward_name";
    final String RST_COURSE_CD = "rst_course_cd";
    final String RST_COURSE_NAME = "rst_course_name";
    final String RST_PUNCTURE_USER_INFO = "rst_puncture_user_info";
    final String RST_RETURN_USER_INFO = "rst_return_user_info";
    final String RST_CHARGE_USER_INFO = "rst_charge_user_info";
    final String RST_BLOOD_CIRCULATE_TOTAL = "rst_blood_circulate_total";
    final String RST_RUNNING_TIME = "rst_running_time";
    final String RST_KT_V = "rst_kt_v";
    final String REC_SET_DATE = "rec_set_date";
    final String SEND_CTL_NO = "send_ctl_no";
    final String BLOOD_PURIFIER_NAME = "blood_purifier_name";
    final String PULL_LEAVE_AMOUNT = "pull_leave_amount";
    final String RST_COND_INFO = "rst_cond_info";
    final String RST_MEDI_INFO = "rst_medi_info";
    final String RST_EQUIP_INFO = "rst_equip_info";
    final String RST_IND_COMMENT_INFO = "rst_ind_comment_info";
    final String RST_TARE_INFO = "rst_tare_info";
    final String RST_OFF_WATER_INFO = "rst_off_water_info";
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//    final String RST_DEVICE_SET_INFO = "rst_device_set_info";
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    final String RST_WEIGHT_INFO = "rst_weight_info";
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//    final String RST_VITAL_INFO = "rst_vital_info";
    /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    final String RST_COMPLAINT_INFO = "rst_complaint_info";
    final String RST_TREATMENT_INFO = "rst_treatment_info";
    final String RST_TREAT_STAFF_INFO = "rst_treat_staff_info";
    final String RST_ROUNDS_INFO = "rst_rounds_info";
    final String IS_DEL = "is_del";
    final String UP_DATE = "up_date";
    final String REG_DATE = "reg_date";
    final String IND_MST_VA_NAME = "ind_mst_va_name";
    final String IND_MST_TREATMENT_NAME = "ind_mst_treatment_name";
    final String IND_MST_KUR_NAME = "ind_mst_kur_name";
    final String IND_MST_BED_NAME = "ind_mst_bed_name";
    final String RST_PUNCTURE_USER_ID_A = "rst_puncture_userid_a";
    final String RST_PUNCTURE_USER_ID_B = "rst_puncture_userid_b";
    final String RST_RETURN_USER_ID_A = "rst_return_userid_a";
    final String RST_RETURN_USER_ID_B = "rst_return_userid_b";
    final String RST_CHARGE_USER_ID_A = "rst_charge_userid_a";
    final String RST_CHARGE_USER_ID_B = "rst_charge_userid_b";
    final String RST_PUNCTURE_DATE_A = "rst_puncture_date_a";
    final String RST_PUNCTURE_DATE_B = "rst_puncture_date_b";
    final String RST_RETURN_DATE_A = "rst_return_date_a";
    final String RST_RETURN_DATE_B = "rst_return_date_b";
    final String RST_CHARGE_DATE_A = "rst_charge_date_a";
    final String RST_CHARGE_DATE_B = "rst_charge_date_b";

    Object ret = null;
    //mod FNSI redmine 6018 6123 劉祥霖 start
    //rst_weight_infoの場合、スペースが発見、削除する
    String columnNameString=columnName.replace(" ","");
    switch (columnNameString) {
    //mod FNSI redmine 6018 6123 劉祥霖 end
    case ORD_NO:
      ret = treatmentStatusList.getOrdNo();
      break;
    case PAT_ID:
      ret = treatmentStatusList.getPatId();
      break;
    case FN_PAT_ID:
      ret = treatmentStatusList.getFnPatId();
      break;
    case TREAT_DATE:
      ret = treatmentStatusList.getTreatDate();
      break;
    case TREAT_WEEK:
      ret = treatmentStatusList.getTreatWeek();
      break;
    case FACILITY_CD:
      ret = treatmentStatusList.getFacilityCd();
      break;
    case FACILITY_NAME:
      ret = treatmentStatusList.getFacilityName();
      break;
    case IND_VA_CD:
      ret = treatmentStatusList.getIndVaCd();
      break;
    case IND_TREATMENT_CD:
      ret = treatmentStatusList.getIndTreatmentCd();
      break;
    case IND_TREATMENT_NAME:
      ret = treatmentStatusList.getIndMstKurName();
      break;
    case IND_KUR_CD:
      ret = treatmentStatusList.getIndKurCd();
      break;
    case IND_KUR_NAME:
      ret = treatmentStatusList.getIndKurName();
      break;
    case IND_TREAT_START_TIME:
      ret = treatmentStatusList.getIndTreatStartTime();
      break;
    case IND_BED_CD:
      ret = treatmentStatusList.getIndBedCd();
      break;
    case IND_BED_NAME:
      ret = treatmentStatusList.getIndBedName();
      break;
    case IND_SCHEDULE_USER_INFO:
      ret = treatmentStatusList.getIndScheduleUserInfo();
      break;
    case IND_COND_INFO:
      ret = treatmentStatusList.getIndCondInfo();
      break;
    case IND_MEDI_INFO:
      ret = treatmentStatusList.getIndMediInfo();
      break;
    case IND_EQUIP_INFO:
      ret = treatmentStatusList.getIndEquipInfo();
      break;
    case IND_IND_COMMENT_INFO:
      ret = treatmentStatusList.getIndIndCommentInfo();
      break;
    case IND_TARE_INFO:
      ret = treatmentStatusList.getIndTareInfo();
      break;
    case IND_OFF_WATER_INFO:
      ret = treatmentStatusList.getIndOffWaterInfo();
      break;
    case IND_DEVICE_SET_INFO:
      ret = treatmentStatusList.getIndDeviceSetInfo();
      break;
    case RST_FN_DIALYSIS_NO:
      ret = treatmentStatusList.getRstFnDialysisNo();
      break;
    case RST_RELATION_DIALYSIS_NO:
      ret = treatmentStatusList.getRstRelationDialysisNo();
      break;
    case RST_EDITION:
      ret = treatmentStatusList.getRstEdition();
      break;
    case RST_IS_UPDATE_EDITION:
      ret = treatmentStatusList.getRstIsUpdateEdition();
      break;
    case RST_INPUT_CLASS:
      ret = treatmentStatusList.getRstInputClass();
      break;
    case RST_DIALYSIS_STATE:
      ret = treatmentStatusList.getRstDialysisState();
      break;
    case RST_TREATMENT_CD:
      ret = treatmentStatusList.getRstTreatmentCd();
      break;
    case RST_TREATMENT_NAME:
      ret = treatmentStatusList.getRstTreatmentName();
      break;
    case RST_KUR_CD:
      ret = treatmentStatusList.getRstKurCd();
      break;
    case RST_KUR_NAME:
      ret = treatmentStatusList.getRstKurName();
      break;
    case RST_BED_CD:
      ret = treatmentStatusList.getRstBedCd();
      break;
    case RST_BED_NAME:
      ret = treatmentStatusList.getRstBedName();
      break;
    case RST_MACHINE_NO:
      ret = treatmentStatusList.getRstMachineNo();
      break;
    case RST_MACHINE_NAME:
      ret = treatmentStatusList.getRstMachineName();
      break;
    case RST_COND_SEND_DATE:
      ret = treatmentStatusList.getRstCondSendDate();
      break;
    case RST_ACCEPT_DATE:
      ret = treatmentStatusList.getRstAcceptDate();
      break;
    case RST_START_DATE:
      ret = treatmentStatusList.getRstStartDate();
      break;
    case RST_END_DATE:
      ret = treatmentStatusList.getRstEndDate();
      break;
    case RST_RETURN_HOME_DATE:
      ret = treatmentStatusList.getRstReturnHomeDate();
      break;
    case RST_IN_OUT_CLASS:
      ret = treatmentStatusList.getRstInOutClass();
      break;
    case RST_DIALYSIS_CNT:
      ret = treatmentStatusList.getRstDialysisCnt();
      break;
    case RST_WARD_CD:
      ret = treatmentStatusList.getRstWardCd();
      break;
    case RST_WARD_NAME:
      ret = treatmentStatusList.getRstWardName();
      break;
    case RST_COURSE_CD:
      ret = treatmentStatusList.getRstCourseCd();
      break;
    case RST_COURSE_NAME:
      ret = treatmentStatusList.getRstCourseName();
      break;
    case RST_PUNCTURE_USER_INFO:
      ret = treatmentStatusList.getRstPunctureUserInfo();
      break;
    case RST_RETURN_USER_INFO:
      ret = treatmentStatusList.getRstReturnUserInfo();
      break;
    case RST_CHARGE_USER_INFO:
      ret = treatmentStatusList.getRstChargeUserInfo();
      break;
    case RST_BLOOD_CIRCULATE_TOTAL:
      ret = treatmentStatusList.getRstBloodCirculateTotal();
      break;
    case RST_RUNNING_TIME:
      ret = treatmentStatusList.getRstRunningTime();
      break;
    case RST_KT_V:
      ret = treatmentStatusList.getRstKtV();
      break;
    case REC_SET_DATE:
      ret = treatmentStatusList.getRecSetDate();
      break;
    case SEND_CTL_NO:
      ret = treatmentStatusList.getSendCtlNo();
      break;
    case BLOOD_PURIFIER_NAME:
      ret = treatmentStatusList.getBloodPurifierName();
      break;
    case PULL_LEAVE_AMOUNT:
      ret = treatmentStatusList.getPullLeaveAmount();
      break;
    case RST_COND_INFO:
      ret = treatmentStatusList.getRstCondInfo();
      break;
    case RST_MEDI_INFO:
      ret = treatmentStatusList.getRstMediInfo();
      break;
    case RST_EQUIP_INFO:
      ret = treatmentStatusList.getRstEquipInfo();
      break;
    case RST_IND_COMMENT_INFO:
      ret = treatmentStatusList.getRstIndCommentInfo();
      break;
    case RST_TARE_INFO:
      ret = treatmentStatusList.getRstTareInfo();
      break;
    case RST_OFF_WATER_INFO:
      ret = treatmentStatusList.getRstOffWaterInfo();
      break;
      /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//    case RST_DEVICE_SET_INFO:
//      ret = treatmentStatusList.getRstDeviceSetInfo();
//      break;
      /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    case RST_WEIGHT_INFO:
      ret = treatmentStatusList.getRstWeightInfo();
      break;
      /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --start */
//    case RST_VITAL_INFO:
//      ret = treatmentStatusList.getRstVitalInfo();
//      break;
      /* del by shiyw 2024-01-31 [#10196]ord_mainのデータ定義の修正 --end */
    case RST_COMPLAINT_INFO:
      ret = treatmentStatusList.getRstComplaintInfo();
      break;
    case RST_TREATMENT_INFO:
      ret = treatmentStatusList.getRstTreatmentInfo();
      break;
    case RST_TREAT_STAFF_INFO:
      ret = treatmentStatusList.getRstTreatStaffInfo();

      break;
    case RST_ROUNDS_INFO:
      ret = treatmentStatusList.getRstRoundsInfo();
      break;
    case IS_DEL:
      ret = treatmentStatusList.getIsDel();
      break;
    case UP_DATE:
      ret = treatmentStatusList.getUpDate();
      break;
    case REG_DATE:
      ret = treatmentStatusList.getRegDate();
      break;

    case IND_MST_VA_NAME:
      ret = treatmentStatusList.getIndMstVaName();
      break;
    case IND_MST_TREATMENT_NAME:
      ret = treatmentStatusList.getIndMstTreatmentName();
      break;
    case IND_MST_KUR_NAME:
      ret = treatmentStatusList.getIndMstKurName();
      break;
    case IND_MST_BED_NAME:
      ret = treatmentStatusList.getIndMstBedName();
      break;

    case RST_PUNCTURE_USER_ID_A:
      ret = treatmentStatusList.getRstPunctureUserIdA();
      break;
    case RST_PUNCTURE_USER_ID_B:
      ret = treatmentStatusList.getRstPunctureUserIdB();
      break;
    case RST_RETURN_USER_ID_A:
      ret = treatmentStatusList.getRstReturnUserIdA();
      break;
    case RST_RETURN_USER_ID_B:
      ret = treatmentStatusList.getRstReturnUserIdB();
      break;
    case RST_CHARGE_USER_ID_A:
      ret = treatmentStatusList.getRstChargeUserIdA();
      break;
    case RST_CHARGE_USER_ID_B:
      ret = treatmentStatusList.getRstChargeUserIdB();
      break;
    case RST_PUNCTURE_DATE_A:
      ret = treatmentStatusList.getRstPunctureDateA();
      break;
    case RST_PUNCTURE_DATE_B:
      ret = treatmentStatusList.getRstPunctureDateB();
      break;
    case RST_RETURN_DATE_A:
      ret = treatmentStatusList.getRstReturnDateA();
      break;
    case RST_RETURN_DATE_B:
      ret = treatmentStatusList.getRstReturnDateB();
      break;
    case RST_CHARGE_DATE_A:
      ret = treatmentStatusList.getRstChargeDateA();
      break;
    case RST_CHARGE_DATE_B:
      ret = treatmentStatusList.getRstChargeDateB();
      break;
    }

    return ret != null ? ret : "";
  }

  /**
   * 与えられた装置状態テーブルのレコードから指定したフィールド名の情報を取得します。
   * @param mntMachineState 装置状態データ
   * @param columnName 取得するフィールド名
   * @return
   */
  public static Object getMachineStateColumnData(MntMachineState mntMachineState, String columnName) {
    /* add by chamaojia 2024-10-24 [9312] add null value judgment --start */
    if (mntMachineState == null) {
      return "";
    }
    /* add by chamaojia 2024-10-24 [9312] add null value judgment --end */
    final String FACILITY_CD = "facility_cd";
    final String MACHINE_TYPE_CD = "machine_type_cd";
    final String MACHINE_SERIAL = "machine_serial";
    final String MODEL = "model";
    final String MACHINE_NAME = "machine_name";
    final String BED_CD = "bed_cd";
    final String BED_NAME = "bed_name";
    final String PROCESS_STATE = "process_state";
    final String M_NOTICE_CNT = "m_notice_cnt";
    final String PREVENTIVE_MAINTE_CNT = "preventive_mainte_cnt";
    final String IS_PREVENTIVE_MAINTE = "is_preventive_mainte";
    final String USE_TIME = "use_time";
    final String MACHINE_STATUS = "machine_status";
    final String ALARM_MONI = "alarm_moni";
    final String IS_OFFLINE = "is_offline";
    final String ORD_NO = "ord_no";
    final String NEXT_ORD_NO = "next_ord_no";
    final String PAT_ID = "pat_id";
    final String NEXT_PATID = "next_patid";
    final String NEXT_KUR_CD = "next_kur_cd";
    final String START_PLAN_DATE = "start_plan_date";
    final String END_PLAN_DATE = "end_plan_date";
    final String WEIGH_BEFORE_DATE = "weigh_before_date";
    final String COND_SEND_DATE = "cond_send_date";
    final String COND_SET_DATE = "cond_set_date";
    final String START_DATE = "start_date";
    final String END_DATE = "end_date";
    final String WEIGH_AFTER_DATE = "weigh_after_date";
    final String ALARM_LIST = "alarm_list";
    final String REG_DATE = "reg_date";
    final String UP_DATE = "up_date";
    // add FNSI-モニタデータ取得変更 付 start
    final String MONITOR_DATA = "monitor_data";
    // add FNSI-モニタデータ取得変更 付 end

    Object ret = null;
    switch (columnName) {
    case FACILITY_CD:
      ret = mntMachineState.getFacilityCd();
      break;
    case MACHINE_TYPE_CD:
      ret = mntMachineState.getMachineTypeCd();
      break;
    case MACHINE_SERIAL:
      ret = mntMachineState.getMachineSerial();
      break;
    case MODEL:
      ret = mntMachineState.getModel();
      break;
    case MACHINE_NAME:
      ret = mntMachineState.getMachineName();
      break;
    case BED_CD:
      ret = mntMachineState.getBedCd();
      break;
    case BED_NAME:
      ret = mntMachineState.getBedName();
      break;
    case PROCESS_STATE:
      ret = getProcessName(mntMachineState.getProcessState());
      break;
    case M_NOTICE_CNT:
      ret = mntMachineState.getMNoticeCnt();
      break;
    case PREVENTIVE_MAINTE_CNT:
      ret = mntMachineState.getPreventiveMainteCnt();
      break;
    case IS_PREVENTIVE_MAINTE:
      ret = mntMachineState.getIsPreventiveMainte();
      break;
    case USE_TIME:
      ret = mntMachineState.getUseTime();
      break;
    case MACHINE_STATUS:
      ret = mntMachineState.getMachineStatus();
      break;
    case ALARM_MONI:
      ret = mntMachineState.getAlarmMoni();
      break;
    case IS_OFFLINE:
      ret = mntMachineState.getIsOffline();
      break;
    case ORD_NO:
      ret = mntMachineState.getOrdNo();
      break;
    case NEXT_ORD_NO:
      ret = mntMachineState.getNextOrdNo();
      break;
    case PAT_ID:
      ret = mntMachineState.getPatId();
      break;
    case NEXT_PATID:
      ret = mntMachineState.getNextPatid();
      break;
    case NEXT_KUR_CD:
      ret = mntMachineState.getNextKurCd();
      break;
    case START_PLAN_DATE:
      ret = mntMachineState.getStartPlanDate();
      break;
    case END_PLAN_DATE:
      ret = mntMachineState.getEndPlanDate();
      break;
    case WEIGH_BEFORE_DATE:
      ret = mntMachineState.getWeighBeforeDate();
      break;
    case COND_SEND_DATE:
      ret = mntMachineState.getCondSendDate();
      break;
    case COND_SET_DATE:
      ret = mntMachineState.getCondSetDate();
      break;
    case START_DATE:
      ret = mntMachineState.getStartDate();
      break;
    case END_DATE:
      ret = mntMachineState.getEndDate();
      break;
    case WEIGH_AFTER_DATE:
      ret = mntMachineState.getWeighAfterDate();
      break;
    case ALARM_LIST:
      ret = mntMachineState.getAlarmList();
      break;
    case REG_DATE:
      ret = mntMachineState.getRegDate();
      break;
    case UP_DATE:
      ret = mntMachineState.getUpDate();
      break;
    // add FNSI-モニタデータ取得変更 付 start
    case MONITOR_DATA:
      ret = mntMachineState.getMonitorData();
      break;
    // add FNSI-モニタデータ取得変更 付 end
    }
    return ret != null ? ret : "";
  }

  /**
   * 与えられた装置モニターデータテーブルのレコードから指定したフィールド名の情報を取得します。
   * @param mniMonitor
   * @param columnName
   * @return
   */
  public static Object getMniMonitorColumnData(MniMonitor mniMonitor, String columnName) {
    /* add by chamaojia 2024-10-24 [9312] add null value judgment --start */
    if (mniMonitor == null) {
      return "";
    }
    /* add by chamaojia 2024-10-24 [9312] add null value judgment --end */

    final String BIO_MONI_CTL_NO = "bio_moni_ctl_no";
    final String FACILITY_CD = "facility_cd";
    final String MACHINE_TYPE_CD = "machine_type_cd";
    final String MACHINE_SERIAL = "machine_serial";
    final String ORD_NO = "ord_no";
    final String PAT_ID = "pat_id";
    final String DATA_TYPE = "data_type";
    final String MONITOR_DATA = "monitor_data";
    final String IS_DEL = "is_del";
    final String OCCUR_DATE = "occur_date";
    final String REG_DATE = "reg_date";
    final String UP_DATE = "up_date";

    Object ret = null;

    switch (columnName) {
    case BIO_MONI_CTL_NO:
      ret = mniMonitor.getBioMoniCtlNo();
      break;
    case FACILITY_CD:
      ret = mniMonitor.getFacilityCd();
      break;
    case MACHINE_TYPE_CD:
      ret = mniMonitor.getMachineTypeCd();
      break;
    case MACHINE_SERIAL:
      ret = mniMonitor.getMachineSerial();
      break;
    case ORD_NO:
      ret = mniMonitor.getOrdNo();
      break;
    case PAT_ID:
      ret = mniMonitor.getPatId();
      break;
    case DATA_TYPE:
      ret = mniMonitor.getDataType();
      break;
    case MONITOR_DATA:
      ret = mniMonitor.getMonitorData();
      break;
    case IS_DEL:
      ret = mniMonitor.getIsDel();
      break;
    case OCCUR_DATE:
      ret = mniMonitor.getOccurDate();
      break;
    case REG_DATE:
      ret = mniMonitor.getRegDate();
      break;
    case UP_DATE:
      ret = mniMonitor.getUpDate();
      break;
    }

    return ret != null ? ret : "";
  }

  /**
   * 左詰め0埋め固定長文字列を返す
   * @param 文字列
   * @param 戻り文字列の長さ
   */
  public static String getZeroRightPaddingString(String string, int length) {
    for (int looper = 0; looper < length; looper++) {
      string = "0" + string;
    }
    String rtn = string.substring(string.length() - length, string.length());
    return rtn;
  }

  /**
   * DateをLocalDateTimeに変換
   * @param date 日付時刻型(Date)
   * @return 日付時刻型(LocalDateTime)
   */
  public static LocalDateTime dateToLocalDateTime( Date date ) {
    LocalDateTime ret = null;
    try {
      ret = LocalDateTime.ofInstant(date.toInstant(), ZoneId.systemDefault());
    } catch ( Exception ex ) {
    }
    return ret;
  }
  /**
   * ISO8601形式の文字列をLocalDateTimeに変換
   * @param date ISO8601形式の文字列
   * @return 日付時刻型(LocalDateTime)
   */
  public static LocalDateTime iso8601StringToLocalDateTime( String date ) {
    LocalDateTime ret = null;
    try {
      // 日付時刻変換(ISO8601形式)→yyyy/mm/dd hh:mm
      if (date.compareTo("") != 0) {
        Date workDate = DateTimeUtils.dateStringToDate_iso8601(date);
        if (workDate != null) {
          ret = Util.dateToLocalDateTime( workDate );
        }
      }
    } catch ( Exception ex ) {
    }
    return ret;
  }
  /**
   * 日付時刻型から指定書式の日付時刻文字列を取得
   * @param date 日付時刻型(LocalDateTime)
   * @param format DataTimeFormatterの日付時刻書式文字列
   * @return 変換された日付時刻型文字列
   */
  public static String localDateTimeToDateTimeString( LocalDateTime date , String format) {
    String ret = "";
    try {
      DateTimeFormatter dtf = DateTimeFormatter.ofPattern(format);
      ret = dtf.format(date);
    } catch ( Exception ex ) {
    }
    return ret;
  }
  /**
   * 指定書式の日付時刻文字列から日付時刻型を取得
   * @param date 日付時刻文字列
   * @param format DataTimeFormatterの日付時刻書式文字列
   * @return 変換された日付時刻型(LocalDateTime)
   */
  public static LocalDateTime dateTimeStringToLocalDateTime( String date, String format ) {
    LocalDateTime ret = null;
    try {
      DateTimeFormatter dtf = DateTimeFormatter.ofPattern(format);
      ret = LocalDateTime.parse(date, dtf);
    } catch ( Exception ex ) {
    }
    return ret;
  }

  /**
   * JSONノード内の発生日が最新であるノードのIndexを返す
   * @param nodeList
   * @return
   */
  public static Integer getLatestOccurDateIndex(List<JsonNode> nodeList) {
    int maxDateIdx = 0;
    Date maxOccurDate = DateTimeUtils.dateStringToDate_iso8601("1970-01-01T00:00:00+09:00");
    // 発生日が最新のノードを取り出す
    for (int intlop = 0; intlop < nodeList.size(); intlop++) {
      JsonNode bufNode = nodeList.get(intlop);
      JsonNode occurDate_node = bufNode.get("occur_date");
      String occurDate_str = occurDate_node.asText();
      Date occurDate = DateTimeUtils.dateStringToDate_iso8601(occurDate_str);

      if (occurDate.after(maxOccurDate)) {
        maxOccurDate = occurDate;
        maxDateIdx = intlop;
      }
    }

    return maxDateIdx;
  }

  /**
   * 指定工程番号に指定値を加算して返す
   * @param processNo 工程番号
   * @param addCount 加山値
   * @return
   */
  public static String getMachineProcessNo( String processNo, Integer addCount ) {
    Integer no = null;
    if( processNo != null && StrUtils.isNumber(processNo)) {
      no = Integer.parseInt(processNo) + addCount;
    }
    return no.toString();
  }

  /**
   * 工程状態文字列を返す
   * @param processNo 工程番号
   * @returnl 工程文字列
   */
  public static String getProcessName(String processNo) {
    String ret = "不明";
    if( processNo != null) {
      switch(processNo) {
        // 透析装置("01"～"11")
        case "01":
          ret = "プリセット";
          break;
        case "02":
          ret = "洗浄";
          break;
        case "03":
          ret = "酸洗";
          break;
        case "04":
          ret = "消毒";
          break;
        case "05":
          ret = "滞留";
          break;
        case "06":
          ret = "液置換";
          break;
        case "07":
          ret = "透析準備";
          break;
        case "08":
          ret = "ガスパージ";
          break;
        case "09":
          ret = "排液";
          break;
        case "10":
          ret = "停止";
          break;
        case "11":
          ret = "運転";
          break;

        // DAB("20"～"29")
        case "20":
          ret = "プリセット";
          break;
        case "21":
          ret = "透析";
          break;
        case "22":
          ret = "予備透析";
          break;
        case "23":
          ret = "液置換";
          break;
        case "24":
          ret = "薬液消毒";
          break;
        case "25":
          ret = "滞留消毒";
          break;
        case "26":
          ret = "熱湯消毒";
          break;
        case "27":
          ret = "酸洗浄";
          break;
        case "28":
          ret = "洗浄";
          break;
        case "29":
          ret = "排液";
          break;

        // DAD("40"～"47")
        case "40":
          ret = "プリセット";
          break;
        case "41":
          ret = "給水";
          break;
        case "42":
          ret = "循環";
          break;
        case "43":
          ret = "移送待機";
          break;
        case "44":
          ret = "移送";
          break;
        case "45":
          ret = "排液";
          break;
        case "46":
          ret = "洗浄";
          break;
        case "47":
          ret = "消毒";
          break;

        // DRO("60"～"65")
        case "60":
          ret = "通常運転";
          break;
        case "61":
          ret = "夜間運転";
          break;
        case "62":
          ret = "熱水消毒運転";
          break;
        case "63":
          ret = "薬液消毒運転";
          break;
        case "64":
          ret = "強制冷却待機中";
          break;
        case "65":
          ret = "強制洗出し待機中";
          break;

        // DRY-50A("A0"～"AG")
        case "A0":
          ret = "プリセット";
          break;
        case "A1":
          ret = "準備溶解";
          break;
        case "A2":
          ret = "溶解";
          break;
        case "A3":
          ret = "追加溶解";
          break;
        case "A4":
          ret = "追加溶解1";
          break;
        case "A5":
          ret = "追加溶解2";
          break;
        case "A6":
          ret = "溶解停止";
          break;
        case "A7":
          ret = "送液準備";
          break;
        case "A8":
          ret = "原液供給";
          break;
        case "A9":
          ret = "排液";
          break;
        case "AA":
          ret = "洗浄溶解槽1";
          break;
        case "AB":
          ret = "洗浄溶解槽2";
          break;
        case "AC":
          ret = "全洗浄";
          break;
        case "AD":
          ret = "給水管熱水洗浄";
          break;
        case "AE":
          ret = "消毒溶解槽2";
          break;
        case "AF":
          ret = "全消毒";
          break;
        case "AG":
          ret = "調整";
          break;

        // DRY-50B("B0"～"B6")
        case "B0":
          ret = "プリセット";
          break;
        case "B1":
          ret = "溶解";
          break;
        case "B2":
          ret = "排液";
          break;
        case "B3":
          ret = "洗浄";
          break;
        case "B4":
          ret = "給水管熱水洗浄";
          break;
        case "B5":
          ret = "消毒";
          break;
        case "B6":
          ret = "調整";
          break;


        // 通信異常("99")
        case "99":
          ret = "通信異常";
          break;
      }
    }

    return ret;
  }

  /**
   * 指定書式で数字を整形する
   * @param val 整形前文字(数字)
   * @param decimalPoint 小数点以下桁数
   * @return 整形された文字列
   */
  public static String getFormattedNumber( String val, Integer decimalPoint) {
    if (val == null || "".equals(val)) {
      return val;
    }
    String ret = val;

    try {
      // 表示形式整形
      BigDecimal dec = new BigDecimal(val);
      if( decimalPoint != null ) {
        if( 0 < decimalPoint ) {
          NumberFormat nf = NumberFormat.getNumberInstance();
          // 少数桁数を設定
          nf.setMaximumFractionDigits(decimalPoint);
          nf.setMinimumFractionDigits(decimalPoint);
          // 指定桁数以下切り捨て
          ret = nf.format(dec.setScale(decimalPoint, BigDecimal.ROUND_DOWN));
        }
      }
    } catch ( Exception e ) {

    }
    return ret;
  }
  /**
   * 経過分をHH:MM形式文字列に変換する
   * @param Time 経過分
   * @return HH:MM形式文字列
   */
  public static String ElapsedMinutesToHHMM( Integer time ) {
    return Util.ElapsedMinutesToHHMM(time.longValue());
  }
  /**
   * 経過分をHH:MM形式文字列に変換する
   * @param Time 経過分
   * @return HH:MM形式文字列
   */
  public static String ElapsedMinutesToHHMM( Long time ) {
    String ret = "";
    try {
      if( time != null ) {
        Long absTime = Math.abs(time);
        ret = String.format("%d:%02d", absTime / 60,  absTime % 60 );
        if ( time < 0 ) {
          ret = "-" + ret;
        }
      }
    } catch ( Exception e) {
    }
    return ret;
  }
  /**
   * HH:MM形式文字列を経過分に変換する
   * @param hhmm HH:MM形式文字列
   * @return 経過分
   */
  public static Long HHMMtoElasendMinutes( String hhmm ) {
    Long ret = null;
    try {
      //mod #11553 治療状況表示項目不足( 残り時間:113) zrx start
      if( hhmm.charAt(hhmm.length() - 3) == ':' ) {
        ret = Long.valueOf( hhmm.substring(hhmm.length() - 2));
//        ret += Long.valueOf( hhmm.substring(0, hhmm.length() - 4)) * 60;
        ret += Long.valueOf( hhmm.substring(0, hhmm.length() - 3)) * 60;
//        if ( hhmm.contains("-") ) {
        //mod #11553 治療状況表示項目不足( 残り時間:113) zrx end
        if (hhmm.startsWith("-")) {
          ret  *= -1;
        }
      }
    } catch ( Exception e) {
    }
    return ret;
  }

  /**
   * BigDecimal型への変換判定
   * @param value 変換元文字列
   * @return true：変換可能/false：変換不可
   */
  public static boolean isDecimal( String value ) {
    boolean ret = false;
    try {
      BigDecimal work = new BigDecimal( value );
      ret = true;
    } catch( Exception ex ) {
      ret = false;
    }
    return ret;
  }

  /**
   * MstSelectorのリストから 指定されたテーブルのMstSelectorの code → index のマップを作成
   * @param mstSelectors MstSelectorのリスト
   * @param masterPhysicalName マスタ物理名称
   * @return 指定されたテーブルのMstSelectorの code → index の Map、null または items が空の場合は空Map
   */
  public static Map<Long, Long> createSelectorsMap(List<MstSelector> mstSelectors, String masterPhysicalName) {
    MstSelector selector = mstSelectors.stream()
        .filter(s -> masterPhysicalName.equals(s.getMasterPhysicalName()))
        .findFirst()
        .orElse(null);
    return createSelectorMap(selector);
  }
  /**
   * MstSelector から code → index のマップを作成
   * @param mstSelector 並び順情報を保持
   * @return code → index の Map、null または items が空の場合は空Map
   */
  public static Map<Long, Long> createSelectorMap(MstSelector mstSelector) {
    if (mstSelector == null || mstSelector.getOrderSettings() == null) {
      return Collections.emptyMap();
    }

    List<MstSelector.Item> items = mstSelector.getOrderSettings().getItems();
    if (items == null || items.isEmpty()) {
      return Collections.emptyMap();
    }

    return IntStream.range(0, items.size())
        .boxed()
        .collect(Collectors.toMap(
            i -> items.get(i).getCode(),  // key: code
            i -> Long.valueOf(i)         // value: index
            ));
    }
  }
