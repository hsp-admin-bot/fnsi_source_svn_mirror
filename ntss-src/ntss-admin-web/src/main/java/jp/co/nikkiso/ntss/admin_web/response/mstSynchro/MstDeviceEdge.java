package jp.co.nikkiso.ntss.admin_web.response.mstSynchro;

import java.sql.Timestamp;

import lombok.AllArgsConstructor;


/**
 * デバイスエッジマスタのマスタ1件を表すクラス.
 */
@AllArgsConstructor
public class MstDeviceEdge {
  
  /**
   * 施設コード.
   */
  public String facilityCd;
  
  /**
   * デバイスエッジ番号.
   */
  public Integer deviceEdgeNo;

  /**
   * デバイスエッジ名.
   */
  public String deviceName;

  /**
   * 登録日時.
   */
  public Timestamp regDate;

  /**
   * 更新日時.
   */
  public Timestamp upDate;
}
