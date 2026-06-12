package jp.co.nikkiso.ntss.admin_web.service.patSearchDetail;

import java.util.List;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.dao.MstPatSearchDetailDao;
import jp.co.nikkiso.ntss.core.entity.MstPatSearchDetail;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

@Service
public class MstPatSearchDetailServiceImpl implements MstPatSearchDetailService {

    @Autowired
    MstPatSearchDetailDao mstPatSearchDetailDao;

  //DB更新ログ出力ロジック wp start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  //DB更新ログ出力ロジック wp end

    /**
     * {@inheritDoc}
     */
    @Override
    public Long create(MstPatSearchDetail mstPatSearchDetail) {
      // mod カスタム検索選択の患者が重複されてしまう  吉 start
//      Long nextSeqSearchCd = mstPatSearchDetailDao.selectNextSeqSearchCd();
//      mstPatSearchDetail.setSearchCd(nextSeqSearchCd);
//      mstPatSearchDetailDao.insert(mstPatSearchDetail);
//      return nextSeqSearchCd;
        boolean flag=true;
        List<MstPatSearchDetail> list =mstPatSearchDetailDao.selectByUserIdAndFacilityCd(mstPatSearchDetail.getUserId(), mstPatSearchDetail.getFacilityCd());
        if(null != list && list.size()>0){
          for(MstPatSearchDetail detail : list){
            if(detail.getSearchName().equals(mstPatSearchDetail.getSearchName())){
              flag=false;
            }
          }
        }
        if(flag){
          Long nextSeqSearchCd = mstPatSearchDetailDao.selectNextSeqSearchCd();
          mstPatSearchDetail.setSearchCd(nextSeqSearchCd);
          mstPatSearchDetailDao.insert(mstPatSearchDetail);
          return nextSeqSearchCd;
        }else{
          return null;
        }

      // mod カスタム検索選択の患者が重複されてしまう  吉 end
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int update(MstPatSearchDetail mstPatSearchDetail) {

      int ret = mstPatSearchDetailDao.updateBySearchCd(mstPatSearchDetail);

      return ret;
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public List<MstPatSearchDetail> get(NtssUser ntssUser) {
        return mstPatSearchDetailDao.selectByUserIdAndFacilityCd(ntssUser.getUserId(), ntssUser.getFacilityCd());
    }

    /**
     * {@inheritDoc}
     */
    @Override
    public int delete(Long searchCd) {
      //DB更新ログ出力ロジック wp start

      String mmsTbN = "mnt_motion_record";

      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" search_cd = " + searchCd  +"\n");
      // logCommon設定
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(mmsTbN, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      //DB更新ログ出力ロジック wp end
      int ret = mstPatSearchDetailDao.delete(searchCd);

      //DB更新ログ出力ロジック wp start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && ret > 0) {
        logCommon.updateLog();
      }
      //DB更新ログ出力ロジック wp

      return ret;
    }

  //DB更新ログ出力ロジック wp start

  /**
   * ログ情報設定
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
    return   eventLogMessage;
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

  //DB更新ログ出力ロジック wp end

}
