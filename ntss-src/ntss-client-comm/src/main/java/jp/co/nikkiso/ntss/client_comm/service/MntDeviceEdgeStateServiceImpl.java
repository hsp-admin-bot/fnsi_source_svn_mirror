package jp.co.nikkiso.ntss.client_comm.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;
import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeStateDao;



/**
 * デバイスエッジ状態管理サービス
 */
@Service
public class MntDeviceEdgeStateServiceImpl implements MntDeviceEdgeStateService{

  @Autowired
  private MntDeviceEdgeStateDao mntDeviceEdgeStateDao;


  public List<MntDeviceEdgeState> findByFacilityDeviceEdgeNo(String facilityCd, int deviceEdgeNo) {
    List<MntDeviceEdgeState> mntDeviceEdgeStateList = mntDeviceEdgeStateDao.selectByFacilityDeviceEdgeNo(facilityCd, deviceEdgeNo);
    return mntDeviceEdgeStateList;
  }

  @Override
  @Transactional
  public int updateAliveMoni(MntDeviceEdgeState param) {
    return mntDeviceEdgeStateDao.updateAliveMoni(param);
  }

}
