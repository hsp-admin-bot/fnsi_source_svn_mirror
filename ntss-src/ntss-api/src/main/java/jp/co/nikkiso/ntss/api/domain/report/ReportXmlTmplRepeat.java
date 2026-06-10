package jp.co.nikkiso.ntss.api.domain.report;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 帳票定義XMLのtmplRepeatタグを表すクラス.
 */
@Getter
@AllArgsConstructor
public class ReportXmlTmplRepeat {

  /**
   * 繰り返し方向：N型(縦).
   */
  public static final String DIRECTION_N = "0";

  /**
   * 繰り返し方向：Z型(横).
   */
  public static final String DIRECTION_Z = "1";

  /**
   * 繰り返しモード：透析日モード.
   */
  public static final String REPEAT_MODE_DIALYSIS = "Dialysis";

  /**
   * 繰り返しモード：検査日モード.
   */
  public static final String REPEAT_MODE_EXAMIN = "Examin";

  /**
   * 改ページするかどうか：改ページしない
   */
  public static final Integer IS_NEW_PAGE_NO = 0;

  /**
   * 改ページするかどうか：改ページする
   */
  public static final Integer IS_NEW_PAGE_YES = 1;

  /**
   * id属性.
   */
  private final String id;

  // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 start
  /**
   * 繰返回数(縦)属性.
   */
  private final Integer repeatCountH;

  /**
   * 繰返回数(横)属性.
   */
  private final Integer repeatCountV;

  /**
   * 余白(縦)属性.
   */
  private final Integer marginV;

  /**
   * 余白(横)属性.
   */
  private final Integer marginH;
  // add 2020-12-18 FNSI-改修 ファイル保存のExcel出力不正 夏 end

  /**
   * repeatMax属性.
   */
  private final Integer repeatMax;

  /**
   * repeatMode属性.
   */
  private final String repeatMode;

  /**
   * key属性.
   */
  private final String key;

  /**
   * isNewPage属性.
   */
  private final Integer isNewPage;

  /**
   * direction属性.
   */
  private final String direction;

  /**
   * baseSqlCd属性.
   */
  private int baseSqlCd;

  /**
   * joinSqlCd属性
   */
  private int joinSqlCd;

}
