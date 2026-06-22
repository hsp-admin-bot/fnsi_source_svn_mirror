package jp.co.nikkiso.ntss.device_edge_updater.service;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;

public interface DeviceEdgeUpdaterManageService {

  MntDeviceEdgeManage selectByManageNo(Long manageNo);
  int updateUpdaterManage(MntDeviceEdgeManage param);
}
