package jp.co.nikkiso.ntss.coop_api.telegram.processor.tag;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.function.BiFunction;

import jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService;
import jp.co.nikkiso.ntss.coop_api.telegram.context.ProcessingContext;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.SharedSysdateStore;
import jp.co.nikkiso.ntss.coop_api.telegram.helper.TelegramHelper;
import jp.co.nikkiso.ntss.coop_api.telegram.model.Fragment;
import jp.co.nikkiso.ntss.coop_api.telegram.processor.selector.FragmentItemProcessorSelector;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.xml.File;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.entity.xml.Occ;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.entity.xml.Record;

/**
 * 電文項目プロセッサの共通基底クラスです。
 * エラーログや基本フローを提供します。
 *
 * @param <T> 処理結果の型
 */
public abstract class ItemProcessorBase<T> implements ItemProcessor<T> {
    protected final TelegramHelper helper;
    protected final ConvertCommonService convertCommonService;
    protected final FragmentItemProcessorSelector fragmentItemProcessorSelector;

    protected ItemProcessorBase(TelegramHelper helper, ConvertCommonService convertCommonService, FragmentItemProcessorSelector fragmentItemProcessorSelector) {
        this.helper = helper;
        this.convertCommonService = convertCommonService;
        this.fragmentItemProcessorSelector = fragmentItemProcessorSelector;
    }

    @Override
    public List<T> process(Item item, ProcessingContext context) {
        try {
            return doProcess(item, context);
        } catch (NtssException e) {
            throw e;
        }
    }

    /**
     * 実際の処理内容を実装するメソッドです。
     *
     * @param item    対象項目
     * @param context 実行コンテキスト
     * @return 処理結果
     */
    protected abstract List<T> doProcess(Item item, ProcessingContext context);

    /**
     * 処理コンテキストを構築します。
     *
     * @param row         データセットの1行
     * @param occ         対象の Occ 要素
     * @param baseContext 基本コンテキスト
     * @param detail      明細レイアウト定義
     * @return 処理コンテキスト
     */
    protected ProcessingContext buildRowContext(Map<String, Object> row, int rowIndex, Occ occ,
            ProcessingContext baseContext, MstCoopLayoutDetail detail) {
        boolean useSharedSysdate = detail.getCoopSettingRoot().getUseSharedSysdate();
        SharedSysdateStore.Key currentSharedSysdateKey = useSharedSysdate
                ? new SharedSysdateStore.Key(detail.getCoopSettingRoot().getName(), rowIndex)
                : baseContext.getCurrentSharedSysdateKey();
        helper.putSharedSysdate(baseContext, rowIndex, detail);
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni --start */
        Map<String, List<Map<String, Object>>> dataSetResultMap = helper
                .fetchDetailCoopExtSettingData(detail.getCoopExtSetting(), baseContext.getJournal(), row,
                        baseContext.getTelegramContext().getCoopIni());
        /* upd by chamaojia 2026-04-24 [10959] add param coopIni --end */
        return ProcessingContext.builder()
                .telegramContext(baseContext.getTelegramContext())
                .detail(detail)
                .currentSharedSysdateKey(currentSharedSysdateKey)
                .sqlCode(occ.getSqlCode())
                .dataSetResult(row)
                .dataSetResultMap(dataSetResultMap)
                .build();
    }

