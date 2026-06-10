package jp.co.nikkiso.ntss.admin_web.service.partsRunning;

import java.io.IOException;

import jp.co.nikkiso.ntss.admin_web.response.partsRunning.PartsRunningResponse;

/**
 * 部品の運転/交換時間のServiceインタフェース.
 */
public interface PartsRunningService {

  /**
   * 部品の運転/交換時間のResponse作成.
   *
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return 部品の運転/交換時間のResponse
   * @throws IOException
   */
  PartsRunningResponse createPartsRunningResponse(String facilityCd, String machineTypeCd, String machineSerial)
      throws IOException;

}
