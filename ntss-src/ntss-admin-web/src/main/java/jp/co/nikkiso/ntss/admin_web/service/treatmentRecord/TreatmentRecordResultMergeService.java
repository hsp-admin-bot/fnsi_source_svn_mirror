package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import jp.co.nikkiso.ntss.core.entity.TreatmentRecordResultMerge;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

import java.util.List;

/**
 * 治療記録（実績マージ）画面のServiceインタフェース.
 */
public interface TreatmentRecordResultMergeService {

  /**
   * 治療記録（実績マージ情報）の取得.
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   *
   * @param ordNo オーダ番号
   * @param facilityCd 施設コード
   * @return 治療記録（実績マージ情報）のリスト
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  List<TreatmentRecordResultMerge> getResultMergeList(Long ordNo, String facilityCd) throws NotExistException;

  /**
   * 治療記録（実績マージ情報）の更新
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   *
   * @param ordNo                      オーダ番号
   * @param treatmentRecordResultMerge 実績マージ情報
   * @throws NotExistException オーダー番号に該当するレコードが存在しない場合
   */
  void updateResultMerge(Long ordNo, TreatmentRecordResultMerge treatmentRecordResultMerge) throws NotExistException;

  //add FNSI修正486改修 房 start
  /**
   * 治療記録（実績マージ情報）の取得.
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   *
   * @param ordNo オーダ番号
   * @param facilityCd 施設コード
   * @return 治療記録（実績マージ情報）のリスト
   * @throws NotExistException オーダ番号に該当するレコードが存在しない場合
   */
  List<TreatmentRecordResultMerge> getResultMergeList(Long ordNo, String facilityCd, String startDate, String endDate, String isUnknown) throws NotExistException;
  //add FNSI修正486改修 房 end

  /**
   * 治療記録（実績マージ情報）の更新
   *
   * @param treatmentRecordResultMerge  実績マージ情報
   */
  void treatmentRecordMergeExecution(TreatmentRecordResultMerge treatmentRecordResultMerge);
}

