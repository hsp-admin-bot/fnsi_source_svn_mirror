package jp.co.nikkiso.ntss.device_edge.service.hostNotify;

import jp.co.nikkiso.ntss.device_edge.request.hostNotify.AlarmNotifyRequest;
import jp.co.nikkiso.ntss.device_edge.request.hostNotify.MedicineNotifyRequest;

public interface HostNotifyService {
  /**
   * 患者個人のホスト報知設定を取得
   * @param facilityCd 施設コード
   * @param deviceEdgeNo DE番号
   * @param patId 患者ID
   * @return
   */
  String hostNotifySettingByPat(String facilityCd, Long deviceEdgeNo, Long patId);

  /**
   * DE下装置に紐づく装置の定期報知チェック
   * @param facilityCd 施設コード
   * @param deviceEdgeNo DE番号
   * @return
   */
  int hostNotifyIntervalCheck(String facilityCd, Integer deviceEdgeNo);

  /**
   * ホスト報知
   * @param param DEから受信したパラメータ
   * @return
   */
  int hostNotify(AlarmNotifyRequest param);

  /**
   * 投薬タイミング報知
   * @param param DEから受信したパラメータ
   * @return
   */
  int MedicineTymingNotify(MedicineNotifyRequest param);

}
