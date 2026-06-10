package jp.co.nikkiso.ntss.coop_api.telegram.processor.tag;

import jp.co.nikkiso.ntss.coop_api.telegram.model.Fragment;

/**
 * Fragment（電文断片）を生成する ItemProcessor のマーカーインタフェース。
 *
 * List<ItemProcessor<?>> のようなワイルドカード混在による型不一致を避けるため、
 * Fragment用はこの型で束ねる。
 */
public interface FragmentItemProcessor extends ItemProcessor<Fragment> {
    // marker interface（メソッド追加なし）
}