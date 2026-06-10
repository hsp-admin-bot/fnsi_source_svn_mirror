package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

/**
 * {@code ConstProcessor} は、以下2種類の固定値・定数指定に対応する {@link ValueProcessor} の実装です。
 *
 * <ul>
 *   <li>{@code $LF}, {@code $CR}, {@code $EOT} などの制御コード指定</li>
 *   <li>{@code const:○○} の形式による任意文字列の出力</li>
 * </ul>
 */
@Component
public class ConstProcessor implements ValueProcessor {

    private static final Map<String, String> CONST_MAP = new HashMap<>();

    static {
        CONST_MAP.put("$LF", "\n");
        CONST_MAP.put("$CR", "\r");
        CONST_MAP.put("$CRLF", "\r\n");
        CONST_MAP.put("$LFCR", "\n\r");
        CONST_MAP.put("$STX", "\u0002"); // 0x02
        CONST_MAP.put("$ETX", "\u0003"); // 0x03
        CONST_MAP.put("$EOT", "\u0004"); // 0x04
    }

    /**
     * このプロセッサが対象の表現に対応するかを判定します。
     * <p>
     * 対応形式：
     * <ul>
     *   <li>const: で始まる文字列</li>
     *   <li>$LF, $CR など CONST_MAP に定義されている定数</li>
     * </ul>
     *
     * @param expression {@code Item.getValue()} に含まれる文字列
     * @return 対応可能な場合 {@code true}
     */
    @Override
    public boolean supports(String expression) {
        return expression != null &&
               (expression.startsWith("const:") || CONST_MAP.containsKey(expression));
    }

    /**
     * 対応する定数または固定値を返却します。
     *
     * @param expression 定数表現（例：{@code "$LF"}, {@code "const:ABC"}）
     * @param item       対象の {@link Item}（未使用）
     * @param context    コンテキスト（未使用）
     * @return 出力する文字列
     */
    @Override
    public String process(String expression, Item item, ProcessingContext context) {
        if (expression.startsWith("const:")) {
            return expression.substring("const:".length());
        }
        return CONST_MAP.getOrDefault(expression, "");
    }
}
