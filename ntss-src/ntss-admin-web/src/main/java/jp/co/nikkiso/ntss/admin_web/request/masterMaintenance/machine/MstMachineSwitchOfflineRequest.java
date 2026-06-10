package jp.co.nikkiso.ntss.admin_web.request.masterMaintenance.machine;

import java.util.List;

import lombok.Data;

/**
 * 装置マスタのオフライン化装置一覧リクエスト
 */
@Data
public class MstMachineSwitchOfflineRequest {
  /**
   * 施設コード
   */
  String facilityCd;

  /**
   * 新オフライン装置番号リスト
   */
  List<Long> newOfflineCodeList;

  /**
   * 新オンライン装置番号リスト
   */
  List<Long> newOnlineCodeList;
}