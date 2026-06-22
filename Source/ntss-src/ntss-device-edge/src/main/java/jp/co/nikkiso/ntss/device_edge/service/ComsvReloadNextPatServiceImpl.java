package jp.co.nikkiso.ntss.device_edge.service;

import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.HashMap;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import java.util.List;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.Map;

import tools.jackson.databind.ObjectMapper;
import io.micrometer.core.instrument.util.StringUtils;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMain;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.constant.Constant.OrdMainConst;
import jp.co.nikkiso.ntss.device_edge.response.comsvReloadNextPat.ComsvReloadNextPatResponse;
import jp.co.nikkiso.ntss.device_edge.response.sendConditionCancel.SendConditionCancelResponse;
import jp.co.nikkiso.ntss.device_edge.service.sendConditionCancel.SendConditionCancelService;
import lombok.AllArgsConstructor;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@Service
public class ComsvReloadNextPatServiceImpl implements ComsvReloadNextPatService {

  /**
   * ObjectMapper.
   */
  @Autowired
  private MntMachineStateService mntMachineStateService;

  @Autowired
  private ComsvOrdMainService comsvOrdMainService;

  @Autowired
  private SendConditionCancelService sendConditionCancelService;

  @Autowired
  private MstMachineDao mstMachineDao;

  @Autowired
  private LogService logService;

