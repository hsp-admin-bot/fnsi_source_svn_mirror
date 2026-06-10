package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * データリストカテゴリ詳細
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_data_list_detail")
@Getter
@Setter
public class SysDataListDetail extends BaseBlankEntity {

  /**
   * データリスト詳細コード
   */
  @Id
  private Long dataListDetailCd;

  /**
   * 表示順
   */
  private Integer dispOrder;

  /**
   * カテゴリコード
   */
  private Long categoryCd;

  /**
   * マスタ表示パターン
   */
  private String masterDisplayName;

  /**
   * マスタ表示区分
   */
  private String masterDisplayType;

  /**
   * マスタ表示SQL
   */
  private String masterDisplaySql;

  /**
   * 一覧表示パターン
   */
  private String functionDisplayName;

  /**
   * 一覧表示区分
   */
  private String functionDisplayType;

  /**
   * 一覧表示SQL
   */
  private String functionDisplaySql;

  /**
   * データセット
   */
  private String dataSet;

  /**
   * セル表示パターン
   */
  private String cellDisplay;
}
