package jp.co.nikkiso.ntss.admin_web.response.details.model;

import jp.co.nikkiso.ntss.admin_web.response.details.dto.DissolutionDto;

/**
 * 溶解記録のResponse返却用Model.
 */
public class DissolutionModel extends BaseTestModel {
  
  /**
   * 溶解記録のJSONオブジェクト.
   */
  public DissolutionDto result;
  
  /**
   * イベント発生日時と溶解記録を設定するコンストラクタ.
   * 
   * @param eventRegDate イベント発生日付
   * @param eventRegTime イベント発生時刻
   * @param result 溶解記録
   */
  public DissolutionModel(String eventRegDate, String eventRegTime, DissolutionDto result) {
    // イベント発生日時
    this.eventRegDate = eventRegDate;
    this.eventRegTime = eventRegTime;
    // 溶解記録
    this.result = result;
  }

}
