package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Getter
@Setter
@Entity(naming= NamingType.SNAKE_LOWER_CASE)
public class MstSelectorToPatGroup {
  /**
   * マスタ名(物理名称).
   */
  private String masterPhysicalName;
  /**
   * コード項目.
   */
  private String code;
}
