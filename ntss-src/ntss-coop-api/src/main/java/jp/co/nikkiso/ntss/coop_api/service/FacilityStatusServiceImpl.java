package jp.co.nikkiso.ntss.coop_api.service;

import java.util.concurrent.ConcurrentHashMap;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;

/**
 * convertの直列化に使用するfacilityStatus管理クラス
 *
 * @see jp.co.nikkiso.ntss.coop_api.service.FacilityStatusService
 */
@Service
public class FacilityStatusServiceImpl implements FacilityStatusService {
  private final ConcurrentHashMap<String, String> facilityStatus = new ConcurrentHashMap<>();

  /**
   * 施設のコンバート実行中チェック
   *
   * @param facilityCd 施設コード
   * @return 実行中：true、停止中：false
   */
  public boolean isStatusStart(String facilityCd) {
    if (facilityStatus.containsKey(facilityCd)) {
      if (JournalConvertConstants.STATUS_START.equals(facilityStatus.get(facilityCd))) {
        // 施設が「実行(start)」の場合、他スレッドでconvert実行中
        return true;
      }
    }
    return false;
  }

  /**
   * 施設のコンバート実行中チェックと更新
   *
   * @param facilityCd 施設コード
   * @return 更新成功：true、更新不可（他スレッドで実行中）：false
  */
  public boolean checkAndPutStatus(String facilityCd) {
    // 施設が無しの場合、施設ステータスに「実行(start)」を追加する
    String oldStatus = facilityStatus.putIfAbsent(facilityCd, JournalConvertConstants.STATUS_START);
    if (oldStatus == null) {
      // 施設ステータスに「実行(start)」を追加成功
      return true;
    } else if (JournalConvertConstants.STATUS_START.equals(oldStatus)) {
      // 施設が「実行(start)」の場合、他スレッドでconvert実行中
      return false;
    } else if (JournalConvertConstants.STATUS_STOP.equals(oldStatus)) {
      // 施設が「停止(stop)」の場合、施設ステータスに「実行(start)」を設定
      if (facilityStatus.replace(facilityCd, JournalConvertConstants.STATUS_STOP, JournalConvertConstants.STATUS_START)) {
        // 施設ステータスを「実行(start)」に更新成功
        return true;
      }
      // 他スレッドでconvert実行中
      return false;
    }
    return false;
  }

  /**
   * replace呼び出し
   *
   * @param facilityCd 施設コード
   * @param newValue   更新値
   */
  public void replace(String facilityCd, String newValue) {
    facilityStatus.replace(facilityCd, newValue);
  }

}
