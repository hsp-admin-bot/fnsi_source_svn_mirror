package jp.co.nikkiso.ntss.device_edge_updater_front.service;

import java.math.BigDecimal;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeUpdaterManageDao;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeUpdaterManage;

@Service
public class MntDeviceEdgeUpdaterManageServiceImpl implements MntDeviceEdgeUpdaterManageService{

  @Autowired
  private MntDeviceEdgeUpdaterManageDao mntDeviceEdgeUpdaterManageDao;

  @Override
  @Transactional
  public int updateUpdaterManage(MntDeviceEdgeUpdaterManage param) {
    return mntDeviceEdgeUpdaterManageDao.updateUpdaterManage(param);
  }

  @Override
  public MntDeviceEdgeUpdaterManage selectByManageNo(BigDecimal manageNo) {
    return mntDeviceEdgeUpdaterManageDao.selectByManageNo(manageNo);
  }

  @Override
  @Transactional
  public int insertNewRecordManageNo(MntDeviceEdgeUpdaterManage param) {
    return mntDeviceEdgeUpdaterManageDao.insertNewRecordManageNo(param);
  }
  
}
