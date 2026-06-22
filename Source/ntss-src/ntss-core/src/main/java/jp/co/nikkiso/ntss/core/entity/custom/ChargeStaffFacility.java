package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 担当施設情報取得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ChargeStaffFacility {
  
  /**
   * 担当済か否か
   */
  private Boolean isCharge;
  
  /**
   * 施設コード.
   */
  private String facilityCd;
  
  /**
   * 施設名.
   */
  private String facilityName;
  
  /**
   * 施設カナ名.
   */
  private String facilityNameKana;

  /**
   * 部署符号.
   */
  private String departmentCd;
  
  /**
   * 都道府県コード.
   */
  private String prefecturesCd;
  
  /**
   * 都道府県名.
   */
  private String prefecturesName;
  
}
