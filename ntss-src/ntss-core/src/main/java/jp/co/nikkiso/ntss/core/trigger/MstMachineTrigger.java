package jp.co.nikkiso.ntss.core.trigger;

import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineTypeDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.sql.Timestamp;
import java.util.List;
import java.util.Map;


/**
 * Triggerの実装クラス.
 */
@Component
public class MstMachineTrigger {

  private static String IS_DEL_0 = "0";
  private static String IS_DEL_1 = "1";
  private static String IS_DISP_0 = "0";
  private static String IS_DISP_1 = "1";

  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  @Autowired
  private MstBedDao mstBedDao;

  @Autowired
  private MstMachineTypeDao mstMachineTypeDao;

  public void triggerInsert(Map<String, Object> newData,String facilityCd) {
    MstMachine newMstMachine = getObjFromMap(newData);
    newMstMachine.setFacilityCd(facilityCd);
    triggerMstMachine(null,newMstMachine,OperateType.INSERT);
  }
  
  public void triggerUpdate(Map<String, Object> beforeUpdateData, Map<String, Object> afterUpdateData) {
    MstMachine oldMstMachine = getObjFromMap(beforeUpdateData);
    MstMachine newMstMachine = getObjFromMap(afterUpdateData);
    triggerMstMachine(oldMstMachine,newMstMachine,OperateType.UPDATE);
  }

  public void triggerDelete(String facilityCd,String machineTypeCd,String getMachineSerial,Long machineNo) {
    MntMachineState mntMachineState = new MntMachineState();
    mntMachineState.setFacilityCd(facilityCd);
    mntMachineState.setMachineTypeCd(machineTypeCd);
    mntMachineState.setMachineSerial(getMachineSerial);
    mntMachineStateDao.delete(mntMachineState);
    mstBedDao.updateMachineNoByMachineNo(machineNo);
  }
  
  private MstMachine getObjFromMap(Map<String, Object> mstMachineData){
    MstMachine mstMachine = new MstMachine();
    mstMachine.setIsDisp( TriggerUtil.getStringValueFromMap(mstMachineData,"is_disp") );
    String isDel = TriggerUtil.getStringValueFromMap(mstMachineData,"is_del");
    if(StringUtils.isEmpty(isDel)){
      isDel = IS_DEL_0;
    }
    mstMachine.setIsDel( isDel );
    mstMachine.setFacilityCd( TriggerUtil.getStringValueFromMap(mstMachineData,"facility_cd") );
    mstMachine.setMachineTypeCd( TriggerUtil.getStringValueFromMap(mstMachineData,"machine_type_cd") );
    mstMachine.setMachineSerial( TriggerUtil.getStringValueFromMap(mstMachineData,"machine_serial") );
    String machineName = TriggerUtil.getStringValueFromMap(mstMachineData,"machine_name");
    if(StringUtils.isEmpty(machineName)){
      machineName = TriggerUtil.getStringValueFromMap(mstMachineData,"name");
    }
    mstMachine.setMachineName( machineName );
    Long machineNo = TriggerUtil.getLongValueFromMap(mstMachineData,"machine_no");
    if(machineNo == null){
      machineNo = TriggerUtil.getLongValueFromMap(mstMachineData,"code");
    }
    mstMachine.setMachineNo( machineNo );
    Timestamp upDate = TriggerUtil.getTimestampValueFromMap(mstMachineData,"up_date");
    if(upDate == null){
      upDate = new Timestamp(System.currentTimeMillis());
    }
    mstMachine.setUpDate(upDate);
    return mstMachine;
  }

