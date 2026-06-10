package jp.co.nikkiso.ntss.device_edge_updater_front.service;

import java.math.BigDecimal;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeUpdaterManage;

public interface MntDeviceEdgeUpdaterManageService {
  
  MntDeviceEdgeUpdaterManage selectByManageNo(BigDecimal manageNo);
  int insertNewRecordManageNo(MntDeviceEdgeUpdaterManage param);
  int updateUpdaterManage(MntDeviceEdgeUpdaterManage param);
}
