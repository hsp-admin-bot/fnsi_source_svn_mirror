package jp.co.nikkiso.ntss.core.logevent;

import jp.co.nikkiso.ntss.core.entity.TableFlagConfig;
import jp.co.nikkiso.ntss.core.entity.custom.WaterSurveyPoint;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.transaction.PlatformTransactionManager;

import java.util.List;

/**
 * ログ出力サービスのインタフェース.
 */
public interface LogServiceCore {

  /**
   * ログ出力する.
   *
   * @param logType ログ種別
   * @param evm ログ出力メッセージ
   * @param functionCode 機能コード
   * @param serviceName サービス名
   * @param sqlFilePath SQLファイルパス
   */
  void log(LogLevel logType, EventLogMessage evm, String functionCode, String moduleName, String serviceName, String sqlFilePath);

  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --start */
  void logToBatch(LogLevel logType, List<EventLogMessage> evmList, String functionCode, String moduleName, String serviceName, String sqlFilePath);
  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --end */

  void createOrdMainHis(OrdMainHisMongo ordMainHisMongo);

  //6375　検査日付・装置名・種別・検査箇所の情報を取得　add start ljx
  /**
   * 水質の装置名・種別・検査箇所の情報を取得。
   *
   * @param pointCd ログ種別
   */
  WaterSurveyPoint getSurveyData(Long pointCd);
  //6375　検査日付・装置名・種別・検査箇所の情報を取得　add start ljx

  PlatformTransactionManager getPlatformTransactionManager();

  // add 10601 eventLog共通処理 gjn start
  List<TableFlagConfig> getTableFlagConfigList ();
  // add 10601 eventLog共通処理 gjn end
}
