
package jp.co.nikkiso.ntss.device_edge_updater.web.rest;

import java.util.Base64;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage.ManageInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.device_edge_updater.constant.Constant.Uri;
import jp.co.nikkiso.ntss.device_edge_updater.service.DeviceEdgeUpdaterManageService;
import jp.co.nikkiso.ntss.device_edge_updater.service.LogService;
import jp.co.nikkiso.ntss.device_edge_updater.util.Utilities;

@RestController
@RequestMapping(Uri.DEVICE_EDGE_UPDATER_RESPONSE)
public class UpdateResource {

  @Autowired
  private DeviceEdgeUpdaterManageService deviceEdgeUpdaterManageService;

  @Autowired
  private LogService logService;

  private static class ResponseData {
    public String content;
    public String status;
    public String info;
  }

  /**
   * 受信
   * @param body
   */
  @PostMapping("/response")
  @ResponseStatus(HttpStatus.OK)
  public HttpStatus Response(@RequestBody String body) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("アプリ更新API応答[" + body + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    // 戻り値
    HttpStatus status = HttpStatus.INTERNAL_SERVER_ERROR;

    // 受信データJson形式なので一度クラスに格納
    ObjectMapper mapper = new ObjectMapper();
    ResponseData data;
    try {
      data = mapper.readValue(body, ResponseData.class);
    } catch (Exception e) {
      eventLogMessage.setLogMessage("アプリ更新API応答：受け取った情報の変換処理に失敗" + e.getMessage());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return status;
    }

    // Base64のデータをデコード
    String strContent = ""; // シーケンス番号
    String strStatus = ""; // ステータス
    String strInfo = ""; // 情報Json
    if (false == StringUtils.isEmpty(data.content)) {
      strContent = new String(Base64.getDecoder().decode(data.content));
    }
    if (false == StringUtils.isEmpty(data.status)) {
      strStatus = new String(Base64.getDecoder().decode(data.status));
    }
    if (false == StringUtils.isEmpty(data.info)) {
      strInfo = new String(Base64.getDecoder().decode(data.info));
    }
    eventLogMessage
        .setLogMessage("アプリ更新応答API受信内容[content:" + strContent + " status:" + strStatus + " info:" + strInfo + "]");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    if (strContent.length() > 0 &&
        strStatus.length() == 0 &&
        strInfo.length() == 0 &&
        strContent.contains("_")) {
      // 旧スタイル
      // content_status
      String[] contents = strContent.split("_");
      strContent = contents[0];
      strStatus = contents[1];
      strInfo = "{}";
    }
    // 受信内容を使ってなんかデータ更新する
    if (Utilities.isNumber(strContent) == false || Utilities.isNumber(strStatus) == false) {
      eventLogMessage.setLogMessage("アプリ更新応答API受信内容エラー");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //return HttpStatus.BAD_REQUEST;
      return HttpStatus.INTERNAL_SERVER_ERROR;
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
    MntDeviceEdgeManage manage = deviceEdgeUpdaterManageService.selectByManageNo(Long.valueOf(strContent));
    if (manage != null) {
      manage.setResponseStatus(Short.parseShort(strStatus));
      ManageInfo manageInfo = manage.getManageInfo() == null ? new ManageInfo() : manage.getManageInfo();
      JsonNode jsonNode = null;
      try {
        jsonNode = mapper.readTree(Utilities.replaceEscapeTab(strInfo));
        manageInfo
            .setDownloadBucket(this.getJsonValueByKey(jsonNode, "download_bucket", manageInfo.getDownloadBucket()));
        manageInfo.setDownloadFile(this.getJsonValueByKey(jsonNode, "download_file", manageInfo.getDownloadFile()));
        manageInfo.setUploadBucket(this.getJsonValueByKey(jsonNode, "upload_bucket", manageInfo.getUploadBucket()));
        manageInfo.setUploadFile(this.getJsonValueByKey(jsonNode, "upload_file", manageInfo.getUploadFile()));
        manageInfo.setMessage(this.getJsonValueByKey(jsonNode, "message", manageInfo.getMessage()));
      } catch (JacksonException e) {
        manageInfo.setMessage(this.getJsonValueByKey(jsonNode, "message", "応答情報の解釈に失敗しました"));
      }
      manage.setManageInfo(manageInfo);

      deviceEdgeUpdaterManageService.updateUpdaterManage(manage);
    }

    // OK
    status = HttpStatus.OK;

    eventLogMessage.setLogMessage("アプリ更新API応答受信処理成功");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    return status;
  }

  /**
   * JSONノードから指定したキーの値を文字列として取得する。
   * 指定したキーがノードにない場合、defaultValueを返す。
   * @param jsonNode
   * @param key
   * @return
   */
  private String getJsonValueByKey(JsonNode jsonNode, String key, String defaultValue) {
    String rtn;
    JsonNode node = jsonNode.get(key);
    // キー存在判定
    if (node != null) {
      // キーが存在する場合はその値を返す
      rtn = node.asText();
    } else {
      // キーが存在しない場合はdefaultValueを返す
      rtn = defaultValue;
    }

    return rtn;
  }
}
