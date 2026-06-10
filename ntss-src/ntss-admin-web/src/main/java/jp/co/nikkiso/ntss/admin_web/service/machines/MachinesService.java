package jp.co.nikkiso.ntss.admin_web.service.machines;

import jp.co.nikkiso.ntss.admin_web.response.MachinesResponse;
import jp.co.nikkiso.ntss.core.entity.custom.Machine;
import jp.co.nikkiso.ntss.core.entity.MstSelfMeasureResult;

import java.util.List;

/**
 * 装置一覧のServiceインタフェース.
 */
public interface MachinesService {

  /**
   * 装置一覧取得.
   *
   * @param facilityCd 施設コード
   * @param isNkkFacility 日機装施設に属しているか否か
   *                      属している場合は<code>true</code>を指定する.
   * @return 装置リスト
   */
  MachinesResponse createMachinesResponse(String facilityCd, boolean isNkkFacility);

  /**
   * 装置マスタ取得
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @param machineSerial 製造番号
   * @return 該当する装置マスタ情報
   */
  Machine getMachine(String facilityCd, String machineTypeCd, String machineSerial);

  /**
   * 自己診断判定マスタ取得
   * @param facilityCd 施設コード
   * @param machineTypeCd 型式コード
   * @return 該当する自己診断判定マスタ情報
   */
  List<MstSelfMeasureResult> getSelfMeasureResultInfo(String facilityCd, String machineTypeCd);
}
