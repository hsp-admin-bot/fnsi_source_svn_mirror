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
 * 日常・定期点検項目マスタ履歴Entity
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_mainte_detail_hst")
@Getter
@Setter
public class MstMainteDetailHst extends BaseEntity {
  /**
   * 点検機詳細コード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long mainteDetailCd;
  /**
   * 版数
   */
  private Integer editionNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * 点検機詳細カテゴリ
   */
  private Long mainteCategoryCd;
  /**
   * 点検機詳細内容１
   */
  @Column(name = "mainte_content_1")
  private String mainteContent1;
  /**
   * 点検機詳細内容２
   */
  @Column(name = "mainte_content_2")
  private String mainteContent2;
  /**
   * 点検機詳細内容３
   */
  @Column(name = "mainte_content_3")
  private String mainteContent3;
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
}
