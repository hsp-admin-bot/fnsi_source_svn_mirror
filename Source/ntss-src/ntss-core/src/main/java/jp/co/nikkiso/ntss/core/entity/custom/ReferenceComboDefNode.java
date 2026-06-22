package jp.co.nikkiso.ntss.core.entity.custom;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

/**
 * sys_master_define.reference_combo_defの1件分のオブジェクトを表現するクラス
 */
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReferenceComboDefNode {
  /**
   * カラム物理名
   */
  @JsonProperty("physical_name")
  private String physicalName;

  /**
   * 参照型コンボの元となるマスタの定義
   */
  @JsonProperty("target_table")
  private ReferenceComboTargetTable referenceComboTargetTable;
}
