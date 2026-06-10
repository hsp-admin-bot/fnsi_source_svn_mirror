package jp.co.nikkiso.ntss.device_edge.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineStateForMinimumTreatDate;

public interface MntMachineStateService {
  List<ComsvMntMachineState> selectByFacilityCd(String facilityCd);

  MntMachineState selectByKey(String facilityCd, String machineTypeCd, String machineSerial);

  List<MntMachineState> selectAllByDeviceEdgeNo(String facilityCd, Integer deviceEdgeNo);

  ComsvMntMachineState selectMachineKey(String facilityCd, String machineTypeCd, String machineSerial);

  int updateUseTime(MntMachineState param);

  int updateCondSend(MntMachineState param);

  int updateCondSet(MntMachineState param);

  int updateDialStart(MntMachineState param);

  int updateDialEnd(MntMachineState param);

  int updateUnregisteredPat(MntMachineState param);

  int updateAlarmList(String facilityCd, String machineTypeCd, String machineSerial, String alarmList);

  ComsvMntMachineStateForMinimumTreatDate selectMinimumTreatDate(
      String facilityCd, Integer deviceEdgeNo,
      String startDate, String endDate);

  /**
   * 通信サーバ用装置状態管理の装置ステータス一括更新
   * @param facilityCd 施設コード
   * @param devJson 装置配列（json）
   * @return
   */
  int updateAllStatus(String facilityCd, String devJson);
   // add 治療記録用データと治療状況用データの登録先を振分けにする --趙-- start
  int updateTreatmentStatus(MntMachineState param);
  // add 治療記録用データと治療状況用データの登録先を振分けにする --趙-- end

  // add 装置のSTATUS状態更新方法の変更 --趙-- start
  int updateMachineState(MntMachineState param);
  // add 装置のSTATUS状態更新方法の変更 --趙-- end

  // add  FNSI-画面リロードの修正 徐 start
  MntMachineState selectMachineState(MntMachineState param);
  // add  FNSI-画面リロードの修正 徐 end

  // add AWSとDEの通信断からの復旧 --趙-- start
  int updateMachineStateCommFail(MntMachineState param);

  int updateProcessState(MntMachineState param);
  // add AWSとDEの通信断からの復旧 --趙-- end
}
