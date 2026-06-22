package jp.co.nikkiso.ntss.admin_web.service.master;

import jp.co.nikkiso.ntss.core.entity.custom.ReferenceComboTargetTable;
import lombok.Getter;

/**
 * 参照コンボのテーブル情報定義.
 */
@Getter
public enum ReferenceComboTargetDefinition {

  BED("mst_bed", "bed_cd", "bed_name"),
  KUR("mst_kur", "kur_cd", "kur_name"),
  TREATMENT("mst_treatment", "treatment_cd", "treatment_name");

  private ReferenceComboTargetTable value = null;

  /**
   * コンストラクタ.
   *
   * @param tableName テーブル名
   * @param cdColumnName コードカラム名
   * @param nameColumnName 名称カラム名
   */
  ReferenceComboTargetDefinition(String tableName, String cdColumnName, String nameColumnName) {
    this.value = new ReferenceComboTargetTable(tableName, cdColumnName, nameColumnName, cdColumnName);
  }

}
