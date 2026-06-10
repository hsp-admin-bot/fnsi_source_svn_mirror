package jp.co.nikkiso.ntss.device_edge.web.rest;

import java.util.Objects;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.device_edge.constant.Constant.Uri;
import jp.co.nikkiso.ntss.device_edge.request.hostNotify.AlarmNotifyRequest;
import jp.co.nikkiso.ntss.device_edge.request.hostNotify.IntervalCheckRequest;
import jp.co.nikkiso.ntss.device_edge.request.hostNotify.MedicineNotifyRequest;
import jp.co.nikkiso.ntss.device_edge.service.LogService;
import jp.co.nikkiso.ntss.device_edge.service.hostNotify.HostNotifyService;

/**
 * 通知系REST API定義
 *
 */
@RestController
@RequestMapping(Uri.NOTIFICATION)
public class ComsvNotificationResource {

  @Autowired
  private LogService logService;

  @Autowired
  private HostNotifyService hostNotifyService;

  /**
   * 患者ごとのホスト報知設定を取得する
   * @param patId 患者ID
   * @return
   */
  @GetMapping({ "/setting/{facilityCd}/{deviceEdgeNo}/{patId}", "/setting/{facilityCd}/{deviceEdgeNo}" })
  public ResponseEntity<?> getPatSetting(
      @PathVariable(name = "facilityCd", required = true) String facilityCd,
      @PathVariable(name = "deviceEdgeNo", required = true) Long deviceEdgeNo,
      @PathVariable(name = "patId", required = false) Long patId) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API CALL ホスト報知設定を取得");
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setDeviceEdgeNo(deviceEdgeNo.toString());
    eventLogMessage.setPatId(Objects.isNull(patId) ? null : patId.toString());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // 患者別のホスト報知定義の取得（patId = null ならば装置設定デフォルト）

    String setting = hostNotifyService.hostNotifySettingByPat(facilityCd, deviceEdgeNo, patId);

    eventLogMessage.setLogMessage("API CALL ホスト報知設定を取得完了：" + setting);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    if (Objects.isNull(setting)) {
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return new ResponseEntity<String>(HttpStatus.BAD_REQUEST);
      return new ResponseEntity<String>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
    return new ResponseEntity<String>(setting, HttpStatus.OK);
  }

  /**
   * デバイスエッジに紐づく施設内治療中装置の血圧測定間隔とケア報知間隔をチェックして必要ならば通知する
   * @param facilityCd 施設コード
   * @param deviceEdgeNo DE番号
   * @return
   */
  @PostMapping("/interval-alarm")
  public ResponseEntity<?> checkAndNotify(@RequestBody IntervalCheckRequest body) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(body.getFacilityCd());
    eventLogMessage.setDeviceEdgeNo(body.getDeviceEdgeNo().toString());
    eventLogMessage.setLogMessage("API CALL 間隔チェックホスト報知 ");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    int ret = hostNotifyService.hostNotifyIntervalCheck(body.getFacilityCd(), body.getDeviceEdgeNo());
    return new ResponseEntity<>(ret, HttpStatus.OK);
  }

  /**
   * デバイスエッジ内で報知対象として判定された内容を通知する
   * @param facilityCd 施設コード
   * @param deviceEdgeNo DE番号
   * @return
   */
  @PostMapping("/host-alarm")
  public ResponseEntity<?> AlarmNotify(@RequestBody AlarmNotifyRequest body) {
    // DE側からホスト報知を行うためのREST API

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(body.getFacilityCd());
    eventLogMessage.setDeviceEdgeNo(body.getDeviceEdgeNo().toString());
    eventLogMessage.setMachineTypeCd(body.getMachineTypeCd());
    eventLogMessage.setLogMessage("API CALL ホスト報知 :" + body.getOccurDate() + "/" + body.getMachineSerial() + "/" + body.getContent());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    int ret = hostNotifyService.hostNotify(body);
    return new ResponseEntity<>(ret, HttpStatus.OK);
  }

  /**
   * デバイスエッジ内で投薬タイミングを通知
   * @param facilityCd 施設コード
   * @param deviceEdgeNo DE番号
   * @return
   */
  @PostMapping("/medicine")
  public ResponseEntity<?> MedicTyming(@RequestBody MedicineNotifyRequest body) {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("API CALL 投与薬剤タイミング通知 :" + body.getOccurDate() + "/"  + body.getMachineSerial() + "/" + body.getMedicineName());
    eventLogMessage.setFacilityCd(body.getFacilityCd());
    eventLogMessage.setDeviceEdgeNo(body.getDeviceEdgeNo().toString());
    eventLogMessage.setPatId(Objects.isNull(body.getPatId()) ? null : body.getPatId().toString());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    int ret = hostNotifyService.MedicineTymingNotify(body);
    return new ResponseEntity<>(ret, HttpStatus.OK);
  }

}
