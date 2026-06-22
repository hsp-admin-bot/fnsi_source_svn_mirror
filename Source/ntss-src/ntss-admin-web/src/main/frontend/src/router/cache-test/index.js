/**
 * キャッシュテストページ用ルーティング設定
 */
// 機能名
import { FUNC_CACHE_TEST_JPN_NAME } from "@/constants/function-code";

// パンくず特定キー
import { HISTORY_KEY_CACHE_TEST } from "@/router/cache-test/HistoryKeyConstants";

// キャッシュテスト
import CacheTestView from "@/views/cache-test/CacheTestView";

// キャッシュテスト
const CACHE_TEST = {
  path: "cache-test",
  name: "cache-test",
  component: CacheTestView,
  meta: {
    title: FUNC_CACHE_TEST_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_CACHE_TEST
  }
};

/* ----- キャッシュテスト ルーティング設定 --- */
export default [CACHE_TEST];
