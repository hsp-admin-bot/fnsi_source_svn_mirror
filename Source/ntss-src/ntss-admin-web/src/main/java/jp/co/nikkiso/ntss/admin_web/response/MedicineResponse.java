package jp.co.nikkiso.ntss.admin_web.response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

/**
 * 薬剤のResponse.
 * ※薬剤選択で使用
 */
@AllArgsConstructor
@Setter
@Getter
public class MedicineResponse {

  /**
   * 薬剤区分
   * 1:通常薬剤
   * 2:調整薬剤
   */
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private String medicineType;
  private Integer medicineType;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

  /**
   * 薬剤コード
   */
  private Integer medicineCd;

  /**
   * 薬剤名
   */
  private String medicineName;

  /**
   * 指示単位
   */
  private String unit;

  /**
   * レセ単位(薬剤マスタのみ)
   */
  private String unitSecond;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 薬剤分類コード
   */
  private Integer classCd;

  /**
   * 指示単位小数部桁数
   */
  private Integer unitDecimalPoint;

  /**
   * レセ単位小数部桁数(薬剤マスタのみ)
   */
  private Integer unitDecimalPointSecond;
}
