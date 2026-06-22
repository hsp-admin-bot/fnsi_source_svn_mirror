package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置動作記録取得用Entity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MotionRecord extends BaseMotionRecordDetail{

  /**
   * 装置動作記録番号.
   */
  private Long motionRecordNo;

  /**
   * 発生日付.
   */
  @Column(name = "event_reg_date")
  private String eventRegDate;

  /**
   * 発生時刻.
   */
  @Column(name = "event_reg_time")
  private String eventRegTime;

  /**
   * 類(データ種別).
   */
  private Integer dataType;

  /**
   * 自己診断種別(データ種別が自己診断時のみセット)
   */
  private Integer testType;

  /**
   * 装置記録メッセージ.
   */
  private String machineRecordMessage;

  /**
   * 対処フラグ.
   */
  private String isCorrection;

  /**
   * 対処者.
   */
  private Long userId;

  /**
   * 対処者名.
   */
  @Transient
  private String userName;

  /**
   * データ収集ステータス.
   */
  private Integer gatheringStatus;

}
