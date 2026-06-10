package jp.co.nikkiso.ntss.core.logevent;

import com.google.common.base.CaseFormat;
import jp.co.nikkiso.ntss.core.dao.BaseEntityDao;
import jp.co.nikkiso.ntss.core.entity.BaseBlankEntity;
import jp.co.nikkiso.ntss.core.entity.BaseEntity;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import org.seasar.doma.Column;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.Config;
import org.springframework.util.StringUtils;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;

public class LogEventUtil {

  private static final String SYSTEM = "system";

  private static  final String PAT_MAIN_CLASSNAME = "jp.co.nikkiso.ntss.core.entity.PatMain";

  /**
   * ログオブジェクトを設定して戻する
   * @param logType ログ種別
   * @param eventLogMessage ログメッセージオブジェクト
   * @return
   */
  public static LogEvent getLogEvent(String logType, EventLogMessage eventLogMessage) {
    LogEvent logEvent = new LogEvent();
    // ログ種別
    logEvent.setLogType(nullToSpace(logType));
    // 施設コード
    logEvent.setFacilityCd(nullToSpace(eventLogMessage.getFacilityCd()));
    // 利用者ID
    logEvent.setUserId(nullToSpace(eventLogMessage.getUserId()));
    // クライアントIP
    logEvent.setClientIp(nullToSpace(eventLogMessage.getClientIp()));
    // セッションID
    logEvent.setSessionId(nullToSpace(eventLogMessage.getSessionId()));
    // デバイスエッジNo
    logEvent.setDeNo(nullToSpace(eventLogMessage.getDeviceEdgeNo()));
    // デバイスエッジ製造番号
    logEvent.setDeSerial(nullToSpace(eventLogMessage.getDeviceEdgeSerialNo()));
    // 型式
    logEvent.setMcnType(nullToSpace(eventLogMessage.getMachineType()));
    // 型式コード
    logEvent.setMcnTypeCd(nullToSpace(eventLogMessage.getMachineTypeCd()));
    // EC2識別
    logEvent.setEc2Ip(nullToSpace(eventLogMessage.getEc2Identification()));
    // サービス名
    logEvent.setSvcName(nullToSpace(eventLogMessage.getServiceName()));
    // 画面コード
    logEvent.setFuncCd(nullToSpace(eventLogMessage.getFunctionCd()));
    // 画面名
    logEvent.setFunctionName(nullToSpace(eventLogMessage.getFunctionName()));
    // 内部患者ID
    logEvent.setPatId(nullToSpace(eventLogMessage.getPatId()));
    // ログ内容
    logEvent.setMessage(nullToSpace(eventLogMessage.getLogMessage()));
    // invoke クラス
    logEvent.setInvokeClass(nullToSpace(eventLogMessage.getInvokeClass()));
    // 対応内容
    logEvent.setTodo("");

    return logEvent;
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

  /**
   * エラーログを出力する
   * @param e
   */
  public static void outputErrorLog(EventLoggerFactory eventLoggerFactory, Exception e, String className) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + ": " +getErrorMessage(e));
    // 本アプリケーションが稼働しているIPアドレスを取得
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    EventLogger logger = eventLoggerFactory.getLogger(SYSTEM, LogClass.APP);
    // ログ出力
    logger.error(eventLogMessage);
  }

  /**
   * エラーメッセージ取得
   * @return
   */
  public static String getErrorMessage(Exception e) {
    if (!StringUtils.isEmpty(e.getMessage())) {
      return e.getMessage();
    }
    StringWriter stringWriter= new StringWriter();
    PrintWriter writer= new PrintWriter(stringWriter);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
    StringBuffer buffer = stringWriter.getBuffer();
    return buffer.toString();
  }

  /**
   * メッセージ設定
   * @return 設定したメッセージ
   */
  public static EventLogMessage getEventLogMessage(Object entity) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(getFacilityCd(entity));
    if (entity instanceof BaseBlankEntity) {
      eventLogMessage.setUserId(DataUpdateLogInfoUtil.convertString(((BaseBlankEntity)entity).getOperatorId()));
      eventLogMessage.setClientIp(DataUpdateLogInfoUtil.convertString(((BaseBlankEntity)entity).getClientIp()));
    }
    if (entity instanceof BaseEntity) {
      eventLogMessage.setUserId(DataUpdateLogInfoUtil.convertString(((BaseEntity)entity).getOperatorId()));
      eventLogMessage.setClientIp(DataUpdateLogInfoUtil.convertString(((BaseEntity)entity).getClientIp()));
    }
    return eventLogMessage;
  }

  public static String getFacilityCd(Object entity) {
    try {
      Method method = null;
      //＃6067　PatMainの場合、メソッドがgetFacility_cd、他はgetFacilityCd。
      if(PAT_MAIN_CLASSNAME.equals(entity.getClass().getName())){
         method = entity.getClass().getDeclaredMethod("getFacility_cd");
      }else{
         method = entity.getClass().getDeclaredMethod("getFacilityCd");
      }
      method.setAccessible(true);
      return (String) method.invoke(entity);
    } catch (Exception ex) {
      // 例外発生時は"targetFacilityCd"から取得する.
      return "";
    }
  }

  /**
   * Where条件取得
   * @param entity
   * @return
   */
  public static StringBuffer createWhereBuilder(EventLoggerFactory eventLoggerFactory, Object entity) {
    try {
      Class<?> clazz = entity.getClass();
      StringBuffer selectBuilder = new StringBuffer("");

      // テーブル名を取得する
      if (!clazz.isAnnotationPresent(Table.class)) {
        return null;
      }

      // 抽出条件を取得する
      List<Field> fields = Arrays.stream(clazz.getDeclaredFields())
        .filter(f -> f.isAnnotationPresent(Id.class))
        .collect(Collectors.toList());
      if (fields.isEmpty()) {
        return null;
      }

      String condition = " where ";
      for (Field field : fields) {

        selectBuilder.append(condition);

        // カラム名を取得する
        String name;
        if (field.isAnnotationPresent(Column.class)) {
          name = field.getAnnotation(Column.class).name();
        } else {
          name = CaseFormat.UPPER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, field.getName());
        }

        selectBuilder.append(name).append(" = ");

        // 値を取得する
        Object obj = null;
        try {
          field.setAccessible(true);
          obj = field.get(entity);
        } catch (IllegalAccessException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 del yangxuewang end
        } finally {
          field.setAccessible(false);
        }

        if (obj == null) {
          return null;
        }

        if (obj instanceof String) {
          selectBuilder.append("'" + DataUpdateLogInfoUtil.convertString(obj) + "'");
        } else if (obj instanceof Integer) {
          selectBuilder.append((Integer) obj);
        } else if (obj instanceof Long) {
          selectBuilder.append((Long) obj);
        } else if (obj instanceof Timestamp) {
          selectBuilder.append((Timestamp) obj);
        }

        condition = " and ";
      }

      return selectBuilder;
    } catch (Exception e) {
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, "jp.co.nikkiso.ntss.core.logevent.LogEventUtil");
      return null;
    }
  }

  /**
   * エンティティからテーブル名を取得する.
   * エンティティに"@Table"が指定されていない場合、空文字を返却する.
   *
   * @param entity エンティティ
   * @return テーブル名
   */
  public static String getTableName(Object entity) {
    Class<?> clazz = entity.getClass();
    // @Tableが付与されているか否かをチェック
    // 付与されていない場合は空文字を返却
    if (!clazz.isAnnotationPresent(Table.class)) {
      return "";
    }
    return clazz.getAnnotation(Table.class).name();
  }

  /**
   * ログオブジェクト設定
   * @param logCommon
   * @param eventLoggerFactory
   * @param logServiceCore
   * @param baseEntityDao
   * @param entity
   * @return
   */
  public static boolean setLogCommon(DataUpdateLogCommonNew logCommon, EventLoggerFactory eventLoggerFactory,
                  LogServiceCore logServiceCore, BaseEntityDao baseEntityDao, Object entity, Config config) {
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(config);
    logCommon.setTableName(LogEventUtil.getTableName(entity));
    StringBuffer whereStr = LogEventUtil.createWhereBuilder(eventLoggerFactory, entity);
    if (whereStr == null) {
      return false;
    }
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(LogEventUtil.getEventLogMessage(entity));
    return logCommon.setInfo();
  }
}
