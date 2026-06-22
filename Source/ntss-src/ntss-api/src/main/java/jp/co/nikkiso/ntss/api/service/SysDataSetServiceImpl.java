package jp.co.nikkiso.ntss.api.service;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import com.mongodb.BasicDBObject;
import com.mongodb.client.FindIterable;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstAdditionDao;
import jp.co.nikkiso.ntss.core.dao.MstCourseDao;
import jp.co.nikkiso.ntss.core.dao.MstDiseaseDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstInfectionDao;
import jp.co.nikkiso.ntss.core.dao.MstPatMemoDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.MstWardDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdPersonalPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDao;
import jp.co.nikkiso.ntss.core.dao.SysDataSetAuthorityDao;
import jp.co.nikkiso.ntss.core.dao.SysDataSetDao;
import jp.co.nikkiso.ntss.core.config.AuthDb;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
import jp.co.nikkiso.ntss.core.config.PersonalDb;
import jp.co.nikkiso.ntss.core.dao.SysDataSetPersonalDao;
import jp.co.nikkiso.ntss.core.dao.SysReportClassDao;
import jp.co.nikkiso.ntss.core.entity.MstAddition;
import jp.co.nikkiso.ntss.core.entity.MstCourse;
import jp.co.nikkiso.ntss.core.entity.MstDisease;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstInfection;
import jp.co.nikkiso.ntss.core.entity.MstPatMemo;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstWard;
import jp.co.nikkiso.ntss.core.entity.OrdPersonalPrescription;
import jp.co.nikkiso.ntss.core.entity.SysDataSet;
import jp.co.nikkiso.ntss.core.entity.SysDataSet.Detail;
import jp.co.nikkiso.ntss.core.entity.SysDataSet.Detail.convSqlItem;
import jp.co.nikkiso.ntss.core.entity.SysDataSet.PreSqlInfo;
import jp.co.nikkiso.ntss.core.entity.SysDataSet.PreSqlInfoItem;
import jp.co.nikkiso.ntss.core.entity.SysReportClass;
import jp.co.nikkiso.ntss.core.entity.custom.AdditionInfoOrdMain;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.collections4.CollectionUtils;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.seasar.doma.jdbc.builder.DeleteBuilder;
import org.seasar.doma.jdbc.builder.InsertBuilder;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.seasar.doma.jdbc.builder.UpdateBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.scheduling.annotation.AsyncResult;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.text.Normalizer;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Arrays;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.Set;
import java.util.StringJoiner;
import java.util.concurrent.Future;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.TreeMap;

import static com.mongodb.client.model.Filters.and;
import static com.mongodb.client.model.Filters.eq;
import static com.mongodb.client.model.Filters.gt;
import static com.mongodb.client.model.Filters.gte;
import static com.mongodb.client.model.Filters.lt;
import static com.mongodb.client.model.Filters.lte;
import static com.mongodb.client.model.Filters.ne;
import static com.mongodb.client.model.Sorts.ascending;
import static com.mongodb.client.model.Sorts.descending;
import static com.mongodb.client.model.Sorts.orderBy;
import static java.util.Map.Entry.comparingByKey;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * {@link SysDataSetService}の実装クラス.
 */
@Service
@Slf4j
public class SysDataSetServiceImpl implements SysDataSetService {

  /**
   * データセットのDaoインタフェース.
   */
  @Autowired
  private SysDataSetDao sysDataSetDao;

  // add #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe start
  @Autowired
  private SysReportClassDao sysReportClassDao;
  // add #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe end

  /**
   * データセット（個人情報DB）のDaoインタフェース.
   */
  @Autowired
  private SysDataSetPersonalDao sysDataSetPersonalDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;

  @Autowired
  @PersonalDb
  private Config personalDbConfig;

  @Autowired
  @AuthDb
  private Config authDbConfig;

  // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
  @Autowired
  private MstInfectionDao mstInfectionDao;
  @Autowired
  private MstFacilityDao mstFacilityDao;
  @Autowired
  private MstCourseDao mstCourseDao;
  @Autowired
  private MstWardDao mstWardDao;
  @Autowired
  private MstDiseaseDao mstDiseaseDao;
  @Autowired
  private PatGroupDao patGroupDao;
  // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
  // add #10210 帳票における患者情報の取得元について sunsy start
  @Autowired
  private MstPatMemoDao mstPatMemoDao;
  // add #10210 帳票における患者情報の取得元について sunsy end
  // 課題追加5_MongoDB追加対応 2021/04/20 add start ウ
  /**
   * データセット（mongoDB）のインタフェース.
   */
  @Autowired(required = false)
  MongoTemplate mongoTemplate;
  // 課題追加5_MongoDB追加対応 2021/04/20 add end ウ

  /**
   * データセット（認証DB）のDaoインタフェース.
   */
  @Autowired
  private SysDataSetAuthorityDao sysDataSetAuthorityDao;

  // add #10210 帳票における患者情報の取得元について sunsy start
  @Autowired
  private OrdPrescriptionDao ordPrescriptionDao;

  @Autowired
  private OrdPersonalPrescriptionDao ordPersonalPrescriptionDao;
  // add #10210 帳票における患者情報の取得元について sunsy end
  // add #10210 帳票における患者情報の取得元について 20240613 sunsy start
  @Autowired
  private MstAdditionDao mstAdditionDao;
  // add #10210 帳票における患者情報の取得元について 20240613 sunsy end

  @Autowired
  private LogService logService;

  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
  // // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
  // private String mergeKey = null;
  // // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */

  // add 10210 by kangjie 20240606 start  「表示順設定」の順で出力されなければならない。
  @Autowired
  private MstSelectorDao mstSelectorDao;
  // addition valid
  // add #11625 【標準帳票】クラス「指示履歴」の仕様変更② sunsy start
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  // add #11625 【標準帳票】クラス「指示履歴」の仕様変更② sunsy end
  private static final String ADDITION_ON = "1";
  // addition invalid
  private static final String ADDITION_OFF = "0";
  // add 10210 by kangjie 20240606 end

  @Autowired
  private OrdMainDao ordMainDao;

  /**
   * 使用用途
   */
  @Getter
  @AllArgsConstructor
  public enum UseApplication {
    /** 帳票(1) */
    REPORT(1),
    /** 患者イベントテンプレートマスタ(2) */
    PATIENT_TEMPLATE_MST(2),
    /** 患者イベント実績(3) */
    PATIENT_EVENT_TBL(3),
    /** 連携(4) */
    COOPERATION(4),
    /** 外部view共有(5) */
    SHARE_VIEW(5);

    // フィールド変数
    private final Integer value;

    /** JSONのキー */
    public static final String JOSN_KEY = "applications";
  }

  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
  // // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
  // /**
  //  * {@inheritDoc}
  //  */
  // @Override
  // public String GetMergeKey() {
  //   return mergeKey;
  // }
  // // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */

  /**
   * {@inheritDoc}
   */
  @Override
  public List<Map<String, Object>> getDataList(Long sqlCode, Map<String, Object> dataKey) {
    return getDataList(sqlCode, dataKey, null);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
  public List<Map<String, Object>> getDataList(Long sqlCode, Map<String, Object> dataKey,
                                               UseApplication targetApplication)  {
    //add IES因島）sql性能試験 後で削除 liuc start
    String sqlTestSign = (String) dataKey.get("sqlTestSign");
    Date beginTime = null;
    if(!StringUtils.isEmpty(sqlTestSign)){
      beginTime = new Date();
    }
    //add IES因島）sql性能試験 後で削除 liuc end
    // add #6467 李 start
    // del 10550 患者別の検査結果一覧帳票を出力できるようにする 吉 start
//    if (sqlCode == 197){
//      dataKey.remove("patId");
//    }
    // del 10550 患者別の検査結果一覧帳票を出力できるようにする 吉 end
    // add #6467 李 end

    // mod #5714 紹介状が正しく出力できない 鄭爽 start
    //List<Map<String, Object>> dataSet = getDataListContainsError(sqlCode, dataKey, targetApplication);
    List<Map<String, Object>> dataSet = new ArrayList<Map<String, Object>>();
    // mod #5714 紹介状が正しく出力できない 日本指摘対応 鄭爽 start
    // if (dataKey.get("ordNos") != null && (sqlCode == 95 || sqlCode == 3)){
    // mod #8310 検査結果表示のフィルタ・表示が正しく動作していない 鄭爽 start
    // if (dataKey.get("ordNos") != null && (sqlCode == 95 || sqlCode == 3 || sqlCode == 7)){
    if (dataKey.get("ordRstNos") != null && (sqlCode == 95 || sqlCode == 3 || sqlCode == 7)){
      // mod #8310 検査結果表示のフィルタ・表示が正しく動作していない 鄭爽 end
      // mod #5714 紹介状が正しく出力できない 日本指摘対応 鄭爽 end
      // mod #8310 検査結果表示のフィルタ・表示が正しく動作していない 鄭爽 end
      // List<Long> ordNoList = (List<Long>)dataKey.get("ordNos");
      List<Long> ordNoList = (List<Long>)dataKey.get("ordRstNos");
      // mod #8310 検査結果表示のフィルタ・表示が正しく動作していない 鄭爽 end
      for (int i = 0; i < ordNoList.size(); i++) {
        dataKey.put(ReportConstant.ReportDataKey.ORD_NO, ordNoList.get(i));
        List<Map<String, Object>> tmpDataSet = getDataListContainsError(sqlCode, dataKey, targetApplication);
        if (tmpDataSet.size() > 0) {
          dataSet.add(tmpDataSet.get(0));
        }
      }
    } else {
      dataSet = getDataListContainsError(sqlCode, dataKey, targetApplication);
    }
    // mod #5714 紹介状が正しく出力できない 鄭爽 end
    if (dataSet != null  && dataSet.size() == 1) {
      Map<String, Object> map = dataSet.get(0);
      if (map.containsKey("error")) {
        return new ArrayList<Map<String, Object>>();
      }
    }

    //add IES因島）sql性能試験 後で削除 liuc start
    if(beginTime != null){
      Date endTime = new Date();
      EventLogMessage LogMessage = new EventLogMessage();
      LogMessage.setLogMessage(sqlTestSign + "SysDataSetServiceImpl::getDataList sqlCode"
        + sqlCode + ": 実行時間:" + (endTime.getTime() - beginTime.getTime()) + "ms");
      logService.log(LogLevel.INFO, LogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
    }
    //add IES因島）sql性能試験 後で削除 liuc end
    return dataSet;
  }

  // add 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 start
  /**
   * 非同期取得DataSetでの結果
   *
   * @param sqlCode sqlCode
   * @param dataKey Query params
   * @param targetApplication 検正条件
   * @return resultMap
   */
  @Override
  @Async("doSomethingExecutor")
  public Future<List<Map<String, Object>>> getDataListAsync(Long sqlCode, Map<String, Object> dataKey,
                                                            UseApplication targetApplication) {
    //
    // del 10550 患者別の検査結果一覧帳票を出力できるようにする 吉 start
    // if (sqlCode == 197) dataKey.remove("patId");
    // del 10550 患者別の検査結果一覧帳票を出力できるようにする 吉 end
    // init Result container
    List<Map<String, Object>> resultList = new ArrayList<>();
    if ((dataKey.containsKey("ordRstNos") && dataKey.get("ordRstNos") != null)
      && List.of(3L, 7L, 95L).contains(sqlCode)){
      List<Long> ordNoList = (List<Long>)dataKey.get("ordRstNos");
      if (CollectionUtils.isNotEmpty(ordNoList)) {
        for (Long ordNo : ordNoList) {
          dataKey.put(ReportConstant.ReportDataKey.ORD_NO, ordNo);
          List<Map<String, Object>> tmpDataSet = getDataListContainsError(sqlCode, dataKey, targetApplication);
          if (CollectionUtils.isNotEmpty(tmpDataSet)) resultList.add(tmpDataSet.get(0));
        }
      }
    } else {
      Date beginTime = new Date();
      resultList = getDataListContainsError(sqlCode, dataKey, targetApplication);
      Date endTime = new Date();
    }
    if (CollectionUtils.isNotEmpty(resultList)) {
      Optional<Map<String, Object>> firstData = resultList.stream().findFirst();
      if (firstData.isPresent() && firstData.get().containsKey("error")) resultList.clear();
    }
    return new AsyncResult<>(resultList);
  }
  // add 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 start


  @Override
  public Map<String, Object> getResultCnt(Long sqlCode, Map<String, Object> paramDataKey)  {

    SysDataSet sysDataSet = getSysDataSet(sqlCode);
    Map<String, Object> resultMap = new HashMap<>();
    if (sysDataSet == null) {
      resultMap.put("message", "指定されたsqlCodeにSQLが登録されていません。sqlCd:「" + sqlCode + "」");
      return resultMap;
    }
    if(StringUtils.isEmpty(sysDataSet.getSql())){
      resultMap.put("message","Sql_CD:["  + sqlCode + "],のsqlが設定されておりません");
      return resultMap;
    }
    if (!"{\"applications\": [4]}".equals(sysDataSet.getUseApplication()) && !"{\"applications\": [5]}".equals(sysDataSet.getUseApplication())) {
        resultMap.put("message", "Sql_CD:[" + sqlCode + "],applicationレベルの設定が間違っております");
        return resultMap;
    }
    // 事前実行SQLがあれば実行して結果をパラメータに追加
    paramDataKey = this.preExecSql(sysDataSet.getPreSqlInfo(), paramDataKey);
    List<Map<String, Object>> reportInfo = new ArrayList<>();
    try{
    Integer dbClass = sysDataSet.getDbClass();
    String sql = sysDataSet.getSql();

    if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
      Config config = defaultDbConfig;
      SelectBuilder selectBuilder = createSelectBuilder(config, sql, paramDataKey);
      reportInfo = sysDataSetDao.executeSql(selectBuilder);
      // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + paramDataKey);
      if (paramDataKey != null ) {
        String facilityCd = Objects.toString(paramDataKey.get("facilityCd"), null);
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
      }
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
    } else if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
      Config config = personalDbConfig;
      SelectBuilder selectBuilder = createSelectBuilder(config, sql, paramDataKey);
      reportInfo = sysDataSetPersonalDao.executeSql(selectBuilder);
      // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + paramDataKey);
      if (paramDataKey != null ) {
        String facilityCd = Objects.toString(paramDataKey.get("facilityCd"), null);
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
      }
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
    } else if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
      Config config = authDbConfig;
      SelectBuilder selectBuilder = createSelectBuilder(config, sql, paramDataKey);
      reportInfo = sysDataSetAuthorityDao.executeSql(selectBuilder);
      // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + paramDataKey);
      if (paramDataKey != null ) {
        String facilityCd = Objects.toString(paramDataKey.get("facilityCd"), null);
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
      }
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
    } else if(SysDataSet.DB_CLASS_MONGODB.equals(dbClass)) {
      Map<String, Object> mongoDBDataKey = new HashMap<String, Object>();
      for (String key: paramDataKey.keySet()) {
        sql = sql.replace("@"+ key,paramDataKey.get(key) == null?"":paramDataKey.get(key).toString());
      }
      mongoDBDataKey = this.createSelectParameter(sql, mongoDBDataKey);
      reportInfo = getMongoDBData(mongoDBDataKey);
    } else {
      resultMap.put("message", "想定しないDB種別が指定されています。");
    }
    }catch(Exception e){
      resultMap.put("message","Sql_CD:["  + sqlCode + "],実行でエラーが発生しました。");
    }
    resultMap.put("message", "正常終了");
    resultMap.put("excuteResultsCount", reportInfo.size());

    return resultMap;
  }

  /**
   * マージキーの取得
   *
   * @param sqlCode SqlCode
   * @return マージキー
   */
  public String getMergeKeyForSqlCode(Long sqlCode){
    // SysDataSetを取得する
    SysDataSet sysDataSet = getSysDataSet(sqlCode);
    String mergeKey = "";
    if (!StringUtils.isEmpty(sysDataSet.getMemo())) {
      // マージキー[Mergekey]が有り場合
      String[] result = sysDataSet.getMemo().split("Mergekey");
      if (result.length >= 2) {
        String tmpkey = result[1];
        int startIndex = tmpkey.indexOf("[");
        int endIndex = tmpkey.indexOf("]");
        if (startIndex >= 0 && endIndex > 0 && endIndex> startIndex) {
          mergeKey = tmpkey.substring(startIndex+1, endIndex-1);
        }
      }
    }
    return mergeKey;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<Map<String, Object>> getDataListContainsError(Long sqlCode, Map<String, Object> paramDataKey,UseApplication targetApplication)  {
    return this.getDataListContainsError(sqlCode, paramDataKey, targetApplication, 0);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<Map<String, Object>> getDataListContainsError(Long sqlCode, Map<String, Object> paramDataKey,
                                                          UseApplication targetApplication, int noderedTimeOut)  {

    // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
    //add 8530 2023-04-06 zhaoqj メソッド内で参照データを修正すると、次の呼び出しフォーマットが乱れます start
    Map<String,Object> dataKey = new HashMap<>();
    // add #11951 紹介状画面でカテゴリ「処方(最新)」が出力されなくなっている 高 start
    if(sqlCode == 223L && !paramDataKey.containsKey("prescriptionClassList")){
      List<String> list =new ArrayList();
      list.add("1");
      list.add("2");
      paramDataKey.put("prescriptionClassList",list);
    }
    // add #11951 紹介状画面でカテゴリ「処方(最新)」が出力されなくなっている 高 end
    dataKey.putAll(paramDataKey);
    //add 8530 2023-04-06 zhaoqj メソッド内で参照データを修正すると、次の呼び出しフォーマットが乱れます end
    // SysDataSetを取得する
    SysDataSet sysDataSet = getSysDataSet(sqlCode);
    // add #11435 並び替えキー「医材／薬剤」の仕様見直し 高 start
    if (sqlCode == 17L) {
      SysDataSet sysDataSet16 = getSysDataSet(16L);
      sysDataSet.setDetailInfo(sysDataSet16.getDetailInfo());
    } else if (sqlCode == 243L) {
      SysDataSet sysDataSet16 = getSysDataSet(11L);
      sysDataSet.setDetailInfo(sysDataSet16.getDetailInfo());
    } else if (sqlCode == 244L) {
      SysDataSet sysDataSet16 = getSysDataSet(206L);
      sysDataSet.setDetailInfo(sysDataSet16.getDetailInfo());
    }
    // add #11679 複数患者帳票で「透析条件.補液量」が出ない 20250417 高　start
    // del #12394 複数患者帳票で検査結果の前回値を比較することができない 高 start
//    else if (sqlCode == 246L) {
//      SysDataSet sysDataSet16 = getSysDataSet(29L);
//      sysDataSet.setDetailInfo(sysDataSet16.getDetailInfo());
//    }
    // del #12394 複数患者帳票で検査結果の前回値を比較することができない 高 end
    else if (sqlCode == 247L) {
      SysDataSet sysDataSet16 = getSysDataSet(31L);
      sysDataSet.setDetailInfo(sysDataSet16.getDetailInfo());
    }
    // add #11679 複数患者帳票で「透析条件.補液量」が出ない 20250417 高　end
    // add #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　start
    else if (sqlCode == 248L) {
      SysDataSet sysDataSet16 = getSysDataSet(2L);
      sysDataSet.setDetailInfo(sysDataSet16.getDetailInfo());
    }
    else if (sqlCode == 249L) {
      SysDataSet sysDataSet16 = getSysDataSet(3L);
      sysDataSet.setDetailInfo(sysDataSet16.getDetailInfo());
    }
    else if (sqlCode == 250L) {
      SysDataSet sysDataSet16 = getSysDataSet(95L);
      sysDataSet.setDetailInfo(sysDataSet16.getDetailInfo());
    }
    // add #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　end
    // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない 高　start
    // del #11623 ord_material_saveに薬剤や医材の登録順情報がない sunsy start
//    if (sqlCode == 252L) {
//      SysDataSet sysDataSet16 = getSysDataSet(251L);
//      sysDataSet.setDetailInfo(sysDataSet16.getDetailInfo());
//    } else if (sqlCode == 254L) {
//      SysDataSet sysDataSet16 = getSysDataSet(253L);
//      sysDataSet.setDetailInfo(sysDataSet16.getDetailInfo());
//    }
    // del #11623 ord_material_saveに薬剤や医材の登録順情報がない sunsy end
    // add #11789 【因島】準備リストを医材と薬剤と分けて出力することができない 高　end
    // add #11435 並び替えキー「医材／薬剤」の仕様見直し 高 end
    // add 10708 by kangjie 20240613 start
    if (sqlCode == 228L && SysDataSet.DB_CLASS_DB5.equals(sysDataSet.getDbClass())) {
      String sql = sysDataSet.getSql();
      Config config = defaultDbConfig;
      SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
      List<Map<String, Object>> reportInfo = sysDataSetDao.executeSql(selectBuilder);
      // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
      if (dataKey != null ) {
        String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
        if (!StringUtils.isEmpty(facilityCd)) {
          eventLogMessage.setFacilityCd(facilityCd);
        }
      }
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
      // 発信前
      if (CollectionUtils.isNotEmpty(reportInfo) && reportInfo.get(0) != null
        && Objects.equals("0",reportInfo.get(0).get("rst_dialysis_state").toString())) {
        sysDataSet = getSysDataSet(229L);

      }
    }
    // add 10708 by kangjie 20240613 end
    // add 7704 帳票が生成されない 姜 start
    if (sysDataSet == null) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("指定されたsqlCodeにSQLが登録されていません。sqlCd:" + sqlCode);
      Map<String, Object> map = new HashMap<String, Object>();
      map.put("error", eventLogMessage.getLogMessage());
      List<Map<String, Object>> errData = new ArrayList<Map<String, Object>>();
      errData.add(map);
      return errData;
    }
    // add 7704 帳票が生成されない 姜 end
    /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
    // // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
    // // マージキーの取得
    // if (!StringUtils.isEmpty(sysDataSet.getMemo())) {
    //   // マージキー[Mergekey]が有り場合
    //   String[] result = sysDataSet.getMemo().split("Mergekey");
    //   if (result.length >= 2) {
    //     String tmpkey = result[1];
    //     int startIndex = tmpkey.indexOf("[");
    //     int endIndex = tmpkey.indexOf("]");
    //     if (startIndex >= 0 && endIndex > 0 && endIndex> startIndex) {
    //       mergeKey = tmpkey.substring(startIndex+1, endIndex-1);
    //     }
    //   }
    // }
    // // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
    /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */

    // 使用用途のチェック
    checkUseApplication(sysDataSet.getUseApplication(), targetApplication);

    // 事前実行SQLがあれば実行して結果をパラメータに追加
    dataKey = this.preExecSql(sysDataSet.getPreSqlInfo(), dataKey);
    // add #5717 李明揚 start
//    if (sysDataSet.getSqlCd() == 10 && dataKey.get("ordNos") == null){
//      String ordNo = dataKey.get("ordNo").toString();
//      List<String> ordnos = new ArrayList<String>(){
//        {add(ordNo);}
//      };
//      dataKey.put("ordNos",ordnos);
//    }
    // mod #7233 特定のデータ入力時に空のポインタ例外が発生することを回避する yumingyang start
    if (sysDataSet.getSqlCd() == 10 && dataKey.get("ordNos") == null){
      List<String> ordnos = new ArrayList<String>();
      if(!(dataKey.get("ordNo") == null)){
        String ordNo = dataKey.get("ordNo").toString();
        ordnos.add(ordNo);
      }
      dataKey.put("ordNos",ordnos);
    }
    // mod #7233 特定のデータ入力時に空のポインタ例外が発生することを回避する yumingyang end
    // add #5717 李明揚 end

    Integer dbClass = sysDataSet.getDbClass();

    // SelectBuilderを作成し実行する
    // add #6304 ローカルDBへの登録に失敗する start
    List<Map<String, Object>> reportInfo = new ArrayList<>();
    // add #6304 ローカルDBへの登録に失敗する end
    String sql = sysDataSet.getSql();
    // SQLに何も登録されていない場合、空の結果を返す.
    if (StringUtils.isEmpty(sql)) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("指定されたsqlCodeにSQLが登録されていません。sqlCd:" + sqlCode);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
//      return new ArrayList<Map<String, Object>>();
      Map<String, Object> map = new HashMap<String, Object>();
      map.put("error", eventLogMessage.getLogMessage());
      List<Map<String, Object>> errData = new ArrayList<Map<String, Object>>();
      errData.add(map);
      return errData;
      // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
    }

    // SQL実行でエラーが発生しても、後続処理を継続する.
    try {
      // add 2021-03-23 外部連携：定時一括送信機能の複数データの対応。 孫 start
      // mst_coop_layoutのcoop_ext_settingのdatasetに事前処理用SQLの結果が複数データか
      if (sysDataSet.getPreSqlInfo() != null && sysDataSet.getPreSqlInfo().getItems().size() > 0
        && dataKey.containsKey(ReportConstant.PreSqlInfoItem)) {

        List<String> preSqlInfoItem = (List<String>)dataKey.get(ReportConstant.PreSqlInfoItem);
        List<Object> itemForCnt = (List<Object>)dataKey.get(preSqlInfoItem.get(0));

        List<Map<String, Object>> preItemList = new ArrayList<>();
        for (int i=0; i<itemForCnt.size(); i++) {
          Map<String, Object> preItemMap = new HashMap<String, Object>();
          for (int j=0; j<preSqlInfoItem.size(); j++) {
            String preItemKey = (String)preSqlInfoItem.get(j);
            List<Object> preItem = (List<Object>)dataKey.get(preItemKey);
            Object preItemValus = preItem.get(i);

            preItemMap.put(preItemKey, preItemValus);
          }

          preItemList.add(preItemMap);
        }

        List<Map<String, Object>> reportInfoAll = new ArrayList<>();
        for (int k=0; k<preItemList.size(); k++) {
          Map<String, Object> preItemMap = preItemList.get(k);
          Set<String> keySet = preItemMap.keySet();
          for (String key : keySet) {
            dataKey.replace(key, preItemMap.get(key));
          }

          if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
            Config config = defaultDbConfig;
            SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
            if(noderedTimeOut > 0){
              selectBuilder.queryTimeout(noderedTimeOut);
            }
            reportInfo = sysDataSetDao.executeSql(selectBuilder);
            // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
            if (dataKey != null ) {
              String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
              if (!StringUtils.isEmpty(facilityCd)) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
            }
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
          } else if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
            Config config = personalDbConfig;
            SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
            if(noderedTimeOut > 0){
              selectBuilder.queryTimeout(noderedTimeOut);
            }
            reportInfo = sysDataSetPersonalDao.executeSql(selectBuilder);
            // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
            if (dataKey != null ) {
              String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
              if (!StringUtils.isEmpty(facilityCd)) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
            }
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
          } else if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
            Config config = authDbConfig;
            SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
            if(noderedTimeOut > 0){
              selectBuilder.queryTimeout(noderedTimeOut);
            }
            reportInfo = sysDataSetAuthorityDao.executeSql(selectBuilder);
            // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
            if (dataKey != null ) {
              String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
              if (!StringUtils.isEmpty(facilityCd)) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
            }
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            // 課題追加5_MongoDB追加対応 2021/04/20 add start ウ
          } else if (SysDataSet.DB_CLASS_MONGODB.equals(dbClass)) {

            Map<String, Object> mongoDBDataKey = new HashMap<String, Object>();
            // 5994_指示履歴の取得について 2021/08/13 mod start 李
            for (String key: dataKey.keySet()) {
              sql = sql.replace("@"+ key,dataKey.get(key) == null?"":dataKey.get(key).toString());
            }
            mongoDBDataKey = this.createSelectParameter(sql, mongoDBDataKey);
            // 5994_指示履歴の取得について 2021/08/13 mod end 李
            reportInfo = getMongoDBData(mongoDBDataKey);
            // 課題追加5_MongoDB追加対応 2021/04/20 add end ウ
          } else {
            throw new NtssException("想定しないDB種別が指定されています。");
          }
          if (reportInfo != null && reportInfo.size() != 0) {
            reportInfoAll.addAll(reportInfo);
          }
        }
        // 5994_指示履歴の取得について 2021/08/13 add start 李
        if (SysDataSet.DB_CLASS_MONGODB.equals(dbClass)){
          return replaceReportInfoMongo(reportInfoAll, sysDataSet.getDetailInfo().getDetails());
        }
        // 5994_指示履歴の取得について 2021/08/13 add end 李
        // 帳票出力情報を返却用に置き換える（フィールド名をデータ項目コードに置き換える）
        return replaceReportInfo(reportInfoAll, sysDataSet.getDetailInfo().getDetails());
      } else {
        // add 2021-03-23 外部連携：定時一括送信機能の複数データの対応。 孫 end
        if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
          Config config = defaultDbConfig;
          // add #7422 「ブラウザ立ち上げ直後に帳票プレビューを表示すると、内容が表示されない」について、対応する 鄧シン start
          // mod #7422 「ブラウザ立ち上げ直後に帳票プレビューを表示すると、内容が表示されない」について、再修正 鄧シン start
          // String data = dataKey.get("fromDate").toString();
          // if (!data.contains("/")){
          // add #6468 複数集計：プレビューでシステムエラー 鄭爽 start
          if (sqlCode != 149L) {
            // add #6468 複数集計：プレビューでシステムエラー 鄭爽 end
            Object data = dataKey.get("fromDate");
            if (UseApplication.SHARE_VIEW != targetApplication && data != null && !data.toString().contains("/")){
              // mod #7422 「ブラウザ立ち上げ直後に帳票プレビューを表示すると、内容が表示されない」について、再修正 鄧シン end
              SimpleDateFormat formater = new SimpleDateFormat("yyyyMMdd");
              formater.setLenient(false);
              // mod #7422 「ブラウザ立ち上げ直後に帳票プレビューを表示すると、内容が表示されない」について、再修正 鄧シン start
              // Date d = formater.parse(data);
              // mod Aspose.cells関連問題対応 商 start
              //Date d = formater.parse(data.toString());
              Date d = formater.parse(data.toString().replace("-",""));
              // mod Aspose.cells関連問題対応 商 start
              // mod #7422 「ブラウザ立ち上げ直後に帳票プレビューを表示すると、内容が表示されない」について、再修正 鄧シン end
              formater = new SimpleDateFormat("yyyy/MM/dd");
              String toData = formater.format(d);
              dataKey.put("fromDate", toData);
            }
            // add #6468 複数集計：プレビューでシステムエラー 鄭爽 start
          }
          // add #6468 複数集計：プレビューでシステムエラー 鄭爽 end
          // add #7422 「ブラウザ立ち上げ直後に帳票プレビューを表示すると、内容が表示されない」について、対応する 鄧シン end
          // add #9323 帳票「並び替え」機能のオーバーホール　高 start
          // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 start
//          if(dataKey.get("reportClass") != null && ReportConstant.ReportClass.LABEL_REPORT.equals(dataKey.get("reportClass")) && sql.contains("@orderBy")){
          if(dataKey.get("reportClass") != null &&
            (ReportConstant.ReportClass.LABEL_REPORT.equals(dataKey.get("reportClass")) ||
              ReportConstant.ReportClass.PREPARATION_LIST_REPORT.equals(dataKey.get("reportClass"))||
              ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT.equals(dataKey.get("reportClass"))) &&
            sql.contains("@orderBy")){
            // mod #11435 並び替えキー「医材／薬剤」の仕様見直し 高 end
            sql = sql.replace("@orderBy",dataKey.get("orderBy").toString());
          }
          // add #9323 帳票「並び替え」機能のオーバーホール　高 end
          SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
          if(noderedTimeOut > 0){
            selectBuilder.queryTimeout(noderedTimeOut);
          }
          reportInfo = sysDataSetDao.executeSql(selectBuilder);
          // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
          if (dataKey != null ) {
            String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
            if (!StringUtils.isEmpty(facilityCd)) {
              eventLogMessage.setFacilityCd(facilityCd);
            }
          }
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
        } else if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
          Config config = personalDbConfig;
          SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
          if(noderedTimeOut > 0){
            selectBuilder.queryTimeout(noderedTimeOut);
          }
          reportInfo = sysDataSetPersonalDao.executeSql(selectBuilder);
          // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
          if (dataKey != null ) {
            String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
            if (!StringUtils.isEmpty(facilityCd)) {
              eventLogMessage.setFacilityCd(facilityCd);
            }
          }
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
        } else if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
          Config config = authDbConfig;
          SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
          if(noderedTimeOut > 0){
            selectBuilder.queryTimeout(noderedTimeOut);
          }
          reportInfo = sysDataSetAuthorityDao.executeSql(selectBuilder);
          // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
          if (dataKey != null ) {
            String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
            if (!StringUtils.isEmpty(facilityCd)) {
              eventLogMessage.setFacilityCd(facilityCd);
            }
          }

          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
          // 課題追加5_MongoDB追加対応 2021/04/20 add start ウ
        } else if (SysDataSet.DB_CLASS_MONGODB.equals(dbClass)) {
          //add IES因島）sql性能試験 後で削除 liuc start
          String sqlTestSign = (String) dataKey.get("sqlTestSign");
          Date beginTime = null;
          if(!StringUtils.isEmpty(sqlTestSign)){
            beginTime = new Date();
          }
          //add IES因島）sql性能試験 後で削除 liuc end

          Map<String, Object> mongoDBDataKey = new HashMap<String, Object>();
          // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
          // treatDateに"-"、"/"を削除する
          // mod #7641 自動印刷で値が入らない項目がある 王永吉 start
          // if (dataKey.containsKey("treatDate")){
          // dataKey.replace("treatDate", dataKey.get("treatDate").toString().replace("-", "").replace("/", ""));
          // }
          String strFromDate = "";
          // mod #10740 指示.修正内容の出力不正 sunsy start
          String strToDate = "";
          if (sql.contains("ind_history") && !sql.contains("treatment_start_date") && !sql.contains("treatment_end_date")) {
            // 指示履歴専用のfromdate取得処理、発症日のフォーマットが「yyyyMMddHHmmssSSS」であり、日付により抽出を満足するため、開始日を「yyyyMMdd000000000」にする
            if (dataKey.containsKey("fromDate") && !"".equals(dataKey.get("fromDate")) && null != dataKey.get("fromDate")) {
              strFromDate = dataKey.get("fromDate").toString().replace("-", "").replace("/", "");
              SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
              String dofromDate = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(df.parse(strFromDate));
              dataKey.replace("fromDate", dofromDate);
            }
            // 指示履歴専用のtodate取得処理、発症日のフォーマットが「yyyyMMddHHmmssSSS」であり、日付により抽出を満足するため、終了日を「yyyyMMdd235959999」にする
            if (dataKey.containsKey("endDate") && !"".equals(dataKey.get("endDate")) && null != dataKey.get("endDate")) {
              strToDate = dataKey.get("endDate").toString().replace("-", "").replace("/", "");
              SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
              Date dateToDate = df.parse(strToDate);
              Calendar calendar = Calendar.getInstance();
              calendar.setTime(dateToDate);
              calendar.set(Calendar.HOUR_OF_DAY, 23);
              calendar.set(Calendar.MINUTE, 59);
              calendar.set(Calendar.SECOND, 59);
              calendar.set(Calendar.MILLISECOND, 999);
              String dotoDate = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(calendar.getTime());
              dataKey.put("endDate", dotoDate);
            } else if (dataKey.containsKey("toDate") && !"".equals(dataKey.get("toDate")) && null != dataKey.get("toDate")) {
              strToDate = dataKey.get("toDate").toString().replace("-", "").replace("/", "");
              SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
              Date dateToDate = df.parse(strToDate);
              Calendar calendar = Calendar.getInstance();
              calendar.setTime(dateToDate);
              calendar.set(Calendar.HOUR_OF_DAY, 23);
              calendar.set(Calendar.MINUTE, 59);
              calendar.set(Calendar.SECOND, 59);
              calendar.set(Calendar.MILLISECOND, 999);
              String dotoDate = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(calendar.getTime());
              dataKey.put("endDate", dotoDate);
            }
          }else if (sql.contains("ind_history") && sql.contains("treatment_start_date") && sql.contains("treatment_end_date")) {
            if (dataKey.containsKey("fromDate") && !"".equals(dataKey.get("fromDate")) && null != dataKey.get("fromDate")) {
              strFromDate = dataKey.get("fromDate").toString().replace("-", "").replace("/", "");
              dataKey.replace("fromDate", strFromDate);
            }
            if (dataKey.containsKey("endDate") && !"".equals(dataKey.get("endDate")) && null != dataKey.get("endDate")) {
              strToDate = dataKey.get("endDate").toString().replace("-", "").replace("/", "");
              dataKey.put("endDate", strToDate);
            }else if (dataKey.containsKey("toDate") && !"".equals(dataKey.get("toDate")) && null != dataKey.get("toDate")) {
              strToDate = dataKey.get("toDate").toString().replace("-", "").replace("/", "");
              dataKey.put("endDate", strToDate);
            }
          }else {
            // add #10645 mongoDBのSQLでup_dateの比較が@fromDateと@toDateと混在している sunsy start
            if (dataKey.containsKey("fromDate") && !"".equals(dataKey.get("fromDate")) && null != dataKey.get("fromDate")) {
              dataKey.replace("fromDate", dataKey.get("fromDate").toString().replace("-", "").replace("/", ""));
              strFromDate = dataKey.get("fromDate").toString();
            }
            // add #10645 mongoDBのSQLでup_dateの比較が@fromDateと@toDateと混在している sunsy end
            // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
            if (dataKey.containsKey("toDate") && !"".equals(dataKey.get("toDate")) && null != dataKey.get("toDate")) {
              dataKey.replace("toDate", dataKey.get("toDate").toString().replace("-", "").replace("/", ""));
              strFromDate = dataKey.get("toDate").toString();
            } else
              // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
              if (dataKey.containsKey("fromDate") && !"".equals(dataKey.get("fromDate")) && null != dataKey.get("fromDate")) {
                dataKey.put("toDate", dataKey.get("fromDate").toString().replace("-", "").replace("/", ""));
                strFromDate = dataKey.get("toDate").toString();
              }
            // mod #7641 自動印刷で値が入らない項目がある 王永吉 end
          }
          // mod #10740 指示.修正内容の出力不正 sunsy end

          String doDetailInfoWord = "";
          // detail取得
          if (!sql.endsWith("}}")){
            String a = sql.substring(0, sql.lastIndexOf("}"));
            String b = a.substring(a.lastIndexOf("}") + 1, a.length());
            doDetailInfoWord = b.substring(1, b.length());
            sql = sql.replace(b, "");
            // add #6886 帳票の患者情報が過去日付時点の内容で表示できない 鄭爽 start
            SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
            // add #6886 帳票の患者情報が過去日付時点の内容で表示できない 鄭爽 end
            // add #10645 mongoDBのSQLでup_dateの比較が@fromDateと@toDateと混在している sunsy start
            if (dataKey.containsKey("fromDate")) {
              String doFromDate = new SimpleDateFormat("yyyy-MM-dd").format(df.parse(dataKey.get("fromDate").toString())) + " 23:59:59";
              dataKey.replace("fromDate", doFromDate);
            }
            // add #10645 mongoDBのSQLでup_dateの比較が@fromDateと@toDateと混在している sunsy end
            // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
            if (dataKey.containsKey("toDate")){
              String dotoDate = new SimpleDateFormat("yyyy-MM-dd").format(df.parse(dataKey.get("toDate").toString())) + " 23:59:59";
              dataKey.replace("toDate", dotoDate);
            } else
              // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
              if (dataKey.containsKey("fromDate")){
                // mod #6886 帳票の患者情報が過去日付時点の内容で表示できない 鄭爽 start
                // String doFromDate = dataKey.get("fromDate") + " 23:59:59";
                String dotoDate = new SimpleDateFormat("yyyy-MM-dd").format(df.parse(dataKey.get("fromDate").toString())) + " 23:59:59";
                // mod #6886 帳票の患者情報が過去日付時点の内容で表示できない 鄭爽 end
                // mod #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
                // dataKey.replace("fromDate", doFromDate);
                dataKey.put("toDate", dotoDate);
                // mod #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
              }
          }
          // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
          // 5994_指示履歴の取得について 2021/08/13 mod start 李
          // mod #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
//          for (String key: dataKey.keySet()) {
//            sql = sql.replace("@" + key, dataKey.get(key) == null ? "" : dataKey.get(key).toString());
//          }
          List<String> keys = new ArrayList<>(dataKey.keySet());
          keys.sort((a, b) -> Integer.compare(b.length(), a.length()));
          for (String key : keys) {
            Object value = dataKey.get(key);
            String replacement;
            if (value instanceof List) {
              List<?> list = (List<?>) value;
              replacement = "(" + list.stream()
                .map(Object::toString)
                .reduce((a, b) -> a + "," + b)
                .orElse("") + ")";
            } else if (value instanceof Object[]) {
              Object[] arr = (Object[]) value;
              replacement = "(" + String.join(",",
                Arrays.stream(arr).map(Object::toString).toArray(String[]::new))
                + ")";
            }
            else {
              replacement = value == null ? "" : value.toString();
            }
            sql = sql.replace("@" + key, replacement);
            // mod #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
          }
          // add 10210 帳票における患者情報の取得元について sunsy start
          // mod #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy start
//          if (sql.contains("@insuranceCd")) {
          if (sql.contains("@insuranceCd") && sysDataSet.getMemo().contains("処方(最新)")) {
          // mod #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy end
            Long ordPrescriptionNo = ordPrescriptionDao.getOrdPrescriptionNoOne(Long.parseLong(String.valueOf(dataKey.get("patId"))), String.valueOf(dataKey.get("fromDate")), String.valueOf(dataKey.get("facilityCd")));
            OrdPersonalPrescription ordPersonalPrescription = ordPersonalPrescriptionDao.selectByOrdPrescriptionNo(ordPrescriptionNo);
            sql = sql.replace("@insuranceCd", String.valueOf(ordPersonalPrescription.getInsuranceCd()));
            // add #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240620 sunsy start
            sql = sql.replace("@upDate", String.valueOf(ordPersonalPrescription.getUpDate()));
            // add #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240620 sunsy end
          }
          // add 10210 帳票における患者情報の取得元について sunsy end
          // add #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy start
          if (sql.contains("@insuranceCd") && sysDataSet.getMemo().contains("処方")) {
            if (dataKey.containsKey("ordPrescriptionNos") || dataKey.get("ordPrescriptionNos") != null) {
              List ordPreList = (List) dataKey.get("ordPrescriptionNos");
              Long ordPrescriptionNo = Long.parseLong(String.valueOf(ordPreList.get(0)));
              OrdPersonalPrescription ordPersonalPrescription = ordPersonalPrescriptionDao.selectByOrdPrescriptionNo(ordPrescriptionNo);
              sql = sql.replace("@insuranceCd", String.valueOf(ordPersonalPrescription.getInsuranceCd()));
              // add #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240620 sunsy start
              sql = sql.replace("@upDate", String.valueOf(ordPersonalPrescription.getUpDate()));
              // add #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240620 sunsy end
            }
          }
          // add #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy end
          mongoDBDataKey = this.createSelectParameter(sql, mongoDBDataKey);
          // 5994_指示履歴の取得について 2021/08/13 mod end 李
          reportInfo = getMongoDBData(mongoDBDataKey);
          // 課題追加5_MongoDB追加対応 2021/04/20 add end ウ
          // add 10210 帳票における患者情報の取得元について sunsy start
          // del #9650 治療経過表、カテゴリ「患者情報」の項目出力不正 limingzhe start
//          if (null != reportInfo && reportInfo.size() > 0 && "1".equals(reportInfo.get(0).get("is_del")) && "14".equals(sqlCode.toString())) {
//              reportInfo.clear();
//          }
          // del #9650 治療経過表、カテゴリ「患者情報」の項目出力不正 limingzhe end
          // add 10210 帳票における患者情報の取得元について sunsy end
          // add #10645 mongoDBのSQLでup_dateの比較が@fromDateと@toDateと混在している sunsy start
          if (dataKey.containsKey("fromDate") && !"".equals(dataKey.get("fromDate"))) {
            dataKey.replace("fromDate", dataKey.get("fromDate").toString().replace("-", "").replace("/", ""));
          }
          // add #10645 mongoDBのSQLでup_dateの比較が@fromDateと@toDateと混在している sunsy end
          // add #6886 帳票の患者情報が過去日付時点の内容で表示できない 鄭爽 start
          // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
          if (dataKey.containsKey("toDate") && !"".equals(dataKey.get("toDate"))) {
            dataKey.replace("toDate", dataKey.get("toDate").toString().replace("-", ""));
          } else
            // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
            if (dataKey.containsKey("fromDate") && !"".equals(dataKey.get("fromDate"))) {
              // mod #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
              // dataKey.replace("fromDate", dataKey.get("fromDate").toString().replace("-", ""));
              dataKey.put("toDate", dataKey.get("fromDate").toString().replace("-", ""));
              // mod #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
            }
          // add #6886 帳票の患者情報が過去日付時点の内容で表示できない 鄭爽 end
          // add #10210 帳票における患者情報の取得元について sunsy start
          String facilityCd = "";
          if (dataKey.containsKey("facilityCd") && !"".equals(dataKey.get("facilityCd"))) {
            facilityCd = dataKey.get("facilityCd").toString();
          }
          // add #10210 帳票における患者情報の取得元について sunsy end

          //add IES因島）sql性能試験 後で削除 liuc start
          if(beginTime != null){
            Date endTime = new Date();
            EventLogMessage LogMessage = new EventLogMessage();
            LogMessage.setLogMessage(sqlTestSign + "SysDataSetServiceImpl::getDataListContainsError "
              + sqlCode + ": MongoDB実行時間:" + (endTime.getTime() - beginTime.getTime()) + "ms");
            logService.log(LogLevel.INFO, LogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
          }
          //add IES因島）sql性能試験 後で削除 liuc end
          // add #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　start
          if("pat_memo_info".equals(doDetailInfoWord)){
            SelectOptions selectOptions = SelectOptions.get();
            MstPatMemo params = new MstPatMemo();
            params.setFacilityCd(String.valueOf(dataKey.get("facilityCd")));
            List<MstPatMemo> list = mstPatMemoDao.selectAll(selectOptions, params);
            if(list != null && list.size() > 0){
              for (Map<String, Object> map : reportInfo) {
                if(map.containsKey("pat_memo_info")){
                  List<Map<String, Object>> reportInfoDetailInfoWord = map.get("pat_memo_info") != null ? (List<Map<String, Object>>)map.get("pat_memo_info") : new LinkedList<>();
                  List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
                  for (int d = 0; d < reportInfoDetailInfoWord.size(); d++){
                    Map<String, Object> currentMap = reportInfoDetailInfoWord.get(d);
                    if(currentMap.containsKey("ctl_no")){
                      for(MstPatMemo mstPatMemo : list){
                        if(String.valueOf(mstPatMemo.getPatMemoNo()).equals(currentMap.get("ctl_no").toString())){
                          if ("1".equals(mstPatMemo.getIsDisp()) && "0".equals(mstPatMemo.getIsDel())){
                            reportInfoDetailInfoWordMiddle.add(currentMap);
                          }
                        }
                      }
                    }
                  }
                  map.put("pat_memo_info", reportInfoDetailInfoWordMiddle);
                }
              }
            }
          }
          // add #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　end
          // MongoDBのデータ置き換え処理を実施
          // mod #10210 帳票における患者情報の取得元について sunsy start
//          reportInfo = replaceDataForMongDb(doDetailInfoWord, reportInfo, sql, strFromDate, sysDataSet);
          if (null != reportInfo && reportInfo.size() > 0) {
            // mod #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 start
            // reportInfo = replaceDataForMongDb(doDetailInfoWord, reportInfo, sql, strFromDate, sysDataSet, facilityCd);
            dataKey.put("strFromDate",strFromDate);
            // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
            if(mongoDBDataKey.containsKey("in")){
              List<Map<String, Object>> infoRes = new ArrayList<>();
              for (Map<String, Object> map : reportInfo) {
                List<Map<String, Object>> resultsNewTmpOne = new ArrayList<>();
                resultsNewTmpOne.add(map);
                resultsNewTmpOne = replaceDataForMongDb(doDetailInfoWord, resultsNewTmpOne, sql, sysDataSet, dataKey);
                if(resultsNewTmpOne != null && resultsNewTmpOne.size() > 0) infoRes.addAll(resultsNewTmpOne);
              }
              reportInfo = infoRes;
            }
            else {
            // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
              reportInfo = replaceDataForMongDb(doDetailInfoWord, reportInfo, sql, sysDataSet,dataKey);
            // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
            }
            // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
            // mod #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 end
          }
          // mod #10210 帳票における患者情報の取得元について sunsy end
        } else {
          throw new NtssException("想定しないDB種別が指定されています。");
        }
        //add 10708 by kangjie 20240613 start
        if (sysDataSet.getSqlCd() == 229L) {
          SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
          //  treatment day time
          String treatDate = ((String) paramDataKey.get("treatDate")).replace("-", "").replace("/", "");
          // A piece of data that is less than  closest to the treatment day time
          Optional<Map<String, Object>> result = reportInfo.stream().filter(m -> {
            try {
              Date treatDateParse = sdf.parse(treatDate);
              String examDate = (String) m.get("exam_date");
              String substring = examDate.replace("-", "").substring(0, 8);
              return sdf.parse(substring).getTime() <= treatDateParse.getTime();
            } catch (ParseException e) {
              throw new RuntimeException(e);
            }
          }).sorted(Comparator.comparing(m -> {
            try {
              Date targetDate = sdf.parse(treatDate);
              String examDate = (String) m.get("exam_date");
              String substring = examDate.replace("-", "").substring(0, 8);
              Date currentDate = sdf.parse(substring);
              return Math.abs(targetDate.getTime() - currentDate.getTime());
            } catch (ParseException e) {
              throw new RuntimeException(e);
            }
          })).findFirst();
          if (result.isPresent()) {
            String indicatorName = result.get().get("indicator_name") == null ? "" : result.get().get("indicator_name").toString();
            String changerName = result.get().get("changer_name")==null?"":result.get().get("changer_name").toString();
            List<Map<String,Object>> list = new ArrayList<>();
            Map<String,Object> map = new HashMap<>();
            map.put("ind_user_name",indicatorName);
            map.put("upd_user_name",changerName);
            list.add(map);
            reportInfo = list;
          }
        }
        //add 10708 by kangjie 20240613 end
        // 帳票出力情報を返却用に置き換える（フィールド名をデータ項目コードに置き換える）
        return replaceReportInfo(reportInfo, sysDataSet.getDetailInfo().getDetails());
        // add 2021-03-23 外部連携：定時一括送信機能の複数データの対応。 孫 start
      }
      // add 2021-03-23 外部連携：定時一括送信機能の複数データの対応。 孫 start
    } catch (Exception ex) {
      // 例外が発生した場合には、空のリストを返却する.
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("帳票用のデータ取得に失敗しました。sqlCd:" + sqlCode);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
//      return new ArrayList<Map<String, Object>>();
      Map<String, Object> map = new HashMap<String, Object>();
      map.put("error", eventLogMessage.getLogMessage());
      List<Map<String, Object>> errData = new ArrayList<Map<String, Object>>();
      errData.add(map);
      return errData;
      // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
    }
  }

  //#dev 6304 ローカルDBへの登録に失敗する sichengbo start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<Map<String, Object>> getDataListSpecialTreatment(Long sqlCode, Map<String, Object> paramDataKey,
                                                               UseApplication targetApplication, int limit, int num)  {
    // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
    //add 8530 2023-04-06 zhaoqj メソッド内で参照データを修正すると、次の呼び出しフォーマットが乱れます start
    Map<String,Object> dataKey = new HashMap<>();
    dataKey.putAll(paramDataKey);
    //add 8530 2023-04-06 zhaoqj メソッド内で参照データを修正すると、次の呼び出しフォーマットが乱れます end
    // SysDataSetを取得する
    SysDataSet sysDataSet = getSysDataSet(sqlCode);
    // add 7704 帳票が生成されない 姜 start
    if (sysDataSet == null) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("指定されたsqlCodeにSQLが登録されていません。sqlCd:" + sqlCode);
      Map<String, Object> map = new HashMap<String, Object>();
      map.put("error", eventLogMessage.getLogMessage());
      List<Map<String, Object>> errData = new ArrayList<Map<String, Object>>();
      errData.add(map);
      return errData;
    }
    // add 7704 帳票が生成されない 姜 end
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
    String doDetailInfoWord = "";
    // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
    /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
    // // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
    // // マージキーの取得
    // if (!StringUtils.isEmpty(sysDataSet.getMemo())) {
    //   // マージキー[Mergekey]が有り場合
    //   String[] result = sysDataSet.getMemo().split("Mergekey");
    //   if (result.length >= 2) {
    //     String tmpkey = result[1];
    //     int startIndex = tmpkey.indexOf("[");
    //     int endIndex = tmpkey.indexOf("]");
    //     if (startIndex >= 0 && endIndex > 0 && endIndex> startIndex) {
    //       mergeKey = tmpkey.substring(startIndex+1, endIndex-1);
    //     }
    //   }
    // }
    // // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
    /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */

    // 使用用途のチェック
    checkUseApplication(sysDataSet.getUseApplication(), targetApplication);

    // 事前実行SQLがあれば実行して結果をパラメータに追加
    dataKey = this.preExecSql(sysDataSet.getPreSqlInfo(), dataKey);
    // add #5717 李明揚 start