  private void triggerMstMachine(MstMachine oldMstMachine, MstMachine newMstMachine,OperateType operateType) {
    if (OperateType.DELETE.equals(operateType)) {
      // 装置マスタのレコード削除時は関連テーブルのレコードも削除
      triggerDelete(oldMstMachine.getFacilityCd(),oldMstMachine.getMachineTypeCd(),oldMstMachine.getMachineSerial(),oldMstMachine.getMachineNo());
    } else if (OperateType.INSERT.equals(operateType) || OperateType.UPDATE.equals(operateType)) {
      if (OperateType.INSERT.equals(operateType)) {
        // 表示、有効データの挿入のみ関連データ登録する
        if (IS_DEL_0.equals(newMstMachine.getIsDel()) && IS_DISP_1.equals(newMstMachine.getIsDisp())) {
          List<MstBed> mstBeds = mstBedDao.selectByMachineNo(newMstMachine.getMachineNo());
          Long bedCd = null; // ベッドマスタのベッドコード
          String bedName = null; // ベッドマスタのベッド名
          if(!mstBeds.isEmpty()){
            bedCd = mstBeds.get(0).getBedCd();
            bedName = mstBeds.get(0).getBedName();
          }
          MstMachineType newMachineType = mstMachineTypeDao.selectByTypeCd(newMstMachine.getMachineTypeCd());
          MntMachineState mntMachineState = new MntMachineState();
          mntMachineState.setFacilityCd(newMstMachine.getFacilityCd());
          mntMachineState.setMachineTypeCd(newMstMachine.getMachineTypeCd());
          mntMachineState.setMachineSerial(newMstMachine.getMachineSerial());
          mntMachineState.setModel(newMachineType.getModel());
          mntMachineState.setMachineName(newMstMachine.getMachineName());
          mntMachineState.setBedCd(bedCd);
          mntMachineState.setBedName(bedName);
          mntMachineState.setRegDate(new Timestamp(System.currentTimeMillis()));
          mntMachineState.setUpDate(new Timestamp(System.currentTimeMillis()));
          mntMachineStateDao.insert(mntMachineState);
        }
      } else if (OperateType.UPDATE.equals(operateType)) {
        // 非表示、削除によるレコード削除
        if (IS_DEL_1.equals(newMstMachine.getIsDel()) || IS_DISP_0.equals(newMstMachine.getIsDisp())) {
          triggerDelete(oldMstMachine.getFacilityCd(),oldMstMachine.getMachineTypeCd(),oldMstMachine.getMachineSerial(),oldMstMachine.getMachineNo());
          // 表示、非削除データの更新
        } else if (IS_DEL_0.equals(newMstMachine.getIsDel()) && IS_DISP_1.equals(newMstMachine.getIsDisp())) {
          // 装置状態管理テーブルの対象レコード件数
          int machineStateRowCnt = mntMachineStateDao.selectMachineStateRowCntByPk(oldMstMachine.getFacilityCd(),oldMstMachine.getMachineTypeCd(), oldMstMachine.getMachineSerial());
          if (machineStateRowCnt == 0) { // 新たに表示、非削除に変更したもの、既存データをカウント有無を確認してなければ挿入
            // 型式マスタのモデル
            MstMachineType newMachineType = mstMachineTypeDao.selectByTypeCd(newMstMachine.getMachineTypeCd());
            List<MstBed> mstBeds = mstBedDao.selectByMachineNo(newMstMachine.getMachineNo());
            Long bedCd = null; // ベッドマスタのベッドコード
            String bedName = null; // ベッドマスタのベッド名
            if(!mstBeds.isEmpty()){
              bedCd = mstBeds.get(0).getBedCd();
              bedName = mstBeds.get(0).getBedName();
            }
            MntMachineState mntMachineState = new MntMachineState();
            mntMachineState.setFacilityCd(newMstMachine.getFacilityCd());
            mntMachineState.setMachineTypeCd(newMstMachine.getMachineTypeCd());
            mntMachineState.setMachineSerial(newMstMachine.getMachineSerial());
            mntMachineState.setModel(newMachineType.getModel());
            mntMachineState.setMachineName(newMstMachine.getMachineName());
            mntMachineState.setBedCd(bedCd);
            mntMachineState.setBedName(bedName);
            mntMachineState.setProcessState(null);
            mntMachineState.setMNoticeCnt(0);
            mntMachineState.setPreventiveMainteCnt(0);
            mntMachineState.setIsPreventiveMainte(0);
            mntMachineState.setMachineStatus(0);
            mntMachineState.setIsOffline("0");
            mntMachineState.setRegDate(new Timestamp(System.currentTimeMillis()));
            mntMachineState.setUpDate(new Timestamp(System.currentTimeMillis()));
            mntMachineStateDao.insert(mntMachineState);
          }
          if (machineStateRowCnt > 0) { // 新たに表示、非削除に変更したもの、既存データをカウント有無を確認してなければ挿入
            if ((!oldMstMachine.getMachineTypeCd().equals(newMstMachine.getMachineTypeCd()))
                    || (!oldMstMachine.getMachineSerial().equals(newMstMachine.getMachineSerial()))
                    || (!oldMstMachine.getMachineName().equals(newMstMachine.getMachineName()))) {
              MstMachineType newMachineType = mstMachineTypeDao.selectByTypeCd(newMstMachine.getMachineTypeCd());
              mntMachineStateDao.updateOldMachineByPk(oldMstMachine.getFacilityCd(), oldMstMachine.getMachineTypeCd(),
                      oldMstMachine.getMachineSerial(), newMstMachine.getMachineTypeCd(), newMstMachine.getMachineSerial(),
                      newMachineType.getModel(), newMstMachine.getMachineName(), newMstMachine.getUpDate());
            }
          } 
        }
      }
    }
  }
  
  public int triggerMachineStateInsert(MstMachine updatedMstMachine){
    // 装置状態管理テーブルの対象レコード件数
    int machineStateRowCnt = mntMachineStateDao.selectMachineStateRowCntByPk(updatedMstMachine.getFacilityCd(),updatedMstMachine.getMachineTypeCd(), updatedMstMachine.getMachineSerial());
    if (machineStateRowCnt == 0) { // 新たに表示、非削除に変更したもの、既存データをカウント有無を確認してなければ挿入
      // 型式マスタのモデル
      MstMachineType newMachineType = mstMachineTypeDao.selectByTypeCd(updatedMstMachine.getMachineTypeCd());
      List<MstBed> mstBeds = mstBedDao.selectByMachineNo(updatedMstMachine.getMachineNo());
      Long bedCd = null; // ベッドマスタのベッドコード
      String bedName = null; // ベッドマスタのベッド名
      if(!mstBeds.isEmpty()){
        bedCd = mstBeds.get(0).getBedCd();
        bedName = mstBeds.get(0).getBedName();
      }
      MntMachineState mntMachineState = new MntMachineState();
      mntMachineState.setFacilityCd(updatedMstMachine.getFacilityCd());
      mntMachineState.setMachineTypeCd(updatedMstMachine.getMachineTypeCd());
      mntMachineState.setMachineSerial(updatedMstMachine.getMachineSerial());
      mntMachineState.setModel(newMachineType.getModel());
      mntMachineState.setMachineName(updatedMstMachine.getMachineName());
      mntMachineState.setBedCd(bedCd);
      mntMachineState.setBedName(bedName);
      mntMachineState.setProcessState(null);
      mntMachineState.setMNoticeCnt(0);
      mntMachineState.setPreventiveMainteCnt(0);
      mntMachineState.setIsPreventiveMainte(0);
      mntMachineState.setMachineStatus(0);
      mntMachineState.setIsOffline("0");
      mntMachineState.setRegDate(new Timestamp(System.currentTimeMillis()));
      mntMachineState.setUpDate(new Timestamp(System.currentTimeMillis()));
      mntMachineStateDao.insert(mntMachineState);
    }
    return machineStateRowCnt;
  }
 
}
