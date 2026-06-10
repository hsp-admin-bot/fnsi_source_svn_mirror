package jp.co.nikkiso.ntss.client_comm.web.websocket;

import java.io.IOException;
import java.util.List;

import jp.co.nikkiso.ntss.client_comm.service.MntDeviceEdgeStateService;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.socket.BinaryMessage;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;
import jp.co.nikkiso.ntss.client_comm.service.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
public class MessageHandler extends TextWebSocketHandler{

  @Autowired
  private SessionManager sessionCtrl;

  @Autowired
  private LogService logService;

  @Autowired
  private MntDeviceEdgeStateService mntDeviceEdgeStateService;

  // add FNSI-バグ #7480 通信サーバ 高 start
  final private String _topicProBase = "NTSS/PROCESS_STATE";
  // add FNSI-バグ #7480 通信サーバ 高 end

  public MessageHandler() {
  }

  @Override
  /**
   * 接続完了後
   */
  public void afterConnectionEstablished(WebSocketSession session) throws Exception {

    // 初回サービス稼働PCのIPアドレスを削除する処理
    if( sessionCtrl.deleteIP() == true ) {
      // 初回処理が行われている場合

      // 接続が確立されたら、セッション情報を保存
      sessionCtrl.addSession(session);
    }
    else {
      // 初回処理が行われていない場合

      // 接続を解除
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("afterConnectionEstablished session close. IP = " + session.getRemoteAddress().toString() + ", " + "Session ID = " + session.getId());
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      session.close();
    }
  }

