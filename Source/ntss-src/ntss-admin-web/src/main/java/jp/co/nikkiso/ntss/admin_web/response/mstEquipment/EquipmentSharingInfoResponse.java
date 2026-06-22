package jp.co.nikkiso.ntss.admin_web.response.mstEquipment;

import lombok.Getter;
import lombok.Setter;


/**
 * 機器マスターを表すクラス.
 */
@Getter
@Setter
public class EquipmentSharingInfoResponse {

  /**
   * 機器名.
   */
  public String equipmentName;

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
