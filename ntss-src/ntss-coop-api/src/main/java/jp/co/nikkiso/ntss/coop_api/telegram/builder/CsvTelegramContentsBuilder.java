package jp.co.nikkiso.ntss.coop_api.telegram.builder;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.context.TelegramContext;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramLogger;
import jp.co.nikkiso.ntss.coop_api.telegram.model.Fragment;
import jp.co.nikkiso.ntss.coop_api.telegram.model.Telegram;
import jp.co.nikkiso.ntss.coop_api.telegram.processor.tag.ItemProcessor;
import jp.co.nikkiso.ntss.core.entity.xml.File;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.entity.xml.Occ;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

/**
 * CSV形式の電文を構築するビルダー実装です。
 * 本クラスはXMLレイアウト情報に基づき、各Itemを適切なProcessorで処理し、Telegramを構築します。
 */
@Component
public class CsvTelegramContentsBuilder implements TelegramBuilder {

        @Autowired
        private TelegramLogger logger;

        private final List<ItemProcessor<Fragment>> itemProcessors;

        /**
         * コンストラクタ。
         * 
         * @param itemProcessors 各種 Item の処理戦略を提供するプロセッサ群
         */
        public CsvTelegramContentsBuilder(List<ItemProcessor<Fragment>> itemProcessors) {
                this.itemProcessors = itemProcessors;
        }

        @Override
        public List<Telegram> build(TelegramContext context) {
                logDebug(context, "build() begin");
                logDebug(context, "context.getRoot().getValue() :=> [%s]", context.getRoot().getValue());
                
                List<Fragment> fragments = buildFragments(context);
                logDebug(context, "build() completed. Total fragments: %d", fragments.size());

                return Collections.singletonList(
                                Telegram.build(builder -> builder.fileName(null)
                                                .addRecords(Collections.singletonList(fragments))));
        }

        @Override
        public boolean supports(TelegramContext context) {
                boolean supported = context.getRoot().getItemList().stream().anyMatch(this::isSupportedItem);
                logDebug(context, "supports() evaluated. result=%s", supported);
                return supported;
        }

        /**
         * 各 Item を処理し、Fragment のリストを構築します。
         * 
         * @param context TelegramContext
         * @return Fragment のリスト
         */
        private List<Fragment> buildFragments(TelegramContext context) {
                List<Fragment> fragments = new ArrayList<>();
                for (Item item : context.getRoot().getItemList()) {
                        Optional<ItemProcessor<Fragment>> processorOpt = findProcessor(item);
                        if (processorOpt.isPresent()) {
                                List<Fragment> processed = processItem(processorOpt.get(), item, context);
                                fragments.addAll(processed);
                        } else {
                                logWarn(context, "Item [%s] を処理できる ItemProcessor が見つかりませんでした。", item.getName());
                        }
                }
                return fragments;
        }

        /**
         * Item に対応する Processor を検索します。
         * 
         * @param item 処理対象 Item
         * @return 対応する Processor（存在しない場合は empty）
         */
        private Optional<ItemProcessor<Fragment>> findProcessor(Item item) {
                return itemProcessors.stream()
                                .filter(p -> p.supports(item))
                                .findFirst();
        }

        /**
         * ItemProcessor を使って Item を処理します。
         * 
         * @param processor Processor
         * @param item      Item
         * @param context   TelegramContext
         * @return 生成された Fragment のリスト
         */
        private List<Fragment> processItem(ItemProcessor<Fragment> processor, Item item, TelegramContext context) {
                ProcessingContext processingContext = ProcessingContext.builder()
                                .telegramContext(context)
                                .detail(null)
                                .sqlCode(null)
                                .dataSetResult(null)
                                .dataSetResultMap(context.getDataSetResultMap())
                                .build();

                List<Fragment> fragments = processor.process(item, processingContext);
                logDebug(context, "Item [%s] に対して %d 件の Fragment を生成しました。", item.getName(), fragments.size());
                return fragments;
        }

        /**
         * 指定された Item が処理対象であるかどうかを判定します。
         * 
         * @param item Item
         * @return true の場合、処理対象
         */
        private boolean isSupportedItem(Item item) {
                return (item instanceof Item && !(item instanceof Occ) && !(item instanceof File))
                                || (item instanceof Occ && !(item instanceof File));
        }

        /**
         * デバッグログを出力します。
         * 
         * @param context コンテキスト
         * @param message メッセージ
         * @param args    パラメータ
         */
        private void logDebug(TelegramContext context, String message, Object... args) {
                logger.debug(getClass(), context.getLayout().getFacilityCd(), message, args);
        }

        /**
         * 警告ログを出力します。
         * 
         * @param context コンテキスト
         * @param message メッセージ
         * @param args    パラメータ
         */
        private void logWarn(TelegramContext context, String message, Object... args) {
                logger.warn(getClass(), context.getLayout().getFacilityCd(), message, args);
        }
}
