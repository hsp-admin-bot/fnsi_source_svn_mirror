package jp.co.nikkiso.ntss.core.logevent;

import static java.util.stream.Collectors.toList;
import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.campareJsonObject;
import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.comparePatUniqueJsonObject;
import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.convertString;
import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.getKeyWithParent;
import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.getKeyWithStep;
import static jp.co.nikkiso.ntss.core.logevent.DataUpdateLogInfoUtil.isEqual;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ConcurrentHashMap;

import org.json.JSONException;
import org.seasar.doma.MapKeyNamingType;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.OptimisticLockException;
import org.seasar.doma.jdbc.SqlLogType;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.TransactionStatus;
import org.springframework.transaction.support.DefaultTransactionDefinition;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;

import tools.jackson.core.JacksonException;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.DataUpdateLogInfoEntity;
import jp.co.nikkiso.ntss.core.entity.custom.WaterSurveyPoint;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.JsonCompareInfo;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.OrdMainHisInfo;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.TableCommentInfo;
import jp.co.nikkiso.ntss.core.logevent.commentinfo.UpdateLogInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import lombok.Getter;
import lombok.Setter;

/**
 * データ更新ログ共通クラス
 * wang zuo
 */
public class DataUpdateLogCommonNew {
  //#8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-03-11 start
  @Getter
  @Setter
  private Boolean hasData=false;
  //#8353 外部連携稼働ビューアからのAPI呼び出しに失敗する 卓 2023-03-11 end
  @Setter
  EventLoggerFactory eventLoggerFactory;

  @Setter
  LogServiceCore logServiceCore;
  /**
   * 更新テーブル物理名
   */
  @Setter
  private String tableName;

  /**
   * 検索SQL文
   */
  @Setter
  private SelectBuilder searchSQL;

  /**
   * 検索SQL条件
   */
  @Setter
  private StringBuffer whereStr;

  /**
   * メッセージ
   */
  @Setter
  private EventLogMessage commonEventLogMessage;

  /**
   * 検索用インタフェース
   */
  @Setter
  private Config config;

  @Setter
  private Config defaultDbConfig;

  @Setter
  private Object daoObject;
  // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou start
  @Setter
  private String limit;
  // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou end
  /**
   * 検索結果格納
   */
  private List<Map<String, Object>> beforeResults;

  /**
   * 更新後検索結果格納
   */
  private List<Map<String, Object>> afterResults;

  private ConcurrentHashMap concurrentHashMap = new ConcurrentHashMap();
  /**
   * カラム情報格納
   */
  Map<String, List<String>> fieldListMap = new HashMap<>();

  /**
   * log_json_commentテーブルデータ一時キャッシュmap
   */
  Map<String, String> keyCommentMap = new HashMap<>();

  /**
   * テーブル情報格納
   */
  List<UpdateLogInfo> tableInfoList = new ArrayList<>();

  final List<String> fieldNameList = Arrays.asList(
    "pat_last_name",
    "pat_first_name",
    "pat_last_name_kana",
    "pat_first_name_kana",
    "pat_last_name_alpha",
    "pat_first_name_alpha",
    "pat_birth_name",
    "pat_birth_name_kana",
    "pat_birth_name_alpha",
    "remote_monitor_user_id",
    "user_last_name",
    "user_first_name",
    "user_last_name_kana",
    "user_first_name_kana",
    "user_last_name_alpha",
    "user_first_name_alpha",
    "user_email_address_1",
    "user_email_address_2",
    "extension_no",
    "home_no",
    "mobile_phone_no",
    "fax_no",
    "zipcd_3",
    "zipcd_4",
    "address",
    "address_kana",
    "job_cd",
    "anesthesiologist_license_no",
    "insu_pub_no",
    "insu_pub_pat_no",
    "insu_no",
    "insu_pat_mark",
    "insu_pat_no",
    "insu_dr_name",
    "insu_dr_sign",
    "remarks_anesthesia",
    "remarks_free",
    "pat_last_name"
    );

  final List<String> tableNameList = Arrays.asList(
    "pat_personal_main",
    "mst_personal_user",
    "ord_personal_prescription"
  );

  public static final String CUT_STR = "#!#!#!#";

