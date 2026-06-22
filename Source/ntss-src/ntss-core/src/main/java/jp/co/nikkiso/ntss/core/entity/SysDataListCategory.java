package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * データリストカテゴリ
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_data_list_category")
@Getter
@Setter
public class SysDataListCategory extends BaseBlankEntity {
 /**
   * カテゴリコード
   */
  @Id
  private Long categoryCd;

  /**
   * カテゴリ名
   */
  private String categoryName;

  /**
   * テンプレートコード
   */
  private Integer templateCd;

  /**
   * 表示順
   */
  private Integer dispOrder;

}
