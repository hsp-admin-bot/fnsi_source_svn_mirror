package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.annotation.JsonNaming;
import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.Transient;
import org.seasar.doma.jdbc.entity.NamingType;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * 処置マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_comp_treatment")
@Getter
@Setter
@JsonNaming(PropertyNamingStrategy.SnakeCaseStrategy.class)
@EqualsAndHashCode(callSuper = false)
public class MstCompTreatment extends BaseEntity {

  /**
   * 処置コード.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Integer compTreatmentCd;

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 処置内容.
   */
  private String treatment;

  /**
   * 処置区分.
   * <p>
   * ('0': 調製薬剤、'1': 薬剤、'2': 処置)
   * </p>
   */
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private String treatClass;
  private Integer treatClass;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

  /**
   * 処置薬剤コード.
   * TODO 調製薬剤マスタ.調製薬剤コードは文字列
   * <ul>
   *   <li>処置区分='0'の場合は調製薬剤マスタ.調製薬剤コード</li>
   *   <li>処置区分='1'の場合は薬剤マスタ.薬剤コード</li>
   *   <li>処置区分='2'の場合は<c>null</c></li>
   * </ul>
   */
  private Integer treatMedicineCd;

  /**
   * 数量.
   */
  private BigDecimal amount;

  /**
   * 手技コード.
   */
  private Integer procedureCd;

  /**
   * 服用コード.
   */
  private Integer takeMedicineCd;

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
   * {@inheritDoc}
   * TODO BaseEntityを使用するAPIがすべて返却しないなら、BaseEntityにJsonIgnoreを記載したい。現状テストがないため、判断不可.
   */

  /**
   * 利用開始日A
   */
  @Column(name = "in_hosp_a_startdate")
  private String inHospAStartdate;
  /**
   * 連携コードA1
   */
  private String inHospitalCdA1;
  /**
   * 連携コードA2
   */
  private String inHospitalCdA2;
  /**
   * 連携コードA3
   */
  private String inHospitalCdA3;
  /**
   * 連携コードA4
   */
  private String inHospitalCdA4;
  /**
   * 利用開始日B
   */
  @Column(name = "in_hosp_b_startdate")
  private String inHospBStartdate;
  /**
   * 連携コードB1
   */
  private String inHospitalCdB1;
  /**
   * 連携コードB2
   */
  private String inHospitalCdB2;
  /**
   * 連携コードB3
   */
  private String inHospitalCdB3;
  /**
   * 連携コードB4
   */
  private String inHospitalCdB4;

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
