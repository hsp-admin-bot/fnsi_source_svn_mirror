package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.coop_api.service.ConvertSendCommonService;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.context.TelegramContext;
import org.springframework.stereotype.Component;

/**
 * {@code AuthIdProcessor} は、{@code auth_id:SQLCODE.COLUMN_NAME} の形式に対応する
 * {@link ValueProcessor} の実装です。
 * <p>
 * 指定されたデータセット内の値（例：職員コードなど）を元に、{@code ConvertSendCommonService} を通じて
 * 利用者ID（AUTH_ID）を取得します。
 * </p>
 *
 * <p>
 * 例：
 * <ul>
 *   <li>{@code auth_id:DS001.staff_cd} → dataSetMap["DS001"][0]["staff_cd"] → getAuthId(value)</li>
 * </ul>
 * </p>
 */
@Component
public class AuthIdProcessor extends AbstractDatasetProcessor {

    private final ConvertSendCommonService convertSendCommonService;

    /**
     * コンストラクタ。
     *
     * @param convertSendCommonService 利用者情報変換処理を提供するサービス
     */
    public AuthIdProcessor(ConvertSendCommonService convertSendCommonService) {
        this.convertSendCommonService = convertSendCommonService;
    }

    /**
     * 本 Processor が対応するプレフィックスを返します。
     * 例：{@code auth_id}
     *
     * @return プレフィックス文字列
     */
    @Override
    protected String getPrefix() {
        return "auth_id";
    }

    /**
     * データセットから取得した値をもとに、利用者IDに変換します。
     *
     * @param value   データセットから取得した raw 値
     * @param context {@link TelegramContext}
     * @return 変換後の利用者ID文字列
     */
    @Override
    protected String convert(String value, ProcessingContext context) {
        return convertSendCommonService.getAuthId(value);
    }
}