//    if (sysDataSet.getSqlCd() == 10 && dataKey.get("ordNos") == null){
//      String ordNo = dataKey.get("ordNo").toString();
//      List<String> ordnos = new ArrayList<String>(){
//        {add(ordNo);}
//      };
//      dataKey.put("ordNos",ordnos);
//    }
    // mod #7233 特定のデータ入力時に空のポインタ例外が発生することを回避する yumingyang start
    if (sysDataSet.getSqlCd() == 10 && dataKey.get("ordNos") == null){
      List<String> ordnos = new ArrayList<String>();
      if(!(dataKey.get("ordNo") == null)){
        String ordNo = dataKey.get("ordNo").toString();
        ordnos.add(ordNo);
      }
      dataKey.put("ordNos",ordnos);
    }
    // mod #7233 特定のデータ入力時に空のポインタ例外が発生することを回避する yumingyang end
    // add #5717 李明揚 end

    Integer dbClass = sysDataSet.getDbClass();

    // SelectBuilderを作成し実行する
    // add #6304 ローカルDBへの登録に失敗する start
    List<Map<String, Object>> reportInfo = new ArrayList<>();
    // add #6304 ローカルDBへの登録に失敗する end
    String sql = sysDataSet.getSql();
    // SQLに何も登録されていない場合、空の結果を返す.
    if (StringUtils.isEmpty(sql)) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("指定されたsqlCodeにSQLが登録されていません。sqlCd:" + sqlCode);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
