package jp.co.nikkiso.ntss.core.config;

import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;

import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLogger;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogClass;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;

public class NtssSecurityPoricy {

  private static final String SYSTEM = "system";

    /**
     * アクセスキーチェック関数
     * @param request
     * @param response
     * @return
     */
    public static boolean doAccessKeyCheck(ServletRequest request, ServletResponse response, EventLoggerFactory eventLoggerFactory) {
        boolean ret = false;
    	final String ACCESS_KEY = "SSECCAYEK";
    	final String KEY_VALUE = "NTSS-NKK-ESM-TDC-YSK";

    	EventLogMessage eventLogMessage = new EventLogMessage();
        // 本アプリケーションが稼働しているIPアドレスを取得
        eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
        eventLogMessage.setServiceName("");
    	EventLogger logger = eventLoggerFactory.getLogger(SYSTEM, LogClass.APP);

        HttpServletRequest sr = (HttpServletRequest)request;
        StringBuffer requestURL = sr.getRequestURL();
        eventLogMessage.setLogMessage("AccessURL:" + requestURL);
        logger.info(eventLogMessage);

        String headerStr = sr.getHeader(ACCESS_KEY);
        if (headerStr != null && headerStr.equals(KEY_VALUE)) {
    		ret = true;
        }
        else
        {
    		ret = false;
        }

        return ret;
    }
}




