package jp.co.nikkiso.ntss.device_edge.packet;

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
   * 装置登録
   */
  ADD_DEV,
  // add 治療記録用データと治療状況用データの登録先を振分けにする --趙-- start
  /**
   * 自己診断結果(通信共通プロトコルV3、V4)
   */
  C_RMN,
  /**
   * 自己診断結果(日機装装置(NX通信含む))
   */
  RMN
  // add 治療記録用データと治療状況用データの登録先を振分けにする --趙-- end
}
