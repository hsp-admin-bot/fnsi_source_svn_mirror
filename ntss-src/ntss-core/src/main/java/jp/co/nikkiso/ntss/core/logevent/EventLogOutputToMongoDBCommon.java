package jp.co.nikkiso.ntss.core.logevent;
// add 10601 eventLog共通処理 gjn start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.IndScheduleDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserAuthenticationDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.SysFunctionDao;
import jp.co.nikkiso.ntss.core.entity.DataUpdateLogInfoEntity;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.SysFunction;
import jp.co.nikkiso.ntss.core.entity.TableFlagConfig;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.JsonCompareInfo;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.TableCommentInfo;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.UpdateLogInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import lombok.Setter;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.seasar.doma.MapKeyNamingType;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.OptimisticLockException;
import org.seasar.doma.jdbc.SqlLogType;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.mongodb.core.BulkOperations;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.lang.reflect.Field;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.convertString;
import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.executeSql;
import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.getKeyWithParent;
import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.getKeyWithStep;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
import jp.co.nikkiso.ntss.core.config.PersonalDb;
import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.isEqual;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Component
public class EventLogOutputToMongoDBCommon {

  /**
   * 検索用インタフェース
   */
  @Setter
  private Config config;

  @Autowired
  private IndScheduleDao indScheduleDao;

  @Autowired
  LogServiceCore logServiceCore;

  /**
   * ロットinsert数量制限
   */
  private static final int BATCH_LIMIT_NUM = 1000;

  @Autowired(required = false)
  MongoTemplate mongoTemplate;

  /**
   * 施設マスタのDaoインタフェース.
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;

  @Autowired
  PatPersonalMainDao patPersonalMainDao;

  /**
   * 利用者マスタ(個人情報DB)Daoインタフェース.
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 利用者マスタ
   */
  @Autowired
  private MstUserAuthenticationDao mstUserAuthenticationDao;

  /**
   * 機能一覧
   */
  @Autowired
  private SysFunctionDao sysFunctionDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;

  @Autowired
  @PersonalDb
  private Config personalDbConfig;

  /* del by chamaojia 2024-08-13 [10959] delete incorrect variable definitions --start */
  // /**
  //  * log_json_commentテーブルデータ一時キャッシュmap
  //  */
  // Map<String, String> keyCommentMap = new HashMap<>();
  /* del by chamaojia 2024-08-13 [10959] delete incorrect variable definitions --end */

  /**
   * Jsonがないコラムのメッセージ
   */
  public final static String LOG_MESSAGE_NO_JSON = "[%s]の[%s]が[%s]→[%s]に変更されました。";

  /**
   * Jsonがあるコラムのメッセージ
   */
  public final static String LOG_MESSAGE_FOR_JSON = "[%s]の[%s]の[%s]が[%s]→[%s]に変更されました。";

  /**
   * Jsonがないコラムのメッセージ
   */
  public final static String LOG_MESSAGE_NO_JSON_INSERT = "[%s]の[%s]が[%s]に新规されました。";

  /**
   * Jsonがあるコラムのメッセージ
   */
  public final static String LOG_MESSAGE_FOR_JSON_INSERT = "[%s]の[%s]の[%s]が[%s]に新规されました。";

  /**
   * Jsonがないコラムのメッセージ
   */
  public final static String LOG_MESSAGE_NO_JSON_DELETE = "[%s]の[%s]が[%s]削除されました。";

  /**
   * Jsonがあるコラムのメッセージ
   */
  public final static String LOG_MESSAGE_FOR_JSON_DELETE = "[%s]の[%s]の[%s]が[%s]削除されました。";

  /**
   * すーべす
   */
  private final static String BLANK = "";

  /**
   * テーブル情報設定
   */
  private Map<String, List<String>> getFieldCommentInfo(String tableName) {
    Map<String, List<String>> fieldListMap = new HashMap<>();
    List<UpdateLogInfo> tableInfoList = new ArrayList<>();
    List<TableCommentInfo> commentInfos = getAllFieldComment(tableName);
    // key物理名格納リスト
    List<String> keyColList = new ArrayList<>();
    // ログ出力カラム物理名格納リスト
    List<String> logFieldColList = new ArrayList<>();
    // テーブル及びカラム情報取得
    commentInfos.forEach(tableCommentInfo -> {
      // テーブルキーの物理名と論理名を取得
      if (tableCommentInfo.getPkFlg() == 1) {
        // key col list
        keyColList.add(tableCommentInfo.getColName());
      }
      // log要出力のみのカラムの物理名と論理名を取得
      if (tableCommentInfo.getDeleteFlg() != 1) {
        // log field col list
        logFieldColList.add(tableCommentInfo.getColName());
        // カラム情報格納
        UpdateLogInfo outputInfo = new UpdateLogInfo();
        outputInfo.setTableName(tableCommentInfo.getTblName());
        outputInfo.setTableComment(tableCommentInfo.getTblComment());
        outputInfo.setFieldName(tableCommentInfo.getColName());
        outputInfo.setFieldComment(tableCommentInfo.getColComment());
        outputInfo.setJson("1".equals(tableCommentInfo.getJsonFlg()));
        outputInfo.setKeyStep(DataUpdateLogInfoUtil.getKeyStep(commentInfos, outputInfo.getFieldName()));
        tableInfoList.add(outputInfo);
      }
    });
    fieldListMap.put("keyColList", keyColList);
    fieldListMap.put("logFieldColList", logFieldColList);
    return fieldListMap;
  }


  /**
   * UpdateLogInfo
   */
  private List<UpdateLogInfo> getUpdateLogInfoList(String tableName) {
    List<UpdateLogInfo> tableInfoList = new ArrayList<>();
    List<TableCommentInfo> commentInfos = getAllFieldComment(tableName);
    // テーブル及びカラム情報取得
    commentInfos.forEach(tableCommentInfo -> {
      // log要出力のみのカラムの物理名と論理名を取得
      if (tableCommentInfo.getDeleteFlg() != 1) {
        // カラム情報格納
        UpdateLogInfo outputInfo = new UpdateLogInfo();
        outputInfo.setTableName(tableCommentInfo.getTblName());
        outputInfo.setTableComment(tableCommentInfo.getTblComment());
        outputInfo.setFieldName(tableCommentInfo.getColName());
        outputInfo.setFieldComment(tableCommentInfo.getColComment());
        outputInfo.setJson("1".equals(tableCommentInfo.getJsonFlg()));
        outputInfo.setKeyStep(DataUpdateLogInfoUtil.getKeyStep(commentInfos, outputInfo.getFieldName()));
        tableInfoList.add(outputInfo);
      }
    });
    return tableInfoList;
  }


