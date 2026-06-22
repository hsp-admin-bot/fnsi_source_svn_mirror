package jp.co.nikkiso.ntss.admin_web.response.mstSynchro;

import java.util.Collections;
import java.util.List;

import lombok.AllArgsConstructor;


/**
 * 施設マスタ情報のResponse.
 */
@AllArgsConstructor
public class MstFacilityResponse {
  
  /**
   * 施設情報のリスト.
   */
  public List<MstFacility> facilityList;
  
  /**
   * 空の施設情報を返却するコンストラクタ.
   * 検索結果0件時のレスポンスに使用
   */
  public MstFacilityResponse() {
    this.facilityList = Collections.emptyList();
  }
}
