package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.TreatmentRecordDeviceSetInfo;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordSetting;
import jp.co.nikkiso.ntss.core.exception.NotExistException;

/**
 * 治療記録画面（装置設置機能）のServiceインタフェース.
 */
public interface TreatmentRecordSettingService {

  /**
   * 治療記録（設定値読み込み履歴情報）の取得
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、空リストを返却する.
   * </p>
   * @return 治療記録（設定値読み込み履歴情報）
   */
  List<TreatmentRecordSetting> getOrdTreatConditionByOrdNo(Long ordNo);

  /**
   * 治療記録（装置設定情報）の取得
   * <p>
   * オーダ番号に該当するレコードが存在しない場合、例外を発生させる.
   * </p>
   * @param ordNo
   * @return 治療記録（装置設定情報）
   */
  TreatmentRecordDeviceSetInfo getTreatmentRecordDeviceSetInfoByOrdNo(Long ordNo) throws NotExistException;
}
