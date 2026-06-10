package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.math.BigDecimal;

/**
 * スケールベッド状態管理のEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mnt_scale_bed_state")
@Getter
@Setter
public class MntScaleBedState extends BaseEntity {

  /**
   * ベッドコード
   */
  @Id
  private Long bedCd;

  /**
   * 体重計管理コード
   */
  private Long weightCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 接続状態
   */
  private String isConnect;

  /**
   * 前体重送信状態
   */
  private Integer beforeSendStatus;

  /**
   * 前体重測定管理番号
   */
  private Long beforeWeightScaleNo;

  /**
   * 後体重送信状態
   */
  private Integer afterSendStatus;

  /**
   * 後体重測定管理番号
   */
  private Long afterWeightScaleNo;

}
