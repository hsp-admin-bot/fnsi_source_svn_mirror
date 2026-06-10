package jp.co.nikkiso.ntss.admin_web.service.ordmain;

import jp.co.nikkiso.ntss.admin_web.response.ordMain.OrdMainResponse;
import jp.co.nikkiso.ntss.admin_web.web.rest.validation.ApiEntityOrdMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;

public interface OrdMainIndService {

  /**
   * 治療予定登録 with 治療方法セットコード(新規登録時)
   * @param bodyData 追加情報
   * @param patMain 患者情報
   * @return インサート対象リスト
   */
  OrdMainResponse createOrdByTreatSetCd(
    ApiEntityOrdMain.ValiCreateTreatPlan bodyData,
    PatMain patMain);
}
