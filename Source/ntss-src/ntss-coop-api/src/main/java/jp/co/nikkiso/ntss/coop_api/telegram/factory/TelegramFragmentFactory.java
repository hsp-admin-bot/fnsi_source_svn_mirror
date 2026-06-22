package jp.co.nikkiso.ntss.coop_api.telegram.factory;

import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.processor.value.ValueProcessor;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * {@code TelegramFragmentFactory} は、電文構成において {@link ValueProcessor} の一覧から
 * 対応可能なプロセッサを選択し、指定された表現式に基づいて文字列断片を生成するファクトリクラスです。
 *
 * <p>
 * {@link Item#getValue()} に定義された表現（例えば "$JOURNAL.ordNo" や "dataset:1234.name" など）を解釈し、
 * 最適な {@link ValueProcessor} を選択して実行することで、電文出力に必要な文字列要素（フラグメント）を構築します。
 * </p>
 *
 * <p>
 * 本クラスは {@code Spring Component} として定義されており、アプリケーション起動時に
 * {@link ValueProcessor} 実装群が自動的にインジェクトされます。
 * </p>
 *
 *
 * @see ValueProcessor
 * @see ProcessingContext
 * @see Item
 */
@Component
public class TelegramFragmentFactory {

    /** 利用可能な ValueProcessor 実装の一覧（Spring により自動注入） */
    private final List<ValueProcessor> processors;

    /**
     * コンストラクタ。
     * <p>
     * Spring により {@link ValueProcessor} 実装クラスのリストが注入されます。
     * </p>
     *
     * @param processors 使用可能な {@link ValueProcessor} の一覧
     */
    public TelegramFragmentFactory(List<ValueProcessor> processors) {
        this.processors = processors;
    }

    /**
     * 指定された式に最も適した {@link ValueProcessor} を選択し、電文出力文字列（フラグメント）を生成します。
     *
     * @param expression 対象の表現式（例: "$JOURNAL.ordNo", "dataset:1001.name" など）
     * @param item       現在処理中の {@link Item} 情報（null 不可）
     * @param context    電文処理に関する追加文脈情報（null 不可）
     * @return 指定式により生成された電文文字列（フラグメント）
     * @throws UnsupportedOperationException 対応する {@link ValueProcessor} が見つからない場合
     */
    public String createFragment(String expression, Item item, ProcessingContext context) {
        return processors.stream()
                .filter(p -> p.supports(expression))
                .findFirst()
                .orElseThrow(() ->
                        new UnsupportedOperationException("対応する電文生成処理が見つかりません: " + expression))
                .process(expression, item, context);
    }
}
