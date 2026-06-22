package jp.co.nikkiso.ntss.api.domain.report;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import org.springframework.util.StringUtils;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 帳票定義XMLのparamタグを表すクラス
 */
@Getter
@AllArgsConstructor
public class ReportXmlParam {

  /**
   * 表示種別：SQL実行結果をそのまま表示.
   */
  public static final String DISP_TYPE_NONE = "0";

  /**
   * 表示種別：計算結果を表示.
   */
  public static final String DISP_TYPE_CALC = "1";

  /**
   * データタイプ：文字列
   */
  public static final String DATA_TYPE_STRING = "string";

  /**
   * データタイプ：数値
   */
  public static final String DATA_TYPE_DECIMAL = "decimal";

  /**
   * データタイプ：日付
   */
  public static final String DATA_TYPE_DATE_TIME = "DateTime";

  /**
   * 縮小表示：しない.
   */
  public static final String IS_SHRINK_NO = "0";

  /**
   * 縮小表示：する.
   */
  public static final String IS_SHRINK_YES = "1";

  /**
   * テンプレート繰り返し範囲内かどうか：範囲外.
   */
  public static final String IS_IN_TMPL_NO = "0";

  /**
   * テンプレート繰り返し範囲内かどうか：範囲内.
   */
  public static final String IS_IN_TMPL_YES = "1";

  /**
   * 改ページするかどうか：改ページしない
   */
  public static final String IS_NEW_PAGE_NO = "0";

  /**
   * 改ページするかどうか：改ページする
   */
  public static final String IS_NEW_PAGE_YES = "1";

  /**
   * styleタグのfont-size属性.
   */
  public static final String FONT_SIZE_NAME = "font-size";

 /**
   * 画像.
   */
  private final String isImage;
  // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正　②患者情報の表示のずれが発生　③空白画面の出力問題  吉 start
  private final String repeatAddress ;
  // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正　②患者情報の表示のずれが発生　③空白画面の出力問題  吉 end

  /**
   * id属性
   */
  private final String id;

  /**
   * dispType属性
   */
  private final String dispType;

  /**
   * dataCode属性
   */
  private final String dataCode;

  /**
   * sqlCode属性
   */
  private final String sqlCode;

  /**
   * dataType属性
   */
  private final String dataType;

  /**
   * isShrink属性
   */
  private final String isShrink;

  /**
   * dispLength属性
   */
  private final String dispLength;

  /**
   * filterType属性
   */
  private final String filterType;

  /**
   * dispFormat属性
   */
  private final String dispFormat;

  /**
   * formula属性
   */
  private final String formula;

  /**
   * groupId属性
   */
  private final String groupId;

  /**
   * isInTmpl属性.
   */
  private final String isInTmpl;

  /**
   * isNewPage属性.
   */
  private final String isNewPage;

  /**
   * colWidth属性.
   */
  private final String colWidth;

  // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
  /**
   * rowHeight属性.
   */
  private final String rowHeight;
  // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end

  // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
  /**
   * dataPath属性.
   */
  private final String dataPath;
  // add #11276 キー日付に対するデータ引き当て仕様対応 高　end

  // add 9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について jiang start
  /**
   * rowCount属性.
   */
  private final String rowCount;
  // add 9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について jiang end
  // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
  /**
   * filterList
   */
  private final List<ReportXmlFilterTable> reportXmlFilters;
  // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end

  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
  /**
   * filterList
   */
  private final List<ReportXmlFilter> reportXmlFiltersForMainte;
  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

  /**
   * conv要素のリスト.
   */
  private final List<ReportXmlConv> reportXmlConvs;

  /**
   * group要素.
   */
  private final ReportXmlGroup reportXmlGroup;

  /**
   * formatCondition要素のリスト.
   */
  private final List<ReportXmlFormatCondition> reportXmlFormatConditions;

  /**
   * function要素.
   */
  private final String function;

  /**
   * targetCell要素のリスト.
   */
  private final List<String> targetCells;

  /*
   * tmplRepeat要素.
   */
  private final ReportXmlTmplRepeat reportXmlTmplRepeat;

  // add FNSI-523 2次元帳票対応 夏 start
  /*
   * totalTable要素.
   */
  private final ReportXmlTotalTable reportXmlTotalTable;
  // add FNSI-523 2次元帳票対応 夏 end

  /**
   * particular要素.
   * 例. particular = "Label"
   */
  private final String particular;

  /**
   * dataCode要素のリスト.
   */
  private final Map<String, ReportXmlClassificationDataCode> reportXmlClassificationDataCodes;

  // add #11535 帳票の汎用バーコード出力対応 吉 start
  private final String barCode;
  // add #11535 帳票の汎用バーコード出力対応 吉 end

