package jp.co.nikkiso.ntss.core.trigger;

import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeStateDao;
import jp.co.nikkiso.ntss.core.dao.MstComsvSettingDao;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;


/**
 * Triggerの実装クラス.
 */
@Slf4j
@Component
public class MstDeviceEdgeTrigger {

  @Autowired
  private MntDeviceEdgeStateDao mntDeviceEdgeStateDao;
  //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
  @Autowired
  private MstComsvSettingDao mstComsvSettingDao;
  //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される end

  public void triggerInsert(Map<String, Object> newData) {
    MstDeviceEdge mstDeviceEdge = getObjFromMap(newData);
    triggerInsert(mstDeviceEdge);
  }


  public void triggerInsert(MstDeviceEdge mstDeviceEdge) {
    triggerMstDeviceEdge(null,mstDeviceEdge,OperateType.INSERT);
  }

  public void triggerDelete(Map<String, Object> deleteDataMap) {
    MstDeviceEdge deleteData = getObjFromMap(deleteDataMap);
    triggerMstDeviceEdge(deleteData,null,OperateType.DELETE);
  }

  public void triggerDelete(MstDeviceEdge deleteEntity) {
    triggerMstDeviceEdge(deleteEntity,null,OperateType.DELETE);
  }

  public void triggerUpdate(MstDeviceEdge oldData, MstDeviceEdge newData) {
    triggerMstDeviceEdge(oldData,newData,OperateType.UPDATE);
  }
  
  private MstDeviceEdge getObjFromMap(Map<String, Object> dataMap){
    MstDeviceEdge entity = new MstDeviceEdge();
    entity.setFacilityCd( TriggerUtil.getStringValueFromMap(dataMap,"facility_cd") );
    entity.setDeviceEdgeNo( TriggerUtil.getIntegerValueFromMap(dataMap,"device_edge_no") );
    return entity;
  }

  public void triggerMstDeviceEdge(MstDeviceEdge oldMstDeviceEdge, MstDeviceEdge newMstDeviceEdge,
                                   OperateType operateType) {
    if (OperateType.DELETE.equals(operateType)) {
      mntDeviceEdgeStateDao.deleteByFacilityDeviceEdge(oldMstDeviceEdge.getFacilityCd(),
        oldMstDeviceEdge.getDeviceEdgeNo());
      //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
      mstComsvSettingDao.updateDisp(oldMstDeviceEdge.getFacilityCd(),oldMstDeviceEdge.getDeviceEdgeNo());
      //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される end
    } else if (OperateType.INSERT.equals(operateType)) {
      mntDeviceEdgeStateDao.insertFacilityDeviceEdge(newMstDeviceEdge.getFacilityCd(),
        newMstDeviceEdge.getDeviceEdgeNo());
    }
  }
 
}
