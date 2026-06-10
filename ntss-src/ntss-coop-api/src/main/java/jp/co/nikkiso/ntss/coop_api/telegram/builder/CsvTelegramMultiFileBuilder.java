package jp.co.nikkiso.ntss.coop_api.telegram.builder;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.context.TelegramContext;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.SharedSysdateStore;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramLogger;
import jp.co.nikkiso.ntss.coop_api.telegram.model.Telegram;
import jp.co.nikkiso.ntss.coop_api.telegram.processor.tag.ItemProcessor;
import jp.co.nikkiso.ntss.core.entity.xml.File;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.exception.NtssException;

/**
 * 複数ファイル出力形式のCSV電文を構築するビルダーです。
 * 各 File 要素ごとに適切な Processor を用いて Telegram を生成します。
 */
@Component
public class CsvTelegramMultiFileBuilder implements TelegramBuilder {

        @Autowired
        private TelegramLogger logger;

        private final List<ItemProcessor<Telegram>> itemProcessors;

        /**
         * コンストラクタ
         * 
         * @param itemProcessors 各 File に対応する電文生成処理戦略
         */
        public CsvTelegramMultiFileBuilder(List<ItemProcessor<Telegram>> itemProcessors) {
                this.itemProcessors = itemProcessors;
        }

        @Override
        public List<Telegram> build(TelegramContext context) {
                logDebug(context, "build() begin");
                logDebug(context, "context.getRoot().getValue() :=> [%s]", context.getRoot().getValue());
                List<Telegram> telegrams = Collections.synchronizedList(new ArrayList<>());
                ExecutorService executor = Executors.newFixedThreadPool(context.getRoot().getItemList().size());
                List<Future<List<Telegram>>> futures = context.getRoot().getItemList().stream()
                                .map(item -> executor.submit(() -> processItem(context, item)
                                                .orElse(Collections.emptyList())))
                                .collect(Collectors.toList());
                try {
                        for (Future<List<Telegram>> future : futures) {
                                try {
                                        List<Telegram> telegram = future.get();
                                        telegrams.addAll(telegram);
                                } catch (ExecutionException e) {
                                        // ExecutionExceptionの場合、実際の原因例外を取得
                                        Throwable cause = e.getCause();
                                        logger.error(getClass(), context.getLayout().getFacilityCd(),
                                                        "Cause stacktrace: %s", cause);
                                        String errorDetail = String.format(
                                                        "並列処理中にエラーが発生しました。原因: %s, メッセージ: %s",
                                                        cause != null ? cause.getClass().getName() : "不明",
                                                        cause != null ? cause.getMessage() : "詳細なし");
                                        throw new NtssException(errorDetail, (cause != null ? cause : e));
                                } catch (InterruptedException e) {
                                        // 現在のスレッドの割り込みステータスを復元
                                        Thread.currentThread().interrupt();
                                        // タイムアウトによってスレッドがinterruptされた可能性があるのでExceptionをThrowせず、ログ出力のみに留める
                                        logger.error(getClass(), context.getLayout().getFacilityCd(),
                                                        "並列処理が中断されました。スレッド: " + Thread.currentThread().getName());
                                }
                        }
                        logDebug(context, "build() end. Total telegrams: %d", telegrams.size());
                } finally {
                        executor.shutdown();
                }
                return telegrams;
        }

        @Override
        public boolean supports(TelegramContext context) {
                boolean hasFile = context.getRoot().getItemList().stream()
                                .anyMatch(item -> item instanceof File);

                logDebug(context, "supports() evaluated. hasFile=%s => result=%s", hasFile, hasFile);
                return hasFile;
        }

        /**
         * Item を処理し、Telegram を生成します。
         * 
         * @param context TelegramContext
         * @param item    処理対象 Item
         * @return 生成された Telegram のリスト（Optional）
         */
        private Optional<List<Telegram>> processItem(TelegramContext context, Item item) {
                ItemProcessor<Telegram> processor = findProcessor(item).orElseThrow(() -> new NtssException(
                                "Item [" + item.getName() + "] に対応する ItemProcessor が見つかりません。"));
                List<Telegram> partialTelegrams = processor.process(item, buildProcessingContext(context));
                logDebug(context, "Item [%s] に対して %d 件の Telegram を生成しました。", item.getName(),
                                partialTelegrams.size());
                return Optional.of(partialTelegrams);
        }

        /**
         * Item に対応する Processor を検索します。
         * 
         * @param item 対象 Item
         * @return 対応する Processor（Optional）
         */
        private Optional<ItemProcessor<Telegram>> findProcessor(Item item) {
                return itemProcessors.stream()
                                .filter(p -> p.supports(item))
                                .findFirst();
        }

        /**
         * ProcessingContext を構築します。
         * 
         * @param context TelegramContext
         * @return ProcessingContext
         */
        private ProcessingContext buildProcessingContext(TelegramContext context) {
                boolean useSharedSysdate = context.getLayout().getCoopSettingRoot().getUseSharedSysdate();
                SharedSysdateStore.Key currentSharedSysdateKey = useSharedSysdate
                                ? new SharedSysdateStore.Key(context.getLayout().getCoopSettingRoot().getName(), 0)
                                : null;
                return ProcessingContext.builder()
                                .telegramContext(context)
                                .detail(null)
                                .sqlCode(null)
                                .dataSetResult(null)
                                .dataSetResultMap(context.getDataSetResultMap())
                                .currentSharedSysdateKey(currentSharedSysdateKey)
                                .build();
        }

        /**
         * デバッグログ出力。
         * 
         * @param context コンテキスト
         * @param message メッセージ
         * @param args    引数
         */
        private void logDebug(TelegramContext context, String message, Object... args) {
                logger.debug(getClass(), context.getLayout().getFacilityCd(), message, args);
        }
}
