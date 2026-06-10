package jp.co.nikkiso.ntss.device_edge.service.download.impl;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.download.DownloadFileService;
import org.seasar.doma.DomaException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class DownloadFileServiceImpl implements DownloadFileService {

  private final LogService logService;
  private final SysSystemDefineDao sysSystemDefineDao;

  private final ObjectMapper objectMapper;

  @Autowired
  public DownloadFileServiceImpl(LogService logService, SysSystemDefineDao sysSystemDefineDao, ObjectMapper objectMapper) {
    this.logService = logService;
    this.sysSystemDefineDao = sysSystemDefineDao;
    this.objectMapper = objectMapper;
  }

  /** オンプレミスSettings */
  @Override
  public Map<String, String> getSystemDefineOfPremise() {

    try {
      SysSystemDefine data = this.sysSystemDefineDao.selectOnPremise(CoreConstant.SysSystemDefine.CTL_NO_ON_PREMISE);
      return this.objectMapper.readValue(data.getValue(), new TypeReference<HashMap<String, String>>(){});
    } catch (DomaException | JsonProcessingException e) {
      // Error Logs
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      eventLogMessage.setInvokeClass(this.getClass().getName());
      logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.REMS, null);
      // return empty
      return null;
    }
  }
}