  /**
   * {@inheritDoc}
   */
  @Override
  public int reloadNextPat(String facilityCd, Integer deviceEdgeNo) {
    int resCount = 0;
    int listCount = 0;
    String machineTypeCd = "";
    String machineSerial = "";
    try {
      List<MntMachineState> mntList = mntMachineStateService.selectAllByDeviceEdgeNo(facilityCd, deviceEdgeNo);
      for (MntMachineState mntMachine : mntList) {
        listCount++;
        machineTypeCd = mntMachine.getMachineTypeCd();
        machineSerial = mntMachine.getMachineSerial();
        Long nextOrdNo = mntMachine.getNextOrdNo();
        Long ordNo = mntMachine.getOrdNo();
        Timestamp condSendDate = mntMachine.getCondSendDate();
        MstMachine machine = mstMachineDao.selectByCd(machineTypeCd, machineSerial, facilityCd);

        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("list = [" + listCount + "] facility_cd = [" + facilityCd
            + "] machine_type_cd = [" + machineTypeCd + "] machine_serial = [" + machineSerial + "]");
        eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
        eventLogMessage
            .setSqlIdentification("(facility_cd = " + facilityCd + ", device_edge_no = " + deviceEdgeNo + ")");
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS,
            "MntMachineStateDao/selectAllByDeviceEdgeNo");
        // 比較先の条件送信日時
        LocalDate date1 = LocalDate.now();
        if (condSendDate != null) {
          LocalDateTime dateTime = condSendDate.toLocalDateTime();
          // 条件送信日時をLocalDateに変換
          date1 = LocalDate.of(dateTime.getYear(), dateTime.getMonth(), dateTime.getDayOfMonth());
        }
        // 比較元の日付取得-2日
        LocalDate date2 = LocalDate.now().minusDays(2);
        // 次患者更新
        if (nextOrdNo == null) {
          ComsvReloadNextPatResponse res = callWebApiNextPat(facilityCd, machineTypeCd, machineSerial);
          if (res.isSuccess == true) {
            resCount++;
          }
        } else {
          // オーダ番号を取得
          ComsvOrdMain ordMain = comsvOrdMainService.selectByNo(nextOrdNo);
          //add redmine bug#6745 劉 start
          if (null == ordMain) {
            continue;
          }
          //add redmine bug#6745 劉 end

          String state = ordMain.getRstDialysisState();
          switch (state) {
          case OrdMainConst.DialysisState.BEFORE_SEND:
            ComsvReloadNextPatResponse res = callWebApiNextPat(facilityCd, machineTypeCd, machineSerial);
            if (res.isSuccess == true) {
              resCount++;
            }
            break;
          case OrdMainConst.DialysisState.AFTER_SEND:
          case OrdMainConst.DialysisState.CHECKED_SEND:
            // 条件送信日時が2日以上過去日は条件送信キャンセル
            if (date1.isBefore(date2) || date1.equals(date2)) {
              // 現患者に対して条件送信キャンセル実施(DB更新のみ)
              SendConditionCancelResponse res1 = new SendConditionCancelResponse();
              try {
                res1 = sendConditionCancelService.DoCancelDBAction(ordNo, machine);
              } catch (Exception ex){
                res1.isSuccess = false;
                res1.errorMessage = ex.getMessage();
                res1.ex = ex;
              }
              if (!res1.isSuccess) {
                // 条件送信キャンセル失敗
                EventLogMessage eventLogMessage1 = new EventLogMessage();
                eventLogMessage1
                    .setLogMessage("API insertUnregistered() DoCancelDBAction failed. error:" + res1.errorMessage);
                eventLogMessage1.setMachineTypeCd(machine.getMachineTypeCd());
                eventLogMessage1.setPatId(ordMain.getPatId().toString());
                eventLogMessage1.setSqlIdentification("ordNo = " + ordNo + ",machine = " + machine);
                eventLogMessage1.setFacilityCd(machine.getFacilityCd());
                logService.log(LogLevel.ERROR, eventLogMessage1, null, SERVICE_NAME.REMS, null);
              } else {
                ComsvReloadNextPatResponse res3 = callWebApiNextPat(facilityCd, machineTypeCd, machineSerial);
                if (res3.isSuccess == true) {
                  resCount++;
                }
              }
            }
            break;
          default:
            break;
          }
        }
      }
    } catch (IOException | URISyntaxException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (!StringUtils.isEmpty(facilityCd)) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("iCnt = [" + resCount + "]");
    eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setSqlIdentification("(facility_cd = " + facilityCd + ", device_edge_no = " + deviceEdgeNo + ")");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS,
        "MntMachineStateDao/selectAllByDeviceEdgeNo");
    return resCount;
  }

  // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  start
  @Override
  public ComsvReloadNextPatResponse reloadNoNextPat(String facilityCd, String machineTypeCd, String machineSerial) throws IOException, URISyntaxException {

    ComsvReloadNextPatResponse res3 = callWebApiNextPat(facilityCd, machineTypeCd, machineSerial);

    return res3;
  }
  // add 10964 ????患者が作成された際にチェックリストマスタのデータが取得できていない。 関  end

  @AllArgsConstructor
  @SuppressWarnings("unused")
  private class webApiPayload {
    public String facility_cd;
    public String machine_type_cd;
    public String machine_serial;
  }

  /**
   * WebApi側のREST APIを呼び出す処理
   *
   * @param facilityCd    施設コード
   * @param machineTypeCd 装置種別
   * @param machineSerial 装置シリアル
   * @return
   * @throws URISyntaxException
   * @throws IOException
   */
  private ComsvReloadNextPatResponse callWebApiNextPat(String facilityCd, String machineTypeCd, String machineSerial)
      throws URISyntaxException, IOException {

    ComsvReloadNextPatResponse res = new ComsvReloadNextPatResponse();

    // 送信URI TODO: ymlから取得するようにする
    URI uri = new URI("http://localhost:8080/ntss-web-api/util/SetNextPatInfo");
    RestTemplate restTemplate = new RestTemplate();

    // body作成
    webApiPayload json = new webApiPayload(facilityCd, machineTypeCd, machineSerial);

    // リクエスト作成
    RequestEntity<webApiPayload> requestEntity = RequestEntity.post(uri).contentType(MediaType.APPLICATION_JSON)
        .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK").body(json);

    try {
	// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // API呼び出し
      ResponseEntity<String> response = restTemplate.exchange(requestEntity, String.class);
      // log start
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.device_edge.service.ComsvReloadNextPatServiceImpl");
      map.put("methodName", "callWebApiNextPat");
      map.put("method", requestEntity.getMethod());
      map.put("url", requestEntity.getUrl());
      map.put("headers", requestEntity.getHeaders().toSingleValueMap());
      map.put("requestParameter", requestEntity.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      restTemplateEventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // log end
      if (response.getStatusCode() == HttpStatus.OK) {
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
        res.isSuccess = true;
      } else {
        // APIエラー
        res.isSuccess = false;
      }
    } catch (Exception e) {
      // API呼び出しエラー
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("API呼び出しエラー = " + e.getMessage());
      eventLogMessage.setMachineTypeCd(machineTypeCd);
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      res.isSuccess = false;
    }

    return res;
  }

}
