package jp.co.nikkiso.ntss.coop_api.service;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

/**
 * ログ出力サービスのインタフェース.
 */
public interface LogService {

  /**
   * ログ出力する.
   *
   * @param logType ログ種別
   * @param evm ログ出力メッセージ
   * @param functionCode 機能コード
   * @param serviceName サービス名
   * @param sqlFilePath SQLファイルパス
   */
  void log(LogLevel logType, EventLogMessage evm, String functionCode, String serviceName, String sqlFilePath);

}
