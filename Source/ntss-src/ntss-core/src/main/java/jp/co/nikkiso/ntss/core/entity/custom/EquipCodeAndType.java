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
public class EquipCodeAndType {

  /**
   * 医療材料コード
   */
  private int equipmentCd;

  /**
   * 医療材料区分.
   */
  private String equipType;


  public String getEquipCdCond() {
    return equipmentCd == 1 ? "01" : "11";
  }

}
