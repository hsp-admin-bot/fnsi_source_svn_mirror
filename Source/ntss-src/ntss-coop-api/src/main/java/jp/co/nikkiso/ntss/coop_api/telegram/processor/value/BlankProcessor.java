package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import org.springframework.stereotype.Component;

/**
 * {@code BlankProcessor} は {@code $BLANK} プレフィックスを処理する
 * {@link ValueProcessor} の実装です。
 * <p>
 * {@code $BLANK} は空文字列を出力します。
 * </p>
 * <p>
 * 例：
 * </p>
 * <ul>
 * <li>$BLANK → ""</li>
 * </ul>
 */
@Component
public class BlankProcessor implements ValueProcessor {

    /**
     * このプロセッサは $BLANK で始まる表現に対応します。
     *
     * @param expression value 属性に指定された式
     * @return "$BLANK" で始まる場合は {@code true}
     */
    @Override
    public boolean supports(String expression) {
        return expression != null && expression.startsWith("$BLANK");
    }

    @Override
    public String process(String expression, Item item, ProcessingContext context) {
        int length = item.getLen();
        // $BLANK の後に長さが指定されている場合は、その長さの空白を返す
        return length > 0 ? " ".repeat(length) : "";
    }
}
