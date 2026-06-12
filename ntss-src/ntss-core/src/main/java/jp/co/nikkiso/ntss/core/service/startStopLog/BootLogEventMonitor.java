package jp.co.nikkiso.ntss.core.service.startStopLog;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.boot.tomcat.TomcatWebServer;
import org.springframework.boot.web.server.context.WebServerApplicationContext;
import org.springframework.context.ApplicationContext;
import org.springframework.context.event.EventListener;
import org.springframework.stereotype.Component;

import jakarta.annotation.PreDestroy;

@Component
public class BootLogEventMonitor {

    @Autowired
    private ApplicationContext applicationContext;

    @Autowired
    private StartStopLogService osBootLogService;

    private boolean isExternalTomcat = false;

    /**
     * ApplicationReadyEvent アプリケーション起動完了時刻を記録するために使用
     * - アプリケーションコンテキストが完全に準備され、リクエストを処理できる状態
     */
    @EventListener(ApplicationReadyEvent.class)
    public void onContextRefreshed(ApplicationReadyEvent event) {
        // Windowsシステムの場合、開発環境であるため、ログを記録しない
        if ( "\\".equals(System.getProperty("file.separator")) ) {
          return;
        }
        // Spring Boot jar起動か、Tomcat war起動かを判定
        isExternalTomcat = !isEmbeddedTomcatStarted();
        // Tomcat war起動の場合
        if (isExternalTomcat) {
            osBootLogService.warBootLog();
            osBootLogService.tomcatBootLog();
        } else { // Spring Boot jar起動
            osBootLogService.jarBootLog();
        }
        osBootLogService.osBootLog();
        osBootLogService.osDownLog();
    }

    /**
     * @PreDestroy：Bean破棄前に実行（ContextClosedEventより早く、この時点でmongoTemplateは完全に利用可能）
     */
    @PreDestroy
    public void beforeDestroy() {
        // Windowsシステムの場合、開発環境であるため、ログを記録しない
        if ( "\\".equals(System.getProperty("file.separator")) ) {
          return;
        }
        // Tomcat war起動の場合
        if (isExternalTomcat) {
            osBootLogService.warDownLog();
            osBootLogService.tomcatDownLog();
        } else { // Spring Boot jar起動
            osBootLogService.jarDownLog();
        }
    }

    /**
     * Spring Boot jar起動か、Tomcat war起動かを判定
     * 組み込みTomcatWebServerが実際に初期化され起動しているかをチェック
     */
    private boolean isEmbeddedTomcatStarted() {
        try {
            // まず組み込みコンテナのコンテキストかどうかを判定
            if (applicationContext instanceof WebServerApplicationContext) {
                WebServerApplicationContext webServerContext = (WebServerApplicationContext) applicationContext;
                // 組み込みWebServerインスタンスを取得
                if (webServerContext.getWebServer() instanceof TomcatWebServer) {
                    TomcatWebServer tomcatWebServer = (TomcatWebServer) webServerContext.getWebServer();
                    // 組み込みTomcat起動後、getPort()は実際にバインドされたポートを返す（-1以外）
                    return tomcatWebServer.getPort() != -1;
                }
            }
        } catch (Exception e) {
            // いかなる例外も → 組み込みTomcatが起動していないことを示す
            return false;
        }
        return false;
    }

}
