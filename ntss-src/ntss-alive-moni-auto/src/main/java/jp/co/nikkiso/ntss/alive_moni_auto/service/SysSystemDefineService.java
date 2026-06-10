package jp.co.nikkiso.ntss.alive_moni_auto.service;

import jp.co.nikkiso.ntss.alive_moni_auto.constant.SysSystemDefineCtlNo;

/**
 * システム設定のServiceインターフェース.
 */
public interface SysSystemDefineService {
  
  /**
   * 処理を行うべきサーバーか否かの確認.
   * 
   * @param ctlNo システム設定の管理番号(Enum定義「SysSystemDefineCtlNo」から設定)
   * @param ipAddress 確認を行うIPアドレス(システム設定から取得された値と比較)
   * @return true：処理実施サーバーである、false：処理実施サーバーではない
   */
  boolean IsProcServer(SysSystemDefineCtlNo ctlNo, String ipAddress);
}
