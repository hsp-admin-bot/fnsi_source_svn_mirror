package jp.co.nikkiso.ntss.web_api.util;

import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

public class ErrorMessageUtil {

  public static EventLogMessage createMessage(String facilityCd, String msg) {
    EventLogMessage elm = new EventLogMessage();
    elm.setFacilityCd(facilityCd);
    elm.setLogMessage(msg);
    return elm;
  }
}