  /**
   * ログ出力カラム情報及び更新前データ情報取得
   */
  public boolean setInfo() {
    try {
      if (Objects.isNull(concurrentHashMap.get(this.tableName))) {
        // ログ出力カラム情報取得
        this.getFieldCommentInfo();
      }
      // テーブルキーない場合、ログ出力不要
      if (CollectionUtils.isEmpty(this.fieldListMap.get("keyColList"))) {
        return false;
      }
      // ログ出力カラムない場合、ログ出力不要。ログ出力カラムの有無（あり->true,なし->false）
      if (CollectionUtils.isEmpty(this.fieldListMap.get("logFieldColList"))) {
        return false;
      }
      this.getSql();
      // 更新前データ取得
      return getBeforeData();
    } catch (Exception e) {
      return false;
    }
  }
  //add 8344【デグレ】チェックリストマスタの保存までが長い zhao end
  public boolean setInfoLimit() {
    try {
      if (Objects.isNull(concurrentHashMap.get(this.tableName))) {
        // ログ出力カラム情報取得
        this.getFieldCommentInfo();
      }
      // テーブルキーない場合、ログ出力不要
      if (CollectionUtils.isEmpty(this.fieldListMap.get("keyColList"))) {
        return false;
      }
      // ログ出力カラムない場合、ログ出力不要。ログ出力カラムの有無（あり->true,なし->false）
      if (CollectionUtils.isEmpty(this.fieldListMap.get("logFieldColList"))) {
        return false;
      }
      this.getSqlLimit();
      // 更新前データ取得
      return getBeforeData();
    } catch (Exception e) {
      return false;
    }
  }
  //add 8344【デグレ】チェックリストマスタの保存までが長い zhao end

  /**
   * テーブル情報設定
   */
  private void getFieldCommentInfo() {
    List<TableCommentInfo> commentInfos = getAllFieldComment();

    concurrentHashMap.put(this.tableName, commentInfos);

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
        // DB更新ログ出力ロジック xie Start
        outputInfo.setOrdMainHstInsFlg(tableCommentInfo.getOrdMainHstInsFlg());
        // DB更新ログ出力ロジック xie End
        this.tableInfoList.add(outputInfo);
      }

