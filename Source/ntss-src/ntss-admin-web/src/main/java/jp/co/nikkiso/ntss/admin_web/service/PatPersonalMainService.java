package jp.co.nikkiso.ntss.admin_web.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang3.ObjectUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatNameId;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
@Service
public class PatPersonalMainService {

    @Autowired
    private PatPersonalMainDao patPersonalMainDao;

    /**
    * ロギングのServiceインタフェース.
    */
    @Autowired
    private LogService logService;

    public Map < String, String > selectPatPersonalMainByPatId(Long patId) throws Exception {
        PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
        if (patPersonalMain == null) {
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("selectPatPersonalMainByPatId() 指定されたpat_idのpat_Personal_Mainレコードが存在しません。(patId: " + patId + ")");
            eventLogMessage.setPatId(patId.toString());
            eventLogMessage.setSqlIdentification("(PatId = "+ patId +")");
            logService.log(LogLevel.ERROR, eventLogMessage,null, SERVICE_NAME.FNSI, "PatPersonalMainDao/selectById");
            return null;
        }
        ObjectMapper mapper = new ObjectMapper();
        Map < String, String > payload = new HashMap < > ();
        payload.put("pat_personal_main", mapper.writeValueAsString(patPersonalMain));
        return payload;
    }

    public PatPersonalMain selectByIdForWriteCard(Long patId) throws Exception {
        return patPersonalMainDao.selectByIdForWriteCard(patId);
    }
    
    /**
     * 施設コードから患者名取得
     * 
     * @param facilityCd 施設コード
     * @return 患者名リスト
     * @throws Exception
     */
    public List<PatPersonalMain> getPatNameByFacilityCd(String facilityCd) throws Exception {
      return patPersonalMainDao.selectPatNameByFacilityCd(facilityCd);
  }
    
    /**
     * 患者IDから患者名取得
     * 
     * @param patId 患者ID
     * @return 患者名
     * @throws Exception
     */
    public PatNameId getPatNameByPatId(Long patId) throws Exception {
      List<PatNameId> list = patPersonalMainDao.selectPatNameById(List.of(patId));
      return ObjectUtils.isEmpty(list) ? null : list.get(0);
  }

}
