package jp.co.nikkiso.ntss.admin_web.service.ordmain;

import jp.co.nikkiso.ntss.admin_web.response.ordMain.OrdMainResponse;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMain;

import java.util.List;

public interface OrdMainEquipInfoService {

  /**
   * 医材一括追加
   * @param bodyDataList 追加情報
   * @return インサート対象リスト
   */
  OrdMainResponse createOrdMainEquipInfo(List<ApiEntityOrdMain.ValiOrdEquip> bodyDataList);

  /**
   * 医材更新
   * @param bodyData 更新情報
   * @param updatePreOrdMainList 更新前のordMain情報
   * @return 更新成功対象リスト
   */
  OrdMainResponse updateOrdMainEquipInfo(ApiEntityOrdMain.ValiOrdEquip bodyData, List<OrdMain> updatePreOrdMainList);

  /**
   * 医材中止
   * @param bodyData 中止情報
   * @param updatePreOrdMainList 更新前のordMain情報
   * @return 更新成功対象リスト
   */
  OrdMainResponse deleteOrdMainEquipInfo(ApiEntityOrdMain.ValiOrdEquip bodyData, List<OrdMain> updatePreOrdMainList);
}
