package jp.co.nikkiso.ntss.alive_moni.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntMachineState;


/**
 * 装置状態管理マスタのServiceインターフェース.
 */
public interface MntMachineStateService {

  List<MntMachineState> findById(String facilityCd);

  int update(MntMachineState machineState);

  /**
   * デバイスエッジに紐づくオンライン装置の状態を更新する
   * @param machineState
   * @param deviceEdgeNo
   * @return
   */
  int updateAllOnlineMachine(MntMachineState machineState, Integer deviceEdgeNo);

  /**
   * デバイスエッジに紐づく全装置の状態を更新する
   * @param machineState
   * @param deviceEdgeNo
   * @return
   */
  int updateAllMachine(MntMachineState machineState, Integer deviceEdgeNo);
}
