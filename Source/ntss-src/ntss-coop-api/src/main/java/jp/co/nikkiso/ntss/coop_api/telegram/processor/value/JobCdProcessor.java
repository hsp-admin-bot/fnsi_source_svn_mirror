package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.coop_api.service.ConvertSendCommonService;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import org.springframework.stereotype.Component;

/**
 * {@code JobCdProcessor} は、{@code job_cd:SQLCODE.COLUMN_NAME} の形式に対応する
 * {@link ValueProcessor} の実装です。
 * <p>
 * データセットから抽出された値（例：職員コード）をもとに、
 * {@link ConvertSendCommonService#getJobCd(String)} を使用して職種コードに変換します。
 * </p>
 *
 * <p>
 * 使用例：
 * <ul>
 *   <li>{@code job_cd:DS001.staff_cd} → データセット "DS001" の "staff_cd" 値 → 職種コード</li>
 * </ul>
 * </p>
 */
@Component
public class JobCdProcessor extends AbstractDatasetProcessor {

    private final ConvertSendCommonService convertSendCommonService;

    /**
     * {@code JobCdProcessor} のコンストラクタ。
     *
     * @param convertSendCommonService 共通のマスタ変換サービス
     */
    public JobCdProcessor(ConvertSendCommonService convertSendCommonService) {
        this.convertSendCommonService = convertSendCommonService;
    }

    /**
     * 本プロセッサが対応する value プレフィックス（"job_cd"）を返します。
     *
     * @return 対象プレフィックス
     */
    @Override
    protected String getPrefix() {
        return "job_cd";
    }

    /**
     * データセットから取得された値を職種コードに変換します。
     *
     * @param value   データセットから取得された値
     * @param context Telegram 処理コンテキスト
     * @return 変換後の職種コード文字列
     */
    @Override
    protected String convert(String value, ProcessingContext context) {
        return convertSendCommonService.getJobCd(value);
    }
}
