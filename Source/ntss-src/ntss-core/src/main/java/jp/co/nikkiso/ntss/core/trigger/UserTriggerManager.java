package jp.co.nikkiso.ntss.core.trigger;

import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeStateDao;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;


/**
 * Triggerの実装クラス.
 */
@Slf4j
@Component
public class UserTriggerManager {

  private static String IS_DEL_0 = "0";
  private static String IS_DEL_1 = "1";
  private static String IS_DISP_0 = "0";
  private static String IS_DISP_1 = "1";
  @Autowired
  private MntDeviceEdgeStateDao mntDeviceEdgeStateDao;


  public void triggerMstDeviceEdge(MstDeviceEdge oldMstDeviceEdge, MstDeviceEdge newMstDeviceEdge,
                                   OperateType operateType) {
    if (OperateType.DELETE.equals(operateType)) {
      mntDeviceEdgeStateDao.deleteByFacilityDeviceEdge(oldMstDeviceEdge.getFacilityCd(),
        oldMstDeviceEdge.getDeviceEdgeNo());
    } else if (OperateType.INSERT.equals(operateType)) {
      mntDeviceEdgeStateDao.insertFacilityDeviceEdge(newMstDeviceEdge.getFacilityCd(),
        newMstDeviceEdge.getDeviceEdgeNo());
    }
  }


}
