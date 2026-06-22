package jp.co.nikkiso.ntss.api.domain.report;

import lombok.AllArgsConstructor;
import lombok.Getter;

// add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
/**
 * 帳票定義XMLのfilterTableタグを表すクラス.
 */
@Getter
@AllArgsConstructor
public class ReportXmlFilterTable {
  /**
   * code属性.
   */
  private final String code;

  /**
   * before属性.
   */
  private final String before;

  /**
   * after属性.
   */
  private final String after;

  /**
   * other属性.
   */
  private final String other;
}
// add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
