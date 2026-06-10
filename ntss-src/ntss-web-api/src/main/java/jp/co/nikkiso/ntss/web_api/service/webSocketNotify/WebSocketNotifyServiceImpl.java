package jp.co.nikkiso.ntss.web_api.service.webSocketNotify;

import java.net.URI;
import java.util.Base64;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.HashMap;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import java.util.List;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.Map;

import com.fasterxml.jackson.databind.ObjectMapper;
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
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import jp.co.nikkiso.ntss.web_api.WebSocketNotifyProperties;
import jp.co.nikkiso.ntss.web_api.constant.WebApiConstant.NotifyTarget;
import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.core.dao.MntClientConnectDao;
import jp.co.nikkiso.ntss.core.entity.MntClientConnect;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@Slf4j
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
  public boolean sendMsg(SendTarget target, String targetLabel, String facilityCd, Integer deviceEdgeNo, String topic, String payload) {
    StringBuilder commApiUri = new StringBuilder();
    boolean ret = false;

    Integer targetServerType;
    String apiPort;
    String apiUri;
    String headerKey;
    String headerValue;

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
    switch (target) {
    case browser:
      targetLabel = targetLabel == null ? NotifyTarget.WEB_BROWSER_LABEL : targetLabel;
      targetServerType = NotifyTarget.WEB_BROWSER_SERVER_TYPE;
      apiPort = webSocketNotifyProperties.getAppSv().getWsPort().toString();
      apiUri = webSocketNotifyProperties.getAppSv().getWsAPI();
      headerKey = webSocketNotifyProperties.getAppSv().getHeaderName();
      headerValue = webSocketNotifyProperties.getAppSv().getHeaderValue();
      break;
    default:
      eventLogMessage.setLogMessage("通知宛先未指定 ");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }

    // 通知対象と繋がっているサーバーのIPアドレスを取得
    List<MntClientConnect> mntClientConnectList = this.mntClientConnectDao.selectByServerType(facilityCd,
        targetServerType);
    if (true == StringUtils.isEmpty(mntClientConnectList)) {
      eventLogMessage.setLogMessage("通知宛先未接続 ");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }
    for (MntClientConnect item : mntClientConnectList) {

      eventLogMessage.setLogMessage("API sendmassage CALLED IP : " + item.getIpAddress());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      commApiUri.setLength(0);
      commApiUri
          .append("http://")
          .append(item.getIpAddress())
          .append(":")
          .append(apiPort)
          .append(apiUri);

      if (SendToMessage(targetLabel, commApiUri.toString(), facilityCd, deviceEdgeNo, headerKey, headerValue, topic,
          payload)) {
        eventLogMessage.setLogMessage("API sendMsg 成功 : " + item.getIpAddress());
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // 通知成功
        ret = true;
      } else {
        eventLogMessage.setLogMessage("API sendMsg 失敗: " + item.getIpAddress());
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
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

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
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

      eventLogMessage.setLogMessage("REST API呼び出し:[" + uri + "], body:{ targerId:" + json.getTargetId() + ", message:" + json.getMessage() + "}");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // リクエスト処理
      ResponseEntity<HttpStatus> response = rt.exchange(request, HttpStatus.class);
      HttpStatus status = response.getStatusCode();
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.web_api.service.webSocketNotify.WebSocketNotifyServiceImpl");
      map.put("methodName", "SendToMessage");
      map.put("method", request.getMethod());
      map.put("url", request.getUrl());
      map.put("headers", request.getHeaders().toSingleValueMap());
      map.put("requestParameter", request.getBody());
      map.put("status",status);
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      restTemplateEventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      if (HttpStatus.OK != status) {
        eventLogMessage.setLogMessage("DE通知API：RestAPI側で接続失敗 " + status);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return false;
      }
    } catch (Exception ex) {
      eventLogMessage.setLogMessage("DE通知API：RestAPI呼び出し処理で例外発生 " + ex.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }
    eventLogMessage.setLogMessage("DE通知API：接続成功");
    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return true;
  }
}
