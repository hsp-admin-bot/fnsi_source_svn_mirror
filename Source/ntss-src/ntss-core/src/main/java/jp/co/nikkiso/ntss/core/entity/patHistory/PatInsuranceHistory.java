package jp.co.nikkiso.ntss.core.entity.patHistory;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;

// add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
@Document(collection="pat_insurance_history")
@Getter
@Setter
public class PatInsuranceHistory {
  @Field("_id")
  @JsonProperty("_id")
  private String _id;
  @Field("pat_id")
  private String pat_id;
  @Field("insurance_cd")
  private String insurance_cd;
  @Field("facility_cd")
  private String facility_cd;
  @Field("ctl_no")
  private String ctl_no;
  @Field("fn_pat_id")
  private String fn_pat_id;
  @Field("insu_class")
	// mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  private Integer insu_class;
	// mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
  @Field("insu_name")
  private String insu_name;
  @Field("insu_name_short")
  private String insu_name_short;
  @Field("insu_info")
  private String insu_info;
  @Field("insu_pub_info")
  private String insu_pub_info;
  @Field("insu_set_info")
  private String insu_set_info;
  @Field("insu_self_info")
  private String insu_self_info;
  @Field("is_selected")
  private String is_selected;
  @Field("is_disp")
  private String is_disp;
  @Field("is_del")
  private String is_del;
  @Field("coop_code")
  private String coop_code;
  @Field("is_coop")
  private String is_coop;
  @Field("start_date")
  private String start_date;
  @Field("end_date")
  private String end_date;
  @Field("check_date")
  private String check_date;
  @Field("old_up_date")
  private String old_up_date;
  @Field("memo1")
  private String memo1;
  @Field("memo2")
  private String memo2;
  @Field("up_date")
  private String up_date;
  @Field("reg_date")
  private String reg_date;

  /* modify by chamaojia 2023-08-09 [9239] データ型の変更  --start */
  @Field("ins_date")
//  private Timestamp ins_date = new Timestamp(0);
  private Date ins_date = new Date();
  /* modify by chamaojia 2023-08-09 [9239] データ型の変更  --end */

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
  @Field("latest_flag")
  private String latest_flag;
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end
}
// add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
