package jp.co.nikkiso.ntss.admin_web.service.utils;

import jp.co.nikkiso.ntss.admin_web.service.IndHistoryMakeService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * IndHistory処理完了後のクリーンアップインターセプター
 * リクエスト終了時にThreadLocalをクリーンアップし、
 * すべてのindHistory登録完了後にJournal作成APIを呼び出す
 */
@Component
public class IndHistoryCleanupInterceptor implements HandlerInterceptor {

    @Autowired
    private IndHistoryMakeService indHistoryMakeService;

    @Autowired
    private LogService logService;

    @PostConstruct
    public void init() {
        try {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("IndHistoryCleanupInterceptor initialized successfully");
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        } catch (Exception e) {
            // logServiceが使用できない場合のフォールバック（起動時のみ）
        }
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String requestUri = request.getRequestURI();
        long threadId = Thread.currentThread().getId();

        try {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("[DEBUG] preHandle called. URI=" + requestUri + ", thread=" + threadId);
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        } catch (Exception logEx) {
            // ログ出力に失敗した場合は無視
        }

        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        long threadId = Thread.currentThread().getId();
        String requestUri = request.getRequestURI();

        try {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("[DEBUG] afterCompletion called. URI=" + requestUri +
                ", thread=" + threadId + ", exception=" + (ex != null ? ex.getClass().getSimpleName() : "null"));
            logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
        } catch (Exception logEx) {
            // ログ出力に失敗した場合は無視
        }

        try {
            /**
             * リクエスト終了時にIndHistoryのThreadLocalをクリーンアップし、
             * キューに蓄積されたindHistoryに対してJournal作成APIを呼び出す
             */
            indHistoryMakeService.clearRequestCache();

            try {
                EventLogMessage eventLogMessage = new EventLogMessage();
                eventLogMessage.setLogMessage("clearRequestCache completed successfully. URI=" + requestUri + ", thread=" + threadId);
                logService.log(LogLevel.INFO, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
            } catch (Exception logEx) {
                // ログ出力に失敗した場合は無視
            }

        } catch (Exception e) {
            try {
                EventLogMessage eventLogMessage = new EventLogMessage();
                eventLogMessage.setLogMessage("clearRequestCache failed. URI=" + requestUri +
                    ", thread=" + threadId + ", error=" + e.getMessage());
                logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
            } catch (Exception logEx) {
                // ログ出力に失敗した場合は無視
            }
            throw e;
        }
    }
}