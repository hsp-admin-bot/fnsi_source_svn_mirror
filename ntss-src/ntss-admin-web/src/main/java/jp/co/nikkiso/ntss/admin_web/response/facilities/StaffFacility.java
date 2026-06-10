package jp.co.nikkiso.ntss.admin_web.response.facilities;

import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;

/**
 * 担当施設1件を表すクラス.
 */
@AllArgsConstructor
@NoArgsConstructor
public class StaffFacility {

  /**
   * 担当フラグ.
   */
  public Boolean isCharge;

  /**
   * 部署符号.
   */
  public String departmentCd;

  /**
   * 都道府県コード.
   */
  public String prefecturesCd;

  /**
   * 都道府県名.
   */
  public String prefecturesName;

  /**
   * 施設コード.
   */
  public String facilityCd;

  /**
   * 施設名.
   */
  public String facilityName;

  /**
   * 施設カナ名
   */
  public String facilityNameKana;

}
