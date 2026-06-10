package jp.co.nikkiso.ntss.admin_web.service.mstSynchro;

import java.net.URI;
import java.util.Base64;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.dao.MntClientConnectDao;
import jp.co.nikkiso.ntss.core.entity.MntClientConnect;
import lombok.Data;
import lombok.extern.slf4j.Slf4j;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end


/**
 * デバイスエッジ通知アプリ(ntss-client-comm)操作Service.
 */
@Slf4j
@Service
public class DeviceEdgeConnectServiceImpl implements DeviceEdgeConnectService {

  @Autowired
  private MntClientConnectDao mntClientConnectDao;

  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;
  /**
   * デバイスエッジ通知アプリのURI(%sにIPアドレスを挿入すること).
   */
  /* upd by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // private String connectUri = "http://%s:8080/ntss-client-comm/api/sendmessage";
  private static final String CONNECT_URL = "http://%s:8080/ntss-client-comm/api/sendmessage";
  /* upd by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * デバイスエッジ通知アプリのRestAPI呼び出し用クラス(body格納用).
   */
  @Data
  private static class SendMessageJson {
    public String targetId;
    public String message;
  };

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean sendToDeviceEdge(String facilityCd, Integer deviceEdgeNo, String topic, String payload) {

    // 送信情報
    // 通知先判定情報(施設コード + "EDGE"(固定大文字) + DE番号(左0埋め))
    String targerId = facilityCd + "EDGE" + (null == deviceEdgeNo ? "" : String.format("%02d", deviceEdgeNo));

    // 通知先に送るメッセージ情報(AWSIoTトピック名 + {TAB記号} + ペイロード文字列)
    String message = topic + "\t" + payload;

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("[DE通知API]送信情報 ： targerId[" + targerId + "]、message[" + message + "]");
    logService.log(LogLevel.INFO, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS, null);

    // Base64化
    targerId = Base64.getEncoder().encodeToString(targerId.getBytes());
    message = Base64.getEncoder().encodeToString(message.getBytes());

    try {

      // 接続先IPアドレスを取得(サーバ種別は0固定)
      String ipAddress = getConnectIp(facilityCd, 0);
      if (true == StringUtils.isEmpty(ipAddress)) {
        return false;
      }

      // 送信URI
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[DE通知API]接続先URI ： ["+ String.format(CONNECT_URL, ipAddress) + "]");
      logService.log(LogLevel.INFO, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS, null);
      URI uri = new URI(String.format(CONNECT_URL, ipAddress));
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
      ResponseEntity<Object> response = rt.exchange(request, Object.class);
      HttpStatus status = response.getStatusCode();
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.admin_web.service.mstSynchro.DeviceEdgeConnectServiceImpl");
      map.put("methodName", "sendToDeviceEdge");
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
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[DE通知API]RestAPI側で接続失敗 ： ["+ status +"]");
        logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS, null);
        return false;
      }
    } catch (Exception ex) {
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[DE通知API]RestAPI呼び出し処理で例外発生 ： [" + ex.getMessage() +"]");
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS, null);
      return false;
    }

    return true;
  }

  /**
   * DeviceEdgeと繋がっているサーバーのIPアドレスを取得.
   *
   * @param facilityCd 施設コード
   * @param serverType サーバ種別(0：DeviceServer、1：WebApServer)
   * @return IPアドレス
   */
  private String getConnectIp(String facilityCd, int serverType) {

    // DeviceEdgeと繋がっているサーバーのIPアドレスを取得
    List<MntClientConnect> ipList = this.mntClientConnectDao.selectByServerType(facilityCd, serverType);
    //List<MntClientConnect> ipList = this.mntClientConnectDao.selectByFacility(facilityCd);
    if (null == ipList) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[DE通知API]RestAPI呼び出し先IPアドレスの取得失敗 ： 施設コード[" + facilityCd +"]、サーバ種別[" + serverType +"]");
      eventLogMessage.setSqlIdentification("(facilityCd = "+ facilityCd +", serverType = "+ serverType +")");
      logService.log(LogLevel.ERROR, eventLogMessage,FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS,"MntClientConnectDao/selectByServerType");
      return null;
    }
    if (0 == ipList.size()) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[DE通知API]RestAPI呼び出し先IPアドレスの取得件数0件 ： 施設コード[" + facilityCd + "]、サーバ種別[" + serverType +"]");
      logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_DEVICE_EDGE_OPERATION, SERVICE_NAME.REMS, null);
      return null;
    }

    return ipList.get(0).getIpAddress();
  }
}
