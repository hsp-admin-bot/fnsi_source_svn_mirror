package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * ord_main装置設定情報の実体
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class OrdMainForDeviceSetInfo {

  /**
   * オーダーNo
   */
  private Long ordNo;

  /**
   * 指示：装置設定情報
   */
  private String indDeviceSetInfo;
}
