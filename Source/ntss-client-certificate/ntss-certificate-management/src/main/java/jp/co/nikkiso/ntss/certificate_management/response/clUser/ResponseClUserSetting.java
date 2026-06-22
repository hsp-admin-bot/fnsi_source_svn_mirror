package jp.co.nikkiso.ntss.certificate_management.response.clUser;

import lombok.Data;

@Data
public class ResponseClUserSetting {

  // バージョン
  private float version;
  // パスワードの最小長
  private int passwordMin;
  // ロックカウント
  private int lockCount;
}
