package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.SysCountryEntityListener;
import lombok.Getter;
import lombok.Setter;

/**
 * 国名クラス
 */
@Entity(listener = SysCountryEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_country")
@Getter
@Setter
public class SysCountry extends BaseBlankEntity {
  /**
   * 国名コード(alpha-3)
   */
  @Id
  private String countryCdAlpha3;
  /**
   * 国名コード(alpha-2)
   */
  private String countryCdAlpha2;
  /**
   * 国名コード(Numeric)
   */
  private String countryCdNumeric;
  /**
   * 国名
   */
  private String countryName;
  /**
   * 国名(英語)
   */
  private String countryNameAlpha;
  /**
   * 地域
   */
  private String region;
}
