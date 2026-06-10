package jp.co.nikkiso.ntss.client_comm.web.websocket;

//import org.springframework.web.socket.TextMessage;

public interface WebSocketSessionControl {
  public boolean sendMessageToClient(String targetId, String message);
}
