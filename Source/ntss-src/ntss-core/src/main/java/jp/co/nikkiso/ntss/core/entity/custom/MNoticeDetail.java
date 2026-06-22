package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置動作記録詳細_緊急発報記録取得用Entity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MNoticeDetail extends BaseMotionRecordDetail{

  /**
   * 装置記録コード.
   */
  @Column(name = "machine_record_cd")
  private String machineRecordCd;

  /**
   * 詳細情報.
   */
  @Column(name = "machine_record_aux_data")
  private String detailInfo;

  /**
   * メール送付先(宛先名称).
   */
  @Column(name = "email_name")
  private String destinationName;

  /**
   * メール本文.
   */
  private String emailText;

  /**
   * 対処者.
   */
  @Column(name = "user_id")
  private Long correctedUserId;

  /**
   * 対処者名.
   */
  @Transient
  private String userName;

  /**
   * 対処フラグ.
   */
  @Column(name = "is_correction")
  private String isCorrection;

}
