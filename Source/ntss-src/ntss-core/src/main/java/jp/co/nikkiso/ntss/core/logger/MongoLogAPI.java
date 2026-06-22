package jp.co.nikkiso.ntss.core.logger;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MongoLogAPI {

  /**
   * ログ出力タイムスタンプ
   */
  private String log_date;

  /**
   * ログ種別
   */
  private String log_type;

  /**
   * 施設コード
   */
  private String facility_cd;

  /**
   * 利用者ID
   */
  private String user_id;

  /**
   * クライアントIP
   */
  private String client_ip;

  /**
   * セッションID
   */
  private String session_id;

  /**
   * デバイスエッジNo
   */
  private String de_no;

  /**
   * デバイスエッジ製造番号
   */
  private String de_serial;

  /**
   * 型式
   */
  private String mcn_type;

  /**
   * 型式コード
   */
  private String mcn_type_cd;

  /**
   * EC2識別
   */
  private String ec2_ip;

  /**
   * サービス名
   */
  private String svc_name;

  /**
   * 画面コード
   */
  private String func_cd;

  /**
   * 内部患者ID
   */
  private String pat_id;

  /**
   * ログ内容
   */
  private String message;

  /**
   * invoke クラス
   */
  private String invoke_class;

  /**
   * 対応内容
   */
  private String todo;

  /** * サービス名 */
  private String serviceName;

  /** * 院内表示用の患者ID */
  private String pat_name;

  /** ユーザ名 */
  private String user_name;

  /** 施設コード名 */
  private String facility_name;

  /** 機能名 */
  private String function_name;

  /** * 患者ID */
  private String hosp_pat_id;
}
