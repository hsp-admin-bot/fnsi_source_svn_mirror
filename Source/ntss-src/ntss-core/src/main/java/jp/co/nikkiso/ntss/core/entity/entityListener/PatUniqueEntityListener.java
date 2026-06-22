package jp.co.nikkiso.ntss.core.entity.entityListener;

import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogEventUtil;
import org.seasar.doma.jdbc.entity.PostUpdateContext;
import org.seasar.doma.jdbc.entity.PreUpdateContext;
import org.springframework.stereotype.Component;

@Component
public class PatUniqueEntityListener extends AbstractEntityListener<PatUnique> {

  @Override
  public void preUpdate(PatUnique patUnique, PreUpdateContext<PatUnique> context) {
    super.preUpdate(patUnique, context);
  }

  @Override
  public void postUpdate(PatUnique patUnique, PostUpdateContext<PatUnique> context) {
    try {
      DataUpdateLogCommonNew logCommon = threadLocalLogCommon.get();
      if (logCommon.getHasData()) {
        logCommon.updatePatUniqueLog();
      }
      threadLocalLogCommon.remove();
    } catch (Exception e) {
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
    }
  }
}
