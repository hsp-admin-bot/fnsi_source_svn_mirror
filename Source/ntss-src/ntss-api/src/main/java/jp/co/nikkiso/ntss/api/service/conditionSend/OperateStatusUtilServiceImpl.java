package jp.co.nikkiso.ntss.api.service.conditionSend;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.OperateStatusDao;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

/**
 * スケジュール表のService実装クラス.
 */
@Service
public class OperateStatusUtilServiceImpl implements OperateStatusUtilService {

  /**
   * 状態変更Dao.
   */
  @Autowired
  private OperateStatusDao operateStatusDao;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;
  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // DB更新ログ出力ロジック wangzuo End

  /**
   * ord_mainの状態変更用
   *
   * @param ord_no         オーダー番号
   * @param status         ステータス
   * @param updateDateFlag 条件送信日時変更フラグ(true:変更)
   * @return update件数
   * @throws Exception
   */
  public int updateOrdMainStatus(
    long ord_no,
    String status,
    boolean updateDateFlag
  ) {
    int ret = -1;

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "ord_main";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" ord_no = " + ord_no + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    ret = operateStatusDao.updateOrdMainStatus(ord_no, status, updateDateFlag);

    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResult && ret > 0) {
      logCommon.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End

    return ret;
  }

  /**
   * pat_mainの状態変更用
   *
   * @param ord_no          オーダー番号
   * @param status          ステータス
   * @param updateValueFlag 進捗計算用値変更フラグ(true:変更)
   * @return update件数
   * @throws Exception
   */
  public int updatePatMainStatus(
    long ord_no,
    String status,
    boolean clearStatusFlag,
    boolean updateValueFlag
  ) {
    int ret = -1;

    ret = operateStatusDao.updatePatMainStatus(
      ord_no,
      status,
      clearStatusFlag,
      updateValueFlag
    );

    return ret;
  }

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
//    add 8074 【デグレ】ログに誤った利用者が記録される 関 start
    eventLogMessage.setUserId("-1");
//    add 8074 【デグレ】ログに誤った利用者が記録される 関  end
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.NTSS_WEB_API + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   *
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End
}
