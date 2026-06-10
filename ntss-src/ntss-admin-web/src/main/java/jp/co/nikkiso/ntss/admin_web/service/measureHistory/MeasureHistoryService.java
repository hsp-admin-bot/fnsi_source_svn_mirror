package jp.co.nikkiso.ntss.admin_web.service.measureHistory;

import java.sql.Timestamp;
import java.util.List;

import jp.co.nikkiso.ntss.admin_web.response.measureHistory.OrdWeightScaleResponse;
import jp.co.nikkiso.ntss.core.entity.OrdWeightScale;

public interface MeasureHistoryService {

  /**
   * 施設コードから体重計測定履歴情報を取得するREST API
   * @param facilityCd
   * @return
   */
  List<OrdWeightScaleResponse> getOrder(String facilityCd, Timestamp startDate, Timestamp endDate);

  /**
   * ユニークなキーで1件取得
   * @param serialNo
   * @return
   */
  OrdWeightScale getSingle(Long serialNo);
}
