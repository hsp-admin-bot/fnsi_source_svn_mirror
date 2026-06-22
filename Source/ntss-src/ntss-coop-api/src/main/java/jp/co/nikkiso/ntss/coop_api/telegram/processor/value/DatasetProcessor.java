package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.context.TelegramContext;
import org.springframework.stereotype.Component;

/**
 * {@code DatasetProcessor} は、{@code dataset:SQLCODE.COLUMN_NAME} の形式に対応し、
 * {@link TelegramContext} に格納されたデータセット結果から指定された値を抽出する
 * {@link ValueProcessor} の実装です。
 *
 * <p>
 * 対応形式例：
 * <ul>
 *   <li>dataset:123.result_cd → sql_cd=123のSQLで取得できた result_cd カラム値</li>
 * </ul>
 * </p>
 */
@Component
public class DatasetProcessor extends AbstractDatasetProcessor {

    @Override
    protected String getPrefix() {
        return "dataset";
    }

    @Override
    protected String convert(String value, ProcessingContext context) {
        return value;
    }
}
