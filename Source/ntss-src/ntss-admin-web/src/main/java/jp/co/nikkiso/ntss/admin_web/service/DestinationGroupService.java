package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.destinationGroup.DestinationGroupNameResponse;

/**
 * 送信先グループ用のServiceインターフェース.
 */
public interface DestinationGroupService {
  /**
   * 送信先グループ名を取得する.
   * @return 送信先グループ名のレスポンス.
   */
  DestinationGroupNameResponse createDestinationGroupNameResponse(Long destinationGroupCd);
}
