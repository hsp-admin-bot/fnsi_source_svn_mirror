package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MstDeviceEdgeDao;
import jp.co.nikkiso.ntss.core.entity.MstDeviceEdge;

/**
 * デバイスエッジマスタサービス
 */
@Service
public class MstDeviceEdgeServiceImpl implements MstDeviceEdgeService {

  @Autowired
  private MstDeviceEdgeDao mstDeviceEdgeDao;
  
  @Override
  public List<MstDeviceEdge> selectAll() {
    List<MstDeviceEdge> mstDeviceEdgeList = mstDeviceEdgeDao.selectAll();
    return mstDeviceEdgeList;
  }
  
  @Override
  public MstDeviceEdge findByEdgeNoAndFacilityCd(Integer deviceEdgeNo, String facilityCd) {
    return mstDeviceEdgeDao.selectByEdgeNoAndFacilityCd(deviceEdgeNo, facilityCd);
  }
}
