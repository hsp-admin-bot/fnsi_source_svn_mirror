package jp.co.nikkiso.ntss.alive_moni.service.util;

import java.net.URI;
import java.util.Base64;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.HashMap;
import java.util.Map;

import com.fasterxml.jackson.core.JsonProcessingException;
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
import org.springframework.web.client.RestTemplate;

import jp.co.nikkiso.ntss.alive_moni.service.LogServiceImpl;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@Service
public class NtssComIOServiceImpl implements NtssComIOService {
  @Autowired
  LogServiceImpl logService;

  /**
   * AWSIoT代替機能RestAPI呼び出し用クラス(body格納用)
   */
  private static class SendMessageJson {
    public String targetId;
    public String message;

    public String getTargetId() {
      return this.targetId;
    }

    public void setTargetId(String targetId) {
      this.targetId = targetId;
    }

    public String getMessage() {
      return this.message;
    }

    public void setMessage(String message) {
      this.message = message;
    }
  };

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean SendToMessage(String commApiUri, String facilityCd, Integer deviceEdgeNo, String topic,
      String payload) {
    // 送信情報
    // 通知先判定情報(施設コード + "EDGE"(固定大文字) + DE番号(左0埋め))
    String targerId = facilityCd + "EDGE" + (null == deviceEdgeNo ? "" : String.format("%02d", deviceEdgeNo));
    // 通知先に送るメッセージ情報(AWSIoTトピック名 + {TAB記号} + ペイロード文字列)
    String message = topic + "\t" + payload;

    // Base64化
    targerId = Base64.getEncoder().encodeToString(targerId.getBytes());
    message = Base64.getEncoder().encodeToString(message.getBytes());

    EventLogMessage eventLogMessage = new EventLogMessage();
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
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      // リクエスト処理
      ResponseEntity<HttpStatus> response = rt.exchange(request, HttpStatus.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.alive_moni.service.util.NtssComIOServiceImpl");
      map.put("methodName", "SendToMessage");
      map.put("method", request.getMethod());
      map.put("url", request.getUrl());
      map.put("headers", request.getHeaders().toSingleValueMap());
      map.put("requestParameter", request.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      restTemplateEventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      HttpStatus status = response.getStatusCode();
      if (HttpStatus.OK != status) {
        eventLogMessage.setLogMessage("DE通知API：RestAPI側で接続失敗 " + status);
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return false;
      }
    } catch (Exception ex) {

      eventLogMessage.setLogMessage("DE通知API：RestAPI呼び出し処理で例外発生 " + ex.getMessage());
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }

    eventLogMessage.setLogMessage("DE通知API：接続成功");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.REMS, null);

    return true;
  }
}
