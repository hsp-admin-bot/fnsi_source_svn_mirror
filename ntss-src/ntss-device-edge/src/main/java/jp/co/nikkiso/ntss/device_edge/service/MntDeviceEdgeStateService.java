package jp.co.nikkiso.ntss.device_edge.service;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;

import java.util.List;

public interface MntDeviceEdgeStateService {
  int updateAliveMoni(MntDeviceEdgeState param);
  // add FNSI-バグ #7480 通信サーバ 高 start
  List<MntDeviceEdgeState> findById(String facilityCd, Integer deviceEdgeNo);
  // add FNSI-バグ #7480 通信サーバ 高 end
}
