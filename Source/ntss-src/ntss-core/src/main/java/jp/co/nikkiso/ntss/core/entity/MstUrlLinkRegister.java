package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.GeneratedValue;
import org.seasar.doma.GenerationType;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;

/**
 * 外部リンクメニューマスタ
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_url_link_register")
@Getter
@Setter
public class MstUrlLinkRegister extends BaseEntity {

  /**
   * URLコード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long urlCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 関数名
   */
  private String functionName;

  /**
   * URL
   */
  private String urlInfo;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

}