      for (int i = 0; i< tableInfoList.size(); i++) {
        UpdateLogInfo outputInfo = tableInfoList.get(i);
      }
    });
    this.fieldListMap.put("keyColList", keyColList);
    this.fieldListMap.put("logFieldColList", logFieldColList);
  }

  /**
   * 検索SQL生成
   */
  private void getSql() {
    List<String> logFieldColList = this.fieldListMap.get("logFieldColList");
    List<String> keyColList = this.fieldListMap.get("keyColList");
    StringBuffer sql = new StringBuffer("");
    sql.append("select\n");
    for (String logField : logFieldColList) {
      // ダミー start
      if (!"fn_plural".equals(logField)) {
        // ダミー end
        sql.append(getDecryptField(this.tableName, logField) + " as " + logField +",");
      }
    }
    sql.deleteCharAt(sql.length() - 1);
    sql.append("\n");
    sql.append("from\n");
    sql.append(this.tableName + "\n");
    if (!StringUtils.isEmpty(this.whereStr)) {
      sql.append(this.whereStr);
      sql.append("\n");
    }
    if (!CollectionUtils.isEmpty(keyColList)) {
      sql.append("order by\n");
      for (String key : keyColList) {
        sql.append(key + ",");
      }
      sql.deleteCharAt(sql.length() - 1);
    }
    // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou start
    if (!StringUtils.isEmpty(this.limit)) {
      sql.append("\n");
      sql.append(this.limit);
      sql.append("\n");
    }
    // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou end
    SelectBuilder selectBuilder = SelectBuilder.newInstance(getDbConfig());
    selectBuilder.sql(String.valueOf(sql));
    this.searchSQL = selectBuilder;
  }
  //add 8344【デグレ】チェックリストマスタの保存までが長い zhao start
  private void getSqlLimit() {
    List<String> logFieldColList = this.fieldListMap.get("logFieldColList");
    List<String> keyColList = this.fieldListMap.get("keyColList");
    StringBuffer sql = new StringBuffer("");
    sql.append("select\n");
    for (String logField : logFieldColList) {
      // ダミー start
      if (!"fn_plural".equals(logField)) {
        // ダミー end
        sql.append(getDecryptField(this.tableName, logField) + " as " + logField +",");
      }
    }
    sql.deleteCharAt(sql.length() - 1);
    sql.append("\n");
    sql.append("from\n");
    sql.append(this.tableName + "\n");
    if (!StringUtils.isEmpty(this.whereStr)) {
      sql.append(this.whereStr);
      sql.append("\n");
    }
    if (!CollectionUtils.isEmpty(keyColList)) {
      sql.append("order by\n");
      for (String key : keyColList) {
        sql.append(key+"+0" + ",");
      }
      sql.deleteCharAt(sql.length() - 1);
    }
    // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou start
    if (!StringUtils.isEmpty(this.limit)) {
      sql.append("\n");
      sql.append(this.limit);
      sql.append("\n");
    }
    // add #7783 2022-07-13 チェックリストマスタを保存するとWebAppサーバーがダウンする。 dou end
    SelectBuilder selectBuilder = SelectBuilder.newInstance(getDbConfig());
    selectBuilder.sql(String.valueOf(sql));
    this.searchSQL = selectBuilder;
  }
  //add 8344【デグレ】チェックリストマスタの保存までが長い zhao end

  private String getDecryptField(String tableName, String fieldName) {
    if (tableNameList.contains(tableName.toLowerCase()) && fieldNameList.contains(fieldName)) {
      return "'" + CUT_STR + "' ||" + fieldName + "|| '" + CUT_STR + "'";
    }
    return fieldName;
  }

  /**
   * 更新前データ取得
   *
   * @return boolean (true->検索結果あり、false->検索結果なし)
   */
  public boolean getBeforeData() {
    PlatformTransactionManager transactionManager = null;
    TransactionStatus status = null;
    try {
      transactionManager = logServiceCore.getPlatformTransactionManager();
      DefaultTransactionDefinition  def = new DefaultTransactionDefinition();
      def.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
      status = transactionManager.getTransaction(def);
      // 更新前データ取得
      this.beforeResults = executeSql(this.searchSQL);
      if (transactionManager != null && status != null) {
        transactionManager.commit(status);
      }
      return !CollectionUtils.isEmpty(this.beforeResults);
    } catch (Exception e) {
      if (transactionManager != null && status != null) {
        transactionManager.rollback(status);
      }
      LogEventUtil.outputErrorLog(this.eventLoggerFactory, e, this.getClass().getName());
      return false;
    }
  }
  // add by shiyw 2023-03-05: For trigger code logic  --start
  public List<Map<String, Object>> getBeforeResults(){
    return this.beforeResults;
  }

  public List<Map<String, Object>> getAfterResults(){
    return this.afterResults;
  }
  // add by shiyw 2023-03-05: For trigger code logic  --end

  /* add by chamaojia 2023-03-09 ステップ別操作方法の追加  --start */
  /**
   * 更新後データ取得
   */
  public void setAfterResults() {
    this.afterResults = executeSql(this.searchSQL);
  }

  /**
   * 差分判定呼び出し
   */
  public void updateLogToAsync() {
    try {
      if (!CollectionUtils.isEmpty(this.afterResults)) {
        this.diffInfo();
      }
    } catch (Exception e) {
      LogEventUtil.outputErrorLog(this.eventLoggerFactory, e, this.getClass().getName());
    }
  }
  /* add by chamaojia 2023-03-09 ステップ別操作方法の追加  --end */

  /**
   * 更新後データ取得
   */
  public void updateLog() {
    try {
      // 更新後データ取得
      this.afterResults = executeSql(this.searchSQL);
      //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
      if (MongoHealthCheckService.getMongoDBConnected()) {
        long instant = System.currentTimeMillis();
        if (!CollectionUtils.isEmpty(this.afterResults)) {
          instant = System.currentTimeMillis();
          this.diffInfo();
        }
      }
      //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
    } catch (Exception e) {
      LogEventUtil.outputErrorLog(this.eventLoggerFactory, e, this.getClass().getName());
    }
  }

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  /**
   * MasterEdit更新後データ取得
   */
  public void getAfterUpdatedResults() {
    try {
      // 更新後データ取得
      this.afterResults = executeSql(this.searchSQL);
    } catch (Exception e) {
      LogEventUtil.outputErrorLog(this.eventLoggerFactory, e, this.getClass().getName());
    }
  }
  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

  /**
   * Sql実行
   *
   * @param selectBuilder
   * @return 検索結果
   */
  private List<Map<String, Object>> executeSql(SelectBuilder selectBuilder) {
    return selectBuilder.getMapResultList(MapKeyNamingType.NONE);
  }

  /**
   * 検索用インタフェース取得
   * @return
   */
  private Config getDbConfig() {
    if (this.config != null) {
      return this.config;
    }

    return defaultDbConfig;
  }

  /**
   * 更新前後データ差分チェック
   */
  private void diffInfo() {

    // key list
    List<String> keyColList = this.fieldListMap.get("keyColList");

    long instant = System.currentTimeMillis();
    // 更新前データ件数ループ
    for (Map<String, Object> oldMap : this.beforeResults) {
      // 更新後のリストから絞り
      this.afterResults.stream()
        // テーブルキーでマッピングして、データを絞り、主キーあれば、一件のはず
        .filter(newMap -> oldEquelsNew(keyColList, oldMap, newMap))
        .forEach(filterNewMap -> {
          // 更新後のMapをループして、更新前後の値が差分があれば、該当するカラムと更新前後の値を格納する
          filterNewMap.keySet().forEach(fieldName -> {
            // 更新前データ
            Object beforeData = oldMap.get(fieldName);
            // 更新後データ
            Object afterData = filterNewMap.get(fieldName);
            // 差分あり、かつログ出力カラムである場合、更新前後の値を設定
            if (checkDiff(afterData, beforeData)) {
              this.tableInfoList.stream()
                .filter(updateLogInfo -> fieldName.equals(updateLogInfo.getFieldName()))
                .forEach(updateLogInfo -> {
                  updateLogInfo.setBeforeUpdateValue(beforeData);
                  updateLogInfo.setAfterUpdateValue(afterData);
                  updateLogInfo.setUpdated(true);
                  // DB更新ログ出力ロジック xie Start
                  if (updateLogInfo.getOrdMainHstInsFlg() == 1) {
                    OrdMainHisInfo ordMainInfo = new OrdMainHisInfo();
                    ordMainInfo.setOrdNo(convertString(filterNewMap.get("ord_no")));
                    // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 start
//                    ordMainInfo.setRstEdition(convertString(filterNewMap.get("rst_edition")));
                    if (oldMap.containsKey("rst_edition")) {
                      ordMainInfo.setRstEdition(convertString(oldMap.get("rst_edition")));
                    }
                    // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 end
                    ordMainInfo.setUpDate(convertString(filterNewMap.get("up_date")));
                    // mod 8277 周安寧 start
                    //ordMainInfo.setUpUserId(convertString(filterNewMap.get("up_user_id")));
                    // mod #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
                    // if(this.commonEventLogMessage.getUserId() != null && this.commonEventLogMessage.getUserId() != ""){
                    if(this.commonEventLogMessage.getUserId() != null && this.commonEventLogMessage.getUserId() != "" && this.commonEventLogMessage.getUserId() != "-1"){
                    // mod #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
                      ordMainInfo.setUpUserId(this.commonEventLogMessage.getUserId());
                    }else{
                      ordMainInfo.setUpUserId(convertString(filterNewMap.get("up_user_id")));
                    }
                   // mod 8277 周安寧 end
                    updateLogInfo.setOrdMainInfo(ordMainInfo);
                  }
                  // DB更新ログ出力ロジック xie End
                  if (updateLogInfo.isJson()) {
                    try {
                      Map<String, Object> map = campareJsonObject(convertString(beforeData), convertString(afterData));
                      if (map != null && map.size() > 0) {
                        List<JsonCompareInfo> list = getJsonCompareObject(map, updateLogInfo);
                        updateLogInfo.setJsonUpdatedlist(list);
                      }
                    } catch (JSONException e) {
                      throw e;
                    }
                  }
                });
            }
          });
        });
    }


    instant = System.currentTimeMillis();
    // ログ出力情報
    List<UpdateLogInfo> filterLogInfo = this.tableInfoList.stream()
      .filter(UpdateLogInfo::isUpdated)
      .collect(toList());

    /* modify by chamaojia 2023-03-14 呼び出し一括メソッドの変更  --start */
    // log出力
    logOutputToBatch(filterLogInfo);
//    for (int i = 0; i < this.beforeResults.size(); i++) {
//      logOutput(filterLogInfo);
//    }
    /* modify by chamaojia 2023-03-14 呼び出し一括メソッドの変更  --end */
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
        result = oldMap.get(s).equals(newMap.get(s));
        if (!result) {
          break;
        }
      }
    }
    return result;
  }

  // #10337 2024.05.21 del 混乱するので不使用のロジックを削除 TDC片口 start