  /**
   * 論理カラム名を取得する
   *
   * @return 論理カラム名
   */
  private List<TableCommentInfo> getAllFieldComment(String tableName) {
    SelectBuilder selectBuilder = SelectBuilder.newInstance(getDbConfig());
    selectBuilder.sql(" SELECT ");
    selectBuilder.sql(" tbl_name, ");
    selectBuilder.sql(" tbl_comment, ");
    selectBuilder.sql(" col_name, ");
    selectBuilder.sql(" col_comment, ");
    selectBuilder.sql(" json_flg, ");
    selectBuilder.sql(" keystep, ");
    selectBuilder.sql(" pk_flg, ");
    selectBuilder.sql(" delete_flg, ");
    selectBuilder.sql(" ord_main_hst_ins_flg ");
    selectBuilder.sql(" FROM ");
    selectBuilder.sql(" log_table_comment ");
    selectBuilder.sql(" WHERE ");
    selectBuilder.sql(" tbl_name = '" + tableName + "' ");
    // Select文の実行
    List<Map<String, Object>> results = selectBuilder.getMapResultList(MapKeyNamingType.NONE);
    // 結果がゼロ件の場合、楽観的排他エラーをスロー
    if (results.isEmpty()) {
      throw new OptimisticLockException(SqlLogType.NONE, selectBuilder.getSql());
    }
    List<TableCommentInfo> tableInfoList = new ArrayList<>();
    for (Map<String, Object> result : results) {
      TableCommentInfo tableInfo = new TableCommentInfo();
      tableInfo.setTblName(convertString(result.get("tbl_name")));
      tableInfo.setTblComment(convertString(result.get("tbl_comment")));
      tableInfo.setColName(convertString(result.get("col_name")));
      tableInfo.setColComment(convertString(result.get("col_comment")));
      tableInfo.setJsonFlg(convertString(result.get("json_flg")));
      if (StringUtils.isEmpty(convertString(result.get("keystep")))) {
        tableInfo.setKeyStep(1);
      } else {
        tableInfo.setKeyStep(Integer.parseInt(convertString(result.get("keystep"))));
      }
      tableInfo.setPkFlg(result.get("pk_flg") == null ? 0 : Integer.parseInt(convertString(result.get("pk_flg"))));
      tableInfo.setDeleteFlg(result.get("delete_flg") == null ? 0 : Integer.parseInt(convertString(result.get("delete_flg"))));
      tableInfo.setOrdMainHstInsFlg(result.get("ord_main_hst_ins_flg") == null ? 0 : Integer.parseInt(convertString(result.get("ord_main_hst_ins_flg"))));
      tableInfoList.add(tableInfo);
    }
    return tableInfoList;
  }

  /**
   * 検索用インタフェース取得
   *
   * @return
   */
  private Config getDbConfig() {
    if (this.config != null) {
      return this.config;
    }
    return defaultDbConfig;
  }

  /**
   * 将实体类转换为Map的方法
   */
  public Map<String, Object> entityToMap(Object entity) throws IllegalAccessException {
    Map<String, Object> map = new HashMap<>();
    Class<?> clazz = entity.getClass();
    for (Field field : clazz.getDeclaredFields()) {
      field.setAccessible(true);
      map.put(field.getName(), field.get(entity));
    }
    return map;
  }

  /**
   * 非同期 Data Diff
   *
   * @param resultAllChangeBeforeDataInfoList
   * @param resultAllChangedDataInfoList
   */
  @Async
  public void makeEvebtLogToMongoByDataDiff(Map<String, List<Object>> resultAllChangeBeforeDataInfoList,
                                        Map<String, List<Object>> resultAllChangedDataInfoList) throws IllegalAccessException {
    List<String> tblNames = new ArrayList<>();
    tblNames.addAll(resultAllChangeBeforeDataInfoList.keySet());
    tblNames.addAll(resultAllChangedDataInfoList.keySet());
    tblNames = tblNames.stream().distinct().collect(Collectors.toList());
    List<Map<String, Object>> beforeResults;
    List<Map<String, Object>> afterResults;
    // 操作タイプ
    AtomicBoolean operateFlag = new AtomicBoolean(false);
    for (String tableName : tblNames) {
      beforeResults = new ArrayList<>();
      afterResults = new ArrayList<>();
      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao strat
      if (resultAllChangeBeforeDataInfoList.get(tableName) != null) {
        for (Object objectBefor : resultAllChangeBeforeDataInfoList.get(tableName)) {
          beforeResults.add(entityToMap(objectBefor));
        }
      }
      if (resultAllChangedDataInfoList.get(tableName) != null) {
        for (Object objectAfter : resultAllChangedDataInfoList.get(tableName)) {
          afterResults.add(entityToMap(objectAfter));
        }
      }
      // mod #10553 ①10125のsys_coop_iniのEXAMIN_INFO IND_SEND_MODE設定に応じた動作切替が画面がで実現 #10125 piao end
      // テーブル名から列集合を取り出す
      List<UpdateLogInfo> tableInfoList = getUpdateLogInfoList(tableName);
      Map<String, List<String>> fieldListMap = getFieldCommentInfo(tableName);
      // PK list
      List<String> keyColList = fieldListMap.get("keyColList");
      //TODO 更新 Diff
      for (Map<String, Object> oldMap : beforeResults) {
        operateFlag.set(false);
        // 更新後のリストから絞り
        afterResults.stream()
          // テーブルキーでマッピングして、データを絞り、主キーあれば、一件のはず
          .filter(newMap -> oldEquelsNew(keyColList, oldMap, newMap))
          .forEach(filterNewMap -> {
            operateFlag.set(true);
            // 更新後のMapをループして、更新前後の値が差分があれば、該当するカラムと更新前後の値を格納する
            filterNewMap.keySet().forEach(fieldName -> {
              // 更新前データ
              Object beforeData = oldMap.get(fieldName);
              // 更新後データ
              Object afterData = filterNewMap.get(fieldName);
              // 差分あり、かつログ出力カラムである場合、更新前後の値を設定
              if (checkDiff(afterData, beforeData)) {
                tableInfoList.stream()
                  .filter(updateLogInfo -> fieldName.equals(toCamelCase(updateLogInfo.getFieldName())))
                  .forEach(updateLogInfo -> {
                    updateLogInfo.setBeforeUpdateValue(beforeData);
                    updateLogInfo.setAfterUpdateValue(afterData);
                    updateLogInfo.setUpdated(true);
                    if (updateLogInfo.isJson()) {
                      try {
                        // フォーマット変換
                        Map<String, Object> map = campareJsonObject(convertString(beforeData), convertString(afterData));
                        if (map != null && map.size() > 0) {
                          // JSONデータ内容複雑比較，差異化データを返す
                          List<JsonCompareInfo> list = this.getJsonCompareObject(map, updateLogInfo);
                          updateLogInfo.setJsonUpdatedlist(list);
                        }
                      } catch (JSONException e) {
                        System.err.println(e.toString());
                      }
                    }
                  });
              }
            });
          });
        // TODO 削除 Diff
        if (!operateFlag.get()) {
          oldMap.keySet().forEach(fieldName -> {
            // 変更後のデータフィールドはデフォルトでnullになり、差分されます
            Object afterData = null;
            // 削除前データ
            Object oldData = oldMap.get(fieldName);
            // 削除差分すべてのデータ
            if (checkDiff(afterData, oldData)) {
              tableInfoList.stream()
                .filter(updateLogInfo -> fieldName.equals(toCamelCase(updateLogInfo.getFieldName())))
                .forEach(updateLogInfo -> {
                  updateLogInfo.setBeforeUpdateValue(oldData);
                  updateLogInfo.setAfterUpdateValue(afterData);
                  updateLogInfo.setUpdated(true);
                  // updateLogInfo.setDeleted(true);
                  if (updateLogInfo.isJson()) {
                    try {
                      // フォーマット変換
                      Map<String, Object> map = campareJsonObject(convertString(oldData), convertString(afterData));
                      if (map != null && map.size() > 0) {
                        // JSONデータ内容複雑比較，差異化データを返す
                        List<JsonCompareInfo> list = this.getJsonCompareObject(map, updateLogInfo);
                        updateLogInfo.setJsonUpdatedlist(list);
                      }
                    } catch (JSONException e) {
                      System.err.println(e.toString());
                    }
                  }
                });
            }
          });
        }
        // 更新としてマークされたフィールド値のフィルタ
        List<UpdateLogInfo> filterLogInfo = tableInfoList.stream()
          .filter(UpdateLogInfo::isUpdated)
          .collect(Collectors.toList());
        // log出力
        this.logOutput(filterLogInfo, beforeResults, false);
      }
      //TODO 新规 Diff
      for (Map<String, Object> newMap : afterResults) {
        operateFlag.set(false);
        beforeResults.stream()
          // テーブルキーでマッピングして、データを絞り、主キーあれば、一件のはず
          .filter(oldMap -> oldEquelsNew(keyColList, newMap, oldMap)).forEach(filterNewMap -> {
          operateFlag.set(true);
        });
        if (!operateFlag.get()) {
          newMap.keySet().forEach(fieldName -> {
            // 新規に更新前データがないので、デフォルトのnullを設定します（後に対nullの処理判定ロジックがあります）
            Object beforeData = null;
            // 新规データ
            Object newData = newMap.get(fieldName);
            // 新规差分すべてのデータ
            if (checkDiff(newData, beforeData)) {
              tableInfoList.stream()
                .filter(updateLogInfo -> fieldName.equals(toCamelCase(updateLogInfo.getFieldName())))
                .forEach(updateLogInfo -> {
                  updateLogInfo.setBeforeUpdateValue(beforeData);
                  updateLogInfo.setAfterUpdateValue(newData);
                  updateLogInfo.setUpdated(true);
                  if (updateLogInfo.isJson()) {
                    try {
                      // フォーマット変換
                      Map<String, Object> map = campareJsonObject(convertString(beforeData), convertString(newData));
                      if (map != null && map.size() > 0) {
                        // JSONデータ内容複雑比較，差異化データを返す
                        List<JsonCompareInfo> list = this.getJsonCompareObject(map, updateLogInfo);
                        updateLogInfo.setJsonUpdatedlist(list);
                      }
                    } catch (JSONException e) {
                      System.err.println(e.toString());
                    }
                  }
                });
            }
          });
          // 更新としてマークされたフィールド値のフィルタ
          List<UpdateLogInfo> filterLogInfo = tableInfoList.stream()
            .filter(UpdateLogInfo::isUpdated)
            .collect(Collectors.toList());
          // log出力
          this.logOutput(filterLogInfo, afterResults, true);
        }
      }
    }
  }


