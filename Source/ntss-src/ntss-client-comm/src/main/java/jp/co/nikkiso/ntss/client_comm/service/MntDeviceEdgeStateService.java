package jp.co.nikkiso.ntss.client_comm.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;


/**
 * デバイスエッジ状態管理サービス
 */
public interface MntDeviceEdgeStateService {

  List<MntDeviceEdgeState> findByFacilityDeviceEdgeNo(String facilityCd, int deviceEdgeNo);

  int updateAliveMoni(MntDeviceEdgeState param);
}
