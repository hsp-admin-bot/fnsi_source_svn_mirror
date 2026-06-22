package jp.co.nikkiso.ntss.web_api.service.component;

import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_IND_HISTORY;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_BACKUP_COMPLETED;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_BACKUP_IN_PROGRESS;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_REMS_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_FNSI_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_ERROR;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_AMOUNT;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_DB_CLASS;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_TABLE_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_TIME_COLUMN_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_ALIAS_COLUMN_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_BACKUP_END;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_END;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_SELECTOR;


import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelManage;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.web_api.service.utils.CalendarUtil;
import jp.co.nikkiso.ntss.web_api.util.ClockWrapper;
import jp.co.nikkiso.ntss.web_api.util.ErrorMessageUtil;

/**
 * 1施設分のバックアップを作成するコンポーネント。
 */
@Component
public class FacilityBackupComponent {

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

  //システム起動時のprofiles(MongoDBに接続しているなら"mongo",そうでないなら空)
  //@Value("${spring.config.activate:on-profile}")
  //private String profiles;
  @Autowired(required = false)
  MongoTemplate mongoTemplate;

  /**
   * 1施設分のバックアップを作成する。
   *
   * @param mfcm MntFacilityCancelManage
   * @param startTime バックアップ開始日時
   * @param endTime バックアップ終了予定日時
   * @return 全テーブルのバックアップが完了した場合はtrue、テーブルに残がある場合はfalse
   */
  public boolean backupFacility(MntFacilityCancelManage mfcm, Long startTime, Long endTime) {
    // トランザクション管理が必要な処理はすべてFacilityCancelDbComponentと
    // ProcStatusComponentに分割した。
    // そのため、このメソッドではトランザクションを意識しなくて良い。
    Long ctlNo = mfcm.getCtlNo();
    String facilityCd = mfcm.getFacilityCd();

    String statsStr = mfcm.getStats();
    List<Map<String, Object>> statsListAll = null;
    try {
      statsListAll = ObjectMapperUtil.readListOfMap(statsStr);
    } catch (IOException e) {
      throw new NtssException("統計情報がJSON文字列として不正です。", e);
    }

    // 統計情報(NoSQLDB)
    String statsNosqlStr = mfcm.getStatsNosql();
    List<Map<String, Object>> statsNosqlList = null;
    try {
      statsNosqlList = ObjectMapperUtil.readListOfMap(statsNosqlStr);
    } catch (IOException e) {
      throw new NtssException("統計情報(NoSQLDB)がJSON文字列として不正です。", e);
    }

    // 解約基準日から削除対象とする基準日を決める
    Long baseDate = mfcm.getStDate().getTime();
    Integer keepPeriod = mfcm.getProcPeriod();
    if (keepPeriod == null) {
      keepPeriod = 0;
    }
    Long criteriaTime = CalendarUtil.shiftMonth(baseDate, -keepPeriod);

    try {
      // 処理ステータスを「バックアップ作成中」に変更する。
      procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_BACKUP_IN_PROGRESS);

      // MongoDBに接続しているか判定(接続されていない場合は処理しない)
      //if(PROFILE_MONGO.equals(this.profiles)) {
      if(mongoTemplate != null) {
        // MongoDBテーブルのバックアップを作成
        Map<String, Object> statsNosql = statsNosqlList.stream()
            .filter(s -> (TABLE_NAME_IND_HISTORY.equals(s.get(STAT_KEY_TABLE_NAME))))
            .findFirst().orElse(null);
        if (statsNosql != null && !statsNosql.containsKey(STAT_KEY_BACKUP_END)) {
          subTransactionComponent.backupTableNosqlRecord(facilityCd, mfcm.getProcClass(), statsNosql, mfcm.getStDate().getTime());
          // MongoDBの処理対象は1件だけなので、処理が終わり次第、状態の更新を行う
          procStatusComponent.updateProcStatusNosql(ctlNo, statsNosqlList);
        }
      }

      // 削除対象レコードを持つテーブルのみ抽出する。
      countRecordAllTables(facilityCd, statsListAll, mfcm.getStDate().getTime());

      // 該当するテーブルが存在しない場合
      // 処理ステータスを「バックアップ作成済」に変更して終了する。
      if (CollectionUtils.isEmpty(statsListAll)) {
        // 処理ステータスを「バックアップ作成済」に変更する。
        procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_BACKUP_COMPLETED);
        return true;
      }

