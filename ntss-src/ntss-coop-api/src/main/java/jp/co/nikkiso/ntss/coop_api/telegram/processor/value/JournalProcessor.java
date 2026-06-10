package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.exception.NtssException;

import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.service.ConvertSendCommonService;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.context.TelegramContext;

/**
 * {@code JournalProcessor} は {@code $JOURNAL.フィールド名} の形式に対応し、
 * {@link SysCoopJournal} から指定されたフィールドの値を取得して電文出力する {@link ValueProcessor} の実装です。
 *
 * <p>
 * 対応形式例：
 * <ul>
 *   <li>$JOURNAL.order_no</li>
 *   <li>$JOURNAL.patient_id</li>
 * </ul>
 * </p>
 */
@Component
public class JournalProcessor implements ValueProcessor {

    private final ConvertSendCommonService convertSendCommonService;

    /**
     * {@code ConvertSendCommonService} を利用してジャーナル情報を取得・解釈します。
     *
     * @param convertSendCommonService ジャーナル置換処理を担当するサービス
     */
    public JournalProcessor(ConvertSendCommonService convertSendCommonService) {
        this.convertSendCommonService = convertSendCommonService;
    }

    /**
     * 式が {@code $JOURNAL.} で始まる場合にこのプロセッサが対応可能であることを示します。
     *
     * @param expression 電文表現文字列
     * @return {@code $JOURNAL.} で始まる場合は {@code true}
     */
    @Override
    public boolean supports(String expression) {
        return expression != null && expression.startsWith("$JOURNAL.");
    }

    /**
     * ジャーナル内の指定フィールドの値を取得して返却します。
     * 該当フィールドが null の場合は空文字を返します。
     *
     * @param expression "$JOURNAL.xxx" の形式（例：$JOURNAL.order_no）
     * @param item       対象の {@link Item}
     * @param context    {@link TelegramContext} を通じて {@link SysCoopJournal} にアクセス
     * @return 指定されたジャーナル項目の値
     * @throws NtssException 式が不正な場合
     */
    @Override
    public String process(String expression, Item item, ProcessingContext context) {
        if (!expression.contains(".")) {
            throw new NtssException("JOURNAL指定が正しくありません：" + expression);
        }

        // 例: $JOURNAL.order_no → $JOURNAL.order_no
        return convertSendCommonService.getJournalReplaceData(expression, context.getJournal());
    }
}
