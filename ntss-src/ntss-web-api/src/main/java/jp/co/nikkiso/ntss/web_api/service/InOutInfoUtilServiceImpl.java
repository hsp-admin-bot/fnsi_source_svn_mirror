package jp.co.nikkiso.ntss.web_api.service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.api.constant.InOutInfoConstant.InOutVisitHistoryInfoMoveInOut;
import jp.co.nikkiso.ntss.api.constant.InOutInfoConstant.PatInfoInOutClass;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
import jp.co.nikkiso.ntss.web_api.service.patMainHistory.PatMainHistory;
import org.json.JSONArray;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessResourceFailureException;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.entity.custom.PatInOutUpdateInfo;
import org.springframework.transaction.annotation.Transactional;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 検査結果計算のService実装クラス.
 */
@Service
public class InOutInfoUtilServiceImpl implements InOutInfoUtilService {
// add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  @Autowired(required = false)
  MongoTemplate mongoTemplate;
// add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end
  /**
   * 患者基本情報Dao.
   */
  @Autowired
  private PatMainDao patMainDao;

  /**
   * 患者基本情報Dao.
   */
  @Autowired
  private PatUniqueDao patUniqueDao;

  /**
   * 患者情報Dao.
   */
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;


  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  // add by guanyingshuai 2023-01-31 [Transaction] --start /
  @Autowired
  private LogService logService;
  // add by guanyingshuai 2023-01-31 [Transaction] --end /


  /**
   * {@inheritDoc}
   */
  @Transactional
  public void updateInOutStateByDate(String targetDt, List<Long> patIdList) {
    // 指定日 または (指定日-1日)の入外情報登録があるデータを全件取得
    String befTargetDt = DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDate.parse(targetDt, DateTimeFormatter.ofPattern("uuuuMMdd")).minusDays(1));
    List<PatInOutUpdateInfo> moveInOutInfoYesterday = patUniqueDao.selectInOutUpdateInfo(befTargetDt, patIdList);
    List<PatInOutUpdateInfo> moveInOutInfoToday = patUniqueDao.selectInOutUpdateInfo(targetDt, patIdList);

    // 未来予定の検索開始日は本日基点
    String today = DateTimeFormatter.ofPattern("uuuuMMdd").format(LocalDateTime.now());

    List<String> moveInOutListYesterday = new ArrayList<String>();
    List<String> moveInOutListToday = new ArrayList<String>();
      // 一時転出期間が終了する患者の転入出情報を更新
      patMainDao.updateMoveInOutInfoTempMoveOutBack(befTargetDt, today, patIdList);

