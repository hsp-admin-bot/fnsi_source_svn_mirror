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
@DynamoDBTable(tableName="pat_group_detail_history")
@Document(collection="pat_group_detail_history")
@Getter
@Setter
public class PatGroupDetailHistory {

  @DynamoDBHashKey(attributeName = "_id")
  @Field("_id")
  private String _id;

  /**
   * 患者コード
   */
  @DynamoDBHashKey(attributeName="pat_id")
  @Field("pat_id")
  private String pat_id;
  /**
   * 施設コード
   */
  @DynamoDBAttribute(attributeName="facility_cd")
  @Field("facility_cd")
  private String facility_cd;
  /**
   * 患者グループコード
   */
  @DynamoDBAttribute(attributeName="pat_group_cd")
  @Field("pat_group_cd")
  private String pat_group_cd;
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  /**
   * 患者グループ名
   */
  @DynamoDBAttribute(attributeName="pat_group_name")
  @Field("pat_group_name")
  private String pat_group_name;
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
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
