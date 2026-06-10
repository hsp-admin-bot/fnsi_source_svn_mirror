package jp.co.nikkiso.ntss.data_gathering.resource;

import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.data_gathering.service.DataGatheringService;
import jp.co.nikkiso.ntss.data_gathering.service.DataGatheringService.CheckRequestByteNum;
import jp.co.nikkiso.ntss.data_gathering.service.DataGatheringService.GatheringTarget;
import jp.co.nikkiso.ntss.data_gathering.service.DataGatheringService.PublishInfo;
import jp.co.nikkiso.ntss.data_gathering.service.LogService;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;


@RestController
@RequestMapping("/api")
public class DataGatheringResource {
  private static class RequestData {
    public String content;
  }

  private static class ResponseData {
    public String content;
    public String filepath;
    public String filename;
  }

  @Autowired
  private DataGatheringService dataGatheringSv;

  @Autowired
  private LogService logService;

  @RequestMapping("/")
  public void main() {
  }

  /**
   * 要求
   *
   * @param target
   * @return
   */
  @PostMapping("/request")
  @ResponseStatus(HttpStatus.OK)
  public HttpStatus Request(@RequestBody String target) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("データ収集API：データ収集要求処理開始");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    eventLogMessage.setLogMessage("データ収集API：呼び出し側からの受信情報[" + target + "]");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // 戻り値
    HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;

    GatheringTarget targetData;
    ObjectMapper mapper = new ObjectMapper();


    try {
      targetData = mapper.readValue(target, GatheringTarget.class);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("データ収集API：受け取った情報の変換処理に失敗　受信情報[" + target + "]、" + e.getMessage());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return status;
    }

    // 収集処理開始
    PublishInfo publishInfo = this.dataGatheringSv.Gathering(targetData);
    if (false == publishInfo.Result) {
      eventLogMessage.setLogMessage("データ収集API：要求失敗　対象施設コード[" + targetData.getFacilityCd() + "]");
      eventLogMessage.setFacilityCd(targetData.getFacilityCd());
      eventLogMessage.setUserId(targetData.getUserId());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return status;
    } else {
      eventLogMessage.setLogMessage("データ収集API：要求成功　対象施設コード[" + targetData.getFacilityCd() + "]");
      eventLogMessage.setFacilityCd(targetData.getFacilityCd());
      eventLogMessage.setUserId(targetData.getUserId());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      status = HttpStatus.OK;
    }

