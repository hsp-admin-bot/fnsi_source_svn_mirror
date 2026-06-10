package jp.co.nikkiso.ntss.core.dto.FacilitySettingNo;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 施設設定情報のDTO.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class FacilitySettingNoDisplayOrder {
  // 施設設定番号
  private String facilitySettingNo;
  // 値
  private String value;
}
