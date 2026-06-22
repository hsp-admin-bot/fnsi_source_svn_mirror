package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 通知メッセージのEntity.
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_release_info")
@Getter
@Setter
public class SysReleaseInfo extends BaseEntity {

  /**
   * 管理番号.
   */
  @Id
  private Long ctlNo;

  /**
   * リリース日
   */
  private String releaseDate;

  /**
   * タイトル
   */
  private String title;

  /**
   * システムタイプ
   */
  private String systemType;

  /**
   * path
   */
  private String pathUrl;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

}
