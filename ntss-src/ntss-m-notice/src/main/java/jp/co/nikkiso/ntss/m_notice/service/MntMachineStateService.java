package jp.co.nikkiso.ntss.m_notice.service;

import jp.co.nikkiso.ntss.core.entity.MntMachineState;

/**
 * 装置状態管理サービス
 */
public interface MntMachineStateService {
  
  /**
   * 施設コード、型式コード、製造番号に該当する装置状態管理情報を取得.
   * 
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return 該当する{@link jp.co.nikkiso.ntss.core.entity._MntMachineState}
   */
  MntMachineState selectByKey(String facilityCd, String machineTypeCd, String machineSerial);

}
