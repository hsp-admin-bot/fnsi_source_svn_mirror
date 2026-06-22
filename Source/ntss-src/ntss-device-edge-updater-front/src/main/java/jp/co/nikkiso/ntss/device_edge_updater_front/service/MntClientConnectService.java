package jp.co.nikkiso.ntss.device_edge_updater_front.service;

import java.util.List;

//import jp.co.nikkiso.ntss.client_comm.entity.MntClientConnect;
import jp.co.nikkiso.ntss.core.entity.MntClientConnect;


/**
 * WebSocket接続状態サービス
 */
public interface MntClientConnectService {

  List<MntClientConnect> findByIp(String ipAddress);

  List<MntClientConnect> findByFacility(String facilityCd);

  List<MntClientConnect> findByIpFacility(String ipAddress, String facilityCd);

  int insert(String ip_address, String facilityCd);

  int update(String ip_address, String facilityCd);

  void deleteByIp(String ipAddress);
  
  void deleteByIpFacility(String ipAddress, String facilityCd);
}
