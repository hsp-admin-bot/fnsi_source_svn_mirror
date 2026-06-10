package jp.co.nikkiso.ntss.admin_web.request.sysMonitorItem;

import lombok.Data;

/**
 * モニタ項目（システム設定）取得条件格納用APIのRequestクラス.
 */
@Data
public class SysMonitorItemRequest {
  /**
   * モニタデータ種別
   */
  private String moniDataType;

  /**
   * バイタルモニタ区分
   */
  private String vitalMonitorClass;
}
