package jp.co.nikkiso.ntss.admin_web.service.master.machine;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.mstSynchro.DeviceEdgeConnectService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MntFindMachineDao;
import jp.co.nikkiso.ntss.core.entity.MntFindMachine;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;


@Service
public class MntFindMachineServiceImpl implements MntFindMachineService {
  @Autowired
  MntFindMachineDao mntFindMachineDao;
  @Autowired
  private DeviceEdgeConnectService deviceEdgeConnectService;
  /**
  * ロギングのServiceインタフェース.
  */
  @Autowired
  private LogService logService;
  /**
   * topicの共通部分
   */
  private final String topicBase = "NTSS/CHANGE_MODE";

  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional
  public int deleteByFacilityCd(String facilityCd) {
    return mntFindMachineDao.deleteByFacilityCd(facilityCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MntFindMachine> selectByFacilityCd(String facilityCd) {
	return mntFindMachineDao.selectByFacilityCd(facilityCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MntFindMachine> selectAll() {
	return mntFindMachineDao.selectAll();
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public boolean deviceSearch(String facilityCd, Integer procMode, Integer deviceEdgeNo) {
    // デバイスエッジへ送信するデータ格納用
    String payload = "";
    // 型式コード
    if(procMode.equals(0) || procMode.equals(1)) {
        payload += procMode.toString();
    }else {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("[装置検索指示]ペイロードのbyte精査処理で異常 ： 動作モード[" +  procMode.toString() + "]");
        logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    	return false;
    }
    // 同期依頼
    String topic = this.topicBase + "/" + facilityCd + "/" + deviceEdgeNo;
    if (false == this.deviceEdgeConnectService.sendToDeviceEdge(facilityCd, deviceEdgeNo, topic, payload)) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("[装置検索指示]DE通知API処理で失敗 ： 施設コード[" + facilityCd +"]、デバイスエッジ番号[" + deviceEdgeNo +"]、指示[" + payload + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }

    return true;
  }
}