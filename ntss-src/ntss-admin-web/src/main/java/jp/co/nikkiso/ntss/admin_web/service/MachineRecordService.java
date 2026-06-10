package jp.co.nikkiso.ntss.admin_web.service;

import jp.co.nikkiso.ntss.admin_web.response.MachineRecordResponse;

/**
 * 装置記録用のServiceインターフェース.
 */
public interface MachineRecordService {
  /**
   * 装置一覧の全レコードを取得する.
   * @return 装置一覧.
   */
  MachineRecordResponse getAllMachineRecords(String facilityCd);
}
