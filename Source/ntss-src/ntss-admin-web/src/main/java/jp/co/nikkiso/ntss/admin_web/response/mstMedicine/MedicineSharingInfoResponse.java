package jp.co.nikkiso.ntss.admin_web.response.mstMedicine;

import lombok.Getter;
import lombok.Setter;


/**
 * 薬剤マスタを表すクラス.
 */
@Getter
@Setter
public class MedicineSharingInfoResponse {
  
  /**
   * 薬名.
   */
  public String medicineName;
  
  /**
   * タブーアレルギーかどうか.
   */
  public Boolean isTabooAllergy;

  /**
   * プレフィックス.
   */
  public String prefix;

  /**
   * 使用開始日
   */
  private String useStartDate;

  /**
   * 使用終了日
   */
  private String useEndDate;

}
