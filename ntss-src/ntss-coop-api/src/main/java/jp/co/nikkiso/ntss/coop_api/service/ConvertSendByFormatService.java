package jp.co.nikkiso.ntss.coop_api.service;

import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;


/**
 * ConvertSend service
 *
 */
public interface ConvertSendByFormatService {
  /**
   * 送信用の電文作成
   *
   * @param journal 外部連携用ジャーナル
   */
  void createTelegram(SysCoopJournal journal);
}
