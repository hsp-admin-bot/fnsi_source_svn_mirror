package jp.co.nikkiso.ntss.admin_web.service.facilities;

import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.StaffFacilitySettingsResponse;
import jp.co.nikkiso.ntss.admin_web.response.facilities.StaffFacilityResponse;
import jp.co.nikkiso.ntss.admin_web.response.facilities.FacilitiesResponse;

/**
 * 施設系のServiceインタフェース.
 */
public interface FacilitiesService {

  /**
   * 稼働ビューア施設一覧のResponse作成.
   *
   * @param userId ユーザーID
   * @param isNkkFacility 日機装施設か否か
   * @return 稼働ビューア施設一覧のResponse.
   */
  FacilitiesResponse createFacilitiesResponse(Long userId, boolean isNkkFacility);

  /**
   * 担当施設取得のResponse作成.
   *
   * @param userId ユーザーID
   * @return 担当施設取得のResponse.
   */
  StaffFacilityResponse getStaffFacility(Long userId);

  StaffFacilityResponse getStaffSharingFacility(Long userId);

  /**
   * 担当施設設定更新処理.
   *
   * @param userId ユーザーID
   * @param staffFacilityCds 担当施設コードリスト
   * @return 成功フラグとエラーメッセージ
   */
  StaffFacilitySettingsResponse updateStaffFacility(Long userId, List<String> staffFacilityCds);

  /**
   * 使用可能機能取得処理.
   *
   * @param facilityCd 施設コード
   * @return 使用可能機能リスト
   */
  List<String> getUseFunctions(String facilityCd);
}
