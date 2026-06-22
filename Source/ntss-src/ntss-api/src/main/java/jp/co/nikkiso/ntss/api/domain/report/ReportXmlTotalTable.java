package jp.co.nikkiso.ntss.api.domain.report;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 帳票定義XMLのtmplRepeatタグを表すクラス.
 */
@Getter
@AllArgsConstructor
public class ReportXmlTotalTable {

  /**
   * 横の集計単位属性.
   */
  private final String unitV;

  /**
   * 集計単位日付属性.
   */
  private final String unitDate;

  /**
   * 縦の集計単位属性.
   */
  private final String unitH;

  // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe start
  /**
   * 「出力値のない列は省略する」設定属性.
   */
  private final String effectDataV;
  // add #12013 集計内訳に横単位の「出力値のない列は省略する」設定を追加 limingzhe end

  // add #12218 集計の縦単位でも値のない行が出力できない limingzhe start
  /**
   * 「出力値のない行は省略する」設定属性.
   */
  private final String effectDataH;
  // add #12218 集計の縦単位でも値のない行が出力できない limingzhe end

  /**
   * 表示内容属性.
   */
  private final String contents;

  // add #11973 日常点検一覧帳票が正常に出せない limingzhe start
  /**
   * 表示内容種類.
   */
  private final String contentsType;
  // add #11973 日常点検一覧帳票が正常に出せない limingzhe end

  /**
   * 表示変換属性.
   */
  private final String conversion;

  /**
   * 縦の合計属性.
   */
  private final String countH;

  /**
   * 横の合計属性.
   */
  private final String countV;

  /**
   * 起点セル属性.
   */
  private final String originRange;

  // add 11011 集計内訳タブ仕様変更 高 start
  /**
   * 横方向のセルの座標
   *
   * */
  private final String unitVAddress;

  /**
   * 縦方向のセルの座標
   * */
  private final String unitHAddress;
  // add 11011 集計内訳タブ仕様変更 高 end
}
