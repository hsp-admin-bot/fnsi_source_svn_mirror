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
 * 標準医薬品マスタクラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_medicine")
@Getter
@Setter
public class SysMedicine extends BaseEntity {

  /**
   * 基準番号(HOTコード)
   */
  @Id
  private String standardNo;

  /**
   * 処方用番号(HOT7)
   */
  private String prescriptionNo;

  /**
   * 会社識別番号
   */
  private String companyNo;

  /**
   * 調剤用番号
   */
  private String dispensingNo;

  /**
   * 物流用番号
   */
  private String logisticsNo;

  /**
   * JANコード
   */
  private String janCd;

  /**
   * 薬価基準収載医薬品コード
   */
  private String drugPriceStandardCd;

  /**
   * 個別医薬品コード(YJコード)
   */
  private String standardMedicineCd;

  /**
   * レセプト電算処理システムコード(1)
   */
  private String receiptCd_1;

  /**
   * レセプト電算処理システムコード(2)
   */
  private String receiptCd_2;

  /**
   * 告示名称
   */
  private String noticeName;

  /**
   * 販売名
   */
  private String salesName;

  /**
   * レセプト電算処理システム医薬品名
   */
  private String receiptMedicineName;

  /**
   * 規格単位
   */
  private String standardUnit;

  /**
   * 包装形態
   */
  private String pkgPresentation;

  /**
   * 包装単位(数)
   */
  private BigDecimal pkgAmount;

  /**
   * 包装単位(単位)
   */
  private String pkgUnit;

  /**
   * 包装総量(数)
   */
  private BigDecimal pkgTotalAmount;

  /**
   * 包装総量(単位)
   */
  private String pkgTotalUnit;

  /**
   * 区分
   * 1:内服、2:外用、3:注射、4:歯科
   */
  private String usageCategoryClass;

  /**
   * 製造会社
   */
  private String manufactureCompany;

  /**
   * 販売会社
   */
  private String salesCompany;

  /**
   * レコード区分
   */
  private String recordClass;

  /**
   * 更新年月日
   */
  private String standardUpDate;

  /**
   * 包装数量(数量)
   */
  private BigDecimal pkgQtyQuantity;

  /**
   * 包装数量(単位)
   */
  private String pkgQtyUnit;

  /**
   * 包装入数(数量)
   */
  private BigDecimal pkgQtyPerCartonQuantity;

  /**
   * 包装入数(単位)
   */
  private String pkgQtyPerCartonUnit;

  /**
   * 指示単位
   */
  private String unit;

  /**
   * レセ単位
   */
  private String unitSecond;

  /**
   * 指示単位換算量
   */
  private BigDecimal unitConvertedAmount;

  /**
   * レセ単位換算量
   */
  private BigDecimal unitConvertedAmountSecond;

  /**
   * 指示単位小数部桁数
   */
  private Integer unitDecimalPoint;

  /**
   * レセ単位小数部桁数
   */
  private Integer unitDecimalPointSecond;
}
