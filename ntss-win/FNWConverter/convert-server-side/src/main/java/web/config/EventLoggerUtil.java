package web.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import web.logger.*;

@Component
public class EventLoggerUtil {

    private static final String serverName = "Convert";

    /**
     * ロガー生成コンポーネント
     */
     @Autowired
     private EventLoggerFactory eventLoggerFactory;

    /**
     * EventLogMessage作成
     *
     * @param mes ログメッセージ
     * @param facilityCd 施設コード
     * @param functionName メソッド名
     * @return EventLogMessage
     */
    public EventLogMessage getEventLogMessage(String mes, String facilityCd, String functionName){
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(mes);
        eventLogMessage.setFacilityCd(facilityCd);
        eventLogMessage.setServiceName(serverName);
        eventLogMessage.setFunctionName(functionName);
        eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
        return eventLogMessage;
    }

    /**
     * ロギングツールの方法
     *
     * @param facilityCd 施設コード
     * @param eventLogMessage EventLogMessage
     * @param logLevel ログレベル
     */
    public void recordLog(String facilityCd, EventLogMessage eventLogMessage, LogLevel logLevel){
        EventLogger loggers = eventLoggerFactory.getLogger(facilityCd, LogClass.APP);
        switch (logLevel){
            case INFO:
                loggers.info(eventLogMessage);
                break;
            case WARN:
                loggers.warn(eventLogMessage);
                break;
            case DEBUG:
                loggers.debug(eventLogMessage);
                break;
            case ERROR:
                loggers.error(eventLogMessage);
                break;
            default:
                loggers.info(eventLogMessage);
                break;
        }
    }

    /**
     * 詳細な例外スタック情報を出力
     * @param e
     * @return
     */
    public static String excetionStackTraceToString(Exception e) {
        StringBuilder strbuff = new StringBuilder();
        for (StackTraceElement stet : e.getStackTrace()) {
            strbuff.append(stet + "\n");
        }
        return e.getClass().getName() + ":" + e.getMessage() + ":" + strbuff.toString();
    }
}
