/**
 * 掲示板登録情報用ルーティング設定
 */
// 機能名
import {
  FUNC_BBS_INFO_JPN_NAME,
  FUNC_BBS_DETAILED_INFO_JPN_NAME
} from "@/constants/function-code";
// パンくず特定キー
import {
  HISTORY_KEY_BBS_INFO,
  HISTORY_KEY_BBS_DETAILED_INFO
} from "@/router/bbs-info/HistoryKeyConstants";
// 掲示板一覧情報
import BbsInfoView from "@/views/bbs-info/BbsInfoView";
// 掲示板詳細情報
import BbsDetailedInfoView from "@/views/bbs-info/BbsDetailedInfoView";
import BbsInfoMainView from "@/views/bbs-info/BbsInfoMainView";
 
export default [
  {
    path: "info",
    component: BbsInfoMainView,
    children: [
      {
        path: "",
        name: "bbs-info",
        component: BbsInfoView,
        meta: {
          title: FUNC_BBS_INFO_JPN_NAME,
          depth: 1,
          historyKey: HISTORY_KEY_BBS_INFO
        }
      },
      {
        path: "detail",
        name: "bbs-detailed-info",
        component: BbsDetailedInfoView,
        meta: {
          title: FUNC_BBS_DETAILED_INFO_JPN_NAME,
          depth: 2,
          historyKey: HISTORY_KEY_BBS_DETAILED_INFO
        }
      }
    ]
  }
];