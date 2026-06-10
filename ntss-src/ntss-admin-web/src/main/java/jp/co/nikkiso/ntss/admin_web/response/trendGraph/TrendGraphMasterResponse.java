package jp.co.nikkiso.ntss.admin_web.response.trendGraph;

import jp.co.nikkiso.ntss.admin_web.response.FlagAndMessageBaseResponse;
import jp.co.nikkiso.ntss.core.entity.MstTrendGraphMonitorSet;
import jp.co.nikkiso.ntss.core.entity.MstTrendGraphTemplate;
import lombok.NoArgsConstructor;
import java.util.List;

/**
 * トレンドグラフのResponse.
 */
@NoArgsConstructor
public class TrendGraphMasterResponse extends FlagAndMessageBaseResponse {

  /**
   * コンストラクタ.
   * @param errorMessage エラーメッセージ
   */
  public TrendGraphMasterResponse(String errorMessage) {
    super(errorMessage);
  }


  /**
  * グラフ系列情報
  */
  public List<MstTrendGraphTemplate> template;

  /**
  * モニター項目セット情報
  */
  public List<MstTrendGraphMonitorSet> monitorSet;

}
