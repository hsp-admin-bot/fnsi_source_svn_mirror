package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * 参照型コンボの元となるマスタを定義するクラス
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReferenceComboTargetTable {
  /**
   * 対象マスタの物理名
   */
  @JsonProperty("name")
  private String name;

  /**
   * 「コンボの値」を保持するカラムの物理名
   */
  @JsonProperty("referenced_column")
  private String referencedColumn;

  /**
   * 「コンボに表示する値」を保持するカラムの物理名
   */
  @JsonProperty("display_column")
  private String displayColumn;

  /**
   * 主キーとなるカラムの物理名（主キーの型はserialを想定）
   */
  @JsonProperty("identifier")
  private String identifier;
}
