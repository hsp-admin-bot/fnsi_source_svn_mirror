package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import java.sql.Timestamp;

/**
 * 装置記録Entity基底クラス.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public abstract class BaseMotionRecordDetail extends BaseEntity {

  /**
   * 対処日時
   */
  private Timestamp isCorrectionUpDate;

  /**
   * サービス対応区分
   */
  private String serviceSupportType;

  /**
   * サービス対応者ID
   */
  private Long serviceSupportUserId;

  /**
   * サービス対応日時
   */
  private Timestamp serviceSupportUpDate;

  /**
   * サービス対応者名
   */
  @Transient
  private String serviceSupportUserName;

}
