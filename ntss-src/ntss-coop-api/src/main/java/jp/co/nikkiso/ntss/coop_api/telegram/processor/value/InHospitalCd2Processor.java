package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.coop_api.service.ConvertSendCommonService;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import org.springframework.stereotype.Component;

/**
 * {@code InHospitalCd2Processor} は、{@code in_hospital_cd_2:SQLCODE.COLUMN_NAME} の形式に対応する
 * {@link ValueProcessor} の実装です。
 * <p>
 * データセットから取得した値を元に、院内コード2を取得します。
 * </p>
 *
 * <p>使用例：</p>
 * <ul>
 *   <li>{@code in_hospital_cd_2:DS004.staff_cd} → データセット "DS004" の "staff_cd" → 院内コード2</li>
 * </ul>
 */
@Component
public class InHospitalCd2Processor extends AbstractDatasetProcessor {

    private final ConvertSendCommonService convertSendCommonService;

    /**
     * コンストラクタ。
     *
     * @param convertSendCommonService 院内コード変換処理を提供する共通サービス
     */
    public InHospitalCd2Processor(ConvertSendCommonService convertSendCommonService) {
        this.convertSendCommonService = convertSendCommonService;
    }

    @Override
    protected String getPrefix() {
        return "in_hospital_cd_2";
    }

    @Override
    protected String convert(String value, ProcessingContext context) {
        return convertSendCommonService.getInHospitalCd2(value);
    }
}
