package jp.co.nikkiso.ntss.device_edge.response.comsvReloadNextPat;

import jp.co.nikkiso.ntss.device_edge.response.FlagAndMessageBaseResponse;
import lombok.NoArgsConstructor;

/**
 * 一斉次患者更新のResponse.
 */
@NoArgsConstructor
public class ComsvReloadNextPatResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public ComsvReloadNextPatResponse(String errorMessage) {
    super(errorMessage);
  }

}
