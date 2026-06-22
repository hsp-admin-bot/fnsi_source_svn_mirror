package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

/**
 * 治療記録削除のServiceインタフェース.
 */
public interface TreatmentRecordDeleteService {
  /**
   * 治療記録削除
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外をスローする.
   * </p>
   * @param ordNo オーダ番号
   */
  //mod FNSI修正401対応 房 start
  void deleteTreatmentRecordByOrdNo(Long ordNo) throws NotExistException;
  //mod FNSI修正401対応 房 end

  /**
   * 治療記録削除
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外をスローする.
   * </p>
   * @param ordNo オーダ番号
   */
  //mod FNSI修正401対応 房 start
  // mod #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou start
//  void deleteTreatmentRecordByOrdNo(Long ordNo, String facilityCd) throws NotExistException;
  OrdMain deleteTreatmentRecordByOrdNo(Long ordNo, String facilityCd) throws NotExistException;
  //mod FNSI修正401対応 房 end

  /**
   * 次患者更新
   * @param ordMain 透析情報
   */
  void setNextPat(OrdMain ordMain) throws NotExistException;
  // mod #6848 2022-08-26 透析実績を削除しても次患者は戻らない。 dou end
}
