package jp.co.nikkiso.ntss.core.entity;

import java.sql.Timestamp;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;

/**
 * 愁訴マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_complaint")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class MstComplaint extends BaseEntity {

  /**
   * 愁訴コード.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer complaintCd;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 愁訴名.
   */
  private String complaintName;

  /**
   * 表示フラグ.
   * <p>
   * ('0': 非表示、'1': 表示)
   * </p>
   */
  private String isDisp;

  /**
   * 削除フラグ.
   * <p>
   * ('0': 通常、'1': 削除)
   * </p>
   */
  private String isDel;

  /**
   * 連携コード1
   */
  private String inHospitalCd_1;
  /**
   * 連携コード2
   */
  private String inHospitalCd_2;

  /**
   * {@inheritDoc}
   * TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可.
   */
  @Override
  public Timestamp getRegDate() {
    return super.getRegDate();
  }

  /**
   * {@inheritDoc}
   * TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可.
   */
  @Override
  public Timestamp getUpDate() {
    return super.getUpDate();
  }

  /**
   * 更新フラグ.
   */
  @Transient
  private Boolean isUpdate;
}
