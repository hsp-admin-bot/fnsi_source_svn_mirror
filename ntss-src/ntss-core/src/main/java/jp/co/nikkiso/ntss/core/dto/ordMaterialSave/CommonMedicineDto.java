package jp.co.nikkiso.ntss.core.dto.ordMaterialSave;

import lombok.Data;

/**
 * add FNSI No.396 治療記録 実績確定 use -- Sanjingye Sun 20210121
 * 調整前の薬剤Dto
 */
@Data
public class CommonMedicineDto {

  /**
   * 薬剤コード
   */
  private int medicineCd;

  /**
   * 薬剤 amount
   */
  private double mediAmount;
}
