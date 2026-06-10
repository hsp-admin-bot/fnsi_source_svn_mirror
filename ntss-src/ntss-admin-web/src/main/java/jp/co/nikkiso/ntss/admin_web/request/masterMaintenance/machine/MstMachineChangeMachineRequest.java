package jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.machine;


import java.util.List;

import lombok.Data;

/**
 * 装置マスタの主キー変更装置一覧リクエスト
 */
@Data
public class MstMachineChangeMachineRequest {
  /**
   * 施設コード
   */
  String facilityCd;

  /**
   * オフライン/通信共通に変更された装置番号リスト
   */
  List<Long> newOfflineAndCommonCodeList;

  /**
   * 主キー変更された全装置番号リスト
   */
  List<Long> changeMachineCodeList;
}
