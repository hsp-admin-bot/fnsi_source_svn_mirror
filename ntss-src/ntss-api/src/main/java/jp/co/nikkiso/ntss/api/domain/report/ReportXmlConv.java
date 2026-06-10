package jp.co.nikkiso.ntss.api.domain.report;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 帳票定義XMLのconvタグを表すクラス.
 */
@Getter
@AllArgsConstructor
public class ReportXmlConv {

  /**
   * code属性.
   */
  private final String code;

  /**
   * item属性.
   */
  private final String item;

  /**
   * disp属性.
   */
  private final String disp;

}
