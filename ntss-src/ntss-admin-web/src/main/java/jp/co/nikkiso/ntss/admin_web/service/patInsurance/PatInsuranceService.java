package jp.co.nikkiso.ntss.admin_web.service.patInsurance;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.custom.PatInsuranceName;
import jp.co.nikkiso.ntss.core.entity.custom.InsuInfo;
import jp.co.nikkiso.ntss.core.entity.PatInsurance;

public interface PatInsuranceService {
    List<PatInsurance> getListPatInsuranceById(Long patId);

    /**
     * 名前とコードで患者保険を取得
     *
     * @param patId 患者ID
     * @param facilityCd 施設コード
     * @param ordPrescriptionNo 処方オーダー番号
     * @return 名前とコード
     *
     */
    List<PatInsuranceName> getListPatInsuranceNameByIdAndCd(Long patId, String facilityCd, Long ordPrescriptionNo);

    /**
     * 保険コードで保険情報を取得
     *
     * @param insuranceCd
     *            保険コード
     * @return 保険情報
     *
     */
    InsuInfo getInsuInfoByCd(Long insuranceCd);
}
