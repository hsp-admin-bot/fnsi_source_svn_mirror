package jp.co.nikkiso.ntss.admin_web.service.master;

import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterListResponse;

/**
 * マスタ一覧のServiceインタフェース.
 */
public interface MasterListService {
  
  /**
   * マスタ一覧の取得.
   * @param userType 利用者種別
   * @return マスタ一覧情報.
   */
  MasterListResponse getMasterList(Integer userType);
  
}
