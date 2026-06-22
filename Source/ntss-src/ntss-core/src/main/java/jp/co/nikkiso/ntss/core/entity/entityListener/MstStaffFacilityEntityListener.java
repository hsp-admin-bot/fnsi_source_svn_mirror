package jp.co.nikkiso.ntss.core.entity.entityListener;

import jp.co.nikkiso.ntss.core.entity.MstStaffFacility;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogEventUtil;
import org.seasar.doma.jdbc.entity.PostUpdateContext;
import org.seasar.doma.jdbc.entity.PreInsertContext;
import org.springframework.stereotype.Component;

import java.sql.Timestamp;
import java.time.LocalDateTime;

/**
 * mst_staff_facility(担当者施設マスタ)のEntityListenerクラス
 */
@Component
public class MstStaffFacilityEntityListener extends AbstractEntityListener<MstStaffFacility> {


  @Override
  public void preInsert(MstStaffFacility mstStaffFacility, PreInsertContext<MstStaffFacility> context) {
    LocalDateTime now = LocalDateTime.now(this.getTime());
    Timestamp currentDate = Timestamp.valueOf(now);
    mstStaffFacility.setRegDate(currentDate);
    mstStaffFacility.setUpDate(currentDate);
  }

  @Override
  public void postUpdate(MstStaffFacility mstStaffFacility, PostUpdateContext<MstStaffFacility> context) {
    LocalDateTime now = LocalDateTime.now(this.getTime());
    Timestamp currentDate = Timestamp.valueOf(now);
    mstStaffFacility.setUpDate(currentDate);
    DataUpdateLogCommonNew logCommon = threadLocalLogCommon.get();
    try {
      if (logCommon.getHasData()) {
        logCommon.updateLog();
      }
      init();
    } catch (Exception e) {
      init();
      LogEventUtil.outputErrorLog(eventLoggerFactory, e, this.getClass().getName());
    }
  }


}
