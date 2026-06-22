package jp.co.nikkiso.ntss.admin_web.service.indHistory;

import lombok.Getter;
import lombok.Setter;

/**
 * 指示履歴の任意検索パラメータ
 */
@Getter
@Setter
public class IndHistoryOptions {
  /**
   * 発行開始日
   */
  private String logDateStart;

  /**
   * 発行終了日
   */
  private String logDateEnd;

  /**
   * フリーワード
   */
  private String searchString;
}
