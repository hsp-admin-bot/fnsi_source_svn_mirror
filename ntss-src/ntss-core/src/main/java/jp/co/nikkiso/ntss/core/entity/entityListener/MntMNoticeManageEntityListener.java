package jp.co.nikkiso.ntss.core.entity.entityListener;

import jp.co.nikkiso.ntss.core.entity.MntMNoticeManage;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogEventUtil;
import org.seasar.doma.jdbc.entity.PreInsertContext;
import org.seasar.doma.jdbc.entity.PreUpdateContext;
import org.springframework.stereotype.Component;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * mnt_m_notice_manage(緊急発報管理)のエンティティリスナークラス.
 */
@Component
public class MntMNoticeManageEntityListener extends AbstractEntityListener<MntMNoticeManage> {


  @Override
  public void preInsert(MntMNoticeManage mntMNoticeManage, PreInsertContext<MntMNoticeManage> context) {
    LocalDateTime now = LocalDateTime.now(this.getTime());
    Timestamp currentDate = Timestamp.valueOf(now);
    mntMNoticeManage.setRegDate(currentDate);
    mntMNoticeManage.setUpDate(currentDate);
  }

  @Override
  public void preUpdate(MntMNoticeManage mntMNoticeManage, PreUpdateContext<MntMNoticeManage> context) {
    LocalDateTime now = LocalDateTime.now(this.getTime());
    Timestamp currentDate = Timestamp.valueOf(now);
    mntMNoticeManage.setUpDate(currentDate);

    // DB更新ログ出力ロジック xie Start
    try {
      DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();

      boolean hasData = LogEventUtil.setLogCommon(logCommon, eventLoggerFactory, logServiceCore, baseEntityDao, mntMNoticeManage, context.getConfig());
      logCommon.setHasData(hasData);
      threadLocalLogCommon.set(logCommon);
    } catch (Exception e) {
      this.init();
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
    }
    // DB更新ログ出力ロジック xie end
  }

}
