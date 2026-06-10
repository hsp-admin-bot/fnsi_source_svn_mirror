package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import jp.co.nikkiso.ntss.core.entity.MntMonitorMsgRecord;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordComplaint;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

import java.util.List;

/**
 * 治療記録画面（愁訴処置機能）のService.
 */
public interface TreatmentRecordComplaintService {

  /**
   * 治療記録（愁訴処置情報）の取得
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @return 治療記録（愁訴処置情報）
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  TreatmentRecordComplaint getTreatmentRecordComplaint(Long ordNo) throws NotExistException;

  /**
   * 治療記録（愁訴処置情報）の更新
   * @param ordNo オーダ番号
   * @param treatmentRecordComplaint 治療記録（愁訴処置情報）
   * @return 更新行数
   */
  int updateTreatmentRecordComplaint(Long ordNo, TreatmentRecordComplaint treatmentRecordComplaint);

  // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 start
  String updateTreatmentRecordComplaint2(Long ordNo, TreatmentRecordComplaint treatmentRecordComplaint, Boolean forcedChangeFlag);
  // add 11420 【たくしん会】H9愁訴処置の表示が壊れる、データが倍増する、データが登録されない 関 end

  //add FNSI修正401改修 房 start
  /**
   * 装置動作記録情報取得
   * @param facilityCd
   * @param ordNo
   * @return
   */
  List<MntMonitorMsgRecord> getMntMonitorMsgRecord(String facilityCd, Long ordNo);

  /**
   * 装置動作記録情報更新
   * @param mntMonitorMsgRecord
   */
  void updateMntMonitorMsgRecord (MntMonitorMsgRecord mntMonitorMsgRecord);
  //add FNSI修正401改修 房 end
}
