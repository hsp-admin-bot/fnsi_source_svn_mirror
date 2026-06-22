package jp.co.nikkiso.ntss.device_edge.service.Utility;

import lombok.Data;

@Data
public class PatNameInfo {
  /**
   * 取得成否
   */
  boolean isSuccess;
  /**
   * 姓
   */
  String LastName;
  /**
   * 名
   */
  String firstName;

  PatNameInfo(boolean isSuccess, String firstName, String LastName) {
    this.isSuccess = isSuccess;
    this.firstName = firstName;
    this.LastName = LastName;
  }
}
