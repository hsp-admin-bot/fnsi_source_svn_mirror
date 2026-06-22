package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * MstSelfMeasureResultのEntity.
 */
@Entity(listener = BaseEntityListener.class , naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_self_measure_result")
@Getter
@Setter
public class MstSelfMeasureResult extends BaseEntity  {
  /**
   * 自己診断判定コード(bigserial).
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long selfMeasureResultCd;
  /**
   * 施設コード(character varying).
   */
  private String facilityCd;

  /**
   * 対象機種(character varying).
   */
  private String dispMachineName;

  /**
   * 対象機種情報(JSON).
   */
  private String machineInfo;

  /**
   * 自己診断情報(JSON).
   */
  private String selfMeasureResult;

  /**
   * 表示フラグ(character varying).
   */
  private String isDisp;

  /**
   * 削除フラグ(character varying).
   */
  private String isDel;
}
