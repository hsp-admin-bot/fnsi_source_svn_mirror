package jp.co.nikkiso.ntss.admin_web.service.statusList.dto.monitorData;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 *  モニタデータ値構造体.
 */
@NoArgsConstructor
@Getter
@Setter
public class MonitorDataItem {

  /** 値 **/
  String value;
  /** 単位 **/
  String Unit;

  /**
   * 値の有効チェック
   * @return false：null、空/true：else
   */
  public boolean isValidValue() {
    return value == null || value.isEmpty() ? false : true;
  }
}
