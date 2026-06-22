package jp.co.nikkiso.ntss.admin_web.response.trendGraph;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import jp.co.nikkiso.ntss.core.entity.MniMonitor;
import lombok.NoArgsConstructor;
import java.util.List;

/**
 * トレンドグラフのResponse.
 */
@NoArgsConstructor
public class TrendGraphResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public TrendGraphResponse(String errorMessage) {
    super(errorMessage);
  }

  /**
   *  モニタデータ一覧セット
   */
  public List<MniMonitor> monitorInfo;

}
