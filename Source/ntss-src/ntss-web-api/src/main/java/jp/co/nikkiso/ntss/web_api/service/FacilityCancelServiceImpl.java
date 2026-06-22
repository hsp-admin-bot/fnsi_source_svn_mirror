package jp.co.nikkiso.ntss.web_api.service;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import org.apache.commons.collections4.CollectionUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FlagType;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntFacilityCancelManageDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.PatNameIdentificationDao;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelManage;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelStat;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.config.FacilityCancelConfig;
import jp.co.nikkiso.ntss.web_api.service.component.FacilityBackupComponent;
import jp.co.nikkiso.ntss.web_api.service.component.FacilityDeleteComponent;
import jp.co.nikkiso.ntss.web_api.service.component.ProcStatusComponent;
import jp.co.nikkiso.ntss.web_api.service.component.SubTransactionComponent;
import jp.co.nikkiso.ntss.web_api.service.component.TargetTableComponent;
import jp.co.nikkiso.ntss.web_api.util.ClockWrapper;
import jp.co.nikkiso.ntss.web_api.util.ErrorMessageUtil;
import jp.co.nikkiso.ntss.web_api.util.FacilityCancelStatUtil;

import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.DB_KIND_AUTH;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.DB_KIND_DEFAULT;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.IS_DEL_OFF;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.IS_DISP_INIT;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.MILLIS_IN_MINUTE;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_FNSI_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_CLASS_REMS_CANCEL;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_BACKUP_COMPLETED;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_BACKUP_IN_PROGRESS;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_CANCELED;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_COMPLETED;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_DELETING;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_ERROR;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_WAITING;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_BACKUP_PATH;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.STAT_KEY_TABLE_NAME;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_FACILITY_HASH;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_MACHINE;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_PAT_HASH;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.TABLE_NAME_MST_USER_AUTHENTICATION;

/**
 * 施設解約サービス実装クラス。
 */
@Service
public class FacilityCancelServiceImpl implements FacilityCancelService {
  // DAO
  /** 解約施設管理 */
  @Autowired
  private MntFacilityCancelManageDao mntFacilityCancelManageDao;
  /** 施設マスタ */
  @Autowired
  private MstFacilityDao mstFacilityDao;
  /** 名寄せ */
  @Autowired
  private PatNameIdentificationDao patNameIdentificationDao;

  // 機能部品
  /** バックアップ処理 */
  @Autowired
  private FacilityBackupComponent facilityBackupComponent;

  /** レコード削除処理 */
  @Autowired
  private FacilityDeleteComponent facilityDeleteComponent;

  /** トランザクション管理を伴う処理 */
  @Autowired
  private SubTransactionComponent subTransactionComponent;

  /** 処理ステータス更新 */
  @Autowired
  private ProcStatusComponent procStatusComponent;

  /** 対象テーブルの取得 */
  @Autowired
  private TargetTableComponent targetTableCancelComponent;

  // 設定
  /** sys_system_define */
  @Autowired
  private FacilityCancelConfig config;

  // サービス
  /** ログサービス */
  @Autowired
  private LogService logService;

  /** システム日付ラッパ */
  @Autowired
  private ClockWrapper clockWrapper;

