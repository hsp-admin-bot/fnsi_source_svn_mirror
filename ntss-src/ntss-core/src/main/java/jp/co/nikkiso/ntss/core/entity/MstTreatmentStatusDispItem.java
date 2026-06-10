package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 治療状況レイアウトマスタ情報クラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_treatment_status_disp_item")
@Getter
@Setter
public class MstTreatmentStatusDispItem extends BaseEntity {

  /**
   * レイアウト表示項目管理番号
   */
  @Id
  private Integer itemCd;
  /**
   * データ取得種別
   */
  private String dataClass;
  /**
   * 装置種別
   */
  private String machineClass;
  /**
   * 項目名
   */
  private String itemName;
  /**
   * 参照先テーブル名
   */
  private String tableName;
  /**
   * 参照先フィールド名
   */
  private String fieldName;
  /**
   * 参照先JSONキー名
   */
  private String jsonKeyName;
  /**
   * 表示順
   */
  private Integer dispOrder;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 単位
   */
  private String unit;

}
