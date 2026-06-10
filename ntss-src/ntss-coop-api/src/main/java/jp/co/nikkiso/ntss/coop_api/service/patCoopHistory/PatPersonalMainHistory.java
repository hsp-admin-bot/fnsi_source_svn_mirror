package jp.co.nikkiso.ntss.coop_api.service.patCoopHistory;

import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBAttribute;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;

@DynamoDBTable(tableName="pat_personal_main_history")
@Document(collection="pat_personal_main_history")
@Getter
@Setter
public class PatPersonalMainHistory {
  @DynamoDBHashKey(attributeName = "_id")
  @Field("_id")
  private String _id;

  @DynamoDBHashKey(attributeName="pat_id")
  @Field("pat_id")
  private String pat_id;

  @DynamoDBAttribute(attributeName="fn_pat_id")
  @Field("fn_pat_id")
  private String fn_pat_id;

  @DynamoDBAttribute(attributeName="hosp_pat_id")
  @Field("hosp_pat_id")
  private String hosp_pat_id;

  @DynamoDBAttribute(attributeName="nkk_pat_id")
  @Field("nkk_pat_id")
  private String nkk_pat_id;

  @DynamoDBAttribute(attributeName="facility_cd")
  @Field("facility_cd")
  private String facility_cd;

  @DynamoDBAttribute(attributeName="pat_last_name")
  @Field("pat_last_name")
  private String pat_last_name;

  @DynamoDBAttribute(attributeName="pat_first_name")
  @Field("pat_first_name")
  private String pat_first_name;

  @DynamoDBAttribute(attributeName="pat_last_name_kana")
  @Field("pat_last_name_kana")
  private String pat_last_name_kana;

  @DynamoDBAttribute(attributeName="pat_first_name_kana")
  @Field("pat_first_name_kana")
  private String pat_first_name_kana;

  @DynamoDBAttribute(attributeName="pat_last_name_alpha")
  @Field("pat_last_name_alpha")
  private String pat_last_name_alpha;

  @DynamoDBAttribute(attributeName="pat_first_name_alpha")
  @Field("pat_first_name_alpha")
  private String pat_first_name_alpha;

  @DynamoDBAttribute(attributeName="pat_birth_name")
  @Field("pat_birth_name")
  private String pat_birth_name;

  @DynamoDBAttribute(attributeName="pat_birth_name_kana")
  @Field("pat_birth_name_kana")
  private String pat_birth_name_kana;

  @DynamoDBAttribute(attributeName="pat_birth_name_alpha")
  @Field("pat_birth_name_alpha")
  private String pat_birth_name_alpha;

  @DynamoDBAttribute(attributeName="pat_birthday")
  @Field("pat_birthday")
  private String pat_birthday;

  @DynamoDBAttribute(attributeName="pat_sex")
  @Field("pat_sex")
  private String pat_sex;

  @DynamoDBAttribute(attributeName="nationality")
  @Field("nationality")
  private String nationality;

  @DynamoDBAttribute(attributeName="pat_blood_type_abo")
  @Field("pat_blood_type_abo")
  private String pat_blood_type_abo;

  @DynamoDBAttribute(attributeName="pat_blood_type_rh")
  @Field("pat_blood_type_rh")
  private String pat_blood_type_rh;

  @DynamoDBAttribute(attributeName="pat_blood_type_serovar")
  @Field("pat_blood_type_serovar")
  private String pat_blood_type_serovar;

  @DynamoDBAttribute(attributeName="in_out_class")
  @Field("in_out_class")
  private String in_out_class;

  @DynamoDBAttribute(attributeName="is_die")
  @Field("is_die")
  private String is_die;

  @DynamoDBAttribute(attributeName="die_cd")
  @Field("die_cd")
  private String die_cd;

  @DynamoDBAttribute(attributeName="die_date")
  @Field("die_date")
  private String die_date;
	// add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @DynamoDBAttribute(attributeName="die_in_hospital_cd_1")
  @Field("die_in_hospital_cd_1")
  private String die_in_hospital_cd_1;
	// add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
  @DynamoDBAttribute(attributeName="dial_diff_com_info")
  @Field("dial_diff_com_info")
  private String dial_diff_com_info;

  @DynamoDBAttribute(attributeName="severity_cd")
  @Field("severity_cd")
  private String severity_cd;

  @DynamoDBAttribute(attributeName="transport_cd")
  @Field("transport_cd")
  private String transport_cd;

  @DynamoDBAttribute(attributeName="pat_contact_info")
  @Field("pat_contact_info")
  private String pat_contact_info;

  @DynamoDBAttribute(attributeName="other_contact_info")
  @Field("other_contact_info")
  private String other_contact_info;

  @DynamoDBAttribute(attributeName="vendor_contact_info")
  @Field("vendor_contact_info")
  private String vendor_contact_info;

  @DynamoDBAttribute(attributeName="insurance_info")
  @Field("insurance_info")
  private String insurance_info;

  @DynamoDBAttribute(attributeName="is_del")
  @Field("is_del")
  private String is_del;

  @DynamoDBAttribute(attributeName="up_date")
  @Field("up_date")
  private String up_date;

  @DynamoDBAttribute(attributeName="reg_date")
  @Field("reg_date")
  private String reg_date;

  @DynamoDBAttribute(attributeName="primary_disease_cd")
  @Field("primary_disease_cd")
  // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  // private String primary_disease_cd;
  private Integer primary_disease_cd;
  // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @DynamoDBAttribute(attributeName="temporary_dialysis_cd")
  @Field("temporary_dialysis_cd")
  private Integer temporary_dialysis_cd;
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
  @DynamoDBAttribute(attributeName="remote_monitor_service")
  @Field("remote_monitor_service")
  private String remote_monitor_service;

  @DynamoDBAttribute(attributeName="remote_monitor_user_id")
  @Field("remote_monitor_user_id")
  private String remote_monitor_user_id;

  @DynamoDBAttribute(attributeName="remote_monitor_user_pw")
  @Field("remote_monitor_user_pw")
  private String remote_monitor_user_pw;

  /* modify by chamaojia 2023-08-09 [9239] データ型の変更  --start */
  @DynamoDBAttribute(attributeName="ins_date")
  @Field("ins_date")
//  private Timestamp ins_date = new Timestamp(0);
  private Date ins_date = new Date();
  /* modify by chamaojia 2023-08-09 [9239] データ型の変更  --end */
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen start
  @DynamoDBAttribute(attributeName="facility_name")
  @Field("facility_name")
  private String facility_name;
  @DynamoDBAttribute(attributeName="die_name")
  @Field("die_name")
  private String die_name;
  @DynamoDBAttribute(attributeName="severity_name")
  @Field("severity_name")
  private String severity_name;
  @DynamoDBAttribute(attributeName="transport_name")
  @Field("transport_name")
  private String transport_name;
  @DynamoDBAttribute(attributeName="primary_disease_name")
  @Field("primary_disease_name")
  private String primary_disease_name;
  // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。 dengshen end
}