    return status;
  }

  /**
   * 要求(Base64形式、1装置)
   *
   * @param target
   * @return
   */
  @PostMapping("/request/device")
  public HttpStatus RequestDevice(@RequestBody String target) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("データ収集API：データ収集要求処理開始");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    eventLogMessage.setLogMessage("データ収集API：呼び出し側からの受信情報[" + target + "]");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // 戻り値
    HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;

    // 受信データJson形式なので一度クラスに格納
    ObjectMapper mapper = new ObjectMapper();
    RequestData data;
    try {
      data = mapper.readValue(target, RequestData.class);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("データ収集API：受け取った情報の変換処理に失敗　受信情報[" + target + "]、" + e.getMessage());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return status;
    }

    eventLogMessage.setLogMessage("データ収集API：受信情報変換前[" + data.content + "]");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // Base64のデータをデコード
    String requestData = new String(Base64.getDecoder().decode(data.content));

    eventLogMessage.setLogMessage("データ収集API：受信情報変換後[" + requestData + "]");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // 受信情報のバイト数チェック
    if (false == this.dataGatheringSv.CheckRequestByte(requestData)) {
      // エラーログは関数内で出力済み
      return status;
    }

    // 受信情報格納クラス
    GatheringTarget targetData = new GatheringTarget();

    // 装置情報の分割に使用
    int sIndex = 0;

    // 受信情報分ループし設定
    int cntRequestInfo = requestData.length() / CheckRequestByteNum.TotalNum;
    // for (int i = 0; i < cntRequestInfo; i++)
    for (int i = 0; i < cntRequestInfo;) {
      String facilityCd = "";
      String deviceEdgeNo = "";
      String machineTypeCd = "";
      String machineComFormatCd = "";
      String machineSerial = "";
      String userId = "";
      List<String> machineInfo = new ArrayList<>();

      // 施設コード
      facilityCd = requestData.substring(sIndex, sIndex + CheckRequestByteNum.FacilityCdByteNum);
      sIndex += CheckRequestByteNum.FacilityCdByteNum;

      // デバイスエッジ番号
      deviceEdgeNo = requestData.substring(sIndex, sIndex + CheckRequestByteNum.DeviceEdgeNoByteNum);
      sIndex += CheckRequestByteNum.DeviceEdgeNoByteNum;

      // 型式コード
      machineTypeCd = requestData.substring(sIndex, sIndex + CheckRequestByteNum.MachineTypeCdByteNum);
      sIndex += CheckRequestByteNum.MachineTypeCdByteNum;

      // 通信フォーマット
      machineComFormatCd = requestData.substring(sIndex, sIndex + CheckRequestByteNum.ComFormatCdByteNum);
      sIndex += CheckRequestByteNum.ComFormatCdByteNum;

      // 製造番号
      machineSerial = requestData.substring(sIndex, sIndex + CheckRequestByteNum.MachineSerialByteNum);
      sIndex += CheckRequestByteNum.MachineSerialByteNum;

      // 利用者ID
      userId = requestData.substring(sIndex, sIndex + CheckRequestByteNum.UserIdByteNum);
      sIndex += CheckRequestByteNum.UserIdByteNum;

      // 装置情報(デバイスエッジ番号 + '_' + 型式コード + '_' + 通信フォーマット + '_' + 製造番号)
      machineInfo.add(deviceEdgeNo.trim() + "_" + machineTypeCd + "_" + machineComFormatCd + "_" + machineSerial);

      // 格納
      // 施設コード
      targetData.setFacilityCd(facilityCd);
      // 装置情報
      targetData.setMachineNo(machineInfo);
      // 全装置かどうか(false)
      targetData.setIsAllCd(false);
      // 操作情報(1：手動収集)
      targetData.setOpeInfo(1);
      // 利用者ID
      targetData.setUserId(userId);

      // ※現状、1回1装置のリクエストのみ
      break;
    }

    // 収集処理開始
    PublishInfo publishInfo = this.dataGatheringSv.Gathering(targetData);
    if (false == publishInfo.Result) {

      eventLogMessage.setLogMessage("データ収集API：要求失敗　対象施設コード[" + targetData.getFacilityCd() + "]");
      eventLogMessage.setFacilityCd(targetData.getFacilityCd());
      eventLogMessage.setUserId(targetData.getUserId());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return status;
    } else {
      eventLogMessage.setLogMessage("データ収集API：要求成功　対象施設コード[" + targetData.getFacilityCd() + "]");
      eventLogMessage.setFacilityCd(targetData.getFacilityCd());
      eventLogMessage.setUserId(targetData.getUserId());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      status = HttpStatus.OK;
    }

    return status;
  }

  @PostMapping("/retry")
  @ResponseStatus(HttpStatus.OK)
  public HttpStatus Retry(@RequestBody String target) {

	EventLogMessage eventLogMessage = new EventLogMessage();

    eventLogMessage.setLogMessage("データ収集API：データ収集再要求処理開始");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    eventLogMessage.setLogMessage("データ収集API：呼び出し側からの受信情報[" + target + "]");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
    // 戻り値
    HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;

    GatheringTarget targetData;
    ObjectMapper mapper = new ObjectMapper();
    try {
      targetData = mapper.readValue(target, GatheringTarget.class);
    } catch (Exception e) {

      eventLogMessage.setLogMessage("データ収集API：受け取った情報の変換処理に失敗　受信情報[" + target + "]、" + e.getMessage());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return status;
    }

    PublishInfo publishInfo = this.dataGatheringSv.Gathering(targetData);
    if (false == publishInfo.Result) {

      eventLogMessage.setLogMessage("データ収集API：再要求失敗　対象施設コード[" + targetData.getFacilityCd() + "]");
      eventLogMessage.setFacilityCd(targetData.getFacilityCd());
      eventLogMessage.setUserId(targetData.getUserId());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return status;
    } else {

      eventLogMessage.setLogMessage("データ収集API：再要求成功　対象施設コード[" + targetData.getFacilityCd() + "]");
      eventLogMessage.setFacilityCd(targetData.getFacilityCd());
      eventLogMessage.setUserId(targetData.getUserId());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      status = HttpStatus.OK;
    }

    return status;
  }

  /**
   * 受信
   *
   * @param body
   */
  @PostMapping("/response")
  @ResponseStatus(HttpStatus.OK)
  public HttpStatus Response(@RequestBody String body) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("データ収集API：データ収集受信処理開始");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    eventLogMessage.setLogMessage("データ収集API：呼び出し側からの受信情報[" + body + "]");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // 戻り値
    HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;

    // 受信データJson形式なので一度クラスに格納
    ObjectMapper mapper = new ObjectMapper();
    ResponseData data;
    try {
      data = mapper.readValue(body, ResponseData.class);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("データ収集API：受け取った情報の変換処理に失敗　受信情報[" + body + "]" + e.getMessage());
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return status;
    }
      eventLogMessage.setLogMessage("データ収集API：受信情報変換前(content)　[" + data.content + "]");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

      eventLogMessage.setLogMessage("データ収集API：受信情報変換前(filepath)　[" + data.filepath + "]");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

      eventLogMessage.setLogMessage("データ収集API：受信情報変換前(filename)　[" + data.filename + "]");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // Base64のデータをデコード
    String strContent = "";
    if (false == StringUtils.isEmpty(data.content)) {
      strContent = new String(Base64.getDecoder().decode(data.content));
    }
    String strFilepath = "";
    if (false == StringUtils.isEmpty(data.filepath)) {
      strFilepath = new String(Base64.getDecoder().decode(data.filepath));
    }
    String strFilename = "";
    if (false == StringUtils.isEmpty(data.filename)) {
      strFilename = new String(Base64.getDecoder().decode(data.filename));
    }

    eventLogMessage.setLogMessage("データ収集API：受信情報変換後(content)　[" + strContent + "]");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    eventLogMessage.setLogMessage("データ収集API：受信情報変換後(filepath)　[" + strFilepath + "]");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    eventLogMessage.setLogMessage("データ収集API：受信情報変換後(filename)　[" + strFilename + "]");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    // データ収集受信処理
    Boolean bRet = this.dataGatheringSv.GatheringResponse(strContent, strFilepath, strFilename);
    if (false == bRet) {
      // エラー
      eventLogMessage.setLogMessage("データ収集API：受信処理失敗");
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI,null);
      return status;
    }

    // OK
    status = HttpStatus.OK;

    eventLogMessage.setLogMessage("データ収集API：受信処理成功");
    //FNSI-修正 ログ対応 xiebzh add start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    //FNSI-修正 ログ対応 xiebzh add end
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI,null);

    return status;
  }
}
