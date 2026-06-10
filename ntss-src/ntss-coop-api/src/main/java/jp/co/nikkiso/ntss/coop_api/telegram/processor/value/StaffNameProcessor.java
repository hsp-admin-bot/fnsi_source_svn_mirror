package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.coop_api.service.ConvertSendCommonService;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import org.springframework.stereotype.Component;

/**
 * {@code StaffNameProcessor} は、{@code staff_name:SQLCODE.COLUMN_NAME} の形式に対応する
 * {@link ValueProcessor} の実装です。
 * <p>
 * データセットから取得されたスタッフコードを基に、
 * {@link ConvertSendCommonService#getStaffName(String)} を使用してスタッフ名に変換します。
 * </p>
 *
 * <p>
 * 使用例：
 * <ul>
 *   <li>{@code staff_name:DS002.staff_cd} → データセット "DS002" の "staff_cd" → スタッフ名</li>
 * </ul>
 * </p>
 */
@Component
public class StaffNameProcessor extends AbstractDatasetProcessor {

    private final ConvertSendCommonService convertSendCommonService;

    /**
     * {@code StaffNameProcessor} のコンストラクタ。
     *
     * @param convertSendCommonService スタッフ名変換処理を提供する共通サービス
     */
    public StaffNameProcessor(ConvertSendCommonService convertSendCommonService) {
        this.convertSendCommonService = convertSendCommonService;
    }

    /**
     * このプロセッサが対応する value のプレフィックスを返します。
     *
     * @return {@code "staff_name"}
     */
    @Override
    protected String getPrefix() {
        return "staff_name";
    }

    /**
     * データセットから取得した raw 値をスタッフ名に変換します。
     *
     * @param value   データセット内の値（例：職員コード）
     * @param context Telegram 処理用コンテキスト
     * @return スタッフ名（文字列）
     */
    @Override
    protected String convert(String value, ProcessingContext context) {
        return convertSendCommonService.getStaffName(value);
    }
}
