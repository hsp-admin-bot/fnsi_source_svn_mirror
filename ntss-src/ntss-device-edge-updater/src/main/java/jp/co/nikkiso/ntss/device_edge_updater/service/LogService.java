package jp.co.nikkiso.ntss.device_edge_updater.service;

import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

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

