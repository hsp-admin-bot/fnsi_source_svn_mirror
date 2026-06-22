package jp.co.nikkiso.ntss.core.entity.custom;


import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;
import lombok.Getter;
import lombok.Setter;

/**
 * 実績：治療状況
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvOrdMainRstDialysisState {
  /**
   * 実績：治療状況
   */
  private String rstDialysisState;

}
