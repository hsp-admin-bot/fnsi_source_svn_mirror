package jp.co.nikkiso.ntss.core.trigger;

import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.dao.MntMotionRecordDao;
import jp.co.nikkiso.ntss.core.entity.MntMotionRecord;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;


/**
 * Triggerの実装クラス.
 */
@Slf4j
@Component
public class MntMotionTrigger {

  /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // private static int CON_DATA_TYPE_M_NOTICE = 2; // データ種別：緊急発報記録
  // private static int CON_DATA_TYPE_PREVENTIVE_MAINTE = 3; // データ種別：予防保全/故障予知記録
  private static final int CON_DATA_TYPE_M_NOTICE = 2; // データ種別：緊急発報記録
  private static final int CON_DATA_TYPE_PREVENTIVE_MAINTE = 3; // データ種別：予防保全/故障予知記録
  /* upd by chamaojia 2026-05-07 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  @Autowired
  private MntMotionRecordDao mntMotionRecordDao;

  public void triggerMntMotionRecord(MntMotionRecord newMntMotionRecord, OperateType operateType) {
    // 装置状態管理テーブル更新
    if (OperateType.UPDATE.equals(operateType)) {
      // 装置動作記録テーブルの該当レコードのデータ種別が「緊急発報記録」の場合、緊急発報記録(未対処)レコード件数を算出
      if (CON_DATA_TYPE_M_NOTICE == newMntMotionRecord.getDataType()) {
        /*
        SELECT COUNT(*) INTO n_m_notice_cnt
        FROM mnt_motion_record
        WHERE facility_cd = NEW.facility_cd AND machine_type_cd = NEW.machine_type_cd AND TRIM(machine_serial) = TRIM(NEW.machine_serial) AND data_type = con_data_type_m_notice  AND (is_correction = con_no_correction OR is_correction = con_responding OR is_correction IS NULL) ;
        */
        int n_m_notice_cnt = mntMotionRecordDao.selectMNoticeCnt(newMntMotionRecord.getFacilityCd(),newMntMotionRecord.getMachineTypeCd(), newMntMotionRecord.getMachineSerial());
        
        // 装置状態管理テーブルに緊急発報件数を反映
        mntMachineStateDao.updateMNoticeCnt(newMntMotionRecord.getFacilityCd(),
                newMntMotionRecord.getMachineTypeCd(), newMntMotionRecord.getMachineSerial(),
                n_m_notice_cnt, newMntMotionRecord.getUpDate());
      }
      
      // 装置動作記録テーブルの該当レコードのデータ種別が「予防保全/故障予知記録」の場合、予防保全/故障予知記録(未対処)レコード件数を算出
      if (CON_DATA_TYPE_PREVENTIVE_MAINTE == newMntMotionRecord.getDataType()) {
        int preventiveMainteCnt = mntMotionRecordDao.selectPreventiveMainteCnt(newMntMotionRecord.getFacilityCd(),newMntMotionRecord.getMachineTypeCd(), newMntMotionRecord.getMachineSerial());
        mntMachineStateDao.updatePreventiveMainteCnt(newMntMotionRecord.getFacilityCd(),
                newMntMotionRecord.getMachineTypeCd(), newMntMotionRecord.getMachineSerial(),
                preventiveMainteCnt, newMntMotionRecord.getUpDate());
      }
      // 緊急発報件数及び予防保守件数を合算した件数をサービス対応件数に書込む
      if (CON_DATA_TYPE_M_NOTICE == newMntMotionRecord.getDataType() || CON_DATA_TYPE_PREVENTIVE_MAINTE == newMntMotionRecord.getDataType()) {
        // 算出した件数を装置状態管理テーブルのサポート対応件数に反映する.
        int serviceSupportCnt = mntMotionRecordDao.selectServiceSupportCnt(newMntMotionRecord.getFacilityCd(),newMntMotionRecord.getMachineTypeCd(),newMntMotionRecord.getMachineSerial());
        mntMachineStateDao.updateServiceSupportCnt(newMntMotionRecord.getFacilityCd(),
                newMntMotionRecord.getMachineTypeCd(), newMntMotionRecord.getMachineSerial(),
                serviceSupportCnt, newMntMotionRecord.getUpDate());
      }
    }
  }
}
