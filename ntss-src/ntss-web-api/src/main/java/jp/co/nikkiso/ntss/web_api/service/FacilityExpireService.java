package jp.co.nikkiso.ntss.web_api.service;

import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/**
 * 期間外削除サービスインタフェース。
 */
public interface FacilityExpireService {
  /**
   * 期間外データ削除を実行する(全施設対象)
   *
   * @param baseDate 処理基準日
   * @param endTime 処理終了時間
   * @param mode 1:REMSのみ、2:FNSiを含む施設
   * @param targetFacilityCdList 処理対象の施設リスト、nullの場合は全施設対象
   */
  void executeExpire(LocalDateTime baseDate, LocalTime endTime, int mode, List<String> targetFacilityCdList);
  void executeExpire(LocalDateTime baseDate, LocalTime endTime, int mode, List<String> targetFacilityCdList,LocalTime startTime);

  /**
   * 期間外データ削除を実行する(施設指定)
   *
   * @param baseDate 処理基準日
   * @param endTime 処理終了時間
   * @param facilityCd 施設コード
   */
  void executeExpireFacility(LocalDateTime baseDate, LocalTime endTime, String facilityCd);
  void executeExpireFacility(LocalDateTime baseDate, LocalTime endTime, String facilityCd,LocalTime startTime);

}
