package jp.co.nikkiso.ntss.admin_web.request.facility;

import lombok.Data;

import java.util.List;

/**
 * 担当者施設設定APIのRequestクラス.
 */
@Data
public class SetStaffFacilityRequest {

  /**
   * 担当施設コードのリスト.
   */
  private List<String> staffFacilityCds;

}
