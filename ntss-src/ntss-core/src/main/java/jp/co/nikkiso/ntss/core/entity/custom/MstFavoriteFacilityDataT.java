// add FNSI-よく使う施設の変更 関 start
package jp.co.nikkiso.ntss.core.entity.custom;

import lombok.Data;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * よく使う施設マスタのcustomEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Data
public class MstFavoriteFacilityDataT {

  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 施設Name
   */
  private String facilityName;

  /**
   * 施設Name
   */
  private String facilityNameKana;

  /**
   * 都道府県コード.
   */
  private String prefCd;

  /**
   * 都道府県.
   */
  private String prefName;


}
// add FNSI-よく使う施設の変更 関 end