  /**
   * log出力
   *
   * @param filterLogInfo
   * @param results
   * @param isInsert
   */
  private void logOutput(List<UpdateLogInfo> filterLogInfo, List<Map<String, Object>> results, boolean isInsert) {
    boolean isDel = false;
    List<DataUpdateLogInfoEntity> logForJsonList = new ArrayList<>();
    List<DataUpdateLogInfoEntity> logNoJsonList = new ArrayList<>();
    for (int i = 0; i < results.size(); i++) {
      // ループ　ログ出力
      for (Object info : filterLogInfo) {
        UpdateLogInfo outputInfo = (UpdateLogInfo) info;
        // up or del
        if (!isInsert) {
          if ((convertString(outputInfo.getFieldName()).indexOf("is_del") >= 0 &&
            "0".equals(outputInfo.getBeforeUpdateValue()) &&
            "1".equals(outputInfo.getAfterUpdateValue()))
            || (convertString(outputInfo.getFieldName()).indexOf("is_disp") >= 0 &&
            "1".equals(outputInfo.getBeforeUpdateValue()) &&
            "0".equals(outputInfo.getAfterUpdateValue()))
            // || outputInfo.isDeleted()
          ) {
            isDel = true;
          }
          // ビジネスに関係のないデータの変更をフィルタリングする
          if (convertString(outputInfo.getFieldName()).indexOf("up_date") >= 0 ||
            convertString(outputInfo.getFieldName()).indexOf("reg_date") >= 0) {
            continue;
          }
        }
        // eventlog作成
        EventLogMessage eventLogMessage = new EventLogMessage();
        // 患者ID
        String patId = DataUpdateLogInfoUtil.getPatId(results);
        // 施设code
        String facilityCd = DataUpdateLogInfoUtil.getFacilityCd(results);
        // 利用者ID
        String userId = DataUpdateLogInfoUtil.getUserId(results);
        // InvokeClass
        eventLogMessage.setInvokeClass(this.getClass().getName());

        if (StringUtils.isEmpty(eventLogMessage.getPatId())) {
          eventLogMessage.setPatId(patId);
        }
        if (StringUtils.isEmpty(eventLogMessage.getFacilityCd())) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
        if (StringUtils.isEmpty(eventLogMessage.getUserId())) {
          eventLogMessage.setUserId(userId);
        }
        // JSONと非JSONの処理パッケージロジック
        if (!outputInfo.isJson()) {
          if (!outputInfo.isUpdated()) {
            continue;
          }
          DataUpdateLogInfoEntity entity = new DataUpdateLogInfoEntity();
          entity.setEventLogMessage(eventLogMessage);
          entity.setOutputInfo(outputInfo);
          logNoJsonList.add(entity);
        } else {
          DataUpdateLogInfoEntity entity = new DataUpdateLogInfoEntity();
          entity.setEventLogMessage(eventLogMessage);
          entity.setOutputInfo(outputInfo);
          logForJsonList.add(entity);
        }
      }
    }
    List<EventLogMessage> eventLogMessageList = new ArrayList<>();
    // 通常フィールドタイプとJSONフィールドタイプは別々に処理される
    if (!logNoJsonList.isEmpty()) {
      this.outputDataAccessLogNoJsonToBatch(eventLogMessageList, logNoJsonList, this.logServiceCore, isDel, isInsert);
    }
    if (!logForJsonList.isEmpty()) {
      this.outputDataAccessLogForJsonToBatch(eventLogMessageList, logForJsonList, this.logServiceCore, isDel, isInsert);
    }
    // 異なる処理をマージして一括書込み
    if (!eventLogMessageList.isEmpty()) {
      // 通常フィールドとJSONフィールドを並べて、mongoに一括書込み
      this.logToBatch(LogLevel.INFO, eventLogMessageList, "", "", "", null);
    }
  }


