package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * #12462 患者情報共有 zrx
 * 利用者マスタ
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class PatDoctorInfo {
  /**
   * 利用者ID（内部用ID）
   */
  private Integer userId ;
  /**
   * 利用者名_名
   */
  private String userFirstName;
  /**
   * 利用者名_姓
   */
  private String userLastName;
}
