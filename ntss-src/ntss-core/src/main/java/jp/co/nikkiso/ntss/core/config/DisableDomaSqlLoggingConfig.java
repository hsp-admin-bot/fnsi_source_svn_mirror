package jp.co.nikkiso.ntss.core.config;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.context.annotation.Configuration;

import javax.annotation.PostConstruct;
import java.util.logging.Level;
import java.util.logging.Logger;
/**
 * 構成クラス: Doma フレームワークの SQL ログを閉じるために使用されます。
 *
 */
@Configuration
public class DisableDomaSqlLoggingConfig {

  @PostConstruct
  public void disable(){
    Logger domaLogger = Logger.getLogger("org.seasar.doma.jdbc.UtilLoggingJdbcLogger");
    // 「org.seasar.doma.jdbc.UtilLoggingJdbcLogger」の印刷ログをオフにする
    domaLogger.setLevel(Level.OFF);
    // org.seasar.doma が生成したログを閉じます。
//    Logger.getLogger("org.seasar.doma").setLevel(Level.OFF);
  }
}
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
