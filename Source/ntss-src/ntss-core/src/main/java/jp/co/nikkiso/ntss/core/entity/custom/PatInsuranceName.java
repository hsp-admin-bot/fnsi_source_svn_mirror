package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
/**
 * 患者保険名APIの応答クラス.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
@NoArgsConstructor
public class PatInsuranceName {

  /**
   * 保険コード
   */
  private Long insuranceCd;

  /**
   * 保険名
   */
  private String insuName;

  /**
   * 選択フラグ
   */
  private String isSelected;

  /**
   * 削除
   */
  private String isDel;
}
