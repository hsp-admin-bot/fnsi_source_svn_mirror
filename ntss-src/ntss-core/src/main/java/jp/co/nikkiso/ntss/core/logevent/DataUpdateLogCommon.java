package jp.co.nikkiso.ntss.core.logevent;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.TableCommentInfo;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.UpdateLogInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.MapKeyNamingType;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.beans.factory.annotation.Autowired;
// #10959 システム内でstatic変数を使っている箇所の洗い出し add yangxuewang start
import org.springframework.context.annotation.Scope;
// #10959 システム内でstatic変数を使っている箇所の洗い出し add yangxuewang end
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
/**
 * データ更新ログ共通クラス
 * xiebzh
 */
@Component
// #10959 システム内でstatic変数を使っている箇所の洗い出し add yangxuewang start
@Scope("prototype")
// #10959 システム内でstatic変数を使っている箇所の洗い出し add yangxuewang end
public class DataUpdateLogCommon {

  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  /**
   * ログサーブす
   */
  @Setter
  @Getter
  private LogServiceCore logServiceCore;

  /**
   * 更新前SQL文
   */
  @Setter
  @Getter
  private String executeSQL;

  /**
   * 更新テーブル物理名
   */
  @Setter
  @Getter
  private String tableName;

  /**
   * SQL実行用Dao
   */
  @Setter
  @Getter
  private Object dao;

  /**
   * 更新コラム物理名
   */
  @Setter
  @Getter
  private Map<String, Object> fieldNameMap;

  /**
   * メッセージ
   */
  @Setter
  @Getter
  private EventLogMessage commonEventLogMessage;

  /**
   * 検索結果格納
   */
  @Setter
  @Getter
  private List<Map<String, Object>> results;

  /**
   * 更新後検索結果格納
   */
  @Setter
  @Getter
  private List<Map<String, Object>> afterResults;

  /**
   * 更新前データ取得
   * @return boolean (true->検索結果あり、false->検索結果なし)
   */
  public boolean getBeforeUpData(){
    try {
      // 更新前データ取得
      this.results = getUpdateData();
      return !CollectionUtils.isEmpty(results);
    } catch (Exception e) {
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
      return false;
    }
}

  /**
   * 更新後データ取得
   * @return afterResults
   */
  public List<Map<String, Object>> getAfterUpData(){
    try {
      // 更新後データ取得
      this.afterResults = getUpdateData();
    } catch (Exception e) {
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
    }
    return this.afterResults;
  }

