package jp.co.nikkiso.ntss.coop_api.service.sysCoopNo;


import jp.co.nikkiso.ntss.coop_api.utils.JournalLogUtil;
import jp.co.nikkiso.ntss.core.dao.SysCoopNoDao;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;


@Service
public class SysCoopNoServiceImpl implements SysCoopNoService {

  @Autowired
  SysCoopNoDao sysCoopNoDao;

  @Transactional
  @Override
  public void updateCurCoopOrdNo(Long curCoopOrdNo, Long sysCoopNoCtlNo, Timestamp now) {

    // DB更新ログ出力ロジック wangzuo Start
    String tableNameSys = "sys_coop_no";
    // SQL検索条件
    StringBuffer wheresSys = new StringBuffer("");
    wheresSys.append(" WHERE\n");
    wheresSys.append(" ctl_no = " + sysCoopNoCtlNo + "\n");
    // logCommon設定
    DataUpdateLogCommonNew logCommonSys = JournalLogUtil.getLogCommon(sysCoopNoDao, tableNameSys, wheresSys, JournalLogUtil.getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResultSys = logCommonSys.setInfo();
    // DB更新ログ出力ロジック wangzuo End

    //3.1.6. sys_coop_noをupdateする(対象カラム: cur_coop_ord_no )
    int updateCountSys = sysCoopNoDao.updateCurCoopOrdNo(curCoopOrdNo, sysCoopNoCtlNo, now);
    // DB更新ログ出力ロジック wangzuo Start
    // 更新後データ取得、差分あれば、log出力
    if (setResultSys && updateCountSys > 0) {
      logCommonSys.updateLog();
    }
    // DB更新ログ出力ロジック wangzuo End
  }
}
