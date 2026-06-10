package jp.co.nikkiso.ntss.core.logevent;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstWaterSurveyPointDao;
import jp.co.nikkiso.ntss.core.dao.TableFlagConfigDao;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.TableFlagConfig;
import jp.co.nikkiso.ntss.core.entity.custom.WaterSurveyPoint;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.List;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * ログ出力サービス
 */
@Service
public class LogServiceCoreImpl implements LogServiceCore {

  private final String SYSTEM = "system";

  /**
   * ロガー生成コンポーネント
   */
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  // xiebzh add start
  @Autowired
  private ILogEventService logEventService;

  @Autowired(required = false)
  MongoTemplate mongoTemplate;

  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  @Autowired
  PlatformTransactionManager transactionManager;
  // xiebzh add end


  @Autowired
  MstWaterSurveyPointDao mstWaterSurveyPointDao;

  // add 10601 eventLog共通処理 gjn start
  @Autowired
  private TableFlagConfigDao tableFlagConfigDao;
  // add 10601 eventLog共通処理 gjn end

  /**
   * {@inheritDoc}
   */
  @Override
  public void log(LogLevel logType, EventLogMessage eventLogMessage, String functionCode, String moduleName, String serviceName,
                  String sqlFilePath) {
    try {

      // SQL名
      if (sqlFilePath != null && eventLogMessage.getSqlIdentification() != null) {
        try {
          String sqlData = LogObjectUtils.readSqlFile(sqlFilePath);
          sqlData += " | " + eventLogMessage.getSqlIdentification();
          eventLogMessage.setSqlIdentification(sqlData);
        } catch (Exception e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
          throw new RuntimeException(e);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        }
      }
      // 機能コード
      if (!StringUtils.isEmpty(functionCode)) {
        eventLogMessage.setFunctionCd(functionCode);
      }
      // サービス名
      if (!StringUtils.isEmpty(serviceName)) {
        eventLogMessage.setServiceName(moduleName + ", " + serviceName);
      }

      // xiebzh add start
      logEventService.create(LogLevel.INFO, LogEventUtil.getLogEvent(LogLevel.INFO.name(), eventLogMessage));
      // xiebzh add end

    } catch (Exception e) {
      //throw e;
    }
  }

  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --start */
  @Override
  public void logToBatch(LogLevel logType, List<EventLogMessage> evmList, String functionCode, String moduleName, String serviceName,
                  String sqlFilePath) {
    try {
      List<LogEvent> logEventList = new ArrayList<>();
      for (EventLogMessage eventLogMessage: evmList) {
        // SQL名
        if (sqlFilePath != null && eventLogMessage.getSqlIdentification() != null) {
          try {
            String sqlData = LogObjectUtils.readSqlFile(sqlFilePath);
            sqlData += " | " + eventLogMessage.getSqlIdentification();
            eventLogMessage.setSqlIdentification(sqlData);
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
            EventLogMessage eventLogMessageNew = new EventLogMessage();
            eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
            this.log(LogLevel.ERROR, eventLogMessageNew, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          }
        }
        // 機能コード
        if (!StringUtils.isEmpty(functionCode)) {
          eventLogMessage.setFunctionCd(functionCode);
        }
        // サービス名
        if (!StringUtils.isEmpty(serviceName)) {
          eventLogMessage.setServiceName(moduleName + ", " + serviceName);
        }

//        // xiebzh add start
//        logEventService.create(LogLevel.INFO, LogEventUtil.getLogEvent(LogLevel.INFO.name(), eventLogMessage));
//        // xiebzh add end
        logEventList.add(LogEventUtil.getLogEvent(LogLevel.INFO.name(), eventLogMessage));
      }

      if (!logEventList.isEmpty()) {
        logEventService.createToBatch(LogLevel.INFO, logEventList);
      }

    } catch (Exception e) {
      //throw e;
    }
  }
  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --end */

  @Override
  public PlatformTransactionManager getPlatformTransactionManager() {
    return transactionManager;
  }

  /**
   * 治療情報履歴登録
   * @param ordMainHisMongo
   */
  public void createOrdMainHis(OrdMainHisMongo ordMainHisMongo){
    // ユーザ名取得
    if (!StringUtils.isEmpty(ordMainHisMongo.getUpUserId())) {
      ordMainHisMongo.setUpUserName(logEventService.getPersonalInfoEncrypt(getUsername(ordMainHisMongo.getUpUserId())));
    }
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        mongoTemplate.insert(ordMainHisMongo);
      }
    } catch (DataAccessResourceFailureException exception) {
      MongoHealthCheckService.setMongoDBConnected(false);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      exception.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
      this.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
    }
    //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
  }

  /**
   * ユーザ名取得する
   * @param userId
   */
  private String getUsername(String userId) {
    if (!StringUtils.isEmpty(userId)) {
      List userList = new ArrayList();
      userList.add(userId);
      List<MstPersonalUser> listPersonalUser = mstPersonalUserDao.selectByIdList(userList);
      if (listPersonalUser != null && listPersonalUser.size() > 0) {
        MstPersonalUser person = listPersonalUser.get(0);
        if (person != null) {
          return nullToSpace(person.getUserLastName()) + " " + nullToSpace(person.getUserFirstName());
        }
      }
    }
    return "";
  }

  /**
   * 文字列変換する
   * @param obj 文字列
   * @return 変換した文字列
   */
  private static String nullToSpace(String obj) {
    if (obj == null) {
      return "";
    }
    return obj;
  }
  //6375　検査日付・装置名・種別・検査箇所の情報を取得　add start ljx
  @Override
 public WaterSurveyPoint getSurveyData(Long pointCd){
   WaterSurveyPoint waterSurveyPoint = mstWaterSurveyPointDao.selectByCd(pointCd);
   return waterSurveyPoint;
 }
  //6375　検査日付・装置名・種別・検査箇所の情報を取得　add start ljx

  // add 10601 eventLog共通処理 gjn start
  @Cacheable("tableFlagCache")
  @Override
  public List<TableFlagConfig> getTableFlagConfigList () {
    if (tableFlagConfigDao != null) {
      List<TableFlagConfig> tableFlagConfigList = tableFlagConfigDao.selectAll();
      return tableFlagConfigList;
    } else {
      return null;
    }
  }
  // add 10601 eventLog共通処理 gjn end
}
