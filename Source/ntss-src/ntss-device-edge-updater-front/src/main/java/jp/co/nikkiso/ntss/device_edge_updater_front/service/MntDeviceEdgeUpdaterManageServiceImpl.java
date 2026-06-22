package jp.co.nikkiso.ntss.device_edge_updater_front.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeManageDao;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;

@Service
public class MntDeviceEdgeUpdaterManageServiceImpl implements MntDeviceEdgeUpdaterManageService{

  @Autowired
  private MntDeviceEdgeManageDao mntDeviceEdgeUpdaterManageDao;

  @Override
  @Transactional
  public int updateUpdaterManage(MntDeviceEdgeManage param) {
    return mntDeviceEdgeUpdaterManageDao.update(param);
  }

  @Override
  public MntDeviceEdgeManage selectByManageNo(Long manageNo) {
    return mntDeviceEdgeUpdaterManageDao.selectByManageNo(manageNo);
  }

  @Override
  @Transactional
  public int insertNewRecordManageNo(MntDeviceEdgeManage param) {
    return mntDeviceEdgeUpdaterManageDao.insertNewRecordManageNo(param);
  }
  
}
