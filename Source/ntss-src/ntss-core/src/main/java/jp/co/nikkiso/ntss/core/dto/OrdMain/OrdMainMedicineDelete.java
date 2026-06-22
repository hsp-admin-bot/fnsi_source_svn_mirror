package jp.co.nikkiso.ntss.core.dto.OrdMain;

import lombok.Data;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Data
public class OrdMainMedicineDelete {
  /**
   * 薬剤CD
   */
  private String cd;
  /**
   * 薬剤Type
   */
  private String medicineType;
  /**
   * 薬剤NO
   */
  private String noList;
}
