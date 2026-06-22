package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置状態管理のEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvMntMachineState {

  /**
   * 装置ステータス.
   */
  private int machineStatus;

  /**
   * システムで管理する一意なオーダ番号.
   */
  private Long ordNo;

  /**
   * 次回透析オーダ番号.
   */
  private Long nextOrdNo;

  /**
   * システムで管理する一意な患者ID.
   */
  private Long patId;

  /**
   * 次患者ID.
   */
  private Long nextPatid;

  /**
   * 次患者名.
   */
  private String nextPatName;

  /**
   * 設定値書込用患者名.
   */
  private String deviceSetPatName;

  /**
   * 透析開始予定日時.
   */
  private String startPlanDate;

  /**
   * 透析終了予定日時.
   */
  private String endPlanDate;

  /**
   * 条件送信日時.
   */
  private String condSendDate;

  /**
   * 条件確認日時.
   */
  private String condSetDate;

  /**
   * 患者確認済みフラグ.
   */
  private String isPatVerified;

  /**
   * 透析開始日時.
   */
  private String startDate;

  /**
   * 透析終了日時.
   */
  private String endDate;

  /**
   * 装置設定一時データ.
   */
  private String tmpDeviceSetInfo;

  /**
   * 治療時間
   */
  private String treatTime;

  /**
   * 治療時間判定時間.
   */
  private String treatJudgeTime;
//add 通信共通プロトコル（V3/V4）患者IDが異なる --趙-- start
  /**
   *   院内表示用の患者ID.
   */
  private String hospPatid;
//add 通信共通プロトコル（V3/V4）患者IDが異なる --趙-- end
}
