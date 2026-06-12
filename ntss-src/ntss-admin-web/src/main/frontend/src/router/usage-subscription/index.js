// 機能名
import { FUNC_USAGE_SUBSCRIPTION_JPN_NAME } from "@/constants/function-code";
// パンくず特定キー
import { HISTORY_KEY_USAGE_SUBSCRIPTION } from "@/router/usage-subscription/HistoryKeyConstants";
// 利用申込
import UsageSubscriptionView from "@/views/usage-subscription/UsageSubscriptionView";

const USAGE_SUBSCRIPTION = {
  path: "",
  name: "usage-subscription",
  component: UsageSubscriptionView,
  meta: {
    title: FUNC_USAGE_SUBSCRIPTION_JPN_NAME,
    depth: 1,
    historyKey: HISTORY_KEY_USAGE_SUBSCRIPTION
  }
};
// 
export default [USAGE_SUBSCRIPTION];
