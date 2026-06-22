package jp.co.nikkiso.ntss.core.dto.ordMaterialSave;

import lombok.Data;
import lombok.EqualsAndHashCode;

import java.util.List;

/**
 * add FNSI No.396 治療記録 実績確定 use -- Sanjingye Sun 20210121
 * 調整薬剤Dto
 */
@Data
@EqualsAndHashCode(callSuper=false)
public class MixMedicineDto extends CommonMedicineDto {

  /**
   * Common medicine of the mix medicine
   */
  private List<CommonMedicineDto> commonMedicineList;
}
