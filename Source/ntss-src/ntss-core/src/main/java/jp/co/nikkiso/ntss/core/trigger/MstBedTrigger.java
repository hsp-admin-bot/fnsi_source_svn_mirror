package jp.co.nikkiso.ntss.core.trigger;

import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.ObjectUtils;
import org.springframework.util.StringUtils;

import java.util.List;
import java.util.Map;


/**
 * Triggerの実装クラス.
 */
@Component
public class MstBedTrigger {

  private static String IS_DEL_0 = "0";
  private static String IS_DEL_1 = "1";
  private static String IS_DISP_0 = "0";
  private static String IS_DISP_1 = "1";

  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  @Autowired
  private MstBedDao mstBedDao;

  @Autowired
  private MstMachineDao mstMachineDao;

  public void triggerInsert(Map<String, Object> newData) {
    MstBed newMstBed = getObjFromMap(newData);
    triggerMstBed(null,newMstBed,OperateType.INSERT);
  }

  public void triggerUpdate(Map<String, Object> beforeUpdateData, Map<String, Object> afterUpdateData) {
    MstBed oldMstBed = getObjFromMap(beforeUpdateData);
    MstBed newMstBed = getObjFromMap(afterUpdateData);
    triggerMstBed(oldMstBed,newMstBed,OperateType.UPDATE);
  }

  public void triggerDelete(Long bedCd) {
    mntMachineStateDao.updateBedInfoByBedCd(bedCd); // UPDATE mnt_machine_state SET bed_cd = NULL, bed_name = NULL WHERE bed_cd = OLD.bed_cd ;
  }

  private MstBed getObjFromMap(Map<String, Object> resultSet){
    MstBed mstBed = new MstBed();
    mstBed.setIsDisp( TriggerUtil.getStringValueFromMap(resultSet,"is_disp") );
    String isDel = TriggerUtil.getStringValueFromMap(resultSet,"is_del");
    if(StringUtils.isEmpty(isDel)){
      isDel = IS_DEL_0;
    }
    mstBed.setIsDel( isDel );
    Long bedCd = TriggerUtil.getLongValueFromMap(resultSet,"bed_cd");
    if(bedCd == null){
      bedCd = TriggerUtil.getLongValueFromMap(resultSet,"code");
    }
    mstBed.setBedCd( bedCd );
    String bedName = TriggerUtil.getStringValueFromMap(resultSet,"bed_name");
    if(StringUtils.isEmpty(bedName)){
      bedName = TriggerUtil.getStringValueFromMap(resultSet,"name");
    }
    mstBed.setBedName( bedName );
    mstBed.setMachineNo( TriggerUtil.getLongValueFromMap(resultSet,"machine_no") );
    return mstBed;
  }

