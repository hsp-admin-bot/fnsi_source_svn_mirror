package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;

/**
 * 緊急発報マスタのServiceインタフェース.
 */
public interface MaintenanceMNoticeService {

  /**
   * 対象施設のメール送信情報を作成する.
   *
   * @param targetFacilities 対象施設コードのリスト
   * @return なし
   */
  void createMstMNotice(List<String> targetFacilities);

}
