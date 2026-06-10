package jp.co.nikkiso.ntss.api.service.additionInfo;

import jp.co.nikkiso.ntss.api.request.AdditionCalculationRequest;

/**
 * 加算情報の算定処理系のServiceインタフェース.
 */
public interface AdditionCalculationService {

  /**
   * 追加料金計算
   *
   * @param request
   * @return true：成功、false：失敗
   */
  boolean calculationAddition(AdditionCalculationRequest request);

}
