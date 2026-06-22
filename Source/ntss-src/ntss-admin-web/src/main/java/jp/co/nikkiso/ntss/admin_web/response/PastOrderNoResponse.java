package jp.co.nikkiso.ntss.admin_web.response;

import jp.co.nikkiso.ntss.core.entity.custom.OrdMainOrdNoAndRstStartDate;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

/**
 * 過去オーダー番号取得のResponse.
 */
@NoArgsConstructor
@Getter
@Setter
public class PastOrderNoResponse {

  /**
   * 直近のオーダー番号と治療日時リスト
   */
  List<OrdMainOrdNoAndRstStartDate> latestOrdList;

  /**
   * 同一曜日のオーダー番号と治療日時リスト
   */
  List<OrdMainOrdNoAndRstStartDate> sameDayOfTheWeekOrdList;
}
