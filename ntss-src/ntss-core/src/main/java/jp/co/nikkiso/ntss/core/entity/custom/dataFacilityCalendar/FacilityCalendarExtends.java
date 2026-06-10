package jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCoreImpl;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.Getter;
import lombok.Setter;
import org.seasar.doma.Entity;
import org.seasar.doma.jdbc.entity.NamingType;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Entity(naming = NamingType.SNAKE_LOWER_CASE)
@Getter
@Setter
public class FacilityCalendarExtends extends FacilityCalendar{
  private String itemCd;

  @Override
  public FacilityCalendarExtends clone() {
    FacilityCalendarExtends fac = null;
    try {
      fac = (FacilityCalendarExtends)super.clone();
    } catch (Exception e) {
//      e.printStackTrace();
      LogServiceCoreImpl logServiceCore = new LogServiceCoreImpl();
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (logServiceCore != null) {
        logServiceCore.log(LogLevel.ERROR, eventLogMessage, "", null, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }
    return fac;
  }
}