//      return new ArrayList<Map<String, Object>>();
      Map<String, Object> map = new HashMap<String, Object>();
      map.put("error", eventLogMessage.getLogMessage());
      List<Map<String, Object>> errData = new ArrayList<Map<String, Object>>();
      errData.add(map);
      return errData;
      // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
    }

    // SQL実行でエラーが発生しても、後続処理を継続する.
    try {
      // add 2021-03-23 外部連携：定時一括送信機能の複数データの対応。 孫 start
      // mst_coop_layoutのcoop_ext_settingのdatasetに事前処理用SQLの結果が複数データか
      if (sysDataSet.getPreSqlInfo() != null && sysDataSet.getPreSqlInfo().getItems().size() > 0
        && dataKey.containsKey(ReportConstant.PreSqlInfoItem)) {

        List<String> preSqlInfoItem = (List<String>)dataKey.get(ReportConstant.PreSqlInfoItem);
        List<Object> itemForCnt = (List<Object>)dataKey.get(preSqlInfoItem.get(0));

        List<Map<String, Object>> preItemList = new ArrayList<>();
        for (int i=0; i<itemForCnt.size(); i++) {
          Map<String, Object> preItemMap = new HashMap<String, Object>();
          for (int j=0; j<preSqlInfoItem.size(); j++) {
            String preItemKey = (String)preSqlInfoItem.get(j);
            List<Object> preItem = (List<Object>)dataKey.get(preItemKey);
            Object preItemValus = preItem.get(i);

            preItemMap.put(preItemKey, preItemValus);
          }

          preItemList.add(preItemMap);
        }

        List<Map<String, Object>> reportInfoAll = new ArrayList<>();
        for (int k=0; k<preItemList.size(); k++) {
          Map<String, Object> preItemMap = preItemList.get(k);
          Set<String> keySet = preItemMap.keySet();
          for (String key : keySet) {
            dataKey.replace(key, preItemMap.get(key));
          }

          if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
            Config config = defaultDbConfig;
            SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
            reportInfo = sysDataSetDao.executeSql(selectBuilder);
            // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
            if (dataKey != null ) {
              String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
              if (!StringUtils.isEmpty(facilityCd)) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
            }
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
          } else if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
            Config config = personalDbConfig;
            SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
            reportInfo = sysDataSetPersonalDao.executeSql(selectBuilder);
            // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
            if (dataKey != null ) {
              String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
              if (!StringUtils.isEmpty(facilityCd)) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
            }
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
          } else if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
            Config config = authDbConfig;
            SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
            reportInfo = sysDataSetAuthorityDao.executeSql(selectBuilder);
            // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
            if (dataKey != null ) {
              String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
              if (!StringUtils.isEmpty(facilityCd)) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
            }
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
            // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
            // 課題追加5_MongoDB追加対応 2021/04/20 add start ウ
          } else if (SysDataSet.DB_CLASS_MONGODB.equals(dbClass)) {

            Map<String, Object> mongoDBDataKey = new HashMap<String, Object>();
            // 5994_指示履歴の取得について 2021/08/13 mod start 李
            for (String key: dataKey.keySet()) {
              sql = sql.replace("@"+ key,dataKey.get(key) == null?"":dataKey.get(key).toString());
            }
            mongoDBDataKey = this.createSelectParameter(sql, mongoDBDataKey);
            // 5994_指示履歴の取得について 2021/08/13 mod end 李
            reportInfo = getMongoDBData(mongoDBDataKey);
            // 課題追加5_MongoDB追加対応 2021/04/20 add end ウ
          } else {
            throw new NtssException("想定しないDB種別が指定されています。");
          }
          if (reportInfo != null && reportInfo.size() != 0) {
            reportInfoAll.addAll(reportInfo);
          }
        }
        // 5994_指示履歴の取得について 2021/08/13 add start 李
        if (SysDataSet.DB_CLASS_MONGODB.equals(dbClass)){
          return replaceReportInfoMongo(reportInfoAll, sysDataSet.getDetailInfo().getDetails());
        }
        // 5994_指示履歴の取得について 2021/08/13 add end 李
        // 帳票出力情報を返却用に置き換える（フィールド名をデータ項目コードに置き換える）
        return replaceReportInfo(reportInfoAll, sysDataSet.getDetailInfo().getDetails());
      } else {
        // add 2021-03-23 外部連携：定時一括送信機能の複数データの対応。 孫 end
        if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
          Config config = defaultDbConfig;
          // add #7422 「ブラウザ立ち上げ直後に帳票プレビューを表示すると、内容が表示されない」について、対応する 鄧シン start
          // mod #7422 「ブラウザ立ち上げ直後に帳票プレビューを表示すると、内容が表示されない」について、再修正 鄧シン start
          // String data = dataKey.get("fromDate").toString();
          // if (!data.contains("/")){
          // add #6468 複数集計：プレビューでシステムエラー 鄭爽 start
          if (sqlCode != 149L) {
            // add #6468 複数集計：プレビューでシステムエラー 鄭爽 end
            Object data = dataKey.get("fromDate");
            if (UseApplication.SHARE_VIEW != targetApplication && data != null && !data.toString().contains("/")){
              // mod #7422 「ブラウザ立ち上げ直後に帳票プレビューを表示すると、内容が表示されない」について、再修正 鄧シン end
              SimpleDateFormat formater = new SimpleDateFormat("yyyyMMdd");
              formater.setLenient(false);
              // mod #7422 「ブラウザ立ち上げ直後に帳票プレビューを表示すると、内容が表示されない」について、再修正 鄧シン start
              // Date d = formater.parse(data);
              // mod Aspose.cells関連問題対応 商 start
              //Date d = formater.parse(data.toString());
              Date d = formater.parse(data.toString().replace("-",""));
              // mod Aspose.cells関連問題対応 商 start
              // mod #7422 「ブラウザ立ち上げ直後に帳票プレビューを表示すると、内容が表示されない」について、再修正 鄧シン end
              formater = new SimpleDateFormat("yyyy/MM/dd");
              String toData = formater.format(d);
              dataKey.put("fromDate", toData);
            }
            // add #6468 複数集計：プレビューでシステムエラー 鄭爽 start
          }
          // add #6468 複数集計：プレビューでシステムエラー 鄭爽 end
          // add #7422 「ブラウザ立ち上げ直後に帳票プレビューを表示すると、内容が表示されない」について、対応する 鄧シン end
          SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
          reportInfo = sysDataSetDao.executeSql(selectBuilder);
          // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
          if (dataKey != null ) {
            String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
            if (!StringUtils.isEmpty(facilityCd)) {
              eventLogMessage.setFacilityCd(facilityCd);
            }
          }
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
        } else if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
          Config config = personalDbConfig;
          SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
          reportInfo = sysDataSetPersonalDao.executeSql(selectBuilder);
          // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
          if (dataKey != null ) {
            String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
            if (!StringUtils.isEmpty(facilityCd)) {
              eventLogMessage.setFacilityCd(facilityCd);
            }
          }
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
        } else if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
          Config config = authDbConfig;
          SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
          reportInfo = sysDataSetAuthorityDao.executeSql(selectBuilder);
          // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
          if (dataKey != null ) {
            String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
            if (!StringUtils.isEmpty(facilityCd)) {
              eventLogMessage.setFacilityCd(facilityCd);
            }
          }
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
          // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
          // 課題追加5_MongoDB追加対応 2021/04/20 add start ウ
        } else if (SysDataSet.DB_CLASS_MONGODB.equals(dbClass)) {

          Map<String, Object> mongoDBDataKey = new HashMap<String, Object>();
          // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
          // treatDateに"-"、"/"を削除する
          // mod #7641 自動印刷で値が入らない項目がある 王永吉 start
          // if (dataKey.containsKey("treatDate")){
          // dataKey.replace("treatDate", dataKey.get("treatDate").toString().replace("-", "").replace("/", ""));
          // }
          // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
          if (dataKey.containsKey("toDate") && !"".equals(dataKey.get("toDate"))) {
            dataKey.replace("toDate", dataKey.get("toDate").toString().replace("-", "").replace("/", ""));
          } else
            // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
            if (dataKey.containsKey("fromDate") && !"".equals(dataKey.get("fromDate"))) {
              // mod #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
              // dataKey.replace("fromDate", dataKey.get("fromDate").toString().replace("-", "").replace("/", ""));
              dataKey.put("toDate", dataKey.get("fromDate").toString().replace("-", "").replace("/", ""));
              // mod #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
            }
          // mod #7641 自動印刷で値が入らない項目がある 王永吉 end
          // detail取得
          if (!sql.endsWith("}}")){
            String a = sql.substring(0, sql.lastIndexOf("}"));
            String b = a.substring(a.lastIndexOf("}") + 1, a.length());
            doDetailInfoWord = b.substring(1, b.length());
            sql = sql.replace(b, "");
            // add #6886 帳票の患者情報が過去日付時点の内容で表示できない 鄭爽 start
            SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
            // add #6886 帳票の患者情報が過去日付時点の内容で表示できない 鄭爽 end
            // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
            if (dataKey.containsKey("toDate")){
              String dotoDate = new SimpleDateFormat("yyyy-MM-dd").format(df.parse(dataKey.get("toDate").toString())) + " 23:59:59";
              dataKey.replace("toDate", dotoDate);
            } else
              // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
              if (dataKey.containsKey("fromDate")){
                // mod #6886 帳票の患者情報が過去日付時点の内容で表示できない 鄭爽 start
                // String doFromDate = dataKey.get("fromDate") + " 23:59:59";
                String dotoDate = new SimpleDateFormat("yyyy-MM-dd").format(df.parse(dataKey.get("fromDate").toString())) + " 23:59:59";
                // mod #6886 帳票の患者情報が過去日付時点の内容で表示できない 鄭爽 end
                // mod #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
                // dataKey.replace("fromDate", doFromDate);
                dataKey.put("toDate", dotoDate);
                // mod #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
              }
          }
          // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
          // 5994_指示履歴の取得について 2021/08/13 mod start 李
          for (String key: dataKey.keySet()) {
            sql = sql.replace("@" + key, dataKey.get(key) == null ? "" : dataKey.get(key).toString());
          }
          mongoDBDataKey = this.createSelectParameter(sql, mongoDBDataKey);
          // 5994_指示履歴の取得について 2021/08/13 mod end 李
          if (-2410L == sqlCode) {
            reportInfo = getMongoDBDataForIndHistory(mongoDBDataKey, num);
            if (reportInfo.size() == 0) {
              return new ArrayList<>();
            }
            return replaceReportInfoMongo(reportInfo, sysDataSet.getDetailInfo().getDetails());
          } else {
            reportInfo = getMongoDBData(mongoDBDataKey);
          }

          // 課題追加5_MongoDB追加対応 2021/04/20 add end ウ
          // add #6886 帳票の患者情報が過去日付時点の内容で表示できない 鄭爽 start
          // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
          if (dataKey.containsKey("toDate") && !"".equals(dataKey.get("toDate"))) {
            dataKey.replace("toDate", dataKey.get("toDate").toString().replace("-", ""));
          } else
            // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
            if (dataKey.containsKey("fromDate") && !"".equals(dataKey.get("fromDate"))) {
              // mod #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
              // dataKey.replace("fromDate", dataKey.get("fromDate").toString().replace("-", ""));
              dataKey.put("toDate", dataKey.get("fromDate").toString().replace("-", ""));
              // mod #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
            }
          // add #6886 帳票の患者情報が過去日付時点の内容で表示できない 鄭爽 end
        } else {
          throw new NtssException("想定しないDB種別が指定されています。");
        }
        // 5994_指示履歴の取得について 2021/08/13 add start 李
        // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
        if (dataKey.containsKey("toDate")){
          dataKey.replace("toDate", dataKey.get("toDate").toString().replace(" 23:59:59", ""));
        } else
          // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
          if (dataKey.containsKey("fromDate")){
            // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
            // dataKey.replace("fromDate", dataKey.get("fromDate").toString().replace(" 23:59:59", ""));
            dataKey.put("toDate", dataKey.get("fromDate").toString().replace(" 23:59:59", ""));
            // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
          }
        // 5994_指示履歴の取得について 2021/08/13 add end 李
        // 帳票出力情報を返却用に置き換える（フィールド名をデータ項目コードに置き換える）
        return replaceReportInfo(reportInfo, sysDataSet.getDetailInfo().getDetails());
        // add 2021-03-23 外部連携：定時一括送信機能の複数データの対応。 孫 start
      }
      // add 2021-03-23 外部連携：定時一括送信機能の複数データの対応。 孫 start
    } catch (Exception ex) {
      // 例外が発生した場合には、空のリストを返却する.
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("帳票用のデータ取得に失敗しました。sqlCd:" + sqlCode);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」を改修 江 end
      // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
//      return new ArrayList<Map<String, Object>>();
      Map<String, Object> map = new HashMap<String, Object>();
      map.put("error", eventLogMessage.getLogMessage());
      List<Map<String, Object>> errData = new ArrayList<Map<String, Object>>();
      errData.add(map);
      return errData;
      // mod 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end
    }
  }
  //#dev 6304 ローカルDBへの登録に失敗する sichengbo end

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  /**
   * {@inheritDoc}
   */
  @Override
  public Integer insertData(Long sqlCode, Map<String, Object> dataKey,
                            UseApplication targetApplication)  {

    // SysDataSetを取得する
    Integer retCount = 0;
    SysDataSet sysDataSet = getSysDataSet(sqlCode);

    // 使用用途のチェック
    checkUseApplication(sysDataSet.getUseApplication(), targetApplication);

    // 事前実行SQLがあれば実行して結果をパラメータに追加
    dataKey = this.preExecSql(sysDataSet.getPreSqlInfo(), dataKey);
    Integer dbClass = sysDataSet.getDbClass();

    String sql = sysDataSet.getSql();
    // SQLに何も登録されていない場合.
    if (StringUtils.isEmpty(sql)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("指定されたsqlCodeにSQLが登録されていません。sqlCd:" + sqlCode);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      String errMsg = "指定されたsqlCodeにSQLが登録されていません。sqlCd:" + sqlCode;
      throw new NtssException(errMsg);
    }

    // SQL実行でエラーが発生しても、後続処理を継続する
    try {
      // mst_coop_layoutのcoop_ext_settingのdatasetに事前処理用SQLの結果が複数データか
      if (sysDataSet.getPreSqlInfo() != null && sysDataSet.getPreSqlInfo().getItems().size() > 0
        && dataKey.containsKey(ReportConstant.PreSqlInfoItem)) {

        List<String> preSqlInfoItem = (List<String>)dataKey.get(ReportConstant.PreSqlInfoItem);
        List<Object> itemForCnt = (List<Object>)dataKey.get(preSqlInfoItem.get(0));

        List<Map<String, Object>> preItemList = new ArrayList<>();
        for (int i=0; i<itemForCnt.size(); i++) {
          Map<String, Object> preItemMap = new HashMap<String, Object>();
          for (int j=0; j<preSqlInfoItem.size(); j++) {
            String preItemKey = (String)preSqlInfoItem.get(j);
            List<Object> preItem = (List<Object>)dataKey.get(preItemKey);
            Object preItemValus = preItem.get(i);

            preItemMap.put(preItemKey, preItemValus);
          }

          preItemList.add(preItemMap);
        }

        List<Map<String, Object>> reportInfoAll = new ArrayList<>();
        for (int k=0; k<preItemList.size(); k++) {
          Map<String, Object> preItemMap = preItemList.get(k);
          Set<String> keySet = preItemMap.keySet();
          for (String key : keySet) {
            dataKey.replace(key, preItemMap.get(key));
          }

          if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
            Config config = defaultDbConfig;
            InsertBuilder builder = createInsertBuilder(config, sql, dataKey);
            retCount = retCount + builder.execute();
          } else if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
            Config config = personalDbConfig;
            InsertBuilder builder = createInsertBuilder(config, sql, dataKey);
            retCount = retCount + builder.execute();
          } else if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
            Config config = authDbConfig;
            InsertBuilder builder = createInsertBuilder(config, sql, dataKey);
            retCount = retCount + builder.execute();
          } else {
            throw new NtssException("想定しないDB種別が指定されています。");
          }
        }
      } else {
        if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
          Config config = defaultDbConfig;
          InsertBuilder builder = createInsertBuilder(config, sql, dataKey);
          retCount = builder.execute();
        } else if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
          Config config = personalDbConfig;
          InsertBuilder builder = createInsertBuilder(config, sql, dataKey);
          retCount = builder.execute();
        } else if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
          Config config = authDbConfig;
          InsertBuilder builder = createInsertBuilder(config, sql, dataKey);
          retCount = builder.execute();
        } else {
          throw new NtssException("想定しないDB種別が指定されています。");
        }
      }
      return retCount;
    } catch (Exception ex) {
      // 例外が発生した場合には、空のリストを返却する.
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("データ登録に失敗しました。sqlCd:" + sqlCode);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
// mod 2021-09-13 #5897:CSI連携ができないの対応 孫 start
//      String errMsg = "データ登録に失敗しました。sqlCd:"+ sqlCode;
      String errMsg = "データ登録に失敗しました。sqlCd:"+ sqlCode + " msg:" + ex.getMessage();
// mod 2021-09-13 #5897:CSI連携ができないの対応 孫 end
      throw new NtssException(errMsg);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public Integer updateData(Long sqlCode, Map<String, Object> dataKey,
                            UseApplication targetApplication)  {

    // 実行するSQLを生成する
    Integer retCount = 0;
    // add 2022-06-22 7521,7522 李 start
    if(sqlCode == 9612 && dataKey.containsKey("@severityCd") && (dataKey.get("@severityCd") == null || dataKey.get("@severityCd").equals(""))){
      dataKey.put("@severityCd", "null");
    }
    // add 2022-06-22 7521,7522 李 end
    SysDataSet sysDataSet = getSysDataSet(sqlCode);

    // 使用用途のチェック
    checkUseApplication(sysDataSet.getUseApplication(), targetApplication);

    // 事前実行SQLがあれば実行して結果をパラメータに追加
    dataKey = this.preExecSql(sysDataSet.getPreSqlInfo(), dataKey);
    Integer dbClass = sysDataSet.getDbClass();

    String sql = sysDataSet.getSql();
    // SQLに何も登録されていない場合.
    if (StringUtils.isEmpty(sql)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("指定されたsqlCodeにSQLが登録されていません。sqlCd:" + sqlCode);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      String errMsg = "指定されたsqlCodeにSQLが登録されていません。sqlCd:" + sqlCode;
      throw new NtssException(errMsg);
    }

    // SQL実行でエラーが発生しても、後続処理を継続する
    try {
      // mst_coop_layoutのcoop_ext_settingのdatasetに事前処理用SQLの結果が複数データか
      if (sysDataSet.getPreSqlInfo() != null && sysDataSet.getPreSqlInfo().getItems().size() > 0
        && dataKey.containsKey(ReportConstant.PreSqlInfoItem)) {

        List<String> preSqlInfoItem = (List<String>)dataKey.get(ReportConstant.PreSqlInfoItem);
        List<Object> itemForCnt = (List<Object>)dataKey.get(preSqlInfoItem.get(0));

        List<Map<String, Object>> preItemList = new ArrayList<>();
        for (int i=0; i<itemForCnt.size(); i++) {
          Map<String, Object> preItemMap = new HashMap<String, Object>();
          for (int j=0; j<preSqlInfoItem.size(); j++) {
            String preItemKey = (String)preSqlInfoItem.get(j);
            List<Object> preItem = (List<Object>)dataKey.get(preItemKey);
            Object preItemValus = preItem.get(i);

            preItemMap.put(preItemKey, preItemValus);
          }

          preItemList.add(preItemMap);
        }

        List<Map<String, Object>> reportInfoAll = new ArrayList<>();
        for (int k=0; k<preItemList.size(); k++) {
          Map<String, Object> preItemMap = preItemList.get(k);
          Set<String> keySet = preItemMap.keySet();
          for (String key : keySet) {
            dataKey.replace(key, preItemMap.get(key));
          }

          if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
            Config config = defaultDbConfig;
            UpdateBuilder builder = createUpdateBuilder(config, sql, dataKey);
            retCount = retCount + builder.execute();
          } else if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
            Config config = personalDbConfig;
            UpdateBuilder builder = createUpdateBuilder(config, sql, dataKey);
            retCount = retCount + builder.execute();
          } else if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
            Config config = authDbConfig;
            UpdateBuilder builder = createUpdateBuilder(config, sql, dataKey);
            retCount = retCount + builder.execute();
          } else {
            throw new NtssException("想定しないDB種別が指定されています。");
          }
        }
      } else {
        if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
          Config config = defaultDbConfig;
          UpdateBuilder builder = createUpdateBuilder(config, sql, dataKey);
          retCount = builder.execute();
        } else if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
          Config config = personalDbConfig;
          UpdateBuilder builder = createUpdateBuilder(config, sql, dataKey);
          retCount = builder.execute();
        } else if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
          Config config = authDbConfig;
          UpdateBuilder builder = createUpdateBuilder(config, sql, dataKey);
          retCount = builder.execute();
        } else {
          throw new NtssException("想定しないDB種別が指定されています。");
        }
      }
      return retCount;
    } catch (Exception ex) {
      // 例外が発生した場合には、空のリストを返却する.
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("データ更新に失敗しました。sqlCd:" + sqlCode);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
// mod 2021-09-13 #5897:CSI連携ができないの対応 孫 start
//      String errMsg = "データ更新に失敗しました。sqlCd:"+ sqlCode;
      String errMsg = "データ更新に失敗しました。sqlCd:"+ sqlCode + " msg:" + ex.getMessage();
// mod 2021-09-13 #5897:CSI連携ができないの対応 孫 end
      throw new NtssException(errMsg);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public Integer deleteData(Long sqlCode, Map<String, Object> dataKey,
                            UseApplication targetApplication)  {

    // 実行するSQLを生成する
    Integer retCount = 0;
    SysDataSet sysDataSet = getSysDataSet(sqlCode);

    // 使用用途のチェック
    checkUseApplication(sysDataSet.getUseApplication(), targetApplication);

    // 事前実行SQLがあれば実行して結果をパラメータに追加
    dataKey = this.preExecSql(sysDataSet.getPreSqlInfo(), dataKey);
    Integer dbClass = sysDataSet.getDbClass();

    String sql = sysDataSet.getSql();
    // SQLに何も登録されていない場合.
    if (StringUtils.isEmpty(sql)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("指定されたsqlCodeにSQLが登録されていません。sqlCd:" + sqlCode);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      String errMsg = "指定されたsqlCodeにSQLが登録されていません。sqlCd:" + sqlCode;
      throw new NtssException(errMsg);
    }

    // SQL実行でエラーが発生しても、後続処理を継続する
    try {
      // mst_coop_layoutのcoop_ext_settingのdatasetに事前処理用SQLの結果が複数データか
      if (sysDataSet.getPreSqlInfo() != null && sysDataSet.getPreSqlInfo().getItems().size() > 0
        && dataKey.containsKey(ReportConstant.PreSqlInfoItem)) {

        List<String> preSqlInfoItem = (List<String>)dataKey.get(ReportConstant.PreSqlInfoItem);
        List<Object> itemForCnt = (List<Object>)dataKey.get(preSqlInfoItem.get(0));

        List<Map<String, Object>> preItemList = new ArrayList<>();
        for (int i=0; i<itemForCnt.size(); i++) {
          Map<String, Object> preItemMap = new HashMap<String, Object>();
          for (int j=0; j<preSqlInfoItem.size(); j++) {
            String preItemKey = (String)preSqlInfoItem.get(j);
            List<Object> preItem = (List<Object>)dataKey.get(preItemKey);
            Object preItemValus = preItem.get(i);

            preItemMap.put(preItemKey, preItemValus);
          }

          preItemList.add(preItemMap);
        }

        List<Map<String, Object>> reportInfoAll = new ArrayList<>();
        for (int k=0; k<preItemList.size(); k++) {
          Map<String, Object> preItemMap = preItemList.get(k);
          Set<String> keySet = preItemMap.keySet();
          for (String key : keySet) {
            dataKey.replace(key, preItemMap.get(key));
          }

          if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
            Config config = defaultDbConfig;
            DeleteBuilder builder = createDeleteBuilder(config, sql, dataKey);
            retCount = retCount + builder.execute();
          } else if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
            Config config = personalDbConfig;
            DeleteBuilder builder = createDeleteBuilder(config, sql, dataKey);
            retCount = retCount + builder.execute();
          } else if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
            Config config = authDbConfig;
            DeleteBuilder builder = createDeleteBuilder(config, sql, dataKey);
            retCount = retCount + builder.execute();
          } else {
            throw new NtssException("想定しないDB種別が指定されています。");
          }
        }
      } else {
        if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
          Config config = defaultDbConfig;
          DeleteBuilder builder = createDeleteBuilder(config, sql, dataKey);
          retCount = builder.execute();
        } else if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
          Config config = personalDbConfig;
          DeleteBuilder builder = createDeleteBuilder(config, sql, dataKey);
          retCount = builder.execute();
        } else if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
          Config config = authDbConfig;
          DeleteBuilder builder = createDeleteBuilder(config, sql, dataKey);
          retCount = builder.execute();
        } else {
          throw new NtssException("想定しないDB種別が指定されています。");
        }
      }
      return retCount;
    } catch (Exception ex) {
      // 例外が発生した場合には、空のリストを返却する.
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("データ削除に失敗しました。sqlCd:" + sqlCode);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
// mod 2021-09-13 #5897:CSI連携ができないの対応 孫 start
//      String errMsg = "データ削除に失敗しました。sqlCd:"+ sqlCode;
      String errMsg = "データ削除に失敗しました。sqlCd:"+ sqlCode + " msg:" + ex.getMessage();
// mod 2021-09-13 #5897:CSI連携ができないの対応 孫 end
      throw new NtssException(errMsg);
    }
  }
  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end

  /**
   * SqlCodeに該当するデータセットレコードを取得します.
   * 存在しない<code>sqlCode</code>を指定された場合、{@link NotExistException}をスローします.
   *
   * @param sqlCode sqlCode
   * @return データセットのEntity
   * @throws NotExistException 存在しない<code>sqlCode</code>を指定された場合
   */
  private SysDataSet getSysDataSet(Long sqlCode) {
    try {
      return sysDataSetDao.selectByCd(sqlCode);
    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no SysDataSet. : sqlCode = [" + sqlCode + "]");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      // mod 7704 帳票が生成されない 姜 start
      //throw new NotExistException("存在しないデータセットのSqlCodeを指定されています。 sqlCode = [" + sqlCode + "]");
      return null;
      // mod 7704 帳票が生成されない 姜 end
    }
  }

  /**
   * 事前処理用SQLの実行
   * @param preSqlInfo 事前処理用SQL情報
   * @param dataKey  パラメータ
   * @return SQLから取得したパラメータを追加したパラメータ一式
   */
  private Map<String, Object> preExecSql(PreSqlInfo preSqlInfo, Map<String, Object> dataKey) {
    if (preSqlInfo != null && preSqlInfo.getItems().size() > 0) {
      Long sqlCodeOld = null;
      List<Map<String, Object>> res = new ArrayList<>();

      for (PreSqlInfoItem item : preSqlInfo.getItems()) {
        Long sqlCode = item.getSqlCd();
        if (!sqlCode.equals(sqlCodeOld)) {
          res.clear();
          res = this.getDataList(sqlCode, dataKey);
          sqlCodeOld = sqlCode;
        }

        String replaceVar = item.getReplaceVar();
        String dataName = item.getFieldName();

        try {
          JSONArray fields = new JSONArray(dataName);

          // --- JSON形式の場合の処理 ---

          // 空のJSON配列 "[]" が指定された場合
          if (fields.length() == 0) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String logMsg = String.format("field_nameに空のJSON配列が指定されました。sqlCode: %d, replaceVar: %s", sqlCode, replaceVar);
            eventLogMessage.setLogMessage(logMsg);
            logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);

            dataKey.put(replaceVar, new ArrayList<>());
            continue;
          }

          List<String> fieldList;
          try {
            fieldList = new ArrayList<>();
            for (int i = 0; i < fields.length(); i++) {
              fieldList.add(fields.getString(i));
            }
          } catch (JSONException je) {
            // JSON配列の要素が文字列以外だった場合
            EventLogMessage eventLogMessage = new EventLogMessage();
            String logMsg = String.format("field_nameに指定されたJSON配列の要素は全て文字列である必要があります。sqlCode[%d], replace_var[%s]", sqlCode, replaceVar);
            eventLogMessage.setLogMessage(logMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

            throw new NtssException(logMsg, je);
          }

          List<Map<String, Object>> resultList = new ArrayList<>();
          Set<String> foundFields = new HashSet<>();

          for (Map<String, Object> row : res) {
            Map<String, Object> newRow = new LinkedHashMap<>();
            for (String field : fieldList) {
              if (row.containsKey(field)) {
                newRow.put(field, row.get(field));
                foundFields.add(field);
              }
            }
            if (!newRow.isEmpty()) {
              resultList.add(newRow);
            }
          }

          // SQL結果に存在しないフィールドが指定されていた場合
          // ループの外で、見つからなかったフィールドをまとめてログ出力
          Set<String> specifiedFields = new HashSet<>(fieldList);
          specifiedFields.removeAll(foundFields);
          if (!specifiedFields.isEmpty()) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            String logMsg = String.format("SQL結果に存在しないフィールドが指定されました。sqlCode: %d, replaceVar: %s, 見つからないフィールド: %s",
                           sqlCode, replaceVar, specifiedFields.toString());
            eventLogMessage.setLogMessage(logMsg);
            logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }

          try {
            // resultListをJSON文字列に変換
            ObjectMapper objectMapper = new ObjectMapper();
            String jsonResultString = objectMapper.writeValueAsString(resultList);
            // JSON文字列をdataKeyに格納
            dataKey.put(replaceVar, jsonResultString);
          } catch (JacksonException e) {
            // JSON文字列への変換に失敗した場合のエラーハンドリング
            EventLogMessage eventLogMessage = new EventLogMessage();
            String logMsg = String.format("結果のJSON文字列への変換に失敗しました。sqlCode: %d, replaceVar: %s", sqlCode, replaceVar);
            eventLogMessage.setLogMessage(logMsg);
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

            throw new NtssException(logMsg, e);
          }
        } catch (JSONException e) {
          // --- JSON形式ではない場合（従来の処理） ---
          if (dataKey.containsKey(ReportConstant.PreSqlInfoItem)) {
            List<String> preSqlInfoItem = (List<String>) dataKey.get(ReportConstant.PreSqlInfoItem);
            if (preSqlInfoItem == null || preSqlInfoItem.isEmpty()) {
              throw new NtssException("mst_coop_layoutのcoop_ext_settingのdatasetのPreSqlInfoItemがnullです。");
            }
            if (!preSqlInfoItem.contains(replaceVar)) {
              throw new NtssException("sqlCode[" + sqlCode + "]のpre_sql_infoのreplace_var[" + replaceVar
                  + "]はmst_coop_layoutのcoop_ext_settingのdatasetのPreSqlInfoItemに存在しない。");
            }
            List<Object> values = new ArrayList<>();
            for (Map<String, Object> row : res) {
              values.add(row.get(dataName));
            }
            dataKey.put(replaceVar, values);
          } else {
            if (res.size() > 0 && res.get(0).containsKey(dataName)) {
              dataKey.put(replaceVar, res.get(0).get(dataName));
            }
            // add #12576 カテゴリ「レセプト」のデータ分類出力順設定が必要 sunsy start
            else {
              dataKey.put(replaceVar, null);
            }
            // add #12576 カテゴリ「レセプト」のデータ分類出力順設定が必要 sunsy end
          }
        }
      }
    }
    return dataKey;
  }

  /**
   * {@link SysDataSet}をもとに{@link SelectBuilder}を作成します.
   *
   * @param config  DB接続先情報
   * @param sql     SQL
   * @param dataKey データキー
   * @return {@link SelectBuilder}
   */
  private SelectBuilder createSelectBuilder(Config config, String sql, Map<String, Object> dataKey) {
    // SQLのバインド変数にあわせて"@"を付与する
    // add 10550 患者別の検査結果一覧帳票を出力できるようにする 吉 start
    if(sql.contains("@patIds")){
      dataKey.remove("patId");
    }
    if(sql.contains("@ordNos")){
      dataKey.remove("ordNo");
    }
    // add 10550 患者別の検査結果一覧帳票を出力できるようにする 吉 end
    Map<String, Object> sqlDataKey = dataKey.entrySet().stream()
      .collect(Collectors.toMap(
        d -> d.getKey().startsWith("@") ? d.getKey() : String.format("@%s", d.getKey()),
        // mod 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
        //d -> d.getValue() == null ? null : d.getValue()
        d -> d.getValue() == null ? "" : d.getValue()
        // mod 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
      ));

    // バインド変数毎にSQL内での出力件数からマップを作成.
    // key:バインド変数名(ex. @ordNos)
    // value:出力回数(ex. 2)
    Map<String, Integer> sqlDataKeyCount = new HashMap<>();
    sqlDataKey.forEach((key, value) -> {
      sqlDataKeyCount.put(key, StringUtils.countOccurrencesOf(sql, key));
    });

    // SQLでの出現位置順にデータキーの項目名を取得する
    Map<Integer, String> itemIndexMap = new HashMap<>();
    sqlDataKey.forEach((key, value) -> {
      if (sql.indexOf(key) >= 0) {
        itemIndexMap.put(sql.indexOf(key), key);
        // 同一パラメータ名（@XXX)が複数存在する場合
        // 次のパラメータの位置を取得する為、+1を行う
        int startIndex = sql.indexOf(key) + 1;
        if (sqlDataKeyCount.containsKey(key) && sqlDataKeyCount.get(key) > 1) {
          for(int index = 1; index <= sqlDataKeyCount.get(key); index++) {
            int matchIndex = sql.indexOf(key, startIndex);
            if (matchIndex < 0) {
              continue;
            }
            itemIndexMap.put(matchIndex, key);
            startIndex = matchIndex + 1;
          }
        }
      }
    });
    List<String> itemNames =
      itemIndexMap.entrySet().stream()
        .sorted(comparingByKey())
        .map(e -> e.getValue())
        .collect(Collectors.toList())
      ;

    // 実行するSQLを生成する
    SelectBuilder selectBuilder = SelectBuilder.newInstance(config);
    String tmpSql = sql;
    for (String itemName : itemNames) {
      // データキーの項目名でSQLを分割する
      String[] splitSqls = tmpSql.split(itemName);
      selectBuilder.sql(splitSqls[0]);

      // 項目名の箇所にパラメータを設定する
      Object itemValue = sqlDataKey.get(itemName);

      // itemValueがListではない場合
      List<Object> itemList = new ArrayList<Object>();
      if (itemValue instanceof List) {
        // リストの場合
        itemList.addAll((List<?>)itemValue);
      } else {
        // リスト以外
        itemList.add(itemValue);
      }

      // リストから展開
      String delimiter = "";
      for (Object obj : itemList) {
        if (!StringUtils.isEmpty(delimiter)) selectBuilder.sql(delimiter);
        if (obj instanceof String) {
          selectBuilder.param(String.class, String.valueOf(obj));
        } else if (obj instanceof Long) {
          selectBuilder.param(Long.class, Long.valueOf(obj.toString()));
        } else if (obj instanceof Integer) {
          selectBuilder.param(Integer.class, Integer.valueOf(obj.toString()));
        } else {
          throw new NtssException("想定しないデータ型が指定されています。");
        }
        delimiter = ",";
      }
      // splitした結果を再結合する.
      StringJoiner sj = new StringJoiner(itemName);
      // 配列の1件目は既にselectBuilderに格納済みの為スキップする.
      Arrays.stream(splitSqls).skip(1).forEach(i -> sj.add(i));
      // split結果が1件以上の場合のみ再結合した文字列を設定する.
      tmpSql = splitSqls.length > 1 ? sj.toString(): "";
    }
    selectBuilder.sql(tmpSql);
    return selectBuilder;
  }

  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 start
  /**
   * {@link SysDataSet}をもとに{@link InsertBuilder}を作成します.
   *
   * @param config  DB接続先情報
   * @param sql     SQL
   * @param dataKey データキー
   * @return {@link InsertBuilder}
   */
  private InsertBuilder createInsertBuilder(Config config, String sql, Map<String, Object> dataKey) {
    // 実行するSQLを生成する
    InsertBuilder insertBuilder = InsertBuilder.newInstance(config);

    if (dataKey != null) {
      String tmpSql = sql;
// mod 2021-08-31 #5887:富士通連携設定の構築の対応 孫 start
//      for (String key : dataKey.keySet()) {
      Object[] keyArr = dataKey.keySet().toArray();
      Arrays.sort(keyArr);
      for(int index=keyArr.length-1;index>=0;index--){
        String key = keyArr[index].toString();
// mod 2021-08-31 #5887:富士通連携設定の構築の対応 孫 end
        Object obj = dataKey.get(key);
        if (obj != null) {
          //mod 7713 7519富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//          tmpSql = tmpSql.replace(key,obj.toString());
          tmpSql = tmpSql.replace(key,obj.toString().replace("\'","\'\'"));
          //mod 7713 7519富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
        } else {
          tmpSql = tmpSql.replace(key,"");
        }
      }
      insertBuilder.sql(tmpSql);
    } else {
      insertBuilder.sql(sql);
    }
    return insertBuilder;
  }

  /**
   * {@link SysDataSet}をもとに{@link UpdateBuilder}を作成します.
   *
   * @param config  DB接続先情報
   * @param sql     SQL
   * @param dataKey データキー
   * @return {@link UpdateBuilder}
   */
  private UpdateBuilder createUpdateBuilder(Config config, String sql, Map<String, Object> dataKey) {
    // 実行するSQLを生成する
    UpdateBuilder updateBuilder = UpdateBuilder.newInstance(config);

    // SQLのバインド変数にあわせて"@"を付与する
    if (dataKey != null) {
      String tmpSql = sql;
// mod 2021-08-31 #5887:富士通連携設定の構築の対応 孫 start
//      for (String key : dataKey.keySet()) {
      Object[] keyArr = dataKey.keySet().toArray();
      Arrays.sort(keyArr);
      for(int index=keyArr.length-1;index>=0;index--){
        String key = keyArr[index].toString();
// mod 2021-08-31 #5887:富士通連携設定の構築の対応 孫 end
        Object obj = dataKey.get(key);
        if (obj != null) {
          //mod 7713 7519富士通指摘：PC上で使用している文字で判読不能になるものがある。張 start
//          tmpSql = tmpSql.replace(key,obj.toString());
          tmpSql = tmpSql.replace(key,obj.toString().replace("\'","\'\'"));
          //mod 7713 7519富士通指摘：PC上で使用している文字で判読不能になるものがある。張 end
        } else {
          tmpSql = tmpSql.replace(key,"");
        }
      }
      updateBuilder.sql(tmpSql);
    } else {
      updateBuilder.sql(sql);
    }
    return updateBuilder;
  }

  /**
   * {@link SysDataSet}をもとに{@link DeleteBuilder}を作成します.
   *
   * @param config  DB接続先情報
   * @param sql     SQL
   * @param dataKey データキー
   * @return {@link DeleteBuilder}
   */
  private DeleteBuilder createDeleteBuilder(Config config, String sql, Map<String, Object> dataKey) {
    // 実行するSQLを生成する
    DeleteBuilder deleteBuilder = DeleteBuilder.newInstance(config);

    // SQLのバインド変数にあわせて"@"を付与する
    if (dataKey != null) {
      String tmpSql = sql;
// mod 2021-08-31 #5887:富士通連携設定の構築の対応 孫 start
//      for (String key : dataKey.keySet()) {
      Object[] keyArr = dataKey.keySet().toArray();
      Arrays.sort(keyArr);
      for(int index=keyArr.length-1;index>=0;index--){
        String key = keyArr[index].toString();
// mod 2021-08-31 #5887:富士通連携設定の構築の対応 孫 end
        Object obj = dataKey.get(key);
        if (obj != null) {
          tmpSql = tmpSql.replace(key,obj.toString());
        } else {
          tmpSql = tmpSql.replace(key,"");
        }
      }
      deleteBuilder.sql(tmpSql);
    } else {
      deleteBuilder.sql(sql);
    }
    return deleteBuilder;
  }
  // add 2021-03-31 課題2と課題12の対応、受信のプロセスを修正 商 end

  /**
   * データセットの詳細情報をもとに帳票出力情報を置き換えます.
   *
   * @param reportInfo       帳票出力情報
   * @param sysDataSetDetail データセットの詳細情報
   * @return 置き換え後の帳票出力情報
   */
  private List<Map<String, Object>> replaceReportInfo(List<Map<String, Object>> reportInfo, List<Detail> sysDataSetDetail) {
    HashMap<String, Object> sqlCacheMap = new HashMap<>();
    sysDataSetDetail.stream().forEach(detail -> reportInfo.stream().forEach(result -> {
      String fieldName = detail.getFieldName();

      if (result.containsKey(fieldName)) {
        Object value = result.get(fieldName);
        result.remove(fieldName, value);

        // add UT帳票No.137 二次元帳票の「スケジュール表」未選択の患者は表示不要の対応 夏 start
        if("スケジュール表".equals(detail.getDataClass()) && "pat_id".equals(fieldName)){
          result.put("patId", Optional.ofNullable(value).orElse(""));
        }
        // add UT帳票No.137 二次元帳票の「スケジュール表」未選択の患者は表示不要の対応 夏 end
        value = execConvSql(detail.getConvSql(), value, sqlCacheMap);

        result.put(detail.getDataCode(), Optional.ofNullable(value).orElse(""));
      }
    }));
    // mod 7843 帳票（器材準備リスト）：出力内容が正しくない 姜 start
    // del 7843 帳票（器材準備リスト）：出力内容が正しくない 姜 start
    return reportInfo;
    //  if (reportInfo == null || reportInfo.size() == 0) {
    //   return reportInfo;
    // } else {
    //   reportInfo.stream().forEach(e -> {
    //     if (null == e.get("name")) {
    //      e.put("name", "");
    //    }
    //    if (null == e.get("amount")) {
    //      e.put("amount", -99999999);
    //    }
    //  });
    //  List<Map<String, Object>> collect = new ArrayList<>();
    //  if ("".equals(reportInfo.get(0).get("name").toString()) || String.valueOf(-99999999).equals(reportInfo.get(0).get("amount").toString())) {
    //    collect = reportInfo;
    //  } else {
    //    collect = reportInfo.stream().collect(Collectors.groupingBy(d -> d.get("name"))).values().stream().map(d -> {
    //      Map<String, Object> sampleData = d.get(0);

    //      sampleData.put("amount", d.stream().map(s -> new BigDecimal(s.get("amount").toString())).reduce(BigDecimal.ZERO, BigDecimal::add));
    //      return sampleData;
    //    }).collect(Collectors.toList());
    //    collect.stream().forEach(e -> {
    //      if ("".equals(e.get("name").toString())) {
    //        e.remove("name");
    //      }
    //      if (String.valueOf(-99999999).equals(e.get("amount").toString())) {
    //        e.remove("amount");
    //      }
    //    });
    //  }
    //  return collect;
    //}
    // del 7843 帳票（器材準備リスト）：出力内容が正しくない 姜 end
    // mod 7843 帳票（器材準備リスト）：出力内容が正しくない 姜 end
  }

  // 5994_指示履歴の取得について 2021/08/13 add start 李
  private List<Map<String, Object>> replaceReportInfoMongo(List<Map<String, Object>> reportInfo, List<Detail> sysDataSetDetail) {
    // mod #10740 指示.修正内容の出力不正 sunsy start
//    List<Map<String, Object>> reportInfoNew = new ArrayList<>();
//    Map<String, Object> mongoMap = new HashMap<String, Object>();
//    sysDataSetDetail.stream().forEach(detail -> reportInfo.stream().forEach(result -> {
//      String dataName = detail.getDataName();
//      String dataNameMong = "";
//      if (result.get("log_target") != null) {
//        dataNameMong = result.get("log_target").toString();
//      }
//      if(!StringUtils.isEmpty(dataName) && !StringUtils.isEmpty(dataNameMong) && dataName.startsWith(dataNameMong)) {
//        String dataCode = detail.getDataCode();
//        if (!StringUtils.isEmpty(dataCode)) {
//          if (dataCode.toLowerCase().endsWith("__after") || dataCode.toLowerCase().endsWith("__before") ) {
//            String valueMong = "";
//            if (result.get("log_content") != null) {
//              valueMong = result.get("log_content").toString();
//            }
//            // value is null
//            if (StringUtils.isEmpty(valueMong)) {
//              mongoMap.put(dataCode, "");
//            } else {
//              String[] valueMongArr = valueMong.split("→", 2);
//              String valueBefore = "未登録".equals(valueMongArr[0])?"":valueMongArr[0];
//              String valueAfter = "";
//              if (valueMongArr.length == 2) {
//                valueAfter = "未登録".equals(valueMongArr[1])?"":valueMongArr[1];
//              }
//              if (dataCode.toLowerCase().endsWith("__before")) {
//                mongoMap.put(dataCode, valueBefore);
//              } else {
//                mongoMap.put(dataCode, valueAfter);
//              }
//            }
//          } else {
//            // not before after
//            //throw new Exception("error");
//          }
//        } else {
//          // dataCode is null
//          //throw new Exception("error");
//        }
//      }
//    }));
//    reportInfoNew.add(mongoMap);
//    return reportInfoNew;
    List<Map<String, Object>> reportInfoNew = new ArrayList<>();
    // log_dateにより情報を分けて、同一のlog_dateに対する情報をリストに挿入
    Map<Object, List<Map<String, Object>>> groupedByLogDate = reportInfo.stream()
      .filter(result -> result.get("log_date") != null)
      .collect(Collectors.groupingBy(
        result -> result.get("log_date"),
        TreeMap::new,
        Collectors.toList()
      ));

    // 各log_dateに対する情報をループして処理
    groupedByLogDate.forEach((logDate, reportInfoGroup) -> {
      Map<String, Object> mongoMap = new HashMap<>();

      sysDataSetDetail.forEach(detail -> {
        String dataCode = detail.getDataCode();
        if (StringUtils.isEmpty(dataCode)) return;

        String lowerCode = dataCode.toLowerCase();
        // __before / __after のみ対象
        if (!(lowerCode.endsWith("__after") || lowerCode.endsWith("__before"))) return;

        String dataName = detail.getDataName();
        List<String> beforeList = new ArrayList<>();
        List<String> afterList = new ArrayList<>();

        reportInfoGroup.forEach(result -> {
          String dataNameMong = result.get("log_target") != null ? result.get("log_target").toString() : "";
          if (StringUtils.isEmpty(dataName) || StringUtils.isEmpty(dataNameMong)) return;

          // "(" を安全に処理
          String baseName = dataName.contains("(修正") ? dataName.substring(0, dataName.indexOf("(修正")) : dataName;
          if (!baseName.equals(dataNameMong)) return;

          String valueMong = result.get("log_content") != null ? result.get("log_content").toString() : "";
          if (StringUtils.isEmpty(valueMong)) return;

          List<String> beforeTmp = new ArrayList<>();
          List<String> afterTmp = new ArrayList<>();
          String[] lines = valueMong.split("\\r?\\n");

          for (String rawLine : lines) {
            if (StringUtils.isEmpty(rawLine)) {
              beforeTmp.add("");
              afterTmp.add("");
              continue;
            }

            // ① 文字正規化（全角→半角など）
            String line = Normalizer.normalize(rawLine, Normalizer.Form.NFKC).trim();

            // ② 変更前後を分割（複数の矢印対応）
            String[] arr = line.split("[→⇒➝➔]|->", 2);
            String beforePart = arr[0].trim();
            String afterPart = arr.length > 1 ? arr[1].trim() : "";

            String prefix = "";

            // ③ 「項目名:値」形式か判定
            boolean isFieldFormat =
              beforePart.contains(":")
                // 時刻ではない（例：02:00）
                && !beforePart.matches("^\\d{1,2}:\\d{2}(:\\d{2})?$")
                // 日付ではない（例：2024/01/01）
                && !beforePart.matches("^\\d{4}/\\d{1,2}/\\d{1,2}.*")
                // 項目名は数字で始まらない
                && beforePart.matches("^[^0-9]+:.*");

            if (isFieldFormat) {
              int idx = beforePart.indexOf(":");
              prefix = beforePart.substring(0, idx + 1);
              beforePart = beforePart.substring(idx + 1).trim();

              // after 側も prefix を除去
              if (!StringUtils.isEmpty(afterPart) && afterPart.contains(":")) {
                int idx2 = afterPart.indexOf(":");
                afterPart = afterPart.substring(idx2 + 1).trim();
              }
            }

            // ④ 結果格納（after は不要な prefix を付けない）
            beforeTmp.add(prefix + beforePart);
            afterTmp.add(StringUtils.isEmpty(afterPart) ? "" : (isFieldFormat ? prefix + afterPart : afterPart));
          }

          // 行数を揃える（ズレ防止）
          int maxSize = Math.max(beforeTmp.size(), afterTmp.size());
          while (beforeTmp.size() < maxSize) beforeTmp.add("");
          while (afterTmp.size() < maxSize) afterTmp.add("");

          beforeList.addAll(beforeTmp);
          afterList.addAll(afterTmp);
        });

        String beforeStr = String.join("\n", beforeList);
        String afterStr = String.join("\n", afterList);

        if (lowerCode.endsWith("__before")) {
          mongoMap.put(dataCode, beforeStr);
        } else {
          mongoMap.put(dataCode, afterStr);
        }
      });

      reportInfoNew.add(mongoMap);
    });
    // mod #10740 指示.修正内容の出力不正 sunsy end
    return reportInfoNew;
  }
  // 5994_指示履歴の取得について 2021/08/13 add end 李

  // add #11625 【標準帳票】クラス「指示履歴」の仕様変更② sunsy start
  private List<Map<String, Object>> getIndHistoryInfoMongo(List<Map<String, Object>> reportInfo) {
    if (CollectionUtils.isEmpty(reportInfo)) {
      return reportInfo;
    }

    Map<Long, String> userNameCache = new HashMap<>();

    for (Map<String, Object> row : reportInfo) {
      Map<String, Object> newValues = new HashMap<>();
      putIndHistoryUserName(row, newValues, "receiver_1", "receiver_name1", userNameCache);
      putIndHistoryUserName(row, newValues, "receiver_2", "receiver_name2", userNameCache);
      putIndHistoryUserName(row, newValues, "approver_1", "approver_name1", userNameCache);
      putIndHistoryUserName(row, newValues, "approver_2", "approver_name2", userNameCache);
      row.putAll(newValues);
    }

    reportInfo.sort(
        Comparator
            .comparing(
                (Map<String, Object> m) -> parseIndHistoryLogDate(m.get("log_date")),
                Comparator.nullsLast(Comparator.<String>reverseOrder())
            )
            .thenComparing(
                (Map<String, Object> m) -> parseIndHistorySortNo(m.get("sort_no")),
                Comparator.nullsLast(Comparator.naturalOrder())
            )
    );

    return reportInfo;
  }

  private void putIndHistoryUserName(
      Map<String, Object> row,
      Map<String, Object> newValues,
      String userKey,
      String nameKey,
      Map<Long, String> userNameCache) {
    Object value = row.get(userKey);
    if (Objects.isNull(value) || StringUtils.isEmpty(value.toString())) {
      return;
    }
    try {
      Long userId = Long.parseLong(value.toString());
      if (!userNameCache.containsKey(userId)) {
        MstPersonalUser mstPersonalUser = mstPersonalUserDao.selectById(userId);
        String fullName = "";
        if (mstPersonalUser != null) {
          // mod #11513 患者名が指定文字数ぶん出ない 高 start
//          String fullName = mstPersonalUser.getUserLastName() + " " + mstPersonalUser.getUserFirstName();
          fullName = mstPersonalUser.getUserLastName() + "" + mstPersonalUser.getUserFirstName();
          // mod #11513 患者名が指定文字数ぶん出ない 高 end
        }
        userNameCache.put(userId, fullName);
      }
      String fullName = userNameCache.get(userId);
      if (!StringUtils.isEmpty(fullName)) {
        newValues.put(nameKey, fullName);
      }
    } catch (NumberFormatException e) {
      // invalid user id
    }
  }

  private String parseIndHistoryLogDate(Object logDate) {
    if (logDate == null || StringUtils.isEmpty(logDate.toString())) {
      return null;
    }
    return logDate.toString();
  }

  private Integer parseIndHistorySortNo(Object sortNo) {
    if (sortNo == null || StringUtils.isEmpty(sortNo.toString())) {
      return null;
    }
    try {
      if (sortNo instanceof Number) {
        return ((Number) sortNo).intValue();
      }
      return Integer.valueOf(sortNo.toString());
    } catch (NumberFormatException e) {
      return null;
    }
  }
  // add #11625 【標準帳票】クラス「指示履歴」の仕様変更② sunsy end
  /**
   * 値置換SQLの実行
   * 方法を再負荷します。元のメソッドを保持し、呼び出しエラーを防ぎます。
   * @param convSqlItem 値置換用SQL情報
   * @param value 置換対象の値
   * @return 置換後の値
   */
  private Object execConvSql(convSqlItem convSqlItem, Object value ) {
    return this.execConvSql(convSqlItem, value, null);
  }

  /**
   * 値置換SQLの実行
   * @param convSqlItem 値置換用SQL情報
   * @param value 置換対象の値
   * @param sqlCacheMap sqlクエリキャッシュです
   * @return 置換後の値
   */
  private Object execConvSql(convSqlItem convSqlItem, Object value, HashMap<String, Object> sqlCacheMap) {
    if (
      convSqlItem != null &&
        value != null &&
        !"".equals(String.valueOf(value)) &&
        convSqlItem.getSqlCd() != null
    ) {
      Long sqlCode = convSqlItem.getSqlCd();
      Map<String, Object> param = new HashMap<>();
      param.put(convSqlItem.getTargetVar(), value);
      String dataName = convSqlItem.getFieldName();
      // add bug#6772 プレビュー表示、ファイル出力が遅い liuc start
      String CacheKey = value + "_" + dataName;   //キャッシュとしてのkeyです
      if(sqlCacheMap!=null){  // とりあえずキャッシュに取りに行きます
        if(sqlCacheMap.containsKey(CacheKey)){
          value = sqlCacheMap.get(CacheKey);
        }else {
          List<Map<String, Object>> res = this.getDataList(sqlCode, param);
          if (res.size() > 0 && res.get(0).containsKey(dataName)) {
            // 事後実行SQLの結果から値を取得して返り値にセットする
            value = res.get(0).get(dataName);
            //クエリ記録をキャッシュmapに入れます
            sqlCacheMap.put(CacheKey, value);
          }
        }
      }else {
        // キャッシュを使わなければです
        List<Map<String, Object>> res = this.getDataList(sqlCode, param);
        if (res.size() > 0 && res.get(0).containsKey(dataName)) {
          // 事後実行SQLの結果から値を取得して返り値にセットする
          value = res.get(0).get(dataName);
        }
        // add bug#6772 プレビュー表示、ファイル出力が遅い liuc end
      }
    }
    return value;
  }
  /**
   * {@inheritDoc}
   */
  @Override
  public List<SysDataSet> selectForReport() {

    try {
      return sysDataSetDao.selectForReport();
    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      throw new NotExistException("sys_data_setにレコードがありません。");
    }

  }


  /**
   * 二次元帳票用キーの取得
   *
   * @param reportInfo 変換元のデータ
   * @param keyFieldNames キー情報リスト
   * @return キー情報リスト配列
   */
  private List<Map<String, Object>> getMatrixKeyList(List<Map<String, Object>> reportInfo, List<String> keyFieldNames) {
    List<Map<String, Object>> key = new ArrayList<Map<String, Object>>();

    reportInfo.stream().forEach(result -> {
      // キー情報作成
      Map<String, Object> info = new HashMap<String, Object>();
      for( String fieldName : keyFieldNames ) {
        if (result.containsKey(fieldName)) {
          info.put(fieldName, result.get(fieldName));
        }
      }

      // 重複チェック
      if( !key.contains(info) ) {
        key.add(info);
      }
    });

    // ソート実施
    key.sort((a, b) -> {
      int flag = 0;
      for( String fieldName : keyFieldNames ) {
        if( Objects.nonNull(a.get(fieldName))
          && Objects.nonNull(b.get(fieldName))) {
          flag = Objects.compare( a.get(fieldName).toString(), b.get(fieldName).toString(), String::compareTo );
        }
        if( flag != 0 ) {
          break;
        }
      }
      return flag;
    });

    return key;
  }
  /**
   * データ型でのObject→Map<String, Object>へのキャスト処理
   * @param src
   * @return
   */
  @SuppressWarnings("unchecked")
  private <T> T valueObjectCast( Object src ) {
    T cast = (T) src;
    return cast;
  }
  /**
   * {@inheritDoc}
   */
  @Override
  public List<Map<String, Object>> getMatrixDataList(List<Map<String, Object>> reportInfo, List<String> rowFieldName, List<String> colFieldName, List<String> valFieldName) {
    List<Map<String, Object>> matrixInfo = new ArrayList<Map<String, Object>>();
    List<Map<String, Object>> reportRow = this.getMatrixKeyList(reportInfo, rowFieldName );
    List<Map<String, Object>> reportCol = this.getMatrixKeyList(reportInfo, colFieldName );
    int nFldNo[] = {0};
    List<Integer> usedRecnoList = new ArrayList<Integer>();

    // 行キー情報分
    reportRow.forEach( row -> {

      // 行キー情報を変換先データのレコードに追加
      Map<String, Object> rec = new HashMap<String, Object>();
      rec.putAll(row);

      // 列件数
      rec.put("field_count", reportCol.size());

      //
      if( row != null ) {
        // 列キー情報による抽出
        nFldNo[0] = 1;
        reportCol.forEach( col -> {
          // 列情報追加
          String strfld = String.format("field_%d", nFldNo[0]++ );
          rec.put( strfld, new ArrayList<Map<String, Object>>());
          rec.put( strfld + "_col", col);
          //log.debug( col.toString());

          // 変換元データ分
          for( int recno = 0; recno < reportInfo.size(); recno++ ) {
            Map<String, Object> info = reportInfo.get(recno);
            boolean bMatch = true;

            // データが使用済みかどうかの判定
            if( ! usedRecnoList.contains(recno) ) {
              // 行キー情報一致判定
              for( int idx = 0; bMatch && idx <= rowFieldName.size() - 1; idx++ ) {
                String rowFld = rowFieldName.get(idx);
                //log.debug( "row[" + rowFld + "]:" + row.get(rowFld) + " / " +  info.get(rowFld) );
                if( row.containsKey(rowFld)) {
                  if( ! Objects.equals( row.get(rowFld), info.get(rowFld) )) {
                    bMatch = false;
                  }
                } else {
                  bMatch = false;
                }
              }

              // 変換元データ使用判定
              if ( bMatch ) {
                // 行キーが一致

                // 列キー情報一致判定
                for( int idx = 0; bMatch && idx <= colFieldName.size() - 1; idx++ ) {
                  String colFld = colFieldName.get(idx);
                  //log.debug( "col[" + colFld + "]:" + col.get(colFld) + " / " +  info.get(colFld) );
                  if( col.containsKey( colFld )) {
                    if( ! Objects.equals( col.get(colFld), info.get(colFld) )) {
                      bMatch = false;
                    }
                  } else {
                    bMatch = false;
                  }
                }

                // 行列キー一致
                if( bMatch ) {
                  // 行列キー情報が一致

                  // 配置データ配列で作成
                  Map<String, Object> valInfo = new HashMap<String, Object>();
                  for( String fieldName : valFieldName ) {
                    valInfo.put(fieldName, info.get(fieldName));
                  }
                  List<Map<String, Object>> valList = this.valueObjectCast(rec.get(strfld));
                  valList.add(valInfo);

                  // 変換先データの指定された列に配置データ配列を追加
                  rec.put( strfld, valList);

                  // 該当データを使用済みとする
                  usedRecnoList.add(recno);
                }
              }
            }
          }
        });

        // 変換先データのレコードを追加
        matrixInfo.add(rec);
      }
    });

    return matrixInfo;
  }
  /**
   * sys_data_setのuse_applicationのチェック
   * 使用用途に呼出元の使用用途が含まれていない場合はNtssExceptionをthrowする
   *
   * @param useApplication sys_data_setのuse_applicaion
   * @param targetApplication 呼出元の使用用途
   */
  @SuppressWarnings("unchecked")
  private void checkUseApplication(String useApplication, UseApplication targetApplication) {

    // 呼出元の使用用途が設定されていない場合はチェックなし
    if (targetApplication == null) {
      return;
    }
    if (StringUtils.isEmpty(useApplication)) {
      throw new NtssException("sys_data_setにuse_applicationが設定されていません。");
    }
    try {
      // use_application(使用用途)を取得 {"applications": [] }の形式
      Map<String, Object> application = ObjectMapperUtil.read(useApplication
        , ObjectMapperUtil.constructMapType(String.class, List.class));
      if (application.size() != 1) {
        throw new NtssException("use_applicationの形式が不正です。");
      }
      Object list = application.get(UseApplication.JOSN_KEY);
      if (list instanceof List<?>) {
        if (!((List<Integer>) list).contains(targetApplication.getValue())) {
          // 呼出元の使用用途がsys_data_set.use_applicationに含まれない場合はエラー
          throw new NtssException("対象のSqlCodeのデータセットは使用できません。");
        }
      } else {
        // 想定している形式以外
        throw new NtssException("use_applicationの形式が不正です。");
      }
    } catch (IOException e) {
      // リストの変換に失敗
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("use_applicationの変換に失敗しました。" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      throw new NtssException("use_applicationの変換に失敗しました。", e);
    }
  }

  // 課題追加5_MongoDB追加対応 2021/04/20 add start ウ
  public Map<String, Object>  createSelectParameter(String sql, Map<String, Object> dataKey) {
    if (sql != null && sql.length() > 0) {
      JSONObject jsonObject = new JSONObject(sql);
      Iterator iterator = jsonObject.keys();
      while(iterator.hasNext()){
        String key = (String) iterator.next();
        Object value = jsonObject.get(key);
        dataKey.put(key, value);
      }
    }
    return dataKey;
  }

  public List getMongoDBData(Map<String, ?> historyload) {
    try {
      List list = new ArrayList<Object>();
      String collection = "";
      if (historyload.get("collection") != null) {
        collection = (String) historyload.get("collection");
      }else {
        return list;
      }
      // find
      Bson bson = null;
      ArrayList<Bson> arr = new ArrayList();
      if (historyload.get("eq") != null) {
        JSONObject jsonEq = (JSONObject) historyload.get("eq");
        Iterator iterator = jsonEq.keys();
        while (iterator.hasNext()) {
          String key = String.valueOf(iterator.next());
          String value = String.valueOf(jsonEq.get(key));
          arr.add(eq(key, value));
        }
      }
      if (historyload.get("ne") != null) {
        JSONObject jsonNe = (JSONObject) historyload.get("ne");
        Iterator iterator = jsonNe.keys();
        while (iterator.hasNext()) {
          String key = String.valueOf(iterator.next());
          String value = String.valueOf(jsonNe.get(key));
          arr.add(ne(key, value));
        }
      }
      if (historyload.get("gt") != null) {
        JSONObject jsonGt = (JSONObject) historyload.get("gt");
        Iterator iterator = jsonGt.keys();
        while (iterator.hasNext()) {
          String key = String.valueOf(iterator.next());
          String value = String.valueOf(jsonGt.get(key));
          arr.add(gt(key, value));
        }
      }
      if (historyload.get("lt") != null) {
        JSONObject jsonLt = (JSONObject) historyload.get("lt");
        Iterator iterator = jsonLt.keys();
        while (iterator.hasNext()) {
          String key = String.valueOf(iterator.next());
          String value = String.valueOf(jsonLt.get(key));
          arr.add(lt(key, value));
        }
      }
      if (historyload.get("gte") != null) {
        JSONObject jsonGte = (JSONObject) historyload.get("gte");
        Iterator iterator = jsonGte.keys();
        while (iterator.hasNext()) {
          String key = String.valueOf(iterator.next());
          String value = String.valueOf(jsonGte.get(key));
          arr.add(gte(key, value));
        }
      }
      if (historyload.get("lte") != null) {
        JSONObject jsonLte = (JSONObject) historyload.get("lte");
        Iterator iterator = jsonLte.keys();
        while (iterator.hasNext()) {
          String key = String.valueOf(iterator.next());
          String value = String.valueOf(jsonLte.get(key));
          arr.add(lte(key, value));
        }
      }
      // add #11625 【標準帳票】クラス「指示履歴」の仕様変更② 吉 start
      if (historyload.get("or") != null) {
        JSONObject jsonEq = (JSONObject) historyload.get("or");
        Iterator iterator = jsonEq.keys();
        while (iterator.hasNext()) {
          String key = String.valueOf(iterator.next());
          List<Bson> conditions = new ArrayList<>();
          JSONObject ob = new JSONObject((String)jsonEq.get(key));
          for (String obkey : ob.keySet()) {
            Object value = ob.get(obkey);
            switch (obkey) {
              case "gte":
                conditions.add(Filters.gte(key, value.toString()));
                break;
              case "exists":
                conditions.add(Filters.exists(key, (Boolean) value));
                break;
              case "eq":
                conditions.add(Filters.eq(key, value.toString()));
                break;
            }
          }
          Bson orFilter = Filters.or(conditions);
          arr.add(orFilter);
        }
      }
      // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
      if (historyload.get("in") != null) {
        JSONObject jsonIn = (JSONObject) historyload.get("in");
        Iterator iterator = jsonIn.keys();
        while (iterator.hasNext()) {
          String key = String.valueOf(iterator.next());
          String strValue = String.valueOf(jsonIn.get(key));
          strValue = strValue.replace("(", "").replace(")", "");
          String[] values = strValue.split(",");
          arr.add(Filters.in(key, values));
        }
      }
      // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
      // add #11625 【標準帳票】クラス「指示履歴」の仕様変更② 吉 end
      // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
      Integer sliceNm = 0;
      if (historyload.get("slice") != null) {
        JSONObject jsonSlice = (JSONObject) historyload.get("slice");
        Iterator iterator = jsonSlice.keys();
        while(iterator.hasNext()){
          String key = (String) iterator.next();
          sliceNm = (Integer) jsonSlice.get(key);
        }
      }
      // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
      if (arr.size() > 1) {
        bson = and(arr);
      }
      else if (arr.size() == 1) {
        bson = arr.get(0);
      }
      // sort
      Bson sortBson = null;
      ArrayList<Bson> sortArr = new ArrayList();
      if (historyload.get("sort") != null) {
        JSONObject jsonSort = (JSONObject) historyload.get("sort");
        Iterator iterator = jsonSort.keys();
        while(iterator.hasNext()){
          String key = (String) iterator.next();
          String value = (String) jsonSort.get(key);
          if ("desc".equals(value)) {
            sortArr.add(descending(key));
          } else {
            sortArr.add(ascending(key));
          }
        }
      }
      if (sortArr.size() > 1) {
        sortBson = orderBy(sortArr);
      }
      else if (sortArr.size() == 1) {
        sortBson = sortArr.get(0);
      }

      // search
      FindIterable<Document> findResult = null;

      //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
      try {
        if (MongoHealthCheckService.getMongoDBConnected()) {
          // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
          if (historyload.get("in") != null) {
            JSONObject jsonIn = (JSONObject) historyload.get("in");
            String patIdKey = "pat_id";
            String values = jsonIn.getString(patIdKey)
              .replace("(", "")
              .replace(")", "");
            String[] patIdArray = values.split(",");
            List<Document> result = new ArrayList<>();
            for (String pid : patIdArray) {
              List<Bson> subFilters = new ArrayList<>();
              subFilters.add(Filters.eq("pat_id", pid.trim()));
              if (bson != null) {
                subFilters.add(bson);
              }
              Bson finalFilter = Filters.and(subFilters);
              Document one = mongoTemplate.getCollection(collection)
                .find(finalFilter)
                .sort(Sorts.descending("up_date"))
                .limit(1)
                .first();
              if (one != null) result.add(one);
            }
            return result;
          }else{
            // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
            if (bson == null) {
              findResult = mongoTemplate.getCollection(collection).find();
            }
            else {
              findResult = mongoTemplate.getCollection(collection).find(bson);
              // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
            }
            // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
          }
        }
      } catch (DataAccessResourceFailureException exception) {
        MongoHealthCheckService.setMongoDBConnected(false);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
      //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end

      if (sortBson != null) {
        findResult = findResult.sort(sortBson);
      }
      // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
      if (sliceNm != 0) {
        findResult = findResult.limit(sliceNm);
      }

      if (collection.equals("ind_history")) {
        findResult = findResult.skip(sliceNm);
      }
      // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
      for(Document document : findResult) {
        if (historyload.get("column") != null) {
          Map<String, Object> map = new HashMap();
          ArrayList<String> colArr = (ArrayList) historyload.get("column");
          colArr.forEach(everyCol -> {
            map.put(everyCol, document.get(everyCol));

          });
          list.add(map);
        }
        else {
          list.add(document);
        }
      }
      return list;
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e);
    }
  }
  // 課題追加5_MongoDB追加対応 2021/04/20 add end ウ

  public List getMongoDBDataForIndHistory(Map<String, ?> historyload, int num) {
    try {
      List list = new ArrayList<Object>();
      String collection = "";
      if (historyload.get("collection") != null) {
        collection = (String) historyload.get("collection");
      }else {
        return list;
      }
      // find
      Bson bson = null;
      ArrayList<Bson> arr = new ArrayList();
      if (historyload.get("eq") != null) {
        JSONObject jsonEq = (JSONObject) historyload.get("eq");
        Iterator iterator = jsonEq.keys();
        while(iterator.hasNext()){
          String key = (String) iterator.next();
          String value = (String) jsonEq.get(key);
          arr.add(eq(key , value));
        }
      }

      if (arr.size() > 1) {
        bson = and(arr);
      }
      else if (arr.size() == 1) {
        bson = arr.get(0);
      }

      //add 10248 mongodbリンク可能状態による関連操作の処理 gjn start
      try {
        if (MongoHealthCheckService.getMongoDBConnected()) {
          // search
          FindIterable<Document> findResult = mongoTemplate.getCollection(collection).find(bson);
          Integer sliceNm = 20000;
          if (findResult != null) {
            findResult = findResult.limit(sliceNm);
            findResult = findResult.skip(num * sliceNm);

            for (Document document : findResult) {
              list.add(document);
            }
          }
        }
      } catch (DataAccessResourceFailureException exception) {
        MongoHealthCheckService.setMongoDBConnected(false);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(exception));
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
      }
      //add 10248 mongodbリンク可能状態による関連操作の処理 gjn end
      return list;
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new RuntimeException(e);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public Map<Long, List<Map<String, Object>>> getSqlDataForOnePatient(List<String> sqlCodes, Map<String, Object> dataKey) {

    Map<Long, List<Map<String, Object>>> rtnDataSet = new HashMap<>();

    // sqlcdでループ処理を実施
    for (String sqlCdStr : sqlCodes) {

      if (!sqlCdStr.matches("^[0-9]+$")) {
        // sqlcdが数値ではなかった場合、処理をスキップする
        continue;
      }

      Long sqlCode = Long.parseLong(sqlCdStr);
      // SysDataSetを取得する
      SysDataSet sysDataSet = getSysDataSet(sqlCode);
      if (sysDataSet == null) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("指定されたsqlCodeがDBに登録されていません。sqlCd:" + sqlCode);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        continue;
      }

      // sql取得
      String sql = sysDataSet.getSql();
      // SQLに何も登録されていない場合、そのsqlcdの処理をスキップする
      if (StringUtils.isEmpty(sql)) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("指定されたsqlCodeにSQLが登録されていません。sqlCd:" + sqlCode);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        continue;
      }

      // 事前実行SQLがあれば実行して結果をパラメータに追加
      dataKey = this.preExecSql(sysDataSet.getPreSqlInfo(), dataKey);

      List<Map<String, Object>> tmpData = new ArrayList<Map<String, Object>>();
      // datakey の クローンを作成 ( execSysDataSet 処理内で内容が変更される為、後続処理に影響が出ないように分けておく )
      Map<String,Object> cloneDataKey = new HashMap<>();
      cloneDataKey.putAll(dataKey); // 新規作成オブジェクトにputAllでクローン扱いになります
      // mod #9743 紋別帳票の表示不具合（観察記録20180810） limingzhe start
      String sql1 = removeComments(sql);
      // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする limingzhe start
      //if (sql.contains("@ordNo")) {
      //if (sql.contains("@ordNo") && !sql.contains("@ordNos")) {
      // mod #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする limingzhe end
      if (sql1.contains("@ordNo") && !sql1.contains("@ordNos")) {
      // mod #9743 紋別帳票の表示不具合（観察記録20180810） limingzhe end
          // sql にパラメータ「@ordNo」を含む場合、パラメータの ordNo の件数分、sqlを実施し、結果を合算する

        // datakey の ordNos でループ
        // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe start
//        List<Long> ordNoList = (List<Long>) cloneDataKey.get(ReportConstant.ReportDataKey.ORD_NOS);
        List<Long> ordNoList = new ArrayList<>();
        if (cloneDataKey.get(ReportConstant.ReportDataKey.ORD_NOS) == null) {
          if(cloneDataKey.get(ReportConstant.ReportDataKey.ORD_NO) != null)
            ordNoList.add(Long.parseLong(cloneDataKey.get(ReportConstant.ReportDataKey.ORD_NO).toString()));
        } else {
          ordNoList = (List<Long>) cloneDataKey.get(ReportConstant.ReportDataKey.ORD_NOS);
        }
        // mod #11254 機能帳票でオーダ番号をキーとする情報が出ない limingzhe end
        // add #9558 機能帳票でパラメータが正しく渡されていない 杜天成 start
        if(ordNoList != null) {
          // add #9558 機能帳票でパラメータが正しく渡されていない 杜天成 end
          for (Long ordNo : ordNoList) {
            // datakey の クローンに、 ordNo を設定
            cloneDataKey.put(ReportConstant.ReportDataKey.ORD_NO, ordNo);
            // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
            if(sqlCode == 239L){
              if(sql.contains("@equsort")) sql = sql.replaceAll("@equsort", dataKey.get("equsort").toString());
              if(sql.contains("@medsort")) sql = sql.replaceAll("@medsort", dataKey.get("medsort").toString());
            }
            // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
            // datakey の クローンをパラメータにsql を1回実施
            List<Map<String, Object>> tmpOrdData = execSysDataSet(sql, sysDataSet, cloneDataKey);
            // add 10708 by kangjie 20240618 start
            // 発信前
            if (sqlCode == 228L) {
              // query mongo
              dataKey.put("ordNo", ordNo);
              tmpOrdData = this.getDataListContainsError(sqlCode, dataKey, null);
            }
            // add 10708 by kangjie 20240618 end
            // ord_no のパラメータを追加
            if (null != tmpOrdData && tmpOrdData.size() > 0) {
              // 内容が空ではない場合、データ内容に ord_no 項目を含まない場合、ord_no 項目を追加する
              for (Map<String, Object> ordData : tmpOrdData) {
                if (null != ordData && ordData.size() > 0 && !ordData.containsKey("ord_no")) {
                  ordData.put("ord_no", ordNo);
                }
              }
            }

            // 処理結果を合算
            tmpData.addAll(tmpOrdData);
          }
        }
      // mod #9743 紋別帳票の表示不具合（観察記録20180810） limingzhe start
      //} else if (sql.contains("@ordPrescriptionNo")) {
      // mod #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 sunsy start
//      } else if (sql1.contains("@ordPrescriptionNo")) {
      } else if (sql1.contains("@ordPrescriptionNo") || sql1.contains("@ordPreNo")) {
      // mod #10526 クラス「処方情報」の「保険者番号」等に一桁づつ出力するデータセットを追加 sunsy end
      // mod #9743 紋別帳票の表示不具合（観察記録20180810） limingzhe end
        // sql にパラメータ「@ordPrescriptionNo」を含む場合、パラメータの ordPrescriptionNos の件数分、sqlを実施し、結果を合算する

        // datakey の ordPrescriptionNos でループ
        // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
        //List<Long> ordPresNoList = (List<Long>) cloneDataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS);
        List<Long> ordPresNoList = new ArrayList<>();
        if (cloneDataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS) == null) {
          if(cloneDataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO) != null)
            ordPresNoList.add(Long.parseLong(cloneDataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO).toString()));
        } else {
          ordPresNoList = (List<Long>) cloneDataKey.get(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS);
        }
        // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
        for (Long ordPrescriptionNo : ordPresNoList) {
          // datakey の クローンに、 ordPrescriptionNo を設定
          cloneDataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO, ordPrescriptionNo);

          // datakey の クローンをパラメータにsql を1回実施
          // 「処方箋」prescription の略語には Rx というものが使われます
          List<Map<String, Object>> rxData = execSysDataSet(sql, sysDataSet, cloneDataKey);

          // ord_prescription_no のパラメータを追加
          if (null != rxData && rxData.size() > 0) {
            // 内容が空ではない場合、データ内容に ord_prescription_no 項目を含まない場合、ord_prescription_no 項目を追加する
            for (Map<String, Object> rx : rxData) {
              if (null != rx && rx.size() > 0 && !rx.containsKey("ord_prescription_no")) {
                rx.put("ord_prescription_no", ordPrescriptionNo);
              }
            }
          }

          // 処理結果を合算
          tmpData.addAll(rxData);
        }

      } else {
        // その他

        // datakey をパラメータに、sqlを1回実施
        tmpData = execSysDataSet(sql, sysDataSet, cloneDataKey);
      }

      // sqlcd 毎の処理結果を集計
      rtnDataSet.put(sqlCode, tmpData);
    }

    return rtnDataSet;
  }

  /**
   * sys_data_set の sql を実行
   * ※ MongoDBの処理の際、dataKey.fromDate のフォーマットが変更されるため、必ず元データを clone してから引数に渡してください
   */
  private List<Map<String, Object>> execSysDataSet(String sql, SysDataSet sysDataSet, Map<String, Object> dataKey) {
    // dbClass(どのdbを使うか) は、not null 制約があるカラムの為、チェック処理不要
    Integer dbClass = sysDataSet.getDbClass();

    List<Map<String, Object>> reportInfo = new ArrayList<Map<String, Object>>();

    // SelectBuilderを作成し実行する
    // SQL実行でエラーが発生しても、後続処理を継続する.
    try {
      // 接続先に応じて SelectBuilder を作成
      if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
        // 接続先：DB5
        Config config = defaultDbConfig;
        SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
        reportInfo = sysDataSetDao.executeSql(selectBuilder);
        // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
        if (dataKey != null ) {
          String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
        }
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
      } else if (SysDataSet.DB_CLASS_DB6.equals(dbClass)) {
        // 接続先：DB6
        Config config = personalDbConfig;
        SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
        reportInfo = sysDataSetPersonalDao.executeSql(selectBuilder);
        // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
        if (dataKey != null ) {
          String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
        }
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
      } else if (SysDataSet.DB_CLASS_DB4.equals(dbClass)) {
        // 接続先：DB4
        Config config = authDbConfig;
        SelectBuilder selectBuilder = createSelectBuilder(config, sql, dataKey);
        reportInfo = sysDataSetAuthorityDao.executeSql(selectBuilder);
        // #9698 アプリケーションログの内容修正 20260327 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("SYSDATASET—LOG : sqlCd = [" + sysDataSet.getSqlCd() + "]"+"parameters =" + dataKey);
        if (dataKey != null ) {
          String facilityCd = Objects.toString(dataKey.get("facilityCd"), null);
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
        }
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
        // #9698 アプリケーションログの内容修正 20260327 add yangxuewang end
      } else if (SysDataSet.DB_CLASS_MONGODB.equals(dbClass)) {
        // 接続先：MongoDB
        // mod #11554 データクラス「指示履歴」の仕様変更 sunsy start
        String strFromDate = "";
        String strToDate = "";
        // mod #11625 【標準帳票】クラス「指示履歴」の仕様変更② sunsy start
//        if (sql.contains("ind_history")) {
        if (sql.contains("ind_history") && !sql.contains("treatment_start_date") && !sql.contains("treatment_end_date")) {
        // mod #11625 【標準帳票】クラス「指示履歴」の仕様変更② sunsy end
          // 指示履歴専用のfromdate取得処理、発症日のフォーマットが「yyyyMMddHHmmssSSS」であり、日付により抽出を満足するため、開始日を「yyyyMMdd000000000」にする
          if (dataKey.containsKey("fromDate") && !"".equals(dataKey.get("fromDate")) && null != dataKey.get("fromDate")) {
            strFromDate = dataKey.get("fromDate").toString().replace("-", "").replace("/", "");
            SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
            String dofromDate = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(df.parse(strFromDate));
            dataKey.replace("fromDate", dofromDate);
          }
          // 指示履歴専用のtodate取得処理、発症日のフォーマットが「yyyyMMddHHmmssSSS」であり、日付により抽出を満足するため、終了日を「yyyyMMdd235959999」にする
          if (dataKey.containsKey("endDate") && !"".equals(dataKey.get("endDate")) && null != dataKey.get("endDate")) {
            strToDate = dataKey.get("endDate").toString().replace("-", "").replace("/", "");
            SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
            Date dateToDate = df.parse(strToDate);
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(dateToDate);
            calendar.set(Calendar.HOUR_OF_DAY, 23);
            calendar.set(Calendar.MINUTE, 59);
            calendar.set(Calendar.SECOND, 59);
            calendar.set(Calendar.MILLISECOND, 999);
            String dotoDate = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(calendar.getTime());
            dataKey.put("endDate", dotoDate);
          } else if (dataKey.containsKey("toDate") && !"".equals(dataKey.get("toDate")) && null != dataKey.get("toDate")) {
            strToDate = dataKey.get("toDate").toString().replace("-", "").replace("/", "");
            SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
            Date dateToDate = df.parse(strToDate);
            Calendar calendar = Calendar.getInstance();
            calendar.setTime(dateToDate);
            calendar.set(Calendar.HOUR_OF_DAY, 23);
            calendar.set(Calendar.MINUTE, 59);
            calendar.set(Calendar.SECOND, 59);
            calendar.set(Calendar.MILLISECOND, 999);
            String dotoDate = new SimpleDateFormat("yyyyMMddHHmmssSSS").format(calendar.getTime());
            dataKey.put("endDate", dotoDate);
          }
          // add #11625 【標準帳票】クラス「指示履歴」の仕様変更② sunsy start
        }else if (sql.contains("ind_history") && sql.contains("treatment_start_date") && sql.contains("treatment_end_date")) {
          if (dataKey.containsKey("fromDate") && !"".equals(dataKey.get("fromDate")) && null != dataKey.get("fromDate")) {
            strFromDate = dataKey.get("fromDate").toString().replace("-", "").replace("/", "");
            dataKey.replace("fromDate", strFromDate);
          }
          if (dataKey.containsKey("endDate") && !"".equals(dataKey.get("endDate")) && null != dataKey.get("endDate")) {
            strToDate = dataKey.get("endDate").toString().replace("-", "").replace("/", "");
            dataKey.put("endDate", strToDate);
          }else if (dataKey.containsKey("toDate") && !"".equals(dataKey.get("toDate")) && null != dataKey.get("toDate")) {
            strToDate = dataKey.get("toDate").toString().replace("-", "").replace("/", "");
            dataKey.put("endDate", strToDate);
          }
          // add #11625 【標準帳票】クラス「指示履歴」の仕様変更② sunsy end
        }else {
          // 日付フォーマットの変更
          // up_date項目の比較に利用するため YYYY-MM-DD形式に変換します。変換元は、YYYY-MM-DD、YYYY/MM/DD、YYYYMMDD形式のいずれかであることが前提です
//        String strFromDate = "";
          // add #10645 mongoDBのSQLでup_dateの比較が@fromDateと@toDateと混在している zy start
          if (dataKey.containsKey("fromDate") && !"".equals(dataKey.get("fromDate")) &&  null != dataKey.get("fromDate")) {
            strFromDate = dataKey.get("fromDate").toString().replace("-", "").replace("/", "");
            SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
            String doFromDate = new SimpleDateFormat("yyyy-MM-dd").format(df.parse(strFromDate)) + " 23:59:59";
            dataKey.replace("fromDate", doFromDate);
          }
          // add #10645 mongoDBのSQLでup_dateの比較が@fromDateと@toDateと混在している zy end
          // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
          if (dataKey.containsKey("toDate") && !"".equals(dataKey.get("toDate")) && null != dataKey.get("toDate")) {
            strFromDate = dataKey.get("toDate").toString().replace("-", "").replace("/", "");
            SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
            String dotoDate = new SimpleDateFormat("yyyy-MM-dd").format(df.parse(strFromDate)) + " 23:59:59";
            dataKey.replace("toDate", dotoDate);
          } else
            // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
            if (dataKey.containsKey("fromDate") && !"".equals(dataKey.get("fromDate")) && null != dataKey.get("fromDate")) {
              strFromDate = dataKey.get("fromDate").toString().replace("-", "").replace("/", "");
              SimpleDateFormat df = new SimpleDateFormat("yyyyMMdd");
              String dotoDate = new SimpleDateFormat("yyyy-MM-dd").format(df.parse(strFromDate)) + " 23:59:59";
              // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy start
              // dataKey.replace("fromDate", doFromDate);
              dataKey.replace("toDate", dotoDate);
              // add #9452 因島帳票の表示不具合（患者個別TMP平均値） jjy end
            }
        }
        // mod #11554 データクラス「指示履歴」の仕様変更 sunsy end

        // add 10210 帳票における患者情報の取得元について sunsy start
        String facilityCd = "";
        if (dataKey.containsKey("facilityCd") && !"".equals(dataKey.get("facilityCd"))) {
          facilityCd = dataKey.get("facilityCd").toString();
        }
        // add 10210 帳票における患者情報の取得元について sunsy end

        // sql 末尾の detail項目取得、取得後のsql整形
        String doDetailInfoWord = "";
        if (!sql.endsWith("}}")){
          String a = sql.substring(0, sql.lastIndexOf("}"));
          String b = a.substring(a.lastIndexOf("}") + 1, a.length());
          doDetailInfoWord = b.substring(1, b.length());
          sql = sql.replace(b, "");
        }

        // パラメータの置き換え
        for (String key: dataKey.keySet()) {
          sql = sql.replace("@" + key, dataKey.get(key) == null ? "" : dataKey.get(key).toString());
        }

        // add 10210 帳票における患者情報の取得元について sunsy start
        // mod #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy start
//        if (sql.contains("@insuranceCd")) {
        if (sql.contains("@insuranceCd") && sysDataSet.getMemo().contains("処方(最新)")) {
        // mod #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy end
          Long ordPrescriptionNo = ordPrescriptionDao.getOrdPrescriptionNoOne(Long.parseLong(String.valueOf(dataKey.get("patId"))), String.valueOf(dataKey.get("fromDate")), String.valueOf(dataKey.get("facilityCd")));
          OrdPersonalPrescription ordPersonalPrescription = ordPersonalPrescriptionDao.selectByOrdPrescriptionNo(ordPrescriptionNo);
          sql = sql.replace("@insuranceCd", String.valueOf(ordPersonalPrescription.getInsuranceCd()));
          // add #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240620 sunsy start
          sql = sql.replace("@upDate", String.valueOf(ordPersonalPrescription.getUpDate()));
          // add #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240620 sunsy end
        }
        // add #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy start
        if (sql.contains("@insuranceCd") && sysDataSet.getMemo().contains("処方")) {
          if (dataKey.containsKey("ordPrescriptionNos") || dataKey.get("ordPrescriptionNos") != null) {
            List ordPreList = (List) dataKey.get("ordPrescriptionNos");
            Long ordPrescriptionNo = Long.parseLong(String.valueOf(ordPreList.get(0)));
            OrdPersonalPrescription ordPersonalPrescription = ordPersonalPrescriptionDao.selectByOrdPrescriptionNo(ordPrescriptionNo);
            sql = sql.replace("@insuranceCd", String.valueOf(ordPersonalPrescription.getInsuranceCd()));
            // add #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240620 sunsy start
            sql = sql.replace("@upDate", String.valueOf(ordPersonalPrescription.getUpDate()));
            // add #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240620 sunsy end
          }
        }
        // add #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy end
        // add 10210 帳票における患者情報の取得元について sunsy end
        // MongoDBからデータの取得
        Map<String, Object> mongoDBDataKey = new HashMap<String, Object>();
        mongoDBDataKey = this.createSelectParameter(sql, mongoDBDataKey);
        reportInfo = getMongoDBData(mongoDBDataKey);
        // add 10210 帳票における患者情報の取得元について 20240620 sunsy start
        // del #9650 治療経過表、カテゴリ「患者情報」の項目出力不正 limingzhe start
//        if (null != reportInfo && reportInfo.size() > 0 && "1".equals(reportInfo.get(0).get("is_del")) && "14".equals(sysDataSet.getSqlCd().toString())) {
//          reportInfo.clear();
//        }
        // del #9650 治療経過表、カテゴリ「患者情報」の項目出力不正 limingzhe end
        // add 10210 帳票における患者情報の取得元について 20240620 sunsy end
        // add #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　start
        if("pat_memo_info".equals(doDetailInfoWord)){
          SelectOptions selectOptions = SelectOptions.get();
          MstPatMemo params = new MstPatMemo();
          params.setFacilityCd(String.valueOf(dataKey.get("facilityCd")));
          List<MstPatMemo> list = mstPatMemoDao.selectAll(selectOptions, params);
          if(list != null && list.size() > 0){
            for (Map<String, Object> map : reportInfo) {
              if(map.containsKey("pat_memo_info")){
                List<Map<String, Object>> reportInfoDetailInfoWord = map.get("pat_memo_info") != null ? (List<Map<String, Object>>)map.get("pat_memo_info") : new LinkedList<>();
                List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
                for (int d = 0; d < reportInfoDetailInfoWord.size(); d++){
                  Map<String, Object> currentMap = reportInfoDetailInfoWord.get(d);
                  if(currentMap.containsKey("ctl_no")){
                    for(MstPatMemo mstPatMemo : list){
                      if(String.valueOf(mstPatMemo.getPatMemoNo()).equals(currentMap.get("ctl_no").toString())){
                        if ("1".equals(mstPatMemo.getIsDisp()) && "0".equals(mstPatMemo.getIsDel())){
                          reportInfoDetailInfoWordMiddle.add(currentMap);
                        }
                      }
                    }
                  }
                }
                map.put("pat_memo_info", reportInfoDetailInfoWordMiddle);
              }
            }
          }
        }
        // add #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　end
        // MongoDBのデータ置き換え処理を実施
        // mod #10210 帳票における患者情報の取得元について sunsy start
//        reportInfo = replaceDataForMongDb(doDetailInfoWord, reportInfo, sql, strFromDate, sysDataSet);
        if (null != reportInfo && reportInfo.size() > 0) {
          // mod #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 start
          // reportInfo = replaceDataForMongDb(doDetailInfoWord, reportInfo, sql, strFromDate, sysDataSet, facilityCd);
          dataKey.put("strFromDate",strFromDate);
          reportInfo = replaceDataForMongDb(doDetailInfoWord, reportInfo, sql, sysDataSet,dataKey);
          // mod #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 end
        }
        // mod #10210 帳票における患者情報の取得元について sunsy end

      } else {
        throw new NtssException("想定しないDB種別が指定されています。");
      }

      // 帳票出力情報を返却用に置き換える（フィールド名をデータ項目コードに置き換える）
      return replaceReportInfo(reportInfo, sysDataSet.getDetailInfo().getDetails());

    } catch (Exception ex) {
      // 例外が発生した場合には、空のリストを返却する.
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("帳票用のデータ取得に失敗しました。sqlCd:" + sysDataSet.getSqlCd());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      Map<String, Object> map = new HashMap<String, Object>();
      map.put("error", eventLogMessage.getLogMessage());
      List<Map<String, Object>> errData = new ArrayList<Map<String, Object>>();
      errData.add(map);
      return errData;
    }
  }

  /**
   * MongoDBの出力結果データを置き換える処理
   */
  // mod #10210 帳票における患者情報の取得元について sunsy start
