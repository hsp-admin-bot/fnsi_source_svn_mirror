package jp.co.nikkiso.ntss.coop_api.telegram.builder;

import java.util.List;

import jp.co.nikkiso.ntss.coop_api.telegram.context.TelegramContext;
import jp.co.nikkiso.ntss.coop_api.telegram.model.Telegram;

/**
 * 電文を構築するためのビルダーインターフェースです。
 * <p>
 * 本インターフェースは、さまざまな形式（CSV、マルチファイルなど）の電文を構築するための共通契約を定義します。
 * 実装クラスは {@link TelegramContext} を解析し、適切な {@link Telegram} オブジェクトを生成する責務を持ちます。
 * </p>
 *
 * @see CsvTelegramContentsBuilder
 * @see CsvTelegramMultiFileBuilder
 */
public interface TelegramBuilder {

    /**
     * 指定された {@link TelegramContext} に基づいて、電文データ（{@link Telegram}）を構築します。
     *
     * @param context 電文構築に必要な情報を保持するコンテキスト
     * @return 構築された {@link Telegram} のリスト（単一または複数）
     */
    List<Telegram> build(TelegramContext context);

    /**
     * このビルダーが指定された {@link TelegramContext} に対応しているかどうかを判定します。
     *
     * @param context 判定対象の {@link TelegramContext}
     * @return 対応している場合は {@code true}
     */
    boolean supports(TelegramContext context);
}
