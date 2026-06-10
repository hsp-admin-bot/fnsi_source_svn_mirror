package jp.co.nikkiso.ntss.coop_api.telegram.factory;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.telegram.TelegramFormat;
import jp.co.nikkiso.ntss.coop_api.telegram.generator.TelegramGenerator;

/**
 * {@code TelegramGeneratorFactory} は、指定された {@link TelegramFormat} に対応する
 * {@link TelegramGenerator} 実装を返すファクトリクラスです。
 * <p>
 * Spring Boot により {@code List<TelegramGenerator>} が自動的に注入され、
 * フォーマットごとの対応表（Map）として保持されます。
 * </p>
 *
 * <p>
 * このクラスは新たなフォーマット（例：XML, TEXT など）を追加する際にも、
 * {@link TelegramGenerator} の実装を追加するだけで拡張が可能です。
 * </p>
 *
 * <pre>{@code
 * TelegramGenerator generator = telegramGeneratorFactory.getGenerator(TelegramFormat.CSV);
 * List<Telegram> telegrams = generator.generate(context);
 * }</pre>
 *
 * @see TelegramGenerator
 * @see TelegramFormat
 */
@Component
public class TelegramGeneratorFactory {

    /** TelegramFormat → 対応する TelegramGenerator のマップ */
    private final Map<TelegramFormat, TelegramGenerator> generatorMap;

    /**
     * コンストラクタ。
     * <p>
     * Spring により登録された {@link TelegramGenerator} 一覧を受け取り、
     * 各 {@link TelegramFormat} に対応するマッピングを構築します。
     * </p>
     *
     * @param generators {@link TelegramGenerator} 実装群（自動注入される）
     */
    public TelegramGeneratorFactory(List<TelegramGenerator> generators) {
        this.generatorMap = generators.stream()
                .collect(Collectors.toMap(
                        TelegramGenerator::getSupportedFormat,
                        g -> g
                ));
    }

    /**
     * 指定されたフォーマットに対応する {@link TelegramGenerator} を返します。
     *
     * @param format 使用する電文フォーマット（例：CSV、XML）
     * @return 対応する {@link TelegramGenerator}
     * @throws IllegalArgumentException 対応するジェネレータが見つからなかった場合
     */
    public TelegramGenerator getGenerator(TelegramFormat format) {
        return Optional.ofNullable(generatorMap.get(format))
                .orElseThrow(() -> new IllegalArgumentException("対応する TelegramGenerator が見つかりません: " + format));
    }
}
