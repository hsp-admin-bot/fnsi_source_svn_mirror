package jp.co.nikkiso.ntss.coop_api.service.patCoopHistory;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;
@Document(collection="pat_main_history")
@Getter
@Setter
public class PatMainHistory {
  @Field("_id")
  @JsonProperty("_id")
  private String _id;

  /**
   * 患者コード
   */
  @Field("pat_id")
  private String pat_id;

  /**
   * 施設コード
   */
  @Field("facility_cd")
  private String facility_cd;
  @Field("is_same")
  private String is_same;
  @Field("is_implant")
  private String is_implant;
  @Field("is_infect")
  private String is_infect;
  @Field("is_diabetes")
  private String is_diabetes;
  // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @Field("is_blood_suger_exam")
  private String is_blood_suger_exam = "";
  // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @Field("dialysis_underlying_disease")
  private String dialysis_underlying_disease = "";
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
  @Field("in_out_current_state")
  private String in_out_current_state = "";
  @Field("in_out_plan_state")
  private String in_out_plan_state = "";

  /* modify by chamaojia 2023-08-07 [9239] データ型の変更  --start */
  @Field("in_out_plan_date")
//  private Timestamp in_out_plan_date = new Timestamp(0);
  private Date in_out_plan_date = new Date();
  /* modify by chamaojia 2023-08-07 [9239] データ型の変更  --end */
  @Field("pat_memo_info")
  private String pat_memo_info;
  @Field("addition_info")
  private String addition_info;
  @Field("charge_staff_info")
  private String charge_staff_info;
  @Field("pat_group_info")
  private String pat_group_info;
  @Field("taboo_allergy_info")
  private String taboo_allergy_info;
  @Field("infect_info")
  private String infect_info;
  @Field("implant_info")
  private String implant_info;
  @Field("tare_info")
  private String tare_info;
  @Field("off_water_info")
  private String off_water_info;
  @Field("device_set_info")
  private String device_set_info;
  @Field("acceptance_status_info")
  private String acceptance_status_info;
  @Field("is_del")
  private String is_del;
  @Field("up_date")
  private String up_date;
  @Field("reg_date")
  private String reg_date;
  @Field("is_wheel_chair")
  private String is_wheel_chair;
  @Field("medical_care_info")
  private String medical_care_info;
  @Field("sch_ext_end_date")
  private String sch_ext_end_date;
  @Field("sch_ext_status")
  private String sch_ext_status;
  @Field("ins_date")
  private Date ins_date = new Date();

  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Field("facility_name")
  private String facility_name;
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

  // add #10210 帳票における患者情報の取得元について limingzhe start
  @Field("host_notification_info")
  private String host_notification_info;
  @Field("wheel_chair_cd")
  private Long wheel_chair_cd;
  @Field("wheel_chair_name")
  private String wheel_chair_name;
  @Field("wheel_chair_weight")
  private Integer wheel_chair_weight;
  // add #10210 帳票における患者情報の取得元について limingzhe end
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @Field("card_idm")
  private String card_idm;
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
}
