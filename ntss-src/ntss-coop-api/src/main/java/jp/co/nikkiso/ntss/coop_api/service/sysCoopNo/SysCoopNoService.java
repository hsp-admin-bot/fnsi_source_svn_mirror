package jp.co.nikkiso.ntss.coop_api.service.sysCoopNo;


import java.sql.Timestamp;

/**
 *
 */
public interface SysCoopNoService {

  /**
   * 更新 現在の連携オーダ番号
   * @param curCoopOrdNo n
   * @param sysCoopNoCtlNo
   * @param now
   *
   */
  void updateCurCoopOrdNo(Long curCoopOrdNo, Long sysCoopNoCtlNo, Timestamp now);
}
