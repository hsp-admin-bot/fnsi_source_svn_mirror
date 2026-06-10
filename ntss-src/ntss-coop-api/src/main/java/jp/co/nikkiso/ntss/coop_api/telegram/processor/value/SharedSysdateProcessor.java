package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * {@code SharedSysdateProcessor} は、共通のシステム日時をフォーマットして返却する
 * {@link ValueProcessor} の実装クラスです。
 * <p>
 * 電文項目の値に {@code $SHARED_SYSDATE} または {@code $SHARED_SYSDATE:<format>}
 * を指定することで、
 * 現在のシステム日時を所定のフォーマットで出力します。
 * </p>
 * <p>
 * 本クラスはスレッドセーフであり、Spring のコンポーネントとして管理されます。
 * </p>
 *
 * <pre>
 * 例:
 *   $SHARED_SYSDATE                      → デフォルトフォーマット (yyyyMMdd) で出力
 *   $SHARED_SYSDATE:yyyy-MM-dd HH:mm:ss  → 指定フォーマットで出力
 * </pre>
 *
 */
@Component
public class SharedSysdateProcessor implements ValueProcessor {

    /** サポートする式のプレフィックス */
    private static final String PREFIX = "$SHARED_SYSDATE";

    /** デフォルトの日付フォーマット */
    private static final String DEFAULT_FORMAT = "yyyyMMdd";

    /** フォーマット指定子を区切るセパレータ */
    private static final String FORMAT_SEPARATOR = ":";

    /**
     * このプロセッサが指定された式に対応しているか判定します。
     *
     * @param expression 判定対象の式
     * @return {@code true} の場合、本プロセッサが処理可能
     */
    @Override
    public boolean supports(String expression) {
        return expression != null && expression.startsWith(PREFIX);
    }

    /**
     * 指定された式およびコンテキストに基づき、共通システム日時をフォーマットして返却します。
     * <p>
     * フォーマット指定が存在しない場合は、デフォルトフォーマット {@code yyyyMMdd} を用います。
     * </p>
     *
     * @param expression 電文項目に設定された値表現
     * @param item       処理対象の {@link Item}
     * @param context    実行時の処理コンテキスト
     * @return フォーマット済みのシステム日時文字列
     * @throws NtssException 日付フォーマットが不正な場合に発生
     */
    @Override
    public String process(String expression, Item item, ProcessingContext context) {
        String format = expression.startsWith(PREFIX + FORMAT_SEPARATOR)
                ? expression.substring((PREFIX + FORMAT_SEPARATOR).length())
                : "";
        if (!StringUtils.hasLength(format) || format.equals(PREFIX)) {
            format = DEFAULT_FORMAT;
        }

        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern(format.trim());
            LocalDateTime sharedSysDate = context
                    .getSharedSysdateStore()
                    .getSysdate(context.getCurrentSharedSysdateKey());
            return formatter.format(sharedSysDate);
        } catch (Exception e) {
            throw new NtssException("現在日のフォーマット [" + format + "] が不正です：" + e.getMessage(), e);
        }
    }
}
