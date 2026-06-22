package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;
import java.math.BigDecimal;

import jp.co.nikkiso.ntss.core.entity.entityListener.MstMedicineEntityListener;
import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
/**
 * 薬剤クラス
 */
@Entity(listener = MstMedicineEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_medicine")
@Getter
@Setter
public class MstMedicine extends BaseBlankEntity {

  /**
   * 薬剤コード
   */
  @Id
  private Integer medicineCd;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * FNW+で管理する施設内の一意な薬剤コード
   */
  private String fnMedicineCd;
  /**
   * 個別医薬品コード(YJコード)
   */
  private String standardMedicineCd;
  /**
   * 治験フラグ
   */
  private String isTrial;
  /**
   * 薬剤名
   */
  private String medicineName;
  /**
   * 省略薬剤名
   */
  private String medicineShortName;
  /**
   * 指示単位
   */
  private String unit;
  /**
   * レセ単位
   */
  private String unitSecond;
  /**
   * 薬剤分類コード
   */
  private Integer classCd;
  /**
   * 注射
   */
  private String isShot;
  /**
   * 使用開始日
   */
  private String useStartDate;
  /**
   * 使用終了日
   */
  private String useEndDate;
  /**
   * 投薬実施フラグ
   */
  private String isMedicated;
  /**
   * 指示単位換算量
   */
  private BigDecimal unitConvertedAmount;
  /**
   * レセ単位換算量
   */
  private BigDecimal unitConvertedAmountSecond;
  /**
   * 指示基準量
   */
  private BigDecimal anticoagulantOriginalQuantity;
  /**
   * ML基準量
   */
  private BigDecimal afterAnticoagulantQuantity;
  /**
   * 連携コード1
   */
  private String inHospitalCd_1;
  /**
   * 連携コード2
   */
  private String inHospitalCd_2;
  /**
   * 連携コード3
   */
  private String inHospitalCd_3;
  /**
   * 連携コード4
   */
  private String inHospitalCd_4;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 登録日時
   */
  private Timestamp regDate;
  /**
   * 更新日時
   */
  private Timestamp upDate;
  /**
   * 換算フラグ
   */
  private String isExchange;
   /**
   * 投与タイミングコード
   */
  private Integer medicateTimingCd;
  /**
   * 手技コード
   */
  private Integer procedureCd;
   /**
   * 指示単位小数部桁数
   */
  private Integer unitDecimalPoint;
  /**
   * レセ単位小数部桁数
   */
  private Integer unitDecimalPointSecond;


}
