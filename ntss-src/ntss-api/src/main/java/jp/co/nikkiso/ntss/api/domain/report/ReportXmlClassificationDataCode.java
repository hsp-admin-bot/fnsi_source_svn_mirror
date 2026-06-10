/**
 *
 */
package jp.co.nikkiso.ntss.api.domain.report;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 帳票定義XMLのdataCode(分類別DataCode)タグを表すクラス.
 */
@Getter
@AllArgsConstructor
public class ReportXmlClassificationDataCode {

  /**
   * dataCode属性.
   */
  private final String dataCode;

  /**
   * fixString(固定文字列)属性.
   */
  private final String fixString;

}
