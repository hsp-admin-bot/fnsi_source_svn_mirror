package jp.co.nikkiso.ntss.core.entity.custom;

import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import lombok.Getter;
import lombok.Setter;

/**
 * 通信サーバ用検査項目マスタクラス
 */
@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class ComsvMstExamItem {

  /**
   * 検査項目コード
   */
  private Long examItemCd;

  /**
   * 検査項目名
   */
  private String examItemName;

  /**
   * 単位
   */
  private String unit;

  /**
   * 小数部桁数
   */
  private int inputDecimalFigure;

  /**
   * グラフ上限値
   */
  private String graphUpper;

  /**
   * グラフ下限値
   */
  private String graphLower;

  //add redmine bug#6766,6767 劉 start
  /**
   * 仮想端末表示対象区分
   */
  private String consoleClass;
  //add redmine bug#6766,6767 劉 end
}
