package jp.co.nikkiso.ntss.core.entity.custom;

import java.math.BigDecimal;
import org.seasar.doma.Entity;
import org.seasar.doma.Table;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * mst_exam_item(検査項目マスタ)の患者結果一覧用エンティティクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_exam_item")
@Getter
@Setter
public class MstExamItemForExamRecordDetail {
  /**
   * システムで管理する一意な検査項目ID
   */
  private long examItemCd;

  /**
   * 施設コード
   */
  private String facilityCd;

  /**
   * 検査項目名
   */
  private String examItemName;

  /**
   * データ形式
   */
  private String dataType;

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
  private BigDecimal normalValueUpper;
  
  /**
   * 正常値(下限)
   */
  private BigDecimal normalValueLower;
  
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


}
