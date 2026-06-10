package jp.co.nikkiso.ntss.core.entity;

import java.math.BigDecimal;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class MstExamRecordItem extends BaseEntity {
  /**
   * システムで管理する一意な検査項目ID
   */
  private Long itemCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * FNW+内使用検査項目コード
   */
  private String fnExamItemCd;

  /**
   * 検査項目名
   */
  private String itemName;

  /**
   * データ形式
   */
  private String type;

  /**
   * 単位
   */
  private String unit;

  /**
   * 正常値区分
   */
  private String normalValueClass;

  /**
   * 正常値(上限)
   */
  private BigDecimal upper;

  /**
   * 正常値(下限)
   */
  private BigDecimal lower;

  /**
   * 正常値(男性上限)
   */
  private BigDecimal normalValueUpperM;

  /**
   * 正常値(男性下限)
   */
  private BigDecimal normalValueLowerM;

  /**
   * 正常値(女性上限)
   */
  private BigDecimal normalValueUpperW;

  /**
   * 正常値(女性下限)
   */
  private BigDecimal normalValueLowerW;

  /**
   * 入力整数部桁数
   */
  private Integer inputIntegerFigure;

  /**
   * 入力小数部桁数
   */
  private Integer inputDecimalFigure;

  /**
   * 入力上限値
   */
  private BigDecimal inputUpper;

  /**
   * 入力下限値
   */
  private BigDecimal inputLower;

  /**
   * グラフ上限値
   */
  private BigDecimal graphUpper;

  /**
   * グラフ下限値
   */
  private BigDecimal graphLower;

  /**
   * 仮想端末表示対象区分
   */
  private String consoleClass;

  /**
   * 検査使用区分
   */
  private String examClass;

  /**
   * 連携コード1
   */
  private String inHospitalCd1;

  /**
   * 属性コード1
   */
  private String sbtCd1;

  /**
   * 連携コード2
   */
  private String inHospitalCd2;

  /**
   * 属性コード2
   */
  private String sbtCd2;

    /**
   * 連携コード3
   */
  private String inHospitalCd3;

  /**
   * 属性コード3
   */
  private String sbtCd3;

  /**
   * 採血管コード
   */
  private String spitzCd;

  /**
   * JLAC10コード
   */
  private String jlac10Cd;

  /**
   * 感染症コード
   */
  private String infectionCd;

  /**
   * システム標準計算項目
   */
  private String defaultCalcExamItemCd;

  /**
   * 計算式領域
   */
  private String freeCalc;

  /**
   * 表示フラグ
   */
  private String isDisp;

  /**
   * 削除フラグ
   */
  private String isDel;

}
