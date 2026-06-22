package jp.co.nikkiso.ntss.coop_api.web.websocket;

import jp.co.nikkiso.ntss.core.dao.MstIfEdgeDao;
import jp.co.nikkiso.ntss.core.entity.MstIfEdge;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.IfedgeFixedResult;
import jp.co.nikkiso.ntss.coop_api.utils.IfEdgeConstants.ResultStatus;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeManage.EdgeResult;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.coop_api.service.LogService;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/** 送信 */
public class IfEdgeSysJournalHandler extends TextWebSocketHandler{

  private final String NODE_KEY_VALUE = "NTSS-NKK-ESM-TDC-YSK-NODE";

  /** Websocket管理クラス */
  @Autowired
  private IfEdgeMntSessionManager sessionManager;

  /** ObjectMapper */
  @Autowired
  ObjectMapper objectMapper;

  /** logService */
  @Autowired
  private LogService logService;

  // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
  /**
   * 連携エッジマスタDao
   */
  @Autowired
  private MstIfEdgeDao mstIfEdgeDao;
  // add 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end

  public IfEdgeSysJournalHandler() {
  }

  @Override
  /**
   * 接続完了後
   *
   * @param session Websocketセッション
   */
  public void afterConnectionEstablished(WebSocketSession session) throws Exception {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage("connected. [LocalAddress:"+ session.getLocalAddress() +"][sessionId: " +  session.getId() + "][url:" + session.getUri() + "]");
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    /* add by chamaojia 2024-06-24 [10574] communication security related additions --start */
    sessionManager.addConnectClient(session);
    /* add by chamaojia 2024-06-24 [10574] communication security related additions --end */
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  }

  @Override
  /**
   * 接続切断後
   *
   * @param session Websocketセッション
   * @param status クローズステータス
   */
  public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
    // 接続が切られたらセッション情報を破棄
    // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
    // sessionManager.removeClient(session, status, IfedgeFixedResult.SERVER_DISCONNECT);
    sessionManager.removeClient(session, status, IfedgeFixedResult.SERVER_DISCONNECT,true);
    // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
    EventLogMessage eventLogMessage = new EventLogMessage();
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    eventLogMessage.setLogMessage("disconnected. [LocalAddress:"+ session.getLocalAddress() +"][sessionId: " +  session.getId() + "][url:" + session.getUri() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
  }

  @Override
  /**
   * テキスト受信時
   *
   * @param session Websocketセッション
   * @param message 受信メッセージ
   */
  protected void handleTextMessage(WebSocketSession session, TextMessage message) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    eventLogMessage.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end

    eventLogMessage.setLogMessage("received message. [LocalAddress:"+ session.getLocalAddress() +"][sessionId: " +  session.getId() + "][url:" + session.getUri() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    eventLogMessage.setLogMessage("message[" +  message.getPayload() + "]");
    logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // 受信したメッセージをJSONに変換
    EdgeResult edgeResult = null;
    try {
      edgeResult = objectMapper.readValue(message.getPayload(), EdgeResult.class);
      switch(ResultStatus.getEnum(edgeResult.getStatus())) {
        case CONNECT:
          // エッジからの接続通知
          // mod 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 start
//          sessionManager.addClient(session, edgeResult.getFacilityCd());
          // マスタ（mst_if_edge）から、施設と使用するエッジとの紐づけはマスタ（mst_if_edge）がありか？
          MstIfEdge mstIfEdge = mstIfEdgeDao.selectByFacilityCdSerialNo(edgeResult.getFacilityCd(), edgeResult.getSerialNo());
          /* modify by chamaojia 2024-06-24 [10574] communication security related additions --start */
          if (mstIfEdge == null || !NODE_KEY_VALUE.equals(edgeResult.getSseccayek())) {
            throw new NtssException(String.format("施設と使用するエッジとの紐づけはマスタ（mst_if_edge）に存在しません。施設コード:[%s],シリアル番号:[%s]", edgeResult.getFacilityCd(), edgeResult.getSerialNo()));
          }
          /* modify by chamaojia 2024-06-24 [10574] communication security related additions --end */
// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 start
//          sessionManager.addClient(session, edgeResult.getFacilityCd(), edgeResult.getSerialNo());
          sessionManager.addClient(session, edgeResult);
// mod 2023-02-22 bug #6912 エッジの連携処理を停止しても稼働ビューア画面では正常と表示される 孫 end
          // mod 2021-06-04 #5271:エッジのシリアルチェックがされていない 孫 end
          break;
        case RESULT:
          // エッジから実行結果返却
          sessionManager.saveResult(edgeResult);
          break;
        default: break;
      }
    } catch(Exception e) {
      // 例外が起こったらセッション情報を破棄
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
      // sessionManager.removeClient(session, CloseStatus.SERVER_ERROR, IfedgeFixedResult.IFEDGE_RES_ERR);
      sessionManager.removeClient(session, CloseStatus.SERVER_ERROR, IfedgeFixedResult.IFEDGE_RES_ERR,true);
      // mod 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
      // ログに吐きだして正常に終了
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return;
    }
  }
}
