package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import java.math.BigDecimal;

/**
 * 投薬支援マスタのEntity.
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_medicine_support")
@Getter
@Setter
public class MntMedicineSupport extends BaseEntity {
  /**
   * 投薬支援コード.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long medicineSupportCd;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 投薬支援パターン名.
   */
  private String medicineSupportName;

  /**
   * 目標検査値.
   */
  private BigDecimal targetInspection;

  /**
   * 詳細.
   */
  private String detailInfo;

  /**
   * 表示フラグ.
   */
  private String isDisp;

  /**
   * 削除フラグ.
   */
  private String isDel;
}
