package jp.co.nikkiso.ntss.core.entity.entityListener;

import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogEventUtil;
import org.seasar.doma.jdbc.entity.PreInsertContext;
import org.seasar.doma.jdbc.entity.PreUpdateContext;
import org.springframework.stereotype.Component;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * mst_facility(施設マスタ)のEntityListener.
 */
@Component
public class MstFacilityEntityListener extends AbstractEntityListener<MstFacility> {


  @Override
  public void preInsert(MstFacility mstFacility, PreInsertContext<MstFacility> context) {
    LocalDateTime now = LocalDateTime.now(this.getTime());
    Timestamp currentDate = Timestamp.valueOf(now);
    mstFacility.setRegDate(currentDate);
    mstFacility.setUpDate(currentDate);
  }

  @Override
  public void preUpdate(MstFacility mstFacility, PreUpdateContext<MstFacility> context) {
    LocalDateTime now = LocalDateTime.now(this.getTime());
    Timestamp currentDate = Timestamp.valueOf(now);
    mstFacility.setUpDate(currentDate);


    try {
      DataUpdateLogCommonNew logCommon =new DataUpdateLogCommonNew();
        Boolean hasData = LogEventUtil.setLogCommon(logCommon, eventLoggerFactory, logServiceCore, baseEntityDao, mstFacility, context.getConfig());
      logCommon.setHasData(hasData);
      threadLocalLogCommon.set(logCommon);
    } catch (Exception e) {
      init();
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
    }
  }


}
