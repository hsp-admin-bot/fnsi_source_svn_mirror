package jp.co.nikkiso.ntss.core.logevent;

import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBAttribute;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBHashKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBRangeKey;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBTable;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

/**
 * ログイベント
 */
@DynamoDBTable(tableName="log_event")
@Document(collection="log_event")
@Getter
@Setter
public class LogEvent {

  @DynamoDBHashKey(attributeName = "_id")
  @Field("_id")
  private String _id;

  /**
   * ログ出力タイムスタンプ
   */
  @DynamoDBRangeKey(attributeName="log_date")
  @Field("log_date")
  private String logDate;

  /**
   * ログ種別
   */
  @DynamoDBRangeKey(attributeName="log_type")
  @Field("log_type")
  private String logType;

  /**
   * 施設コード
   */
  @DynamoDBAttribute(attributeName="facility_cd")
  @Field("facility_cd")
  private String facilityCd;

  /**
   * 利用者ID
   */
  @DynamoDBAttribute(attributeName="user_id")
  @Field("user_id")
  private String userId;

  /**
   * クライアントIP
   */
  @DynamoDBAttribute(attributeName="client_ip")
  @Field("client_ip")
  private String clientIp;

  /**
   * セッションID
   */
  @DynamoDBAttribute(attributeName="session_id")
  @Field("session_id")
  private String sessionId;

  /**
   * デバイスエッジNo
   */
  @DynamoDBAttribute(attributeName="de_no")
  @Field("de_no")
  private String deNo;

  /**
   * デバイスエッジ製造番号
   */
  @DynamoDBAttribute(attributeName="de_serial")
  @Field("de_serial")
  private String deSerial;

  /**
   * 型式
   */
  @DynamoDBAttribute(attributeName="mcn_type")
  @Field("mcn_type")
  private String mcnType;

  /**
   * 型式コード
   */
  @DynamoDBAttribute(attributeName="mcn_type_cd")
  @Field("mcn_type_cd")
  private String mcnTypeCd;

  /**
   * EC2識別
   */
  @DynamoDBAttribute(attributeName="ec2_ip")
  @Field("ec2_ip")
  private String ec2Ip;

  /**
   * サービス名
   */
  @DynamoDBAttribute(attributeName="svc_name")
  @Field("svc_name")
  private String svcName;

  /**
   * 画面コード
   */
  @DynamoDBAttribute(attributeName="func_cd")
  @Field("func_cd")
  private String funcCd;

  /**
   * 内部患者ID
   */
  @DynamoDBHashKey(attributeName="pat_id")
  @Field("pat_id")
  private String patId;

  /**
   * ログ内容
   */
  @DynamoDBHashKey(attributeName="message")
  @Field("message")
  private String message;

  /**
   * invoke クラス
   */
  @DynamoDBHashKey(attributeName="invoke_class")
  @Field("invoke_class")
  private String invokeClass;

  /**
   * 対応内容
   */
  @DynamoDBHashKey(attributeName="todo")
  @Field("todo")
  private String todo;

  /** * 院内表示用の患者ID */
  @DynamoDBHashKey(attributeName="pat_name")
  @Field("pat_name")
  private String patName;

  /** ユーザ名 */
  @DynamoDBHashKey(attributeName="user_name")
  @Field("user_name")
  private String username;

  /** 施設コード名 */
  @DynamoDBHashKey(attributeName="facility_name")
  @Field("facility_name")
  private String facilityName;

  /** 機能名 */
  @DynamoDBHashKey(attributeName="function_name")
  @Field("function_name")
  private String functionName;

  /** 患者ID */
  @DynamoDBHashKey(attributeName="hosp_pat_id")
  @Field("hosp_pat_id")
  private String hospPatId;

}
