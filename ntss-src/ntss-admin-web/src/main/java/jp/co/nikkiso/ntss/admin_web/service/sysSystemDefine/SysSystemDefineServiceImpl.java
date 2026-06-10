package jp.co.nikkiso.ntss.admin_web.service.sysSystemDefine;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

@Service
public class SysSystemDefineServiceImpl implements SysSystemDefineService {
  
  @Autowired
  private SysSystemDefineDao sysSystemDefineDao;
  
  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;

  /**
   * {@inheritDoc} 
   */
  @Override
  public List<SysSystemDefine> getSysSystemDefine(int ctlNo) {

    List<SysSystemDefine> data;
    try {
      data = this.sysSystemDefineDao.selectByCtlNo(ctlNo);
    } catch (Exception e) {
      data = null;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setSqlIdentification("(ctl_no = " + ctlNo + ")");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "SysSystemDefineDao/selectByCtlNo");
    }
    
    return data;
  }

}
