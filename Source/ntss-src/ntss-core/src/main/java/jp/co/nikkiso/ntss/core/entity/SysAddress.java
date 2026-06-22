package jp.co.nikkiso.ntss.core.entity;

import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import jp.co.nikkiso.ntss.core.entity.entityListener.SysAddressEntityListener;
import lombok.Getter;
import lombok.Setter;


/**
 * sys_address(住所マスタ)のエンティティクラス
 */
@Entity(listener = SysAddressEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_address")
@Getter
@Setter
public class SysAddress extends BaseBlankEntity {

  /**
   * 全国地方公共団体コード
   */
  private String cityCd;

  /**
   * （旧）郵便番号（5桁）
   */
  private String zipCdOld;

  /**
   * 郵便番号（7桁）
   */
  private String zipCd;

  /**
   * 都道府県名（カナ）
   */
  private String prefNameKana;

  /**
   * 市区町村名（カナ）
   */
  private String cityNameKana;

  /**
   * 町域名（カナ）
   */
  private String townNameKana;

  /**
   * 都道府県名
   */
  private String prefName;

  /**
   * 市区町村名
   */
  private String cityName;

  /**
   * 町域名
   */
  private String townName;

  /**
   * 一町域が二以上の郵便番号で表される場合の表示
   */
  private String flag1;

  /**
   * 小字毎に番地が起番されている町域の表示
   */
  private String flag2;

  /**
   * 丁目を有する町域の場合の表示
   */
  private String flag3;

  /**
   * 一つの郵便番号で二以上の町域を表す場合の表示
   */
  private String flag4;

  /**
   * 更新の表示
   */
  private String flag5;

  /**
   * 変更理由
   */
  private String flag6;

  /**
   * 住所
   */
  private String address;

  /**
   * 住所（カナ）
   */
  private String addressKana;


  /**
   * 住所検索用文字列
   */
  private String searchString;
}
