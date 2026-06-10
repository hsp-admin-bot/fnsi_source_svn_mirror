package jp.co.nikkiso.ntss.web_api.service.component;

import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.IS_DEL_OFF;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.IS_DEL_ON;
import static jp.co.nikkiso.ntss.web_api.util.FacilityCancelConstants.PROC_STATUS_CANCELED;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntFacilityCancelManageDao;
import jp.co.nikkiso.ntss.core.entity.MntFacilityCancelManage;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.service.LogService;

/**
 * 処理ステータスを更新するコンポーネントクラス。
 */
@Component
public class ProcStatusComponent {

  // DAO
  /** 解約施設管理 */
  @Autowired
  private MntFacilityCancelManageDao mntFacilityCancelManageDao;

  // サービス
  /** ログサービス */
  @Autowired
  private LogService logService;

  /**
   * 解約処理状況を更新する。
   *
   * @param ctlNo mnt_facility_cancel_manageの管理番号
   * @param status 処理状況
   * @return 更新件数
   */
  @Transactional(propagation = Propagation.NESTED)
  public Integer updateProcStatus(Long ctlNo, String status) {
    String isDel = PROC_STATUS_CANCELED.equals(status) ? IS_DEL_ON : IS_DEL_OFF;
    return mntFacilityCancelManageDao.updateProcStatus(ctlNo, status, isDel);
  }

  /**
   * 解約処理状況を更新する。
   *
   * @param ctlNo mnt_facility_cancel_manageの管理番号
   * @param status 処理状況
   * @param statsList 統計情報
   * @return 更新件数
   */
  @Transactional(propagation = Propagation.NESTED)
  public Integer updateProcStatus(Long ctlNo, String status, List<Map<String, Object>> statsList) {
    // 統計情報を文字列に変換する。
    // 不正な値（循環参照等）の時は空配列を表す文字列に変換する。
    String statsListStr = null;
    try {
      statsListStr = ObjectMapperUtil.write(statsList);
    } catch (IOException e) {
      warnLog("統計情報の値が不正です。", e);
      statsListStr = "[]";
    }

    MntFacilityCancelManage mfcm = new MntFacilityCancelManage();
    mfcm.setCtlNo(ctlNo);
    mfcm.setProcStatus(status);
    mfcm.setStats(statsListStr);

    String isDel = PROC_STATUS_CANCELED.equals(status) ? IS_DEL_ON : IS_DEL_OFF;
    mfcm.setIsDel(isDel);

    return mntFacilityCancelManageDao.update(mfcm);
  }

  /**
   * NoSQLDBの解約処理状況を更新する。
   *
   * @param ctlNo mnt_facility_cancel_manageの管理番号
   * @param statsNosqlList 統計情報(NoSQLDB)
   * @return 更新件数
   */
  @Transactional(propagation = Propagation.NESTED)
  public Integer updateProcStatusNosql(Long ctlNo, List<Map<String, Object>> statsNosqlList) {
    // 統計情報(NoSQLDB)を文字列に変換する。
    // 不正な値（循環参照等）の時は空配列を表す文字列に変換する。
    String statsListStr = null;
    try {
      statsListStr = ObjectMapperUtil.write(statsNosqlList);
    } catch (IOException e) {
      warnLog("統計情報(NoSQLDB)の値が不正です。", e);
      statsListStr = "[]";
    }

    MntFacilityCancelManage mfcm = new MntFacilityCancelManage();
    mfcm.setCtlNo(ctlNo);
    mfcm.setStatsNosql(statsListStr);
    return mntFacilityCancelManageDao.update(mfcm);
  }

  /**
   * 警告ログを出力する。
   *
   * @param facilityCd 施設コード
   * @param errMsg エラーメッセージ
   * @param t 例外
   */
  private void warnLog(String errMsg, Throwable t) {
    EventLogMessage elm = new EventLogMessage();
    elm.setLogMessage(errMsg);
    elm.setSupportMessage(t.toString());

    logService.log(LogLevel.WARN, elm, null, SERVICE_NAME.REMS, null);
  }
}