  /**
   * Jsonオブジェクト変換
   *
   * @param oldJsonStr 更新前データ
   * @param newJsonStr 更新後データ
   * @return 更新前後データのマージ結果
   * @throws JSONException
   */
  public Map<String, Object> campareJsonObject(String oldJsonStr, String newJsonStr) throws JSONException {
    if ("".equals(oldJsonStr)) {
      oldJsonStr = "[]";
    }
    if ("".equals(newJsonStr)) {
      newJsonStr = "[]";
    }
    boolean isJsonArray = false;
    boolean isJson = false;
    Map<String, Object> oldMap = new LinkedHashMap<>();
    Map<String, Object> newMap = new LinkedHashMap<>();
    Map<String, Object> differenceMap = null;
    JSONArray oldJsonArray = null;
    JSONArray newJsonArray = null;
    JSONObject oldJson = null;
    JSONObject newJson = null;
    try {
      oldJsonArray = new JSONArray(oldJsonStr);
      newJsonArray = new JSONArray(newJsonStr);
      isJsonArray = true;
    } catch (Exception e) {
      isJsonArray = false;
    }
    try {
      oldJson = new JSONObject(oldJsonStr);
      newJson = new JSONObject(newJsonStr);
      isJson = true;
    } catch (Exception e) {
      isJson = false;
    }
    if (isJsonArray) {
      convertJsonToMap(oldJsonArray, BLANK, oldMap);
      convertJsonToMap(newJsonArray, BLANK, newMap);
      differenceMap = campareMap(oldMap, newMap);
    } else {
      if (isJson) {
        convertJsonToMap(oldJson, BLANK, oldMap);
        convertJsonToMap(newJson, BLANK, newMap);
        differenceMap = campareMap(oldMap, newMap);
      }
    }
    return differenceMap;
  }

  /**
   * 新旧比較
   *
   * @param oldMap 更新前データ
   * @param newMap 更新後データ
   * @return 比較した結果
   */
  private static Map<String, Object> campareMap(Map<String, Object> oldMap, Map<String, Object> newMap) {
    campareNewToOld(oldMap, newMap);
    campareOldToNew(oldMap);
    return oldMap;
  }


  /**
   * 新旧比較
   *
   * @param oldMap 更新前データ
   */
  private static void campareOldToNew(Map<String, Object> oldMap) {
    for (Iterator<Map.Entry<String, Object>> it = oldMap.entrySet().iterator(); it.hasNext(); ) {
      Map.Entry<String, Object> item = it.next();
      String key = item.getKey();
      Object value = item.getValue();
      if (!(value instanceof Map)) {
        Map<String, Object> differenceMap = new HashMap<>();
        differenceMap.put("oldValue", value);
        differenceMap.put("newValue", BLANK);
        oldMap.put(key, differenceMap);
      }
    }
  }

  /**
   * 新旧比較
   *
   * @param oldMap 更新前データ
   * @param newMap 更新後データ
   */
  private static void campareNewToOld(Map<String, Object> oldMap, Map<String, Object> newMap) {
    for (Iterator<Map.Entry<String, Object>> it = newMap.entrySet().iterator(); it.hasNext(); ) {
      Map.Entry<String, Object> item = it.next();
      String key = item.getKey();
      Object newValue = item.getValue();
      Map<String, Object> differenceMap = new HashMap<>();
      if (oldMap.containsKey(key)) {
        Object oldValue = oldMap.get(key);
        if (newValue.equals(oldValue)) {
          oldMap.remove(key);
          continue;
        } else {
          differenceMap.put("oldValue", oldValue);
          differenceMap.put("newValue", newValue);
          oldMap.put(key, differenceMap);
        }
      } else {
        differenceMap.put("oldValue", BLANK);
        differenceMap.put("newValue", newValue);
        oldMap.put(key, differenceMap);
      }
    }
  }


  /**
   * JsonからMapに変換する
   *
   * @param json      jsonデータ
   * @param root      ルートキー
   * @param resultMap 結果
   */
  private void convertJsonToMap(Object json, String root, Map<String, Object> resultMap) {
    if (json instanceof JSONObject) {
      JSONObject jsonObject = ((JSONObject) json);
      Iterator iterator = jsonObject.keySet().iterator();
      while (iterator.hasNext()) {
        String key = convertString(iterator.next());
        Object value = jsonObject.get(key);
        String newRoot = BLANK.equals(root) ? key + BLANK : root + "." + key;
        if (value instanceof JSONObject || value instanceof JSONArray) {
          convertJsonToMap(value, newRoot, resultMap);
        } else {
          resultMap.put(newRoot, value);
        }
      }
    } else if (json instanceof JSONArray) {
      JSONArray jsonArray = (JSONArray) json;
      for (int i = 0; i < jsonArray.length(); i++) {
        Object vaule = jsonArray.get(i);
        String newRoot = BLANK.equals(root) ? "[" + i + "]" : root + ".[" + i + "]";
        if (vaule instanceof JSONObject || vaule instanceof JSONArray) {
          convertJsonToMap(vaule, newRoot, resultMap);
        } else {
          resultMap.put(newRoot, vaule);
        }
      }
    }
  }

  /**
   * &&と同様、主キーリストの主キーに該当する更新前後の値を差分チェックする
   *
   * @param tableKeyList テーブルの主キーリスト
   * @param oldMap       更新前データMap
   * @param newMap       更新後データMap
   * @return boolean (すべて一致の場合 -> true、いずれか一致じゃない場合 -> false)
   */
  public static boolean oldEquelsNew(
    List<String> tableKeyList,
    Map<String, Object> oldMap,
    Map<String, Object> newMap) {
    boolean result = true;
    if (tableKeyList != null && tableKeyList.size() > 0) {
      for (String s : tableKeyList) {
        String ss = toCamelCase(String.valueOf(s).contains("_") ? String.valueOf(s) : "");
        Object om = oldMap.get(ss) != null ? oldMap.get(ss) : "om";
        Object nm = newMap.get(ss) != null ? newMap.get(ss) : "nm";
        result = om.equals(nm);
        if (!result) {
          break;
        }
      }
    }
    return result;
  }


  /**
   * 差分チェック
   */
  private boolean checkDiff(Object newData, Object oldData) {
    if (newData == null) {
      return oldData != null;
    } else {
      if (oldData == null) {
        return true;
      }
      return !newData.equals(oldData);
    }
  }


  /**
   * Jsonデータを比較する
   *
   * @param map        map
   * @param outputInfo outputInfo
   * @return list
   */
  private List<JsonCompareInfo> getJsonCompareObject(Map<String, Object> map, UpdateLogInfo outputInfo) {
    List<JsonCompareInfo> list = new ArrayList<JsonCompareInfo>();
    map.keySet().forEach(key -> {
      Map<String, Object> value = (Map<String, Object>) map.get(key);
      JsonCompareInfo jsonCompareInfo = new JsonCompareInfo();
      if (outputInfo.getKeyStep() == 1) {
        jsonCompareInfo.setKey(getKeyWithStep(key, 0));
      } else {
        jsonCompareInfo.setKey(getKeyWithParent(key));
      }
      jsonCompareInfo.setOldValue(convertString(value.get("oldValue")));
      jsonCompareInfo.setNewValue(convertString(value.get("newValue")));
      jsonCompareInfo.setTableName(outputInfo.getTableName());
      jsonCompareInfo.setColName(outputInfo.getFieldName());
      jsonCompareInfo.setKeyComment(getKeyComment(jsonCompareInfo));
      if (!isEqual(jsonCompareInfo.getOldValue(), jsonCompareInfo.getNewValue())) {
        list.add(jsonCompareInfo);
      }
    });
    return list;
  }

