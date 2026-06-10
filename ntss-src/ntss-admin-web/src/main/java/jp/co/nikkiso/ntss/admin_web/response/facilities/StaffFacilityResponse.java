package jp.co.nikkiso.ntss.admin_web.response.facilities;

import java.util.Collections;
import java.util.List;

import lombok.AllArgsConstructor;

/**
 *　担当施設取得のResponse.
 */
@AllArgsConstructor
public class StaffFacilityResponse {

  /**
   * 全施設情報のリスト.
   */
  public List<StaffFacility> staffFacilities;
  
  /**
   * 空の施設情報を返却するコンストラクタ.
   * 検索結果0件時のレスポンスに使用
   */
  public StaffFacilityResponse() {
    this.staffFacilities = Collections.emptyList();
  }

}
