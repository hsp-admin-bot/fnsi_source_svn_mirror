package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 処方一覧
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PrescriptionCount {

  /**
   * 交付日
   */
  private String issue_date;
  /**
   * 処方
   */
  private String syohou;
}
