package jp.co.nikkiso.ntss.client_comm.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.entity.MntClientConnect;
import jp.co.nikkiso.ntss.core.dao.MntClientConnectDao;


/**
 * WebSocket接続状態サービス
 */
@Service
public class MntClientConnectServiceImpl implements MntClientConnectService{

  @Autowired
  private MntClientConnectDao mntClientConnectDao;


  @Override
  public List<MntClientConnect> findByIp(String ipAddress) {
    List<MntClientConnect> mntClientConnectList = mntClientConnectDao.selectByIp(ipAddress);
    return mntClientConnectList;
  }

  @Override
  public List<MntClientConnect> findByFacility(String facilityCd) {
    List<MntClientConnect> mntClientConnectList = mntClientConnectDao.selectByFacility(facilityCd);
    return mntClientConnectList;
  }

  @Override
  public List<MntClientConnect> findByIpFacility(String ipAddress, String facilityCd) {
    List<MntClientConnect> mntClientConnectList = mntClientConnectDao.selectByIpFacility(ipAddress, facilityCd);
    return mntClientConnectList;
  }

  @Override
  @Transactional
  public int insert(String ipAddress, String facilityCd, int serverType) {
    // 接続情報作成
    MntClientConnect mntClientConnect = new MntClientConnect();
    mntClientConnect.setIpAddress(ipAddress);
    mntClientConnect.setFacilityCd(facilityCd);
    mntClientConnect.setServerType(serverType);

    return mntClientConnectDao.insert(mntClientConnect);
  }

  @Override
  @Transactional
  public int update(String ipAddress, String facilityCd) {
    // 接続情報作成
    MntClientConnect mntClientConnect = new MntClientConnect();
    mntClientConnect.setIpAddress(ipAddress);
    mntClientConnect.setFacilityCd(facilityCd);

    return mntClientConnectDao.update(mntClientConnect);
  }


  @Override
  @Transactional
  public void deleteByIp(String ipAddress) {
    List<MntClientConnect> mntClientConnectList = this.findByIp(ipAddress);
    mntClientConnectList.forEach( item -> mntClientConnectDao.delete(item) );
  }

  @Override
  @Transactional
  public void deleteByIpFacility(String ipAddress, String facilityCd) {
    List<MntClientConnect> mntClientConnectList = this.findByIpFacility(ipAddress, facilityCd);
    mntClientConnectList.forEach( item -> mntClientConnectDao.delete(item) );
  }
}
