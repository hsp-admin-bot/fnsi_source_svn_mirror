package jp.co.nikkiso.ntss.admin_web.response.details;

import jp.co.nikkiso.ntss.admin_web.response.details.dto.GatheringDetailDto;
import lombok.AllArgsConstructor;

/**
 * 装置動作記録詳細_データ収集記録のResponse.
 */
@AllArgsConstructor
public class GatheringDetailResponse {

  /**
   * 装置記録メッセージ.
   */
  public String machineRecordMessage;

  /**
   * 対処(実行)者.
   */
  public Long gatheringUserId;

  /**
   * 実施者名
   */
  public String userName;

  /**
   * ファイルデータ.
   */
  public GatheringDetailDto fileData;

  /**
   * 空のレスポンスを返却するコンストラクタ.
   */
  public GatheringDetailResponse() {
    this.machineRecordMessage = "";
    this.gatheringUserId = null;
    this.userName = "";
    this.fileData = null;
  }

}
