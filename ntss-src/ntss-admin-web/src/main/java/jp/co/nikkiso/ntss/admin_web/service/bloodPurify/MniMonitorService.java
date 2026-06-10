package jp.co.nikkiso.ntss.admin_web.service.bloodPurify;

import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;

public interface MniMonitorService {

  /**
   * モニタデータ登録
   * @param param モニタデータ
   * @param state 装置状態
   * @return
   * @throws Exception
   */
  int insertMonitor(MniMonitor param, MntMachineState state);

  /**
   * モニタデータ登録(開始)
   * @param param モニタデータ
   * @param state 装置状態
   * @return
   * @throws Exception
   */
  int insertMonitorDyalysisStart(MniMonitor param, MntMachineState state);

  /**
   * モニタデータ登録(終了)
   * @param param モニタデータ
   * @param state 装置状態
   * @return
   * @throws Exception
   */
  int insertMonitorDyalysisFinish(MniMonitor param, MntMachineState state);

  /**
   *
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param ordNo オーダ番号
   * @return
   */
  MniMonitor selectMonitorByFacilityCdAndPatIdAndOrdNo(String facilityCd, Long patId, Long ordNo);
}
