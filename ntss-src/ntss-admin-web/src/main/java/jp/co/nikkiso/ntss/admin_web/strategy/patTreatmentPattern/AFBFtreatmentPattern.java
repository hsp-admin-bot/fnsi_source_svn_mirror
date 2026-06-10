package jp.co.nikkiso.ntss.admin_web.strategy.patTreatmentPattern;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ObjectNode;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.PatTreatmentPatternDao;
import jp.co.nikkiso.ntss.core.entity.OrdMainOnly;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import static jp.co.nikkiso.ntss.admin_web.strategy.PatTreatmentPatternFactory.regist;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Component
public class AFBFtreatmentPattern implements PatTreatmentPatternStategy, InitializingBean {
  @Autowired
  PatTreatmentPatternDao patTreatmentPatternDao;

  // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
  @Autowired
  private LogService logService;
// #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end

  // 透析液
  public static final String IND_COND_INFO_15 = "15";
  // 補液
  public static final String IND_COND_INFO_19 = "19";
  public static final String IND_COND_INFO_20 = "20";
  public static final String IND_COND_INFO_21 = "21";
  public static final String IND_COND_INFO_22 = "22";
  public static final String IND_COND_INFO_23 = "23";
  public static final String IND_COND_INFO_24 = "24";
  public void update(OrdMainOnly ord, String facilityCd, Integer code) {
    try {
      // 15->null  19 ->null
      ObjectMapper mapper = new ObjectMapper();
      ObjectNode jsonNodes = mapper.readValue(ord.getIndCondInfoForMerge(), ObjectNode.class);
      ObjectNode root = mapper.createObjectNode();
//      jsonNodes.put(IND_COND_INFO_15, root);
//      jsonNodes.put(IND_COND_INFO_19, root);
      // HD/ECUM
      if ("0".equals(ord.getOldDeviceMode()) || "1".equals(ord.getOldDeviceMode())) {
        jsonNodes.put(IND_COND_INFO_19,mapper.readValue("{\"value\":null}", JsonNode.class));
        jsonNodes.put(IND_COND_INFO_20,mapper.readValue("{\"value\":\"0.0\"}", JsonNode.class));
        jsonNodes.put(IND_COND_INFO_21,mapper.readValue("{\"value\":\"1\"}",JsonNode.class));
        jsonNodes.put(IND_COND_INFO_22,mapper.readValue("{\"value\":\"0\"}",JsonNode.class));
        jsonNodes.put(IND_COND_INFO_23,mapper.readValue("{\"value\":\"36.0\"}",JsonNode.class));
        jsonNodes.put(IND_COND_INFO_24,mapper.readValue("{\"value\":\"0.00\"}",JsonNode.class));
      }
      // OHDF/OHF/I_HDF
      if ("7".equals(ord.getOldDeviceMode()) || "8".equals(ord.getOldDeviceMode()) || "10".equals(ord.getOldDeviceMode())) {
        jsonNodes.put(IND_COND_INFO_19,root.putNull("value"));
      }

      ord.setIndCondInfoForMerge(mapper.writeValueAsString(jsonNodes));
      patTreatmentPatternDao.updatePatTreatmentPatternByPatIdsAFBF(ord,facilityCd,code);
    }catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }

  }

  @Override
  public void afterPropertiesSet() throws Exception {
    regist("AFBF",this);
  }
}
