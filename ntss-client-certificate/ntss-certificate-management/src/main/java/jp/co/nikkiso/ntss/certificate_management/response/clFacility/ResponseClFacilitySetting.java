package jp.co.nikkiso.ntss.certificate_management.response.clFacility;

import lombok.Data;

@Data
public class ResponseClFacilitySetting {

  // パスワードの最小長
  private int passwordMin;

  // ロックカウント
  private int lockCount;
}
