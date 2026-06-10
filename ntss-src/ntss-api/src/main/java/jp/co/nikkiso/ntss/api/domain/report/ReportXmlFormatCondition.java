package jp.co.nikkiso.ntss.api.domain.report;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 帳票定義XMLのformatConditionタグを表すクラス.
 */
@Getter
@AllArgsConstructor
public class ReportXmlFormatCondition {

  /**
   * comparisonOperator属性.
   */
  private final String comparisonOperator;

  /**
   * value属性.
   */
  private final String value;

  /**
   * TextContent.
   */
  private final String textContent;

}
