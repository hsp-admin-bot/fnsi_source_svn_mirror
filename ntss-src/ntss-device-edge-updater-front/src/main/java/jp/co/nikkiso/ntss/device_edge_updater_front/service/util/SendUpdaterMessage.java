package jp.co.nikkiso.ntss.device_edge_updater_front.service.util;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.entity.MntClientConnect;
import jp.co.nikkiso.ntss.device_edge_updater_front.config.MyProperties;
import jp.co.nikkiso.ntss.device_edge_updater_front.service.MntClientConnectService;
import jp.co.nikkiso.ntss.device_edge_updater_front.service.util.NtssComIO.SendTarget;
import jp.co.nikkiso.ntss.device_edge_updater_front.service.LogService;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;

@Service
public class SendUpdaterMessage {

  @Autowired
  private MntClientConnectService mntClientConnectService;

  @Autowired
  private MyProperties myPropaties;

  @Autowired
  private LogService logService;

  public boolean sendMsg(SendTarget target, String facilityCd, Integer deviceEdgeNo, String topic, String payload) {

    StringBuilder commApiUri = new StringBuilder();
    boolean ret = false;

    EventLogMessage eventLogMessage = new EventLogMessage();

    // WebSocketクライアント接続状態から対象施設コードの一覧を取得する
    List<MntClientConnect> mntClientConnectList = mntClientConnectService.findByFacility(facilityCd);
    for (MntClientConnect item : mntClientConnectList) {
      eventLogMessage.setLogMessage("API sendmassage CALLED IP : " + item.getIpAddress());
      eventLogMessage.setFacilityCd(facilityCd);
      //FNSI-修正 ログ対応 xiebzh add start
      eventLogMessage.setInvokeClass(this.getClass().getName());
      //FNSI-修正 ログ対応 xiebzh add end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);

      commApiUri.setLength(0);
      commApiUri
      .append("http://")
      .append(item.getIpAddress())
      .append(":")
      .append(myPropaties.getWebsocket().getPort())
      .append(myPropaties.getWebsocket().getSenduri());

      if(NtssComIO.SendToMessage(target, commApiUri.toString(), facilityCd, deviceEdgeNo, topic, payload)) {
        eventLogMessage.setLogMessage("API sendmassage 成功 : " + item.getIpAddress());
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.REMS, null);
        // 通知成功
        ret = true;
      }else {
        eventLogMessage.setLogMessage("API sendmassage 失敗: " + item.getIpAddress());
        eventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.REMS, null);
      }
    }

    return ret;
  }
}
