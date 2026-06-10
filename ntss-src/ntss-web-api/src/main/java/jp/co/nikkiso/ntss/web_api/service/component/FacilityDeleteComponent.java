package jp.co.nikkiso.ntss.web_api.service.component;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelManage;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.config.FacilityCancelConfig;
import jp.co.nikkiso.ntss.web_api.service.FacilityCancelService;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.service.utils.CalendarUtil;
import jp.co.nikkiso.ntss.web_api.util.ClockWrapper;
import jp.co.nikkiso.ntss.web_api.util.ErrorMessageUtil;

import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_FNSI_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_REMS_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_COMPLETED;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_DELETING;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_ERROR;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_ALIAS_COLUMN_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_AMOUNT;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_DB_CLASS;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_DB_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_DELETED;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_END;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_START;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_TABLE_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_TIME_COLUMN_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_IND_HISTORY;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_SELECTOR;

/**
 * 1施設分のレコードを削除するコンポーネント。
 */
@Component
public class FacilityDeleteComponent {

  // コンポーネント
  /** トランザクション管理を伴う処理 */
  @Autowired
  private SubTransactionComponent subTransactionComponent;

  /** 処理ステータス更新 */
  @Autowired
  private ProcStatusComponent procStatusComponent;

  // サービス
  /** ログサービス */
  @Autowired
  private LogService logService;

  /** システム日付ラッパ */
  @Autowired
  private ClockWrapper clockWrapper;

  /** 施設解約サービス */
  @Autowired
  private FacilityCancelService facilityCancelService;

  // 設定
  /** sys_system_define */
  @Autowired
  private FacilityCancelConfig config;

  /** 指示記録削除処理(MongoDB) */
  @Autowired
  private MongodbProcComponent mongodbProcComponent;

  //システム起動時のprofiles(MongoDBに接続しているなら"mongo",そうでないなら空)
//  @Value("${spring.config.activate:on-profile}")
//  private String profiles;
  @Autowired(required = false)
  MongoTemplate mongoTemplate;

  /**
   * MntFacilityCancelManageごとに施設解約を実行する。
   *
   * @param mfcm MntFacilityCancelManageエンティティ
   * @param endTime 処理終了期限
   * @param priorityTableList 削除優先順テーブルリスト
   * @param includeTableList 施設コード別名定義テーブルリスト
   * @return すべての処理を終了した場合はtrue、途中で終了期限に到達した場合はfalse
   */
  public boolean deleteFacility(MntFacilityCancelManage mfcm, Long endTime, List<Map<String, Object>> priorityTableList, List<Map<String, Object>> includeTableList) {
    // トランザクション管理が必要な処理はすべてFacilityCancelDbComponentと
    // ProcStatusComponentに分割した。
    // そのため、このメソッドではトランザクションを意識しなくて良い。

    Long ctlNo = mfcm.getCtlNo();
    String facilityCd = mfcm.getFacilityCd();

    String statsStr = mfcm.getStats();
    List<Map<String, Object>> statsList = null;

    String statsNosqlStr = mfcm.getStatsNosql();
    List<Map<String, Object>> statsNosqlList = null;

    try {
      statsList = ObjectMapperUtil.readListOfMap(statsStr);
    } catch (IOException e) {
      // JSON変換でエラーが発生した場合
      String errMsg = String.format("施設の解約処理で例外が発生しました。 施設コード:[%s]", mfcm.getFacilityCd());

      // 処理状態を「エラー」に更新する。
      procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_ERROR);
      throw new NtssException(errMsg, e);
    }

