package jp.co.nikkiso.ntss.monitoring.service;

import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineState;

import java.util.List;

/**
 * 装置状態管理サービス
 */
public interface MntMachineStateService {

  /**
   * 施設コードに該当する装置状態管理情報を取得.
   * 
   * @param facilityCd 施設コード
   * @return 該当する{@link jp.co.nikkiso.ntss.core.entity._MntMachineState}
   */
  List<ComsvMntMachineState> selectByFacility(String facilityCd);
  
  /**
   * 施設コード、型式コード、製造番号に該当する装置状態管理情報を取得.
   * 
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return 該当する{@link jp.co.nikkiso.ntss.core.entity._MntMachineState}
   */
  MntMachineState selectByKey(String facilityCd, String machineTypeCd, String machineSerial);
  
  /**
   * 施設コード、型式コード、製造番号に該当する装置の警報リストを更新
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @param alarmList 警報リスト
   * @return
   */
  int updateAlarmList(String facilityCd, String machineTypeCd, String machineSerial, String alarmList);
}
