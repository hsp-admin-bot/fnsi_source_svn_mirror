package jp.co.nikkiso.ntss.coop_api.telegram.processor.value;

import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;

/**
 * {@code ValueProcessor} は、電文項目の {@code value} 式に対応する文字列値を生成するためのインターフェースです。
 * <p>
 * 複数の具体実装により異なる形式（固定値、定数、SQL参照、ジャーナル参照など）に対応可能とし、
 * 拡張性の高い電文生成処理を実現します。
 * </p>
 *
 * <p>
 * 本インターフェースは {@link jp.co.nikkiso.ntss.coop_api.telegram.factory.TelegramFragmentFactory}
 * によって動的に選択され、該当する式を処理できるプロセッサに委譲されます。
 * </p>
 *
 * @see jp.co.nikkiso.ntss.coop_api.telegram.factory.TelegramFragmentFactory
 */
public interface ValueProcessor {

    /**
     * 与えられた式がこのプロセッサで処理可能かどうかを判定します。
     *
     * @param expression {@code Item.getValue()} から得られる文字列式
     * @return 対応可能な場合は {@code true}、それ以外は {@code false}
     */
    boolean supports(String expression);

    /**
     * 指定された式を解析・評価し、最終的な出力値（電文の1項目）を生成します。
     *
     * @param expression {@code Item.getValue()} から得られた式
     * @param item       対象の {@link Item} オブジェクト
     * @param context    電文生成時の文脈情報
     * @return 出力対象の文字列（null不可）
     */
    String process(String expression, Item item, ProcessingContext context);
}
