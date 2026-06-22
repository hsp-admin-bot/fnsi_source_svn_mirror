package jp.co.nikkiso.ntss.admin_web.service.reportDesigner.dto;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class MedicineDto {

  /**
   * 薬剤分類コード
   */
  private Integer classCd;

  /**
   * 分類名称.
   */
  private String className;

  /**
   * 標準薬剤 or 調整薬剤.
   */
  private Integer preparation;

  /**
   * 薬剤コード
   */
  private Integer medicineCd;

  /**
   * 薬剤名
   */
  private String medicineName;

}
