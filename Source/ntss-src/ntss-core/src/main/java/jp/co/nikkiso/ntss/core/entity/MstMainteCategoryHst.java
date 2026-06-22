package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 定期点検項目グループマスタ履歴Entity
 */
@Entity(listener = BaseEntityListener.class, naming= NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_mainte_category_hst")
@Getter
@Setter
public class MstMainteCategoryHst extends BaseEntity {
  /**
   * 点検機カテゴリコード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long mainteCategoryCd;
  /**
   * 版数
   */
  private Integer editionNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * カテゴリー名
   */
  private String categoryName;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 詳細
   */
  private String detail;
  /**
   * 用途
   */
  private String mainteClass;
}
