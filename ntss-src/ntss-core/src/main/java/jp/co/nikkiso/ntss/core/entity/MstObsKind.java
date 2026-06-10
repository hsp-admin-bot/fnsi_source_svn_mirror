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
 * 観察記録種別情報クラス
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_obs_kind")
@Getter
@Setter
public class MstObsKind extends BaseEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  /**
   * 管理番号
   */
  private Long kindNo;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 種別名
   */
  private String kindName;

  /**
   * 種別区分
   */
  private Integer kindClass;

  /**
   * 掲示板への掲載有無
   */
  private String isPostBbs;

  /**
   * 掲載期間
   */
  private Integer postPeriod;

  /**
   * 周知先
   */
  private Integer postAddressClass;

  /**
   * 治療実績とリンク有無
   */
  private String isLinkOrdNo;

  /**
   * FNW+で管理する施設内の一意な種別ID
   */
  private Integer fnKindId;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;
}
