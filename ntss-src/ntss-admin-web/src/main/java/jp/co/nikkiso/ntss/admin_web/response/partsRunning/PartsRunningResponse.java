package jp.co.nikkiso.ntss.admin_web.response.partsRunning;

import jp.co.nikkiso.ntss.admin_web.response.partsRunning.dto.PartsRunningDto;
import lombok.AllArgsConstructor;

/**
 * 部品の運転/交換時間のResponseクラス.
 */
@AllArgsConstructor
public class PartsRunningResponse {

  /**
   * 通信種別.
   */
  public Integer comType;

  /**
   * 通信フォーマットコード.
   */
  public String comFormatCd;

  /**
   * 運転時間Dto.
   */
  public PartsRunningDto partsRunning;

  /**
   * 空の部品運転/交換時間を返却するコンストラクタ.
   * 検索結果0件時のレスポンスに使用
   */
  public PartsRunningResponse() {
    this.comType = 0;
    this.comFormatCd = "";
    this.partsRunning = null;
  }

}