//  private List<Map<String, Object>> replaceDataForMongDb(String doDetailInfoWord, List<Map<String, Object>> reportInfo, String sql, String strFromDate, SysDataSet sysDataSet) throws Exception {
	// mod #11679 複数患者帳票で「透析条件.補液量」が出ない 20250417 高　start
// private List<Map<String, Object>> replaceDataForMongDb(String doDetailInfoWord, List<Map<String, Object>> reportInfo, String sql, String strFromDate, SysDataSet sysDataSet, String facilityCd) throws Exception {
  // mod #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 start
  //public List<Map<String, Object>> replaceDataForMongDb(String doDetailInfoWord, List<Map<String, Object>> reportInfo, String sql, String strFromDate, SysDataSet sysDataSet, String facilityCd) throws Exception {
  public List<Map<String, Object>> replaceDataForMongDb(String doDetailInfoWord, List<Map<String, Object>> reportInfo, String sql, SysDataSet sysDataSet,Map<String,Object>dataKey) throws Exception {
    // mod #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 end
  	// mod #11679 複数患者帳票で「透析条件.補液量」が出ない 20250417 高　end
    // mod #10210 帳票における患者情報の取得元について sunsy end

    // 操作のMongoDBにの表名取得
    int doSqlIndHistory = sql.indexOf("ind_history");
    int doSqlPatPersonalMainHistory = sql.indexOf("pat_personal_main_history");
    int doSqlPatMainHistory = sql.indexOf("pat_main_history");
    int doSqlPatUniqueHistory = sql.indexOf("pat_unique_history");
    int doSqlPatInsuranceHistory = sql.indexOf("pat_insurance_history");
    int doSqlpatGroupDetailHistory = sql.indexOf("pat_group_detail_history");
    // add #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 start
    String facilityCd = String.valueOf(dataKey.get("facilityCd"));
    String strFromDate = String.valueOf(dataKey.get("strFromDate"));
    // add #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 end
    // mod #10740 指示.修正内容の出力不正 sunsy start
    if (doSqlIndHistory >= 0) {
      return getIndHistoryInfoMongo(reportInfo);
    }
    // mod #10740 指示.修正内容の出力不正 sunsy end
    else if (
        (!"".equals(doDetailInfoWord) && (doSqlPatPersonalMainHistory >= 0 || doSqlPatMainHistory >= 0
        || doSqlPatUniqueHistory >= 0 || doSqlPatInsuranceHistory >= 0 || doSqlpatGroupDetailHistory >= 0)) && reportInfo.size() > 0) {

      String doOrder = "";
      String doCheckWordValue = "";
      // 昇順、降順の取得
      if (doDetailInfoWord.endsWith("_asc")){
        doOrder = "asc";
        doDetailInfoWord = doDetailInfoWord.replace("_asc", "");
      } else if (doDetailInfoWord.endsWith("_desc")){
        doOrder = "desc";
        doDetailInfoWord = doDetailInfoWord.replace("_desc", "");
      }

      if (doDetailInfoWord.contains("=") && doDetailInfoWord.contains("(") && doDetailInfoWord.contains(")")) {
        int strL = doDetailInfoWord.indexOf("(");
        int strR = doDetailInfoWord.indexOf(")");
        doCheckWordValue = doDetailInfoWord.substring(strL + 1, strR);
        doDetailInfoWord = doDetailInfoWord.substring(0, strL);
      }
      boolean doDetailInfoFlag = false;
      // 結果中のDetail内容の取得
      List<Map<String, Object>> reportInfoDetailInfoWord = new LinkedList<>();
      String doJsonStr = "";
      if (!"none".equals(doDetailInfoWord) && !doDetailInfoWord.contains("&")){
        // add #10210帳票における患者情報の取得元について sunsy start
        if ("dial_diff_com_info_all".equals(doDetailInfoWord)) {
          doJsonStr = String.valueOf(reportInfo.get(0).get("dial_diff_com_info"));
        }
        // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
        else if ("dial_diff_com_info_receipt".equals(doDetailInfoWord)) {
          doJsonStr = String.valueOf(reportInfo.get(0).get("dial_diff_com_info"));
        }
        // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
        // mod #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
        //else {
        else if ("period_start_date".equals(doDetailInfoWord)) {
          doJsonStr = String.valueOf(reportInfo.get(0).get("in_out_visit_history_info"));
        }
        else if(reportInfo.get(0).containsKey(doDetailInfoWord)){
        // mod #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
          doJsonStr = String.valueOf(reportInfo.get(0).get(doDetailInfoWord));
        }
        // add #10210帳票における患者情報の取得元について sunsy end
        // del #10210帳票における患者情報の取得元について sunsy start
//        doJsonStr = reportInfo.get(0).get(doDetailInfoWord).toString();
        // del #10210帳票における患者情報の取得元について sunsy end
        if (doJsonStr.startsWith("[{")){
          // mdoe 2023/07/06 kangjie start eol_6805
//          reportInfoDetailInfoWord = (List<Map<String, Object>>) BasicDBObject.parse(doJsonStr);
          reportInfoDetailInfoWord = ObjectMapperUtil.readListOfMap(doJsonStr);
          // mdoe 2023/07/06 kangjie end eol_6805
        } else if (doJsonStr.startsWith("{")){
          Map maps = (Map) BasicDBObject.parse(doJsonStr);
          reportInfoDetailInfoWord.add(maps);
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 sunsy start
        } else if (doJsonStr.contains("[Document{{")){
          Gson gson = new Gson();
          if ("dial_diff_com_info_all".equals(doDetailInfoWord)) {
            String jsonString = gson.toJson(reportInfo.get(0).get("dial_diff_com_info"));
            reportInfoDetailInfoWord = ObjectMapperUtil.readListOfMap(jsonString);
          }
          // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
          else if ("dial_diff_com_info_receipt".equals(doDetailInfoWord)) {
            String jsonString = gson.toJson(reportInfo.get(0).get("dial_diff_com_info"));
            reportInfoDetailInfoWord = ObjectMapperUtil.readListOfMap(jsonString);
          }
          // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
          // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
          else if ("period_start_date".equals(doDetailInfoWord)) {
            String jsonString = gson.toJson(reportInfo.get(0).get("in_out_visit_history_info"));
            reportInfoDetailInfoWord = ObjectMapperUtil.readListOfMap(jsonString);
          }
          // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
          else {
            String jsonString = gson.toJson(reportInfo.get(0).get(doDetailInfoWord));
            reportInfoDetailInfoWord = ObjectMapperUtil.readListOfMap(jsonString);
          }
        } else if (doJsonStr.contains("Document{{")){
          Gson gson = new Gson();
          String jsonString = gson.toJson(reportInfo.get(0).get(doDetailInfoWord));
          Map maps = (Map) BasicDBObject.parse(jsonString);
          reportInfoDetailInfoWord.add(maps);
        // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 sunsy end
        }
      }

      // 緊急連絡先部分
      if ("other_contact_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        for (int d = 0; d < reportInfoDetailInfoWord.size(); d++){
          Map<String, Object> detailInfoMiddle = new HashMap<>();
          reportInfoDetailInfoWordMiddle.add(detailInfoMiddle);
          String lastName = "";
          String firstName = "";
          String lastNameKana = "";
          String firstNameKana = "";
          for (String key : reportInfoDetailInfoWord.get(d).keySet()) {
            if ("last_name".equals(key) && reportInfoDetailInfoWord.get(d).get(key) != null){
              lastName = String.valueOf(reportInfoDetailInfoWord.get(d).get(key));
            } else if ("first_name".equals(key) && reportInfoDetailInfoWord.get(d).get(key) != null){
              firstName = String.valueOf(reportInfoDetailInfoWord.get(d).get(key));
            } else if ("last_name_kana".equals(key) && reportInfoDetailInfoWord.get(d).get(key) != null){
              lastNameKana = String.valueOf(reportInfoDetailInfoWord.get(d).get(key));
            } else if ("first_name_kana".equals(key) && reportInfoDetailInfoWord.get(d).get(key) != null){
              firstNameKana = String.valueOf(reportInfoDetailInfoWord.get(d).get(key));
            } else {
              reportInfoDetailInfoWordMiddle.get(d).put(key, reportInfoDetailInfoWord.get(d).get(key));
            }
          }
          // 氏名を追加する
          // mod #11513 患者名が指定文字数ぶん出ない 高 start
//          reportInfoDetailInfoWordMiddle.get(d).put("other_name", lastName + " " + firstName);
          reportInfoDetailInfoWordMiddle.get(d).put("other_name", lastName + "" + firstName);
          // mod #11513 患者名が指定文字数ぶん出ない 高 end
          lastName = "";
          firstName = "";
          // 氏名フリガナを追加する
          // mod #11513 患者名が指定文字数ぶん出ない 高 start
//          reportInfoDetailInfoWordMiddle.get(d).put("other_name_kana", lastNameKana + " " + firstNameKana);
          reportInfoDetailInfoWordMiddle.get(d).put("other_name_kana", lastNameKana + "" + firstNameKana);
          // mod #11513 患者名が指定文字数ぶん出ない 高 end
          lastNameKana = "";
          firstNameKana = "";
        }
        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
      }
      // 業者連絡先部分
      else if ("vendor_contact_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        for (int d = 0; d < reportInfoDetailInfoWord.size(); d++){
          Map<String, Object> detailInfoMiddle = new HashMap<>();
          reportInfoDetailInfoWordMiddle.add(detailInfoMiddle);
          String workerLastName = "";
          String workerFirstName = "";
          for (String key : reportInfoDetailInfoWord.get(d).keySet()){
            if ("worker_last_name".equals(key) && reportInfoDetailInfoWord.get(d).get(key) != null){
              workerLastName = String.valueOf(reportInfoDetailInfoWord.get(d).get(key));
              // 担当者名を追加する
            } else if ("worker_first_name".equals(key) && reportInfoDetailInfoWord.get(d).get(key) != null){
              workerFirstName = String.valueOf(reportInfoDetailInfoWord.get(d).get(key));
            } else if ("fax".equals(key)){
              reportInfoDetailInfoWordMiddle.get(d).put("company_fax", reportInfoDetailInfoWord.get(d).get(key));
            } else {
              reportInfoDetailInfoWordMiddle.get(d).put(key, reportInfoDetailInfoWord.get(d).get(key));
            }

            if (!"".equals(workerLastName) && !"".equals(workerFirstName)){
              // mod #11513 患者名が指定文字数ぶん出ない 高 start
//              reportInfoDetailInfoWordMiddle.get(d).put("worker_name", workerLastName + " " + workerFirstName);
              reportInfoDetailInfoWordMiddle.get(d).put("worker_name", workerLastName + "" + workerFirstName);
              // mod #11513 患者名が指定文字数ぶん出ない 高 end
              workerLastName = "";
              workerFirstName = "";
            }
          }
        }
        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
      }
      // add #10210帳票における患者情報の取得元について sunsy start
      // 風袋
      else if ("tare_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        int current = 0;
        int sumWeight = 0;
        strFromDate = strFromDate.replace("/", "").replace("-", "");

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        LocalDate date = LocalDate.parse(strFromDate, formatter);
        int dow = date.getDayOfWeek().getValue();

        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        for (int d = 0; d < reportInfoDetailInfoWord.size(); d++){
          for (String key : reportInfoDetailInfoWord.get(d).keySet()){
            if (key.equals(String.valueOf(dow))){
              Map<String, Object> currentMap = reportInfoDetailInfoWord.get(d);
              for (Map.Entry<String, Object> entry : currentMap.entrySet()) {
                current++;
                if (current == dow){
                  Map value = (Map)entry.getValue();

                  for (Object key1 : value.keySet()) {
                    if(String.valueOf(key1).contains("weight")){
                      int weight = (int)value.get(key1);
                      sumWeight += weight;
                    }
                  }
                  value.put("weight_sum",sumWeight);
                  // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
                  value.put("pat_id", reportInfo.get(0).get("pat_id"));
                  // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
                  reportInfoDetailInfoWordMiddle.add(value);
                }
              }
            }
          }
        }
        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
      }
      // add #10210帳票における患者情報の取得元について sunsy end
      // add #10210帳票における患者情報の取得元について sunsy start
      // 除水補正
      else if ("off_water_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        int current = 0;
        int sumWeight = 0;
        strFromDate = strFromDate.replace("/", "").replace("-", "");

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        LocalDate date = LocalDate.parse(strFromDate, formatter);
        int dow = date.getDayOfWeek().getValue();

        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        for (int d = 0; d < reportInfoDetailInfoWord.size(); d++){
          for (String key : reportInfoDetailInfoWord.get(d).keySet()){
            if (key.equals(String.valueOf(dow))){
              Map<String, Object> currentMap = reportInfoDetailInfoWord.get(d);
              for (Map.Entry<String, Object> entry : currentMap.entrySet()) {
                current++;
                if (current == dow){
                  Map value = (Map)entry.getValue();

                  for (Object key1 : value.keySet()) {
                    if(String.valueOf(key1).contains("weight")){
                      int weight = (int)value.get(key1);
                      sumWeight += weight;
                    }
                  }
                  value.put("weight_sum",sumWeight);
                  // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
                  value.put("pat_id", reportInfo.get(0).get("pat_id"));
                  // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
                  reportInfoDetailInfoWordMiddle.add(value);
                }
              }
            }
          }
        }
        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
      }
      // add #10210帳票における患者情報の取得元について sunsy end
      // add #10210帳票における患者情報の取得元について sunsy start
      // CTR・DW履歴(昇順)
      else if ("physical_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        // ➀exam_dateでソート
        reportInfoDetailInfoWord.sort(
          Comparator.comparing(
            info -> (String) info.get("exam_date"),
            Comparator.nullsLast(Comparator.naturalOrder())
          )
        );
        List<Map<String, Object>> doWord = new LinkedList<>();
        List<Map<String, Object>> doWordMiddle;
        String doDispOrderValue = "";
        for (int p = 0; p < reportInfoDetailInfoWord.size(); p++){
          String doPWord = String.valueOf(reportInfoDetailInfoWord.get(p).get("exam_date"));

          String examDate = String.valueOf(reportInfoDetailInfoWord.get(p).get("exam_date"));
          if (! "".equals(examDate)){
            SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd");
            if ("".equals(examDate)){
              examDate = new SimpleDateFormat("yyyy-MM-dd").format(simpleDateFormat.parse(examDate));
            }
          }
          reportInfoDetailInfoWord.get(p).replace("exam_date", examDate);

          // add #10645 mongoDBのSQLでup_dateの比較が@fromDateと@toDateと混在している sunsy start
          if (reportInfoDetailInfoWord.get(p).get("indicator_start_date") != null) {
          // add #10645 mongoDBのSQLでup_dateの比較が@fromDateと@toDateと混在している sunsy end
            String indicatorStartDate = String.valueOf(reportInfoDetailInfoWord.get(p).get("indicator_start_date"));
            if (! "".equals(indicatorStartDate)){
              SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMdd");
              if ("".equals(indicatorStartDate)){
                indicatorStartDate = new SimpleDateFormat("yyyy-MM-dd").format(simpleDateFormat.parse(indicatorStartDate));
              }
            }
            reportInfoDetailInfoWord.get(p).replace("indicator_start_date", indicatorStartDate);
          // add #10645 mongoDBのSQLでup_dateの比較が@fromDateと@toDateと混在している sunsy start
          }
          // add #10645 mongoDBのSQLでup_dateの比較が@fromDateと@toDateと混在している sunsy end

          if (doDispOrderValue.equals(doPWord)){
            continue;
          }
          doWordMiddle = new LinkedList<>();
          for (int q = 0; q < reportInfoDetailInfoWord.size(); q++){
            String doQWord = String.valueOf(reportInfoDetailInfoWord.get(q).get("exam_date"));
            if (doPWord.equals(doQWord)){
              doWordMiddle.add(reportInfoDetailInfoWord.get(q));
            }
          }
          doDispOrderValue = doPWord;
          // ②ctl_noでソート
          doWordMiddle = doWordMiddle.stream().sorted(Comparator.comparingDouble(e -> (Integer) (e.get("ctl_no")))).collect(Collectors.toList());
          for (int u = 0; u < doWordMiddle.size(); u++){
            doWord.add(doWordMiddle.get(u));
          }
        }
        if ("asc".equals(doOrder)) {
          reportInfoDetailInfoWord = doWord;
        }
        if ("desc".equals(doOrder)) {
          doWordMiddle = new LinkedList<>();
          for (int i = doWord.size() - 1; i >= 0; i--) {
            doWordMiddle.add(doWord.get(i));
          }
          reportInfoDetailInfoWord = doWordMiddle;
        }
      }
      // add #10210帳票における患者情報の取得元について sunsy end

      // add #10210帳票における患者情報の取得元について sunsy start
      // 患者フリーコメント
      else if ("pat_memo_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        Map<String, Object> newMap = new HashMap<>();
        // del #11695 検査結果帳票で患者メモが出ない sunsy start
//        int entryCount = 1;
        // del #11695 検査結果帳票で患者メモが出ない sunsy end
        for (int d = 0; d < reportInfoDetailInfoWord.size(); d++){
          Map<String, Object> currentMap = reportInfoDetailInfoWord.get(d);
          // del #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　start
          // add 10210 帳票における患者情報の取得元について sunsy start
//          MstPatMemo mstPatMemo = mstPatMemoDao.selectByFacilityCdAndPatMemoNo(facilityCd, (short) (d + 1));
          // add 10210 帳票における患者情報の取得元について sunsy end
          // del #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　end
          // mod #11695 検査結果帳票で患者メモが出ない sunsy start
          int entryCount = 0;
//          for (Map.Entry<String, Object> entry : currentMap.entrySet()) {
//            String key = entry.getKey();
//            Object value = entry.getValue();
            // del #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　start
            // add 10210 帳票における患者情報の取得元について sunsy start
//            if ("1".equals(mstPatMemo.getIsDisp()) && "0".equals(mstPatMemo.getIsDel())) {
              // add 10210 帳票における患者情報の取得元について sunsy end
            // del #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　end
              Object ctlNoObj = currentMap.get("ctl_no");
              if (ctlNoObj != null && !String.valueOf(ctlNoObj).isEmpty()) {
                entryCount = (int) currentMap.get("ctl_no");
              }
              if (entryCount < 10) {
                newMap.put("memo0" + entryCount + "_" + "title", currentMap.get("title"));
                newMap.put("memo0" + entryCount + "_" + "content", currentMap.get("content"));
              }else {
                newMap.put("memo" + entryCount + "_" + "title", currentMap.get("title"));
                newMap.put("memo" + entryCount + "_" + "content", currentMap.get("content"));
              }
//              if (key.equals("title")){
//                if(entryCount < 10) {
//                  newMap.put("memo0" + entryCount + "_" + key, value);
//                }else {
//                  newMap.put("memo" + entryCount + "_" + key, value);
//                }
//              }
//              if (key.equals("content")){
//                if(entryCount < 10) {
//                  newMap.put("memo0" + entryCount + "_" + key, value);
//                }else {
//                  newMap.put("memo" + entryCount + "_" + key, value);
//                }
//              }
            // add 10210 帳票における患者情報の取得元について sunsy start
            // del #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　start
            //}
            // del #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　end
            // add 10210 帳票における患者情報の取得元について sunsy end
//          }
//          entryCount++;
          // del #11695 検査結果帳票で患者メモが出ない sunsy end
          // del #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
//          reportInfoDetailInfoWordMiddle.add(newMap);
          // del #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
          // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
          if(!newMap.containsKey("pat_id")) {
            newMap.put("pat_id", reportInfo.get(0).get("pat_id"));
          }
          // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
        }
        // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
        reportInfoDetailInfoWordMiddle.add(newMap);
        // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
      }
      // add #10210帳票における患者情報の取得元について sunsy end

      // 既往歴-担当・スタッフ部分
      else if ("charge_staff_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> doIsMainOver = new LinkedList<>();
        Map<String, Object> doIsMain = new HashMap<>();
        int main0 = 0;
        int main1 = 0;
        // add #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
        // 穿刺者の人数を計算する
        int main2 = 0;
        // add #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
        for (int d = 0; d < reportInfoDetailInfoWord.size(); d++){
          for (String key : reportInfoDetailInfoWord.get(d).keySet()){
            // タイプを変換する
            if (reportInfoDetailInfoWord.get(d).get("staff_cd") != null) {
              reportInfoDetailInfoWord.get(d).put("staff_cd",
                  String.valueOf(reportInfoDetailInfoWord.get(d).get("staff_cd")));
            }
            if ("is_main".equals(key)){
              // 担当医ID、担当医
              if ("1".equals(reportInfoDetailInfoWord.get(d).get(key)) && main1 < 2){
                main1++;
                // mod #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
//                doIsMain.put("doctor" + main1 + "_cd", reportInfoDetailInfoWord.get(d).get("staff_cd"));
                doIsMain.put("doctor" + main1 + "_cd", reportInfoDetailInfoWord.get(d).get("staff_disp_cd"));
                // add #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
                // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
//                doIsMain.put("doctor" + main1 + "_name", reportInfoDetailInfoWord.get(d).get("staff_cd"));
                doIsMain.put("doctor" + main1 + "_name", reportInfoDetailInfoWord.get(d).get("staff_name"));
                // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
              }
            }
            if ("is_charge".equals(key)){
              // 担当スタッフ1ID、担当スタッフ1
              if ("1".equals(reportInfoDetailInfoWord.get(d).get(key)) && main0 < 2){
                main0++;
                // mod #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
//                doIsMain.put("staff" + main0 + "_cd", reportInfoDetailInfoWord.get(d).get("staff_cd"));
                doIsMain.put("staff" + main0 + "_cd", reportInfoDetailInfoWord.get(d).get("staff_disp_cd"));
                // mod #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
                // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
//                doIsMain.put("staff" + main0 + "_name", reportInfoDetailInfoWord.get(d).get("staff_cd"));
                doIsMain.put("staff" + main0 + "_name", reportInfoDetailInfoWord.get(d).get("staff_name"));
                // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
              }
            }
            // add #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
            if ("is_puncture".equals(key)){
              // 穿刺スタッフ1ID、穿刺スタッフ
              if ("1".equals(reportInfoDetailInfoWord.get(d).get(key)) && main2 < 2){
                main2++;
                doIsMain.put("puncture" + main2 + "_cd", reportInfoDetailInfoWord.get(d).get("staff_disp_cd"));
                doIsMain.put("puncture" + main2 + "_name", reportInfoDetailInfoWord.get(d).get("staff_name"));
              }
            }
            // add #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
            // mod #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
//            if (main0 == 2 && main1 == 2){
            if (main0 == 2 && main1 == 2 && main2 == 2) {
            // mod #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
              break;
            }
          }
        }
        // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
        if(doIsMain != null && doIsMain.size() > 0) doIsMain.put("pat_id", reportInfo.get(0).get("pat_id"));
        // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
        doIsMainOver.add(doIsMain);
        reportInfoDetailInfoWord = doIsMainOver;
      }
      // 感染症部分
      else if ("infect_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        // mod 10210 帳票における患者情報の取得元について sunsy start
//        List doCheckWordValues = new ArrayList();
        Map doCheckWordValues = new HashMap();
        // mod 10210 帳票における患者情報の取得元について sunsy end
        int doEqual = doCheckWordValue.indexOf("=");
        String doKey = doCheckWordValue.substring(0, doEqual);
        Pattern p = Pattern.compile("=");
        Matcher m = p.matcher(doCheckWordValue);
        while (m.find()) {
          int doS = doCheckWordValue.indexOf("=");
          String doSt = doCheckWordValue.substring(doS + 1, doS + 2);
          doCheckWordValue = doCheckWordValue.substring(doS + 1, doCheckWordValue.length());
          // mod 10210 帳票における患者情報の取得元について sunsy start
//          doCheckWordValues.add(doSt);
          doCheckWordValues.put(doSt,doSt);
          // mod 10210 帳票における患者情報の取得元について sunsy end
        }
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        // del 10210 帳票における患者情報の取得元について sunsy start
//        for (int i = 0; i < doCheckWordValues.size(); i++){
//          String infoWord = doCheckWordValues.get(i).toString();
        // del 10210 帳票における患者情報の取得元について sunsy end

          for (int s = 0; s < reportInfoDetailInfoWord.size(); s++){
            // mod 10210 帳票における患者情報の取得元について sunsy start
//            if (infoWord.equals(reportInfoDetailInfoWord.get(s).get(doKey))){
            if (doCheckWordValues.containsKey(reportInfoDetailInfoWord.get(s).get(doKey))){
            // mod 10210 帳票における患者情報の取得元について sunsy end
              int code = 0;
              String keyOfInfectionCd = "";
              if (reportInfoDetailInfoWord.get(s).get("infection_cd") != null){
                code = String.valueOf(reportInfoDetailInfoWord.get(s).get("infection_cd")).indexOf(".");
                keyOfInfectionCd = String.valueOf(reportInfoDetailInfoWord.get(s).get("infection_cd"));
                if (code >= 0){
                  keyOfInfectionCd = String.valueOf(reportInfoDetailInfoWord.get(s).get("infection_cd")).substring(0, code);
                }
              }

              // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
              if (reportInfoDetailInfoWord.get(s).get("infection_name") != null) {
                reportInfoDetailInfoWord.get(s).put("infection_name", reportInfoDetailInfoWord.get(s).get("infection_name"));
              } else {
                if (!"".equals(keyOfInfectionCd)) {
                  MstInfection infection = mstInfectionDao.selectByCd(Integer.parseInt(keyOfInfectionCd));
                  if (infection != null) {
                    reportInfoDetailInfoWord.get(s).put("infection_name", infection.getInfectionName());
                  } else {
                    reportInfoDetailInfoWord.get(s).put("infection_name", "");
                  }
                } else {
                  reportInfoDetailInfoWord.get(s).put("infection_name", "");
                }
              }
//              if (!"".equals(keyOfInfectionCd)) {
//                MstInfection infection = mstInfectionDao.selectByCd(Integer.parseInt(keyOfInfectionCd));
//                if (infection != null) {
//                  reportInfoDetailInfoWord.get(s).put("infection_name", infection.getInfectionName());
//                } else {
//                  reportInfoDetailInfoWord.get(s).put("infection_name", "");
//                }
//              } else {
//                reportInfoDetailInfoWord.get(s).put("infection_name", "");
//              }
              // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
              reportInfoDetailInfoWordMiddle.add(reportInfoDetailInfoWord.get(s));
            }
          }
        // del 10210 帳票における患者情報の取得元について sunsy start
//        }
        // del 10210 帳票における患者情報の取得元について sunsy end

        // modify 10210 by kangjie 20240606 start 「表示順設定」の順で出力されなければならない。
        List<Map<String, Object>> sortDataByMasterSetting = sortDataByMasterSetting(
          facilityCd,
          "mst_infection",
          "infection_cd",
          reportInfoDetailInfoWordMiddle);
        if (CollectionUtils.isEmpty(sortDataByMasterSetting)){
          reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
        } else {
          reportInfoDetailInfoWord = sortDataByMasterSetting;
        }
        // reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
        // modify 10210 by kangjie 20240606 end
      }
      // 既往歴-透析困難(主のみ)
      else if ("dial_diff_com_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        int index = 0;
        for (int u = 0; u < reportInfoDetailInfoWord.size(); u++){
          if("1".equals(reportInfoDetailInfoWord.get(u).get("is_main"))) {
            Map<String, Object> detailInfoMiddle = new HashMap<>();
            reportInfoDetailInfoWordMiddle.add(detailInfoMiddle);
            for (String key : reportInfoDetailInfoWord.get(u).keySet()){
              // mod #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
//              if ("dial_diff_cd".equals(key)) {
              if ("dial_diff_name".equals(key)) {
              // mod #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
                // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
//                reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key, reportInfoDetailInfoWord.get(u).get(key));
//                reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key + "1", reportInfoDetailInfoWord.get(u).get(key));
//                reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key + "2", reportInfoDetailInfoWord.get(u).get(key));
                reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key, reportInfoDetailInfoWord.get(u).get("dial_diff_name"));
                // del #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
//                reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key + "1", reportInfoDetailInfoWord.get(u).get("dial_diff_name"));
//                reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key + "2", reportInfoDetailInfoWord.get(u).get("dial_diff_name"));
                // del #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
                // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
                // add #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
              } else if ("in_hospital_cd_1".equals(key)) {
                reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key, reportInfoDetailInfoWord.get(u).get("in_hospital_cd_1"));
              } else if ("in_hospital_cd_2".equals(key)) {
                reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key, reportInfoDetailInfoWord.get(u).get("in_hospital_cd_2"));
                // add #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
              } else if ("is_dial_diff".equals(key)) {
                reportInfoDetailInfoWordMiddle.get(index).put("is_pat_dial_diff", reportInfoDetailInfoWord.get(u).get(key));
              } else {
                reportInfoDetailInfoWordMiddle.get(index).put(key, reportInfoDetailInfoWord.get(u).get(key));
              }
              // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
              reportInfoDetailInfoWordMiddle.get(index).put("pat_id", reportInfo.get(0).get("pat_id"));
              // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
            }
            // del #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
