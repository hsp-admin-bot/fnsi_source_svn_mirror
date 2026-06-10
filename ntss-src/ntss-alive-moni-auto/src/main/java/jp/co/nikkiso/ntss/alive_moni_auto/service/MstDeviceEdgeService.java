package jp.co.nikkiso.ntss.alive_moni_auto.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;

public interface MstDeviceEdgeService {
  List<MstDeviceEdge> findById(String facilityCd);
}
