package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * ユーザー名取得用Entity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class UserName {

  /**
   * 利用者ID.
   */
  private Long userId;

  /**
   * 利用者名.
   */
  private String userName;
  
}