    /**
     * 順序を保持したまま並列で処理を実行します。
     *
     * @param inputs 入力リスト
     * @param task   処理関数（例：row -> processRow(row, ...)）
     * @param <I>    入力の型
     * @param <O>    出力の型
     * @return 出力結果リスト（入力順を保持）
     */
    protected <I, O> List<O> runParallelInOrder(List<I> inputs, BiFunction<I, Integer, O> task) {
        int size = inputs.size();
        ExecutorService executor = Executors.newFixedThreadPool(Runtime.getRuntime().availableProcessors()); // 個別プールを使用
        List<Future<O>> futures = new ArrayList<>(size);
        for (int index = 0; index < inputs.size(); index++) {
            final int currentIndex = index;
            futures.add(executor.submit(() -> task.apply(inputs.get(currentIndex),
                    currentIndex)));
        }

        List<O> results = new ArrayList<>(Collections.nCopies(size, null));

        try {
            for (int i = 0; i < size; i++) {
                results.set(i, futures.get(i).get());
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            throw new RuntimeException("スレッドが割り込まれました", e);
        } catch (ExecutionException e) {
            Throwable cause = e.getCause();
            String errorDetail = String.format(
                    "並列タスク中に例外が発生しました。[例外=%s, メッセージ=%s, 発生箇所=%s]",
                    cause != null ? cause.getClass().getName() : "不明",
                    cause != null ? cause.getMessage() : "詳細なし",
                    cause != null && cause.getStackTrace().length > 0
                            ? cause.getStackTrace()[0].toString()
                            : "不明");
            throw new RuntimeException(errorDetail, cause);
        } finally {
            executor.shutdown();
        }
        return results;

    }

    /**
     * レイアウト情報に基づき、送信用電文の一部を作成します。
     *
     * @param detail  現在処理対象の明細レイアウト
     * @param context 処理に必要な文脈情報（TelegramContext＋1行分のデータなど）
     * @return 電文断片のリスト（1レイアウト内のすべての項目分）
     */
    protected List<Fragment> createDetailFragments(MstCoopLayoutDetail detail, ProcessingContext context) {
        List<Fragment> fragments = new ArrayList<>();
        List<Item> items = Optional
                .ofNullable(detail.getCoopSettingRoot().getItemList())
                .orElseGet(List::of)
                .stream()
                .filter(item -> (item instanceof Item || item instanceof Occ) && !(item instanceof File)
                        && !(item instanceof Record))
                .toList();

        for (Item item : items) {
            // Item に応じた Processor を選択
            FragmentItemProcessor processor = fragmentItemProcessorSelector.select(item);
            fragments.addAll(processor.process(item, context));
        }

        return fragments;
    }

    /**
     * オカレンスの repeat 属性に基づき、データ不足分を補完するパディング電文を生成します。
     * <p>
     * 実データ数が repeat 指定数に満たない場合、ブランク用レイアウトを取得し、
     * 空データで電文断片を追加生成します。
     * </p>
     *
     * @param occ         オカレンス要素（repeat や len の条件を持つ）
     * @param repeatCount repeat属性の値（ループ回数）
     * @param actualCount 実際に取得されたデータ件数
     * @param baseContext 親コンテキスト（ジャーナルや元のレイアウト情報など）
     * @return ブランクで構成された電文断片のリスト
     */
    protected List<Fragment> generatePadding(Occ occ, int repeatCount, int actualCount, ProcessingContext baseContext) {
        List<Fragment> paddings = new ArrayList<>();
        if (occ.getLen() != 0 || actualCount >= repeatCount)
            return paddings;

        MstCoopLayoutDetail blankLayout = convertCommonService.getMstCoopLayoutDetailBySub(
                baseContext.getJournal().getFacilityCd(),
                baseContext.getJournal().getDirection(),
                baseContext.getJournal().getCoopCd(),
                baseContext.getJournal().getCoopVersion(),
                occ.getDetail(),
                "blank");

        for (int i = 0; i < repeatCount - actualCount; i++) {
            ProcessingContext blankContext = ProcessingContext.builder()
                    .telegramContext(baseContext.getTelegramContext())
                    .detail(blankLayout)
                    .sqlCode(occ.getSqlCode())
                    .dataSetResult(null)
                    .dataSetResultMap(baseContext.getDataSetResultMap())
                    .build();
            paddings.addAll(createDetailFragments(blankLayout, blankContext));
        }

        return paddings;
    }
}