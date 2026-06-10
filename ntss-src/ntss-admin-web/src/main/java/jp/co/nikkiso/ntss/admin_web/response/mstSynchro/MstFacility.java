package jp.co.nikkiso.ntss.admin_web.response.mstSynchro;

import lombok.AllArgsConstructor;

/**
 * 施設マスタのマスタ1件を表すクラス.
 */
@AllArgsConstructor
public class MstFacility {
  
  /**
   * 施設コード.
   */
  public String facilityCd;
  
  /**
   * 施設名.
   */
  public String facilityName;
}
