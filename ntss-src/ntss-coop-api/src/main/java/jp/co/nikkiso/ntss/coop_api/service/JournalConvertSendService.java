package jp.co.nikkiso.ntss.coop_api.service;

import jp.co.nikkiso.ntss.coop_api.request.JournalConvertSendRequest;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

/**
 * ジャーナル変換処理のサービス
 *
 * 機能JournalConvertSendResourceの内容にJournalConvertSendServiceを移動する。
 * JournalConvertSendServiceのみにJournalConvertSendServiceを呼び出い。
 */
public interface JournalConvertSendService {

  /**
   * ジャーナル変換処理
   * @param request : {@link JournalConvertSendRequest}
   * @param ordNo （次世代FN)オーダ番号
   * @param patId 患者番号（システム）
   * @return {@link JournalConvertResult}
   */
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --start */
  public JournalConvertResult convert(JournalConvertSendRequest request, Long ordNo, Long patId);
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --end */

  /**
   * 送信しない設定
   * @param facilityCd 施設コード
   * @param ordNo （次世代FN)オーダ番号
   * @param patId 患者番号（システム）
   */
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --start */
  Boolean updateToSkip(SysCoopJournal sysCoopJournal);
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId  --end */
}
