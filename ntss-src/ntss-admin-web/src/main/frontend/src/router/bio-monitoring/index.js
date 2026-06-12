/**
 * 生体モニタリング用ルーティング設定
 */
// 機能名
import {
  FUNC_MONITORING_JPN_NAME,
  FUNC_MONITORING_DETAIL_JPN_NAME
} from "@/constants/function-code";

// 生体モニタリング
import BioMonitoringView from "@/pages/BioMonitoringPage";
// 生体モニタリング詳細
import BioMonitoringDetailView from "@/pages/BioMonitoringDetailPage";

const BIO_MONITORING_DETAIL = {
  path: "detail",
  name: "bio-monitoring-detail",
  component: BioMonitoringDetailView,
  meta: {
    title: FUNC_MONITORING_DETAIL_JPN_NAME,
    depth: 2
  }
};
const BIO_MONITORING = {
  path: "list",
  name: "bio-monitoring",
  component: BioMonitoringView,
  meta: {
    title: FUNC_MONITORING_JPN_NAME,
    depth: 1
  },
  children: [BIO_MONITORING_DETAIL]
};

/* ----- 生体モニタリング ルーティング設定 --------- */
export default [BIO_MONITORING];
