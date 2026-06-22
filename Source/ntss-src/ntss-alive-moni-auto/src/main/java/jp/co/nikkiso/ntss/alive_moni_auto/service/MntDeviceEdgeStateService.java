package jp.co.nikkiso.ntss.alive_moni_auto.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;

public interface MntDeviceEdgeStateService {
  List<MntDeviceEdgeState> findById(String facilityCd, int deviceEdgeNo);
}