//  /**
//   * log出力
//   */
//  private void logOutput(List<UpdateLogInfo> filterLogInfo) {
//    EventLogMessage eventLogMessage = null;
//    // 患者ID
//    String patId = DataUpdateLogInfoUtil.getPatId(this.beforeResults);
//    String facilityCd = DataUpdateLogInfoUtil.getFacilityCd(this.beforeResults);
////    mod 8074 【デグレ】ログに誤った利用者が記録される 関 start
////  String userId = DataUpdateLogInfoUtil.getUserId(this.beforeResults);
////  String userId = DataUpdateLogInfoUtil.getUserId(this.afterResults);
//    String userId = this.commonEventLogMessage.getUserId();
////    mod 8074 【デグレ】ログに誤った利用者が記録される 関  end
//    //add 8168 装置状態管理のログ内容について 周安寧　start
//    String machineName ="";
//    //add 8168 装置状態管理のログ内容について 周安寧　end
//    // ループ　ログ出力
//    for (Object info : filterLogInfo) {
//      UpdateLogInfo outputInfo = (UpdateLogInfo) info;
//      //FNSI-修正 4109対応 xiebzh add start
//      if (convertString(outputInfo.getFieldName()).indexOf("up_date") >= 0 ||
//          convertString(outputInfo.getFieldName()).indexOf("reg_date") >= 0 ||
//          convertString(outputInfo.getFieldName()).indexOf("flg") >= 0 ||
//          convertString(outputInfo.getFieldComment()).indexOf("フラグ") >= 0) {
//        continue;
//      }
//      //FNSI-修正 4109対応 xiebzh add end
//      eventLogMessage = new EventLogMessage();
//      eventLogMessage.setInvokeClass(this.getClass().getName());
//      if (StringUtils.isEmpty(eventLogMessage.getPatId())) {
//        eventLogMessage.setPatId(patId);
//      }
//
//      if (StringUtils.isEmpty(eventLogMessage.getFacilityCd())) {
//        eventLogMessage.setFacilityCd(facilityCd);
//      }
//
//      if (StringUtils.isEmpty(eventLogMessage.getUserId())) {
//        eventLogMessage.setUserId(userId);
//      }
//
//      setEventLogMessage(eventLogMessage);
//      //6375　検査日付・装置名・種別・検査箇所の情報を取得　add start ljx
//      if("mnt_water_survey".equals(outputInfo.getTableName())){
//        outputInfo = convertOutputInfo(outputInfo);
//      }
//      //6375　検査日付・装置名・種別・検査箇所の情報を取得　add end ljx
//      //add 8168 装置状態管理のログ内容について 周安寧　start
//      if("mnt_machine_state".equals(outputInfo.getTableName())){
//        for (Map map : this.beforeResults) {
//          if (map.containsKey("machine_name")) {
//            machineName =  convertString(map.get("machine_name"));
//          }
//        }
//      }
//      //mod 8168 装置状態管理のログ内容について 周安寧　end
//      if (!outputInfo.isJson()) {
//        if (!outputInfo.isUpdated()) {
//          continue;
//        }
//        //mod 8168 装置状態管理のログ内容について 周安寧　start
//        if ("mnt_machine_state".equals(outputInfo.getTableName())){
//          // データ変更ログ出力(Json以外)
//          DataUpdateLogInfoUtil.outputDataAccessLogNoJson(eventLogMessage, this.logServiceCore, outputInfo, machineName);
//        }else{
//          // データ変更ログ出力(Json以外)
//          DataUpdateLogInfoUtil.outputDataAccessLogNoJson(eventLogMessage, this.logServiceCore, outputInfo, outputInfo.getTableComment());
//        }
//        // データ変更ログ出力(Json以外)
//        //DataUpdateLogInfoUtil.outputDataAccessLogNoJson(eventLogMessage, this.logServiceCore, outputInfo, outputInfo.getTableComment());
//        //mod 8168 装置状態管理のログ内容について 周安寧　end
//      } else {
//        //mod 8168 装置状態管理のログ内容について 周安寧　start
//        if ("mnt_machine_state".equals(outputInfo.getTableName())){
//          // データ変更ログ出力(Json)
//          DataUpdateLogInfoUtil.outputDataAccessLogForJson(eventLogMessage, this.logServiceCore, outputInfo, machineName);
//        } else {
//          // データ変更ログ出力(Json)
//          DataUpdateLogInfoUtil.outputDataAccessLogForJson(eventLogMessage, this.logServiceCore, outputInfo, outputInfo.getTableComment());
//        }
//        // データ変更ログ出力(Json)
//        //DataUpdateLogInfoUtil.outputDataAccessLogForJson(eventLogMessage, this.logServiceCore, outputInfo, outputInfo.getTableComment());
//        //mod 8168 装置状態管理のログ内容について 周安寧　end
//      }
//    }
//  }
  // #10337 2024.05.21 del 混乱するので不使用のロジックを削除 TDC片口 end

  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --start */
  /**
   * log出力
   */
  private void logOutputToBatch(List<UpdateLogInfo> filterLogInfo) {
    EventLogMessage eventLogMessage = null;
    // 患者ID
    String patId = DataUpdateLogInfoUtil.getPatId(this.beforeResults);
    String facilityCd = DataUpdateLogInfoUtil.getFacilityCd(this.beforeResults);
//    mod 8074 【デグレ】ログに誤った利用者が記録される 関 start
//  String userId = DataUpdateLogInfoUtil.getUserId(this.beforeResults);
//  String userId = DataUpdateLogInfoUtil.getUserId(this.afterResults);
    String userId = this.commonEventLogMessage.getUserId();
//    mod 8074 【デグレ】ログに誤った利用者が記録される 関  end
    //add 8168 装置状態管理のログ内容について 周安寧　start
    String machineName ="";
    //add 8168 装置状態管理のログ内容について 周安寧　end
    // add #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 start
    boolean isConfirm = false;
    // add #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 end
    List<DataUpdateLogInfoEntity> logForJsonList = new ArrayList<>();
    List<DataUpdateLogInfoEntity> logNoJsonList = new ArrayList<>();
    for (int i = 0; i < this.beforeResults.size(); i++) {
      // ループ　ログ出力
      for (Object info : filterLogInfo) {
        UpdateLogInfo outputInfo = (UpdateLogInfo) info;
        // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 start
//        // add #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 start
//        if ((convertString(outputInfo.getFieldName()).indexOf("is_confirm") >= 0 &&
//          "0".equals(outputInfo.getBeforeUpdateValue()) &&
//          "1".equals(outputInfo.getAfterUpdateValue())) ||
//          (convertString(outputInfo.getFieldName()).indexOf("rst_is_update_edition") >= 0 &&
//          outputInfo.getBeforeUpdateValue() == null &&
//          "0".equals(outputInfo.getAfterUpdateValue()))) {
//          isConfirm = true;
//        }
//        // add #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 end
        // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 end
        //FNSI-修正 4109対応 xiebzh add start
        if (convertString(outputInfo.getFieldName()).indexOf("up_date") >= 0 ||
          convertString(outputInfo.getFieldName()).indexOf("reg_date") >= 0 ||
          convertString(outputInfo.getFieldName()).indexOf("flg") >= 0 ||
          convertString(outputInfo.getFieldComment()).indexOf("フラグ") >= 0) {
          continue;
        }
        //FNSI-修正 4109対応 xiebzh add end
        eventLogMessage = new EventLogMessage();
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

        setEventLogMessage(eventLogMessage);
        //6375　検査日付・装置名・種別・検査箇所の情報を取得　add start ljx
        if("mnt_water_survey".equals(outputInfo.getTableName())){
          outputInfo = convertOutputInfo(outputInfo);
        }
        //6375　検査日付・装置名・種別・検査箇所の情報を取得　add end ljx
        //add 8168 装置状態管理のログ内容について 周安寧　start
        if("mnt_machine_state".equals(outputInfo.getTableName())){
          for (Map map : this.beforeResults) {
            if (map.containsKey("machine_name")) {
              machineName =  convertString(map.get("machine_name"));
            }
          }
        }
        //mod 8168 装置状態管理のログ内容について 周安寧　end
        if (!outputInfo.isJson()) {
          if (!outputInfo.isUpdated()) {
            continue;
          }
          DataUpdateLogInfoEntity entity = new DataUpdateLogInfoEntity();
          entity.setEventLogMessage(eventLogMessage);
          entity.setOutputInfo(outputInfo);
          //mod 8168 装置状態管理のログ内容について 周安寧　start
          if ("mnt_machine_state".equals(outputInfo.getTableName())){
//            // データ変更ログ出力(Json以外)
//            DataUpdateLogInfoUtil.outputDataAccessLogNoJson(eventLogMessage, this.logServiceCore, outputInfo, machineName);
            entity.setTableName(machineName);
          }else{
//            // データ変更ログ出力(Json以外)
//            DataUpdateLogInfoUtil.outputDataAccessLogNoJson(eventLogMessage, this.logServiceCore, outputInfo, outputInfo.getTableComment());
            entity.setTableName(outputInfo.getTableComment());
          }
          logNoJsonList.add(entity);
          // データ変更ログ出力(Json以外)
          //DataUpdateLogInfoUtil.outputDataAccessLogNoJson(eventLogMessage, this.logServiceCore, outputInfo, outputInfo.getTableComment());
          //mod 8168 装置状態管理のログ内容について 周安寧　end
        } else {
          DataUpdateLogInfoEntity entity = new DataUpdateLogInfoEntity();
          entity.setEventLogMessage(eventLogMessage);
          entity.setOutputInfo(outputInfo);
          //mod 8168 装置状態管理のログ内容について 周安寧　start
          if ("mnt_machine_state".equals(outputInfo.getTableName())){
//            // データ変更ログ出力(Json)
//            DataUpdateLogInfoUtil.outputDataAccessLogForJson(eventLogMessage, this.logServiceCore, outputInfo, machineName);
            entity.setTableName(machineName);
          } else {
//            // データ変更ログ出力(Json)
//            DataUpdateLogInfoUtil.outputDataAccessLogForJson(eventLogMessage, this.logServiceCore, outputInfo, outputInfo.getTableComment());
            entity.setTableName(outputInfo.getTableComment());
          }
          logForJsonList.add(entity);
          // データ変更ログ出力(Json)
          //DataUpdateLogInfoUtil.outputDataAccessLogForJson(eventLogMessage, this.logServiceCore, outputInfo, outputInfo.getTableComment());
          //mod 8168 装置状態管理のログ内容について 周安寧　end
        }
      }
    }

    if (!logNoJsonList.isEmpty()) {
      // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 start
//      // mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 start
//      // DataUpdateLogInfoUtil.outputDataAccessLogNoJsonToBatch(logNoJsonList, this.logServiceCore);
//      DataUpdateLogInfoUtil.outputDataAccessLogNoJsonToBatch(logNoJsonList, this.logServiceCore, isConfirm);
//      // mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 end
      DataUpdateLogInfoUtil.outputDataAccessLogNoJsonToBatch(logNoJsonList, this.logServiceCore);
      // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 end
    }

    if (!logForJsonList.isEmpty()) {
      // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 start
//      // mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 start
//      // DataUpdateLogInfoUtil.outputDataAccessLogForJsonToBatch(logForJsonList, this.logServiceCore);
//      DataUpdateLogInfoUtil.outputDataAccessLogForJsonToBatch(logForJsonList, this.logServiceCore, isConfirm);
//      // mod #6126 治療記録の変更履歴表示の第0版～第1版に1版の版確定の内容が表示されない 鄭爽 end
      DataUpdateLogInfoUtil.outputDataAccessLogForJsonToBatch(logForJsonList, this.logServiceCore);
      // #10337 2024.05.21 mod 変更履歴の版番号は更新前の版を使用する TDC片口 end
    }
  }
  /* add by chamaojia 2023-03-14 新しい一括ログ記録方法の追加  --end */

  /**
   * ログメッセージ情報設定
   *
   * @param em ログメッセージ
   */
  private void setEventLogMessage(EventLogMessage em) {
    //#6067 利用者ないの場合の補足.
    if (StringUtils.isEmpty(em.getUserId())){
      em.setUserId(commonEventLogMessage.getUserId());
    }
    if (StringUtils.isEmpty(em.getFacilityCd())) {
      em.setFacilityCd(commonEventLogMessage.getFacilityCd());
    }
    if(StringUtils.isEmpty(em.getClientIp())){
      em.setClientIp(commonEventLogMessage.getClientIp());
    }
    if(StringUtils.isEmpty(em.getSessionId())){
      em.setSessionId(commonEventLogMessage.getSessionId());
    }
    if(StringUtils.isEmpty(em.getServiceName())){
      em.setServiceName(commonEventLogMessage.getServiceName());
    }
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
   * 論理カラム名を取得する
   *
   * @return 論理カラム名
   */
  private List<TableCommentInfo> getAllFieldComment() {
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
    // DB更新ログ出力ロジック xie Start
    selectBuilder.sql(" ord_main_hst_ins_flg ");
    // DB更新ログ出力ロジック xie End
    selectBuilder.sql(" FROM ");
    selectBuilder.sql(" log_table_comment ");
    selectBuilder.sql(" WHERE ");
    selectBuilder.sql(" tbl_name = '" + this.tableName + "' ");

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
      // DB更新ログ出力ロジック xie Start
      tableInfo.setOrdMainHstInsFlg(result.get("ord_main_hst_ins_flg") == null ? 0 : Integer.parseInt(convertString(result.get("ord_main_hst_ins_flg"))));
      // DB更新ログ出力ロジック xie End
      tableInfoList.add(tableInfo);
    }
    return tableInfoList;
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
    /* add by chamaojia 2023-03-14 一時的なmapキャッシュ読み込みの追加  --start */
    String key = new StringBuilder().append(jsonCompareInfo.getTableName()).append("-")
      .append(jsonCompareInfo.getColName()).append("-").append(jsonCompareInfo.getKey()).toString();
    if (keyCommentMap.containsKey(key)) {
      return keyCommentMap.get(key);
    }
    /* add by chamaojia 2023-03-14 一時的なmapキャッシュ読み込みの追加  --end */

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
      return null;
    }
    Map<String, Object> map = results.get(0);
    /* modify by chamaojia 2023-03-14 一時的なmapキャッシュレコード（単一スレッドレベル）  --start */
    String result = convertString(map.get("json_key_comment"));
    keyCommentMap.put(key, result);
    return result;
    /* modify by chamaojia 2023-03-14 一時的なmapキャッシュレコード（単一スレッドレベル）  --end */
  }

  /**
   * 検索条件 IN情報
   *
   * @param fieldInfo カラム情報
   * @param inList    IN値リスト
   * @return inStr
   */
  public String getInStr(String fieldInfo, List<Object> inList) {
    StringBuffer inStr = new StringBuffer("");
    inStr.append(fieldInfo);
    inStr.append(" ( ");
    for (Object obj : inList) {
      if (obj instanceof String) {
        inStr.append(" '");
        inStr.append(obj);
        inStr.append("' ");
        inStr.append(" ,");
      } else {
        inStr.append(obj);
        inStr.append(" ,");
      }
    }
    inStr.deleteCharAt(inStr.length() - 1);
    inStr.append(" ) ");
    return String.valueOf(inStr);
  }
  /**
   * 水質の検査日付・装置名・種別・検査箇所の情報を取得
   *
   * @param outputInfo 水質情報
   * @return outputInfo
   */
  public  UpdateLogInfo convertOutputInfo(UpdateLogInfo outputInfo){
    //変更前のデータ
    String beforeUpdateValue = convertString(outputInfo.getBeforeUpdateValue());
    List<Map<String, String>> beforeList = this.changeListMap(beforeUpdateValue);
    //変更後のデータ
    String afterUpdateValue = convertString(outputInfo.getAfterUpdateValue());
    List<Map<String, String>> afterList = this.changeListMap(afterUpdateValue);
    //差分データ
    List<Map<String, String>> diffList = afterList.stream().filter(item -> !beforeList.contains(item)).collect(toList());

    if(diffList.size()==0){
      //中止の場合、変更後より、変更前のデータが多いので、差分データを再処理。
      diffList = beforeList.stream().filter(item -> !afterList.contains(item)).collect(toList());
    }
    //装置名・種別・検査箇所の情報を取得のため、ポイントCDが必要ので、差分データから取得。
    Long pointCd = null;
    for (int j = 0; j < diffList.size(); j++){
      Map<String, String> mapAfter = diffList.get(j);
      pointCd = Long.parseLong(mapAfter.get("point_cd"));
    }
    //検査日付取得。変更前後が不変のため、変更後のデータから取得。
    String inspectionDate = "";
    if (!CollectionUtils.isEmpty(this.afterResults)) {
      Map<String, Object> surveyMap = this.afterResults.get(0);
      inspectionDate = surveyMap.get("inspection_date").toString();
    }
    //ポイントCDで装置名・種別・検査箇所の情報を取得。
    WaterSurveyPoint waterSurveyPoint = logServiceCore.getSurveyData(pointCd);
    //取得した装置名・種別・検査箇所を再処理。
    String surveyData = "{検査日付:"+inspectionDate.substring(0,10)+" 装置名:"+waterSurveyPoint.getMachineName()
      +" 種別:"+waterSurveyPoint.getSurveyTypeName()+" 検査箇所:"+waterSurveyPoint.getPointName()+"}";
    //元のFieldCommentを基づいて取得した装置名・種別・検査箇所を加えて最後のFieldCommentとして保存
    outputInfo.setFieldComment(outputInfo.getFieldComment()+surveyData);
    return outputInfo;
  }
  /**
   * JSon文字列をマップ型リストに変換する処理
   *
   * @param strJson JSon文字列
   * @return 変換したマップ型リスト
   */
  public List<Map<String,String>> changeListMap (String strJson){
    //変換したマップ型リスト
    List<Map<String, String>> changedList = new ArrayList<>();
    //変換処理
    ObjectMapper mapper = new ObjectMapper();
    TypeReference<List<Map<String, String>>> type = new TypeReference<List<Map<String, String>>>() {};
    try {
      changedList = mapper.readValue(strJson, type);
    } catch (JacksonException e) {
      System.err.println(e.getMessage());
    }
    return changedList;
  }

  // add 10626 データリストのCTR・DW一括登録修正 房 start
  /**
   * テーブル「pat_unique」のログ登録
   */
  public void updatePatUniqueLog() {
    try {
      // 更新後データ取得
      this.afterResults = executeSql(this.searchSQL);
      if (MongoHealthCheckService.getMongoDBConnected()) {
        if (!CollectionUtils.isEmpty(this.afterResults)) {
          CompletableFuture.runAsync(()->{
            this.diffPatUniqueInfo();
          });
        }
      }
    } catch (Exception e) {
      LogEventUtil.outputErrorLog(this.eventLoggerFactory, e, this.getClass().getName());
    }
  }

  /**
   * pat_unique：変更内容比較
   */
  private void diffPatUniqueInfo() {
    // key list
    List<String> keyColList = this.fieldListMap.get("keyColList");
    for (Map<String, Object> oldMap : this.beforeResults) {
      // 更新後のリストから絞り
      this.afterResults.stream()
        // テーブルキーでマッピングして、データを絞り、主キーあれば、一件のはず
        .filter(newMap -> oldEquelsNew(keyColList, oldMap, newMap))
        .forEach(filterNewMap -> {
          // 更新後のMapをループして、更新前後の値が差分があれば、該当するカラムと更新前後の値を格納する
          filterNewMap.keySet().forEach(fieldName -> {
            // 更新前データ
            Object beforeData = oldMap.get(fieldName);
            // 更新後データ
            Object afterData = filterNewMap.get(fieldName);
            // 差分あり、かつログ出力カラムである場合、更新前後の値を設定
            if (checkDiff(afterData, beforeData)) {
              this.tableInfoList.stream()
                .filter(updateLogInfo -> fieldName.equals(updateLogInfo.getFieldName()))
                .forEach(updateLogInfo -> {
                  updateLogInfo.setBeforeUpdateValue(beforeData);
                  updateLogInfo.setAfterUpdateValue(afterData);
                  updateLogInfo.setUpdated(true);
                  if (updateLogInfo.isJson()) {
                    Map<String, Object> map = comparePatUniqueJsonObject(convertString(beforeData), convertString(afterData));
                    if (map != null && map.size() > 0) {
                      List<JsonCompareInfo> list = getJsonCompareObject(map, updateLogInfo);
                      updateLogInfo.setJsonUpdatedlist(list);
                    }
                  }
                });
            }
          });
        });
    }
    // ログ出力情報
    List<UpdateLogInfo> filterLogInfo = this.tableInfoList.stream()
      .filter(UpdateLogInfo::isUpdated)
      .collect(toList());

    // log出力
    logOutputToBatch(filterLogInfo);
  }
  // add 10626 データリストのCTR・DW一括登録修正 房 end
}
