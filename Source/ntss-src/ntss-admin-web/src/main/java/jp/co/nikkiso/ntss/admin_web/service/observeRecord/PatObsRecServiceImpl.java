package jp.co.nikkiso.ntss.admin_web.service.observeRecord;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.SelectHistoryUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatObsRecDao;
import jp.co.nikkiso.ntss.core.entity.PatObsRec;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainPatObsRecCombo;
import jp.co.nikkiso.ntss.core.entity.custom.PatObsRecView;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

@Service
public class PatObsRecServiceImpl implements PatObsRecService {

  @Autowired
  PatObsRecDao patObsRecDao;

  @Autowired
  OrdMainDao ordMainDao;

  // add FNSI-改修内容追加OrdMain履歴 付 start
  @Autowired
  private SelectHistoryUtils selectHistoryUtils;
  // add FNSI-改修内容追加OrdMain履歴 付 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;
  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  private LogService logService;

  /**
   * 患者観察記録コンボ用ordMainの取得
   * @param patId
   * @param treatDate
   * @param dialysisState
   * @return
   */
  public List<OrdMainPatObsRecCombo> selectPatObsRecCombo(String facilityCd, Long patId, String treatDate, Long ordNo,
      Timestamp dialysisDateFrom, Timestamp dialysisDateTo, boolean getIndTreatFlg) {
    return ordMainDao.selectPatObsRecCombo(facilityCd, patId, treatDate, ordNo, dialysisDateFrom, dialysisDateTo, getIndTreatFlg);
  }

  public List<PatObsRecView> selectByViewSpan(Long patId, Timestamp startDate, Timestamp endDate, String isDel,
      String isNewest) {
    return patObsRecDao.selectByViewSpan(patId, null, null, startDate, endDate, isDel, isNewest);
  }

  public List<PatObsRecView> selectByOrdNo(Long ordNo, String isDel, String isNewest) {
	return patObsRecDao.selectByOrdNo(ordNo, null, null, isDel, isNewest);
  }

  @Override
  public PatObsRecView selectByViewKey(Long patId, Long ctlNo) {
    return patObsRecDao.selectByViewKey(patId, ctlNo);
  }

  @Override
  public int insert(PatObsRec param) {

    return patObsRecDao.insert(param);
  }

  @Override
  public int delete(PatObsRec param) {
    return patObsRecDao.delete(param);
  }

  @Override
  @Transactional
  public int update(PatObsRec param) {
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(param,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
    int ret = patObsRecDao.update(param);

    // オーダー番号判定
    if ( param.getOrdNo() != null ) {

      // add FNSI-改修内容追加OrdMain履歴 付 start
      // mangoDb-updateIsConfirm-insertSuccess
      getHistory(param.getOrdNo());
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "ord_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" is_confirm = '1'\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      //治療情報の確定フラグが「1：確定」の場合に「0：未確定」に更新する
      int updateCount = ordMainDao.updateIsConfirm(param.getOrdNo(), "1", "0");

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End
    }

    return ret;
  }

  // add FNSI-改修内容追加OrdMain履歴 付 start
  private void getHistory(Long ordNo){
    selectHistoryUtils.insertMangoDbHistory(7, ordNo, null, new ArrayList<>(), new ArrayList<>(), null, null,
      null, null, null, new ArrayList<>(), new ArrayList<>(), null, null, null,
      new ArrayList<>(), null, null);
  }
  // add FNSI-改修内容追加OrdMain履歴 付 end

  @Override
  @Transactional
  public int insertRenew(PatObsRec param) {
    int ret = patObsRecDao.insertRenew(param);

    // オーダー番号判定
    if ( param.getOrdNo() != null ) {

      // add FNSI-改修内容追加OrdMain履歴 付 start
      // mangoDb-updateIsConfirm-insertSuccess
      getHistory(param.getOrdNo());
      // add FNSI-改修内容追加OrdMain履歴 付 end

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "ord_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" is_confirm = '1'\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      //治療情報の確定フラグが「1：確定」の場合に「0：未確定」に更新する
      int updateCount = ordMainDao.updateIsConfirm(param.getOrdNo(), "1", "0");

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End
    }

    return ret;
  }

  @Override
  public List<PatObsRec> getObsRecByBbsCtlNo(Long bbsCtlNo) {
    return patObsRecDao.selectByBbsCtlNo(bbsCtlNo);
  }
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie start
  @Override
  public PatObsRec selectByObsRecNo(Long obsRecNo) {
    return patObsRecDao.selectByCd(obsRecNo);
  }
  // #11205 -ペンテスト2－4認可制御の不備  add 20260317 zhangYingJie end

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End
}