      // 患者基本情報(pat_main)の転入出情報(in_out_current_state、in_out_plan_state、in_out_plan_date)更新
      moveInOutListYesterday.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_MOVING_OUT);
      moveInOutListYesterday.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_WITHDRAWAL);
      moveInOutListYesterday.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_IMPLANTATION);
      moveInOutListYesterday.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_TEMPORARILY_MOVING_OUT);
      patMainDao.updateMoveInOutInfo(befTargetDt, today, patIdList, moveInOutListYesterday);

      moveInOutListToday.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_INTRODUCTION);
      moveInOutListToday.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_MOVE_IN);
      moveInOutListToday.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_HOSPITALIZATION);
      moveInOutListToday.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_DISCHARGE);
      moveInOutListToday.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_OUTPATIENT);
      moveInOutListToday.add(InOutVisitHistoryInfoMoveInOut.MOVE_IN_OUT_CLASS_REJECTION_UNKNOWN);
      patMainDao.updateMoveInOutInfo(targetDt, today, patIdList, moveInOutListToday);

    // 入外区分(pat_personal_main.in_out_class)更新
    // 入外区分を"－"にするデータを集計
    // 昨日分の転入出履歴(転出・離脱・移植のみ、一時転出は更新対象外(in_out is not null条件で弾いてある))
    List<Long> patIdListAbsrence =
      moveInOutInfoYesterday.stream()
      .filter(d->PatInfoInOutClass.IN_OUT_CLASS_ABSRENCE.equals(d.getInOut()))
      .filter(d-> moveInOutListYesterday.contains(d.getMoveInOut()))
      .map(d->d.getPatId())
      .collect(Collectors.toList());
    // 本日分の転入出履歴(通院拒否・不明)
    moveInOutInfoToday.stream()
      .filter(d->PatInfoInOutClass.IN_OUT_CLASS_ABSRENCE.equals(d.getInOut()))
      .forEach(d->patIdListAbsrence.add(d.getPatId()));

    // 入外区分を"外来"にするデータを集計
    List<Long> patIdListOutpatient =
      moveInOutInfoToday.stream()
      .filter(d->PatInfoInOutClass.IN_OUT_CLASS_OUTPATIENT.equals(d.getInOut()))
      .map(d->d.getPatId())
      .collect(Collectors.toList());

    // 入外区分を"入院"に更新するデータを集計
    List<Long> patIdListHospitalization =
        moveInOutInfoToday.stream()
        .filter(d->PatInfoInOutClass.IN_OUT_CLASS_HOSPITALIZATION.equals(d.getInOut()))
        .map(d->d.getPatId())
        .collect(Collectors.toList());

    // 入外区分を"－"に一括更新
    if (patIdListAbsrence.size() > 0) {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_personal_main";
      // SQL検索条件
      String inStr = getInStr("pat_id in ", patIdListAbsrence);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(inStr + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patPersonalMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End
      // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　start
      //del 6785入外・転出歴が存在する状態で入外区分を「不明：－」にできない 赵 start
      int updateCount = patPersonalMainDao.updateInOutClass(patIdListAbsrence, Integer.parseInt(PatInfoInOutClass.IN_OUT_CLASS_ABSRENCE));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
       logCommon.updateLog();
      }
      //del 6785入外・転出歴が存在する状態で入外区分を「不明：－」にできない 赵 end
      // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　end
      // DB更新ログ出力ロジック wangzuo End
    }

    // 入外区分を"外来"に一括更新
    if (patIdListOutpatient.size() > 0) {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_personal_main";
      // SQL検索条件
      String inStr = getInStr("pat_id in ", patIdListOutpatient);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(inStr + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patPersonalMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End
      // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　start
//del 6785入外・転出歴が存在する状態で入外区分を「不明：－」にできない 赵 start
      int updateCount = patPersonalMainDao.updateInOutClass(patIdListOutpatient, Integer.parseInt(PatInfoInOutClass.IN_OUT_CLASS_OUTPATIENT));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　end
      // DB更新ログ出力ロジック wangzuo End
//del 6785入外・転出歴が存在する状態で入外区分を「不明：－」にできない 赵 end
    }

    // 入外区分を"入院"に一括更新
    if (patIdListHospitalization.size() > 0) {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_personal_main";
      // SQL検索条件
      String inStr = getInStr("pat_id in ", patIdListHospitalization);
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(inStr + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patPersonalMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End
      // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　start
//del 6785入外・転出歴が存在する状態で入外区分を「不明：－」にできない 赵 start
      int updateCount = patPersonalMainDao.updateInOutClass(patIdListHospitalization, Integer.parseInt(PatInfoInOutClass.IN_OUT_CLASS_HOSPITALIZATION));

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End
      // add 6625【ST試験】【S12_患者の既往・転入履歴】患者情報：患者状態が変更された場合、ページ頭部状態は変更されない zhou　end
//del 6785入外・転出歴が存在する状態で入外区分を「不明：－」にできない 赵 end
    }
  }

// add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe start
  public void insertPatMainHistorybyIDList(List<String> patIdList) {
    try {
      if (MongoHealthCheckService.getMongoDBConnected()) {
        Query queryHistory = new Query();
        queryHistory.addCriteria(Criteria.where("pat_id").in(patIdList));
        queryHistory.addCriteria(Criteria.where("latest_flag").is("on"));
        queryHistory.addCriteria(Criteria.where("is_del").is("0"));
        List<PatMainHistory> patMainHistories = mongoTemplate.find(queryHistory, PatMainHistory.class);

        List<PatMainHistory> patMainHistoryList = new ArrayList<>();
        for(PatMainHistory patMainHistory : patMainHistories){
//          Timestamp now = new Timestamp(new Date().getTime());
//          patMainHistory.setIns_date(now);
//          patMainHistory.setLatest_flag("on");
          LocalDateTime currentTime = LocalDateTime.now();
          DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
//          patMainHistory.setUp_date(currentTime.format(formatter));

          Long patId = Long.parseLong(patMainHistory.getPat_id());
          Map<String, Object> map = patMainDao.selectInOutState(patMainHistory.getFacility_cd(), patId);
//          if(map.get("in_out_current_state") != null) {
//            patMainHistory.setIn_out_current_state(map.get("in_out_current_state").toString());
//          }else{
//            patMainHistory.setIn_out_current_state(null);
//          }
//          if(map.get("in_out_plan_state") != null) {
//            patMainHistory.setIn_out_plan_state(map.get("in_out_plan_state").toString());
//          }else{
//            patMainHistory.setIn_out_plan_state(null);
//          }
//          if(map.get("in_out_plan_date") != null) {
//            patMainHistory.setIn_out_plan_date((Date)map.get("in_out_plan_date"));
//          }else{
//            patMainHistory.setIn_out_plan_date(null);
//          }
//
//          patMainHistoryList.add(patMainHistory);

          Query query = new Query();
          Update update = new Update();
          query.addCriteria(Criteria.where("pat_id").is(patMainHistory.getPat_id()));
          query.addCriteria(Criteria.where("latest_flag").is("on"));
          query.addCriteria(Criteria.where("is_del").is("0"));

          update.set("up_date", currentTime.format(formatter));
          // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
//          if(map.get("in_out_current_state") != null) {
          if(map != null && map.get("in_out_current_state") != null) {
            update.set("in_out_current_state", map.get("in_out_current_state").toString());
          }else{
            update.set("in_out_current_state", null);
          }
//          if(map.get("in_out_plan_state") != null) {
          if(map != null && map.get("in_out_plan_state") != null) {
            update.set("in_out_plan_state", map.get("in_out_plan_state").toString());
          }else{
            update.set("in_out_plan_state", null);
          }
//          if(map.get("in_out_plan_date") != null) {
          if(map != null && map.get("in_out_plan_date") != null) {
            // mod #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end
            update.set("in_out_plan_date", (Date)map.get("in_out_plan_date"));
          }else{
            update.set("in_out_plan_date", null);
          }

          mongoTemplate.updateMulti(query, update, PatMainHistory.class);
        }
//        Query query = new Query();
//        Update update = new Update();
//        query.addCriteria(Criteria.where("pat_id").in(patIdList));
//        query.addCriteria(Criteria.where("latest_flag").ne("off"));
//        update.set("latest_flag", "off");
//        mongoTemplate.updateMulti(query, update, PatMainHistory.class);

//        if(patMainHistoryList.size() > 0) mongoTemplate.insertAll(patMainHistoryList);
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
  }

  public JSONArray getJSONArray(String json) {
    JSONArray jsonArray = new JSONArray();
    if (json != null) {
      jsonArray = new JSONArray(json);
    }
    return jsonArray;
  }
// add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 limingzhe end

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.NTSS_WEB_API + "," + LoggingConstant.SERVICE_NAME.REMS);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }

  /**
   * 検索条件 IN情報
   *
   * @param fieldInfo カラム情報
   * @param inList    IN値リスト
   * @return inStr
   */
  public <T> String getInStr(String fieldInfo, List<T> inList) {
    StringBuffer inStr = new StringBuffer("");
    inStr.append(fieldInfo);
    inStr.append(" ( ");
    for (T obj : inList) {
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
  // DB更新ログ出力ロジック wangzuo End
}
