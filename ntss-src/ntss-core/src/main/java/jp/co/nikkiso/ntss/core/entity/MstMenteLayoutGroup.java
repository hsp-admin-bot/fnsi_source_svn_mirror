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
 * 定期点検機種別レイアウトグループEntity
 */
@Entity(listener = BaseEntityListener.class, naming= NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_mainte_layout_group")
@Getter
@Setter
public class MstMenteLayoutGroup extends BaseEntity{
  /**
   * 点検レイアウトグループコード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "mainte_layout_group_cd")
  private Long menteLayoutGroupCd;
  /**
   * 版数
   */
  private Integer editionNo;
  /**
   * 施設コード
   */
  private String facilityCd;
  /**
   * レイアウト検査グループの名前
   */
  private String groupName;
  /**
   * リストレイアウト検査
   */
  private String layoutList;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 削除フラグ
   */
  private String isDel;
}