  /**
   * Jsonキーのコメントを取得する
   *
   * @param jsonCompareInfo Json情報
   * @return Jsonキーのコメント
   */
  private String getKeyComment(JsonCompareInfo jsonCompareInfo) {
    String key = new StringBuilder().append(jsonCompareInfo.getTableName()).append("-")
      .append(jsonCompareInfo.getColName()).append("-").append(jsonCompareInfo.getKey()).toString();
    /* del by chamaojia 2024-08-13 [10959] delete unnecessary variables for use --start */
    // if (keyCommentMap.containsKey(key)) {
    //   return keyCommentMap.get(key);
    // }
    /* del by chamaojia 2024-08-13 [10959] delete unnecessary variables for use --end */
    SelectBuilder selectBuilder = SelectBuilder.newInstance(getDbConfig());
    selectBuilder.sql(" SELECT ");
    selectBuilder.sql(" tbl_name, ");
    selectBuilder.sql(" col_name, ");
    selectBuilder.sql(" json_key_name, ");
    selectBuilder.sql(" json_key_comment ");
    selectBuilder.sql(" FROM ");
    selectBuilder.sql(" log_json_comment ");
    selectBuilder.sql(" WHERE ");
    selectBuilder.sql(" tbl_name = '" + jsonCompareInfo.getTableName() + "' ");
    selectBuilder.sql(" AND col_name = '" + jsonCompareInfo.getColName() + "' ");
    selectBuilder.sql(" AND json_key_name = '" + jsonCompareInfo.getKey() + "' ");
    // Select文の実行
    List<Map<String, Object>> results = executeSql(selectBuilder);
    // 結果がゼロ件の場合、楽観的排他エラーをスロー
    if (results.isEmpty()) {
      return "";
    }
    Map<String, Object> map = results.get(0);
    String result = convertString(map.get("json_key_comment"));
    /* del by chamaojia 2024-08-13 [10959] delete unnecessary variables for use --start */
    // keyCommentMap.put(key, result);
    /* del by chamaojia 2024-08-13 [10959] delete unnecessary variables for use --end */
    return result;
  }


  public static String toCamelCase(String underscoreString) {
    StringBuilder result = new StringBuilder();
    boolean capitalizeNext = false;

    for (int i = 0; i < underscoreString.length(); i++) {
      char currentChar = underscoreString.charAt(i);

      if (currentChar == '_') {
        capitalizeNext = true;
      } else {
        if (capitalizeNext) {
          result.append(Character.toUpperCase(currentChar));
          capitalizeNext = false;
        } else {
          result.append(Character.toLowerCase(currentChar));
        }
      }
    }
    return result.toString();
  }

  /**
   * パスワード含むかどうか
   *
   * @param str コラム名
   * @return true: 含む false: 含まない
   */
  private static boolean isContainPassword(String str) {
    if (StringUtils.isEmpty(str)) {
      return false;
    }
    if (str.indexOf("user_password") >= 0) {
      return true;
    }
    return false;
  }

  /**
   * パスワードから[*]に変換する
   *
   * @param pass パスワード
   * @return 変換後パスワード
   */
  private static String passwordConvert(String pass) {
    if (StringUtils.isEmpty(pass)) {
      return "";
    }
    String newPass = "";
    for (int i = 0; i < pass.length(); i++) {
      newPass += "*";
    }
    return newPass;
  }

  /**
   * データ変更ログを出力する(JSON以外)
   *
   * @param entityList
   * @param logServiceCore
   * @param isDel
   */
  public void outputDataAccessLogNoJsonToBatch(List<EventLogMessage> eventLogMessageList, List<DataUpdateLogInfoEntity> entityList,
                                               LogServiceCore logServiceCore, boolean isDel, boolean isInsert) {
    for (DataUpdateLogInfoEntity entity : entityList) {
      if (isContainPassword(entity.getOutputInfo().getFieldName())) {
        entity.getOutputInfo().setBeforeUpdateValue(passwordConvert(convertString(entity.getOutputInfo().getBeforeUpdateValue())));
        entity.getOutputInfo().setAfterUpdateValue(passwordConvert(convertString(entity.getOutputInfo().getAfterUpdateValue())));
      }
      String logMessage = "";

      List<TableFlagConfig> tableFlagConfigListBefor = new ArrayList<>();
      List<TableFlagConfig> tableFlagConfigListAfter = new ArrayList<>();
      // List<TableFlagConfig> tableFlagConfigList = logServiceCore.getTableFlagConfigList();
      //jsonFlagのデータをフィルタリングする
      // if (tableFlagConfigList != null && tableFlagConfigList.size() > 0) {
      //   tableFlagConfigList = tableFlagConfigList.stream().filter(f -> (!f.getTblName().contains(".")
      //     && "0".equals(f.getJsonFlg()))).distinct().collect(Collectors.toList());
      //   //マッチングが必要な条件には、tblName、colName、flagValueがあり、マッチングが成功した後に1つだけ保証されます。
      //   //befor
      //   tableFlagConfigListBefor = tableFlagConfigList.stream()
      //     .filter(f -> (f.getTblName().equals(convertString(entity.getOutputInfo().getTableName()))
      //       && f.getColName().equals(convertString(entity.getOutputInfo().getFieldName()))
      //       && f.getFlagValue().equals(convertString(entity.getOutputInfo().getBeforeUpdateValue()))))
      //     .distinct().collect(Collectors.toList());
      //   //after
      //   tableFlagConfigListAfter = tableFlagConfigList.stream()
      //     .filter(f -> (f.getTblName().equals(convertString(entity.getOutputInfo().getTableName()))
      //       && f.getColName().equals(convertString(entity.getOutputInfo().getFieldName()))
      //       && f.getFlagValue().equals(convertString(entity.getOutputInfo().getAfterUpdateValue()))))
      //     .distinct().collect(Collectors.toList());
      // }
      //tableFlagConfigListBeforとtableFlagConfigListAfterの両方が1つの場合にのみ変換が必要と判断
      if (tableFlagConfigListBefor.size() == 1 && tableFlagConfigListAfter.size() == 1) {
        String befor = tableFlagConfigListBefor.get(0).getFlagComment();
        String after = tableFlagConfigListAfter.get(0).getFlagComment();
        // どのメッセージテンプレートを使用するかを判断する
        if (isInsert) {
          logMessage = String.format(LOG_MESSAGE_NO_JSON_INSERT,
            entity.getOutputInfo().getTableName(),
            entity.getOutputInfo().getFieldComment(),
            after);
        } else if (isDel) {
          logMessage = String.format(LOG_MESSAGE_NO_JSON_DELETE,
            entity.getOutputInfo().getTableName(),
            entity.getOutputInfo().getFieldComment(),
            befor);
        } else {
          logMessage = String.format(LOG_MESSAGE_NO_JSON,
            entity.getOutputInfo().getTableName(),
            entity.getOutputInfo().getFieldComment(),
            befor, after);
        }
      } else { //コード変換不要メッセージ作成
        // どのメッセージテンプレートを使用するかを判断する
        if (isInsert) {
          logMessage = String.format(LOG_MESSAGE_NO_JSON_INSERT,
            entity.getOutputInfo().getTableName(),
            entity.getOutputInfo().getFieldComment(),
            convertString(entity.getOutputInfo().getAfterUpdateValue()));
        } else if (isDel) {
          logMessage = String.format(LOG_MESSAGE_NO_JSON_DELETE,
            entity.getOutputInfo().getTableName(),
            entity.getOutputInfo().getFieldComment(),
            convertString(entity.getOutputInfo().getBeforeUpdateValue()));
        } else {
          logMessage = String.format(LOG_MESSAGE_NO_JSON, entity.getOutputInfo().getTableName(),
            entity.getOutputInfo().getFieldComment(),
            convertString(entity.getOutputInfo().getBeforeUpdateValue()),
            convertString(entity.getOutputInfo().getAfterUpdateValue()));
        }
      }
      entity.getEventLogMessage().setLogMessage(logMessage);
      entity.getEventLogMessage().setEc2Identification(LogObjectUtils.getHostAddress());
      entity.getEventLogMessage().setFunctionName(entity.getOutputInfo().getTableComment());
      // 削除かどうかを判定し、削除であれば1つのメッセージのみをmongoDBに出力することを確認する
      eventLogMessageList.add(entity.getEventLogMessage());
    }
  }

