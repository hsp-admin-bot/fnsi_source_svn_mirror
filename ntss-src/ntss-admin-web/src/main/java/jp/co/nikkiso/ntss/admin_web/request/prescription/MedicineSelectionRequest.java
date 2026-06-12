package jp.co.nikkiso.ntss.admin_web.request.prescription;

import jakarta.validation.constraints.NotNull;

import lombok.Data;

/**
 * 処方薬剤選択.
 *
 */
@Data
public class MedicineSelectionRequest {
    /**
     * 施設コード
     */
    @NotNull
    private String facilityCd;
    /**
     * 薬剤分類
     */
    private Integer classCd;
    /**
     * 薬剤名
     */
    private String medicineName;

    /**
     * 一般名
     */
    private String genericName;
    /**
     * 患者ID
     */
    private Long patId;
    // add FNSI5516-処方薬剤選択画面の表示が遅い 周 start
  /**
   * offset
   */
  private long offset;

  /**
   * limit
   */
  private int limit;
  // add FNSI5516-処方薬剤選択画面の表示が遅い 周 end
}
