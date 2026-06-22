package jp.co.nikkiso.ntss.admin_web.service.patHistory;

import com.fasterxml.jackson.annotation.JsonProperty;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.patPersonalMainHistoryDetail.DialDiffComInfo;
import jp.co.nikkiso.ntss.admin_web.service.patHistory.patPersonalMainHistoryDetail.OtherContactInfo;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;
import java.util.List;
@Document(collection="pat_personal_main_history")
@Getter
@Setter
public class PatPersonalMainHistory {
  @Field("_id")
  @JsonProperty("_id")
  private String _id;
  @Field("pat_id")
  private String pat_id;
  @Field("fn_pat_id")
  private String fn_pat_id;
  @Field("hosp_pat_id")
  private String hosp_pat_id;
  @Field("nkk_pat_id")
  private String nkk_pat_id;
  @Field("facility_cd")
  private String facility_cd;
  @Field("pat_last_name")
  private String pat_last_name;
  @Field("pat_first_name")
  private String pat_first_name;
  @Field("pat_last_name_kana")
  private String pat_last_name_kana;
  @Field("pat_first_name_kana")
  private String pat_first_name_kana;
  @Field("pat_last_name_alpha")
  private String pat_last_name_alpha;
  @Field("pat_first_name_alpha")
  private String pat_first_name_alpha;
  @Field("pat_birth_name")
  private String pat_birth_name;
  @Field("pat_birth_name_kana")
  private String pat_birth_name_kana;
  @Field("pat_birth_name_alpha")
  private String pat_birth_name_alpha;
  @Field("pat_birthday")
  private String pat_birthday;
  @Field("pat_sex")
  private String pat_sex;
  @Field("nationality")
  private String nationality;
  @Field("pat_blood_type_abo")
  private String pat_blood_type_abo;
  @Field("pat_blood_type_rh")
  private String pat_blood_type_rh;
  @Field("pat_blood_type_serovar")
  private String pat_blood_type_serovar;
  @Field("in_out_class")
  private String in_out_class;
  @Field("is_die")
  private String is_die;
  @Field("die_cd")
  private String die_cd;
  @Field("die_date")
  private String die_date;
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @Field("die_in_hospital_cd_1")
  private String die_in_hospital_cd_1;
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end

  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
  @Field("dial_diff_com_info")
  // private String dial_diff_com_info;
  private List<DialDiffComInfo> dial_diff_com_info;
  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
  @Field("severity_cd")
  private String severity_cd;
  @Field("transport_cd")
  private String transport_cd;
  @Field("pat_contact_info")
  private String pat_contact_info;

  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
  @Field("other_contact_info")
  // private String other_contact_info;
  private List<OtherContactInfo> other_contact_info;
  // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
  @Field("vendor_contact_info")
  private String vendor_contact_info;
  @Field("insurance_info")
  private String insurance_info;
  @Field("is_del")
  private String is_del;
  @Field("up_date")
  private String up_date;
  @Field("reg_date")
  private String reg_date;
  @Field("primary_disease_cd")
  // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  // private String primary_disease_cd;
  private Integer primary_disease_cd;
  // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @Field("temporary_dialysis_cd")
  private Integer temporary_dialysis_cd;
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
  @Field("remote_monitor_service")
  private String remote_monitor_service;
  @Field("remote_monitor_user_id")
  private String remote_monitor_user_id;
  @Field("remote_monitor_user_pw")
  private String remote_monitor_user_pw;

  /* modify by chamaojia 2023-08-09 [9239] データ型の変更  --start */
  @Field("ins_date")
//  private Timestamp ins_date = new Timestamp(0);
  private Date ins_date = new Date();
  /* modify by chamaojia 2023-08-09 [9239] データ型の変更  --end */
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @Field("facility_name")
  private String facility_name;
  @Field("die_name")
  private String die_name;
  @Field("severity_name")
  private String severity_name;
  @Field("transport_name")
  private String transport_name;
  @Field("primary_disease_name")
  private String primary_disease_name;
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
  @Field("latest_flag")
  private String latest_flag;
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end
}