  /**
   * Mongo一括挿入
   *
   * @param logType
   * @param evmList
   * @param functionCode
   * @param moduleName
   * @param serviceName
   * @param sqlFilePath
   */
  public void logToBatch(LogLevel logType, List<EventLogMessage> evmList, String functionCode, String moduleName, String serviceName,
                         String sqlFilePath) {
    try {
      List<LogEvent> logEventList = new ArrayList<>();
      for (EventLogMessage eventLogMessage : evmList) {
        // SQL名
        if (sqlFilePath != null && eventLogMessage.getSqlIdentification() != null) {
          try {
            String sqlData = LogObjectUtils.readSqlFile(sqlFilePath);
            sqlData += " | " + eventLogMessage.getSqlIdentification();
            eventLogMessage.setSqlIdentification(sqlData);
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
            EventLogMessage eventLogMessageNew = new EventLogMessage();
            eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
            logServiceCore.log(LogLevel.ERROR, eventLogMessageNew, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
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
        logEventList.add(LogEventUtil.getLogEvent(LogLevel.INFO.name(), eventLogMessage));
      }
      if (!logEventList.isEmpty()) {
        this.createToBatch(logType, logEventList);
      }
    } catch (Exception e) {
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
   * 内部患者IDによって、患者IDを取得する
   *
   * @return
   */
  private void initLogEvent(LogEvent event) {
    if (event.getHospPatId() == null) {
      event.setHospPatId("");
    }
    if (event.getFunctionName() == null) {
      event.setFunctionName("");
    }
    if (event.getFacilityName() == null) {
      event.setFacilityName("");
    }
    if (event.getUsername() == null) {
      event.setUsername("");
    }
    if (event.getPatName() == null) {
      event.setPatName("");
    }
  }

  /**
   * 患者名取得する
   *
   * @param patId
   */
  private PatPersonalMain getPatName(String patId) {
    if (!StringUtils.isEmpty(patId)) {
      List patIdList = new ArrayList();
      patIdList.add(patId);
      List<PatPersonalMain> listPatPersonal = patPersonalMainDao.selectByIdList(patIdList);
      if (listPatPersonal != null && listPatPersonal.size() > 0) {
        PatPersonalMain pat = listPatPersonal.get(0);
        return pat;
      }
    }
    return null;
  }

  /**
   * Encryptデータ取得
   *
   * @param inData 抽出条件
   * @return
   */
  public String getPersonalInfoEncrypt(String inData) {
    if (StringUtils.isEmpty(inData)) {
      return "";
    }
    String returnValue = "";
    Config config = personalDbConfig;
    SelectBuilder selectBuilder = SelectBuilder.newInstance(config);
    selectBuilder.sql("select personal_info_encrypt('" + inData + "') as encrypt_value");
    List<Map<String, Object>> results = selectBuilder.getMapResultList(MapKeyNamingType.NONE);

    if (results.isEmpty()) {
      return "";
    }

    for (Map<String, Object> result : results) {
      returnValue = convertString(result.get("encrypt_value"));
      break;
    }

    return returnValue;
  }

  /**
   * ユーザ名取得する
   *
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
   * 機能名取得
   *
   * @param funCd 機能コード
   * @return 機能名
   */
  private String getFunctionName(String funCd) {
    if (!StringUtils.isEmpty(funCd)) {
      SysFunction function = sysFunctionDao.selectByFunctionCd(funCd);
      if (function != null) {
        return nullToSpace(function.getFunctionName());
      }
    }
    return "";
  }

  /**
   * 施設名取得する
   *
   * @param facilityCd
   */
  private String getFacilityName(String facilityCd) {
    if (!StringUtils.isEmpty(facilityCd)) {
      List listFacilityCds = new ArrayList();
      listFacilityCds.add(facilityCd);
      List<MstFacility> listFacility = mstFacilityDao.selectByFacilityCds(listFacilityCds);
      if (listFacility != null && listFacility.size() > 0) {
        MstFacility mstFacility = listFacility.get(0);
        if (mstFacility != null) {
          return nullToSpace(mstFacility.getFacilityName());
        }
      }
    }
    return "";
  }


  /**
   * 登陆MongoDB
   *
   * @param logType
   * @param logEventList
   */
  public void createToBatch(LogLevel logType, List<LogEvent> logEventList) {
    if (logType == LogLevel.DEBUG) {
      return;
    }
    Map<String, PatPersonalMain> patPersonalMainMap = new HashMap<>();
    Map<String, String> userMap = new HashMap<>();
    Map<String, String> facilityCdMap = new HashMap<>();
    Map<String, String> functionNameMap = new HashMap<>();
    Map<String, String> functionCdMap = new HashMap<>();
    List<LogEvent> logEventSaveList = new ArrayList<>();
    for (LogEvent params : logEventList) {
      // ログ出力タイムスタンプ
      params.setLogDate(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date()));
      initLogEvent(params);

      try {
        // 患者IDと患者名取得
        if (!StringUtils.isEmpty(params.getPatId())) {
          if (patPersonalMainMap.containsKey(params.getPatId())) {
            if (patPersonalMainMap.get(params.getPatId()) != null) {
              params.setPatName(patPersonalMainMap.get(params.getPatId()).getPat_last_name());
              params.setHospPatId(patPersonalMainMap.get(params.getPatId()).getHosp_pat_id());
            }
          } else {
            PatPersonalMain pat = getPatName(params.getPatId());
            if (pat != null) {
              params.setPatName(getPersonalInfoEncrypt(nullToSpace(pat.getPat_last_name()) + " " + nullToSpace(pat.getPat_first_name())));
              params.setHospPatId(nullToSpace(pat.getHosp_pat_id()));

              pat.setPat_last_name(params.getPatName());
              pat.setHosp_pat_id(params.getHospPatId());
              patPersonalMainMap.put(params.getPatId(), pat);
            } else {
              patPersonalMainMap.put(params.getPatId(), null);
            }
          }
        }

        if ("-1".equals(params.getUserId())) {
          String dispUserId = "ScalApp4";
          String userAuthenticationUserId = mstUserAuthenticationDao.selectUserIdByFacilityCd(dispUserId, params.getFacilityCd());
          params.setUsername(getPersonalInfoEncrypt(getUsername(userAuthenticationUserId)));
          params.setUserId(userAuthenticationUserId);
          if (!"".equals(userAuthenticationUserId)) {
            params.setUsername(getPersonalInfoEncrypt("体重計App ユーザー"));
          } else {
            params.setUsername(getPersonalInfoEncrypt(getUsername(userAuthenticationUserId)));
            params.setUserId(userAuthenticationUserId);
          }
        } else if (!StringUtils.isEmpty(params.getUserId())) {
          if (userMap.containsKey(params.getUserId())) {
            params.setUsername(userMap.get(params.getUserId()));
          } else {
            params.setUsername(getPersonalInfoEncrypt(getUsername(params.getUserId())));
            userMap.put(params.getUserId(), params.getUsername());
          }
        }
        // ユーザ名取得
        if (!StringUtils.isEmpty(params.getFacilityCd())) {
          if (facilityCdMap.containsKey(params.getFacilityCd())) {
            params.setFacilityName(facilityCdMap.get(params.getFacilityCd()));
          } else {
            params.setFacilityName(getPersonalInfoEncrypt(getFacilityName(params.getFacilityCd())));
            facilityCdMap.put(params.getFacilityCd(), params.getFacilityName());
          }
        }
        // 機能名取得
        if (!StringUtils.isEmpty(params.getFuncCd())) {
          if (functionCdMap.containsKey(params.getFuncCd())) {
            params.setFunctionName(functionCdMap.get(params.getFuncCd()));
          } else {
            params.setFunctionName(getPersonalInfoEncrypt(getFunctionName(params.getFuncCd())));
            functionCdMap.put(params.getFuncCd(), params.getFunctionName());
          }
        }
        if (!StringUtils.isEmpty(params.getFunctionName()) && StringUtils.isEmpty(params.getFuncCd())) {
          if (functionNameMap.containsKey(params.getFunctionName())) {
            if (functionNameMap.get(params.getFunctionName()) != null) {
              params.setFuncCd(functionNameMap.get(params.getFunctionName()));
            }
          } else {
            SysFunction sysFunction = sysFunctionDao.selectByFunctionName(params.getFunctionName());
            if (sysFunction != null) {
              params.setFuncCd(sysFunction.getFunctionCd());
              functionNameMap.put(params.getFunctionName(), params.getFuncCd());
            } else {
              functionNameMap.put(params.getFunctionName(), null);
            }
          }
        }
      } catch (Exception e) {
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
      logEventSaveList.add(params);
    }
    // メッセージ情報を1つにまとめて、mongoDBに書き込みます
    List<LogEvent> saveList = new ArrayList<>();
    StringBuffer stringBuffer = new StringBuffer();
    boolean isWrite = false;
    LogEvent logEventNew = new LogEvent();
    for (LogEvent logEvent : logEventSaveList) {
      if (!isWrite) {
        logEventNew = logEvent;
        isWrite = true;
      }
      stringBuffer.append(logEvent.getMessage());
      stringBuffer.append(identifyOperatingSystemTypes());
    }
    logEventNew.setMessage(stringBuffer.toString());
    saveList.add(logEventNew);
    if (!saveList.isEmpty()) {
      // 分割非同期書き込みmongo
      CompletableFuture.runAsync(() -> {
        try {
          if (MongoHealthCheckService.getMongoDBConnected())
            mongoTemplate.bulkOps(BulkOperations.BulkMode.ORDERED, LogEvent.class).insert(saveList).execute();
        } catch (DataAccessResourceFailureException exception) {
          MongoHealthCheckService.setMongoDBConnected(false);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
          logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
        }
      });
    }
  }

  /**
   * OSタイプの識別,異なる改行文字を返す
   * { Windows：\r\n，Linux：\n，Mac：\n，その他のオペレーティングシステム：\n}
   *
   * @return
   */
  private String identifyOperatingSystemTypes() {
    String osName = System.getProperty("os.name");
    if (osName.toLowerCase().contains("windows")) {
      return "\r\n";
    } else if (osName.toLowerCase().contains("linux")) {
      return "\n";
    } else if (osName.toLowerCase().contains("mac")) {
      return "\n";
    } else {
      return "\n";
    }
  }


  /**
   * JSON特殊データ手動暗号化
   *
   * @param jsonCompareInfo
   * @param tableName
   * @param colName
   * @param keyName
   */
  private static void isDecryptJsonValue(JsonCompareInfo jsonCompareInfo, String tableName, String colName, String keyName) {
    if (jsonCompareInfo == null) {
      return;
    }
    if (jsonCompareInfo.getTableName().toLowerCase().equals(tableName) &&
      jsonCompareInfo.getColName().toLowerCase().equals(colName) &&
      jsonCompareInfo.getKey().toLowerCase().indexOf(keyName) >= 0) {
      String decryptOldValue = DataUpdateLogCommonNew.CUT_STR + jsonCompareInfo.getOldValue() + DataUpdateLogCommonNew.CUT_STR;
      String decryptNewValue = DataUpdateLogCommonNew.CUT_STR + jsonCompareInfo.getNewValue() + DataUpdateLogCommonNew.CUT_STR;
      jsonCompareInfo.setOldValue(decryptOldValue);
      jsonCompareInfo.setNewValue(decryptNewValue);
    }
  }

  /**
   * 保険情報Decrypt value 設定
   *
   * @param jsonCompareInfo
   */
  private void setPatInsuranceDecryptJsonValue(JsonCompareInfo jsonCompareInfo) {
    isDecryptJsonValue(jsonCompareInfo, "pat_insurance", "insu_info", "insu_pat_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_insurance", "insu_info", "insu_pat_mark");
    isDecryptJsonValue(jsonCompareInfo, "pat_insurance", "insu_pub_info", "insu_pub_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_insurance", "insu_pub_info", "insu_pub_no");
    isDecryptJsonValue(jsonCompareInfo, "pat_insurance", "insu_pub_info", "insu_pub_pat_no");
  }

  /**
   * 患者基本情報Decrypt value 設定
   *
   * @param jsonCompareInfo
   */
  private void setPatPersonalMainDecryptJsonValue(JsonCompareInfo jsonCompareInfo) {
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "fax");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "tel1");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "tel2");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "memo1");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "memo2");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "e_mail");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "pat_id");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "zip_cd");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "address");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "work_tel");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "last_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "work_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "first_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "work_address");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "is_key_person");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "relation_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "last_name_kana");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "other_contact_info", "first_name_kana");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "fax");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "tel1");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "tel2");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "memo1");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "memo2");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "e_mail");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "zip_cd");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "address");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "work_tel");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "work_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "pat_contact_info", "work_address");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "fax");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "memo1");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "memo2");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "zip_cd");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "address");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "worker_tel");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "company_tel");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "company_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "worker_e_mail");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "worker_last_name");
    isDecryptJsonValue(jsonCompareInfo, "pat_personal_main", "vendor_contact_info", "worker_first_name");
  }

  /**
   * データ変更ログを出力する(JSON対象)
   *
   * @param entityList
   * @param logServiceCore
   * @param isDel
   */
  public void outputDataAccessLogForJsonToBatch(List<EventLogMessage> eventLogMessageList, List<DataUpdateLogInfoEntity> entityList,
                                                LogServiceCore logServiceCore, boolean isDel, boolean isInsert) {
    if (isDel) return;
    for (DataUpdateLogInfoEntity entity : entityList) {
      String logMessage = "";
      List<JsonCompareInfo> list = entity.getOutputInfo().getJsonUpdatedlist();
      if (list == null) {
        continue;
      }
      for (int i = 0; i < list.size(); i++) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        BeanUtils.copyProperties(entity.getEventLogMessage(), eventLogMessage);
        JsonCompareInfo jsonCompareInfo = list.get(i);
        // ビジネスに関係のないデータの変更をフィルタリングする
        if (convertString(jsonCompareInfo.getKey()).indexOf("up_date") >= 0 ||
          convertString(jsonCompareInfo.getKey()).indexOf("reg_date") >= 0
        ) {
          continue;
        }
        if (isContainPassword(jsonCompareInfo.getKey())) {
          jsonCompareInfo.setOldValue(passwordConvert(convertString(jsonCompareInfo.getOldValue())));
          jsonCompareInfo.setNewValue(passwordConvert(convertString(jsonCompareInfo.getNewValue())));
        }
        // 保険情報
        this.setPatInsuranceDecryptJsonValue(jsonCompareInfo);
        // 患者基本情報
        this.setPatPersonalMainDecryptJsonValue(jsonCompareInfo);

        List<TableFlagConfig> tableFlagConfigListBefor = new ArrayList<>();
        List<TableFlagConfig> tableFlagConfigListAfter = new ArrayList<>();
        // List<TableFlagConfig> tableFlagConfigList = logServiceCore.getTableFlagConfigList();
        //出力が必要かどうかを判断するフィールド
        // List<TableFlagConfig> tableFlagConfigListNo = tableFlagConfigList.stream().filter(f -> ("1".equals(f.getIsOutput()))).distinct().collect(Collectors.toList());
        // //現在のフィールドを含む出力不要のものがあるかどうかを再フィルタ
        // tableFlagConfigListNo = tableFlagConfigListNo.stream().filter(f -> (jsonCompareInfo.getKey().equals(f.getColName()))).distinct().collect(Collectors.toList());
        // if (tableFlagConfigListNo.size() > 0) {
        //   continue;
        // }
        // jsonFlag=1のデータを取得する
        // if (tableFlagConfigList != null && tableFlagConfigList.size() > 0) {
        //   tableFlagConfigList = tableFlagConfigList.stream().filter(f -> (f.getTblName().contains(".")
        //     && "1".equals(f.getJsonFlg()))).distinct().collect(Collectors.toList());
        //   //マッチングが必要な条件には、tblName、colName、flagValueがあり、マッチングが成功した後に1つだけ保証されます。
        //   //befor
        //   tableFlagConfigListBefor = tableFlagConfigList.stream()
        //     .filter(f -> (
        //       (jsonCompareInfo.getTableName() + "." + jsonCompareInfo.getColName()).equals(f.getTblName())
        //         && f.getColName().equals(jsonCompareInfo.getKey())
        //         && f.getFlagValue().equals(jsonCompareInfo.getOldValue())))
        //     .distinct().collect(Collectors.toList());
        //   //after
        //   tableFlagConfigListAfter = tableFlagConfigList.stream()
        //     .filter(f -> (
        //       (jsonCompareInfo.getTableName() + "." + jsonCompareInfo.getColName()).equals(f.getTblName())
        //         && f.getColName().equals(jsonCompareInfo.getKey())
        //         && f.getFlagValue().equals(jsonCompareInfo.getNewValue())))
        //     .distinct().collect(Collectors.toList());
        // }
        //tableFlagConfigListBeforとtableFlagConfigListAfterの両方が1つの場合にのみ変換が必要と判断
        if (tableFlagConfigListBefor.size() == 1 && tableFlagConfigListAfter.size() == 1) {
          String befor = tableFlagConfigListBefor.get(0).getFlagComment();
          String after = tableFlagConfigListAfter.get(0).getFlagComment();
          //
          if (isInsert) {
            logMessage = String.format(
              LOG_MESSAGE_FOR_JSON_INSERT,
              entity.getOutputInfo().getTableName(),
              entity.getOutputInfo().getFieldComment(),
              StringUtils.isEmpty(jsonCompareInfo.getKeyComment()) ? jsonCompareInfo.getKey() : jsonCompareInfo.getKeyComment(),
              after);
          } else if (isDel) {
            logMessage = String.format(
              LOG_MESSAGE_FOR_JSON_DELETE,
              entity.getOutputInfo().getTableName(),
              entity.getOutputInfo().getFieldComment(),
              StringUtils.isEmpty(jsonCompareInfo.getKeyComment()) ? jsonCompareInfo.getKey() : jsonCompareInfo.getKeyComment(),
              befor);
          } else {
            logMessage = String.format(
              LOG_MESSAGE_FOR_JSON,
              entity.getOutputInfo().getTableName(),
              entity.getOutputInfo().getFieldComment(),
              StringUtils.isEmpty(jsonCompareInfo.getKeyComment()) ? jsonCompareInfo.getKey() : jsonCompareInfo.getKeyComment(),
              befor,
              after);
          }
        } else { //コード変換不要メッセージ作成
          if (isInsert) {
            logMessage = String.format(
              LOG_MESSAGE_FOR_JSON_INSERT,
              entity.getOutputInfo().getTableName(),
              entity.getOutputInfo().getFieldComment(),
              StringUtils.isEmpty(jsonCompareInfo.getKeyComment()) ? jsonCompareInfo.getKey() : jsonCompareInfo.getKeyComment(),
              convertString(jsonCompareInfo.getNewValue()));
          } else if (isDel) {
            logMessage = String.format(
              LOG_MESSAGE_FOR_JSON_DELETE,
              entity.getOutputInfo().getTableName(),
              entity.getOutputInfo().getFieldComment(),
              StringUtils.isEmpty(jsonCompareInfo.getKeyComment()) ? jsonCompareInfo.getKey() : jsonCompareInfo.getKeyComment(),
              convertString(jsonCompareInfo.getOldValue()));
          } else {
            logMessage = String.format(
              LOG_MESSAGE_FOR_JSON,
              entity.getOutputInfo().getTableName(),
              entity.getOutputInfo().getFieldComment(),
              StringUtils.isEmpty(jsonCompareInfo.getKeyComment()) ? jsonCompareInfo.getKey() : jsonCompareInfo.getKeyComment(),
              convertString(jsonCompareInfo.getOldValue()),
              convertString(jsonCompareInfo.getNewValue()));
          }
        }
        eventLogMessage.setLogMessage(logMessage);
        eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
        eventLogMessage.setFunctionName(entity.getOutputInfo().getTableComment());
        eventLogMessageList.add(eventLogMessage);
      }
    }
  }


  /**
   * 文字列変換する
   *
   * @param obj 文字列
   * @return 変換した文字列
   */
  private static String nullToSpace(String obj) {
    if (obj == null) {
      return "";
    }
    return obj;
  }

}
// add 10601 eventLog共通処理 gjn end
