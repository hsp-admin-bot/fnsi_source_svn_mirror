package web.logger;

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
	DEBUG("Debug"),

  // FNSI-修正 ログ対応 xiebzh add start
  /**
   * Mongo
   */
  MONGO("Mongo");
  // FNSI-修正 ログ対応 xiebzh add end

  /**
   * ログレベル
   */
  private final String level;
}
