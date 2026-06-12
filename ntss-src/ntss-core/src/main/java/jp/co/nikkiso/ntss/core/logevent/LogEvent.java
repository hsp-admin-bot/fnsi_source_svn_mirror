package jp.co.nikkiso.ntss.core.logevent;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.mongodb.core.mapping.Document;
import org.springframework.data.mongodb.core.mapping.Field;

/**
 * ログイベント
 */
@Document(collection="log_event")
@Getter
@Setter
public class LogEvent {
  @Field("_id")
  @JsonProperty("_id")
  private String _id;

  /**
   * ログ出力タイムスタンプ
   */
  @Field("log_date")
  private String logDate;

  /**
   * ログ種別
   */
  @Field("log_type")
  private String logType;

  /**
   * 施設コード
   */
  @Field("facility_cd")
  private String facilityCd;

  /**
   * 利用者ID
   */
  @Field("user_id")
  private String userId;

  /**
   * クライアントIP
   */
  @Field("client_ip")
  private String clientIp;

  /**
   * セッションID
   */
  @Field("session_id")
  private String sessionId;

  /**
   * デバイスエッジNo
   */
  @Field("de_no")
  private String deNo;

  /**
   * デバイスエッジ製造番号
   */
  @Field("de_serial")
  private String deSerial;

  /**
   * 型式
   */
  @Field("mcn_type")
  private String mcnType;

  /**
   * 型式コード
   */
  @Field("mcn_type_cd")
  private String mcnTypeCd;

  /**
   * EC2識別
   */
  @Field("ec2_ip")
  private String ec2Ip;

  /**
   * サービス名
   */
  @Field("svc_name")
  private String svcName;

  /**
   * 画面コード
   */
  @Field("func_cd")
  private String funcCd;

  /**
   * 内部患者ID
   */
  @Field("pat_id")
  private String patId;

  /**
   * ログ内容
   */
  @Field("message")
  private String message;

  /**
   * invoke クラス
   */
  @Field("invoke_class")
  private String invokeClass;

  /**
   * 対応内容
   */
  @Field("todo")
  private String todo;

  /** * 院内表示用の患者ID */
  @Field("pat_name")
  private String patName;

  /** ユーザ名 */
  @Field("user_name")
  private String username;

  /** 施設コード名 */
  @Field("facility_name")
  private String facilityName;

  /** 機能名 */
  @Field("function_name")
  private String functionName;

  /** 患者ID */
  @Field("hosp_pat_id")
  private String hospPatId;

}
