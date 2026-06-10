package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.PersonalSettingsDefine;

/**
 * 個人設定の共通画面用設定のServiceインターフェース
 */
public interface SysPersonalSettingsDefineService {

  /**
   * 共通画面用設定を取得する
   * @param facilityCd 施設コード
   * @param tabDefineCd タブ定義コード
   * @return 共通画面用設定
   */
  PersonalSettingsDefine getPersonalSettingsDefine(String facilityCd, Integer tabDefineCd);
}
