package jp.co.nikkiso.ntss.device_edge_updater_front.service;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;

public interface MntDeviceEdgeUpdaterManageService {
  
  MntDeviceEdgeManage selectByManageNo(Long manageNo);
  int insertNewRecordManageNo(MntDeviceEdgeManage param);
  int updateUpdaterManage(MntDeviceEdgeManage param);
}