  /**
   * ファクトリメソッド
   * @param id id属性
   * @param dispType 表示種別
   * @param dataCode データ項目コード
   * @param sqlCode sqlCode属性
   * @param dataType データ型
   * @param isShrink isShrink属性
   * @param dispLength 表示可能文字数
   * @param filterType filterType属性
   * @param dispFormat フォーマット文字列
   * @param formula formula属性
   * @param groupId groupId属性
   * @param isInTmpl isInTmpl属性
   * @param isNewPage isNewPage属性
   * @param colWidth colWidth属性
   * @param reportXmlFilters filterList
   * @param reportXmlConvs conv要素のリスト
   * @param reportXmlGroup group要素
   * @param reportXmlFormatConditions formatConditions要素のリスト
   * @param function function要素
   * @param targetCell targetCell要素
   * @param reportXmlTmplRepeat tmplRepeat要素
   * @param reportXmlTotalTable totalTable要素;
   * @param particular 特殊動作タグ
   * @param reportXmlClassificationDataCodes dataCode(分類別DataCode)要素のリスト
   * @return 帳票定義XMLのparamタグを表すクラス
   */
  public static ReportXmlParam of(
    String isImage,
    // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正　②患者情報の表示のずれが発生　③空白画面の出力問題  吉 start
    String repeatAddress,
    // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正　②患者情報の表示のずれが発生　③空白画面の出力問題  吉 end
    String id,
    String dispType,
    String dataCode,
    String sqlCode,
    String dataType,
    String isShrink,
    String dispLength,
    // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
    String filterType,
    // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
    String dispFormat,
    String formula,
    String groupId,
    String isInTmpl,
    String isNewPage,
    String colWidth,
    // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
    String rowHeight,
    // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
    // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
    String dataPath,
    // add #11276 キー日付に対するデータ引き当て仕様対応 高　end
    // add 9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について jiang start
    String rowCount,
    // add 9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について jiang end
    // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
    List<ReportXmlFilterTable> reportXmlFilters,
    // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
    // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
    List<ReportXmlFilter> reportXmlFiltersForMainte,
    // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
    List<ReportXmlConv> reportXmlConvs,
    ReportXmlGroup reportXmlGroup,
    List<ReportXmlFormatCondition> reportXmlFormatConditions,
    String function,
    String targetCell,
    ReportXmlTmplRepeat reportXmlTmplRepeat,
    // add FNSI-523 2次元帳票対応 夏 start
    ReportXmlTotalTable reportXmlTotalTable,
    // add FNSI-523 2次元帳票対応 夏 end
    String particular,
    Map<String, ReportXmlClassificationDataCode> reportXmlClassificationDataCodes,
    // add #11535 帳票の汎用バーコード出力対応 吉 start
    String barCode
    // add #11535 帳票の汎用バーコード出力対応 吉 end
  ) {
    return new ReportXmlParam(
      isImage,
      // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正　②患者情報の表示のずれが発生　③空白画面の出力問題  吉 start
      repeatAddress,
      // add 8417 【帳票】【紹介状（集計）】①薬剤の表示が不正　②患者情報の表示のずれが発生　③空白画面の出力問題  吉 end
      id,
      dispType,
      dataCode,
      sqlCode,
      dataType,
      isShrink,
      dispLength,
      // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
      filterType,
      // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
      dispFormat,
      formula,
      groupId,
      isInTmpl,
      isNewPage,
      colWidth,
      // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 start
      rowHeight,
      // add #6077 透析レポートのグラフの縮尺が正しくない 王永吉 end
      // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
      dataPath,
      // add #11276 キー日付に対するデータ引き当て仕様対応 高　end
      // add 9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について jiang start
      rowCount,
      // add 9397 表示文字列長の設定、およびフリー計算パラメータの書式設定について jiang end
      // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
      reportXmlFilters,
      // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
      // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
      reportXmlFiltersForMainte,
      // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
      reportXmlConvs,
      reportXmlGroup,
      reportXmlFormatConditions,
      function,
      Arrays.asList(Optional.ofNullable(targetCell).orElse("").split(",")),
      reportXmlTmplRepeat,
      // add FNSI-523 2次元帳票対応 夏 start
      reportXmlTotalTable,
      // add FNSI-523 2次元帳票対応 夏 end
      particular,
      reportXmlClassificationDataCodes,
      // add #11535 帳票の汎用バーコード出力対応 吉 start
      barCode
      // add #11535 帳票の汎用バーコード出力対応 吉 end
    );
  }

  /**
   * 計算を実施する式かどうか.
   * @return 計算を実施する式の場合、<code>true</code>、それ以外の場合、<code>false</code>
   */
  public boolean isFormulaToCalc() {
    return DISP_TYPE_CALC.equals(dispType) && !StringUtils.isEmpty(formula);
  }

  /**
   * 縮小表示をするかどうか.
   * @return 縮小表示をする場合、<code>true</code>、しない場合、<code>false</code>
   */
  public boolean needShrink() {
    return isShrink.equals(ReportXmlParam.IS_SHRINK_YES) && !StringUtils.isEmpty(colWidth);
  }

  /**
   * 関数定義があるかどうか.
   * @return 関数定義がある場合、<code>true</code>、ない場合、<code>false</code>
   */
  public boolean hasFunction() {
    return !StringUtils.isEmpty(function);
  }

  /**
   * テンプレート繰り返し対象かどうか.
   * @return テンプレート繰り返し対象の場合、<code>true</code>、それ以外の場合、<code>false</code>
   */
  public boolean isTmplRepeat() {
    return IS_IN_TMPL_YES.equals(isInTmpl) && reportXmlTmplRepeat != null;
  }
}
