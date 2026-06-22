package jp.co.nikkiso.ntss.coop_api.telegram.helper;

import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

/**
 * {@code TelegramLogger} は、連携電文処理における共通的なログ出力機能を提供するユーティリティクラスです。
 *
 * <p>
 * ログレベル（DEBUG、INFO、WARN、ERROR）に応じた出力を簡易に行えるインタフェースを提供し、
 * {@link LogService} を通じてログ出力されます。
 * </p>
 */
@Component
public class TelegramLogger {

    /** ログ出力に使用するサービス識別子 */
    private static final String SERVICE = SERVICE_NAME.FNSI;

    private final LogService logService;

    /**
     * {@code TelegramLogger} のコンストラクタ。
     *
     * @param logService 内部ログ基盤と接続する {@link LogService}
     */
    public TelegramLogger(LogService logService) {
        this.logService = logService;
    }

    /**
     * INFO レベルのログを出力します。
     *
     * @param clazz      呼び出し元クラス
     * @param facilityCd 対象施設コード
     * @param format     {@link String#format} 形式のログメッセージ
     * @param args       メッセージ埋め込み変数
     */
    public void info(Class<?> clazz, String facilityCd, String format, Object... args) {
        log(LogLevel.INFO, clazz, facilityCd, format, args);
    }

    /**
     * WARN レベルのログを出力します。
     *
     * @param clazz      呼び出し元クラス
     * @param facilityCd 対象施設コード
     * @param format     {@link String#format} 形式のログメッセージ
     * @param args       メッセージ埋め込み変数
     */
    public void warn(Class<?> clazz, String facilityCd, String format, Object... args) {
        log(LogLevel.WARN, clazz, facilityCd, format, args);
    }

    /**
     * ERROR レベルのログを出力します。
     *
     * @param clazz      呼び出し元クラス
     * @param facilityCd 対象施設コード
     * @param format     {@link String#format} 形式のログメッセージ
     * @param args       メッセージ埋め込み変数
     */
    public void error(Class<?> clazz, String facilityCd, String format, Object... args) {
        log(LogLevel.ERROR, clazz, facilityCd, format, args);
    }

    /**
     * DEBUG レベルのログを出力します。
     *
     * @param clazz      呼び出し元クラス
     * @param facilityCd 対象施設コード
     * @param format     {@link String#format} 形式のログメッセージ
     * @param args       メッセージ埋め込み変数
     */
    public void debug(Class<?> clazz, String facilityCd, String format, Object... args) {
        log(LogLevel.DEBUG, clazz, facilityCd, format, args);
    }

    /**
     * 内部的に共通のログ出力処理を実行します。
     *
     * @param level      ログレベル
     * @param clazz      呼び出し元クラス
     * @param facilityCd 対象施設コード（null 可）
     * @param format     {@link String#format} 形式のメッセージ
     * @param args       メッセージ埋め込み変数
     */
    private void log(LogLevel level,
            Class<?> clazz,
            String facilityCd,
            String format,
            Object... args) {
        Object[] safeArgs = args != null ? args : new Object[0];
        String message = String.format(format, safeArgs);

        EventLogMessage logMessage = new EventLogMessage();
        logMessage.setLogMessage(message);
        logMessage.setFacilityCd(facilityCd);
        logMessage.setInvokeClass(clazz.getName());

        logService.log(level, logMessage, null, SERVICE, null);
    }
}
