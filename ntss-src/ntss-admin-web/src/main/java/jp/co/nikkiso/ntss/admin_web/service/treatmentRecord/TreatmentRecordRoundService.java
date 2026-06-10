package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import jp.co.nikkiso.ntss.core.entity.TreatmentRecordRoundsInfo;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

/**
 * 治療記録画面（回診記録機能）のServiceインタフェース.
 */
public interface TreatmentRecordRoundService {
  /**
   * 治療記録（回診記録情報）の取得
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo
   * @return 治療記録（回診記録情報）
   */
  TreatmentRecordRoundsInfo getTreatmentRecordRoundsInfoByOrdNo(Long ordNo) throws NotExistException;

  /**
   * 治療記録（回診記録情報）の更新
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo オーダ番号
   * @param treatmentRecordRoundsInfo 治療記録（回診記録情報）
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  void updateTreatmentRecordRoundsInfo(Long ordNo, TreatmentRecordRoundsInfo treatmentRecordRoundsInfo) throws NotExistException;
}
