package jp.co.nikkiso.ntss.core.entity.entityListener;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogEventUtil;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import org.seasar.doma.jdbc.entity.PostUpdateContext;
import org.springframework.stereotype.Component;

/**
 * ord_main(透析情報)のエンティティリスナークラス
 */
@Component
public class OrdMainEntityListener extends AbstractEntityListener<OrdMain> {

  /**
   * {@inheritDoc}
   */
  @Override
  public void postUpdate(OrdMain base, PostUpdateContext<OrdMain> context) {
    try {
      // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen start
      if (!base.getUpdateFlg()) {
        return;
      }
      // add #8642 「治療記録>変更履歴の内容が不正」について、対応する。 dengshen end
      DataUpdateLogCommonNew logCommon = threadLocalLogCommon.get();
      if (logCommon.getHasData()) {
//        add 8074 【デグレ】ログに誤った利用者が記録される 関 start
        if (base.getLogUserId() != null) {
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setUserId(base.getLogUserId());
          logCommon.setCommonEventLogMessage(eventLogMessage);
        }
//        add 8074 【デグレ】ログに誤った利用者が記録される 関  end
        logCommon.updateLog();
      }
      init();
    } catch (Exception e) {
      init();
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
    }
  }


}
