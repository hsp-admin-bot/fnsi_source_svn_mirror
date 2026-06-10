package jp.co.nikkiso.ntss.client_comm.service;

import java.util.List;
import java.time.Clock;

import jp.co.nikkiso.ntss.core.entity.MntWebsocketCertification;


/**
 * WebSocket認証コードサービス
 */
public interface MntWebsocketCertificationService {

  List<MntWebsocketCertification> findByCertification(String certificationCd);

  int insert(String certificationCd, String facilityCd);

  int delete(String certificationCd);
  
  int deleteAfterMinute(int addMinute);
  
  Clock getTime();
}