  /**
   * 更新ログ出力する
   */
  public void outputDataAccessLog() {
    try {
      EventLogMessage eventLogMessage = null;
      // 更新前データ取得
      if (results == null) {
        results = getUpdateData();
        if (results == null || results.isEmpty()) {
          return;
        }
      }
      // 患者ID
      String patId = DataUpdateLogInfoUtil.getPatId(results);
      //add 8168 装置状態管理のログ内容について 周安寧　start
      String machineName ="";
      //add 8168 装置状態管理のログ内容について 周安寧　end
      // 検索結果によって、ログを出力する
      for (int i = 0; i < results.size(); i++) {
        List listResult = new ArrayList();
        listResult.add(results.get(i));
        //add 8168 装置状態管理のログ内容について 周安寧　start
        Map<String, Object> map =results.get(i);
        machineName = (String) map.get("machine_name");
        //mod 8168 装置状態管理のログ内容について 周安寧　end
        // カラム情報を取得
        Map<String, UpdateLogInfo> logOutputInfoMap = getFieldInfo();
        if (logOutputInfoMap == null || logOutputInfoMap.size() == 0) {
          continue;
        }
        // 変更前データを取得
        DataUpdateLogInfoUtil.setBeforeFieldValue(listResult, logOutputInfoMap);
        // データ更新済みフラグ設定
        DataUpdateLogInfoUtil.setUpdated(Config.get(dao), logOutputInfoMap);
        Iterator<String> iter = logOutputInfoMap.keySet().iterator();
        while (iter.hasNext()) {
          eventLogMessage = new EventLogMessage();
          //FNSI-修正 ログ対応 xiebzh add start
          eventLogMessage.setInvokeClass(this.getClass().getName());
          //FNSI-修正 ログ対応 xiebzh add end
          eventLogMessage.setPatId(patId);
          setEventLogMessage(eventLogMessage);
          String key = iter.next();
          UpdateLogInfo outputInfo = logOutputInfoMap.get(key);
          if (!outputInfo.isJson()) {
            if (!outputInfo.isUpdated()) {
              continue;
            }
            //mod 8168 装置状態管理のログ内容について 周安寧　start
            if ("mnt_machine_state".equals(outputInfo.getTableName())){
              // データ変更ログ出力(Json以外)
              DataUpdateLogInfoUtil.outputDataAccessLogNoJson(eventLogMessage, logServiceCore, outputInfo, machineName);
            } else {

              DataUpdateLogInfoUtil.outputDataAccessLogNoJson(eventLogMessage, logServiceCore, outputInfo, outputInfo.getTableComment());
            }
            //DataUpdateLogInfoUtil.outputDataAccessLogNoJson(eventLogMessage, logServiceCore, outputInfo, outputInfo.getTableComment());
            //mod 8168 装置状態管理のログ内容について 周安寧　end
          } else {
            //mod 8168 装置状態管理のログ内容について 周安寧　start
            if ("mnt_machine_state".equals(outputInfo.getTableName())){

              // データ変更ログ出力(Json)
              DataUpdateLogInfoUtil.outputDataAccessLogForJson(eventLogMessage, logServiceCore, outputInfo, machineName);
            }else {

              // データ変更ログ出力(Json)
              DataUpdateLogInfoUtil.outputDataAccessLogForJson(eventLogMessage, logServiceCore, outputInfo, outputInfo.getTableComment());
            }
            // データ変更ログ出力(Json)
            //DataUpdateLogInfoUtil.outputDataAccessLogForJson(eventLogMessage, logServiceCore, outputInfo, outputInfo.getTableComment());
            //mod 8168 装置状態管理のログ内容について 周安寧　end
          }
        }
      }
    } catch (NotExistException ole) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ole));
      logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      return;
    } catch (Exception e) {
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
  }



  /**
   * ログメッセージ情報設定
   * @param em ログメッセージ
   */
  private void setEventLogMessage(EventLogMessage em) {
    em.setUserId(commonEventLogMessage.getUserId());
    em.setFacilityCd(commonEventLogMessage.getFacilityCd());
    em.setClientIp(commonEventLogMessage.getClientIp());
    em.setSessionId(commonEventLogMessage.getSessionId());
    em.setServiceName(commonEventLogMessage.getServiceName());
  }

  /**
   * 更新前データ取得
   * @return 更新前データ情報
   */
  private List<Map<String, Object>> getUpdateData() {
    SelectBuilder selectBuilder = SelectBuilder.newInstance(Config.get(dao));
    selectBuilder.sql(executeSQL);
    return selectBuilder.getMapResultList(MapKeyNamingType.NONE);
  }

  /**
   * Sql実行
   * @param selectBuilder
   * @return 検索結果
   */
  private List<Map<String, Object>> executeSql(SelectBuilder selectBuilder) {
    return selectBuilder.getMapResultList(MapKeyNamingType.NONE);
  }

  /**
   * カラム情報を取得する
   * @return カラム情報
   */
  private Map<String, UpdateLogInfo> getFieldInfo() {
    List<TableCommentInfo> fieldCommentList = DataUpdateLogInfoUtil.getAllFieldComment(Config.get(dao), tableName);
    if (fieldCommentList == null || fieldCommentList.size() == 0) {
      return null;
    }
    Map<String, UpdateLogInfo> map = new HashMap<String, UpdateLogInfo>();
    UpdateLogInfo info = null;
    Iterator<String> iter = fieldNameMap.keySet().iterator();
    while(iter.hasNext()) {

      info = new UpdateLogInfo();
      String key = iter.next();
      info.setTableName(tableName);
      info.setTableComment(DataUpdateLogInfoUtil.getTableComment(fieldCommentList));
      info.setFieldName(key);
      info.setFieldComment(DataUpdateLogInfoUtil.getFieldComment(info.getFieldName(), fieldCommentList));
      if (StringUtils.isEmpty(info.getFieldName()) || StringUtils.isEmpty(info.getFieldComment())) {
        continue;
      }
      info.setKeyStep(DataUpdateLogInfoUtil.getKeyStep(fieldCommentList, info.getFieldName()));
      info.setAfterUpdateValue(fieldNameMap.get(key));
      map.put(info.getFieldName(), info);
    }

    return map;
  }
}
