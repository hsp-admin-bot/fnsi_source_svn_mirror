package jp.co.nikkiso.ntss.admin_web.service.bloodPurify;

import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import jp.co.nikkiso.ntss.core.entity.MntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineState;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvMntMachineStateForMinimumTreatDate;

import java.util.List;

public interface MntMachineStateService {
  /**
   * 指定パラメータに一致する装置状態一覧を取得
   * @param facilityCd 施設コード
   * @return
   */
  List<ComsvMntMachineState> selectByFacilityCd(String facilityCd);

  /**
   * 指定パラメータに一致する装置状態を取得
   * @param facilityCd 施設コード
   * @param machineTypeCd 装置型式コード
   * @param machineSerial 装置製造番号
   * @return
   */
  MntMachineState selectByKey(String facilityCd, String machineTypeCd, String machineSerial);

  /**
   * 指定パラメータに一致する装置状態一覧を取得
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @return
   */
  List<MntMachineState> selectAllByDeviceEdgeNo(String facilityCd, Integer deviceEdgeNo);

  /**
   * 指定パラメータに一致する装置状態を取得
   * @param facilityCd 施設コード
   * @param machineTypeCd 装置型式コード
   * @param machineSerial 装置製造番号
   * @return
   */
  ComsvMntMachineState selectMachineKey(String facilityCd, String machineTypeCd, String machineSerial);

  /**
   * 装置状態の稼働時間を更新
   * @param param 装置状態
   * @return
   */
  int updateUseTime(MntMachineState param);

  /**
   * 装置状態の条件送信日時を更新
   * @param param 装置状態
   * @return
   */
  int updateCondSend(MntMachineState param);

  /**
   *  装置状態の条件確認を更新
   * @param param 装置状態
   * @return
   */
  int updateCondSet(MntMachineState param);

  /**
   * 装置状態の治療開始日時を更新
   * @param param 装置状態
   * @return
   */
  int updateDialStart(MntMachineState param);

  /**
   * 装置状態の治療終了日時を更新
   * @param param 装置状態
   * @return
   */
  int updateDialEnd(MntMachineState param);

  /**
   * 装置状態で？？？？患者の治療を開始
   * @param param 装置状態
   * @return
   */
  int updateUnregisteredPat(MntMachineState param);

  /**
   * 指定パラメータの装置状態警報一覧を更新
   * @param facilityCd 施設コード
   * @param machineTypeCd 装置型式コード
   * @param machineSerial 装置製造番号
   * @param alarmList 警報一覧
   * @return
   */
  int updateAlarmList(String facilityCd, String machineTypeCd, String machineSerial, String alarmList);

  /**
   * 指定期間内の次患者治療予定日で最小のものを取得する
   * @param facilityCd 施設コード
   * @param deviceEdgeNo デバイスエッジ番号
   * @param startDate 検索開始日付
   * @param endDate 検索終了日付
   * @return
   */
  ComsvMntMachineStateForMinimumTreatDate selectMinimumTreatDate(
      String facilityCd, Integer deviceEdgeNo,
      String startDate, String endDate);

  /**
   * 指定パラメータに一致する装置状態一覧を取得
   * @param
   * @return
   */
  List<MntMachineState> selectAll();

  /**
   *
   * @param bodyDataList
   * @return
   */
  List<MntMachineState> selectMonitorByFacilityCdAndPatIdAndOrdNo(List<MniMonitor> bodyDataList);
  //add 7074 2022-12-02 設定していないホスト報知が通知される 張 start
  /**
   * 装置治療状況チェック.
   * processState 工程状態！=99
   * @param patId 患者ID
   * @return 対象の装置情報
   */
  List<MntMachineState> selectByPatId(Long patId);
  //add 7074 2022-12-02 設定していないホスト報知が通知される 張 end
}
