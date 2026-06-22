package jp.co.nikkiso.ntss.core.logger;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * ログ区分
 */
@Getter
@AllArgsConstructor
public enum LogClass {
  /**
   * イベントログ
   */
  EVENT(0),

  /**
   * アプリケーションログ
   */
  APP(1);

  /**
   * ログ区分
   */
  private final int logClass;
}
