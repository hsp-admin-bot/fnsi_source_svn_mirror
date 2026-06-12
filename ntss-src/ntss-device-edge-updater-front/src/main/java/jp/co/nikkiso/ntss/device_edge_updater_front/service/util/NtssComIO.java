package jp.co.nikkiso.ntss.device_edge_updater_front.service.util;

import java.net.URI;
import java.util.Base64;
import jp.co.nikkiso.ntss.device_edge_updater_front.service.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.web.client.RestTemplate;

import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

import lombok.Getter;
import lombok.Setter;

public class NtssComIO {
  
  @Autowired
  private static LogService logService;

  /**
   * WebSocketSendMessage RestAPI呼び出し用クラス(body格納用)
   */
  @Getter
  @Setter
  private static class SendMessageJson {
    public String targetId;
    public String message;
  };
  
  public static enum SendTarget {
    main,
    updater,
    webmoni
  }
  
  /**
   * DE通知API呼び出し
   * @return true：成功、false：失敗
   */
  public static boolean SendToMessage(SendTarget target, String commApiUri, String facilityCd, Integer deviceEdgeNo, String topic, String payload)
  {
    String targetStr = "";
    switch (target) {
    case main:
      targetStr = "EDGE";
      break;
      
    case updater:
      targetStr = "UPDEDGE";
      break;
      
    case webmoni:
      targetStr = "WEBMONI";
      break;
      
    default:
      break;
    }
    // 送信情報
    // 通知先判定情報(施設コード + "EDGE"(固定大文字) + DE番号(左0埋め))
    String targerId = facilityCd + targetStr + (null == deviceEdgeNo ? "" : String.format("%02d", deviceEdgeNo));
    // 通知先に送るメッセージ情報(AWSIoTトピック名 + {TAB記号} + ペイロード文字列)
    String message = topic + "\t" + payload;
    
    // Base64化
    targerId = Base64.getEncoder().encodeToString(targerId.getBytes());
    message = Base64.getEncoder().encodeToString(message.getBytes());
    EventLogMessage eventLogMessage = new EventLogMessage();
    try
    {
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
      
      // リクエスト処理
      ResponseEntity<HttpStatus> response = rt.exchange(request, HttpStatus.class);
      HttpStatus status = HttpStatus.valueOf(response.getStatusCode().value());
      if (HttpStatus.OK != status)
      {
        eventLogMessage.setLogMessage("DE通知API：RestAPI側で接続失敗 " + status);
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
        return false;
      }
    }
    catch (Exception ex)
    {
      eventLogMessage.setLogMessage("DE通知API：RestAPI呼び出し処理で例外発生 " + ex.getMessage());
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      return false;
    }
    eventLogMessage.setLogMessage("DE通知API：接続成功");
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
    
    return true;
  }
}
