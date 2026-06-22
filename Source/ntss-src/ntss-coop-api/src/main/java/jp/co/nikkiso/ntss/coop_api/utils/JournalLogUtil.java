package jp.co.nikkiso.ntss.coop_api.utils;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jakarta.annotation.PostConstruct;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

//#7239 2022-11-23 add  処理保留イベントの最適化処理が行われない start
@Component
public class JournalLogUtil {
  @Autowired
  private LogService logServiceTemp;
  @Autowired
  private EventLoggerFactory eventLoggerFactoryTemp;
  @Autowired
  private LogServiceCore logServiceCoreTemp;

  @Autowired
  @DefaultDb
  private Config defaultDbConfigTemp;

  private static LogService logService;
  private static EventLoggerFactory eventLoggerFactory;
  private static LogServiceCore logServiceCore;
  private static Config defaultDbConfig;


  @PostConstruct
  public void init() {
    logService = logServiceTemp;
    logServiceCore = logServiceCoreTemp;
    eventLoggerFactory = eventLoggerFactoryTemp;
    defaultDbConfig = defaultDbConfigTemp;
  }

  public static void eventMessageDebug(String messageTemplate, SysCoopJournal journal, String className, String fnsi) {
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    String message = String.format(messageTemplate + " オーダ番号:[%s],患者番号:[%s],電文種別:[%s],送信/受信:[%s]",
//      journal.getOrdNo(), journal.getPatId(), journal.getCoopCd(), journal.getDirection());
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":String.valueOf(journal.getCoopVersion());
    String message = String.format(messageTemplate + " オーダ番号:[%s],患者番号:[%s],電文種別:[%s],連携版番号:[%s],送信/受信:[%s]",
      journal.getOrdNo(), journal.getPatId(), journal.getCoopCd(), coopVersion, journal.getDirection());
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(journal.getFacilityCd());
    eventLogMessage.setInvokeClass(className);
    eventLogMessage.setLogMessage(message);
    logService.log(LogLevel.DEBUG, eventLogMessage, null, fnsi, null);
  }

  public static void eventMessageInfo(String messageTemplate, SysCoopJournal journal, String className, String fnsi) {
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    String message = String.format(messageTemplate + " オーダ番号:[%s],患者番号:[%s],電文種別:[%s],送信/受信:[%s]",
//      journal.getOrdNo(), journal.getPatId(), journal.getCoopCd(), journal.getDirection());
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":String.valueOf(journal.getCoopVersion());
    String message = String.format(messageTemplate + " オーダ番号:[%s],患者番号:[%s],電文種別:[%s],連携版番号:[%s],送信/受信:[%s]",
      journal.getOrdNo(), journal.getPatId(), journal.getCoopCd(), coopVersion, journal.getDirection());
// mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(journal.getFacilityCd());
    eventLogMessage.setInvokeClass(className);
    eventLogMessage.setLogMessage(message);
    logService.log(LogLevel.INFO, eventLogMessage, null, fnsi, null);
  }

  /**
   * ログ出力共通クラス設定、取得
   *
   * @return logCommon ログ出力共通クラス
   */
  public static DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  public static EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();

    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return eventLogMessage;
  }
  /**
   * エラーログ出力
   *
   * @param facilityCd 施設コード
   * @param message    ログメッセージ
   */
  public static void outputErrorLog(String message,String facilityCd ,String className) {
    outputLog(LogLevel.ERROR, facilityCd, message,className);
  }

  /**
   * ログ出力
   *
   * @param level      {@link LogLevel} ログレベル
   * @param facilityCd 施設コード
   * @param message    ログメッセージ
   */
  private static void outputLog(LogLevel level, String facilityCd, String message, String className) {
    EventLogMessage elm = new EventLogMessage();
    elm.setFacilityCd(facilityCd);
    elm.setLogMessage(message);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    elm.setInvokeClass(className);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(level, elm, null, LoggingConstant.SERVICE_NAME.FNSI, null);
  }
}
//#7239 2022-11-23 add  処理保留イベントの最適化処理が行われない end

