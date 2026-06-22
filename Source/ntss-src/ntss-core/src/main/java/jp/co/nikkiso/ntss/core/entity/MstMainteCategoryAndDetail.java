package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Column;
import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 日常・定期点検項目マスタEntity
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstMainteCategoryAndDetail extends BaseEntity implements Comparable<MstMainteCategoryAndDetail> {
  /**
   * 検査詳細品目コード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "mainte_detail_cd")
  private Long menteDetailCd;

  /**
   * 検査詳細項目番号1の内容
   */
  @Column(name = "mainte_content_1")
  private String menteContent1;
  /**
   * 検査詳細項目番号2の内容
   */
  @Column(name = "mainte_content_2")
  private String menteContent2;
  /**
   * 検査詳細項目番号3の内容
   */
  @Column(name = "mainte_content_3")
  private String menteContent3;

  /**
   * 検査詳細項目のグループコード
   */
  @Column(name = "mainte_category_cd")
  private Long menteCategoryCd;

  /**
   * 検査詳細項目のグループ名
   */
  @Column(name = "category_name")
  private String categoryName;

  /**
   * 用途
   */
  private String mainteClass;

  @Override
  public int compareTo(MstMainteCategoryAndDetail o) {
    return this.menteCategoryCd.compareTo(o.menteCategoryCd);
  }
}
