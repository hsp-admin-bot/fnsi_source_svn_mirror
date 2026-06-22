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

@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_status_map_bed_layout")
@Getter
@Setter
public class MstStatusMapBedLayout extends BaseEntity {
  /**
   * システムで管理する一意なレイアウト番号
   */
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long layoutId;
  /**
   * 登録施設コード
   */
  private String facilityCd;
  /**
   * レイアウト名
   */
  private String layoutName;
  /**
   * ベッドレイアウト
   */
  private String bedLayout;
  /**
   * 背景画像
   */
  private String backgroundImage;
  /**
   * 削除フラグ
   */
  private String isDel;
  /**
   * 表示フラグ
   */
  private String isDisp;
  /**
   * 在宅フラグ
   */
  private String isHomeDialysis;
}
