package jp.co.nikkiso.ntss.admin_web.request.bloodPurify;

public enum EnumRcvDataKind {
  /**
   * 装置記録
   */
  LOG,
  /**
   * モニタデータ
   */
  MONITER,
  /**
   * 透析開始
   */
  MONITER_START,
  /**
   * 透析終了
   */
  MONITER_FINISH,
  /**
   * UFRC自己診断
   */
  MNT_UFRC_SELF,
  /**
   * 漏血テスト
   */
  MNT_BLEEDING,
  /**
   * 透析液流量自己診断
   */
  MNT_DIALYSIS_FLOW,
  /**
   * 濃度自己診断
   */
  MNT_CONCENTRATION,
  /**
   * 動作時間
   */
  MNT_TIME,
  /**
   * 配管テスト
   */
  PIPE_TEST,
  /**
   * 希釈テスト
   */
  DILUTION_TEST,
  /**
   * 稼働時間(動作時間)
   */
  USE_TIME,
  /**
   * 溶解記録
   */
  DISSOLUTION,

  /**
   * 装置記録(通信共通用)
   */
  C_LOG,
  /**
   * モニタデータ(通信共通用)
   */
  C_MONITER,
  /**
   * 稼働時間(通信共通V4用：ETRF)
   */
  C_USE_TIME,
  /**
   * 自己診断結果(通信共通V4用)
   */
  C_MNT_SELF,

  /**
   * 治療開始日時
   */
  BP_START,
  /**
   * 治療終了日時
   */
  BP_END,
  /**
   * 治療装置種別
   */
  BP_DEVICE_TYPE,
  /**
   * 最終モニタ値
   */
  // mod FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 start
  //BP_LAST_MONITOR
  BP_LAST_MONITOR,
  // mod FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 end
  // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 start
  /**
   * ログモニタ値
   */
  LOG_MONITOR
  // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 end
}
