package jp.co.nikkiso.ntss.admin_web.service.ordmain;

import jp.co.nikkiso.ntss.admin_web.response.ordMain.OrdMainResponse;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdMain;

import java.util.List;

public interface OrdMainMediInfoService {

  /**
   * 投薬一括追加
   * @param bodyDataList 追加情報
   * @return インサート対象リスト
   */
  OrdMainResponse createOrdMainMediInfo(List<ApiEntityOrdMain.ValiOrdMedi> bodyDataList);

  /**
   * 投薬更新
   * @param bodyData 更新情報
   * @param updatePreOrdMainList 更新前のordMain情報
   * @return 更新成功対象リスト
   */
  OrdMainResponse updateOrdMainMediInfo(ApiEntityOrdMain.ValiOrdMedi bodyData, List<OrdMain> updatePreOrdMainList);

  /**
   * 投薬中止
   * @param bodyData 中止情報
   * @param updatePreOrdMainList 更新前のordMain情報
   * @return 更新成功対象リスト
   */
  OrdMainResponse deleteOrdMainMediInfo(ApiEntityOrdMain.ValiOrdMedi bodyData, List<OrdMain> updatePreOrdMainList);
}
