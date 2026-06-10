package jp.co.nikkiso.ntss.core.entity;

import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

/**
 * 施設マスタのEntity.
 */
@Entity(naming=NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_facility")
@Getter
@Setter
public class SysFacility extends BaseEntity {
  /**
   * 施設コード.
   */
  private String facilityCd;
  
  /**
   * 都道府県コード.
   */
  private String prefecturesCd;
  
  /**
   * 施設名.
   */
  private String facilityName;
  
  /**
   * 短縮施設名.
   */
  private String facilityShortName;
  
  /**
   * JSDT施設コード.
   */
  private String jsdtFacilityCd;
  
  /**
   * 医療機関コード.
   */
  private String medicalInstitutionCd;
  
  /**
   * 郵便番号.
   */
  private String zipcd;
  
  /**
   * 住所.
   */
  private String address;
  
  /**
   * 住所カナ.
   */
  private String addressKana;
  
  /**
   * 電話番号1.
   */
  private String phoneNo1;
  
  /**
   * 電話番号2.
   */
  private String phoneNo2;
  
  /**
   * FAX1.
   */
  private String faxNo1;
  
  /**
   * FAX2.
   */
  private String faxNo2;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;
}

