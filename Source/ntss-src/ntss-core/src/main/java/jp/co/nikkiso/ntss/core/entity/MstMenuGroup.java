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
 * メニューグループマスタ
 */
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_menu_group")
@Getter
@Setter
public class MstMenuGroup extends BaseEntity {

  /**
   * メニューグループコード
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long menuGroupCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * メニューグループ名
   */
  private String menuGroupName;
  
  /**
   * メニューリスト
   */
  private String menuList;

  /**
   * アイコン情報
   */
  private String iconInfo;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

}
