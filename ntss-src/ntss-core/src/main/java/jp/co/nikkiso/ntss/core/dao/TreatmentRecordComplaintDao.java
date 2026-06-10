package jp.co.nikkiso.ntss.core.dao;

import jp.co.nikkiso.ntss.core.entity.MntMonitorMsgRecord;
import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.TreatmentRecordComplaint;

import java.util.List;

/**
 * 治療記録用愁訴処置のDaoインタフェース.
 */
@Dao
@ConfigAutowireable
public interface TreatmentRecordComplaintDao {

  /**
   * オーダ番号に紐づく愁訴処置情報を取得する
   * @param ordNo オーダ番号
   * @return 治療情報のEntity（愁訴処置情報）
   */
  @Select(ensureResult = true)
  TreatmentRecordComplaint selectTreatmentRecordComplaintByOrdNo(Long ordNo);

  /**
   * オーダ番号に紐づく愁訴処置情報を更新する
   * @param ordNo オーダ番号
   * @param treatmentRecordComplaint 治療情報のEntity（愁訴処置情報）
   * @return 更新行数
   */
  @Update(sqlFile = true)
  int updateTreatmentRecordComplaint(Long ordNo, TreatmentRecordComplaint treatmentRecordComplaint);

  /**
   * mnt_motion_recordから対象データを取得
   * @param facilityCd
   * @param ordNo
   * @return
   */
  @Select
  List<MntMonitorMsgRecord> selectMonitorMsgRecord(String facilityCd, Long ordNo);

  @Update(sqlFile = true)
  int updatetMonitorMsgRecord(MntMonitorMsgRecord mntMonitorMsgRecord);
}
