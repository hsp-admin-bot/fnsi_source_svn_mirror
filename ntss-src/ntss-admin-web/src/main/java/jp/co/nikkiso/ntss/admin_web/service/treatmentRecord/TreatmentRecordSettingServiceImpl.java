package jp.co.nikkiso.ntss.admin_web.service.treatmentRecord;

import java.util.List;

import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordDeviceSetInfo;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.TreatmentRecordOrdTreatConditionDao;
import jp.co.nikkiso.ntss.core.entity.TreatmentRecordSetting;

/**
 * 治療記録画面（装置設定機能）のService実装クラス.
 */
@Service
@Slf4j
public class TreatmentRecordSettingServiceImpl implements TreatmentRecordSettingService {

  /**
   * 治療記録用設定値読み込み履歴のDaoインタフェース.
   */
  @Autowired
  private TreatmentRecordOrdTreatConditionDao treatmentRecordOrdTreatConditionDao;

  /**
   * 治療情報のDaoインタフェース.
   */
  @Autowired
  private TreatmentRecordDao treatmentRecordDao;

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  /**
   * {@inheritDoc}
   */
  @Override
  public List<TreatmentRecordSetting> getOrdTreatConditionByOrdNo(Long ordNo) {
    return treatmentRecordOrdTreatConditionDao.selectTreatmentRecordSettingsByOrdNo(ordNo);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public TreatmentRecordDeviceSetInfo getTreatmentRecordDeviceSetInfoByOrdNo(Long ordNo) throws NotExistException {
    try {
      return treatmentRecordDao.selectTreatmentRecordDeviceSetInfoByOrdNo(ordNo);
    } catch (EmptyResultDataAccessException e) {
    	EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no TreatmentRecordDeviceSetInfo.");
      eventLogMessage.setSqlIdentification("(ordNo = "+ ordNo +")");
      logService.log(LogLevel.DEBUG, eventLogMessage,FUNCTION_CODE.FUNC_TREATMENT_RECORD,SERVICE_NAME.REMS, "TreatmentRecordDao/selectTreatmentRecordDeviceSetInfoByOrdNo");
      throw new NotExistException("存在しない治療情報のオーダ番号を指定されています。");
    }
  }
}
