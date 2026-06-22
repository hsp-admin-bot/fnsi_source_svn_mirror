package jp.co.nikkiso.ntss.device_edge_updater.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeManageDao;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;

@Service
public class DeviceEdgeUpdaterManageServiceImpl implements DeviceEdgeUpdaterManageService {

  @Autowired
  private MntDeviceEdgeManageDao mntDeviceEdgeManageDao;

  @Override
  @Transactional
  public int updateUpdaterManage(MntDeviceEdgeManage param) {
    return mntDeviceEdgeManageDao.update(param);
  }

  @Override
  public MntDeviceEdgeManage selectByManageNo(Long manageNo) {
    return mntDeviceEdgeManageDao.selectByManageNo(manageNo);
  }
}
