package jp.co.nikkiso.ntss.coop_api.telegram.generator;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.coop_api.telegram.TelegramFormat;
import jp.co.nikkiso.ntss.coop_api.telegram.builder.TelegramBuilder;
import jp.co.nikkiso.ntss.coop_api.telegram.context.TelegramContext;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramLayoutValidator;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramLogger;
import jp.co.nikkiso.ntss.coop_api.telegram.model.Telegram;
import jp.co.nikkiso.ntss.coop_api.telegram.model.TelegramDump;
import jp.co.nikkiso.ntss.core.entity.xml.Item;

/**
 * {@code CsvTelegramGenerator} は {@link TelegramGenerator} の CSV形式に対応する実装です。
 *
 * <p>
 * 指定された {@link TelegramContext} に基づき、適切な {@link TelegramBuilder} を選択して電文を生成し、
 * 電文を区切り文字で結合して文字列化した結果を {@link TelegramDump} に格納して返します。
 * 複数ファイルの場合は、区切りヘッダ（例: "------ filename ------"）を付与することで分離可能な出力を行います。
 * </p>
 *
 * <p>
 * 本クラスは Spring 管理下の Bean であり、他のコンポーネントから DI される構成を前提としています。
 * </p>
 */
@Component
public class CsvTelegramGenerator implements TelegramGenerator {

    private final TelegramLogger logger;
    private final List<TelegramBuilder> builders;
    private final TelegramLayoutValidator layoutValidator;

    /**
     * コンストラクタ。必要な依存コンポーネントを注入します。
     *
     * @param builders        {@link TelegramBuilder} の一覧（CSV単一/複数ファイル対応）
     * @param layoutValidator レイアウトバリデーション処理クラス
     * @param logger          電文生成処理用のロガー
     */
    public CsvTelegramGenerator(List<TelegramBuilder> builders,
            TelegramLayoutValidator layoutValidator,
            TelegramLogger logger) {
        this.logger = logger;
        this.builders = builders;
        this.layoutValidator = layoutValidator;
    }

    /**
     * 指定された {@link TelegramContext} に基づき、電文ファイル出力用の {@link TelegramDump} を構築します。
     *
     * @param context 電文生成対象となる処理コンテキスト
     * @return {@link TelegramDump} オブジェクト（ファイルパス・ダンプ文字列を含む）
     * @throws UnsupportedOperationException 対応するビルダーが存在しない場合
     */
    @Override
    public TelegramDump generate(TelegramContext context) {
        logger.debug(getClass(), context.getLayout().getFacilityCd(), "generate() begin");

        validateLayout(context);

        logger.debug(getClass(), context.getLayout().getFacilityCd(), "電文構築処理開始");
        List<Telegram> telegrams = buildTelegrams(context);
        logger.info(getClass(), context.getLayout().getFacilityCd(), "電文構築完了。件数: %d", telegrams.size());

        String dumpPath = generateDumpPath(telegrams, context);
        logger.info(getClass(), context.getLayout().getFacilityCd(), "ダンプファイルパス: %s",
                dumpPath != null ? dumpPath : "null");

        String dumpString = formatTelegrams(telegrams, context);

        TelegramDump dump = TelegramDump.builder()
                .dumpPath(dumpPath)
                .dumpString(dumpString)
                .build();

        logger.debug(getClass(), context.getLayout().getFacilityCd(), "generate() dump <=: [%s]", dump);
        logger.debug(getClass(), context.getLayout().getFacilityCd(), "generate() end");
        return dump;
    }

    /**
     * 電文レイアウトの構成内容に対する妥当性検証を行います。
     *
     * @param context 検証対象の電文コンテキスト
     */
    private void validateLayout(TelegramContext context) {
        logger.debug(getClass(), context.getLayout().getFacilityCd(), "レイアウトバリデーション開始");
        List<Item> itemList = context.getRoot().getItemList();
        layoutValidator.validate(itemList);
        logger.debug(getClass(), context.getLayout().getFacilityCd(), "レイアウトバリデーション完了");
    }

    /**
     * {@link TelegramBuilder} 群から対応可能なものを選び、電文を構築します。
     *
     * @param context コンテキスト
     * @return 構築された電文のリスト
     * @throws UnsupportedOperationException 対応するビルダーが見つからなかった場合
     */
    private List<Telegram> buildTelegrams(TelegramContext context) {
        logger.debug(getClass(), context.getLayout().getFacilityCd(), "ビルダー選定開始");

        return builders.stream()
                .filter(b -> b.supports(context))
                .findFirst()
                .map(builder -> {
                    logger.info(getClass(), context.getLayout().getFacilityCd(), "ビルダー選定成功: %s",
                            builder.getClass().getSimpleName());
                    return builder.build(context);
                })
                .orElseThrow(() -> {
                    logger.error(getClass(), context.getLayout().getFacilityCd(), "対応するビルダーが見つかりません");
                    return new UnsupportedOperationException("対応する電文生成処理が見つかりません");
                });
    }

    /**
     * ファイル名を {@code fileNameDelimiter} で連結して出力ファイル名（ダンプパス）を生成します。
     *
     * @param telegrams 出力対象の電文リスト
     * @param context   区切り文字定義などを含むコンテキスト
     * @return 出力ファイル名（複数の場合は連結形式）、または null
     */
    private String generateDumpPath(List<Telegram> telegrams, TelegramContext context) {
        List<String> filePaths = telegrams.stream()
                .map(t -> t.getFilePathString())
                .toList();

        String dumpPath = (filePaths.size() == 1 && !StringUtils.hasText(filePaths.get(0)))
                ? null
                : String.join(context.getFileNameDelimiter(), filePaths);

        logger.debug(getClass(), null, "生成されたダンプパス: %s", dumpPath != null ? dumpPath : "null");
        return dumpPath;
    }

    /**
     * 電文の中身（body）を出力形式に整形して連結します。
     *
     * @param telegrams 出力対象の電文リスト
     * @param context   区切り文字やヘッダー定義を含むコンテキスト
     * @return 整形された CSV電文出力（複数ファイルも対応）
     */
    private String formatTelegrams(List<Telegram> telegrams, TelegramContext context) {
        logger.debug(getClass(), context.getLayout().getFacilityCd(), "電文整形処理開始");

        boolean isSingle = telegrams.size() == 1;
        String result = telegrams.stream()
                .map(t -> formatTelegram(t, isSingle, context))
                .collect(Collectors.joining(System.lineSeparator()));

        logger.debug(getClass(), context.getLayout().getFacilityCd(), "電文整形処理完了");
        return result;
    }

    /**
     * 各電文をフォーマットルールに基づいて整形します。
     * 複数ファイルの場合はファイル名ヘッダーを付与します。
     *
     * @param telegram 対象の電文
     * @param isSingle 単一電文かどうか
     * @param context  区切り文字やヘッダ形式を含むコンテキスト
     * @return 整形済みの電文テキスト
     */
    private String formatTelegram(Telegram telegram, boolean isSingle, TelegramContext context) {

        String body = String.join(System.lineSeparator(), telegram.getRecordValues(context.getDelimiter()));
        String result = isSingle
                ? body
                : String.format(context.getFileSplitDelimiterFormat(), telegram.getFilePathString())
                        + System.lineSeparator()
                        + body;

        logger.debug(getClass(), null, "整形済み電文（%s）: %s", telegram.getFilePathString(), result);

        return result;
    }

    /**
     * このクラスが対応する電文形式（CSV）を返します。
     *
     * @return {@link TelegramFormat#CSV}
     */
    @Override
    public TelegramFormat getSupportedFormat() {
        return TelegramFormat.CSV;
    }
}
