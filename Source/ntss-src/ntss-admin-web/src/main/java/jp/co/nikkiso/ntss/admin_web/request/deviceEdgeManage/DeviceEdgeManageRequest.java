package jp.co.nikkiso.ntss.admin_web.request.deviceEdgeManage;

import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeManage;
import lombok.Data;

@Data
public class DeviceEdgeManageRequest {
  /**
   * デバイスエッジ番号
   */
  private Integer deviceEdgeNo;
  /**
   * 指示対象施設コード
   */
  private String targetFacilityCd;
  /**
   * 対象バケット名
   */
  private String bucket;
  /**
   * 対象ファイル名
   */
  private String fileName;
  /**
   * アプリケーション種別
   * 0: メイン
   * 1: アップデータ
   * 2: すべて
   */
  private Short appType;

  /**
   * 予約日時 yyyyMMddHHmmss
   */
  private String planDate;

  /**
   * 指示情報
   */
  private MntDeviceEdgeManage manageParam;
}
