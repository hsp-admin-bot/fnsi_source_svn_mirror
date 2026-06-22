package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import org.springframework.stereotype.Component;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * {@code HexProcessor} は、{@code $HEXxx} の形式に対応する {@link ValueProcessor} の実装です。
 * <p>
 * 2桁の16進数を指定して、制御コードやバイナリ文字を1文字出力します。
 * </p>
 */
@Component
public class HexProcessor implements ValueProcessor {

    private static final Pattern HEX_PATTERN = Pattern.compile("^\\$HEX([0-9a-fA-F]{2})$");

    /**
     * {@code $HEXxx} 形式に対応しているかを判定します。
     *
     * @param expression {@link Item#getValue()} で指定された値
     * @return 対応形式であれば {@code true}
     */
    @Override
    public boolean supports(String expression) {
        return expression != null && HEX_PATTERN.matcher(expression).matches();
    }

    /**
     * 16進数表現から1バイトの文字列を生成します。
     * <p>
     * ※ codePoint は {@code 0x00 ～ 0x20}（制御コード領域）のみ許可されます。
     * </p>
     *
     * @param expression 例：{@code "$HEX0D"}
     * @param item       対象の {@link Item}
     * @param context    Telegram 処理コンテキスト
     * @return 生成された1文字
     * @throws NtssException フォーマットや範囲エラーがある場合
     */
    @Override
    public String process(String expression, Item item, ProcessingContext context) {
        Matcher matcher = HEX_PATTERN.matcher(expression);
        if (!matcher.matches()) {
            throw new NtssException("HEX形式が不正です: " + expression);
        }

        try {
            int codePoint = Integer.parseInt(matcher.group(1), 16);

            // 制御コード（0x00〜0x20）のみ許可
            if (codePoint > 32 || codePoint < 0) {
                throw new NtssException("対応範囲外のHex値です。対象データ:[" + expression + "]");
            }

            return new String(new int[] { codePoint }, 0, 1);

        } catch (Exception e) {
            throw new NtssException("HEX値の処理に失敗しました: " + expression, e);
        }
    }
}
