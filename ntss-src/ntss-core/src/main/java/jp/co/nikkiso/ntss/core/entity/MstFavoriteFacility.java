package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.BaseEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * よく使う施設マスタのEntity.
 */
@Entity(listener = BaseEntityListener.class , naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_favorite_facility")
@Getter
@Setter
public class MstFavoriteFacility extends BaseEntity {

  /**
   * お気に入り施設マスタコード.
   */
  @Id
  private int masterCd;

  /**
   * 登録施設コード.
   */
  private String facilityCd;

  /**
   * お気に入り施設コード.
   */
  private String favoriteFacilityCd;

  /**
   * 表示フラグ.
   * 0 : 非表示、1 : 表示
   */
  private String isDisp;

  /**
   * 削除フラグ.
   * 0 : 通常、1 : 削除
   */
  private String isDel;

  /**
   * add by maxueqiang
   * 医療機関コード.
   */
  private String medicalInstitutionCd;

}
