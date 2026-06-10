package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.SysDataItemEntityListener;
import lombok.Getter;
import lombok.Setter;


/**
 * データ項目設定クラス
 */
@Entity(listener = SysDataItemEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_data_item")
@Getter
@Setter
public class SysDataItem extends BaseBlankEntity {
  @Id
  /**
   * 施設コード
   */
  private String facilityCd;
  @Id
  /**
   * テンプレート番号
   */
  private Integer templateNo;
  @Id
  /**
   * 項目区分
   */
  private Integer itemCategory;
  @Id
  /**
   * サブ項目区分
   */
  private Integer itemSubCategory;

  /**
   * 項目名タイプ
   */
  private Integer itemType;

  /**
   * 値タイプ
   */
  private Integer valueType;

  /**
   * 表示位置
   */
  private Integer dispPosition;

  /**
   * 項目名
   */
  private String itemTitle;

  /**
   * 項目単位
   */
  private String itemUnit;

  /**
   * 項目キー
   */
  private String itemTable;

  /**
   * 項目キー
   */
  private String itemKey;

  /**
   * 表示順
   */
  private Integer dispOrder;

  /**
   * 表示設定
   */
  private String isDisp;
}
