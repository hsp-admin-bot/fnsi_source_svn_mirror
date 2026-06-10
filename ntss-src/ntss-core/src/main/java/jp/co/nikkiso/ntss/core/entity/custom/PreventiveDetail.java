package jp.co.nikkiso.ntss.core.entity.custom;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 装置動作記録詳細_予防保全/故障予知取得用Entity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PreventiveDetail extends BaseMotionRecordDetail {

  /**
   * 装置記録コード.
   */
  private String machineRecordCd;

  /**
   * 詳細情報.
   */
  @Column(name = "machine_record_aux_data")
  private String detailInfo;

  /**
   * 対処(実施)者.
   */
  @Column(name = "user_id")
  private Long correctedUserId;

  /**
   * 対処(実施)名.
   */
  @Transient
  private String userName;

  /**
   * 対処フラグ.
   */
  @Column(name = "is_correction")
  private String isCorrection;

}
