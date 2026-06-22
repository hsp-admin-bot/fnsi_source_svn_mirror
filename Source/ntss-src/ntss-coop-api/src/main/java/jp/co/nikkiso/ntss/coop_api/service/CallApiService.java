package jp.co.nikkiso.ntss.coop_api.service;

import java.util.Map;

import jp.co.nikkiso.ntss.coop_api.request.CallApiJournalRequest;
import jp.co.nikkiso.ntss.core.entity.MstCoopApilink.AfterApiStatus;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

/**
 * API呼び出しサービス
 *
 */
public interface CallApiService {

  /**
   * 連携API関連付けに定義されているAPIの呼び出し。
   *
   * @param request ジャーナル転送APIリクエスト
   * @param jounal 外部連携用ジャーナル
   * @param afterApiStatusMap 処理後ステータスentity
   * @return 処理後続行可否
   */
  public boolean callApiJournal(CallApiJournalRequest request, SysCoopJournal journal, Map<String, AfterApiStatus> afterApiStatusMap);

}
