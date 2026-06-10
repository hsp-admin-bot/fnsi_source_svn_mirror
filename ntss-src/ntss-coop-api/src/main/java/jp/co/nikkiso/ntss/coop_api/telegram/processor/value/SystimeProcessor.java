package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.context.TelegramContext;

import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * {@code SystimeProcessor} は {@code $SYSTIME} または {@code $SYSTIME:フォーマット}
 * の形式に対応し、
 * 現在の時刻を指定された形式で電文出力する {@link ValueProcessor} の実装です。
 *
 * <p>
 * 対応形式例：
 * <ul>
 * <li>$SYSTIME</li>
 * <li>$SYSTIME:HHmmss</li>
 * <li>$SYSTIME:HH:mm:ss</li>
 * </ul>
 * </p>
 *
 * <p>
 * フォーマットが省略された場合、デフォルトで {@code HHmmss} 形式を使用します。
 * </p>
 */
@Component
public class SystimeProcessor implements ValueProcessor {

    /**
     * このプロセッサが {@code $SYSTIME} で始まる式に対応することを示します。
     *
     * @param expression {@link Item#getValue()} から取得した電文表現
     * @return {@code $SYSTIME} で始まる場合は {@code true}
     */
    @Override
    public boolean supports(String expression) {
        return expression != null && expression.startsWith("$SYSTIME");
    }

    /**
     * 現在時刻を指定フォーマットで文字列化し返却します。
     *
     * @param expression {@code $SYSTIME[:フォーマット]} の形式（例："$SYSTIME:HHmmss"）
     * @param item       対象の {@link Item}
     * @param context    {@link TelegramContext} を通じて {@code Clock} にアクセス
     * @return 現在時刻をフォーマットした文字列（例："143015"）
     * @throws NtssException フォーマット指定が不正な場合
     */
    @Override
    public String process(String expression, Item item, ProcessingContext context) {
        String format = expression.replace("$SYSTIME", "");
        if (!StringUtils.hasLength(format)) {
            format = "HHmmss";
        }

        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern(format.trim());
            return formatter.format(LocalDateTime.now(context
                    .getTelegramContext()
                    .getClock()
                    .getClock()));
        } catch (Exception e) {
            throw new NtssException("現在時刻のフォーマット [" + format + "] が不正です：" + e.getMessage(), e);
        }
    }
}
