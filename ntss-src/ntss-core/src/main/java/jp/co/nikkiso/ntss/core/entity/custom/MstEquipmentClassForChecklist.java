package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;
/**
 * チェックリスト設定用医療材料分類クラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_equipment_class")
@Getter
@Setter
public class MstEquipmentClassForChecklist {
  /**
   * 分類コード
   */
  @Id
  private Integer classCd;
  /**
   * 分類名称
   */
  private String className;
  /**
   * 分類区分
   */
  private Double classType;
}
