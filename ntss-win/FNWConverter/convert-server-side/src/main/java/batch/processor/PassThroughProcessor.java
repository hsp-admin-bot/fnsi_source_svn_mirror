package batch.processor;

import org.springframework.batch.infrastructure.item.ItemProcessor;

/**
 * readerで読み取ったデータをwriterへ加工せず渡すprocessor
 * 渡す際にデータをログ出力
 */
public class PassThroughProcessor<T> implements ItemProcessor<T, T> {

    @Override
	public T process(T item) {
		return item;
    }
}
