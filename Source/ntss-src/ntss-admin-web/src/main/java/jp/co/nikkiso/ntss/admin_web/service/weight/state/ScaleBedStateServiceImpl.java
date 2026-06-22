package jp.co.nikkiso.ntss.admin_web.service.weight.state;

import jp.co.nikkiso.ntss.core.dao.MntScaleBedStateDao;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.weight.WeightService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.MntScaleBedState;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.lang.Nullable;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.Objects;

@Service
public class ScaleBedStateServiceImpl implements ScaleBedStateService {
  @Autowired
  MntScaleBedStateDao mntScaleBedStateDao;
  @Autowired
  WeightService weightService;
  @Autowired
  private ObjectMapper objectMapper;
  @Autowired
  private LogService logService;

  @Override
  public MntScaleBedState selectByBedCd(Long bedCd) {
    return mntScaleBedStateDao.selectByBedCd(bedCd);
  }

  @Override
  @Transactional
  public int insert(MntScaleBedState param) {
    return mntScaleBedStateDao.insert(param);
  }

  @Override
  @Transactional
  public int update(MntScaleBedState param) {
    LogEventUtils.setOperatorId(param, logService);
    return mntScaleBedStateDao.update(param);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateIsConnect(Long bedCd, String isConnect) {
    MntScaleBedState state = mntScaleBedStateDao.selectByBedCd(bedCd);
    state.setIsConnect(isConnect);

    LogEventUtils.setOperatorId(state, logService);
    return mntScaleBedStateDao.update(state);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateScaleValueBefore(Long bedCd, Long weightCd, String facilityCd,  Long weightScaleNo) {
    MntScaleBedState state = mntScaleBedStateDao.selectByBedCd(bedCd);
    state.setWeightCd(weightCd);
    state.setFacilityCd(facilityCd);
    state.setBeforeSendStatus(0); // 「0:正常」で初期化
    state.setBeforeWeightScaleNo(weightScaleNo);

    LogEventUtils.setOperatorId(state, logService);
    return mntScaleBedStateDao.update(state);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int updateScaleValueAfter(Long bedCd, Long weightCd, String facilityCd, Long weightScaleNo) {
    MntScaleBedState state = mntScaleBedStateDao.selectByBedCd(bedCd);
    state.setWeightCd(weightCd);
    state.setFacilityCd(facilityCd);
    state.setAfterSendStatus(0); // 「0:正常」で初期化
    state.setAfterWeightScaleNo(weightScaleNo);

    LogEventUtils.setOperatorId(state, logService);
    return mntScaleBedStateDao.update(state);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public void updateSendStatusNormalize(Long bedCd, boolean isBeforeWeight, Long weightScaleNo) {
    if (bedCd == null){
      return;
    }
    updateSendStatusNormalize(bedCd, isBeforeWeight, weightScaleNo, null);
  }
  /**
   * {@inheritDoc}
   */
  @Override
  public void updateSendStatusNormalize(Long bedCd, boolean isBeforeWeight, Long weightScaleNo, BigDecimal scaleValue) {
    if (bedCd == null){
      return;
    }
    var state = getChangedScaleBedState(bedCd, isBeforeWeight, weightScaleNo, 0, scaleValue);
    if (state == null)
    {
      return;
    }

    LogEventUtils.setOperatorId(state, logService);
    mntScaleBedStateDao.update(state);
  }
  /**
   * {@inheritDoc}
   */
  @Override
  public void updateSendStatusWarning(Long bedCd, boolean isBeforeWeight, Long weightScaleNo) {
    if (bedCd == null){
      return;
    }
    var state = getChangedScaleBedState(bedCd, isBeforeWeight, weightScaleNo, 2, null);
    if (state == null)
    {
      return;
    }

    LogEventUtils.setOperatorId(state, logService);
    mntScaleBedStateDao.update(state);
  }
  /**
   * {@inheritDoc}
   */
  @Override
  public void updateSendStatusError(Long bedCd, boolean isBeforeWeight, Long weightScaleNo) {
    if (bedCd == null){
      return;
    }
    var state = getChangedScaleBedState(bedCd, isBeforeWeight, weightScaleNo, 1, null);
    if (state == null)
    {
      return;
    }
    LogEventUtils.setOperatorId(state, logService);
    mntScaleBedStateDao.update(state);

  }

  /**
   * {@inheritDoc}
   */
  @Override
  public OrdWeightScale selectForOrdWeightScaleByBedCd(Long bedCd, Long targetOrdNo, boolean isAfter) {
    EventLogMessage eventLogMessage = new EventLogMessage();

    String defaultTareAndOffWater = """
      {"name_1":"","name_2":"","name_3":"","name_4":"","name_5":"","weight_1":0,"weight_2":0,"weight_3":0,"weight_4":0,"weight_5":0}
      """;

    OrdWeightScale ows = mntScaleBedStateDao.selectForOrdWeightScaleByBedCd(bedCd, targetOrdNo);
    if (targetOrdNo == null) {
      // 対象ord_noなし
      ows.setPatId(null);
      ows.setRstTareInfo(defaultTareAndOffWater);
      ows.setRstOffWaterInfo(defaultTareAndOffWater);

    } else {
      var ordParameter = weightService.buildOrderResponse(targetOrdNo);
      eventLogMessage.setFacilityCd(ordParameter.ord.getFacilityCd());

      ows.setPatId(ordParameter.ord.getPatId());
      if (isAfter) {
        // 後体重時
        String tareInfo = defaultTareAndOffWater;
        var tareStr = ordParameter.ord.getRstTareInfo();
        var rstTareInfo = parseNode(tareStr, eventLogMessage);
        if (rstTareInfo != null) {
          var tareInfoJson = rstTareInfo.has("after") ? rstTareInfo.get("after") : null;
          if (tareInfoJson != null) {
            tareInfo = tareInfoJson.toString();
          }
        }
        ows.setRstTareInfo(tareInfo);
        ows.setRstOffWaterInfo(ordParameter.ord.getRstOffWaterInfo());
        ows.setKurCd(ordParameter.ord.getRstKurCd());
        ows.setKurName(ordParameter.ord.getRstKurName());
        ows.setTreatmentCd(ordParameter.ord.getRstTreatmentCd());
        ows.setTreatmentName(ordParameter.ord.getRstTreatmentName());
        ows.setBedCd(bedCd);
        if (bedCd.equals(ordParameter.ord.getRstBedCd())) {
          ows.setBedName(ordParameter.ord.getRstBedName());
        }
      } else {
        // 前体重時
        //　実績風袋を取得しない場合は、指示風袋をセットする。
        String tareInfo = defaultTareAndOffWater;
        var tareStr = ordParameter.ord.getRstTareInfo();
        var rstTareInfo = parseNode(tareStr, eventLogMessage);
        if (rstTareInfo != null) {
          var tareInfoJson = rstTareInfo.has("before") ? rstTareInfo.get("before") : null;
          if (tareInfoJson != null) {
            tareInfo = tareInfoJson.toString();
          }
        }
        ows.setRstTareInfo(tareInfo);
        if(Objects.equals(tareInfo, "")) {
          ows.setRstTareInfo(ordParameter.ord.getIndTareInfo());
        }
        ows.setRstOffWaterInfo(ordParameter.ord.getIndOffWaterInfo());
        ows.setKurCd(ordParameter.ord.getIndKurCd());
        ows.setKurName(ordParameter.ord.getIndKurName());
        ows.setTreatmentCd(ordParameter.ord.getIndTreatmentCd());
        ows.setTreatmentName(ordParameter.ord.getIndTreatmentName());
        ows.setBedCd(bedCd);
        if (bedCd.equals(ordParameter.ord.getIndBedCd())) {
          ows.setBedName(ordParameter.ord.getIndBedName());
        }
      }
    }

    return ows;
  }

  private @Nullable JsonNode parseNode(String jsonString, EventLogMessage eventLogMessage) {
    if (jsonString == null || jsonString.isEmpty()) {
      return null;
    }
    try {
      return objectMapper.readTree(jsonString);
    } catch (Exception e) {
      eventLogMessage.setLogMessage(e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      return null;
    }
  }

  /**
   * 各ステータスを変更した状態を取得する
   * @param bedCd ベッドコード
   * @param isBeforeWeight 前体重かどうか
   * @param weightScaleNo 体重測定記録コード
   * @param sendStatus 状態 (0:正常、1:エラー、2:警告)
   * @param scaleValue 測定値（null時は更新しない）
   * @return 各ステータスを変更したScaleBedState
   */
  private MntScaleBedState getChangedScaleBedState(Long bedCd, boolean isBeforeWeight, Long weightScaleNo, int sendStatus, BigDecimal scaleValue) {
    MntScaleBedState state = mntScaleBedStateDao.selectByBedCd(bedCd);
    if (state != null) {
      if (isBeforeWeight) {
        state.setBeforeWeightScaleNo(weightScaleNo);
        state.setBeforeSendStatus(sendStatus);
        if (scaleValue != null) {
        }
      } else {
        state.setAfterWeightScaleNo(weightScaleNo);
        state.setAfterSendStatus(sendStatus);
        if (scaleValue != null) {
        }
      }
    }
    return state;
  }
}
