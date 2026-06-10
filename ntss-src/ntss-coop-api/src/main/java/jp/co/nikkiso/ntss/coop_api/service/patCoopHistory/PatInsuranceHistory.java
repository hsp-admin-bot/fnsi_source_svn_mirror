package jp.co.nikkiso.ntss.coop_api.service.patCoopHistory;

import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBAttribute;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

import java.util.Date;

// add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
@DynamoDBTable(tableName="pat_insurance_history")
@Document(collection="pat_insurance_history")
@Getter
@Setter
public class PatInsuranceHistory {

  @DynamoDBHashKey(attributeName = "_id")
  @Field("_id")
  private String _id;

  @DynamoDBHashKey(attributeName="pat_id")
  @Field("pat_id")
  private String pat_id;

  @DynamoDBAttribute(attributeName="insurance_cd")
  @Field("insurance_cd")
  private String insurance_cd;

  @DynamoDBAttribute(attributeName="facility_cd")
  @Field("facility_cd")
  private String facility_cd;

  @DynamoDBAttribute(attributeName="ctl_no")
  @Field("ctl_no")
  private String ctl_no;

  @DynamoDBAttribute(attributeName="fn_pat_id")
  @Field("fn_pat_id")
  private String fn_pat_id;

  @DynamoDBAttribute(attributeName="insu_class")
  @Field("insu_class")
  // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  private Integer insu_class;
  // mod #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end

  @DynamoDBAttribute(attributeName="insu_name")
  @Field("insu_name")
  private String insu_name;

  @DynamoDBAttribute(attributeName="insu_name_short")
  @Field("insu_name_short")
  private String insu_name_short;

  @DynamoDBAttribute(attributeName="insu_info")
  @Field("insu_info")
  private String insu_info;

  @DynamoDBAttribute(attributeName="insu_pub_info")
  @Field("insu_pub_info")
  private String insu_pub_info;

  @DynamoDBAttribute(attributeName="insu_set_info")
  @Field("insu_set_info")
  private String insu_set_info;

  @DynamoDBAttribute(attributeName="insu_self_info")
  @Field("insu_self_info")
  private String insu_self_info;

  @DynamoDBAttribute(attributeName="is_selected")
  @Field("is_selected")
  private String is_selected;

  @DynamoDBAttribute(attributeName="is_disp")
  @Field("is_disp")
  private String is_disp;

  @DynamoDBAttribute(attributeName="is_del")
  @Field("is_del")
  private String is_del;

  @DynamoDBAttribute(attributeName="coop_code")
  @Field("coop_code")
  private String coop_code;

  @DynamoDBAttribute(attributeName="is_coop")
  @Field("is_coop")
  private String is_coop;

  @DynamoDBAttribute(attributeName="start_date")
  @Field("start_date")
  private String start_date;

  @DynamoDBAttribute(attributeName="end_date")
  @Field("end_date")
  private String end_date;

  @DynamoDBAttribute(attributeName="check_date")
  @Field("check_date")
  private String check_date;

  @DynamoDBAttribute(attributeName="old_up_date")
  @Field("old_up_date")
  private String old_up_date;

  @DynamoDBAttribute(attributeName="memo1")
  @Field("memo1")
  private String memo1;

  @DynamoDBAttribute(attributeName="memo2")
  @Field("memo2")
  private String memo2;

  @DynamoDBAttribute(attributeName="up_date")
  @Field("up_date")
  private String up_date;

  @DynamoDBAttribute(attributeName="reg_date")
  @Field("reg_date")
  private String reg_date;

  /* modify by chamaojia 2023-08-09 [9239] データ型の変更  --start */
  @DynamoDBAttribute(attributeName="ins_date")
  @Field("ins_date")
//  private Timestamp ins_date = new Timestamp(0);
  private Date ins_date = new Date();
  /* modify by chamaojia 2023-08-09 [9239] データ型の変更  --end */
}
// add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
