package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Column;
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
 * 日常・定期点検項目マスタEntity
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_mainte_detail")
@Getter
@Setter
public class MstMenteDetail extends BaseEntity implements Comparable<MstMenteDetail> {
  /**
   * 検査詳細品目コード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "mainte_detail_cd")
  private Long menteDetailCd;
  /**
   * 版数
   */
  private Integer editionNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 検査詳細項目のカテゴリ
   */
  @Column(name = "mainte_category_cd")
  private Long menteCategoryCd;
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
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 用途
   */
  private String mainteClass;
  /**
   * 回答パターン
   */
  private String ansPattern;
  /**
   * 補足コメント有無
   */
  private String isCmt;
  /**
   * 初期展開テキスト
   */
  private String iniText;

  @Override
  public int compareTo(MstMenteDetail o) {
    return this.menteCategoryCd.compareTo(o.menteCategoryCd);
  }
}
