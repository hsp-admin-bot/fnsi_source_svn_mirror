package web.logger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

/**
 * イベントログのプロパティクラス.
 */
@Component
public class EventLoggingProperties extends LoggingProperties {
  /**
   * コンストラクタ.
   *
   * 各引数は以下の通りである.
   * 尚、設定は各アプリケーションが使用するapplication.ymlから取得する.
   * 保存日数 :
   *  ntss.logging.rolling.max-history
   *  ※デフォルト : 14
   *
   * ログファイル名及びローテーション後のログファイル名の {0} には施設コードが設定される.
   * @param maxHistory ログファイル保存日数
   */
  @Autowired
  public EventLoggingProperties(@Value("${ntss.logging.rolling.max-history:14}") int maxHistory) {
    super(maxHistory);
  }
}
