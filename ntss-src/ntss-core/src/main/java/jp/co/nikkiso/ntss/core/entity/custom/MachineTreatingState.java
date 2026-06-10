package jp.co.nikkiso.ntss.core.entity.custom;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置識別情報Entiy.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MachineTreatingState {
  /**
   * 型式コード
   */
  private String machineTypeCd;

  /**
   * 通信フォーマット.
   */
  private String comFormatCd;

  /**
   * 通信種別.
   */
  private Integer comType;

  /**
   * ベッドコード.
   */
  private Long bedCd;
  /**
   * 工程状態.
   */
  private String processState;
  /**
   * 装置ステータス.
   */
  private Integer machineStatus;

  /**
   * オンラインフラグ.
   */
  private String isOffline;

  /**
   * 透析開始予定日時.
   */
  private Timestamp startPlanDate;

  /**
   * 透析終了予定日時.
   */
  private Timestamp endPlanDate;

  /**
   * 透析開始日時.
   */
  private Timestamp startDate;

  /**
   * 透析終了日時.
   */
  private Timestamp endDate;

  /**
   * 前体重測定日時.
   */
  private Timestamp weighBeforeDate;

  /**
   * 後体重測定日時.
   */
  private Timestamp weighAfterDate;

  /**
   * 条件送信日時.
   */
  private Timestamp condSendDate;

  /**
   * 条件確認日時.
   */
  private Timestamp condSetDate;

  /**
   * 患者確認済みフラグ.
   */
  private String isPatVerified;


}
