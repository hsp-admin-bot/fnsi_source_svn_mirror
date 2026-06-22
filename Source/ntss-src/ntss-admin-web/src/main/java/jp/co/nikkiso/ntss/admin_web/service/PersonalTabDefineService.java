package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.entity.TabDisplayNameAndContentsId;

import java.util.List;

/**
 * 個人設定タブ定義のServiceインターフェース.
 */
public interface PersonalTabDefineService {

  /**
   * 施設ごとの個人設定タブ定義を取得する.
   *
   * @param ntssUser 認証済みユーザ.
   * @return 個人設定タブ定義.
   */
  List<TabDisplayNameAndContentsId> getDisplayNameAndContentsIdByFacilityCd(NtssUser ntssUser);
}
