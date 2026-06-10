package batch.entity;

import com.google.gson.JsonObject;
import org.seasar.doma.*;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * 計算材料保持テーブルクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "ord_material_save")
@Getter
@Setter
public class OrdMaterialSave extends BaseBlankEntity {
  @Id
  @GeneratedValue(strategy = GenerationType.SEQUENCE)
  @SequenceGenerator(sequence = "ntss.ord_material_save_seq")
  /**
   * 管理番号
   */
  private Long ordMaterialSaveNo;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 患者ID
   */
  private Long patId;

  /**
   * データ基準日
   */
  private String suppliesBaseDate;

  /**
   * データ基準番号
   */
  private Long suppliesBaseNo;

  /**
   * データ発生元区分
   */
  private String suppliesSourceClass;

  /**
   * 物品区分
   */
  private String suppliesClass;

  /**
   * 物品コード
   */
  private String suppliesCd;

  /**
   * 調整薬剤コード
   */
  private String medicineMixCd;

  /**
   * 分類コード
   */
  private String classCd;

  /**
   * 指示・実績区分
   */
  private String indRstClass;

  /**
   * 指示・実績値
   */
  private String indRstValue;

  /**
   * レセ値
   */
  private String receiptValue;

  /**
   * 確定フラグ
   */
  private String isConfirm;

  /**
   * 登録日時
   */
  private Timestamp regDate;

  /**
   * 更新日時
   */
  private Timestamp upDate;
  /**
   * 薬剤識別番号
   */
  private JsonObject medicineNo;

  /**
   * 手技コード
   */
  private String procedureCd;
  /**
   * 投与タイミングコード
   */
  private String timingCd;

  /**
   * 単位換算情报
   */
  private String ReceiptConversion;

  @Override
  public String toString() {
    StringBuffer sb = new StringBuffer();
    sb.append(facilityCd==null ? "" : facilityCd).append(",")
            .append(patId==null ? "" : patId).append(",")
            .append(suppliesBaseDate==null ? "" : suppliesBaseDate).append(",")
            .append(suppliesBaseNo==null ? "" : suppliesBaseNo).append(",")
            .append(suppliesSourceClass==null ? "" : suppliesSourceClass).append(",")
            .append(suppliesClass==null ? "" : suppliesClass).append(",")
            .append(suppliesCd==null ? "" : suppliesCd).append(",")
            .append(medicineMixCd==null ? "" : medicineMixCd).append(",")
            .append(classCd==null ? "" : classCd).append(",")
            .append(indRstClass==null ? "" : indRstClass).append(",")
            .append(indRstValue==null ? "" : indRstValue).append(",")
            .append(receiptValue==null ? "" : receiptValue).append(",")
            .append(isConfirm==null ? "" : isConfirm).append(",")
            .append(medicineNo == null ? "[]" : medicineNo.toString().replace(",","|")).append(",")
            .append(procedureCd == null ? "" : procedureCd).append(",")
            .append(timingCd == null ? "" : timingCd).append(",")
            .append(ReceiptConversion == null ? "" : ReceiptConversion.replace(",","|")).append(",")
            .append(regDate==null ? Timestamp.valueOf(LocalDateTime.now()) : regDate).append(",")
            .append(upDate==null ? Timestamp.valueOf(LocalDateTime.now()) : upDate);
    return sb.toString();

  }
}
