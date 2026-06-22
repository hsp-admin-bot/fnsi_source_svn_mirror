package jp.co.nikkiso.ntss.client_comm.web.rest;

import java.net.URISyntaxException;

import jakarta.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import jp.co.nikkiso.ntss.client_comm.service.LogService;
import jp.co.nikkiso.ntss.client_comm.web.dto.SendClientMessageDTO;
import jp.co.nikkiso.ntss.client_comm.web.websocket.SessionManager;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;


@RestController
@RequestMapping("/api")
public class ApiResource {


  @Autowired
  private SessionManager sessionCtrl;

  @Autowired
  private LogService logService;


  @GetMapping("/clientlist")
  public ResponseEntity<String> getAll(HttpServletRequest request) throws URISyntaxException {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("REST clientlist CALLED IP：" + request.getRemoteAddr());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return new ResponseEntity<>(sessionCtrl.getClients(), HttpStatus.OK);
  }


  @PostMapping("/sendmessage")
  public ResponseEntity<Void> sendMsg(HttpServletRequest request, @RequestBody SendClientMessageDTO SendClientMessage) {

    ResponseEntity<Void> ret;
    StringBuilder sb = new StringBuilder();
    sb.append("REST sendmassage CALLED IP : " + request.getRemoteAddr());
    sb.append(", targetId : " + SendClientMessage.getTargetId() + " -> " + SendClientMessage.getDecodeTargetId());
    sb.append(", message  : " + SendClientMessage.getMessage()  + " -> " + SendClientMessage.getDecodeMessage());
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(sb.toString());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // 施設コード取得
    String facilityCd = SendClientMessage.getDecodeTargetId().substring(0, 6);


    // 全サーバー対象で指定施設コードを持つWebSocketクライアントへの通知結果
    if( sessionCtrl.sendMessageToAllServer(request.getRemoteAddr(), facilityCd, SendClientMessage) == true ) {
      // 成功
      ret = new ResponseEntity<>(HttpStatus.OK);
    } else {
      // 失敗
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //ret = new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      ret= new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }

    sb.setLength(0);
    sb.append("REST sendmassage CALLED IP : " + request.getRemoteAddr());
    sb.append(", targetId : " + SendClientMessage.getDecodeTargetId());
    sb.append(", status : " + ret.getStatusCode());
    eventLogMessage.setLogMessage(sb.toString());
    eventLogMessage.setFacilityCd(facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return ret;
  }

  @PostMapping("/sendclient")
  public ResponseEntity<Void> sendClientMsg(HttpServletRequest request, @RequestBody SendClientMessageDTO SendClientMessage) {

    ResponseEntity<Void> ret;
    StringBuilder sb = new StringBuilder();
    sb.append("REST sendclient CALLED IP : " + request.getRemoteAddr());
    sb.append(", targetId : " + SendClientMessage.getTargetId() + " -> " + SendClientMessage.getDecodeTargetId());
    sb.append(", message  : " + SendClientMessage.getMessage()  + " -> " + SendClientMessage.getDecodeMessage());
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(sb.toString());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // WebSocket通知
    if(sessionCtrl.sendMessageToClient(SendClientMessage.getDecodeTargetId(), SendClientMessage.getDecodeMessage()) == true) {
      // 成功
      ret = new ResponseEntity<>(HttpStatus.OK);
    } else {
      // 失敗
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 start
      //ret = new ResponseEntity<>(HttpStatus.BAD_REQUEST);
      ret= new ResponseEntity<>(HttpStatus.INTERNAL_SERVER_ERROR);
      // #8081 2023.04.19 mod 応答を BadRequest から InternalServerError に変更する TDC米沢 end
    }
    sb.setLength(0);
    sb.append("REST sendclient CALLED IP : " + request.getRemoteAddr());
    sb.append(", targetId : " + SendClientMessage.getDecodeTargetId());
    sb.append(", status : " + ret.getStatusCode());
    eventLogMessage.setLogMessage(sb.toString());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return ret;
  }

  //　空のメッセージを送信して端末接続状態をチェックする
  @PostMapping("/chkclientconnect")
  public ResponseEntity<Void> chkClientConnect(HttpServletRequest request, @RequestBody SendClientMessageDTO SendClientMessage) {

    ResponseEntity<Void> ret;
    StringBuilder sb = new StringBuilder();
    sb.append("REST chkClientConnect CALLED IP : " + request.getRemoteAddr());
    sb.append(", message  : " + SendClientMessage.getMessage()  + " -> " + SendClientMessage.getDecodeMessage());
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(sb.toString());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    String[] strs = SendClientMessage.getDecodeMessage().split("\t");

    if(sessionCtrl.sendChkMessageToClient(strs[strs.length - 1])) {
      // 成功
      ret = new ResponseEntity<>(HttpStatus.OK);
    } else {
      // 失敗
      ret = new ResponseEntity<>(HttpStatus.BAD_REQUEST);
    }
    sb.setLength(0);
    sb.append("REST chkClientConnect CALLED IP : " + request.getRemoteAddr());
    sb.append(", status : " + ret.getStatusCode());
    eventLogMessage.setLogMessage(sb.toString());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

    return ret;
  }
}
