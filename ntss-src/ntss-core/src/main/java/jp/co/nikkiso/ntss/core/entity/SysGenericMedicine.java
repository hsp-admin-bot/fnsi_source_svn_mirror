package jp.co.nikkiso.ntss.core.entity;

import jp.co.nikkiso.ntss.core.entity.entityListener.CommonEntityListener;
import org.seasar.doma.Entity;
import org.seasar.doma.Id;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;
/**
 * 一般名処方クラス
 */
@Entity(listener = CommonEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "sys_generic_medicine")
@Getter
@Setter
public class SysGenericMedicine extends BaseEntity {

  /**
   * 区分
   */
  @Id
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou start
  //private String medicineType;
  private Integer medicineType;
  // mod #7475 コンバートしたord_mainにデータが正常な形でコンバートされていない dou end

  /**
   * 一般名コード
   */
  @Id
  private String genericCd;

  /**
   * 一般名処方の標準的な記載
   */
  private String genericName;

  /**
   * 成分名
   */
  private String ingredient;

  /**
   * 規格
   */
  private String strength;

  /**
   * 第一単位
   */
  private String unitFirst;

  /**
   * 第二単位
   */
  private String unitSecond;

  /**
   * 一般名処方加算対象
   */
  private String additionType;

  /**
   * 例外コード
   */
  private String exceptionCd;

  /**
   * 同一剤形・規格内の最低薬価
   */
  private String minPrice;

  /**
   * 備考
   */
  private String notes;

  /**
   * 検索コードリスト
   */
  private String searchCodeList;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

}