      // 統計情報（テーブル単位）についてループする。
      int len = statsListAll.size();
      int index = 0;
      for (Map<String, Object> stats : statsListAll) {

        ++index;

        // 処理途中で終了期限を過ぎた場合はループを中断する。
        // 処理ステータスは「バックアップ作成中」のままとする。
        // （終了期限を過ぎていても全テーブル処理済の場合は完了とする。）
        Long currentTime = clockWrapper.getClockMillis();
        if (index < len && endTime.compareTo(currentTime) < 0) {
          // 処理中の統計情報を更新する
          procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_BACKUP_IN_PROGRESS, statsListAll);
          return false;
        }

        // バックアップ作成済のため次のテーブルへ
        if (stats.containsKey(STAT_KEY_BACKUP_END)) {
          continue;
        }

        if ( (PROC_CLASS_REMS_CANCEL.equals(mfcm.getProcClass()) || PROC_CLASS_FNSI_CANCEL.equals(mfcm.getProcClass()))
            && TABLE_NAME_MST_SELECTOR.equals((String)stats.get(STAT_KEY_TABLE_NAME))) {
          // 処理区分が「ReMSのみ解約」または「FNSiのみ」、かつ処理対象がmst_selectorの場合
          subTransactionComponent.backupMstSelectorRecord(facilityCd, mfcm.getProcClass(), mfcm.getStDate().getTime(), statsListAll, stats);
        } else {
          Long count = (Long) stats.get(STAT_KEY_AMOUNT);
          if (count == 0L) {
            continue;
          }
          // 1テーブル分のバックアップを作成する。
          // （テーブル単位のバックアップ開始/終了日時の記録もこの中で行う。）
          subTransactionComponent.backupTableRecord(facilityCd, mfcm.getProcClass(), stats, mfcm.getStDate().getTime(), criteriaTime);
        }
      }

      // 処理ステータスを「バックアップ作成済」に変更する。
      procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_BACKUP_COMPLETED, statsListAll);

      // バックアップ開始/終了日の追加した統計情報を再設定
      String stats = ObjectMapperUtil.write(statsListAll);
      mfcm.setStats(stats);

      return true;
    } catch (NtssException e) {
      procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_ERROR);
      throw e;
    } catch (Exception e) {
      procStatusComponent.updateProcStatus(ctlNo, PROC_STATUS_ERROR);

      String msg = "解約施設のバックアップ作成中にシステムエラーが発生しました。";
      errorLog(null, msg, e);
      throw new NtssException(msg, e);
    }
  }

  // レコード数取得処理

  /**
   * 統計情報にテーブルのレコード数を設定する。
   *
   * @param facilityCd 施設コード
   * @param statsList 統計情報のリスト
   * @param criteriaTime 比較日時（この値より古いレコードを削除する）
   */
  private void countRecordAllTables(String facilityCd, List<Map<String, Object>> statsList, Long criteriaTime) {
    statsList.stream().forEach(s -> countRecordByTable(facilityCd, s, criteriaTime));
  }

  /**
   * 統計情報にテーブルのレコード数を設定する。
   *
   * @param facilityCd 施設コード
   * @param stat 統計情報
   * @param criteriaTime 比較日時（この値より古いレコードを削除する）
   */
  private void countRecordByTable(String facilityCd, Map<String, Object> stat, Long criteriaTime) {

    if (stat.containsKey(STAT_KEY_END)) {
      // ログイン無効化で既に削除済のレコードは結果を変更しない
      // デフォルトでint判定されることがあるのでLongに変換する
      String amount = String.valueOf(stat.get(STAT_KEY_AMOUNT));
      stat.put(STAT_KEY_AMOUNT, Long.valueOf(amount));
      return;
    }

    Integer dbClass = (Integer) stat.get(STAT_KEY_DB_CLASS);
    String tableName = (String) stat.get(STAT_KEY_TABLE_NAME);
    String aliasColumnName = (String) stat.get(STAT_KEY_ALIAS_COLUMN_NAME);
    String timeColumnName = (String) stat.get(STAT_KEY_TIME_COLUMN_NAME);

    Long count = subTransactionComponent.getRecordCount(dbClass, tableName, facilityCd,
        aliasColumnName, timeColumnName, criteriaTime);
    stat.put(STAT_KEY_AMOUNT, count);
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
}
