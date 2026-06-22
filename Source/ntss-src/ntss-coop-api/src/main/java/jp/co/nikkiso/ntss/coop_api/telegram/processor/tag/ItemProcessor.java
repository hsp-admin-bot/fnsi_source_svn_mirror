package jp.co.nikkiso.ntss.coop_api.telegram.processor.tag;

import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.core.entity.xml.Item;

import java.util.List;

/**
 * 各種 {@link Item} の処理を担当する戦略インタフェースです。
 * <p>
 * 電文生成処理において、Item の種類や属性に応じて適切な処理を実装クラスに委譲するために使用されます。
 * {@link #supports(Item)} で処理対象かどうかを判定し、{@link #process(Item, ProcessingContext)} で具体的な処理を実行します。
 * </p>
 *
 * @param <T> {@link Item} を処理した結果として返す要素の型（例: Telegram など）
 */
public interface ItemProcessor<T> {

    /**
     * このプロセッサが指定された {@link Item} を処理対象とするかを判定します。
     *
     * @param item 判定対象の {@link Item}
     * @return true の場合、このプロセッサが {@code item} の処理を担当する
     */
    boolean supports(Item item);

    /**
     * 指定された {@link Item} と {@link ProcessingContext} に基づいて、処理結果を生成します。
     * <p>
     * 処理結果の内容や件数は実装に依存します。結果として返されるリストには 0 件以上のデータが含まれる可能性があります。
     * </p>
     *
     * @param item    処理対象の {@link Item}
     * @param context 処理に必要な追加情報を保持する {@link ProcessingContext}
     * @return {@code item} を処理した結果（0 件以上のリスト）
     */
    List<T> process(Item item, ProcessingContext context);
}
