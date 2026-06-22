package jp.co.nikkiso.ntss.coop_api.telegram.processor.selector;

import java.util.List;

import org.springframework.core.annotation.AnnotationAwareOrderComparator;
import org.springframework.stereotype.Component;

import jp.co.nikkiso.ntss.coop_api.telegram.processor.tag.FragmentItemProcessor;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.exception.NtssException;


import java.util.concurrent.atomic.AtomicReference;

import org.springframework.beans.factory.ObjectProvider;

/**
 * Item に対応する FragmentItemProcessor を選択する Selector。
 *
 * 【ポイント】
 * - 起動時の循環参照（OccItemProcessor -> Selector -> List<Processor> -> OccItemProcessor）を避けるため、
 *   Processor一覧の注入を「遅延（実行時）」にする。
 * - Processor一覧は最初に必要になったタイミングで取得し、以後キャッシュして使い回す。
 * - 複数一致した場合の順序依存を避けるため @Order を尊重してソートする。
 */
@Component
public class FragmentItemProcessorSelector {

    private final ObjectProvider<List<FragmentItemProcessor>> processorsProvider;

    // 初回取得時にキャッシュ（起動時ではなく、最初のselect呼び出し時に確定させる）
    private final AtomicReference<List<FragmentItemProcessor>> cachedProcessors = new AtomicReference<>();

    public FragmentItemProcessorSelector(ObjectProvider<List<FragmentItemProcessor>> processorsProvider) {
        this.processorsProvider = processorsProvider;
    }

    public FragmentItemProcessor select(Item item) {
        List<FragmentItemProcessor> processors = getProcessors();

        return processors.stream()
                .filter(p -> p.supports(item))
                .findFirst()
                .orElseThrow(() -> new NtssException(
                        "対応するFragmentItemProcessorが見つかりません。itemName=" + item.getName()
                                + ", type=" + item.getClass().getSimpleName()));
    }

    private List<FragmentItemProcessor> getProcessors() {
        List<FragmentItemProcessor> current = cachedProcessors.get();
        if (current != null) {
            return current;
        }

        // ここで初めてProcessor一覧を取得（起動時じゃない）
        List<FragmentItemProcessor> loaded = processorsProvider.getObject();
        loaded.sort(AnnotationAwareOrderComparator.INSTANCE);

        cachedProcessors.compareAndSet(null, loaded);
        return cachedProcessors.get();
    }
}
