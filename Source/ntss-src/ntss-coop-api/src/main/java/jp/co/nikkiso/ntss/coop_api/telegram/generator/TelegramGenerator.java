package jp.co.nikkiso.ntss.coop_api.telegram.generator;

import jp.co.nikkiso.ntss.coop_api.telegram.TelegramFormat;
import jp.co.nikkiso.ntss.coop_api.telegram.context.TelegramContext;
import jp.co.nikkiso.ntss.coop_api.telegram.model.TelegramDump;

/**
 * 電文生成処理を定義する戦略インタフェースです。
 *
 * <p>
 * 各種フォーマット（CSV、XML、TEXTなど）に応じて異なる実装クラスがこのインタフェースを実装します。<br>
 * 呼び出し元は {@link TelegramGeneratorFactory} を通じてフォーマットに対応した具象クラスを取得し、
 * {@link #generate(TelegramContext)} を用いて電文生成処理を実行します。
 * </p>
 *
 * <p>
 * 新しい電文フォーマットを追加する際は新規クラスを実装すれば既存コードへの影響を最小限に抑えることができます。
 * </p>
 *
 * @see TelegramContext
 * @see TelegramDump
 * @see TelegramFormat
 * @see jp.co.nikkiso.ntss.coop_api.telegram.factory.TelegramGeneratorFactory
 */
public interface TelegramGenerator {

    /**
     * 与えられた {@link TelegramContext} に基づいて電文を生成します。
     *
     * <p>
     * 電文の内容、ファイル名、区切り形式、フォーマット固有のルールに従って、
     * 出力形式に整形された {@link TelegramDump} を生成して返却します。
     * </p>
     *
     * @param context 電文生成に必要な入力情報（レイアウト、ジャーナル、出力形式など）
     * @return 出力対象の電文文字列およびファイル名を保持する {@link TelegramDump}
     * @throws UnsupportedOperationException 対応できない形式や不正なコンテキストが渡された場合
     */
    TelegramDump generate(TelegramContext context);

    /**
     * このジェネレータがサポートしている電文フォーマットを返却します。
     *
     * @return 対応する {@link TelegramFormat}（例: CSV, XML）
     */
    TelegramFormat getSupportedFormat();
}
