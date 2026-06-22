package jp.co.nikkiso.ntss.core.dto.patUnique;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@NoArgsConstructor
public class PatDWEffectsTimeLineDTO {

  /** 管理番号 */
  private Integer ctlNo;
  /** 指示者Code */
  private String indicatorCd;
  /** 変更者Code */
  private String changerCd;
  /** 効力開始時間 */
  private String startDate;
  /** 効力終了時間 */
  private String endDate;
  /** 有効なDW */
  private String dw;
}