  @Override
  /**
   * 接続切断後
   */
  public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("afterConnectionClosed session close. IP = " + session.getRemoteAddress().toString() + ", " + "Session ID = " + session.getId());
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // 接続が切られたらセッション情報を破棄
    sessionCtrl.removeSession(session);
  }

  @Override
  /**
   * テキスト受信時
   */
  public void handleTextMessage(WebSocketSession session, TextMessage message) {

    // メッセージ取得
    String msg = message.getPayload();

    // キー情報取得
    String key = sessionCtrl.getClientKey(session);

    // 施設コード
    String fcd = "";
    // 識別子
    String deviceId = "";
    // クライアントキーから施設コード、識別子を取得
    List<String> param = sessionCtrl.getClientKeyParams( key );
    if( 0 < param.size() ) {
      // 施設コード取得
      fcd = param.get(0);
      // 識別子取得
      deviceId = param.get(1);
    }

    // WebSocketクライアントからメッセージを受信した時に呼ばれる
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("recieve message. IP = " + session.getRemoteAddress().toString() + ", "
        + "Session ID = " + session.getId() + ",　Client Key = " + key + ", Message =[" + msg + "]");
    eventLogMessage.setFacilityCd(fcd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // 識別判定
    if( msg.startsWith("NTSS") == true ) {
      // テキストの先頭が「NTSS」の場合

      // 端末固有IDの取得
      String terminalUniqueStr = "";
      String splitStr = "BROWSER";
      int splitIndex = msg.indexOf(splitStr);
      if (splitIndex > -1) {
        terminalUniqueStr = msg.substring(splitIndex + splitStr.length());
        // 端末固有IDをmsgから除去
        msg = msg.replace(terminalUniqueStr, "");
      }

      // 識別子判定処理
      key = sessionCtrl.checkWSCertification( msg.substring( 4 ));
      if( 0 < key.length() ) {
        // 認証OK

        // クライアント接続確立処理を行う
        sessionCtrl.addClient( key, session, terminalUniqueStr);
      } else {
        // 認証NG

        try {
          eventLogMessage.setLogMessage("not establishment session. IP = " + session.getRemoteAddress().toString() + ", Session ID = " + session.getId() + ", Client Key = " + key);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          session.close(CloseStatus.NOT_ACCEPTABLE.withReason("not supported"));
        }
        catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
      }
    } else {
      // クライアント接続確立一覧に同じセッションが登録されているかどうかを判定
      if( sessionCtrl.existWSClientInfo(session) == null ) {
        // セッションがない場合は切断

        try {
          eventLogMessage.setLogMessage("not establishment session. IP = " + session.getRemoteAddress().toString() + ", Session ID = " + session.getId() + ", Client Key = " + key);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          session.close(CloseStatus.NOT_ACCEPTABLE.withReason("not supported"));
        }
        catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
      } else {
        // セッションがある場合

        // クライアントの最終受信日時を更新
        sessionCtrl.updateWSClientInfoLastRecieved( session );

        // クライアント種別判定
        if( sessionCtrl.checkClientClass( key ) == Client_Classes.DEVICE_EDGE ) {
          // クライアントがデバイスエッジである場合

          // デバイスエッジ番号取得
          int deviceEdgeNo = Integer.parseInt( deviceId.substring( Client_Classes.DEVICE_EDGE.getName().length() ));

          // add FNSI-バグ #7480 通信サーバ 高 start
          try {
            List<MntDeviceEdgeState> lstMntDeviceEdgeState = mntDeviceEdgeStateService.findByFacilityDeviceEdgeNo(fcd, deviceEdgeNo);
            if (null != lstMntDeviceEdgeState && 0 != lstMntDeviceEdgeState.size()) {
              if(("F1".equals(lstMntDeviceEdgeState.get(0).getAliveMoniStatus()) || "F2".equals(lstMntDeviceEdgeState.get(0).getAliveMoniStatus()))) {
                String topic = _topicProBase + "/" + fcd + "/" + deviceEdgeNo + "\t";
                TextMessage message1 = new TextMessage(topic);
                session.sendMessage(message1);
              }
            }
          }
          catch (Exception ex1) {
            eventLogMessage.setLogMessage("死活監視PROCESS API：要求失敗　対象施設コード[" + fcd + "]、対象デバイスエッジ番号 [" + deviceEdgeNo + "]");
            eventLogMessage.setDeviceEdgeNo(String.valueOf(deviceEdgeNo));
            eventLogMessage.setFacilityCd(fcd);
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
          }
          // add FNSI-バグ #7480 通信サーバ 高 end

          // デバイスエッジのモニタ生存最終更新日時を更新
          sessionCtrl.updateAliveMoni( fcd, deviceEdgeNo );
        }

        try {

          // 受信データを再送信
          eventLogMessage.setLogMessage("send message. IP = " + session.getRemoteAddress().toString() + ", Session ID = " + session.getId() + ", Client Key = " + key +  ", Message = " + message);
          eventLogMessage.setFacilityCd(fcd);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          session.sendMessage( message );
          eventLogMessage.setLogMessage("send message. IP = " + session.getRemoteAddress().toString() + ", Session ID = " + session.getId() + ", Client Key = " + key + " success");
          eventLogMessage.setFacilityCd(fcd);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }
        catch (Exception ex) {

          // 送信失敗

          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
          eventLogMessage.setFacilityCd(fcd);
          logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

          try {
            // セッション切断
            eventLogMessage.setLogMessage("handleTextMessage Exception session close. IP = " + session.getRemoteAddress().toString() + ", " + "Session ID = " + session.getId());
            eventLogMessage.setFacilityCd(fcd);
            logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            session.close(CloseStatus.NOT_ACCEPTABLE);
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
            eventLogMessage.setFacilityCd(fcd);
            logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          }
        }
      }
    }
  }

  @Override
  /**
   * バイナリー受信時
   */
  protected void handleBinaryMessage(WebSocketSession session, BinaryMessage message) {
      // バイナリを受信した場合はソケットを閉じる
      try {
          // キー情報取得
          String key = sessionCtrl.getClientKey(session);

          // 施設コード
          String fcd = "";
          // クライアントキーから施設コード、識別子を取得
          List<String> param = sessionCtrl.getClientKeyParams( key );
          if( 0 < param.size() ) {
            // 施設コード取得
            fcd = param.get(0);
          }

          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("handleBinaryMessage session close. IP = " + session.getRemoteAddress().toString() + ", " + "Session ID = " + session.getId());
          eventLogMessage.setFacilityCd(fcd);
          logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          session.close(CloseStatus.NOT_ACCEPTABLE.withReason("Binary messages not supported"));
      }
      catch (IOException ex) {
          // ignore
      }
  }
}