  /**
   * 施設解約を登録する。
   *
   * @param facilityCd 施設コード
   * @param baseDate 解約基準日
   * @see jp.co.nikkiso.ntss.web_api.service.FacilityCancelManageService#registerCancel(java.lang.String)
   */
  @Override
  @Transactional(noRollbackFor = { NtssException.class })
  public void register(String facilityCd, String baseDate, String procClass) {
    // トランザクション管理方針:
    // ・noRollbackFor = { NtssException.class } （ServiceImplクラスのみ）
    // アプリケーション例外（NtssException）を発生させる場合、トランザクションがreadOnlyに変更されるのを防止する。
    // （Springトランザクション管理のデフォルトでは、RuntimeExceptionが発生するとreadOnlyに変更される。
    // Spring Boot/JUnitではアプリケーション外でコミット操作があり、readOnlyの場合はUnexpectedRollbackExceptionが発生する。）

    // 同一施設コードで有効な管理レコードが存在する場合
    // 重複登録は認めず、エラーとする。
    MntFacilityCancelManage existing = mntFacilityCancelManageDao.selectByFacilityCd(facilityCd, PROC_CLASS_CANCEL);
    if (existing != null) {
      // mod bug 7923 修正 chen start
      mntFacilityCancelManageDao.deleteById(existing.getCtlNo());
      // String msg = String.format("指定された施設コードはすでに解約登録されています。 施設コード:[%s]", facilityCd);
      // debugLog(facilityCd, msg);
      // throw new NtssException(msg);
      // mod bug 7923 修正 chen end
    }

    Timestamp stDate = convertStringToTimestamp(baseDate);
    if (stDate == null) {
      String msg = String.format("解約基準日の変換に失敗しました。 解約基準日:[%s]", baseDate);
      debugLog(facilityCd, msg);
      throw new NtssException(msg);
    }

    // 施設解約管理レコードを登録する。
    MntFacilityCancelManage mfcm = new MntFacilityCancelManage();
    mfcm.setFacilityCd(facilityCd);
    mfcm.setProcClass(procClass);
    mfcm.setProcPeriod(null);
    mfcm.setStDate(stDate);
    mfcm.setStats(createInitStats(facilityCd, procClass));
    if (PROC_CLASS_CANCEL.equals(procClass) || PROC_CLASS_FNSI_CANCEL.equals(procClass)) {
      // 全解約、FNSiのみ解約の場合はmongoデータ(ind_history)も削除対象
      mfcm.setStatsNosql("[{\"table_name\":\"ind_history\" }]");
    } else {
      mfcm.setStatsNosql("[]");
    }
    mfcm.setProcStatus(PROC_STATUS_WAITING);
    mfcm.setIsDisp(IS_DISP_INIT);
    mfcm.setIsDel(IS_DEL_OFF);

    try {
      subTransactionComponent.insert(mfcm);

    } catch (Exception e) {
      errorLog(facilityCd, "施設解約の登録でDBエラーが発生しました。", e);
      throw new NtssException(e);
    }
  }

