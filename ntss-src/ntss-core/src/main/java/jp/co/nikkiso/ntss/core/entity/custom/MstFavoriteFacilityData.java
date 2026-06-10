package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Data;

/**
 * よく使う施設マスタのcustomEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Data
public class MstFavoriteFacilityData {

  /**
   * マスターコード.
   */
  private Long masterCd;

  /**
   * 施設コード.
   */
  private String facilityCd;
  
  /**
   * 医療機関コード.
   */
  private String medicalInstitutionCd;
  
  /**
   * お気に入り施設コード.
   */
  private String favoriteFacilityCd;

  /**
   * お気に入り施設名.
   */
  private String favoriteFacilityName;

  /**
   * 都道府県コード.
   */
  private String prefCd;

  /**
   * 都道府県.
   */
  private String prefName;

  /**
   * 住所.
   */
  private String address;

  /**
   * 電話番号.
   */
  private String phoneNo;

  /**
   * FAX.
   */
  private String faxNo;

  /**
   * 表示フラグ.
   */
  private String isDisp;

  /**
   * よく使う施設マスタの削除フラグ.
   */
  private String isFavDel;

  /**
   * 全施設マスタの削除フラグ.
   */
  private String isSysDel;

}
