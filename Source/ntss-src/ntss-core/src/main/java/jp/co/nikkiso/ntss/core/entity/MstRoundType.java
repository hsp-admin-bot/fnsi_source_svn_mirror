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
 * 種別マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class , naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_round_type")
@Getter
@Setter
public class MstRoundType extends BaseEntity  {
  /**
   * 種別コード.
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long roundTypeCd;
  /**
   * 施設コード.
   */
  private String facilityCd;

  /**
   * 種別名.
   */
  private String roundTypeName;

  /**
   * 内容.
   */
  private String content;

  /**
   * 内容省略フラグ.
   */
  private String isContentOmission;

  /**
   * 指示コメント転記初期値.
   */
  private String commentPostDefault;

  /**
   * 転記区分初期値.
   */
  private String postingClassDefault;

  /**
   * 表示フラグ.
   */
  private String isDisp;

  /**
   * 削除フラグ.
   */
  private String isDel;

  /**
   * 通知対象.
   */
  private String isNotification;

  /**
   * 強調表示.
   */
  private String highlighting;
}
