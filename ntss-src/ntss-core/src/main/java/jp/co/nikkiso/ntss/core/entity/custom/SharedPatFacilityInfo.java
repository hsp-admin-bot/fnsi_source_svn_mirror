package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 施設一覧取得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class SharedPatFacilityInfo {

  /**
   * 施設コード.
   */
  public String facilityCd;

  /**
   * 施設名.
   */
  public String facilityName;

  /**
   * 患者ID .
   */
  private Long patId;

}