  private void triggerMstBed(MstBed oldMstBed, MstBed newMstBed, OperateType operateType) {
    /* delete by chamaojia 2024-07-03 [10806] [operateType=DELETE] This situation does not exist --start */
//    if (OperateType.DELETE.equals(operateType)) {
//      triggerDelete(oldMstBed.getBedCd()); // 装置状態管理テーブルの装置名称をクリア
//    } else if (OperateType.INSERT.equals(operateType) || OperateType.UPDATE.equals(operateType)) {
    /* delete by chamaojia 2024-07-03 [10806] [operateType=DELETE] This situation does not exist --end */
      if (OperateType.UPDATE.equals(operateType)) { // 更新用処理(挿入用処理より先に処理する必要あり)
        MstMachine oldMstMachine = mstMachineDao.selectByMachineNo(oldMstBed.getMachineNo());
        if (IS_DEL_1.equals(newMstBed.getIsDel()) || IS_DISP_0.equals(newMstBed.getIsDisp())) {
          if (newMstBed.getMachineNo() != null) {
            mstBedDao.updateMachineNoByBedCd(newMstBed.getBedCd(), null);
            /* delete by chamaojia 2024-07-10 [10806] information should not be cleared here --start */
//            mntMachineStateDao.updateBedInfoByPk(oldMstMachine.getFacilityCd(), oldMstMachine.getMachineTypeCd(), oldMstMachine.getMachineSerial(), null, null);
            /* delete by chamaojia 2024-07-10 [10806] information should not be cleared here --end */
          }
          /* add by chamaojia 2024-07-10 [10806] clear the bed info --start */
          List<MstBed> oldBeds = mstBedDao.selectByMachineNo(oldMstBed.getMachineNo());
          if (oldBeds.isEmpty() && !ObjectUtils.isEmpty(oldMstMachine)) {
            mntMachineStateDao.updateBedInfoToClearByPk(oldMstMachine.getFacilityCd()
                    , oldMstMachine.getMachineTypeCd(), oldMstMachine.getMachineSerial());
          }
          /* add by chamaojia 2024-07-10 [10806] clear the bed info --end */
        } else if (IS_DEL_0.equals(newMstBed.getIsDel()) && IS_DISP_1.equals(newMstBed.getIsDisp())) {
          Long oldmachineNo = oldMstBed.getMachineNo() == null ? -1 : oldMstBed.getMachineNo();
          Long newmachineNo = newMstBed.getMachineNo() == null ? -1 : newMstBed.getMachineNo();
          if (!oldmachineNo.equals(newmachineNo)) {
            /* modify by chamaojia 2024-07-10 [10806] move query to upper level logic --start */
            // SELECT bed_cd, bed_name INTO old_bed_cd, old_bed_name FROM mst_bed WHERE machine_no = OLD.machine_no;
            List<MstBed> oldBeds = mstBedDao.selectByMachineNo(oldMstBed.getMachineNo());
            if (oldBeds.isEmpty() && !ObjectUtils.isEmpty(oldMstMachine)) {
              mntMachineStateDao.updateBedInfoToClearByPk(oldMstMachine.getFacilityCd()
                      , oldMstMachine.getMachineTypeCd(), oldMstMachine.getMachineSerial());
            }
            /* modify by chamaojia 2024-07-10 [10806] move query to upper level logic --end */
            if (newMstBed.getMachineNo() != null) { // 元の紐づく装置の情報をクリア
              // UPDATE mnt_machine_state SET bed_cd = old_bed_cd, bed_name = old_bed_name WHERE facility_cd = old_mst_machine_facility_cd AND machine_type_cd = old_mst_machine_type_cd AND machine_serial = old_mst_machine_serial;
//upd by ztc 2023-03-29 [No.8508 fixed NullPointerException] --start /
//              mntMachineStateDao.updateBedInfoByPk(oldMstMachine.getFacilityCd(), oldMstMachine.getMachineTypeCd(), oldMstMachine.getMachineSerial(), old_bed_cd, old_bed_name);
              /* modify by chamaojia 2024-07-03 [10806] clear the bed info --start */
//              mntMachineStateDao.updateBedInfoByPk(ObjectUtils.isEmpty(oldMstMachine) ? null : oldMstMachine.getFacilityCd(),
//                ObjectUtils.isEmpty(oldMstMachine) ? null : oldMstMachine.getMachineTypeCd(),
//                ObjectUtils.isEmpty(oldMstMachine) ? null : oldMstMachine.getMachineSerial(), old_bed_cd, old_bed_name);
              /* modify by chamaojia 2024-07-03 [10806] clear the bed info --end */
//upd by ztc 2023-03-29 [No.8508 fixed NullPointerException] --end /
//            } else { // 新たに紐づけた装置の情報で更新
              MstMachine newMstMachine = mstMachineDao.selectByMachineNo(newMstBed.getMachineNo());
              // UPDATE mnt_machine_state SET bed_cd = old_bed_cd, bed_name = old_bed_name WHERE facility_cd = old_mst_machine_facility_cd AND machine_type_cd = old_mst_machine_type_cd AND machine_serial = old_mst_machine_serial;
//upd by ztc 2023-03-29 [No.8508 fixed NullPointerException] --start /
//              mntMachineStateDao.updateBedInfoByPk(oldMstMachine.getFacilityCd(), oldMstMachine.getMachineTypeCd(), oldMstMachine.getMachineSerial(), old_bed_cd, old_bed_name);
              /* modify by chamaojia 2024-07-03 [10806] clear the bed info --start */
//              mntMachineStateDao.updateBedInfoByPk(ObjectUtils.isEmpty(oldMstMachine) ? null : oldMstMachine.getFacilityCd(),
//                ObjectUtils.isEmpty(oldMstMachine) ? null : oldMstMachine.getMachineTypeCd(),
//                ObjectUtils.isEmpty(oldMstMachine) ? null : oldMstMachine.getMachineSerial(), old_bed_cd, old_bed_name);
              /* modify by chamaojia 2024-07-03 [10806] clear the bed info --end */
//upd by ztc 2023-03-29 [No.8508 fixed NullPointerException] --end /
              // UPDATE mnt_machine_state SET bed_cd = NEW.bed_cd, bed_name = NEW.bed_name WHERE facility_cd = new_mst_machine_facility_cd AND machine_type_cd = new_mst_machine_type_cd AND machine_serial = new_mst_machine_serial ;
//upd by ztc 2023-03-29 [No.8508 fixed NullPointerException] --start /
//              mntMachineStateDao.updateBedInfoByPk(newMstMachine.getFacilityCd(), newMstMachine.getMachineTypeCd(), newMstMachine.getMachineSerial(), newMstBed.getBedCd(), newMstBed.getBedName());
              mntMachineStateDao.updateBedInfoByPk(ObjectUtils.isEmpty(newMstMachine) ? null : newMstMachine.getFacilityCd(),
                ObjectUtils.isEmpty(newMstMachine) ? null : newMstMachine.getMachineTypeCd(),
                ObjectUtils.isEmpty(newMstMachine) ? null : newMstMachine.getMachineSerial(), newMstBed.getBedCd(), newMstBed.getBedName());
//upd by ztc 2023-03-29 [No.8508 fixed NullPointerException] --end /
            }
          } else {
            String oldBedNm = oldMstBed.getBedName() == null ? "" : oldMstBed.getBedName();
            String newBedNm = newMstBed.getBedName() == null ? "" : newMstBed.getBedName();
            if (!oldBedNm.equals(newBedNm)) {
              MstMachine newMstMachine = mstMachineDao.selectByMachineNo(newMstBed.getMachineNo());
              // UPDATE mnt_machine_state SET bed_cd = NEW.bed_cd, bed_name = NEW.bed_name WHERE facility_cd = new_mst_machine_facility_cd AND machine_type_cd = new_mst_machine_type_cd AND machine_serial = new_mst_machine_serial ;
//upd by ztc 2023-03-29 [No.8508 fixed NullPointerException] --start /
//              mntMachineStateDao.updateBedInfoByPk(newMstMachine.getFacilityCd(), newMstMachine.getMachineTypeCd(), newMstMachine.getMachineSerial(), newMstBed.getBedCd(), newMstBed.getBedName());
              mntMachineStateDao.updateBedInfoByPk(ObjectUtils.isEmpty(newMstMachine) ? null : newMstMachine.getFacilityCd(),
                ObjectUtils.isEmpty(newMstMachine) ? null : newMstMachine.getMachineTypeCd(),
                ObjectUtils.isEmpty(newMstMachine) ? null : newMstMachine.getMachineSerial(), newMstBed.getBedCd(), newMstBed.getBedName());
//upd by ztc 2023-03-29 [No.8508 fixed NullPointerException] --end /
            }
          }
        }
      } else if (OperateType.INSERT.equals(operateType)) {
        if (IS_DEL_1.equals(newMstBed.getIsDel()) || IS_DISP_0.equals(newMstBed.getIsDisp())) { // 行追加→無効データで登録
          if (newMstBed.getMachineNo() != null) {
            // UPDATE mst_bed SET machine_no = NULL WHERE bed_cd = NEW.bed_cd ;
            mstBedDao.updateMachineNoByBedCd(newMstBed.getBedCd(), null);
          }
        } else if (IS_DEL_0.equals(newMstBed.getIsDel()) && IS_DISP_1.equals(newMstBed.getIsDisp())) { // 行追加→有効データで登録
          MstMachine newMstMachine = mstMachineDao.selectByMachineNo(newMstBed.getMachineNo());
          // UPDATE mnt_machine_state SET bed_cd = NEW.bed_cd, bed_name = NEW.bed_name WHERE facility_cd = new_mst_machine_facility_cd AND machine_type_cd = new_mst_machine_type_cd AND machine_serial = new_mst_machine_serial ;
//upd by ztc 2023-03-29 [No.8508 fixed NullPointerException] --start /
//          mntMachineStateDao.updateBedInfoByPk(newMstMachine.getFacilityCd(), newMstMachine.getMachineTypeCd(),
//            newMstMachine.getMachineSerial(), newMstBed.getBedCd(), newMstBed.getBedName());
          mntMachineStateDao.updateBedInfoByPk(ObjectUtils.isEmpty(newMstMachine) ? null : newMstMachine.getFacilityCd(),
            ObjectUtils.isEmpty(newMstMachine) ? null : newMstMachine.getMachineTypeCd(),
            ObjectUtils.isEmpty(newMstMachine) ? null : newMstMachine.getMachineSerial(), newMstBed.getBedCd(), newMstBed.getBedName());
//upd by ztc 2023-03-29 [No.8508 fixed NullPointerException] --end /
        }
      }
    /* delete by chamaojia 2024-07-03 [10806] [operateType=DELETE] This situation does not exist --start */
//    }
    /* delete by chamaojia 2024-07-03 [10806] [operateType=DELETE] This situation does not exist --end */
  }

}