  /**
   * 解約処理対象のテーブルを取得する。
   *
   * @param facilityCd 施設コード
   * @return 解約処理対象を示すJSON文字列
   */
  private String createInitStats(String facilityCd, String procClass) {
    // このメソッドはカーソルを使用しないPostgreSQLデータディクショナリのSELECTのみであるので、
    // 明示的にトランザクションは発行しない。

    try {
      List<MntFacilityCancelStat> allTableList = targetTableCancelComponent.getTargetTableList(facilityCd, procClass);
      return ObjectMapperUtil.write(allTableList);
    } catch (Exception e) {
      String errMsg = String.format("DBエラーが発生しました。 施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg, e);
    }
  }

  /**
   * 削除対象レコードのバックアップを作成する。
   *
   * @param expiration 実行時間上限（単位=分）
   * @see jp.co.nikkiso.ntss.web_api.service.FacilityCancelService#backup(java.lang.Long)
   */
  @Override
  @Transactional(noRollbackFor = { NtssException.class })
  public void backup(Long expiration) {

    // 解約処理終了期限
    // 未指定の場合はデフォルト値を使用する。
    expiration = expiration == null ? config.getExpiration() : expiration;
    Long startTime = clockWrapper.getClockMillis();
    Long endTime = startTime + expiration * MILLIS_IN_MINUTE;


    // 解約対象施設を取得する。
    // (処理ステータス = 処理待機 or バックアップ作成中))
    List<MntFacilityCancelManage> facilityList = subTransactionComponent.getTargetFacilityList(
        Arrays.asList(PROC_CLASS_CANCEL, PROC_CLASS_REMS_CANCEL, PROC_CLASS_FNSI_CANCEL),
        PROC_STATUS_WAITING, PROC_STATUS_BACKUP_IN_PROGRESS);
    if (CollectionUtils.isEmpty(facilityList)) {
      // 対象施設なし。
      infoLog(null, "バックアップ処理対象レコードが存在しませんでした");
      return;
    }

    for (MntFacilityCancelManage facility : facilityList) {
      boolean isCompleted = facilityBackupComponent.backupFacility(facility, startTime, endTime);

      // 施設単位の解約の途中で終了期限を過ぎた場合
      // 途中で終了する。（次回の実行でバックアップが続行される。）
      if (!isCompleted) {
        break;
      }
    }
  }
  /**
   * 削除対象レコードのバックアップを作成する。
   *
   * @param expiration 実行時間上限（単位=分）
   * @see jp.co.nikkiso.ntss.web_api.service.FacilityCancelService#backup(java.lang.Long)
   */
  @Override
  @Transactional(noRollbackFor = { NtssException.class })
  public void backup(Long expiration, LocalTime startTimeC, LocalTime endTimeC) {

    // 解約処理終了期限
    // 未指定の場合はデフォルト値を使用する。
    expiration = expiration == null ? config.getExpiration() : expiration;
    Long startTime = clockWrapper.getClockMillis();
    Long endTime = startTime + expiration * MILLIS_IN_MINUTE;


    // 解約対象施設を取得する。
    // (処理ステータス = 処理待機 or バックアップ作成中))
    List<MntFacilityCancelManage> facilityList = subTransactionComponent.getTargetFacilityList(
      Arrays.asList(PROC_CLASS_CANCEL, PROC_CLASS_REMS_CANCEL, PROC_CLASS_FNSI_CANCEL),
      PROC_STATUS_WAITING, PROC_STATUS_BACKUP_IN_PROGRESS);
    if (CollectionUtils.isEmpty(facilityList)) {
      // 対象施設なし。
      infoLog(null, "バックアップ処理対象レコードが存在しませんでした");
      return;
    }

    for (MntFacilityCancelManage facility : facilityList) {
      //add 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 start
      if (LocalTime.now().isBefore(startTimeC) || LocalTime.now().plusMinutes(10).isAfter(endTimeC)) {
        break;
      }
      //add 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 end
      boolean isCompleted = facilityBackupComponent.backupFacility(facility, startTime, endTime);

      // 施設単位の解約の途中で終了期限を過ぎた場合
      // 途中で終了する。（次回の実行でバックアップが続行される。）
      if (!isCompleted) {
        break;
      }
    }
  }

  /**
   * 施設解約を実行する。
   *
   * @param expiration 実行時間上限（単位=分）
   * @see jp.co.nikkiso.ntss.web_api.service.FacilityCancelManageService#executeCancel(boolean, java.lang.Long)
   */
  @Override
  @Transactional(noRollbackFor = { NtssException.class })
  public void execute(Long expiration) {
    // 解約処理終了期限
    // 未指定の場合はデフォルト値を使用する。
    expiration = expiration == null ? config.getExpiration() : expiration;
    Long endTime = clockWrapper.getClockMillis() + expiration * MILLIS_IN_MINUTE;

    // 解約対象施設を取得する。
    // (処理ステータス=バックアップ済 or 処理中(delete))
    List<MntFacilityCancelManage> facilityList = subTransactionComponent.getTargetFacilityList(
        Arrays.asList(PROC_CLASS_CANCEL, PROC_CLASS_REMS_CANCEL, PROC_CLASS_FNSI_CANCEL),
        PROC_STATUS_BACKUP_COMPLETED, PROC_STATUS_DELETING);

    // 施設解約の対象施設が存在しない場合
    if (CollectionUtils.isEmpty(facilityList)) {
      infoLog(null, "施設解約対象レコードが存在しませんでした");
      return;
    }

    // 削除優先順のテーブル定義を取得
    List<Map<String, Object>> priorityTableList = config.getPriorityTableList();

    // 施設コードが別名で定義されているテーブル定義を取得
    List<Map<String, Object>> includeTableList = config.getIncludeTableList();

    for (MntFacilityCancelManage facility : facilityList) {
      boolean isCompleted = facilityDeleteComponent.deleteFacility(facility, endTime, priorityTableList, includeTableList);
      // 施設単位の解約の途中で終了期限を過ぎた場合
      // 途中で終了する。（次回の実行で解約される。）
      if (!isCompleted) {
        break;
      }
    }
  }
  /**
   * 施設解約を実行する。
   *
   * @param expiration 実行時間上限（単位=分）
   * @see jp.co.nikkiso.ntss.web_api.service.FacilityCancelManageService#executeCancel(boolean, java.lang.Long)
   */
  @Override
  @Transactional(noRollbackFor = { NtssException.class })
  public void execute(Long expiration,LocalTime startTimeC, LocalTime endTimeC) {
    // 解約処理終了期限
    // 未指定の場合はデフォルト値を使用する。
    expiration = expiration == null ? config.getExpiration() : expiration;
    Long endTime = clockWrapper.getClockMillis() + expiration * MILLIS_IN_MINUTE;

    // 解約対象施設を取得する。
    // (処理ステータス=バックアップ済 or 処理中(delete))
    List<MntFacilityCancelManage> facilityList = subTransactionComponent.getTargetFacilityList(
      Arrays.asList(PROC_CLASS_CANCEL, PROC_CLASS_REMS_CANCEL, PROC_CLASS_FNSI_CANCEL),
      PROC_STATUS_BACKUP_COMPLETED, PROC_STATUS_DELETING);

    // 施設解約の対象施設が存在しない場合
    if (CollectionUtils.isEmpty(facilityList)) {
      infoLog(null, "施設解約対象レコードが存在しませんでした");
      return;
    }

    // 削除優先順のテーブル定義を取得
    List<Map<String, Object>> priorityTableList = config.getPriorityTableList();

    // 施設コードが別名で定義されているテーブル定義を取得
    List<Map<String, Object>> includeTableList = config.getIncludeTableList();

    for (MntFacilityCancelManage facility : facilityList) {
      //add 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 start
      if (LocalTime.now().isBefore(startTimeC) || LocalTime.now().plusMinutes(10).isAfter(endTimeC)) {
        break;
      }
      //add 8008日次処理のスケジュール自動延長がされない患者が存在する。 赵 end
      boolean isCompleted = facilityDeleteComponent.deleteFacility(facility, endTime, priorityTableList, includeTableList);

      // 施設単位の解約の途中で終了期限を過ぎた場合
      // 途中で終了する。（次回の実行で解約される。）
      if (!isCompleted) {
        break;
      }
    }
  }

  /**
   * 解約処理ステータス更新。
   *
   * @param facilityCd 施設コード
   * @see jp.co.nikkiso.ntss.web_api.service.FacilityCancelManageService#updateCancelStatus(java.lang.Long)
   */
  @Override
  @Transactional(noRollbackFor = { NtssException.class })
  public void updateStatus(String facilityCd, String procClass) {
    // 施設コードから管理番号を取得
    // 存在しない場合、エラーとする
    MntFacilityCancelManage mfcm = mntFacilityCancelManageDao.selectByFacilityCd(facilityCd, procClass);
    if (mfcm == null) {
      String errMsg = String.format("指定された施設コードの管理レコードは存在しません。 施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg);
    }

    // ステータスチェック
    if (!PROC_STATUS_WAITING.equals(mfcm.getProcStatus()) && !PROC_STATUS_ERROR.equals(mfcm.getProcStatus())) {
      // 未処理、エラー以外はキャンセルを禁止する
      String errMsg = String.format("解約処理が実行済のためキャンセルできません。施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg);
    }

    // ステータスをキャンセルに更新
    procStatusComponent.updateProcStatus(mfcm.getCtlNo(), PROC_STATUS_CANCELED);
  }

  /**
   * ログイン無効化の更新<br/>
   * 処理開始日を迎えた施設コードのログイン無効化を行うため、指定テーブルのデータを削除する
   */
  @Override
  @Transactional
  public void disableLogin() {

    // 解約対象施設を取得する。
    // (処理ステータス = 処理待機))
    List<MntFacilityCancelManage> facilityList = subTransactionComponent.getTargetFacilityList(
        Arrays.asList(PROC_CLASS_CANCEL, PROC_CLASS_REMS_CANCEL, PROC_CLASS_FNSI_CANCEL),
        PROC_STATUS_WAITING);
    if (CollectionUtils.isEmpty(facilityList)) {
      debugLog(null, "ログイン無効化の対象施設コードなし");
      return;
    }

    for (MntFacilityCancelManage mfcm : facilityList) {
      String facilityCd = (String) mfcm.getFacilityCd();
      String statsStr = mfcm.getStats();
      List<Map<String, Object>> statsList = null;
      try {
        statsList = ObjectMapperUtil.readListOfMap(statsStr);
      } catch (IOException e) {
        throw new NtssException("統計情報がJSON文字列として不正です。", e);
      }

      // 解約対象施設
      List<String> facilityCdList = new ArrayList<String>();
      // 処理区分によってログイン無効化処理をわける
      switch (mfcm.getProcClass()) {
        case PROC_CLASS_CANCEL:
          // 全解約
          // 患者情報共有解除
          facilityCdList.add(facilityCd);
          cancelSharePatientInfo(facilityCdList);

          // バックアップ作成
          // 利用者マスタ(DB4)
          Map<String, Object> muaStat = FacilityCancelStatUtil.findStat(statsList, DB_KIND_AUTH, TABLE_NAME_MST_USER_AUTHENTICATION);
          subTransactionComponent.backupTableRecord(facilityCd, PROC_CLASS_CANCEL, muaStat, mfcm.getStDate().getTime(), mfcm.getStDate().getTime());
          // 施設マスタハッシュ
          Map<String, Object> mfhStat = FacilityCancelStatUtil.findStat(statsList, DB_KIND_AUTH, TABLE_NAME_MST_FACILITY_HASH);
          subTransactionComponent.backupTableRecord(facilityCd, PROC_CLASS_CANCEL, mfhStat, mfcm.getStDate().getTime(), mfcm.getStDate().getTime());
          // 患者用施設マスタハッシュ
          Map<String, Object> mphStat = FacilityCancelStatUtil.findStat(statsList, DB_KIND_AUTH, TABLE_NAME_MST_PAT_HASH);
          subTransactionComponent.backupTableRecord(facilityCd, PROC_CLASS_CANCEL, mphStat, mfcm.getStDate().getTime(), mfcm.getStDate().getTime());
          // 装置マスタ
          Map<String, Object> mmStat = FacilityCancelStatUtil.findStat(statsList, DB_KIND_DEFAULT, TABLE_NAME_MST_MACHINE);
          subTransactionComponent.backupTableRecord(facilityCd, PROC_CLASS_CANCEL, mmStat, mfcm.getStDate().getTime(), mfcm.getStDate().getTime());

          // 無効化更新
          subTransactionComponent.invalidateFacility(facilityCd, statsList);

          // マスタ同期処理
          if (false == subTransactionComponent.synchroMstMachine(facilityCd)) {
            // 対象施設のデバイスエッジマスタ同期に失敗した場合はメッセージ出力
            String msg = String.format("ログイン無効化処理内のマスタ同期処理に失敗しました。施設コード:[%s]", facilityCd);
            errorLog(null, msg, new Exception());
          }

          // IFエッジ停止
          subTransactionComponent.stopIfEdge(facilityCd);
          break;
        case PROC_CLASS_REMS_CANCEL:
          // ReMSのみ解約
          // システム利用設定更新
          subTransactionComponent.updSystemUseSetting(facilityCd, mfcm.getProcClass());
          break;
        case PROC_CLASS_FNSI_CANCEL:
          // FNSiのみ解約
          // システム利用設定更新
          subTransactionComponent.updSystemUseSetting(facilityCd, mfcm.getProcClass());

          // 患者情報共有解除
          facilityCdList.add(facilityCd);
          cancelSharePatientInfo(facilityCdList);

          // IFエッジ停止
          subTransactionComponent.stopIfEdge(facilityCd);
          break;
        default:
          break;
      }

      // バックアップと削除結果の更新を行う
      // ※処理開始済とするため、ステータスはバックアップ作成中とする
      procStatusComponent.updateProcStatus(mfcm.getCtlNo(), PROC_STATUS_BACKUP_IN_PROGRESS, statsList);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public byte[] getBackupData(String facilityCd, String baseDate, String procClass) {

    MntFacilityCancelManage mntFacilityCancelManage = mntFacilityCancelManageDao.selectByDownloadRequirement(facilityCd, baseDate, procClass);

    if (mntFacilityCancelManage == null) {
      return null;
    }

    List<Map<String, Object>> statsList = null;
    try {
      statsList = ObjectMapperUtil.readListOfMap(mntFacilityCancelManage.getStats());
    } catch (IOException e) {
      throw new NtssException("統計情報がJSON文字列として不正です。", e);
    }

    List<Map<String, Object>> statsNosqlList = null;
    try {
      statsNosqlList = ObjectMapperUtil.readListOfMap(mntFacilityCancelManage.getStatsNosql());
    } catch (IOException e) {
      throw new NtssException("統計情報(NoSQLDB)がJSON文字列として不正です。", e);
    }

    ZipOutputStream zipOutputStream = null;
    ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
    zipOutputStream = new ZipOutputStream(new BufferedOutputStream(byteArrayOutputStream));
    try {
      for (Map<String, Object> statsMap : statsList) {
        if (statsMap.containsKey(STAT_KEY_BACKUP_PATH)) {
          String downloadFilePath = (String)statsMap.get("backup_path");
          entryZip(downloadFilePath, zipOutputStream);
        }
      }
      for (Map<String, Object> statsNosqlMap : statsNosqlList) {
        if (statsNosqlMap.containsKey(STAT_KEY_BACKUP_PATH)) {
          String downloadFilePath = (String)statsNosqlMap.get("backup_path");
          entryZip(downloadFilePath, zipOutputStream);
        }
      }
    } catch(IOException ioe) {
      throw new NtssException("施設解約バックアップダウンロードでエラーが発生しました。", ioe);
    } finally {
      try {
        zipOutputStream.closeEntry();
        zipOutputStream.close();
      } catch(IOException ioe2) {
      }
    }

    if (byteArrayOutputStream.size() == 0) {
      return null;
    }

    return byteArrayOutputStream.toByteArray();
  }

  /**
   * 指定ファイルをZipストリームに設定する。
   *
   * @param filePath 指定ファイルパス
   * @param zipOutputStream Zipストリーム
   * @throws IOException
   */
  private void entryZip(String filePath, ZipOutputStream zipOutputStream) throws IOException {

    File downloadFile = new File(filePath);
    if (!downloadFile.exists()) {
      return;
    }

    ZipEntry entry = new ZipEntry(downloadFile.getName());
    zipOutputStream.putNextEntry(entry);

    // ZIPファイルに情報を書き込む
    InputStream inputStream = new BufferedInputStream(new FileInputStream(downloadFile));
    try {
      int len = 0;
      byte[] buf = new byte[1024];
      while ((len = inputStream.read(buf)) != -1) {
        zipOutputStream.write(buf, 0, len);
      }
    } finally {
      // ストリームを閉じる
      inputStream.close();
    }
  }

  /**
   * 基準日をTimestampへ変換
   * @param dateStri
   * @return 変換した日付(Timestamp)
   */
  private Timestamp convertStringToTimestamp(String dateStr) {

    DateFormat sdf  = new SimpleDateFormat("yyyyMMdd");
    String tmpDt = dateStr.replace("-", "").replace("/", "");
    Date date = null;
    try {
      date = sdf.parse(tmpDt);
    } catch (ParseException e) {
      return null;
    }

    sdf = new SimpleDateFormat("yyyy-MM-dd");
    String target = sdf.format(date);
    return Timestamp.valueOf(target + " " + "00:00:00");
  }


  @Override
  @Transactional(noRollbackFor = { NtssException.class })
  public void completeDeleteFacility(String facilityCd) {

    // 施設コードから解約管理情報を取得
    // 存在しない場合、エラーとする
    MntFacilityCancelManage mfcm = mntFacilityCancelManageDao.selectByFacilityCd(facilityCd, PROC_CLASS_CANCEL);
    if (mfcm == null) {
      String errMsg = String.format("指定された施設コードの管理レコードは存在しません。 施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg);
    }

    // ステータスチェック
    if (!PROC_STATUS_COMPLETED.equals(mfcm.getProcStatus())) {
      // 未処理、エラー以外はキャンセルを禁止する
      String errMsg = String.format("解約処理が完了していないため完全削除できません。施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg);
    }

    try {
      // バックアップファイルの削除
      deleteBackupFacility(mfcm);
      // 施設マスタの物理削除
      mstFacilityDao.deleteByCd(facilityCd);
      // 施設解約管理の物理削除
      mntFacilityCancelManageDao.deleteByFacilityCd(mfcm.getFacilityCd());
    } catch (Exception e) {
      String msg = String.format("システムエラーが発生したため完全削除に失敗しました。施設コード:[%s]", facilityCd);
      errorLog(null, msg, e);
      throw new NtssException(msg, e);
    }
  }

  @Override
  @Transactional(noRollbackFor = { NtssException.class })
  public void dataDeleteFacility(String facilityCd) {

    // 施設コードから解約管理情報を取得
    // 存在しない場合、エラーとする
    List<String> lstProcClass = new ArrayList<String>();
    lstProcClass.add(PROC_CLASS_FNSI_CANCEL);
    lstProcClass.add(PROC_CLASS_REMS_CANCEL);
    MntFacilityCancelManage mfcm = mntFacilityCancelManageDao.selectByFacilityCdProcClassList(facilityCd, lstProcClass);
    if (mfcm == null) {
      String errMsg = String.format("指定された施設コードの管理レコードは存在しません。 施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg);
    }

    // ステータスチェック
    if (!PROC_STATUS_COMPLETED.equals(mfcm.getProcStatus())) {
      // 未処理、エラー以外はキャンセルを禁止する
      String errMsg = String.format("解約処理が完了していないためバックアップファイル削除できません。施設コード:[%s]", facilityCd);
      throw new NtssException(errMsg);
    }

    try {
      // バックアップファイルの削除
      deleteBackupFacility(mfcm);
      // 施設解約管理の論理削除
      mfcm.setIsDisp(FlagType.FLAG_OFF);
      mntFacilityCancelManageDao.updateIsDispIsDel(mfcm);
    } catch (Exception e) {
      String msg = String.format("システムエラーが発生したためバックアップファイル削除に失敗しました。施設コード:[%s]", facilityCd);
      errorLog(null, msg, e);
      throw new NtssException(msg, e);
    }
  }

  /**
   * 施設のバックアップファイルを削除する。
   *
   * @param mfcm MntFacilityCancelManage
   */
  private void deleteBackupFacility(MntFacilityCancelManage mfcm) {

    // 統計情報の抽出
    String statsStr = mfcm.getStats();
    List<Map<String, Object>> statsListAll = null;
    try {
      statsListAll = ObjectMapperUtil.readListOfMap(statsStr);
    } catch (IOException e) {
      throw new NtssException("統計情報がJSON文字列として不正です。", e);
    }
    // 統計情報(NoSQLDB)の抽出
    String statsNosqlStr = mfcm.getStatsNosql();
    List<Map<String, Object>> statsNosqlList = null;
    try {
      statsNosqlList = ObjectMapperUtil.readListOfMap(statsNosqlStr);
    } catch (IOException e) {
      throw new NtssException("統計情報(NoSQLDB)がJSON文字列として不正です。", e);
    }

    // 統計情報分ループ処理を行う
    statsListAll.stream().forEach(stat -> {
      try {
        // 統計情報からバックアップファイルのパスを抽出する
        if (stat.containsKey(STAT_KEY_BACKUP_PATH)) {
          String backupPath = (String) stat.get(STAT_KEY_BACKUP_PATH);
          if (!backupPath.isEmpty()) {
            //バックアップファイルパスが設定されている場合、バックアップを削除する
            File backupFile = new File(backupPath);
            if (backupFile.exists()) {
              backupFile.delete();
              // 親ディレクトリの取得
              File parentFileDir = backupFile.getParentFile();
              // 親ディレクトリの中身が空になった場合、親ディレクトリを削除する
              if (parentFileDir.isDirectory() && parentFileDir.list().length == 0) {
                parentFileDir.delete();
              }
            }
          }
        }
      } catch (Exception e) {
        String msg = "バックアップファイルの削除に失敗しました。table_name[" + stat.get(STAT_KEY_TABLE_NAME).toString() +"]";
        errorLog(null, msg, e);
        throw new NtssException(msg, e);
      }
    });

    // 統計情報(NoSQLDB)分ループ処理を行う
    statsNosqlList.stream().forEach(statNosql -> {
      try {
        // 統計情報(NoSQLDB)からバックアップファイルのパスを抽出する
        if (statNosql.containsKey(STAT_KEY_BACKUP_PATH)) {
          String backupPath = (String) statNosql.get(STAT_KEY_BACKUP_PATH);
          if (!backupPath.isEmpty()) {
            //バックアップファイルパスが設定されている場合、バックアップを削除する
            File backupFile = new File(backupPath);
            if (backupFile.exists()) {
              backupFile.delete();
              // 親ディレクトリの取得
              File parentFileDir = backupFile.getParentFile();
              // 親ディレクトリの中身が空になった場合、親ディレクトリを削除する
              if (parentFileDir.isDirectory() && parentFileDir.list().length == 0) {
                parentFileDir.delete();
              }
            }
          }
        }
      } catch (Exception e) {
        String msg = "バックアップファイルの削除に失敗しました。table_name[" + statNosql.get(STAT_KEY_TABLE_NAME).toString() +"]";
        errorLog(null, msg, e);
        throw new NtssException(msg, e);
      }
    });

  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional(rollbackFor = NtssException.class)
  public void cancelSharePatientInfo(List<String> lstFacilityCd) {
    try {
      patNameIdentificationDao.updateApproveByFacilityCdSrc(lstFacilityCd, "9");
      patNameIdentificationDao.updateReceiveByFacilityCdDst(lstFacilityCd, "9");
    } catch (Exception e) {
      String msg = "患者情報共有の解除に失敗しました。対象施設コード：" + lstFacilityCd.toString() +"]";
      errorLog(null, msg, e);
      throw new NtssException(msg, e);
    }
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
   * インフォメーションログを出力する。
   *
   * @param facilityCd 施設コード
   * @param infoMsg デバッグメッセージ
   */
  private void infoLog(String facilityCd, String infoMsg) {
    EventLogMessage msg = ErrorMessageUtil.createMessage(facilityCd, infoMsg);
    logService.log(LogLevel.INFO, msg, null, SERVICE_NAME.REMS, null);
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
