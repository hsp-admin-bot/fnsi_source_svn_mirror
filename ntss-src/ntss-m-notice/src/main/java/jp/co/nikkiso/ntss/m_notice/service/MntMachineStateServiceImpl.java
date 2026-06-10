package jp.co.nikkiso.ntss.m_notice.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.core.dao.MntMachineStateDao;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;

/**
 * 装置状態管理サービス.
 */
@Service
public class MntMachineStateServiceImpl implements MntMachineStateService {
  
  /**
   * 装置状態管理のDAOインスタンス
   */
  @Autowired
  private MntMachineStateDao mntMachineStateDao;

  /**
   * 施設コード、型式コード、製造番号に該当する装置状態管理情報を取得.
   * 
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return 該当する{@link jp.co.nikkiso.ntss.core.entity._MntMachineState}
   */
  @Override
  public MntMachineState selectByKey(String facilityCd, String machineTypeCd, String machineSerial) {
    return mntMachineStateDao.selectByKey(facilityCd, machineTypeCd, machineSerial);
  }
}
