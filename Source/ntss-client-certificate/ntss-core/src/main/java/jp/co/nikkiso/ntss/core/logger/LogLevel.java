package jp.co.nikkiso.ntss.core.logger;

import lombok.AllArgsConstructor;
import lombok.Getter;

/**
 * ログレベル
 */
@AllArgsConstructor
@Getter
public enum LogLevel {
  /**
   * 情報
   */
  INFO("Info"),
  /**
   * 警告
   */
  WARN("Warning"),
  /**
   * エラー
   */
  ERROR("Error"),
  /**
   * デバッグ
   */
	DEBUG("Debug");

  /**
   * ログレベル
   */
  private final String level;
}
