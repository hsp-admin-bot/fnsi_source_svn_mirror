package jp.co.nikkiso.ntss.api.domain.report;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * 帳票定義XMLのfilterタグを表すクラス.
 */
@Getter
@AllArgsConstructor
public class ReportXmlFilter {

  /**
   * item属性.
   */
  private final String item;

  /**
   * col属性.
   */
  private final String col;

  // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする sunsy start
  /**
   * code属性.
   */
  private final String code;
  // add #10372 フィルタの種類によってグループタブからフィルタ設定できるようにする sunsy end

}
