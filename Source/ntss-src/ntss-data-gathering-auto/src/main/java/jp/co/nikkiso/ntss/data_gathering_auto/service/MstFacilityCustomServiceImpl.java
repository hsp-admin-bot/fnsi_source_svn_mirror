package jp.co.nikkiso.ntss.data_gathering_auto.service;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.data_gathering_auto.dao.MstFacilityCustomDao;
import jp.co.nikkiso.ntss.data_gathering_auto.entity.MstFacilityCustom;

/**
 * 施設マスタのService実装クラス.
 *
 */
@Service
public class MstFacilityCustomServiceImpl implements MstFacilityCustomService {
  @Autowired
  private MstFacilityCustomDao mstFacilityCustomDao;
  @Autowired
  private LogService logService;
  @Override
  public List<MstFacilityCustom> findAll() {
    List<MstFacilityCustom> data;
    try {
      data = this.mstFacilityCustomDao.selectAll();
    } catch (Exception e) {
      data = null;
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage( "例外発生：" + e.getMessage());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    return data;
  }
}
