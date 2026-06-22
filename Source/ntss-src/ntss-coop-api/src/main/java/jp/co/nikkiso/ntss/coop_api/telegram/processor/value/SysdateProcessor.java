package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * {@code SysdateProcessor} は {@code $SYSDATE} プレフィックスを処理する
 * {@link ValueProcessor} の実装です。
 * <p>
 * 現在日時を指定フォーマットで出力します。デフォルトは {@code yyyyMMdd} 形式です。
 * </p>
 * <p>
 * 例：
 * </p>
 * <ul>
 * <li>$SYSDATE → "20250513"</li>
 * <li>$SYSDATE:yyyy/MM/dd → "2025/05/13"</li>
 * </ul>
 */
@Component
public class SysdateProcessor implements ValueProcessor {

    /**
     * このプロセッサは $SYSDATE で始まる表現に対応します。
     *
     * @param expression value 属性に指定された式
     * @return "$SYSDATE" で始まる場合は {@code true}
     */
    @Override
    public boolean supports(String expression) {
        return expression != null && expression.startsWith("$SYSDATE");
    }

    /**
     * 現在日付を指定の形式で出力します。
     *
     * @param expression "$SYSDATE" で始まる文字列（例："$SYSDATEyyyy-MM-dd"）
     * @param item       対象の {@link Item}
     * @param context    電文生成コンテキスト
     * @return 現在日付をフォーマットした文字列
     * @throws NtssException フォーマット文字列が不正な場合
     */
    @Override
    public String process(String expression, Item item, ProcessingContext context) {
        String format = expression.replace("$SYSDATE", "");
        if (!StringUtils.hasLength(format)) {
            format = "yyyyMMdd";
        }

        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern(format.trim());
            return formatter.format(LocalDateTime.now(context
                    .getTelegramContext()
                    .getClock()
                    .getClock()));
        } catch (Exception e) {
            throw new NtssException("現在日のフォーマット [" + format + "] が不正です：" + e.getMessage(), e);
        }
    }
}
