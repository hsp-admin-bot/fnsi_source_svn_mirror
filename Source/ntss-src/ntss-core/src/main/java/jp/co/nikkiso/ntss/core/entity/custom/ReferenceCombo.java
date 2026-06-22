package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Column;
import org.seasar.doma.Entity;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 参照型コンボの構造定義から取得したデータを表現するクラス
 */
@Entity(immutable = true)
@Getter
@AllArgsConstructor
public class ReferenceCombo {
  /**
   * target_table.referenced_columnで指定されたカラムが保持する値
   */
  @Column(name = "referenced_value")
  private final Object referencedValue;

  /**
   * target_table.display_columnで指定されたカラムが保持する値
   */
  @Column(name = "display_value")
  private final Object displayValue;

  /**
   * target_table.identifierで指定されたカラムが保持する値
   */
  @Column(name = "identifier_value")
  private final Long identifierValue;
}