//            index++;
            // del #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
          }
        }
        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
      }
      // add #10210帳票における患者情報の取得元について sunsy start
      // 透析困難(すべて)
      else if ("dial_diff_com_info_all".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        int index = 0;
        for (int u = 0; u < reportInfoDetailInfoWord.size(); u++){
          if ("1".equals(reportInfoDetailInfoWord.get(u).get("is_dial_diff"))) {
            Map<String, Object> detailInfoMiddle = new HashMap<>();
            reportInfoDetailInfoWordMiddle.add(detailInfoMiddle);
            for (String key : reportInfoDetailInfoWord.get(u).keySet()){
              // mod #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
              //            if ("dial_diff_cd".equals(key)) {
              //              reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key, reportInfoDetailInfoWord.get(u).get("dial_diff_name"));
              //              reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key + "1", reportInfoDetailInfoWord.get(u).get("dial_diff_cd"));
              //              reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key + "2", reportInfoDetailInfoWord.get(u).get("dial_diff_cd"));
              //            } else if ("is_dial_diff".equals(key)) {
              //              reportInfoDetailInfoWordMiddle.get(index).put("is_pat_dial_diff", reportInfoDetailInfoWord.get(u).get(key));
              if ("dial_diff_name".equals(key)) {
                reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key, reportInfoDetailInfoWord.get(u).get("dial_diff_name"));
              } else if ("in_hospital_cd_1".equals(key)) {
                reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key, reportInfoDetailInfoWord.get(u).get("in_hospital_cd_1"));
              } else if ("in_hospital_cd_2".equals(key)) {
                reportInfoDetailInfoWordMiddle.get(index).put("pat_" + key, reportInfoDetailInfoWord.get(u).get("in_hospital_cd_2"));
                // mod #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
              } else {
                reportInfoDetailInfoWordMiddle.get(index).put(key, reportInfoDetailInfoWord.get(u).get(key));
              }
            }
            index++;
          }
        }
        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
      }
      // add #10210帳票における患者情報の取得元について sunsy end
      // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
      // レセプト
      else if ("dial_diff_com_info_receipt".equals(doDetailInfoWord)){
        StringBuilder sqlBuilder = new StringBuilder();
        sqlBuilder.append("[");
        for (int u = 0; u < reportInfoDetailInfoWord.size(); u++){
          if ("1".equals(reportInfoDetailInfoWord.get(u).get("is_dial_diff"))) {
            sqlBuilder.append("{");
            int fieCount = reportInfoDetailInfoWord.get(u).size();
            int i = 0;
            for (String key : reportInfoDetailInfoWord.get(u).keySet()){
              if ("dial_diff_name".equals(key) || "in_hospital_cd_1".equals(key) || "in_hospital_cd_2".equals(key)) {
                sqlBuilder.append('"').append("pat_").append(key).append('"').append(":").append('"').append(reportInfoDetailInfoWord.get(u).get(key)).append('"');
              } else {
                sqlBuilder.append('"').append(key).append('"').append(":").append('"').append(reportInfoDetailInfoWord.get(u).get(key)).append('"');
              }
              i++;
              if(i < fieCount) sqlBuilder.append(",");
            }
            sqlBuilder.append("},");
          }
        }
        if(sqlBuilder.length() > 1) sqlBuilder.deleteCharAt(sqlBuilder.length() - 1);
        sqlBuilder.append("]");
        reportInfo.get(0).put(doDetailInfoWord, String.valueOf(sqlBuilder));
      }
      // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end
      // add #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
      // インプラント
      else if ("implant_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        for (int u = 0; u < reportInfoDetailInfoWord.size(); u++){
          Map<String, Object> detailInfoMiddle = new HashMap<>();
          for (String key : reportInfoDetailInfoWord.get(u).keySet()){
            detailInfoMiddle.put(key,reportInfoDetailInfoWord.get(u).get(key));
          }
          reportInfoDetailInfoWordMiddle.add(detailInfoMiddle);
        }
        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
      }
      // add #10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
      // add #10210帳票における患者情報の取得元について sunsy start
      // 装置設定
      else if ("device_set_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        Map<String, Object> currentMap = new HashMap<>();
        for (int u = 0; u < reportInfoDetailInfoWord.size(); u++){
          if (reportInfoDetailInfoWord.get(u).containsKey("bp")) {
            Map<String, Object> bp = (Map<String, Object>)reportInfoDetailInfoWord.get(u).get("bp");
            Map<String, Object> bpDev = (Map<String, Object>)bp.get("dev");
            Map<String, Object> bpDevA = (Map<String, Object>)bpDev.get("A");
            for (Map.Entry<String, Object> entry : bpDevA.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              if (Integer.valueOf(key) < 10) {
                currentMap.put("bp_dev_a_000" + key, value);
              }else if (Integer.valueOf(key) < 100) {
                currentMap.put("bp_dev_a_00" + key, value);
              }else {
                currentMap.put("bp_dev_a_0" + key, value);
              }
            }
          }
          if (reportInfoDetailInfoWord.get(u).containsKey("bv")) {
            Map<String, Object> bv = (Map<String, Object>)reportInfoDetailInfoWord.get(u).get("bv");
            Map<String, Object> bvDev = (Map<String, Object>)bv.get("dev");
            Map<String, Object> bvDevA = (Map<String, Object>)bvDev.get("A");
            for (Map.Entry<String, Object> entry : bvDevA.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              if (Integer.valueOf(key) < 10) {
                currentMap.put("bv_dev_a_000" + key, value);
              }else if (Integer.valueOf(key) < 100) {
                currentMap.put("bv_dev_a_00" + key, value);
              }else {
                currentMap.put("bv_dev_a_0" + key, value);
              }
            }
          }
          if (reportInfoDetailInfoWord.get(u).containsKey("lap")) {
            Map<String, Object> lap = (Map<String, Object>)reportInfoDetailInfoWord.get(u).get("lap");
            Map<String, Object> lapDev = (Map<String, Object>)lap.get("dev");
            Map<String, Object> lapDevA = (Map<String, Object>)lapDev.get("A");
            for (Map.Entry<String, Object> entry : lapDevA.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              if (Integer.valueOf(key) < 10) {
                currentMap.put("lap_dev_a_000" + key, value);
              }else if (Integer.valueOf(key) < 100) {
                currentMap.put("lap_dev_a_00" + key, value);
              }else {
                currentMap.put("lap_dev_a_0" + key, value);
              }
            }
          }
          if (reportInfoDetailInfoWord.get(u).containsKey("ope")) {
            Map<String, Object> ope = (Map<String, Object>)reportInfoDetailInfoWord.get(u).get("ope");
            Map<String, Object> opeDev = (Map<String, Object>)ope.get("dev");
            if (opeDev.containsKey("A")){
              Map<String, Object> opeDevA = (Map<String, Object>)opeDev.get("A");
              for (Map.Entry<String, Object> entry : opeDevA.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                if (Integer.valueOf(key) < 10) {
                  currentMap.put("ope_dev_a_000" + key, value);
                }else if (Integer.valueOf(key) < 100) {
                  currentMap.put("ope_dev_a_00" + key, value);
                }else {
                  currentMap.put("ope_dev_a_0" + key, value);
                }
              }
            }
            if (opeDev.containsKey("B")){
              Map<String, Object> opeDevB = (Map<String, Object>)opeDev.get("B");
              for (Map.Entry<String, Object> entry : opeDevB.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                if (Integer.valueOf(key) < 10) {
                  currentMap.put("ope_dev_b_000" + key, value);
                }else if (Integer.valueOf(key) < 100) {
                  currentMap.put("ope_dev_b_00" + key, value);
                }else {
                  currentMap.put("ope_dev_b_0" + key, value);
                }
              }
            }
            if (opeDev.containsKey("C")){
              Map<String, Object> opeDevC = (Map<String, Object>)opeDev.get("C");
              for (Map.Entry<String, Object> entry : opeDevC.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                if (Integer.valueOf(key) < 10) {
                  currentMap.put("ope_dev_c_000" + key, value);
                }else if (Integer.valueOf(key) < 100) {
                  currentMap.put("ope_dev_c_00" + key, value);
                }else {
                  currentMap.put("ope_dev_c_0" + key, value);
                }
              }
            }
          }
          if (reportInfoDetailInfoWord.get(u).containsKey("pri")) {
            Map<String, Object> pri = (Map<String, Object>)reportInfoDetailInfoWord.get(u).get("pri");
            if (pri.containsKey("dev")) {
              Map<String, Object> priDev = (Map<String, Object>)pri.get("dev");
              Map<String, Object> priDevA = (Map<String, Object>)priDev.get("A");
              for (Map.Entry<String, Object> entry : priDevA.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                if (Integer.valueOf(key) < 10) {
                  currentMap.put("pri_dev_a_000" + key, value);
                }else if (Integer.valueOf(key) < 100) {
                  currentMap.put("pri_dev_a_00" + key, value);
                }else {
                  currentMap.put("pri_dev_a_0" + key, value);
                }
              }
            }
            if (pri.containsKey("pat")) {
              Map<String, Object> priPat = (Map<String, Object>)pri.get("pat");
              if (priPat.containsKey("A")) {
                Map<String, Object> priPatA = (Map<String, Object>)priPat.get("A");
                for (Map.Entry<String, Object> entry : priPatA.entrySet()) {
                  String key = entry.getKey();
                  Object value = entry.getValue();
                  if (Integer.valueOf(key) < 10) {
                    currentMap.put("pri_pat_a_000" + key, value);
                  }else if (Integer.valueOf(key) < 100) {
                    currentMap.put("pri_pat_a_00" + key, value);
                  }else {
                    currentMap.put("pri_pat_a_0" + key, value);
                  }
                }
              }
              if (priPat.containsKey("B")) {
                Map<String, Object> priPatB = (Map<String, Object>)priPat.get("B");
                for (Map.Entry<String, Object> entry : priPatB.entrySet()) {
                  String key = entry.getKey();
                  Object value = entry.getValue();
                  if (Integer.valueOf(key) < 10) {
                    currentMap.put("pri_pat_b_000" + key, value);
                  }else if (Integer.valueOf(key) < 100) {
                    currentMap.put("pri_pat_b_00" + key, value);
                  }else {
                    currentMap.put("pri_pat_b_0" + key, value);
                  }
                }
              }
            }
          }
          if (reportInfoDetailInfoWord.get(u).containsKey("war")) {
            Map<String, Object> war = (Map<String, Object>)reportInfoDetailInfoWord.get(u).get("war");
            Map<String, Object> warDev = (Map<String, Object>)war.get("dev");
            Map<String, Object> warDevA = (Map<String, Object>)warDev.get("A");
            for (Map.Entry<String, Object> entry : warDevA.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              if (Integer.valueOf(key) < 10) {
                currentMap.put("war_dev_a_000" + key, value);
              }else if (Integer.valueOf(key) < 100) {
                currentMap.put("war_dev_a_00" + key, value);
              }else {
                currentMap.put("war_dev_a_0" + key, value);
              }
            }
          }
          if (reportInfoDetailInfoWord.get(u).containsKey("cpro")) {
            Map<String, Object> cpro = (Map<String, Object>)reportInfoDetailInfoWord.get(u).get("cpro");
            Map<String, Object> cproDev = (Map<String, Object>)cpro.get("dev");
            Map<String, Object> cproDevA = (Map<String, Object>)cproDev.get("A");
            for (Map.Entry<String, Object> entry : cproDevA.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              if (Integer.valueOf(key) < 10) {
                currentMap.put("cpro_dev_a_000" + key, value);
              }else if (Integer.valueOf(key) < 100) {
                currentMap.put("cpro_dev_a_00" + key, value);
              }else {
                currentMap.put("cpro_dev_a_0" + key, value);
              }
            }
          }
          if (reportInfoDetailInfoWord.get(u).containsKey("dfas")) {
            Map<String, Object> dfas = (Map<String, Object>)reportInfoDetailInfoWord.get(u).get("dfas");
            if (dfas.containsKey("dev")) {
              Map<String, Object> dfasDev = (Map<String, Object>)dfas.get("dev");
              if (dfasDev.containsKey("A")) {
                Map<String, Object> dfasDevA = (Map<String, Object>)dfasDev.get("A");
                for (Map.Entry<String, Object> entry : dfasDevA.entrySet()) {
                  String key = entry.getKey();
                  Object value = entry.getValue();
                  if (Integer.valueOf(key) < 10) {
                    currentMap.put("dfas_dev_a_000" + key, value);
                  }else if (Integer.valueOf(key) < 100) {
                    currentMap.put("dfas_dev_a_00" + key, value);
                  }else {
                    currentMap.put("dfas_dev_a_0" + key, value);
                  }
                }
              }
              if (dfasDev.containsKey("B")) {
                Map<String, Object> dfasDevB = (Map<String, Object>)dfasDev.get("B");
                for (Map.Entry<String, Object> entry : dfasDevB.entrySet()) {
                  String key = entry.getKey();
                  Object value = entry.getValue();
                  if (Integer.valueOf(key) < 10) {
                    currentMap.put("dfas_dev_b_000" + key, value);
                  }else if (Integer.valueOf(key) < 100) {
                    currentMap.put("dfas_dev_b_00" + key, value);
                  }else {
                    currentMap.put("dfas_dev_b_0" + key, value);
                  }
                }
              }
            }
            if (dfas.containsKey("pat")) {
              Map<String, Object> dfasPat = (Map<String, Object>)dfas.get("pat");
              Map<String, Object> dfasPatB = (Map<String, Object>)dfasPat.get("B");
              for (Map.Entry<String, Object> entry : dfasPatB.entrySet()) {
                String key = entry.getKey();
                Object value = entry.getValue();
                if (Integer.valueOf(key) < 10) {
                  currentMap.put("dfas_pat_b_000" + key, value);
                }else if (Integer.valueOf(key) < 100) {
                  currentMap.put("dfas_pat_b_00" + key, value);
                }else {
                  currentMap.put("dfas_pat_b_0" + key, value);
                }
              }
            }
          }
          if (reportInfoDetailInfoWord.get(u).containsKey("ecum")) {
            Map<String, Object> ecum = (Map<String, Object>)reportInfoDetailInfoWord.get(u).get("ecum");
            Map<String, Object> ecumDev = (Map<String, Object>)ecum.get("dev");
            Map<String, Object> ecumDevA = (Map<String, Object>)ecumDev.get("A");
            for (Map.Entry<String, Object> entry : ecumDevA.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              if (Integer.valueOf(key) < 10) {
                currentMap.put("ecum_dev_a_000" + key, value);
              }else if (Integer.valueOf(key) < 100) {
                currentMap.put("ecum_dev_a_00" + key, value);
              }else {
                currentMap.put("ecum_dev_a_0" + key, value);
              }
            }
          }
          // #add #12148 患者情報.装置設定の項目過不足対応 sunsy start
          if (reportInfoDetailInfoWord.get(u).containsKey("iap")) {
            Map<String, Object> iap = (Map<String, Object>)reportInfoDetailInfoWord.get(u).get("iap");
            if (iap.containsKey("dev")) {
              Map<String, Object> iapDev = (Map<String, Object>)iap.get("dev");
              if (iapDev.containsKey("A")) {
                Map<String, Object> iapDevA = (Map<String, Object>)iapDev.get("A");
                for (Map.Entry<String, Object> entry : iapDevA.entrySet()) {
                  String key = entry.getKey();
                  Object value = entry.getValue();
                  if (Integer.valueOf(key) < 10) {
                    currentMap.put("iap_dev_a_000" + key, value);
                  }else if (Integer.valueOf(key) < 100) {
                    currentMap.put("iap_dev_a_00" + key, value);
                  }else {
                    currentMap.put("iap_dev_a_0" + key, value);
                  }
                }
              }
            }
          }
          // #add #12148 患者情報.装置設定の項目過不足対応 sunsy end

          reportInfoDetailInfoWordMiddle.add(currentMap);
        }
        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
      }
      // add #10210帳票における患者情報の取得元について sunsy end
      // add #10210帳票における患者情報の取得元について sunsy start
      // ホスト監視
      else if ("host_notification_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        Map<String, Object> currentMap = new HashMap<>();
        for (int i = 0; i < reportInfoDetailInfoWord.size(); i++) {
          if(reportInfoDetailInfoWord.get(i).containsKey("ap")) {
            Map<String, Object> ap = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("ap");
            for (Map.Entry<String, Object> entry : ap.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_ap_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("vp")) {
            Map<String, Object> vp = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("vp");
            for (Map.Entry<String, Object> entry : vp.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_vp_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("ufr")) {
            Map<String, Object> ufr = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("ufr");
            for (Map.Entry<String, Object> entry : ufr.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_ufr_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("bpmi")) {
            Map<String, Object> bpmi = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("bpmi");
            for (Map.Entry<String, Object> entry : bpmi.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_bpmi_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("ldqb")) {
            Map<String, Object> ldqb = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("ldqb");
            for (Map.Entry<String, Object> entry : ldqb.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_ldqb_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("pulse")) {
            Map<String, Object> pulse = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("pulse");
            for (Map.Entry<String, Object> entry : pulse.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_pulse_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("bp_ave")) {
            Map<String, Object> bpAve = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("bp_ave");
            for (Map.Entry<String, Object> entry : bpAve.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_bp_ave_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("bp_max")) {
            Map<String, Object> bpMax = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("bp_max");
            for (Map.Entry<String, Object> entry : bpMax.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_bp_max_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("bp_min")) {
            Map<String, Object> bpMin = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("bp_min");
            for (Map.Entry<String, Object> entry : bpMin.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_bp_min_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("care_i")) {
            Map<String, Object> careI = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("care_i");
            for (Map.Entry<String, Object> entry : careI.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_care_i_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("na_conc")) {
            Map<String, Object> naConc = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("na_conc");
            for (Map.Entry<String, Object> entry : naConc.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_na_conc_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("d_bv_roc")) {
            Map<String, Object> dBvRoc = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("d_bv_roc");
            for (Map.Entry<String, Object> entry : dBvRoc.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_d_bv_roc_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("ip_speed")) {
            Map<String, Object> ipSpeed = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("ip_speed");
            for (Map.Entry<String, Object> entry : ipSpeed.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_ip_speed_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("blood_flow")) {
            Map<String, Object> bloodFlow = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("blood_flow");
            for (Map.Entry<String, Object> entry : bloodFlow.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_blood_flow_" + key, value);
            }
          }
          if(reportInfoDetailInfoWord.get(i).containsKey("dialys_temp")) {
            Map<String, Object> dialysTemp = (Map<String, Object>)reportInfoDetailInfoWord.get(i).get("dialys_temp");
            for (Map.Entry<String, Object> entry : dialysTemp.entrySet()) {
              String key = entry.getKey();
              Object value = entry.getValue();
              currentMap.put("pat_dialys_temp_" + key, value);
            }
          }
          reportInfoDetailInfoWordMiddle.add(currentMap);
        }
        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
      }
      // add #10210帳票における患者情報の取得元について sunsy end
      // 禁忌部分
      else if ("taboo_allergy_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        if(null != reportInfoDetailInfoWord ){
          for (int i = 0; i < reportInfoDetailInfoWord.size(); i++) {
            // mod #9987 コンバートによるアレルギーの調製薬剤の参照側修正 sunsy start
//            if("1".equals(reportInfoDetailInfoWord.get(i).get("taboo_allergy_class"))){
//              reportInfoDetailInfoWordMiddle.add(reportInfoDetailInfoWord.get(i));
//            }
            if ("禁忌・アレルギー".equals(sysDataSet.getDetailInfo().getDetails().get(0).getDataClass())) {
              reportInfoDetailInfoWordMiddle.add(reportInfoDetailInfoWord.get(i));
            }
            if ("禁忌".equals(sysDataSet.getDetailInfo().getDetails().get(0).getDataClass()) && "1".equals(reportInfoDetailInfoWord.get(i).get("taboo_allergy_class"))) {
              reportInfoDetailInfoWordMiddle.add(reportInfoDetailInfoWord.get(i));
            }
            if ("アレルギー".equals(sysDataSet.getDetailInfo().getDetails().get(0).getDataClass()) && "2".equals(reportInfoDetailInfoWord.get(i).get("taboo_allergy_class"))) {
              reportInfoDetailInfoWordMiddle.add(reportInfoDetailInfoWord.get(i));
            }
            // mod #9987 コンバートによるアレルギーの調製薬剤の参照側修正 sunsy end
          }
          reportInfoDetailInfoWord=reportInfoDetailInfoWordMiddle;
        }
      }
      // 原疾患、病歴(昇順)、病歴(降順)部分
      else if ("medical_hst_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordDoMiddle = reportInfoDetailInfoWord;
        for (int x = 0; x < reportInfoDetailInfoWord.size(); x++) {
          // 診断医CDタイプを変換する
          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
//          if (reportInfoDetailInfoWord.get(x).get("diagnostician_cd") != null) {
//            reportInfoDetailInfoWordDoMiddle.get(x).put("diagnostician_cd",
//                String.valueOf(reportInfoDetailInfoWord.get(x).get("diagnostician_cd")));
//          }
          if (reportInfoDetailInfoWord.get(x).get("diagnostician_name") != null) {
            reportInfoDetailInfoWordDoMiddle.get(x).put("diagnostician_name",
              String.valueOf(reportInfoDetailInfoWord.get(x).get("diagnostician_name")));
          }
          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
          // 透析導入原疾患、病名連携コードを追加する
          reportInfoDetailInfoWordDoMiddle.get(x).put("is_dialysis_main", reportInfoDetailInfoWord.get(x).get("is_diagnosed"));
          reportInfoDetailInfoWordDoMiddle.get(x).put("disease_cd1", reportInfoDetailInfoWord.get(x).get("disease_cd"));
          // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
          reportInfoDetailInfoWordDoMiddle.get(x).put("pat_id", reportInfo.get(0).get("pat_id"));
          // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
        }
        // 原疾患
        if ("".equals(doOrder)) {
          for (int y = 0; y < reportInfoDetailInfoWord.size(); y++) {
            if ((reportInfoDetailInfoWord.get(y).containsKey("is_primary_illness")
                && "1".equals(reportInfoDetailInfoWord.get(y).get("is_primary_illness")))|| "1".equals(reportInfoDetailInfoWord.get(y).get("is_dialysis_underlying_disease"))){

              // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
              if (reportInfoDetailInfoWord.get(y).get("disease_name") != null) {
                reportInfoDetailInfoWordDoMiddle.get(y).put("disease_name", reportInfoDetailInfoWord.get(y).get("disease_name"));
              } else {
                if ("1".equals(reportInfoDetailInfoWord.get(y).get("diagnostician_is_free")) || "1".equals(reportInfoDetailInfoWord.get(y).get("is_dialysis_underlying_disease"))){
                  reportInfoDetailInfoWordDoMiddle.get(y).put("disease_name", reportInfoDetailInfoWord.get(y).get("disease_cd"));
                } else {
                  List<MstDisease> disease = mstDiseaseDao.selectAllDisease();
                  if (disease.size() > 0) {
                    for (int u = 0; u < disease.size(); u++) {
                      if ("1".equals(disease.get(u).getIsDisp()) &&
                        disease.get(u).getFacilityCd().equals(reportInfoDetailInfoWord.get(y).get("facility_cd")) &&
                        String.valueOf(disease.get(u).getDiseaseCd()).equals(reportInfoDetailInfoWord.get(y).get("disease_cd"))) {
                      reportInfoDetailInfoWordDoMiddle.get(y).put("disease_name", disease.get(u).getDiseaseName());
                      }
                    }
                  } else {
                    reportInfoDetailInfoWordDoMiddle.get(y).put("disease_name", "");
                  }
                }
              }
//              if ("1".equals(reportInfoDetailInfoWord.get(y).get("diagnostician_is_free")) || "1".equals(reportInfoDetailInfoWord.get(y).get("is_dialysis_underlying_disease"))){
//                reportInfoDetailInfoWordDoMiddle.get(y).put("disease_name", reportInfoDetailInfoWord.get(y).get("disease_cd"));
//              } else {
//                List<MstDisease> disease = mstDiseaseDao.selectAllDisease();
//                if (disease.size() > 0) {
//                  for (int u = 0; u < disease.size(); u++) {
//                    if ("1".equals(disease.get(u).getIsDisp()) &&
//                        disease.get(u).getFacilityCd().equals(reportInfoDetailInfoWord.get(y).get("facility_cd")) &&
//                        disease.get(u).getDiseaseCd().toString().equals(reportInfoDetailInfoWord.get(y).get("disease_cd"))) {
////                      reportInfoDetailInfoWordDoMiddle.get(y).put("disease_name", disease.get(u).getDiseaseName());
//                    }
//                  }
//                } else {
//                  reportInfoDetailInfoWordDoMiddle.get(y).put("disease_name", "");
//                }
//              }
              // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
              // 診断施設を追加する
              if ("1".equals(reportInfoDetailInfoWord.get(y).get("diagnosis_facility_is_free"))){
                reportInfoDetailInfoWordDoMiddle.get(y).put("facility_name", reportInfoDetailInfoWord.get(y).get("diagnosis_facility_cd"));
              } else {

                // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
                if (reportInfoDetailInfoWord.get(y).get("facility_name") != null) {
                  reportInfoDetailInfoWordDoMiddle.get(y).put("facility_name", reportInfoDetailInfoWord.get(y).get("facility_name"));
                } else {
                  if (reportInfoDetailInfoWord.get(y).get("facility_cd") != null) {
                    MstFacility facility = mstFacilityDao.selectByCd(String.valueOf(reportInfoDetailInfoWord.get(y).get("facility_cd")));
                    if (facility != null) {
                    reportInfoDetailInfoWordDoMiddle.get(y).put("facility_name", facility.getFacilityName());
                    } else {
                      reportInfoDetailInfoWordDoMiddle.get(y).put("facility_name", "");
                    }
                  } else {
                    reportInfoDetailInfoWordDoMiddle.get(y).put("facility_name", "");
                  }
                }
//                if (reportInfoDetailInfoWord.get(y).get("facility_cd") != null) {
//                  MstFacility facility = mstFacilityDao.selectByCd(reportInfoDetailInfoWord.get(y).get("facility_cd").toString());
//                  if (facility != null) {
//                    reportInfoDetailInfoWordDoMiddle.get(y).put("facility_name", facility.getFacilityName());
//                  } else {
//                    reportInfoDetailInfoWordDoMiddle.get(y).put("facility_name", "");
//                  }
//                } else {
//                  reportInfoDetailInfoWordDoMiddle.get(y).put("facility_name", "");
//                }
                // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
              }
              // 診療科を追加する
              if ("1".equals(reportInfoDetailInfoWord.get(y).get("course_is_free"))){
                reportInfoDetailInfoWordDoMiddle.get(y).put("course_name", reportInfoDetailInfoWord.get(y).get("course_cd"));
              } else {
                // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
                if (reportInfoDetailInfoWord.get(y).get("course_name") != null) {
                  reportInfoDetailInfoWordDoMiddle.get(y).put("course_name", reportInfoDetailInfoWord.get(y).get("course_name"));
                } else {
                  if (reportInfoDetailInfoWord.get(y).get("course_cd") != null) {
                    MstCourse course = mstCourseDao.selectByCd(Integer.parseInt(String.valueOf(reportInfoDetailInfoWord.get(y).get("course_cd"))));
                    if (course != null) {
                      if ("1".equals(course.getIsDisp()) && "0".equals(course.getIsDel())) {
                        reportInfoDetailInfoWordDoMiddle.get(y).put("course_name", course.getCourseName());
                      } else {
                        reportInfoDetailInfoWordDoMiddle.get(y).put("course_name", "");
                      }
                    } else {
                      reportInfoDetailInfoWordDoMiddle.get(y).put("course_name", "");
                    }
                  } else {
                    reportInfoDetailInfoWordDoMiddle.get(y).put("course_name", "");
                  }
                }
//                if (reportInfoDetailInfoWord.get(y).get("course_cd") != null) {
//                  MstCourse course = mstCourseDao.selectByCd(Integer.parseInt(reportInfoDetailInfoWord.get(y).get("course_cd").toString()));
//                  if (course != null) {
//                    if ("1".equals(course.getIsDisp()) && "0".equals(course.getIsDel())) {
//                      reportInfoDetailInfoWordDoMiddle.get(y).put("course_name", course.getCourseName());
//                    } else {
//                      reportInfoDetailInfoWordDoMiddle.get(y).put("course_name", "");
//                    }
//                  } else {
//                    reportInfoDetailInfoWordDoMiddle.get(y).put("course_name", "");
//                  }
//                } else {
//                  reportInfoDetailInfoWordDoMiddle.get(y).put("course_name", "");
//                }
                // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
              }
            } else {
              reportInfoDetailInfoWord.remove(y);
              y = y -1;
              continue;
            }
          }
        }
        // 病歴(昇順)、病歴(降順)
        else {
          boolean doContinueFalg;
          // 転帰更新日、発症日ToDate
          for (int d = 0; d < reportInfoDetailInfoWord.size(); d++){
            doContinueFalg = true;
            for (String key : reportInfoDetailInfoWord.get(d).keySet()){
              // 発症日
              if ("disease_date".equals(key)){
                String diseaseDate = "";
                String dateDiseaseDate = "";
                if (reportInfoDetailInfoWord.get(d).get("disease_date") != null){
                  diseaseDate = String.valueOf(reportInfoDetailInfoWord.get(d).get("disease_date"));
                }
                // 発症日が空の場合、初期値設定
                if ("".equals(diseaseDate)){
                  doContinueFalg = false;
                } else {
                  doContinueFalg = true;
                }
                if (doContinueFalg){
                  SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMdd");
                  if ("".equals(dateDiseaseDate)){
                    dateDiseaseDate = new SimpleDateFormat("yyyy-MM-dd").format(simpleDateFormat.parse(diseaseDate));
                  }
                }
                reportInfoDetailInfoWord.get(d).replace("disease_date", dateDiseaseDate);
              }
              // 転帰更新日
              else if ("out_come_date".equals(key)){
                String outComeDate = "";
                String dateOutComeDate = "";
                if (reportInfoDetailInfoWord.get(d).get("out_come_date") != null){
                  outComeDate = String.valueOf(reportInfoDetailInfoWord.get(d).get("out_come_date"));
                }
                // 転帰更新日が空の場合、初期値設定
                if ("".equals(outComeDate)){
                  doContinueFalg = false;
                } else {
                  doContinueFalg = true;
                }
                if (doContinueFalg){
                  SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyyMMdd");
                  if ("".equals(dateOutComeDate)){
                    dateOutComeDate = new SimpleDateFormat("yyyy-MM-dd").format(simpleDateFormat.parse(outComeDate));
                  }
                }
                reportInfoDetailInfoWord.get(d).replace("out_come_date", dateOutComeDate);
              }
            }
          }
          // mod #11465 【たくしん会】既往歴に発症日nullのデータがあると帳票出力時にエラー sunsy start
//          // ①disp_orderでソート
//          reportInfoDetailInfoWord = reportInfoDetailInfoWord.stream().sorted(Comparator.comparingDouble(e -> (Integer) (e.get("disp_order")))).collect(Collectors.toList());
//          List<Map<String, Object>> doWord = new LinkedList<>();
//          List<Map<String, Object>> doWordMiddle;
//          String doDispOrderValue = "";
//          for (int p = 0; p < reportInfoDetailInfoWord.size(); p++){
//            String doPWord = reportInfoDetailInfoWord.get(p).get("disp_order").toString();
//            if (doDispOrderValue.equals(doPWord)){
//              continue;
//            }
//            doWordMiddle = new LinkedList<>();
//            for (int q = 0; q < reportInfoDetailInfoWord.size(); q++){
//              String doQWord = reportInfoDetailInfoWord.get(q).get("disp_order").toString();
//              if (doPWord.equals(doQWord)){
//                doWordMiddle.add(reportInfoDetailInfoWord.get(q));
//              }
//            }
//            doDispOrderValue = doPWord;
//            // ②ctl_noでソート
//            doWordMiddle = doWordMiddle.stream().sorted(Comparator.comparingDouble(e -> (Integer) (e.get("ctl_no")))).collect(Collectors.toList());
//            for (int u = 0; u < doWordMiddle.size(); u++){
//              doWord.add(doWordMiddle.get(u));
//            }
//          }
          // 昇順
          if ("asc".equals(doOrder)) {
        	// 発症日、診断日でソート
            // mod #11465 【たくしん会】既往歴に発症日nullのデータがあると帳票出力時にエラー
//            doWord = doWord.stream().sorted(Comparator.comparing(e -> (String) (e.get("disease_date")))).collect(Collectors.toList());
//            doWord = doWord.stream().sorted(Comparator.comparing(e -> (String) e.get("disease_date"), Comparator.nullsLast(String::compareTo))).collect(Collectors.toList());
            // sort_year、sort_month、sort_dayのkey追加
            reportInfoDetailInfoWord.forEach(SysDataSetServiceImpl::populateSortFields);
            reportInfoDetailInfoWord = reportInfoDetailInfoWord.stream()
              .sorted(Comparator
                .comparing((Map<String, Object> e) -> Integer.parseInt(String.valueOf(e.get("sort_year")))) // 年昇順
                .thenComparing(e -> Integer.parseInt(String.valueOf(e.get("sort_month")))) // 月昇順
                .thenComparing(e -> Integer.parseInt(String.valueOf(e.get("sort_day"))))) // 日昇順
                  .collect(Collectors.toList());
            // mod #11465 【たくしん会】既往歴に発症日nullのデータがあると帳票出力時にエラー

//        	reportInfoDetailInfoWordDoMiddle = doWord;
        	reportInfoDetailInfoWordDoMiddle = reportInfoDetailInfoWord;
//            reportInfoDetailInfoWord = doWord;
            // mod #11465 【たくしん会】既往歴に発症日nullのデータがあると帳票出力時にエラー sunsy end
          }
          // 降順
          else if ("desc".equals(doOrder)) {
            // mod #11465 【たくしん会】既往歴に発症日nullのデータがあると帳票出力時にエラー
//            doWordMiddle = new LinkedList<>();
//            doWord = doWord.stream().sorted(Comparator.comparing(e -> (String) (e.get("disease_date")))).collect(Collectors.toList());
//            for (int u = doWord.size() - 1; u >= 0; u--){
//              doWordMiddle.add(doWord.get(u));
//            }
//            doWord = doWord.stream()
//              .sorted(Comparator
//                .comparing((Map<String, Object> e) -> e.get("disease_date") == null) // disease_dateがnullである情報をリストの最後に並ぶ
//                .thenComparing(e -> (String) e.get("disease_date"), Comparator.reverseOrder()) // disease_dateがnullではない情報に対して降順で並ぶ
            reportInfoDetailInfoWord.forEach(SysDataSetServiceImpl::populateSortFields);
            reportInfoDetailInfoWord = reportInfoDetailInfoWord.stream()
                    .sorted(Comparator
                                    .comparing((Map<String, Object> e) -> Integer.parseInt(String.valueOf(e.get("sort_year"))), Comparator.reverseOrder()) // 年降順
                                    .thenComparing((Map<String, Object> e) -> Integer.parseInt(String.valueOf(e.get("sort_month"))), Comparator.reverseOrder()) // 月降順
                                    .thenComparing((Map<String, Object> e) -> Integer.parseInt(String.valueOf(e.get("sort_day"))), Comparator.reverseOrder()) // 日降順
              ).collect(Collectors.toList());
//            reportInfoDetailInfoWordDoMiddle = doWordMiddle;
//            reportInfoDetailInfoWord = doWordMiddle;
//            reportInfoDetailInfoWordDoMiddle = doWord;
            reportInfoDetailInfoWordDoMiddle = reportInfoDetailInfoWord;
//            reportInfoDetailInfoWord = doWord;
            // mod #11465 【たくしん会】既往歴に発症日nullのデータがあると帳票出力時にエラー
            // mod #11465 【たくしん会】既往歴に発症日nullのデータがあると帳票出力時にエラー sunsy end
          }
          // 病名を追加する
          for (int y = 0; y < reportInfoDetailInfoWordDoMiddle.size(); y++) {
            String diseaseCd = "";
            String diagnosisFacilityCd = "";
            String courseCd = "";
            if (reportInfoDetailInfoWordDoMiddle.get(y).get("disease_cd") != null){
              diseaseCd = String.valueOf(reportInfoDetailInfoWordDoMiddle.get(y).get("disease_cd"));
            }
            // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
//            if (reportInfoDetailInfoWordDoMiddle.get(y).get("diagnosis_facility_cd") != null){
//              diagnosisFacilityCd = reportInfoDetailInfoWordDoMiddle.get(y).get("diagnosis_facility_cd").toString();
//            }
            if (reportInfoDetailInfoWordDoMiddle.get(y).get("diagnosis_facility_name") != null){
              diagnosisFacilityCd = String.valueOf(reportInfoDetailInfoWordDoMiddle.get(y).get("diagnosis_facility_name"));
            }
            // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
            if (reportInfoDetailInfoWordDoMiddle.get(y).get("course_cd") != null){
              courseCd = String.valueOf(reportInfoDetailInfoWordDoMiddle.get(y).get("course_cd"));
            }

            // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
            if (reportInfoDetailInfoWordDoMiddle.get(y).get("disease_name") != null) {
              reportInfoDetailInfoWord.get(y).put("disease_name", reportInfoDetailInfoWordDoMiddle.get(y).get("disease_name"));
            } else {
              if ("1".equals(reportInfoDetailInfoWordDoMiddle.get(y).get("diagnostician_is_free"))){
                reportInfoDetailInfoWord.get(y).put("disease_name", diseaseCd);
              } else {
                List<MstDisease> disease = mstDiseaseDao.selectAllDisease();
                if (disease.size() > 0) {
                  for (int u = 0; u < disease.size(); u++) {
                    if ("1".equals(disease.get(u).getIsDisp()) &&
                      String.valueOf(disease.get(u).getDiseaseCd()).equals(diseaseCd)) {
                    reportInfoDetailInfoWord.get(y).put("disease_name", disease.get(u).getDiseaseName());
                    }
                  }
                  if (!reportInfoDetailInfoWord.get(y).containsKey("disease_name")){
                    reportInfoDetailInfoWord.get(y).put("disease_name", "");
                  }
                } else {
                  reportInfoDetailInfoWord.get(y).put("disease_name", "");
                }
              }
            }
//            if ("1".equals(reportInfoDetailInfoWordDoMiddle.get(y).get("diagnostician_is_free"))){
//              reportInfoDetailInfoWord.get(y).put("disease_name", diseaseCd);
//            } else {
//              List<MstDisease> disease = mstDiseaseDao.selectAllDisease();
//              if (disease.size() > 0) {
//                for (int u = 0; u < disease.size(); u++) {
//                  if ("1".equals(disease.get(u).getIsDisp()) &&
//                      disease.get(u).getDiseaseCd().toString().equals(diseaseCd)) {
//                    reportInfoDetailInfoWord.get(y).put("disease_name", disease.get(u).getDiseaseName());
//                  }
//                }
//                if (!reportInfoDetailInfoWord.get(y).containsKey("disease_name")){
//                  reportInfoDetailInfoWord.get(y).put("disease_name", "");
//                }
//              } else {
//                reportInfoDetailInfoWord.get(y).put("disease_name", "");
//              }
//            }
            // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
            // 診断施設を追加する
            if ("1".equals(reportInfoDetailInfoWordDoMiddle.get(y).get("diagnosis_facility_is_free"))){
              reportInfoDetailInfoWord.get(y).put("facility_name", diagnosisFacilityCd);
            } else {

              // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
              if (reportInfoDetailInfoWord.get(y).get("facility_name") != null) {
                reportInfoDetailInfoWordDoMiddle.get(y).put("facility_name", reportInfoDetailInfoWord.get(y).get("facility_name"));
              } else {
                if (reportInfoDetailInfoWordDoMiddle.get(y).get("facility_cd") != null) {
                  MstFacility facility = mstFacilityDao.selectByCd(String.valueOf(reportInfoDetailInfoWordDoMiddle.get(y).get("facility_cd")));
                  if (facility != null) {
                    reportInfoDetailInfoWord.get(y).put("facility_name", facility.getFacilityName());
                  } else {
                    reportInfoDetailInfoWord.get(y).put("facility_name", "");
                  }
                } else {
                  reportInfoDetailInfoWord.get(y).put("facility_name", "");
                }
              }
//              if (reportInfoDetailInfoWordDoMiddle.get(y).get("facility_cd") != null) {
//                MstFacility facility = mstFacilityDao.selectByCd(reportInfoDetailInfoWordDoMiddle.get(y).get("facility_cd").toString());
//                if (facility != null) {
//                  reportInfoDetailInfoWord.get(y).put("facility_name", facility.getFacilityName());
//                } else {
//                  reportInfoDetailInfoWord.get(y).put("facility_name", "");
//                }
//              } else {
//                reportInfoDetailInfoWord.get(y).put("facility_name", "");
//              }
              // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
            }
            // 診療科を追加する

            // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
            if (reportInfoDetailInfoWord.get(y).get("course_name") != null) {
              reportInfoDetailInfoWordDoMiddle.get(y).put("course_name", reportInfoDetailInfoWord.get(y).get("course_name"));
            } else {
              if ("1".equals(reportInfoDetailInfoWordDoMiddle.get(y).get("course_is_free"))){
                reportInfoDetailInfoWord.get(y).put("course_name", courseCd);
              } else {
                if (reportInfoDetailInfoWordDoMiddle.get(y).get("course_cd") != null) {
                  MstCourse course = mstCourseDao.selectByCd(Integer.parseInt(courseCd));
                  if (course != null) {
                    if ("1".equals(course.getIsDisp()) && "0".equals(course.getIsDel())) {
                    reportInfoDetailInfoWord.get(y).put("course_name", course.getCourseName());
                    } else {
                      reportInfoDetailInfoWord.get(y).put("course_name", "");
                    }
                  } else {
                    reportInfoDetailInfoWord.get(y).put("course_name", "");
                  }
                } else {
                  reportInfoDetailInfoWord.get(y).put("course_name", "");
                }
              }
            }
//            if ("1".equals(reportInfoDetailInfoWordDoMiddle.get(y).get("course_is_free"))){
//              reportInfoDetailInfoWord.get(y).put("course_name", courseCd);
//            } else {
//              if (reportInfoDetailInfoWordDoMiddle.get(y).get("course_cd") != null) {
//                MstCourse course = mstCourseDao.selectByCd(Integer.parseInt(courseCd));
//                if (course != null) {
//                  if ("1".equals(course.getIsDisp()) && "0".equals(course.getIsDel())) {
//                    reportInfoDetailInfoWord.get(y).put("course_name", course.getCourseName());
//                  } else {
//                    reportInfoDetailInfoWord.get(y).put("course_name", "");
//                  }
//                } else {
//                  reportInfoDetailInfoWord.get(y).put("course_name", "");
//                }
//              } else {
//                reportInfoDetailInfoWord.get(y).put("course_name", "");
//              }
//            }
              // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
            }
          }
        }
      // add 10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
      //加算管理料
      else if ("addition_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        // add #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 start
        JSONObject obj = new JSONObject(sql);
        JSONObject eq = obj.getJSONObject("eq");
        String patId = eq.getString("pat_id");
        List<AdditionInfoOrdMain> response = new ArrayList<>();
        if(dataKey.containsKey("addInfoLastDate")){
          String addInfoLastDate = String.valueOf(dataKey.get("addInfoLastDate")).replace("-", "").replace("/", "");
          response = ordMainDao.selectCalculationDateList(null, facilityCd, Long.valueOf(patId), addInfoLastDate);
        }else{
          response = ordMainDao.selectCalculationDateList(null, facilityCd, Long.valueOf(patId), strFromDate);
        }
        Map<Integer, String> result = response.stream()
          .collect(Collectors.toMap(
            item -> Integer.valueOf(String.valueOf(item.getCd())),
            AdditionInfoOrdMain::getLast_date
          ));
        // add #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 end
        for (int u = 0; u < reportInfoDetailInfoWord.size(); u++){
          Map<String, Object> detailInfoMiddle = new HashMap<>();
          // add #10210 帳票における患者情報の取得元について 20240613 sunsy start
          Object additionCd = reportInfoDetailInfoWord.get(u).get("cd");
          MstAddition mstAddition = mstAdditionDao.selectByAdditionCd(Long.valueOf(String.valueOf(additionCd)));
          if ("2".equals(String.valueOf(mstAddition.getAdditionKind())) && !"12".equals(String.valueOf(mstAddition.getAdditionClass()))) {
            reportInfoDetailInfoWord.get(u).put("kind", "1");
          }
          // add #10210 帳票における患者情報の取得元について 20240613 sunsy end
          // mod #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 start
//          for (String key : reportInfoDetailInfoWord.get(u).keySet()){
//            detailInfoMiddle.put(key,reportInfoDetailInfoWord.get(u).get(key));
//          }
//          reportInfoDetailInfoWordMiddle.add(detailInfoMiddle);
          if(result.containsKey(reportInfoDetailInfoWord.get(u).get("cd"))){
            reportInfoDetailInfoWord.get(u).put("last_date",result.get(reportInfoDetailInfoWord.get(u).get("cd")));
          }
          reportInfoDetailInfoWordMiddle.add( reportInfoDetailInfoWord.get(u));
          // mod #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 end
        }
        // modify 10210 by kangjie 20240606 start
        List<Map<String, Object>> sortDataByMasterSetting = sortDataByMasterSetting(
          facilityCd,
          "mst_addition",
          "cd",
          reportInfoDetailInfoWordMiddle);
        if (CollectionUtils.isEmpty(sortDataByMasterSetting)) {
          reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
        } else {
          reportInfoDetailInfoWord = sortDataByMasterSetting;
        }
//        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
        List<Map<String,Object>> enableList = reportInfoDetailInfoWord.stream()
          .filter(item->Objects.equals(String.valueOf(item.get("is_enable")),ADDITION_ON))
          .collect(Collectors.toList());

        List<Map<String,Object>> isEnableList = reportInfoDetailInfoWord.stream()
          .filter(item->Objects.equals(String.valueOf(item.get("is_enable")),ADDITION_OFF))
          .collect(Collectors.toList());
        List<Map<String,Object>> differentList = new ArrayList<>();
        differentList.addAll(enableList);
        differentList.addAll(isEnableList);
        reportInfoDetailInfoWord = differentList;
        // modify 10210 by kangjie 20240606 end

        // modify 10210 by kangjie 20240606 start

        // add 10210 帳票における患者情報の取得元について sunsy start
        // cd を基準に reportInfoDetailInfoWordMiddle リストを降順でソートする
//        Collections.sort(reportInfoDetailInfoWordMiddle, new Comparator<Map<String, Object>>() {
//          @Override
//          public int compare(Map<String, Object> o1, Map<String, Object> o2) {
//            // o1 と o2 の cd キーの値を取得
//            Object cd1 = o1.get("is_enable");
//            Object cd2 = o2.get("is_enable");
//
//            // cd の値が Comparable であることを確認してから比較
//            if (cd1 instanceof Comparable && cd2 instanceof Comparable) {
//              // Comparable として比較可能な場合は、降順で比較
//              return ((Comparable) cd2).compareTo((Comparable) cd1);
//            } else {
//              // cd の値が Comparable でない場合は、0 を返して順序を変更しない
//              return 0;
//            }
//          }
//        });
        // add 10210 帳票における患者情報の取得元について sunsy end
      }
      // add 10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
      // modify 10210 by kangjie 20240606 end
      // 基本情報部分部分
      else if ("pat_contact_info".equals(doDetailInfoWord)){
        // 氏名を追加する
        if ((reportInfo.get(0).containsKey("pat_last_name") && reportInfo.get(0).get("pat_last_name") == null) || !reportInfo.get(0).containsKey("pat_last_name")){
          reportInfo.get(0).put("pat_last_name", "");
        }
        if ((reportInfo.get(0).containsKey("pat_first_name") && reportInfo.get(0).get("pat_first_name") == null) || !reportInfo.get(0).containsKey("pat_first_name")){
          reportInfo.get(0).put("pat_first_name", "");
        }
        // mod #11513 患者名が指定文字数ぶん出ない 高 start
//        String patName = reportInfo.get(0).get("pat_last_name") + " " + reportInfo.get(0).get("pat_first_name");
        String patName = reportInfo.get(0).get("pat_last_name") + "" + reportInfo.get(0).get("pat_first_name");
        // mod #11513 患者名が指定文字数ぶん出ない 高 end
        reportInfo.get(0).put("pat_name", patName);

        // 氏名フリガナを追加する
        if ((reportInfo.get(0).containsKey("pat_last_name_kana") && reportInfo.get(0).get("pat_last_name_kana") == null) || !reportInfo.get(0).containsKey("pat_last_name_kana")){
          reportInfo.get(0).put("pat_last_name_kana", "");
        }
        if ((reportInfo.get(0).containsKey("pat_first_name_kana") && reportInfo.get(0).get("pat_first_name_kana") == null) || !reportInfo.get(0).containsKey("pat_first_name_kana")){
          reportInfo.get(0).put("pat_first_name_kana", "");
        }
        // mod #11513 患者名が指定文字数ぶん出ない 高 start
//        String patNameKana = reportInfo.get(0).get("pat_last_name_kana") + " " + reportInfo.get(0).get("pat_first_name_kana");
        String patNameKana = reportInfo.get(0).get("pat_last_name_kana") + "" + reportInfo.get(0).get("pat_first_name_kana");
        // mod #11513 患者名が指定文字数ぶん出ない 高 end
        reportInfo.get(0).put("pat_name_kana", patNameKana);

        // ローマ字を追加する
        if ((reportInfo.get(0).containsKey("pat_last_name_alpha") && reportInfo.get(0).get("pat_last_name_alpha") == null) || !reportInfo.get(0).containsKey("pat_last_name_alpha")){
          reportInfo.get(0).put("pat_last_name_alpha", "");
        }
        if ((reportInfo.get(0).containsKey("pat_first_name_alpha") && reportInfo.get(0).get("pat_first_name_alpha") == null) || !reportInfo.get(0).containsKey("pat_first_name_alpha")){
          reportInfo.get(0).put("pat_first_name_alpha", "");
        }
        // mod #11513 患者名が指定文字数ぶん出ない 高 start
//        String patNameAlpha = reportInfo.get(0).get("pat_last_name_alpha") + " " + reportInfo.get(0).get("pat_first_name_alpha");
        String patNameAlpha = reportInfo.get(0).get("pat_last_name_alpha") + "" + reportInfo.get(0).get("pat_first_name_alpha");
        // mod #11513 患者名が指定文字数ぶん出ない 高 end
        reportInfo.get(0).put("pat_name_alpha", patNameAlpha);

        // 年齢を追加する
        String patAge = "";
        if (reportInfo.get(0).get("pat_birthday") != null && !"".equals(reportInfo.get(0).get("pat_birthday"))){
          int age = Integer.parseInt(strFromDate.substring(0, 4)) -
              Integer.parseInt(String.valueOf(reportInfo.get(0).get("pat_birthday")).substring(0, 4));
          int day = Integer.parseInt(strFromDate.substring(4, 8)) -
              Integer.parseInt(String.valueOf(reportInfo.get(0).get("pat_birthday")).substring(4, 8));
          if (day < 0){
            patAge = String.valueOf(age - 1);
          } else {
            patAge = String.valueOf(age);
          }
        }
        if("".equals(patAge)){
          reportInfo.get(0).put("pat_age", "");
        } else {
          reportInfo.get(0).put("pat_age", patAge);
        }

        // 血液型
        int patBloodTypeAboRh = 0;
        if (reportInfo.get(0).containsKey("pat_blood_type_rh") && !"".equals(reportInfo.get(0).get("pat_blood_type_rh"))){
          patBloodTypeAboRh = Integer.parseInt(String.valueOf(reportInfo.get(0).get("pat_blood_type_rh")));
          reportInfo.get(0).replace("pat_blood_type_rh", Integer.parseInt(String.valueOf(reportInfo.get(0).get("pat_blood_type_rh"))));
        }
        if (reportInfo.get(0).containsKey("pat_blood_type_abo") && !"".equals(reportInfo.get(0).get("pat_blood_type_abo"))){
          patBloodTypeAboRh = patBloodTypeAboRh + Integer.parseInt(String.valueOf(reportInfo.get(0).get("pat_blood_type_abo"))) * 10;
          reportInfo.get(0).replace("pat_blood_type_abo", Integer.parseInt(String.valueOf(reportInfo.get(0).get("pat_blood_type_abo"))));
        }
        if (reportInfo.get(0).containsKey("pat_sex") && !"".equals(reportInfo.get(0).get("pat_sex"))){
          reportInfo.get(0).replace("pat_sex", Integer.parseInt(String.valueOf(reportInfo.get(0).get("pat_sex"))));
        }
        if (reportInfo.get(0).containsKey("in_out_class") && !"".equals(reportInfo.get(0).get("in_out_class"))){
          reportInfo.get(0).replace("in_out_class", Integer.parseInt(String.valueOf(reportInfo.get(0).get("in_out_class"))));
        }
        // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
//        if (reportInfo.get(0).containsKey("die_cd") && !"".equals(reportInfo.get(0).get("die_cd"))){
//          reportInfo.get(0).put("die_cd1", Integer.parseInt(reportInfo.get(0).get("die_cd").toString()));
//        }
        if (reportInfo.get(0).containsKey("die_name") && !"".equals(reportInfo.get(0).get("die_name"))){
          reportInfo.get(0).put("die_name", String.valueOf(reportInfo.get(0).get("die_name")));
        }
        // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
        // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
        if (reportInfo.get(0).containsKey("severity_name") && !"".equals(reportInfo.get(0).get("severity_name"))){
          reportInfo.get(0).put("severity_name", String.valueOf(reportInfo.get(0).get("severity_name")));
        }
        if (reportInfo.get(0).containsKey("transport_name") && !"".equals(reportInfo.get(0).get("transport_name"))){
          reportInfo.get(0).put("transport_name", String.valueOf(reportInfo.get(0).get("transport_name")));
        }
        // add #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
        reportInfo.get(0).put("pat_blood_type_abo_rh", patBloodTypeAboRh);

        reportInfo.get(0).remove(doDetailInfoWord);
        for (String key : reportInfoDetailInfoWord.get(0).keySet()){
          if ("zip_cd".equals(key)){
            reportInfo.get(0).put("pat_zip", reportInfoDetailInfoWord.get(0).get(key));
          } else {
            reportInfo.get(0).put("pat_" + key, reportInfoDetailInfoWord.get(0).get(key));
          }
        }
      }
      // add #10210 帳票における患者情報の取得元について sunsy start
      // 在院
      else if ("in_out_current_state".equals(doDetailInfoWord)){
        if (!reportInfo.get(0).containsKey("in_out_current_state")) {
          reportInfo.get(0).put("in_out_current_state", "10");
        }
      }
      // add #10210 帳票における患者情報の取得元について sunsy end
      // 既往歴部分
      else if ("medical_care_info".equals(doDetailInfoWord)){
        String dialysisVintage = "";
        for (int o = 0; o < reportInfoDetailInfoWord.size(); o++) {
          // 透析歴を追加する
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
//          if (reportInfoDetailInfoWord.get(o).get("dialysis_start_date") != null) {
          if (reportInfoDetailInfoWord.get(o).containsKey("dialysis_start_date") && !StringUtils.isEmpty(reportInfoDetailInfoWord.get(o).get("dialysis_start_date"))) {
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
            String fromDateYear = strFromDate.substring(0, 4);
            String fromDateMons = strFromDate.substring(4, 6);
            String dialysisStartDateOfYear = String.valueOf(reportInfoDetailInfoWord.get(o).get("dialysis_start_date")).substring(0, 4);
            String dialysisStartDateOfMons = String.valueOf(reportInfoDetailInfoWord.get(o).get("dialysis_start_date")).substring(4, 6);
            // mod 9484　因島帳票の表示不具合（帳票種別：紹介状）　吉 start
            // String ageYear = Integer.parseInt(fromDateYear) - Integer.parseInt(dialysisStartDateOfYear) + "年";
            String ageYear = "";
            // mod 9484　因島帳票の表示不具合（帳票種別：紹介状）　吉 end
            int vintage = 0;
            if (Integer.parseInt(fromDateMons) >= Integer.parseInt(dialysisStartDateOfMons)) {
              // add 9484　因島帳票の表示不具合（帳票種別：紹介状）　吉 start
              ageYear = Integer.parseInt(fromDateYear) - Integer.parseInt(dialysisStartDateOfYear) + "年";
              // add 9484　因島帳票の表示不具合（帳票種別：紹介状）　吉 end
              vintage = Integer.parseInt(fromDateMons) - Integer.parseInt(dialysisStartDateOfMons);
            } else {
              vintage = 12 - Integer.parseInt(dialysisStartDateOfMons) + Integer.parseInt(fromDateMons);
              // add 9484　因島帳票の表示不具合（帳票種別：紹介状）　吉 start
              ageYear = Integer.parseInt(fromDateYear) - Integer.parseInt(dialysisStartDateOfYear) -1 + "年";
              // add 9484　因島帳票の表示不具合（帳票種別：紹介状）　吉 end
            }
            dialysisVintage = ageYear + vintage + "ヶ月";
          }
          reportInfoDetailInfoWord.get(o).put("dialysis_vintage", dialysisVintage);
          int code = 0;
          // del #10210 帳票における患者情報の取得元について sunsy start
//          String facilityCd = "";
          // del #10210 帳票における患者情報の取得元について sunsy end
          // 透析導入施設を追加する
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
//          if (reportInfoDetailInfoWord.get(o).get("facility_cd") != null){
          String facilityCdinMedicalCareInfo = "";
          if (reportInfoDetailInfoWord.get(o).containsKey("facility_cd") && !StringUtils.isEmpty(reportInfoDetailInfoWord.get(o).get("facility_cd"))) {
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
            code = String.valueOf(reportInfoDetailInfoWord.get(o).get("facility_cd")).indexOf(".");
            // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
//            facilityCd = reportInfoDetailInfoWord.get(o).get("facility_cd").toString();
            facilityCdinMedicalCareInfo = String.valueOf(reportInfoDetailInfoWord.get(o).get("facility_cd"));
            // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
            if (code >= 0){
              // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
//              facilityCd = reportInfoDetailInfoWord.get(o).get("facility_cd").toString().substring(0, code);
              facilityCdinMedicalCareInfo = String.valueOf(reportInfoDetailInfoWord.get(o).get("facility_cd")).substring(0, code);
              // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
            }
          }

          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
//          if (reportInfoDetailInfoWord.get(o).get("facility_name") != null) {
//            reportInfo.get(0).put("facility_name", reportInfoDetailInfoWord.get(o).get("facility_name"));
//          } else {
//            if (!"".equals(facilityCd)){
//              MstFacility facility = mstFacilityDao.selectByCd(facilityCd);
//              if (facility != null) {
//                reportInfo.get(0).put("facility_name", facility.getFacilityName());
//              } else {
//                reportInfo.get(0).put("facility_name", facilityCd);
//              }
//            } else {
//              reportInfo.get(0).put("facility_name", "");
//            }
//          }
          String facilityName = "";
          if (reportInfoDetailInfoWord.get(o).containsKey("facility_name") && !StringUtils.isEmpty(reportInfoDetailInfoWord.get(o).get("facility_name"))) {
            facilityName = String.valueOf(reportInfoDetailInfoWord.get(o).get("facility_name"));
          } else {
            if (!"".equals(facilityCdinMedicalCareInfo)){
              MstFacility facility = mstFacilityDao.selectByCd(facilityCdinMedicalCareInfo);
              if (facility != null) {
                facilityName = facility.getFacilityName();
              } else {
                facilityName = facilityCdinMedicalCareInfo;
              }
            }
          }
          reportInfoDetailInfoWord.get(o).put("facility_name", facilityName);
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
//          if (!"".equals(facilityCd)){
//            MstFacility facility = mstFacilityDao.selectByCd(facilityCd);
//            if (facility != null) {
//              reportInfo.get(0).put("facility_name", facility.getFacilityName());
//            } else {
//              reportInfo.get(0).put("facility_name", facilityCd);
//            }
//          } else {
//            reportInfo.get(0).put("facility_name", "");
//          }
          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
          // 診療科、診療科連携コードを追加する
          code = 0;
          String mainCourseCd = "";
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
//          if (reportInfoDetailInfoWord.get(o).get("main_course_cd") != null){
          if (reportInfoDetailInfoWord.get(o).containsKey("main_course_cd") && !StringUtils.isEmpty(reportInfoDetailInfoWord.get(o).get("main_course_cd"))) {
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
            code = String.valueOf(reportInfoDetailInfoWord.get(o).get("main_course_cd")).indexOf(".");
            mainCourseCd = String.valueOf(reportInfoDetailInfoWord.get(o).get("main_course_cd"));
            if (code >= 0){
              mainCourseCd = String.valueOf(reportInfoDetailInfoWord.get(o).get("main_course_cd")).substring(0, code);
            }
          }

          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
//          if (reportInfoDetailInfoWord.get(o).get("main_course_name") != null) {
//            reportInfo.get(0).put("main_course_name", reportInfoDetailInfoWord.get(o).get("main_course_name"));
//          } else {
//            if (!"".equals(mainCourseCd)) {
//              MstCourse course = mstCourseDao.selectByCd(Integer.parseInt(mainCourseCd));
//              if (course != null) {
//                if ("1".equals(course.getIsDisp()) && "0".equals(course.getIsDel())) {
//                  reportInfo.get(0).put("main_course_name", course.getCourseName());
//                  reportInfo.get(0).put("main_in_hospital_cd_1", course.getInHospitalCd_1());
//                }
//              } else {
//                reportInfo.get(0).put("main_course_name", "");
//                reportInfo.get(0).put("main_in_hospital_cd_1", "");
//              }
//            } else {
//              reportInfo.get(0).put("main_course_name", "");
//              reportInfo.get(0).put("main_in_hospital_cd_1", "");
//            }
//          }
          String mainCourseName = "";
          String mainInHospitalCd1 = "";
          if (reportInfoDetailInfoWord.get(o).containsKey("main_in_hospital_cd_1") && !StringUtils.isEmpty(reportInfoDetailInfoWord.get(o).get("main_in_hospital_cd_1"))) {
            mainInHospitalCd1 = String.valueOf(reportInfoDetailInfoWord.get(o).get("main_in_hospital_cd_1"));
          }
          if (reportInfoDetailInfoWord.get(o).containsKey("main_course_name") && !StringUtils.isEmpty(reportInfoDetailInfoWord.get(o).get("main_course_name"))) {
            mainCourseName = String.valueOf(reportInfoDetailInfoWord.get(o).get("main_course_name"));
          } else {
            if (!"".equals(mainCourseCd)) {
              MstCourse course = mstCourseDao.selectByCd(Integer.parseInt(mainCourseCd));
              if (course != null) {
                if ("1".equals(course.getIsDisp()) && "0".equals(course.getIsDel())) {
                  mainCourseName = course.getCourseName();
                  if(StringUtils.isEmpty(mainInHospitalCd1)) mainInHospitalCd1 = course.getInHospitalCd_1();
                }
              }
            }
          }
          reportInfoDetailInfoWord.get(o).put("main_course_name", mainCourseName);
          reportInfoDetailInfoWord.get(o).put("main_in_hospital_cd_1", mainInHospitalCd1);
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
//          if (!"".equals(mainCourseCd)) {
//            MstCourse course = mstCourseDao.selectByCd(Integer.parseInt(mainCourseCd));
//            if (course != null) {
//              if ("1".equals(course.getIsDisp()) && "0".equals(course.getIsDel())) {
//                reportInfo.get(0).put("main_course_name", course.getCourseName());
//                reportInfo.get(0).put("main_in_hospital_cd_1", course.getInHospitalCd_1());
//              }
//            } else {
//              reportInfo.get(0).put("main_course_name", "");
//              reportInfo.get(0).put("main_in_hospital_cd_1", "");
//            }
//          } else {
//            reportInfo.get(0).put("main_course_name", "");
//            reportInfo.get(0).put("main_in_hospital_cd_1", "");
//          }
          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end
          // 病棟名、病棟名連携コードを追加する
          code = 0;
          String wardCd = "";
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
//          if (reportInfoDetailInfoWord.get(o).get("ward_cd") != null){
          if (reportInfoDetailInfoWord.get(o).containsKey("ward_cd") && !StringUtils.isEmpty(reportInfoDetailInfoWord.get(o).get("ward_cd"))) {
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
            code = String.valueOf(reportInfoDetailInfoWord.get(o).get("ward_cd")).indexOf(".");
            wardCd = String.valueOf(reportInfoDetailInfoWord.get(o).get("ward_cd"));
            if (code >= 0){
              wardCd = String.valueOf(reportInfoDetailInfoWord.get(o).get("ward_cd")).substring(0, code);
            }
          }

          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　start
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe start
//          if (reportInfoDetailInfoWord.get(o).get("ward_name") != null) {
//            reportInfo.get(0).put("ward_name", reportInfoDetailInfoWord.get(o).get("ward_name"));
//          } else {
//            if (!"".equals(wardCd)) {
//              MstWard ward = mstWardDao.selectByCd(Integer.parseInt(wardCd));
//              if (ward != null) {
//                if ("1".equals(ward.getIsDisp()) && "0".equals(ward.getIsDel())) {
//                  reportInfo.get(0).put("ward_name", ward.getWardName());
//                  reportInfo.get(0).put("ward_in_hospital_cd_1", ward.getInHospitalCd_1());
//                }
//              } else {
//                reportInfo.get(0).put("ward_name", "");
//                reportInfo.get(0).put("ward_in_hospital_cd_1", "");
//              }
//            } else {
//              reportInfo.get(0).put("ward_name", "");
//              reportInfo.get(0).put("ward_in_hospital_cd_1", "");
//            }
//          }
          String wardName = "";
          String wardInHospitalCd1 = "";
          if (reportInfoDetailInfoWord.get(o).containsKey("ward_in_hospital_cd_1") && !StringUtils.isEmpty(reportInfoDetailInfoWord.get(o).get("ward_in_hospital_cd_1"))) {
            wardInHospitalCd1 = String.valueOf(reportInfoDetailInfoWord.get(o).get("ward_in_hospital_cd_1"));
          }
          if (reportInfoDetailInfoWord.get(o).containsKey("ward_name") && !StringUtils.isEmpty(reportInfoDetailInfoWord.get(o).get("ward_name"))) {
            wardName = String.valueOf(reportInfoDetailInfoWord.get(o).get("ward_name"));
          } else {
            if (!"".equals(wardCd)) {
              MstWard ward = mstWardDao.selectByCd(Integer.parseInt(wardCd));
              if (ward != null) {
                if ("1".equals(ward.getIsDisp()) && "0".equals(ward.getIsDel())) {
                  wardName = ward.getWardName();
                  if(StringUtils.isEmpty(wardInHospitalCd1)) wardInHospitalCd1 = ward.getInHospitalCd_1();
                }
              }
            }
          }
          reportInfoDetailInfoWord.get(o).put("ward_name", wardName);
          reportInfoDetailInfoWord.get(o).put("ward_in_hospital_cd_1", wardInHospitalCd1);
          // mod #11813 紹介状出力時、手打ち入力した導入施設名が表示されない limingzhe end
//          if (!"".equals(wardCd)) {
//            MstWard ward = mstWardDao.selectByCd(Integer.parseInt(wardCd));
//            if (ward != null) {
//              if ("1".equals(ward.getIsDisp()) && "0".equals(ward.getIsDel())) {
//                reportInfo.get(0).put("ward_name", ward.getWardName());
//                reportInfo.get(0).put("ward_in_hospital_cd_1", ward.getInHospitalCd_1());
//              }
//            } else {
//              reportInfo.get(0).put("ward_name", "");
//              reportInfo.get(0).put("ward_in_hospital_cd_1", "");
//            }
//          } else {
//            reportInfo.get(0).put("ward_name", "");
//            reportInfo.get(0).put("ward_in_hospital_cd_1", "");
//          }
          // mod #9823 mongoDBの患者情報履歴情報にマスタの名称などが記録されていない。高　end

          for (String key : reportInfoDetailInfoWord.get(o).keySet()) {
            reportInfo.get(0).put(key, reportInfoDetailInfoWord.get(o).get(key));
          }
        }
      }
      // 入外転入出
      else if ("in_out_visit_history_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        // mod 10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 sunsy start
        // mod #10319 患者情報.入外・転入出に区分でDBの取得元を変えるデータ項目を追加 sunsy start
//        return reportInfoDetailInfoWord;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        Set<Integer> moveInTarget = Set.of(1, 2, 4, 5, 7, 8, 10);
        Set<Integer> moveOutTarget = Set.of(3, 9);
        for (int i = 0; i < reportInfoDetailInfoWord.size(); i++) {
          Map<String, Object> detailInfoMiddle = new HashMap<>();

          detailInfoMiddle = reportInfoDetailInfoWord.get(i);
          if (reportInfoDetailInfoWord.get(i).containsKey("move_in_out") && reportInfoDetailInfoWord.get(i).get("move_in_out") != null) {
            int intValue = Integer.parseInt(String.valueOf(reportInfoDetailInfoWord.get(i).get("move_in_out")));
            if (moveInTarget.contains(intValue)) {
              detailInfoMiddle.put("facility_name",reportInfoDetailInfoWord.get(i).get("from_facility_name"));
              detailInfoMiddle.put("course_name",reportInfoDetailInfoWord.get(i).get("from_course_name"));
              detailInfoMiddle.put("doctor_name",reportInfoDetailInfoWord.get(i).get("from_doctor_name"));
            }else if (moveOutTarget.contains(intValue)){
              detailInfoMiddle.put("facility_name",reportInfoDetailInfoWord.get(i).get("to_facility_name"));
              detailInfoMiddle.put("course_name",reportInfoDetailInfoWord.get(i).get("to_course_name"));
              detailInfoMiddle.put("doctor_name",reportInfoDetailInfoWord.get(i).get("to_doctor_name"));
            }else {
              detailInfoMiddle.put("facility_name","");
              detailInfoMiddle.put("course_name","");
              detailInfoMiddle.put("doctor_name","");
            }
          }
          reportInfoDetailInfoWordMiddle.add(detailInfoMiddle);
        }
        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
        // mod #10319 患者情報.入外・転入出に区分でDBの取得元を変えるデータ項目を追加 sunsy end
//        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
//        // 当院開始日
//        if(null != reportInfoDetailInfoWord ){
//          Map<Object,Object> periodStartDate1 = new HashMap<>();
//          Map<Object,Object> periodStartDate2 = new HashMap<>();
//          String date = strFromDate;
//          Map<String, Object> minNode = new HashMap<>();
//          List<Integer> list = new ArrayList<>();
//          for (int i = 0; i < reportInfoDetailInfoWord.size(); i++) {
//            Map<String,Object> map  = reportInfoDetailInfoWord.get(i);
//            // mod 9484　因島帳票の表示不具合（帳票種別：紹介状）　吉 start
//            // if(null == map.get("from_facility") && "1".equals(map.get("move_in_out")) && null != map.get("period_start_date")){
//            // del 10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 高　start
////            if( "1".equals(map.get("move_in_out")) && null != map.get("period_start_date")){
//            // del 10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 高　end
//              // mod 9484　因島帳票の表示不具合（帳票種別：紹介状）　吉 end
//              periodStartDate1.put(map.get("period_start_date").toString(),map);
//            // del 10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 高　start
////            }
//            // del 10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 高　end
//            // mod 9484　因島帳票の表示不具合（帳票種別：紹介状）　吉 str
//            // if(null == map.get("from_facility") && "2".equals(map.get("move_in_out")) && null != map.get("period_start_date")){
//            // del 10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 高　start
////            if( "2".equals(map.get("move_in_out")) && null != map.get("period_start_date")){
//            // del 10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 高　end
//              // mod 9484　因島帳票の表示不具合（帳票種別：紹介状）　吉 end
//              Integer a =Integer.valueOf(date)-Integer.valueOf(map.get("period_start_date").toString()) > 0 ? Integer.valueOf(date)-Integer.valueOf(map.get("period_start_date").toString()) :-(Integer.valueOf(date)-Integer.valueOf(map.get("period_start_date").toString()));
//              periodStartDate2.put(String.valueOf(a),map);
//            // del 10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 高　start
////            }
//            // del 10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 高　end
//          }
//          if(null != periodStartDate1 && periodStartDate1.size()>0){
//            List<Map.Entry<String,Object>> lstEntry=new ArrayList(periodStartDate1.entrySet());
//            Collections.sort(lstEntry,((o1, o2) -> {
//              return Integer.valueOf(o1.getKey()).compareTo(Integer.valueOf(o2.getKey()));
//            }));
//            Map.Entry<String,Object> minMap  = lstEntry.get(0);
//            minNode = (Map<String, Object>) minMap.getValue();
//          }else{
//            if(null != periodStartDate2 && periodStartDate2.size()>0){
//              List<Map.Entry<String,Object>> lstEntry=new ArrayList(periodStartDate2.entrySet());
//              Collections.sort(lstEntry,((o1, o2) -> {
//                return Integer.valueOf(o1.getKey()).compareTo(Integer.valueOf(o2.getKey()));
//              }));
//              Map.Entry<String,Object> minMap  = lstEntry.get(0);
//              minNode = (Map<String, Object>) minMap.getValue();
//            }
//          }
//          reportInfoDetailInfoWordMiddle.add(minNode);
//          reportInfoDetailInfoWord=reportInfoDetailInfoWordMiddle;
//        }
        // mod 10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 sunsy end
      }
      // 既往歴-患者グループ部分
      // mod 10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
//      else if ("none".equals(doDetailInfoWord)){
//        String patGroupCd = "";
//        String facilityCd = "";
//        if (reportInfo.get(0).get("pat_group_cd") != null){
//          patGroupCd = reportInfo.get(0).get("pat_group_cd").toString();
//        }
//        if (reportInfo.get(0).get("facility_cd") != null){
//          facilityCd = reportInfo.get(0).get("facility_cd").toString();
//        }
//        if (!"".equals(patGroupCd) && !"".equals(facilityCd)) {
//          PatGroup patGroup = patGroupDao.selectById(Long.parseLong(patGroupCd), facilityCd);
//          if (patGroup != null){
//            if ("1".equals(patGroup.getIsDisp()) && "0".equals(patGroup.getIsDel())){
//              reportInfo.get(0).put("pat_group_name", patGroup.getPatGroupName());
//            } else {
//              reportInfo.get(0).put("pat_group_name", "");
//            }
//          } else {
//            reportInfo.get(0).put("pat_group_name", "");
//          }
//        } else {
//          reportInfo.get(0).put("pat_group_name", "");
//        }
//      }
      else if ("pat_group_info".equals(doDetailInfoWord)){
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        for (int u = 0; u < reportInfoDetailInfoWord.size(); u++){
          Map<String, Object> detailInfoMiddle = new HashMap<>();
          for (String key : reportInfoDetailInfoWord.get(u).keySet()){
            detailInfoMiddle.put(key,reportInfoDetailInfoWord.get(u).get(key));
          }
          reportInfoDetailInfoWordMiddle.add(detailInfoMiddle);
        }
        reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
      }
      // mod 10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
      //　保険情報部分
      // mod #10210帳票における患者情報の取得元について sunsy start
//      else if (doDetailInfoWord.contains("&")){
      // mod #9650 治療経過表、カテゴリ「患者情報」の項目出力不正 limingzhe start
//      else if (doDetailInfoWord.contains("&") && !doDetailInfoWord.equals("wheel_chair_cd&wheel_chair_name&wheel_chair_weight")){
      else if (doDetailInfoWord.contains("insu_set_info") || doDetailInfoWord.contains("insu_info") || doDetailInfoWord.contains("insu_pub_info")){
      // mod #9650 治療経過表、カテゴリ「患者情報」の項目出力不正 limingzhe end
        // add #10210帳票における患者情報の取得元について sunsy end
        // add #9650 治療経過表、カテゴリ「患者情報」の項目出力不正 limingzhe start
        if(reportInfo != null && reportInfo.size() > 0
          && reportInfo.get(0).get("is_disp").equals("1") && reportInfo.get(0).get("is_del").equals("0")
        ) {
        // add #9650 治療経過表、カテゴリ「患者情報」の項目出力不正 limingzhe end
          int num = 1;
          String doInfo = "";
          Pattern p = Pattern.compile("&");
          Matcher m = p.matcher(doDetailInfoWord);
          while (m.find()) {
            num++;
          }
          for (int i = 0; i < num; i++) {
            if (i == 2) {
              doInfo = doDetailInfoWord;
            } else {
              int strL = doDetailInfoWord.indexOf("&");
              doInfo = doDetailInfoWord.substring(0, strL);
              doDetailInfoWord = doDetailInfoWord.substring(strL + 1, doDetailInfoWord.length());
            }
            // add #10210 帳票における患者情報の取得元について sunsy start
            if (reportInfo.get(0).get(doInfo) != null) {
              // add #10210 帳票における患者情報の取得元について sunsy end

              String doStr = String.valueOf(reportInfo.get(0).get(doInfo));
              if (doStr.startsWith("[{")) {
                // mode 2023/07/06 kangjie start eol_6805
                //            reportInfoDetailInfoWord = (List<Map<String, Object>>) BasicDBObject.parse(doStr);
                reportInfoDetailInfoWord = ObjectMapperUtil.readListOfMap(doStr);
                // mode 2023/07/06 kangjie end eol_6805
              } else if (doStr.startsWith("{")) {
                Map maps = (Map) BasicDBObject.parse(doStr);
                reportInfoDetailInfoWord.add(maps);
              }
              // add #10210 帳票における患者情報の取得元について sunsy start
            }
            // add #10210 帳票における患者情報の取得元について sunsy end

            if (reportInfoDetailInfoWord.size() > 0) {
              for (int s = 0; s < reportInfoDetailInfoWord.size(); s++) {
                for (String key : reportInfoDetailInfoWord.get(s).keySet()) {
                  if ("futan-g".equals(key)) {
                    reportInfo.get(0).put("futan_g", reportInfoDetailInfoWord.get(s).get(key));
                  } else if ("futan-n".equals(key)) {
                    reportInfo.get(0).put("futan_n", reportInfoDetailInfoWord.get(s).get(key));
                    // add 10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy start
                  } else if ("insu_name".equals(key)) {
                    reportInfo.get(0).put("insu_set_name", reportInfoDetailInfoWord.get(s).get(key));
                    // add 10242 カテゴリ「患者情報」のクラス等名称変更と不足項目の追加 sunsy end
                    // add #10210 帳票における患者情報の取得元について sunsy start
                  } else if ("insu_pub_name".equals(key)) {
                    reportInfo.get(0).put("insu_pub1_name", reportInfoDetailInfoWord.get(s).get(key));
                  } else if ("insu_pub_no".equals(key)) {
                    reportInfo.get(0).put("insu_pub1_no", reportInfoDetailInfoWord.get(s).get(key));
                  } else if ("insu_pub_pat_no".equals(key)) {
                    reportInfo.get(0).put("insu_pub1_pat_no", reportInfoDetailInfoWord.get(s).get(key));
                  } else if ("passbook_no".equals(key)) {
                    reportInfo.get(0).put("insu_pub1_passbook_no", reportInfoDetailInfoWord.get(s).get(key));
                  } else if ("insu_class".equals(key)) {
                    continue;
                    // add #10210 帳票における患者情報の取得元について sunsy end
                  } else {
                    reportInfo.get(0).put(key, reportInfoDetailInfoWord.get(s).get(key));
                  }
                }
              }
              reportInfo.get(0).remove(doInfo);
            }
          }
          reportInfo.get(0).put("selected_flg", reportInfo.get(0).get("is_selected"));
          reportInfo.get(0).put("insu_start_date", reportInfo.get(0).get("start_date"));
          reportInfo.get(0).remove("start_date");
          reportInfo.get(0).put("insu_end_date", reportInfo.get(0).get("end_date"));
          reportInfo.get(0).remove("end_date");
          reportInfo.get(0).put("insu_check_date", reportInfo.get(0).get("check_date"));
          reportInfo.get(0).remove("check_date");
        // add #9650 治療経過表、カテゴリ「患者情報」の項目出力不正 limingzhe start
        }
        else {
          reportInfo.clear();
        }
        // add #9650 治療経過表、カテゴリ「患者情報」の項目出力不正 limingzhe end
      }
      // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
      // 当院開始日
      else if ("period_start_date".equals(doDetailInfoWord)) {
        doDetailInfoFlag = true;
        List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
        if(null != reportInfoDetailInfoWord ){
          Map<Object,Object> periodStartDate1 = new HashMap<>();
          Map<Object,Object> periodStartDate2 = new HashMap<>();
          String date = strFromDate;
          Map<String, Object> minNode = new HashMap<>();
          for (int i = 0; i < reportInfoDetailInfoWord.size(); i++) {
            Map<String,Object> map  = reportInfoDetailInfoWord.get(i);
            if(!map.containsKey("period_start_date")) continue;
            periodStartDate1.put(String.valueOf(map.get("period_start_date")),map);
            Integer a =Integer.valueOf(date)-Integer.valueOf(String.valueOf(map.get("period_start_date"))) > 0 ? Integer.valueOf(date)-Integer.valueOf(String.valueOf(map.get("period_start_date"))) :-(Integer.valueOf(date)-Integer.valueOf(String.valueOf(map.get("period_start_date"))));
            periodStartDate2.put(String.valueOf(a),map);
          }
          if(null != periodStartDate1 && periodStartDate1.size()>0){
            List<Map.Entry<String,Object>> lstEntry=new ArrayList(periodStartDate1.entrySet());
            Collections.sort(lstEntry,((o1, o2) -> {
              return Integer.valueOf(o1.getKey()).compareTo(Integer.valueOf(o2.getKey()));
            }));
            Map.Entry<String,Object> minMap  = lstEntry.get(0);
            minNode = (Map<String, Object>) minMap.getValue();
          }else{
            if(null != periodStartDate2 && periodStartDate2.size()>0){
              List<Map.Entry<String,Object>> lstEntry=new ArrayList(periodStartDate2.entrySet());
              Collections.sort(lstEntry,((o1, o2) -> {
                return Integer.valueOf(o1.getKey()).compareTo(Integer.valueOf(o2.getKey()));
              }));
              Map.Entry<String,Object> minMap  = lstEntry.get(0);
              minNode = (Map<String, Object>) minMap.getValue();
            }
          }
          if(minNode != null && minNode.size() > 0) minNode.put("pat_id", reportInfo.get(0).get("pat_id"));
          reportInfoDetailInfoWordMiddle.add(minNode);
          reportInfoDetailInfoWord = reportInfoDetailInfoWordMiddle;
        }
      }
      // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end

      if (doDetailInfoFlag) {
        // 帳票出力情報
        return replaceReportInfo(reportInfoDetailInfoWord, sysDataSet.getDetailInfo().getDetails());
      }
    }
    return reportInfo;
  }

  // add 10210 by kangjie 20240606 start
  /**
  * @Author kangjie
  * @Description マスター設定でソートします
  * @Date 2024/06/06 13:45
  * @Param [facilityCd, masterPhysicalName, code,reportInfoDetailInfoWordMiddle]
  * @return java.util.List<java.util.Map<java.lang.String,java.lang.Object>>
  **/
  private List<Map<String,Object>> sortDataByMasterSetting(
      String facilityCd
    , String masterPhysicalName
    , String code
    , List<Map<String, Object>> reportInfoDetailInfoWordMiddle) {

    List<Map<String,Object>> result = new LinkedList<>();
    MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, masterPhysicalName);
    if (Objects.nonNull(mstSelector)) {
      // マスターでソートされた順序リスト
      List<String> selectCodes = mstSelector.getOrderSettings().getItems().stream()
        .map(e -> e.getCode().toString()).collect(Collectors.toList());

      for (String selectCode: selectCodes) {
        for (Map<String,Object> map : reportInfoDetailInfoWordMiddle) {
          if (Objects.equals(selectCode,map.get(code).toString())) {
            result.add(map);
          }
        }
      }
    }

    return result;
  }
  // add 10210 by kangjie 20240606 end

  // add #10605 【デグレ】観察記録がテンプレート繰返しされない limingzhe start
  @Override
  public boolean distinParaOnlybyPatId(Long sqlCode)  {
    SysDataSet sysDataSet = getSysDataSet(sqlCode);
    if (sysDataSet == null) {
      return false;
    }
    if(StringUtils.isEmpty(sysDataSet.getSql())){
      return false;
    }
    if (!"{\"applications\": [1]}".equals(sysDataSet.getUseApplication())){
      return false;
    }

    try{
      Integer dbClass = sysDataSet.getDbClass();
      String sql = sysDataSet.getSql();

      if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
        List<String> sqlDataKey = new ArrayList<>();
        sqlDataKey.add("patId");
        sqlDataKey.add("ordNo");
        Map<String, Integer> sqlDataKeyCount = new HashMap<>();
        sqlDataKey.forEach((key) -> {
          sqlDataKeyCount.put(key, StringUtils.countOccurrencesOf(sql, key));
        });
        return sqlDataKeyCount.get("ordNo") == 0 && sqlDataKeyCount.get("patId") > 0;
        // add #10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない 杜天成 start
      }else if(SysDataSet.DB_CLASS_MONGODB.equals(dbClass)){
        List<String> sqlDataKey = new ArrayList<>();
        sqlDataKey.add("patId");
        sqlDataKey.add("ordNo");
        Map<String, Integer> sqlDataKeyCount = new HashMap<>();
        sqlDataKey.forEach((key) -> {
          sqlDataKeyCount.put(key, StringUtils.countOccurrencesOf(sql, key));
        });
        return sqlDataKeyCount.get("ordNo") == 0 && sqlDataKeyCount.get("patId") > 0;
      }
      // add #10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない 杜天成 end
    }catch(Exception e){
      return false;
    }
    return false;
  }
  // add #10605 【デグレ】観察記録がテンプレート繰返しされない limingzhe end
  // add #10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない 杜天成 start
  @Override
  public boolean distinParaOnlybyOrdNos(Long sqlCode)  {
    SysDataSet sysDataSet = getSysDataSet(sqlCode);
    if (sysDataSet == null) {
      return false;
    }
    if(StringUtils.isEmpty(sysDataSet.getSql())){
      return false;
    }
    if (!"{\"applications\": [1]}".equals(sysDataSet.getUseApplication())){
      return false;
    }

    try{
      Integer dbClass = sysDataSet.getDbClass();
      String sql = sysDataSet.getSql();

      if (SysDataSet.DB_CLASS_DB5.equals(dbClass)) {
        List<String> sqlDataKey = new ArrayList<>();
        sqlDataKey.add("ordNos");
        Map<String, Integer> sqlDataKeyCount = new HashMap<>();
        sqlDataKey.forEach((key) -> {
          sqlDataKeyCount.put(key, StringUtils.countOccurrencesOf(sql, key));
        });
        return sqlDataKeyCount.get("ordNos") > 0;
      }
    }catch(Exception e){
      return false;
    }
    return false;
  }
  // add #10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない 杜天成  end

  // add #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
  @Override
  public boolean distinParaOnlybyParam(Long sqlCode, String strParam)  {
    SysDataSet sysDataSet = getSysDataSet(sqlCode);
    if (sysDataSet == null) {
      return false;
    }
    if(StringUtils.isEmpty(sysDataSet.getSql())){
      return false;
    }
    if (!"{\"applications\": [1]}".equals(sysDataSet.getUseApplication())){
      return false;
    }

    try{
      Integer dbClass = sysDataSet.getDbClass();
      String sql = sysDataSet.getSql();

      if (SysDataSet.DB_CLASS_DB5.equals(dbClass) || SysDataSet.DB_CLASS_DB6.equals(dbClass)
        // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
        || SysDataSet.DB_CLASS_DB4.equals(dbClass) || SysDataSet.DB_CLASS_MONGODB.equals(dbClass)
        // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
      ) {
        List<String> sqlDataKey = new ArrayList<>();
        sqlDataKey.add(strParam);
        Map<String, Integer> sqlDataKeyCount = new HashMap<>();
        sqlDataKey.forEach((key) -> {
          sqlDataKeyCount.put(key, StringUtils.countOccurrencesOf(sql, key));
        });
        return sqlDataKeyCount.get(strParam) > 0;
      }
    }catch(Exception e){
      return false;
    }
    return false;
  }
  // add #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end

  // add #9743 紋別帳票の表示不具合（観察記録20180810） limingzhe start
  private String removeComments(String sql) {
    String singleLineComment = "--[^\\n]*";
    String multiLineComment = "/\\*[\\s\\S]*?\\*/";
    String newSql = sql.replaceAll(singleLineComment, "");
    return newSql.replaceAll(multiLineComment, "");
  }
  // add #9743 紋別帳票の表示不具合（観察記録20180810） limingzhe end

  // add #11172 患者情報系historyの取得条件見直し limingzhe start
  @Override
  public boolean isMongDBSqlSearch(Long sqlCode){
    SysDataSet sysDataSet = getSysDataSet(sqlCode);
    if (sysDataSet == null) {
      return false;
    }
    if(StringUtils.isEmpty(sysDataSet.getSql())){
      return false;
    }
    if (!"{\"applications\": [1]}".equals(sysDataSet.getUseApplication()) || sysDataSet.getDbClass() != 4){
      return false;
    }
    return true;
  }
  // add #11172 患者情報系historyの取得条件見直し limingzhe end

  // add #10740 指示.修正内容の出力不正 sunsy start
  @Override
  public boolean isIndHistorySqlSearch(Long sqlCode){
    SysDataSet sysDataSet = getSysDataSet(sqlCode);
    if (sysDataSet == null) {
      return false;
    }
    if (StringUtils.isEmpty(sysDataSet.getSql())){
      return false;
    }
    if (!"{\"applications\": [1]}".equals(sysDataSet.getUseApplication()) || sysDataSet.getDbClass() != 4 || !sysDataSet.getSql().contains("ind_history")){
      return false;
    }
    return true;
  }
  // add #10740 指示.修正内容の出力不正 sunsy end
  // add #11226 患者情報系historyの取得条件見直し② limingzhe start
  @Override
  public List<Map<String, Object>> sqlDB5Search(String sql){
    Config config = defaultDbConfig;
    SelectBuilder builder = SelectBuilder.newInstance(config);

    builder.sql(sql);
    List<Map<String, Object>> results = sysDataSetDao.executeSql(builder);
    return results;
  }
  // add #11226 患者情報系historyの取得条件見直し② limingzhe end

  // add #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　start
  private Map<String, Object> getMongDBSelectParameter(Long sqlCode, Map<String, Object> dataKey, boolean bSelectAll) {
    Map<String, Object> mongoDBParameter = new HashMap<String, Object>();
    SysDataSet sysDataSet = getSysDataSet(sqlCode);
    if (sysDataSet == null) {
      return mongoDBParameter;
    }
    if(StringUtils.isEmpty(sysDataSet.getSql())){
      return mongoDBParameter;
    }
    if (!"{\"applications\": [1]}".equals(sysDataSet.getUseApplication()) || sysDataSet.getDbClass() != 4){
      return mongoDBParameter;
    }
    String sql = sysDataSet.getSql();
    if (!sql.endsWith("}}")){
      String a = sql.substring(0, sql.lastIndexOf("}"));
      String b = a.substring(a.lastIndexOf("}") + 1, a.length());
      mongoDBParameter.put("field", b.substring(1, b.length()));
      sql = sql.replace(b, "");
    }
    for (String key: dataKey.keySet()) {
      sql = sql.replace("@"+ key,dataKey.get(key) == null?"":dataKey.get(key).toString());
    }
    mongoDBParameter.putAll(this.createSelectParameter(sql, mongoDBParameter));
    // add #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 start
    mongoDBParameter.put("sql",sql);
    // add #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 end
    if(bSelectAll && mongoDBParameter.containsKey("slice")) {
      mongoDBParameter.remove("slice");
    }
    return mongoDBParameter;
  }

  public List<Map<String, Object>> getMongDBSelectResults(Long sqlCode, Map<String, Object> dataKey, String strFromDate,boolean oneOrMoreDayFlag) {
    List<Map<String, Object>> mongoDBResult = new ArrayList<>();

    Map<String, Object> mongoDBDataKey = new HashMap<String, Object>();
    dataKey.put("toDate", strFromDate);
    mongoDBDataKey = getMongDBSelectParameter(sqlCode, dataKey, oneOrMoreDayFlag);

    List<Map<String, Object>> mongoDBData = getMongoDBData(mongoDBDataKey);

    // mod #12017 複数患者帳票のテンプレートに一部のsqlに対する情報が出ない sunsy start
//    if("pat_memo_info".equals(mongoDBDataKey.get("field").toString())){
    if(mongoDBDataKey.get("field") != null && "pat_memo_info".equals(mongoDBDataKey.get("field").toString())){
    // mod #12017 複数患者帳票のテンプレートに一部のsqlに対する情報が出ない sunsy end
      SelectOptions selectOptions = SelectOptions.get();
      MstPatMemo params = new MstPatMemo();
      params.setFacilityCd(String.valueOf(dataKey.get("facilityCd")));
      List<MstPatMemo> list = mstPatMemoDao.selectAll(selectOptions, params);
      if(list != null && list.size() > 0){
        for (Map<String, Object> map : mongoDBData) {
          if(map.containsKey("pat_memo_info")){
            List<Map<String, Object>> reportInfoDetailInfoWord = map.get("pat_memo_info") != null ? (List<Map<String, Object>>)map.get("pat_memo_info") : new LinkedList<>();
            List<Map<String, Object>> reportInfoDetailInfoWordMiddle = new LinkedList<>();
            for (int d = 0; d < reportInfoDetailInfoWord.size(); d++){
              Map<String, Object> currentMap = reportInfoDetailInfoWord.get(d);
              if(currentMap.containsKey("ctl_no")){
                for(MstPatMemo mstPatMemo : list){
                  if(String.valueOf(mstPatMemo.getPatMemoNo()).equals(currentMap.get("ctl_no").toString())){
                    if ("1".equals(mstPatMemo.getIsDisp()) && "0".equals(mstPatMemo.getIsDel())){
                      reportInfoDetailInfoWordMiddle.add(currentMap);
                    }
                  }
                }
              }
            }
            map.put("pat_memo_info", reportInfoDetailInfoWordMiddle);
          }
        }
      }
    }
    try {
      for (Map<String, Object> map : mongoDBData) {
        List<Map<String, Object>> resultsNewTmpOne = new ArrayList<>();
        resultsNewTmpOne.add(map);
        List<Map<String, Object>> resultsNewTmpTwo = new ArrayList<>();
        // add #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 start
        dataKey.put("strFromDate",String.valueOf(dataKey.get("toDate")).replace("-","").replace("/","").substring(0,8));
        // add #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 end
        resultsNewTmpTwo = replaceDataForMongDb(
          // mod #12017 複数患者帳票のテンプレートに一部のsqlに対する情報が出ない sunsy start
//          mongoDBDataKey.get("field").toString(),
          mongoDBDataKey.get("field") != null ? mongoDBDataKey.get("field").toString() : "",
          // mod #12017 複数患者帳票のテンプレートに一部のsqlに対する情報が出ない sunsy end
          resultsNewTmpOne,
          // add #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 start
          mongoDBDataKey.get("sql").toString(),
          // add #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 end
          // mod #12017 複数患者帳票のテンプレートに一部のsqlに対する情報が出ない sunsy start
//          String.valueOf(dataKey.get("toDate")).replace("-","").replace("/",""),
          // mod #12017 複数患者帳票のテンプレートに一部のsqlに対する情報が出ない sunsy end
          // mod #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 start
//          getSysDataSet(sqlCode),
//          String.valueOf(dataKey.get("facilityCd"))
          getSysDataSet(sqlCode),dataKey
          // mod #12195 "患者情報"にある"加算/管理料"の算定日が帳票で表示されない 吉 end
        );
        // add #9961 複数患者帳票で保険情報の出力不正 高 start
        // del #9650 治療経過表、カテゴリ「患者情報」の項目出力不正 limingzhe start
//        if (null != resultsNewTmpTwo && resultsNewTmpTwo.size() > 0 && "0".equals(resultsNewTmpTwo.get(0).get("is_disp")) && "14".equals(sqlCode.toString())) {
//          resultsNewTmpTwo.clear();
//        }
        // del #9650 治療経過表、カテゴリ「患者情報」の項目出力不正 limingzhe end
        // add #9961 複数患者帳票で保険情報の出力不正 高 end
        if(resultsNewTmpTwo.size() > 0){
          // mod #11259 テンプレート内の繰り返しで2行目以降の書式がコピーされなくなっている 高 start
          for (int index = 0; index < resultsNewTmpTwo.size();index++) {
            if(!resultsNewTmpTwo.get(index).containsKey("up_date") && map.containsKey("up_date")) {
              resultsNewTmpTwo.get(index).put("up_date", map.get("up_date"));
            }
            mongoDBResult.add(resultsNewTmpTwo.get(index));
          }
//          if(!resultsNewTmpTwo.get(0).containsKey("up_date") && map.containsKey("up_date")) {
//            resultsNewTmpTwo.get(0).put("up_date", map.get("up_date"));
//          }
//          mongoDBResult.add(resultsNewTmpTwo.get(0));
          // mod #11259 テンプレート内の繰り返しで2行目以降の書式がコピーされなくなっている 高 end
        }
      }
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
    return mongoDBResult;
  }
  // add #11679 複数患者帳票で「透析条件.補液量」が出ない 20250422 limingzhe　end

  // add #11465 【たくしん会】既往歴に発症日nullのデータがあると帳票出力時にエラー sunsy start
  // 病歴(昇順)、病歴(降順)を実現するため、sort_year、sort_month、sort_day値の設定
  private static void populateSortFields(Map<String, Object> record) {
    // 発生日が完全であり、年月日が揃っている場合、つまりdisease_dateが存在する状況
    if (record.containsKey("disease_date") && record.get("disease_date") != null) {
      String date = record.get("disease_date").toString();
      if (date.length() == 8) {
        record.put("sort_year", date.substring(0, 4));
        record.put("sort_month", date.substring(4, 6));
        record.put("sort_day", date.substring(6, 8));
        return;
      }
    }

    // 診断日が完全であり、年月日が揃っている場合、つまりdiagnosis_dateが存在する状況
    if (record.containsKey("diagnosis_date") && record.get("diagnosis_date") != null) {
      String date = record.get("diagnosis_date").toString();
      if (date.length() == 8) {
        record.put("sort_year", date.substring(0, 4));
        record.put("sort_month", date.substring(4, 6));
        record.put("sort_day", date.substring(6, 8));
        return;
      }
    }

    // 発生日が年月日の一部のみである場合、情報がない部分でデフォルト値として変換する処理
    String diseaseYear = safeGetString(record, "disease_year", "0000");
    String diseaseMonth = safeGetString(record, "disease_month", "00");
    String diseaseDay = safeGetString(record, "disease_day", "00");

    // 診断日が年月日の一部のみである場合、情報がない部分でデフォルト値として変換する処理
    String diagnosisYear = safeGetString(record, "diagnosis_year", "0000");
    String diagnosisMonth = safeGetString(record, "diagnosis_month", "00");
    String diagnosisDay = safeGetString(record, "diagnosis_day", "00");

    // 発生日が年月ある場合
    if (!diseaseYear.equals("0000") && !diseaseMonth.equals("00")) {
      record.put("sort_year", diseaseYear);
      record.put("sort_month", diseaseMonth);
      record.put("sort_day", diseaseDay);
      return;
    }
    // 診断日が年月ある場合
    if (!diagnosisYear.equals("0000") && !diagnosisMonth.equals("00")) {
      record.put("sort_year", diagnosisYear);
      record.put("sort_month", diagnosisMonth);
      record.put("sort_day", diagnosisDay);
      return;
    }
    // 発生日が年日ある場合
    if (!diseaseYear.equals("0000") && !diseaseDay.equals("00")) {
      record.put("sort_year", diseaseYear);
      record.put("sort_month", diseaseMonth);
      record.put("sort_day", diseaseDay);
      return;
    }
    // 診断日が年日ある場合
    if (!diagnosisYear.equals("0000") && !diagnosisDay.equals("00")) {
      record.put("sort_year", diagnosisYear);
      record.put("sort_month", diagnosisMonth);
      record.put("sort_day", diagnosisDay);
      return;
    }
    // 発生日が年ある場合
    if (!diseaseYear.equals("0000")) {
      record.put("sort_year", diseaseYear);
      record.put("sort_month", diseaseMonth);
      record.put("sort_day", diseaseDay);
      return;
    }
    // 診断日が年ある場合
    if (!diagnosisYear.equals("0000")) {
      record.put("sort_year", diagnosisYear);
      record.put("sort_month", diagnosisMonth);
      record.put("sort_day", diagnosisDay);
      return;
    }
    // 発生日が月日ある場合
    if (!diseaseMonth.equals("00") && !diseaseDay.equals("00")) {
      record.put("sort_year", diseaseYear);
      record.put("sort_month", diseaseMonth);
      record.put("sort_day", diseaseDay);
      return;
    }
    // 診断日が月日ある場合
    if (!diagnosisMonth.equals("00") && !diagnosisDay.equals("00")) {
      record.put("sort_year", diagnosisYear);
      record.put("sort_month", diagnosisMonth);
      record.put("sort_day", diagnosisDay);
      return;
    }
    // 発生日が月ある場合
    if (!diseaseMonth.equals("00")) {
      record.put("sort_year", diseaseYear);
      record.put("sort_month", diseaseMonth);
      record.put("sort_day", diseaseDay);
      return;
    }
    // 診断日が月ある場合
    if (!diagnosisMonth.equals("00")) {
      record.put("sort_year", diagnosisYear);
      record.put("sort_month", diagnosisMonth);
      record.put("sort_day", diagnosisDay);
      return;
    }
    // 発生日が日のみある場合
    if (!diseaseDay.equals("00")) {
      record.put("sort_year", diseaseYear);
      record.put("sort_month", diseaseMonth);
      record.put("sort_day", diseaseDay);
      return;
    }
    // 診断日が日のみある場合
    if (!diagnosisDay.equals("00")) {
      record.put("sort_year", diagnosisYear);
      record.put("sort_month", diagnosisMonth);
      record.put("sort_day", diagnosisDay);
      return;
    }
    // 発生日でも診断日でも両方ない場合
    record.put("sort_year", "0000");
    record.put("sort_month", "00");
    record.put("sort_day", "00");
  }

  // 発生日または診断日に、年月日のどちらがない場合、デフォルト値に変換
  private static String safeGetString(Map<String, Object> record, String key, String defaultValue) {
    Object value = record.get(key);
    return (value == null) ? defaultValue : value.toString();
  }
  // add #11465 【たくしん会】既往歴に発症日nullのデータがあると帳票出力時にエラー sunsy end

  // add #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe start
  public List<Map<String, String>> getConvTableItemStr(Long sqlCode, String dataCode) {
    List<Map<String, String>> convTableList = new ArrayList<>();
    if(sqlCode == 0l) {
      if(dataCode.equals("reportClass")){
        List<SysReportClass> reportClasses = sysReportClassDao.selectSysReportClassAll();
        if(reportClasses != null){
          for(SysReportClass reportClass : reportClasses) {
            Map<String, String> map = new HashMap<>();
            map.put("code", reportClass.getReportClassCd());
            map.put("item", reportClass.getReportClassName());
            map.put("disp", reportClass.getReportClassName());
            convTableList.add(map);
          }
        }
      }
      else if(dataCode.equals("sortOrder1") || dataCode.equals("sortOrder2") || dataCode.equals("sortOrder3")){
        Map<String, String> map1 = new HashMap<>();
        map1.put("code", "0");
        map1.put("item", "昇順");
        map1.put("disp", "昇順");
        convTableList.add(map1);
        Map<String, String> map2 = new HashMap<>();
        map2.put("code", "1");
        map2.put("item", "降順");
        map2.put("disp", "降順");
        convTableList.add(map2);
      }
      return convTableList;
    }
    SysDataSet sysDataSet = getSysDataSet(sqlCode);
    if(sysDataSet != null) {
      List<Detail> details = sysDataSet.getDetailInfo().getDetails();
      Detail detail = details.stream().filter(d -> dataCode.equals(d.getDataCode())).findFirst().orElse(null);

      if(detail != null) {
        for(Detail.convTableItem convItem : detail.getConvTable()) {
          Map<String, String> map = new HashMap<>();
          map.put("code", convItem.getCode());
          map.put("item", convItem.getItem());
          map.put("disp", convItem.getDisp());
          convTableList.add(map);
        }
      }
    }
    return convTableList;
  }
  // add #12125 文字列型の組み合わせが正しく表示されない場合がある limingzhe end
}
