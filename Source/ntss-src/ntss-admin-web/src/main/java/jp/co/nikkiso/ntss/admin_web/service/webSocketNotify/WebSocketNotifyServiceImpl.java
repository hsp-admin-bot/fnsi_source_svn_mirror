package jp.co.nikkiso.ntss.admin_web.service.webSocketNotify;

import java.net.URI;
import java.util.Base64;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.HashMap;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import java.util.List;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.Map;


import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.apache.commons.collections4.CollectionUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import jp.co.nikkiso.ntss.admin_web.WebSocketNotifyProperties;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.NotifyTarget;
import jp.co.nikkiso.ntss.core.dao.MntClientConnectDao;
import jp.co.nikkiso.ntss.core.entity.MntClientConnect;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;

import lombok.Data;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@Service
public class WebSocketNotifyServiceImpl implements WebSocketNotifyService {

  @Autowired
  private MntClientConnectDao mntClientConnectDao;

  @Autowired
  private WebSocketNotifyProperties webSocketNotifyProperties;

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;

  @Override
  public boolean sendMsg(SendTarget target, String facilityCd, Integer deviceEdgeNo, String topic, String payload) {
    return sendMsg(target, null, facilityCd, deviceEdgeNo, topic, payload);
  }

  @Override
  public boolean sendMsg(SendTarget target, String targetLabel, String facilityCd, Integer deviceEdgeNo, String topic,
      String payload) {
    StringBuilder commApiUri = new StringBuilder();
    boolean ret = false;
    // ログ改善対応　毛 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
    // ログ改善対応　毛 Add End

    Integer targetServerType;
    String apiPort;
    String apiUri;
    String headerKey;
    String headerValue;

    switch (target) {
    case main:
      targetLabel = targetLabel == null ? NotifyTarget.DEVICE_EDGE_MAIN_LABEL : targetLabel;
      targetServerType = NotifyTarget.DEVICE_EDGE_SERVER_TYPE;
      apiPort = webSocketNotifyProperties.getDeviceSv().getWsPort().toString();
      apiUri = webSocketNotifyProperties.getDeviceSv().getWsAPI();
      headerKey = webSocketNotifyProperties.getDeviceSv().getHeaderName();
      headerValue = webSocketNotifyProperties.getDeviceSv().getHeaderValue();
      break;
    case updater:
      targetLabel = targetLabel == null ? NotifyTarget.DEVICE_EDGE_UPDATER_LABEL : targetLabel;
      targetServerType = NotifyTarget.DEVICE_EDGE_SERVER_TYPE;
      apiPort = webSocketNotifyProperties.getDeviceSv().getWsPort().toString();
      apiUri = webSocketNotifyProperties.getDeviceSv().getWsAPI();
      headerKey = webSocketNotifyProperties.getDeviceSv().getHeaderName();
      headerValue = webSocketNotifyProperties.getDeviceSv().getHeaderValue();
      break;
    case browser:
      targetLabel = targetLabel == null ? NotifyTarget.WEB_BROWSER_LABEL : targetLabel;
      targetServerType = NotifyTarget.WEB_BROWSER_SERVER_TYPE;
      apiPort = webSocketNotifyProperties.getAppSv().getWsPort().toString();
      apiUri = webSocketNotifyProperties.getAppSv().getWsAPI();
      headerKey = webSocketNotifyProperties.getAppSv().getHeaderName();
      headerValue = webSocketNotifyProperties.getAppSv().getHeaderValue();
      break;
    case weightApp:
      targetLabel = targetLabel == null ? NotifyTarget.WEB_WEIGHT_APP_LABEL : targetLabel;
      targetServerType = NotifyTarget.WEB_BROWSER_SERVER_TYPE;
      apiPort = webSocketNotifyProperties.getAppSv().getWsPort().toString();
      apiUri = webSocketNotifyProperties.getAppSv().getWsAPI();
      headerKey = webSocketNotifyProperties.getAppSv().getHeaderName();
      headerValue = webSocketNotifyProperties.getAppSv().getHeaderValue();
      break;
    case accessCard:
      targetLabel = targetLabel == null ? NotifyTarget.DEVICE_ACCESS_CARD_LABEL : targetLabel;
      targetServerType = NotifyTarget.WEB_BROWSER_SERVER_TYPE;
      apiPort = webSocketNotifyProperties.getAppSv().getWsPort().toString();
      apiUri = webSocketNotifyProperties.getAppSv().getWsAPI();
      headerKey = webSocketNotifyProperties.getAppSv().getHeaderName();
      headerValue = webSocketNotifyProperties.getAppSv().getHeaderValue();
      break;
    default:
      // ログ改善対応　毛 Del
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("通知宛先未指定 ");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    // 通知対象と繋がっているサーバーのIPアドレスを取得
    List<MntClientConnect> mntClientConnectList = this.mntClientConnectDao.selectByServerType(facilityCd,
        targetServerType);
    if (true == StringUtils.isEmpty(mntClientConnectList)) {
      // ログ改善対応　毛 Del
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("通知宛先未接続");
      eventLogMessage
          .setSqlIdentification("(facilityCd = " + facilityCd + ", targetServerType = " + targetServerType + ")");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS,
          "MntClientConnectDao/selectByServerType");
      return false;
    }
    for (MntClientConnect item : mntClientConnectList) {
      // ログ改善対応　毛 Del
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("send WebSocket message.");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      commApiUri.setLength(0);
      commApiUri
          .append("http://")
          .append(item.getIpAddress())
          .append(":")
          .append(apiPort)
          .append(apiUri);

      if (SendToMessage(targetLabel, commApiUri.toString(), facilityCd, deviceEdgeNo, headerKey, headerValue, topic,
          payload)) {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("API sendMsg 成功 : " + item.getIpAddress());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // 通知成功
        ret = true;
      } else {
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("API sendMsg 失敗: " + item.getIpAddress());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }

    return ret;
  }

  @Override
  public boolean chkClientConnect(List<String> facilityCdList, String terminalUniqueString) {
    StringBuilder commApiUri = new StringBuilder();
    boolean ret = false;

    // 確認対象のブラウザに空文字を送信する
    String targetLabel = NotifyTarget.WEB_BROWSER_LABEL;
    Integer targetServerType = NotifyTarget.WEB_BROWSER_SERVER_TYPE;
    String apiPort = webSocketNotifyProperties.getAppSv().getWsPort().toString();
    String apiUri = webSocketNotifyProperties.getAppSv().getConnectchkAPI();
    String headerKey = webSocketNotifyProperties.getAppSv().getHeaderName();
    String headerValue = webSocketNotifyProperties.getAppSv().getHeaderValue();

    // 通知対象と繋がっているサーバーのIPアドレスを取得
    List<MntClientConnect> mntClientConnectList = this.mntClientConnectDao.selectByFacilityList(facilityCdList,
        targetServerType);
    if (CollectionUtils.isEmpty(mntClientConnectList)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("通知宛先未接続");
      for (String facilityCd : facilityCdList) {
          // ログ改善対応  毛 Add
          eventLogMessage.setFacilityCd(facilityCd);
          eventLogMessage
          .setSqlIdentification("(facilityCd = " + facilityCd + ", targetServerType = " + targetServerType + ")");
          // ログ改善対応  毛 Add
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS,
                  "MntClientConnectDao/selectByServerType");
      }
      // ログ改善対応  毛 Del
      //logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS,
      //    "MntClientConnectDao/selectByServerType");
      return false;
    }
    // ログ改善対応  毛 Add
    EventLogMessage eventLogMessage = new EventLogMessage();
    for (MntClientConnect item : mntClientConnectList) {
      // ログ改善対応  毛 Mod Start
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setFacilityCd(item.getFacilityCd());
      eventLogMessage.setLogMessage("send client connect check message.");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
      commApiUri.setLength(0);
      commApiUri
          .append("http://")
          .append(item.getIpAddress())
          .append(":")
          .append(apiPort)
          .append(apiUri);

      if (SendToMessage(targetLabel, commApiUri.toString(), item.getFacilityCd(), null, headerKey, headerValue, null, terminalUniqueString)) {
        // ログ改善対応  毛 Del
        //eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("API sendMsg 成功 : " + item.getIpAddress());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // 通知成功
        ret = true;
      } else {
        // ログ改善対応  毛 Del
        //eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("API sendMsg 失敗: " + item.getIpAddress());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }
    return ret;
  }

  /**
   * WebSocketSendMessage RestAPI呼び出し用クラス(body格納用)
   */
  @Data
  private static class SendMessageJson {
    public String targetId;
    public String message;
  };

  /**
   * WebSocket通知API呼び出し
   * @param targetLabel 宛先（DE、アップデータ、Web画面）
   * @param commApiUri APIのURI
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param headerKey ヘッダキー文字列
   * @param headerValue ヘッダバリュー文字列
   * @param topic トピック部文字列
   * @param payload ペイロード部文字列
   * @return true：成功、false：失敗
   */
  public boolean SendToMessage(String targetLabel, String commApiUri, String facilityCd, Integer deviceEdgeNo,
      String headerKey, String headerValue, String topic, String payload) {
    // 送信情報
    // 通知先判定情報(施設コード + 宛先種別 + DE番号(左0埋め))
    String targerId = facilityCd + targetLabel + (null == deviceEdgeNo ? "" : String.format("%02d", deviceEdgeNo));
    // 通知先に送るメッセージ情報(トピック名 + {TAB記号} + ペイロード文字列)
    String message = topic + "\t" + payload;

    // Base64化
    targerId = Base64.getEncoder().encodeToString(targerId.getBytes());
    message = Base64.getEncoder().encodeToString(message.getBytes());
    // ログ改善対応　毛　Add
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    try {
      // 送信URI
      URI uri = new URI(commApiUri);
      RestTemplate rt = new RestTemplate();

      // body作成
      SendMessageJson json = new SendMessageJson();
      json.setTargetId(targerId);
      json.setMessage(message);

      // リクエスト作成
      RequestEntity<SendMessageJson> request = RequestEntity
          .post(uri)
          .contentType(MediaType.APPLICATION_JSON)
          .header("SSECCAYEK", "NTSS-NKK-ESM-TDC-YSK")
          .body(json);
      // ログ改善対応　毛　Del
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(
          "REST API呼び出し:[" + uri + "], body:{ targerId:" + json.getTargetId() + ", message:" + json.getMessage() + "}");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // リクエスト処理
      ResponseEntity<HttpStatus> response = rt.exchange(request, HttpStatus.class);
      HttpStatus status = HttpStatus.valueOf(response.getStatusCode().value());
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.service.webSocketNotify.WebSocketNotifyServiceImpl");
      map.put("methodName", "SendToMessage");
      map.put("method", request.getMethod());
      map.put("url", uri.getPath());
      map.put("headers", request.getHeaders());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      restTemplateEventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      if (HttpStatus.OK != status) {
        //ログ改善対応　毛　Del
        //eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("DE通知API：RestAPI側で接続失敗 " + status);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return false;
      }
    } catch (Exception ex) {
      //ログ改善対応　毛　Del
      //EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("DE通知API：RestAPI呼び出し処理で例外発生 " + ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }
    //ログ改善対応　毛　Del
    //EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("DE通知API：接続成功");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    return true;
  }
}
