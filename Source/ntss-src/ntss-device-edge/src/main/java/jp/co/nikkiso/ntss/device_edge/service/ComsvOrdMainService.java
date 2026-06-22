package jp.co.nikkiso.ntss.device_edge.service;

import jp.co.nikkiso.ntss.core.entity.custom.ComsvComplaintTreatment;
import jp.co.nikkiso.ntss.core.entity.custom.ComsvOrdMain;
import jp.co.nikkiso.ntss.core.entity.custom.RecrclRt;
import jp.co.nikkiso.ntss.core.entity.custom.RecrclRtElement;
import jp.co.nikkiso.ntss.device_edge.response.comsvOrdMain.ComsvNextPatOrdResponse;

import java.io.IOException;

public interface ComsvOrdMainService {
  ComsvOrdMain selectByNo(Long ordNo);

  int selectTreatmentCount(Long ordNo);

  int selectTreatStaffCount(Long ordNo);

  ComsvOrdMain selectUnregisteredPat(ComsvOrdMain param);

  ComsvNextPatOrdResponse selectNextPatInfo(Long ordNo, int deviceEdgeNo);

  // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
  String selectWeightInfo(Long ordNo);
  // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end

  //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
  ComsvComplaintTreatment selectRecentRstTreatmentInfo(Long ordNo);
  //add 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end

  int updateSendDate(ComsvOrdMain param);

  int updateStartDate(ComsvOrdMain param);

  int updateEndDate(ComsvOrdMain param);

  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
  //int updateCompTreatStaff(Long ordNo, String occurDate, String staffCd);
  int updateCompTreatStaff(Long ordNo, int ctl_no, String occurDate, String staffCd);

  //int updateOxygen(Long ordNo, String occurDate, String oxygenStart, String oxygenAmount);
  //mod 複数組の酸素吸入データマッチング問題に対応 劉 start
  //int updateOxygen(Long ordNo, int ctl_no, int row_no, String occurDate, String oxygenStart, String oxygenAmount);
  int updateOxygen(Long ordNo, int ctl_no, int row_no, String occurDate, String oxygenStart, String oxygenAmount, String linkStartDate);
  //mod 複数組の酸素吸入データマッチング問題に対応 劉 end

  //int updateOxygenStaff(Long ordNo, String occurDate, String staffCd);
  int updateOxygenStaff(Long ordNo, int ctl_no, int row_no, String occurDate, String staffCd);
  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
  int updatePunctureUser(int inpNo, Long ordNo, Long userId, String userDate);

  int updateReturnUser(int inpNo, Long ordNo, Long userId, String userDate);

  int updateChargeUser(int inpNo, Long ordNo, Long userId, String userDate);

  int updateRstMonitor(ComsvOrdMain param);

  int updateRstWeight(Long ordNo, String waterRemovalTarget);

  int updatePullLeaveAmount(ComsvOrdMain param);

  int updateRstMediInfo(Long ordNo, String effectDate, String noJson);

  int updateRstMediInfoUser(Long ordNo, Long userId, String effectDate);

  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  start
  //  int insertUnregistered(int machine_status, ComsvOrdMain param);
  int insertUnregistered(int machine_status, ComsvOrdMain param) throws IOException;
  //  mod 9539 チェックリストマスタの設定を変更して保存しても保存できない 関  end
  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- start
  //int updateRstCompTreat(String facilityCd, Long ordNo, String occurDate, String cdJson);
  int updateRstCompTreat(String facilityCd, Long ordNo, int ctl_no_complaint ,int ctl_no_treat, String occurDate, String cdJson);
  //mod 通信サーバーでは愁訴処置と処置者が分かれてデータ受信するのでそれを同一の操作のものとして扱うことが必要 --趙-- end
  // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- start
  int updateWeightInfo(Long ordNo,String weightInfo);
  // add 治療完了後、I-HDFの引き残し記録を別途で登録要 --趙-- end
  // add AWSとDEの通信断からの復旧 --趙-- start
  int insertUnregisteredCommFail(ComsvOrdMain param);
  // add AWSとDEの通信断からの復旧 --趙-- end
  //add 通信サーバ用条件送信キャンセル 劉 start
  int cancelSendCondCommfail(String facilityCd, String machineTypeCd, String machineSerial, Long ordNo);
  //add 通信サーバ用条件送信キャンセル 劉 end
  //add 実績：治療状況取得 劉 start
  String selectRstDialysisState(Long ordNo);
  //add 実績：治療状況取得 劉 end

  // ＃10847 2024.07.11 add 再循環率情報作成 TDC米沢 start
  RecrclRt makeRecrclRt(RecrclRt base, RecrclRtElement elm);
  // ＃10847 2024.07.11 add 再循環率情報作成 TDC米沢 end

  // #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 start
  /**
   * 対象オーダーが存在するかどうか確認
   * @param ordNo 対象ord_no
   * @return true: アリ false: ナシ
   */
  boolean existsOrdNo(Long ordNo);
  // #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 end

  int updateOxygenReplace(Long ord_no, int ctlNo, String occur_date, String oxygen_start, String oxygen_amount, String linkStartDate);
}
