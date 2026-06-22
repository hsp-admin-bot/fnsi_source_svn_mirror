package jp.co.nikkiso.ntss.device_edge.service;

import java.util.Objects;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.NotificationDefinition;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.SendCondition.WeightScaleClass;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.ComsvOrdWeightScaleDao;
import jp.co.nikkiso.ntss.core.dao.OrdWeightScaleDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdWeightScale;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.service.Utility.PatNameInfo;
import jp.co.nikkiso.ntss.device_edge.service.Utility.PatNameUtilityService;
import jp.co.nikkiso.ntss.device_edge.web.rest.util.WebApiCallCommonUtil;

@Service
public class ComsvOrdWeightScaleServiceImpl implements ComsvOrdWeightScaleService {

  @Autowired
  ComsvOrdWeightScaleDao comsvOrdWeightScaleDao;
  @Autowired
  OrdWeightScaleDao ordWeightScaleDao;
  @Autowired
  PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private LogService logService;

  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;
  @Autowired
  PatNameUtilityService patNameUtilityService;

  @Transactional
  public int updateStatus(ComsvOrdWeightScale param) {
    return comsvOrdWeightScaleDao.updateStatus(param);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean updateSendCondStatus(String facilityCd, Long weightScaleNo, Integer weightScaleStatus, String message) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);

    ComsvOrdWeightScale comsv = new ComsvOrdWeightScale();
    comsv.setWeightScaleNo(weightScaleNo);
    comsv.setWeightScaleStatus(weightScaleStatus);
    if (message.equals("null")) {
      comsv.setMessage(null);
    } else if (message.equals("0001")) {
      comsv.setMessage("装置通信未接続");
    } else if (message.equals("0002")) {
      comsv.setMessage("送信前設定値読み込み失敗");
    } else if (message.equals("0003")) {
      comsv.setMessage("通信データ異常");
    } else if (message.equals("0004")) {
      comsv.setMessage("通信データ異常（CRCエラー）");
    } else if (message.equals("0005")) {
      comsv.setMessage("透析中のため書き込みできません。");
    } else if (message.equals("0006")) {
      comsv.setMessage("透析装置で確認が押されているため書き込みできません。");
    } else if (message.equals("0007")) {
      comsv.setMessage("条件送信応答異常");
    } else if (message.equals("0008")) {
      comsv.setMessage("不明なエラー");
    } else {
      comsv.setMessage(message);
    }

    int ret = updateStatus(comsv);

    if (Objects.equals(comsv.getWeightScaleStatus(), WeightScaleClass.SEND_NG.intValue())) {
      // 失敗の場合、通知機能を使用してフロントに条件送信失敗を通知する

      try {
        // 通知用の情報収集
        OrdWeightScale ordScale = ordWeightScaleDao.selectByCd(weightScaleNo);

        PatNameInfo patNames = patNameUtilityService.fetchPatName(ordScale.getPatId());

        // 変換用JSONデータを作成
        JSONObject replaceData = new JSONObject();

        // 必要なJSONパラメータを追加
        replaceData.put("FACILITYCD", facilityCd);
        replaceData.put("BEDNAME", ordScale.getBedName());
        replaceData.put("PATID", Objects.isNull(ordScale.getPatId()) ? "" : ordScale.getPatId().toString());
        replaceData.put("LASTNAME", patNames.getLastName());
        replaceData.put("FIRSTNAME", patNames.getFirstName());

        webApiCallCommonUtil.registerNotification(NotificationDefinition.SEND_COND_NG, facilityCd, replaceData);
        comsvOrdWeightScaleDao.updateStatus(comsv);
      } catch (Exception e) {
        eventLogMessage.setLogMessage("通知失敗:" + e.getMessage());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      }
    }

    if (ret > 0) {
      eventLogMessage.setLogMessage("体重計測定実績のステータス、メッセージ更新 = " + comsv.getMessage());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return true;
    } else {
      eventLogMessage.setLogMessage("DB保存失敗");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }
  }
}