    try {
      statsNosqlList = ObjectMapperUtil.readListOfMap(statsNosqlStr);
    } catch (IOException e) {
      // JSON変換でエラーが発生した場合
      String errMsg = String.format("施設の解約処理(MongoDBレコード削除)で例外が発生しました。 施設コード:[%s]", mfcm.getFacilityCd());

      // 処理状態を「エラー」に更新する。
      procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_ERROR);
      throw new NtssException(errMsg, e);
    }

    try {
      // 処理状態を「処理中」に更新する。
      procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_DELETING);

      // 基準日から削除対象とする基準日を決める
      Long baseDate = mfcm.getStDate().getTime();
      Integer keepPeriod = mfcm.getProcPeriod();
      if (keepPeriod == null) {
        keepPeriod = 0;
      }
      Long criteriaTime = CalendarUtil.shiftMonth(baseDate, -keepPeriod);

      boolean isCompleted = true;

      // MongoDBに接続しているか判定(接続されていない場合は処理しない)
      //if(PROFILE_MONGO.equals(this.profiles)) {
      if(mongoTemplate != null) {
        // 統計情報(NoSQLDB)リストから対象テーブルの統計情報を取得
        Map<String, Object> statsNosql = getStats(statsNosqlList, TABLE_NAME_IND_HISTORY);
        // 削除済の場合は次の処理へ
        if (statsNosql != null && !statsNosql.containsKey(STAT_KEY_END)) {
          // 削除処理
          isCompleted = deleteMongodbRecord(facilityCd, statsNosql, endTime);
          // MongoDBの処理対象は1件だけなので、処理が終わり次第、状態の更新を行う
          procStatusComponent.updateProcStatusNosql(ctlNo, statsNosqlList);

          // 終了期限を過ぎた場合は終了する
          if (!isCompleted) {
            debugLog(facilityCd, "[delete_mongodb] delete process expired... table_name:" + statsNosql.get(STAT_KEY_TABLE_NAME));
            // 削除処理中の状態で現状の統計情報を更新する
            procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_DELETING, statsList);
            return false;
          }
        }
      }

      // 削除テーブルの優先順が指定されている場合
      // 優先的に削除を行う
      if (priorityTableList != null) {
        for (Map<String, Object> priority : priorityTableList) {
          String tableName = (String) priority.get(STAT_KEY_TABLE_NAME);
          // 統計情報リストから対象テーブルの統計情報を取得
          Map<String, Object> stats = getStats(statsList, tableName);
          // 削除済の場合は次のテーブルへ
          if (stats != null && !stats.containsKey(STAT_KEY_END)) {
            // 削除処理
            isCompleted = deleteTableRecord(facilityCd, stats, endTime, criteriaTime);

            // 終了期限を過ぎた場合はループを中断して終了する
            if (!isCompleted) {
              debugLog(facilityCd, "[delete_priority] delete process expired... table_name:" + stats.get(STAT_KEY_TABLE_NAME));
              // 削除処理中の状態で現状の統計情報を更新する
              procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_DELETING, statsList);
              return false;
            }
          }
        }
      }

      // 施設コード別名のカラム名リストが存在する場合
      // 優先的に削除を行う
      if (includeTableList != null) {
        for (Map<String, Object> include : includeTableList) {
          String tableName = (String) include.get(STAT_KEY_TABLE_NAME);
          String aliasColumnName = (String) include.get(STAT_KEY_ALIAS_COLUMN_NAME);
          // 統計情報リストから対象テーブルの統計情報を取得
          Map<String, Object> stats = getStatsByAliasColumnName(statsList, tableName, aliasColumnName);
          // 削除済の場合は次のテーブルへ
          if (stats != null && !stats.containsKey(STAT_KEY_END)) {
            // 削除処理
            isCompleted = deleteTableRecord(facilityCd, stats, endTime, criteriaTime);

            // 終了期限を過ぎた場合はループを中断して終了する
            if (!isCompleted) {
              debugLog(facilityCd, "[delete_priority] delete process expired... table_name:" + stats.get(STAT_KEY_TABLE_NAME));
              // 削除処理中の状態で現状の統計情報を更新する
              procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_DELETING, statsList);
              return false;
            }
          }
        }
      }

      for (Map<String, Object> stats : statsList) {
        // 削除済の場合は次のテーブルへ
        if (!stats.containsKey(STAT_KEY_END)) {
          if ( (PROC_CLASS_REMS_CANCEL.equals(mfcm.getProcClass()) || PROC_CLASS_FNSI_CANCEL.equals(mfcm.getProcClass()))
              && TABLE_NAME_MST_SELECTOR.equals((String)stats.get(STAT_KEY_TABLE_NAME))) {
            // 処理区分が「ReMSのみ解約」または「FNSiのみ」、かつ処理対象がmst_selectorの場合の削除処理
            isCompleted = deleteMstSelectorRecord(facilityCd, stats, statsList);
          } else {
            // 削除処理
            isCompleted = deleteTableRecord(facilityCd, stats, endTime, criteriaTime);
          }

          // 終了期限を過ぎた場合はループを中断して終了する。
          if (!isCompleted) {
            debugLog(facilityCd, "delete process expired... table_name:" + stats.get(STAT_KEY_TABLE_NAME));
            // 削除処理中の状態で現状の統計情報を更新する
            procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_DELETING, statsList);
            return false;
          }
        }
      }

      String msg1 = String.format("isCompleted=%s", isCompleted);
      debugLog(facilityCd, msg1);

      // 施設解約、FNSiのみ解約の場合、患者共有情報を更新する
      if (PROC_CLASS_CANCEL.equals(mfcm.getProcClass()) || PROC_CLASS_FNSI_CANCEL.equals(mfcm.getProcClass())) {
        List<String> facilityCdList = new ArrayList<String>();
        facilityCdList.add(facilityCd);
        facilityCancelService.cancelSharePatientInfo(facilityCdList);
      }

      // ReMSのみ解約、FNSiのみ解約の場合、システム利用設定を変更する
      if (PROC_CLASS_REMS_CANCEL.equals(mfcm.getProcClass()) || PROC_CLASS_FNSI_CANCEL.equals(mfcm.getProcClass())) {
        subTransactionComponent.updSystemUseSetting(facilityCd, mfcm.getProcClass());
      }

      // 統計情報を削除結果に更新する。
      // 終了期限の前に完了した場合は、処理状態を「完了」に更新する。
      procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_COMPLETED, statsList);
      return true;
    } catch (NtssException e) {
      // エラーログは発生時に出力しているので省略する。
      // ここでは処理ステータスのみエラーに更新する。
      procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_ERROR);
      throw e;
    } catch (Exception e) {
      procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_ERROR);
      String msg = "施設解約の実行でシステムエラーが発生しました。";
      errorLog(facilityCd, msg, e);
      throw new NtssException(msg, e);
    }
  }

  /**
   * 統計情報1件あたりの解約（レコード削除）を実行する。
   *
   * @param facilityCd 施設コード
   * @param stat 統計情報中の1エントリ
   * @param endTime 処理終了期限
   * @param criteriaTime 削除対象基準日時（システム時刻-処理対象期間）
   * @return すべての処理を終了した場合はtrue、途中で終了期限に到達した場合はfalse
   */
  private boolean deleteTableRecord(String facilityCd, Map<String, Object> stat, Long endTime, Long criteriaTime) {
    Integer dbClass = (Integer) stat.get(STAT_KEY_DB_CLASS);
    String dbName = (String) stat.get(STAT_KEY_DB_NAME);
    String tableName = (String) stat.get(STAT_KEY_TABLE_NAME);
    String aliasColumnName = (String) stat.get(STAT_KEY_ALIAS_COLUMN_NAME);
    String timeColumnName = (String) stat.get(STAT_KEY_TIME_COLUMN_NAME);

    String msg1 = String.format("delete table : dbName=%s, tableName=%s", dbName, tableName);
    debugLog(facilityCd, msg1);

    // テーブルごとの削除対象レコード件数、削除件数初期値（0）、テーブル削除開始時間を統計情報に設定する。
    // 削除対象レコード件数はバックアップ時に統計情報に登録されるが、正確を期するため取得しなおす。
    // （バックアップ作成後にレコードが登録された場合を考慮し、削除漏れをなくす。
    //   この場合、削除されるレコードはバックアップされていないが、操作手順が不正であるので対応しない。）
    Long amount = subTransactionComponent.getRecordCount(dbClass, tableName, facilityCd,
        aliasColumnName, timeColumnName, criteriaTime);
    stat.put(STAT_KEY_AMOUNT, amount);
    stat.put(STAT_KEY_DELETED, 0);
    stat.put(STAT_KEY_START, clockWrapper.getCurrentTimeStr());

    // 対象レコードが0件の場合は終了する。
    if (amount == 0L) {
      // 削除対象なしで、終了時刻を設定する
      stat.put(STAT_KEY_END, clockWrapper.getCurrentTimeStr());
      return true;
    }

    // 一度あたりの削除上限数を設定から取得する。
    final Integer lim = config.getMaxDeleteLimit();

    Long deletedCount = 0L;
    while (true) {

      // 処理の途中でシステム時刻が終了期限を過ぎた場合
      // 処理を中断する。ステータスは「処理中」のままとする。
      Long currentTime = clockWrapper.getClockMillis();
      if (endTime.compareTo(currentTime) < 0) {
        return false;
      }

      // 削除実行
      // テーブルあたり全レコードの削除が完了した場合、ループを終了する。
      Integer d = subTransactionComponent.delete(dbClass, tableName, facilityCd, lim,
          aliasColumnName, timeColumnName, criteriaTime);
      if (d == 0) {
        break;
      }

      // 統計情報の削除件数を更新する。
      deletedCount += d;
      stat.put(STAT_KEY_DELETED, deletedCount);

      String msg2 = String.format("delete db_name=%s, table_name=%s, amount=%s, deleted=%s",
          dbName, tableName, amount, d);
      debugLog(facilityCd, msg2);
    }

    // テーブル削除完了時間を設定する。
    stat.put(STAT_KEY_END, clockWrapper.getCurrentTimeStr());

    return true;
  }

  /**
   * 統計情報(NoSQLDB)1件あたりの解約（レコード削除）を実行する。
   *
   * @param facilityCd 施設コード
   * @param statsNosql 統計情報(NoSQLDB)中の1エントリ
   * @param endTime 処理終了期限
   * @return 終了期限内にすべての処理を終了した場合はtrue、終了期限に到達した場合はfalse
   */
  private boolean deleteMongodbRecord(String facilityCd, Map<String, Object> statsNosql, Long endTime) {
    // 削除対象レコード件数、削除件数初期値（0）、テーブル削除開始時間を統計情報(NoSQL)に設定する。
    Long amount = mongodbProcComponent.getDeleteTargetCount(facilityCd);
    statsNosql.put(STAT_KEY_AMOUNT, amount);
    statsNosql.put(STAT_KEY_DELETED, 0);
    statsNosql.put(STAT_KEY_START, clockWrapper.getCurrentTimeStr());

    // 対象レコードが0件の場合は終了する。
    if (amount == 0L) {
      // 削除対象なしで、終了時刻を設定する
      statsNosql.put(STAT_KEY_END, clockWrapper.getCurrentTimeStr());
      return true;
    }

    // 削除実行
    Long rtnAmount = mongodbProcComponent.deleteTarget(facilityCd);
    // 統計情報の削除件数を更新する。
    statsNosql.put(STAT_KEY_DELETED, rtnAmount);

    // テーブル削除完了時間を設定する。
    statsNosql.put(STAT_KEY_END, clockWrapper.getCurrentTimeStr());

    // 処理が終わった時点で、システム時刻が終了期限を過ぎた場合、続く処理を実施させないように、 false を返す。
    Long currentTime = clockWrapper.getClockMillis();
    return endTime.compareTo(currentTime) < 0 ? false : true;
  }

  /**
   * ReMSのみ解約、FNSiのみ解約指定時に、mst_selector(選択肢マスタ)の解約（レコード削除）を実行する。
   *
   * @param facilityCd 施設コード
   * @param stat mst_selectorの統計情報
   * @param statsLIst 統計情報リスト
   * @return すべての処理を終了した場合はtrue、途中で終了期限に到達した場合はfalse
   */
  private boolean deleteMstSelectorRecord(String facilityCd, Map<String, Object> stat, List<Map<String, Object>> statsList) {
    Integer dbClass = (Integer) stat.get(STAT_KEY_DB_CLASS);
    String dbName = (String) stat.get(STAT_KEY_DB_NAME);
    String tableName = (String) stat.get(STAT_KEY_TABLE_NAME);

    String msg1 = String.format("delete table : dbName=%s, tableName=%s", dbName, tableName);
    debugLog(facilityCd, msg1);

    // テーブルの削除件数初期値（0）、テーブル削除開始時間を統計情報に設定する。
    stat.put(STAT_KEY_DELETED, 0);
    stat.put(STAT_KEY_START, clockWrapper.getCurrentTimeStr());

    String strTargetMstNm = statsList.stream().map(stats -> (String)stats.get(STAT_KEY_TABLE_NAME)).collect(Collectors.joining("','"));
    strTargetMstNm = "'" + strTargetMstNm + "'";

    // 削除実行
    // テーブルあたり全レコードの削除が完了した場合、ループを終了する。
    Integer d = subTransactionComponent.deleteMstSelector(dbClass, tableName, facilityCd, strTargetMstNm);

    // 統計情報の件数・削除件数を更新する。
    stat.put(STAT_KEY_AMOUNT, d);
    stat.put(STAT_KEY_DELETED, d);

    // テーブル削除完了時間を設定する。
    stat.put(STAT_KEY_END, clockWrapper.getCurrentTimeStr());

    return true;
  }

  /**
   * 対象テーブルの統計情報を取得
   *
   * @param statsList 統計情報リスト
   * @param tableName テーブル名
   * @return 統計情報
   */
  private Map<String, Object> getStats(List<Map<String, Object>> statsList, String tableName) {
    return statsList.stream()
        .filter(s -> (tableName.equals(s.get(STAT_KEY_TABLE_NAME))))
        .findFirst().orElse(null);
  }

  /**
   * 施設コード別名のカラム名をもとに対象テーブルの統計情報を取得
   *
   * @param statsList 統計情報リスト
   * @param tableName テーブル名
   * @param aliasColumnName 施設コード別名のカラム名
   * @return 統計情報
   */
  private Map<String, Object> getStatsByAliasColumnName(List<Map<String, Object>> statsList, String tableName, String aliasColumnName) {
    return statsList.stream()
        .filter(s -> (tableName.equals(s.get(STAT_KEY_TABLE_NAME)) && aliasColumnName.equals(s.get(STAT_KEY_ALIAS_COLUMN_NAME))))
        .findFirst().orElse(null);
  }


  /**
   * エラーログを出力する。
   *
   * @param facilityCd 施設コード
   * @param errMsg エラーメッセージ
   * @param t 例外
   */
  private void errorLog(String facilityCd, String errMsg, Throwable t) {
    EventLogMessage msg = ErrorMessageUtil.createMessage(facilityCd, errMsg);
    msg.setSupportMessage(t.toString());
    logService.log(LogLevel.ERROR, msg, null, SERVICE_NAME.REMS, null);
  }

  /**
   * デバッグログを出力する。
   *
   * @param facilityCd 施設コード
   * @param debugMsg デバッグメッセージ
   */
  private void debugLog(String facilityCd, String debugMsg) {
    EventLogMessage msg = ErrorMessageUtil.createMessage(facilityCd, debugMsg);
    logService.log(LogLevel.DEBUG, msg, null, SERVICE_NAME.REMS, null);
  }
}
