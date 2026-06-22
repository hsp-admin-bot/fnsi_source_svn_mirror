package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 日常・定期点検履歴
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE, immutable = true)
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class DetailResult {
  private Long code;
  private String isDisp;
  private String mainteClass;
}
