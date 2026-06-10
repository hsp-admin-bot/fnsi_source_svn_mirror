package jp.co.nikkiso.ntss.core.dto.MstListCompose.request;

public enum MstListComposeSourceType {
  FIXED,         // 固定リスト
  MST,           // 単一MST
  MST_COMBINED,  // 複数MST統合
  MAIN_DISTINCT  // 主リストまたはMSTの重複排除
}
