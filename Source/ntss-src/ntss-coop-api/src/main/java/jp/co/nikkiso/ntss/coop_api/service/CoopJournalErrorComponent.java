package jp.co.nikkiso.ntss.coop_api.service;

import jp.co.nikkiso.ntss.coop_api.utils.NotificationApiCallUtil;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class CoopJournalErrorComponent {
  @Autowired
  MstUserDao mstUserDao;
  @Autowired
  private LogService logService;
  @Autowired
  private NotificationApiCallUtil notificationApiCallUtil;

  public void sendCoopJournalError(SysCoopJournal journal) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(journal.getFacilityCd());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      eventLogMessage.setLogMessage("ctlNo: "+journal.getCtlNo()+
        "; ordNo: "+journal.getOrdNo()+
        "; facilityCd:"+journal.getFacilityCd()+
        "; coopCd:"+journal.getCoopCd()+
        "; hospPatId:"+journal.getHospPatId()+
        "; baseDate:"+journal.getBaseDate());
      logService.log(LogLevel.WARN, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      notificationApiCallUtil.registerNotification(journal.getCtlNo(),journal.getOrdNo(),journal.getFacilityCd(), journal.getCoopCd(),
        journal.getHospPatId(), journal.getBaseDate());
  }
}
