package jp.co.nikkiso.ntss.admin_web.response.mstMedicineMix;

import lombok.Getter;
import lombok.Setter;


/**
 * 調整薬剤マスタを表すクラス.
 */
@Getter
@Setter
public class MedicineMixSharingInfoResponse {

  /**
   * 調製薬剤名.
   */
  public String medicineMixName;

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
