package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Data;

/**
 * 全施設マスタのCustomEntity.
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Data
public class SysFacilityData {

  /**
   * 施設コード.
   */
  private String facilityCd;
  /* mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 start */  
  /**
   * 医療機関コード.
   */
  private String medicalInstitutionCd;
  /* mod よく使う施設の変更 （施設コードから医療機関コードに主キーを変更。） 杜 end */  
  /**
   * 都道府県コード.
   */
  private String prefCd;

  /**
   * 施設名.
   */
  private String facilityName;

  /**
   * 短縮施設名.
   */
  private String facilityShortName;

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
   * 都道府県名
   */
  private String prefName;

}
